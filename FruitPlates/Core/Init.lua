local addonName, ns = ...

local FP = _G.FruitPlates or {}
_G.FruitPlates = FP

FP.name = addonName or "FruitPlates"
FP.version = "0.9.8b-beta"
FP.modules = FP.modules or {}
FP.debug = false

FP.myclass = select(2, UnitClass("player"))
FP.mylevel = UnitLevel("player")
FP.myguid = UnitGUID("player")
FP.PixelMode = true
FP.mult = 1

FP.InversePoints = {
    TOP = "BOTTOM",
    BOTTOM = "TOP",
    LEFT = "RIGHT",
    RIGHT = "LEFT",
    TOPLEFT = "BOTTOMLEFT",
    TOPRIGHT = "BOTTOMRIGHT",
    BOTTOMLEFT = "TOPLEFT",
    BOTTOMRIGHT = "TOPRIGHT",
    CENTER = "CENTER",
}

FP.TexCoords = {0.08, 0.92, 0.08, 0.92}

FP.HealingClasses = {
    DRUID = true,
    PALADIN = true,
    PRIEST = true,
    SHAMAN = true,
}

function FP:Print(...)
    local out = {}
    for i = 1, select("#", ...) do
        out[i] = tostring(select(i, ...))
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cff22ff88FruitPlates:|r " .. table.concat(out, " "))
end

function FP:Debug(...)
    if self.debug then
        self:Print("[debug]", ...)
    end
end

function FP:RegisterModule(name, module)
    self.modules[name] = module
    module.name = name
    module.FP = self
    return module
end

function FP:GetModule(name)
    return self.modules[name]
end

function FP:CopyTable(src, dst)
    if type(src) ~= "table" then return src end
    dst = dst or {}
    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = self:CopyTable(v, type(dst[k]) == "table" and dst[k] or {})
        else
            dst[k] = v
        end
    end
    return dst
end

function FP:MergeDefaults(defaults, db)
    if type(defaults) ~= "table" then return db end
    db = type(db) == "table" and db or {}
    for k, v in pairs(defaults) do
        if type(v) == "table" then
            db[k] = self:MergeDefaults(v, db[k])
        elseif db[k] == nil then
            db[k] = v
        end
    end
    return db
end

FP.EventFrame = FP.EventFrame or CreateFrame("Frame", "FruitPlatesEventFrame")
FP.EventFrame.handlers = FP.EventFrame.handlers or {}

function FP:RegisterEvent(event, func)
    self.EventFrame:RegisterEvent(event)
    self.EventFrame.handlers[event] = self.EventFrame.handlers[event] or {}
    table.insert(self.EventFrame.handlers[event], func)
end

FP.EventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local loaded = ...
        if loaded == FP.name then
            FP:InitializeDatabase()
            FP:InitializeMedia()
            FP:InitializeSlash()
            if FP.RegisterBlizzardOptions then
                FP:RegisterBlizzardOptions()
            end
            local NP = FP:GetModule("NamePlates")
            if NP and NP.Initialize then
                NP:Initialize()
            end
            FP:Print("loaded. Open GUI with /fp")
        end
    end

    local list = FP.EventFrame.handlers[event]
    if list then
        for i = 1, #list do
            list[i](event, ...)
        end
    end
end)

FP.EventFrame:RegisterEvent("ADDON_LOADED")
