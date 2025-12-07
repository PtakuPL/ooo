<?php
namespace App\Payment\PayPal;

use PayPalCheckoutSdk\Core\PayPalHttpClient;
use PayPalCheckoutSdk\Core\SandboxEnvironment;
use PayPalCheckoutSdk\Core\ProductionEnvironment;

final class PayPalClient
{
    public static function client(): PayPalHttpClient
    {
        $clientId = getenv('PAYPAL_CLIENT_ID') ?: '';
        $clientSecret = getenv('PAYPAL_CLIENT_SECRET') ?: '';
        $mode = getenv('PAYPAL_MODE') ?: 'sandbox'; // 'sandbox' albo 'live'

        $environment = ($mode === 'live')
            ? new ProductionEnvironment($clientId, $clientSecret)
            : new SandboxEnvironment($clientId, $clientSecret);

        return new PayPalHttpClient($environment);
    }
}
