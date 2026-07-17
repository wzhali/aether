// dashboard.js — lightweight dashboard widget orchestration.
// Fetches data through LuCI's rpcd JSON-RPC interface and updates widgets.
// No external dependencies. Pure ES2022 module.

const POLL_INTERVAL = 5000;

function rpcCall(method, params) {
  return fetch("/cgi-bin/luci/rpc/" + method, {
    method: "POST",
    credentials: "same-origin",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ id: 1, method, params: params || [] })
  }).then(r => r.json()).then(j => {
    if (j && j.error) throw new Error(j.error.message || "rpc error");
    return j.result;
  });
}

function fmtBytes(n) {
  if (!Number.isFinite(n)) return "—";
  const u = ["B", "KB", "MB", "GB", "TB"];
  let i = 0; while (n >= 1024 && i < u.length - 1) { n /= 1024; i++; }
  return `${n.toFixed(i === 0 ? 0 : 1)} ${u[i]}`;
}

function fmtRate(n) {
  if (!Number.isFinite(n)) return "—";
  return fmtBytes(n) + "/s";
}

function fmtUptime(seconds) {
  const s = Math.max(0, Math.floor(seconds || 0));
  const d = Math.floor(s / 86400);
  const h = Math.floor((s % 86400) / 3600);
  const m = Math.floor((s % 3600) / 60);
  if (d > 0) return `${d}d ${h}h`;
  if (h > 0) return `${h}h ${m}m`;
  return `${m}m`;
}

function setRing(node, pct) {
  node.style.setProperty("--_pct", String(Math.max(0, Math.min(100, pct))));
}

function drawSparkline(svg, data, stroke = "var(--ae-primary)") {
  if (!svg || !data || data.length === 0) return;
  const w = 100, h = 36;
  const max = Math.max(...data, 1);
  const min = Math.min(...data, 0);
  const range = Math.max(1, max - min);
  const step = w / (data.length - 1 || 1);
  const pts = data.map((v, i) => [i * step, h - ((v - min) / range) * h]);
  const line = "M" + pts.map(p => p.join(",")).join(" L");
  const area = line + ` L${w},${h} L0,${h} Z`;
  svg.innerHTML = `
    <path class="ae-sparkline__area" d="${area}"/>
    <path d="${line}" stroke="${stroke}"/>
  `;
  svg.setAttribute("viewBox", `0 0 ${w} ${h}`);
  svg.setAttribute("preserveAspectRatio", "none");
}

async function pollSystem() {
  try {
    const sys = await rpcCall("sys", ["info"]);
    const cpu = sys.loadavg?.[0] ?? 0;
    const memTotal = sys.memory?.total ?? 0;
    const memFree  = sys.memory?.free  ?? 0;
    const memUsed  = Math.max(0, memTotal - memFree);
    const memPct   = memTotal ? (memUsed / memTotal) * 100 : 0;

    const cpuCard = document.querySelector("[data-widget='cpu']");
    if (cpuCard) {
      const ring = cpuCard.querySelector(".ae-ring");
      const val  = cpuCard.querySelector("[data-bind='cpu-pct']");
      const fill = cpuCard.querySelector(".ae-progress__fill");
      const pct  = Math.min(100, cpu * 100 / Math.max(1, sys.nprocs || 1));
      if (ring) setRing(ring, pct);
      if (val)  val.textContent = `${pct.toFixed(0)}%`;
      if (fill) fill.style.width = `${pct}%`;
    }

    const memCard = document.querySelector("[data-widget='mem']");
    if (memCard) {
      const ring = memCard.querySelector(".ae-ring");
      const val  = memCard.querySelector("[data-bind='mem-pct']");
      const sub  = memCard.querySelector("[data-bind='mem-sub']");
      const fill = memCard.querySelector(".ae-progress__fill");
      if (ring) setRing(ring, memPct);
      if (val)  val.textContent = `${memPct.toFixed(0)}%`;
      if (sub)  sub.textContent = `${fmtBytes(memUsed)} / ${fmtBytes(memTotal)}`;
      if (fill) fill.style.width = `${memPct}%`;
    }

    const upCard = document.querySelector("[data-widget='uptime']");
    if (upCard) {
      const v = upCard.querySelector("[data-bind='uptime']");
      if (v) v.textContent = fmtUptime(sys.uptime);
    }
  } catch (err) {
    // Silent: dashboard may run on a non-rpcd environment (preview).
  }
}

async function pollNetwork() {
  try {
    const wan = await rpcCall("network", ["interfaces"]);
    const wanIf = wan?.["wan"] || wan?.["WAN"] || Object.values(wan || {})[0];
    const wanCard = document.querySelector("[data-widget='wan']");
    if (wanCard && wanIf) {
      const rx = wanIf.stats?.rx_bytes ?? 0;
      const tx = wanIf.stats?.tx_bytes ?? 0;
      const rxEl = wanCard.querySelector("[data-bind='wan-rx']");
      const txEl = wanCard.querySelector("[data-bind='wan-tx']");
      if (rxEl) rxEl.textContent = fmtRate(rx);
      if (txEl) txEl.textContent = fmtRate(tx);
    }
  } catch (_) { /* ignore */ }
}

function bootDashboard() {
  if (!document.querySelector(".ae-dashboard")) return;
  pollSystem();
  pollNetwork();
  setInterval(pollSystem, POLL_INTERVAL);
  setInterval(pollNetwork, POLL_INTERVAL);
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", bootDashboard);
} else {
  bootDashboard();
}

export const aetherDashboard = { pollSystem, pollNetwork };