// theme.js — runtime theme, density, color overrides + persistence.
// Loaded as a module from both theme.htm and login template. Pure ES2022.

const STORAGE_KEY = "aether:settings:v1";

const DEFAULT_SETTINGS = Object.freeze({
  theme: "auto",                // auto | light | dark | hc
  density: "comfortable",       // comfortable | compact
  primary: null,                 // optional override; null => use token
  accent: null,
  radius: 12,                    // px
  fontScale: 1,
  blur: 24,                      // px
  glass: true,
  wallpaper: "auto",             // none | auto | aurora | mesh
  sidebar: "expanded",           // expanded | collapsed | overlay
  motion: "normal",              // normal | reduced
  widgets: {                     // dashboard widget visibility
    cpu: true, mem: true, temp: true, disk: true,
    wan: true, topo: true, ipv4: true, ipv6: true,
    vpn: true, wifi: true, clients: true, updates: true, uptime: true
  }
});

function loadSettings() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return { ...DEFAULT_SETTINGS };
    const parsed = JSON.parse(raw);
    return { ...DEFAULT_SETTINGS, ...parsed, widgets: { ...DEFAULT_SETTINGS.widgets, ...(parsed.widgets || {}) } };
  } catch (_) {
    return { ...DEFAULT_SETTINGS };
  }
}

function saveSettings(s) {
  try { localStorage.setItem(STORAGE_KEY, JSON.stringify(s)); } catch (_) { /* ignore */ }
}

function applySettings(s) {
  const root = document.documentElement;
  root.setAttribute("data-theme", s.theme || "auto");
  root.setAttribute("data-density", s.density || "comfortable");
  if (typeof s.radius === "number") {
    root.style.setProperty("--ae-radius", `${s.radius}px`);
    root.style.setProperty("--ae-radius-sm", `${Math.max(4, s.radius / 2)}px`);
    root.style.setProperty("--ae-radius-lg", `${Math.round(s.radius * 1.6)}px`);
    root.style.setProperty("--ae-radius-xl", `${Math.round(s.radius * 2.2)}px`);
  }
  if (typeof s.fontScale === "number") {
    root.style.setProperty("--ae-font-scale", String(s.fontScale));
  }
  if (typeof s.blur === "number") {
    root.style.setProperty("--ae-blur-strength", s.glass === false ? "0px" : `${s.blur}px`);
  } else if (s.glass === false) {
    root.style.setProperty("--ae-blur-strength", "0px");
  }
  if (s.primary) root.style.setProperty("--ae-primary", s.primary);
  if (s.accent)  root.style.setProperty("--ae-accent",  s.accent);
  if (s.wallpaper && s.wallpaper !== "none") {
    root.style.setProperty("--ae-wallpaper",
      `url("${getWallpaperURL(s.wallpaper, s.theme)}")`);
  }
  // Density / sidebar applied to the shell, not <html>.
  const shell = document.getElementById("ae-shell");
  if (shell) {
    shell.setAttribute("data-density", s.density || "comfortable");
    shell.setAttribute("data-sidebar", s.sidebar || "expanded");
    if ((s.sidebar || "expanded") === "overlay") {
      shell.setAttribute("data-sidebar-open", "false");
    }
  }
}

function getWallpaperURL(name, theme) {
  const base = "/luci-static/aether/img/";
  switch (name) {
    case "aurora": return base + "wallpaper-" + (theme === "light" ? "light" : "dark") + ".svg";
    case "mesh":   return base + "wallpaper-" + (theme === "light" ? "light" : "dark") + ".svg";
    default:       return base + "wallpaper-" + (theme === "light" ? "light" : "dark") + ".svg";
  }
}

function attachSidebarToggle() {
  const btn = document.querySelector(".ae-sidebar__toggle");
  const shell = document.getElementById("ae-shell");
  if (!btn || !shell) return;
  btn.addEventListener("click", () => {
    const settings = loadSettings();
    const cycle = ["expanded", "collapsed", "overlay"];
    const next = cycle[(cycle.indexOf(settings.sidebar) + 1) % cycle.length];
    settings.sidebar = next;
    shell.setAttribute("data-sidebar", next);
    shell.setAttribute("data-sidebar-open", next === "overlay" ? "true" : "false");
    saveSettings(settings);
  });
}

function attachThemeMenu() {
  const btn = document.querySelector("[data-action='theme-cycle']");
  if (!btn) return;
  btn.addEventListener("click", () => {
    const order = ["auto", "light", "dark", "hc"];
    const settings = loadSettings();
    settings.theme = order[(order.indexOf(settings.theme) + 1) % order.length];
    saveSettings(settings);
    applySettings(settings);
    document.dispatchEvent(new CustomEvent("aether:theme-change", { detail: settings }));
  });
}

function attachUserMenu() {
  const menu = document.getElementById("ae-user-menu");
  if (!menu) return;
  const btn = menu.querySelector("button");
  const panel = menu.querySelector(".ae-menu__panel");
  if (!btn || !panel) return;
  btn.addEventListener("click", (e) => {
    e.stopPropagation();
    const open = menu.getAttribute("data-open") === "true";
    menu.setAttribute("data-open", open ? "false" : "true");
    btn.setAttribute("aria-expanded", open ? "false" : "true");
  });
  document.addEventListener("click", (e) => {
    if (!menu.contains(e.target)) {
      menu.setAttribute("data-open", "false");
      btn.setAttribute("aria-expanded", "false");
    }
  });
}

function attachNotify() {
  const el = document.getElementById("ae-notify");
  if (!el) return;
  const btn = el.querySelector("button");
  const panel = el.querySelector(".ae-notify__panel");
  if (!btn || !panel) return;
  // Sample notifications. Real implementation would fetch from rpcd.
  panel.innerHTML = `
    <div class="ae-notify__item">
      <div class="ae-notify__icon ae-notify__icon--warn">
        <svg class="ae-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75"><path d="M10.3 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0Z"/><path d="M12 9v4M12 17h.01"/></svg>
      </div>
      <div>
        <div>High CPU usage on radio0</div>
        <div class="ae-notify__time">3 minutes ago</div>
      </div>
    </div>
    <div class="ae-notify__item">
      <div class="ae-notify__icon">
        <svg class="ae-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg>
      </div>
      <div>
        <div>Scheduled reboot in 4 hours</div>
        <div class="ae-notify__time">Today, 02:00</div>
      </div>
    </div>`;
  btn.addEventListener("click", (e) => {
    e.stopPropagation();
    el.setAttribute("data-open", el.getAttribute("data-open") === "true" ? "false" : "true");
  });
  document.addEventListener("click", (e) => {
    if (!el.contains(e.target)) el.setAttribute("data-open", "false");
  });
}

function attachSearch() {
  const root = document.getElementById("ae-search");
  if (!root) return;
  const input = root.querySelector("input");
  const list = root.querySelector(".ae-search__results");
  if (!input || !list) return;
  const items = [
    { label: "Dashboard", href: "/cgi-bin/luci/admin/status/overview", cat: "Status" },
    { label: "Interfaces", href: "/cgi-bin/luci/admin/network/interfaces", cat: "Network" },
    { label: "Wireless", href: "/cgi-bin/luci/admin/network/wireless", cat: "Network" },
    { label: "Firewall", href: "/cgi-bin/luci/admin/network/firewall", cat: "Network" },
    { label: "Aether Settings", href: "/cgi-bin/luci/admin/system/aether", cat: "System" }
  ];
  function render(q) {
    const ql = (q || "").toLowerCase();
    const matched = items.filter(i => !ql || i.label.toLowerCase().includes(ql));
    if (!matched.length) {
      list.innerHTML = `<div class="ae-cmdk__empty">No results</div>`;
      return;
    }
    list.innerHTML = matched.map(i => `
      <a class="ae-search__item" href="${i.href}" role="option">
        <svg class="ae-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75"><path d="M9 18l6-6-6-6"/></svg>
        <span>${i.label}</span>
        <span class="ae-search__item-cat">${i.cat}</span>
      </a>
    `).join("");
  }
  input.addEventListener("focus", () => { render(input.value); root.setAttribute("data-open", "true"); });
  input.addEventListener("blur", () => setTimeout(() => root.setAttribute("data-open", "false"), 120));
  input.addEventListener("input", () => render(input.value));
  document.addEventListener("keydown", (e) => {
    if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === "k") {
      e.preventDefault(); input.focus();
    }
  });
}

function boot() {
  const s = loadSettings();
  applySettings(s);
  attachSidebarToggle();
  attachThemeMenu();
  attachUserMenu();
  attachNotify();
  attachSearch();
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", boot);
} else {
  boot();
}

// Public API for the Theme Settings page.
export const aetherTheme = {
  get: loadSettings,
  set: (patch) => { const s = { ...loadSettings(), ...patch }; saveSettings(s); applySettings(s); return s; },
  reset: () => { saveSettings({ ...DEFAULT_SETTINGS }); applySettings({ ...DEFAULT_SETTINGS }); }
};