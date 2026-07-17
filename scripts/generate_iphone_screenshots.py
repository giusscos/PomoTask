#!/usr/bin/env python3
"""
Compose PomoTask App Store iPhone marketing screenshots.

Uses the half-phone device frame + in-app captures to produce 1290×2796 PNGs
with Pattern A / B / C layouts from metadata/1.1.0/SCREENSHOTS_PROMPT.md.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]
SHOTS = ROOT / "metadata" / "1.1.0" / "screenshots"
ASSETS = SHOTS / "assets"
FRAMES = ASSETS / "frames"
CAPTURES = ASSETS / "captures"
OUT = SHOTS / "out"

# App Store Connect — iPhone 6.7"
CANVAS_W, CANVAS_H = 1290, 2796

TOMATO = (219, 36, 36, 255)  # #DB2424
LIGHT_CANVAS = (250, 247, 246, 255)  # #FAF7F6
WHITE = (255, 255, 255, 255)
DARK_CANVAS = (20, 20, 20, 255)  # #141414
TEXT_DARK = (17, 17, 17, 255)
TEXT_SECONDARY = (92, 92, 92, 255)
TEXT_LIGHT = (245, 245, 245, 255)
TEXT_LIGHT_SECONDARY = (180, 180, 180, 255)

FONT_DISPLAY_HEAVY = "/Library/Fonts/SF-Pro-Display-Heavy.otf"
FONT_TEXT_MEDIUM = "/Library/Fonts/SF-Pro-Text-Medium.otf"


@dataclass(frozen=True)
class Slide:
    id: str
    capture: str
    pattern: str  # a | b | c
    headline: str
    accent: str
    subhead: str


# en-US only for now — extend COPY later for locales
SLIDES: list[Slide] = [
    Slide(
        id="01-hero",
        capture="01-hero.png",
        pattern="c",
        headline="Find your focus length",
        accent="focus",
        subhead="Start short. Grow with flow.",
    ),
    Slide(
        id="04-stats",
        capture="04-stats.png",
        pattern="a",
        headline="See your focus grow",
        accent="grow",
        subhead="Streaks, week totals, tomato splash days.",
    ),
    Slide(
        id="05-classic",
        capture="05-classic.png",
        pattern="b",
        headline="Classic Pomodoro, your way",
        accent="Pomodoro",
        subhead="Custom focus, breaks, and repetitions.",
    ),
]


def load_font(path: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(path, size=size)


def prepare_frame(path: Path) -> tuple[Image.Image, tuple[int, int, int, int]]:
    """Return frame with screen punched transparent + screen bbox (l,t,r,b)."""
    frame = Image.open(path).convert("RGBA")
    w, h = frame.size
    px = frame.load()

    # Screen = near-black opaque pixels
    mask = Image.new("L", (w, h), 0)
    mp = mask.load()
    min_x, min_y, max_x, max_y = w, h, 0, 0
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a > 180 and (r + g + b) < 45:
                mp[x, y] = 255
                min_x = min(min_x, x)
                min_y = min(min_y, y)
                max_x = max(max_x, x)
                max_y = max(max_y, y)
                # Punch screen hole
                px[x, y] = (0, 0, 0, 0)

    # Soften hole edge slightly so capture doesn't hard-clip against bezel
    return frame, (min_x, min_y, max_x + 1, max_y + 1)


def cover_crop(img: Image.Image, tw: int, th: int, *, align_top: bool = True) -> Image.Image:
    """Scale to cover target box. Top-align for half-phone frames so app chrome stays visible."""
    sw, sh = img.size
    scale = max(tw / sw, th / sh)
    nw, nh = int(sw * scale + 0.5), int(sh * scale + 0.5)
    resized = img.resize((nw, nh), Image.Resampling.LANCZOS)
    left = (nw - tw) // 2
    if align_top:
        top = 0
    else:
        top = (nh - th) // 2
    return resized.crop((left, top, left + tw, top + th))


def compose_device(
    capture: Image.Image,
    frame: Image.Image,
    screen: tuple[int, int, int, int],
    target_width: int,
) -> Image.Image:
    """Build framed device at target_width (keeps frame aspect)."""
    fw, fh = frame.size
    scale = target_width / fw
    tw, th = target_width, int(fh * scale + 0.5)

    sl, st, sr, sb = screen
    sw, sh = sr - sl, sb - st

    device = Image.new("RGBA", (fw, fh), (0, 0, 0, 0))
    screen_img = cover_crop(capture.convert("RGBA"), sw, sh)

    # Rounded clip approximating display corners
    radius = int(min(sw, sh) * 0.08)
    clip = Image.new("L", (sw, sh), 0)
    ImageDraw.Draw(clip).rounded_rectangle((0, 0, sw - 1, sh - 1), radius=radius, fill=255)
    rounded = Image.new("RGBA", (sw, sh), (0, 0, 0, 0))
    rounded.paste(screen_img, (0, 0))
    rounded.putalpha(clip)
    device.paste(rounded, (sl, st), rounded)
    device.alpha_composite(frame)

    return device.resize((tw, th), Image.Resampling.LANCZOS)


def draw_shadow(canvas: Image.Image, box: tuple[int, int, int, int], radius: int = 40, opacity: int = 90) -> None:
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(shadow)
    d.rounded_rectangle(box, radius=radius, fill=(0, 0, 0, opacity))
    shadow = shadow.filter(ImageFilter.GaussianBlur(36))
    canvas.alpha_composite(shadow)


def split_accent(headline: str, accent: str) -> tuple[str, str, str]:
    idx = headline.find(accent)
    if idx < 0:
        return headline, "", ""
    return headline[:idx], accent, headline[idx + len(accent) :]


def wrap_words(text: str, font: ImageFont.ImageFont, max_width: int, draw: ImageDraw.ImageDraw) -> list[str]:
    words = text.split()
    if not words:
        return []
    lines: list[str] = []
    current = words[0]
    for word in words[1:]:
        trial = f"{current} {word}"
        if draw.textlength(trial, font=font) <= max_width:
            current = trial
        else:
            lines.append(current)
            current = word
    lines.append(current)
    return lines


def draw_headline_centered(
    draw: ImageDraw.ImageDraw,
    cy: int,
    headline: str,
    accent: str,
    font: ImageFont.ImageFont,
    accent_font: ImageFont.ImageFont,
    max_width: int,
    fill,
    accent_fill,
) -> int:
    """Draw multi-line centered headline with one accent span. Returns bottom y."""
    before, acc, after = split_accent(headline, accent)
    # Prefer keeping accent on same line as surrounding words when possible
    parts = [p for p in (before, acc, after) if p is not None]
    # Simple approach: wrap full string, then color accent occurrences when drawing line-by-line
    lines = wrap_words(headline, font, max_width, draw)
    line_h = int(font.size * 1.12)
    total_h = line_h * len(lines)
    y = cy - total_h // 2
    for line in lines:
        draw_line_with_accent(draw, CANVAS_W // 2, y, line, accent, font, accent_font, fill, accent_fill, center=True)
        y += line_h
    return y


def draw_line_with_accent(
    draw: ImageDraw.ImageDraw,
    x: int,
    y: int,
    line: str,
    accent: str,
    font: ImageFont.ImageFont,
    accent_font: ImageFont.ImageFont,
    fill,
    accent_fill,
    center: bool = True,
    left: bool = False,
) -> None:
    if accent and accent in line:
        i = line.find(accent)
        segments = [
            (line[:i], font, fill),
            (accent, accent_font, accent_fill),
            (line[i + len(accent) :], font, fill),
        ]
    else:
        segments = [(line, font, fill)]

    widths = [draw.textlength(t, font=f) for t, f, _ in segments if t]
    total = sum(widths)
    if center:
        cx = x - total / 2
    elif left:
        cx = x
    else:
        cx = x - total / 2

    cursor = cx
    for text, fnt, color in segments:
        if not text:
            continue
        draw.text((cursor, y), text, font=fnt, fill=color)
        cursor += draw.textlength(text, font=fnt)


def draw_subhead_centered(draw: ImageDraw.ImageDraw, y: int, text: str, font: ImageFont.ImageFont, fill, max_width: int) -> int:
    lines = wrap_words(text, font, max_width, draw)
    line_h = int(font.size * 1.28)
    for line in lines:
        w = draw.textlength(line, font=font)
        draw.text(((CANVAS_W - w) / 2, y), line, font=font, fill=fill)
        y += line_h
    return y


def apply_bottom_fade(device: Image.Image, canvas_color: tuple[int, int, int, int], fade_start_ratio: float = 0.45) -> Image.Image:
    """Fade the lower portion of the device into the canvas color."""
    out = device.copy()
    w, h = out.size
    fade = Image.new("L", (w, h), 255)
    fd = ImageDraw.Draw(fade)
    start = int(h * fade_start_ratio)
    for y in range(start, h):
        t = (y - start) / max(1, h - start)
        # ease-in
        a = int(255 * (1 - t * t))
        fd.line([(0, y), (w, y)], fill=a)
    # Multiply alpha
    r, g, b, a = out.split()
    a = ImageChops_multiply(a, fade)
    out = Image.merge("RGBA", (r, g, b, a))

    # Also overlay soft gradient of canvas color for dissolve feel
    overlay = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    od = ImageDraw.Draw(overlay)
    for y in range(start, h):
        t = (y - start) / max(1, h - start)
        alpha = int(255 * (t**1.35))
        od.line([(0, y), (w, y)], fill=(*canvas_color[:3], alpha))
    out = Image.alpha_composite(out, overlay)
    return out


def ImageChops_multiply(a: Image.Image, b: Image.Image) -> Image.Image:
    from PIL import ImageChops

    return ImageChops.multiply(a, b)


def render_pattern_a(slide: Slide, device: Image.Image) -> Image.Image:
    canvas = Image.new("RGBA", (CANVAS_W, CANVAS_H), LIGHT_CANVAS)
    faded = apply_bottom_fade(device, LIGHT_CANVAS, fade_start_ratio=0.42)

    # Place device in upper area
    dw, dh = faded.size
    x = (CANVAS_W - dw) // 2
    y = 120
    draw_shadow(canvas, (x + 20, y + 40, x + dw - 20, y + int(dh * 0.85)), radius=80, opacity=55)
    canvas.alpha_composite(faded, (x, y))

    draw = ImageDraw.Draw(canvas)
    headline_font = load_font(FONT_DISPLAY_HEAVY, 78)
    accent_font = load_font(FONT_DISPLAY_HEAVY, 78)
    sub_font = load_font(FONT_TEXT_MEDIUM, 36)

    copy_top = int(CANVAS_H * 0.72)
    draw_headline_centered(
        draw,
        copy_top + 40,
        slide.headline,
        slide.accent,
        headline_font,
        accent_font,
        max_width=CANVAS_W - 140,
        fill=TEXT_DARK,
        accent_fill=TOMATO,
    )
    draw_subhead_centered(draw, copy_top + 160, slide.subhead, sub_font, TEXT_SECONDARY, CANVAS_W - 200)
    return canvas


def render_pattern_b(slide: Slide, device: Image.Image) -> Image.Image:
    canvas = Image.new("RGBA", (CANVAS_W, CANVAS_H), LIGHT_CANVAS)
    draw = ImageDraw.Draw(canvas)

    headline_font = load_font(FONT_DISPLAY_HEAVY, 82)
    accent_font = load_font(FONT_DISPLAY_HEAVY, 82)
    sub_font = load_font(FONT_TEXT_MEDIUM, 36)

    # Headline near top
    y = 220
    bottom = draw_headline_centered(
        draw,
        y + 90,
        slide.headline,
        slide.accent,
        headline_font,
        accent_font,
        max_width=CANVAS_W - 120,
        fill=TEXT_DARK,
        accent_fill=TOMATO,
    )
    draw_subhead_centered(draw, bottom + 36, slide.subhead, sub_font, TEXT_SECONDARY, CANVAS_W - 180)

    # Subtle accent guide line
    mid_y = bottom + 130
    draw.line((CANVAS_W // 2 - 40, mid_y, CANVAS_W // 2 + 40, mid_y), fill=(*TOMATO[:3], 140), width=3)

    faded = apply_bottom_fade(device, LIGHT_CANVAS, fade_start_ratio=0.55)
    dw, dh = faded.size
    x = (CANVAS_W - dw) // 2
    # Rise from bottom — show upper device, crop hanging off bottom a bit
    y_dev = CANVAS_H - int(dh * 0.78)
    draw_shadow(canvas, (x + 24, y_dev + 30, x + dw - 24, CANVAS_H - 40), radius=70, opacity=50)
    canvas.alpha_composite(faded, (x, y_dev))
    return canvas


def render_pattern_c(slide: Slide, device: Image.Image) -> Image.Image:
    canvas = Image.new("RGBA", (CANVAS_W, CANVAS_H), DARK_CANVAS)
    draw = ImageDraw.Draw(canvas)

    headline_font = load_font(FONT_DISPLAY_HEAVY, 80)
    accent_font = load_font(FONT_DISPLAY_HEAVY, 80)
    sub_font = load_font(FONT_TEXT_MEDIUM, 36)

    # Left-ish / centered statement at top
    y = 200
    bottom = draw_headline_centered(
        draw,
        y + 100,
        slide.headline,
        slide.accent,
        headline_font,
        accent_font,
        max_width=CANVAS_W - 140,
        fill=TEXT_LIGHT,
        accent_fill=TOMATO,
    )
    draw_subhead_centered(draw, bottom + 28, slide.subhead, sub_font, TEXT_LIGHT_SECONDARY, CANVAS_W - 200)

    faded = apply_bottom_fade(device, DARK_CANVAS, fade_start_ratio=0.50)
    dw, dh = faded.size
    x = (CANVAS_W - dw) // 2
    y_dev = int(CANVAS_H * 0.38)
    draw_shadow(canvas, (x + 10, y_dev + 20, x + dw - 10, y_dev + int(dh * 0.9)), radius=90, opacity=140)
    canvas.alpha_composite(faded, (x, y_dev))
    return canvas


def render_slide(slide: Slide, frame: Image.Image, screen: tuple[int, int, int, int], locale: str) -> Path:
    capture_path = CAPTURES / slide.capture
    if not capture_path.exists():
        raise FileNotFoundError(f"Missing capture: {capture_path}")

    capture = Image.open(capture_path)
    # Device ~82% of canvas width for premium presence
    device = compose_device(capture, frame, screen, target_width=int(CANVAS_W * 0.86))

    if slide.pattern == "a":
        art = render_pattern_a(slide, device)
    elif slide.pattern == "b":
        art = render_pattern_b(slide, device)
    else:
        art = render_pattern_c(slide, device)

    out_dir = OUT / locale / "iphone"
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / f"{slide.id}.png"
    art.convert("RGB").save(out_path, "PNG", optimize=True)
    return out_path


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate PomoTask iPhone App Store screenshots")
    parser.add_argument("--locale", default="en-US")
    parser.add_argument("--only", nargs="*", help="Optional slide ids, e.g. 01-hero 04-stats")
    args = parser.parse_args()

    frame_path = FRAMES / "iphone-17-pro-silver.png"
    print(f"Preparing frame: {frame_path}")
    frame, screen = prepare_frame(frame_path)
    print(f"Screen bbox: {screen}")

    # Cache punched frame for HTML preview assets
    punched = FRAMES / "iphone-17-pro-silver-punched.png"
    frame.save(punched)

    slides = SLIDES
    if args.only:
        wanted = set(args.only)
        slides = [s for s in SLIDES if s.id in wanted]

    for slide in slides:
        path = render_slide(slide, frame, screen, args.locale)
        print(f"Wrote {path}")


if __name__ == "__main__":
    main()
