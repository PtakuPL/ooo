<?php
/**
 * CreateCharacter Class
 *
 * @package   CanaryAAC
 * @author    Lucas Giovanni <lucasgiovannidesigner@gmail.com>
 * @copyright 2022 CanaryAAC
 */

namespace App\Controller\Pages\Account;

use \App\Utils\View;
use App\Controller\Pages\Base;
use App\Model\Functions\Player;
use App\Model\Functions\Server;
use App\Session\Admin\Login as SessionAdminLogin;
use App\Model\Entity\CreateAccount as EntityCreateAccount;
use App\Model\Entity\Worlds as EntityWorlds;
use App\Model\Entity\Player as EntityPlayer;
use App\Model\Entity\ServerConfig as EntityServerConfig;

class CreateCharacter extends Base{

    public static function getWorlds()
    {
        $arrayAllWorlds = [];
        $allWorlds = EntityWorlds::getWorlds();
        while($world = $allWorlds->fetchObject()){
            $arrayAllWorlds[] = [
                'id' => $world->id,
                'name' => $world->name,
                'location' => $world->location,
                'pvp_type' => $world->pvp_type,
                'premium_type' => $world->premium_type,
                'transfer_type' => $world->transfer_type,
                'battle_eye' => $world->battle_eye,
                'world_type' => $world->world_type
            ];
        }
        return $arrayAllWorlds;
    }

    private static function normalizeMode(string $mode): ?string
    {
        $mode = strtolower(trim($mode));
        if (in_array($mode, ['classic74', 'classic', 'retro', 'retro74', '7.4', '74'], true)) {
            return 'classic74';
        }
        if (in_array($mode, ['modern', 'main', '14', '14.20', 'latest'], true)) {
            return 'modern';
        }
        return null;
    }

    private static function isClassicWorldName(string $name): bool
    {
        $name = strtolower($name);
        foreach (['classic', 'retro', '7.4', '74'] as $needle) {
            if (str_contains($name, $needle)) {
                return true;
            }
        }
        return false;
    }

    private static function isModernWorldName(string $name): bool
    {
        $name = strtolower($name);
        foreach (['modern', 'main', 'global', '14', '14.'] as $needle) {
            if (str_contains($name, $needle)) {
                return true;
            }
        }
        return false;
    }

    private static function resolvePreselectedWorldId(array $worlds, ?string $mode): ?int
    {
        if (empty($worlds) || $mode === null) {
            return null;
        }

        foreach ($worlds as $world) {
            $id = isset($world['id']) ? (int)$world['id'] : 0;
            $name = isset($world['name']) ? (string)$world['name'] : '';
            if ($mode === 'classic74' && (self::isClassicWorldName($name) || $id === 0)) {
                return $id;
            }
            if ($mode === 'modern' && (self::isModernWorldName($name) || $id === 1)) {
                return $id;
            }
        }

        return isset($worlds[0]['id']) ? (int)$worlds[0]['id'] : null;
    }

    private static function resolvePreselectedWorldName(array $worlds, ?int $worldId): string
    {
        if ($worldId === null) {
            return '';
        }
        foreach ($worlds as $world) {
            if (isset($world['id']) && (int)$world['id'] === $worldId) {
                return (string)($world['name'] ?? '');
            }
        }
        return '';
    }

    private static function resolveWorldMode(int $worldId, string $worldName): string
    {
        if ($worldId === 0 || self::isClassicWorldName($worldName)) {
            return 'classic74';
        }

        if ($worldId === 1 || self::isModernWorldName($worldName)) {
            return 'modern';
        }

        return 'unknown';
    }

    public static function getActiveVocation()
    {
        $activeVocations = EntityServerConfig::getInfoWebsite()->fetchObject();
        $active = $activeVocations->player_voc;
        return $active;
    }

    public static function insertCharacter($request)
    {
        if(SessionAdminLogin::isLogged() == false){
            return self::viewCreateCharacter($request);
        }

        $AccountId = SessionAdminLogin::idLogged();
        $ServerConfig = EntityServerConfig::getInfoWebsite()->fetchObject();
        $countPlayers = (int)EntityPlayer::getPlayer([ 'account_id' => $AccountId], null, null, ['COUNT(*) as qtd'])->fetchObject()->qtd;
        if($countPlayers >= $ServerConfig->player_max){
            return self::viewCreateCharacter($request, __('error_character_limit'));
        }

        $postVars = $request->getPostVars();
        $queryParams = $request->getQueryParams();
        $requestedMode = self::normalizeMode((string)($queryParams['mode'] ?? ''));
        $LoggedId = SessionAdminLogin::idLogged();

        if(empty($postVars['name'])){
            return self::viewCreateCharacter($request, __('error_character_name_set'));
        }
        if(empty($postVars['world'])){
            return self::viewCreateCharacter($request, __('error_world_select'));
        }
        
        $character_name = filter_var($postVars['name'], FILTER_SANITIZE_SPECIAL_CHARS);
        $character_vocation = filter_var($postVars['vocation'], FILTER_SANITIZE_NUMBER_INT);
        $character_world = filter_var($postVars['world'], FILTER_SANITIZE_NUMBER_INT);
        $character_tutorial = $postVars['tutorial'] ?? '';

        $CountName = strlen($character_name);
        if($CountName < 5){
            return self::viewCreateCharacter($request, __('error_character_name_too_short'));
        }
        if($CountName > 29){
            return self::viewCreateCharacter($request, __('error_character_name_too_long'));
        }
        $verifyPlayerName = EntityPlayer::getPlayer([ 'name' => $character_name])->fetchObject();
        if($verifyPlayerName == true){
            return self::viewCreateCharacter($request, __('error_character_name_taken'));
        }

        $character_sex = filter_var($postVars['sex'], FILTER_SANITIZE_NUMBER_INT);
        if($character_sex > 2){
            return self::viewCreateCharacter($request, __('error_gender_select'));
        }
        if ($character_sex == 2) {
            $character_sex = 0;
        }
        
        $activeVocations = EntityServerConfig::getInfoWebsite()->fetchObject();
        if($activeVocations->player_voc == 1){
            if (empty($character_vocation)) {
                return self::viewCreateCharacter($request, __('error_vocation_choose'));
            }

            $verifyVocation = EntityCreateAccount::getPlayerSamples([ 'vocation' => $character_vocation])->fetchObject();
            if($verifyVocation == false){
                return self::viewCreateCharacter($request, __('error_vocation_select'));
            }
        }else{
            $character_vocation = 0;
        }

        $selectWorlds = EntityWorlds::getWorlds([ 'id' => $character_world])->fetchObject();
        if($selectWorlds == false){
            return self::viewCreateCharacter($request, __('error_world_invalid_select'));
        }

        if ($requestedMode !== null) {
            $selectedWorldMode = self::resolveWorldMode((int)$selectWorlds->id, (string)$selectWorlds->name);
            if ($selectedWorldMode !== 'unknown' && $selectedWorldMode !== $requestedMode) {
                if ($requestedMode === 'classic74') {
                    return self::viewCreateCharacter($request, 'Tryb Classic 7.4 moze tworzyc postacie tylko na swiecie Tibia 7.4.');
                }

                return self::viewCreateCharacter($request, 'Tryb Modern moze tworzyc postacie tylko na swiecie Modern.');
            }
        }

        if(empty($character_tutorial)){
            $character_tutorial = 0;
        }

        if(self::getActiveVocation() == 0){
            $character_vocation = 0;
        }
        $playerSample = EntityCreateAccount::getPlayerSamples([ 'vocation' => $character_vocation])->fetchObject();

        $character = [
            'name' => $character_name,
            'group_id' => '1',
            'account_id' => $LoggedId,
            'main' => '0',
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
            'world' => $character_world,
            'posx' => $playerSample->posx,
            'posy' => $playerSample->posy,
            'posz' => $playerSample->posz,
            'cap' => $playerSample->cap,
            'sex' => $character_sex,
            'balance' => $playerSample->balance,
            'istutorial' => $character_tutorial,
        ];
        EntityCreateAccount::createCharacter($character);

        $content = View::render('pages/account/createcharacter_confirm', [
            'character_name' => $character_name,
            'character_sex' => Player::convertSex($character_sex),
            'world_name' => $selectWorlds->name,
            'world_pvptype' => Server::convertPvpType($selectWorlds->pvp_type),
            'world_location' => Server::convertLocation($selectWorlds->location),
        ]);
        return parent::getBase(__('create_account'), $content);
    }

    public static function viewCreateCharacter($request, $errorMessage = null)
    {
        $queryParams = $request->getQueryParams();
        $source = isset($queryParams['source']) ? strtolower((string)$queryParams['source']) : '';
        $source = $source === 'launcher' ? 'launcher' : '';
        $mode = self::normalizeMode((string)($queryParams['mode'] ?? ''));
        $worlds = self::getWorlds();
        $preselectedWorldId = self::resolvePreselectedWorldId($worlds, $mode);
        $preselectedWorldName = self::resolvePreselectedWorldName($worlds, $preselectedWorldId);

        $content = View::render('pages/account/createcharacter', [
            'worlds' => $worlds,
            'status' => $errorMessage,
            'activevoc' => self::getActiveVocation(),
            'preselect_mode' => $mode,
            'preselect_source' => $source,
            'preselect_world_id' => $preselectedWorldId,
            'preselect_world_name' => $preselectedWorldName,
        ]);
        return parent::getBase('Account Management', $content);
    }

}
