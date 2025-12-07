<?php
// ------------------------------------------------------------
// routes/api/v1/login.php
// ------------------------------------------------------------

// Prosty debug wejścia (przydaje się w diagnozie klienta)
$__raw = file_get_contents('php://input');
$__ct  = $_SERVER['CONTENT_TYPE']     ?? '';
$__ua  = $_SERVER['HTTP_USER_AGENT']  ?? '';
$__m   = $_SERVER['REQUEST_METHOD']   ?? '';
@file_put_contents(
    '/var/www/html/login_debug.log',
    date('c')." m=".$__m." ct=".$__ct." ua=".$__ua." RAW=".$__raw.PHP_EOL,
    FILE_APPEND
);

// Jeśli przychodzi application/json – zmerguj body do $_POST/$_REQUEST
if (stripos($_SERVER['CONTENT_TYPE'] ?? '', 'application/json') !== false) {
    $parsed = json_decode($__raw, true);
    if (is_array($parsed)) {
        $_POST    = $parsed;
        $_REQUEST = array_merge($_REQUEST, $parsed);
    }
}

/**
 * Wykrywa sensowne IPv4 hosta dla klienta gry.
 * Kolejność:
 *  1) Zmienna środowiskowa LOGIN_FORCE_IP (jeśli chcesz wymusić np. 127.0.0.1)
 *  2) $_SERVER['SERVER_ADDR'] (od nginx/fastcgi)
 *  3) gethostbyname(gethostname())
 *  4) fallback 127.0.0.1
 */
function pickServerIp(): string
{
    $force = getenv('LOGIN_FORCE_IP');
    if (is_string($force) && $force !== '') {
        return $force;
    }

    $candidates = [];

    if (!empty($_SERVER['SERVER_ADDR'])) {
        $candidates[] = $_SERVER['SERVER_ADDR'];
    }

    $gh = @gethostbyname(gethostname());
    if (filter_var($gh, FILTER_VALIDATE_IP)) {
        $candidates[] = $gh;
    }

    foreach ($candidates as $ip) {
        if ($ip !== '127.0.0.1') {
            return $ip;
        }
    }
    return '127.0.0.1';
}

$hostIp   = pickServerIp();
$gamePort = 7172;

global $obRouter;

use App\Http\Response;
use App\Controller\Api;

/**
 * Wspólna logika handlera:
 * - pobiera oryginalną odpowiedź z Api\Login::getLogin($request)
 * - ujednolica do tablicy (gdy string JSON -> json_decode)
 * - nadpisuje adresy/porty światów
 * - zwraca JEDEN json_encode (bez podwójnego kodowania)
 */
$handler = function ($request) use ($hostIp, $gamePort) {
    $json = Api\Login::getLogin($request);

    // Jeśli $json jest stringiem – dekoduj; jeśli już tablica – użyj bez zmian
    $data = is_string($json) ? json_decode($json, true) : $json;
    if (!is_array($data)) {
        $data = [];
    }

    if (isset($data['playdata']['worlds']) && is_array($data['playdata']['worlds'])) {
        foreach ($data['playdata']['worlds'] as &$w) {
            $w['externaladdress']            = $hostIp;
            $w['externaladdressprotected']   = $hostIp;
            $w['externaladdressunprotected'] = $hostIp;
            $w['externalport']               = $gamePort;
            $w['externalportprotected']      = $gamePort;
            $w['externalportunprotected']    = $gamePort;
        }
        unset($w);
    }

    return new Response(
        200,
        json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES),
        'application/json'
    );
};

// GET /api/v1/login
$obRouter->get('/api/v1/login', [
    'middlewares' => ['api'],
    $handler
]);

// POST /api/v1/login
$obRouter->post('/api/v1/login', [
    'middlewares' => ['api'],
    $handler
]);
