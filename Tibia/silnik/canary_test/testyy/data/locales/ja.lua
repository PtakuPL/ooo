-- Japanese translations / 日本語翻訳
-- Includes both Japanese characters and romanized (romaji) versions

locale = {
  name = "ja",
  charset = "utf8",
  languageName = "日本語",

  formatNumbers = true,
  decimalSeperator = '.',
  thousandsSeperator = ',',

  translation = {
    -- Basic UI / 基本UI
    ["Accept"] = "承諾", -- Shoudaku
    ["Cancel"] = "キャンセル", -- Kyanseru
    ["Close"] = "閉じる", -- Tojiru
    ["Ok"] = "OK",
    ["Yes"] = "はい", -- Hai
    ["No"] = "いいえ", -- Iie
    ["Error"] = "エラー", -- Eraa
    ["Warning"] = "警告", -- Keikoku
    
    -- Login / ログイン
    ["Login"] = "ログイン", -- Roguin
    ["Logout"] = "ログアウト", -- Roguauto
    ["Password"] = "パスワード", -- Pasuwaado
    ["Account name"] = "アカウント名", -- Akaunto-mei
    ["Remember password"] = "パスワードを記憶", -- Pasuwaado wo kioku
    ["Auto login"] = "自動ログイン", -- Jidou roguin
    ["Enter Game"] = "ゲームに入る", -- Geemu ni hairu
    ["Character List"] = "キャラクターリスト", -- Kyarakutaa risuto
    ["Login Error"] = "ログインエラー", -- Roguin eraa
    ["Connecting to login server..."] = "ログインサーバーに接続中...", -- Roguin saabaa ni setsuzoku-chuu
    ["Connecting to game server..."] = "ゲームサーバーに接続中...", -- Geemu saabaa ni setsuzoku-chuu
    ["Are you sure you want to logout?"] = "ログアウトしますか？", -- Roguauto shimasu ka?
    ["Logging out..."] = "ログアウト中...", -- Roguauto-chuu
    ["Unable to logout."] = "ログアウトできません。", -- Roguauto dekimasen
    
    -- Game / ゲーム
    ["Attack"] = "攻撃", -- Kougeki
    ["Follow"] = "追跡", -- Tsuiseki
    ["Look"] = "見る", -- Miru
    ["Use"] = "使う", -- Tsukau
    ["Open"] = "開く", -- Hiraku
    ["Trade"] = "取引", -- Torihiki
    ["Rotate"] = "回転", -- Kaiten
    
    -- Combat / 戦闘
    ["Battle"] = "戦闘", -- Sentou
    ["Stop Attack"] = "攻撃停止", -- Kougeki teishi
    ["Stop Follow"] = "追跡停止", -- Tsuiseki teishi
    ["Combat Controls"] = "戦闘操作", -- Sentou sousa
    
    -- Skills / スキル
    ["Skills"] = "スキル", -- Sukiru
    ["Level"] = "レベル", -- Reberu
    ["Experience"] = "経験値", -- Keikenchi
    ["Magic Level"] = "魔法レベル", -- Mahou reberu
    ["Fist Fighting"] = "素手戦闘", -- Sude sentou
    ["Club Fighting"] = "棍棒戦闘", -- Konbou sentou
    ["Sword Fighting"] = "剣術", -- Kenjutsu
    ["Axe Fighting"] = "斧戦闘", -- Ono sentou
    ["Distance Fighting"] = "遠距離戦闘", -- Enkyori sentou
    ["Shielding"] = "盾術", -- Tatejutsu
    ["Fishing"] = "釣り", -- Tsuri
    
    -- Stats / ステータス
    ["Health Info"] = "体力情報", -- Tairyoku jouhou
    ["Hit Points"] = "ヒットポイント", -- Hitto pointo
    ["Mana"] = "マナ", -- Mana
    ["Soul"] = "ソウル", -- Souru
    ["Capacity"] = "容量", -- Youryou
    ["Speed"] = "速度", -- Sokudo
    ["Stamina"] = "スタミナ", -- Sutamina
    
    -- Inventory / インベントリ
    ["Inventory"] = "インベントリ", -- Inbentori
    ["Head"] = "頭", -- Atama
    ["Buy"] = "購入", -- Kounyuu
    ["Sell"] = "売却", -- Baikyaku
    ["Amount"] = "数量", -- Suuryou
    ["Amount:"] = "数量:", -- Suuryou:
    ["Price"] = "価格", -- Kakaku
    ["Price:"] = "価格:", -- Kakaku:
    
    -- VIP
    ["VIP List"] = "VIPリスト", -- VIP risuto
    ["Add new VIP"] = "新規VIP追加", -- Shinki VIP tsuika
    ["Add to VIP list"] = "VIPリストに追加", -- VIP risuto ni tsuika
    
    -- Party / パーティー
    ["Invite to Party"] = "パーティーに招待", -- Paatii ni shoutai
    ["Leave Party"] = "パーティーを離脱", -- Paatii wo ridatsu
    ["Enable Shared Experience"] = "経験値共有を有効", -- Keikenchi kyouyuu wo yuukou
    ["Disable Shared Experience"] = "経験値共有を無効", -- Keikenchi kyouyuu wo mukou
    
    -- Options / 設定
    ["Options"] = "設定", -- Settei
    ["Graphics"] = "グラフィック", -- Gurafikku
    ["Audio"] = "オーディオ", -- Oudio
    ["Fullscreen"] = "全画面", -- Zengamen
    ["Enable music"] = "音楽を有効", -- Ongaku wo yuukou
    ["Enable lights"] = "照明を有効", -- Shoumei wo yuukou
    
    -- Console / コンソール
    ["Console"] = "コンソール", -- Konsooru
    ["Channels"] = "チャンネル", -- Channeru
    ["Open new channel"] = "新規チャンネルを開く", -- Shinki channeru wo hiraku
    ["Close this channel"] = "このチャンネルを閉じる", -- Kono channeru wo tojiru
    ["Send"] = "送信", -- Soushin
    ["Copy message"] = "メッセージをコピー", -- Messeeji wo kopii
    ["Copy name"] = "名前をコピー", -- Namae wo kopii
    
    -- Minimap / ミニマップ
    ["Minimap"] = "ミニマップ", -- Minimappu
    ["Create mark"] = "マークを作成", -- Maaku wo sakusei
    ["Delete mark"] = "マークを削除", -- Maaku wo sakujo
    
    -- Market / マーケット
    ["Market"] = "マーケット", -- Maaketto
    ["Market Offers"] = "マーケットの提供", -- Maaketto no teikyou
    ["Buy Offers"] = "購入オファー", -- Kounyuu ofaa
    ["Sell Offers"] = "売却オファー", -- Baikyaku ofaa
    ["Create Offer"] = "オファーを作成", -- Ofaa wo sakusei
    ["My Offers"] = "私のオファー", -- Watashi no ofaa
    
    -- Hotkeys / ホットキー
    ["Hotkeys"] = "ホットキー", -- Hottokii
    ["Manage hotkeys:"] = "ホットキー管理:", -- Hottokii kanri:
    ["Current hotkeys:"] = "現在のホットキー:", -- Genzai no hottokii:
    
    -- Status effects / 状態効果
    ["You are dead"] = "あなたは死んでいます", -- Anata wa shinde imasu
    ["You are dead."] = "あなたは死んでいます。", -- Anata wa shinde imasu.
    ["You are poisoned"] = "毒状態です", -- Doku joutai desu
    ["You are burning"] = "燃えています", -- Moete imasu
    ["You are freezing"] = "凍っています", -- Kootte imasu
    ["You are bleeding"] = "出血しています", -- Shukketsu shite imasu
    ["You are drunk"] = "酔っています", -- Yotte imasu
    ["You are hungry"] = "空腹です", -- Kuufuku desu
    ["You are paralysed"] = "麻痺しています", -- Mahi shite imasu
    ["You are hasted"] = "加速中です", -- Kasoku-chuu desu
    ["You are protected by a magic shield"] = "魔法の盾で守られています", -- Mahou no tate de mamorarete imasu
    ["You are cursed"] = "呪われています", -- Norowarete imasu
    ["You are dazzled"] = "眩惑されています", -- Genwaku sarete imasu
    ["You are drowning"] = "溺れています", -- Oborete imasu
    ["You are electrified"] = "感電しています", -- Kanden shite imasu
    ["You are strengthened"] = "強化されています", -- Kyouka sarete imasu
    ["You are within a protection zone"] = "保護ゾーン内にいます", -- Hogo zoon nai ni imasu
    
    -- Rules & Reports / ルールとレポート
    ["1a) Offensive Name"] = "1a) 攻撃的な名前",
    ["1b) Invalid Name Format"] = "1b) 無効な名前形式",
    ["1c) Unsuitable Name"] = "1c) 不適切な名前",
    ["1d) Name Inciting Rule Violation"] = "1d) ルール違反を誘発する名前",
    ["2a) Offensive Statement"] = "2a) 攻撃的な発言",
    ["2b) Spamming"] = "2b) スパム",
    ["2c) Illegal Advertising"] = "2c) 違法広告",
    ["2d) Off-Topic Public Statement"] = "2d) トピック外の発言",
    ["2e) Non-English Public Statement"] = "2e) 英語以外の発言",
    ["2f) Inciting Rule Violation"] = "2f) ルール違反の誘発",
    ["3a) Bug Abuse"] = "3a) バグの悪用",
    ["3b) Game Weakness Abuse"] = "3b) ゲームの弱点悪用",
    ["3c) Using Unofficial Software to Play"] = "3c) 非公式ソフトウェアの使用",
    ["3d) Hacking"] = "3d) ハッキング",
    ["3e) Multi-Clienting"] = "3e) マルチクライアント",
    ["3f) Account Trading or Sharing"] = "3f) アカウント売買・共有",
    ["4a) Threatening Gamemaster"] = "4a) ゲームマスターへの脅迫",
    ["4b) Pretending to Have Influence on Rule Enforcement"] = "4b) ルール執行への影響力偽装",
    ["4c) False Report to Gamemaster"] = "4c) 虚偽の報告",
    ["Report Bug"] = "バグを報告",
    ["Report Rule Violation"] = "ルール違反を報告",
    ["Bug report sent."] = "バグ報告が送信されました。",
    
    -- Vocations / 職業
    ["Knight"] = "ナイト", -- Naito
    ["Paladin"] = "パラディン", -- Paradin
    ["Sorcerer"] = "ソーサラー", -- Soosaraa
    ["Druid"] = "ドルイド", -- Doruido
    ["Vocation"] = "職業", -- Shokugyou
    ["Voc."] = "職",
    
    -- More UI / その他UI
    ["Addon 1"] = "アドオン1",
    ["Addon 2"] = "アドオン2",
    ["Addon 3"] = "アドオン3",
    ["Browse"] = "参照", -- Sanshou
    ["Browse Field"] = "フィールド参照",
    ["Classic control"] = "クラシック操作",
    ["Clear object"] = "オブジェクトをクリア",
    ["Copy"] = "コピー",
    ["Copy Name"] = "名前をコピー",
    ["Default"] = "デフォルト",
    ["Detail"] = "詳細", -- Shousai
    ["Details"] = "詳細",
    ["Force Exit"] = "強制終了",
    ["Game"] = "ゲーム",
    ["Group"] = "グループ",
    ["Healing"] = "回復", -- Kaifuku
    ["Health Information"] = "体力情報",
    ["Module Manager"] = "モジュール管理",
    ["Module name"] = "モジュール名",
    ["Mount"] = "マウント",
    ["No Mount"] = "マウントなし",
    ["No Outfit"] = "衣装なし",
    ["NPC Trade"] = "NPC取引",
    ["Offline Training"] = "オフライン訓練",
    ["Overview"] = "概要", -- Gaiyou
    ["Primary"] = "プライマリ",
    ["Quest Log"] = "クエストログ",
    ["Randomize"] = "ランダム化",
    ["Randomize characters outfit"] = "衣装をランダム化",
    ["Reject"] = "拒否", -- Kyohi
    ["Reload All"] = "すべて再読込",
    ["Reset All"] = "すべてリセット",
    ["Secondary"] = "セカンダリ",
    ["Select all"] = "すべて選択",
    ["Select object"] = "オブジェクト選択",
    ["Select Outfit"] = "衣装を選択",
    ["Sell All"] = "すべて売却",
    ["Server list"] = "サーバーリスト",
    ["Server List"] = "サーバーリスト",
    ["Server Log"] = "サーバーログ",
    ["Set Outfit"] = "衣装を設定",
    ["Soul Points"] = "ソウルポイント",
    ["Special"] = "特殊", -- Tokushu
    ["Spell Cooldowns"] = "呪文クールダウン",
    ["Spell List"] = "呪文リスト",
    ["Statement"] = "声明", -- Seimei
    ["Statement Report"] = "声明報告",
    ["Statistics"] = "統計", -- Toukei
    ["Support"] = "サポート",
    ["Terminal"] = "ターミナル",
    ["There is no way."] = "道はありません。",
    ["Title"] = "タイトル",
    ["Total Price"] = "合計価格",
    ["Type"] = "タイプ",
    ["Unload"] = "アンロード",
    ["Waiting List"] = "待機リスト",
    ["Website"] = "ウェブサイト",
    ["Weight"] = "重量", -- Juuryou
    
    -- Connection messages / 接続メッセージ
    ["Connection Error"] = "接続エラー",
    ["Connection failed."] = "接続失敗。",
    ["Connection failed, the server address does not exist."] = "接続失敗。サーバーアドレスが存在しません。",
    ["Client needs update."] = "クライアントの更新が必要です。",
    ["Update needed"] = "更新が必要",
    
    -- Reward Wall & Cyclopedia / 報酬ウォールとサイクロペディア
    ["Date"] = "日付", -- Hizuke
    ["Streak"] = "連続", -- Renzoku
    ["Event"] = "イベント", -- Ibento
    ["Free capacity"] = "空き容量", -- Aki youryou
    ["Total weight"] = "総重量", -- Soujuuryou
    ["Unknown bonus."] = "不明なボーナス。", -- Fumei na boonasu
    ["Not yet, UI missing"] = "まだです、UIがありません", -- Mada desu, UI ga arimasen
    ["Unlocks at 1500 Boss Points"] = "1500ボスポイントで解除", -- 1500 bosu pointo de kaijo
    ["Equipment Loot Bonus"] = "装備ドロップボーナス", -- Soubi doroppu boonasu
    ["Next"] = "次", -- Tsugi
    ["fully unlocked"] = "完全に解除", -- Kanzen ni kaijo
    ["Equipment loot bonus"] = "装備ドロップボーナス", -- Soubi doroppu boonasu
    ["Kill bonus"] = "キルボーナス", -- Kiru boonasu
    ["Boosted Boss"] = "ブーストボス", -- Buusuto bosu
    ["Slot"] = "スロット", -- Surotto
    ["Locked"] = "ロック済み", -- Rokku zumi
    ["Select Boss"] = "ボス選択", -- Bosu sentaku
    ["Unlocks at %d Boss Points"] = "%dボスポイントで解除", -- %d bosu pointo de kaijo
    
    -- House / 家
    ["Your Limit"] = "あなたの上限", -- Anata no jougen
    ["There is no bid so far."] = "まだ入札がありません。", -- Mada nyuusatsu ga arimasen
    ["Be the first to bid on this house."] = "この家に最初に入札してください。", -- Kono ie ni saisho ni nyuusatsu shite kudasai
    ["When the auction ends, the winning bid plus the rent for the first month"] = "オークション終了時、落札額と初月の家賃が", -- Ookushon shuuryou ji, rakusatsugaku to shogetsu no yachin ga
    ["will be debited to your bank account."] = "銀行口座から引き落とされます。", -- Ginkou kouza kara hikiotosaremasu
    ["Auction"] = "オークション", -- Ookushon
    ["Highest Bidder"] = "最高入札者", -- Saikou nyuusatsusha
    ["End Time"] = "終了時間", -- Shuuryou jikan
    ["Highest Bid"] = "最高入札額", -- Saikou nyuusatsugaku
    ["Rental Details"] = "賃貸詳細", -- Chintai shousai
    ["Tenant"] = "借主", -- Karinushi
    ["Paid Until"] = "支払い済み", -- Shiharai zumi
    ["New Owner"] = "新オーナー", -- Shin oonaa
    ["Transfer"] = "譲渡", -- Jouto
    
    -- Misc / その他
    ["Server"] = "サーバー", -- Saabaa
    ["Port"] = "ポート", -- Pooto
    ["Protocol"] = "プロトコル", -- Purotokoru
    ["Version"] = "バージョン", -- Baajon
    ["Name"] = "名前", -- Namae
    ["Name:"] = "名前:", -- Namae:
    ["Description"] = "説明", -- Setsumei
    ["Description:"] = "説明:", -- Setsumei:
    ["Author"] = "作者", -- Sakusha
    ["Add"] = "追加", -- Tsuika
    ["Remove"] = "削除", -- Sakujo
    ["Save"] = "保存", -- Hozon
    ["Load"] = "読込", -- Yomikomi
    ["Refresh"] = "更新", -- Koushin
    ["Search"] = "検索", -- Kensaku
    ["Search:"] = "検索:", -- Kensaku:
    ["Find"] = "検索", -- Kensaku
    ["Find:"] = "検索:", -- Kensaku:
    ["Select"] = "選択", -- Sentaku
    ["Exit"] = "終了", -- Shuuryou
    
    -- Language / 言語
    ["Change language"] = "言語を変更", -- Gengo wo henkou
    ["Select your language"] = "言語を選択", -- Gengo wo sentaku
    ["Language"] = "言語", -- Gengo
  }
}

modules.client_locales.installLocale(locale)
