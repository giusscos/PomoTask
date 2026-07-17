#!/usr/bin/env python3
"""Generate TomaTask/Localizable.xcstrings and InfoPlist.xcstrings with Tier 1+2 AI drafts."""

from __future__ import annotations

import json
from pathlib import Path

LOCALES = ["ja", "de", "ko", "fr", "es", "pt-BR", "it", "zh-Hans", "zh-Hant", "nl"]

# English key -> {locale: translation}. Missing locale falls back to English.
# Order of locales in each list: ja, de, ko, fr, es, pt-BR, it, zh-Hans, zh-Hant, nl
T: dict[str, list[str]] = {}


def add(en: str, *translations: str) -> None:
    assert len(translations) == 10, f"{en!r} needs 10 translations, got {len(translations)}"
    T[en] = list(translations)


# --- Common ---
add("Statistics", "統計", "Statistik", "통계", "Statistiques", "Estadísticas", "Estatísticas", "Statistiche", "统计", "統計", "Statistieken")
add("Progressive", "Progressive", "Progressive", "Progressive", "Progressive", "Progressive", "Progressive", "Progressive", "Progressive", "Progressive", "Progressive")
add("Classic", "クラシック", "Klassisch", "클래식", "Classique", "Clásico", "Clássico", "Classico", "经典", "經典", "Klassiek")
add("Settings", "設定", "Einstellungen", "설정", "Réglages", "Ajustes", "Ajustes", "Impostazioni", "设置", "設定", "Instellingen")
add("Focus", "集中", "Fokus", "집중", "Focus", "Enfoque", "Foco", "Focus", "专注", "專注", "Focus")
add("Break", "休憩", "Pause", "휴식", "Pause", "Descanso", "Pausa", "Pausa", "休息", "休息", "Pauze")
add("Pause", "一時停止", "Pause", "일시정지", "Pause", "Pausa", "Pausar", "Pausa", "暂停", "暫停", "Pauze")
add("Play", "再生", "Start", "재생", "Lecture", "Reproducir", "Reproduzir", "Play", "播放", "播放", "Afspelen")
add("Start", "開始", "Start", "시작", "Démarrer", "Iniciar", "Iniciar", "Avvia", "开始", "開始", "Start")
add("Stop", "停止", "Stopp", "중지", "Arrêter", "Detener", "Parar", "Stop", "停止", "停止", "Stop")
add("Done", "完了", "Fertig", "완료", "OK", "Listo", "Concluído", "Fine", "完成", "完成", "Klaar")
add("Open", "開く", "Öffnen", "열기", "Ouvrir", "Abrir", "Abrir", "Apri", "打开", "打開", "Openen")
add("Resume", "再開", "Fortsetzen", "재개", "Reprendre", "Reanudar", "Retomar", "Riprendi", "继续", "繼續", "Hervatten")
add("Paused", "一時停止中", "Pausiert", "일시정지됨", "En pause", "En pausa", "Pausado", "In pausa", "已暂停", "已暫停", "Gepauzeerd")
add("Delete", "削除", "Löschen", "삭제", "Supprimer", "Eliminar", "Excluir", "Elimina", "删除", "刪除", "Verwijderen")
add("Edit", "編集", "Bearbeiten", "편집", "Modifier", "Editar", "Editar", "Modifica", "编辑", "編輯", "Bewerken")
add("Next", "次へ", "Weiter", "다음", "Suivant", "Siguiente", "Próximo", "Avanti", "下一步", "下一步", "Volgende")
add("Continue", "続ける", "Weiter", "계속", "Continuer", "Continuar", "Continuar", "Continua", "继续", "繼續", "Doorgaan")
add("min", "分", "Min.", "분", "min", "min", "min", "min", "分钟", "分鐘", "min")
add("Default", "デフォルト", "Standard", "기본", "Par défaut", "Predeterminado", "Padrão", "Predefinito", "默认", "預設", "Standaard")
add("Solid", "単色", "Einfarbig", "단색", "Uni", "Sólido", "Sólido", "Tinta unita", "纯色", "純色", "Effen")
add("Gradient", "グラデーション", "Verlauf", "그라데이션", "Dégradé", "Degradado", "Gradiente", "Sfumatura", "渐变", "漸層", "Verloop")
add("Solid Color", "単色", "Einfarbige Farbe", "단색", "Couleur unie", "Color sólido", "Cor sólida", "Colore pieno", "纯色", "純色", "Effen kleur")
add("Work", "仕事", "Arbeit", "업무", "Travail", "Trabajo", "Trabalho", "Lavoro", "工作", "工作", "Werk")
add("Study", "勉強", "Studium", "공부", "Études", "Estudio", "Estudo", "Studio", "学习", "學習", "Studie")
add("Home", "家庭", "Zuhause", "집", "Maison", "Hogar", "Casa", "Casa", "家庭", "居家", "Thuis")
add("Wealth", "資産", "Finanzen", "재테크", "Finance", "Finanzas", "Finanças", "Finanze", "理财", "理財", "Vermogen")
add("Timers", "タイマー", "Timer", "타이머", "Minuteurs", "Temporizadores", "Temporizadores", "Timer", "计时器", "計時器", "Timers")
add("Tasks", "タスク", "Aufgaben", "작업", "Tâches", "Tareas", "Tarefas", "Attività", "任务", "任務", "Taken")
add("Stats", "統計", "Stats", "통계", "Stats", "Stats", "Stats", "Stats", "统计", "統計", "Stats")
add("Today", "今日", "Heute", "오늘", "Aujourd’hui", "Hoy", "Hoje", "Oggi", "今天", "今天", "Vandaag")
add("Week", "週", "Woche", "주", "Semaine", "Semana", "Semana", "Settimana", "周", "週", "Week")
add("Month", "月", "Monat", "월", "Mois", "Mes", "Mês", "Mese", "月", "月", "Maand")
add("Active", "アクティブ", "Aktiv", "활성", "Actif", "Activo", "Ativo", "Attivo", "活跃", "活躍", "Actief")
add("Less", "少", "Weniger", "적음", "Moins", "Menos", "Menos", "Meno", "少", "少", "Minder")
add("More", "多", "Mehr", "많음", "Plus", "Más", "Mais", "Più", "多", "多", "Meer")
add("Day", "日", "Tag", "일", "Jour", "Día", "Dia", "Giorno", "日", "日", "Dag")
add("Minutes", "分", "Minuten", "분", "Minutes", "Minutos", "Minutos", "Minuti", "分钟", "分鐘", "Minuten")
add("Overview", "概要", "Übersicht", "개요", "Aperçu", "Resumen", "Visão geral", "Panoramica", "概览", "概覽", "Overzicht")
add("Add", "追加", "Hinzufügen", "추가", "Ajouter", "Añadir", "Adicionar", "Aggiungi", "添加", "加入", "Toevoegen")
add("Title", "タイトル", "Titel", "제목", "Titre", "Título", "Título", "Titolo", "标题", "標題", "Titel")
add("Name", "名前", "Name", "이름", "Nom", "Nombre", "Nome", "Nome", "名称", "名稱", "Naam")
add("Category", "カテゴリ", "Kategorie", "카테고리", "Catégorie", "Categoría", "Categoria", "Categoria", "分类", "分類", "Categorie")
add("Duration", "時間", "Dauer", "시간", "Durée", "Duración", "Duração", "Durata", "时长", "時長", "Duur")
add("Repetitions", "回数", "Wiederholungen", "반복", "Répétitions", "Repeticiones", "Repetições", "Ripetizioni", "重复次数", "重複次數", "Herhalingen")
add("Repeat", "繰り返し", "Wiederholen", "반복", "Répéter", "Repetir", "Repetir", "Ripeti", "重复", "重複", "Herhalen")
add("Time", "時間", "Zeit", "시간", "Temps", "Tiempo", "Tempo", "Tempo", "时间", "時間", "Tijd")
add("Discard", "破棄", "Verwerfen", "버리기", "Ignorer", "Descartar", "Descartar", "Annulla", "丢弃", "捨棄", "Verwerpen")
add("Keep Editing", "編集を続ける", "Weiter bearbeiten", "계속 편집", "Continuer à modifier", "Seguir editando", "Continuar editando", "Continua a modificare", "继续编辑", "繼續編輯", "Blijven bewerken")
add("Upgrade to Pro", "Proにアップグレード", "Auf Pro upgraden", "Pro로 업그레이드", "Passer à Pro", "Actualizar a Pro", "Atualizar para Pro", "Passa a Pro", "升级到 Pro", "升級至 Pro", "Upgrade naar Pro")
add("Subscribe", "登録", "Abonnieren", "구독", "S’abonner", "Suscribirse", "Assinar", "Abbonati", "订阅", "訂閱", "Abonneren")
add("Manage subscription", "サブスクリプションを管理", "Abo verwalten", "구독 관리", "Gérer l’abonnement", "Gestionar suscripción", "Gerenciar assinatura", "Gestisci abbonamento", "管理订阅", "管理訂閱", "Abonnement beheren")
add("App Icon", "アプリアイコン", "App-Symbol", "앱 아이콘", "Icône de l’app", "Icono de la app", "Ícone do app", "Icona dell’app", "应用图标", "App 圖示", "App-pictogram")
add("Support", "サポート", "Support", "지원", "Assistance", "Soporte", "Suporte", "Supporto", "支持", "支援", "Ondersteuning")
add("Request a feature", "機能をリクエスト", "Funktion vorschlagen", "기능 요청", "Demander une fonctionnalité", "Solicitar una función", "Pedir um recurso", "Richiedi una funzione", "请求功能", "請求功能", "Functie aanvragen")
add("Privacy Policy", "プライバシーポリシー", "Datenschutz", "개인정보 처리방침", "Politique de confidentialité", "Política de privacidad", "Política de Privacidade", "Informativa sulla privacy", "隐私政策", "隱私權政策", "Privacybeleid")
add("Terms of Use", "利用規約", "Nutzungsbedingungen", "이용약관", "Conditions d’utilisation", "Términos de uso", "Termos de Uso", "Termini di utilizzo", "使用条款", "使用條款", "Gebruiksvoorwaarden")
add("Terms of use", "利用規約", "Nutzungsbedingungen", "이용약관", "Conditions d’utilisation", "Términos de uso", "Termos de uso", "Termini di utilizzo", "使用条款", "使用條款", "Gebruiksvoorwaarden")
add("Alarm", "アラーム", "Alarm", "알람", "Alarme", "Alarma", "Alarme", "Sveglia", "闹钟", "鬧鐘", "Alarm")
add("Session Alerts", "セッション通知", "Sitzungswarnungen", "세션 알림", "Alertes de session", "Alertas de sesión", "Alertas de sessão", "Avvisi sessione", "会话提醒", "工作階段提醒", "Sessiemeldingen")
add("Session notification", "セッション通知", "Sitzungsbenachrichtigung", "세션 알림", "Notification de session", "Notificación de sesión", "Notificação de sessão", "Notifica sessione", "会话通知", "工作階段通知", "Sessiemelding")
add("this week", "今週", "diese Woche", "이번 주", "cette semaine", "esta semana", "esta semana", "questa settimana", "本周", "本週", "deze week")
add("This week", "今週", "Diese Woche", "이번 주", "Cette semaine", "Esta semana", "Esta semana", "Questa settimana", "本周", "本週", "Deze week")
add("Active days", "アクティブな日", "Aktive Tage", "활동 일수", "Jours actifs", "Días activos", "Dias ativos", "Giorni attivi", "活跃天数", "活躍天數", "Actieve dagen")
add("Month focus", "今月の集中", "Monatsfokus", "이번 달 집중", "Focus du mois", "Enfoque del mes", "Foco do mês", "Focus del mese", "本月专注", "本月專注", "Maandfocus")
add("Best day", "ベストな日", "Bester Tag", "최고의 날", "Meilleur jour", "Mejor día", "Melhor dia", "Giorno migliore", "最佳日", "最佳日", "Beste dag")
add("Longest streak", "最長ストリーク", "Längste Serie", "최장 연속", "Plus longue série", "Racha más larga", "Maior sequência", "Serie più lunga", "最长连续", "最長連續", "Langste reeks")
add("Focus time", "集中時間", "Fokuszeit", "집중 시간", "Temps de focus", "Tiempo de enfoque", "Tempo de foco", "Tempo di focus", "专注时间", "專注時間", "Focustijd")
add("Focus Time", "集中時間", "Fokuszeit", "집중 시간", "Temps de focus", "Tiempo de enfoque", "Tempo de foco", "Tempo di focus", "专注时间", "專注時間", "Focustijd")
add("Timers started", "開始したタイマー", "Gestartete Timer", "시작한 타이머", "Minuteurs démarrés", "Temporizadores iniciados", "Temporizadores iniciados", "Timer avviati", "已开始的计时", "已開始的計時", "Gestarte timers")
add("Timers completed", "完了したタイマー", "Abgeschlossene Timer", "완료한 타이머", "Minuteurs terminés", "Temporizadores completados", "Temporizadores concluídos", "Timer completati", "已完成的计时", "已完成的計時", "Voltooide timers")
add("Timers Started", "開始したタイマー", "Gestartete Timer", "시작한 타이머", "Minuteurs démarrés", "Temporizadores iniciados", "Temporizadores iniciados", "Timer avviati", "已开始的计时", "已開始的計時", "Gestarte timers")
add("Timers Completed", "完了したタイマー", "Abgeschlossene Timer", "완료한 타이머", "Minuteurs terminés", "Temporizadores completados", "Temporizadores concluídos", "Timer completati", "已完成的计时", "已完成的計時", "Voltooide timers")
add("Day splash", "デイ・スプラッシュ", "Tages-Splash", "데이 스플래시", "Splash du jour", "Splash del día", "Splash do dia", "Splash del giorno", "每日番茄", "每日番茄", "Dag-splash")
add("Goal ~90m", "目標 約90分", "Ziel ~90 Min.", "목표 ~90분", "Objectif ~90 min", "Objetivo ~90 min", "Meta ~90 min", "Obiettivo ~90 min", "目标约90分钟", "目標約90分鐘", "Doel ~90 m")
add("In progress", "進行中", "Läuft", "진행 중", "En cours", "En curso", "Em andamento", "In corso", "进行中", "進行中", "Bezig")
add("Time's up", "時間切れ", "Zeit ist um", "시간 종료", "Temps écoulé", "Se acabó el tiempo", "Tempo esgotado", "Tempo scaduto", "时间到", "時間到", "Tijd is om")
add("Break · Paused", "休憩 · 一時停止", "Pause · Pausiert", "휴식 · 일시정지", "Pause · En pause", "Descanso · En pausa", "Pausa · Pausado", "Pausa · In pausa", "休息 · 已暂停", "休息 · 已暫停", "Pauze · Gepauzeerd")
add("Focus · Paused", "集中 · 一時停止", "Fokus · Pausiert", "집중 · 일시정지", "Focus · En pause", "Enfoque · En pausa", "Foco · Pausado", "Focus · In pausa", "专注 · 已暂停", "專注 · 已暫停", "Focus · Gepauzeerd")
add("No data available", "データがありません", "Keine Daten verfügbar", "데이터 없음", "Aucune donnée", "No hay datos", "Nenhum dado disponível", "Nessun dato disponibile", "暂无数据", "暫無資料", "Geen gegevens")
add("Time Range", "期間", "Zeitraum", "기간", "Période", "Intervalo", "Intervalo", "Periodo", "时间范围", "時間範圍", "Periode")
add("No tasks", "タスクなし", "Keine Aufgaben", "작업 없음", "Aucune tâche", "Sin tareas", "Sem tarefas", "Nessuna attività", "暂无任务", "暫無任務", "Geen taken")
add("Task Title", "タスク名", "Aufgabentitel", "작업 제목", "Titre de la tâche", "Título de la tarea", "Título da tarefa", "Titolo attività", "任务标题", "任務標題", "Taaktitel")
add("Break time", "休憩時間", "Pausenzeit", "휴식 시간", "Temps de pause", "Tiempo de descanso", "Tempo de pausa", "Tempo di pausa", "休息时间", "休息時間", "Pauzetijd")
add("Focus time", "集中時間", "Fokuszeit", "집중 시간", "Temps de focus", "Tiempo de enfoque", "Tempo de foco", "Tempo di focus", "专注时间", "專注時間", "Focustijd")  # duplicate ok
add("Break over", "休憩終了", "Pause vorbei", "휴식 종료", "Pause terminée", "Descanso terminado", "Pausa terminada", "Pausa finita", "休息结束", "休息結束", "Pauze voorbij")
add("Pomodoro", "ポモドーロ", "Pomodoro", "포모도로", "Pomodoro", "Pomodoro", "Pomodoro", "Pomodoro", "番茄钟", "番茄鐘", "Pomodoro")
add("Untitled Timer", "無題のタイマー", "Unbenannter Timer", "제목 없는 타이머", "Minuteur sans titre", "Temporizador sin título", "Temporizador sem título", "Timer senza titolo", "未命名计时器", "未命名計時器", "Naamloze timer")
add("Date", "日付", "Datum", "날짜", "Date", "Fecha", "Data", "Data", "日期", "日期", "Datum")
add("Color type", "カラー種別", "Farbtyp", "색상 유형", "Type de couleur", "Tipo de color", "Tipo de cor", "Tipo di colore", "颜色类型", "顏色類型", "Kleurtetype")
add("Select Color", "色を選択", "Farbe wählen", "색상 선택", "Choisir une couleur", "Seleccionar color", "Selecionar cor", "Seleziona colore", "选择颜色", "選擇顏色", "Kleur kiezen")
add("Color 1", "カラー1", "Farbe 1", "색상 1", "Couleur 1", "Color 1", "Cor 1", "Colore 1", "颜色 1", "顏色 1", "Kleur 1")
add("Color 2", "カラー2", "Farbe 2", "색상 2", "Couleur 2", "Color 2", "Cor 2", "Colore 2", "颜色 2", "顏色 2", "Kleur 2")
add("Color 3", "カラー3", "Farbe 3", "색상 3", "Couleur 3", "Color 3", "Cor 3", "Colore 3", "颜色 3", "顏色 3", "Kleur 3")
add("Color", "色", "Farbe", "색상", "Couleur", "Color", "Cor", "Colore", "颜色", "顏色", "Kleur")
add("Saturation", "彩度", "Sättigung", "채도", "Saturation", "Saturación", "Saturação", "Saturazione", "饱和度", "飽和度", "Verzadiging")
add("Brightness", "明るさ", "Helligkeit", "밝기", "Luminosité", "Brillo", "Brilho", "Luminosità", "亮度", "亮度", "Helderheid")
add("I'm struggling", "つらい", "Ich habe Schwierigkeiten", "힘들어요", "J’ai du mal", "Me cuesta", "Estou com dificuldade", "Sto faticando", "我有点撑不住", "我有點撐不住", "Ik vind het lastig")
add("Timer dial", "タイマーダイアル", "Timer-Wählrad", "타이머 다이얼", "Cadran du minuteur", "Dial del temporizador", "Disco do temporizador", "Quadrante del timer", "计时旋钮", "計時旋鈕", "Timerschijf")
add("Drag to wind or reset the timer", "ドラッグしてタイマーをセットまたはリセット", "Ziehen zum Aufziehen oder Zurücksetzen", "드래그하여 타이머를 감거나 초기화", "Faites glisser pour régler ou réinitialiser", "Arrastra para cargar o reiniciar", "Arraste para ajustar ou redefinir", "Trascina per caricare o reimpostare", "拖动以上发条或重置", "拖曳以上發條或重設", "Sleep om te stellen of te resetten")
add("Running", "実行中", "Läuft", "실행 중", "En cours", "En marcha", "Em execução", "In esecuzione", "运行中", "執行中", "Actief")

# --- Onboarding ---
add("TomaTask", "TomaTask", "TomaTask", "TomaTask", "TomaTask", "TomaTask", "TomaTask", "TomaTask", "TomaTask", "TomaTask", "TomaTask")
add("Find your focus length", "自分の集中できる長さを見つけよう", "Finde deine Fokuslänge", "집중할 수 있는 길이를 찾아보세요", "Trouvez votre durée de focus", "Encuentra tu duración de enfoque", "Encontre sua duração de foco", "Trova la tua durata di focus", "找到适合你的专注时长", "找到適合你的專注時長", "Vind jouw focustijd")
add(
    "Progressive Timer helps you discover how long you can truly focus — then gently stretch that edge.",
    "Progressive Timerは、本当に集中できる時間を見つけ、その限界をやさしく伸ばします。",
    "Progressive Timer hilft dir zu entdecken, wie lange du dich wirklich konzentrieren kannst — und dehnt diese Grenze sanft.",
    "Progressive Timer는 정말 집중할 수 있는 시간을 찾고, 그 한계를 부드럽게 늘려 줍니다.",
    "Progressive Timer vous aide à découvrir combien de temps vous pouvez vraiment vous concentrer — puis à étirer doucement cette limite.",
    "Progressive Timer te ayuda a descubrir cuánto puedes concentrarte de verdad — y luego estira esa frontera con suavidad.",
    "O Progressive Timer ajuda você a descobrir por quanto tempo consegue se concentrar de verdade — e depois estende esse limite com cuidado.",
    "Progressive Timer ti aiuta a scoprire quanto riesci davvero a concentrarti — poi allarga quel limite con delicatezza.",
    "Progressive Timer 帮你发现真正能专注多久，再温和地拉长这个上限。",
    "Progressive Timer 幫你發現真正能專注多久，再溫和地拉長這個上限。",
    "Progressive Timer helpt je ontdekken hoe lang je écht kunt focussen — en rek die grens dan zachtjes op.",
)
add("Show me how", "やり方を見る", "Zeig mir wie", "방법 보기", "Montrez-moi", "Muéstrame cómo", "Mostre-me como", "Mostrami come", "看看怎么做", "看看怎麼做", "Laat zien hoe")
add("Start short. Grow with flow.", "短く始めて、流れに乗って伸ばす。", "Kurz starten. Mit dem Flow wachsen.", "짧게 시작하고, 흐름과 함께 성장하세요.", "Commencez court. Grandissez avec le flow.", "Empieza corto. Crece con el flow.", "Comece curto. Cresça com o fluxo.", "Inizia breve. Cresci con il flow.", "从短开始，随心流成长。", "從短開始，隨心流成長。", "Begin kort. Groei met de flow.")
add(
    "Every focus block begins around 5 minutes. When you’re in the flow, the next block gets a little longer — up to 25 minutes.",
    "集中ブロックは約5分から。フローに乗ると次は少し長くなり、最大25分まで。",
    "Jeder Fokusblock beginnt bei etwa 5 Minuten. Im Flow wird der nächste etwas länger — bis 25 Minuten.",
    "모든 집중 블록은 약 5분부터 시작합니다. 흐름에 타면 다음 블록이 조금 길어지며, 최대 25분까지입니다.",
    "Chaque bloc de focus commence vers 5 minutes. En flow, le suivant s’allonge un peu — jusqu’à 25 minutes.",
    "Cada bloque de enfoque empieza alrededor de 5 minutos. Si estás en flow, el siguiente dura un poco más — hasta 25 minutos.",
    "Cada bloco de foco começa perto de 5 minutos. No fluxo, o próximo fica um pouco mais longo — até 25 minutos.",
    "Ogni blocco di focus inizia intorno ai 5 minuti. Se sei in flow, il successivo si allunga un po’ — fino a 25 minuti.",
    "每个专注块大约从 5 分钟开始。进入心流后，下一块会稍长一些——最多 25 分钟。",
    "每個專注塊大約從 5 分鐘開始。進入心流後，下一塊會稍長一些——最多 25 分鐘。",
    "Elke focusblok begint rond 5 minuten. In de flow wordt de volgende iets langer — tot 25 minuten.",
)
add("How focused did you feel?", "どれくらい集中できましたか？", "Wie fokussiert hast du dich gefühlt?", "얼마나 집중되었나요?", "À quel point étiez-vous concentré ?", "¿Qué tan enfocado te sentiste?", "Quão focado você se sentiu?", "Quanto ti sei sentito concentrato?", "你感觉专注程度如何？", "你感覺專注程度如何？", "Hoe gefocust voelde je je?")
add("How focused were you?", "どれくらい集中できましたか？", "Wie fokussiert warst du?", "얼마나 집중했나요?", "À quel point étiez-vous concentré ?", "¿Qué tan enfocado estabas?", "Quão focado você estava?", "Quanto eri concentrato?", "你刚才有多专注？", "你剛才有多專注？", "Hoe gefocust was je?")
add(
    "After each focus block, a quick check-in tunes the next one.",
    "集中ブロックのあとに短いチェックインで、次を調整します。",
    "Nach jedem Fokusblock justiert ein kurzer Check-in den nächsten.",
    "각 집중 블록 후 짧은 체크인으로 다음을 조정합니다.",
    "Après chaque bloc, un court check-in ajuste le suivant.",
    "Tras cada bloque, un check-in rápido ajusta el siguiente.",
    "Após cada bloco, um check-in rápido ajusta o próximo.",
    "Dopo ogni blocco, un check-in rapido regola il successivo.",
    "每个专注块结束后，快速签到会调整下一块。",
    "每個專注塊結束後，快速簽到會調整下一塊。",
    "Na elke focusblok stemt een korte check-in de volgende af.",
)
add("In the flow", "フローに乗っている", "Im Flow", "흐름에 탐", "En flow", "En el flow", "No fluxo", "In flow", "进入心流", "進入心流", "In de flow")
add("Next block gets longer · starts right away", "次は長く · すぐに開始", "Nächster Block länger · startet sofort", "다음 블록이 더 김 · 바로 시작", "Bloc suivant plus long · démarre tout de suite", "El siguiente dura más · empieza ya", "O próximo fica mais longo · começa já", "Il prossimo è più lungo · parte subito", "下一块更长 · 立即开始", "下一塊更長 · 立即開始", "Volgende langer · start meteen")
add("A bit much", "少しキツい", "Etwas viel", "조금 많음", "Un peu trop", "Un poco mucho", "Um pouco demais", "Un po’ troppo", "有点多", "有點多", "Een beetje te veel")
add("Shorten the next block · you tap play", "次を短く · 再生で開始", "Nächsten kürzen · du tippst Play", "다음을 짧게 · 재생을 눌러 시작", "Raccourcir le suivant · vous lancez Play", "Acorta el siguiente · tú pulsas play", "Encurta o próximo · você toca em play", "Accorcia il prossimo · premi play tu", "缩短下一块 · 由你点播放", "縮短下一塊 · 由你點播放", "Volgende korter · jij tikt op play")
add("Need a break", "休憩が必要", "Brauche eine Pause", "휴식이 필요함", "Besoin d’une pause", "Necesito un descanso", "Preciso de uma pausa", "Serve una pausa", "需要休息", "需要休息", "Pauze nodig")
add("A short break scaled to your last focus", "直前の集中に合わせた短い休憩", "Kurze Pause passend zum letzten Fokus", "직전 집중에 맞춘 짧은 휴식", "Une courte pause adaptée à votre dernier focus", "Un descanso corto según tu último enfoque", "Uma pausa curta proporcional ao último foco", "Una breve pausa in base all’ultimo focus", "按上次专注时长安排的短休息", "依上次專注時長安排的短休息", "Een korte pauze afgestemd op je laatste focus")
add("Stuck mid-session?", "途中でつまずいた？", "Mittsession festgefahren?", "세션 중간에 막혔나요?", "Bloqué en pleine session ?", "¿Atascado a mitad de sesión?", "Travado no meio da sessão?", "Bloccato a metà sessione?", "中途卡住了？", "中途卡住了？", "Vast midden in de sessie?")
add(
    "Tap the struggle button anytime. Pause, shorten what’s left, or take a break — no guilt, just options.",
    "つらいときはいつでもボタンを。一時停止、残りを短縮、または休憩——罪悪感なし、選択肢だけ。",
    "Tippe jederzeit auf den Struggle-Button. Pausieren, Rest kürzen oder Pause machen — ohne Schuldgefühle, nur Optionen.",
    "힘들 때 언제든 버튼을 누르세요. 일시정지, 남은 시간 줄이기, 휴식 — 죄책감 없이 선택만.",
    "Touchez le bouton difficulté à tout moment. Pause, raccourcissez le reste ou prenez une pause — sans culpabilité, juste des options.",
    "Toca el botón de dificultad cuando quieras. Pausa, acorta lo que queda o descansa — sin culpa, solo opciones.",
    "Toque o botão de dificuldade a qualquer momento. Pause, encurte o restante ou faça uma pausa — sem culpa, só opções.",
    "Tocca il pulsante difficoltà in qualsiasi momento. Pausa, accorcia il resto o fai una pausa — senza sensi di colpa, solo opzioni.",
    "随时点困难按钮。暂停、缩短剩余时间，或休息——没有愧疚，只有选择。",
    "隨時點困難按鈕。暫停、縮短剩餘時間，或休息——沒有愧疚，只有選擇。",
    "Tik altijd op de struggle-knop. Pauzeer, verkort wat resteert of neem een pauze — geen schuldgevoel, alleen opties.",
)
add("Keep going", "続ける", "Weitermachen", "계속하기", "Continuer", "Seguir", "Continuar", "Continua", "继续", "繼續", "Doorgaan")
add("Resume when you’re ready", "準備できたら再開", "Fortsetzen, wenn du bereit bist", "준비되면 재개", "Reprendre quand vous êtes prêt", "Reanuda cuando estés listo", "Retome quando estiver pronto", "Riprendi quando sei pronto", "准备好再继续", "準備好再繼續", "Hervatten wanneer je klaar bent")
add("Shorten remaining", "残りを短縮", "Rest kürzen", "남은 시간 줄이기", "Raccourcir le reste", "Acortar lo restante", "Encurtar o restante", "Accorcia il restante", "缩短剩余时间", "縮短剩餘時間", "Resterende tijd verkorten")
add("Cut about a third, then continue", "約3分の1を削って続ける", "Etwa ein Drittel kürzen, dann weiter", "약 1/3을 줄인 뒤 계속", "Coupez environ un tiers, puis continuez", "Recorta cerca de un tercio y sigue", "Corte cerca de um terço e continue", "Taglia circa un terzo, poi continua", "大约去掉三分之一后继续", "大約去掉三分之一後繼續", "Ongeveer een derde eraf, dan verder")
add("Break now", "今すぐ休憩", "Jetzt Pause", "지금 휴식", "Pause maintenant", "Descanso ahora", "Pausa agora", "Pausa ora", "现在休息", "現在休息", "Nu pauze")
add("Start a short recovery break", "短い回復休憩を開始", "Kurze Erholungspause starten", "짧은 회복 휴식 시작", "Démarrer une courte pause de récupération", "Empieza un descanso corto de recuperación", "Inicie uma pausa curta de recuperação", "Avvia una breve pausa di recupero", "开始短暂恢复休息", "開始短暫恢復休息", "Start een korte herstelpauze")
add("Stay on track", "リズムをキープ", "Bleib auf Kurs", "궤도 유지", "Restez sur la bonne voie", "Mantente en marcha", "Mantenha o ritmo", "Resta in carreggiata", "保持节奏", "保持節奏", "Blijf op schema")
add(
    "Get a nudge when a focus block or break ends — even if you’re in another app.",
    "集中や休憩が終わったら通知——他のアプリを使っていても。",
    "Erhalte einen Hinweis, wenn Fokus oder Pause endet — auch in einer anderen App.",
    "집중이나 휴식이 끝나면 알림을 받으세요 — 다른 앱을 써도.",
    "Recevez un rappel quand un focus ou une pause se termine — même dans une autre app.",
    "Recibe un aviso al terminar un enfoque o descanso — aunque estés en otra app.",
    "Receba um aviso quando um foco ou pausa terminar — mesmo em outro app.",
    "Ricevi un promemoria quando finisce un focus o una pausa — anche in un’altra app.",
    "专注或休息结束时收到提醒——即使你在其他 App。",
    "專注或休息結束時收到提醒——即使你在其他 App。",
    "Krijg een seintje als focus of pauze eindigt — ook in een andere app.",
)
add("Focus complete", "集中完了", "Fokus fertig", "집중 완료", "Focus terminé", "Enfoque completo", "Foco concluído", "Focus completato", "专注完成", "專注完成", "Focus voltooid")
add("Know when it’s time to check in", "チェックインのタイミングを逃さない", "Wisse, wann Check-in dran ist", "체크인 시점을 놓치지 마세요", "Sachez quand faire le check-in", "Sabe cuándo hacer el check-in", "Saiba quando fazer o check-in", "Sappi quando fare il check-in", "知道何时该签到", "知道何時該簽到", "Weet wanneer je moet inchecken")
add("Break over", "休憩終了", "Pause vorbei", "휴식 종료", "Pause terminée", "Descanso terminado", "Pausa terminada", "Pausa finita", "休息结束", "休息結束", "Pauze voorbij")
add("Jump back in when you’re ready", "準備できたらまた始めよう", "Mach weiter, wenn du bereit bist", "준비되면 다시 시작", "Revenez quand vous êtes prêt", "Vuelve cuando estés listo", "Volte quando estiver pronto", "Rientra quando sei pronto", "准备好再回来", "準備好再回來", "Ga verder wanneer je klaar bent")
add("You control it", "あなたがコントロール", "Du hast die Kontrolle", "당신이 제어합니다", "Vous avez le contrôle", "Tú tienes el control", "Você no controle", "Sei tu a controllare", "由你掌控", "由你掌控", "Jij hebt de controle")
add("Change anytime in Settings", "設定でいつでも変更", "Jederzeit in den Einstellungen ändern", "설정에서 언제든 변경", "Modifiable à tout moment dans Réglages", "Cámbialo cuando quieras en Ajustes", "Altere quando quiser em Ajustes", "Modifica quando vuoi in Impostazioni", "随时可在设置中更改", "隨時可在設定中更改", "Wijzig wanneer je wilt in Instellingen")
add("Enable notifications", "通知をオンにする", "Mitteilungen aktivieren", "알림 켜기", "Activer les notifications", "Activar notificaciones", "Ativar notificações", "Attiva notifiche", "开启通知", "開啟通知", "Meldingen inschakelen")
add("Asking…", "確認中…", "Wird angefragt…", "요청 중…", "Demande…", "Solicitando…", "Solicitando…", "Richiesta…", "请求中…", "請求中…", "Vragen…")
add("Not now", "あとで", "Nicht jetzt", "나중에", "Pas maintenant", "Ahora no", "Agora não", "Non ora", "暂时不要", "暫時不要", "Niet nu")
add("Unlock Progressive", "Progressiveを解除", "Progressive freischalten", "Progressive 잠금 해제", "Débloquer Progressive", "Desbloquear Progressive", "Desbloquear Progressive", "Sblocca Progressive", "解锁 Progressive", "解鎖 Progressive", "Progressive ontgrendelen")
add(
    "Find your focus length — then grow it with adaptive blocks, check-ins, and clear stats.",
    "集中できる長さを見つけ、適応ブロック・チェックイン・わかりやすい統計で伸ばそう。",
    "Finde deine Fokuslänge — und wachse mit adaptiven Blöcken, Check-ins und klaren Stats.",
    "집중 길이를 찾고, 적응형 블록·체크인·명확한 통계로 키우세요.",
    "Trouvez votre durée de focus — puis faites-la grandir avec blocs adaptatifs, check-ins et stats claires.",
    "Encuentra tu duración de enfoque — y hazla crecer con bloques adaptativos, check-ins y stats claras.",
    "Encontre sua duração de foco — e faça-a crescer com blocos adaptativos, check-ins e estatísticas claras.",
    "Trova la tua durata di focus — poi falla crescere con blocchi adattivi, check-in e stats chiare.",
    "找到适合你的专注时长——再用自适应块、签到和清晰统计去成长。",
    "找到適合你的專注時長——再用自適應塊、簽到和清晰統計去成長。",
    "Vind jouw focustijd — en groei met adaptieve blokken, check-ins en duidelijke stats.",
)
add("Continue with Classic", "クラシックで続ける", "Mit Klassisch fortfahren", "클래식으로 계속", "Continuer avec Classique", "Continuar con Clásico", "Continuar com Clássico", "Continua con Classico", "继续使用经典", "繼續使用經典", "Doorgaan met Klassiek")
add("Progressive Timer", "Progressive Timer", "Progressive Timer", "Progressive Timer", "Progressive Timer", "Progressive Timer", "Progressive Timer", "Progressive Timer", "Progressive Timer", "Progressive Timer", "Progressive Timer")
add("Start around 5′, grow when you’re in flow, up to 25′", "約5′から開始、フローで伸ばし最大25′", "Start bei ~5′, wachsen im Flow bis 25′", "약 5′부터 시작, 흐름에서 성장해 최대 25′", "Commencez vers 5′, grandissez en flow jusqu’à 25′", "Empieza cerca de 5′, crece en flow hasta 25′", "Comece perto de 5′, cresça no fluxo até 25′", "Inizia intorno a 5′, cresci in flow fino a 25′", "约 5′ 开始，心流时增长，最多 25′", "約 5′ 開始，心流時成長，最多 25′", "Begin rond 5′, groei in flow tot 25′")
add("Smart check-ins", "スマートチェックイン", "Smarte Check-ins", "스마트 체크인", "Check-ins intelligents", "Check-ins inteligentes", "Check-ins inteligentes", "Check-in smart", "智能签到", "智慧簽到", "Slimme check-ins")
add("After each block: go longer, shorten, or take a break", "各ブロック後：長くする・短くする・休憩", "Nach jedem Block: länger, kürzer oder Pause", "각 블록 후: 더 길게, 짧게, 또는 휴식", "Après chaque bloc : allonger, raccourcir ou pause", "Tras cada bloque: alargar, acortar o descansar", "Após cada bloco: alongar, encurtar ou pausar", "Dopo ogni blocco: allunga, accorcia o pausa", "每块之后：加长、缩短或休息", "每塊之後：加長、縮短或休息", "Na elk blok: langer, korter of pauze")
add("Struggle escape", "つらいときの逃げ道", "Struggle-Ausweg", "힘든 순간의 탈출구", "Issue de secours", "Salida ante la dificultad", "Saída na dificuldade", "Uscita dalla difficoltà", "困难时的出路", "困難時的出路", "Uitweg bij struggle")
add("Pause, cut remaining time, or break — anytime mid-session", "一時停止、残り短縮、休憩——いつでも", "Pausieren, Rest kürzen oder Pause — jederzeit", "일시정지, 남은 시간 줄이기, 휴식 — 언제든", "Pause, raccourcir ou break — à tout moment", "Pausa, recorta o descansa — en cualquier momento", "Pause, encurte ou pause — a qualquer momento", "Pausa, taglia il resto o break — quando vuoi", "暂停、缩短剩余或休息——随时可做", "暫停、縮短剩餘或休息——隨時可做", "Pauzeer, verkort of break — altijd midden in de sessie")
add("Focus statistics", "集中統計", "Fokusstatistik", "집중 통계", "Statistiques de focus", "Estadísticas de enfoque", "Estatísticas de foco", "Statistiche di focus", "专注统计", "專注統計", "Focusstatistieken")
add("See focus time, starts, and completions on device", "端末上で集中時間・開始・完了を確認", "Fokuszeit, Starts und Abschlüsse auf dem Gerät sehen", "기기에서 집중 시간·시작·완료를 확인", "Voir temps de focus, démarrages et finis sur l’appareil", "Ve tiempo de enfoque, inicios y finales en el dispositivo", "Veja tempo de foco, inícios e conclusões no dispositivo", "Vedi tempo di focus, avvii e completamenti sul dispositivo", "在设备上查看专注时间、开始与完成", "在裝置上查看專注時間、開始與完成", "Bekijk focustijd, starts en afrondingen op het apparaat")
add("Themes & icons", "テーマとアイコン", "Themes & Icons", "테마 및 아이콘", "Thèmes et icônes", "Temas e iconos", "Temas e ícones", "Temi e icone", "主题与图标", "主題與圖示", "Thema’s en pictogrammen")
add("Colors, gradients, and handcrafted app icons", "色、グラデーション、手描きアプリアイコン", "Farben, Verläufe und handgefertigte App-Icons", "색상, 그라데이션, 수작업 앱 아이콘", "Couleurs, dégradés et icônes artisanales", "Colores, degradados e iconos artesanales", "Cores, gradientes e ícones artesanais", "Colori, sfumature e icone artigianali", "颜色、渐变与精心制作的图标", "顏色、漸層與精心製作的圖示", "Kleuren, verlopen en handgemaakte app-pictogrammen")
add(
    "Start short, grow with flow, and recover smart. Unlock Progressive with Pro.",
    "短く始めて流れで伸ばし、賢く回復。ProでProgressiveを解除。",
    "Kurz starten, mit Flow wachsen, smart erholen. Progressive mit Pro freischalten.",
    "짧게 시작하고 흐름으로 성장하며 현명하게 회복. Pro로 Progressive 잠금 해제.",
    "Commencez court, grandissez avec le flow, récupérez intelligemment. Débloquez Progressive avec Pro.",
    "Empieza corto, crece con el flow y recupérate con inteligencia. Desbloquea Progressive con Pro.",
    "Comece curto, cresça com o fluxo e recupere com inteligência. Desbloqueie Progressive com Pro.",
    "Inizia breve, cresci con il flow e recupera in modo smart. Sblocca Progressive con Pro.",
    "从短开始，随心流成长，聪明恢复。用 Pro 解锁 Progressive。",
    "從短開始，隨心流成長，聰明恢復。用 Pro 解鎖 Progressive。",
    "Begin kort, groei met de flow en herstel slim. Ontgrendel Progressive met Pro.",
)

# --- Progressive runtime ---
add("Break over · ready when you are", "休憩終了 · 準備できたら", "Pause vorbei · bereit, wenn du bist", "휴식 종료 · 준비되면", "Pause terminée · quand vous êtes prêt", "Descanso listo · cuando quieras", "Pausa terminada · quando quiser", "Pausa finita · quando sei pronto", "休息结束 · 准备好再开始", "休息結束 · 準備好再開始", "Pauze voorbij · klaar wanneer jij bent")
add("Alarm Sound: On", "アラーム音: オン", "Alarmton: An", "알람 소리: 켜짐", "Son d’alarme : Activé", "Sonido de alarma: Activado", "Som do alarme: Ligado", "Suono sveglia: On", "闹钟声：开", "鬧鐘聲：開", "Alarmgeluid: Aan")
add("Alarm Sound: Off", "アラーム音: オフ", "Alarmton: Aus", "알람 소리: 꺼짐", "Son d’alarme : Désactivé", "Sonido de alarma: Desactivado", "Som do alarme: Desligado", "Suono sveglia: Off", "闹钟声：关", "鬧鐘聲：關", "Alarmgeluid: Uit")
add("Screen Always On", "画面常時点灯", "Bildschirm immer an", "화면 항상 켜짐", "Écran toujours allumé", "Pantalla siempre encendida", "Tela sempre ligada", "Schermo sempre acceso", "屏幕常亮", "螢幕常亮", "Scherm altijd aan")
add("Screen Auto-Lock", "画面自動ロック", "Autom. Bildschirmsperre", "화면 자동 잠금", "Verrouillage auto de l’écran", "Bloqueo automático", "Bloqueio automático", "Blocco automatico", "自动锁屏", "自動鎖定", "Automatisch vergrendelen")
add("Reset Timer", "タイマーをリセット", "Timer zurücksetzen", "타이머 재설정", "Réinitialiser le minuteur", "Reiniciar temporizador", "Redefinir temporizador", "Reimposta timer", "重置计时器", "重設計時器", "Timer resetten")
add("Take a breath", "ひと息つこう", "Atme durch", "한숨 돌리세요", "Prenez une respiration", "Respira un momento", "Respire um pouco", "Fai un respiro", "深呼吸一下", "深呼吸一下", "Neem even adem")
add("You're paused. What would help?", "一時停止中。何が役立ちますか？", "Du bist pausiert. Was hilft?", "일시정지됨. 무엇이 도움이 될까요?", "Vous êtes en pause. Qu’est-ce qui aiderait ?", "Estás en pausa. ¿Qué te ayudaría?", "Você está pausado. O que ajudaria?", "Sei in pausa. Cosa ti aiuterebbe?", "已暂停。怎样会有帮助？", "已暫停。怎樣會有幫助？", "Je bent gepauzeerd. Wat helpt?")
add("Resume this focus block", "この集中ブロックを再開", "Diesen Fokusblock fortsetzen", "이 집중 블록 재개", "Reprendre ce bloc de focus", "Reanudar este bloque", "Retomar este bloco de foco", "Riprendi questo blocco di focus", "恢复这个专注块", "恢復這個專注塊", "Hervat dit focusblok")
add("Cut about a third, then resume", "約3分の1を削って再開", "Etwa ein Drittel kürzen, dann fortsetzen", "약 1/3을 줄인 뒤 재개", "Coupez environ un tiers, puis reprenez", "Recorta cerca de un tercio y reanuda", "Corte cerca de um terço e retome", "Taglia circa un terzo, poi riprendi", "大约去掉三分之一后继续", "大約去掉三分之一後繼續", "Ongeveer een derde eraf, dan hervatten")
add("Start a short break", "短い休憩を開始", "Kurze Pause starten", "짧은 휴식 시작", "Démarrer une courte pause", "Empezar un descanso corto", "Iniciar uma pausa curta", "Avvia una breve pausa", "开始短休息", "開始短休息", "Start een korte pauze")
add("Start your session", "セッションを開始", "Starte deine Sitzung", "세션 시작", "Démarrez votre session", "Empieza tu sesión", "Comece sua sessão", "Avvia la sessione", "开始你的会话", "開始你的工作階段", "Start je sessie")
add(
    "Tap the button to start or pause. The dial scrolls automatically as time passes.",
    "ボタンで開始／一時停止。時間が進むとダイアルが自動で動きます。",
    "Tippe zum Starten oder Pausieren. Das Rad scrollt automatisch mit der Zeit.",
    "버튼으로 시작하거나 일시정지. 시간이 지나면 다이얼이 자동으로 움직입니다.",
    "Touchez pour démarrer ou mettre en pause. Le cadran défile automatiquement.",
    "Toca para iniciar o pausar. El dial se mueve solo con el tiempo.",
    "Toque para iniciar ou pausar. O disco rola automaticamente com o tempo.",
    "Tocca per avviare o mettere in pausa. Il quadrante scorre da solo col tempo.",
    "点按钮开始或暂停。时间流逝时旋钮会自动滚动。",
    "點按鈕開始或暫停。時間流逝時旋鈕會自動滾動。",
    "Tik om te starten of te pauzeren. De schijf scrollt automatisch mee met de tijd.",
)

# Format / interpolated keys (String Catalog style)
add("%@ this week", "%@ 今週", "%@ diese Woche", "%@ 이번 주", "%@ cette semaine", "%@ esta semana", "%@ esta semana", "%@ questa settimana", "%@ 本周", "%@ 本週", "%@ deze week")
add("%lld-day streak", "%lld日連続", "%lld-Tage-Serie", "%lld일 연속", "Série de %lld jours", "Racha de %lld días", "Sequência de %lld dias", "Serie di %lld giorni", "连续 %lld 天", "連續 %lld 天", "%lld-daagse reeks")
add("Best run %lld", "最長 %lld", "Beste Serie %lld", "최고 기록 %lld", "Meilleure série %lld", "Mejor racha %lld", "Melhor sequência %lld", "Miglior serie %lld", "最长 %lld", "最長 %lld", "Beste reeks %lld")
add("%lldh %lldm", "%lld時間%lld分", "%lld Std. %lld Min.", "%lld시간 %lld분", "%lld h %lld min", "%lld h %lld min", "%lld h %lld min", "%lld h %lld min", "%lld小时%lld分", "%lld小時%lld分", "%lld u %lld m")
add("%lldm", "%lld分", "%lld Min.", "%lld분", "%lld min", "%lld min", "%lld min", "%lld min", "%lld分钟", "%lld分鐘", "%lld m")
add("%lld min", "%lld 分", "%lld Min.", "%lld분", "%lld min", "%lld min", "%lld min", "%lld min", "%lld 分钟", "%lld 分鐘", "%lld min")
add("%lld′ focus", "集中 %lld′", "%lld′ Fokus", "집중 %lld′", "%lld′ focus", "%lld′ enfoque", "%lld′ foco", "%lld′ focus", "专注 %lld′", "專注 %lld′", "%lld′ focus")
add("%lld′ break", "休憩 %lld′", "%lld′ Pause", "휴식 %lld′", "%lld′ pause", "%lld′ descanso", "%lld′ pausa", "%lld′ pausa", "休息 %lld′", "休息 %lld′", "%lld′ pauze")
add("%lld′", "%lld′", "%lld′", "%lld′", "%lld′", "%lld′", "%lld′", "%lld′", "%lld′", "%lld′", "%lld′")
add("+%lld", "+%lld", "+%lld", "+%lld", "+%lld", "+%lld", "+%lld", "+%lld", "+%lld", "+%lld", "+%lld")
add("%lld time", "%lld 回", "%lld Mal", "%lld회", "%lld fois", "%lld vez", "%lld vez", "%lld volta", "%lld 次", "%lld 次", "%lld keer")
add("%lld times", "%lld 回", "%lld Mal", "%lld회", "%lld fois", "%lld veces", "%lld vezes", "%lld volte", "%lld 次", "%lld 次", "%lld keer")
add(" min for ", " 分 × ", " Min. für ", "분 × ", " min pour ", " min para ", " min para ", " min per ", " 分钟 × ", " 分鐘 × ", " min voor ")
add(" time", " 回", " Mal", "회", " fois", " vez", " vez", " volta", " 次", " 次", " keer")
add(" times", " 回", " Mal", "회", " fois", " veces", " vezes", " volte", " 次", " 次", " keer")
add(
    "Total: %lld min focus + %lld min break = %lld min",
    "合計: 集中 %lld 分 + 休憩 %lld 分 = %lld 分",
    "Gesamt: %lld Min. Fokus + %lld Min. Pause = %lld Min.",
    "합계: 집중 %lld분 + 휴식 %lld분 = %lld분",
    "Total : %lld min focus + %lld min pause = %lld min",
    "Total: %lld min enfoque + %lld min descanso = %lld min",
    "Total: %lld min foco + %lld min pausa = %lld min",
    "Totale: %lld min focus + %lld min pausa = %lld min",
    "合计：专注 %lld 分钟 + 休息 %lld 分钟 = %lld 分钟",
    "合計：專注 %lld 分鐘 + 休息 %lld 分鐘 = %lld 分鐘",
    "Totaal: %lld min focus + %lld min pauze = %lld min",
)
add("Focus · building to %@", "集中 · %@ へ伸ばし中", "Fokus · aufbauend auf %@", "집중 · %@로 늘리는 중", "Focus · vers %@", "Enfoque · creciendo a %@", "Foco · crescendo para %@", "Focus · verso %@", "专注 · 正在增至 %@", "專注 · 正在增至 %@", "Focus · opbouwen naar %@")
add("Focus · %@", "集中 · %@", "Fokus · %@", "집중 · %@", "Focus · %@", "Enfoque · %@", "Foco · %@", "Focus · %@", "专注 · %@", "專注 · %@", "Focus · %@")
add("%@ → %@ · starts next", "%@ → %@ · 次から開始", "%@ → %@ · startet als Nächstes", "%@ → %@ · 다음에 시작", "%@ → %@ · démarre ensuite", "%@ → %@ · empieza a continuación", "%@ → %@ · começa em seguida", "%@ → %@ · parte dopo", "%@ → %@ · 接下来开始", "%@ → %@ · 接下來開始", "%@ → %@ · start hierna")
add("%@ → %@ · tap play when ready", "%@ → %@ · 準備できたら再生", "%@ → %@ · Play tippen wenn bereit", "%@ → %@ · 준비되면 재생", "%@ → %@ · lancez Play quand prêt", "%@ → %@ · pulsa play cuando quieras", "%@ → %@ · toque em play quando quiser", "%@ → %@ · premi play quando pronto", "%@ → %@ · 准备好后点播放", "%@ → %@ · 準備好後點播放", "%@ → %@ · tik op play als je klaar bent")
add("%@ break · starts next", "休憩 %@ · 次から開始", "%@ Pause · startet als Nächstes", "휴식 %@ · 다음에 시작", "Pause %@ · démarre ensuite", "Descanso %@ · empieza a continuación", "Pausa %@ · começa em seguida", "Pausa %@ · parte dopo", "休息 %@ · 接下来开始", "休息 %@ · 接下來開始", "Pauze %@ · start hierna")
add("%@, %@ focused", "%@、%@ 集中", "%@, %@ fokussiert", "%@, %@ 집중", "%@, %@ de focus", "%@, %@ de enfoque", "%@, %@ de foco", "%@, %@ di focus", "%@，专注 %@", "%@，專注 %@", "%@, %@ gefocust")
add("%@, no focus", "%@、集中なし", "%@, kein Fokus", "%@, 집중 없음", "%@, aucun focus", "%@, sin enfoque", "%@, sem foco", "%@, nessun focus", "%@，无专注", "%@，無專注", "%@, geen focus")
add("Need a break · %@", "休憩が必要 · %@", "Brauche Pause · %@", "휴식이 필요함 · %@", "Besoin d’une pause · %@", "Necesito un descanso · %@", "Preciso de uma pausa · %@", "Serve una pausa · %@", "需要休息 · %@", "需要休息 · %@", "Pauze nodig · %@")
add("A bit much · %@", "少しキツい · %@", "Etwas viel · %@", "조금 많음 · %@", "Un peu trop · %@", "Un poco mucho · %@", "Um pouco demais · %@", "Un po’ troppo · %@", "有点多 · %@", "有點多 · %@", "Een beetje te veel · %@")
add("In the flow · %@", "フロー · %@", "Im Flow · %@", "흐름에 탐 · %@", "En flow · %@", "En el flow · %@", "No fluxo · %@", "In flow · %@", "心流 · %@", "心流 · %@", "In de flow · %@")
add("%lld minutes remaining", "残り %lld 分", "Noch %lld Minuten", "%lld분 남음", "%lld minutes restantes", "%lld minutos restantes", "%lld minutos restantes", "%lld minuti rimanenti", "剩余 %lld 分钟", "剩餘 %lld 分鐘", "%lld minuten resterend")

# --- Classic tasks ---
add("No Timers Yet", "まだタイマーがありません", "Noch keine Timer", "아직 타이머 없음", "Aucun minuteur", "Aún no hay temporizadores", "Ainda não há temporizadores", "Nessun timer ancora", "还没有计时器", "還沒有計時器", "Nog geen timers")
add(
    "Create a timer to start a focused work session with the Pomodoro technique.",
    "タイマーを作ってポモドーロで集中セッションを始めましょう。",
    "Erstelle einen Timer für eine fokussierte Pomodoro-Sitzung.",
    "포모도로로 집중 세션을 시작하려면 타이머를 만드세요.",
    "Créez un minuteur pour une session Pomodoro concentrée.",
    "Crea un temporizador para una sesión Pomodoro enfocada.",
    "Crie um temporizador para uma sessão Pomodoro focada.",
    "Crea un timer per una sessione Pomodoro concentrata.",
    "创建计时器，用番茄钟开始专注会话。",
    "建立計時器，用番茄鐘開始專注工作階段。",
    "Maak een timer voor een gefocuste Pomodoro-sessie.",
)
add("Create Your First Timer", "最初のタイマーを作成", "Ersten Timer erstellen", "첫 타이머 만들기", "Créer votre premier minuteur", "Crea tu primer temporizador", "Crie seu primeiro temporizador", "Crea il tuo primo timer", "创建第一个计时器", "建立第一個計時器", "Maak je eerste timer")
add("e.g. Deep Work, Morning Study…", "例: ディープワーク、朝の勉強…", "z. B. Deep Work, Morgenlernen…", "예: 딥 워크, 아침 공부…", "ex. Deep Work, révision du matin…", "ej. Deep Work, estudio matutino…", "ex.: Deep Work, estudo matinal…", "es. Deep Work, studio mattutino…", "例如：深度工作、晨间学习…", "例如：深度工作、晨間學習…", "bijv. Deep Work, ochtendstudie…")
add("New Timer", "新しいタイマー", "Neuer Timer", "새 타이머", "Nouveau minuteur", "Nuevo temporizador", "Novo temporizador", "Nuovo timer", "新建计时器", "新增計時器", "Nieuwe timer")
add("Edit Timer", "タイマーを編集", "Timer bearbeiten", "타이머 편집", "Modifier le minuteur", "Editar temporizador", "Editar temporizador", "Modifica timer", "编辑计时器", "編輯計時器", "Timer bewerken")
add("Discard Timer?", "タイマーを破棄しますか？", "Timer verwerfen?", "타이머를 버릴까요?", "Ignorer le minuteur ?", "¿Descartar temporizador?", "Descartar temporizador?", "Annullare il timer?", "丢弃计时器？", "捨棄計時器？", "Timer verwerpen?")
add("Discard Changes?", "変更を破棄しますか？", "Änderungen verwerfen?", "변경사항을 버릴까요?", "Ignorer les modifications ?", "¿Descartar cambios?", "Descartar alterações?", "Annullare le modifiche?", "丢弃更改？", "捨棄變更？", "Wijzigingen verwerpen?")
add("This timer will not be saved.", "このタイマーは保存されません。", "Dieser Timer wird nicht gespeichert.", "이 타이머는 저장되지 않습니다.", "Ce minuteur ne sera pas enregistré.", "Este temporizador no se guardará.", "Este temporizador não será salvo.", "Questo timer non verrà salvato.", "此计时器不会被保存。", "此計時器不會被儲存。", "Deze timer wordt niet opgeslagen.")
add("Your edits will be lost.", "編集内容は失われます。", "Deine Änderungen gehen verloren.", "편집 내용이 사라집니다.", "Vos modifications seront perdues.", "Se perderán tus cambios.", "Suas edições serão perdidas.", "Le modifiche andranno perse.", "你的编辑将丢失。", "你的編輯將遺失。", "Je bewerkingen gaan verloren.")

# --- Settings / WhatsNew ---
add("Progressive Pro", "Progressive Pro", "Progressive Pro", "Progressive Pro", "Progressive Pro", "Progressive Pro", "Progressive Pro", "Progressive Pro", "Progressive Pro", "Progressive Pro", "Progressive Pro")
add(
    "Adaptive focus, check-ins, stats, and themes are yours.",
    "適応フォーカス、チェックイン、統計、テーマが使えます。",
    "Adaptiver Fokus, Check-ins, Stats und Themes gehören dir.",
    "적응형 집중, 체크인, 통계, 테마를 사용할 수 있습니다.",
    "Focus adaptatif, check-ins, stats et thèmes sont à vous.",
    "Enfoque adaptativo, check-ins, stats y temas son tuyos.",
    "Foco adaptativo, check-ins, estatísticas e temas são seus.",
    "Focus adattivo, check-in, stats e temi sono tuoi.",
    "自适应专注、签到、统计与主题都归你。",
    "自適應專注、簽到、統計與主題都歸你。",
    "Adaptieve focus, check-ins, stats en thema’s zijn van jou.",
)
add(
    "Adaptive focus, check-ins, stats, and themes",
    "適応フォーカス、チェックイン、統計、テーマ",
    "Adaptiver Fokus, Check-ins, Stats und Themes",
    "적응형 집중, 체크인, 통계, 테마",
    "Focus adaptatif, check-ins, stats et thèmes",
    "Enfoque adaptativo, check-ins, stats y temas",
    "Foco adaptativo, check-ins, estatísticas e temas",
    "Focus adattivo, check-in, stats e temi",
    "自适应专注、签到、统计与主题",
    "自適應專注、簽到、統計與主題",
    "Adaptieve focus, check-ins, stats en thema’s",
)
add(
    "Alarm uses AlarmKit for a Clock-style alert that breaks through Silent mode and Focus. Turn on Alarm in Settings and allow Alarms & Timers when prompted. Session notifications are optional banners and are skipped while AlarmKit is active.",
    "アラームはAlarmKitを使い、サイレントや集中モードでも届く時計アプリ風の通知です。設定でアラームをオンにし、求められたら「アラームとタイマー」を許可してください。セッション通知は任意のバナーで、AlarmKit動作中はスキップされます。",
    "Der Alarm nutzt AlarmKit für eine Uhr-ähnliche Warnung, die Lautlos und Fokus durchbricht. Aktiviere Alarm in den Einstellungen und erlaube Alarme & Timer. Sitzungsbenachrichtigungen sind optionale Banner und entfallen, solange AlarmKit aktiv ist.",
    "알람은 AlarmKit으로 무음·집중 모드를 뚫는 시계 스타일 알림을 제공합니다. 설정에서 알람을 켜고 요청 시 알람 및 타이머를 허용하세요. 세션 알림은 선택 배너이며 AlarmKit이 켜져 있으면 건너뜁니다.",
    "L’alarme utilise AlarmKit pour une alerte style Horloge qui passe le mode Silencieux et Concentration. Activez Alarme dans Réglages et autorisez Alarmes et minuteries. Les notifications de session sont des bannières optionnelles, ignorées quand AlarmKit est actif.",
    "La alarma usa AlarmKit para un aviso estilo Reloj que atraviesa Silencio y Concentración. Activa Alarma en Ajustes y permite Alarmas y temporizadores. Las notificaciones de sesión son banners opcionales y se omiten con AlarmKit activo.",
    "O alarme usa AlarmKit para um alerta estilo Relógio que passa pelo Silencioso e Foco. Ative Alarme em Ajustes e permita Alarmes e timers. Notificações de sessão são banners opcionais e são ignoradas com AlarmKit ativo.",
    "La sveglia usa AlarmKit per un avviso stile Orologio che supera Silenzioso e Concentrazione. Attiva Sveglia in Impostazioni e consenti Sveglie e timer. Le notifiche di sessione sono banner opzionali e vengono saltate con AlarmKit attivo.",
    "闹钟使用 AlarmKit，可像时钟 App 一样突破静音和专注模式。在设置中开启闹钟，并在提示时允许“闹钟与计时器”。会话通知是可选横幅，AlarmKit 启用时会跳过。",
    "鬧鐘使用 AlarmKit，可像時鐘 App 一樣突破靜音和專注模式。在設定中開啟鬧鐘，並在提示時允許「鬧鐘與計時器」。工作階段通知是可選橫幅，AlarmKit 啟用時會略過。",
    "Alarm gebruikt AlarmKit voor een Klok-achtige melding die Stil en Focus doorbreekt. Zet Alarm aan in Instellingen en sta Alarmen en timers toe. Sessie-meldingen zijn optionele banners en worden overgeslagen als AlarmKit actief is.",
)
add("What's New", "新機能", "Neuigkeiten", "새로운 기능", "Nouveautés", "Novedades", "Novidades", "Novità", "新功能", "新功能", "Wat is er nieuw")
add("Discover the latest features", "最新機能をチェック", "Entdecke die neuesten Funktionen", "최신 기능을 확인하세요", "Découvrez les dernières fonctionnalités", "Descubre las últimas funciones", "Descubra os recursos mais recentes", "Scopri le ultime funzioni", "了解最新功能", "了解最新功能", "Ontdek de nieuwste functies")
add("Apple Watch App", "Apple Watchアプリ", "Apple Watch App", "Apple Watch 앱", "App Apple Watch", "App de Apple Watch", "App do Apple Watch", "App Apple Watch", "Apple Watch 应用", "Apple Watch App", "Apple Watch-app")
add(
    "Take your productivity on the go with our new Apple Watch app. Start and track your timers directly from your wrist.",
    "新しいApple Watchアプリで、腕元からタイマーを開始・追跡。",
    "Mit der neuen Apple Watch App startest und verfolgst du Timer direkt vom Handgelenk.",
    "새로운 Apple Watch 앱으로 손목에서 바로 타이머를 시작하고 추적하세요.",
    "Avec la nouvelle app Apple Watch, démarrez et suivez vos minuteurs depuis le poignet.",
    "Con la nueva app de Apple Watch inicia y sigue tus temporizadores desde la muñeca.",
    "Com o novo app do Apple Watch, inicie e acompanhe timers no pulso.",
    "Con la nuova app Apple Watch avvia e monitora i timer dal polso.",
    "用全新 Apple Watch 应用，在手腕上启动并跟踪计时器。",
    "用全新 Apple Watch App，在手腕上啟動並追蹤計時器。",
    "Met de nieuwe Apple Watch-app start en volg je timers vanaf je pols.",
)
add("Deep Timer Customization", "タイマーの深いカスタマイズ", "Tiefe Timer-Anpassung", "심층 타이머 맞춤설정", "Personnalisation avancée du minuteur", "Personalización profunda del temporizador", "Personalização profunda do temporizador", "Personalizzazione avanzata del timer", "深度计时器自定义", "深度計時器自訂", "Diepe timer-aanpassing")
add(
    "Personalize your timer experience with advanced color settings. Adjust colors to match your preferences.",
    "高度なカラー設定でタイマー体験をカスタマイズ。好みの色に合わせましょう。",
    "Personalisieren Sie Ihr Timer-Erlebnis mit erweiterten Farbeinstellungen.",
    "고급 색상 설정으로 타이머 경험을 맞춤화하세요.",
    "Personnalisez votre expérience avec des réglages de couleur avancés.",
    "Personaliza tu experiencia con ajustes avanzados de color.",
    "Personalize sua experiência com configurações avançadas de cor.",
    "Personalizza l’esperienza con impostazioni colore avanzate.",
    "用高级颜色设置个性化计时体验。",
    "用進階顏色設定個人化計時體驗。",
    "Personaliseer je timer met geavanceerde kleurinstellingen.",
)
add("Timer Status Notifications", "タイマー状態の通知", "Timer-Statusmeldungen", "타이머 상태 알림", "Notifications d’état du minuteur", "Notificaciones de estado", "Notificações de status do temporizador", "Notifiche di stato del timer", "计时器状态通知", "計時器狀態通知", "Timerstatusmeldingen")
add(
    "Stay focus with real-time notifications about your timer status. Never miss a break or work session again.",
    "タイマー状態のリアルタイム通知で集中をキープ。休憩や作業を逃しません。",
    "Bleib fokussiert mit Echtzeit-Benachrichtigungen zum Timer-Status.",
    "타이머 상태 실시간 알림으로 집중을 유지하세요.",
    "Restez concentré avec des notifications en temps réel sur l’état du minuteur.",
    "Mantente enfocado con notificaciones en tiempo real del estado del temporizador.",
    "Mantenha o foco com notificações em tempo real do status do temporizador.",
    "Resta concentrato con notifiche in tempo reale sullo stato del timer.",
    "通过实时状态通知保持专注，不再错过休息或工作。",
    "透過即時狀態通知保持專注，不再錯過休息或工作。",
    "Blijf gefocust met realtime meldingen over je timerstatus.",
)

# --- Statistics marketing ---
add("Tomato splash calendar", "トマト・スプラッシュ・カレンダー", "Tomato-Splash-Kalender", "토마토 스플래시 캘린더", "Calendrier tomato splash", "Calendario tomato splash", "Calendário tomato splash", "Calendario tomato splash", "番茄飞溅日历", "番茄飛濺日曆", "Tomato-splashkalender")
add(
    "See every focus day as a tomato hit — streaks, heat, and a stage full of smashed tomatoes. Unlock with Progressive Pro.",
    "集中した日をトマトヒットで表示——ストリーク、ヒート、潰れたトマトのステージ。Progressive Proで解除。",
    "Sieh jeden Fokustag als Tomato-Hit — Serien, Hitze und eine Bühne voller Tomaten. Mit Progressive Pro freischalten.",
    "집중한 날을 토마토 히트로 — 연속, 히트, 으깨진 토마토 무대. Progressive Pro로 잠금 해제.",
    "Voyez chaque jour de focus comme un tomato hit — séries, chaleur et scène de tomates. Débloquez avec Progressive Pro.",
    "Ve cada día de enfoque como un tomato hit — rachas, calor y un escenario de tomates. Desbloquea con Progressive Pro.",
    "Veja cada dia de foco como um tomato hit — sequências, calor e um palco de tomates. Desbloqueie com Progressive Pro.",
    "Vedi ogni giorno di focus come un tomato hit — serie, calore e un palco di pomodori. Sblocca con Progressive Pro.",
    "把每个专注日看成番茄命中——连续、热力与满台砸烂番茄。用 Progressive Pro 解锁。",
    "把每個專注日看成番茄命中——連續、熱力與滿台砸爛番茄。用 Progressive Pro 解鎖。",
    "Zie elke focusdag als een tomato hit — reeksen, heat en een podium vol tomaten. Ontgrendel met Progressive Pro.",
)
add(
    "Track your productivity and progress with detailed statistics. Upgrade to Pro on your iPhone to unlock this feature.",
    "詳細な統計で生産性と進捗を追跡。iPhoneでProにアップグレードして解除。",
    "Verfolge Produktivität und Fortschritt mit detaillierter Statistik. Upgrade auf dem iPhone auf Pro.",
    "상세 통계로 생산성과 진행을 추적하세요. iPhone에서 Pro로 업그레이드해 잠금 해제.",
    "Suivez productivité et progrès avec des stats détaillées. Passez à Pro sur iPhone pour débloquer.",
    "Sigue productividad y progreso con estadísticas detalladas. Actualiza a Pro en el iPhone.",
    "Acompanhe produtividade e progresso com estatísticas detalhadas. Atualize para Pro no iPhone.",
    "Traccia produttività e progressi con statistiche dettagliate. Passa a Pro su iPhone.",
    "用详细统计跟踪效率与进度。在 iPhone 上升级到 Pro 解锁。",
    "用詳細統計追蹤效率與進度。在 iPhone 上升級至 Pro 解鎖。",
    "Volg productiviteit en voortgang met gedetailleerde stats. Upgrade naar Pro op je iPhone.",
)

# --- Notifications / intents ---
add("Break Time Complete", "休憩完了", "Pause beendet", "휴식 완료", "Pause terminée", "Descanso terminado", "Pausa concluída", "Pausa completata", "休息完成", "休息完成", "Pauze voltooid")
add("Focus Time Complete", "集中完了", "Fokus beendet", "집중 완료", "Focus terminé", "Enfoque terminado", "Foco concluído", "Focus completato", "专注完成", "專注完成", "Focus voltooid")
add("Your break session has ended.", "休憩セッションが終了しました。", "Deine Pause ist beendet.", "휴식 세션이 끝났습니다.", "Votre session de pause est terminée.", "Tu sesión de descanso ha terminado.", "Sua sessão de pausa terminou.", "La sessione di pausa è terminata.", "休息会话已结束。", "休息工作階段已結束。", "Je pauzesessie is beëindigd.")
add("Your focus session has ended.", "集中セッションが終了しました。", "Deine Fokussitzung ist beendet.", "집중 세션이 끝났습니다.", "Votre session de focus est terminée.", "Tu sesión de enfoque ha terminado.", "Sua sessão de foco terminou.", "La sessione di focus è terminata.", "专注会话已结束。", "專注工作階段已結束。", "Je focussessie is beëindigd.")
add("Break complete", "休憩完了", "Pause fertig", "휴식 완료", "Pause terminée", "Descanso completo", "Pausa concluída", "Pausa completata", "休息完成", "休息完成", "Pauze voltooid")
add("Play or Pause Focus Timer", "集中タイマーの再生／一時停止", "Fokus-Timer starten oder pausieren", "집중 타이머 재생 또는 일시정지", "Lire ou mettre en pause le focus", "Reproducir o pausar el enfoque", "Reproduzir ou pausar o foco", "Avvia o metti in pausa il focus", "播放或暂停专注计时器", "播放或暫停專注計時器", "Focus-timer afspelen of pauzeren")
add(
    "Starts, pauses, or resumes the Progressive focus timer.",
    "Progressive集中タイマーを開始、一時停止、または再開します。",
    "Startet, pausiert oder setzt den Progressive-Fokus-Timer fort.",
    "Progressive 집중 타이머를 시작, 일시정지 또는 재개합니다.",
    "Démarre, met en pause ou reprend le minuteur Progressive.",
    "Inicia, pausa o reanuda el temporizador Progressive.",
    "Inicia, pausa ou retoma o temporizador Progressive.",
    "Avvia, mette in pausa o riprende il timer Progressive.",
    "开始、暂停或恢复 Progressive 专注计时器。",
    "開始、暫停或恢復 Progressive 專注計時器。",
    "Start, pauzeert of hervat de Progressive-focustimer.",
)
add("Open PomoTask", "PomoTaskを開く", "PomoTask öffnen", "PomoTask 열기", "Ouvrir PomoTask", "Abrir PomoTask", "Abrir PomoTask", "Apri PomoTask", "打开 PomoTask", "開啟 PomoTask", "PomoTask openen")
add(
    "Opens PomoTask after a focus or break alarm.",
    "集中または休憩アラームのあとPomoTaskを開きます。",
    "Öffnet PomoTask nach einem Fokus- oder Pausenalarm.",
    "집중 또는 휴식 알람 후 PomoTask를 엽니다.",
    "Ouvre PomoTask après une alarme de focus ou de pause.",
    "Abre PomoTask tras una alarma de enfoque o descanso.",
    "Abre o PomoTask após um alarme de foco ou pausa.",
    "Apre PomoTask dopo un allarme di focus o pausa.",
    "在专注或休息闹钟后打开 PomoTask。",
    "在專注或休息鬧鐘後開啟 PomoTask。",
    "Opent PomoTask na een focus- of pauzealarm.",
)
add("Alarm ID", "アラームID", "Alarm-ID", "알람 ID", "ID d’alarme", "ID de alarma", "ID do alarme", "ID sveglia", "闹钟 ID", "鬧鐘 ID", "Alarm-ID")
add(
    "Break is over — ready when you are.",
    "休憩終了——準備できたら。",
    "Pause vorbei — bereit, wenn du bist.",
    "휴식 종료 — 준비되면.",
    "La pause est terminée — quand vous voulez.",
    "El descanso terminó — cuando quieras.",
    "A pausa acabou — quando quiser.",
    "La pausa è finita — quando sei pronto.",
    "休息结束——准备好再开始。",
    "休息結束——準備好再開始。",
    "Pauze voorbij — klaar wanneer jij bent.",
)
add(
    "Focus block finished. How did it feel?",
    "集中ブロック終了。どうでしたか？",
    "Fokusblock fertig. Wie hat es sich angefühlt?",
    "집중 블록 끝. 어땠나요?",
    "Bloc de focus terminé. Comment ça s’est passé ?",
    "Bloque de enfoque terminado. ¿Cómo te sentiste?",
    "Bloco de foco terminado. Como foi?",
    "Blocco di focus finito. Com’è andata?",
    "专注块结束。感觉如何？",
    "專注塊結束。感覺如何？",
    "Focusblok klaar. Hoe voelde het?",
)

# --- Widgets ---
add("Focus Timer", "集中タイマー", "Fokus-Timer", "집중 타이머", "Minuteur de focus", "Temporizador de enfoque", "Temporizador de foco", "Timer di focus", "专注计时器", "專注計時器", "Focustimer")
add(
    "Start or pause a Progressive focus session from your Home Screen.",
    "ホーム画面からProgressive集中セッションを開始または一時停止。",
    "Starte oder pausiere eine Progressive-Fokus-Sitzung vom Home-Bildschirm.",
    "홈 화면에서 Progressive 집중 세션을 시작하거나 일시정지하세요.",
    "Démarrez ou mettez en pause une session Progressive depuis l’écran d’accueil.",
    "Inicia o pausa una sesión Progressive desde la pantalla de inicio.",
    "Inicie ou pause uma sessão Progressive na Tela de Início.",
    "Avvia o metti in pausa una sessione Progressive dalla Home.",
    "从主屏幕开始或暂停 Progressive 专注会话。",
    "從主畫面開始或暫停 Progressive 專注工作階段。",
    "Start of pauzeer een Progressive-focussessie vanaf je beginscherm.",
)
add("Focus Stats", "集中統計", "Fokus-Stats", "집중 통계", "Stats de focus", "Estadísticas de enfoque", "Estatísticas de foco", "Stats di focus", "专注统计", "專注統計", "Focusstats")
add(
    "Week focus and streaks in small/medium; tomato splash calendar in large.",
    "小／中サイズは週の集中とストリーク、大はトマト・スプラッシュ・カレンダー。",
    "Wochenfokus und Serien in Klein/Mittel; Tomato-Splash-Kalender in Groß.",
    "작음/중간은 주간 집중과 연속, 큼은 토마토 스플래시 캘린더.",
    "Focus de la semaine et séries en petit/moyen ; calendrier tomato splash en grand.",
    "Enfoque semanal y rachas en pequeño/mediano; calendario tomato splash en grande.",
    "Foco da semana e sequências no pequeno/médio; calendário tomato splash no grande.",
    "Focus della settimana e serie in piccolo/medio; calendario tomato splash in grande.",
    "小/中尺寸显示本周专注与连续；大尺寸为番茄飞溅日历。",
    "小/中尺寸顯示本週專注與連續；大尺寸為番茄飛濺日曆。",
    "Weekfocus en reeksen in klein/middel; tomato-splashkalender in groot.",
)

# Info.plist (also in InfoPlist.xcstrings)
INFO_PLIST_KEY = "NSAlarmKitUsageDescription"
INFO_PLIST_EN = "PomoTask schedules alarms so you hear when a focus or break session ends, even in Silent mode or Focus."
add(
    INFO_PLIST_EN,
    "PomoTaskは集中または休憩の終了時にアラームを鳴らし、サイレントや集中モードでも聞こえるようにします。",
    "PomoTask plant Alarme, damit du das Ende von Fokus oder Pause hörst — auch im Lautlos- oder Fokusmodus.",
    "PomoTask는 집중이나 휴식이 끝날 때 알람을 울려 무음이나 집중 모드에서도 들을 수 있게 합니다.",
    "PomoTask planifie des alarmes pour signaler la fin d’un focus ou d’une pause, même en mode Silencieux ou Concentration.",
    "PomoTask programa alarmas para que oigas el fin de un enfoque o descanso, incluso en Silencio o Concentración.",
    "O PomoTask agenda alarmes para você ouvir o fim de um foco ou pausa, mesmo no Silencioso ou Foco.",
    "PomoTask programma sveglie così senti quando finisce un focus o una pausa, anche in Silenzioso o Concentrazione.",
    "PomoTask 会安排闹钟，以便在专注或休息结束时提醒你，即使处于静音或专注模式。",
    "PomoTask 會安排鬧鐘，以便在專注或休息結束時提醒你，即使處於靜音或專注模式。",
    "PomoTask plant alarmen zodat je hoort wanneer focus of pauze eindigt, ook in Stil of Focus.",
)


def build_catalog(translations: dict[str, list[str]]) -> dict:
    strings: dict = {}
    for en, vals in translations.items():
        locs = {}
        for locale, value in zip(LOCALES, vals):
            locs[locale] = {"stringUnit": {"state": "translated", "value": value}}
        strings[en] = {"localizations": locs}
    return {
        "sourceLanguage": "en",
        "strings": strings,
        "version": "1.0",
    }


def build_infoplist() -> dict:
    locs = {}
    vals = T[INFO_PLIST_EN]
    for locale, value in zip(LOCALES, vals):
        locs[locale] = {"stringUnit": {"state": "translated", "value": value}}
    return {
        "sourceLanguage": "en",
        "strings": {
            INFO_PLIST_KEY: {
                "comment": "Privacy - AlarmKit Usage Description",
                "localizations": {
                    "en": {"stringUnit": {"state": "translated", "value": INFO_PLIST_EN}},
                    **locs,
                },
            }
        },
        "version": "1.0",
    }


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    out = root / "TomaTask" / "Localizable.xcstrings"
    out.write_text(json.dumps(build_catalog(T), ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {out} with {len(T)} keys")

    info = root / "TomaTask" / "InfoPlist.xcstrings"
    info.write_text(json.dumps(build_infoplist(), ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {info}")


if __name__ == "__main__":
    main()
