<?php
/**
 * NotifyPagSeguro Class
 *
 * @package   CanaryAAC
 * @author    Lucas Giovanni <lucasgiovannidesigner@gmail.com>
 * @copyright 2022 CanaryAAC
 */

namespace App\Payment\PagSeguro;

use PagSeguro\Configuration\Configure;
use PagSeguro\Services\Transactions\Notification;
use App\Payment\CallbackProcessor;

class NotifyPagSeguro {

    public static function ReturnPagSeguro()
    {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            return;
        }

        $notificationType = filter_var($_POST['notificationType'] ?? '', FILTER_SANITIZE_SPECIAL_CHARS);
        $notificationCode = filter_var($_POST['notificationCode'] ?? '', FILTER_SANITIZE_SPECIAL_CHARS);
        if ($notificationType !== 'transaction' || $notificationCode === '') {
            return;
        }

        $credentials = Configure::getAccountCredentials();
        $transaction = Notification::check($credentials);
        if (!$transaction) {
            return;
        }

        $reference = (string) $transaction->getReference();
        $transactionCode = (string) $transaction->getCode();
        $transactionStatus = strtoupper((string) $transaction->getStatus()->getTypeFromValue());

        if ($transactionStatus !== 'PAID' || $reference === '') {
            return;
        }

        CallbackProcessor::processApproved(
            'pagseguro',
            $transactionCode !== '' ? $transactionCode : $notificationCode,
            $reference,
            [
                'notification_type' => $notificationType,
                'notification_code' => $notificationCode,
                'transaction_code' => $transactionCode,
                'transaction_status' => $transactionStatus,
                'reference' => $reference,
            ],
            true
        );
    }

}
