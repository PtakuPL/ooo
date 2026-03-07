<?php
/**
 * NotifyMercadoPago Class
 *
 * @package   CanaryAAC
 * @author    Lucas Giovanni <lucasgiovannidesigner@gmail.com>
 * @copyright 2022 CanaryAAC
 */

namespace App\Payment\MercadoPago;

use MercadoPago\Payment;
use MercadoPago\SDK;
use App\Payment\CallbackProcessor;

class NotifyMercadoPago {

    public static function ReturnMercadoPago($request = null)
    {
        if (!isset($_POST['type']) || $_POST['type'] !== 'payment') {
            return;
        }

        SDK::setAccessToken($_ENV['MERCADOPAGO_TOKEN']);

        $paymentId = (string) ($_POST['data']['id'] ?? '');
        if ($paymentId === '') {
            return;
        }

        $payment = Payment::find_by_id($paymentId);
        self::updatePayment($payment);
    }

    public static function updatePayment($payment)
    {
        if (!$payment) {
            return;
        }

        $status = strtolower((string) ($payment->status ?? $payment->order_status ?? ''));
        if (!in_array($status, ['paid', 'approved'], true)) {
            return;
        }

        $isCancelled = strtolower((string) ($payment->cancelled ?? 'false')) === 'true';
        if ($isCancelled) {
            return;
        }

        $reference = (string) ($payment->external_reference ?? '');
        if ($reference === '' && isset($payment->metadata->reference)) {
            $reference = (string) $payment->metadata->reference;
        }
        if ($reference === '') {
            $reference = (string) ($payment->preference_id ?? '');
        }
        if ($reference === '') {
            return;
        }

        $providerTxnId = (string) ($payment->id ?? $payment->preference_id ?? 'unknown');

        CallbackProcessor::processApproved(
            'mercadopago',
            $providerTxnId,
            $reference,
            self::normalizePayload($payment),
            false
        );
    }

    private static function normalizePayload($payload): array
    {
        $encoded = json_encode($payload);
        if (!is_string($encoded)) {
            return [];
        }

        $decoded = json_decode($encoded, true);
        return is_array($decoded) ? $decoded : [];
    }

}
