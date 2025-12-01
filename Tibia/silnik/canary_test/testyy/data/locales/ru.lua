-- Russian translations / Русские переводы
-- Includes both Cyrillic and Latin transliteration versions

locale = {
  name = "ru",
  charset = "utf8",
  languageName = "Русский",

  formatNumbers = true,
  decimalSeperator = ',',
  thousandsSeperator = ' ',

  translation = {
    -- Basic UI
    ["Accept"] = "Принять",
    ["Cancel"] = "Отмена",
    ["Close"] = "Закрыть",
    ["Ok"] = "Ок",
    ["Yes"] = "Да",
    ["No"] = "Нет",
    ["Error"] = "Ошибка",
    ["Warning"] = "Предупреждение",
    
    -- Login
    ["Login"] = "Войти",
    ["Logout"] = "Выйти",
    ["Password"] = "Пароль",
    ["Account name"] = "Имя аккаунта",
    ["Remember password"] = "Запомнить пароль",
    ["Auto login"] = "Автовход",
    ["Enter Game"] = "Войти в игру",
    ["Character List"] = "Список персонажей",
    ["Login Error"] = "Ошибка входа",
    ["Connecting to login server..."] = "Подключение к серверу...",
    ["Connecting to game server..."] = "Подключение к игровому серверу...",
    ["Are you sure you want to logout?"] = "Вы уверены, что хотите выйти?",
    ["Logging out..."] = "Выход...",
    ["Unable to logout."] = "Невозможно выйти.",
    
    -- Game
    ["Attack"] = "Атака",
    ["Follow"] = "Следовать",
    ["Look"] = "Осмотреть",
    ["Use"] = "Использовать",
    ["Open"] = "Открыть",
    ["Trade"] = "Торговля",
    ["Rotate"] = "Повернуть",
    
    -- Combat
    ["Battle"] = "Бой",
    ["Stop Attack"] = "Остановить атаку",
    ["Stop Follow"] = "Остановить следование",
    ["Combat Controls"] = "Управление боем",
    
    -- Skills
    ["Skills"] = "Навыки",
    ["Level"] = "Уровень",
    ["Experience"] = "Опыт",
    ["Magic Level"] = "Уровень магии",
    ["Fist Fighting"] = "Бой без оружия",
    ["Club Fighting"] = "Бой палицей",
    ["Sword Fighting"] = "Бой мечом",
    ["Axe Fighting"] = "Бой топором",
    ["Distance Fighting"] = "Дистанционный бой",
    ["Shielding"] = "Защита щитом",
    ["Fishing"] = "Рыбалка",
    
    -- Stats
    ["Health Info"] = "Информация о здоровье",
    ["Hit Points"] = "Здоровье",
    ["Mana"] = "Мана",
    ["Soul"] = "Душа",
    ["Capacity"] = "Грузоподъёмность",
    ["Speed"] = "Скорость",
    ["Stamina"] = "Выносливость",
    
    -- Inventory
    ["Inventory"] = "Инвентарь",
    ["Head"] = "Голова",
    ["Buy"] = "Купить",
    ["Sell"] = "Продать",
    ["Amount"] = "Количество",
    ["Amount:"] = "Количество:",
    ["Price"] = "Цена",
    ["Price:"] = "Цена:",
    
    -- VIP
    ["VIP List"] = "Список VIP",
    ["Add new VIP"] = "Добавить VIP",
    ["Add to VIP list"] = "Добавить в VIP",
    
    -- Party
    ["Invite to Party"] = "Пригласить в группу",
    ["Leave Party"] = "Покинуть группу",
    ["Enable Shared Experience"] = "Включить общий опыт",
    ["Disable Shared Experience"] = "Выключить общий опыт",
    
    -- Options
    ["Options"] = "Настройки",
    ["Graphics"] = "Графика",
    ["Audio"] = "Звук",
    ["Fullscreen"] = "Полный экран",
    ["Enable music"] = "Включить музыку",
    ["Enable lights"] = "Включить освещение",
    
    -- Console
    ["Console"] = "Консоль",
    ["Channels"] = "Каналы",
    ["Open new channel"] = "Открыть новый канал",
    ["Close this channel"] = "Закрыть этот канал",
    ["Send"] = "Отправить",
    ["Copy message"] = "Копировать сообщение",
    ["Copy name"] = "Копировать имя",
    
    -- Minimap
    ["Minimap"] = "Миникарта",
    ["Create mark"] = "Создать метку",
    ["Delete mark"] = "Удалить метку",
    
    -- Market
    ["Market"] = "Рынок",
    ["Market Offers"] = "Предложения рынка",
    ["Buy Offers"] = "Предложения покупки",
    ["Sell Offers"] = "Предложения продажи",
    ["Create Offer"] = "Создать предложение",
    ["My Offers"] = "Мои предложения",
    
    -- Hotkeys
    ["Hotkeys"] = "Горячие клавиши",
    ["Manage hotkeys:"] = "Управление клавишами:",
    ["Current hotkeys:"] = "Текущие клавиши:",
    
    -- Status effects
    ["You are dead"] = "Вы мертвы",
    ["You are dead."] = "Вы мертвы.",
    ["You are poisoned"] = "Вы отравлены",
    ["You are burning"] = "Вы горите",
    ["You are freezing"] = "Вы замерзаете",
    ["You are bleeding"] = "Вы истекаете кровью",
    ["You are drunk"] = "Вы пьяны",
    ["You are hungry"] = "Вы голодны",
    ["You are paralysed"] = "Вы парализованы",
    ["You are hasted"] = "Вы ускорены",
    ["You are protected by a magic shield"] = "Вы защищены магическим щитом",
    
    -- Misc
    ["Server"] = "Сервер",
    ["Port"] = "Порт",
    ["Protocol"] = "Протокол",
    ["Version"] = "Версия",
    ["Name"] = "Имя",
    ["Name:"] = "Имя:",
    ["Description"] = "Описание",
    ["Description:"] = "Описание:",
    ["Author"] = "Автор",
    ["Add"] = "Добавить",
    ["Remove"] = "Удалить",
    ["Save"] = "Сохранить",
    ["Load"] = "Загрузить",
    ["Refresh"] = "Обновить",
    ["Search"] = "Поиск",
    ["Search:"] = "Поиск:",
    ["Find"] = "Найти",
    ["Find:"] = "Найти:",
    ["Select"] = "Выбрать",
    ["Exit"] = "Выход",
    
    -- Language
    ["Change language"] = "Сменить язык",
    ["Select your language"] = "Выберите язык",
    ["Language"] = "Язык",
  }
}

modules.client_locales.installLocale(locale)
