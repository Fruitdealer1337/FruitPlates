local FP = _G.FruitPlates
local NP = FP:GetModule("NamePlates")

-- File-local because Lua locals in Nameplates.lua are not visible from this chunk.
local NONTOTEM_RECHECK_INTERVAL = 0.25

local function TotemName(spellID, suffix, fallback)
    local name = GetSpellInfo and GetSpellInfo(spellID) or nil
    if not name or name == "" then name = fallback end
    if suffix and suffix ~= "" then
        return name .. suffix
    end
    return name
end

-- Keep this list local and explicit. The key is stable for SavedVariables,
-- while name is localized through GetSpellInfo when available.
local TOTEM_LIST = {
    {key = "CLEANSING", spellID = 8170, fallback = "Cleansing Totem", icon = [[Interface\Icons\Spell_nature_diseasecleansingtotem]]},
    {key = "EARTHBIND", spellID = 2484, fallback = "Earthbind Totem", icon = [[Interface\Icons\Spell_nature_strengthofearthtotem02]]},
    {key = "GROUNDING", spellID = 8177, fallback = "Grounding Totem", icon = [[Interface\Icons\Spell_nature_groundingtotem]]},
    {key = "TREMOR", spellID = 8143, fallback = "Tremor Totem", icon = [[Interface\Icons\Spell_nature_tremortotem]]},
    {key = "MANA_TIDE", spellID = 16190, fallback = "Mana Tide Totem", icon = [[Interface\Icons\Spell_frost_summonwaterelemental]]},
    {key = "MANA_SPRING", spellID = 58774, suffix = " VIII", fallback = "Mana Spring Totem", icon = [[Interface\Icons\Spell_nature_manaregentotem]]},
    {key = "MAGMA", spellID = 58734, suffix = " VII", fallback = "Magma Totem", icon = [[Interface\Icons\Spell_fire_selfdestruct]]},
    {key = "FIRE_RESISTANCE", spellID = 58739, suffix = " VI", fallback = "Fire Resistance Totem", icon = [[Interface\Icons\Spell_fireresistancetotem_01]]},
    {key = "FLAMETONGUE", spellID = 58656, suffix = " VIII", fallback = "Flametongue Totem", icon = [[Interface\Icons\Spell_nature_guardianward]]},
    {key = "FROST_RESISTANCE", spellID = 58745, suffix = " VI", fallback = "Frost Resistance Totem", icon = [[Interface\Icons\Spell_frostresistancetotem_01]]},
    {key = "HEALING_STREAM", spellID = 58757, suffix = " IX", fallback = "Healing Stream Totem", icon = [[Interface\Icons\Inv_spear_04]]},
    {key = "NATURE_RESISTANCE", spellID = 58749, suffix = " VI", fallback = "Nature Resistance Totem", icon = [[Interface\Icons\Spell_nature_natureresistancetotem]]},
    {key = "SEARING", spellID = 58704, suffix = " X", fallback = "Searing Totem", icon = [[Interface\Icons\Spell_fire_searingtotem]]},
    {key = "SENTRY", spellID = 6495, fallback = "Sentry Totem", icon = [[Interface\Icons\Spell_nature_removecurse]]},
    {key = "STONECLAW", spellID = 58582, suffix = " X", fallback = "Stoneclaw Totem", icon = [[Interface\Icons\Spell_nature_stoneclawtotem]]},
    {key = "STONESKIN", spellID = 58753, suffix = " X", fallback = "Stoneskin Totem", icon = [[Interface\Icons\Spell_nature_stoneskintotem]]},
    {key = "STRENGTH_OF_EARTH", spellID = 58643, suffix = " VIII", fallback = "Strength of Earth Totem", icon = [[Interface\Icons\Spell_nature_earthbindtotem]]},
    {key = "TOTEM_OF_WRATH", spellID = 57722, suffix = " IV", fallback = "Totem of Wrath", icon = [[Interface\Icons\Spell_fire_totemofwrath]]},
    {key = "WINDFURY", spellID = 8512, fallback = "Windfury Totem", icon = [[Interface\Icons\Spell_nature_windfury]]},
    {key = "WRATH_OF_AIR", spellID = 3738, fallback = "Wrath of Air Totem", icon = [[Interface\Icons\Spell_nature_slowingtotem]]},
    {key = "EARTH_ELEMENTAL", spellID = 2062, fallback = "Earth Elemental Totem", icon = [[Interface\Icons\Spell_nature_earthelemental_totem]]},
    {key = "FIRE_ELEMENTAL", spellID = 2894, fallback = "Fire Elemental Totem", icon = [[Interface\Icons\Spell_fire_elemental_totem]]},
}

NP.TotemList = TOTEM_LIST
NP.TotemNameToInfo = NP.TotemNameToInfo or {}

function NP:RebuildTotemNameMap()
    local map = self.TotemNameToInfo
    if wipe then wipe(map) else for k in pairs(map) do map[k] = nil end end

    for i = 1, #TOTEM_LIST do
        local info = TOTEM_LIST[i]
        local name = TotemName(info.spellID, info.suffix, info.fallback)
        info.name = name
        if name and name ~= "" then
            map[name] = info
        end
        -- Also accept the fallback without rank in case the server/client reports a shorter plate name.
        if info.fallback and info.fallback ~= name then
            map[info.fallback] = info
        end
    end
end

function NP:GetTotemInfoByName(name)
    if not name or name == "" then return nil end
    if not self.TotemNameToInfo or not next(self.TotemNameToInfo) then
        self:RebuildTotemNameMap()
    end
    return self.TotemNameToInfo[name]
end

local function HideElement(element)
    if element and element.Hide then element:Hide() end
end

local function SetTotemTextureGroupShown(texture, shown)
    if not texture then return end

    if shown then
        if texture.Show then texture:Show() end
        if texture.backdrop and texture.backdrop.Show then texture.backdrop:Show() end
        if texture.bordertop and texture.bordertop.Show then texture.bordertop:Show() end
        if texture.borderbottom and texture.borderbottom.Show then texture.borderbottom:Show() end
        if texture.borderleft and texture.borderleft.Show then texture.borderleft:Show() end
        if texture.borderright and texture.borderright.Show then texture.borderright:Show() end
    else
        if texture.Hide then texture:Hide() end
        if texture.TargetGlow and texture.TargetGlow.Hide then texture.TargetGlow:Hide() end
        if texture.OutlineTop and texture.OutlineTop.Hide then texture.OutlineTop:Hide() end
        if texture.OutlineBottom and texture.OutlineBottom.Hide then texture.OutlineBottom:Hide() end
        if texture.OutlineLeft and texture.OutlineLeft.Hide then texture.OutlineLeft:Hide() end
        if texture.OutlineRight and texture.OutlineRight.Hide then texture.OutlineRight:Hide() end
        if texture.backdrop and texture.backdrop.Hide then texture.backdrop:Hide() end
        if texture.bordertop and texture.bordertop.Hide then texture.bordertop:Hide() end
        if texture.borderbottom and texture.borderbottom.Hide then texture.borderbottom:Hide() end
        if texture.borderleft and texture.borderleft.Hide then texture.borderleft:Hide() end
        if texture.borderright and texture.borderright.Hide then texture.borderright:Hide() end
    end
end

function NP:HideTotemIcon(frame)
    if frame and frame.TotemIcon then
        SetTotemTextureGroupShown(frame.TotemIcon, false)
    end
end

function NP:HideTotemPlateElements(frame)
    HideElement(frame.Health)
    HideElement(frame.Name)
    HideElement(frame.Level)
    HideElement(frame.CastBar)
    HideElement(frame.Auras)
    HideElement(frame.Highlight)
    if frame.Highlight and frame.Highlight.HealthGlow then frame.Highlight.HealthGlow:Hide() end
    if frame.Highlight and frame.Highlight.IconGlow then frame.Highlight.IconGlow:Hide() end
    if frame.Highlight and frame.Highlight.TargetGlow then frame.Highlight.TargetGlow:Hide() end
    if frame.ClassIcon then frame.ClassIcon:Hide() end
    if frame.RaidIcon and frame.RaidIcon.SetAlpha then frame.RaidIcon:SetAlpha(0) end
end



local function GetTotemDisplayMode(db)
    if not db then return "ICONS" end
    return db.displayMode or (db.enable == true and "ICONS" or "NAMEPLATES")
end

function NP:ApplyTotemNameplate(frame, info, db)
    if not frame or not frame.Health then return end

    local plateDB = db.nameplate or {}
    plateDB.enemyColor = plateDB.enemyColor or {r = 0.55, g = 0.16, b = 0.12}
    plateDB.friendlyColor = plateDB.friendlyColor or {r = 0.12, g = 0.45, b = 0.14}
    plateDB.text = plateDB.text or {}
    plateDB.text.color = plateDB.text.color or {r = 1, g = 1, b = 1}
    plateDB.outline = plateDB.outline or {}
    plateDB.outline.color = plateDB.outline.color or {r = 0, g = 0, b = 0}

    if frame.TotemIcon then
        SetTotemTextureGroupShown(frame.TotemIcon, false)
    end

    frame.showTotemIcon = nil
    frame.showTotemNameplate = true

    HideElement(frame.CastBar)
    HideElement(frame.Highlight)
    if frame.Highlight and frame.Highlight.HealthGlow then frame.Highlight.HealthGlow:Hide() end
    if frame.Highlight and frame.Highlight.IconGlow then frame.Highlight.IconGlow:Hide() end
    if frame.ClassIcon then frame.ClassIcon:Hide() end
    if frame.RaidIcon and frame.RaidIcon.SetAlpha then frame.RaidIcon:SetAlpha(0) end
    HideElement(frame.Level)

    local health = frame.Health
    health:ClearAllPoints()
    health:SetPoint("CENTER", frame, "CENTER", plateDB.xOffset or 0, plateDB.yOffset or 0)
    health:SetWidth(plateDB.width or 74)
    health:SetHeight(plateDB.height or 7)
    health:SetMinMaxValues(0, 1)
    health:SetValue(1)

    local c
    if frame.UnitReaction and frame.UnitReaction > 4 then
        c = plateDB.friendlyColor
    else
        c = plateDB.enemyColor
    end
    health:SetStatusBarColor(c.r or 1, c.g or 1, c.b or 1)
    if not health:IsShown() then health:Show() end

    -- Nameplate-mode outline is intentionally disabled for now. Keep the mini plate clean.
    if health.OutlineTop then health.OutlineTop:Hide() end
    if health.OutlineBottom then health.OutlineBottom:Hide() end
    if health.OutlineLeft then health.OutlineLeft:Hide() end
    if health.OutlineRight then health.OutlineRight:Hide() end

    local textDB = plateDB.text or {}
    if textDB.enable ~= false and frame.Name then
        local text = info.name or info.fallback or frame.UnitName or ""
        if frame.Name._fruitplatesText ~= text then
            frame.Name:SetText(text)
            frame.Name._fruitplatesText = text
        end
        frame.Name:ClearAllPoints()
        frame.Name:SetPoint("BOTTOM", health, "TOP", textDB.xOffset or 0, textDB.yOffset or 9)
        frame.Name:SetJustifyH("CENTER")
        FP:FontTemplate(frame.Name, FP:FetchMedia("font", textDB.font or "Default"), textDB.fontSize or 9, textDB.fontOutline or "OUTLINE")
        local tc = textDB.color or {r = 1, g = 1, b = 1}
        frame.Name:SetTextColor(tc.r or 1, tc.g or 1, tc.b or 1)
        if frame.Name.SetDrawLayer then frame.Name:SetDrawLayer("OVERLAY", 7) end
        if not frame.Name:IsShown() then frame.Name:Show() end
    else
        HideElement(frame.Name)
    end
end


function NP:ApplyTotemOutline(frame, iconFrame, db)
    if not iconFrame then return end

    local outline = db and db.outline or {}
    local enabled = outline.enable ~= false
    local t = tonumber(outline.thickness) or 1

    if t < 0.25 then t = 0.25 end
    if t > 8 then t = 8 end

    local function HideOutline()
        if iconFrame.OutlineTop then iconFrame.OutlineTop:Hide() end
        if iconFrame.OutlineBottom then iconFrame.OutlineBottom:Hide() end
        if iconFrame.OutlineLeft then iconFrame.OutlineLeft:Hide() end
        if iconFrame.OutlineRight then iconFrame.OutlineRight:Hide() end
    end

    if not enabled then
        HideOutline()
        return
    end

    local color
    if frame.UnitReaction and frame.UnitReaction > 4 then
        color = outline.friendlyColor or {r = 0.10, g = 0.80, b = 0.20}
    else
        color = outline.enemyColor or {r = 0.90, g = 0.10, b = 0.10}
    end

    local r, g, b = color.r or 1, color.g or 1, color.b or 1

    -- Keep the icon below the outline. Reassert this every time because these
    -- raw plate textures are reused by Blizzard nameplates after resummon/reload.
    if iconFrame.SetDrawLayer then iconFrame:SetDrawLayer("OVERLAY", 4) end

    local function RaiseOutline(tex)
        if tex and tex.SetDrawLayer then
            tex:SetDrawLayer("OVERLAY", 7)
        end
    end

    RaiseOutline(iconFrame.OutlineTop)
    RaiseOutline(iconFrame.OutlineBottom)
    RaiseOutline(iconFrame.OutlineLeft)
    RaiseOutline(iconFrame.OutlineRight)

    local growth = outline.growth or "IN"
    local outward = growth == "OUT"

    local x1, y1, x2, y2 = 0, 0, 0, 0
    if outward then
        x1, y1, x2, y2 = -t, t, t, -t
    end

    iconFrame.OutlineTop:ClearAllPoints()
    iconFrame.OutlineTop:SetPoint("TOPLEFT", iconFrame, "TOPLEFT", x1, y1)
    iconFrame.OutlineTop:SetPoint("TOPRIGHT", iconFrame, "TOPRIGHT", x2, y1)
    iconFrame.OutlineTop:SetHeight(t)
    iconFrame.OutlineTop:SetTexture(r, g, b, 1)
    iconFrame.OutlineTop:Show()

    iconFrame.OutlineBottom:ClearAllPoints()
    iconFrame.OutlineBottom:SetPoint("BOTTOMLEFT", iconFrame, "BOTTOMLEFT", x1, y2)
    iconFrame.OutlineBottom:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", x2, y2)
    iconFrame.OutlineBottom:SetHeight(t)
    iconFrame.OutlineBottom:SetTexture(r, g, b, 1)
    iconFrame.OutlineBottom:Show()

    iconFrame.OutlineLeft:ClearAllPoints()
    iconFrame.OutlineLeft:SetPoint("TOPLEFT", iconFrame, "TOPLEFT", x1, y1)
    iconFrame.OutlineLeft:SetPoint("BOTTOMLEFT", iconFrame, "BOTTOMLEFT", x1, y2)
    iconFrame.OutlineLeft:SetWidth(t)
    iconFrame.OutlineLeft:SetTexture(r, g, b, 1)
    iconFrame.OutlineLeft:Show()

    iconFrame.OutlineRight:ClearAllPoints()
    iconFrame.OutlineRight:SetPoint("TOPRIGHT", iconFrame, "TOPRIGHT", x2, y1)
    iconFrame.OutlineRight:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", x2, y2)
    iconFrame.OutlineRight:SetWidth(t)
    iconFrame.OutlineRight:SetTexture(r, g, b, 1)
    iconFrame.OutlineRight:Show()
end

function NP:Update_TotemIcon(frame)
    if not frame then return false end

    local db = self.db and self.db.totems
    local iconFrame = frame.TotemIcon

    if not db or db.enable == false then
        local info = self:GetTotemInfoByName(frame.UnitName)
        if info then
            self:HideTotemPlateElements(frame)
            if iconFrame then SetTotemTextureGroupShown(iconFrame, false) end
            frame._fruitplatesTotemKey = "disabled:hidden:" .. (info.key or "")
            frame.isTotemPlate = true
            frame.showTotemIcon = nil
            frame.showTotemNameplate = nil
            return true
        end

        if frame._fruitplatesTotemKey ~= "none" and iconFrame then
            SetTotemTextureGroupShown(iconFrame, false)
        end
        frame._fruitplatesTotemKey = "none"
        frame.isTotemPlate = nil
        frame.showTotemIcon = nil
        frame.showTotemNameplate = nil
        return false
    end

    local now = GetTime and GetTime() or 0
    if frame._fruitplatesKnownNonTotem and frame._fruitplatesNextTotemCheck and now < frame._fruitplatesNextTotemCheck then
        return false
    end

    local info = self:GetTotemInfoByName(frame.UnitName)
    if not info then
        frame._fruitplatesKnownNonTotem = true
        frame._fruitplatesNextTotemCheck = now + NONTOTEM_RECHECK_INTERVAL
        if frame._fruitplatesTotemKey ~= "none" and iconFrame then
            SetTotemTextureGroupShown(iconFrame, false)
        end
        frame._fruitplatesTotemKey = "none"
        frame.isTotemPlate = nil
        frame.showTotemIcon = nil
        frame.showTotemNameplate = nil
        return false
    end

    frame._fruitplatesKnownNonTotem = nil
    frame._fruitplatesNextTotemCheck = nil

    frame.isTotemPlate = true
    local mode = GetTotemDisplayMode(db)

    -- Totems keep alpha for clickability, but must not mutate the raw Blizzard
    -- nameplate strata/framelevel. That native mutation was confirmed to cause
    -- framegaps during active-target/nameplate churn.
    local rawPlate = frame:GetParent()
    if rawPlate and rawPlate.SetAlpha and (not rawPlate.GetAlpha or rawPlate:GetAlpha() ~= 1) then rawPlate:SetAlpha(1) end
    -- Do not touch raw Blizzard plate strata/framelevel. This native mutation
    -- was confirmed to cause client-side framegaps during plate churn.

    if mode == "NAMEPLATES" then
        self:ApplyTotemNameplate(frame, info, db)
        frame._fruitplatesTotemKey = "nameplate:" .. (info.key or "")
        return true
    end

    if mode == "HIDDEN" then
        self:HideTotemPlateElements(frame)
        if iconFrame then SetTotemTextureGroupShown(iconFrame, false) end
        frame._fruitplatesTotemKey = "hidden:" .. (info.key or "")
        frame.showTotemIcon = nil
        frame.showTotemNameplate = nil
        return true
    end

    self:HideTotemPlateElements(frame)

    local selected = db.selected or {}
    if selected[info.key] ~= true then
        -- Known but unchecked totem: hide the plate completely in Icon mode.
        if frame._fruitplatesTotemKey ~= info.key .. ":hidden" and iconFrame then
            SetTotemTextureGroupShown(iconFrame, false)
        end
        frame._fruitplatesTotemKey = info.key .. ":hidden"
        frame.showTotemIcon = nil
        frame.showTotemNameplate = nil
        return true
    end

    if not iconFrame then return true end
    frame.showTotemIcon = true
    frame.showTotemNameplate = nil

    local size = db.size or 36
    local alpha = db.alpha or 0.85
    local x = db.xOffset or 0
    local y = db.yOffset or 0
    local outline = db.outline or {}
    local friendlyColor = outline.friendlyColor or {}
    local enemyColor = outline.enemyColor or {}
    local key = (info.key or "") .. "|"
        .. (info.icon or "") .. "|"
        .. tostring(size) .. "|"
        .. tostring(alpha) .. "|"
        .. tostring(x) .. "|"
        .. tostring(y) .. "|"
        .. tostring(frame.isTarget) .. "|"
        .. tostring(frame.UnitReaction or "") .. "|"
        .. tostring(outline.enable) .. "|"
        .. tostring(outline.thickness or "") .. "|"
        .. tostring(outline.growth or "") .. "|"
        .. tostring(friendlyColor.r or "") .. "|"
        .. tostring(friendlyColor.g or "") .. "|"
        .. tostring(friendlyColor.b or "") .. "|"
        .. tostring(enemyColor.r or "") .. "|"
        .. tostring(enemyColor.g or "") .. "|"
        .. tostring(enemyColor.b or "")

    if frame._fruitplatesTotemKey ~= key then
        iconFrame:ClearAllPoints()
        iconFrame:SetWidth(size)
        iconFrame:SetHeight(size)
        iconFrame:SetAlpha(alpha)
        if iconFrame.SetDrawLayer then iconFrame:SetDrawLayer("OVERLAY", 7) end

        -- Passive texture on the real Blizzard plate. Clicks still go to the plate.
        iconFrame:SetPoint("CENTER", frame:GetParent() or frame, "CENTER", x, y)
        iconFrame:SetTexture(info.icon or [[Interface\Icons\INV_Misc_QuestionMark]])

        self:ApplyTotemOutline(frame, iconFrame, db)

        if iconFrame.SetDrawLayer then iconFrame:SetDrawLayer("OVERLAY", 7) end
        if iconFrame.OutlineTop and iconFrame.OutlineTop.SetDrawLayer then iconFrame.OutlineTop:SetDrawLayer("OVERLAY", 7) end
        if iconFrame.OutlineBottom and iconFrame.OutlineBottom.SetDrawLayer then iconFrame.OutlineBottom:SetDrawLayer("OVERLAY", 7) end
        if iconFrame.OutlineLeft and iconFrame.OutlineLeft.SetDrawLayer then iconFrame.OutlineLeft:SetDrawLayer("OVERLAY", 7) end
        if iconFrame.OutlineRight and iconFrame.OutlineRight.SetDrawLayer then iconFrame.OutlineRight:SetDrawLayer("OVERLAY", 7) end

        if iconFrame.TargetGlow then
            if iconFrame.TargetGlow.SetFrameStrata then iconFrame.TargetGlow:SetFrameStrata("MEDIUM") end
            iconFrame.TargetGlow:ClearAllPoints()
            iconFrame.TargetGlow:SetPoint("TOPLEFT", iconFrame, "TOPLEFT", -5, 5)
            iconFrame.TargetGlow:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", 5, -5)
            if iconFrame.TargetGlow.SetFrameLevel then
                iconFrame.TargetGlow:SetFrameLevel(175)
            end
            iconFrame.TargetGlow:SetBackdropBorderColor(1, 1, 1, 0.9)
            iconFrame.TargetGlow:SetAlpha(0.9)
        end
        frame._fruitplatesTotemKey = key
    end

    if iconFrame.TargetGlow then
        if frame.isTarget then
            if not iconFrame.TargetGlow:IsShown() then iconFrame.TargetGlow:Show() end
        else
            if iconFrame.TargetGlow:IsShown() then iconFrame.TargetGlow:Hide() end
        end
    end

    if not iconFrame:IsShown() then
        SetTotemTextureGroupShown(iconFrame, true)
    end
    return true
end


function NP:Construct_TotemIcon(parent)
    -- TotemViewer-style passive texture on the original Blizzard plate.
    -- Textures do not receive mouse input, so clicks go to the real nameplate.
    local plate = parent:GetParent() or parent
    local texture = plate:CreateTexture(nil, "ARTWORK")
    texture:SetWidth(36)
    texture:SetHeight(36)
    texture:SetAlpha(0.85)
    if texture.SetDrawLayer then texture:SetDrawLayer("OVERLAY", 7) end

    texture.TargetGlow = CreateFrame("Frame", nil, plate)
    if texture.TargetGlow.SetFrameStrata then texture.TargetGlow:SetFrameStrata("MEDIUM") end
    texture.TargetGlow:EnableMouse(false)
    texture.TargetGlow:SetBackdrop({
        edgeFile = FP.media and FP.media.glowTex or [[Interface\AddOns\FruitPlates\Media\Textures\glowTex.tga]],
        edgeSize = 6,
        insets = {left = 0, right = 0, top = 0, bottom = 0},
    })
    texture.TargetGlow:Hide()

    texture.OutlineTop = plate:CreateTexture(nil, "OVERLAY")
    texture.OutlineBottom = plate:CreateTexture(nil, "OVERLAY")
    texture.OutlineLeft = plate:CreateTexture(nil, "OVERLAY")
    texture.OutlineRight = plate:CreateTexture(nil, "OVERLAY")
    if texture.OutlineTop.SetDrawLayer then texture.OutlineTop:SetDrawLayer("OVERLAY", 7) end
    if texture.OutlineBottom.SetDrawLayer then texture.OutlineBottom:SetDrawLayer("OVERLAY", 7) end
    if texture.OutlineLeft.SetDrawLayer then texture.OutlineLeft:SetDrawLayer("OVERLAY", 7) end
    if texture.OutlineRight.SetDrawLayer then texture.OutlineRight:SetDrawLayer("OVERLAY", 7) end
    texture.OutlineTop:Hide()
    texture.OutlineBottom:Hide()
    texture.OutlineLeft:Hide()
    texture.OutlineRight:Hide()

    -- Border textures are also passive; they are drawn by the raw plate frame.
    FP:CreateBorder(plate, texture)

    texture:Hide()
    return texture
end
