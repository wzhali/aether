-- Aether theme controller.
-- Provides the in-theme Settings page and registers the theme entry.

module("luci.controller.aether", package.seeall)

function index()
    local fs = require "nixio.fs"
    if not fs.access("/etc/config/aether") then
        -- Defensive: ensure a baseline config exists. Real config is
        -- normally materialised by /etc/uci-defaults/99-luci-theme-aether.
        local nixio = require "nixio"
        nixio.fs.writefile("/etc/config/aether", "")
    end

    entry({"admin", "system", "aether"}, cbi("aether/settings"), _("Aether Theme"), 60)
    entry({"admin", "system", "aether", "dashboard"}, cbi("aether/dashboard"), _("Dashboard"), 1)
end