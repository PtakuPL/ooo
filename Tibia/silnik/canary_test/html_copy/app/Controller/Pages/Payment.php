<?php
/**
 * Payment Class
 *
 * @package   CanaryAAC
 * @author    Lucas Giovanni <lucasgiovannidesigner@gmail.com>
 * @copyright 2022 CanaryAAC
 */

namespace App\Controller\Pages;

use App\DatabaseManager\Database;
use App\Model\Entity\Account as EntityAccount;
use App\Model\Entity\Payments as EntityPayments;
use App\Model\Entity\ServerConfig as EntityServerConfig;
use App\Payment\MercadoPago\ApiMercadoPago;
use App\Payment\PagSeguro\ApiPagSeguro;
use App\Session\Admin\Login as SessionAdminLogin;
use App\Utils\View;

class Payment extends Base
{
    private const WORLD_CLASSIC = 0;
    private const WORLD_MODERN = 1;

    private static function parseWorldId($value): int
    {
        $worldId = filter_var($value, FILTER_SANITIZE_NUMBER_INT);
        $worldId = is_numeric($worldId) ? (int) $worldId : self::WORLD_CLASSIC;
        return $worldId === self::WORLD_MODERN ? self::WORLD_MODERN : self::WORLD_CLASSIC;
    }

    private static function worldModeById(int $worldId): string
    {
        return $worldId === self::WORLD_MODERN ? 'modern' : 'classic74';
    }

    private static function worldLabelById(int $worldId): string
    {
        return $worldId === self::WORLD_MODERN ? 'Modern' : 'Classic 7.4';
    }

    private static function paymentTableHasColumn(string $column): bool
    {
        static $cache = [];
        if (isset($cache[$column])) {
            return $cache[$column];
        }

        $database = new Database('canary_payments');
        $stmt = $database->execute("SHOW COLUMNS FROM canary_payments LIKE '" . $column . "'");
        $cache[$column] = (bool) $stmt->fetchObject();
        return $cache[$column];
    }

    private static function appendWorldContext(array $order, int $worldId): array
    {
        if (self::paymentTableHasColumn('world_id')) {
            $order['world_id'] = $worldId;
        }

        if (self::paymentTableHasColumn('game_mode')) {
            $order['game_mode'] = self::worldModeById($worldId);
        }

        return $order;
    }

    private static function requirePostKeys($request, array $postVars, array $required): void
    {
        foreach ($required as $key) {
            if (!isset($postVars[$key])) {
                $request->getRouter()->redirect('/payment');
            }
        }
    }

    public static function viewPayment()
    {
        $idLogged = SessionAdminLogin::idLogged();
        $dbAccount = EntityAccount::getAccount([ 'id' => $idLogged])->fetchObject();
        $donateConfigs = EntityServerConfig::getInfoWebsite([ 'id' => 1])->fetchObject();

        $arrayProducts = [];
        $select_products = EntityServerConfig::getProducts(null, 'id ASC');
        $product_web_id = 192;
        while ($product = $select_products->fetchObject()) {
            $product_web_id++;
            $final_price = $donateConfigs->coin_price * $product->coins;
            $arrayProducts[] = [
                'id' => $product->id,
                'coins' => $product->coins,
                'web_id' => $product_web_id,
                'final_price' => $final_price
            ];
        }

        $selectedWorldId = self::parseWorldId($_GET['payment_world_id'] ?? ($_GET['worldId'] ?? ($_GET['world'] ?? 0)));

        $content = View::render('pages/shop/payment', [
            'email' => $dbAccount->email ?? null,
            'products' => $arrayProducts,
            'active_mercadopago' => $donateConfigs->mercadopago,
            'active_pagseguro' => $donateConfigs->pagseguro,
            'active_paypal' => $donateConfigs->paypal,
            'selected_world_id' => $selectedWorldId,
            'selected_world_name' => self::worldLabelById($selectedWorldId),
        ]);
        return parent::getBase('Webshop', $content, 'donate');
    }

    public static function viewPaymentData($request)
    {
        $idLogged = SessionAdminLogin::idLogged();
        $dbAccount = EntityAccount::getAccount([ 'id' => $idLogged])->fetchObject();
        $postVars = $request->getPostVars();
        self::requirePostKeys($request, $postVars, ['payment_country', 'payment_method', 'payment_coins', 'payment_world_id']);

        $worldId = self::parseWorldId($postVars['payment_world_id']);

        $content = View::render('pages/shop/paymentdata', [
            'country' => $postVars['payment_country'],
            'coins' => $postVars['payment_coins'],
            'method' => $postVars['payment_method'],
            'email' => $dbAccount->email ?? null,
            'world_id' => $worldId,
            'world_name' => self::worldLabelById($worldId),
        ]);
        return parent::getBase('Webshop', $content, 'donate');
    }

    public static function viewPaymentConfirm($request)
    {
        $donateConfigs = EntityServerConfig::getInfoWebsite([ 'id' => 1])->fetchObject();
        $postVars = $request->getPostVars();
        self::requirePostKeys($request, $postVars, ['payment_email', 'payment_coins', 'payment_method', 'payment_country', 'payment_world_id']);

        if(!filter_var($postVars['payment_email'], FILTER_VALIDATE_EMAIL)){
            $request->getRouter()->redirect('/payment');
        }

        $filter_coins = (int) filter_var($postVars['payment_coins'], FILTER_SANITIZE_NUMBER_INT);
        if ($filter_coins < 1) {
            $request->getRouter()->redirect('/payment');
        }
        $final_price = $filter_coins * $donateConfigs->coin_price;
        $worldId = self::parseWorldId($postVars['payment_world_id']);
        
        $content = View::render('pages/shop/paymentconfirm', [
            'method' => $postVars['payment_method'],
            'coins' => $filter_coins,
            'country' => $postVars['payment_country'],
            'email' => $postVars['payment_email'],
            'price' => $final_price,
            'world_id' => $worldId,
            'world_name' => self::worldLabelById($worldId),
        ]);
        return parent::getBase('Webshop', $content, 'donate');
    }

    public static function viewPaymentSummary($request)
    {
        $idLogged = SessionAdminLogin::idLogged();
        $donateConfigs = EntityServerConfig::getInfoWebsite([ 'id' => 1])->fetchObject();
        $postVars = $request->getPostVars();

        if (!isset($postVars['TermsOfService']) || (int)$postVars['TermsOfService'] !== 1) {
            $request->getRouter()->redirect('/payment');
        }
        self::requirePostKeys($request, $postVars, ['payment_coins', 'payment_method', 'payment_country', 'payment_email', 'payment_world_id']);

        if (!filter_var($postVars['payment_email'], FILTER_VALIDATE_EMAIL)) {
            $request->getRouter()->redirect('/payment');
        }
        $filter_email = filter_var($postVars['payment_email'], FILTER_SANITIZE_EMAIL);

        $filter_method = filter_var($postVars['payment_method'], FILTER_SANITIZE_SPECIAL_CHARS);
        $url_method = 0;
        switch($filter_method)
        {
            case 'paypal':
                $url_method = 1;
                if ((int)$donateConfigs->paypal !== 1) {
                    $request->getRouter()->redirect('/payment');
                }
                break;
            case 'pagseguro':
                $url_method = 2;
                if ((int)$donateConfigs->pagseguro !== 1) {
                    $request->getRouter()->redirect('/payment');
                }
                break;
            case 'pix':
                $url_method = 3;
                break;
            case 'mercadopago':
                $url_method = 4;
                if ((int)$donateConfigs->mercadopago !== 1) {
                    $request->getRouter()->redirect('/payment');
                }
                break;
            default:
                $url_method = 0;
        }
        if($url_method == 0){
            $request->getRouter()->redirect('/payment');
        }

        if(!filter_var($postVars['payment_coins'], FILTER_VALIDATE_INT)){
            $request->getRouter()->redirect('/payment');
        }
        $filter_coins = (int) filter_var($postVars['payment_coins'], FILTER_SANITIZE_NUMBER_INT);
        if($filter_coins < 1){
            $request->getRouter()->redirect('/payment');
        }
        $coin_price = (float)$donateConfigs->coin_price;
        if($coin_price <= 0){
            $request->getRouter()->redirect('/payment');
        }
        $price = $coin_price * $filter_coins;
        $worldId = self::parseWorldId($postVars['payment_world_id']);

        // METHOD PAGSEGURO
        if($url_method == 2){
            $reference = uniqid();
            $checkout = [
                'reference' => $reference,
                'item' => [
                    'id' => '0001',
                    'title' => $filter_coins.' Coins',
                    'amount' => $coin_price,
                    'quantity' => $filter_coins,
                ],
            ];
            $code_payment = ApiPagSeguro::createPaymentLightBox($checkout, $filter_email);
            $order = [
                'account_id' => $idLogged,
                'method' => 'pagseguro',
                'reference' => $reference,
                'total_coins' => $filter_coins,
                'final_price' => $price,
                'status' => 0,
                'date' => strtotime(date('Y-m-d h:i:s')),
            ];
            EntityPayments::insertPayment(self::appendWorldContext($order, $worldId));
        }

        // METHOD PAYPAL (API v2)
        if ($url_method == 1) {
            $reference = uniqid();
            $checkout = [
                'reference' => $reference,
                'item' => [
                    'id' => '0001',
                    'title' => $filter_coins . ' Coins',
                    'amount' => $coin_price,
                    'quantity' => $filter_coins,
                ],
            ];

            $order = [
                'account_id'  => $idLogged,
                'method'      => 'paypal',
                'reference'   => $reference,
                'total_coins' => $filter_coins,
                'final_price' => $price,
                'status'      => 0,
                'date'        => strtotime(date('Y-m-d h:i:s')),
            ];
            EntityPayments::insertPayment(self::appendWorldContext($order, $worldId));

            $description = $checkout['item']['title'];
            $currency    = getenv('PAYPAL_CURRENCY') ?: 'USD';

            $api = new \App\Payment\PayPal\ApiPayPal();
            $approvalUrl = $api->createOrder((float)$price, $currency, $description, $reference);

            header('Location: ' . $approvalUrl);
            exit;
        }

        // METHOD PIX
        if($url_method == 3){}

        // METHOD MERCADO PAGO
        if($url_method == 4){
            $reference = uniqid();
            $checkout = [
                'reference' => $reference,
                'item' => [
                    'id' => '0001',
                    'title' => $filter_coins.' Coins',
                    'amount' => $coin_price,
                    'quantity' => $filter_coins,
                ],
            ];
            $code_payment = ApiMercadoPago::createPaymentSandbox($checkout, $filter_email);
            $order = [
                'account_id' => $idLogged,
                'method' => 'mercadopago',
                'reference' => $reference,
                'total_coins' => $filter_coins,
                'final_price' => $price,
                'status' => 0,
                'date' => strtotime(date('Y-m-d h:i:s')),
            ];
            EntityPayments::insertPayment(self::appendWorldContext($order, $worldId));
        }

        $content = View::render('pages/shop/paymentsummary', [
            'email' => $filter_email,
            'method' => $url_method,
            'code_payment' => $code_payment ?? null,
        ]);
        return parent::getBase('Webshop', $content, 'donate');
    }
}
