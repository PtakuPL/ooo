<?php
declare(strict_types=1);

require_once __DIR__ . '/common.php';

/**
 * Shared register-account service for API and portal.
 *
 * @return array{ok:bool, httpCode:int, error?:string, message?:string, accountId?:int, accountName?:string, email?:string}
 */
function register_account_shared(array $req, array $ENV = []): array
{
    $accountName = trim((string)($req['accountName'] ?? $req['account'] ?? ''));
    $email = strtolower(trim((string)($req['email'] ?? '')));
    $password = (string)($req['password'] ?? '');
    $passwordConfirm = array_key_exists('passwordConfirm', $req) ? (string)$req['passwordConfirm'] : null;

    if (!preg_match('/^[A-Za-z0-9_]{3,32}$/', $accountName)) {
        return [
            'ok' => false,
            'httpCode' => 400,
            'error' => 'invalid_account_name',
            'message' => 'Account name must be 3-32 chars [A-Za-z0-9_].',
        ];
    }
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        return [
            'ok' => false,
            'httpCode' => 400,
            'error' => 'invalid_email',
            'message' => 'Invalid email address.',
        ];
    }
    if (strlen($password) < 6 || strlen($password) > 72) {
        return [
            'ok' => false,
            'httpCode' => 400,
            'error' => 'invalid_password_length',
            'message' => 'Password must be between 6 and 72 characters.',
        ];
    }
    if ($passwordConfirm !== null && !hash_equals($password, $passwordConfirm)) {
        return [
            'ok' => false,
            'httpCode' => 400,
            'error' => 'password_mismatch',
            'message' => 'Password confirmation does not match.',
        ];
    }

    if ($ENV === []) {
        $ENV = loadEnvFiles([
            __DIR__ . '/.env',
            dirname(__DIR__, 2) . '/.env',
        ]);
    }
    $clientIp = getClientIp($ENV);
    $ipHash = hashClientIp($clientIp, $ENV);
    $requestStartedAt = microtime(true);

    // F1: multi-DB — accounts are in GLOBAL_DB
    try {
        $globalDb = getGlobalDb($ENV);
    } catch (\Exception $e) {
        return [
            'ok' => false,
            'httpCode' => 500,
            'error' => 'db_connect_failed',
            'message' => 'Database connection failed.',
        ];
    }

    $stmt = $globalDb->prepare("SELECT id, name, email FROM accounts WHERE name = ? OR email = ? LIMIT 1");
    $stmt->execute([$accountName, $email]);
    $row = $stmt->fetch();
    if ($row) {
        if (isset($row['name']) && strcasecmp((string)$row['name'], $accountName) === 0) {
            return [
                'ok' => false,
                'httpCode' => 409,
                'error' => 'account_exists',
                'message' => 'Account name already exists.',
            ];
        }
        return [
            'ok' => false,
            'httpCode' => 409,
            'error' => 'email_exists',
            'message' => 'Email already exists.',
        ];
    }

    // Store SHA1 in `password` column — MyAAC expects sha1 (database_encryption=sha1)
    // and the game server engine also uses SHA1.
    $engineSha1 = sha1($password);
    $passwordHash = $engineSha1;
    $key = bin2hex(random_bytes(32));
    $created = time();
    $emailHash = md5($email);
    $emailVerified = 0; // email must be verified via link
    $pageAccess = 0;
    $premdays = 0;
    $type = 0;
    $coins = 0;
    $recruiter = 0;

    $stmt = $globalDb->prepare(
        "INSERT INTO accounts (name, password, engine_password_sha1, email, `key`, created, email_hash, email_verified, page_access, premdays, type, coins, recruiter)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
    );
    $ok = $stmt->execute([
        $accountName,
        $passwordHash,
        $engineSha1,
        $email,
        $key,
        $created,
        $emailHash,
        $emailVerified,
        $pageAccess,
        $premdays,
        $type,
        $coins,
        $recruiter,
    ]);
    if (!$ok) {
        return [
            'ok' => false,
            'httpCode' => 500,
            'error' => 'db_insert_failed',
            'message' => 'Cannot create account.',
        ];
    }
    $accountId = (int)$globalDb->lastInsertId();

    // Generate email verification token and send verification email
    $emailVerifSent = false;
    try {
        require_once __DIR__ . '/mailer.php';

        $verifyToken = bin2hex(random_bytes(32)); // 64 hex chars
        $verifyHash  = hash('sha256', $verifyToken);
        $verifyExpires = time() + 86400; // 24 hours

        $apiDb = getApiDb($ENV);
        $stmtV = $apiDb->prepare(
            "INSERT INTO email_verification_tokens (account_id, email, token_hash, expires_at, created_at)
             VALUES (?, ?, ?, ?, NOW())"
        );
        $stmtV->execute([$accountId, $email, $verifyHash, $verifyExpires]);

        $siteUrl = rtrim((string)($ENV['SITE_URL'] ?? 'https://reddaxe.pl'), '/');
        $verifyUrl = $siteUrl . '/apik/v1/verify-email.php?token=' . $verifyToken;

        $htmlBody = '<h2>Witaj ' . htmlspecialchars($accountName) . '!</h2>'
            . '<p>Potwierdz swoj adres e-mail klikajac w ponizszy link:</p>'
            . '<p><a href="' . htmlspecialchars($verifyUrl) . '">' . htmlspecialchars($verifyUrl) . '</a></p>'
            . '<p>Link wygasa po 24 godzinach.</p>';
        $plainBody = "Witaj $accountName!\nPotwierdz e-mail: $verifyUrl\nLink wygasa po 24 godzinach.";

        $mailResult = apiSendMail($ENV, $email, 'Potwierdz swoj e-mail - RedDAXE', $htmlBody, $plainBody);
        $emailVerifSent = ($mailResult['ok'] ?? false);

        if (!$emailVerifSent) {
            logTicketEvent('email.verification_send_failed', [
                'accountId' => $accountId,
                'email' => $email,
                'error' => (string)($mailResult['error'] ?? 'unknown'),
            ], $ENV);
        }
    } catch (\Throwable $e) {
        logTicketEvent('email.verification_exception', [
            'accountId' => $accountId,
            'error' => $e->getMessage(),
        ], $ENV);
    }

    logTicketEvent('account.registered', [
        'endpoint' => 'register-account-shared',
        'ipHash' => $ipHash,
        'accountId' => $accountId,
        'accountName' => $accountName,
        'emailVerifSent' => $emailVerifSent,
        'latencyMs' => (int)round((microtime(true) - $requestStartedAt) * 1000),
    ], $ENV);

    return [
        'ok' => true,
        'httpCode' => 200,
        'accountId' => $accountId,
        'accountName' => $accountName,
        'email' => $email,
        'emailVerificationSent' => $emailVerifSent,
    ];
}
