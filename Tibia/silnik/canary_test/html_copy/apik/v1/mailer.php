<?php
declare(strict_types=1);

/**
 * Standalone mailer for API layer (no MyAAC dependency).
 * Reads SMTP config from $ENV array (loaded from .env).
 *
 * .env keys:
 *   API_SMTP_HOST=smtp.example.com
 *   API_SMTP_PORT=587
 *   API_SMTP_USER=noreply@example.com
 *   API_SMTP_PASS=secret
 *   API_SMTP_SECURITY=tls         (tls|ssl|none)
 *   API_MAIL_FROM=noreply@example.com
 *   API_MAIL_FROM_NAME=RedDAXE
 */

require_once dirname(__DIR__, 2) . '/vendor/autoload.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception as PHPMailerException;

/**
 * Send an HTML email via SMTP.
 *
 * @return array{ok:bool, error?:string}
 */
function apiSendMail(array $ENV, string $to, string $subject, string $htmlBody, string $plainBody = ''): array
{
    $host = trim((string)($ENV['API_SMTP_HOST'] ?? ''));
    if ($host === '') {
        return ['ok' => false, 'error' => 'API_SMTP_HOST not configured in .env'];
    }

    $port     = (int)($ENV['API_SMTP_PORT'] ?? 587);
    $user     = trim((string)($ENV['API_SMTP_USER'] ?? ''));
    $pass     = (string)($ENV['API_SMTP_PASS'] ?? '');
    $security = strtolower(trim((string)($ENV['API_SMTP_SECURITY'] ?? 'tls')));
    $from     = trim((string)($ENV['API_MAIL_FROM'] ?? $user));
    $fromName = trim((string)($ENV['API_MAIL_FROM_NAME'] ?? 'RedDAXE'));

    try {
        $mail = new PHPMailer(true);
        $mail->isSMTP();
        $mail->Host       = $host;
        $mail->Port       = $port;
        $mail->SMTPAuth   = ($user !== '');
        $mail->Username   = $user;
        $mail->Password   = $pass;
        $mail->CharSet    = 'utf-8';

        if ($security === 'tls') {
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
        } elseif ($security === 'ssl') {
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
        }

        $mail->setFrom($from, $fromName);
        $mail->addAddress($to);
        $mail->isHTML(true);
        $mail->Subject = $subject;
        $mail->Body    = $htmlBody;
        $mail->AltBody = $plainBody !== '' ? $plainBody : strip_tags($htmlBody);

        $mail->send();
        return ['ok' => true];
    } catch (PHPMailerException $e) {
        return ['ok' => false, 'error' => $e->getMessage()];
    }
}
