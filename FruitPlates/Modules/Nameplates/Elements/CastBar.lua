local FP = _G.FruitPlates
local NP = FP:GetModule("NamePlates")

local UnitCreatureFamily = UnitCreatureFamily

local CreateFrame = CreateFrame
local GetTime = GetTime
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitName = UnitName
local UnitBuff = UnitBuff
local FAILED = FAILED or "Failed"
local INTERRUPTED = INTERRUPTED or "Interrupted"
local CANCELED = "Canceled"

local CASTBAR_TEST_DURATION = 30
local CASTBAR_TEST_CAST_TIME = 2.5
local CASTBAR_TEST_PAUSE = 0.25
local CASTBAR_TEST_SPELL = "Test Cast"
local CASTBAR_TEST_ICON = [[Interface\Icons\Spell_Nature_Lightning]]

local PROTECTED_CAST_AURAS = {
    [642] = true, -- Divine Shield
    [54748] = true, -- Burning Determination
}

local AURA_MASTERY = 31821
local CONCENTRATION_AURA = 19746

local function ResetCast(castBar)
    castBar.casting = nil
    castBar.channeling = nil
    castBar.notInterruptible = nil
    castBar.protectedCast = nil
    castBar.holdState = nil
    castBar.spellName = nil
    castBar.value = nil
    castBar.max = nil
    castBar.startTime = nil
    castBar.endTime = nil
    castBar.delay = 0
    if castBar.StateText then
        castBar.StateText:SetText("")
        castBar.StateText:Hide()
    end
end

local function HasProtectedCastAura(unit)
    if not unit or not UnitExists(unit) then return false end

    local hasAuraMastery = false
    local hasConcentrationAura = false

    for i = 1, 40 do
        local name, _, _, _, _, _, _, _, _, _, spellID = UnitBuff(unit, i)
        if not name then break end
        if PROTECTED_CAST_AURAS[spellID] then
            return true
        elseif spellID == AURA_MASTERY then
            hasAuraMastery = true
        elseif spellID == CONCENTRATION_AURA then
            hasConcentrationAura = true
        end
    end

    return hasAuraMastery and hasConcentrationAura
end

local function FormatTime(value)
    value = tonumber(value) or 0
    if value < 0 then value = 0 end
    return string.format("%.1f", value)
end


local IMPORTANT_PET_FAMILIES = {
    Succubus = true,
    Felhunter = true,
    Felguard = true,
    Voidwalker = true,
    Imp = true,
    Doomguard = true,
    Infernal = true,
}

local IMPORTANT_PET_NAME_PARTS = {
    Gargoyle = true,
}

local BLOCKED_PET_NAME_PARTS = {
    ["Mirror Image"] = true,
    ["Water Elemental"] = true,
    ["Spirit Wolf"] = true,
    ["Shadowfiend"] = true,
    ["Treant"] = true,
    ["Viper"] = true,
    ["Venomous Snake"] = true,
}

local function NameContainsAny(name, patterns)
    if not name or name == "" then return false end
    for pattern in pairs(patterns) do
        if string.find(name, pattern, 1, true) then
            return true
        end
    end
    return false
end

local function IsPetUnitType(unitType)
    return unitType == "ENEMY_PET" or unitType == "FRIENDLY_PET"
end

local function IsImportantPetCast(frame, unit)
    local name = (unit and UnitExists(unit) and UnitName(unit)) or (frame and frame.UnitName)

    if NameContainsAny(name, BLOCKED_PET_NAME_PARTS) then
        return false
    end

    if unit and UnitExists(unit) and UnitCreatureFamily then
        local family = UnitCreatureFamily(unit)
        if family and IMPORTANT_PET_FAMILIES[family] then
            return true
        end
    end

    if NameContainsAny(name, IMPORTANT_PET_NAME_PARTS) then
        return true
    end

    return false
end

local function PetCastBarAllowed(rootDB, frame, unit)
    local petDB = rootDB and rootDB.petCastBars or nil
    if petDB and petDB.enable == false then
        return false
    end

    if petDB and petDB.importantOnly == false then
        return true
    end

    return IsImportantPetCast(frame, unit)
end

local function CastBarAllowedByMode(rootDB, unitType)
    local mode = rootDB and rootDB.castbarMode or "ENEMY"

    if IsPetUnitType(unitType) then
        return true
    end

    if mode == "BOTH" then
        return unitType == "ENEMY_PLAYER" or unitType == "FRIENDLY_PLAYER" or unitType == "ENEMY_NPC" or unitType == "FRIENDLY_NPC"
    elseif mode == "FRIENDLY" then
        return unitType == "FRIENDLY_PLAYER" or unitType == "FRIENDLY_NPC"
    end

    return unitType == "ENEMY_PLAYER" or unitType == "ENEMY_NPC"
end

local function GetCastBarDB(rootDB, unitType)
    local units = rootDB and rootDB.units
    if not units then return nil end

    -- Pets borrow the player castbar settings on purpose.
    -- Keeps pet casts visually tied to the Cast Bars page.
    if unitType == "ENEMY_PET" then
        return units.ENEMY_PLAYER and units.ENEMY_PLAYER.castbar
    elseif unitType == "FRIENDLY_PET" then
        return units.FRIENDLY_PLAYER and units.FRIENDLY_PLAYER.castbar
    end

    return units[unitType] and units[unitType].castbar
end

local function GetCastBarDBForFrame(rootDB, frame)
    local layoutType = NP.GetLayoutUnitType and NP:GetLayoutUnitType(frame) or (frame and frame.UnitType)
    return GetCastBarDB(rootDB, layoutType), layoutType
end

local function ApplyCastBarIconVisibility(castBar, db)
    if not castBar or not castBar.Icon then return end

    if db and db.showIcon then
        castBar.Icon:Show()
    else
        castBar.Icon:Hide()
    end
end


function NP:Update_CastBarOnUpdate(elapsed)
    if self._fruitplatesCastBarTest then
        NP:UpdateCastBarTestBar(self, elapsed)
        return
    end

    if self.casting or self.channeling then
        if self.casting then
            self.value = (self.value or 0) + elapsed
            if self.max and self.value >= self.max then
                ResetCast(self)
                self:Hide()
                return
            end
            self.Time:SetText(FormatTime((self.max or 0) - (self.value or 0)))
        else
            self.value = (self.value or 0) - elapsed
            if self.value <= 0 then
                ResetCast(self)
                self:Hide()
                return
            end
            self.Time:SetText(FormatTime(self.value))
        end

        self:SetValue(self.value or 0)
    elseif self.holdTime and self.holdTime > 0 then
        self.holdTime = self.holdTime - elapsed
    else
        ResetCast(self)
        self:Hide()
    end
end

function NP:SetCastBarColor(castBar, state)
    local colors = self.db.colors or {}
    local color

    if state == "INTERRUPTED" then
        color = colors.castInterruptedColor or {r = 1.00, g = 0.12, b = 0.05}
    elseif state == "CANCELED" then
        color = colors.castCanceledColor or {r = 0.55, g = 0.55, b = 0.55}
    elseif state == "PROTECTED" then
        color = colors.castProtectedColor or {r = 0.35, g = 0.70, b = 1.00}
    else
        color = colors.castColor or {r = 1, g = 0.72, b = 0.1}
    end

    local r, g, b = color.r or 1, color.g or 0.72, color.b or 0.1

    if castBar._fruitplatesR ~= r or castBar._fruitplatesG ~= g or castBar._fruitplatesB ~= b then
        castBar:SetStatusBarColor(r, g, b)
        castBar._fruitplatesR, castBar._fruitplatesG, castBar._fruitplatesB = r, g, b
    end

    if castBar.Icon and castBar.Icon.texture and castBar.Icon.texture.SetDesaturated then
        castBar.Icon.texture:SetDesaturated(false)
    end
end

local function NormalizeGUID(guid)
    if not guid then return nil end
    return string.lower(tostring(guid))
end

local function NormalizeName(name)
    if not name or name == "" then return nil end
    return string.lower(tostring(name))
end

function NP:GetRecentInterrupt(guid, name)
    if not self.CastInterrupts then return nil end

    local key = NormalizeGUID(guid)
    local info = key and self.CastInterrupts[key] or nil

    if not info then
        local nameKey = NormalizeName(name)
        info = nameKey and self.CastInterruptsByName and self.CastInterruptsByName[nameKey] or nil
    end

    if not info then return nil end
    if GetTime() - (info.time or 0) > 1.0 then
        if key then self.CastInterrupts[key] = nil end
        if info.destName and self.CastInterruptsByName then
            self.CastInterruptsByName[NormalizeName(info.destName)] = nil
        end
        return nil
    end

    return info
end

function NP:BeginCastHold(castBar, state, db)
    if not castBar then return end

    castBar.casting = nil
    castBar.channeling = nil
    castBar.holdState = state
    castBar.holdTime = db.timeToHold or 0.4
    castBar.Spark:Hide()

    if db.showStateText ~= false and castBar.StateText then
        castBar.StateText:SetText(state == "INTERRUPTED" and "Interrupted" or "Canceled!")
        castBar.StateText:Show()
    elseif castBar.StateText then
        castBar.StateText:SetText("")
        castBar.StateText:Hide()
    end

    if db.hideSpellName then
        castBar.Name:SetText("")
        castBar.Name:Hide()
    else
        castBar.Name:SetText("")
    end

    castBar.Time:SetText("")

    -- Interrupted casts keep the colored hold bar/state text, but the spell icon
    -- disappears immediately. Canceled/protected/live behavior is unchanged.
    if state == "INTERRUPTED" and castBar.Icon then
        castBar.Icon:Hide()
    end

    castBar:SetValue(castBar.value or castBar.max or 1)
    self:SetCastBarColor(castBar, state)
    castBar:Show()
end

function NP:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
    local timestamp, eventType,
        sourceGUID, sourceName, sourceFlags,
        destGUID, destName, destFlags,
        spellID, spellName, spellSchool,
        extraSpellID, extraSpellName, extraSpellSchool = ...

    if eventType ~= "SPELL_INTERRUPT" then return end

    -- All interrupts matter for castbar state color. Do not filter to mine.
    local guidKey = NormalizeGUID(destGUID)
    local nameKey = NormalizeName(destName)
    if not guidKey and not nameKey then return end

    local info = {
        time = GetTime(),
        sourceGUID = sourceGUID,
        sourceName = sourceName,
        destGUID = destGUID,
        destName = destName,
        spellID = spellID,
        spellName = spellName,
        extraSpellID = extraSpellID,
        extraSpellName = extraSpellName,
    }

    self.CastInterrupts = self.CastInterrupts or {}
    self.CastInterruptsByName = self.CastInterruptsByName or {}

    if guidKey then self.CastInterrupts[guidKey] = info end
    if nameKey then self.CastInterruptsByName[nameKey] = info end
    if self.RegisterInterruptLockout then
        self:RegisterInterruptLockout(destGUID, destName, spellID, spellName)
    end

    -- Combat log can arrive just after the castbar already decided "canceled".
    -- If this visible trusted-token plate matches the interrupt target, correct
    -- the hold color immediately.
    for frame in pairs(self.VisiblePlates or {}) do
        local unit = frame and (frame.unit or frame.castbarUnit)
        local unitGUID = unit and UnitExists(unit) and UnitGUID(unit) or nil
        local unitName = unit and UnitExists(unit) and UnitName(unit) or nil
        local frameGUID = NormalizeGUID(unitGUID or frame.guid)
        local frameName = NormalizeName(unitName or frame.UnitName)
        local castBar = frame and frame.CastBar

        if castBar and castBar:IsShown() and ((guidKey and frameGUID == guidKey) or (not guidKey and nameKey and frameName == nameKey)) then
            if castBar.casting or castBar.channeling or castBar.holdState == "CANCELED" then
                local db = GetCastBarDBForFrame(self.db, frame)
                if db then self:BeginCastHold(castBar, "INTERRUPTED", db) end
            end
        end
    end
end

function NP:Update_CastBar(frame, event, unit)
    local castBar = frame and frame.CastBar
    if not castBar or not frame.UnitType then return end

    if castBar._fruitplatesCastBarTest and self.CastBarTestEnabled then
        return
    end

    local db = GetCastBarDBForFrame(self.db, frame)
    if not CastBarAllowedByMode(self.db, frame.UnitType) or not db or not db.enable or not frame.Health or not frame.Health:IsShown() then
        ResetCast(castBar)
        castBar:Hide()
        return
    end

    unit = unit or frame.unit or frame.castbarUnit

    if IsPetUnitType(frame.UnitType) and not PetCastBarAllowed(self.db, frame, unit) then
        ResetCast(castBar)
        castBar:Hide()
        return
    end

    if not unit or not UnitExists(unit) then
        if not castBar.holdTime or castBar.holdTime <= 0 then
            ResetCast(castBar)
            castBar:Hide()
        end
        return
    end

    local name, _, _, texture, startTime, endTime, _, _, notInterruptible = UnitCastingInfo(unit)
    local channeling = false

    if not name then
        name, _, _, texture, startTime, endTime, _, notInterruptible = UnitChannelInfo(unit)
        channeling = name and true or false
    end

    if not name or not startTime or not endTime then
        local guid = UnitGUID(unit)
        local unitName = UnitName(unit)
        local recentInterrupt = self:GetRecentInterrupt(guid, unitName)

        if castBar:IsShown() and (castBar.casting or castBar.channeling) then
            if recentInterrupt or event == "UNIT_SPELLCAST_INTERRUPTED" then
                self:BeginCastHold(castBar, "INTERRUPTED", db)
            elseif event == "UNIT_SPELLCAST_FAILED" then
                self:BeginCastHold(castBar, "CANCELED", db)
            elseif castBar.max and castBar.value and castBar.value < (castBar.max - 0.05) then
                -- If the same unit starts another cast, the live path clears this hold.
                self:BeginCastHold(castBar, "CANCELED", db)
            else
                ResetCast(castBar)
                castBar:Hide()
            end
        elseif not castBar.holdTime or castBar.holdTime <= 0 then
            ResetCast(castBar)
            castBar:Hide()
        end
        return
    end

    startTime = startTime / 1000
    endTime = endTime / 1000

    if self.ClearInterruptLockout and self:ClearInterruptLockout(unit) then
        if self.Update_Auras then self:Update_Auras(frame, "new-cast-cleared-lockout", unit) end
    end

    castBar.max = endTime - startTime
    if castBar.max <= 0 then castBar.max = 0.01 end
    castBar.startTime = startTime
    castBar.endTime = endTime
    castBar.delay = 0
    castBar.casting = not channeling
    castBar.channeling = channeling
    castBar.notInterruptible = notInterruptible
    castBar.protectedCast = HasProtectedCastAura(unit)
    castBar.interrupted = nil
    castBar.holdState = nil
    castBar.holdTime = 0
    castBar.spellName = name

    if channeling then
        castBar.value = endTime - GetTime()
    else
        castBar.value = GetTime() - startTime
    end

    if castBar.value < 0 then castBar.value = 0 end
    if castBar.value > castBar.max then castBar.value = castBar.max end

    castBar:SetMinMaxValues(0, castBar.max)
    castBar:SetValue(castBar.value)

    if db.showStateText ~= false and castBar.protectedCast and castBar.StateText then
        castBar.StateText:SetText("DO NOT KICK")
        castBar.StateText:Show()
    elseif castBar.StateText then
        castBar.StateText:SetText("")
        castBar.StateText:Hide()
    end

    if db.hideSpellName then
        castBar.Name:SetText("")
        castBar.Name:Hide()
    else
        castBar.Name:SetText(name)
        castBar.Name:Show()
    end

    castBar.Time:SetText(FormatTime(channeling and castBar.value or (castBar.max - castBar.value)))

    if texture then
        castBar.Icon.texture:SetTexture(texture)
    elseif frame.oldCastBar and frame.oldCastBar.Icon and frame.oldCastBar.Icon.GetTexture then
        castBar.Icon.texture:SetTexture(frame.oldCastBar.Icon:GetTexture())
    else
        castBar.Icon.texture:SetTexture(nil)
    end

    -- A kick hides the icon during the hold bar. If this unit starts another
    -- valid cast right away, restore the icon from the user's setting.
    ApplyCastBarIconVisibility(castBar, db)

    castBar.Spark:Show()
    self:SetCastBarColor(castBar, castBar.protectedCast and "PROTECTED" or nil)
    castBar:Show()
end

local function GetPreferredCastBarTestFrame(self)
    if self.ScanNameplates then self:ScanNameplates() end

    local fallback

    for frame in pairs(self.VisiblePlates or {}) do
        if frame and frame.CastBar and frame.Health and frame.Health:IsShown() then
            fallback = fallback or frame

            if UnitExists("target") and self.IsUnitPlate and self:IsUnitPlate(frame, "target") then
                return frame
            end

            if UnitExists("mouseover") and self.IsUnitPlate and self:IsUnitPlate(frame, "mouseover") then
                fallback = frame
            end
        end
    end

    return fallback
end

local function BeginTestCast(self, frame, keepTimer)
    local castBar = frame and frame.CastBar
    if not castBar then return false end

    local db = GetCastBarDBForFrame(self.db, frame)
    if not db or db.enable == false or not frame.Health or not frame.Health:IsShown() then
        return false
    end

    self:Configure_CastBar(frame)

    castBar._fruitplatesCastBarTest = true
    castBar._fruitplatesCastBarTestFrame = frame
    castBar._fruitplatesCastBarTestPause = 0
    castBar._fruitplatesCastBarTestEnd = self.CastBarTestEnd
    castBar.max = CASTBAR_TEST_CAST_TIME
    castBar.value = 0
    castBar.startTime = GetTime()
    castBar.endTime = castBar.startTime + CASTBAR_TEST_CAST_TIME
    castBar.delay = 0
    castBar.casting = true
    castBar.channeling = nil
    castBar.notInterruptible = nil
    castBar.protectedCast = nil
    castBar.interrupted = nil
    castBar.holdState = nil
    castBar.holdTime = 0
    castBar.spellName = CASTBAR_TEST_SPELL

    castBar:SetMinMaxValues(0, CASTBAR_TEST_CAST_TIME)
    castBar:SetValue(0)

    if castBar.StateText then
        castBar.StateText:SetText("")
        castBar.StateText:Hide()
    end

    if db.hideSpellName then
        castBar.Name:SetText("")
        castBar.Name:Hide()
    else
        castBar.Name:SetText(CASTBAR_TEST_SPELL)
        castBar.Name:Show()
    end

    castBar.Time:SetText(FormatTime(CASTBAR_TEST_CAST_TIME))

    if castBar.Icon and castBar.Icon.texture then
        castBar.Icon.texture:SetTexture(CASTBAR_TEST_ICON)
    end
    ApplyCastBarIconVisibility(castBar, db)

    if castBar.Spark then castBar.Spark:Show() end
    self:SetCastBarColor(castBar, nil)
    castBar:Show()
    return true
end

function NP:UpdateCastBarTestBar(castBar, elapsed)
    if not castBar then return end

    if not self.CastBarTestEnabled then
        castBar._fruitplatesCastBarTest = nil
        ResetCast(castBar)
        castBar:Hide()
        return
    end

    if self.CastBarTestEnd and GetTime() >= self.CastBarTestEnd then
        self:StopCastBarTest()
        return
    end

    local frame = castBar._fruitplatesCastBarTestFrame or self.CastBarTestFrame
    if not frame or frame.CastBar ~= castBar or not frame.Health or not frame.Health:IsShown() then
        self:StartCastBarTest(true)
        return
    end

    local db = GetCastBarDBForFrame(self.db, frame)
    if not db or db.enable == false then
        self:StopCastBarTest()
        return
    end

    self:Configure_CastBar(frame)

    if castBar._fruitplatesCastBarTestPause and castBar._fruitplatesCastBarTestPause > 0 then
        castBar._fruitplatesCastBarTestPause = castBar._fruitplatesCastBarTestPause - elapsed
        if castBar._fruitplatesCastBarTestPause <= 0 then
            BeginTestCast(self, frame, true)
        end
        return
    end

    if not castBar.casting then
        BeginTestCast(self, frame, true)
        return
    end

    castBar.value = (castBar.value or 0) + elapsed
    if castBar.value >= (castBar.max or CASTBAR_TEST_CAST_TIME) then
        castBar.casting = nil
        castBar.value = 0
        castBar:SetValue(0)
        castBar.Time:SetText(FormatTime(CASTBAR_TEST_CAST_TIME))
        if castBar.Spark then castBar.Spark:Hide() end
        castBar._fruitplatesCastBarTestPause = CASTBAR_TEST_PAUSE
        castBar:Show()
        return
    end

    castBar:SetMinMaxValues(0, castBar.max or CASTBAR_TEST_CAST_TIME)
    castBar:SetValue(castBar.value or 0)
    castBar.Time:SetText(FormatTime((castBar.max or CASTBAR_TEST_CAST_TIME) - (castBar.value or 0)))

    if db.hideSpellName then
        castBar.Name:SetText("")
        castBar.Name:Hide()
    else
        castBar.Name:SetText(CASTBAR_TEST_SPELL)
        castBar.Name:Show()
    end

    if castBar.StateText then
        castBar.StateText:SetText("")
        castBar.StateText:Hide()
    end

    if castBar.Spark then castBar.Spark:Show() end
    self:SetCastBarColor(castBar, nil)
    castBar:Show()
end

function NP:StartCastBarTest(keepEndTime)
    if not keepEndTime then
        self.CastBarTestEnd = GetTime() + CASTBAR_TEST_DURATION
    end
    self.CastBarTestEnabled = true

    if self.CastBarTestFrame and self.CastBarTestFrame.CastBar then
        self.CastBarTestFrame.CastBar._fruitplatesCastBarTest = nil
        ResetCast(self.CastBarTestFrame.CastBar)
        self.CastBarTestFrame.CastBar:Hide()
    end

    local frame = GetPreferredCastBarTestFrame(self)
    self.CastBarTestFrame = frame

    if frame then
        BeginTestCast(self, frame, false)
    end
end

function NP:StopCastBarTest()
    self.CastBarTestEnabled = nil
    self.CastBarTestEnd = nil

    local frame = self.CastBarTestFrame
    if frame and frame.CastBar then
        frame.CastBar._fruitplatesCastBarTest = nil
        frame.CastBar._fruitplatesCastBarTestFrame = nil
        frame.CastBar._fruitplatesCastBarTestPause = nil
        frame.CastBar._fruitplatesCastBarTestEnd = nil
        ResetCast(frame.CastBar)
        frame.CastBar:Hide()
    end
    self.CastBarTestFrame = nil

    for visibleFrame in pairs(self.VisiblePlates or {}) do
        local castBar = visibleFrame and visibleFrame.CastBar
        if castBar and castBar._fruitplatesCastBarTest then
            castBar._fruitplatesCastBarTest = nil
            castBar._fruitplatesCastBarTestFrame = nil
            castBar._fruitplatesCastBarTestPause = nil
            castBar._fruitplatesCastBarTestEnd = nil
            ResetCast(castBar)
            castBar:Hide()
        end
    end
end

function NP:UpdateCastBarTest()
    if not self.CastBarTestEnabled then return end

    if self.CastBarTestEnd and GetTime() >= self.CastBarTestEnd then
        self:StopCastBarTest()
        return
    end

    local frame = self.CastBarTestFrame
    if not frame or not frame.CastBar or not frame.Health or not frame.Health:IsShown() then
        self:StartCastBarTest(true)
        return
    end

    if not frame.CastBar._fruitplatesCastBarTest then
        BeginTestCast(self, frame, true)
    else
        self:Configure_CastBar(frame)
    end
end

function NP:Configure_CastBar(frame)
    local db, layoutType = GetCastBarDBForFrame(self.db, frame)
    local castBar = frame.CastBar
    if not db or not castBar then return end

    local statusbar = FP:FetchMedia("statusbar", self.db.statusbar)
    local iconPosition = db.iconPosition or "LEFT"
    local nameX = db.spellNameOffsetX
    local nameY = db.spellNameOffsetY
    local timeX = db.timeOffsetX
    local timeY = db.timeOffsetY
    if nameX == nil then nameX = 3 end
    if nameY == nil then nameY = 0 end
    if timeX == nil then timeX = -3 end
    if timeY == nil then timeY = 0 end

    local key = (layoutType or frame.UnitType or "") .. "|"
        .. (statusbar or "") .. "|"
        .. tostring(db.xOffset or 0) .. "|"
        .. tostring(db.yOffset or -3) .. "|"
        .. tostring(db.width or 120) .. "|"
        .. tostring(db.height or 8) .. "|"
        .. tostring(db.showIcon == true) .. "|"
        .. tostring(db.iconSize or 16) .. "|"
        .. iconPosition .. "|"
        .. tostring(db.iconOffsetX or (iconPosition == "RIGHT" and 3 or -3)) .. "|"
        .. tostring(db.iconOffsetY or 0) .. "|"
        .. tostring(db.textPosition or "ONBAR") .. "|"
        .. tostring(nameX) .. "|"
        .. tostring(nameY) .. "|"
        .. tostring(timeX) .. "|"
        .. tostring(timeY) .. "|"
        .. (db.font or "") .. "|"
        .. tostring(db.spellNameFontSize or db.fontSize or 9) .. "|"
        .. tostring(db.timeFontSize or db.fontSize or 9) .. "|"
        .. (db.fontOutline or "OUTLINE") .. "|"
        .. tostring(db.hideSpellName == true) .. "|"
        .. tostring(db.hideTime == true) .. "|"
        .. tostring(db.showStateText ~= false) .. "|"
        .. tostring(db.stateTextFontSize or db.spellNameFontSize or db.fontSize or 9) .. "|"
        .. tostring(db.stateTextOffsetX or 0) .. "|"
        .. tostring(db.stateTextOffsetY or 0)

    if castBar._fruitplatesConfigKey == key then
        return
    end
    castBar._fruitplatesConfigKey = key

    castBar:ClearAllPoints()
    castBar:SetPoint("TOP", frame.Health, "BOTTOM", db.xOffset or 0, db.yOffset or -3)
    castBar:SetWidth(db.width or 120)
    castBar:SetHeight(db.height or 8)
    castBar:SetStatusBarTexture(statusbar, "BORDER")

    castBar.Icon:ClearAllPoints()
    castBar.Icon:SetWidth(db.iconSize or 16)
    castBar.Icon:SetHeight(db.iconSize or 16)
    if db.showIcon then
        if iconPosition == "RIGHT" then
            castBar.Icon:SetPoint("BOTTOMLEFT", castBar, "BOTTOMRIGHT", db.iconOffsetX or 3, db.iconOffsetY or 0)
        else
            castBar.Icon:SetPoint("BOTTOMRIGHT", castBar, "BOTTOMLEFT", db.iconOffsetX or -3, db.iconOffsetY or 0)
        end
        castBar.Icon:Show()
    else
        castBar.Icon:Hide()
    end

    castBar.Spark:ClearAllPoints()
    castBar.Spark:SetPoint("CENTER", castBar:GetStatusBarTexture(), "RIGHT", 0, 0)
    castBar.Spark:SetHeight((db.height or 8) * 2)

    castBar.Name:ClearAllPoints()
    castBar.Time:ClearAllPoints()

    if db.textPosition == "ABOVE" then
        castBar.Name:SetPoint("BOTTOMLEFT", castBar, "TOPLEFT", nameX, nameY + 1)
        castBar.Time:SetPoint("BOTTOMRIGHT", castBar, "TOPRIGHT", timeX, timeY + 1)
    elseif db.textPosition == "BELOW" then
        castBar.Name:SetPoint("TOPLEFT", castBar, "BOTTOMLEFT", nameX, nameY - 1)
        castBar.Time:SetPoint("TOPRIGHT", castBar, "BOTTOMRIGHT", timeX, timeY - 1)
    else
        castBar.Name:SetPoint("LEFT", castBar, "LEFT", nameX, nameY)
        castBar.Time:SetPoint("RIGHT", castBar, "RIGHT", timeX, timeY)
    end

    if castBar.StateText then
        castBar.StateText:ClearAllPoints()
        castBar.StateText:SetPoint("CENTER", castBar, "CENTER", db.stateTextOffsetX or 0, db.stateTextOffsetY or 0)
    end

    FP:FontTemplate(castBar.Name, FP:FetchMedia("font", db.font), db.spellNameFontSize or db.fontSize or 9, db.fontOutline or "OUTLINE")
    FP:FontTemplate(castBar.Time, FP:FetchMedia("font", db.font), db.timeFontSize or db.fontSize or 9, db.fontOutline or "OUTLINE")
    if castBar.StateText then
        FP:FontTemplate(castBar.StateText, FP:FetchMedia("font", db.font), db.stateTextFontSize or db.spellNameFontSize or db.fontSize or 9, db.fontOutline or "OUTLINE")
        castBar.StateText:SetTextColor(1, 1, 1, 1)
        castBar.StateText:Hide()
    end

    if db.hideSpellName then castBar.Name:Hide() else castBar.Name:Show() end
    if db.hideTime then castBar.Time:Hide() else castBar.Time:Show() end
end

function NP:Construct_CastBar(parent)
    local frame = CreateFrame("StatusBar", nil, parent)
    frame:SetStatusBarTexture(FP:FetchMedia("statusbar", self.db.statusbar), "BORDER")
    frame:SetMinMaxValues(0, 1)
    frame:SetValue(0)
    frame:SetFrameLevel(parent:GetFrameLevel() + 2)
    frame:SetScript("OnUpdate", NP.Update_CastBarOnUpdate)
    FP:CreateBorder(frame)

    frame.Icon = CreateFrame("Frame", nil, frame)
    frame.Icon:SetFrameLevel(frame:GetFrameLevel() + 1)
    FP:CreateBorder(frame.Icon)

    frame.Icon.texture = frame.Icon:CreateTexture(nil, "BORDER")
    frame.Icon.texture:SetAllPoints(frame.Icon)
    frame.Icon.texture:SetTexCoord(unpack(FP.TexCoords))

    frame.Name = frame:CreateFontString(nil, "OVERLAY")
    frame.Name:SetJustifyH("LEFT")
    frame.Name:SetWordWrap(false)

    frame.Time = frame:CreateFontString(nil, "OVERLAY")
    frame.Time:SetJustifyH("RIGHT")
    frame.Time:SetWordWrap(false)

    frame.StateText = frame:CreateFontString(nil, "OVERLAY")
    frame.StateText:SetJustifyH("CENTER")
    frame.StateText:SetWordWrap(false)
    frame.StateText:Hide()

    frame.Spark = frame:CreateTexture(nil, "OVERLAY")
    frame.Spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
    frame.Spark:SetBlendMode("ADD")
    frame.Spark:SetWidth(15)
    frame.Spark:SetHeight(15)

    frame.holdTime = 0
    frame.holdState = nil
    frame.protectedCast = nil
    frame.delay = 0
    frame:Hide()

    return frame
end
