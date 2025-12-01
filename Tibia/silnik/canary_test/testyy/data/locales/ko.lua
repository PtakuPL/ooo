-- Korean translations / 한국어 번역
-- Uses Hangul with romanized (romaji) comments

locale = {
  name = "ko",
  charset = "utf8",
  languageName = "한국어",

  formatNumbers = true,
  decimalSeperator = '.',
  thousandsSeperator = ',',

  translation = {
    -- Basic UI / 기본 UI
    ["Accept"] = "수락", -- Surak
    ["Cancel"] = "취소", -- Chwiso
    ["Close"] = "닫기", -- Datgi
    ["Ok"] = "확인", -- Hwagin
    ["Yes"] = "예", -- Ye
    ["No"] = "아니오", -- Anio
    ["Error"] = "오류", -- Oryu
    ["Warning"] = "경고", -- Gyeonggo
    
    -- Login / 로그인
    ["Login"] = "로그인", -- Rogeu-in
    ["Logout"] = "로그아웃", -- Rogeu-aut
    ["Password"] = "비밀번호", -- Bimilbeonho
    ["Account name"] = "계정 이름", -- Gyejeong ireum
    ["Remember password"] = "비밀번호 저장", -- Bimilbeonho jeojang
    ["Auto login"] = "자동 로그인", -- Jadong rogeu-in
    ["Enter Game"] = "게임 입장", -- Geim ipjang
    ["Character List"] = "캐릭터 목록", -- Kaerikter mongnog
    ["Login Error"] = "로그인 오류", -- Rogeu-in oryu
    ["Connecting to login server..."] = "로그인 서버에 연결 중...", -- Rogeu-in seobeoe yeongyeol jung
    ["Connecting to game server..."] = "게임 서버에 연결 중...", -- Geim seobeoe yeongyeol jung
    ["Are you sure you want to logout?"] = "로그아웃 하시겠습니까?", -- Rogeu-aut hasigetseumnikka?
    ["Logging out..."] = "로그아웃 중...", -- Rogeu-aut jung
    ["Unable to logout."] = "로그아웃할 수 없습니다.", -- Rogeu-authal su eobsseumnida
    
    -- Game / 게임
    ["Attack"] = "공격", -- Gonggyeok
    ["Follow"] = "따라가기", -- Ttaragagi
    ["Look"] = "보기", -- Bogi
    ["Use"] = "사용", -- Sayong
    ["Open"] = "열기", -- Yeolgi
    ["Trade"] = "거래", -- Georae
    ["Rotate"] = "회전", -- Hoejeon
    
    -- Combat / 전투
    ["Battle"] = "전투", -- Jeontu
    ["Stop Attack"] = "공격 중지", -- Gonggyeok jungji
    ["Stop Follow"] = "따라가기 중지", -- Ttaragagi jungji
    ["Combat Controls"] = "전투 컨트롤", -- Jeontu keonteurol
    
    -- Skills / 스킬
    ["Skills"] = "스킬", -- Seukil
    ["Level"] = "레벨", -- Rebel
    ["Experience"] = "경험치", -- Gyeongheomchi
    ["Magic Level"] = "마법 레벨", -- Mabeob rebel
    ["Fist Fighting"] = "맨손 전투", -- Maenson jeontu
    ["Club Fighting"] = "곤봉 전투", -- Gonbong jeontu
    ["Sword Fighting"] = "검술", -- Geomsul
    ["Axe Fighting"] = "도끼 전투", -- Dokki jeontu
    ["Distance Fighting"] = "원거리 전투", -- Wongeori jeontu
    ["Shielding"] = "방어", -- Bang-eo
    ["Fishing"] = "낚시", -- Naksi
    
    -- Stats / 스탯
    ["Health Info"] = "체력 정보", -- Cheryeok jeongbo
    ["Hit Points"] = "체력", -- Cheryeok
    ["Mana"] = "마나", -- Mana
    ["Soul"] = "영혼", -- Yeonghon
    ["Capacity"] = "적재량", -- Jeokjaeryang
    ["Speed"] = "속도", -- Sokdo
    ["Stamina"] = "스태미나", -- Seutaemina
    
    -- Inventory / 인벤토리
    ["Inventory"] = "인벤토리", -- Inbentori
    ["Head"] = "머리", -- Meori
    ["Buy"] = "구매", -- Gumae
    ["Sell"] = "판매", -- Panmae
    ["Amount"] = "수량", -- Suryang
    ["Amount:"] = "수량:", -- Suryang:
    ["Price"] = "가격", -- Gagyeok
    ["Price:"] = "가격:", -- Gagyeok:
    
    -- VIP
    ["VIP List"] = "VIP 목록", -- VIP mongnog
    ["Add new VIP"] = "새 VIP 추가", -- Sae VIP chuga
    ["Add to VIP list"] = "VIP 목록에 추가", -- VIP mongnoge chuga
    
    -- Party / 파티
    ["Invite to Party"] = "파티 초대", -- Pati chodae
    ["Leave Party"] = "파티 나가기", -- Pati nagagi
    ["Enable Shared Experience"] = "경험치 공유 활성화", -- Gyeongheomchi gongyuhwalseong-hwa
    ["Disable Shared Experience"] = "경험치 공유 비활성화", -- Gyeongheomchi gongyu bihwalseong-hwa
    
    -- Options / 옵션
    ["Options"] = "옵션", -- Obsyeon
    ["Graphics"] = "그래픽", -- Geuraepik
    ["Audio"] = "오디오", -- Odio
    ["Fullscreen"] = "전체 화면", -- Jeonche hwamyeon
    ["Enable music"] = "음악 활성화", -- Eumak hwalseong-hwa
    ["Enable lights"] = "조명 활성화", -- Jomyeong hwalseong-hwa
    
    -- Console / 콘솔
    ["Console"] = "콘솔", -- Konsol
    ["Channels"] = "채널", -- Chaeneol
    ["Open new channel"] = "새 채널 열기", -- Sae chaeneol yeolgi
    ["Close this channel"] = "이 채널 닫기", -- I chaeneol datgi
    ["Send"] = "보내기", -- Bonaegi
    ["Copy message"] = "메시지 복사", -- Mesiji boksa
    ["Copy name"] = "이름 복사", -- Ireum boksa
    
    -- Minimap / 미니맵
    ["Minimap"] = "미니맵", -- Minimaep
    ["Create mark"] = "표시 만들기", -- Pyosi mandeulgi
    ["Delete mark"] = "표시 삭제", -- Pyosi sakje
    
    -- Market / 시장
    ["Market"] = "시장", -- Sijang
    ["Market Offers"] = "시장 제안", -- Sijang jean
    ["Buy Offers"] = "구매 제안", -- Gumae jean
    ["Sell Offers"] = "판매 제안", -- Panmae jean
    ["Create Offer"] = "제안 만들기", -- Jean mandeulgi
    ["My Offers"] = "내 제안", -- Nae jean
    
    -- Hotkeys / 단축키
    ["Hotkeys"] = "단축키", -- Danchukki
    ["Manage hotkeys:"] = "단축키 관리:", -- Danchukki gwalli:
    ["Current hotkeys:"] = "현재 단축키:", -- Hyeonjae danchukki:
    
    -- Status effects / 상태 효과
    ["You are dead"] = "사망했습니다", -- Samanghassseumnida
    ["You are dead."] = "사망했습니다.", -- Samanghassseumnida.
    ["You are poisoned"] = "중독되었습니다", -- Jungdokdoeeossseumnida
    ["You are burning"] = "불타고 있습니다", -- Bultago issseumnida
    ["You are freezing"] = "얼어붙고 있습니다", -- Eoreobutgo issseumnida
    ["You are bleeding"] = "출혈 중입니다", -- Chulhyeol jungimmnida
    ["You are drunk"] = "취했습니다", -- Chwihassseumnida
    ["You are hungry"] = "배고픕니다", -- Baegopeuumnida
    ["You are paralysed"] = "마비되었습니다", -- Mabidoeeossseumnida
    ["You are hasted"] = "가속 중입니다", -- Gasok jungimmnida
    ["You are protected by a magic shield"] = "마법 방패로 보호받고 있습니다", -- Mabeob bangpaero bohobatgo issseumnida
    
    -- Misc / 기타
    ["Server"] = "서버", -- Seobeo
    ["Port"] = "포트", -- Poteu
    ["Protocol"] = "프로토콜", -- Peulotokol
    ["Version"] = "버전", -- Beojeon
    ["Name"] = "이름", -- Ireum
    ["Name:"] = "이름:", -- Ireum:
    ["Description"] = "설명", -- Seolmyeong
    ["Description:"] = "설명:", -- Seolmyeong:
    ["Author"] = "저자", -- Jeoja
    ["Add"] = "추가", -- Chuga
    ["Remove"] = "제거", -- Jegeo
    ["Save"] = "저장", -- Jeojang
    ["Load"] = "불러오기", -- Bulleo-ogi
    ["Refresh"] = "새로고침", -- Saerogochim
    ["Search"] = "검색", -- Geomsaek
    ["Search:"] = "검색:", -- Geomsaek:
    ["Find"] = "찾기", -- Chatgi
    ["Find:"] = "찾기:", -- Chatgi:
    ["Select"] = "선택", -- Seontaek
    ["Exit"] = "종료", -- Jongryo
    
    -- Language / 언어
    ["Change language"] = "언어 변경", -- Eoneo byeongyeong
    ["Select your language"] = "언어 선택", -- Eoneo seontaek
    ["Language"] = "언어", -- Eoneo
  }
}

modules.client_locales.installLocale(locale)
