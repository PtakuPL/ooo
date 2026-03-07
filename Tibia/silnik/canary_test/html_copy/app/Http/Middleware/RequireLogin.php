<?php
/**
 * Validator class
 *
 * @package   CanaryAAC
 * @author    Lucas Giovanni <lucasgiovannidesigner@gmail.com>
 * @copyright 2022 CanaryAAC
 */

namespace App\Http\Middleware;

use App\Session\Admin\Login as SessionPlayerLogin;

class RequireLogin{
    
    public static function handle($request, $next)
    {
        if(!SessionPlayerLogin::isLogged()){
            $path = $request->getUri();
            $query = $request->getQueryParams();
            if (!empty($query)) {
                $path .= '?' . http_build_query($query);
            }
            $request->getRouter()->redirect('/account/login?redirect=' . rawurlencode($path));
        }
        return $next($request);
    }
    
}
