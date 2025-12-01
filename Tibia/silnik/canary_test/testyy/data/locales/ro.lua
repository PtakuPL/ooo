-- Romanian translations / Traduceri în limba română

locale = {
  name = "ro",
  charset = "utf8",
  languageName = "Română",

  formatNumbers = true,
  decimalSeperator = ',',
  thousandsSeperator = '.',

  translation = {
    -- Basic UI
    ["Accept"] = "Acceptă",
    ["Cancel"] = "Anulează",
    ["Close"] = "Închide",
    ["Ok"] = "Ok",
    ["Yes"] = "Da",
    ["No"] = "Nu",
    ["Error"] = "Eroare",
    ["Warning"] = "Avertisment",
    
    -- Login
    ["Login"] = "Conectare",
    ["Logout"] = "Deconectare",
    ["Password"] = "Parolă",
    ["Account name"] = "Nume cont",
    ["Remember password"] = "Reține parola",
    ["Auto login"] = "Autentificare automată",
    ["Enter Game"] = "Intră în joc",
    ["Character List"] = "Lista personajelor",
    ["Login Error"] = "Eroare de conectare",
    ["Connecting to login server..."] = "Conectare la server...",
    ["Connecting to game server..."] = "Conectare la serverul de joc...",
    ["Are you sure you want to logout?"] = "Ești sigur că vrei să te deconectezi?",
    ["Logging out..."] = "Deconectare...",
    ["Unable to logout."] = "Nu se poate deconecta.",
    
    -- Game
    ["Attack"] = "Atacă",
    ["Follow"] = "Urmărește",
    ["Look"] = "Privește",
    ["Use"] = "Folosește",
    ["Open"] = "Deschide",
    ["Trade"] = "Comerț",
    ["Rotate"] = "Rotește",
    
    -- Combat
    ["Battle"] = "Luptă",
    ["Stop Attack"] = "Oprește atacul",
    ["Stop Follow"] = "Oprește urmărirea",
    ["Combat Controls"] = "Controale de luptă",
    
    -- Skills
    ["Skills"] = "Abilități",
    ["Level"] = "Nivel",
    ["Experience"] = "Experiență",
    ["Magic Level"] = "Nivel magic",
    ["Fist Fighting"] = "Luptă cu pumnii",
    ["Club Fighting"] = "Luptă cu măciuca",
    ["Sword Fighting"] = "Luptă cu sabia",
    ["Axe Fighting"] = "Luptă cu toporul",
    ["Distance Fighting"] = "Luptă la distanță",
    ["Shielding"] = "Apărare cu scutul",
    ["Fishing"] = "Pescuit",
    
    -- Stats
    ["Health Info"] = "Informații sănătate",
    ["Hit Points"] = "Puncte de viață",
    ["Mana"] = "Mana",
    ["Soul"] = "Suflet",
    ["Capacity"] = "Capacitate",
    ["Speed"] = "Viteză",
    ["Stamina"] = "Rezistență",
    
    -- Inventory
    ["Inventory"] = "Inventar",
    ["Head"] = "Cap",
    ["Buy"] = "Cumpără",
    ["Sell"] = "Vinde",
    ["Amount"] = "Cantitate",
    ["Amount:"] = "Cantitate:",
    ["Price"] = "Preț",
    ["Price:"] = "Preț:",
    
    -- VIP
    ["VIP List"] = "Lista VIP",
    ["Add new VIP"] = "Adaugă VIP nou",
    ["Add to VIP list"] = "Adaugă la lista VIP",
    
    -- Party
    ["Invite to Party"] = "Invită în grup",
    ["Leave Party"] = "Părăsește grupul",
    ["Enable Shared Experience"] = "Activează experiența partajată",
    ["Disable Shared Experience"] = "Dezactivează experiența partajată",
    
    -- Options
    ["Options"] = "Opțiuni",
    ["Graphics"] = "Grafică",
    ["Audio"] = "Audio",
    ["Fullscreen"] = "Ecran complet",
    ["Enable music"] = "Activează muzica",
    ["Enable lights"] = "Activează luminile",
    
    -- Console
    ["Console"] = "Consolă",
    ["Channels"] = "Canale",
    ["Open new channel"] = "Deschide canal nou",
    ["Close this channel"] = "Închide acest canal",
    ["Send"] = "Trimite",
    ["Copy message"] = "Copiază mesajul",
    ["Copy name"] = "Copiază numele",
    
    -- Minimap
    ["Minimap"] = "Minihartă",
    ["Create mark"] = "Creează marcaj",
    ["Delete mark"] = "Șterge marcaj",
    
    -- Market
    ["Market"] = "Piață",
    ["Market Offers"] = "Oferte piață",
    ["Buy Offers"] = "Oferte de cumpărare",
    ["Sell Offers"] = "Oferte de vânzare",
    ["Create Offer"] = "Creează ofertă",
    ["My Offers"] = "Ofertele mele",
    
    -- Hotkeys
    ["Hotkeys"] = "Taste rapide",
    ["Manage hotkeys:"] = "Gestionează tastele:",
    ["Current hotkeys:"] = "Taste curente:",
    
    -- Status effects
    ["You are dead"] = "Ești mort",
    ["You are dead."] = "Ești mort.",
    ["You are poisoned"] = "Ești otrăvit",
    ["You are burning"] = "Arzi",
    ["You are freezing"] = "Înghețați",
    ["You are bleeding"] = "Sângerezi",
    ["You are drunk"] = "Ești beat",
    ["You are hungry"] = "Ești flămând",
    ["You are paralysed"] = "Ești paralizat",
    ["You are hasted"] = "Ești grăbit",
    ["You are protected by a magic shield"] = "Ești protejat de un scut magic",
    
    -- Misc
    ["Server"] = "Server",
    ["Port"] = "Port",
    ["Protocol"] = "Protocol",
    ["Version"] = "Versiune",
    ["Name"] = "Nume",
    ["Name:"] = "Nume:",
    ["Description"] = "Descriere",
    ["Description:"] = "Descriere:",
    ["Author"] = "Autor",
    ["Add"] = "Adaugă",
    ["Remove"] = "Elimină",
    ["Save"] = "Salvează",
    ["Load"] = "Încarcă",
    ["Refresh"] = "Reîmprospătează",
    ["Search"] = "Caută",
    ["Search:"] = "Caută:",
    ["Find"] = "Găsește",
    ["Find:"] = "Găsește:",
    ["Select"] = "Selectează",
    ["Exit"] = "Ieșire",
    
    -- Language
    ["Change language"] = "Schimbă limba",
    ["Select your language"] = "Selectează limba",
    ["Language"] = "Limba",
  }
}

modules.client_locales.installLocale(locale)
