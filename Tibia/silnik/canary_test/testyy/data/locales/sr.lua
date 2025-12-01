-- Serbian translations / Српски преводи
-- Uses Latin alphabet (can be easily converted to Cyrillic)

locale = {
  name = "sr",
  charset = "utf8",
  languageName = "Srpski",

  formatNumbers = true,
  decimalSeperator = ',',
  thousandsSeperator = '.',

  translation = {
    -- Basic UI
    ["Accept"] = "Prihvati",
    ["Cancel"] = "Otkaži",
    ["Close"] = "Zatvori",
    ["Ok"] = "Ok",
    ["Yes"] = "Da",
    ["No"] = "Ne",
    ["Error"] = "Greška",
    ["Warning"] = "Upozorenje",
    
    -- Login
    ["Login"] = "Prijava",
    ["Logout"] = "Odjava",
    ["Password"] = "Lozinka",
    ["Account name"] = "Ime naloga",
    ["Remember password"] = "Zapamti lozinku",
    ["Auto login"] = "Automatska prijava",
    ["Enter Game"] = "Uđi u igru",
    ["Character List"] = "Lista likova",
    ["Login Error"] = "Greška pri prijavi",
    ["Connecting to login server..."] = "Povezivanje sa serverom...",
    ["Connecting to game server..."] = "Povezivanje sa serverom igre...",
    ["Are you sure you want to logout?"] = "Da li ste sigurni da želite da se odjavite?",
    ["Logging out..."] = "Odjavljivanje...",
    ["Unable to logout."] = "Nije moguće odjaviti se.",
    
    -- Game
    ["Attack"] = "Napadni",
    ["Follow"] = "Prati",
    ["Look"] = "Pogledaj",
    ["Use"] = "Koristi",
    ["Open"] = "Otvori",
    ["Trade"] = "Trgovina",
    ["Rotate"] = "Rotiraj",
    
    -- Combat
    ["Battle"] = "Borba",
    ["Stop Attack"] = "Zaustavi napad",
    ["Stop Follow"] = "Zaustavi praćenje",
    ["Combat Controls"] = "Kontrole borbe",
    
    -- Skills
    ["Skills"] = "Veštine",
    ["Level"] = "Nivo",
    ["Experience"] = "Iskustvo",
    ["Magic Level"] = "Magijski nivo",
    ["Fist Fighting"] = "Borba pesnicama",
    ["Club Fighting"] = "Borba buzdovanom",
    ["Sword Fighting"] = "Borba mačem",
    ["Axe Fighting"] = "Borba sekirom",
    ["Distance Fighting"] = "Borba na daljinu",
    ["Shielding"] = "Odbrana štitom",
    ["Fishing"] = "Pecanje",
    
    -- Stats
    ["Health Info"] = "Informacije o zdravlju",
    ["Hit Points"] = "Poeni zdravlja",
    ["Mana"] = "Mana",
    ["Soul"] = "Duša",
    ["Capacity"] = "Kapacitet",
    ["Speed"] = "Brzina",
    ["Stamina"] = "Izdržljivost",
    
    -- Inventory
    ["Inventory"] = "Inventar",
    ["Head"] = "Glava",
    ["Buy"] = "Kupi",
    ["Sell"] = "Prodaj",
    ["Amount"] = "Količina",
    ["Amount:"] = "Količina:",
    ["Price"] = "Cena",
    ["Price:"] = "Cena:",
    
    -- VIP
    ["VIP List"] = "VIP lista",
    ["Add new VIP"] = "Dodaj novi VIP",
    ["Add to VIP list"] = "Dodaj na VIP listu",
    
    -- Party
    ["Invite to Party"] = "Pozovi u grupu",
    ["Leave Party"] = "Napusti grupu",
    ["Enable Shared Experience"] = "Omogući deljeno iskustvo",
    ["Disable Shared Experience"] = "Onemogući deljeno iskustvo",
    
    -- Options
    ["Options"] = "Opcije",
    ["Graphics"] = "Grafika",
    ["Audio"] = "Zvuk",
    ["Fullscreen"] = "Ceo ekran",
    ["Enable music"] = "Omogući muziku",
    ["Enable lights"] = "Omogući svetla",
    
    -- Console
    ["Console"] = "Konzola",
    ["Channels"] = "Kanali",
    ["Open new channel"] = "Otvori novi kanal",
    ["Close this channel"] = "Zatvori ovaj kanal",
    ["Send"] = "Pošalji",
    ["Copy message"] = "Kopiraj poruku",
    ["Copy name"] = "Kopiraj ime",
    
    -- Minimap
    ["Minimap"] = "Minimapa",
    ["Create mark"] = "Kreiraj oznaku",
    ["Delete mark"] = "Obriši oznaku",
    
    -- Market
    ["Market"] = "Pijaca",
    ["Market Offers"] = "Ponude na pijaci",
    ["Buy Offers"] = "Ponude za kupovinu",
    ["Sell Offers"] = "Ponude za prodaju",
    ["Create Offer"] = "Kreiraj ponudu",
    ["My Offers"] = "Moje ponude",
    
    -- Hotkeys
    ["Hotkeys"] = "Prečice",
    ["Manage hotkeys:"] = "Upravljaj prečicama:",
    ["Current hotkeys:"] = "Trenutne prečice:",
    
    -- Status effects
    ["You are dead"] = "Mrtav si",
    ["You are dead."] = "Mrtav si.",
    ["You are poisoned"] = "Otrovan si",
    ["You are burning"] = "Goriš",
    ["You are freezing"] = "Smrzavaš se",
    ["You are bleeding"] = "Krvariš",
    ["You are drunk"] = "Pijan si",
    ["You are hungry"] = "Gladan si",
    ["You are paralysed"] = "Paralizovan si",
    ["You are hasted"] = "Ubrzan si",
    ["You are protected by a magic shield"] = "Zaštićen si magičnim štitom",
    
    -- Misc
    ["Server"] = "Server",
    ["Port"] = "Port",
    ["Protocol"] = "Protokol",
    ["Version"] = "Verzija",
    ["Name"] = "Ime",
    ["Name:"] = "Ime:",
    ["Description"] = "Opis",
    ["Description:"] = "Opis:",
    ["Author"] = "Autor",
    ["Add"] = "Dodaj",
    ["Remove"] = "Ukloni",
    ["Save"] = "Sačuvaj",
    ["Load"] = "Učitaj",
    ["Refresh"] = "Osveži",
    ["Search"] = "Pretraži",
    ["Search:"] = "Pretraži:",
    ["Find"] = "Pronađi",
    ["Find:"] = "Pronađi:",
    ["Select"] = "Izaberi",
    ["Exit"] = "Izlaz",
    
    -- Language
    ["Change language"] = "Promeni jezik",
    ["Select your language"] = "Izaberi jezik",
    ["Language"] = "Jezik",
  }
}

modules.client_locales.installLocale(locale)
