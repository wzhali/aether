// nav.js — sidebar keyboard navigation and current-route highlighting.

function setCurrentFromURL() {
  const here = location.pathname;
  const links = document.querySelectorAll(".ae-sidebar__link");
  links.forEach(a => {
    try {
      const u = new URL(a.href, location.href);
      if (u.pathname === here) a.setAttribute("aria-current", "page");
      else a.removeAttribute("aria-current");
    } catch (_) { /* ignore */ }
  });
}

function attachKeyboardNav() {
  const links = Array.from(document.querySelectorAll(".ae-sidebar__link"));
  if (!links.length) return;
  links.forEach((link, i) => {
    link.addEventListener("keydown", (e) => {
      if (e.key === "ArrowDown") {
        e.preventDefault();
        links[(i + 1) % links.length].focus();
      } else if (e.key === "ArrowUp") {
        e.preventDefault();
        links[(i - 1 + links.length) % links.length].focus();
      } else if (e.key === "Home") {
        e.preventDefault(); links[0].focus();
      } else if (e.key === "End") {
        e.preventDefault(); links[links.length - 1].focus();
      }
    });
  });
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", () => { setCurrentFromURL(); attachKeyboardNav(); });
} else {
  setCurrentFromURL(); attachKeyboardNav();
}