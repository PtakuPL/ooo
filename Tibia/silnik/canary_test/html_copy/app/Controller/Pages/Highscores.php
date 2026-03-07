<?php
/**
 * Highscores Class
 *
 * @package   CanaryAAC
 * @author    Lucas Giovanni <lucasgiovannidesigner@gmail.com>
 * @copyright 2022 CanaryAAC
 */

namespace App\Controller\Pages;

use App\DatabaseManager\Database;
use App\DatabaseManager\Pagination;
use App\Model\Entity\Highscores as EntityHighscores;
use App\Model\Functions\Player;
use App\Utils\View;

class Highscores extends Base{
    private const MODE_ALL = 'all';
    private const MODE_CLASSIC = 'classic74';
    private const MODE_MODERN = 'modern';

    public static function convertCategory($category)
    {
        switch((int)$category){
            case 0:
                $input_category = 'skill_axe';
                break;
            case 1:
                $input_category = 'skill_club';
                break;
            case 2:
                $input_category = 'skill_dist';
                break;
            case 3:
                $input_category = 'level';
                break;
            case 4:
                $input_category = 'skill_fishing';
                break;
            case 5:
                $input_category = 'skill_fist';
                break;
            case 6:
                $input_category = 'maglevel';
                break;
            case 7:
                $input_category = 'skill_shielding';
                break;
            case 8:
                $input_category = 'skill_sword';
                break;
            default:
                $input_category = 'level';
                break;
        }
        return $input_category;
    }

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

    private static function buildHighscoresWhere(int $profession, string $mode): array
    {
        $where = [
            'group_id <=' => 3,
            'deletion' => 0,
        ];

        if ($profession !== 5) {
            $where['vocation'] = $profession;
        }

        $worldId = self::modeToWorldId($mode);
        if ($worldId !== null) {
            $where[self::resolveWorldColumn()] = $worldId;
        }

        return $where;
    }

    public static function getPlayers($request,&$obPagination)
    {
        $player = [];
        $queryParams = $request->getQueryParams();

        $input_profession = (int) filter_var($queryParams['profession'] ?? null, FILTER_SANITIZE_NUMBER_INT);
        if($input_profession < 1 || $input_profession > 5){
            $input_profession = 5;
        }

        $input_category = (int) filter_var($queryParams['category'] ?? null, FILTER_SANITIZE_NUMBER_INT);
        if($input_category < 0 || $input_category > 8){
            $input_category = 3;
        }
        $input_category = self::convertCategory($input_category);

        $input_mode = self::normalizeGameMode($queryParams['gameMode'] ?? ($queryParams['mode'] ?? ($queryParams['server'] ?? 'all')));

        $where = self::buildHighscoresWhere($input_profession, $input_mode);
        $countResult = EntityHighscores::getHighscoresEntity($where, null, null, ['COUNT(*) as qtd'])->fetchObject();
        $totaAmount = (int)($countResult->qtd ?? 0);

        $currentPage = (int)($queryParams['page'] ?? 1);
        if ($currentPage < 1) {
            $currentPage = 1;
        }
        $obPagination = new Pagination($totaAmount, $currentPage, 50);

        $results = EntityHighscores::getHighscoresEntity($where, $input_category . ' DESC, experience DESC', $obPagination->getLimit());
        
        while($obRank = $results->fetchObject(EntityHighscores::class)){
            $player[] = [
                'name' => $obRank->name,
                'vocation' => Player::convertVocation($obRank->vocation),
                'level' => $obRank->level,
                'experience' => $obRank->experience,
                'skill_axe' =>$obRank->skill_axe,
                'skill_club' =>$obRank->skill_club,
                'skill_dist' =>$obRank->skill_dist,
                'skill_fishing' =>$obRank->skill_fishing,
                'skill_fist' =>$obRank->skill_fist,
                'maglevel' =>$obRank->maglevel,
                'skill_shielding' =>$obRank->skill_shielding,
                'skill_sword' =>$obRank->skill_sword,
                'online' => Player::isOnline($obRank->id),
            ];
        }

        $ranks = [
            'category' => $input_category,
            'profession' => $input_profession,
            'game_mode' => $input_mode,
            'allplayers' => $player,
        ];
        return $ranks;
    }

    public static function getHighscores($request)
    {
        $content = View::render('pages/community/highscores', [
            'players' => self::getPlayers($request, $obPagination),
            'pagination' => self::getPagination($request, $obPagination),
        ]);
        return parent::getBase('Highscores', $content, 'highscores');
    }
}
