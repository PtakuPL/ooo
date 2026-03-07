<?php
namespace App\Payment\PayPal;

use App\Payment\CallbackProcessor;
use PayPalCheckoutSdk\Orders\OrdersCaptureRequest;

class NotifyPayPal
{
    /**
     * Finalizuje płatność (CAPTURE) dla podanego orderId (token).
     * Zwraca pełną odpowiedź SDK (->result).
     */
    public function capture(string $orderId): object
    {
        if (!$orderId) {
            throw new \RuntimeException('Brak identyfikatora zamówienia (orderId/token).');
        }

        $client = PayPalClient::client();

        $request = new OrdersCaptureRequest($orderId);
        $request->prefer('return=representation');

        $response = $client->execute($request);

        // Spodziewany status: COMPLETED
        if (isset($response->result->status) && $response->result->status === 'COMPLETED') {
            return $response;
        }

        $status = $response->result->status ?? 'UNKNOWN';
        throw new \RuntimeException('Capture nie jest COMPLETED. Status: ' . $status);
    }

    /**
     * Handler trasy GET/POST /payment/paypal/return
     * - pobiera token (orderId) z query
     * - wykonuje CAPTURE
     * - uruchamia idempotentny proces zaksięgowania
     */
    public static function ReturnPayPal($request)
    {
        $query = \method_exists($request, 'getQueryParams')
            ? $request->getQueryParams()
            : ($_GET ?? []);

        $token = $query['token'] ?? '';
        if (!$token) {
            header('Location: ' . URL . '/payment?status=error&provider=paypal&msg=missing_token');
            exit;
        }

        try {
            $notifier = new self();
            $response = $notifier->capture($token);
            $result = $response->result ?? null;

            $reference = '';
            if (!empty($result->purchase_units) && isset($result->purchase_units[0])) {
                $purchaseUnit = $result->purchase_units[0];
                // createOrder ustawia reference_id i custom_id
                $reference = $purchaseUnit->reference_id ?? ($purchaseUnit->custom_id ?? '');
            }

            if (!$reference) {
                header('Location: ' . URL . '/payment?status=error&provider=paypal&msg=missing_reference');
                exit;
            }

            $providerTxnId = (string) ($result->id ?? $token);
            $callbackResult = CallbackProcessor::processApproved(
                'paypal',
                $providerTxnId,
                $reference,
                self::normalizePayload($result),
                true
            );

            if ($callbackResult['ok'] ?? false) {
                header('Location: ' . URL . '/payment?status=success&provider=paypal&ref=' . urlencode($reference) . '&msg=' . urlencode((string) ($callbackResult['reason'] ?? 'ok')));
                exit;
            }

            header('Location: ' . URL . '/payment?status=error&provider=paypal&msg=' . urlencode((string) ($callbackResult['reason'] ?? 'processing_failed')));
            exit;
        } catch (\Throwable $e) {
            header('Location: ' . URL . '/payment?status=error&provider=paypal');
            exit;
        }
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
