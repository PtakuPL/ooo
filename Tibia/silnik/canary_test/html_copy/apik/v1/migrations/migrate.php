#!/usr/bin/env php
<?php
declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "This script is CLI-only.\n");
    exit(1);
}

require_once dirname(__DIR__) . '/common.php';

/**
 * Usage:
 *   php migrate.php status
 *   php migrate.php rollout
 *   php migrate.php rollback <target_version>
 *
 * Examples:
 *   php migrate.php rollout
 *   php migrate.php rollback 2
 *   php migrate.php status
 */

function usage(): void {
    $msg = <<<TXT
Usage:
  php migrate.php status
  php migrate.php rollout
  php migrate.php rollback <target_version>

Examples:
  php migrate.php rollout
  php migrate.php rollback 2
  php migrate.php status

TXT;
    fwrite(STDERR, $msg);
}

/**
 * @return array<int, array{id:int,name:string,rollout:string,rollback:string}>
 */
function discoverMigrations(string $dir): array {
    $files = glob($dir . '/*_rollout.sql');
    if ($files === false) {
        throw new RuntimeException('Cannot scan migrations directory.');
    }

    $migrations = [];
    foreach ($files as $rolloutPath) {
        $base = basename($rolloutPath);
        if (!preg_match('/^(\d+)_([a-z0-9_]+)_rollout\.sql$/i', $base, $m)) {
            continue;
        }

        $id = (int)$m[1];
        $name = $m[1] . '_' . $m[2];
        $rollbackPath = $dir . '/' . $m[1] . '_' . $m[2] . '_rollback.sql';
        if (!is_file($rollbackPath)) {
            throw new RuntimeException("Missing rollback file for migration {$base}");
        }

        $migrations[$id] = [
            'id' => $id,
            'name' => $name,
            'rollout' => $rolloutPath,
            'rollback' => $rollbackPath,
        ];
    }

    ksort($migrations);
    return $migrations;
}

/**
 * @return array{id:int,name:string,applied_at:string}[]
 */
function fetchAppliedMigrations(mysqli $db): array {
    $rows = [];
    $sql = "SELECT id, name, applied_at FROM _migrations ORDER BY id ASC";
    $res = $db->query($sql);
    if ($res === false) {
        throw new RuntimeException("Cannot read _migrations: {$db->error}");
    }

    while ($row = $res->fetch_assoc()) {
        $rows[] = [
            'id' => (int)$row['id'],
            'name' => (string)$row['name'],
            'applied_at' => (string)$row['applied_at'],
        ];
    }
    $res->free();
    return $rows;
}

/**
 * @return array<int, array{id:int,name:string,applied_at:string}>
 */
function appliedMap(array $rows): array {
    $map = [];
    foreach ($rows as $row) {
        $map[$row['id']] = $row;
    }
    return $map;
}

function ensureMigrationsTable(mysqli $db): void {
    $sql = <<<SQL
CREATE TABLE IF NOT EXISTS `_migrations` (
    `id`         INT UNSIGNED NOT NULL,
    `name`       VARCHAR(128) NOT NULL,
    `applied_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
SQL;

    if (!$db->query($sql)) {
        throw new RuntimeException("Cannot ensure _migrations table: {$db->error}");
    }
}

function executeSqlFile(mysqli $db, string $path): void {
    $sql = file_get_contents($path);
    if ($sql === false) {
        throw new RuntimeException("Cannot read SQL file: {$path}");
    }

    if (!$db->multi_query($sql)) {
        throw new RuntimeException("SQL execution failed in {$path}: {$db->error}");
    }

    do {
        $result = $db->store_result();
        if ($result instanceof mysqli_result) {
            $result->free();
        }

        if (!$db->more_results()) {
            break;
        }

        if (!$db->next_result()) {
            throw new RuntimeException("SQL execution failed in {$path}: {$db->error}");
        }
    } while (true);
}

function printStatus(array $migrations, array $appliedRows): void {
    $applied = appliedMap($appliedRows);
    echo "Migration status\n";
    echo "----------------\n";
    foreach ($migrations as $id => $m) {
        $isApplied = isset($applied[$id]);
        $status = $isApplied ? 'APPLIED' : 'PENDING';
        $when = $isApplied ? $applied[$id]['applied_at'] : '-';
        printf("%3d  %-8s  %-28s  %s\n", $id, $status, $m['name'], $when);
    }

    $unknownApplied = array_diff(array_keys($applied), array_keys($migrations));
    if (!empty($unknownApplied)) {
        echo "\nApplied migrations without local files:\n";
        foreach ($unknownApplied as $id) {
            $row = $applied[$id];
            printf("  - %d (%s) at %s\n", $row['id'], $row['name'], $row['applied_at']);
        }
    }
}

function maybeEnableEventScheduler(mysqli $db): void {
    if (!$db->query("SET GLOBAL event_scheduler = ON")) {
        fwrite(
            STDERR,
            "[WARN] Could not enable event_scheduler automatically: {$db->error}\n" .
            "       Run as DBA if needed: SET GLOBAL event_scheduler = ON;\n"
        );
        return;
    }
    fwrite(STDOUT, "[INFO] event_scheduler enabled (SET GLOBAL event_scheduler = ON).\n");
}

function applyRollout(mysqli $db, array $migrations): void {
    $applied = appliedMap(fetchAppliedMigrations($db));
    $appliedAny = false;

    foreach ($migrations as $id => $migration) {
        if (isset($applied[$id])) {
            continue;
        }

        if ($id === 3) {
            maybeEnableEventScheduler($db);
        }

        echo "Applying {$migration['name']}...\n";
        executeSqlFile($db, $migration['rollout']);

        $applied = appliedMap(fetchAppliedMigrations($db));
        if (!isset($applied[$id])) {
            throw new RuntimeException(
                "Migration {$migration['name']} executed but not registered in _migrations."
            );
        }

        $appliedAny = true;
        echo "  OK\n";
    }

    if (!$appliedAny) {
        echo "No pending migrations.\n";
    }
}

function applyRollback(mysqli $db, array $migrations, int $targetVersion): void {
    $appliedRows = fetchAppliedMigrations($db);
    $applied = appliedMap($appliedRows);
    $appliedIds = array_keys($applied);
    rsort($appliedIds, SORT_NUMERIC);

    $rolledBackAny = false;
    foreach ($appliedIds as $id) {
        if ($id <= $targetVersion) {
            continue;
        }

        if (!isset($migrations[$id])) {
            throw new RuntimeException(
                "Cannot rollback migration {$id}: local rollback file not found."
            );
        }

        $migration = $migrations[$id];
        echo "Rolling back {$migration['name']}...\n";
        executeSqlFile($db, $migration['rollback']);

        // Safety net: if rollback file forgot metadata cleanup.
        $db->query("DELETE FROM _migrations WHERE id = " . (int)$id);

        $rolledBackAny = true;
        echo "  OK\n";
    }

    if (!$rolledBackAny) {
        echo "Nothing to rollback (already at or below target version {$targetVersion}).\n";
    }
}

$command = $argv[1] ?? 'status';
$targetArg = $argv[2] ?? null;

if (!in_array($command, ['status', 'rollout', 'rollback'], true)) {
    usage();
    exit(1);
}

if ($command === 'rollback' && ($targetArg === null || !ctype_digit($targetArg))) {
    usage();
    exit(1);
}

try {
    $env = loadEnvFiles([
        dirname(__DIR__) . '/.env',
        dirname(dirname(__DIR__)) . '/.env',
    ]);

    if (!isset($env['DB_USER']) || !isset($env['DB_PASS'])) {
        throw new RuntimeException('Missing DB_USER/DB_PASS in .env.');
    }

    $host = $env['DB_HOST'] ?? '127.0.0.1';
    $user = $env['DB_USER'];
    $pass = $env['DB_PASS'];
    $name = $env['DB_NAME'] ?? 'canaryaac';
    $port = isset($env['DB_PORT']) ? (int)$env['DB_PORT'] : 3306;

    $db = @new mysqli($host, $user, $pass, $name, $port);
    if ($db->connect_errno) {
        throw new RuntimeException("Database connection failed: {$db->connect_error}");
    }
    $db->set_charset('utf8mb4');

    ensureMigrationsTable($db);
    $migrations = discoverMigrations(__DIR__);
    if (empty($migrations)) {
        throw new RuntimeException('No migration files discovered.');
    }

    if ($command === 'status') {
        printStatus($migrations, fetchAppliedMigrations($db));
    } elseif ($command === 'rollout') {
        applyRollout($db, $migrations);
        echo "\n";
        printStatus($migrations, fetchAppliedMigrations($db));
    } else {
        $targetVersion = (int)$targetArg;
        applyRollback($db, $migrations, $targetVersion);
        echo "\n";
        printStatus($migrations, fetchAppliedMigrations($db));
    }

    $db->close();
    exit(0);
} catch (Throwable $e) {
    fwrite(STDERR, "[ERROR] " . $e->getMessage() . "\n");
    exit(1);
}
