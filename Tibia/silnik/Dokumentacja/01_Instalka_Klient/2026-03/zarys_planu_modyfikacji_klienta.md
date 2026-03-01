Mam pytanie jak byś rozwiązać aby w jednej instalce OTC klient była opcja do wyboru tibia aktualna i tibia 7.4 i gdy wybierzesz tobie 7.4 to jest wiele innych opcji np. blokada hotkeys na runy i przedmioty czy możliwość już wrzucania itemow wszystkich itemow do ekwipunku 
Myślał przez 7s

Da się to zrobić sensownie, ale klucz to nie „mieszać wszystkiego naraz”, tylko zrobić w jednej instalce system profili (trybów), który przełącza:

dane klienta (things/sprites + dat/spr)

protokół / sposób logowania (HTTP vs protocol login, RSA, wersja protokołu)

zestaw funkcji UI/komfortu (hotkeys, quick-loot, drag&drop, itp.) – jako feature flags

walidację po stronie serwera (bo klienta zawsze da się przerobić)

Poniżej masz podejście, które jest stabilne i łatwe do rozbudowy.

1) Jedna instalka = Launcher + Profile + Zasoby

Najczyściej: instalka zawiera launcher, a launcher ma wybór profilu:

„Tibia Aktualna (np. 14.12)”

„Classic 7.4 (styl)” (przy czym technicznie możesz odpalać to na kliencie 7.6/8.0–8.2 lub nawet 14.x, ale z classic-trybem UI/zasadami)

W Twoim ekosystemie już masz bazę pod to, bo używasz launcher_config.json oraz API URL w stylu /api/v1/ 

audit_html_zip_REALCHECK_2025-0…

. To oznacza, że profil może decydować, który zestaw danych i jaki config ma być pobrany/aktywny.

2) Struktura „profiles” (konkretnie)

Zrób jeden plik np. profiles.json (lub OTML), a w nim:

id, name

protocol (np. 1412 dla nowego, a dla classic wg Twojej implementacji)

assetsPack (np. things/1412 dla nowego; dla classic osobny katalog)

loginMode (HTTP / protocol)

featureFlags (lista flag)

uiPreset (folder z OTUI/OTML, hotkeys preset, układ paneli)

serverList (domyślny world/endpoint)

W samym OTClient masz już praktykę trzymania wpisów serwerów i przełączania HTTP/protocol w Lua (np. Servers_init w client_entergame) 

worklog_all

 – to da się spiąć z profilem.

3) Feature flags: czyli jak zrobić „Classic rules” bez rzeźbienia wszędzie

W profilu ustawiasz np.:

Przykładowe flagi dla Classic 7.4

classic_hotkeys_runes_disabled = true

classic_hotkeys_items_disabled = true

classic_no_item_move_to_eq_anywhere = true (albo odwrotnie, jeśli chcesz ułatwienie)

classic_no_modern_ui_panels = true

classic_no_quickloot = true

classic_no_autoloot = true

classic_no_actionbar = true

classic_container_rules = "old" (np. brak sortowania, brak smart-move)

Dla „Aktualnej”

modern_actionbar = true

modern_hotkeys_full = true

modern_quickloot = true

modern_move_items = true

itd.

Ważne: te flagi czytasz w 2–3 centralnych miejscach, a nie „po całym kliencie”.

Najlepsze punkty zaczepienia (praktycznie):

manager hotkeys (modules/game_hotkeys/...) – blokowanie bindów lub wykonywania akcji

obsługa „use item / use with / move item” (tam, gdzie idzie request do protokołu)

UI: ładowanie modułów .otmod zależnie od flag (classic wycina actionbar/market/cyclopedia itd.)

4) Blokada hotkeys na runy/przedmioty – jak to zrobić poprawnie

Masz 2 poziomy:

Poziom A: UI/UX (szybkie i skuteczne)

W trybie Classic:

nie pozwalaj dodać hotkey typu “use item” / “use with”

albo pozwól dodać, ale nie wykonuj akcji (wyświetl komunikat)

To robisz w module hotkeys: walidacja przy dodawaniu + walidacja przy użyciu.

Poziom B: Anty-cheat / pewność reguł (konieczne)

Klient można zmodyfikować. Jeśli Classic ma być „sportowy”, to serwer musi egzekwować zasady:

jeśli akcja to “use rune via hotkey” → serwer odrzuca albo nakłada cooldown/warunek

jeśli „move item do eq z pominięciem zasad” → serwer odrzuca

Inaczej ktoś odpali custom client i ma wszystko.

5) „Możliwość wrzucania wszystkich itemów do ekwipunku” – o co chodzi technicznie

Tu są dwa różne tematy:

przenoszenie itemów w UI (drag & drop / smart-move)

logika serwera (czy item może być założony/umieszczony w slocie, czy w ogóle istnieje w tej wersji)

Jeżeli chcesz w Classic „ułatwienie” (np. szybkie wrzucenie do slotów), to po stronie klienta możesz:

zrobić „smart equip”: jeśli przesuwasz item, klient proponuje docelowy slot

ale finalna walidacja i tak musi być serwerowa

Jeżeli chcesz w Classic „utrudnienie” (brak takich ułatwień), to wyłączasz:

automatyczne przerzucanie

skróty typu ctrl+klik „equip”

wszelkie akcje „move stacks directly”, „auto equip” (to akurat w tłumaczeniach i opcjach też się przewija jako funkcjonalność UI) 

worklog_all

6) Najważniejsza decyzja strategiczna (żeby nie wpaść w pułapkę)

Masz dwie rozsądne drogi:

Opcja 1: Jeden klient „technicznie nowy”, a Classic to tylko profil UI + reguły

plusy: jedna baza kodu, proste utrzymanie

minusy: „feeling” 7.4 to nie tylko UI – dochodzi zachowanie walki, animacji, opóźnień, itp. (to w większości i tak robisz w serwerze)

Opcja 2: Dwa różne asset packi i dwa profile protokołu

plusy: możesz mieć „prawdziwszy” klasyk

minusy: utrzymanie rośnie, więcej testów

W praktyce: zacząłbym od opcji 1, a dopiero gdy „Classic” będzie gotowy gameplayowo, rozdzielałbym głębiej.

Jeżeli chcesz, w następnym kroku mogę rozpisać Ci minimalny zestaw flag i miejsc w kodzie/Lua, które trzeba spiąć, żeby już dziś dało się przełączać „Classic/Aktualna” bez rozwalania reszty (i bez dotykania 50 plików naraz).

Źródła
Czaciku ale znowu zapomniałeś my robimy imitację 74 czyli nie zmieniamy protokołów nie zmieniamy żadnych protokołów czy things sprites
Myślał kilka sekund

Masz rację — jeżeli robimy imitację 7.4 na tym samym protokole i tych samych rzeczach (things/sprites), to cała „różnica 7.4 vs aktualna” musi siedzieć wyłącznie w zachowaniu klienta (UI/controls) + zasadach po stronie serwera.

W praktyce robisz to tak:

1) Jeden klient, dwa tryby działania (profile) – bez zmiany protokołu

Dodajesz w kliencie przełącznik: Tryb: Modern / Classic 7.4 (imitacja).
Ten tryb nie zmienia assets ani protokołu – zmienia tylko:

jakie moduły UI są ładowane

jakie skróty i akcje są dozwolone

jak działają ułatwienia (smart-move, quick actions, action bar itd.)

jakie limity/reguły są egzekwowane (częściowo w kliencie, docelowo na serwerze)

Najprościej: jedna globalna flaga w Lua, np. g_gameConfig.profile = "classic74" i zestaw feature flags.

2) Feature flags: “classic74” to lista wyłączeń/wymuszeń

Dla Twoich przykładów:

A) Blokada hotkeys na runy i przedmioty

Robisz to na 2 poziomach:

Poziom UI (żeby gracz widział, że się nie da):

w module hotkeys blokujesz dodawanie bindów typu “use item / use with item”

ewentualnie pozwalasz dodać, ale przy wykonaniu pokazujesz komunikat i nic nie wysyłasz

Poziom reguł (żeby nikt nie oszukiwał przerobionym klientem):

serwer odrzuca akcje, które w “classic74” są zabronione (np. użycie runy przez hotkey / szybkie użycie itema „bez kontekstu”)

Bez serwera to zawsze będzie do obejścia.

B) “Wrzucanie itemów do ekwipunku” (zależy co masz na myśli)

Tu są dwa warianty — oba bez zmiany protokołu:

Wariant 1: Ułatwienie (smart equip / szybkie zakładanie)

klient może robić „podpowiedź slota” i wykonywać move/use szybciej

serwer waliduje, czy item może wejść w slot i czy akcja jest dozwolona

Wariant 2: Classic ogranicza ułatwienia

wyłączasz: ctrl+klik equip, auto-equip, “smart move to slot”, skróty na przerzucanie

zostaje czysty drag&drop jak w klasyku

To jest dokładnie kwestia flag + intercept w logice przenoszenia/use.

3) Gdzie to spinać, żeby nie przerabiać 200 plików

Trzymasz „bramki” w 3 miejscach:

Hotkeys – zanim wyślesz jakąkolwiek akcję “use/useWith/move”

Item actions / move – centralny punkt, gdzie klient tworzy request (use/move)

Ładowanie modułów UI – classic ładuje inną paczkę/preset (albo wycina action bar / szybkie przyciski)

Dzięki temu “classic74” to w większości konfiguracja + kilka ifów w punktach krytycznych, a nie wielka przebudowa.

4) Najważniejsze: serwer musi znać tryb “classic74”

Skoro protokół i assets zostają, to tryb rozpoznajesz i egzekwujesz np. tak:

tryb przypisany do świata (world = classic) albo

tryb przypisany do konta/postać/serwerlisty (przy logowaniu)
i wtedy serwer:

odrzuca zabronione akcje

ustawia cooldowny/limity zgodne z klasykiem

prowadzi spójne zasady niezależnie od klienta

Jeśli chcesz, to podam Ci konkretną listę flag “classic74” (np. 15–30 pozycji: hotkeys, smart-move, actionbar, quick-loot, use-with, wheel, container actions) i mapę: które 3–5 miejsc w OTClient/Lua muszą je sprawdzać, żeby to zaczęło działać od razu.

Dobrze to więc lecimy po kolei bo za dużo informacji mi piszesz które są niepotrzebne. Sumując moje wypowiedzi tworzymy dalej plan. Już się pytam ciebie jeżeli w kliencie wybiorę tryb 74 to w gotowej instalce której pobiera gracz ma zablokowaną możliwość dodawania serwerów i serwery już są w niej dodane z którymi możesz się połączyć za pomocą http te wszystkie opcje z dodawaniem serwerów powinny być niewidoczne dla gracza który pobiera instalkę. Bym tylko i wyłącznie ja jako właściciel tej instalki i serwerów mógł dodawać serwery z jakimi można się łączyć za pomocą tej instalki a na serwerze powinna być blokada aby inne instalki nie mogły się z nim łączyć jak ta którą ja udostępniamI i wtedy gdy ktoś wybierze tryb 74 w instalce to nie może się połączyć z innym serwerem jak z serwer imitacja 74. 
Myślał przez 13s

Tak — to da się zrobić w Twoim założeniu (ten sam protokół, te same sprites), tylko trzeba rozdzielić to na dwie rzeczy:

Klient/instalka: gracz nie widzi opcji dodawania serwerów, a lista serwerów jest „na sztywno” sterowana przez Ciebie (np. pobierana z Twojego API i podpisana).

Serwer: nie wpuszcza „byle jakiego” klienta — wpuszcza tylko sesje wygenerowane przez Twoje HTTP API (czyli bez przejścia przez Twoją instalkę/launcher nie ma jak się zalogować).

Uwaga uczciwa: na PC nie da się tego zrobić w 100% „nie do złamania”, bo ktoś może przerobić klienta. Da się natomiast zrobić to tak, żeby zwykły użytkownik nie miał opcji, a obejście wymagało realnego reverse engineeringu + częstych aktualizacji po Twojej stronie.

Co dokładnie ma się dziać w trybie 7.4 (Twoje wymagania)

Brak UI do dodawania/edycji serwerów (niewidoczne).

Lista serwerów jest tylko Twoja (zaciągana z HTTP lub wbudowana).

Po wyborze Tryb 7.4 klient widzi tylko serwer „imitacja 7.4” i nie ma jak wybrać innego.

Serwer 7.4 odrzuca logowanie jeśli nie ma „Twojej” autoryzacji z HTTP (token/sesja).

KROK 1 (pierwszy, najważniejszy)

Ukryj graczowi zarządzanie serwerami i wymuś ładowanie listy serwerów tylko z Twojego endpointu HTTP — a w trybie 7.4 filtruj listę do 1 świata (classic).

To jest fundament, bo bez tego użytkownik zawsze będzie mógł „kliknąć i dodać IP”.

Jeśli potwierdzisz, że to wdrażamy jako pierwszy krok, to w kolejnym kroku przejdziemy do blokady po stronie serwera (token z HTTP jako warunek wejścia), bo to dopiero daje sensowne “tylko moja instalka może się łączyć”.

Ale jeszcze ci dodam że na przykład na githubie OTC klient oryginalny jest do pobrania instalka której nie ma żadnych plików lua czy dat tam jest gotowa instalka tylko do odpalenia dla zwykłego gracza i jeśli coś takiego uda nam się zrobić i skompilować to jakim cudem gracz będzie mógł przerobić moją instalkę? 
Myślał przez 11s

To, że instalka „dla gracza” nie ma Lua/dat i jest tylko gotowym EXE, nie oznacza, że nie da się jej przerobić. Oznacza tylko, że trudniej.

Gracz nadal może obejść Twoje ograniczenia na kilka sposobów (bez wchodzenia w techniczne instrukcje łamania zabezpieczeń):

Patch binarki / wstrzyknięcie DLL
Nawet bez Lua da się zmienić zachowanie klienta, bo logika nadal jest w kodzie (C++). Narzędzia do analizy i modyfikacji binarek istnieją i są powszechne.

Podmiana lub przechwycenie ruchu sieciowego (proxy / MITM)
Jeśli klient pobiera listę serwerów przez HTTP, ktoś może próbować przechwycić/zastąpić odpowiedź i „wcisnąć” inne serwery, albo odtworzyć Twoje wywołania API.

Napisanie własnego klienta / użycie innego OTClienta
Jeżeli serwer przyjmuje logowanie „standardowo”, to ktoś może użyć innej instalki, byle umiała gadać tym samym protokołem.

Wniosek: blokowanie UI w kliencie jest dobre (dla zwykłych graczy), ale nie jest zabezpieczeniem. Zabezpieczenie musi być po stronie serwera.

Co działa realnie w Twoim modelu “tylko moja instalka”

Najmocniejszy wariant w Twoich założeniach (bez zmiany protokołu/things) to:

logowanie tylko po autoryzacji z Twojego HTTP API (token sesyjny krótko żyjący, jednorazowy),

serwer odrzuca połączenie, jeśli nie dostanie poprawnego tokenu/handshake’u z Twojego API,

dodatkowo: pinning certyfikatu po stronie klienta + podpisywanie odpowiedzi z API (żeby trudniej było podmienić listę serwerów).

To nadal nie daje “100% nie do złamania”, ale podnosi próg na tyle, że przypadkowe osoby odpadają, a Ty masz kontrolę nad tym, kto wejdzie.

Następny krok (jeden, konkretny): ustalamy format “token-gate” na serwerze (co serwer ma wymagać od klienta po HTTP-loginie), tak żeby bez Twojego API nie dało się wejść na world 7.4.

Tutaj już chodzi o to aby bez tego API nie można było wejść na jakikolwiek serwer
Otrzymano odpowiedź aplikacji
Myślał przez 12s

Rozumiem. W takim razie robimy jeden, spójny standard: bez Twojego API nie da się wejść na żaden Twój serwer, niezależnie od trybu (74/modern). I to jest podejście właściwe, bo wtedy sama „instalka” jest tylko klientem, a bramą bezpieczeństwa jest API + serwer.

Jak to spiąć (bez zmiany protokołów/things)
1) Serwer wymaga “biletu sesji” z Twojego API

Schemat:

Klient łączy się najpierw z Twoim HTTP API (login).

API po poprawnym loginie wydaje krótko-żyjący, jednorazowy token (ticket) + wskazuje world/tryb.

Klient próbuje wejść na serwer gry i musi przedstawić ticket.

Serwer przyjmuje połączenie tylko wtedy, gdy:

ticket jest ważny (czas, podpis, nieużyty),

ticket jest wystawiony na ten konkretny world,

ticket spełnia politykę (np. tryb 74 → tylko world classic).

Efekt: ktoś może mieć inną instalkę, ale bez Twojego API nie dostanie biletu, więc nie wejdzie.

2) Ticket musi być weryfikowalny offline albo przez szybki callback

Masz dwa bezpieczne warianty:

A. Ticket podpisany (JWT/PASETO lub własny podpis HMAC/Ed25519)
Serwer weryfikuje podpis lokalnie, bez pytania API (szybko, stabilnie).

B. Ticket “opaque” + serwer pyta API o walidację
Serwer robi krótkie zapytanie do API: „czy ticket X jest ważny?” (łatwe do revokowania, ale wymaga dostępności API).

W praktyce najlepiej: podpis + dodatkowy “used nonce” w DB, żeby był jednorazowy.

3) Wymuszenie trybu 7.4

W ticket wpisujesz pole typu:

mode: classic74 albo mode: modern

worldId: classic albo worldId: main

Serwer world “classic74” odrzuca ticket bez mode=classic74.
Serwer world “modern” odrzuca ticket z mode=classic74, jeśli chcesz separacji.

4) Ukrycie dodawania serwerów w instalce (to jest tylko UX)

To nadal robisz, ale to jest warstwa wygody, nie bezpieczeństwa:

w trybie 74 pokazujesz tylko world classic,

brak UI do edycji/dodawania,

lista serwerów z API może być podpisana, żeby trudniej ją podmienić.

Bez ticketów po stronie serwera, samo ukrycie UI nie ma wartości ochronnej.

Krok 1 (jeden, konkretny – od tego zaczynamy plan)

Definiujemy format “ticketu sesji” i zasady walidacji na serwerze (czas życia, jednorazowość, worldId, mode).

Jeśli to potwierdzasz, w następnym kroku podam Ci minimalny, praktyczny zestaw pól ticketu + politykę (np. TTL 60–120s, nonce, accountId/characterId, worldId, mode) i jak to logicznie wpiąć w przepływ logowania HTTP, żeby działało dla wszystkich Twoich serwerów.