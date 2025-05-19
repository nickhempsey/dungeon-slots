local Localization = {}
local current, fallback = {}, {}

local domains = { "ui", "abilities", "heroes", "symbols" }

-- load language tables into `current`, always load
-- English as `fallback`
function Localization.load(locale)
    -- load fallback first
    fallback = {}
    for _, domain in ipairs(domains) do
        fallback[domain] = require("locales.en." .. domain)
    end

    current = {}
    for _, domain in ipairs(domains) do
        local ok, translations = pcall(require, "locales." .. locale .. "." .. domain)
        current[domain] = ok and translations or {}
    end
end

local function dot(tbl, path)
    for part in path:gmatch("[^.]+") do
        if not tbl then return nil end
        tbl = tbl[part]
    end
    return tbl
end

--- Returns the translations for a dot separated string.
---
--- locales/en/ui.lua
--- return status_effects = { luck = "Luck increased by %d%" }
---
--- I18n.t("ui.status_effects.luck", luck.increase)
---@param key string The dot separated key. ie: 'ui.status_effects.luck'
---@param ... unknown interpolation params. ie: 'luck.increase'
---@return string
function Localization.t(key, ...)
    local domain, path = key:match("^(%w+)%.(.+)$")
    if not domain then return key end

    local text = dot(current[domain], path)
        or dot(fallback[domain], path)
        or key

    -- pass through any args to string.format
    if select("#", ...) > 0 then
        return string.format(text, ...)
    else
        return text
    end
end

return Localization
