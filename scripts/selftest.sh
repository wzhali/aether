#!/usr/bin/env bash
# Aether — local + CI self-check.
# 用法: bash scripts/selftest.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ASSETS="$ROOT/luci/htdocs/luci-static/aether"
fail=0

note() { printf '\n\033[1;34m[%s]\033[0m %s\n' "$1" "$2"; }
warn() { printf '\033[1;33m  WARN\033[0m %s\n' "$1"; fail=1; }
pass() { printf '\033[1;32m  PASS\033[0m %s\n' "$1"; }

note "compat" "core theme entrypoints exist"
for f in theme.htm header.htm footer.htm; do
  if [ -f "$ASSETS/$f" ]; then pass "$f"; else warn "missing $f"; fi
done

note "compat" "luasrc views exist"
for f in dashboard.htm settings.htm sysauth.htm; do
  if [ -f "$ROOT/luci/luasrc/view/themes/aether/$f" ]; then pass "$f"; else warn "missing $f"; fi
done

note "compat" "JS syntax"
for f in "$ASSETS"/js/*.js; do
  if node --check "$f" >/dev/null 2>&1; then pass "$(basename "$f")"; else warn "JS syntax error in $f"; fi
done

note "size"   "CSS / JS budgets"
total_css=$(find "$ASSETS/css" -name '*.css' -exec cat {} + | wc -c | tr -d ' ')
total_js=$(find "$ASSETS/js" -name '*.js' -exec cat {} + | wc -c | tr -d ' ')
[ "$total_css" -lt 102400 ] && pass "css total ${total_css}B < 100KB" || warn "css total ${total_css}B > 100KB"
[ "$total_js"  -lt 16384 ]  && pass "js  total ${total_js}B < 16KB"   || warn "js  total ${total_js}B > 16KB (soft)"
while read -r size path; do
  if [ "$path" = "total" ] || [ -z "$path" ]; then continue; fi
  if [ "$size" -ge 30720 ]; then warn "$path ${size}B > 30KB"; fi
done < <(find "$ASSETS/css" -name '*.css' -exec wc -c {} +)

note "security" "no eval / inline JS / remote CDN"
grep -rEn '\beval\(|new[[:space:]]+Function\(' "$ASSETS" >/dev/null && warn "eval() or new Function() found" || pass "no eval / new Function"
grep -rEn 'https?://(?!www\.w3\.org)[^"'\'' )]+' "$ASSETS" | grep -v 'rsms\.me\|lucide\.dev\|fonts\.googleapis' >/dev/null \
  && warn "remote URL detected" || pass "no remote CDN"
grep -rEn ' on[a-z]+=' "$ASSETS" >/dev/null && warn "inline event handler" || pass "no inline on* handlers"

note "a11y"    "basic accessibility checks"
grep -rEn 'aria-hidden|aria-label|role=' "$ASSETS" "$ROOT/luci/luasrc" >/dev/null && pass "ARIA hooks present" || warn "no ARIA hooks"

note "css"     "stylelint"
if [ -f "$ROOT/node_modules/.bin/stylelint" ]; then
  "$ROOT/node_modules/.bin/stylelint" "$ASSETS/css/**/*.css" \
    --config "$ROOT/.stylelintrc.json" && pass "stylelint clean" || warn "stylelint reported issues"
else
  warn "stylelint not installed (npm i)"
fi

if [ "$fail" -ne 0 ]; then
  printf '\n\033[1;31mSelf-check FAILED\033[0m\n'
  exit 1
fi
printf '\n\033[1;32mSelf-check OK\033[0m\n'