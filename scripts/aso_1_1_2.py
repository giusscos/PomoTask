#!/usr/bin/env python3
"""ASO metadata for PomoTask 1.1.2: name, subtitle, keywords, promo text per App Store locale.

Rules: name/subtitle <= 30 chars, keywords <= 100 chars, promo <= 170.
Keywords never repeat a word already in that locale's name or subtitle
(Apple indexes name + subtitle + keywords together).
en-GB and es-MX are extra locales that Apple also indexes for the US storefront,
so they carry *different* keywords than en-US / es-ES.
"""

from __future__ import annotations

import re
from pathlib import Path

ASO: dict[str, dict[str, str]] = {
    "en-US": {
        "name": "PomoTask: Pomodoro Focus Timer",
        "subtitle": "Adaptive Study & Work Sessions",
        "keywords": "tomato,adhd,deep,flow,concentration,habit,routine,break,countdown,homework,exam,productive,streak",
        "promo": "Try Progressive free for 3 sessions: start at 5 minutes and let PomoTask grow your focus with every block. Apple Watch, widgets, and Live Activities included.",
    },
    "en-GB": {
        "name": "PomoTask: Pomodoro Study Clock",
        "subtitle": "Productivity Timer for Tasks",
        "keywords": "tomato,adhd,deep,flow,concentrate,revision,student,planner,interval,stopwatch,widget,watch,calm",
        "promo": "Try Progressive free for 3 sessions: start at 5 minutes and let PomoTask grow your focus with every block. Apple Watch, widgets, and Live Activities included.",
    },
    "es-MX": {
        "name": "PomoTask: Pomodoro y Estudio",
        "subtitle": "Temporizador de concentración",
        "keywords": "productividad,tdah,tomate,enfoque,trabajo,tareas,hábitos,descanso,reloj,examen,racha,cronómetro",
        "promo": "Prueba Progressive gratis durante 3 sesiones: empieza con 5 minutos y deja que PomoTask haga crecer tu enfoque. Incluye Apple Watch, widgets y Live Activities.",
    },
    "es-ES": {
        "name": "PomoTask: Pomodoro y Enfoque",
        "subtitle": "Temporizador para estudiar",
        "keywords": "concentración,productividad,tdah,tomate,trabajo,tareas,hábitos,descanso,reloj,examen,racha,flow",
        "promo": "Prueba Progressive gratis durante 3 sesiones: empieza con 5 minutos y deja que PomoTask haga crecer tu enfoque. Incluye Apple Watch, widgets y Live Activities.",
    },
    "fr-FR": {
        "name": "PomoTask : Pomodoro & Focus",
        "subtitle": "Minuteur pour étudier, bosser",
        "keywords": "concentration,productivité,tdah,tomate,travail,révision,habitude,pause,chrono,examen,série,flow",
        "promo": "Essayez Progressive gratuitement pendant 3 sessions : commencez à 5 minutes et laissez PomoTask faire grandir votre concentration. Apple Watch et widgets inclus.",
    },
    "de-DE": {
        "name": "PomoTask: Pomodoro Fokus",
        "subtitle": "Lern-Timer für Konzentration",
        "keywords": "produktivität,adhs,tomate,arbeit,lernen,gewohnheit,pause,stoppuhr,prüfung,streak,flow,aufgaben",
        "promo": "Teste Progressive 3 Sessions gratis: Starte mit 5 Minuten und lass PomoTask deinen Fokus mit jedem Block wachsen. Mit Apple Watch, Widgets und Live Activities.",
    },
    "it": {
        "name": "PomoTask: Pomodoro e Focus",
        "subtitle": "Timer per studio e lavoro",
        "keywords": "concentrazione,produttività,adhd,tomato,abitudini,pausa,cronometro,esame,compiti,streak,flow",
        "promo": "Prova Progressive gratis per 3 sessioni: inizia da 5 minuti e lascia che PomoTask faccia crescere la tua concentrazione. Con Apple Watch, widget e Live Activity.",
    },
    "pt-BR": {
        "name": "PomoTask: Pomodoro e Foco",
        "subtitle": "Timer para estudar e trabalhar",
        "keywords": "concentração,produtividade,tdah,tomate,hábitos,pausa,cronômetro,prova,vestibular,tarefas,flow",
        "promo": "Experimente o Progressive grátis por 3 sessões: comece com 5 minutos e deixe o PomoTask aumentar seu foco a cada bloco. Com Apple Watch, widgets e Live Activities.",
    },
    "nl-NL": {
        "name": "PomoTask: Pomodoro Focus",
        "subtitle": "Studietimer voor concentratie",
        "keywords": "productiviteit,adhd,tomaat,werk,leren,gewoonte,pauze,stopwatch,examen,taken,streak,flow,huiswerk",
        "promo": "Probeer Progressive 3 sessies gratis: begin met 5 minuten en laat PomoTask je focus met elk blok laten groeien. Met Apple Watch, widgets en Live Activities.",
    },
    "ja": {
        "name": "PomoTask ポモドーロ集中タイマー",
        "subtitle": "勉強・仕事の集中力アップ",
        "keywords": "ポモドーロテクニック,トマト,ADHD,生産性,習慣,休憩,ストップウォッチ,試験,受験,作業,フロー,ストリーク",
        "promo": "Progressiveを3セッション無料でお試し。5分から始めて、ブロックごとに集中時間を伸ばします。Apple Watch・ウィジェット・ライブアクティビティ対応。",
    },
    "ko": {
        "name": "PomoTask 뽀모도로 집중 타이머",
        "subtitle": "공부·업무 집중력 향상",
        "keywords": "포모도로,토마토,ADHD,생산성,습관,휴식,스톱워치,시험,수능,과제,플로우,스트릭,공부시간",
        "promo": "Progressive를 3회 무료로 체험하세요. 5분부터 시작해 블록마다 집중 시간을 늘려 갑니다. Apple Watch, 위젯, 라이브 액티비티 지원.",
    },
    "zh-Hans": {
        "name": "PomoTask 番茄钟专注计时器",
        "subtitle": "学习工作 提升专注力",
        "keywords": "番茄工作法,pomodoro,自律,效率,习惯,休息,秒表,考试,考研,作业,ADHD,心流,打卡",
        "promo": "免费体验 3 次 Progressive：从 5 分钟开始，每个专注块都让 PomoTask 帮你延长专注时间。支持 Apple Watch、小组件和实时活动。",
    },
    "zh-Hant": {
        "name": "PomoTask 番茄鐘專注計時器",
        "subtitle": "讀書工作 提升專注力",
        "keywords": "番茄工作法,pomodoro,自律,效率,習慣,休息,碼錶,考試,作業,ADHD,心流,打卡,讀書",
        "promo": "免費體驗 3 次 Progressive：從 5 分鐘開始，每個專注區塊都讓 PomoTask 幫你延長專注時間。支援 Apple Watch、小工具和即時動態。",
    },
}


def words(text: str) -> set[str]:
    return {w for w in re.split(r"[\s,:&·・、/]+", text.lower()) if len(w) > 1}


def validate() -> list[str]:
    problems = []
    for loc, d in ASO.items():
        for field, limit in (("name", 30), ("subtitle", 30), ("keywords", 100), ("promo", 170)):
            if len(d[field]) > limit:
                problems.append(f"{loc} {field} {len(d[field])}>{limit}")
        if " " in d["keywords"].replace(", ", ","):
            pass
        if ", " in d["keywords"]:
            problems.append(f"{loc} keywords contain ', '")
        dup = words(d["name"] + " " + d["subtitle"]) & set(d["keywords"].lower().split(","))
        if dup:
            problems.append(f"{loc} keyword repeats name/subtitle: {sorted(dup)}")
    return problems


def main() -> None:
    probs = validate()
    for loc, d in ASO.items():
        print(f"{loc:8} name {len(d['name']):>2}  sub {len(d['subtitle']):>2}  kw {len(d['keywords']):>3}  promo {len(d['promo']):>3}")
    if probs:
        raise SystemExit("\n".join(probs))
    out = Path(__file__).resolve().parents[1] / "metadata" / "1.1.2"
    out.mkdir(parents=True, exist_ok=True)
    lines = ["# PomoTask 1.1.2 — App Store listing (ASO)", "",
             "Generated by `scripts/aso_1_1_2.py`. Name changes ship with the next version; subtitle/keywords too.", ""]
    for loc, d in ASO.items():
        lines += [f"## {loc}", "", f"- **Name:** `{d['name']}`", f"- **Subtitle:** `{d['subtitle']}`",
                  f"- **Keywords:** `{d['keywords']}`", f"- **Promotional text:** {d['promo']}", ""]
    (out / "ASO.md").write_text("\n".join(lines), encoding="utf-8")
    print("wrote", out / "ASO.md")


if __name__ == "__main__":
    main()
