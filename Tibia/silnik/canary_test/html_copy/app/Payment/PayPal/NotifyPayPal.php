<?php
namespace App\Payment\PayPal;

use App\Model\Entity\Payments as EntityPayments;
use App\Model\Entity\Account as EntityAccount;
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
     * - aktualizuje rekord płatności po naszym reference_id
     * - przyznaje coiny na konto użytkownika
     * - przekierowuje z komunikatem statusu
     */
    public static function ReturnPayPal($request)
    {
        // Pobierz parametry zapytania
        $query = \method_exists($request, 'getQueryParams')
            ? $request->getQueryParams()
            : ($_GET ?? []);

        $token = $query['token'] ?? ''; // orderId z PayPal
        if (!$token) {
            header('Location: ' . URL . '/payment?status=error&provider=paypal&msg=missing_token');
            exit;
        }

        try {
            // 1) CAPTURE
            $notifier = new self();
            $response = $notifier->capture($token); // rzuci wyjątek, jeśli nie COMPLETED
            $result   = $response->result ?? null;

            // 2) Wyciągnij nasz reference z purchase_units
            $reference = '';
            if (!empty($result->purchase_units) && isset($result->purchase_units[0])) {
                $pu = $result->purchase_units[0];
                // w createOrder ustawiliśmy oba: reference_id i custom_id
                $reference = $pu->reference_id ?? ($pu->custom_id ?? '');
            }
            if (!$reference) {
                // Bez reference nie zwiążemy z naszą płatnością
                header('Location: ' . URL . '/payment?status=error&provider=paypal&msg=missing_reference');
                exit;
            }

            // 3) Znajdź rekord płatności po reference
            $dbPayment = EntityPayments::getPayment(['reference' => $reference])->fetchObject();
            if (!$dbPayment) {
                header('Location: ' . URL . '/payment?status=error&provider=paypal&msg=payment_not_found');
                exit;
            }

            // 4) Zaktualizuj status płatności: 4 = approved (wg Twojego kodu)
            EntityPayments::updatePayment(['reference' => $reference], [
                'status' => 4,
            ]);

            // 5) Przyznaj coiny na konto
            $dbAccount = EntityAccount::getAccount(['id' => $dbPayment->account_id])->fetchObject();
            if ($dbAccount) {
                $newCoins = (int)$dbAccount->coins + (int)$dbPayment->total_coins;
                EntityAccount::updateAccount(['id' => $dbPayment->account_id], [
                    'coins' => $newCoins,
                ]);
            }

            // 6) Przekierowanie sukces
            header('Location: ' . URL . '/payment?status=success&provider=paypal&ref=' . urlencode($reference));
            exit;

        } catch (\Throwable $e) {
            // (opcjonalnie) można zalogować $e->getMessage()
            header('Location: ' . URL . '/payment?status=error&provider=paypal');
            exit;
        }
    }
}