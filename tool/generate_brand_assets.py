#!/usr/bin/env python3
"""JARA brand asset generator — deterministic, one command, no manual exports.

Renders the JARA Stride mark (a bold geometric "J + A" monogram that also
reads as two legs mid-run, see .hermes/brand/BRAND.md) to every required
platform asset and stages them under brand/generated/.

The mark is drawn from a small set of parametric strokes (a Catmull-Rom
trailing J-bowl, a straight leading leg, and the A crossbar) at a uniform
stroke weight — no external geometry file, no manual exports.

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

# ── Mark geometry (the JARA Stride) ──────────────────────────────────────
# One A (two legs + crossbar) whose trailing leg sweeps into a tight J-bowl:
# the J letters; mid-stride runner (bent trailing leg, extended leading leg,
# hips at the apex). All coords normalized 0..1, uniform stroke width.
STROKE_W = 0.085

TRAILING_CTRL = [  # smooth J-bowl + the A's left leg, up to the apex
    (0.25, 0.58), (0.20, 0.68), (0.24, 0.80), (0.32, 0.84),
    (0.40, 0.79), (0.46, 0.67), (0.51, 0.52), (0.58, 0.18),
]
LEADING_LEG = [(0.58, 0.18), (0.71, 0.54), (0.81, 0.76)]  # A's right leg
CROSSBAR = [(0.515, 0.50), (0.695, 0.50)]                # the A crossbar


def catmull(pts, n=40):
    """Sample a Catmull-Rom spline through pts -> a dense polyline."""
    out = []
    if len(pts) == 2:
        return [pts[0], pts[1]]
    for i in range(len(pts) - 1):
        p0 = pts[i - 1] if i > 0 else pts[i]
        p1, p2 = pts[i], pts[i + 1]
        p3 = pts[i + 2] if i + 2 < len(pts) else pts[i + 1]
        for t in range(n):
            u = t / n
            u2, u3 = u * u, u * u * u
            x = 0.5 * ((2 * p1[0]) + (-p0[0] + p2[0]) * u
                       + (2 * p0[0] - 5 * p1[0] + 4 * p2[0] - p3[0]) * u2
                       + (-p0[0] + 3 * p1[0] - 3 * p2[0] + p3[0]) * u3)
            y = 0.5 * ((2 * p1[1]) + (-p0[1] + p2[1]) * u
                       + (2 * p0[1] - 5 * p1[1] + 4 * p2[1] - p3[1]) * u2
                       + (-p0[1] + 3 * p1[1] - 3 * p2[1] + p3[1]) * u3)
            out.append((x, y))
    out.append(pts[-1])
    return out


def _stroke(draw: ImageDraw.ImageDraw, size: int, color, pts, w=STROKE_W) -> None:
    """Draw one thick stroke (round caps) through normalized `pts`."""
    width = max(2, int(round(size * w)))
    draw.line([(x * size, y * size) for x, y in pts],
              fill=color, width=width, joint="curve")
    r = width // 2
    for x, y in (pts[0], pts[-1]):
        draw.ellipse([x * size - r, y * size - r,
                      x * size + r, y * size + r], fill=color)


def draw_mark(draw: ImageDraw.ImageDraw, size: int, color) -> None:
    """Draw the Stride mark on a square canvas of `size` px.

    `size` is the (already supersampled) render size; coords are normalized
    0..1 and scaled by `size`. Grayscale only."""
    _stroke(draw, size, color, catmull(TRAILING_CTRL))
    _stroke(draw, size, color, LEADING_LEG)
    _stroke(draw, size, color, CROSSBAR)


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