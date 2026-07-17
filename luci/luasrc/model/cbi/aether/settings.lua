-- Aether — theme settings CBI form.
-- Renders the in-theme Settings page (`/admin/system/aether`).

local m = Map("aether", translate("Aether Theme"), translate("Customise the Aether LuCI theme."))

-- Theme
s = m:section(SimpleSection, translate("Appearance"))
theme = s:option(ListValue, "theme", translate("Theme"))
theme:value("auto",    translate("Auto (follow browser)"))
theme:value("light",   translate("Light"))
theme:value("dark",    translate("Dark"))
theme:value("hc",      translate("High Contrast"))
theme.default = "auto"
theme.rmempty = false

density = s:option(ListValue, "density", translate("Density"))
density:value("comfortable", translate("Comfortable"))
density:value("compact",     translate("Compact"))
density.default = "comfortable"

primary = s:option(Value, "primary", translate("Primary color"))
primary.placeholder = "#0A84FF"
primary.rmempty = true
function primary.validate(self, value)
    if value and value ~= "" and not value:match("^#?[0-9a-fA-F]+$") then
        return nil, translate("Use a hex color (e.g. #0A84FF).")
    end
    return value
end

accent = s:option(Value, "accent", translate("Accent color"))
accent.placeholder = "#BF5AF2"
accent.rmempty = true

radius = s:option(Value, "radius", translate("Card radius"))
radius.placeholder = "12"
radius.rmempty = true
function radius.validate(self, value)
    local n = tonumber(value)
    if value and value ~= "" and (not n or n < 0 or n > 32) then
        return nil, translate("Enter a number between 0 and 32.")
    end
    return value
end

fontScale = s:option(Value, "font_scale", translate("Font size scale"))
fontScale.placeholder = "1.0"
function fontScale.validate(self, value)
    local n = tonumber(value)
    if not n or n < 0.85 or n > 1.4 then
        return nil, translate("Use 0.85 – 1.4.")
    end
    return value
end

-- Sidebar / Glass
glass = s:option(Flag, "glass", translate("Glass effect"))
glass.default = 1

blur = s:option(Value, "blur", translate("Blur strength (px)"))
blur.placeholder = "24"
function blur.validate(self, value)
    local n = tonumber(value)
    if not n or n < 0 or n > 60 then
        return nil, translate("Use 0 – 60.")
    end
    return value
end

sidebar = s:option(ListValue, "sidebar", translate("Sidebar style"))
sidebar:value("expanded",  translate("Expanded"))
sidebar:value("collapsed", translate("Collapsed"))
sidebar:value("overlay",   translate("Overlay (mobile-style)"))
sidebar.default = "expanded"

wallpaper = s:option(ListValue, "wallpaper", translate("Wallpaper"))
wallpaper:value("none",   translate("None"))
wallpaper:value("auto",   translate("Auto"))
wallpaper:value("aurora", translate("Aurora"))
wallpaper:value("mesh",   translate("Mesh"))
wallpaper.default = "auto"

-- Motion
motion = s:option(ListValue, "motion", translate("Motion"))
motion:value("normal",  translate("Normal"))
motion:value("reduced", translate("Reduced"))
motion.default = "normal"

-- Dashboard widgets
w = m:section(SimpleSection, translate("Dashboard widgets"))
local widgets = {
    "cpu","mem","temp","disk","wan","topo",
    "ipv4","ipv6","vpn","wifi","clients","updates","uptime"
}
for _, key in ipairs(widgets) do
    local o = w:option(Flag, "widget_" .. key, translate(key:gsub("^%l", string.upper)))
    o.default = 1
end

return m