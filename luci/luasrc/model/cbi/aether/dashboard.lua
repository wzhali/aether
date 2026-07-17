-- Aether — Dashboard widget ordering CBI form.

local m = Map("aether", translate("Dashboard Layout"), translate("Reorder Aether dashboard widgets."))

o = m:section(SimpleSection, translate("Widget order"))
for _, key in ipairs({
    "cpu","mem","temp","disk","wan","topo",
    "ipv4","ipv6","vpn","wifi","clients","updates","uptime"
}) do
    local f = o:option(Value, "order_" .. key, key:gsub("^%l", string.upper))
    f.placeholder = "0"
end

return m