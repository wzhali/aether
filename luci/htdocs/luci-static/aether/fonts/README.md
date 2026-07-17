# Aether — Fonts

Aether bundles two system-friendly font families via `@font-face`:

- **Inter** — UI primary face (Regular / Medium / SemiBold)
- **JetBrains Mono** — used in the terminal, monospaced cells, code

The repository does NOT ship the actual font binaries because of their
licensing weight. To finalise the build:

1. Download `Inter-Regular.woff2`, `Inter-Medium.woff2`,
   `Inter-SemiBold.woff2` from <https://rsms.me/inter/>.
2. Download `JetBrainsMono-Regular.woff2` from
   <https://github.com/JetBrains/JetBrainsMono/releases>.
3. Place the binaries into this directory.
4. Add the `@font-face` declarations below to `css/base.css`
   (kept here as a maintenance reminder).

```css
@font-face {
  font-family: "Inter";
  font-weight: 400;
  font-display: swap;
  src: url("../fonts/Inter-Regular.woff2") format("woff2");
}
@font-face {
  font-family: "Inter";
  font-weight: 500;
  font-display: swap;
  src: url("../fonts/Inter-Medium.woff2") format("woff2");
}
@font-face {
  font-family: "Inter";
  font-weight: 600;
  font-display: swap;
  src: url("../fonts/Inter-SemiBold.woff2") format("woff2");
}
@font-face {
  font-family: "JetBrains Mono";
  font-weight: 400;
  font-display: swap;
  src: url("../fonts/JetBrainsMono-Regular.woff2") format("woff2");
}
```

If the binaries are unavailable, Aether falls back gracefully to
`-apple-system / BlinkMacSystemFont / Segoe UI` on the host OS.