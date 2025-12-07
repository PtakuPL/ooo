<?php
namespace App\Payment\PayPal;

use PayPalCheckoutSdk\Orders\OrdersCreateRequest;

class ApiPayPal
{
    /**
     * Tworzy zamówienie w PayPal i zwraca URL do przekierowania (approval_url).
     *
     * @param float  $amount      Kwota (np. 9.99)
     * @param string $currency    Waluta (np. 'PLN' / 'USD' / 'EUR')
     * @param string $description Opis transakcji dla użytkownika
     * @param string $reference   Nasz wewnętrzny identyfikator (do powiązania z DB)
     * @return string             URL do przekierowania użytkownika na PayPal
     * @throws \RuntimeException  Gdy PayPal nie zwróci linku approve
     */
    public function createOrder(float $amount, string $currency, string $description, string $reference): string
    {
        $client = PayPalClient::client();

        $request = new OrdersCreateRequest();
        $request->prefer('return=representation');

        $returnUrl = defined('URL') ? (URL . '/payment/paypal/return') : '/payment/paypal/return';
        $cancelUrl = defined('URL') ? (URL . '/payment') : '/payment';

        $request->body = [
            'intent' => 'CAPTURE',
            'purchase_units' => [[
                // to pole pozwoli nam znaleźć płatność po powrocie
                'reference_id' => $reference,
                'custom_id'    => $reference,

                'amount' => [
                    'currency_code' => $currency,
                    'value' => number_format($amount, 2, '.', ''),
                ],
                'description' => $description,
            ]],
            'application_context' => [
                'brand_name' => getenv('PAYPAL_BRAND') ?: 'Donation',
                'landing_page' => 'LOGIN',
                'user_action'  => 'PAY_NOW',
                'return_url'   => $returnUrl,
                'cancel_url'   => $cancelUrl,
            ],
        ];

        $response = $client->execute($request);

        if (!empty($response->result->links)) {
            foreach ($response->result->links as $link) {
                if (isset($link->rel) && $link->rel === 'approve') {
                    return $link->href;
                }
            }
        }

        throw new \RuntimeException('Nie udało się uzyskać linku zatwierdzenia PayPal (approve).');
    }
}
