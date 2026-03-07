<?php
/**
 * Validator class
 *
 * @package   CanaryAAC
 * @author    Lucas Giovanni <lucasgiovannidesigner@gmail.com>
 * @copyright 2022 CanaryAAC
 */

namespace App\Controller\Api;

use App\DatabaseManager\Database;
use App\DatabaseManager\Pagination;
use App\Model\Entity\Highscores as EntityHighscores;
use App\Model\Functions\Player;
use App\Http\Request;
use Exception;

class Highscores extends Api
{
    private const MODE_ALL = 'all';
    private const MODE_CLASSIC = 'classic74';
    private const MODE_MODERN = 'modern';

    private static function normalizeGameMode($mode): string
    {
        $mode = strtolower(trim((string)$mode));
        if (in_array($mode, ['', 'all', 'both', 'global'], true)) {
            return self::MODE_ALL;
        }
        if (in_array($mode, ['classic74', 'classic', 'retro', 'retro74', '7.4', '74'], true)) {
            return self::MODE_CLASSIC;
        }
        if (in_array($mode, ['modern', 'main', '14', '14.20', 'latest'], true)) {
            return self::MODE_MODERN;
        }
        return self::MODE_ALL;
    }

    private static function modeToWorldId(string $mode): ?int
    {
        if ($mode === self::MODE_CLASSIC) {
            return 0;
        }
        if ($mode === self::MODE_MODERN) {
            return 1;
        }
        return null;
    }

    private static function resolveWorldColumn(): string
    {
        static $cachedColumn = null;
        if (is_string($cachedColumn)) {
            return $cachedColumn;
        }

        $database = new Database('players');
        $hasWorld = $database->execute("SHOW COLUMNS FROM players LIKE 'world'")->fetchObject();
        if ($hasWorld) {
            $cachedColumn = 'world';
            return $cachedColumn;
        }

        $hasWorldId = $database->execute("SHOW COLUMNS FROM players LIKE 'world_id'")->fetchObject();
        if ($hasWorldId) {
            $cachedColumn = 'world_id';
            return $cachedColumn;
        }

        $cachedColumn = 'world';
        return $cachedColumn;
    }

    private static function parseProfession($profession): ?int
    {
        switch((string)$profession) {
            case 'sorcerer':
            case '1':
                return 1;
            case 'druid':
            case '2':
                return 2;
            case 'knight':
            case '3':
                return 3;
            case 'paladin':
            case '4':
                return 4;
            default:
                return null;
        }
    }

    private static function parseOrderCategory($category): string
    {
        switch((string)$category) {
            case '1':
            case 'achievements':
                return 'achievements DESC';
            case '2':
            case 'axe':
                return 'skill_axe DESC';
            case '3':
            case 'charm':
                return 'charm DESC';
            case '4':
            case 'club':
                return 'skill_club DESC';
            case '5':
            case 'distance':
                return 'skill_dist DESC';
            case '6':
            case 'experience':
                return 'level DESC';
            case '7':
            case 'fishing':
                return 'skill_fishing DESC';
            case '8':
            case 'fist':
                return 'skill_fist DESC';
            case '9':
            case 'taint':
                return 'taint DESC';
            case '10':
            case 'loyalty':
                return 'loyalty DESC';
            case '11':
            case 'magiclevel':
                return 'maglevel DESC';
            case '12':
            case 'shielding':
                return 'skill_shielding DESC';
            case '13':
            case 'sword':
                return 'skill_sword DESC';
            default:
                return 'level DESC';
        }
    }

    private static function buildHighscoresWhere(?int $profession, string $mode): array
    {
        $where = [
            'group_id <=' => 3,
            'deletion' => 0,
        ];

        if ($profession !== null) {
            $where['vocation'] = $profession;
        }

        $worldId = self::modeToWorldId($mode);
        if ($worldId !== null) {
            $where[self::resolveWorldColumn()] = $worldId;
        }

        return $where;
    }

    public static function getHighscoresCharacters($request, &$obPagination)
    {

        $queryParams = $request->getQueryParams();

        $profession = self::parseProfession($queryParams['profession'] ?? null);
        $category = self::parseOrderCategory($queryParams['category'] ?? null);
        $mode = self::normalizeGameMode($queryParams['gameMode'] ?? ($queryParams['mode'] ?? 'all'));
        $where = self::buildHighscoresWhere($profession, $mode);

        $player = [];

        $totalResult = EntityHighscores::getHighscoresEntity($where, null, null, ['COUNT(*) as qtd'])->fetchObject();
        $totalAmount = (int)($totalResult->qtd ?? 0);
        $currentPage = (int)($queryParams['page'] ?? 1);
        if ($currentPage < 1) {
            $currentPage = 1;
        }
        $perPage = (int)($queryParams['limit'] ?? 50);
        if ($perPage < 1) {
            $perPage = 1;
        }
        if ($perPage > 200) {
            $perPage = 200;
        }
        $obPagination = new Pagination($totalAmount, $currentPage, $perPage);

        $results = EntityHighscores::getHighscoresEntity($where, $category . ', experience DESC', $obPagination->getLimit());

        while($obRank = $results->fetchObject(EntityHighscores::class)) {
            $player[] = [
                'name' => $obRank->name,
                'vocation' => Player::convertVocation($obRank->vocation),
                'level' => (int)$obRank->level,
                'experience' => (int)$obRank->experience,
                'online' => Player::isOnline($obRank->id)
            ];
        }

        if($totalAmount == 0) {
            throw new Exception('No characters found.', 404);
        }

        return [
            'mode' => $mode,
            'players' => $player,
        ];
    }

    /**
     * Método responsável por retornar os detalhes da API
     *
     * @param Request $request
     * @return array
     */
    public static function getHighscores($request)
    {
        $payload = self::getHighscoresCharacters($request, $obPagination);
        return [
            'mode' => $payload['mode'],
            'highscores' => $payload['players'],
            'pagination' => parent::getPagination($request, $obPagination)
        ];
    }

}
