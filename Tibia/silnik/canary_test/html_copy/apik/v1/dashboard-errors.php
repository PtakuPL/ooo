<?php
declare(strict_types=1);

/**
 * dashboard-errors.php — prosty widok logów błędów (Faza 8.5).
 *
 * Wyświetla ostatnie wpisy z /var/log/serwercanary/error-reports.log
 * oraz /var/log/serwercanary/security-events.log w tabelce HTML.
 *
 * Dostęp: tylko z localhost lub z autoryzowanym tokenem.
 * GET /apik/v1/dashboard-errors.php?token=<DASHBOARD_TOKEN>&limit=50&log=errors
 */

require_once __DIR__ . '/common.php';
$ENV = loadEnvFiles([__DIR__ . '/.env', __DIR__ . '/../.env', '/var/www/html/.env']);

// ─── Access control ───
$clientIp = getClientIp($ENV);
$isLocal = in_array($clientIp, ['127.0.0.1', '::1', 'localhost'], true)
        || str_starts_with($clientIp, '172.')
        || str_starts_with($clientIp, '10.')
        || str_starts_with($clientIp, '192.168.');

$dashToken = trim((string)($ENV['DASHBOARD_TOKEN'] ?? ''));
$givenToken = trim((string)($_GET['token'] ?? ''));

if (!$isLocal && ($dashToken === '' || !hash_equals($dashToken, $givenToken))) {
    http_response_code(403);
    header('Content-Type: application/json');
    echo json_encode(['error' => 'forbidden']);
    exit;
}

// ─── Parameters ───
$limit = max(1, min(500, (int)($_GET['limit'] ?? 100)));
$logType = in_array(($_GET['log'] ?? 'errors'), ['errors', 'security'], true)
         ? $_GET['log']
         : 'errors';

$logFiles = [
    'errors'   => '/var/log/serwercanary/error-reports.log',
    'security' => '/var/log/serwercanary/security-events.log',
];
$logFile = $logFiles[$logType];

$format = ($_GET['format'] ?? 'html');
if ($format === 'json') {
    header('Content-Type: application/json; charset=utf-8');
    $lines = readLastLines($logFile, $limit);
    $entries = array_map(fn($l) => json_decode($l, true) ?: ['raw' => $l], $lines);
    echo json_encode(['log' => $logType, 'count' => count($entries), 'entries' => $entries], JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT);
    exit;
}

// ─── Read log ───
$lines = readLastLines($logFile, $limit);
$entries = [];
foreach ($lines as $line) {
    $parsed = json_decode($line, true);
    if ($parsed) {
        $entries[] = $parsed;
    }
}

function readLastLines(string $file, int $n): array {
    if (!file_exists($file) || !is_readable($file)) return [];
    $all = file($file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    if (!$all) return [];
    return array_slice($all, -$n);
}

// ─── HTML output ───
header('Content-Type: text/html; charset=utf-8');
$logLabel = $logType === 'errors' ? 'Error Reports' : 'Security Events';
$otherLog = $logType === 'errors' ? 'security' : 'errors';
$tokenParam = $givenToken ? "&token=" . urlencode($givenToken) : '';
?>
<!DOCTYPE html>
<html lang="pl">
<head>
<meta charset="utf-8">
<title>SerwerCanary — <?= htmlspecialchars($logLabel) ?></title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { font-family: 'Segoe UI', system-ui, sans-serif; background: #0d1117; color: #c9d1d9; padding: 1rem; }
  h1 { color: #58a6ff; margin-bottom: 0.5rem; font-size: 1.4rem; }
  .meta { color: #8b949e; margin-bottom: 1rem; font-size: 0.85rem; }
  .meta a { color: #58a6ff; text-decoration: none; }
  .meta a:hover { text-decoration: underline; }
  table { width: 100%; border-collapse: collapse; font-size: 0.82rem; }
  th { background: #161b22; color: #58a6ff; text-align: left; padding: 6px 8px; position: sticky; top: 0; }
  td { padding: 5px 8px; border-bottom: 1px solid #21262d; vertical-align: top; max-width: 400px; word-break: break-all; }
  tr:hover { background: #161b22; }
  .tag { display: inline-block; padding: 1px 6px; border-radius: 3px; font-size: 0.75rem; }
  .tag-error { background: #da363388; color: #f85149; }
  .tag-warn { background: #d29922aa; color: #e3b341; }
  .tag-info { background: #388bfd44; color: #58a6ff; }
  .empty { text-align: center; padding: 2rem; color: #8b949e; }
  code { background: #161b22; padding: 1px 4px; border-radius: 3px; font-size: 0.8rem; }
</style>
</head>
<body>
<h1>📊 <?= htmlspecialchars($logLabel) ?></h1>
<p class="meta">
  Plik: <code><?= htmlspecialchars($logFile) ?></code> |
  Wyświetlono: <?= count($entries) ?>/<?= $limit ?> |
  <a href="?log=<?= $otherLog . $tokenParam ?>">Przełącz na <?= $otherLog ?></a> |
  <a href="?log=<?= $logType ?>&format=json<?= $tokenParam ?>">JSON</a>
</p>

<?php if (empty($entries)): ?>
  <div class="empty">Brak wpisów w logu.</div>
<?php elseif ($logType === 'errors'): ?>
<table>
<tr><th>Czas</th><th>Kod</th><th>Wiadomość</th><th>Wersja</th><th>OS</th><th>IP hash</th></tr>
<?php foreach (array_reverse($entries) as $e): ?>
<tr>
  <td><?= htmlspecialchars($e['ts'] ?? '?') ?></td>
  <td><span class="tag tag-error"><?= htmlspecialchars($e['errorCode'] ?? '?') ?></span></td>
  <td><?= htmlspecialchars(mb_substr($e['message'] ?? '', 0, 200)) ?></td>
  <td><?= htmlspecialchars($e['launcherVersion'] ?? '') ?></td>
  <td><?= htmlspecialchars($e['os'] ?? '') ?></td>
  <td><code><?= htmlspecialchars($e['ipHash'] ?? '') ?></code></td>
</tr>
<?php endforeach; ?>
</table>
<?php else: ?>
<table>
<tr><th>Czas</th><th>Zdarzenie</th><th>Szczegóły</th><th>IP hash</th></tr>
<?php foreach (array_reverse($entries) as $e):
  $event = $e['event'] ?? '?';
  $tagClass = str_contains($event, 'rejected') ? 'tag-warn' : 'tag-info';
  $details = $e;
  unset($details['ts'], $details['event'], $details['ipHash']);
?>
<tr>
  <td><?= htmlspecialchars($e['ts'] ?? '?') ?></td>
  <td><span class="tag <?= $tagClass ?>"><?= htmlspecialchars($event) ?></span></td>
  <td><code><?= htmlspecialchars(mb_substr(json_encode($details, JSON_UNESCAPED_SLASHES) ?: '', 0, 300)) ?></code></td>
  <td><code><?= htmlspecialchars($e['ipHash'] ?? '') ?></code></td>
</tr>
<?php endforeach; ?>
</table>
<?php endif; ?>
</body>
</html>
