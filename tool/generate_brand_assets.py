#!/usr/bin/env python3
"""JARA brand asset generator — deterministic, one command, no manual exports.

Renders the JARA app icon (a glossy red "core-with-orbit" emblem) and the
mark-only emblem (for splash/launch) to every required platform asset. The
authoritative artwork is the SVGs in brand/source/ (jara-icon-square.svg,
jara-icon-rounded.svg, jara-emblem.svg), rasterized once to high-res PNGs at
1536px by tool/raster_brand_sources.sh. This script only scales those
canonical rasters — it never redraws the mark.

Usage:
    python3 tool/generate_brand_assets.py            # all assets
    python3 tool/generate_brand_assets.py --preview  # preview PNG only
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "brand" / "generated"
SRC = ROOT / "brand" / "source"

# ── Brand tokens (keep in sync with .hermes/brand/BRAND.md) ──────────────
BRAND_RED_DEEP = (196, 0, 30)       # #C4001E — splash / launch background
BRAND_RED = (230, 0, 43)            # #E6002B — primary brand red
BRAND_RED_BRIGHT = (255, 36, 64)    # #FF2440
HIGHLIGHT = (255, 240, 242)         # #FFF0F2 — sparkles / highlights

# Canonical rasters (rasterized from brand/source/*.svg at 1536px).
ICON_SQUARE = SRC / "jara-icon-square.png"    # full artwork, square
ICON_ROUNDED = SRC / "jara-icon-rounded.png"  # pre-masked app kit
EMBLEM = SRC / "jara-emblem.png"              # mark only, transparent


def _load(name: str) -> Image.Image:
    return Image.open(SRC / name).convert("RGBA")


def _fit(img: Image.Image, w: int, h: int) -> Image.Image:
    """Scale `img` to fit inside w×h, centered on a transparent canvas."""
    s = min(w / img.width, h / img.height)
    nw, nh = max(1, round(img.width * s)), max(1, round(img.height * s))
    r = img.resize((nw, nh), Image.LANCZOS)
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    out.alpha_composite(r, ((w - nw) // 2, (h - nh) // 2))
    return out


def _rgb(grad: str) -> Image.Image:
    """A flat brand-red splash surface."""
    img = Image.new("RGBA", (grad[0], grad[1]), (*BRAND_RED_DEEP, 255))
    return img


# ── iOS app icon (modern single-size format) ────────────────────────────
IOS_ICON_SIZE = 1024

# ── iOS splash: emblem-only, transparent; the storyboard paints the red bg ──
IOS_SPLASHES = [("LaunchImage.png", (168, 185)),
                ("LaunchImage@2x.png", (336, 370)),
                ("LaunchImage@3x.png", (504, 555))]

# ── Android mipmaps / launch images ──────────────────────────────────────
ANDROID_MIPMAPS = [("mdpi", 48), ("hdpi", 72), ("xhdpi", 96),
                   ("xxhdpi", 144), ("xxxhdpi", 192)]
ANDROID_LAUNCH_SIZES = {"mdpi": 288, "hdpi": 432, "xhdpi": 576,
                        "xxhdpi": 864, "xxxhdpi": 1152}
ANDROID_LAUNCH = [("drawable-mdpi", (480, 800)), ("drawable-hdpi", (720, 1280)),
                  ("drawable-xhdpi", (960, 1600)),
                  ("drawable-xxhdpi", (1280, 1920)),
                  ("drawable-xxxhdpi", (1600, 2560))]


def ios_contents_json() -> dict:
    """Contents.json for the single-size AppIcon.appiconset."""
    return {
        "images": [{
            "filename": "AppIcon.png",
            "idiom": "universal",
            "platform": "ios",
            "size": "1024x1024",
        }],
        "info": {"author": "xcode", "version": 1},
    }


def render_splash_surface(w: int, h: int) -> Image.Image:
    """Brand-red launch surface with the emblem centered."""
    img = _rgb((w, h))
    em = _load("jara-emblem.png")
    mark = _fit(em, int(min(w, h) * 0.62), int(min(w, h) * 0.62))
    img.alpha_composite(mark, ((w - mark.width) // 2, (h - mark.height) // 2))
    return img.convert("RGB")


def generate_all() -> list[Path]:
    written: list[Path] = []
    ic_sq = _load("jara-icon-square.png")
    ic_rnd = _load("jara-icon-rounded.png")
    em = _load("jara-emblem.png")

    # iOS app icon (single 1024 universal; display sizes derived at build)
    ios_dir = OUT / "ios" / "AppIcon.appiconset"
    ios_dir.mkdir(parents=True, exist_ok=True)
    p = ios_dir / "AppIcon.png"
    _fit(ic_rnd, IOS_ICON_SIZE, IOS_ICON_SIZE).save(p)
    written.append(p)
    (ios_dir / "Contents.json").write_text(json.dumps(ios_contents_json(), indent=2))
    written.append(ios_dir / "Contents.json")

    # iOS splash — emblem baked onto brand red, OPAQUE.
    # iOS composites legacy launch-screen images onto white, so a transparent
    # overlay would show a white box; baking the red surface avoids that.
    for filename, (w, h) in IOS_SPLASHES:
        p = OUT / "ios" / filename
        p.parent.mkdir(parents=True, exist_ok=True)
        canvas = Image.new("RGBA", (w, h), (*BRAND_RED_DEEP, 255))
        mark = _fit(em, int(min(w, h) * 0.92), int(min(w, h) * 0.92))
        canvas.alpha_composite(mark, ((w - mark.width) // 2, (h - mark.height) // 2))
        canvas.convert("RGB").save(p)
        written.append(p)

    # Android mipmaps: launcher icon (square) + launch_image (emblem)
    for density, size in ANDROID_MIPMAPS:
        d = OUT / "android" / f"mipmap-{density}"
        d.mkdir(parents=True, exist_ok=True)
        p = d / "ic_launcher.png"
        _fit(ic_sq, size, size).save(p)
        written.append(p)
        lp = d / "launch_image.png"
        _fit(em, ANDROID_LAUNCH_SIZES[density], ANDROID_LAUNCH_SIZES[density]).save(lp)
        written.append(lp)

    # Android launch backgrounds (composite; app splash uses the XML layer-list)
    for density, (w, h) in ANDROID_LAUNCH:
        d = OUT / "android" / density
        d.mkdir(parents=True, exist_ok=True)
        p = d / "launch_background.png"
        render_splash_surface(w, h).save(p)
        written.append(p)

    # Store icon + web assets
    store = OUT / "store"
    store.mkdir(parents=True, exist_ok=True)
    p = store / "icon-512.png"
    _fit(ic_sq, 512, 512).save(p)
    written.append(p)

    web = OUT / "web"
    web.mkdir(parents=True, exist_ok=True)
    for name, size in [("favicon-32.png", 32), ("favicon-180.png", 180)]:
        p = web / name
        _fit(ic_sq, size, size).save(p)
        written.append(p)
    social = render_splash_surface(1200, 630)
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
        _fit(_load("jara-icon-rounded.png"), 1024, 1024).save(
            ROOT / "brand" / "preview-icon.png")
        _fit(_load("jara-emblem.png"), 512, 512).save(
            ROOT / "brand" / "preview-emblem.png")
        print("previews written to brand/preview-icon.png, brand/preview-emblem.png")
        return

    written = generate_all()
    for p in written:
        print(f"  {p.relative_to(ROOT)}")
    print(f"\n{len(written)} assets staged under {OUT.relative_to(ROOT)}/")


if __name__ == "__main__":
    main()