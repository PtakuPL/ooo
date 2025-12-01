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
    ["You are cursed"] = "저주받았습니다", -- Jeojubadassseumnida
    ["You are dazzled"] = "눈이 부십니다", -- Nuni busipnida
    ["You are drowning"] = "익사 중입니다", -- Iksa jungimmnida
    ["You are electrified"] = "감전되었습니다", -- Gamjeondoeeossseumnida
    ["You are strengthened"] = "강화되었습니다", -- Ganghwadoeeossseumnida
    ["You are within a protection zone"] = "보호 구역 안에 있습니다", -- Boho guyeok ane issseumnida
    
    -- Rules & Reports / 규칙 및 신고
    ["1a) Offensive Name"] = "1a) 공격적인 이름",
    ["1b) Invalid Name Format"] = "1b) 잘못된 이름 형식",
    ["1c) Unsuitable Name"] = "1c) 부적절한 이름",
    ["1d) Name Inciting Rule Violation"] = "1d) 규칙 위반 유도 이름",
    ["2a) Offensive Statement"] = "2a) 공격적인 발언",
    ["2b) Spamming"] = "2b) 스팸",
    ["2c) Illegal Advertising"] = "2c) 불법 광고",
    ["2d) Off-Topic Public Statement"] = "2d) 주제 이탈 발언",
    ["2e) Non-English Public Statement"] = "2e) 비영어 발언",
    ["2f) Inciting Rule Violation"] = "2f) 규칙 위반 유도",
    ["3a) Bug Abuse"] = "3a) 버그 악용",
    ["3b) Game Weakness Abuse"] = "3b) 게임 취약점 악용",
    ["3c) Using Unofficial Software to Play"] = "3c) 비공식 소프트웨어 사용",
    ["3d) Hacking"] = "3d) 해킹",
    ["3e) Multi-Clienting"] = "3e) 멀티 클라이언트",
    ["3f) Account Trading or Sharing"] = "3f) 계정 거래 또는 공유",
    ["4a) Threatening Gamemaster"] = "4a) 게임마스터 위협",
    ["4b) Pretending to Have Influence on Rule Enforcement"] = "4b) 규칙 집행에 영향력 가장",
    ["4c) False Report to Gamemaster"] = "4c) 허위 신고",
    ["Report Bug"] = "버그 신고",
    ["Report Rule Violation"] = "규칙 위반 신고",
    ["Bug report sent."] = "버그 신고가 전송되었습니다.",
    
    -- Vocations / 직업
    ["Knight"] = "나이트", -- Naiteu
    ["Paladin"] = "팔라딘", -- Palladin
    ["Sorcerer"] = "소서러", -- Soseoreo
    ["Druid"] = "드루이드", -- Deuruideo
    ["Vocation"] = "직업", -- Jigeob
    ["Voc."] = "직",
    
    -- More UI / 추가 UI
    ["Addon 1"] = "애드온 1",
    ["Addon 2"] = "애드온 2",
    ["Addon 3"] = "애드온 3",
    ["Browse"] = "찾아보기", -- Chajabogi
    ["Browse Field"] = "필드 찾아보기",
    ["Classic control"] = "클래식 조작",
    ["Clear object"] = "오브젝트 지우기",
    ["Copy"] = "복사", -- Boksa
    ["Copy Name"] = "이름 복사",
    ["Default"] = "기본값", -- Gibongab
    ["Detail"] = "세부 정보", -- Sebu jeongbo
    ["Details"] = "세부 정보",
    ["Force Exit"] = "강제 종료",
    ["Game"] = "게임",
    ["Group"] = "그룹",
    ["Healing"] = "치유", -- Chiyu
    ["Health Information"] = "체력 정보",
    ["Module Manager"] = "모듈 관리자",
    ["Module name"] = "모듈 이름",
    ["Mount"] = "탈것", -- Talgeot
    ["No Mount"] = "탈것 없음",
    ["No Outfit"] = "의상 없음",
    ["NPC Trade"] = "NPC 거래",
    ["Offline Training"] = "오프라인 훈련",
    ["Overview"] = "개요", -- Gaeyo
    ["Primary"] = "기본", -- Gibon
    ["Quest Log"] = "퀘스트 로그",
    ["Randomize"] = "무작위화",
    ["Randomize characters outfit"] = "의상 무작위화",
    ["Reject"] = "거부", -- Geobu
    ["Reload All"] = "모두 다시 로드",
    ["Reset All"] = "모두 초기화",
    ["Secondary"] = "보조", -- Bojo
    ["Select all"] = "모두 선택",
    ["Select object"] = "오브젝트 선택",
    ["Select Outfit"] = "의상 선택",
    ["Sell All"] = "모두 판매",
    ["Server list"] = "서버 목록",
    ["Server List"] = "서버 목록",
    ["Server Log"] = "서버 로그",
    ["Set Outfit"] = "의상 설정",
    ["Soul Points"] = "영혼 포인트",
    ["Special"] = "특수", -- Teuksu
    ["Spell Cooldowns"] = "주문 쿨다운",
    ["Spell List"] = "주문 목록",
    ["Statement"] = "진술", -- Jinsul
    ["Statement Report"] = "진술 신고",
    ["Statistics"] = "통계", -- Tonggye
    ["Support"] = "지원", -- Jiwon
    ["Terminal"] = "터미널",
    ["There is no way."] = "길이 없습니다.",
    ["Title"] = "칭호", -- Chingho
    ["Total Price"] = "총 가격",
    ["Type"] = "유형", -- Yuhyeong
    ["Unload"] = "언로드",
    ["Waiting List"] = "대기 목록",
    ["Website"] = "웹사이트",
    ["Weight"] = "무게", -- Muge
    
    -- Connection messages / 연결 메시지
    ["Connection Error"] = "연결 오류",
    ["Connection failed."] = "연결 실패.",
    ["Connection failed, the server address does not exist."] = "연결 실패. 서버 주소가 존재하지 않습니다.",
    ["Client needs update."] = "클라이언트 업데이트가 필요합니다.",
    ["Update needed"] = "업데이트 필요",
    
    -- Reward Wall & Cyclopedia / 보상 벽 및 사이클로피디아
    ["Date"] = "날짜", -- Nalcha
    ["Streak"] = "연속", -- Yeonsok
    ["Event"] = "이벤트", -- Ibenteu
    ["Free capacity"] = "남은 용량", -- Nameun yongryang
    ["Total weight"] = "총 무게", -- Chong muge
    ["Unknown bonus."] = "알 수 없는 보너스.", -- Al su eomneun boneoseu
    ["Not yet, UI missing"] = "아직, UI 누락", -- Ajik, UI nurak
    ["Unlocks at 1500 Boss Points"] = "1500 보스 포인트에서 잠금 해제", -- 1500 boseu pointeueseo jamgeum haeje
    ["Equipment Loot Bonus"] = "장비 드롭 보너스", -- Jangbi deurop boneoseu
    ["Next"] = "다음", -- Daeum
    ["fully unlocked"] = "완전 잠금 해제", -- Wanjeon jamgeum haeje
    ["Equipment loot bonus"] = "장비 드롭 보너스", -- Jangbi deurop boneoseu
    ["Kill bonus"] = "킬 보너스", -- Kil boneoseu
    ["Boosted Boss"] = "부스트 보스", -- Buseut boseu
    ["Slot"] = "슬롯", -- Seullot
    ["Locked"] = "잠김", -- Jamgim
    ["Select Boss"] = "보스 선택", -- Boseu seontaek
    ["Unlocks at %d Boss Points"] = "%d 보스 포인트에서 잠금 해제", -- %d boseu pointeueseo jamgeum haeje
    
    -- House / 집
    ["Your Limit"] = "귀하의 한도", -- Gwihaui hando
    ["There is no bid so far."] = "아직 입찰이 없습니다.", -- Ajik ipchali eobsseumnida
    ["Be the first to bid on this house."] = "이 집에 첫 입찰을 하세요.", -- I jibe cheot ipchareul haseyo
    ["When the auction ends, the winning bid plus the rent for the first month"] = "경매 종료 시, 낙찰가와 첫 달 임대료가", -- Gyeongmae jongryo si, nakchalgawa cheot dal imdaeryoga
    ["will be debited to your bank account."] = "은행 계좌에서 인출됩니다.", -- Eunhaeng gyejwaeseo inchuldoemnida
    ["Auction"] = "경매", -- Gyeongmae
    ["Highest Bidder"] = "최고 입찰자", -- Choego ipcharja
    ["End Time"] = "종료 시간", -- Jongryo sigan
    ["Highest Bid"] = "최고 입찰가", -- Choego ipchalga
    ["Rental Details"] = "임대 세부사항", -- Imdae sebusahang
    ["Tenant"] = "임차인", -- Imchain
    ["Paid Until"] = "결제 완료", -- Gyeolje wanryo
    ["New Owner"] = "새 소유자", -- Sae soyuja
    ["Transfer"] = "양도", -- Yangdo
    
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
