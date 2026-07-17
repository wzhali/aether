# Self-check checklist

Run these checks after every module.

## Compatibility

- [ ] Theme loads against `luci-base` 25.12.x without console errors.
- [ ] `theme.htm`, `header.htm`, `footer.htm` all exist.
- [ ] All `.ae-*` selectors are namespaced; no leakage outside the shell.
- [ ] `.cbi-*` legacy views still render correctly.
- [ ] APK metadata validates with `apk add --allow-untrusted`.

## Maintainability

- [ ] No inline `style="…"` in templates (except dynamically computed).
- [ ] No JS in HTML attributes; only `data-*` hooks.
- [ ] All CSS files < 30 KB raw, total < 100 KB.
- [ ] No utility class outside the documented set.
- [ ] All new components documented in `ARCHITECTURE.md`.

## Performance

- [ ] First paint < 200 ms on a simulated MIPS router (4× Atheros 600 MHz).
- [ ] JS bundle < 15 KB uncompressed.
- [ ] No layout shift after font load (FOIT/FOUT handled).
- [ ] No animation on `prefers-reduced-motion: reduce`.

## Accessibility

- [ ] Tab order matches visual order.
- [ ] `:focus-visible` ring visible against all surfaces.
- [ ] Text contrast ≥ 4.5:1; large text ≥ 3:1.
- [ ] Sidebar arrow-key navigation works.
- [ ] All icons either `aria-hidden` or have accessible labels.
- [ ] `cmd/ctrl-K` opens search.

## Security

- [ ] No `eval`, no inline JS, no remote CDN.
- [ ] All SVG icons loaded via local `<use>` references.
- [ ] No third-party tracking, no telemetry.

## Visual

- [ ] No gaming/RGB gradients.
- [ ] Soft shadows only (≤ 48 px blur).
- [ ] Consistent stroke width across icons (1.75).
- [ ] Light/Dark/HC themes render without colour inversion.