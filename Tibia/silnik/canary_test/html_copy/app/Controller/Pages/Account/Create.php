<?php
/**
 * Create Class
 *
 * @package   CanaryAAC
 * @author    Lucas Giovanni <lucasgiovannidesigner@gmail.com>
 * @copyright 2022 CanaryAAC
 */

namespace App\Controller\Pages\Account;

use App\Controller\Pages\Base;
use App\Model\Entity\Worlds as EntityWorlds;
use App\Model\Entity\CreateAccount as EntityCreateAccount;
use App\Model\Entity\ServerConfig as EntityServerConfig;
use App\Model\Entity\Player as EntityPlayer;
use App\Model\Functions\Server as FunctionServer;
use App\Utils\Argon;
use App\Utils\View;
use App\Model\Functions\Player as FunctionsPlayer;
use App\DatabaseManager\Database;

class Create extends Base{
    private static ?array $accountsColumnsCache = null;

    private static function getAccountsColumns(): array
    {
        if (self::$accountsColumnsCache !== null) {
            return self::$accountsColumnsCache;
        }

        $db = new Database('accounts');
        $stmt = $db->execute('SHOW COLUMNS FROM accounts');
        $cols = [];
        while ($row = $stmt->fetchObject()) {
            if (!empty($row->Field)) {
                $cols[(string)$row->Field] = true;
            }
        }
        self::$accountsColumnsCache = $cols;
        return self::$accountsColumnsCache;
    }

    private static function accountHasColumn(string $column): bool
    {
        $cols = self::getAccountsColumns();
        return isset($cols[$column]);
    }

    public static function getActiveVocation()
    {
        $activeVocations = EntityServerConfig::getInfoWebsite()->fetchObject();
        $active = $activeVocations->player_voc;
        return $active;
    }

    public static function getCreateAccount($request, $status = null)
    {
        $content = View::render('pages/account/createaccount', [
            'status' => $status,
            'worlds' => FunctionServer::getWorlds(),
            'preselect_world_pvptype' => 'open',
            'activevoc' => self::getActiveVocation(),
        ]);
        return parent::getBase(__('create_account'), $content, 'createaccount');
    }

    public static function createAccount($request)
    {
        $postVars = $request->getPostVars();
        $account_name = trim((string)($postVars['accname'] ?? ''));
        $account_email = strtolower(trim((string)($postVars['email'] ?? '')));
        $account_password1 = $postVars['password1'] ?? '';
        $account_password2 = $postVars['password2'] ?? '';
        $character_name = $postVars['name'] ?? '';
        $character_sex = $postVars['sex'] ?? '';
        $character_vocation = $postVars['vocation'] ?? '';
        $character_world = $postVars['world'] ?? '';
        $account_agreeagreements = $postVars['agreeagreements'] ?? '';

        if (!preg_match('/^[A-Za-z0-9_]{3,32}$/', $account_name)) {
            return self::getCreateAccount($request, __('error_account_name_format'));
        }
        $filter_acc_name = $account_name;
        $verifyAccAccount = EntityPlayer::getAccount([ 'name' => $account_name])->fetchObject();
        if(!empty($verifyAccAccount)){
            return self::getCreateAccount($request, __('error_account_name_taken'));
        }
		
        if(!filter_var($account_email, FILTER_VALIDATE_EMAIL)){
            return self::getCreateAccount($request, __('error_email_invalid'));
        }
        $filter_email = $account_email;
        $verifyAccountEmail = EntityPlayer::getAccount([ 'email' => $filter_email])->fetchObject();
        if(!empty($verifyAccountEmail)){
            return self::getCreateAccount($request, __('error_email_taken'));
        }

        if($account_password1 != $account_password2){
            return self::getCreateAccount($request, __('error_password_repeat'));
        }
        $passwordLength = strlen((string)$account_password1);
        if ($passwordLength < 6 || $passwordLength > 72) {
            return self::getCreateAccount($request, __('error_password_length'));
        }
        $plainPassword = (string)$account_password1;
        $convertPassword = Argon::generateArgonPassword($plainPassword);
        
        $filter_name = filter_var($character_name, FILTER_SANITIZE_SPECIAL_CHARS);
        if(empty($filter_name)){
            return self::getCreateAccount($request, __('error_character_name_required'));
        }
        $CountName = strlen($filter_name);
        if($CountName < 5){
            return self::getCreateAccount($request, __('error_character_name_too_short'));
        }
        if($CountName > 29){
            return self::getCreateAccount($request, __('error_character_name_too_long'));
        }
        $verifyPlayerName = EntityPlayer::getPlayer([ 'name' => $filter_name])->fetchObject();
        if($verifyPlayerName == true){
            return self::getCreateAccount($request, __('error_character_name_taken'));
        }

        $filter_sex = filter_var($character_sex, FILTER_SANITIZE_NUMBER_INT);
        if (empty($filter_sex)) {
            return self::getCreateAccount($request, __('error_gender_required'));
        }
        if($filter_sex > 2){
            return self::getCreateAccount($request, __('error_gender_choose'));
        }
        if ($filter_sex == 2) {
            $filter_sex = 0;
        }

        $activeVocations = EntityServerConfig::getInfoWebsite()->fetchObject();
        if($activeVocations->player_voc == 1){
            $filter_vocation = filter_var($character_vocation, FILTER_SANITIZE_SPECIAL_CHARS);
            if (empty($filter_vocation)) {
                return self::getCreateAccount($request, __('error_vocation_choose'));
            }

            $verifyVocation = EntityCreateAccount::getPlayerSamples([ 'vocation' => $filter_vocation])->fetchObject();
            if($verifyVocation == false){
                return self::getCreateAccount($request, __('error_vocation_select'));
            }
        } else {
            $filter_vocation = 0;
        }

        $filter_world = filter_var($character_world, FILTER_SANITIZE_SPECIAL_CHARS);
        $filter_world = str_replace('server_', '', $filter_world);
        $selectWorlds = EntityWorlds::getWorlds([ 'name' => $filter_world])->fetchObject();
        if($selectWorlds == false){
            return self::getCreateAccount($request, __('error_world_invalid'));
        }

        if($account_agreeagreements != 'true'){
            return self::getCreateAccount($request, __('error_rules_accept'));
        }

        $account = [
            'name' => $filter_acc_name,
            'password' => $convertPassword,
            'email' => $filter_email,
        ];

        // Keep WWW account creation schema-compatible with API registration,
        // while still working on older schemas where some columns may be absent.
        $optionalAccountFields = [
            'engine_password_sha1' => sha1($plainPassword),
            'key' => bin2hex(random_bytes(32)),
            'created' => time(),
            'email_hash' => md5($filter_email),
            'email_verified' => 1,
            'page_access' => 0,
            'premdays' => 0,
            'type' => 0,
            'coins' => 0,
            'recruiter' => 0,
        ];
        foreach ($optionalAccountFields as $field => $value) {
            if (self::accountHasColumn($field)) {
                $account[$field] = $value;
            }
        }

        $accountId = EntityCreateAccount::createAccount($account);
        $playerSample = EntityCreateAccount::getPlayerSamples([ 'vocation' => $filter_vocation])->fetchObject();

        $character = [
            'name' => $filter_name,
            'group_id' => '1',
            'account_id' => $accountId,
            'main' => '1',
            'level' => $playerSample->level,
            'vocation' => $playerSample->vocation,
            'health' => $playerSample->health,
            'healthmax' => $playerSample->healthmax,
            'experience' => $playerSample->experience,
            'lookbody' => $playerSample->lookbody,
            'lookfeet' => $playerSample->lookfeet,
            'lookhead' => $playerSample->lookhead,
            'looklegs' => $playerSample->looklegs,
            'looktype' => $playerSample->looktype,
            'lookaddons' => $playerSample->lookaddons,
            'maglevel' => $playerSample->maglevel,
            'mana' => $playerSample->mana,
            'manamax' => $playerSample->manamax,
            'manaspent' => $playerSample->manaspent,
            'soul' => $playerSample->soul,
            'town_id' => $playerSample->town_id,
            'world' => $selectWorlds->id,
            'posx' => $playerSample->posx,
            'posy' => $playerSample->posy,
            'posz' => $playerSample->posz,
            'cap' => $playerSample->cap,
            'sex' => $filter_sex,
            'balance' => $playerSample->balance,
            'istutorial' => '1',
        ];
        EntityCreateAccount::createCharacter($character);

        $confirmCharacter = [
            'name' => $filter_name,
            'vocation' => FunctionsPlayer::convertVocation($playerSample->vocation),
            'sex' => FunctionsPlayer::convertSex($filter_sex),
            'world' => FunctionServer::getWorldById($selectWorlds->id),
        ];

        $content = View::render('pages/account/createaccount_confirm', [
            'account' => $account,
            'character' => $confirmCharacter,
        ]);
        return parent::getBase(__('create_account'), $content, 'createaccount');
    }

}
