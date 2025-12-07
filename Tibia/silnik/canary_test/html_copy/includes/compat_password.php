<?php
declare(strict_types=1);

/* ===== global (namespace {}) ===== */
namespace {
    if (!function_exists("verify_password_any")) {
        function verify_password_any(string $plain, string $stored): bool {
            $h = trim($stored);
            if ($h === "") { return false; }

            // argon2 / bcrypt
            if (str_starts_with($h, "\$argon2") || str_starts_with($h, "\$2y$") || str_starts_with($h, "\$2a$")) {
                return password_verify($plain, $h);
            }

            // stare SHA1 w hex (40 znaków)
            if (preg_match("/^[A-Fa-f0-9]{40}$/", $h) === 1) {
                return hash_equals(strtoupper($h), strtoupper(sha1($plain)));
            }

            // awaryjnie porównanie 1:1
            return hash_equals($h, $plain);
        }
    }
}

/* ===== wrapper w App\Utils ===== */
namespace App\Utils {
    if (!function_exists(__NAMESPACE__ . "\\verify_password_any")) {
        function verify_password_any(string $plain, string $stored): bool {
            return \verify_password_any($plain, $stored);
        }
    }
}
