# Aether — OpenWrt 25.12 LuCI Theme (Ultimate Edition)

> A premium, enterprise-grade LuCI theme for OpenWrt 25.12 Stable, designed to feel
> like an appliance worth over $1000. Built on design tokens, modular widgets and
> complete offline operation.

![status](https://img.shields.io/badge/OpenWrt-25.12-00B5E2?logo=openwrt)
![license](https://img.shields.io/badge/license-Apache--2.0-blue)
![luci](https://img.shields.io/badge/LuCI-25.12-green)

## Highlights

- **Vision + Material + Fluent inspired visuals** — calm neutrals, soft shadows,
  layered surfaces, no gaming RGB.
- **Full Design Tokens** — every color, spacing, radius, duration and shadow
  exposed as CSS variables. Light / Dark / High Contrast themes included,
  `auto` defers to browser preference.
- **Complete component library** — buttons, forms, switches, sliders, tables,
  cards, tabs, dropdowns, modals, alerts, toasts, progress, charts, breadcrumbs,
  notifications, search, terminal.
- **Modular dashboard widgets** — CPU, Memory, Temperature, Disk, WAN Traffic,
  Network Topology, IPv4, IPv6, VPN, Wireless, Clients, Updates, Uptime.
- **In-theme Settings page** — change primary color, accent color, sidebar
  style, card radius, compact mode, glass effect, blur strength, font scale,
  animation speed, wallpaper, dark mode, dashboard widgets.
- **A11y** — WCAG AA contrast, visible focus rings, full keyboard navigation,
  `prefers-reduced-motion` honoured, screen-reader labels.
- **Performance** — zero runtime dependencies, ~12 KB JS total, all SVG icons
  from a single sprite, no external CDN.

## Supported platforms

| Architecture | Status |
| --- | --- |
| x86_64 | Supported |
| ARM64 | Supported |
| MediaTek (mt7621, mt7622, mt7981, mt7986, mt7988) | Supported |
| Qualcomm (ipq40xx, ipq807x, ipq60xx) | Supported |
| Rockchip (rk3328, rk3399, rk3568) | Supported |
| Any other architecture supported by OpenWrt 25.12 | Supported |

## Installation

### Via the OpenWrt 25.12 SDK / Image Builder

```bash
git clone https://github.com/aether-luci/aether.git
cd aether
make package/luci-theme-aether/compile V=s
```

The resulting `.ipk` is placed under `bin/packages/<arch>/luci/`.

### Manual install on a running device

```bash
opkg install luci-theme-aether_1.0.0_all.ipk
/etc/init.d/rpcd restart
```

### Switching the active theme

1. Log in to LuCI.
2. Go to **System → System → Language and Style** and pick **aether**.
3. Hard refresh the browser to flush cached CSS (`Ctrl + Shift + R`).

## Project structure

```
theme-aether-luci/
├── Makefile
├── README.md
├── LICENSE
├── docs/
│   ├── ARCHITECTURE.md
│   ├── ROADMAP.md
│   └── CHANGELOG.md
├── .github/workflows/
│   ├── build.yml
│   └── release.yml
├── luci/
│   ├── Makefile
│   ├── manifests/base
│   ├── apk/APKBUILD
│   ├── uci-defaults/99-luci-theme-aether
│   ├── htdocs/luci-static/aether/
│   │   ├── theme.htm / header.htm / footer.htm
│   │   ├── css/         # tokens, base, layout, components, pages, vendor
│   │   ├── js/          # theme.js, dashboard.js, nav.js, aether.js
│   │   ├── fonts/       # README (binaries downloaded separately)
│   │   ├── icons/       # lucide.svg sprite
│   │   └── img/         # logo + wallpaper
│   ├── luasrc/
│   │   ├── view/themes/aether/    # sysauth, dashboard, settings
│   │   ├── model/cbi/aether/      # settings.lua, dashboard.lua
│   │   └── controller/aether.lua
└── screenshots/         # README + placeholders
```

## Development

### Prerequisites

- OpenWrt 25.12 SDK (or Image Builder for your target).
- `git`, `make`, `wget`, `unzip`, `file`.

### Build a single package

```bash
make package/luci-theme-aether/{clean,compile} V=s
```

### Build the entire firmware

Drop the cloned directory into `package/luci/` of an OpenWrt tree and run:

```bash
make menuconfig   # enable LuCI → Themes → aether
make -j$(nproc)
```

## Customisation

All runtime customisation lives in **System → Aether Theme**. Persisted values
are stored in `localStorage` for the browser session and (optionally) written
back to `/etc/config/aether` for cross-device consistency.

| Setting | Default | Range |
| --- | --- | --- |
| Theme | auto | auto / light / dark / hc |
| Density | comfortable | comfortable / compact |
| Primary color | `#0A84FF` | hex |
| Accent color | `#BF5AF2` | hex |
| Card radius | 12 px | 0 – 24 |
| Font scale | 1.00 | 0.85 – 1.40 |
| Glass effect | on | toggle |
| Blur strength | 24 px | 0 – 60 |
| Sidebar style | expanded | expanded / collapsed / overlay |
| Wallpaper | auto | none / auto / aurora / mesh |
| Motion | normal | normal / reduced |
| Widgets | all on | per widget |

## Accessibility

- All interactive elements have a visible `:focus-visible` outline.
- Tab order matches visual order; arrow keys navigate the sidebar.
- `prefers-reduced-motion` globally dampens transitions to 0ms.
- Text contrast meets WCAG AA (4.5:1 for body, 3:1 for large text).
- High Contrast theme meets WCAG AAA on body text.

## Security

- No inline JavaScript, no `eval`, no external CDN dependency.
- All SVGs are local and use `<use>` references — no XSS surface.
- All API calls go through LuCI's existing `rpcd` JSON-RPC endpoints.

## License

Apache-2.0 — see [LICENSE](./LICENSE).

## Contributing

PRs welcome. Please keep changes scoped, follow the existing naming convention
(`.ae-*` for components, BEM-style variants), and run a self-check against the
**Accessibility & Performance** checklist in `docs/ARCHITECTURE.md`.

## Acknowledgements

- [LuCI](https://github.com/openwrt/luci) — the LuCI framework.
- [Lucide](https://lucide.dev) — the icon set.
- [Inter](https://rsms.me/inter/) — UI typography.