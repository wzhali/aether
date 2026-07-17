# Screenshots

Aether ships with SVG placeholders at the following resolutions. Replace each
with a real screenshot from a target device when you cut a release.

| File | Size | Theme | Description |
| --- | --- | --- | --- |
| `screenshots/login-light.svg` | 1440×900 | light  | Login page in light mode |
| `screenshots/login-dark.svg`  | 1440×900 | dark   | Login page in dark mode |
| `screenshots/dashboard-light.svg` | 1440×900 | light | Default dashboard, light |
| `screenshots/dashboard-dark.svg`  | 1440×900 | dark  | Default dashboard, dark |

## Capture workflow

```bash
# Headless Chromium at 1440x900
chromium --headless --disable-gpu --hide-scrollbars \
  --window-size=1440,900 \
  --screenshot=/tmp/ae.png \
  http://router.lan/cgi-bin/luci/admin/status/overview
```

Then post-process with `cwebp -q 80 ae.png -o screenshots/dashboard-light.webp`.