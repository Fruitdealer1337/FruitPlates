local FP = _G.FruitPlates
local NP = FP:GetModule("NamePlates")

local CreateFrame = CreateFrame
local GetTime = GetTime
local UnitAffectingCombat = UnitAffectingCombat
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitName = UnitName
local UnitIsUnit = UnitIsUnit

local swipePath = [[Interface\AddOns\FruitPlates\Media\Auras\swipe]]

local timeMinute = 60
local timeHour = 3600
local timeDay = 86400
local aboutMinute = 59.5
local aboutHour = 60 * 59.5
local aboutDay = 3600 * 23.5

local INTERRUPT_LOCKOUT_DURATIONS = {
    [57994] = 2, -- Wind Shear
    [6552] = 4, -- Pummel
    [1766] = 5, -- Kick
    [72] = 6, -- Shield Bash
    [47528] = 4, -- Mind Freeze
    [2139] = 8, -- Counterspell
    [19647] = 6, -- Spell Lock
    [19675] = 4, -- Feral Charge - Bear interrupt effect
}

local function NormalizeGUID(guid)
    if not guid then return nil end
    return string.lower(tostring(guid))
end

local function NormalizeName(name)
    if not name or name == "" then return nil end
    return string.lower(tostring(name))
end

local function ClearTable(tbl)
    if wipe then return wipe(tbl) end
    for k in pairs(tbl) do tbl[k] = nil end
end

local function Round(value)
    return math.floor((tonumber(value) or 0) + 0.5)
end

local function FormatTime(seconds, showDecimals)
    seconds = tonumber(seconds) or 0
    if seconds < 1 and showDecimals then
        return string.format("%.1f", seconds)
    elseif seconds < aboutMinute then
        local rounded = Round(seconds)
        if rounded ~= 0 then return tostring(rounded) end
        return ""
    elseif seconds < aboutHour then
        return tostring(Round(seconds / timeMinute)) .. "m"
    elseif seconds < aboutDay then
        return tostring(Round(seconds / timeHour)) .. "h"
    end
    return tostring(Round(seconds / timeDay)) .. "d"
end

local function TimeColor(seconds)
    seconds = tonumber(seconds) or 0
    if seconds <= 1 then
        return 1, seconds, seconds
    end
    return 1, 1, 1
end

local function UnitGroup(unitType)
    if unitType == "ENEMY_PLAYER" then return "enemyPlayer" end
    if unitType == "ENEMY_PET" then return "enemyPet" end
    return nil
end

local function GetUnitDB(db, unitType)
    local group = UnitGroup(unitType)
    return group and db and db.units and db.units[group] or nil
end

local function FriendlyUnitGroup(unitType)
    if unitType == "FRIENDLY_PLAYER" then return "friendlyPlayer" end
    if unitType == "FRIENDLY_PET" then return "friendlyPet" end
    return nil
end

local function GetFriendlyUnitDB(db, unitType)
    local group = FriendlyUnitGroup(unitType)
    return group and db and db.units and db.units[group] or nil
end

local function GetPriorityEntry(name, spellID)
    local data = FP.PriorityAuraData
    if not data then return nil end
    local spells = data.spells
    if not spells then return nil end
    if spellID and spells[spellID] then return spells[spellID] end
    if name and spells[name] then return spells[name] end
    return nil
end

local function IsAuraBlacklisted(db, name, spellID)
    local blacklist = db and db.blacklist
    if not blacklist then return false end

    if spellID and blacklist.spells and blacklist.spells[spellID] then
        return true
    end

    if name and blacklist.names then
        local key = string.lower(tostring(name))
        if blacklist.names[key] then return true end
    end

    return false
end

local function IsFriendlyAuraWhitelisted(db, name, spellID)
    local whitelist = db and db.whitelist
    if not whitelist then return false end

    if spellID and whitelist.spells and whitelist.spells[spellID] then
        return true
    end

    if name and whitelist.names then
        local key = string.lower(tostring(name))
        if whitelist.names[key] then return true end
    end

    return false
end

local function AuraAllowed(frame, unit, unitDB, db)
    if not frame or not unit or not unitDB or unitDB.enable == false then return false end
    if frame.UnitType ~= "ENEMY_PLAYER" and frame.UnitType ~= "ENEMY_PET" then return false end
    if db.showOnlyInCombat and not UnitAffectingCombat("player") then return false end
    if db.showUnitInCombat and not UnitAffectingCombat(unit) then return false end
    if UnitIsUnit(unit, "player") then return false end
    return true
end

local function FriendlyAuraAllowed(frame, unit, unitDB, db)
    if not frame or not unit or not unitDB or unitDB.enable == false then return false end
    if frame.UnitType ~= "FRIENDLY_PLAYER" and frame.UnitType ~= "FRIENDLY_PET" then return false end
    if UnitIsUnit(unit, "player") then return false end
    return db and db.enable ~= false
end

local function RecycleAuraRecords(records, pool)
    if not records then return end
    pool = pool or {}
    for i = #records, 1, -1 do
        local record = records[i]
        records[i] = nil
        if record then
            ClearTable(record)
            pool[#pool + 1] = record
        end
    end
    return pool
end

local function AcquireAuraRecord(records, pool)
    local record = pool and pool[#pool] or nil
    if record then
        pool[#pool] = nil
    else
        record = {}
    end
    records[#records + 1] = record
    return record
end

local function AddAuraRecord(records, pool, frame, unit, db, auraType, index)
    local name, rank, icon, count, debuffType, duration, expiration, caster, isStealable, shouldConsolidate, spellID
    if auraType == "HARMFUL" then
        name, rank, icon, count, debuffType, duration, expiration, caster, isStealable, shouldConsolidate, spellID = UnitDebuff(unit, index)
    else
        name, rank, icon, count, debuffType, duration, expiration, caster, isStealable, shouldConsolidate, spellID = UnitBuff(unit, index)
    end
    if not name then return false end

    if IsAuraBlacklisted(db, name, spellID) then return true end
    duration = tonumber(duration) or 0
    expiration = tonumber(expiration) or 0
    if db.hidePermanent ~= false and duration == 0 then return true end

    local mine = caster == "player"
    local priorityEntry = GetPriorityEntry(name, spellID)

    if priorityEntry and priorityEntry.enable == false then return true end
    if priorityEntry and priorityEntry.onlyMine == true and not mine then return true end
    if priorityEntry and priorityEntry.type == "other" and priorityEntry.onlyMine ~= false and not mine then return true end

    -- Bottom row is for player-applied auras on the current target.
    -- Center/left/right priority auras stay in their dedicated slots and do not duplicate below.
    -- Unlisted player-applied auras can still appear as plain bottom-row records.
    if not priorityEntry and not mine then return true end

    local record = AcquireAuraRecord(records, pool)
    record.name = name
    record.spellID = spellID
    record.type = auraType
    record.icon = icon
    record.count = tonumber(count) or 0
    record.debuffType = debuffType
    record.duration = duration
    record.expiration = expiration
    record.mine = mine
    record.scale = 1
    record.index = index
    record.priorityData = priorityEntry
    record.priorityType = priorityEntry and priorityEntry.type or "other"
    record.priority = priorityEntry and (priorityEntry.priority or 100) or 200
    record.highlight = priorityEntry and priorityEntry.highlight or nil

    return true
end

local function ScanAuras(frame, unit, db, records, pool)
    RecycleAuraRecords(records, pool)

    local index = 1
    while AddAuraRecord(records, pool, frame, unit, db, "HARMFUL", index) do
        index = index + 1
    end

    index = 1
    while AddAuraRecord(records, pool, frame, unit, db, "HELPFUL", index) do
        index = index + 1
    end
end

local function AddFriendlyAuraRecord(records, pool, frame, unit, db, auraType, index)
    local name, rank, icon, count, debuffType, duration, expiration, caster, isStealable, shouldConsolidate, spellID
    if auraType == "HARMFUL" then
        name, rank, icon, count, debuffType, duration, expiration, caster, isStealable, shouldConsolidate, spellID = UnitDebuff(unit, index)
    else
        name, rank, icon, count, debuffType, duration, expiration, caster, isStealable, shouldConsolidate, spellID = UnitBuff(unit, index)
    end
    if not name then return false end

    if not IsFriendlyAuraWhitelisted(db, name, spellID) then return true end
    duration = tonumber(duration) or 0
    expiration = tonumber(expiration) or 0
    if db.hidePermanent ~= false and duration == 0 then return true end

    local record = AcquireAuraRecord(records, pool)
    record.name = name
    record.spellID = spellID
    record.type = auraType
    record.icon = icon
    record.count = tonumber(count) or 0
    record.debuffType = debuffType
    record.duration = duration
    record.expiration = expiration
    record.mine = caster == "player"
    record.scale = 1
    record.index = index

    return true
end

local function ScanFriendlyAuras(frame, unit, db, records, pool)
    RecycleAuraRecords(records, pool)

    -- Friendly Buffs&Debuffs is whitelist-only. Keep the rule simple:
    -- a friendly aura is shown only if the whitelist says it is allowed.
    local index = 1
    while AddFriendlyAuraRecord(records, pool, frame, unit, db, "HARMFUL", index) do
        index = index + 1
    end

    index = 1
    while AddFriendlyAuraRecord(records, pool, frame, unit, db, "HELPFUL", index) do
        index = index + 1
    end
end

local function ConfigureIcon(icon, db)
    if icon._fruitplatesAuraConfigured then return end
    icon._fruitplatesAuraConfigured = true

    icon.Icon:SetAllPoints(icon)
    icon.Icon:SetTexCoord(unpack(FP.TexCoords))
    icon.Icon:SetVertexColor(1, 1, 1, 1)

    icon.Swipe:SetAllPoints(icon)
    icon.Swipe:SetTexture(swipePath)
    icon.Swipe:SetVertexColor(0, 0, 0, 1)
    icon.Swipe:Hide()

    icon.Cooldown:SetAllPoints(icon)
    icon.Cooldown:SetTexture([[Interface\Buttons\WHITE8x8]])
    icon.Cooldown:SetVertexColor(0, 0, 0, 0.35)
    icon.Cooldown:Hide()

    FP:CreateBorder(icon)

    icon.Duration:SetPoint("TOP", icon, "BOTTOM", 0, -1)
    icon.Duration:SetTextColor(1, 1, 1, 1)

    icon.Count:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -1, 1)
    icon.Count:SetTextColor(0.20, 0.95, 0.70, 1)

    icon:EnableMouse(false)
end

local function ResetIconVisuals(icon)
    if not icon then return end
    if FP.HideAuraGlow then FP:HideAuraGlow(icon) end
    icon.Icon:SetVertexColor(1, 1, 1, 1)
    if icon.Swipe then icon.Swipe:Hide() end
    icon.Cooldown:Hide()

    local border = FP.media and FP.media.bordercolor or {0, 0, 0, 1}
    FP:SetBorderColor(icon, border[1] or 0, border[2] or 0, border[3] or 0, border[4] or 1)
end

local function UpdateAuraSwipe(icon, remaining, db)
    if not icon or not icon.Swipe then return end

    if not db or db.showSwipe == false or not icon.duration or icon.duration <= 0 or not remaining or remaining <= 0 then
        icon.Swipe:Hide()
        return
    end

    local progress = remaining / math.max(icon.duration, 0.001)
    if progress < 0 then progress = 0 elseif progress > 1 then progress = 1 end

    -- 8x8 swipe spritesheet. Higher remaining time uses later frames;
    -- horizontal coords are flipped so the sweep matches the bundled texture.
    local frameIndex = math.floor(progress * 63)
    local row = math.floor(frameIndex / 8)
    local col = frameIndex - row * 8

    local l = col / 8
    local r = (col + 1) / 8
    local t = row / 8
    local b = (row + 1) / 8

    icon.Swipe:SetTexCoord(r, l, t, b)
    icon.Swipe:SetAlpha(tonumber(db.swipeAlpha) or 0.55)
    icon.Swipe:Show()
end

local function IconOnUpdate(self, elapsed)
    if not self.expiration or self.expiration <= 0 then return end
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed < 0.07 then return end
    self.elapsed = 0

    local remaining = self.expiration - GetTime()
    if remaining <= 0 then
        self:Hide()
        local container = self:GetParent()
        if container and container.Owner then
            NP:Update_Auras(container.Owner, "expired")
        end
        return
    end

    local db = self._fruitplatesAuraDB or NP.db and NP.db.auras or {}
    UpdateAuraSwipe(self, remaining, db)

    if db.showDuration ~= false and self.Duration then
        self.Duration:SetText(FormatTime(remaining, db.showDecimals ~= false))
        if db.colorTransition ~= false then
            self.Duration:SetTextColor(TimeColor(remaining))
        end
    end
end

local function ConstructIcon(parent)
    local icon = CreateFrame("Frame", nil, parent)
    icon.Icon = icon:CreateTexture(nil, "ARTWORK")
    icon.Swipe = icon:CreateTexture(nil, "OVERLAY")
    icon.Cooldown = icon:CreateTexture(nil, "OVERLAY")
    -- Duration should win over stack count if the texts overlap.
    -- In arena, the remaining time is usually the more important read.
    icon.Count = icon:CreateFontString(nil, "ARTWORK")
    icon.Duration = icon:CreateFontString(nil, "OVERLAY")

    -- 3.3.5 can throw "Font not set" if SetText runs before SetFont.
    -- Give aura texts a safe font now; later updates can resize it normally.
    FP:FontTemplate(icon.Duration, nil, 10, "OUTLINE")
    FP:FontTemplate(icon.Count, nil, 10, "OUTLINE")
    icon._fruitplatesDurationFontKey = "10|OUTLINE"
    icon._fruitplatesStackFontKey = "10|OUTLINE"

    if icon.Count.SetDrawLayer then icon.Count:SetDrawLayer("ARTWORK", 7) end
    if icon.Duration.SetDrawLayer then icon.Duration:SetDrawLayer("OVERLAY", 7) end

    if icon.Swipe.SetDrawLayer then icon.Swipe:SetDrawLayer("OVERLAY", 1) end

    icon:SetScript("OnUpdate", IconOnUpdate)
    icon:SetScript("OnHide", function(self)
        if FP.HideAuraGlow then FP:HideAuraGlow(self) end
        self.expiration = nil
        self.duration = nil
        self.elapsed = nil
        self.Duration:SetText("")
        self.Count:SetText("")
        self._fruitplatesAuraDB = nil
        if self.Swipe then self.Swipe:Hide() end
        self.Cooldown:Hide()
    end)
    icon:Hide()
    return icon
end

function NP:Construct_Auras(frame)
    local auras = CreateFrame("Frame", nil, frame)
    auras.Owner = frame
    auras.icons = {}
    auras.priorityRightIcons = {}
    auras.priorityBottomIcons = {}
    auras.friendlyIcons = {}
    auras.records = {}
    auras.recordPool = {}
    auras.priorityRightRecords = {}
    auras.priorityOther = {}
    auras:SetWidth(1)
    auras:SetHeight(1)
    auras:Hide()
    return auras
end

function NP:Configure_Auras(frame)
    if not frame or not frame.Auras then return end

    local db
    local unitDB
    if frame.UnitType == "FRIENDLY_PLAYER" or frame.UnitType == "FRIENDLY_PET" then
        db = self.db and self.db.friendlyAuras
        unitDB = db and GetFriendlyUnitDB(db, frame.UnitType)
    else
        db = self.db and self.db.auras
        unitDB = db and GetUnitDB(db, frame.UnitType)
    end
    if not db or db.enable == false or not unitDB or unitDB.enable == false then
        frame.Auras:Hide()
        return
    end

    local auras = frame.Auras
    local parent = frame.Health or frame
    local baseLevel = (parent.GetFrameLevel and parent:GetFrameLevel()) or frame:GetFrameLevel() or 1

    if auras._fruitplatesAnchor ~= "PRIORITY"
        or auras._fruitplatesParent ~= parent
        or auras._fruitplatesLevel ~= baseLevel + 24 then
        auras:SetParent(frame)
        auras:ClearAllPoints()
        auras:SetPoint("CENTER", parent, "CENTER", 0, 0)
        if auras.SetFrameLevel then auras:SetFrameLevel(baseLevel + 24) end
        auras._fruitplatesAnchor = "PRIORITY"
        auras._fruitplatesParent = parent
        auras._fruitplatesX = nil
        auras._fruitplatesY = nil
        auras._fruitplatesLevel = baseLevel + 24
    end
end

function NP:GetAuraUnit(frame)
    if not frame or not frame.UnitType then return nil end

    -- 3.3.5 recycles nameplate frames, so visible name alone is not enough.
    -- No trusted token means no aura. Missing an aura is safer than showing it on the wrong plate.
    local unit = frame.unit
    if unit and UnitExists(unit) then
        if unit == "target" or unit == "mouseover" then
            if self:IsUnitPlate(frame, unit) then return unit end
            return nil
        end
        return unit
    end

    unit = frame.castbarUnit
    if unit and UnitExists(unit) then
        return unit
    end

    -- Do not bind target or mouseover from here.
    -- Aura rendering only consumes tokens the resolver has already trusted.
    return nil
end

function NP:Clear_Auras(frame)
    local auras = frame and frame.Auras
    if not auras then return end

    for i = 1, #auras.icons do
        auras.icons[i]:Hide()
    end
    if auras.priorityCenter then auras.priorityCenter:Hide() end
    if auras.priorityLeft then auras.priorityLeft:Hide() end
    for i = 1, #(auras.priorityRightIcons or {}) do
        auras.priorityRightIcons[i]:Hide()
    end
    for i = 1, #auras.priorityBottomIcons do
        auras.priorityBottomIcons[i]:Hide()
    end
    for i = 1, #auras.friendlyIcons do
        auras.friendlyIcons[i]:Hide()
    end
    if auras.records then RecycleAuraRecords(auras.records, auras.recordPool) end
    if auras.priorityRightRecords then ClearTable(auras.priorityRightRecords) end
    if auras.priorityOther then ClearTable(auras.priorityOther) end
    auras._fruitplatesAuraUnit = nil
    auras._fruitplatesAuraUnitType = nil
    auras._fruitplatesTestMode = nil
    auras._fruitplatesTestEnd = nil
    auras._fruitplatesFriendlyTestMode = nil
    auras._fruitplatesFriendlyTestEnd = nil
    auras:Hide()
end

local function HideLegacyAuraIcons(auras)
    for i = 1, #auras.icons do
        auras.icons[i]:Hide()
    end
end

local function HidePriorityAuraIcons(auras)
    if auras.priorityCenter then auras.priorityCenter:Hide() end
    if auras.priorityLeft then auras.priorityLeft:Hide() end
    for i = 1, #(auras.priorityRightIcons or {}) do
        auras.priorityRightIcons[i]:Hide()
    end
    for i = 1, #auras.priorityBottomIcons do
        auras.priorityBottomIcons[i]:Hide()
    end
end

local function HideFriendlyAuraIcons(auras)
    for i = 1, #auras.friendlyIcons do
        auras.friendlyIcons[i]:Hide()
    end
end

local function AddTestAuraRecord(records, pool, spellID, icon, auraType, priorityType, priority, highlight, duration, count)
    local now = GetTime()
    local record = AcquireAuraRecord(records, pool)
    record.name = GetSpellInfo and GetSpellInfo(spellID) or ("Test " .. tostring(spellID))
    record.spellID = spellID
    record.icon = icon
    record.count = count or 0
    record.debuffType = nil
    record.duration = duration or 30
    record.expiration = now + (duration or 30)
    record.caster = "player"
    record.mine = true
    record.type = auraType or "HARMFUL"
    record.priorityType = priorityType
    record.priority = priority or 1
    record.highlight = highlight
    record.index = spellID or 0
    record.scale = 1
end

local function BuildAuraTestRecords(auras)
    local records = auras and auras.records
    if not records then return end
    RecycleAuraRecords(records, auras.recordPool)

    -- Test records cover each enemy aura area: center, left lockout,
    -- right priority icons, and the bottom row.
    AddTestAuraRecord(records, auras.recordPool, 33786, [[Interface\Icons\Spell_Nature_EarthBind]], "HARMFUL", "cc", 1, 3, 30, 0) -- Cyclone-style center
    local _, _, pummelIcon = GetSpellInfo and GetSpellInfo(6552)
    AddTestAuraRecord(records, auras.recordPool, 6552, pummelIcon or [[Interface\Icons\INV_Gauntlets_04]], "HARMFUL", "lockout", 1, 3, 4, 0) -- Pummel-style left lockout
    AddTestAuraRecord(records, auras.recordPool, 48707, [[Interface\Icons\Spell_Shadow_AntiMagicShell]], "HELPFUL", "immunities", 1, 1, 30, 1) -- AMS-style right
    AddTestAuraRecord(records, auras.recordPool, 642, [[Interface\Icons\spell_holy_divineintervention]], "HELPFUL", "immunities", 2, nil, 30, 1) -- Divine Shield-style second right icon
    AddTestAuraRecord(records, auras.recordPool, 47486, [[Interface\Icons\Ability_Warrior_SavageBlow]], "HARMFUL", "other", 1, 4, 30, 0) -- Mortal Strike-style bottom
    AddTestAuraRecord(records, auras.recordPool, 772, [[Interface\Icons\Ability_Gouge]], "HARMFUL", "other", 2, nil, 30, 0) -- Rend-style bottom
    AddTestAuraRecord(records, auras.recordPool, 1715, [[Interface\Icons\Ability_ShockWave]], "HARMFUL", "other", 3, nil, 30, 0) -- Hamstring-style bottom
end

local function BuildFriendlyAuraTestRecords(auras)
    local records = auras and auras.records
    if not records then return end
    RecycleAuraRecords(records, auras.recordPool)

    -- Friendly preview uses the real single-row renderer.
    -- Skip the whitelist for test mode so a fresh profile still has a visible preview.
    AddTestAuraRecord(records, auras.recordPool, 53563, [[Interface\Icons\Ability_Paladin_BeaconofLight]], "HELPFUL", "friendly", 1, nil, 30, 0)
    AddTestAuraRecord(records, auras.recordPool, 48066, [[Interface\Icons\Spell_Holy_PowerWordShield]], "HELPFUL", "friendly", 2, nil, 18, 0)
    AddTestAuraRecord(records, auras.recordPool, 774, [[Interface\Icons\Spell_Nature_Rejuvenation]], "HELPFUL", "friendly", 3, nil, 12, 0)
    AddTestAuraRecord(records, auras.recordPool, 6788, [[Interface\Icons\Spell_Holy_AshesToAshes]], "HARMFUL", "friendly", 4, nil, 8, 0)
end


function NP:RegisterInterruptLockout(destGUID, destName, spellID, spellName)
    local duration = INTERRUPT_LOCKOUT_DURATIONS[tonumber(spellID)]
    if not duration or duration <= 0 then return end

    local now = GetTime()
    local info = {
        time = now,
        duration = duration,
        expiration = now + duration,
        spellID = tonumber(spellID),
        spellName = spellName,
        destGUID = destGUID,
        destName = destName,
    }

    self.AuraLockouts = self.AuraLockouts or {}
    self.AuraLockoutsByName = self.AuraLockoutsByName or {}

    local guidKey = NormalizeGUID(destGUID)
    local nameKey = NormalizeName(destName)
    if guidKey then self.AuraLockouts[guidKey] = info end
    if nameKey then self.AuraLockoutsByName[nameKey] = info end

    for frame in pairs(self.VisiblePlates or {}) do
        local unit = frame and (frame.unit or frame.castbarUnit)
        local unitGUID = unit and UnitExists(unit) and UnitGUID(unit) or nil
        local unitName = unit and UnitExists(unit) and UnitName(unit) or nil
        local frameGUID = NormalizeGUID(unitGUID or frame.guid)
        local frameName = NormalizeName(unitName or frame.UnitName)

        if (guidKey and frameGUID == guidKey) or (not guidKey and nameKey and frameName == nameKey) then
            self:Update_Auras(frame, "interrupt-lockout", unit)
        end
    end
end

function NP:GetActiveInterruptLockout(unit)
    if not unit or not UnitExists(unit) then return nil end
    local now = GetTime()

    self.AuraLockouts = self.AuraLockouts or {}
    self.AuraLockoutsByName = self.AuraLockoutsByName or {}

    local guid = NormalizeGUID(UnitGUID(unit))
    local name = NormalizeName(UnitName(unit))
    local info = guid and self.AuraLockouts[guid] or nil
    if not info and name then info = self.AuraLockoutsByName[name] end
    if not info then return nil end

    if not info.expiration or info.expiration <= now then
        if guid then self.AuraLockouts[guid] = nil end
        if name then self.AuraLockoutsByName[name] = nil end
        return nil
    end

    return info
end

function NP:ClearInterruptLockout(unit)
    if not unit or not UnitExists(unit) then return false end
    if not self.AuraLockouts and not self.AuraLockoutsByName then return false end

    local guid = NormalizeGUID(UnitGUID(unit))
    local name = NormalizeName(UnitName(unit))
    local cleared = false

    if guid and self.AuraLockouts and self.AuraLockouts[guid] then
        self.AuraLockouts[guid] = nil
        cleared = true
    end

    if name and self.AuraLockoutsByName and self.AuraLockoutsByName[name] then
        self.AuraLockoutsByName[name] = nil
        cleared = true
    end

    return cleared
end

local function AddLockoutRecord(records, pool, info)
    if not info then return false end
    local name, _, icon = GetSpellInfo(info.spellID)
    local record = AcquireAuraRecord(records, pool)
    record.name = name or info.spellName or "Interrupt"
    record.spellID = info.spellID
    record.icon = icon or [[Interface\Icons\INV_Misc_QuestionMark]]
    record.count = 0
    record.debuffType = nil
    record.duration = info.duration
    record.expiration = info.expiration
    record.caster = nil
    record.mine = false
    record.type = "HARMFUL"
    record.priorityType = "lockout"
    record.priority = 1
    record.highlight = 3
    record.index = info.spellID or 0
    record.scale = 1
    record.syntheticLockout = true
    return true
end

local function GetPrioritySlotDB(db, key)
    local priority = db and db.priority or {}
    local slot = priority[key] or {}
    return slot
end

local function BetterAura(current, candidate)
    if not candidate then return current end
    if not current then return candidate end

    local data = FP.PriorityAuraData or {}
    local priorities = data.typePriority or {}
    local currentType = priorities[current.priorityType] or 0
    local candidateType = priorities[candidate.priorityType] or 0
    if candidateType ~= currentType then
        return candidateType > currentType and candidate or current
    end

    local currentSpell = tonumber(current.priority) or 100
    local candidateSpell = tonumber(candidate.priority) or 100
    if candidateSpell ~= currentSpell then
        return candidateSpell < currentSpell and candidate or current
    end

    local currentExpiration = current.expiration and current.expiration > 0 and current.expiration or 5000000
    local candidateExpiration = candidate.expiration and candidate.expiration > 0 and candidate.expiration or 5000000
    if candidateExpiration ~= currentExpiration then
        return candidateExpiration < currentExpiration and candidate or current
    end

    return (candidate.index or 0) < (current.index or 0) and candidate or current
end

local function SortPriorityAuras(a, b)
    local data = FP.PriorityAuraData or {}
    local priorities = data.typePriority or {}
    local at = priorities[a.priorityType] or 0
    local bt = priorities[b.priorityType] or 0
    if at ~= bt then return at > bt end
    if (a.priority or 100) ~= (b.priority or 100) then return (a.priority or 100) < (b.priority or 100) end
    local ae = a.expiration and a.expiration > 0 and a.expiration or 5000000
    local be = b.expiration and b.expiration > 0 and b.expiration or 5000000
    if ae ~= be then return ae < be end
    return (a.index or 0) < (b.index or 0)
end

local function SelectPriorityAuras(records, auras)
    local data = FP.PriorityAuraData or {}
    local centerTypes = data.centerTypes or {}
    local leftTypes = data.leftTypes or {}
    local rightTypes = data.rightTypes or {}
    local otherTypes = data.otherTypes or {}
    local right = auras.priorityRightRecords or {}
    local other = auras.priorityOther
    ClearTable(right)
    ClearTable(other)

    local center, left
    for i = 1, #records do
        local record = records[i]
        local auraType = record.priorityType
        if centerTypes[auraType] then
            center = BetterAura(center, record)
        elseif leftTypes[auraType] then
            left = BetterAura(left, record)
        elseif rightTypes[auraType] then
            right[#right + 1] = record
        elseif otherTypes[auraType] then
            other[#other + 1] = record
        end
    end

    table.sort(right, SortPriorityAuras)
    table.sort(other, SortPriorityAuras)
    return center, left, right, other
end

local function ApplyIconFont(icon, objectKey, cacheKey, size, flags)
    size = tonumber(size) or 10
    flags = flags or "OUTLINE"
    local key = tostring(size) .. "|" .. flags
    if icon[cacheKey] ~= key then
        FP:FontTemplate(icon[objectKey], nil, size, flags)
        icon[cacheKey] = key
    end
end

local function ConfigurePriorityText(icon, slotDB, db)
    ApplyIconFont(icon, "Duration", "_fruitplatesDurationFontKey", slotDB.durationSize or db.durationSize or 10, "OUTLINE")
    ApplyIconFont(icon, "Count", "_fruitplatesStackFontKey", slotDB.stackSize or db.stackSize or 10, "OUTLINE")
    icon.Duration:ClearAllPoints()
    icon.Duration:SetPoint(slotDB.textAnchor or "CENTER", icon, slotDB.textAnchor or "CENTER", tonumber(slotDB.textX) or 0, tonumber(slotDB.textY) or 0)
    icon.Duration:SetTextColor(1, 1, 1, 1)
    icon.Count:ClearAllPoints()
    icon.Count:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -1, 1)
end

local function ApplyRecordToIcon(icon, record, db, size, slotDB)
    ConfigureIcon(icon, db)
    ResetIconVisuals(icon)
    icon:SetWidth(size)
    icon:SetHeight(size)
    icon.Icon:SetTexture(record.icon)

    if slotDB then
        ConfigurePriorityText(icon, slotDB, db)
    else
        ApplyIconFont(icon, "Duration", "_fruitplatesDurationFontKey", db.durationSize or 10, "OUTLINE")
        ApplyIconFont(icon, "Count", "_fruitplatesStackFontKey", db.stackSize or 10, "OUTLINE")
        icon.Duration:ClearAllPoints()
        icon.Duration:SetPoint("TOP", icon, "BOTTOM", 0, -1)
        icon.Count:ClearAllPoints()
        icon.Count:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -1, 1)
    end

    icon.Duration:SetText("")
    icon.Count:SetText("")
    icon.type = record.type
    icon.duration = record.duration
    icon.expiration = record.expiration
    icon.elapsed = 1
    icon._fruitplatesAuraDB = db

    if db.showDuration ~= false and record.expiration and record.expiration > 0 then
        local remaining = record.expiration - GetTime()
        if remaining > 0 then
            icon.Duration:SetText(FormatTime(remaining, db.showDecimals ~= false))
            if db.colorTransition ~= false then icon.Duration:SetTextColor(TimeColor(remaining)) end
        end
    end
    if db.showStacks ~= false and record.count and record.count > 1 then
        icon.Count:SetText(tostring(record.count))
    end

    if record.expiration and record.expiration > 0 and record.duration and record.duration > 0 then
        UpdateAuraSwipe(icon, record.expiration - GetTime(), db)
    elseif icon.Swipe then
        icon.Swipe:Hide()
    end
end

local function ApplyPriorityHighlight(icon, highlight, db)
    if not highlight then return end

    if (highlight == 1 or highlight == 2) and db.priority and db.priority.useGlow ~= false and FP.ShowAuraGlow then
        FP:ShowAuraGlow(icon, highlight)
        return
    end

    local color
    if highlight == 1 then
        color = {1, 0.90, 0.35, 1}
    elseif highlight == 2 or highlight == 4 then
        color = {0.70, 0.20, 1, 1}
    elseif highlight == 3 then
        color = {1, 0.60, 0, 1}
    elseif highlight == 5 then
        color = {0, 0.35, 1, 1}
    end
    if color then FP:SetBorderColor(icon, color[1], color[2], color[3], color[4]) end
end

local function GetPriorityIcon(auras, key)
    if key == "center" then
        if not auras.priorityCenter then auras.priorityCenter = ConstructIcon(auras) end
        return auras.priorityCenter
    elseif key == "left" then
        if not auras.priorityLeft then auras.priorityLeft = ConstructIcon(auras) end
        return auras.priorityLeft
    end
end

local function RenderPrioritySlot(auras, parent, key, record, db)
    local slotDB = GetPrioritySlotDB(db, key)
    local icon = GetPriorityIcon(auras, key)
    if not icon then return false end
    if slotDB.enable == false or not record then
        icon:Hide()
        return false
    end

    local size = tonumber(slotDB.size) or (key == "center" and 30 or 20)
    ApplyRecordToIcon(icon, record, db, size, slotDB)
    ApplyPriorityHighlight(icon, record.highlight, db)

    icon:ClearAllPoints()
    if key == "left" then
        icon:SetPoint("RIGHT", parent, "LEFT", tonumber(slotDB.xOffset) or -5, tonumber(slotDB.yOffset) or 0)
    else
        icon:SetPoint("CENTER", parent, "TOP", tonumber(slotDB.xOffset) or 0, tonumber(slotDB.yOffset) or 55)
    end
    icon:Show()
    return true
end

local function RenderPriorityRightIcons(auras, parent, records, db)
    local slotDB = GetPrioritySlotDB(db, "right")
    if slotDB.enable == false or not records or #records == 0 then
        for i = 1, #(auras.priorityRightIcons or {}) do auras.priorityRightIcons[i]:Hide() end
        return 0
    end

    local maxIcons = tonumber(slotDB.maxIcons) or 2
    if maxIcons < 1 then maxIcons = 1 end
    if maxIcons > 2 then maxIcons = 2 end

    local size = tonumber(slotDB.size) or 20
    local spacing = tonumber(slotDB.spacing) or 2
    local shown = math.min(#records, maxIcons)
    local x = tonumber(slotDB.xOffset) or 25
    local y = tonumber(slotDB.yOffset) or 0

    for i = 1, shown do
        local icon = auras.priorityRightIcons[i]
        if not icon then
            icon = ConstructIcon(auras)
            auras.priorityRightIcons[i] = icon
        end

        local record = records[i]
        ApplyRecordToIcon(icon, record, db, size, slotDB)
        ApplyPriorityHighlight(icon, record.highlight, db)
        icon:ClearAllPoints()
        icon:SetPoint("LEFT", parent, "RIGHT", x + (i - 1) * (size + spacing), y)
        icon:Show()
    end

    for i = shown + 1, #auras.priorityRightIcons do
        auras.priorityRightIcons[i]:Hide()
    end

    return shown
end

local function RenderPriorityBottomRow(auras, parent, records, db)
    local slotDB = GetPrioritySlotDB(db, "bottom")
    if slotDB.enable == false then
        for i = 1, #auras.priorityBottomIcons do auras.priorityBottomIcons[i]:Hide() end
        return 0
    end

    local maxIcons = tonumber(slotDB.maxIcons) or 6
    local size = tonumber(slotDB.size) or 20
    local spacing = tonumber(slotDB.spacing) or 2
    local shown = math.min(#records, maxIcons)
    local totalWidth = shown > 0 and (shown * size + (shown - 1) * spacing) or 0
    local startX = -totalWidth / 2

    for i = 1, shown do
        local icon = auras.priorityBottomIcons[i]
        if not icon then
            icon = ConstructIcon(auras)
            auras.priorityBottomIcons[i] = icon
        end

        local record = records[i]
        ApplyRecordToIcon(icon, record, db, size, slotDB)
        ApplyPriorityHighlight(icon, record.highlight, db)
        icon:ClearAllPoints()
        icon:SetPoint("CENTER", parent, "TOP", startX + (i - 0.5) * size + (i - 1) * spacing + (tonumber(slotDB.xOffset) or 0), tonumber(slotDB.yOffset) or 24)
        icon:Show()
    end

    for i = shown + 1, #auras.priorityBottomIcons do
        auras.priorityBottomIcons[i]:Hide()
    end

    return shown
end

local function SortFriendlyAuras(a, b)
    local ae = a.expiration and a.expiration > 0 and a.expiration or 5000000
    local be = b.expiration and b.expiration > 0 and b.expiration or 5000000
    if ae ~= be then return ae < be end
    return (a.index or 0) < (b.index or 0)
end

local function RenderFriendlyRow(auras, parent, records, db)
    local row = db and db.row or {}
    if row.enable == false then
        HideFriendlyAuraIcons(auras)
        return 0
    end

    table.sort(records, SortFriendlyAuras)

    local maxIcons = tonumber(row.maxIcons) or 6
    local size = tonumber(row.size) or 30
    local spacing = tonumber(row.spacing) or 2
    local shown = math.min(#records, maxIcons)
    local totalWidth = shown > 0 and (shown * size + (shown - 1) * spacing) or 0
    local startX = -totalWidth / 2

    for i = 1, shown do
        local icon = auras.friendlyIcons[i]
        if not icon then
            icon = ConstructIcon(auras)
            auras.friendlyIcons[i] = icon
        end

        ApplyRecordToIcon(icon, records[i], db, size, row)
        icon:ClearAllPoints()
        icon:SetPoint("CENTER", parent, "TOP", startX + (i - 0.5) * size + (i - 1) * spacing + (tonumber(row.xOffset) or 0), tonumber(row.yOffset) or 18)
        icon:Show()
    end

    for i = shown + 1, #auras.friendlyIcons do
        auras.friendlyIcons[i]:Hide()
    end

    return shown
end

function NP:Update_Auras_Friendly(frame, records, db, unitDB, unit)
    local auras = frame.Auras
    HideLegacyAuraIcons(auras)
    HidePriorityAuraIcons(auras)

    local parent = frame.Health or frame
    local shown = RenderFriendlyRow(auras, parent, records, db)
    if shown == 0 then
        self:Clear_Auras(frame)
        return
    end

    auras:SetWidth(1)
    auras:SetHeight(1)
    auras._fruitplatesAuraUnit = unit
    auras._fruitplatesAuraUnitType = frame.UnitType
    auras:Show()
end

function NP:Update_Auras_Priority(frame, records, db, unitDB, unit)
    local auras = frame.Auras
    HideLegacyAuraIcons(auras)
    HideFriendlyAuraIcons(auras)

    -- Enemy auras use the priority PvP renderer only.
    local center, left, right, other = SelectPriorityAuras(records, auras)
    local parent = frame.Health or frame
    local shown = 0
    if RenderPrioritySlot(auras, parent, "center", center, db) then shown = shown + 1 end
    if RenderPrioritySlot(auras, parent, "left", left, db) then shown = shown + 1 end
    shown = shown + RenderPriorityRightIcons(auras, parent, right, db)
    shown = shown + RenderPriorityBottomRow(auras, parent, other, db)

    if shown == 0 then
        self:Clear_Auras(frame)
        return
    end

    auras:SetWidth(1)
    auras:SetHeight(1)
    auras._fruitplatesAuraUnit = unit
    auras._fruitplatesAuraUnitType = frame.UnitType
    auras:Show()
end

function NP:Update_Auras(frame, reason, eventUnit)
    if not frame or not frame.Auras then return end

    if frame.isTotemPlate and self.db and self.db.totems and self.db.totems.enable == false then
        self:Clear_Auras(frame)
        return
    end

    if self.AuraTestEnabled and self.AuraTestFrame == frame then
        self:UpdateAuraTest()
        return
    end
    if self.FriendlyAuraTestEnabled and self.FriendlyAuraTestFrame == frame then
        self:UpdateFriendlyAuraTest()
        return
    end

    local isFriendlyAuraPlate = frame.UnitType == "FRIENDLY_PLAYER" or frame.UnitType == "FRIENDLY_PET"
    local db = isFriendlyAuraPlate and self.db and self.db.friendlyAuras or self.db and self.db.auras
    if not db or db.enable == false then
        self:Clear_Auras(frame)
        return
    end

    local unitDB = isFriendlyAuraPlate and GetFriendlyUnitDB(db, frame.UnitType) or GetUnitDB(db, frame.UnitType)
    local unit = self:GetAuraUnit(frame)
    local allowed = isFriendlyAuraPlate and FriendlyAuraAllowed(frame, unit, unitDB, db) or AuraAllowed(frame, unit, unitDB, db)
    if not unit or not allowed then
        self:Clear_Auras(frame)
        return
    end

    if eventUnit and UnitExists(eventUnit) and not UnitIsUnit(unit, eventUnit) then
        return
    end

    local auras = frame.Auras
    if auras._fruitplatesAuraUnit and not UnitIsUnit(auras._fruitplatesAuraUnit, unit) then
        self:Clear_Auras(frame)
    end
    if auras._fruitplatesAuraUnitType and auras._fruitplatesAuraUnitType ~= frame.UnitType then
        self:Clear_Auras(frame)
    end

    self:Configure_Auras(frame)
    if isFriendlyAuraPlate then
        ScanFriendlyAuras(frame, unit, db, auras.records, auras.recordPool)
    else
        ScanAuras(frame, unit, db, auras.records, auras.recordPool)
        AddLockoutRecord(auras.records, auras.recordPool, self:GetActiveInterruptLockout(unit))
    end

    local records = auras.records
    if #records == 0 then
        self:Clear_Auras(frame)
        return
    end

    if isFriendlyAuraPlate then
        self:Update_Auras_Friendly(frame, records, db, unitDB, unit)
    else
        self:Update_Auras_Priority(frame, records, db, unitDB, unit)
    end
end

function NP:RenderTestAuras(frame)
    if not frame or not frame.Auras then return false end

    local db = self.db and self.db.auras
    if not db or db.enable == false then return false end

    local auras = frame.Auras
    local parent = frame.Health or frame
    local baseLevel = (parent.GetFrameLevel and parent:GetFrameLevel()) or frame:GetFrameLevel() or 1

    -- Test mode bypasses unit-type checks so any visible plate can host the preview.
    -- This keeps layout tuning possible on dummies, neutral NPCs, or city plates.
    auras:SetParent(frame)
    auras:ClearAllPoints()
    auras:SetPoint("CENTER", parent, "CENTER", 0, 0)
    if auras.SetFrameLevel then auras:SetFrameLevel(baseLevel + 24) end

    BuildAuraTestRecords(auras)

    if #auras.records == 0 then return false end

    local unitDB = GetUnitDB(db, "ENEMY_PLAYER")
    self:Update_Auras_Priority(frame, auras.records, db, unitDB, "fruitplates-test")
    auras._fruitplatesTestMode = true
    auras._fruitplatesTestEnd = GetTime() + 30
    return true
end

function NP:StartAuraTest()
    if self.FriendlyAuraTestEnabled and self.StopFriendlyAuraTest then
        self:StopFriendlyAuraTest()
    end

    self.AuraTestEnabled = true
    self.AuraTestEnd = GetTime() + 30

    -- Run one normal scan first so the preview has a current plate to attach to.
    if self.ScanNameplates then self:ScanNameplates() end

    local preferred
    local fallback

    for frame in pairs(self.VisiblePlates) do
        if frame and frame.Auras then
            fallback = fallback or frame

            if UnitExists("target") and self.IsUnitPlate and self:IsUnitPlate(frame, "target") then
                preferred = frame
                break
            end

            if not preferred and UnitExists("mouseover") and self.IsUnitPlate and self:IsUnitPlate(frame, "mouseover") then
                preferred = frame
            end
        end
    end

    preferred = preferred or fallback

    if preferred then
        self.AuraTestFrame = preferred
        self:RenderTestAuras(preferred)
    end
end

function NP:StopAuraTest()
    self.AuraTestEnabled = nil
    self.AuraTestEnd = nil

    if self.AuraTestFrame then
        self:Clear_Auras(self.AuraTestFrame)
        self.AuraTestFrame = nil
    end

    for frame in pairs(self.VisiblePlates) do
        if frame and frame.Auras and frame.Auras._fruitplatesTestMode then
            self:Clear_Auras(frame)
        end
    end
end

function NP:UpdateAuraTest()
    if not self.AuraTestEnabled then return end

    if self.AuraTestEnd and GetTime() >= self.AuraTestEnd then
        self:StopAuraTest()
        return
    end

    local frame = self.AuraTestFrame
    if not frame or not frame.Health or not frame.Health:IsShown() then
        self:StartAuraTest()
        return
    end

    self:RenderTestAuras(frame)
end

function NP:RenderFriendlyTestAuras(frame)
    if not frame or not frame.Auras then return false end

    local db = self.db and self.db.friendlyAuras
    if not db or db.enable == false then return false end

    local auras = frame.Auras
    local parent = frame.Health or frame
    local baseLevel = (parent.GetFrameLevel and parent:GetFrameLevel()) or frame:GetFrameLevel() or 1

    -- Friendly test mode previews only the Friendly Buffs&Debuffs row.
    -- It bypasses token and whitelist checks so layout tuning works even without a trusted friendly unit.
    auras:SetParent(frame)
    auras:ClearAllPoints()
    auras:SetPoint("CENTER", parent, "CENTER", 0, 0)
    if auras.SetFrameLevel then auras:SetFrameLevel(baseLevel + 24) end

    BuildFriendlyAuraTestRecords(auras)

    if #auras.records == 0 then return false end

    local unitDB = GetFriendlyUnitDB(db, "FRIENDLY_PLAYER")
    self:Update_Auras_Friendly(frame, auras.records, db, unitDB, "fruitplates-friendly-test")
    auras._fruitplatesFriendlyTestMode = true
    auras._fruitplatesFriendlyTestEnd = GetTime() + 30
    return true
end

function NP:StartFriendlyAuraTest()
    if self.AuraTestEnabled and self.StopAuraTest then
        self:StopAuraTest()
    end

    self.FriendlyAuraTestEnabled = true
    self.FriendlyAuraTestEnd = GetTime() + 30

    -- Run one normal scan first so the preview has a current plate to attach to.
    if self.ScanNameplates then self:ScanNameplates() end

    local preferred
    local fallback

    for frame in pairs(self.VisiblePlates) do
        if frame and frame.Auras then
            fallback = fallback or frame

            if UnitExists("target") and self.IsUnitPlate and self:IsUnitPlate(frame, "target") then
                preferred = frame
                break
            end

            if not preferred and UnitExists("mouseover") and self.IsUnitPlate and self:IsUnitPlate(frame, "mouseover") then
                preferred = frame
            end
        end
    end

    preferred = preferred or fallback

    if preferred then
        self.FriendlyAuraTestFrame = preferred
        self:RenderFriendlyTestAuras(preferred)
    end
end

function NP:StopFriendlyAuraTest()
    self.FriendlyAuraTestEnabled = nil
    self.FriendlyAuraTestEnd = nil

    if self.FriendlyAuraTestFrame then
        self:Clear_Auras(self.FriendlyAuraTestFrame)
        self.FriendlyAuraTestFrame = nil
    end

    for frame in pairs(self.VisiblePlates) do
        if frame and frame.Auras and frame.Auras._fruitplatesFriendlyTestMode then
            self:Clear_Auras(frame)
        end
    end
end

function NP:UpdateFriendlyAuraTest()
    if not self.FriendlyAuraTestEnabled then return end

    if self.FriendlyAuraTestEnd and GetTime() >= self.FriendlyAuraTestEnd then
        self:StopFriendlyAuraTest()
        return
    end

    local frame = self.FriendlyAuraTestFrame
    if not frame or not frame.Health or not frame.Health:IsShown() then
        self:StartFriendlyAuraTest()
        return
    end

    self:RenderFriendlyTestAuras(frame)
end


function NP:RefreshAurasForUnit(eventUnit)
    if not eventUnit or not UnitExists(eventUnit) then return end

    for frame in pairs(self.VisiblePlates) do
        local unit = self:GetAuraUnit(frame)
        if unit and UnitExists(unit) and UnitIsUnit(unit, eventUnit) then
            self:Update_Auras(frame, "UNIT_AURA", eventUnit)
        end
    end
end
