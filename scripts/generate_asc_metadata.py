#!/usr/bin/env python3
"""Generate App Store Connect metadata markdown for PomoTask 1.1.0."""

from __future__ import annotations

from pathlib import Path

# Locale code -> content dict
# Limits: name 30, subtitle 30, promo 170, keywords 100

DATA: dict[str, dict] = {}

DATA["en-US"] = {
    "locale_name": "English (U.S.)",
    "name": "PomoTask Progressive",
    "subtitle": "Find your focus length",
    "promotional_text": "Build focus gently with Progressive Timer — adaptive blocks, smart check-ins, Apple Watch, and widgets.",
    "keywords": "pomodoro,focus,timer,productivity,progressive,study,work,streak,watch,widget",
    "whats_new": """Version 1.1.0

• Localization for Japanese, German, Korean, French, Spanish, Brazilian Portuguese, Italian, Chinese, and Dutch
• Shared focus stats on Home Screen widgets
• Polish across Progressive Timer, alerts, and onboarding

Thank you for using PomoTask — rate the app if it helps you focus.""",
    "description": """PomoTask helps you find how long you can truly focus — then gently stretch that edge.

PROGRESSIVE TIMER
Start around 5 minutes. When you’re in the flow, the next block grows a little — up to 25 minutes. After each focus block, a quick check-in tunes what comes next: go longer, shorten, or take a break.

STRUGGLE ESCAPE
Stuck mid-session? Pause, cut about a third of the remaining time, or start a short break — no guilt, just options.

CLASSIC POMODORO
Prefer a fixed rhythm? Create custom timers with focus, break, and repetitions. Organize by Work, Study, Home, or Wealth.

STATISTICS YOU CAN FEEL
See week focus, streaks, active days, and a tomato splash calendar that turns every focus day into a hit.

APPLE WATCH & WIDGETS
Start and track sessions from your wrist. Toggle Progressive focus from the Home Screen. Check week focus and streaks at a glance.

ALERTS THAT CUT THROUGH
Optional AlarmKit alerts break through Silent mode and Focus when a session ends. Session notifications keep you on track in other apps.

THEMES & ICONS
Solid colors, gradients, and handcrafted app icons so your timer feels like yours.

Classic mode stays free. Unlock Progressive with Pro for adaptive focus, check-ins, stats, and themes.

Privacy-friendly: focus stats stay on your devices.""",
    "screenshots": [
        {
            "id": "01-hero",
            "frame": "iPhone 6.7\" / 6.5\" — Progressive Timer dial",
            "headline": "Find your focus length",
            "subhead": "Start short. Grow with flow.",
            "overlay_lines": ["Progressive Timer", "5′ → 8′ → … → 25′"],
        },
        {
            "id": "02-checkin",
            "frame": "iPhone — Focus check-in sheet",
            "headline": "Smart check-ins",
            "subhead": "After each block, tune the next one.",
            "overlay_lines": ["In the flow", "A bit much", "Need a break"],
        },
        {
            "id": "03-struggle",
            "frame": "iPhone — Struggle sheet",
            "headline": "Stuck mid-session?",
            "subhead": "Pause, shorten, or break — anytime.",
            "overlay_lines": ["Keep going", "Shorten remaining", "Break now"],
        },
        {
            "id": "04-stats",
            "frame": "iPhone — Statistics / tomato calendar",
            "headline": "See your focus grow",
            "subhead": "Streaks, week totals, tomato splash days.",
            "overlay_lines": ["This week", "Day streak", "Tomato splash"],
        },
        {
            "id": "05-classic",
            "frame": "iPhone — Classic timers list / dial",
            "headline": "Classic Pomodoro, your way",
            "subhead": "Custom focus, breaks, and repetitions.",
            "overlay_lines": ["Timers", "Work · Study · Home"],
        },
        {
            "id": "06-watch-widgets",
            "frame": "iPhone + Watch + widget collage",
            "headline": "Focus on wrist & Home Screen",
            "subhead": "Watch app, Live Activities, and widgets.",
            "overlay_lines": ["Apple Watch", "Focus Timer widget", "Focus Stats"],
        },
    ],
}

DATA["ja"] = {
    "locale_name": "Japanese",
    "name": "PomoTask Progressive",
    "subtitle": "集中できる長さを見つけよう",
    "promotional_text": "Progressive Timerで集中力をやさしく伸ばす。適応ブロック、チェックイン、Apple Watch、ウィジェット対応。",
    "keywords": "ポモドーロ,集中,タイマー,生産性,勉強,仕事,ストリーク,ウォッチ,ウィジェット,フォーカス",
    "whats_new": """バージョン 1.1.0

• 日本語ほか多言語対応
• ホーム画面ウィジェットの集中統計
• Progressive Timer・通知・オンボーディングの改善

PomoTaskをご利用いただきありがとうございます。""",
    "description": """PomoTaskは、本当に集中できる時間を見つけ、その限界をやさしく伸ばすアプリです。

PROGRESSIVE TIMER
約5分から開始。フローに乗ると次のブロックが少し長くなり、最大25分まで。集中後の短いチェックインで、長くする・短くする・休憩を選べます。

つらいときの逃げ道
途中でつまずいても大丈夫。一時停止、残り時間の短縮、短い休憩——罪悪感なし、選択肢だけ。

クラシック・ポモドーロ
固定リズムが好きなら、集中・休憩・回数をカスタム。仕事・勉強・家庭・資産で整理。

実感できる統計
今週の集中、ストリーク、アクティブな日、トマト・スプラッシュ・カレンダー。

APPLE WATCH & ウィジェット
手首からセッション開始・追跡。ホーム画面からProgressiveを操作。週間集中とストリークを一目で。

届くアラート
AlarmKitでサイレントや集中モードでも終了を通知。他のアプリ利用中もセッション通知でリズムをキープ。

テーマとアイコン
単色、グラデーション、手描きアプリアイコン。

クラシックは無料。ProgressiveはProで解除。統計は端末上でプライバシーに配慮。""",
    "screenshots": [
        {
            "id": "01-hero",
            "frame": "iPhone — Progressive Timer",
            "headline": "集中できる長さを見つけよう",
            "subhead": "短く始めて、流れで伸ばす。",
            "overlay_lines": ["Progressive Timer", "5′ → 8′ → … → 25′"],
        },
        {
            "id": "02-checkin",
            "frame": "iPhone — チェックイン",
            "headline": "スマートチェックイン",
            "subhead": "各ブロック後に次を調整。",
            "overlay_lines": ["フローに乗っている", "少しキツい", "休憩が必要"],
        },
        {
            "id": "03-struggle",
            "frame": "iPhone — ストラグル",
            "headline": "途中でつまずいた？",
            "subhead": "一時停止・短縮・休憩、いつでも。",
            "overlay_lines": ["続ける", "残りを短縮", "今すぐ休憩"],
        },
        {
            "id": "04-stats",
            "frame": "iPhone — 統計",
            "headline": "集中の成長が見える",
            "subhead": "ストリーク、週間、トマトカレンダー。",
            "overlay_lines": ["今週", "連続日数", "Tomato splash"],
        },
        {
            "id": "05-classic",
            "frame": "iPhone — クラシック",
            "headline": "クラシック・ポモドーロ",
            "subhead": "集中・休憩・回数を自由に。",
            "overlay_lines": ["タイマー", "仕事 · 勉強 · 家庭"],
        },
        {
            "id": "06-watch-widgets",
            "frame": "iPhone + Watch + ウィジェット",
            "headline": "手首とホーム画面で集中",
            "subhead": "Watch、Live Activity、ウィジェット。",
            "overlay_lines": ["Apple Watch", "集中タイマー", "集中統計"],
        },
    ],
}

DATA["de-DE"] = {
    "locale_name": "German",
    "name": "PomoTask Progressive",
    "subtitle": "Finde deine Fokuslänge",
    "promotional_text": "Fokus sanft aufbauen mit Progressive Timer — adaptive Blöcke, Check-ins, Apple Watch und Widgets.",
    "keywords": "pomodoro,fokus,timer,produktivität,lernen,arbeit,streak,uhr,widget,konzentration",
    "whats_new": """Version 1.1.0

• Lokalisierung u. a. für Deutsch, Japanisch, Koreanisch, Französisch, Spanisch und mehr
• Fokus-Statistiken auf Home-Screen-Widgets
• Verbesserungen an Progressive Timer, Alarmen und Onboarding

Danke, dass du PomoTask nutzt.""",
    "description": """PomoTask hilft dir zu entdecken, wie lange du dich wirklich konzentrieren kannst — und dehnt diese Grenze sanft.

PROGRESSIVE TIMER
Start bei etwa 5 Minuten. Im Flow wird der nächste Block etwas länger — bis 25 Minuten. Nach jedem Fokusblock justiert ein kurzer Check-in den nächsten: länger, kürzer oder Pause.

STRUGGLE-AUSWEG
Mittsession festgefahren? Pausieren, Rest um etwa ein Drittel kürzen oder kurze Pause — ohne Schuldgefühle.

KLASSISCHES POMODORO
Feste Rhythmen mit Fokus, Pause und Wiederholungen. Sortiert nach Arbeit, Studium, Zuhause oder Finanzen.

STATISTIK ZUM ANFASSEN
Wochenfokus, Serien, aktive Tage und ein Tomato-Splash-Kalender.

APPLE WATCH & WIDGETS
Sitzungen vom Handgelenk starten und verfolgen. Progressive vom Home-Bildschirm steuern. Wochenfokus und Serien auf einen Blick.

ALARME DIE DURCHKOMMEN
Optionale AlarmKit-Alarme durchbrechen Lautlos und Fokus. Sitzungsbenachrichtigungen halten dich in anderen Apps auf Kurs.

THEMES & ICONS
Einfarbig, Verläufe und handgefertigte App-Icons.

Klassisch bleibt kostenlos. Progressive mit Pro freischalten. Statistiken bleiben auf deinen Geräten.""",
    "screenshots": [
        {
            "id": "01-hero",
            "frame": "iPhone — Progressive Timer",
            "headline": "Finde deine Fokuslänge",
            "subhead": "Kurz starten. Mit dem Flow wachsen.",
            "overlay_lines": ["Progressive Timer", "5′ → 8′ → … → 25′"],
        },
        {
            "id": "02-checkin",
            "frame": "iPhone — Check-in",
            "headline": "Smarte Check-ins",
            "subhead": "Nach jedem Block den nächsten justieren.",
            "overlay_lines": ["Im Flow", "Etwas viel", "Brauche Pause"],
        },
        {
            "id": "03-struggle",
            "frame": "iPhone — Struggle",
            "headline": "Mittsession festgefahren?",
            "subhead": "Pausieren, kürzen oder Pause — jederzeit.",
            "overlay_lines": ["Weitermachen", "Rest kürzen", "Jetzt Pause"],
        },
        {
            "id": "04-stats",
            "frame": "iPhone — Statistik",
            "headline": "Sieh deinen Fokus wachsen",
            "subhead": "Serien, Wochenwerte, Tomato Splash.",
            "overlay_lines": ["Diese Woche", "Serie", "Tomato splash"],
        },
        {
            "id": "05-classic",
            "frame": "iPhone — Klassisch",
            "headline": "Klassisches Pomodoro",
            "subhead": "Fokus, Pausen und Wiederholungen.",
            "overlay_lines": ["Timer", "Arbeit · Studium · Zuhause"],
        },
        {
            "id": "06-watch-widgets",
            "frame": "iPhone + Watch + Widgets",
            "headline": "Fokus am Handgelenk & Home",
            "subhead": "Watch-App, Live Activities und Widgets.",
            "overlay_lines": ["Apple Watch", "Fokus-Timer", "Fokus-Stats"],
        },
    ],
}

DATA["ko"] = {
    "locale_name": "Korean",
    "name": "PomoTask Progressive",
    "subtitle": "집중할 수 있는 길이를 찾으세요",
    "promotional_text": "Progressive Timer로 집중력을 부드럽게 키우세요. 적응형 블록, 체크인, Apple Watch, 위젯.",
    "keywords": "포모도로,집중,타이머,생산성,공부,업무,연속,워치,위젯,포커스",
    "whats_new": """버전 1.1.0

• 한국어 등 다국어 지원
• 홈 화면 위젯의 집중 통계
• Progressive Timer, 알림, 온보딩 개선

PomoTask를 사용해 주셔서 감사합니다.""",
    "description": """PomoTask는 정말 집중할 수 있는 시간을 찾고, 그 한계를 부드럽게 늘려 줍니다.

PROGRESSIVE TIMER
약 5분부터 시작. 흐름에 타면 다음 블록이 조금 길어지며 최대 25분. 각 집중 후 짧은 체크인으로 더 길게, 짧게, 또는 휴식을 고릅니다.

힘든 순간의 탈출구
세션 중간에 막혀도 괜찮아요. 일시정지, 남은 시간 줄이기, 짧은 휴식 — 죄책감 없이 선택만.

클래식 포모도로
고정 리듬이 좋다면 집중·휴식·반복을 맞춤 설정. 업무·공부·집·재테크로 정리.

체감되는 통계
주간 집중, 연속, 활동 일수, 토마토 스플래시 캘린더.

APPLE WATCH & 위젯
손목에서 세션을 시작하고 추적. 홈 화면에서 Progressive 조작. 주간 집중과 연속을 한눈에.

뚫고 나오는 알림
AlarmKit으로 무음·집중 모드에서도 종료 알림. 다른 앱을 써도 세션 알림으로 리듬 유지.

테마 & 아이콘
단색, 그라데이션, 수작업 앱 아이콘.

클래식은 무료. Progressive는 Pro로 잠금 해제. 통계는 기기에 보관.""",
    "screenshots": [
        {
            "id": "01-hero",
            "frame": "iPhone — Progressive Timer",
            "headline": "집중할 수 있는 길이를 찾으세요",
            "subhead": "짧게 시작. 흐름과 함께 성장.",
            "overlay_lines": ["Progressive Timer", "5′ → 8′ → … → 25′"],
        },
        {
            "id": "02-checkin",
            "frame": "iPhone — 체크인",
            "headline": "스마트 체크인",
            "subhead": "각 블록 후 다음을 조정.",
            "overlay_lines": ["흐름에 탐", "조금 많음", "휴식이 필요함"],
        },
        {
            "id": "03-struggle",
            "frame": "iPhone — 스트러글",
            "headline": "세션 중간에 막혔나요?",
            "subhead": "일시정지·줄이기·휴식, 언제든.",
            "overlay_lines": ["계속하기", "남은 시간 줄이기", "지금 휴식"],
        },
        {
            "id": "04-stats",
            "frame": "iPhone — 통계",
            "headline": "집중의 성장을 확인하세요",
            "subhead": "연속, 주간, 토마토 캘린더.",
            "overlay_lines": ["이번 주", "연속", "Tomato splash"],
        },
        {
            "id": "05-classic",
            "frame": "iPhone — 클래식",
            "headline": "클래식 포모도로",
            "subhead": "집중, 휴식, 반복을 내 방식대로.",
            "overlay_lines": ["타이머", "업무 · 공부 · 집"],
        },
        {
            "id": "06-watch-widgets",
            "frame": "iPhone + Watch + 위젯",
            "headline": "손목과 홈 화면에서 집중",
            "subhead": "Watch, Live Activity, 위젯.",
            "overlay_lines": ["Apple Watch", "집중 타이머", "집중 통계"],
        },
    ],
}

DATA["fr-FR"] = {
    "locale_name": "French",
    "name": "PomoTask Progressive",
    "subtitle": "Trouvez votre durée de focus",
    "promotional_text": "Développez votre focus avec Progressive Timer — blocs adaptatifs, check-ins, Apple Watch et widgets.",
    "keywords": "pomodoro,focus,minuteur,productivité,étude,travail,série,montre,widget,concentration",
    "whats_new": """Version 1.1.0

• Localisation en français et d’autres langues
• Stats de focus sur les widgets d’écran d’accueil
• Améliorations du Progressive Timer, des alertes et de l’onboarding

Merci d’utiliser PomoTask.""",
    "description": """PomoTask vous aide à découvrir combien de temps vous pouvez vraiment vous concentrer — puis à étirer doucement cette limite.

PROGRESSIVE TIMER
Commencez vers 5 minutes. En flow, le bloc suivant s’allonge un peu — jusqu’à 25 minutes. Après chaque focus, un check-in ajuste la suite : plus long, plus court ou pause.

ISSUE DE SECOURS
Bloqué en pleine session ? Pause, raccourcissez d’environ un tiers, ou courte pause — sans culpabilité.

POMODORO CLASSIQUE
Rythme fixe avec focus, pause et répétitions. Classez par Travail, Études, Maison ou Finance.

DES STATS QUI PARLENT
Focus de la semaine, séries, jours actifs et calendrier tomato splash.

APPLE WATCH & WIDGETS
Démarrez et suivez depuis le poignet. Contrôlez Progressive depuis l’écran d’accueil. Focus et séries en un coup d’œil.

ALERTES QUI PASSENT
AlarmKit traverse le mode Silencieux et Concentration. Les notifications de session vous gardent sur la voie.

THÈMES & ICÔNES
Couleurs unies, dégradés et icônes artisanales.

Le mode Classique reste gratuit. Débloquez Progressive avec Pro. Les stats restent sur vos appareils.""",
    "screenshots": [
        {
            "id": "01-hero",
            "frame": "iPhone — Progressive Timer",
            "headline": "Trouvez votre durée de focus",
            "subhead": "Commencez court. Grandissez avec le flow.",
            "overlay_lines": ["Progressive Timer", "5′ → 8′ → … → 25′"],
        },
        {
            "id": "02-checkin",
            "frame": "iPhone — Check-in",
            "headline": "Check-ins intelligents",
            "subhead": "Après chaque bloc, ajustez le suivant.",
            "overlay_lines": ["En flow", "Un peu trop", "Besoin d’une pause"],
        },
        {
            "id": "03-struggle",
            "frame": "iPhone — Difficulté",
            "headline": "Bloqué en pleine session ?",
            "subhead": "Pause, raccourcir ou break — à tout moment.",
            "overlay_lines": ["Continuer", "Raccourcir le reste", "Pause maintenant"],
        },
        {
            "id": "04-stats",
            "frame": "iPhone — Statistiques",
            "headline": "Voyez votre focus grandir",
            "subhead": "Séries, totaux, calendrier tomato.",
            "overlay_lines": ["Cette semaine", "Série", "Tomato splash"],
        },
        {
            "id": "05-classic",
            "frame": "iPhone — Classique",
            "headline": "Pomodoro classique",
            "subhead": "Focus, pauses et répétitions à votre façon.",
            "overlay_lines": ["Minuteurs", "Travail · Études · Maison"],
        },
        {
            "id": "06-watch-widgets",
            "frame": "iPhone + Watch + widgets",
            "headline": "Focus au poignet et à l’accueil",
            "subhead": "Watch, Live Activities et widgets.",
            "overlay_lines": ["Apple Watch", "Minuteur focus", "Stats focus"],
        },
    ],
}

DATA["es-ES"] = {
    "locale_name": "Spanish (Spain)",
    "name": "PomoTask Progressive",
    "subtitle": "Encuentra tu duración de foco",
    "promotional_text": "Crece tu enfoque con Progressive Timer: bloques adaptativos, check-ins, Apple Watch y widgets.",
    "keywords": "pomodoro,enfoque,temporizador,productividad,estudio,trabajo,racha,reloj,widget,concentración",
    "whats_new": """Versión 1.1.0

• Localización en español y más idiomas
• Estadísticas de enfoque en widgets de inicio
• Mejoras en Progressive Timer, alertas y onboarding

Gracias por usar PomoTask.""",
    "description": """PomoTask te ayuda a descubrir cuánto puedes concentrarte de verdad — y luego estira esa frontera con suavidad.

PROGRESSIVE TIMER
Empieza alrededor de 5 minutos. En flow, el siguiente bloque dura un poco más — hasta 25. Tras cada enfoque, un check-in ajusta lo siguiente: más largo, más corto o descanso.

SALIDA ANTE LA DIFICULTAD
¿Atascado a mitad de sesión? Pausa, recorta cerca de un tercio o toma un descanso corto — sin culpa.

POMODORO CLÁSICO
Ritmo fijo con enfoque, descanso y repeticiones. Organiza por Trabajo, Estudio, Hogar o Finanzas.

ESTADÍSTICAS QUE SE SIENTEN
Enfoque de la semana, rachas, días activos y calendario tomato splash.

APPLE WATCH Y WIDGETS
Inicia y sigue desde la muñeca. Controla Progressive desde la pantalla de inicio. Enfoque y rachas de un vistazo.

ALERTAS QUE LLEGAN
AlarmKit atraviesa Silencio y Concentración. Las notificaciones de sesión te mantienen en marcha.

TEMAS E ICONOS
Colores sólidos, degradados e iconos artesanales.

Clásico sigue gratis. Desbloquea Progressive con Pro. Las estadísticas permanecen en tus dispositivos.""",
    "screenshots": [
        {
            "id": "01-hero",
            "frame": "iPhone — Progressive Timer",
            "headline": "Encuentra tu duración de foco",
            "subhead": "Empieza corto. Crece con el flow.",
            "overlay_lines": ["Progressive Timer", "5′ → 8′ → … → 25′"],
        },
        {
            "id": "02-checkin",
            "frame": "iPhone — Check-in",
            "headline": "Check-ins inteligentes",
            "subhead": "Tras cada bloque, ajusta el siguiente.",
            "overlay_lines": ["En el flow", "Un poco mucho", "Necesito un descanso"],
        },
        {
            "id": "03-struggle",
            "frame": "iPhone — Dificultad",
            "headline": "¿Atascado a mitad de sesión?",
            "subhead": "Pausa, acorta o descansa — cuando quieras.",
            "overlay_lines": ["Seguir", "Acortar lo restante", "Descanso ahora"],
        },
        {
            "id": "04-stats",
            "frame": "iPhone — Estadísticas",
            "headline": "Mira cómo crece tu enfoque",
            "subhead": "Rachas, totales y calendario tomato.",
            "overlay_lines": ["Esta semana", "Racha", "Tomato splash"],
        },
        {
            "id": "05-classic",
            "frame": "iPhone — Clásico",
            "headline": "Pomodoro clásico",
            "subhead": "Enfoque, descansos y repeticiones a tu modo.",
            "overlay_lines": ["Temporizadores", "Trabajo · Estudio · Hogar"],
        },
        {
            "id": "06-watch-widgets",
            "frame": "iPhone + Watch + widgets",
            "headline": "Enfoque en muñeca e inicio",
            "subhead": "Watch, Live Activities y widgets.",
            "overlay_lines": ["Apple Watch", "Temporizador", "Estadísticas"],
        },
    ],
}

DATA["pt-BR"] = {
    "locale_name": "Portuguese (Brazil)",
    "name": "PomoTask Progressive",
    "subtitle": "Encontre sua duração de foco",
    "promotional_text": "Cresça seu foco com o Progressive Timer — blocos adaptativos, check-ins, Apple Watch e widgets.",
    "keywords": "pomodoro,foco,temporizador,produtividade,estudo,trabalho,sequência,relógio,widget,concentração",
    "whats_new": """Versão 1.1.0

• Localização em português e outros idiomas
• Estatísticas de foco nos widgets da Tela de Início
• Melhorias no Progressive Timer, alertas e onboarding

Obrigado por usar o PomoTask.""",
    "description": """O PomoTask ajuda você a descobrir por quanto tempo consegue se concentrar de verdade — e depois estende esse limite com cuidado.

PROGRESSIVE TIMER
Comece perto de 5 minutos. No fluxo, o próximo bloco fica um pouco mais longo — até 25. Após cada foco, um check-in ajusta o próximo: alongar, encurtar ou pausar.

SAÍDA NA DIFICULDADE
Travado no meio da sessão? Pause, corte cerca de um terço ou faça uma pausa curta — sem culpa.

POMODORO CLÁSSICO
Ritmo fixo com foco, pausa e repetições. Organize por Trabalho, Estudo, Casa ou Finanças.

ESTATÍSTICAS QUE FAZEM SENTIDO
Foco da semana, sequências, dias ativos e calendário tomato splash.

APPLE WATCH E WIDGETS
Inicie e acompanhe no pulso. Controle o Progressive na Tela de Início. Foco e sequências de relance.

ALERTAS QUE CHEGAM
AlarmKit passa pelo Silencioso e Foco. Notificações de sessão mantêm seu ritmo em outros apps.

TEMAS E ÍCONES
Cores sólidas, gradientes e ícones artesanais.

O Clássico continua grátis. Desbloqueie o Progressive com Pro. As estatísticas ficam nos seus dispositivos.""",
    "screenshots": [
        {
            "id": "01-hero",
            "frame": "iPhone — Progressive Timer",
            "headline": "Encontre sua duração de foco",
            "subhead": "Comece curto. Cresça com o fluxo.",
            "overlay_lines": ["Progressive Timer", "5′ → 8′ → … → 25′"],
        },
        {
            "id": "02-checkin",
            "frame": "iPhone — Check-in",
            "headline": "Check-ins inteligentes",
            "subhead": "Após cada bloco, ajuste o próximo.",
            "overlay_lines": ["No fluxo", "Um pouco demais", "Preciso de uma pausa"],
        },
        {
            "id": "03-struggle",
            "frame": "iPhone — Dificuldade",
            "headline": "Travado no meio da sessão?",
            "subhead": "Pause, encurte ou pause — quando quiser.",
            "overlay_lines": ["Continuar", "Encurtar o restante", "Pausa agora"],
        },
        {
            "id": "04-stats",
            "frame": "iPhone — Estatísticas",
            "headline": "Veja seu foco crescer",
            "subhead": "Sequências, totais e calendário tomato.",
            "overlay_lines": ["Esta semana", "Sequência", "Tomato splash"],
        },
        {
            "id": "05-classic",
            "frame": "iPhone — Clássico",
            "headline": "Pomodoro clássico",
            "subhead": "Foco, pausas e repetições do seu jeito.",
            "overlay_lines": ["Temporizadores", "Trabalho · Estudo · Casa"],
        },
        {
            "id": "06-watch-widgets",
            "frame": "iPhone + Watch + widgets",
            "headline": "Foco no pulso e na Tela de Início",
            "subhead": "Watch, Live Activities e widgets.",
            "overlay_lines": ["Apple Watch", "Temporizador", "Estatísticas"],
        },
    ],
}

DATA["it"] = {
    "locale_name": "Italian",
    "name": "PomoTask Progressive",
    "subtitle": "Trova la tua durata di focus",
    "promotional_text": "Fai crescere il focus con Progressive Timer — blocchi adattivi, check-in, Apple Watch e widget.",
    "keywords": "pomodoro,focus,timer,produttività,studio,lavoro,serie,orologio,widget,concentrazione",
    "whats_new": """Versione 1.1.0

• Localizzazione in italiano e altre lingue
• Statistiche di focus sui widget della Home
• Miglioramenti a Progressive Timer, avvisi e onboarding

Grazie per usare PomoTask.""",
    "description": """PomoTask ti aiuta a scoprire quanto riesci davvero a concentrarti — poi allarga quel limite con delicatezza.

PROGRESSIVE TIMER
Inizia intorno ai 5 minuti. In flow, il blocco successivo si allunga un po’ — fino a 25. Dopo ogni focus, un check-in regola il prossimo: più lungo, più corto o pausa.

USCITA DALLA DIFFICOLTÀ
Bloccato a metà sessione? Pausa, taglia circa un terzo oppure una breve pausa — senza sensi di colpa.

POMODORO CLASSICO
Ritmo fisso con focus, pausa e ripetizioni. Organizza per Lavoro, Studio, Casa o Finanze.

STATISTICHE CHE SI SENTONO
Focus della settimana, serie, giorni attivi e calendario tomato splash.

APPLE WATCH E WIDGET
Avvia e monitora dal polso. Controlla Progressive dalla Home. Focus e serie a colpo d’occhio.

AVVISI CHE PASSANO
AlarmKit supera Silenzioso e Concentrazione. Le notifiche di sessione ti tengono in carreggiata.

TEMI E ICONE
Colori pieni, sfumature e icone artigianali.

Il Classico resta gratis. Sblocca Progressive con Pro. Le statistiche restano sui tuoi dispositivi.""",
    "screenshots": [
        {
            "id": "01-hero",
            "frame": "iPhone — Progressive Timer",
            "headline": "Trova la tua durata di focus",
            "subhead": "Inizia breve. Cresci con il flow.",
            "overlay_lines": ["Progressive Timer", "5′ → 8′ → … → 25′"],
        },
        {
            "id": "02-checkin",
            "frame": "iPhone — Check-in",
            "headline": "Check-in smart",
            "subhead": "Dopo ogni blocco, regola il successivo.",
            "overlay_lines": ["In flow", "Un po’ troppo", "Serve una pausa"],
        },
        {
            "id": "03-struggle",
            "frame": "iPhone — Difficoltà",
            "headline": "Bloccato a metà sessione?",
            "subhead": "Pausa, accorcia o break — quando vuoi.",
            "overlay_lines": ["Continua", "Accorcia il restante", "Pausa ora"],
        },
        {
            "id": "04-stats",
            "frame": "iPhone — Statistiche",
            "headline": "Guarda crescere il tuo focus",
            "subhead": "Serie, totali e calendario tomato.",
            "overlay_lines": ["Questa settimana", "Serie", "Tomato splash"],
        },
        {
            "id": "05-classic",
            "frame": "iPhone — Classico",
            "headline": "Pomodoro classico",
            "subhead": "Focus, pause e ripetizioni a modo tuo.",
            "overlay_lines": ["Timer", "Lavoro · Studio · Casa"],
        },
        {
            "id": "06-watch-widgets",
            "frame": "iPhone + Watch + widget",
            "headline": "Focus al polso e in Home",
            "subhead": "Watch, Live Activities e widget.",
            "overlay_lines": ["Apple Watch", "Timer focus", "Stats focus"],
        },
    ],
}

DATA["zh-Hans"] = {
    "locale_name": "Chinese (Simplified)",
    "name": "PomoTask Progressive",
    "subtitle": "找到适合你的专注时长",
    "promotional_text": "用 Progressive Timer 温和提升专注力——自适应块、签到、Apple Watch 与小组件。",
    "keywords": "番茄钟,专注,计时器,效率,学习,工作,连续,手表,小组件,番茄工作法",
    "whats_new": """版本 1.1.0

• 简体中文等多语言支持
• 主屏幕小组件专注统计
• Progressive Timer、提醒与引导流程优化

感谢使用 PomoTask。""",
    "description": """PomoTask 帮你发现真正能专注多久，再温和地拉长这个上限。

PROGRESSIVE TIMER
大约从 5 分钟开始。进入心流后，下一块会稍长一些——最多 25 分钟。每个专注块后快速签到：加长、缩短或休息。

困难时的出路
中途卡住也没关系。暂停、缩短约三分之一剩余时间，或短暂休息——没有愧疚，只有选择。

经典番茄钟
喜欢固定节奏？自定义专注、休息与重复次数。按工作、学习、家庭或理财分类。

看得见的统计
本周专注、连续天数、活跃日，以及番茄飞溅日历。

APPLE WATCH 与小组件
在手腕上开始并跟踪会话。从主屏幕控制 Progressive。一眼查看本周专注与连续。

能穿透的提醒
AlarmKit 可在静音与专注模式下提醒结束。会话通知帮你在其他 App 中保持节奏。

主题与图标
纯色、渐变与精心制作的应用图标。

经典模式免费。用 Pro 解锁 Progressive。统计保留在你的设备上。""",
    "screenshots": [
        {
            "id": "01-hero",
            "frame": "iPhone — Progressive Timer",
            "headline": "找到适合你的专注时长",
            "subhead": "从短开始，随心流成长。",
            "overlay_lines": ["Progressive Timer", "5′ → 8′ → … → 25′"],
        },
        {
            "id": "02-checkin",
            "frame": "iPhone — 签到",
            "headline": "智能签到",
            "subhead": "每块结束后调整下一块。",
            "overlay_lines": ["进入心流", "有点多", "需要休息"],
        },
        {
            "id": "03-struggle",
            "frame": "iPhone — 困难",
            "headline": "中途卡住了？",
            "subhead": "暂停、缩短或休息——随时可做。",
            "overlay_lines": ["继续", "缩短剩余", "现在休息"],
        },
        {
            "id": "04-stats",
            "frame": "iPhone — 统计",
            "headline": "看见专注在成长",
            "subhead": "连续、周统计、番茄日历。",
            "overlay_lines": ["本周", "连续", "Tomato splash"],
        },
        {
            "id": "05-classic",
            "frame": "iPhone — 经典",
            "headline": "经典番茄钟",
            "subhead": "按你的方式设置专注与休息。",
            "overlay_lines": ["计时器", "工作 · 学习 · 家庭"],
        },
        {
            "id": "06-watch-widgets",
            "frame": "iPhone + Watch + 小组件",
            "headline": "手腕与主屏幕上的专注",
            "subhead": "Watch、实时活动与小组件。",
            "overlay_lines": ["Apple Watch", "专注计时器", "专注统计"],
        },
    ],
}

DATA["zh-Hant"] = {
    "locale_name": "Chinese (Traditional)",
    "name": "PomoTask Progressive",
    "subtitle": "找到適合你的專注時長",
    "promotional_text": "用 Progressive Timer 溫和提升專注力——自適應塊、簽到、Apple Watch 與小組件。",
    "keywords": "番茄鐘,專注,計時器,效率,學習,工作,連續,手錶,小組件,番茄工作法",
    "whats_new": """版本 1.1.0

• 繁體中文等多語系支援
• 主畫面小組件專注統計
• Progressive Timer、提醒與引導流程優化

感謝使用 PomoTask。""",
    "description": """PomoTask 幫你發現真正能專注多久，再溫和地拉長這個上限。

PROGRESSIVE TIMER
大約從 5 分鐘開始。進入心流後，下一塊會稍長一些——最多 25 分鐘。每個專注塊後快速簽到：加長、縮短或休息。

困難時的出路
中途卡住也沒關係。暫停、縮短約三分之一剩餘時間，或短暫休息——沒有愧疚，只有選擇。

經典番茄鐘
喜歡固定節奏？自訂專注、休息與重複次數。依工作、學習、居家或理財分類。

看得見的統計
本週專注、連續天數、活躍日，以及番茄飛濺日曆。

APPLE WATCH 與小組件
在手腕上開始並追蹤工作階段。從主畫面控制 Progressive。一眼查看本週專注與連續。

能穿透的提醒
AlarmKit 可在靜音與專注模式下提醒結束。工作階段通知幫你在其他 App 中保持節奏。

主題與圖示
純色、漸層與精心製作的 App 圖示。

經典模式免費。用 Pro 解鎖 Progressive。統計保留在你的裝置上。""",
    "screenshots": [
        {
            "id": "01-hero",
            "frame": "iPhone — Progressive Timer",
            "headline": "找到適合你的專注時長",
            "subhead": "從短開始，隨心流成長。",
            "overlay_lines": ["Progressive Timer", "5′ → 8′ → … → 25′"],
        },
        {
            "id": "02-checkin",
            "frame": "iPhone — 簽到",
            "headline": "智慧簽到",
            "subhead": "每塊結束後調整下一塊。",
            "overlay_lines": ["進入心流", "有點多", "需要休息"],
        },
        {
            "id": "03-struggle",
            "frame": "iPhone — 困難",
            "headline": "中途卡住了？",
            "subhead": "暫停、縮短或休息——隨時可做。",
            "overlay_lines": ["繼續", "縮短剩餘", "現在休息"],
        },
        {
            "id": "04-stats",
            "frame": "iPhone — 統計",
            "headline": "看見專注在成長",
            "subhead": "連續、週統計、番茄日曆。",
            "overlay_lines": ["本週", "連續", "Tomato splash"],
        },
        {
            "id": "05-classic",
            "frame": "iPhone — 經典",
            "headline": "經典番茄鐘",
            "subhead": "依你的方式設定專注與休息。",
            "overlay_lines": ["計時器", "工作 · 學習 · 居家"],
        },
        {
            "id": "06-watch-widgets",
            "frame": "iPhone + Watch + 小組件",
            "headline": "手腕與主畫面上的專注",
            "subhead": "Watch、即時活動與小組件。",
            "overlay_lines": ["Apple Watch", "專注計時器", "專注統計"],
        },
    ],
}

DATA["nl-NL"] = {
    "locale_name": "Dutch",
    "name": "PomoTask Progressive",
    "subtitle": "Vind jouw focustijd",
    "promotional_text": "Bouw focus zachtjes op met Progressive Timer — adaptieve blokken, check-ins, Apple Watch en widgets.",
    "keywords": "pomodoro,focus,timer,productiviteit,studie,werk,reeks,horloge,widget,concentratie",
    "whats_new": """Versie 1.1.0

• Localisatie in het Nederlands en andere talen
• Focusstatistieken op beginscherm-widgets
• Verbeteringen aan Progressive Timer, meldingen en onboarding

Bedankt dat je PomoTask gebruikt.""",
    "description": """PomoTask helpt je ontdekken hoe lang je écht kunt focussen — en rekt die grens dan zachtjes op.

PROGRESSIVE TIMER
Begin rond 5 minuten. In de flow wordt het volgende blok iets langer — tot 25 minuten. Na elke focus stemt een korte check-in af: langer, korter of pauze.

UITWEG BIJ STRUGGLE
Vast midden in de sessie? Pauzeer, verkort ongeveer een derde, of neem een korte pauze — zonder schuldgevoel.

KLASSIEKE POMODORO
Vaste ritmes met focus, pauze en herhalingen. Orden op Werk, Studie, Thuis of Vermogen.

STATISTIEKEN DIE JE VOELT
Weekfocus, reeksen, actieve dagen en een tomato-splashkalender.

APPLE WATCH & WIDGETS
Start en volg vanaf je pols. Bedien Progressive vanaf het beginscherm. Weekfocus en reeksen in één oogopslag.

MELDINGEN DIE DOORKOMEN
AlarmKit breekt door Stil en Focus heen. Sessiemeldingen houden je op schema in andere apps.

THEMA’S & PICTOGRAMMEN
Effen kleuren, verlopen en handgemaakte app-pictogrammen.

Klassiek blijft gratis. Ontgrendel Progressive met Pro. Stats blijven op je apparaten.""",
    "screenshots": [
        {
            "id": "01-hero",
            "frame": "iPhone — Progressive Timer",
            "headline": "Vind jouw focustijd",
            "subhead": "Begin kort. Groei met de flow.",
            "overlay_lines": ["Progressive Timer", "5′ → 8′ → … → 25′"],
        },
        {
            "id": "02-checkin",
            "frame": "iPhone — Check-in",
            "headline": "Slimme check-ins",
            "subhead": "Na elk blok de volgende afstemmen.",
            "overlay_lines": ["In de flow", "Een beetje te veel", "Pauze nodig"],
        },
        {
            "id": "03-struggle",
            "frame": "iPhone — Struggle",
            "headline": "Vast midden in de sessie?",
            "subhead": "Pauzeer, verkort of break — altijd.",
            "overlay_lines": ["Doorgaan", "Resterende tijd verkorten", "Nu pauze"],
        },
        {
            "id": "04-stats",
            "frame": "iPhone — Statistieken",
            "headline": "Zie je focus groeien",
            "subhead": "Reeksen, weektotalen, tomato-kalender.",
            "overlay_lines": ["Deze week", "Reeks", "Tomato splash"],
        },
        {
            "id": "05-classic",
            "frame": "iPhone — Klassiek",
            "headline": "Klassieke Pomodoro",
            "subhead": "Focus, pauzes en herhalingen op jouw manier.",
            "overlay_lines": ["Timers", "Werk · Studie · Thuis"],
        },
        {
            "id": "06-watch-widgets",
            "frame": "iPhone + Watch + widgets",
            "headline": "Focus op pols & beginscherm",
            "subhead": "Watch, Live Activities en widgets.",
            "overlay_lines": ["Apple Watch", "Focustimer", "Focusstats"],
        },
    ],
}


def check_limits(locale: str, d: dict) -> None:
    assert len(d["name"]) <= 30, f"{locale} name {len(d['name'])}: {d['name']!r}"
    assert len(d["subtitle"]) <= 30, f"{locale} subtitle {len(d['subtitle'])}: {d['subtitle']!r}"
    assert len(d["promotional_text"]) <= 170, f"{locale} promo {len(d['promotional_text'])}"
    assert len(d["keywords"]) <= 100, f"{locale} keywords {len(d['keywords'])}: {d['keywords']!r}"


def render(locale: str, d: dict) -> str:
    shots = []
    for i, s in enumerate(d["screenshots"], 1):
        lines = "\n".join(f"  - {line}" for line in s["overlay_lines"])
        shots.append(
            f"""### Screenshot {i}: `{s['id']}`
- **Frame / layout:** {s['frame']}
- **Headline (large overlay):** {s['headline']}
- **Subhead:** {s['subhead']}
- **UI / badge labels to show on art:**
{lines}"""
        )

    return f"""# PomoTask — App Store Connect Metadata

- **Version:** 1.1.0
- **Locale:** `{locale}` — {d['locale_name']}
- **Brand:** PomoTask (do not translate in name field beyond product naming)

> Character limits: Name ≤30 · Subtitle ≤30 · Promotional Text ≤170 · Keywords ≤100

---

## Name
```
{d['name']}
```
({len(d['name'])}/30)

## Subtitle
```
{d['subtitle']}
```
({len(d['subtitle'])}/30)

## Promotional Text
```
{d['promotional_text']}
```
({len(d['promotional_text'])}/170)

## Keywords
```
{d['keywords']}
```
({len(d['keywords'])}/100)

## Description
```
{d['description']}
```

## What’s New
```
{d['whats_new']}
```

---

## Screenshot overlay copy

Use these headlines/subheads as text on App Store screenshot frames (not ASC caption fields). Keep brand tomato-red / white typography consistent across locales.

{chr(10).join(shots)}

### Design notes
- Prefer short headlines; wrap subheads to 2 lines max on 6.7\".
- Keep `Progressive Timer` / `PomoTask` as product terms where natural.
- Screens 1–4 are highest priority for conversion; 5–6 support Classic + Watch/widgets story.
"""


def main() -> None:
    out_dir = Path(__file__).resolve().parents[1] / "metadata" / "1.1.0"
    out_dir.mkdir(parents=True, exist_ok=True)
    for locale, d in DATA.items():
        check_limits(locale, d)
        path = out_dir / f"{locale}.md"
        path.write_text(render(locale, d), encoding="utf-8")
        print(f"Wrote {path.name}")


if __name__ == "__main__":
    main()
