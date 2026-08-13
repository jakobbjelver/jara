#!/usr/bin/env python3
"""JARA brand asset generator — deterministic, one command, no manual exports.

Renders the JARA Stride mark (open-loop run-glyph, see .hermes/brand/BRAND.md)
to every required platform asset and stages them under brand/generated/.
Assets are NOT wired into the app until the brand guide is approved
(PLAN-002 §1.3 gate).

Usage:
    python3 tool/generate_brand_assets.py            # all assets
    python3 tool/generate_brand_assets.py --preview  # preview PNG only
"""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "brand" / "generated"

# ── Brand tokens (keep in sync with .hermes/brand/BRAND.md) ──────────────
INK = (26, 26, 28)            # #1A1A1C
SURFACE_INVERSE = (38, 38, 43)  # #26262B
MARK_ON_INVERSE = (232, 232, 234)  # #E8E8EA
ACCENT = (78, 127, 224)       # #4E7FE0 JARA Blue

# ── Mark geometry (relative to canvas size 1.0, BRAND.md §2) ────────────
STROKE = 0.13
STEM_TOP = (0.64, 0.18)
STEM_BOTTOM = (0.64, 0.68)          # hook arc starts exactly here
HOOK_CENTER = (0.44, 0.68)
HOOK_RADIUS = 0.20
HOOK_START_DEG = 0.0                # 3 o'clock (stem bottom), clockwise
HOOK_END_DEG = 180.0                # 9 o'clock — half circle sweeping under
DOT_CENTER = (0.46, 0.44)           # the runner (reads as lowercase-j dot)
DOT_RADIUS = 0.075


def draw_mark(draw: ImageDraw.ImageDraw, size: int, color, accent: bool = False) -> None:
    """Draw the stride mark centered on a square canvas of `size` px.

    All geometry is relative to `size`; render at a supersampled size and
    downscale for smooth edges."""
    s = size
    stroke = max(2, int(round(s * STROKE)))
    fill = ACCENT if accent else color

    # Stem — the stride, planted and solid.
    draw.line(
        (STEM_TOP[0] * s, STEM_TOP[1] * s, STEM_BOTTOM[0] * s, STEM_BOTTOM[1] * s),
        fill=fill,
        width=stroke,
    )

    # Hook — the track's 180° turn, sweeping under the stem.
    cx, cy = HOOK_CENTER[0] * s, HOOK_CENTER[1] * s
    r = HOOK_RADIUS * s
    bbox = (cx - r, cy - r, cx + r, cy + r)
    draw.arc(bbox, start=HOOK_START_DEG, end=HOOK_END_DEG, fill=fill, width=stroke)

    # Runner dot — motion on the path.
    dx, dy = DOT_CENTER[0] * s, DOT_CENTER[1] * s
    dr = DOT_RADIUS * s
    draw.ellipse((dx - dr, dy - dr, dx + dr, dy + dr), fill=fill)


def render_mark(size: int, background=None, color=MARK_ON_INVERSE,
                accent: bool = False, supersample: int = 4) -> Image.Image:
    """Render the mark at `size` px with optional background, supersampled."""
    big = size * supersample
    if background is None:
        img = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    else:
        img = Image.new("RGBA", (big, big), (*background, 255))
    draw = ImageDraw.Draw(img)
    draw_mark(draw, big, color, accent=accent)
    return img.resize((size, size), Image.LANCZOS)


# ── iOS app icon set ─────────────────────────────────────────────────────
IOS_ICONS = [
    ("Icon-App-20x20@1x.png", 20), ("Icon-App-20x20@2x.png", 40),
    ("Icon-App-20x20@3x.png", 60), ("Icon-App-29x29@1x.png", 29),
    ("Icon-App-29x29@2x.png", 58), ("Icon-App-29x29@3x.png", 87),
    ("Icon-App-40x40@1x.png", 40), ("Icon-App-40x40@2x.png", 80),
    ("Icon-App-40x40@3x.png", 120), ("Icon-App-60x60@2x.png", 120),
    ("Icon-App-60x60@3x.png", 180), ("Icon-App-76x76@1x.png", 76),
    ("Icon-App-76x76@2x.png", 152), ("Icon-App-83.5x83.5@2x.png", 167),
    ("Icon-App-1024x1024@1x.png", 1024),
]

# ── Android mipmaps ──────────────────────────────────────────────────────
ANDROID_MIPMAPS = [("mdpi", 48), ("hdpi", 72), ("xhdpi", 96),
                   ("xxhdpi", 144), ("xxxhdpi", 192)]

# ── iOS splash (centered mark on neutral background) ────────────────────
IOS_SPLASHES = [("LaunchImage.png", (375, 667)),
                ("LaunchImage@2x.png", (750, 1334)),
                ("LaunchImage@3x.png", (1242, 2208))]

# ── Android launch backgrounds ──────────────────────────────────────────
ANDROID_LAUNCH = [("drawable-mdpi", (480, 800)), ("drawable-hdpi", (720, 1280)),
                  ("drawable-xhdpi", (960, 1600)), ("drawable-xxhdpi", (1280, 1920)),
                  ("drawable-xxxhdpi", (1600, 2560))]


def render_splash(width: int, height: int, color=MARK_ON_INVERSE) -> Image.Image:
    """Splash: neutral surface + centered mark, sized by min dimension."""
    img = Image.new("RGBA", (width, height), (*SURFACE_INVERSE, 255))
    mark_size = int(min(width, height) * 0.34)
    mark = render_mark(mark_size, background=None, color=color)
    img.alpha_composite(mark, ((width - mark_size) // 2, (height - mark_size) // 2))
    return img.convert("RGB")


def ios_contents_json() -> dict:
    """Contents.json for the generated AppIcon.appiconset."""
    images = []
    for filename, size in IOS_ICONS:
        parts = filename.replace(".png", "").split("@")
        scale = parts[1].rstrip("x") if len(parts) > 1 else "1x"
        dim = float(parts[0].rsplit("x", 1)[1])
        images.append({
            "filename": filename,
            "idiom": "ios-marketing" if "1024" in filename else "iphone",
            "scale": scale,
            "size": f"{dim:g}x{dim:g}",
        })
    return {"images": images, "info": {"author": "xcode", "version": 1}}


def generate_all() -> list[Path]:
    written: list[Path] = []

    # iOS app icon set
    ios_dir = OUT / "ios" / "AppIcon.appiconset"
    ios_dir.mkdir(parents=True, exist_ok=True)
    for filename, size in IOS_ICONS:
        render_mark(size, background=SURFACE_INVERSE).save(ios_dir / filename)
        written.append(ios_dir / filename)
    (ios_dir / "Contents.json").write_text(json.dumps(ios_contents_json(), indent=2))
    written.append(ios_dir / "Contents.json")

    # Android mipmaps
    for density, size in ANDROID_MIPMAPS:
        d = OUT / "android" / f"mipmap-{density}"
        d.mkdir(parents=True, exist_ok=True)
        p = d / "ic_launcher.png"
        render_mark(size, background=SURFACE_INVERSE).save(p)
        written.append(p)

    # iOS splash
    for filename, (w, h) in IOS_SPLASHES:
        p = OUT / "ios" / filename
        p.parent.mkdir(parents=True, exist_ok=True)
        render_splash(w, h).save(p)
        written.append(p)

    # Android launch backgrounds + 12-style icon (reuse mipmap)
    for density, (w, h) in ANDROID_LAUNCH:
        d = OUT / "android" / density
        d.mkdir(parents=True, exist_ok=True)
        p = d / "launch_background.png"
        render_splash(w, h).save(p)
        written.append(p)

    # Store icon + web assets
    store = OUT / "store"
    store.mkdir(parents=True, exist_ok=True)
    p = store / "icon-512.png"
    render_mark(512, background=SURFACE_INVERSE).save(p)
    written.append(p)

    web = OUT / "web"
    web.mkdir(parents=True, exist_ok=True)
    for name, size in [("favicon-32.png", 32), ("favicon-180.png", 180)]:
        p = web / name
        render_mark(size, background=SURFACE_INVERSE).save(p)
        written.append(p)
    social = render_splash(1200, 630, color=MARK_ON_INVERSE)
    social.save(web / "social-preview.png")
    written.append(web / "social-preview.png")

    return written


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--preview", action="store_true",
                        help="write previews next to the script and exit")
    args = parser.parse_args()

    if args.preview:
        (ROOT / "brand").mkdir(parents=True, exist_ok=True)
        render_mark(512, background=SURFACE_INVERSE).save(
            ROOT / "brand" / "preview-mark-dark.png")
        render_mark(512, background=(255, 255, 255), color=INK).save(
            ROOT / "brand" / "preview-mark-light.png")
        render_mark(512, background=SURFACE_INVERSE, accent=True).save(
            ROOT / "brand" / "preview-mark-accent.png")
        print("previews written to brand/preview-mark-*.png")
        return

    written = generate_all()
    for p in written:
        print(f"  {p.relative_to(ROOT)}")
    print(f"\n{len(written)} assets staged under {OUT.relative_to(ROOT)}/")


if __name__ == "__main__":
    main()
