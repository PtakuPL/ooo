<?php

namespace App\Payment;

use App\DatabaseManager\Database;
use PDO;

class CallbackProcessor
{
    private const STATUS_PAID = 4;
    private const EVENT_TYPE = 'callback';
    private const DEFAULT_GAME_MODE = 'classic74';
    private const DEFAULT_WORLD_ID = 0;
    private const DEFAULT_CURRENCY = 'BRL';

    private static array $tableExistsCache = [];
    private static array $columnExistsCache = [];

    public static function processApproved(
        string $provider,
        string $providerTxnId,
        string $reference,
        array $payload = [],
        bool $signatureValid = false
    ): array {
        $provider = self::sanitizeToken($provider, 32, 'unknown');
        $providerTxnId = self::sanitizeToken($providerTxnId, 128, 'unknown');
        $reference = self::sanitizeToken($reference, 128, '');

        if ($reference === '') {
            return [
                'ok' => false,
                'credited' => false,
                'reason' => 'missing_reference',
            ];
        }

        $payloadJson = self::safeJson($payload);
        $eventHash = hash('sha256', $payloadJson);

        $eventState = self::registerEvent(
            $provider,
            $providerTxnId,
            $reference,
            $payloadJson,
            $eventHash,
            $signatureValid
        );

        if ($eventState === 'duplicate') {
            return [
                'ok' => true,
                'credited' => false,
                'reason' => 'duplicate_event',
            ];
        }

        $db = new Database();
        $fields = ['id', 'account_id', 'total_coins', 'final_price', 'status'];
        $hasGameMode = self::columnExists('canary_payments', 'game_mode');
        $hasWorldId = self::columnExists('canary_payments', 'world_id');
        if ($hasGameMode) {
            $fields[] = 'game_mode';
        }
        if ($hasWorldId) {
            $fields[] = 'world_id';
        }

        $selectSql = 'SELECT ' . implode(', ', $fields)
            . ' FROM canary_payments WHERE reference = ? LIMIT 1 FOR UPDATE';

        $db->execute('START TRANSACTION');
        $payment = $db->execute($selectSql, [$reference])->fetch(PDO::FETCH_ASSOC);

        if (!$payment) {
            $db->execute('COMMIT');
            self::finishEvent(
                $provider,
                $providerTxnId,
                'failed',
                'payment_not_found',
                $reference,
                self::DEFAULT_GAME_MODE,
                self::DEFAULT_WORLD_ID,
                $signatureValid,
                $payloadJson,
                $eventHash
            );
            return [
                'ok' => false,
                'credited' => false,
                'reason' => 'payment_not_found',
            ];
        }

        $gameMode = self::normalizeGameMode($payment['game_mode'] ?? self::DEFAULT_GAME_MODE);
        $worldId = isset($payment['world_id']) ? (int) $payment['world_id'] : self::DEFAULT_WORLD_ID;

        if ((int) $payment['status'] === self::STATUS_PAID) {
            $db->execute('COMMIT');
            self::finishEvent(
                $provider,
                $providerTxnId,
                'duplicate',
                'already_paid',
                $reference,
                $gameMode,
                $worldId,
                $signatureValid,
                $payloadJson,
                $eventHash
            );
            return [
                'ok' => true,
                'credited' => false,
                'reason' => 'already_paid',
                'payment_id' => (int) $payment['id'],
                'account_id' => (int) $payment['account_id'],
            ];
        }

        $updatedRows = $db->execute(
            'UPDATE canary_payments SET status = ? WHERE id = ? AND status <> ?',
            [self::STATUS_PAID, (int) $payment['id'], self::STATUS_PAID]
        )->rowCount();

        if ($updatedRows === 0) {
            $db->execute('COMMIT');
            self::finishEvent(
                $provider,
                $providerTxnId,
                'duplicate',
                'already_paid_race',
                $reference,
                $gameMode,
                $worldId,
                $signatureValid,
                $payloadJson,
                $eventHash
            );
            return [
                'ok' => true,
                'credited' => false,
                'reason' => 'already_paid',
                'payment_id' => (int) $payment['id'],
                'account_id' => (int) $payment['account_id'],
            ];
        }

        $coinsDelta = max(0, (int) ($payment['total_coins'] ?? 0));
        if ($coinsDelta > 0) {
            $db->execute(
                'UPDATE accounts SET coins = coins + ? WHERE id = ? LIMIT 1',
                [$coinsDelta, (int) $payment['account_id']]
            );
        }

        $db->execute('COMMIT');

        self::insertLedgerEntry(
            $provider,
            $providerTxnId,
            (int) $payment['account_id'],
            (int) $payment['id'],
            $coinsDelta,
            (float) ($payment['final_price'] ?? 0),
            $gameMode,
            $worldId,
            self::buildLedgerMetadata($reference, $eventHash, $payload)
        );

        self::finishEvent(
            $provider,
            $providerTxnId,
            'processed',
            null,
            $reference,
            $gameMode,
            $worldId,
            $signatureValid,
            $payloadJson,
            $eventHash
        );

        return [
            'ok' => true,
            'credited' => true,
            'reason' => 'credited',
            'payment_id' => (int) $payment['id'],
            'account_id' => (int) $payment['account_id'],
            'coins_delta' => $coinsDelta,
            'game_mode' => $gameMode,
            'world_id' => $worldId,
        ];
    }

    private static function registerEvent(
        string $provider,
        string $providerTxnId,
        string $reference,
        string $payloadJson,
        string $eventHash,
        bool $signatureValid
    ): string {
        if (!self::tableExists('payment_provider_events')) {
            return 'disabled';
        }

        $db = new Database();
        $insert = $db->execute(
            'INSERT IGNORE INTO payment_provider_events
                (provider, event_type, provider_txn_id, reference, game_mode, world_id, signature_valid, event_hash, payload_json, status, error_message, received_at)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())',
            [
                $provider,
                self::EVENT_TYPE,
                $providerTxnId,
                $reference,
                self::DEFAULT_GAME_MODE,
                self::DEFAULT_WORLD_ID,
                $signatureValid ? 1 : 0,
                $eventHash,
                $payloadJson,
                'received',
                null,
            ]
        );

        if ($insert->rowCount() === 0) {
            return 'duplicate';
        }

        return 'inserted';
    }

    private static function finishEvent(
        string $provider,
        string $providerTxnId,
        string $status,
        ?string $errorMessage,
        string $reference,
        string $gameMode,
        int $worldId,
        bool $signatureValid,
        string $payloadJson,
        string $eventHash
    ): void {
        if (!self::tableExists('payment_provider_events')) {
            return;
        }

        $db = new Database();
        $db->execute(
            'UPDATE payment_provider_events
                SET reference = ?,
                    game_mode = ?,
                    world_id = ?,
                    signature_valid = ?,
                    event_hash = ?,
                    payload_json = ?,
                    status = ?,
                    error_message = ?,
                    processed_at = NOW()
              WHERE provider = ?
                AND provider_txn_id = ?
                AND event_type = ?
              LIMIT 1',
            [
                $reference,
                $gameMode,
                $worldId,
                $signatureValid ? 1 : 0,
                $eventHash,
                $payloadJson,
                $status,
                $errorMessage !== null ? self::truncate($errorMessage, 255) : null,
                $provider,
                $providerTxnId,
                self::EVENT_TYPE,
            ]
        );
    }

    private static function insertLedgerEntry(
        string $provider,
        string $providerTxnId,
        int $accountId,
        int $paymentId,
        int $coinsDelta,
        float $amountGross,
        string $gameMode,
        int $worldId,
        string $metadataJson
    ): void {
        if (!self::tableExists('payment_ledger_entries')) {
            return;
        }

        $db = new Database();
        $db->execute(
            'INSERT IGNORE INTO payment_ledger_entries
                (account_id, payment_id, provider, provider_txn_id, entry_type, game_mode, world_id, coins_delta, amount_gross, currency, metadata_json)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
                $accountId,
                $paymentId,
                $provider,
                $providerTxnId,
                'credit',
                $gameMode,
                $worldId,
                $coinsDelta,
                $amountGross,
                self::DEFAULT_CURRENCY,
                $metadataJson,
            ]
        );
    }

    private static function tableExists(string $table): bool
    {
        if (!isset(self::$tableExistsCache[$table])) {
            if (!preg_match('/^[a-zA-Z0-9_]+$/', $table)) {
                self::$tableExistsCache[$table] = false;
                return false;
            }

            $db = new Database();
            $stmt = $db->execute('SHOW TABLES LIKE ?', [$table]);
            self::$tableExistsCache[$table] = (bool) $stmt->fetch(PDO::FETCH_NUM);
        }

        return self::$tableExistsCache[$table];
    }

    private static function columnExists(string $table, string $column): bool
    {
        $cacheKey = $table . '.' . $column;
        if (!isset(self::$columnExistsCache[$cacheKey])) {
            if (!preg_match('/^[a-zA-Z0-9_]+$/', $table) || !preg_match('/^[a-zA-Z0-9_]+$/', $column)) {
                self::$columnExistsCache[$cacheKey] = false;
                return false;
            }

            $db = new Database();
            $stmt = $db->execute('SHOW COLUMNS FROM ' . $table . ' LIKE ?', [$column]);
            self::$columnExistsCache[$cacheKey] = (bool) $stmt->fetch(PDO::FETCH_NUM);
        }

        return self::$columnExistsCache[$cacheKey];
    }

    private static function sanitizeToken(string $value, int $maxLength, string $fallback): string
    {
        $value = trim($value);
        if ($value === '') {
            return $fallback;
        }

        $value = preg_replace('/\s+/', '_', $value);
        return self::truncate($value, $maxLength);
    }

    private static function normalizeGameMode(string $gameMode): string
    {
        $normalized = strtolower(trim($gameMode));
        return $normalized === 'modern' ? 'modern' : self::DEFAULT_GAME_MODE;
    }

    private static function truncate(string $value, int $maxLength): string
    {
        if (strlen($value) <= $maxLength) {
            return $value;
        }

        return substr($value, 0, $maxLength);
    }

    private static function safeJson(array $payload): string
    {
        $encoded = json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        if (!is_string($encoded)) {
            return '{}';
        }

        return self::truncate($encoded, 65535);
    }

    private static function buildLedgerMetadata(string $reference, string $eventHash, array $payload): string
    {
        return self::safeJson([
            'reference' => $reference,
            'payload_hash' => $eventHash,
            'payload' => $payload,
        ]);
    }
}
