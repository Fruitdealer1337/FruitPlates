local FP = _G.FruitPlates

local Config = {}
FP.Config = Config
Config.controlIndex = 0

local UNIT_GROUPS = {
    enemy = {"ENEMY_PLAYER"},
    friendly = {"FRIENDLY_PLAYER"},
    npc = {"ENEMY_NPC", "FRIENDLY_NPC"},
    pet = {"ENEMY_PET", "FRIENDLY_PET"},
    npcpet = {"ENEMY_NPC", "FRIENDLY_NPC", "ENEMY_PET", "FRIENDLY_PET"},
    all = {"ENEMY_PLAYER", "ENEMY_NPC", "FRIENDLY_PLAYER", "FRIENDLY_NPC", "ENEMY_PET", "FRIENDLY_PET"},
}

local TEXTURES = {
    {label = "FurtiPlates Shade", value = "FurtiPlates Shade"},
    {label = "FruitPlates Flat", value = "FruitPlates Flat"},
    {label = "Aluminium", value = "Aluminium"},
    {label = "Armory", value = "Armory"},
    {label = "BantoBar", value = "BantoBar"},
    {label = "Bars", value = "Bars"},
    {label = "Button", value = "Button"},
    {label = "Charcoal", value = "Charcoal"},
    {label = "Cilo", value = "Cilo"},
    {label = "Cloud", value = "Cloud"},
    {label = "DarkBottom", value = "DarkBottom"},
    {label = "Diagonal", value = "Diagonal"},
    {label = "Glamour", value = "Glamour"},
    {label = "Glass", value = "Glass"},
    {label = "Graphite", value = "Graphite"},
    {label = "Melli", value = "Melli"},
    {label = "Minimalist", value = "Minimalist"},
}

local TEXT_ANCHORS = {
    {label="Left", value="LEFT"},
    {label="Middle", value="MIDDLE"},
    {label="Right", value="RIGHT"},
}

local OUTLINE_GROWTH = {
    {label="Inward", value="IN"},
    {label="Outward", value="OUT"},
}

local ICON_MODES = {
    {label = "Raid Icons Only", value = "RAID"},
    {label = "Class Icons Only", value = "CLASS"},
    {label = "Both", value = "BOTH"},
}

local PLATE_TABS = {
    {label = "Healthbar", value = "healthbar", width = 106},
    {label = "Text", value = "text", width = 86},
    {label = "Icons", value = "icons", width = 92},
    {label = "Outlines", value = "colors", width = 106},
    {label = "Highlight", value = "highlight", width = 106},
}

local CASTBAR_TABS = {
    {label = "General", value = "castbar", width = 92},
    {label = "Text", value = "text", width = 86},
    {label = "Icon", value = "icon", width = 86},
    {label = "Color", value = "color", width = 92},
    {label = "Pet Cast Bars", value = "pets", width = 132},
}

local HIGHLIGHT_MODES = {
    {label = "Healthbar Only", value = "HEALTHBAR"},
    {label = "Healthbar + Class Icon", value = "HEALTHBAR_ICON"},
    {label = "Class Icon Only", value = "ICON"},
}


local CASTBAR_MODES = {
    {label = "Enemy Plates", value = "ENEMY"},
    {label = "Friendly Plates", value = "FRIENDLY"},
    {label = "Enemy & Friendly Plates", value = "BOTH"},
}

local TOTEM_DISPLAY_MODES = {
    {label = "Icons", value = "ICONS"},
    {label = "Nameplates", value = "NAMEPLATES"},
    {label = "Hidden", value = "HIDDEN"},
}

local AURA_TEXT_ANCHORS = {
    {label = "Center", value = "CENTER"},
    {label = "Top", value = "TOP"},
    {label = "Bottom", value = "BOTTOM"},
    {label = "Left", value = "LEFT"},
    {label = "Right", value = "RIGHT"},
}


local AURA_TABS = {
    {label = "README FIRST", value = "readme", width = 126},
    {label = "General", value = "general", width = 92},
    {label = "Layout", value = "priority", width = 92},
    {label = "Spell List", value = "spells", width = 104},
}

local FRIENDLY_AURA_TABS = {
    {label = "README FIRST", value = "readme", width = 126},
    {label = "General", value = "general", width = 92},
    {label = "Layout", value = "layout", width = 92},
    {label = "Whitelist", value = "whitelist", width = 104},
}

local TOTEM_TABS = {
    {label = "General", value = "general", width = 92},
    {label = "Icons", value = "icons", width = 86},
    {label = "Nameplates", value = "nameplates", width = 112},
    {label = "Totem Icon List", value = "list", width = 132},
}

local TOTEM_CONFIG_LIST = {
    {key = "CLEANSING", label = "Cleansing Totem"},
    {key = "EARTHBIND", label = "Earthbind Totem"},
    {key = "GROUNDING", label = "Grounding Totem"},
    {key = "TREMOR", label = "Tremor Totem"},
    {key = "MANA_TIDE", label = "Mana Tide Totem"},
    {key = "MANA_SPRING", label = "Mana Spring Totem VIII"},
    {key = "MAGMA", label = "Magma Totem VII"},
    {key = "FIRE_RESISTANCE", label = "Fire Resistance Totem VI"},
    {key = "FLAMETONGUE", label = "Flametongue Totem VIII"},
    {key = "FROST_RESISTANCE", label = "Frost Resistance Totem VI"},
    {key = "HEALING_STREAM", label = "Healing Stream Totem IX"},
    {key = "NATURE_RESISTANCE", label = "Nature Resistance Totem VI"},
    {key = "SEARING", label = "Searing Totem X"},
    {key = "SENTRY", label = "Sentry Totem"},
    {key = "STONECLAW", label = "Stoneclaw Totem X"},
    {key = "STONESKIN", label = "Stoneskin Totem X"},
    {key = "STRENGTH_OF_EARTH", label = "Strength of Earth Totem VIII"},
    {key = "TOTEM_OF_WRATH", label = "Totem of Wrath IV"},
    {key = "WINDFURY", label = "Windfury Totem"},
    {key = "WRATH_OF_AIR", label = "Wrath of Air Totem"},
    {key = "EARTH_ELEMENTAL", label = "Earth Elemental Totem"},
    {key = "FIRE_ELEMENTAL", label = "Fire Elemental Totem"},
}

local PAGES = {
    {key="general", label="General", builder="BuildGeneral"},
    {key="enemy", label="Enemy Plates", builder="BuildEnemyPlates"},
    {key="friendly", label="Friendly Plates", builder="BuildFriendlyPlates"},
    {key="npc", label="NPC & Pets Plates", builder="BuildNPCPlates"},
    {key="castbar", label="Cast Bars", builder="BuildCastBar"},
    {key="auras", label="Enemy Buffs&Debuffs", builder="BuildAuras"},
    {key="friendlyAuras", label="Friendly Buffs&Debuffs", builder="BuildFriendlyAuras"},
    {key="totems", label="Totems", builder="BuildTotems"},
    {key="profile", label="Profile", builder="BuildProfile"},
}

local function NextName(prefix)
    Config.controlIndex = Config.controlIndex + 1
    return "FruitPlates"..prefix..Config.controlIndex
end

local function Clamp(v, minV, maxV)
    v = tonumber(v) or minV
    if v < minV then return minV end
    if v > maxV then return maxV end
    return v
end

local function StepValue(v, step)
    step = tonumber(step) or 1
    v = tonumber(v) or 0
    if step <= 0 then return v end
    local out = math.floor((v / step) + 0.5) * step
    if step < 1 then out = tonumber(string.format("%.2f", out)) or out end
    return out
end

local function ClampStep(v, minV, maxV, step)
    return Clamp(StepValue(v, step), minV, maxV)
end

local function UnitList(group)
    return UNIT_GROUPS[group] or UNIT_GROUPS.all
end

local function Backdrop(frame, r, g, b, a, borderA)
    if not frame.SetBackdrop then return end
    frame:SetBackdrop({
        bgFile = [[Interface\Buttons\WHITE8x8]],
        edgeFile = [[Interface\Buttons\WHITE8x8]],
        tile = false,
        edgeSize = 1,
        insets = {left=1,right=1,top=1,bottom=1},
    })
    frame:SetBackdropColor(r or 0.04, g or 0.04, b or 0.04, a or 0.94)
    frame:SetBackdropBorderColor(0.23, 0.23, 0.23, borderA or 0.9)
end

local function Font(parent, text, template, size, color)
    local fs = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
    fs:SetText(text or "")
    if size and fs.GetFont then
        local font, _, flags = fs:GetFont()
        fs:SetFont(font, size, flags)
    end
    if color == "accent" then fs:SetTextColor(0.22, 0.95, 0.70)
    elseif color == "muted" then fs:SetTextColor(0.62, 0.62, 0.62)
    elseif color == "header" then fs:SetTextColor(0.45, 0.45, 0.45)
    else fs:SetTextColor(0.92, 0.92, 0.92) end
    return fs
end

function Config:GetUnitDB(group, unitType)
    local db = FP.db.nameplates
    unitType = unitType or UnitList(group)[1]
    return db.units[unitType]
end

function Config:ForEachUnit(group, func)
    local db = FP.db.nameplates
    local list = UnitList(group)
    for i = 1, #list do
        local unitType = list[i]
        if db.units[unitType] then
            func(db.units[unitType], unitType)
        end
    end
end

function Config:GetHealthbarTexture(unitDB)
    local root = FP.db and FP.db.nameplates or {}
    local health = unitDB and unitDB.health
    return (health and health.statusbar) or root.statusbar or "FurtiPlates Shade"
end

function Config:SetHealthbarTextureForGroup(group, value)
    self:ForEachUnit(group, function(db)
        db.health = db.health or {}
        db.health.statusbar = value
    end)
end


function Config:RefreshPlates()
    local NP = FP:GetModule("NamePlates")
    -- GUI changes can rebuild visible plates; the combat hot path stays lean.
    if NP and NP.ApplySettings then NP:ApplySettings()
    elseif NP and NP.ScanWorldFrame then NP:ScanWorldFrame(true) end

    if NP and NP.AuraTestEnabled and NP.UpdateAuraTest then
        NP:UpdateAuraTest()
    end
    if NP and NP.FriendlyAuraTestEnabled and NP.UpdateFriendlyAuraTest then
        NP:UpdateFriendlyAuraTest()
    end
    if NP and NP.CastBarTestEnabled and NP.UpdateCastBarTest then
        NP:UpdateCastBarTest()
    end
end

function Config:CreateSubDivider(parent, title, y)
    local label = Font(parent, title, "GameFontNormal", 11)
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", 24, y)
    label:SetTextColor(0.20, 0.95, 0.65, 0.95)

    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetTexture([[Interface\Buttons\WHITE8x8]])
    line:SetPoint("LEFT", label, "RIGHT", 10, 0)
    line:SetPoint("RIGHT", parent, "RIGHT", -24, 0)
    line:SetHeight(1)
    line:SetVertexColor(0.20, 0.95, 0.65, 0.65)

    return line
end

function Config:CreateSection(parent, title, y, desc)
    local f = CreateFrame("Frame", nil, parent)
    f:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y)
    f:SetPoint("RIGHT", parent, "RIGHT", -8, 0)
    f:SetHeight(desc and 50 or 34)
    Backdrop(f, 0.075, 0.075, 0.075, 0.86, 0.65)

    local accent = f:CreateTexture(nil, "ARTWORK")
    accent:SetTexture([[Interface\Buttons\WHITE8x8]])
    accent:SetPoint("TOPLEFT", f, "TOPLEFT", 1, -1)
    accent:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 1, 1)
    accent:SetWidth(3)
    accent:SetVertexColor(0.20, 0.95, 0.65, 0.95)

    local t = Font(f, title, "GameFontNormal", 13)
    t:SetPoint("TOPLEFT", f, "TOPLEFT", 13, -8)

    if desc then
        local d = Font(f, desc, "GameFontHighlightSmall", 10, "muted")
        d:SetPoint("TOPLEFT", t, "BOTTOMLEFT", 0, -4)
        d:SetPoint("RIGHT", f, "RIGHT", -10, 0)
        d:SetJustifyH("LEFT")
    end

    return f
end


function Config:ResetCollapse()
    self.collapseOpen = nil
    self.collapseScope = nil
end

function Config:BuildPlatePageByGroup(group)
    if group == "enemy" then
        self:BuildEnemyPlates()
    elseif group == "friendly" then
        self:BuildFriendlyPlates()
    elseif group == "npcpet" then
        self:BuildNPCPlates()
    end
end

function Config:CreateCollapsibleSection(parent, title, scope, sectionKey, y, desc, rebuildFunc)
    if self.collapseScope ~= scope then
        self.collapseScope = scope
        self.collapseOpen = nil
    end

    local key = scope .. "." .. sectionKey
    local open = self.collapseOpen == key
    local f = self:CreateSection(parent, (open and "[-] " or "[+] ") .. title, y, desc)
    f:EnableMouse(true)

    local hint = Font(f, open and "Click to collapse" or "Click to expand", "GameFontDisableSmall", 9, "muted")
    hint:SetPoint("RIGHT", f, "RIGHT", -12, 0)
    hint:SetTextColor(0.55, 0.55, 0.55, 0.95)

    f:SetScript("OnEnter", function(self)
        if self.SetBackdropBorderColor then self:SetBackdropBorderColor(0.20, 0.95, 0.65, 0.95) end
        hint:SetTextColor(0.20, 0.95, 0.65, 1)
    end)
    f:SetScript("OnLeave", function(self)
        if self.SetBackdropBorderColor then self:SetBackdropBorderColor(0.23, 0.23, 0.23, 0.65) end
        hint:SetTextColor(0.55, 0.55, 0.55, 0.95)
    end)
    f:SetScript("OnMouseUp", function()
        if Config.collapseOpen == key then
            Config.collapseOpen = nil
        else
            Config.collapseOpen = key
        end
        if rebuildFunc then rebuildFunc() end
    end)

    return open
end

function Config:CreatePlateCollapsibleSection(parent, group, title, sectionKey, y, desc)
    self.plateTabs = self.plateTabs or {}
    local tab = self.plateTabs[group] or "healthbar"
    return self:CreateCollapsibleSection(parent, title, "plates." .. group .. "." .. tab, sectionKey, y, desc, function()
        Config:BuildPlatePageByGroup(group)
    end)
end

function Config:CreateEnemyCollapsibleSection(parent, title, sectionKey, y, desc)
    return self:CreatePlateCollapsibleSection(parent, "enemy", title, sectionKey, y, desc)
end

function Config:CreateCastbarCollapsibleSection(parent, title, sectionKey, y, desc)
    local tab = self.castbarTab or "castbar"
    return self:CreateCollapsibleSection(parent, title, "castbar." .. tab, sectionKey, y, desc, function()
        Config:BuildCastBar()
    end)
end

function Config:CreateAurasCollapsibleSection(parent, title, sectionKey, y, desc)
    local tab = self.auraTab or "readme"
    return self:CreateCollapsibleSection(parent, title, "auras." .. tab, sectionKey, y, desc, function()
        Config:BuildAuras()
    end)
end

function Config:CreateFriendlyAurasCollapsibleSection(parent, title, sectionKey, y, desc)
    local tab = self.friendlyAuraTab or "readme"
    return self:CreateCollapsibleSection(parent, title, "friendlyAuras." .. tab, sectionKey, y, desc, function()
        Config:BuildFriendlyAuras()
    end)
end

function Config:CreateTotemCollapsibleSection(parent, title, sectionKey, y, desc)
    local tab = self.totemTab or "general"
    return self:CreateCollapsibleSection(parent, title, "totems." .. tab, sectionKey, y, desc, function()
        Config:BuildTotems()
    end)
end

function Config:CreateDescription(parent, text, x, y, width, size, color)
    local fs = Font(parent, text, "GameFontHighlightSmall", size or 10, color or "muted")
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    fs:SetWidth(width or 500)
    fs:SetJustifyH("LEFT")
    return fs
end

function Config:CreateCheck(parent, label, desc, x, y, getValue, setValue)
    local name = NextName("Check")
    local cb = CreateFrame("CheckButton", name, parent, "OptionsCheckButtonTemplate")
    cb.Text = cb.Text or _G[name.."Text"]
    cb:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    if cb.Text then cb.Text:SetText(label); cb.Text:SetTextColor(0.92,0.92,0.92) end
    if desc then
        local d = Font(parent, desc, "GameFontDisableSmall", 9, "muted")
        d:SetPoint("TOPLEFT", cb, "BOTTOMLEFT", 25, 2)
        d:SetWidth(270)
        d:SetJustifyH("LEFT")
    end
    cb:SetScript("OnClick", function(self)
        setValue(self:GetChecked() == 1)
        Config:RefreshPlates()
    end)
    cb.Refresh = function(self) self:SetChecked(getValue() and 1 or nil) end
    cb:Refresh()
    table.insert(parent.controls, cb)
    return cb
end

function Config:CreateSlider(parent, label, desc, x, y, minV, maxV, step, getValue, setValue)
    local name = NextName("Slider")
    local s = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    s.Text = s.Text or _G[name.."Text"]
    s.Low = s.Low or _G[name.."Low"]
    s.High = s.High or _G[name.."High"]
    s:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    s:SetWidth(155)
    s:SetMinMaxValues(minV, maxV)
    s:SetValueStep(step or 1)
    if s.SetObeyStepOnDrag then s:SetObeyStepOnDrag(true) end
    if s.Text then s.Text:SetText(label); s.Text:SetTextColor(0.92,0.92,0.92) end
    if s.Low then s.Low:SetText(tostring(minV)) end
    if s.High then s.High:SetText(tostring(maxV)) end

    local e = CreateFrame("EditBox", NextName("Edit"), parent, "InputBoxTemplate")
    e:SetAutoFocus(false)
    e:SetWidth(42)
    e:SetHeight(20)
    e:SetPoint("LEFT", s, "RIGHT", 11, 0)
    e:SetJustifyH("CENTER")
    e:SetTextInsets(0, 0, 0, 0)

    if desc then
        local d = Font(parent, desc, "GameFontDisableSmall", 9, "muted")
        d:SetPoint("TOPLEFT", s, "BOTTOMLEFT", 0, -18)
        d:SetWidth(225)
        d:SetJustifyH("LEFT")
    end

    local function fmt(v)
        if step and step < 1 then return string.format("%.2f", v) end
        return tostring(math.floor(v + 0.5))
    end

    local function apply(v)
        v = ClampStep(v, minV, maxV, step or 1)
        s.silent = true
        s:SetValue(v)
        s.silent = nil
        e:SetText(fmt(v))
        setValue(v)
        Config:RefreshPlates()
    end

    s:SetScript("OnValueChanged", function(self, v)
        v = ClampStep(v, minV, maxV, step or 1)
        e:SetText(fmt(v))
        if not self.silent then
            setValue(v)
            Config:RefreshPlates()
        end
    end)

    e:SetScript("OnEnterPressed", function(self) apply(self:GetText()); self:ClearFocus() end)
    e:SetScript("OnEscapePressed", function(self) self:ClearFocus(); if s.Refresh then s:Refresh() end end)
    e:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    e:SetScript("OnEditFocusLost", function(self) self:HighlightText(0,0); if s.Refresh then s:Refresh() end end)

    s.Refresh = function(self)
        self.silent = true
        local v = ClampStep(getValue(), minV, maxV, step or 1)
        self:SetValue(v)
        e:SetText(fmt(v))
        self.silent = nil
    end

    s.EditBox = e
    s:Refresh()
    table.insert(parent.controls, s)
    return s
end

function Config:CreateDropdown(parent, label, desc, x, y, width, choices, getValue, setValue)
    local fs = Font(parent, label, "GameFontNormal", 11)
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)

    local dd = CreateFrame("Frame", NextName("Dropdown"), parent, "UIDropDownMenuTemplate")
    dd:SetPoint("TOPLEFT", parent, "TOPLEFT", x - 16, y - 23)
    UIDropDownMenu_SetWidth(dd, width or 150)

    local function labelFor(value)
        for i = 1, #choices do
            if choices[i].value == value then return choices[i].label end
        end
        return tostring(value or "")
    end

    UIDropDownMenu_Initialize(dd, function(self, level)
        for i = 1, #choices do
            local choice = choices[i]
            local info = UIDropDownMenu_CreateInfo()
            info.text = choice.label
            info.value = choice.value
            info.checked = getValue() == choice.value
            info.func = function(button)
                setValue(button.value)
                UIDropDownMenu_SetText(dd, labelFor(button.value))
                Config:RefreshPlates()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    dd.Refresh = function(self) UIDropDownMenu_SetText(self, labelFor(getValue())) end
    dd:Refresh()
    table.insert(parent.controls, dd)
    return dd
end



function Config:ReleaseColorPickerKeyboard()
    if not ColorPickerFrame then return end

    -- The native ColorPickerFrame can capture keyboard input while shown on 3.3.5a,
    -- which prevents movement keybinds from firing. It does not need keyboard input;
    -- only our RGB edit boxes do, and those are separate controls.
    if ColorPickerFrame.EnableKeyboard then
        ColorPickerFrame:EnableKeyboard(false)
    end

    if GetCurrentKeyBoardFocus then
        local focus = GetCurrentKeyBoardFocus()
        if focus and focus.ClearFocus then
            focus:ClearFocus()
        end
    end
end

function Config:CreateColorPicker(parent, label, desc, x, y, getColor, setColor, isDisabled)
    local fs = Font(parent, label, "GameFontNormal", 11)
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)

    local swatch = CreateFrame("Button", nil, parent)
    swatch:SetWidth(28)
    swatch:SetHeight(18)
    swatch:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y - 22)
    Backdrop(swatch, 0.05, 0.05, 0.05, 1, 1)

    swatch.Texture = swatch:CreateTexture(nil, "ARTWORK")
    swatch.Texture:SetPoint("TOPLEFT", swatch, "TOPLEFT", 3, -3)
    swatch.Texture:SetPoint("BOTTOMRIGHT", swatch, "BOTTOMRIGHT", -3, 3)
    swatch.Texture:SetTexture([[Interface\Buttons\WHITE8x8]])

    local valueText = Font(parent, "", "GameFontHighlightSmall", 10, "muted")
    valueText:SetPoint("LEFT", swatch, "RIGHT", 8, 0)

    local function ClampColorValue(value)
        value = tonumber(value) or 0
        if value < 0 then return 0 end
        if value > 1 then return 1 end
        return tonumber(string.format("%.2f", value)) or value
    end

    local rgbLabel = Font(parent, "RGB", "GameFontDisableSmall", 9, "muted")
    rgbLabel:SetPoint("TOPLEFT", swatch, "BOTTOMLEFT", 0, -12)

    local function CreateRGBBox(channel, anchor, xOffset)
        local labelFS = Font(parent, channel, "GameFontDisableSmall", 9, "muted")
        labelFS:SetPoint("LEFT", anchor, "LEFT", xOffset, 0)

        local box = CreateFrame("EditBox", NextName("ColorEdit"), parent, "InputBoxTemplate")
        box:SetAutoFocus(false)
        box:SetWidth(32)
        box:SetHeight(18)
        box:SetPoint("LEFT", labelFS, "RIGHT", 8, 0)
        box:SetJustifyH("CENTER")
        box:SetTextInsets(0, 0, 0, 0)
        box:EnableKeyboard(false)
        box.channel = channel

        return box
    end

    local rBox = CreateRGBBox("R", rgbLabel, 34)
    local gBox = CreateRGBBox("G", rBox, 52)
    local bBox = CreateRGBBox("B", gBox, 52)

    if desc then
        local d = Font(parent, desc, "GameFontDisableSmall", 9, "muted")
        d:SetPoint("TOPLEFT", rgbLabel, "BOTTOMLEFT", 0, -12)
        d:SetWidth(250)
        d:SetJustifyH("LEFT")
    end

    local function GetSafeColor()
        local c = getColor() or {r = 1, g = 1, b = 1}
        c.r = ClampColorValue(c.r or 1)
        c.g = ClampColorValue(c.g or 1)
        c.b = ClampColorValue(c.b or 1)
        return c
    end

    local function Format(value)
        return string.format("%.2f", ClampColorValue(value))
    end

    local function SetBoxes(c)
        rBox:SetText(Format(c.r))
        gBox:SetText(Format(c.g))
        bBox:SetText(Format(c.b))
    end

    local function SetDisabledVisual(disabled)
        local alpha = disabled and 0.35 or 1
        swatch.Texture:SetAlpha(alpha)
        rgbLabel:SetTextColor(disabled and 0.45 or 0.62, disabled and 0.45 or 0.62, disabled and 0.45 or 0.62)
        rBox:SetTextColor(disabled and 0.55 or 1, disabled and 0.55 or 1, disabled and 0.55 or 1)
        gBox:SetTextColor(disabled and 0.55 or 1, disabled and 0.55 or 1, disabled and 0.55 or 1)
        bBox:SetTextColor(disabled and 0.55 or 1, disabled and 0.55 or 1, disabled and 0.55 or 1)
        if fs then fs:SetTextColor(disabled and 0.50 or 0.92, disabled and 0.50 or 0.92, disabled and 0.50 or 0.92) end
        valueText:SetTextColor(disabled and 0.45 or 0.75, disabled and 0.45 or 0.75, disabled and 0.45 or 0.75)
    end

    local function UpdateVisual()
        local c = GetSafeColor()
        local disabled = isDisabled and isDisabled()
        swatch.Texture:SetVertexColor(c.r, c.g, c.b, 1)
        valueText:SetText(string.format("%.2f / %.2f / %.2f", c.r, c.g, c.b))
        SetBoxes(c)
        SetDisabledVisual(disabled)
    end

    local function ApplyFromBoxes()
        if isDisabled and isDisabled() then
            UpdateVisual()
            return
        end

        local r = ClampColorValue(rBox:GetText())
        local g = ClampColorValue(gBox:GetText())
        local b = ClampColorValue(bBox:GetText())
        setColor(r, g, b)
        UpdateVisual()
        Config:RefreshPlates()
    end

    local function WireBox(box)
        box:SetAutoFocus(false)
        box:EnableKeyboard(false)

        box:SetScript("OnMouseDown", function(self)
            self:EnableKeyboard(true)
            self:SetFocus()
        end)

        box:SetScript("OnEnterPressed", function(self)
            ApplyFromBoxes()
            self:ClearFocus()
            self:EnableKeyboard(false)
        end)

        box:SetScript("OnEscapePressed", function(self)
            self:ClearFocus()
            self:EnableKeyboard(false)
            UpdateVisual()
        end)

        box:SetScript("OnEditFocusGained", function(self)
            self:EnableKeyboard(true)
            self:HighlightText()
        end)

        box:SetScript("OnEditFocusLost", function(self)
            self:HighlightText(0, 0)
            self:EnableKeyboard(false)
            UpdateVisual()
        end)
    end

    WireBox(rBox)
    WireBox(gBox)
    WireBox(bBox)

    swatch:SetScript("OnClick", function(self)
        if isDisabled and isDisabled() then return end

        local c = GetSafeColor()
        ColorPickerFrame.func = function()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            setColor(r, g, b)
            UpdateVisual()
            Config:RefreshPlates()
        end
        ColorPickerFrame.cancelFunc = function(previous)
            if previous then
                setColor(previous.r, previous.g, previous.b)
                UpdateVisual()
                Config:RefreshPlates()
            end
        end
        ColorPickerFrame.hasOpacity = false
        ColorPickerFrame.previousValues = {r = c.r, g = c.g, b = c.b}
        ColorPickerFrame:SetColorRGB(c.r, c.g, c.b)
        ColorPickerFrame:Hide()
        ColorPickerFrame:Show()
        Config:ReleaseColorPickerKeyboard()
    end)

    swatch.Refresh = UpdateVisual
    swatch:Refresh()
    table.insert(parent.controls, swatch)
    return swatch
end

function Config:CreateButton(parent, text, x, y, w, h, onClick)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetWidth(w or 120)
    b:SetHeight(h or 22)
    b:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    b:SetText(text)
    b:SetScript("OnClick", onClick)
    table.insert(parent.controls, b)
    return b
end


function Config:CreateEditBox(parent, label, x, y, w)
    if label then
        local fs = Font(parent, label, "GameFontHighlightSmall", 10, "muted")
        fs:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y + 18)
        fs:SetWidth(w or 180)
        fs:SetJustifyH("LEFT")
    end

    local e = CreateFrame("EditBox", NextName("Edit"), parent, "InputBoxTemplate")
    e:SetAutoFocus(false)
    e:SetWidth(w or 180)
    e:SetHeight(22)
    e:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    e:SetTextInsets(0, 0, 0, 0)
    table.insert(parent.controls, e)
    return e
end


function Config:CreateTabs(parent, tabs, selected, setSelected)
    local x = 0
    for i = 1, #tabs do
        local tab = tabs[i]
        local b = CreateFrame("Button", nil, parent)
        b:SetWidth(tab.width or 110)
        b:SetHeight(24)
        b:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -4)

        b.BG = b:CreateTexture(nil, "BACKGROUND")
        b.BG:SetTexture([[Interface\Buttons\WHITE8x8]])
        b.BG:SetAllPoints(b)

        b.Text = Font(b, tab.label, "GameFontHighlightSmall", 10)
        b.Text:SetPoint("CENTER", b, "CENTER", 0, 0)

        if tab.value == selected then
            b.BG:SetVertexColor(0.10, 0.28, 0.22, 0.95)
            b.Text:SetTextColor(0.20, 1.00, 0.72)
        else
            b.BG:SetVertexColor(0.06, 0.06, 0.06, 0.85)
            b.Text:SetTextColor(0.78, 0.78, 0.78)
        end

        b:SetScript("OnEnter", function(self)
            if tab.value ~= selected then self.BG:SetVertexColor(0.12, 0.12, 0.12, 0.95) end
        end)
        b:SetScript("OnLeave", function(self)
            if tab.value ~= selected then self.BG:SetVertexColor(0.06, 0.06, 0.06, 0.85) end
        end)
        b:SetScript("OnClick", function()
            if tab.value ~= selected then Config:ResetCollapse() end
            setSelected(tab.value)
        end)

        x = x + (tab.width or 110) + 6
    end
end

function Config:CreatePageContainer()
    local child = CreateFrame("Frame", nil, self.scrollFrame)
    child:SetWidth(620)
    child:SetHeight(780)
    child.controls = {}
    self.scrollFrame:SetScrollChild(child)
    self.scrollChild = child
    self.currentPage = child
    return child
end

function Config:ClearPage()
    if self.scrollChild then
        self.scrollChild:Hide()
    end

    local child = self:CreatePageContainer()
    self.scrollFrame:SetVerticalScroll(0)
    return child
end

function Config:SetPageTitle(title, subtitle)
    self.title:SetText(title or "FruitPlates")
    self.subtitle:SetText(subtitle or "")
end



function Config:EnsurePlateColor(key, r, g, b)
    local db = FP.db.nameplates
    db.plateColors = db.plateColors or {}
    db.plateColors[key] = db.plateColors[key] or {}

    local c = db.plateColors[key]
    if c.r == nil then c.r = r end
    if c.g == nil then c.g = g end
    if c.b == nil then c.b = b end

    return c
end

function Config:EnsureTextColor(textDB, r, g, b)
    textDB.manualColor = textDB.manualColor or {}
    local c = textDB.manualColor
    if c.r == nil then c.r = r end
    if c.g == nil then c.g = g end
    if c.b == nil then c.b = b end
    return c
end

function Config:FamilyFromPlateGroup(group)
    if group == "enemy" then return "enemy" end
    if group == "friendly" then return "friendly" end
    if group == "pet" then return "pet" end
    return "npc"
end

function Config:EnsureHighlightDB(unitDB)
    unitDB.highlight = unitDB.highlight or {}

    local globalTarget = FP.db.nameplates.highlight and FP.db.nameplates.highlight.target or {}

    if unitDB.highlight.enable == nil then
        if globalTarget.enable == nil then unitDB.highlight.enable = true else unitDB.highlight.enable = globalTarget.enable end
    end
    if unitDB.highlight.mode == nil then unitDB.highlight.mode = globalTarget.mode or "HEALTHBAR_ICON" end
    if unitDB.highlight.padding == nil then unitDB.highlight.padding = globalTarget.padding or 7 end
    if unitDB.highlight.alpha == nil then unitDB.highlight.alpha = globalTarget.alpha or 0.92 end

    unitDB.highlight.color = unitDB.highlight.color or {}
    if unitDB.highlight.color.r == nil then unitDB.highlight.color.r = (globalTarget.color and globalTarget.color.r) or 1 end
    if unitDB.highlight.color.g == nil then unitDB.highlight.color.g = (globalTarget.color and globalTarget.color.g) or 1 end
    if unitDB.highlight.color.b == nil then unitDB.highlight.color.b = (globalTarget.color and globalTarget.color.b) or 1 end

    return unitDB.highlight
end

function Config:EnsureOutlineDB(unitDB)
    unitDB.health = unitDB.health or {}
    unitDB.health.outline = unitDB.health.outline or {}
    unitDB.health.outline.color = unitDB.health.outline.color or {r = 0, g = 0, b = 0}

    if unitDB.health.outline.thickness == nil then unitDB.health.outline.thickness = 1 end
    if unitDB.health.outline.growth == nil then unitDB.health.outline.growth = "IN" end

    return unitDB.health.outline
end


function Config:EnsureClassIconOutline(family)
    local icons = FP.db.nameplates.icons
    icons.classIcons = icons.classIcons or {}
    local classDB = icons.classIcons

    classDB.outline = classDB.outline or {}
    classDB.outline.color = classDB.outline.color or {r = 0, g = 0, b = 0}

    classDB.outlines = classDB.outlines or {}
    classDB.outlines[family] = classDB.outlines[family] or {}

    local out = classDB.outlines[family]
    if out.enable == nil then out.enable = classDB.outline.enable == true end
    if out.thickness == nil then out.thickness = classDB.outline.thickness or 1 end
    if out.growth == nil then out.growth = classDB.outline.growth or "IN" end
    out.color = out.color or {}
    if out.color.r == nil then out.color.r = classDB.outline.color.r or 0 end
    if out.color.g == nil then out.color.g = classDB.outline.color.g or 0 end
    if out.color.b == nil then out.color.b = classDB.outline.color.b or 0 end

    return out
end


function Config:BuildGeneral()
    self:ClearPage()
    self:SetPageTitle("General", "Global FruitPlates behavior.")
    local p = self.scrollChild

    self:CreateCheck(p, "Enable FruitPlates", "Disabling hides FruitPlates custom frames without deleting settings.", 22, -28,
        function() return FP.db.nameplates.enable ~= false end,
        function(v) FP.db.nameplates.enable = v end)

    self:CreateDescription(p, "FruitPlates is heavily focused on the |cff36f0b0arena environment|r. Most features rely on trusted unit tokens: arena1-5, arenapets, target, focus, and party/raid members. Due to 3.3.5a client limitations, open-world detection is more limited and usually depends on target, focus, mouseover, or party/raid data.", 22, -102, 560, 11)

    self:CreateDescription(p, "|cffff4444IMPORTANT!!!|r FruitPlates is still in an early public testing stage. Bugs may happen during heavy gameplay or testing, so please report them properly if you find any. Every effort has been made to keep the addon optimized and lightweight. Future builds and updates will be posted in my GitHub repo.", 22, -230, 560, 11)

    p:SetHeight(460)
end



function Config:BuildPlateGroup(title, group, subtitle)
    self:ClearPage()
    self:SetPageTitle(title, subtitle)

    self.plateTabs = self.plateTabs or {}
    local selected = self.plateTabs[group] or "healthbar"
    self.plateTabs[group] = selected

    local p = self.scrollChild
    self:CreateTabs(p, PLATE_TABS, selected, function(tab)
        self.plateTabs[group] = tab
        self:BuildPlateGroup(title, group, subtitle)
    end)

    if group == "enemy" then
        if selected == "healthbar" then
            self:BuildEnemyPlateHealthbarTab()
        elseif selected == "text" then
            self:BuildEnemyPlateTextTab()
        elseif selected == "icons" then
            self:BuildEnemyPlateIconsTab()
        elseif selected == "colors" then
            self:BuildEnemyPlateColorsOutlineTab()
        elseif selected == "highlight" then
            self:BuildEnemyPlateHighlightTab()
        end
        return
    end

    if group == "npcpet" then
        if selected == "healthbar" then
            self:BuildNPCPetHealthbarTab()
        elseif selected == "text" then
            self:BuildNPCPetTextTab()
        elseif selected == "icons" then
            self:BuildNPCPetIconsTab()
        elseif selected == "colors" then
            self:BuildNPCPetColorsOutlineTab()
        elseif selected == "highlight" then
            self:BuildNPCPetHighlightTab()
        end
        return
    end

    if selected == "healthbar" then
        self:BuildPlateHealthbarTab(group)
    elseif selected == "text" then
        self:BuildPlateTextTab(group)
    elseif selected == "icons" then
        self:BuildPlateIconsTab(group)
    elseif selected == "colors" then
        self:BuildPlateColorsOutlineTab(group)
    elseif selected == "highlight" then
        self:BuildPlateHighlightTab(group)
    end
end

function Config:BuildPlateHealthbarTab(group)
    local p = self.scrollChild
    local function each(func) self:ForEachUnit(group, func) end
    local function first() return self:GetUnitDB(group) end

    self:CreateCheck(p, "Enable", nil, 22, -54,
        function() return first().health.enable ~= false end,
        function(v)
            each(function(db)
                db.health.enable = v
            end)
        end)

    local y = -118
    if group == "friendly" then
        self:CreateCheck(p, "Group-Only Friendly Class Styling", nil, 22, -102,
            function() return FP.db.nameplates.groupOnlyFriendlyClassStyling == true end,
            function(v) FP.db.nameplates.groupOnlyFriendlyClassStyling = v end)
        self:CreateDescription(p, "3.3.5a cannot reliably identify open-world friendly nameplates unless they are targeted, mouseovered, or part of your group. This can make friendly class colors/icons appear inconsistently in crowded areas. When enabled, FruitPlates only applies friendly class color and class icons to party/raid units and their pets.", 47, -138, 535)
        y = -250
    end

    local settingsOpen = self:CreatePlateCollapsibleSection(p, group, "Settings", "healthbar.settings", y)
    y = y - 50
    if settingsOpen then
        self:CreateSlider(p, "Width", nil, 24, y - 30, 15, 260, 1,
            function() return first().health.width or 120 end,
            function(v) each(function(db) db.health.width = v; if db.castbar then db.castbar.width = v end end) end)
        self:CreateSlider(p, "Height", nil, 300, y - 30, 4, 34, 1,
            function() return first().health.height or 10 end,
            function(v) each(function(db) db.health.height = v end) end)
        self:CreateDropdown(p, "Texture", nil, 24, y - 112, 190, TEXTURES,
            function() return self:GetHealthbarTexture(first()) end,
            function(v) self:SetHealthbarTextureForGroup(group, v) end)
        y = y - 222
    end

    local colorsOpen = self:CreatePlateCollapsibleSection(p, group, "Colors", "healthbar.colors", y)
    y = y - 50
    if colorsOpen then
        self:CreateCheck(p, "Class Color", nil, 22, y - 28,
            function() return first().health.useClassColor ~= false end,
            function(v) each(function(db) db.health.useClassColor = v; if db.name then db.name.useClassColor = v end end) end)

        if group == "enemy" then
            self:CreateColorPicker(p, "Enemy Player Color", nil, 24, y - 104,
                function() return self:EnsurePlateColor("enemyPlayer", 0.78, 0.25, 0.25) end,
                function(r, g, b)
                    local c = self:EnsurePlateColor("enemyPlayer", 0.78, 0.25, 0.25)
                    c.r, c.g, c.b = r, g, b
                end)
        else
            self:CreateColorPicker(p, "Friendly Player Color", nil, 24, y - 104,
                function() return self:EnsurePlateColor("friendlyPlayer", 0.25, 0.50, 0.95) end,
                function(r, g, b)
                    local c = self:EnsurePlateColor("friendlyPlayer", 0.25, 0.50, 0.95)
                    c.r, c.g, c.b = r, g, b
                end)
        end
        y = y - 240
    end

    p:SetHeight(math.max(360, math.abs(y) + 120))
end

function Config:BuildPlateTextTab(group)
    local p = self.scrollChild
    local function each(func) self:ForEachUnit(group, func) end
    local function first() return self:GetUnitDB(group) end

    self:CreateCheck(p, "Hide Name", nil, 22, -54,
        function() return first().name.enable == false end,
        function(v) each(function(db) db.name.enable = not v end) end)
    self:CreateCheck(p, "Hide Level", nil, 175, -54,
        function() return first().level.enable == false end,
        function(v) each(function(db) db.level.enable = not v end) end)

    local y = -126
    if group == "enemy" then
        self:CreateCheck(p, "Arena Number", "Replace arena player names with 1/2/3/4/5 when mapped.", 330, -54,
            function() return first().name.arenaNumber == true end,
            function(v) each(function(db) db.name.arenaNumber = v end) end)
        y = -150
    end

    local settingsOpen = self:CreatePlateCollapsibleSection(p, group, "Settings", "text.settings", y)
    y = y - 50
    if settingsOpen then
        local nameLabelY = y - 20
        local row1 = nameLabelY - 48
        local row2 = row1 - 74
        local nameColorRow = row2 - 88
        local levelLabelY = nameColorRow - 106
        local row3 = levelLabelY - 48
        local row4 = row3 - 74
        local levelColorRow = row4 - 88

        self:CreateSubDivider(p, "Name Settings", nameLabelY)
        self:CreateSlider(p, "Name Size", nil, 24, row1, 6, 28, 1,
            function() return first().name.fontSize or 11 end,
            function(v) each(function(db) db.name.fontSize = v end) end)
        self:CreateDropdown(p, "Name Anchor", nil, 300, row1, 150, TEXT_ANCHORS,
            function() return first().name.anchor or "LEFT" end,
            function(v) each(function(db) db.name.anchor = v end) end)
        self:CreateSlider(p, "Name X", nil, 24, row2, -100, 100, 1,
            function() return first().name.xOffset or 0 end,
            function(v) each(function(db) db.name.xOffset = v end) end)
        self:CreateSlider(p, "Name Y", "0 is the default text baseline.", 300, row2, -60, 60, 1,
            function() return first().name.yOffset or 0 end,
            function(v) each(function(db) db.name.yOffset = v end) end)
        self:CreateColorPicker(p, "Name Color", nil, 24, nameColorRow,
            function() return self:EnsureTextColor(first().name, 1, 1, 1) end,
            function(r, g, b)
                each(function(db)
                    local c = self:EnsureTextColor(db.name, 1, 1, 1)
                    c.r, c.g, c.b = r, g, b
                end)
            end,
            function() return first().name.inheritPlateColor ~= false end)
        self:CreateCheck(p, "Inherit plate's color", "Uses plate/class color. Off uses Name Color.", 300, nameColorRow,
            function() return first().name.inheritPlateColor ~= false end,
            function(v) each(function(db) db.name.inheritPlateColor = v end) end)

        self:CreateSubDivider(p, "Level Settings", levelLabelY)
        self:CreateSlider(p, "Level Size", nil, 24, row3, 6, 28, 1,
            function() return first().level.fontSize or 10 end,
            function(v) each(function(db) db.level.fontSize = v end) end)
        self:CreateDropdown(p, "Level Anchor", nil, 300, row3, 150, TEXT_ANCHORS,
            function() return first().level.anchor or "RIGHT" end,
            function(v) each(function(db) db.level.anchor = v end) end)
        self:CreateSlider(p, "Level X", nil, 24, row4, -100, 100, 1,
            function() return first().level.xOffset or 0 end,
            function(v) each(function(db) db.level.xOffset = v end) end)
        self:CreateSlider(p, "Level Y", "0 is the default text baseline.", 300, row4, -60, 60, 1,
            function() return first().level.yOffset or 0 end,
            function(v) each(function(db) db.level.yOffset = v end) end)
        self:CreateColorPicker(p, "Level Color", nil, 24, levelColorRow,
            function() return self:EnsureTextColor(first().level, 1, 1, 1) end,
            function(r, g, b)
                each(function(db)
                    local c = self:EnsureTextColor(db.level, 1, 1, 1)
                    c.r, c.g, c.b = r, g, b
                end)
            end)
        y = levelColorRow - 170
    end

    p:SetHeight(math.max(330, math.abs(y) + 120))
end

function Config:BuildPlateIconsTab(group)
    local p = self.scrollChild
    local db = FP.db.nameplates.icons
    db.raidIcons = db.raidIcons or {}
    db.classIcons = db.classIcons or {}

    local family = self:FamilyFromPlateGroup(group)
    local prefix = family

    local function OffsetGet(tbl, axis, default)
        local key = prefix .. axis .. "Offset"
        if tbl[key] ~= nil then return tbl[key] end
        if tbl[axis .. "Offset"] ~= nil then return tbl[axis .. "Offset"] end
        return default
    end

    local function OffsetSet(tbl, axis, value)
        tbl[prefix .. axis .. "Offset"] = value
    end

    self:CreateCheck(p, "Enable Icons", nil, 22, -54,
        function() return db[family] ~= false end,
        function(v) db[family] = v; db.raidIcons[family] = v; db.classIcons[family] = v end)
    self:CreateDropdown(p, "Icon Mode", nil, 210, -54, 190, ICON_MODES,
        function() return db.mode or "RAID" end,
        function(v) db.mode = v end)

    local y = -146
    local raidOpen = self:CreatePlateCollapsibleSection(p, group, "Raid Icon", "icons.raid", y)
    y = y - 70
    if raidOpen then
        self:CreateSlider(p, "Raid Size", nil, 24, y - 10, 8, 48, 1,
            function() return db.raidIcons.size or db.size or 18 end,
            function(v) db.raidIcons.size = v end)
        self:CreateSlider(p, "Raid X", nil, 300, y - 10, -100, 100, 1,
            function() return OffsetGet(db.raidIcons, "X", db.xOffset or 0) end,
            function(v) OffsetSet(db.raidIcons, "X", v) end)
        self:CreateSlider(p, "Raid Y", nil, 24, y - 84, -80, 100, 1,
            function() return OffsetGet(db.raidIcons, "Y", db.yOffset or 10) end,
            function(v) OffsetSet(db.raidIcons, "Y", v) end)
        y = y - 190
    end

    local classOpen = self:CreatePlateCollapsibleSection(p, group, "Class Icon", "icons.class", y)
    y = y - 70
    if classOpen then
        self:CreateSlider(p, "Class Size", nil, 24, y - 10, 8, 48, 1,
            function() return db.classIcons.size or db.size or 18 end,
            function(v) db.classIcons.size = v end)
        self:CreateSlider(p, "Zoom In", nil, 300, y - 10, 0, 20, 1,
            function() return db.classIcons.zoom or 0 end,
            function(v) db.classIcons.zoom = v end)
        self:CreateSlider(p, "Class X", nil, 24, y - 84, -100, 100, 1,
            function() return OffsetGet(db.classIcons, "X", db.xOffset or 0) end,
            function(v) OffsetSet(db.classIcons, "X", v) end)
        self:CreateSlider(p, "Class Y", nil, 300, y - 84, -80, 100, 1,
            function() return OffsetGet(db.classIcons, "Y", db.yOffset or 10) end,
            function(v) OffsetSet(db.classIcons, "Y", v) end)
        y = y - 210
    end

    p:SetHeight(math.max(360, math.abs(y) + 120))
end

function Config:BuildPlateColorsOutlineTab(group)
    local p = self.scrollChild
    local function each(func) self:ForEachUnit(group, func) end
    local function first() return self:GetUnitDB(group) end
    local family = self:FamilyFromPlateGroup(group)
    local iconOutlineLabel = family == "enemy" and "Enemy Icon Outline" or family == "friendly" and "Friendly Icon Outline" or "NPC Icon Outline"

    local y = -54
    local healthOpen = self:CreatePlateCollapsibleSection(p, group, "Healthbar Outline", "outlines.healthbar", y)
    y = y - 70
    if healthOpen then
        self:CreateCheck(p, "Enable Outline", nil, 22, y - 8,
            function() return self:EnsureOutlineDB(first()).enable == true end,
            function(v) each(function(db) self:EnsureOutlineDB(db).enable = v end) end)
        self:CreateDropdown(p, "Growth", nil, 205, y - 8, 150, OUTLINE_GROWTH,
            function() return self:EnsureOutlineDB(first()).growth or "IN" end,
            function(v) each(function(db) self:EnsureOutlineDB(db).growth = v end) end)
        self:CreateSlider(p, "Thickness", nil, 390, y - 31, 0.25, 8, 0.25,
            function() return self:EnsureOutlineDB(first()).thickness or 1 end,
            function(v) each(function(db) self:EnsureOutlineDB(db).thickness = v end) end)
        self:CreateColorPicker(p, "Outline Color", nil, 24, y - 88,
            function() return self:EnsureOutlineDB(first()).color end,
            function(r, g, b)
                each(function(db)
                    local o = self:EnsureOutlineDB(db)
                    o.color.r, o.color.g, o.color.b = r, g, b
                end)
            end)
        y = y - 260
    end

    local iconOpen = self:CreatePlateCollapsibleSection(p, group, iconOutlineLabel, "outlines.icon", y)
    y = y - 70
    if iconOpen then
        self:CreateCheck(p, "Enable Outline", nil, 22, y - 8,
            function() return self:EnsureClassIconOutline(family).enable == true end,
            function(v) self:EnsureClassIconOutline(family).enable = v end)
        self:CreateDropdown(p, "Growth", nil, 205, y - 8, 150, OUTLINE_GROWTH,
            function() return self:EnsureClassIconOutline(family).growth or "IN" end,
            function(v) self:EnsureClassIconOutline(family).growth = v end)
        self:CreateSlider(p, "Thickness", nil, 390, y - 31, 0.25, 8, 0.25,
            function() return self:EnsureClassIconOutline(family).thickness or 1 end,
            function(v) self:EnsureClassIconOutline(family).thickness = v end)
        self:CreateColorPicker(p, "Outline Color", nil, 24, y - 88,
            function() return self:EnsureClassIconOutline(family).color end,
            function(r, g, b)
                local o = self:EnsureClassIconOutline(family)
                o.color.r = r
                o.color.g = g
                o.color.b = b
            end)
        y = y - 260
    end

    p:SetHeight(math.max(330, math.abs(y) + 120))
end

function Config:BuildPlateHighlightTab(group)
    local p = self.scrollChild
    local function each(func) self:ForEachUnit(group, func) end
    local function first() return self:GetUnitDB(group) end
    local function hdb() return self:EnsureHighlightDB(first()) end

    local title = "Target Highlight Color"
    if group == "enemy" then
        title = "Enemy Target Highlight"
    elseif group == "friendly" then
        title = "Friendly Target Highlight"
    elseif group == "npcpet" then
        title = "NPC & Pet Target Highlight"
    end

    self:CreateCheck(p, "Enable Highlight", nil, 22, -54,
        function() return hdb().enable ~= false end,
        function(v) each(function(db) self:EnsureHighlightDB(db).enable = v end) end)

    local y = -126
    local settingsOpen = self:CreatePlateCollapsibleSection(p, group, "Settings", "highlight.settings", y)
    y = y - 70
    if settingsOpen then
        self:CreateDropdown(p, "Highlight Mode", nil, 24, y - 8, 210, HIGHLIGHT_MODES,
            function() return hdb().mode or "HEALTHBAR_ICON" end,
            function(v) each(function(db) self:EnsureHighlightDB(db).mode = v end) end)
        self:CreateSlider(p, "Glow Size", nil, 300, y - 31, 2, 14, 1,
            function() return hdb().padding or 8 end,
            function(v) each(function(db) self:EnsureHighlightDB(db).padding = v end) end)
        self:CreateSlider(p, "Glow Alpha", nil, 24, y - 106, 0.05, 1.0, 0.05,
            function() return hdb().alpha or 0.85 end,
            function(v) each(function(db) self:EnsureHighlightDB(db).alpha = v end) end)
        y = y - 220
    end

    local colorOpen = self:CreatePlateCollapsibleSection(p, group, "Color", "highlight.color", y)
    y = y - 70
    if colorOpen then
        self:CreateColorPicker(p, title, nil, 24, y - 8,
            function() return hdb().color end,
            function(r, g, b)
                each(function(db)
                    local hl = self:EnsureHighlightDB(db)
                    hl.color.r = r
                    hl.color.g = g
                    hl.color.b = b
                end)
            end)
        y = y - 210
    end

    p:SetHeight(math.max(330, math.abs(y) + 120))
end

function Config:BuildNPCPetHealthbarTab()
    local p = self.scrollChild

    local function eachNPC(func) self:ForEachUnit("npc", func) end
    local function eachPet(func) self:ForEachUnit("pet", func) end
    local function npc() return self:GetUnitDB("npc") end
    local function pet() return self:GetUnitDB("pet") end

    self:CreateCheck(p, "Enable NPC Healthbar", nil, 22, -54,
        function() return npc().health.enable ~= false end,
        function(v) eachNPC(function(db) db.health.enable = v end) end)
    self:CreateCheck(p, "Enable Pet Healthbar", nil, 300, -54,
        function() return pet().health.enable ~= false end,
        function(v) eachPet(function(db) db.health.enable = v end) end)

    local y = -126
    local npcOpen = self:CreatePlateCollapsibleSection(p, "npcpet", "NPC Settings", "healthbar.npc", y)
    y = y - 70
    if npcOpen then
        self:CreateSlider(p, "NPC Width", nil, 24, y - 10, 15, 260, 1,
            function() return npc().health.width or 120 end,
            function(v) eachNPC(function(db) db.health.width = v; if db.castbar then db.castbar.width = v end end) end)
        self:CreateSlider(p, "NPC Height", nil, 300, y - 10, 4, 34, 1,
            function() return npc().health.height or 10 end,
            function(v) eachNPC(function(db) db.health.height = v end) end)
        self:CreateDropdown(p, "Texture", nil, 24, y - 82, 190, TEXTURES,
            function() return self:GetHealthbarTexture(npc()) end,
            function(v) eachNPC(function(db) db.health.statusbar = v end) end)
        y = y - 215
    end

    local petOpen = self:CreatePlateCollapsibleSection(p, "npcpet", "Pet Settings", "healthbar.pet", y)
    y = y - 70
    if petOpen then
        self:CreateSlider(p, "Pet Width", nil, 24, y - 10, 15, 260, 1,
            function() return pet().health.width or 110 end,
            function(v) eachPet(function(db) db.health.width = v; if db.castbar then db.castbar.width = v end end) end)
        self:CreateSlider(p, "Pet Height", nil, 300, y - 10, 4, 34, 1,
            function() return pet().health.height or 8 end,
            function(v) eachPet(function(db) db.health.height = v end) end)
        self:CreateDescription(p, "Pet settings only work when FruitPlates knows the plate is really a pet. In arenas, party, or raid this is ALWAYS reliable. In the open world, the old 3.3.5a client often does not tell addons that a visible nameplate is a pet until you target or mouseover it. Until then, friendly pets use Friendly NPC settings and enemy pets use Enemy Plate settings.", 24, y - 82, 540)
        self:CreateDropdown(p, "Texture", nil, 24, y - 162, 190, TEXTURES,
            function() return self:GetHealthbarTexture(pet()) end,
            function(v) eachPet(function(db) db.health.statusbar = v end) end)
        y = y - 295
    end

    local colorsOpen = self:CreatePlateCollapsibleSection(p, "npcpet", "Colors", "healthbar.colors", y)
    y = y - 70
    if colorsOpen then
        self:CreateColorPicker(p, "Enemy NPC Color", nil, 24, y - 8,
            function() return self:EnsurePlateColor("enemyNPC", 0.78, 0.25, 0.25) end,
            function(r, g, b) local c = self:EnsurePlateColor("enemyNPC", 0.78, 0.25, 0.25); c.r, c.g, c.b = r, g, b end)
        self:CreateColorPicker(p, "Friendly NPC Color", nil, 300, y - 8,
            function() return self:EnsurePlateColor("friendlyNPC", 0.25, 0.78, 0.25) end,
            function(r, g, b) local c = self:EnsurePlateColor("friendlyNPC", 0.25, 0.78, 0.25); c.r, c.g, c.b = r, g, b end)
        self:CreateColorPicker(p, "Neutral NPC Color", nil, 24, y - 90,
            function() return self:EnsurePlateColor("neutralNPC", 0.85, 0.70, 0.25) end,
            function(r, g, b) local c = self:EnsurePlateColor("neutralNPC", 0.85, 0.70, 0.25); c.r, c.g, c.b = r, g, b end)
        self:CreateColorPicker(p, "Enemy Pet Color", nil, 300, y - 90,
            function() return self:EnsurePlateColor("enemyPet", 0.78, 0.25, 0.25) end,
            function(r, g, b) local c = self:EnsurePlateColor("enemyPet", 0.78, 0.25, 0.25); c.r, c.g, c.b = r, g, b end)
        self:CreateColorPicker(p, "Friendly Pet Color", nil, 24, y - 172,
            function() return self:EnsurePlateColor("friendlyPet", 0.25, 0.78, 0.25) end,
            function(r, g, b) local c = self:EnsurePlateColor("friendlyPet", 0.25, 0.78, 0.25); c.r, c.g, c.b = r, g, b end)
        y = y - 330
    end

    p:SetHeight(math.max(360, math.abs(y) + 120))
end

function Config:BuildNPCPetTextTab()
    local p = self.scrollChild

    local function eachNPC(func) self:ForEachUnit("npc", func) end
    local function eachPet(func) self:ForEachUnit("pet", func) end
    local function npc() return self:GetUnitDB("npc") end
    local function pet() return self:GetUnitDB("pet") end

    self:CreateCheck(p, "Hide NPC Name", nil, 22, -54,
        function() return npc().name.enable == false end,
        function(v) eachNPC(function(db) db.name.enable = not v end) end)
    self:CreateCheck(p, "Hide NPC Level", nil, 175, -54,
        function() return npc().level.enable == false end,
        function(v) eachNPC(function(db) db.level.enable = not v end) end)
    self:CreateCheck(p, "Crop long names", nil, 328, -54,
        function() return npc().name.cropLongNames == true end,
        function(v) eachNPC(function(db) db.name.cropLongNames = v end) end)

    self:CreateCheck(p, "Hide Pet Name", nil, 22, -102,
        function() return pet().name.enable == false end,
        function(v) eachPet(function(db) db.name.enable = not v end) end)
    self:CreateCheck(p, "Hide Pet Level", nil, 175, -102,
        function() return pet().level.enable == false end,
        function(v) eachPet(function(db) db.level.enable = not v end) end)

    local y = -174
    local npcOpen = self:CreatePlateCollapsibleSection(p, "npcpet", "NPC Text", "text.npc", y)
    y = y - 70
    if npcOpen then
        local nameLabelY = y - 10
        local row1 = nameLabelY - 48
        local row2 = row1 - 74
        local nameColorRow = row2 - 88
        local levelLabelY = nameColorRow - 106
        local row3 = levelLabelY - 48
        local row4 = row3 - 74
        local levelColorRow = row4 - 88

        self:CreateSubDivider(p, "NPC Name Settings", nameLabelY)
        self:CreateSlider(p, "NPC Name Size", nil, 24, row1, 6, 28, 1,
            function() return npc().name.fontSize or 10 end,
            function(v) eachNPC(function(db) db.name.fontSize = v end) end)
        self:CreateDropdown(p, "NPC Name Anchor", nil, 300, row1, 150, TEXT_ANCHORS,
            function() return npc().name.anchor or "LEFT" end,
            function(v) eachNPC(function(db) db.name.anchor = v end) end)
        self:CreateSlider(p, "NPC Name X", nil, 24, row2, -100, 100, 1,
            function() return npc().name.xOffset or 0 end,
            function(v) eachNPC(function(db) db.name.xOffset = v end) end)
        self:CreateSlider(p, "NPC Name Y", nil, 300, row2, -60, 60, 1,
            function() return npc().name.yOffset or 0 end,
            function(v) eachNPC(function(db) db.name.yOffset = v end) end)
        self:CreateColorPicker(p, "NPC Name Color", nil, 24, nameColorRow,
            function() return self:EnsureTextColor(npc().name, 1, 1, 1) end,
            function(r, g, b) eachNPC(function(db) local c = self:EnsureTextColor(db.name, 1, 1, 1); c.r, c.g, c.b = r, g, b end) end,
            function() return npc().name.inheritPlateColor ~= false end)
        self:CreateCheck(p, "Inherit plate's color", "Uses plate/reaction color. Off uses Name Color.", 300, nameColorRow,
            function() return npc().name.inheritPlateColor ~= false end,
            function(v) eachNPC(function(db) db.name.inheritPlateColor = v end) end)
        self:CreateSubDivider(p, "NPC Level Settings", levelLabelY)
        self:CreateSlider(p, "NPC Level Size", nil, 24, row3, 6, 28, 1,
            function() return npc().level.fontSize or 9 end,
            function(v) eachNPC(function(db) db.level.fontSize = v end) end)
        self:CreateSlider(p, "NPC Level X", nil, 300, row3, -100, 100, 1,
            function() return npc().level.xOffset or 0 end,
            function(v) eachNPC(function(db) db.level.xOffset = v end) end)
        self:CreateSlider(p, "NPC Level Y", nil, 24, row4, -60, 60, 1,
            function() return npc().level.yOffset or 0 end,
            function(v) eachNPC(function(db) db.level.yOffset = v end) end)
        self:CreateColorPicker(p, "NPC Level Color", nil, 300, row4,
            function() return self:EnsureTextColor(npc().level, 1, 1, 1) end,
            function(r, g, b) eachNPC(function(db) local c = self:EnsureTextColor(db.level, 1, 1, 1); c.r, c.g, c.b = r, g, b end) end)
        y = levelColorRow - 140
    end

    local petOpen = self:CreatePlateCollapsibleSection(p, "npcpet", "Pet Text", "text.pet", y)
    y = y - 70
    if petOpen then
        local nameLabelY = y - 10
        local row1 = nameLabelY - 48
        local row2 = row1 - 74
        local nameColorRow = row2 - 88
        local levelLabelY = nameColorRow - 106
        local row3 = levelLabelY - 48
        local row4 = row3 - 74
        local levelColorRow = row4 - 88

        self:CreateSubDivider(p, "Pet Name Settings", nameLabelY)
        self:CreateSlider(p, "Pet Name Size", nil, 24, row1, 6, 28, 1,
            function() return pet().name.fontSize or 10 end,
            function(v) eachPet(function(db) db.name.fontSize = v end) end)
        self:CreateDropdown(p, "Pet Name Anchor", nil, 300, row1, 150, TEXT_ANCHORS,
            function() return pet().name.anchor or "LEFT" end,
            function(v) eachPet(function(db) db.name.anchor = v end) end)
        self:CreateSlider(p, "Pet Name X", nil, 24, row2, -100, 100, 1,
            function() return pet().name.xOffset or 0 end,
            function(v) eachPet(function(db) db.name.xOffset = v end) end)
        self:CreateSlider(p, "Pet Name Y", nil, 300, row2, -60, 60, 1,
            function() return pet().name.yOffset or 0 end,
            function(v) eachPet(function(db) db.name.yOffset = v end) end)
        self:CreateColorPicker(p, "Pet Name Color", nil, 24, nameColorRow,
            function() return self:EnsureTextColor(pet().name, 1, 1, 1) end,
            function(r, g, b) eachPet(function(db) local c = self:EnsureTextColor(db.name, 1, 1, 1); c.r, c.g, c.b = r, g, b end) end,
            function() return pet().name.inheritPlateColor ~= false end)
        self:CreateCheck(p, "Inherit plate's color", "Uses plate/reaction color. Off uses Name Color.", 300, nameColorRow,
            function() return pet().name.inheritPlateColor ~= false end,
            function(v) eachPet(function(db) db.name.inheritPlateColor = v end) end)
        self:CreateSubDivider(p, "Pet Level Settings", levelLabelY)
        self:CreateSlider(p, "Pet Level Size", nil, 24, row3, 6, 28, 1,
            function() return pet().level.fontSize or 9 end,
            function(v) eachPet(function(db) db.level.fontSize = v end) end)
        self:CreateSlider(p, "Pet Level X", nil, 300, row3, -100, 100, 1,
            function() return pet().level.xOffset or 0 end,
            function(v) eachPet(function(db) db.level.xOffset = v end) end)
        self:CreateSlider(p, "Pet Level Y", nil, 24, row4, -60, 60, 1,
            function() return pet().level.yOffset or 0 end,
            function(v) eachPet(function(db) db.level.yOffset = v end) end)
        self:CreateColorPicker(p, "Pet Level Color", nil, 300, row4,
            function() return self:EnsureTextColor(pet().level, 1, 1, 1) end,
            function(r, g, b) eachPet(function(db) local c = self:EnsureTextColor(db.level, 1, 1, 1); c.r, c.g, c.b = r, g, b end) end)
        y = levelColorRow - 140
    end

    p:SetHeight(math.max(380, math.abs(y) + 120))
end

function Config:BuildNPCPetIconsTab()
    local p = self.scrollChild
    local db = FP.db.nameplates.icons
    db.raidIcons = db.raidIcons or {}
    db.classIcons = db.classIcons or {}

    self:CreateCheck(p, "Enable NPC Icons", nil, 22, -54,
        function() return db.npc ~= false end,
        function(v) db.npc = v; db.raidIcons.npc = v; db.classIcons.npc = v end)
    self:CreateDropdown(p, "Icon Mode", nil, 210, -54, 190, ICON_MODES,
        function() return db.mode or "RAID" end,
        function(v) db.mode = v end)
    self:CreateCheck(p, "Enable Pet Icons", nil, 22, -102,
        function() return db.pet ~= false end,
        function(v) db.pet = v; db.raidIcons.pet = v; db.classIcons.pet = v end)

    local y = -174
    local npcOpen = self:CreatePlateCollapsibleSection(p, "npcpet", "NPC Icons", "icons.npc", y)
    y = y - 70
    if npcOpen then
        self:CreateSlider(p, "NPC Raid X", nil, 24, y - 10, -100, 100, 1,
            function() return db.raidIcons.npcXOffset or db.raidIcons.xOffset or db.xOffset or 0 end,
            function(v) db.raidIcons.npcXOffset = v end)
        self:CreateSlider(p, "NPC Raid Y", nil, 300, y - 10, -80, 100, 1,
            function() return db.raidIcons.npcYOffset or db.raidIcons.yOffset or db.yOffset or 10 end,
            function(v) db.raidIcons.npcYOffset = v end)
        y = y - 150
    end

    local petOpen = self:CreatePlateCollapsibleSection(p, "npcpet", "Pet Icons", "icons.pet", y)
    y = y - 70
    if petOpen then
        self:CreateSlider(p, "Pet Raid X", nil, 24, y - 10, -100, 100, 1,
            function() return db.raidIcons.petXOffset or db.raidIcons.npcXOffset or db.raidIcons.xOffset or db.xOffset or 0 end,
            function(v) db.raidIcons.petXOffset = v end)
        self:CreateSlider(p, "Pet Raid Y", nil, 300, y - 10, -80, 100, 1,
            function() return db.raidIcons.petYOffset or db.raidIcons.npcYOffset or db.raidIcons.yOffset or db.yOffset or 10 end,
            function(v) db.raidIcons.petYOffset = v end)
        y = y - 150
    end

    local sharedOpen = self:CreatePlateCollapsibleSection(p, "npcpet", "Shared Sizes", "icons.shared", y)
    y = y - 70
    if sharedOpen then
        self:CreateSlider(p, "Raid Size", nil, 24, y - 10, 8, 48, 1,
            function() return db.raidIcons.size or db.size or 18 end,
            function(v) db.raidIcons.size = v end)
        self:CreateSlider(p, "Class Size", nil, 300, y - 10, 8, 48, 1,
            function() return db.classIcons.size or db.size or 18 end,
            function(v) db.classIcons.size = v end)
        y = y - 150
    end

    p:SetHeight(math.max(360, math.abs(y) + 120))
end

function Config:BuildNPCPetColorsOutlineTab()
    local p = self.scrollChild

    local function eachNPC(func) self:ForEachUnit("npc", func) end
    local function eachPet(func) self:ForEachUnit("pet", func) end
    local function npc() return self:GetUnitDB("npc") end
    local function pet() return self:GetUnitDB("pet") end

    local y = -54
    local npcOpen = self:CreatePlateCollapsibleSection(p, "npcpet", "NPC Healthbar Outline", "outlines.npc", y)
    y = y - 70
    if npcOpen then
        self:CreateCheck(p, "Enable NPC Outline", nil, 22, y - 8,
            function() return self:EnsureOutlineDB(npc()).enable == true end,
            function(v) eachNPC(function(db) self:EnsureOutlineDB(db).enable = v end) end)
        self:CreateDropdown(p, "NPC Growth", nil, 205, y - 8, 150, OUTLINE_GROWTH,
            function() return self:EnsureOutlineDB(npc()).growth or "IN" end,
            function(v) eachNPC(function(db) self:EnsureOutlineDB(db).growth = v end) end)
        self:CreateSlider(p, "NPC Thickness", nil, 390, y - 31, 0.25, 8, 0.25,
            function() return self:EnsureOutlineDB(npc()).thickness or 1 end,
            function(v) eachNPC(function(db) self:EnsureOutlineDB(db).thickness = v end) end)
        self:CreateColorPicker(p, "NPC Outline Color", nil, 24, y - 88,
            function() return self:EnsureOutlineDB(npc()).color end,
            function(r, g, b) eachNPC(function(db) local o = self:EnsureOutlineDB(db); o.color.r, o.color.g, o.color.b = r, g, b end) end)
        y = y - 260
    end

    local petOpen = self:CreatePlateCollapsibleSection(p, "npcpet", "Pet Healthbar Outline", "outlines.pet", y)
    y = y - 70
    if petOpen then
        self:CreateCheck(p, "Enable Pet Outline", nil, 22, y - 8,
            function() return self:EnsureOutlineDB(pet()).enable == true end,
            function(v) eachPet(function(db) self:EnsureOutlineDB(db).enable = v end) end)
        self:CreateDropdown(p, "Pet Growth", nil, 205, y - 8, 150, OUTLINE_GROWTH,
            function() return self:EnsureOutlineDB(pet()).growth or "IN" end,
            function(v) eachPet(function(db) self:EnsureOutlineDB(db).growth = v end) end)
        self:CreateSlider(p, "Pet Thickness", nil, 390, y - 31, 0.25, 8, 0.25,
            function() return self:EnsureOutlineDB(pet()).thickness or 1 end,
            function(v) eachPet(function(db) self:EnsureOutlineDB(db).thickness = v end) end)
        self:CreateColorPicker(p, "Pet Outline Color", nil, 24, y - 88,
            function() return self:EnsureOutlineDB(pet()).color end,
            function(r, g, b) eachPet(function(db) local o = self:EnsureOutlineDB(db); o.color.r, o.color.g, o.color.b = r, g, b end) end)
        y = y - 260
    end

    p:SetHeight(math.max(330, math.abs(y) + 120))
end

function Config:BuildNPCPetHighlightTab()
    self:BuildPlateHighlightTab("npcpet")
end


function Config:BuildEnemyPlateHealthbarTab()
    local p = self.scrollChild
    local group = "enemy"
    local function each(func) self:ForEachUnit(group, func) end
    local function first() return self:GetUnitDB(group) end

    self:CreateCheck(p, "Enable", nil, 22, -54,
        function() return first().health.enable ~= false end,
        function(v)
            each(function(db)
                db.health.enable = v
            end)
        end)

    local y = -118
    local settingsOpen = self:CreateEnemyCollapsibleSection(p, "Settings", "healthbar.settings", y)
    y = y - 50
    if settingsOpen then
        self:CreateSlider(p, "Width", nil, 24, y - 30, 15, 260, 1,
            function() return first().health.width or 120 end,
            function(v) each(function(db) db.health.width = v; if db.castbar then db.castbar.width = v end end) end)
        self:CreateSlider(p, "Height", nil, 300, y - 30, 4, 34, 1,
            function() return first().health.height or 10 end,
            function(v) each(function(db) db.health.height = v end) end)
        self:CreateDropdown(p, "Texture", nil, 24, y - 112, 190, TEXTURES,
            function() return self:GetHealthbarTexture(first()) end,
            function(v) self:SetHealthbarTextureForGroup(group, v) end)
        y = y - 222
    end

    local colorsOpen = self:CreateEnemyCollapsibleSection(p, "Colors", "healthbar.colors", y)
    y = y - 50
    if colorsOpen then
        self:CreateCheck(p, "Class Color", nil, 22, y - 30,
            function() return first().health.useClassColor ~= false end,
            function(v) each(function(db) db.health.useClassColor = v; if db.name then db.name.useClassColor = v end end) end)
        self:CreateColorPicker(p, "Enemy Player Color", nil, 24, y - 106,
            function() return self:EnsurePlateColor("enemyPlayer", 0.78, 0.25, 0.25) end,
            function(r, g, b)
                local c = self:EnsurePlateColor("enemyPlayer", 0.78, 0.25, 0.25)
                c.r, c.g, c.b = r, g, b
            end)
        y = y - 296
    end

    p:SetHeight(math.max(360, math.abs(y) + 120))
end

function Config:BuildEnemyPlateTextTab()
    local p = self.scrollChild
    local group = "enemy"
    local function each(func) self:ForEachUnit(group, func) end
    local function first() return self:GetUnitDB(group) end

    self:CreateCheck(p, "Hide Name", nil, 22, -54,
        function() return first().name.enable == false end,
        function(v) each(function(db) db.name.enable = not v end) end)
    self:CreateCheck(p, "Hide Level", nil, 175, -54,
        function() return first().level.enable == false end,
        function(v) each(function(db) db.level.enable = not v end) end)
    self:CreateCheck(p, "Arena Number", "Replace arena player names with 1/2/3/4/5 when mapped.", 330, -54,
        function() return first().name.arenaNumber == true end,
        function(v) each(function(db) db.name.arenaNumber = v end) end)

    local y = -150
    local settingsOpen = self:CreateEnemyCollapsibleSection(p, "Settings", "text.settings", y)
    y = y - 70
    if settingsOpen then
        local nameLabelY = y
        local row1 = nameLabelY - 48
        local row2 = row1 - 74
        local nameColorRow = row2 - 88
        local levelLabelY = nameColorRow - 106
        local row3 = levelLabelY - 48
        local row4 = row3 - 74
        local levelColorRow = row4 - 88

        self:CreateSubDivider(p, "Name Settings", nameLabelY)
        self:CreateSlider(p, "Name Size", nil, 24, row1, 6, 28, 1,
            function() return first().name.fontSize or 11 end,
            function(v) each(function(db) db.name.fontSize = v end) end)
        self:CreateDropdown(p, "Name Anchor", nil, 300, row1, 150, TEXT_ANCHORS,
            function() return first().name.anchor or "LEFT" end,
            function(v) each(function(db) db.name.anchor = v end) end)
        self:CreateSlider(p, "Name X", nil, 24, row2, -100, 100, 1,
            function() return first().name.xOffset or 0 end,
            function(v) each(function(db) db.name.xOffset = v end) end)
        self:CreateSlider(p, "Name Y", "0 is the default text baseline.", 300, row2, -60, 60, 1,
            function() return first().name.yOffset or 0 end,
            function(v) each(function(db) db.name.yOffset = v end) end)
        self:CreateColorPicker(p, "Name Color", nil, 24, nameColorRow,
            function() return self:EnsureTextColor(first().name, 1, 1, 1) end,
            function(r, g, b)
                each(function(db)
                    local c = self:EnsureTextColor(db.name, 1, 1, 1)
                    c.r, c.g, c.b = r, g, b
                end)
            end,
            function() return first().name.inheritPlateColor ~= false end)
        self:CreateCheck(p, "Inherit plate's color", "Uses plate/class color. Off uses Name Color.", 300, nameColorRow,
            function() return first().name.inheritPlateColor ~= false end,
            function(v) each(function(db) db.name.inheritPlateColor = v end) end)

        self:CreateSubDivider(p, "Level Settings", levelLabelY)
        self:CreateSlider(p, "Level Size", nil, 24, row3, 6, 28, 1,
            function() return first().level.fontSize or 10 end,
            function(v) each(function(db) db.level.fontSize = v end) end)
        self:CreateDropdown(p, "Level Anchor", nil, 300, row3, 150, TEXT_ANCHORS,
            function() return first().level.anchor or "RIGHT" end,
            function(v) each(function(db) db.level.anchor = v end) end)
        self:CreateSlider(p, "Level X", nil, 24, row4, -100, 100, 1,
            function() return first().level.xOffset or 0 end,
            function(v) each(function(db) db.level.xOffset = v end) end)
        self:CreateSlider(p, "Level Y", "0 is the default text baseline.", 300, row4, -60, 60, 1,
            function() return first().level.yOffset or 0 end,
            function(v) each(function(db) db.level.yOffset = v end) end)
        self:CreateColorPicker(p, "Level Color", nil, 24, levelColorRow,
            function() return self:EnsureTextColor(first().level, 1, 1, 1) end,
            function(r, g, b)
                each(function(db)
                    local c = self:EnsureTextColor(db.level, 1, 1, 1)
                    c.r, c.g, c.b = r, g, b
                end)
            end)
        y = levelColorRow - 230
    end

    p:SetHeight(math.max(330, math.abs(y) + 120))
end

function Config:BuildEnemyPlateIconsTab()
    local p = self.scrollChild
    local db = FP.db.nameplates.icons
    db.raidIcons = db.raidIcons or {}
    db.classIcons = db.classIcons or {}

    local family = "enemy"
    local prefix = family

    local function OffsetGet(tbl, axis, default)
        local key = prefix .. axis .. "Offset"
        if tbl[key] ~= nil then return tbl[key] end
        if tbl[axis .. "Offset"] ~= nil then return tbl[axis .. "Offset"] end
        return default
    end

    local function OffsetSet(tbl, axis, value)
        tbl[prefix .. axis .. "Offset"] = value
    end

    self:CreateCheck(p, "Enable Icons", nil, 22, -54,
        function() return db[family] ~= false end,
        function(v) db[family] = v; db.raidIcons[family] = v; db.classIcons[family] = v end)
    self:CreateDropdown(p, "Icon Mode", nil, 210, -54, 190, ICON_MODES,
        function() return db.mode or "RAID" end,
        function(v) db.mode = v end)

    local y = -146
    local raidOpen = self:CreateEnemyCollapsibleSection(p, "Raid Icon", "icons.raid", y)
    y = y - 70
    if raidOpen then
        self:CreateSlider(p, "Raid Size", nil, 24, y - 10, 8, 48, 1,
            function() return db.raidIcons.size or db.size or 18 end,
            function(v) db.raidIcons.size = v end)
        self:CreateSlider(p, "Raid X", nil, 300, y - 10, -100, 100, 1,
            function() return OffsetGet(db.raidIcons, "X", db.xOffset or 0) end,
            function(v) OffsetSet(db.raidIcons, "X", v) end)
        self:CreateSlider(p, "Raid Y", nil, 24, y - 84, -80, 100, 1,
            function() return OffsetGet(db.raidIcons, "Y", db.yOffset or 10) end,
            function(v) OffsetSet(db.raidIcons, "Y", v) end)
        y = y - 190
    end

    local classOpen = self:CreateEnemyCollapsibleSection(p, "Class Icon", "icons.class", y)
    y = y - 70
    if classOpen then
        self:CreateSlider(p, "Class Size", nil, 24, y - 10, 8, 48, 1,
            function() return db.classIcons.size or db.size or 18 end,
            function(v) db.classIcons.size = v end)
        self:CreateSlider(p, "Zoom In", nil, 300, y - 10, 0, 20, 1,
            function() return db.classIcons.zoom or 0 end,
            function(v) db.classIcons.zoom = v end)
        self:CreateSlider(p, "Class X", nil, 24, y - 84, -100, 100, 1,
            function() return OffsetGet(db.classIcons, "X", db.xOffset or 0) end,
            function(v) OffsetSet(db.classIcons, "X", v) end)
        self:CreateSlider(p, "Class Y", nil, 300, y - 84, -80, 100, 1,
            function() return OffsetGet(db.classIcons, "Y", db.yOffset or 10) end,
            function(v) OffsetSet(db.classIcons, "Y", v) end)
        y = y - 210
    end

    p:SetHeight(math.max(360, math.abs(y) + 120))
end

function Config:BuildEnemyPlateColorsOutlineTab()
    local p = self.scrollChild
    local group = "enemy"
    local function each(func) self:ForEachUnit(group, func) end
    local function first() return self:GetUnitDB(group) end
    local family = "enemy"

    local y = -54
    local healthOpen = self:CreateEnemyCollapsibleSection(p, "Healthbar Outline", "outlines.healthbar", y)
    y = y - 70
    if healthOpen then
        self:CreateCheck(p, "Enable Outline", nil, 22, y - 8,
            function() return self:EnsureOutlineDB(first()).enable == true end,
            function(v) each(function(db) self:EnsureOutlineDB(db).enable = v end) end)
        self:CreateDropdown(p, "Growth", nil, 205, y - 8, 150, OUTLINE_GROWTH,
            function() return self:EnsureOutlineDB(first()).growth or "IN" end,
            function(v) each(function(db) self:EnsureOutlineDB(db).growth = v end) end)
        self:CreateSlider(p, "Thickness", nil, 390, y - 31, 0.25, 8, 0.25,
            function() return self:EnsureOutlineDB(first()).thickness or 1 end,
            function(v) each(function(db) self:EnsureOutlineDB(db).thickness = v end) end)
        self:CreateColorPicker(p, "Outline Color", nil, 24, y - 88,
            function() return self:EnsureOutlineDB(first()).color end,
            function(r, g, b)
                each(function(db)
                    local o = self:EnsureOutlineDB(db)
                    o.color.r, o.color.g, o.color.b = r, g, b
                end)
            end)
        y = y - 260
    end

    local iconOpen = self:CreateEnemyCollapsibleSection(p, "Enemy Icon Outline", "outlines.icon", y)
    y = y - 70
    if iconOpen then
        self:CreateCheck(p, "Enable Outline", nil, 22, y - 8,
            function() return self:EnsureClassIconOutline(family).enable == true end,
            function(v) self:EnsureClassIconOutline(family).enable = v end)
        self:CreateDropdown(p, "Growth", nil, 205, y - 8, 150, OUTLINE_GROWTH,
            function() return self:EnsureClassIconOutline(family).growth or "IN" end,
            function(v) self:EnsureClassIconOutline(family).growth = v end)
        self:CreateSlider(p, "Thickness", nil, 390, y - 31, 0.25, 8, 0.25,
            function() return self:EnsureClassIconOutline(family).thickness or 1 end,
            function(v) self:EnsureClassIconOutline(family).thickness = v end)
        self:CreateColorPicker(p, "Outline Color", nil, 24, y - 88,
            function() return self:EnsureClassIconOutline(family).color end,
            function(r, g, b)
                local o = self:EnsureClassIconOutline(family)
                o.color.r = r
                o.color.g = g
                o.color.b = b
            end)
        y = y - 260
    end

    p:SetHeight(math.max(330, math.abs(y) + 120))
end

function Config:BuildEnemyPlateHighlightTab()
    local p = self.scrollChild
    local group = "enemy"
    local function each(func) self:ForEachUnit(group, func) end
    local function first() return self:GetUnitDB(group) end
    local function hdb() return self:EnsureHighlightDB(first()) end

    self:CreateCheck(p, "Enable Highlight", nil, 22, -54,
        function() return hdb().enable ~= false end,
        function(v) each(function(db) self:EnsureHighlightDB(db).enable = v end) end)

    local y = -126
    local settingsOpen = self:CreateEnemyCollapsibleSection(p, "Settings", "highlight.settings", y)
    y = y - 70
    if settingsOpen then
        self:CreateDropdown(p, "Highlight Mode", nil, 24, y - 8, 210, HIGHLIGHT_MODES,
            function() return hdb().mode or "HEALTHBAR_ICON" end,
            function(v) each(function(db) self:EnsureHighlightDB(db).mode = v end) end)

        self:CreateSlider(p, "Glow Size", nil, 300, y - 31, 2, 14, 1,
            function() return hdb().padding or 8 end,
            function(v) each(function(db) self:EnsureHighlightDB(db).padding = v end) end)

        self:CreateSlider(p, "Glow Alpha", nil, 24, y - 106, 0.05, 1.0, 0.05,
            function() return hdb().alpha or 0.85 end,
            function(v) each(function(db) self:EnsureHighlightDB(db).alpha = v end) end)
        y = y - 220
    end

    local colorOpen = self:CreateEnemyCollapsibleSection(p, "Color", "highlight.color", y)
    y = y - 70
    if colorOpen then
        self:CreateColorPicker(p, "Enemy Target Highlight", nil, 24, y - 8,
            function() return hdb().color end,
            function(r, g, b)
                each(function(db)
                    local hl = self:EnsureHighlightDB(db)
                    hl.color.r = r
                    hl.color.g = g
                    hl.color.b = b
                end)
            end)
        y = y - 210
    end

    p:SetHeight(math.max(330, math.abs(y) + 120))
end
function Config:BuildEnemyPlates()
    self:BuildPlateGroup("Enemy Plates", "enemy", "Enemy player plate controls.")
end

function Config:BuildFriendlyPlates()
    self:BuildPlateGroup("Friendly Plates", "friendly", "Friendly player plate controls.")
end

function Config:BuildNPCPlates()
    self:BuildPlateGroup("NPC & Pets Plates", "npcpet", "NPC and player pet plate controls.")
end



function Config:BuildCastBar()
    self:ClearPage()
    self:SetPageTitle("Cast Bars", "Cast Bar controls.")

    self.castbarTab = self.castbarTab or "castbar"
    local selected = self.castbarTab
    local p = self.scrollChild

    self:CreateTabs(p, CASTBAR_TABS, selected, function(tab)
        self.castbarTab = tab
        self:BuildCastBar()
    end)

    local function each(func) self:ForEachUnit("all", function(db) if db.castbar then func(db.castbar, db) end end) end
    local function first() return self:GetUnitDB("enemy").castbar end
    local root = FP.db.nameplates

    if selected == "castbar" then
        self:CreateCheck(p, "Enable", nil, 22, -54,
            function() return first().enable ~= false end,
            function(v) each(function(cb) cb.enable = v end) end)
        self:CreateDropdown(p, "Mode", nil, 210, -54, 210, CASTBAR_MODES,
            function() return root.castbarMode or "ENEMY" end,
            function(v) root.castbarMode = v end)

        local y = -118
        local settingsOpen = self:CreateCastbarCollapsibleSection(p, "Settings", "general.settings", y)
        y = y - 70
        if settingsOpen then
            self:CreateSlider(p, "Width", nil, 24, y - 10, 60, 260, 1,
                function() return first().width or 120 end,
                function(v) each(function(cb) cb.width = v end) end)
            self:CreateSlider(p, "Height", nil, 300, y - 10, 3, 28, 1,
                function() return first().height or 8 end,
                function(v) each(function(cb) cb.height = v end) end)
            self:CreateSlider(p, "Cast Bar X", nil, 24, y - 84, -100, 100, 1,
                function() return first().xOffset or 0 end,
                function(v) each(function(cb) cb.xOffset = v end) end)
            self:CreateSlider(p, "Cast Bar Y", nil, 300, y - 84, -80, 80, 1,
                function() return first().yOffset or -4 end,
                function(v) each(function(cb) cb.yOffset = v end) end)
            self:CreateDropdown(p, "Texture", nil, 24, y - 162, 190, TEXTURES,
                function() return root.statusbar or "FurtiPlates Shade" end,
                function(v) root.statusbar = v end)
            y = y - 270
        end

        local testOpen = self:CreateCastbarCollapsibleSection(p, "Test Mode", "general.test", y)
        y = y - 70
        if testOpen then
            self:CreateButton(p, "Start Test", 22, y - 8, 150, 24, function()
                local NP = FP.GetModule and FP:GetModule("NamePlates")
                if NP and NP.StartCastBarTest then
                    NP:StartCastBarTest()
                end
            end)
            self:CreateButton(p, "Stop Test", 205, y - 8, 150, 24, function()
                local NP = FP.GetModule and FP:GetModule("NamePlates")
                if NP and NP.StopCastBarTest then
                    NP:StopCastBarTest()
                end
            end)
            y = y - 120
        end
        p:SetHeight(math.max(340, math.abs(y) + 120))
    elseif selected == "text" then
        self:CreateCheck(p, "Hide Spell Name", nil, 22, -54,
            function() return first().hideSpellName == true end,
            function(v) each(function(cb) cb.hideSpellName = v end) end)
        self:CreateCheck(p, "Hide Cast Duration", nil, 210, -54,
            function() return first().hideTime == true end,
            function(v) each(function(cb) cb.hideTime = v end) end)
        self:CreateCheck(p, "Cast State Text", "Shows Canceled!, Interrupted, and DO NOT KICK inside state-colored castbars.", 22, -104,
            function() return first().showStateText ~= false end,
            function(v) each(function(cb) cb.showStateText = v end) end)

        local y = -188
        local settingsOpen = self:CreateCastbarCollapsibleSection(p, "Settings", "text.settings", y)
        y = y - 70
        if settingsOpen then
            self:CreateSlider(p, "Spell Size", nil, 24, y - 10, 6, 24, 1,
                function() return first().spellNameFontSize or first().fontSize or 9 end,
                function(v) each(function(cb) cb.spellNameFontSize = v end) end)
            self:CreateSlider(p, "Spell X", nil, 300, y - 10, -100, 100, 1,
                function() return first().spellNameOffsetX or 3 end,
                function(v) each(function(cb) cb.spellNameOffsetX = v end) end)
            self:CreateSlider(p, "Spell Y", nil, 24, y - 84, -60, 60, 1,
                function() return first().spellNameOffsetY or 0 end,
                function(v) each(function(cb) cb.spellNameOffsetY = v end) end)
            self:CreateSlider(p, "Time Size", nil, 300, y - 84, 6, 24, 1,
                function() return first().timeFontSize or first().fontSize or 9 end,
                function(v) each(function(cb) cb.timeFontSize = v end) end)
            self:CreateSlider(p, "Time X", nil, 24, y - 158, -100, 100, 1,
                function() return first().timeOffsetX or -3 end,
                function(v) each(function(cb) cb.timeOffsetX = v end) end)
            self:CreateSlider(p, "Time Y", nil, 300, y - 158, -60, 60, 1,
                function() return first().timeOffsetY or 0 end,
                function(v) each(function(cb) cb.timeOffsetY = v end) end)
            y = y - 270
        end

        local stateOpen = self:CreateCastbarCollapsibleSection(p, "Cast State Text", "text.state", y)
        y = y - 70
        if stateOpen then
            self:CreateSlider(p, "State Size", nil, 24, y - 10, 6, 24, 1,
                function() return first().stateTextFontSize or first().spellNameFontSize or first().fontSize or 9 end,
                function(v) each(function(cb) cb.stateTextFontSize = v end) end)
            self:CreateSlider(p, "State X", nil, 300, y - 10, -100, 100, 1,
                function() return first().stateTextOffsetX or 0 end,
                function(v) each(function(cb) cb.stateTextOffsetX = v end) end)
            self:CreateSlider(p, "State Y", nil, 24, y - 84, -60, 60, 1,
                function() return first().stateTextOffsetY or 0 end,
                function(v) each(function(cb) cb.stateTextOffsetY = v end) end)
            y = y - 190
        end
        p:SetHeight(math.max(360, math.abs(y) + 120))
    elseif selected == "icon" then
        self:CreateCheck(p, "Hide Cast Icon", nil, 22, -54,
            function() return first().showIcon == false end,
            function(v) each(function(cb) cb.showIcon = not v end) end)

        local y = -126
        local settingsOpen = self:CreateCastbarCollapsibleSection(p, "Settings", "icon.settings", y)
        y = y - 70
        if settingsOpen then
            self:CreateSlider(p, "Icon Size", nil, 24, y - 10, 6, 48, 1,
                function() return first().iconSize or 16 end,
                function(v) each(function(cb) cb.iconSize = v end) end)
            self:CreateSlider(p, "Icon X", nil, 300, y - 10, -80, 80, 1,
                function() return first().iconOffsetX or -3 end,
                function(v) each(function(cb) cb.iconOffsetX = v end) end)
            self:CreateSlider(p, "Icon Y", nil, 24, y - 84, -60, 60, 1,
                function() return first().iconOffsetY or 0 end,
                function(v) each(function(cb) cb.iconOffsetY = v end) end)
            y = y - 190
        end
        p:SetHeight(math.max(330, math.abs(y) + 120))
    elseif selected == "color" then
        local y = -54
        local colorsOpen = self:CreateCastbarCollapsibleSection(p, "Colors", "color.colors", y)
        y = y - 70
        if colorsOpen then
            self:CreateColorPicker(p, "Cast Bar Color", nil, 24, y - 8,
                function()
                    FP.db.nameplates.colors.castColor = FP.db.nameplates.colors.castColor or {r = 1.00, g = 0.72, b = 0.10}
                    return FP.db.nameplates.colors.castColor
                end,
                function(r, g, b)
                    FP.db.nameplates.colors.castColor = FP.db.nameplates.colors.castColor or {}
                    FP.db.nameplates.colors.castColor.r = r
                    FP.db.nameplates.colors.castColor.g = g
                    FP.db.nameplates.colors.castColor.b = b
                end)

            self:CreateColorPicker(p, "Protected Cast Color", nil, 300, y - 8,
                function()
                    FP.db.nameplates.colors.castProtectedColor = FP.db.nameplates.colors.castProtectedColor or {r = 0.35, g = 0.70, b = 1.00}
                    return FP.db.nameplates.colors.castProtectedColor
                end,
                function(r, g, b)
                    FP.db.nameplates.colors.castProtectedColor = FP.db.nameplates.colors.castProtectedColor or {}
                    FP.db.nameplates.colors.castProtectedColor.r = r
                    FP.db.nameplates.colors.castProtectedColor.g = g
                    FP.db.nameplates.colors.castProtectedColor.b = b
                end)

            self:CreateColorPicker(p, "Canceled Cast Color", nil, 24, y - 156,
                function()
                    FP.db.nameplates.colors.castCanceledColor = FP.db.nameplates.colors.castCanceledColor or {r = 0.55, g = 0.55, b = 0.55}
                    return FP.db.nameplates.colors.castCanceledColor
                end,
                function(r, g, b)
                    FP.db.nameplates.colors.castCanceledColor = FP.db.nameplates.colors.castCanceledColor or {}
                    FP.db.nameplates.colors.castCanceledColor.r = r
                    FP.db.nameplates.colors.castCanceledColor.g = g
                    FP.db.nameplates.colors.castCanceledColor.b = b
                end)

            self:CreateColorPicker(p, "Interrupted Cast Color", nil, 300, y - 156,
                function()
                    FP.db.nameplates.colors.castInterruptedColor = FP.db.nameplates.colors.castInterruptedColor or {r = 1.00, g = 0.12, b = 0.05}
                    return FP.db.nameplates.colors.castInterruptedColor
                end,
                function(r, g, b)
                    FP.db.nameplates.colors.castInterruptedColor = FP.db.nameplates.colors.castInterruptedColor or {}
                    FP.db.nameplates.colors.castInterruptedColor.r = r
                    FP.db.nameplates.colors.castInterruptedColor.g = g
                    FP.db.nameplates.colors.castInterruptedColor.b = b
                end)

            self:CreateSlider(p, "Failed Cast Hold Time", nil, 24, y - 306, 0.10, 1.00, 0.05,
                function() return first().timeToHold or 0.4 end,
                function(v) each(function(cb) cb.timeToHold = v end) end)
            y = y - 430
        end
        p:SetHeight(math.max(330, math.abs(y) + 120))
    elseif selected == "pets" then
        root.petCastBars = root.petCastBars or {}
        self:CreateCheck(p, "Enable", "Master toggle for pet/summon castbars.", 22, -54,
            function() return root.petCastBars.enable ~= false end,
            function(v) root.petCastBars.enable = v end)
        self:CreateCheck(p, "Important pet casts only", "Show lock pets and Gargoyle, hide noisy summons like Mirror Images and Water Elemental.", 22, -138,
            function() return root.petCastBars.importantOnly ~= false end,
            function(v) root.petCastBars.importantOnly = v end)

        p:SetHeight(260)
    end
end

function Config:EnsureAurasDB()
    local db = FP.db.nameplates
    db.auras = db.auras or {}
    db.auras.units = db.auras.units or {}
    db.auras.priority = db.auras.priority or {}
    db.auras.blacklist = db.auras.blacklist or {}
    db.auras.blacklist.spells = db.auras.blacklist.spells or {}
    db.auras.blacklist.names = db.auras.blacklist.names or {}
    if db.auras.showSwipe == nil then db.auras.showSwipe = true end
    if db.auras.swipeAlpha == nil then db.auras.swipeAlpha = 0.55 end

    -- Enemy Buffs&Debuffs now uses the priority layout only.
    -- Drop older row-mode keys so old profiles do not keep stale settings around.
    db.auras.displayStyle = nil
    db.auras.showDebuffs = nil
    db.auras.showBuffs = nil
    db.auras.spells = nil
    db.auras.colorTypes = nil
    db.auras.showOnPlayers = nil
    db.auras.showOnPets = nil
    db.auras.showOnNPC = nil
    db.auras.showOnEnemy = nil
    db.auras.showOnFriend = nil
    db.auras.showOnNeutral = nil

    local units = db.auras.units
    units.enemyPlayer = units.enemyPlayer or {}
    units.enemyPet = units.enemyPet or {}
    if units.enemyPlayer.enable == nil then units.enemyPlayer.enable = true end
    if units.enemyPet.enable == nil then units.enemyPet.enable = true end
    units.friendlyPlayer = nil
    units.friendlyPet = nil
    units.enemyNPC = nil
    units.friendlyNPC = nil
    return db.auras
end

function Config:GetAuraPriorityDB()
    local auras = self:EnsureAurasDB()
    local priority = auras.priority
    priority.useGlow = priority.useGlow ~= false
    priority.center = priority.center or {}
    priority.left = priority.left or {}
    priority.right = priority.right or {}
    priority.bottom = priority.bottom or {}
    return priority
end

function Config:GetAuraPrioritySlotDB(key)
    local priority = self:GetAuraPriorityDB()
    local slot = priority[key] or {}
    priority[key] = slot

    if key == "center" then
        if slot.enable == nil then slot.enable = true end
        if slot.size == nil then slot.size = 30 end
        if slot.xOffset == nil then slot.xOffset = 0 end
        if slot.yOffset == nil then slot.yOffset = 55 end
    elseif key == "left" then
        if slot.enable == nil then slot.enable = true end
        if slot.size == nil then slot.size = 20 end
        if slot.xOffset == nil then slot.xOffset = -5 end
        if slot.yOffset == nil then slot.yOffset = 0 end
    elseif key == "right" then
        if slot.enable == nil then slot.enable = true end
        if slot.size == nil then slot.size = 20 end
        if slot.maxIcons == nil then slot.maxIcons = 2 end
        if slot.spacing == nil then slot.spacing = 2 end
        if slot.xOffset == nil then slot.xOffset = 25 end
        if slot.yOffset == nil then slot.yOffset = 0 end
    else
        if slot.enable == nil then slot.enable = true end
        if slot.size == nil then slot.size = 20 end
        if slot.maxIcons == nil then slot.maxIcons = 6 end
        if slot.spacing == nil then slot.spacing = 2 end
        if slot.xOffset == nil then slot.xOffset = 0 end
        if slot.yOffset == nil then slot.yOffset = 24 end
    end

    if slot.textAnchor == nil then slot.textAnchor = "CENTER" end
    if slot.textX == nil then slot.textX = 0 end
    if slot.textY == nil then slot.textY = 0 end
    return slot
end

function Config:GetAuraUnitDB(key)
    local auras = self:EnsureAurasDB()
    auras.units[key] = auras.units[key] or {}
    local unitDB = auras.units[key]
    return unitDB
end

function Config:EnsureFriendlyAurasDB()
    local db = FP.db.nameplates
    db.friendlyAuras = db.friendlyAuras or {}
    local friendly = db.friendlyAuras

    friendly.units = friendly.units or {}
    friendly.units.friendlyPlayer = friendly.units.friendlyPlayer or {}
    friendly.units.friendlyPet = friendly.units.friendlyPet or {}
    if friendly.units.friendlyPlayer.enable == nil then friendly.units.friendlyPlayer.enable = true end
    if friendly.units.friendlyPet.enable == nil then friendly.units.friendlyPet.enable = true end

    friendly.row = friendly.row or {}
    if friendly.row.enable == nil then friendly.row.enable = true end
    if friendly.row.size == nil then friendly.row.size = 30 end
    if friendly.row.maxIcons == nil then friendly.row.maxIcons = 6 end
    if friendly.row.spacing == nil then friendly.row.spacing = 2 end
    if friendly.row.xOffset == nil then friendly.row.xOffset = 0 end
    if friendly.row.yOffset == nil then friendly.row.yOffset = 18 end
    if friendly.row.textAnchor == nil then friendly.row.textAnchor = "CENTER" end
    if friendly.row.textX == nil then friendly.row.textX = 0 end
    if friendly.row.textY == nil then friendly.row.textY = 0 end
    if friendly.row.durationSize == nil then friendly.row.durationSize = 10 end
    if friendly.row.stackSize == nil then friendly.row.stackSize = 10 end

    friendly.whitelist = friendly.whitelist or {}
    friendly.whitelist.spells = friendly.whitelist.spells or {}
    friendly.whitelist.names = friendly.whitelist.names or {}

    if friendly.enable == nil then friendly.enable = true end
    if friendly.hidePermanent == nil then friendly.hidePermanent = true end
    if friendly.showDuration == nil then friendly.showDuration = true end
    if friendly.showStacks == nil then friendly.showStacks = true end
    if friendly.showDecimals == nil then friendly.showDecimals = true end
    if friendly.colorTransition == nil then friendly.colorTransition = true end
    if friendly.showSwipe == nil then friendly.showSwipe = true end
    if friendly.swipeAlpha == nil then friendly.swipeAlpha = 0.55 end

    return friendly
end

function Config:GetFriendlyAuraUnitDB(key)
    local friendly = self:EnsureFriendlyAurasDB()
    friendly.units[key] = friendly.units[key] or {}
    return friendly.units[key]
end

function Config:BuildPrioritySlotControls(p, key, x, y)
    local firstRowY = y
    self:CreateCheck(p, "Enable", nil, x, firstRowY,
        function() return self:GetAuraPrioritySlotDB(key).enable ~= false end,
        function(v) self:GetAuraPrioritySlotDB(key).enable = v end)
    self:CreateSlider(p, key == "bottom" and "Icon Size" or "Size", nil, x + 300, firstRowY, 10, 72, 1,
        function() return self:GetAuraPrioritySlotDB(key).size or 30 end,
        function(v) self:GetAuraPrioritySlotDB(key).size = v end)

    if key == "bottom" then
        self:CreateSlider(p, "Max Icons", nil, x, y - 74, 1, 12, 1,
            function() return self:GetAuraPrioritySlotDB(key).maxIcons or 6 end,
            function(v) self:GetAuraPrioritySlotDB(key).maxIcons = v end)
        self:CreateSlider(p, "Spacing", nil, x + 300, y - 74, 0, 12, 1,
            function() return self:GetAuraPrioritySlotDB(key).spacing or 2 end,
            function(v) self:GetAuraPrioritySlotDB(key).spacing = v end)
        self:CreateSlider(p, "X Offset", nil, x, y - 156, -120, 120, 1,
            function() return self:GetAuraPrioritySlotDB(key).xOffset or 0 end,
            function(v) self:GetAuraPrioritySlotDB(key).xOffset = v end)
        self:CreateSlider(p, "Y Offset", nil, x + 300, y - 156, -80, 120, 1,
            function() return self:GetAuraPrioritySlotDB(key).yOffset or 24 end,
            function(v) self:GetAuraPrioritySlotDB(key).yOffset = v end)
        self:CreateDropdown(p, "Text Anchor", nil, x, y - 238, 150, AURA_TEXT_ANCHORS,
            function() return self:GetAuraPrioritySlotDB(key).textAnchor or "CENTER" end,
            function(v) self:GetAuraPrioritySlotDB(key).textAnchor = v end)
        self:CreateSlider(p, "Text X", nil, x + 300, y - 238, -40, 40, 1,
            function() return self:GetAuraPrioritySlotDB(key).textX or 0 end,
            function(v) self:GetAuraPrioritySlotDB(key).textX = v end)
        self:CreateSlider(p, "Text Y", nil, x, y - 320, -40, 40, 1,
            function() return self:GetAuraPrioritySlotDB(key).textY or 0 end,
            function(v) self:GetAuraPrioritySlotDB(key).textY = v end)
        self:CreateSlider(p, "Duration Size", nil, x + 300, y - 320, 6, 24, 1,
            function() return self:GetAuraPrioritySlotDB(key).durationSize or 10 end,
            function(v) self:GetAuraPrioritySlotDB(key).durationSize = v end)
        self:CreateSlider(p, "Stack Size", nil, x, y - 402, 6, 24, 1,
            function() return self:GetAuraPrioritySlotDB(key).stackSize or 9 end,
            function(v) self:GetAuraPrioritySlotDB(key).stackSize = v end)
        return y - 510
    elseif key == "right" then
        self:CreateSlider(p, "Max Icons", nil, x, y - 74, 1, 2, 1,
            function() return self:GetAuraPrioritySlotDB(key).maxIcons or 2 end,
            function(v) self:GetAuraPrioritySlotDB(key).maxIcons = v end)
        self:CreateSlider(p, "Spacing", nil, x + 300, y - 74, 0, 12, 1,
            function() return self:GetAuraPrioritySlotDB(key).spacing or 2 end,
            function(v) self:GetAuraPrioritySlotDB(key).spacing = v end)
        self:CreateSlider(p, "X Offset", nil, x, y - 156, -120, 120, 1,
            function() return self:GetAuraPrioritySlotDB(key).xOffset or 25 end,
            function(v) self:GetAuraPrioritySlotDB(key).xOffset = v end)
        self:CreateSlider(p, "Y Offset", nil, x + 300, y - 156, -80, 120, 1,
            function() return self:GetAuraPrioritySlotDB(key).yOffset or 0 end,
            function(v) self:GetAuraPrioritySlotDB(key).yOffset = v end)
        self:CreateDropdown(p, "Text Anchor", nil, x, y - 238, 150, AURA_TEXT_ANCHORS,
            function() return self:GetAuraPrioritySlotDB(key).textAnchor or "CENTER" end,
            function(v) self:GetAuraPrioritySlotDB(key).textAnchor = v end)
        self:CreateSlider(p, "Text X", nil, x + 300, y - 238, -40, 40, 1,
            function() return self:GetAuraPrioritySlotDB(key).textX or 0 end,
            function(v) self:GetAuraPrioritySlotDB(key).textX = v end)
        self:CreateSlider(p, "Text Y", nil, x, y - 320, -40, 40, 1,
            function() return self:GetAuraPrioritySlotDB(key).textY or 0 end,
            function(v) self:GetAuraPrioritySlotDB(key).textY = v end)
        self:CreateSlider(p, "Duration Size", nil, x + 300, y - 320, 6, 24, 1,
            function() return self:GetAuraPrioritySlotDB(key).durationSize or 10 end,
            function(v) self:GetAuraPrioritySlotDB(key).durationSize = v end)
        self:CreateSlider(p, "Stack Size", nil, x, y - 402, 1, 24, 1,
            function() return self:GetAuraPrioritySlotDB(key).stackSize or 1 end,
            function(v) self:GetAuraPrioritySlotDB(key).stackSize = v end)
        return y - 510
    else
        self:CreateSlider(p, "X Offset", nil, x, y - 74, -120, 120, 1,
            function() return self:GetAuraPrioritySlotDB(key).xOffset or 0 end,
            function(v) self:GetAuraPrioritySlotDB(key).xOffset = v end)
        self:CreateSlider(p, "Y Offset", nil, x + 300, y - 74, -80, 120, 1,
            function() return self:GetAuraPrioritySlotDB(key).yOffset or 0 end,
            function(v) self:GetAuraPrioritySlotDB(key).yOffset = v end)
        self:CreateDropdown(p, "Text Anchor", nil, x, y - 156, 150, AURA_TEXT_ANCHORS,
            function() return self:GetAuraPrioritySlotDB(key).textAnchor or "CENTER" end,
            function(v) self:GetAuraPrioritySlotDB(key).textAnchor = v end)
        self:CreateSlider(p, "Text X", nil, x + 300, y - 156, -40, 40, 1,
            function() return self:GetAuraPrioritySlotDB(key).textX or 0 end,
            function(v) self:GetAuraPrioritySlotDB(key).textX = v end)
        self:CreateSlider(p, "Text Y", nil, x, y - 238, -40, 40, 1,
            function() return self:GetAuraPrioritySlotDB(key).textY or 0 end,
            function(v) self:GetAuraPrioritySlotDB(key).textY = v end)
        self:CreateSlider(p, "Duration Size", nil, x + 300, y - 238, 6, 24, 1,
            function() return self:GetAuraPrioritySlotDB(key).durationSize or 10 end,
            function(v) self:GetAuraPrioritySlotDB(key).durationSize = v end)
        self:CreateSlider(p, "Stack Size", nil, x, y - 320, 6, 24, 1,
            function() return self:GetAuraPrioritySlotDB(key).stackSize or 10 end,
            function(v) self:GetAuraPrioritySlotDB(key).stackSize = v end)
        return y - 430
    end
end

function Config:BuildAurasReadmeTab()
    local p = self.scrollChild

    local function ReadmeLegendLine(y, label, text, r, g, b)
        local l = Font(p, label, "GameFontHighlightSmall", 10)
        l:SetPoint("TOPLEFT", p, "TOPLEFT", 24, y)
        l:SetTextColor(r, g, b, 1)

        local eq = Font(p, " = ", "GameFontHighlightSmall", 10, "muted")
        eq:SetPoint("LEFT", l, "RIGHT", 0, 0)

        local d = Font(p, text, "GameFontHighlightSmall", 10, "muted")
        d:SetPoint("LEFT", eq, "RIGHT", 0, 0)
        d:SetWidth(245)
        d:SetJustifyH("LEFT")
        return l, eq, d
    end

    self:CreateDescription(p, "Enemy Buffs&Debuffs uses a priority PvP layout.", 24, -46, 285)

    ReadmeLegendLine(-96, "Center", "crowd control", 1.00, 0.08, 0.05)
    ReadmeLegendLine(-120, "Left", "interrupts and silences", 0.10, 0.18, 0.95)
    ReadmeLegendLine(-144, "Right", "important buffs, defensives, immunities, disarms", 0.10, 0.95, 0.25)
    ReadmeLegendLine(-168, "Bottom", "player-applied auras only", 1.00, 0.90, 0.00)

    local preview = p:CreateTexture(nil, "ARTWORK")
    preview:SetTexture([[Interface\AddOns\FruitPlates\Media\Textures\AuraReadmeLayout.tga]])
    preview:SetTexCoord(0, 423/512, 0, 280/512)
    preview:SetPoint("TOPLEFT", p, "TOPLEFT", 330, -52)
    preview:SetWidth(240)
    preview:SetHeight(159)

    self:CreateDescription(p, "Use the Layout tab to move/resize or completely disable each section.", 24, -222, 560)
    self:CreateDescription(p, "For now, aura priorities are edited manually in:", 24, -272, 560)
    self:CreateDescription(p, "Modules/Nameplates/AuraPriorityData.lua", 24, -296, 560)
    self:CreateDescription(p, "Aura editing will be moved into the GUI in a future build.", 24, -346, 560)
    self:CreateDescription(p, "Use Test Mode in the General tab to preview this layout.", 24, -396, 560)
    p:SetHeight(560)
end

function Config:BuildAurasGeneralTab()
    local p = self.scrollChild
    local db = self:EnsureAurasDB()

    self:CreateCheck(p, "Enable", nil, 22, -46,
        function() return db.enable ~= false end,
        function(v) db.enable = v end)
    self:CreateCheck(p, "Enemy Players", nil, 205, -46,
        function() return self:GetAuraUnitDB("enemyPlayer").enable ~= false end,
        function(v) self:GetAuraUnitDB("enemyPlayer").enable = v end)
    self:CreateCheck(p, "Enemy Pets", nil, 390, -46,
        function() return self:GetAuraUnitDB("enemyPet").enable ~= false end,
        function(v) self:GetAuraUnitDB("enemyPet").enable = v end)

    local y = -118
    local settingsOpen = self:CreateAurasCollapsibleSection(p, "Settings", "general.settings", y)
    y = y - 70
    if settingsOpen then
        self:CreateCheck(p, "Hide Permanent Auras", nil, 22, y - 8,
            function() return db.hidePermanent ~= false end,
            function(v) db.hidePermanent = v end)
        self:CreateCheck(p, "Show Duration", nil, 205, y - 8,
            function() return db.showDuration ~= false end,
            function(v) db.showDuration = v end)
        self:CreateCheck(p, "Show Stacks", nil, 390, y - 8,
            function() return db.showStacks ~= false end,
            function(v) db.showStacks = v end)
        self:CreateCheck(p, "Show Icon Swipe", nil, 22, y - 90,
            function() return db.showSwipe ~= false end,
            function(v) db.showSwipe = v end)
        self:CreateSlider(p, "Swipe Alpha", nil, 205, y - 90, 0.05, 1.00, 0.05,
            function() return db.swipeAlpha or 0.55 end,
            function(v) db.swipeAlpha = v end)
        self:CreateCheck(p, "Use Glow Effects", nil, 22, y - 172,
            function() return self:GetAuraPriorityDB().useGlow ~= false end,
            function(v) self:GetAuraPriorityDB().useGlow = v end)
        self:CreateSlider(p, "Glow Size", nil, 205, y - 172, 0.50, 2.00, 0.05,
            function() return self:GetAuraPriorityDB().glowScale or 1.00 end,
            function(v) self:GetAuraPriorityDB().glowScale = v end)
        self:CreateSlider(p, "Glow Intensity", nil, 205, y - 254, 0.20, 1.00, 0.05,
            function() return self:GetAuraPriorityDB().glowThickness or 0.60 end,
            function(v) self:GetAuraPriorityDB().glowThickness = v end)
        y = y - 360
    end

    local testOpen = self:CreateAurasCollapsibleSection(p, "Test Mode", "general.test", y)
    y = y - 70
    if testOpen then
        self:CreateButton(p, "Start Test", 22, y - 8, 150, 24, function()
            local NP = FP.GetModule and FP:GetModule("NamePlates")
            if NP and NP.StartAuraTest then
                NP:StartAuraTest()
            end
        end)
        self:CreateButton(p, "Stop Test", 205, y - 8, 150, 24, function()
            local NP = FP.GetModule and FP:GetModule("NamePlates")
            if NP and NP.StopAuraTest then
                NP:StopAuraTest()
            end
        end)
        y = y - 120
    end

    p:SetHeight(math.max(340, math.abs(y) + 120))
end

function Config:BuildAurasPriorityLayoutTab()
    local p = self.scrollChild
    local y = -46

    local sections = {
        {title = "Center Icon", key = "center"},
        {title = "Left Interrupt/Silence Icon", key = "left"},
        {title = "Right Icon", key = "right"},
        {title = "Bottom Row", key = "bottom"},
    }

    for i = 1, #sections do
        local info = sections[i]
        local open = self:CreateAurasCollapsibleSection(p, info.title, "layout." .. info.key, y)
        y = y - 70
        if open then
            y = self:BuildPrioritySlotControls(p, info.key, 22, y - 8)
        end
    end

    p:SetHeight(math.max(360, math.abs(y) + 120))
end

function Config:AddAuraBlacklistValue(value)
    value = value and tostring(value) or ""
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    if value == "" then return end

    local db = self:EnsureAurasDB()
    db.blacklist = db.blacklist or {}
    db.blacklist.spells = db.blacklist.spells or {}
    db.blacklist.names = db.blacklist.names or {}

    local id = tonumber(value)
    if id then
        db.blacklist.spells[id] = true
        local name = GetSpellInfo and GetSpellInfo(id)
        if name then db.blacklist.names[string.lower(name)] = true end
    else
        db.blacklist.names[string.lower(value)] = value
    end

    self:RefreshPlates()
    self:BuildAuras()
end

function Config:RemoveAuraBlacklistValue(value)
    value = value and tostring(value) or ""
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    if value == "" then return end

    local db = self:EnsureAurasDB()
    local blacklist = db.blacklist or {}
    blacklist.spells = blacklist.spells or {}
    blacklist.names = blacklist.names or {}

    local id = tonumber(value)
    if id then
        blacklist.spells[id] = nil
        local name = GetSpellInfo and GetSpellInfo(id)
        if name then blacklist.names[string.lower(name)] = nil end
    else
        blacklist.names[string.lower(value)] = nil
    end

    self:RefreshPlates()
    self:BuildAuras()
end

function Config:ClearAuraBlacklist()
    local db = self:EnsureAurasDB()
    db.blacklist = {spells = {}, names = {}}
    self:RefreshPlates()
    self:BuildAuras()
end


function Config:BuildAurasSpellListTab()
    local p = self.scrollChild
    local db = self:EnsureAurasDB()
    local y = -46

    local blacklistOpen = self:CreateAurasCollapsibleSection(p, "Blacklist", "spells.blacklist", y, "Blacklisted auras never show in any of the aura positions.")
    y = y - 88
    if blacklistOpen then
        local input = self:CreateEditBox(p, "Spell ID or exact aura name", 24, y, 220)
        self:CreateButton(p, "Add", 270, y, 78, 22, function()
            self:AddAuraBlacklistValue(input:GetText())
        end)
        self:CreateButton(p, "Remove", 358, y, 90, 22, function()
            self:RemoveAuraBlacklistValue(input:GetText())
        end)
        self:CreateButton(p, "Clear", 458, y, 78, 22, function()
            self:ClearAuraBlacklist()
        end)

        y = y - 50
        local blacklist = db.blacklist or {}
        local shown = 0

        self:CreateDescription(p, "Current blacklist:", 24, y, 540)
        y = y - 24

        if blacklist.spells then
            local ids = {}
            for id in pairs(blacklist.spells) do
                if type(id) == "number" then ids[#ids + 1] = id end
            end
            table.sort(ids)
            for i = 1, #ids do
                local id = ids[i]
                local name = GetSpellInfo and GetSpellInfo(id) or "Unknown"
                self:CreateDescription(p, "  " .. tostring(id) .. "  " .. tostring(name), 24, y, 540)
                y = y - 20
                shown = shown + 1
            end
        end

        if blacklist.names then
            local names = {}
            for key, value in pairs(blacklist.names) do
                names[#names + 1] = tostring(value == true and key or value)
            end
            table.sort(names)
            for i = 1, #names do
                self:CreateDescription(p, "  " .. names[i], 24, y, 540)
                y = y - 20
                shown = shown + 1
            end
        end

        if shown == 0 then
            self:CreateDescription(p, "  empty", 24, y, 540)
            y = y - 20
        end
        y = y - 36
    end

    local listOpen = self:CreateAurasCollapsibleSection(p, "Spell List", "spells.list", y, "Read-only priority aura table from AuraPriorityData.lua.")
    y = y - 88
    if listOpen then
        local data = FP.PriorityAuraData or {}
        local spells = data.spells or {}

        local groupOrder = {
            {label = "Center Icon", types = {"cc", "snare", "roots"}},
            {label = "Left Interrupt / Silence Icon", types = {"lockout", "silence", "interrupts"}},
            {label = "Right Icon", types = {"immunities", "buffs_defensive", "buffs_offensive", "buffs_other", "disarm"}},
            {label = "Bottom Row", types = {"other"}},
        }

        local typeLabel = {
            lockout = "Real Lockouts",
            cc = "CC",
            silence = "Blanket Silences",
            interrupts = "Interrupt Auras",
            snare = "Snare",
            roots = "Roots",
            immunities = "Immunities",
            buffs_defensive = "Defensive Buffs",
            buffs_offensive = "Offensive Buffs",
            buffs_other = "Other Buffs",
            disarm = "Disarm",
            other = "Other / Player Applied",
        }

        local byType = {}
        for spellID, info in pairs(spells) do
            if type(spellID) == "number" and info and info.type then
                byType[info.type] = byType[info.type] or {}
                byType[info.type][#byType[info.type] + 1] = {
                    id = spellID,
                    info = info,
                    name = GetSpellInfo and GetSpellInfo(spellID) or nil,
                }
            end
        end

        for _, list in pairs(byType) do
            table.sort(list, function(a, b)
                local ap = a.info.priority or 100
                local bp = b.info.priority or 100
                if ap ~= bp then return ap < bp end
                return a.id < b.id
            end)
        end

        for gi = 1, #groupOrder do
            local group = groupOrder[gi]
            self:CreateDescription(p, group.label, 24, y, 540)
            y = y - 28

            for ti = 1, #group.types do
                local auraType = group.types[ti]
                local list = byType[auraType] or {}
                self:CreateDescription(p, "  " .. (typeLabel[auraType] or auraType) .. ":", 24, y, 540)
                y = y - 22

                if #list == 0 then
                    self:CreateDescription(p, "    no entries", 24, y, 540)
                    y = y - 20
                else
                    for i = 1, #list do
                        local entry = list[i]
                        local info = entry.info
                        local line = "    " .. tostring(entry.id) .. "  " .. tostring(entry.name or "Unknown")
                            .. "  p" .. tostring(info.priority or 100)
                        if info.highlight then line = line .. "  h" .. tostring(info.highlight) end
                        if info.onlyMine then line = line .. "  mine" end
                        self:CreateDescription(p, line, 24, y, 540)
                        y = y - 20
                    end
                end
                y = y - 8
            end

            y = y - 14
        end
    end

    p:SetHeight(math.max(420, math.abs(y) + 80))
end

function Config:BuildAuras()
    self:ClearPage()
    self:SetPageTitle("Enemy Buffs&Debuffs", "PvP priority aura display for trusted enemy unit frames.")

    self.auraTab = self.auraTab or "readme"
    if self.auraTab == "enemy" or self.auraTab == "friendly" or self.auraTab == "npcpets" then
        self.auraTab = "general"
    end

    local selected = self.auraTab
    local p = self.scrollChild
    self:CreateTabs(p, AURA_TABS, selected, function(tab)
        self.auraTab = tab
        self:BuildAuras()
    end)

    if selected == "readme" then
        self:BuildAurasReadmeTab()
    elseif selected == "priority" then
        self:BuildAurasPriorityLayoutTab()
    elseif selected == "spells" then
        self:BuildAurasSpellListTab()
    else
        self:BuildAurasGeneralTab()
    end
end

function Config:BuildFriendlyAurasReadmeTab()
    local p = self.scrollChild
    self:CreateDescription(p, "Friendly Buffs&Debuffs are whitelist-based.", 24, -46, 560)
    self:CreateDescription(p, "By default, nothing is shown on friendly plates.", 24, -96, 560)
    self:CreateDescription(p, "Add spell IDs or exact aura names to the Whitelist to choose what appears.", 24, -146, 560)
    self:CreateDescription(p, "This keeps friendly plates clean and avoids unnecessary aura spam.", 24, -170, 560)
    self:CreateDescription(p, "Use Layout to position and resize the friendly aura row.", 24, -224, 560)
    self:CreateDescription(p, "Use Test Mode in the General tab to preview the friendly row.", 24, -274, 560)
    p:SetHeight(470)
end

function Config:BuildFriendlyAurasGeneralTab()
    local p = self.scrollChild
    local db = self:EnsureFriendlyAurasDB()

    self:CreateCheck(p, "Enable Friendly Buffs&Debuffs", nil, 22, -46,
        function() return db.enable ~= false end,
        function(v) db.enable = v end)
    self:CreateCheck(p, "Friendly Players", nil, 300, -46,
        function() return self:GetFriendlyAuraUnitDB("friendlyPlayer").enable ~= false end,
        function(v) self:GetFriendlyAuraUnitDB("friendlyPlayer").enable = v end)
    self:CreateCheck(p, "Friendly Pets", nil, 475, -46,
        function() return self:GetFriendlyAuraUnitDB("friendlyPet").enable ~= false end,
        function(v) self:GetFriendlyAuraUnitDB("friendlyPet").enable = v end)

    local y = -118
    local settingsOpen = self:CreateFriendlyAurasCollapsibleSection(p, "Settings", "general.settings", y)
    y = y - 70
    if settingsOpen then
        self:CreateCheck(p, "Hide Permanent Auras", nil, 22, y - 8,
            function() return db.hidePermanent ~= false end,
            function(v) db.hidePermanent = v end)
        self:CreateCheck(p, "Show Duration", nil, 205, y - 8,
            function() return db.showDuration ~= false end,
            function(v) db.showDuration = v end)
        self:CreateCheck(p, "Show Stacks", nil, 390, y - 8,
            function() return db.showStacks ~= false end,
            function(v) db.showStacks = v end)
        self:CreateCheck(p, "Show Icon Swipe", nil, 22, y - 90,
            function() return db.showSwipe ~= false end,
            function(v) db.showSwipe = v end)
        self:CreateSlider(p, "Swipe Alpha", nil, 205, y - 90, 0.05, 1.00, 0.05,
            function() return db.swipeAlpha or 0.55 end,
            function(v) db.swipeAlpha = v end)
        y = y - 200
    end

    local testOpen = self:CreateFriendlyAurasCollapsibleSection(p, "Test Mode", "general.test", y)
    y = y - 70
    if testOpen then
        self:CreateButton(p, "Start Test", 22, y - 8, 150, 24, function()
            local NP = FP.GetModule and FP:GetModule("NamePlates")
            if NP and NP.StartFriendlyAuraTest then
                NP:StartFriendlyAuraTest()
            end
        end)
        self:CreateButton(p, "Stop Test", 205, y - 8, 150, 24, function()
            local NP = FP.GetModule and FP:GetModule("NamePlates")
            if NP and NP.StopFriendlyAuraTest then
                NP:StopFriendlyAuraTest()
            end
        end)
        y = y - 120
    end

    p:SetHeight(math.max(330, math.abs(y) + 120))
end

function Config:BuildFriendlyAurasLayoutTab()
    local p = self.scrollChild
    local db = self:EnsureFriendlyAurasDB()
    local row = db.row

    local y = -46
    local rowOpen = self:CreateFriendlyAurasCollapsibleSection(p, "Friendly Row", "layout.row", y)
    y = y - 70
    if rowOpen then
        self:CreateCheck(p, "Enable Row", nil, 22, y - 8,
            function() return row.enable ~= false end,
            function(v) row.enable = v end)
        self:CreateSlider(p, "Icon Size", nil, 300, y - 8, 10, 72, 1,
            function() return row.size or 30 end,
            function(v) row.size = v end)
        self:CreateSlider(p, "Max Icons", nil, 22, y - 90, 1, 12, 1,
            function() return row.maxIcons or 6 end,
            function(v) row.maxIcons = v end)
        self:CreateSlider(p, "Spacing", nil, 300, y - 90, 0, 12, 1,
            function() return row.spacing or 2 end,
            function(v) row.spacing = v end)
        self:CreateSlider(p, "X Offset", nil, 22, y - 172, -120, 120, 1,
            function() return row.xOffset or 0 end,
            function(v) row.xOffset = v end)
        self:CreateSlider(p, "Y Offset", nil, 300, y - 172, -80, 120, 1,
            function() return row.yOffset or 18 end,
            function(v) row.yOffset = v end)
        self:CreateDropdown(p, "Text Anchor", nil, 24, y - 264, 150, AURA_TEXT_ANCHORS,
            function() return row.textAnchor or "CENTER" end,
            function(v) row.textAnchor = v end)
        self:CreateSlider(p, "Text X", nil, 300, y - 264, -40, 40, 1,
            function() return row.textX or 0 end,
            function(v) row.textX = v end)
        self:CreateSlider(p, "Text Y", nil, 22, y - 346, -40, 40, 1,
            function() return row.textY or 0 end,
            function(v) row.textY = v end)
        self:CreateSlider(p, "Duration Size", nil, 300, y - 346, 6, 24, 1,
            function() return row.durationSize or 10 end,
            function(v) row.durationSize = v end)
        self:CreateSlider(p, "Stack Size", nil, 22, y - 428, 6, 24, 1,
            function() return row.stackSize or 10 end,
            function(v) row.stackSize = v end)
        y = y - 530
    end

    p:SetHeight(math.max(330, math.abs(y) + 120))
end

function Config:AddFriendlyAuraWhitelistValue(value)
    value = value and tostring(value) or ""
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    if value == "" then return end

    local db = self:EnsureFriendlyAurasDB()
    db.whitelist.spells = db.whitelist.spells or {}
    db.whitelist.names = db.whitelist.names or {}

    local id = tonumber(value)
    if id then
        db.whitelist.spells[id] = true
        local name = GetSpellInfo and GetSpellInfo(id)
        if name then db.whitelist.names[string.lower(name)] = true end
    else
        db.whitelist.names[string.lower(value)] = true
    end

    self:RefreshPlates()
    self:BuildFriendlyAuras()
end

function Config:RemoveFriendlyAuraWhitelistValue(value)
    value = value and tostring(value) or ""
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    if value == "" then return end

    local db = self:EnsureFriendlyAurasDB()
    local whitelist = db.whitelist or {}
    whitelist.spells = whitelist.spells or {}
    whitelist.names = whitelist.names or {}

    local id = tonumber(value)
    if id then
        whitelist.spells[id] = nil
        local name = GetSpellInfo and GetSpellInfo(id)
        if name then whitelist.names[string.lower(name)] = nil end
    else
        whitelist.names[string.lower(value)] = nil
    end

    self:RefreshPlates()
    self:BuildFriendlyAuras()
end

function Config:ClearFriendlyAuraWhitelist()
    local db = self:EnsureFriendlyAurasDB()
    db.whitelist = {spells = {}, names = {}}
    self:RefreshPlates()
    self:BuildFriendlyAuras()
end

function Config:BuildFriendlyAurasWhitelistTab()
    local p = self.scrollChild
    local db = self:EnsureFriendlyAurasDB()
    local y = -46
    local open = self:CreateFriendlyAurasCollapsibleSection(p, "Whitelist", "whitelist.main", y, "Only whitelisted friendly auras can show.")
    y = y - 88
    if open then
        local input = self:CreateEditBox(p, "Spell ID or exact aura name", 24, y, 220)
        self:CreateButton(p, "Add", 270, y, 78, 22, function()
            self:AddFriendlyAuraWhitelistValue(input:GetText())
        end)
        self:CreateButton(p, "Remove", 358, y, 90, 22, function()
            self:RemoveFriendlyAuraWhitelistValue(input:GetText())
        end)
        self:CreateButton(p, "Clear", 458, y, 78, 22, function()
            self:ClearFriendlyAuraWhitelist()
        end)

        y = y - 50
        local whitelist = db.whitelist or {}
        local shown = 0

        self:CreateDescription(p, "Current whitelist:", 24, y, 540)
        y = y - 24

        if whitelist.spells then
            local ids = {}
            for id in pairs(whitelist.spells) do
                if type(id) == "number" then ids[#ids + 1] = id end
            end
            table.sort(ids)
            for i = 1, #ids do
                local id = ids[i]
                local name = GetSpellInfo and GetSpellInfo(id) or "Unknown"
                self:CreateDescription(p, "  " .. tostring(id) .. "  " .. tostring(name), 24, y, 540)
                y = y - 20
                shown = shown + 1
            end
        end

        if whitelist.names then
            local names = {}
            for key in pairs(whitelist.names) do
                names[#names + 1] = tostring(key)
            end
            table.sort(names)
            for i = 1, #names do
                self:CreateDescription(p, "  " .. names[i], 24, y, 540)
                y = y - 20
                shown = shown + 1
            end
        end

        if shown == 0 then
            self:CreateDescription(p, "  empty", 24, y, 540)
            y = y - 20
        end
    end

    p:SetHeight(math.max(420, math.abs(y) + 80))
end

function Config:BuildFriendlyAuras()
    self:ClearPage()
    self:SetPageTitle("Friendly Buffs&Debuffs", "Whitelist aura row for trusted friendly unit frames.")

    self.friendlyAuraTab = self.friendlyAuraTab or "readme"
    local selected = self.friendlyAuraTab
    local p = self.scrollChild
    self:CreateTabs(p, FRIENDLY_AURA_TABS, selected, function(tab)
        self.friendlyAuraTab = tab
        self:BuildFriendlyAuras()
    end)

    if selected == "readme" then
        self:BuildFriendlyAurasReadmeTab()
    elseif selected == "general" then
        self:BuildFriendlyAurasGeneralTab()
    elseif selected == "layout" then
        self:BuildFriendlyAurasLayoutTab()
    else
        self:BuildFriendlyAurasWhitelistTab()
    end
end


function Config:EnsureTotemsDB()
    local db = FP.db.nameplates.totems
    db.selected = db.selected or {}
    db.displayMode = db.displayMode or (db.enable == true and "ICONS" or "NAMEPLATES")
    db.nameplate = db.nameplate or {}
    db.nameplate.enemyColor = db.nameplate.enemyColor or {r = 0.55, g = 0.16, b = 0.12}
    db.nameplate.friendlyColor = db.nameplate.friendlyColor or {r = 0.12, g = 0.45, b = 0.14}
    db.nameplate.text = db.nameplate.text or {}
    db.nameplate.text.color = db.nameplate.text.color or {r = 1, g = 1, b = 1}
    db.nameplate.outline = db.nameplate.outline or {}
    db.nameplate.outline.color = db.nameplate.outline.color or {r = 0, g = 0, b = 0}
    db.outline = db.outline or {}
    db.outline.enemyColor = db.outline.enemyColor or {r = 0.90, g = 0.10, b = 0.10}
    db.outline.friendlyColor = db.outline.friendlyColor or {r = 0.10, g = 0.80, b = 0.20}
    return db
end

function Config:BuildTotemsGeneralTab()
    local p = self.scrollChild
    local db = self:EnsureTotemsDB()

    self:CreateCheck(p, "Enable Totem Handling", "If disabled, recognized totems are hidden completely.", 22, -46,
        function() return db.enable ~= false end,
        function(v) db.enable = v end)

    self:CreateDropdown(p, "Display Mode", nil, 24, -124, 170, TOTEM_DISPLAY_MODES,
        function() return db.displayMode or "ICONS" end,
        function(v) db.displayMode = v end)

    p:SetHeight(280)
end

function Config:BuildTotemsIconsTab()
    local p = self.scrollChild
    local db = self:EnsureTotemsDB()

    local y = -54
    local settingsOpen = self:CreateTotemCollapsibleSection(p, "Settings", "icons.settings", y)
    y = y - 70
    if settingsOpen then
        self:CreateSlider(p, "Icon Size", nil, 24, y - 10, 12, 64, 1,
            function() return db.size or 36 end,
            function(v) db.size = v end)
        self:CreateSlider(p, "Icon Alpha", nil, 300, y - 10, 0.05, 1.0, 0.05,
            function() return db.alpha or 0.85 end,
            function(v) db.alpha = v end)
        self:CreateSlider(p, "Icon X", nil, 24, y - 92, -100, 100, 1,
            function() return db.xOffset or 0 end,
            function(v) db.xOffset = v end)
        self:CreateSlider(p, "Icon Y", nil, 300, y - 92, -100, 100, 1,
            function() return db.yOffset or 18 end,
            function(v) db.yOffset = v end)
        y = y - 200
    end

    local outlineOpen = self:CreateTotemCollapsibleSection(p, "Outline", "icons.outline", y)
    y = y - 70
    if outlineOpen then
        self:CreateCheck(p, "Enable Icon Outline", nil, 22, y - 8,
            function() return db.outline.enable ~= false end,
            function(v) db.outline.enable = v end)
        self:CreateDropdown(p, "Icon Growth", nil, 205, y - 8, 150, OUTLINE_GROWTH,
            function() return db.outline.growth or "IN" end,
            function(v) db.outline.growth = v end)
        self:CreateSlider(p, "Icon Thickness", nil, 390, y - 31, 0.25, 8, 0.25,
            function() return db.outline.thickness or 1 end,
            function(v) db.outline.thickness = v end)
        self:CreateColorPicker(p, "Enemy Icon Outline", nil, 24, y - 90,
            function() return db.outline.enemyColor end,
            function(r, g, b)
                db.outline.enemyColor.r = r
                db.outline.enemyColor.g = g
                db.outline.enemyColor.b = b
            end)
        self:CreateColorPicker(p, "Friendly Icon Outline", nil, 300, y - 90,
            function() return db.outline.friendlyColor end,
            function(r, g, b)
                db.outline.friendlyColor.r = r
                db.outline.friendlyColor.g = g
                db.outline.friendlyColor.b = b
            end)
        y = y - 250
    end

    p:SetHeight(math.max(330, math.abs(y) + 120))
end

function Config:BuildTotemsNameplatesTab()
    local p = self.scrollChild
    local db = self:EnsureTotemsDB()

    local y = -54
    local settingsOpen = self:CreateTotemCollapsibleSection(p, "Settings", "nameplates.settings", y)
    y = y - 70
    if settingsOpen then
        self:CreateSlider(p, "Width", nil, 24, y - 10, 20, 180, 1,
            function() return db.nameplate.width or 74 end,
            function(v) db.nameplate.width = v end)
        self:CreateSlider(p, "Height", nil, 300, y - 10, 4, 24, 1,
            function() return db.nameplate.height or 7 end,
            function(v) db.nameplate.height = v end)
        self:CreateSlider(p, "Nameplate X", nil, 24, y - 92, -100, 100, 1,
            function() return db.nameplate.xOffset or 0 end,
            function(v) db.nameplate.xOffset = v end)
        self:CreateSlider(p, "Nameplate Y", nil, 300, y - 92, -100, 100, 1,
            function() return db.nameplate.yOffset or 0 end,
            function(v) db.nameplate.yOffset = v end)
        y = y - 200
    end

    local textOpen = self:CreateTotemCollapsibleSection(p, "Text", "nameplates.text", y)
    y = y - 70
    if textOpen then
        self:CreateCheck(p, "Show Name", nil, 22, y - 8,
            function() return db.nameplate.text.enable ~= false end,
            function(v) db.nameplate.text.enable = v end)
        self:CreateSlider(p, "Name Size", nil, 205, y - 31, 6, 18, 1,
            function() return db.nameplate.text.fontSize or 9 end,
            function(v) db.nameplate.text.fontSize = v end)
        self:CreateSlider(p, "Name X", nil, 24, y - 112, -100, 100, 1,
            function() return db.nameplate.text.xOffset or 0 end,
            function(v) db.nameplate.text.xOffset = v end)
        self:CreateSlider(p, "Name Y", nil, 300, y - 112, -60, 60, 1,
            function() return db.nameplate.text.yOffset or 9 end,
            function(v) db.nameplate.text.yOffset = v end)
        y = y - 220
    end

    local colorsOpen = self:CreateTotemCollapsibleSection(p, "Colors", "nameplates.colors", y)
    y = y - 70
    if colorsOpen then
        self:CreateColorPicker(p, "Enemy Color", nil, 24, y - 8,
            function() return db.nameplate.enemyColor end,
            function(r, g, b)
                db.nameplate.enemyColor.r = r
                db.nameplate.enemyColor.g = g
                db.nameplate.enemyColor.b = b
            end)
        self:CreateColorPicker(p, "Friendly Color", nil, 300, y - 8,
            function() return db.nameplate.friendlyColor end,
            function(r, g, b)
                db.nameplate.friendlyColor.r = r
                db.nameplate.friendlyColor.g = g
                db.nameplate.friendlyColor.b = b
            end)
        self:CreateColorPicker(p, "Name Color", nil, 24, y - 142,
            function() return db.nameplate.text.color end,
            function(r, g, b)
                db.nameplate.text.color.r = r
                db.nameplate.text.color.g = g
                db.nameplate.text.color.b = b
            end)
        y = y - 260
    end

    p:SetHeight(math.max(330, math.abs(y) + 120))
end

function Config:BuildTotemsListTab()
    local p = self.scrollChild
    local db = self:EnsureTotemsDB()

    local y = -54
    local rowGap = 30
    for i = 1, #TOTEM_CONFIG_LIST do
        local info = TOTEM_CONFIG_LIST[i]
        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        local x = col == 0 and 22 or 320
        local rowY = y - 8 - (row * rowGap)
        self:CreateCheck(p, info.label, nil, x, rowY,
            function() return db.selected[info.key] == true end,
            function(v) db.selected[info.key] = v end)
    end
    y = y - 8 - (math.ceil(#TOTEM_CONFIG_LIST / 2) * rowGap) - 40

    p:SetHeight(math.max(330, math.abs(y) + 120))
end

function Config:BuildTotems()
    self:ClearPage()
    self:SetPageTitle("Totems", "Totem controls.")

    self.totemTab = self.totemTab or "general"
    local selected = self.totemTab
    local p = self.scrollChild
    self:CreateTabs(p, TOTEM_TABS, selected, function(tab)
        self.totemTab = tab
        self:BuildTotems()
    end)

    if selected == "icons" then
        self:BuildTotemsIconsTab()
    elseif selected == "nameplates" then
        self:BuildTotemsNameplatesTab()
    elseif selected == "list" then
        self:BuildTotemsListTab()
    else
        self:BuildTotemsGeneralTab()
    end
end

function Config:BuildProfile()
    self:ClearPage()
    self:SetPageTitle("Profile", "Profile tools for the current FruitPlates SavedVariables profile.")
    local p = self.scrollChild
    self:CreateDescription(p, "There is no multi-profile support for now. FruitPlates stores SavedVariables per account, not per character. In the near future, I plan to introduce |cff36f0b0EXPORT and IMPORT|r strings for easier transfer of settings between accounts.", 22, -46, 560, 10)
    self:CreateButton(p, "Reset Current Profile", 22, -132, 170, 24, function()
        FruitPlatesDB.profile = FP:CopyTable(FP.Defaults, {})
        FP:InitializeDatabase()
        self:RefreshPlates()
        self:SelectPage("profile")
        FP:Print("profile reset")
    end)
end

function Config:CreateSidebarButton(parent, item, y)
    if item.header then
        local fs = Font(parent, item.label, "GameFontDisableSmall", 10, "header")
        fs:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, y)
        return nil
    end

    local b = CreateFrame("Button", nil, parent)
    b:SetHeight(24)
    b:SetPoint("TOPLEFT", parent, "TOPLEFT", 8 + ((item.indent or 0) * 12), y)
    b:SetPoint("RIGHT", parent, "RIGHT", -8, 0)

    b.Selected = b:CreateTexture(nil, "BACKGROUND")
    b.Selected:SetTexture([[Interface\Buttons\WHITE8x8]])
    b.Selected:SetAllPoints(b)
    b.Selected:SetVertexColor(0.10, 0.28, 0.22, 0.92)
    b.Selected:Hide()

    b.Hover = b:CreateTexture(nil, "BACKGROUND")
    b.Hover:SetTexture([[Interface\Buttons\WHITE8x8]])
    b.Hover:SetAllPoints(b)
    b.Hover:SetVertexColor(1, 1, 1, 0.06)
    b.Hover:Hide()

    b.Text = Font(b, item.label, "GameFontHighlightSmall", 11)
    b.Text:SetPoint("LEFT", b, "LEFT", 9, 0)

    b:SetScript("OnEnter", function(self) self.Hover:Show() end)
    b:SetScript("OnLeave", function(self) self.Hover:Hide() end)
    b:SetScript("OnClick", function() Config:SelectPage(item.key) end)

    return b
end

function Config:SelectPage(key)
    local selected
    for i = 1, #PAGES do
        if PAGES[i].key == key then selected = PAGES[i] break end
    end
    if not selected or selected.header then return end

    local oldKey = self.selectedKey
    if oldKey ~= key then
        self:ResetCollapse()
    end

    self.selectedKey = key
    for buttonKey, button in pairs(self.sidebarButtons or {}) do
        if buttonKey == key then
            button.Selected:Show()
            button.Text:SetTextColor(0.20, 1.00, 0.72)
        else
            button.Selected:Hide()
            button.Text:SetTextColor(0.82, 0.82, 0.82)
        end
    end

    local builder = selected.builder and self[selected.builder]
    if builder then builder(self) end
end

function Config:CreateWindow()
    if self.window then return self.window end

    local f = CreateFrame("Frame", "FruitPlatesConfigFrame", UIParent)
    f:SetWidth(860)
    f:SetHeight(590)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self) self:StartMoving() end)
    f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    Backdrop(f, 0.03, 0.03, 0.03, 0.97, 1)

    local top = CreateFrame("Frame", nil, f)
    top:SetPoint("TOPLEFT", f, "TOPLEFT", 1, -1)
    top:SetPoint("TOPRIGHT", f, "TOPRIGHT", -1, -1)
    top:SetHeight(46)
    Backdrop(top, 0.055, 0.055, 0.055, 1, 0)

    local logo = Font(top, "FruitPlates", "GameFontNormalLarge", 17, "accent")
    logo:SetPoint("LEFT", top, "LEFT", 16, 0)

    local ver = Font(top, FP.version or "", "GameFontDisableSmall", 10, "muted")
    ver:SetPoint("LEFT", logo, "RIGHT", 10, -2)

    local discordIcon = top:CreateTexture(nil, "ARTWORK")
    discordIcon:SetTexture([[Interface\AddOns\FruitPlates\Media\Branding\discord.tga]])
    discordIcon:SetWidth(14)
    discordIcon:SetHeight(14)
    discordIcon:SetAlpha(0.66)
    discordIcon:SetPoint("RIGHT", top, "RIGHT", -230, 0)

    local discordText = Font(top, "scartino", "GameFontHighlightSmall", 8)
    discordText:SetPoint("LEFT", discordIcon, "RIGHT", 5, 0)

    local githubIcon = top:CreateTexture(nil, "ARTWORK")
    githubIcon:SetTexture([[Interface\AddOns\FruitPlates\Media\Branding\github.tga]])
    githubIcon:SetWidth(14)
    githubIcon:SetHeight(14)
    githubIcon:SetAlpha(0.62)
    githubIcon:SetPoint("LEFT", discordText, "RIGHT", 24, 0)

    local githubText = Font(top, "Fruitdealer1337", "GameFontHighlightSmall", 8)
    githubText:SetPoint("LEFT", githubIcon, "RIGHT", 5, 0)

    local close = CreateFrame("Button", nil, top, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", top, "TOPRIGHT", -5, -5)
    close:SetScript("OnClick", function() f:Hide() end)

    local sidebar = CreateFrame("Frame", nil, f)
    sidebar:SetPoint("TOPLEFT", top, "BOTTOMLEFT", 0, -1)
    sidebar:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 1, 1)
    sidebar:SetWidth(178)
    Backdrop(sidebar, 0.045, 0.045, 0.045, 0.96, 0.65)

    local brandLogo = sidebar:CreateTexture(nil, "ARTWORK")
    brandLogo:SetTexture([[Interface\AddOns\FruitPlates\Media\Branding\FruitArenaPlates_logo.tga]])
    brandLogo:SetWidth(152)
    brandLogo:SetHeight(152)
    brandLogo:SetAlpha(0.58)
    brandLogo:SetPoint("BOTTOM", sidebar, "BOTTOM", 0, 54)

    local author = Font(sidebar, "Author: Fruitdealer1337", "GameFontHighlightSmall", 10, "muted")
    author:SetPoint("TOP", brandLogo, "BOTTOM", 0, -8)
    author:SetJustifyH("CENTER")

    local content = CreateFrame("Frame", nil, f)
    content:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 1, 0)
    content:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -1, 1)
    Backdrop(content, 0.025, 0.025, 0.025, 0.72, 0)

    self.title = Font(content, "General", "GameFontNormalLarge", 18)
    self.title:SetPoint("TOPLEFT", content, "TOPLEFT", 18, -16)

    self.subtitle = Font(content, "", "GameFontHighlightSmall", 10, "muted")
    self.subtitle:SetPoint("TOPLEFT", self.title, "BOTTOMLEFT", 0, -6)
    self.subtitle:SetWidth(620)
    self.subtitle:SetJustifyH("LEFT")

    local line = content:CreateTexture(nil, "ARTWORK")
    line:SetTexture([[Interface\Buttons\WHITE8x8]])
    line:SetPoint("TOPLEFT", content, "TOPLEFT", 18, -62)
    line:SetPoint("TOPRIGHT", content, "TOPRIGHT", -18, -62)
    line:SetHeight(1)
    line:SetVertexColor(0.20, 0.20, 0.20, 1)

    local scroll = CreateFrame("ScrollFrame", "FruitPlatesConfigScrollFrame", content, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", content, "TOPLEFT", 18, -90)
    scroll:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -30, 16)

    local child = CreateFrame("Frame", nil, scroll)
    child:SetWidth(620)
    child:SetHeight(780)
    child.controls = {}
    scroll:SetScrollChild(child)

    self.window = f
    self.sidebar = sidebar
    self.content = content
    self.scrollFrame = scroll
    self.scrollChild = child
    self.sidebarButtons = {}

    local y = -16
    for i = 1, #PAGES do
        local item = PAGES[i]
        local b = self:CreateSidebarButton(sidebar, item, y)
        if b then
            self.sidebarButtons[item.key] = b
            y = y - 28
        else
            y = y - 22
        end
    end

    if ColorPickerFrame and ColorPickerFrame.HookScript and not self.colorPickerKeyboardHooked then
        ColorPickerFrame:HookScript("OnShow", function()
            Config:ReleaseColorPickerKeyboard()
        end)
        self.colorPickerKeyboardHooked = true
    end

    f:Hide()
    return f
end

function Config:Toggle()
    local f = self:CreateWindow()
    if f:IsShown() then
        f:Hide()
    else
        f:Show()
        self:SelectPage(self.selectedKey or "general")
    end
end

function Config:Open()
    local f = self:CreateWindow()
    f:Show()
    self:SelectPage(self.selectedKey or "general")
end


function FP:RegisterBlizzardOptions()
    if self.blizzardOptionsPanel or not InterfaceOptions_AddCategory then return end

    local panel = CreateFrame("Frame", "FruitPlatesBlizzardOptionsPanel")
    panel.name = "FruitPlates"

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -16)
    title:SetText("FruitPlates")

    local note = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    note:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    note:SetWidth(520)
    note:SetJustifyH("LEFT")
    note:SetText("FruitPlates uses its own config window. Use the button below or type /fp.")

    local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    button:SetWidth(190)
    button:SetHeight(24)
    button:SetPoint("TOPLEFT", note, "BOTTOMLEFT", 0, -18)
    button:SetText("Open FruitPlates Config")
    button:SetScript("OnClick", function()
        -- Opened from Interface -> AddOns. Close Blizzard panels so only FruitPlates stays visible.
        if InterfaceOptionsFrame then
            if HideUIPanel then HideUIPanel(InterfaceOptionsFrame) else InterfaceOptionsFrame:Hide() end
        end
        if GameMenuFrame then
            if HideUIPanel then HideUIPanel(GameMenuFrame) else GameMenuFrame:Hide() end
        end
        if CloseMenus then CloseMenus() end
        if HideDropDownMenu then HideDropDownMenu(1) end

        FP:OpenConfig()
    end)

    InterfaceOptions_AddCategory(panel)
    self.blizzardOptionsPanel = panel
end

function FP:ToggleConfig()
    Config:Toggle()
end

function FP:OpenConfig()
    Config:Open()
end
