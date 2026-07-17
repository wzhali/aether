// aether.js — main module. Re-exports the entry points.

export { aetherTheme } from "./theme.js";
export { aetherDashboard } from "./dashboard.js";
import "./nav.js";
import "./theme.js";
import "./dashboard.js";

// Wire theme-cycle button if the settings page adds it.
document.addEventListener("aether:theme-change", () => {
  // Re-render dependent UI by dispatching a custom event listeners can hook.
  document.documentElement.dataset.themeReady = "1";
});