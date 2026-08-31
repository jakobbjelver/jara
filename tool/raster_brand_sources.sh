#!/usr/bin/env bash
# Rasterize the JARA brand SVGs (source of truth) to high-res PNGs consumed by
# tool/generate_brand_assets.py. Uses cairosvg (transparency + gradients), so
# the mark-only emblem keeps a transparent background.
set -euo pipefail
cd "$(dirname "$0")/../brand/source"

# cairosvg needs Homebrew's cairo dylib; ensure it's loadable.
CAIRO_LIB_DIR="$(brew --prefix cairo 2>/dev/null)/lib"
export DYLD_LIBRARY_PATH="$CAIRO_LIB_DIR:${DYLD_LIBRARY_PATH:-}"

python3 - <<'PY'
import cairosvg
SIZE = 1536
for name in ("jara-icon-square", "jara-icon-rounded", "jara-emblem"):
    cairosvg.svg2png(url=f"{name}.svg", write_to=f"{name}.png",
                     output_width=SIZE, output_height=SIZE)
    print(f"rasterized {name}.svg -> {name}.png ({SIZE}px, alpha-preserving)")
print("done. re-run: python3 tool/generate_brand_assets.py")
PY