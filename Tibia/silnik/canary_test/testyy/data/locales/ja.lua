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
