#!/usr/bin/env python3
"""
scripts/preview.py — 把 LuCI 主题资源组装成可直接用浏览器打开的静态预览。

用法: python3 scripts/preview.py [out_dir]
默认输出到 dist/preview/。
"""
from __future__ import annotations

import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "luci/htdocs/luci-static/aether"
OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / "dist/preview"

CSS = '<link rel="stylesheet" href="/luci-static/aether/css/aether.css">'
SPRITE = (
    '<object id="ae-sprite" type="image/svg+xml" '
    'data="/luci-static/aether/icons/lucide.svg" style="display:none"></object>'
)

SIDEBAR = """\
<aside class="ae-sidebar">
  <div class="ae-sidebar__brand">
    <img src="/luci-static/aether/img/logo.svg" alt="" width="28" height="28">
    <strong>Aether</strong>
  </div>
  <nav class="ae-sidebar__nav">
    <a class="ae-sidebar__link is-active" href="#">Dashboard</a>
    <a class="ae-sidebar__link" href="#">Network</a>
    <a class="ae-sidebar__link" href="#">Wireless</a>
    <a class="ae-sidebar__link" href="#">VPN</a>
    <a class="ae-sidebar__link" href="#">Settings</a>
  </nav>
</aside>"""

DASHBOARD = """\
<div class="ae-shell" data-sidebar="expanded">
__SIDEBAR__
  <main class="ae-main">
    <header class="ae-topbar">
      <h1>Dashboard</h1>
      <span class="ae-pill ae-pill--ok">All systems normal</span>
    </header>
    <section class="ae-grid ae-grid--cards">
      <article class="ae-card"><h3>CPU</h3><div class="ae-stat__value">12<span class="ae-mute">%</span></div>
        <div class="ae-progress ae-progress--sm"><div class="ae-progress__fill" style="width:12%"></div></div></article>
      <article class="ae-card"><h3>Memory</h3><div class="ae-stat__value">312<span class="ae-mute">MB / 1GB</span></div>
        <div class="ae-progress ae-progress--sm"><div class="ae-progress__fill" style="width:31%"></div></div></article>
      <article class="ae-card"><h3>Temperature</h3><div class="ae-stat__value">47.2<span class="ae-mute">°C</span></div></article>
      <article class="ae-card"><h3>Disk</h3><div class="ae-stat__value">12.8<span class="ae-mute">GB / 32GB</span></div>
        <div class="ae-progress ae-progress--sm"><div class="ae-progress__fill" style="width:38%"></div></div></article>
      <article class="ae-card ae-card--wide"><h3>WAN</h3>
        <div class="ae-stat__value">124.6<span class="ae-mute">Mb/s ↓</span></div>
        <div class="ae-stat__value">38.2<span class="ae-mute">Mb/s ↑</span></div></article>
      <article class="ae-card ae-card--wide"><h3>Clients</h3>
        <div class="ae-stat__value">19<span class="ae-mute">connected</span></div></article>
    </section>
  </main>
</div>"""

SETTINGS = """\
<div class="ae-shell" data-sidebar="expanded">
__SIDEBAR__
  <main class="ae-main">
    <header class="ae-topbar"><h1>Aether Theme</h1></header>
    <section class="ae-card">
      <h3>Appearance</h3>
      <div class="ae-row">
        <div class="ae-field"><label>Theme</label>
          <select class="ae-input"><option>Auto</option><option>Light</option><option selected>Dark</option><option>High contrast</option></select></div>
        <div class="ae-field"><label>Density</label>
          <select class="ae-input"><option>Comfortable</option><option>Compact</option></select></div>
      </div>
    </section>
    <section class="ae-card">
      <h3>Primary color</h3>
      <div class="ae-row">
        <button class="ae-color-swatch is-active" style="background:#0A84FF" aria-label="Apple Blue"></button>
        <button class="ae-color-swatch" style="background:#5856D6" aria-label="Indigo"></button>
        <button class="ae-color-swatch" style="background:#34C759" aria-label="Green"></button>
        <button class="ae-color-swatch" style="background:#FF9500" aria-label="Orange"></button>
        <button class="ae-color-swatch" style="background:#FF2D55" aria-label="Pink"></button>
      </div>
    </section>
  </main>
</div>"""

LOGIN = """\
<main class="ae-login">
  <div class="ae-login__card">
    <img src="/luci-static/aether/img/logo.svg" alt="" width="56" height="56">
    <h1 class="ae-login__title">Aether</h1>
    <p class="ae-login__sub">OpenWrt 25.12 · LuCI Theme</p>
    <label class="ae-field"><span>Password</span><input type="password" value="••••••••"></label>
    <button class="ae-btn ae-btn--primary ae-btn--lg">Sign in</button>
    <p class="ae-login__hint">Press <kbd>Enter</kbd> to continue</p>
  </div>
</main>"""

TEMPLATE = """<!doctype html>
<html lang="en" data-theme="{theme}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Aether — {page} ({theme})</title>
{css}
{sprite}
<style>body{{margin:0;background:{bg};color:{fg};font-family:Inter,system-ui,-apple-system,sans-serif;}}</style>
</head>
<body class="ae-theme">
{body}
</body>
</html>
"""


def main() -> int:
    if OUT.exists():
        shutil.rmtree(OUT)
    OUT.mkdir(parents=True)
    (OUT / "luci-static/aether").mkdir(parents=True)
    shutil.copytree(ASSETS, OUT / "luci-static/aether", dirs_exist_ok=True)

    pages = {
        "login": LOGIN,
        "dashboard": DASHBOARD.replace("__SIDEBAR__", SIDEBAR),
        "settings": SETTINGS.replace("__SIDEBAR__", SIDEBAR),
    }

    themes = {
        "dark": ("#0B0B0F", "#fff"),
        "light": ("#F7F7FA", "#0B0B0F"),
    }

    for theme, (bg, fg) in themes.items():
        for page, body in pages.items():
            html = TEMPLATE.format(
                theme=theme, page=page, css=CSS, sprite=SPRITE, bg=bg, fg=fg, body=body
            )
            (OUT / f"{page}-{theme}.html").write_text(html, encoding="utf-8")

    print(f"Preview generated at: {OUT}")
    for p in sorted(OUT.iterdir()):
        print("  " + p.name)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())