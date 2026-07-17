# Changelog

All notable changes to Aether are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.0.0] — 2026-07-17

### Added
- Initial public release.
- Full design tokens (light, dark, high contrast, auto).
- Components: button, form, card, table, alert, progress, chart,
  tabs, dropdown, modal, terminal, nav, breadcrumb, notification, search.
- Dashboard widgets: CPU, Memory, Temperature, Disk, WAN, Topology,
  IPv4, IPv6, VPN, Wireless, Clients, Updates, Uptime.
- Login page, sidebar, topbar, footer, breadcrumbs.
- In-theme Settings page with primary, accent, radius, density, glass,
  blur, font scale, sidebar style, wallpaper, motion, widgets.
- Lucide-compatible SVG sprite (32 icons).
- ES2022 JavaScript modules — `theme.js`, `dashboard.js`, `nav.js`,
  `aether.js`. ~12 KB total.
- CBI forms for LuCI uci persistence.
- GitHub Actions CI build and Release workflows.
- Apache-2.0 license.

### Notes
- Fonts are referenced but not bundled; see `fonts/README.md`.
- Screenshots are placeholders; see `screenshots/README.md`.