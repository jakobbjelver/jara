#!/usr/bin/env python3
"""JARA brand asset generator — deterministic, one command, no manual exports.

Renders the JARA Swoosh mark (filled ribbon silhouette read as an S through
negative space, see .hermes/brand/BRAND.md) to every required platform asset
and stages them under brand/generated/.

The mark's polygon data is sourced from brand/swoosh_rings.json (normalized
0..1 coordinates, Douglas-Peucker-simplified trace of the approved sweep).

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

# ── Mark geometry ────────────────────────────────────────────────────────
# The JARA Swoosh: a family of filled closed paths in normalized (0..1)
# coordinates. One continuous fill reads as a dynamic, motion-forward sweep;
# the S is implied by the negative space. Grayscale only.
RINGS = json.loads((ROOT / "brand" / "swoosh_rings.json").read_text())


def draw_mark(draw: ImageDraw.ImageDraw, size: int, color) -> None:
    """Fill the Swoosh polygons on a square canvas of `size` px.

    `size` is the (already supersampled) render size; polygon coords are
    normalized 0..1 and scaled by `size`. Grayscale only."""
    for ring in RINGS:
        draw.polygon([(x * size, y * size) for x, y in ring], fill=color)


def render_mark(size: int, background=None, color=MARK_ON_INVERSE,
                supersample: int = 4) -> Image.Image:
    """Render the mark at `size` px with optional background, supersampled."""
    big = size * supersample
    if background is None:
        img = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    else:
        img = Image.new("RGBA", (big, big), (*background, 255))
    draw = ImageDraw.Draw(img)
    draw_mark(draw, big, color)
    return img.resize((size, size), Image.LANCZOS)


# ── iOS app icon (modern single-size format) ────────────────────────────
# Xcode/iOS 26 compile a single 1024 universal image; all display sizes are
# derived from it. The multi-image "iphone" appiconset format is dropped.
IOS_ICON_SIZE = 1024

# ── Android mipmaps ──────────────────────────────────────────────────────
ANDROID_MIPMAPS = [("mdpi", 48), ("hdpi", 72), ("xhdpi", 96),
                   ("xxhdpi", 144), ("xxxhdpi", 192)]

# ── iOS splash (mark-only, transparent — storyboard supplies the dark bg) ──
IOS_SPLASHES = [("LaunchImage.png", (168, 185)),
                ("LaunchImage@2x.png", (336, 370)),
                ("LaunchImage@3x.png", (504, 555))]

# ── Android launch backgrounds ───────────────────────────────────────────
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


def generate_all() -> list[Path]:
    written: list[Path] = []

    # iOS app icon (single 1024 universal; display sizes derived at build)
    ios_dir = OUT / "ios" / "AppIcon.appiconset"
    ios_dir.mkdir(parents=True, exist_ok=True)
    p = ios_dir / "AppIcon.png"
    render_mark(IOS_ICON_SIZE, background=SURFACE_INVERSE).save(p)
    written.append(p)
    (ios_dir / "Contents.json").write_text(json.dumps(ios_contents_json(), indent=2))
    written.append(ios_dir / "Contents.json")

    # Android mipmaps + launch image (mark on transparent, centered)
    launch_sizes = {"mdpi": 288, "hdpi": 432, "xhdpi": 576,
                    "xxhdpi": 864, "xxxhdpi": 1152}
    for density, size in ANDROID_MIPMAPS:
        d = OUT / "android" / f"mipmap-{density}"
        d.mkdir(parents=True, exist_ok=True)
        p = d / "ic_launcher.png"
        render_mark(size, background=SURFACE_INVERSE).save(p)
        written.append(p)
        lp = d / "launch_image.png"
        render_mark(launch_sizes[density], background=None,
                    color=MARK_ON_INVERSE).save(lp)
        written.append(lp)

    # iOS splash — mark only on transparent; the storyboard paints the
    # #26262B background.
    for filename, (w, h) in IOS_SPLASHES:
        p = OUT / "ios" / filename
        p.parent.mkdir(parents=True, exist_ok=True)
        render_mark(min(w, h), background=None,
                    color=MARK_ON_INVERSE).save(p)
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
        print("previews written to brand/preview-mark-*.png")
        return

    written = generate_all()
    for p in written:
        print(f"  {p.relative_to(ROOT)}")
    print(f"\n{len(written)} assets staged under {OUT.relative_to(ROOT)}/")


if __name__ == "__main__":
    main()