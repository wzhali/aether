#!/usr/bin/env python3
"""
scripts/screenshot.py — 用 Playwright/Chromium 给静态预览截图。

用法:
    pip install playwright
    playwright install --with-deps chromium
    python3 scripts/screenshot.py [preview_dir] [out_dir]
"""
from __future__ import annotations

import asyncio
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PREVIEW = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / "dist/preview"
OUT = Path(sys.argv[2]) if len(sys.argv) > 2 else ROOT / "dist/screenshots"

VARIANTS = [
    ("login-dark", 1440, 900),
    ("login-light", 1440, 900),
    ("dashboard-dark", 1440, 900),
    ("dashboard-light", 1440, 900),
    ("settings-dark", 1440, 900),
    ("settings-light", 1440, 900),
    ("dashboard-dark", 1024, 768),  # tablet
    ("dashboard-dark", 390, 844),   # phone
]


async def shoot(page, html: Path, w: int, h: int, out: Path):
    await page.set_viewport_size({"width": w, "height": h})
    await page.goto(html.resolve().as_uri(), wait_until="networkidle")
    await page.wait_for_timeout(400)  # 让字体/动画稳定
    await page.screenshot(path=out, full_page=False)
    print(f"  {out.relative_to(OUT.parent)}  {w}x{h}")


async def main() -> int:
    try:
        from playwright.async_api import async_playwright
    except ImportError:
        print("Playwright not installed. Run:")
        print("  pip install playwright && playwright install --with-deps chromium")
        return 2

    OUT.mkdir(parents=True, exist_ok=True)
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        ctx = await browser.new_context(device_scale_factor=2)
        page = await ctx.new_page()
        for name, w, h in VARIANTS:
            html = PREVIEW / f"{name}.html"
            if not html.exists():
                print(f"  skip (missing) {html.name}")
                continue
            out = OUT / f"{name}-{w}x{h}.png"
            await shoot(page, html, w, h, out)
        await browser.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(asyncio.run(main()))