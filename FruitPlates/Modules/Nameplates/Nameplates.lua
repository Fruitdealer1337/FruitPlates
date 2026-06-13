local FP = _G.FruitPlates
local NP = FP:GetModule("NamePlates")

local CreateFrame = CreateFrame
local UnitName = UnitName
local UnitGUID = UnitGUID
local UnitClass = UnitClass
local UnitExists = UnitExists
local UnitIsPlayer = UnitIsPlayer
local UnitIsOtherPlayersPet = UnitIsOtherPlayersPet
local UnitIsFriend = UnitIsFriend
local UnitReaction = UnitReaction
local UnitFactionGroup = UnitFactionGroup
local UnitIsUnit = UnitIsUnit
local UnitCanAttack = UnitCanAttack
local UnitHealthMax = UnitHealthMax
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local GetNumPartyMembers = GetNumPartyMembers
local GetNumRaidMembers = GetNumRaidMembers
local InCombatLockdown = InCombatLockdown
local WorldFrame = WorldFrame
local GetTime = GetTime

local OVERLAY = [[Interface\TargetingFrame\UI-TargetingFrame-Flash]]

-- Do not change raw Blizzard plate strata/framelevel.
-- FruitPlates can layer its own frames, but the native plate must stay alone.
-- Touching the native plate was the source of the big framegap/freeze bug.

NP.CreatedPlates = NP.CreatedPlates or {}
NP.VisiblePlates = NP.VisiblePlates or {}
NP.GUIDList = NP.GUIDList or {}
NP.ENEMY_PLAYER = NP.ENEMY_PLAYER or {}
NP.FRIENDLY_PLAYER = NP.FRIENDLY_PLAYER or {}
NP.ENEMY_NPC = NP.ENEMY_NPC or {}
NP.FRIENDLY_NPC = NP.FRIENDLY_NPC or {}
NP.ENEMY_PET = NP.ENEMY_PET or {}
NP.FRIENDLY_PET = NP.FRIENDLY_PET or {}
NP.PetNameToType = NP.PetNameToType or {}
NP.PetGUIDToType = NP.PetGUIDToType or {}
NP.ResizeQueue = NP.ResizeQueue or {}
NP.NativeClassProbeQueue = NP.NativeClassProbeQueue or {}
NP.ClassCache = NP.ClassCache or {}
NP.ArenaCastbarNameToUnit = NP.ArenaCastbarNameToUnit or {}
NP.ArenaCastbarUnitToName = NP.ArenaCastbarUnitToName or {}
NP.ArenaCastbarLastUpdate = 0
NP.Perf = NP.Perf or {enabled = false, counters = {}, lastCounters = {}, lastTime = 0, visible = 0, nativeProbes = 0}

local lastChildren = 0
local hasTarget = false
local plateID = 0

-- Keep cheap visual updates fast; slower identity/layout work is budgeted.
local HEAVY_UPDATE_INTERVAL = 0.05
local HEAVY_UPDATES_PER_FRAME = 5
local MOUSEOVER_PROBE_DURATION = 0.14
local MOUSEOVER_PROBE_INTERVAL = 0.015
local NATIVE_HIDE_INTERVAL = 0.15
local AURA_UNITS_PER_FRAME = 2

-- Mirror Images inherit the mage name. Keep this guard narrow:
-- arena Mage name, duplicate visible plates, and low visible max HP only.
local MIRROR_IMAGE_MAX_HEALTH_THRESHOLD = 10000

local heavyUpdatesThisFrame = 0

local function ClearTable(tbl)
    if wipe then return wipe(tbl) end
    for k in pairs(tbl) do tbl[k] = nil end
end

local function ValidClass(value)
    return type(value) == "string" and RAID_CLASS_COLORS[value] and value or nil
end

local function SetAlphaIfChanged(object, alpha)
    if object and object.SetAlpha and (not object.GetAlpha or object:GetAlpha() ~= alpha) then
        object:SetAlpha(alpha)
    end
end

local function SetWidthIfChanged(object, width)
    if object and object.SetWidth and (not object.GetWidth or object:GetWidth() ~= width) then
        object:SetWidth(width)
    end
end

local function SetHeightIfChanged(object, height)
    if object and object.SetHeight and (not object.GetHeight or object:GetHeight() ~= height) then
        object:SetHeight(height)
    end
end

local function SetFrameLevelIfChanged(object, level)
    if object and object.SetFrameLevel and object._fruitplatesFrameLevel ~= level then
        object:SetFrameLevel(level)
        object._fruitplatesFrameLevel = level
    end
end

local function GetSizingCastBarDB(rootDB, unitType)
    local units = rootDB and rootDB.units
    if not units then return nil end

    if unitType == "ENEMY_PET" then
        return units.ENEMY_PLAYER and units.ENEMY_PLAYER.castbar
    elseif unitType == "FRIENDLY_PET" then
        return units.FRIENDLY_PLAYER and units.FRIENDLY_PLAYER.castbar
    end

    return units[unitType] and units[unitType].castbar
end

function NP:BumpPerf(key, amount)
    local perf = self.Perf
    if not perf or not perf.enabled then return end
    perf.counters[key] = (perf.counters[key] or 0) + (amount or 1)
end

function NP:UpdatePerfSnapshot(force)
    local perf = self.Perf
    if not perf or not perf.enabled then return end

    local now = GetTime()
    if not force and now - (perf.lastTime or 0) < 1 then return end

    ClearTable(perf.lastCounters)
    for k, v in pairs(perf.counters) do
        perf.lastCounters[k] = v
        perf.counters[k] = nil
    end
    perf.lastTime = now
end

function NP:PrintPerfSnapshot()
    local perf = self.Perf
    if not perf then return end
    self:UpdatePerfSnapshot(true)
    FP:Print(
        "perf",
        "visible:", perf.visible or 0,
        "updates/s:", perf.lastCounters.visibleUpdates or 0,
        "scans/s:", perf.lastCounters.scanCalls or 0,
        "probes:", perf.nativeProbes or 0,
        "full/s:", perf.lastCounters.fullUpdates or 0,
        "healthcfg/s:", perf.lastCounters.configureHealthBar or 0,
        "nativehide/s:", perf.lastCounters.hideNativeParts or 0
    )
end

function NP:TogglePerf()
    local perf = self.Perf
    if not perf then return end
    if perf.enabled then
        self:PrintPerfSnapshot()
        perf.enabled = false
        ClearTable(perf.counters)
        FP:Print("perf disabled")
    else
        perf.enabled = true
        ClearTable(perf.counters)
        ClearTable(perf.lastCounters)
        perf.lastTime = GetTime()
        FP:Print("perf enabled. Run /fp perf again to print the latest counters and disable it.")
    end
end

local greenColorToClass = {}
local classColors = {}

local function RegisterClassColor(class, color)
    if not class or not color then return end
    local r, g, b = tonumber(color.r), tonumber(color.g), tonumber(color.b)
    if not r or not g or not b then return end

    greenColorToClass[math.floor(g * 100 + 0.5) / 100] = class
    classColors[#classColors + 1] = {class = class, r = r, g = g, b = b}
end

for class, color in pairs(RAID_CLASS_COLORS) do
    RegisterClassColor(class, color)
end

if CUSTOM_CLASS_COLORS then
    for class, color in pairs(CUSTOM_CLASS_COLORS) do
        RegisterClassColor(class, color)
    end
end

function NP:GetClassFromHealthBarColor(frame, strictRGB)
    if not frame or not frame.oldHealthBar then return nil end

    local r, g, b = frame.oldHealthBar:GetStatusBarColor()
    r, g, b = tonumber(r), tonumber(g), tonumber(b)
    if not r or not g or not b then return nil end

    -- Old 3.3.5a trick: enemy class-colored bars can be guessed by green value.
    -- Friendly plates use stricter RGB so NPC colors don't get mistaken for classes.
    if not strictRGB then
        local byGreen = greenColorToClass[math.floor(g * 100 + 0.5) / 100]
        if byGreen then
            return byGreen
        end
    end

    local bestClass, bestDistance
    for i = 1, #classColors do
        local c = classColors[i]
        local dr, dg, db = r - c.r, g - c.g, b - c.b
        local distance = (dr * dr) + (dg * dg) + (db * db)
        if not bestDistance or distance < bestDistance then
            bestDistance = distance
            bestClass = c.class
        end
    end

    -- Friendly native sensor must be conservative to avoid classifying NPC reaction colors.
    -- 0.012 is roughly <= 0.11 per channel if evenly spread, but usually much stricter.
    local threshold = strictRGB and 0.012 or 0.035
    if bestClass and bestDistance and bestDistance <= threshold then
        return bestClass, bestDistance
    end
end

local function CleanName(name)
    if not name then return nil end
    name = string.gsub(name, "%s*%*?$", "")
    name = string.gsub(name, "%s%-%s.*$", "")
    return name
end

function NP:RefreshNativePlateName(frame)
    if not frame or not frame.oldName or not frame.oldName.GetText then return false end

    local latestName = CleanName(frame.oldName:GetText())
    if not latestName or latestName == "" or latestName == UNKNOWN then
        return false
    end

    if latestName == frame.UnitName then
        return false
    end

    -- Plates get recycled. If the native name changes, any old token/GUID/class
    -- on the frame is now suspect and has to be rebuilt from the new name.
    frame.UnitName = latestName
    frame.unit = nil
    frame.castbarUnit = nil
    frame.isGroupUnit = nil
    frame.guid = nil
    frame.NeutralNPCLayoutAttackable = nil
    self:ClearResolvedClass(frame, true)

    local reaction, unitType = self:GetUnitInfo(frame)
    frame.UnitReaction = reaction
    frame.UnitType = unitType

    self:RefreshFriendlyGroupBinding(frame)

    return true
end


function NP:MakeNativeSensorInvisible(frame)
    if not frame then return end

    -- Keep the native healthbar alive as an invisible C++ color sensor.
    -- Do not Hide(), reparent, recolor, or retexture it while probing.
    local hb = frame.oldHealthBar
    if hb then
        if hb.EnableMouse and not frame.NativeSensorMouseDisabled then
            hb:EnableMouse(false)
            frame.NativeSensorMouseDisabled = true
        end
        SetAlphaIfChanged(hb, 0.001)

        local tex = hb.GetStatusBarTexture and hb:GetStatusBarTexture()
        SetAlphaIfChanged(tex, 0)
        SetAlphaIfChanged(hb.bg, 0)
        if hb.SetFrameLevel and frame.Health and frame.Health.GetFrameLevel then
            SetFrameLevelIfChanged(hb, math.max((frame.Health:GetFrameLevel() or 1) - 1, 0))
        end
    end

    SetAlphaIfChanged(frame.oldName, 0)
    SetAlphaIfChanged(frame.oldLevel, 0)
end

function NP:QueueNativeClassProbe(frame, force)
    if not frame or not frame.oldHealthBar or not frame.UnitName then return end
    if frame.UnitType ~= "ENEMY_PLAYER" then return end
    if frame.UnitClass and not force then return end

    frame.nativeClassProbeTicks = 4
    self.NativeClassProbeQueue[frame] = true
    self:MakeNativeSensorInvisible(frame)
end

function NP:CacheResolvedClass(frame, class, source)
    if not frame or not class or not RAID_CLASS_COLORS[class] then return false end

    source = source or "unknown"
    frame.UnitClass = class
    frame.UnitClassSource = source
    frame.UnitClassTrusted = (source == "token" or source == "guid" or source == "arena" or source == "group")

    -- Name cache is only allowed from trusted/direct sources. Native color probes can be wrong
    -- on friendly plates and must not poison future recycled plates.
    if frame.UnitName
        and (frame.UnitType == "FRIENDLY_PLAYER" or frame.UnitType == "ENEMY_PLAYER")
        and frame.UnitClassTrusted then
        self.ClassCache[frame.UnitName] = class
    end

    return true
end

function NP:ClearResolvedClass(frame, clearIcon)
    if not frame then return end

    frame.UnitClass = nil
    frame.UnitClassSource = nil
    frame.UnitClassTrusted = nil
    self.NativeClassProbeQueue[frame] = nil
    frame.nativeClassProbeTicks = nil

    if clearIcon and frame.ClassIcon then
        if self.ClearClassIcon then
            self:ClearClassIcon(frame)
        else
            frame.ClassIcon._fruitplatesClass = nil
            frame.ClassIcon._fruitplatesTexture = nil
            if frame.ClassIcon.Texture then
                frame.ClassIcon.Texture:SetTexture(nil)
            end
            if frame.ClassIcon:IsShown() then
                frame.ClassIcon:Hide()
            end
        end
    end
end

function NP:IsFriendlyClassStylingAllowed(frame)
    if not frame or frame.UnitType ~= "FRIENDLY_PLAYER" then return true end

    -- Optional visual-consistency mode for crowded cities/open world.
    -- Target/mouseover can still resolve identity internally, but class color/icons
    -- are only displayed for stable party/raid identity.
    if self.db and self.db.groupOnlyFriendlyClassStyling == true then
        return frame.isGroupUnit == true
    end

    return frame.UnitClassTrusted == true
end

function NP:TryCachedClass(frame)
    if not frame or frame.UnitClass or not frame.UnitName then return false end
    if frame.UnitType ~= "FRIENDLY_PLAYER" and frame.UnitType ~= "ENEMY_PLAYER" then return false end

    -- Friendly players in cities are the dangerous case: name-only cached class can be stale
    -- or inherited from a recycled plate. Only use cache if we already have a stronger identity.
    if frame.UnitType == "FRIENDLY_PLAYER" and not frame.guid and not (frame.unit and UnitExists(frame.unit)) then
        return false
    end

    local class = self.ClassCache[frame.UnitName]
    if class and RAID_CLASS_COLORS[class] then
        return self:CacheResolvedClass(frame, class, "cache")
    end

    return false
end

function NP:TryNativeClassProbe(frame)
    if not frame or not frame.oldHealthBar then return false end
    -- Native color probing on FRIENDLY_PLAYER is not trusted on 3.3.5a.
    -- It can read default/bright bars as PRIEST and show wrong class icons/colors.
    if frame.UnitType ~= "ENEMY_PLAYER" then return false end

    local class = self:GetClassFromHealthBarColor(frame, true)
    if class and self:CacheResolvedClass(frame, class, "native") then
        frame.nativeClassProbeTicks = nil
        self.NativeClassProbeQueue[frame] = nil
        return true
    end

    return false
end

function NP:RunNativeClassProbes()
    local active = 0
    local scanned = 0
    local budget = 8
    for frame in pairs(self.NativeClassProbeQueue) do
        if not frame or not frame:IsShown() or not frame.oldHealthBar then
            self.NativeClassProbeQueue[frame] = nil
        else
            active = active + 1
            if scanned < budget then
                scanned = scanned + 1
                -- Old 3.3.5 plates recycle frames. Probe a few per frame so
                -- Dalaran/arena spikes do not all hit the native bar sensor at once.
                self:MakeNativeSensorInvisible(frame)

                if self:TryNativeClassProbe(frame) then
                    self:Update_HealthColor(frame)
                    self:Update_Name(frame)
                    self:Update_ClassIcon(frame)
                else
                    frame.nativeClassProbeTicks = (frame.nativeClassProbeTicks or 0) - 1
                    if frame.nativeClassProbeTicks <= 0 then
                        self.NativeClassProbeQueue[frame] = nil
                        frame.nativeClassProbeTicks = nil
                    end
                end
            end
        end
    end
    if self.Perf and self.Perf.enabled then
        self.Perf.nativeProbes = active
        self:BumpPerf("nativeProbeFrames", active)
    end
end



function NP:UnitLevel(frame)
    if not frame.oldLevel or frame.oldLevel:GetObjectType() ~= "FontString" then
        return "??", 0.9, 0, 0
    end

    local text = frame.oldLevel:GetText()
    local level = tonumber(text)
    local boss = frame.BossIcon and frame.BossIcon:IsShown()
    if boss or not level then
        return "??", 0.9, 0, 0
    end

    local r, g, b = frame.oldLevel:GetTextColor()
    return level, r, g, b
end

function NP:GetUnitInfo(frame)
    local r, g, b = frame.oldHealthBar:GetStatusBarColor()
    r, g, b = tonumber(r) or 0, tonumber(g) or 0, tonumber(b) or 0

    -- First honor the old Blizzard reaction colors. This must happen before the
    -- class-color fallback, otherwise bright/white friendly NPC plates can be
    -- misread as PRIEST and inherit player visuals/icons.
    if r < 0.05 then
        if b < 0.05 and g > 0.90 then
            return 5, "FRIENDLY_NPC"
        elseif b > 0.90 and g < 0.15 then
            return 5, "FRIENDLY_PLAYER"
        end
    elseif r > 0.90 then
        if b < 0.15 and g > 0.90 then
            return 4, "ENEMY_NPC"
        elseif b < 0.15 and g < 0.15 then
            return 2, "ENEMY_NPC"
        end
    elseif r > 0.45 and r < 0.70 then
        if g > 0.45 and g < 0.70 and b > 0.45 and b < 0.70 then
            return 1, "ENEMY_NPC"
        end
    end

    -- Very bright/white or grey nameplate bars are commonly neutral/friendly NPCs
    -- on old clients/private servers. Do not allow the priest class-color fallback
    -- to steal these plates.
    if r > 0.80 and g > 0.80 and b > 0.80 then
        return 5, "FRIENDLY_NPC"
    end

    -- Enemy player class-color fallback. This is intentionally late and is only
    -- used when the plate did not look like a clear NPC/reaction plate.
    if self:GetClassFromHealthBarColor(frame) then
        return 3, "ENEMY_PLAYER"
    end

    return 3, "ENEMY_PLAYER"
end

function NP:GetUnitTypeFromUnit(unit)
    local reaction = UnitReaction("player", unit)
    local isPlayer = UnitIsPlayer(unit)

    if not isPlayer and UnitIsOtherPlayersPet and UnitIsOtherPlayersPet(unit) then
        if UnitIsFriend("player", unit) and reaction and reaction >= 5 then
            return "FRIENDLY_PET"
        end
        return "ENEMY_PET"
    end

    if not isPlayer and UnitPlayerControlled and UnitPlayerControlled(unit) then
        if UnitIsFriend("player", unit) and reaction and reaction >= 5 then
            return "FRIENDLY_PET"
        end
        return "ENEMY_PET"
    end

    if isPlayer and UnitIsFriend("player", unit) and reaction and reaction >= 5 then
        return "FRIENDLY_PLAYER"
    elseif not isPlayer then
        -- Neutral NPCs are reaction 4 on the old client. Do not classify them as
        -- FRIENDLY_NPC just because UnitFactionGroup(unit) can report "Neutral";
        -- FruitPlates already uses frame.UnitReaction == 4 to apply the exposed
        -- neutral NPC color, while ENEMY_NPC keeps neutral plates out of the
        -- friendly NPC sizing/behavior bucket.
        if reaction and reaction >= 5 then
            return "FRIENDLY_NPC"
        end
        return "ENEMY_NPC"
    else
        return "ENEMY_PLAYER"
    end
end


function NP:CachePetUnit(frame, unit, unitType)
    if not unitType or (unitType ~= "ENEMY_PET" and unitType ~= "FRIENDLY_PET") then return end

    local name = CleanName(UnitName(unit)) or (frame and frame.UnitName)
    local guid = UnitGUID(unit)

    if name and name ~= "" then
        self.PetNameToType[name] = unitType
    end
    if guid then
        self.PetGUIDToType[guid] = unitType
    end

    if frame then
        frame._fruitplatesPetUnitType = unitType
        frame._fruitplatesPetName = name
        frame._fruitplatesPetGUID = guid
    end
end

function NP:GetCachedPetType(frame)
    if not frame then return nil end

    if frame._fruitplatesPetUnitType == "ENEMY_PET" or frame._fruitplatesPetUnitType == "FRIENDLY_PET" then
        return frame._fruitplatesPetUnitType
    end

    if frame.guid and self.PetGUIDToType[frame.guid] then
        return self.PetGUIDToType[frame.guid]
    end

    if frame.UnitName and self.PetNameToType[frame.UnitName] then
        return self.PetNameToType[frame.UnitName]
    end

    return nil
end


function NP:GetUnitByName(frame, unitType)
    return self[unitType] and self[unitType][frame.UnitName]
end

function NP:RefreshFriendlyGroupBinding(frame)
    if not frame or not frame.UnitName then return false end
    if frame.UnitType ~= "FRIENDLY_PLAYER" and frame.UnitType ~= "FRIENDLY_PET" then return false end

    local plateName = self:GetNativePlateName(frame) or CleanName(frame.UnitName)
    if not plateName or plateName == "" or plateName == UNKNOWN then return false end

    local currentUnitName
    if frame.isGroupUnit and frame.unit and UnitExists(frame.unit) then
        currentUnitName = CleanName(UnitName(frame.unit))
        if currentUnitName == plateName then
            return false
        end
    end

    local unit = self[frame.UnitType] and self[frame.UnitType][plateName]
    if unit and UnitExists(unit) then
        local oldUnit = frame.unit
        local oldGUID = frame.guid

        frame.unit = unit
        frame.isGroupUnit = true
        frame.guid = UnitGUID(unit)

        if frame.UnitType == "FRIENDLY_PLAYER" then
            self:ClearResolvedClass(frame, true)
            local _, class = UnitClass(unit)
            if class then
                self:CacheResolvedClass(frame, class, "group")
            else
                local resolved = self:GetUnitClassByGUID(frame, frame.guid)
                if resolved then self:CacheResolvedClass(frame, resolved, "group") end
            end
        else
            self:ClearResolvedClass(frame, true)
        end

        return oldUnit ~= frame.unit or oldGUID ~= frame.guid
    end

    if frame.isGroupUnit then
        frame.unit = nil
        frame.isGroupUnit = nil
        frame.guid = nil
        self:ClearResolvedClass(frame, true)
        return true
    end

    return false
end


function NP:RebuildArenaCastbarMap()
    ClearTable(self.ArenaCastbarNameToUnit)
    ClearTable(self.ArenaCastbarUnitToName)

    for i = 1, 5 do
        local unit = "arena" .. i
        if UnitExists(unit) then
            local name = CleanName(UnitName(unit))
            if name and name ~= "" then
                self.ArenaCastbarNameToUnit[name] = unit
                self.ArenaCastbarUnitToName[unit] = name
            end
        end

        local pet = "arenapet" .. i
        if UnitExists(pet) then
            local petName = CleanName(UnitName(pet))
            if petName and petName ~= "" then
                self.ArenaCastbarNameToUnit[petName] = pet
                self.ArenaCastbarUnitToName[pet] = petName
            end
        end
    end

    self.ArenaCastbarLastUpdate = GetTime()
end


function NP:GetArenaCastbarUnitByName(name)
    name = CleanName(name)
    if not name or name == "" then return nil end

    if GetTime() - (self.ArenaCastbarLastUpdate or 0) > 0.5 then
        self:RebuildArenaCastbarMap()
    end

    local direct = self.ArenaCastbarNameToUnit[name]
    if direct and UnitExists(direct) then
        return direct
    end

    for arenaName, unit in pairs(self.ArenaCastbarNameToUnit) do
        if name == arenaName then
            return UnitExists(unit) and unit or nil
        end

        -- Accept "Name-Realm" or name prefixes used by some nameplate text formats.
        if string.find(name, arenaName, 1, true) == 1 then
            local nextChar = string.sub(name, string.len(arenaName) + 1, string.len(arenaName) + 1)
            if nextChar == "" or nextChar == "-" or nextChar == " " then
                return UnitExists(unit) and unit or nil
            end
        end
    end

    return nil
end

function NP:GetVisiblePlateName(frame)
    if not frame then return nil end

    local name = CleanName(frame.UnitName)
    if name and name ~= "" and name ~= UNKNOWN then
        return name
    end

    if frame.oldName and frame.oldName.GetText then
        name = CleanName(frame.oldName:GetText())
        if name and name ~= "" and name ~= UNKNOWN then
            return name
        end
    end

    return nil
end


function NP:GetNativePlateName(frame)
    if not frame then return nil end

    -- For target/mouseover force-refresh we must read the raw Blizzard name text
    -- first. frame.UnitName may be temporarily mutated by token resolving on old
    -- 3.3.5a recycled plates, and using it for matching can leak the current
    -- mouseover/target identity into other already-resolved friendly plates.
    if frame.oldName and frame.oldName.GetText then
        local name = CleanName(frame.oldName:GetText())
        if name and name ~= "" and name ~= UNKNOWN then
            return name
        end
    end

    local name = CleanName(frame.UnitName)
    if name and name ~= "" and name ~= UNKNOWN then
        return name
    end

    return nil
end

local function IsNPCUnitType(unitType)
    return unitType == "ENEMY_NPC" or unitType == "FRIENDLY_NPC"
end

local function IsPetUnitType(unitType)
    return unitType == "ENEMY_PET" or unitType == "FRIENDLY_PET"
end

local function IsNPCOrPetUnitType(unitType)
    return IsNPCUnitType(unitType) or IsPetUnitType(unitType)
end

function NP:RefreshNeutralNPCAttackableProof(frame, unit)
    if not frame then return false end

    if frame.UnitType ~= "ENEMY_NPC" or frame.UnitReaction ~= 4 then
        if frame.NeutralNPCLayoutAttackable ~= nil then
            frame.NeutralNPCLayoutAttackable = nil
            return true
        end
        return false
    end

    if not unit or not UnitExists(unit) or UnitIsPlayer(unit) then return false end

    if unit == "mouseover" and frame._fruitplatesNeutralNPCMouseoverProof ~= true then
        return false
    end

    local tokenType = self:GetUnitTypeFromUnit(unit)
    if not IsNPCUnitType(tokenType) then return false end

    -- Trusted-token override only. Neutral/yellow color remains reaction-driven;
    -- this flag only lets proven attackable neutral NPCs borrow Enemy Plate layout.
    local attackable = UnitCanAttack and UnitCanAttack("player", unit) and true or false
    if frame.NeutralNPCLayoutAttackable ~= attackable then
        frame.NeutralNPCLayoutAttackable = attackable
        return true
    end

    return false
end

-- Some neutral/yellow NPCs on 3.3.5a report as friendly through the live
-- target token once targeted, even though the physical Blizzard nameplate is
-- still yellow. For nameplates, the native plate color is the ground truth for
-- neutral reaction. Preserve reaction 4 so neutral NPCs keep the exposed
-- neutral NPC color instead of flipping to friendly-green on target.
function NP:GetNPCTokenTypeAndReactionFromPlate(frame, unit)
    local unitType = self:GetUnitTypeFromUnit(unit) or (frame and frame.UnitType)
    local reaction = UnitReaction("player", unit) or (frame and frame.UnitReaction)

    if frame and unit and UnitExists(unit) and not UnitIsPlayer(unit) then
        local nativeReaction, nativeType = self:GetUnitInfo(frame)
        if nativeReaction == 4 then
            return "ENEMY_NPC", 4
        end
        if nativeReaction and nativeReaction >= 5 and IsNPCUnitType(nativeType) then
            return "FRIENDLY_NPC", nativeReaction
        end
        if nativeReaction and nativeReaction < 4 and IsNPCUnitType(nativeType) then
            return "ENEMY_NPC", nativeReaction
        end
    end

    return unitType, reaction
end

function NP:IsFriendlyPlayerForceRefreshPlate(frame, unit)
    if not frame or not unit or not UnitExists(unit) then return false end
    -- Keep the aggressive open-world friendly resolver for hard target only.
    -- Mouseover name-only promotion can leak the current token identity into
    -- already-resolved nearby friendly plates on the old 3.3.5a client.
    if unit ~= "target" then return false end

    local unitType = self:GetUnitTypeFromUnit(unit)
    if unitType ~= "FRIENDLY_PLAYER" or not UnitIsPlayer(unit) then return false end

    -- Keep this strictly friendly-player only. Do not affect NPCs, pets,
    -- enemy players, arena tokens, or group/raid token logic.
    if frame.UnitType and frame.UnitType ~= "FRIENDLY_PLAYER" then return false end

    local unitName = CleanName(UnitName(unit))
    local plateName = self:GetNativePlateName(frame)
    if not unitName or unitName == "" or unitName == UNKNOWN then return false end
    if not plateName or plateName ~= unitName then return false end

    return true
end

function NP:IsOpenWorldPlayerTargetPlate(frame, unit)
    if not frame or unit ~= "target" or not UnitExists(unit) then return false end
    if not UnitIsPlayer(unit) then return false end

    local unitType = self:GetUnitTypeFromUnit(unit)
    if unitType ~= "ENEMY_PLAYER" and unitType ~= "FRIENDLY_PLAYER" then return false end

    -- Hard-target player bridge only. No NPCs, pets, mouseover, or arena mapping.
    -- If arena tokens already know this unit, leave that path in charge.
    local unitName = CleanName(UnitName(unit))
    if not unitName or unitName == "" or unitName == UNKNOWN then return false end
    if self:GetArenaCastbarUnitByName(unitName) then return false end

    local plateType = frame.UnitType
    if plateType and plateType ~= "ENEMY_PLAYER" and plateType ~= "FRIENDLY_PLAYER" then return false end

    local plateName = self:GetNativePlateName(frame)
    if not plateName or plateName ~= unitName then return false end

    return true
end

function NP:HasPhysicalMouseoverEvidence(frame, allowFrameHitTest)
    if not frame then return false end

    -- Primary old-client signal: Blizzard shows this region on the physical
    -- nameplate under the mouse. This remains the safest anti-leak selector.
    if frame.oldHighlight and frame.oldHighlight.IsShown and frame.oldHighlight:IsShown() then
        return true
    end

    -- Responsiveness fallback for friendly players only: UPDATE_MOUSEOVER_UNIT
    -- can fire before the native highlight is visible again, especially after
    -- FruitPlates hides it for visual cleanup. A real frame hit-test is still
    -- physical-frame evidence, not name-only promotion, and friendly player
    -- names are unique, so the later UnitName match remains safe. Keep this
    -- fallback opt-in so same-name NPC/pet paths stay on stricter native proof.
    if allowFrameHitTest then
        local plate = frame.GetParent and frame:GetParent() or nil
        if plate and plate.IsMouseOver and plate:IsMouseOver() then
            return true
        end
        if frame.IsMouseOver and frame:IsMouseOver() then
            return true
        end
        if frame.Health and frame.Health.IsMouseOver and frame.Health:IsMouseOver() then
            return true
        end
    end

    return false
end

function NP:IsFriendlyPlayerPhysicalMouseoverPlate(frame, unit)
    if not frame or unit ~= "mouseover" or not UnitExists("mouseover") then return false end

    -- Mouseover must be selected by the physical Blizzard mouseover highlight
    -- first, then token-resolved. Do not use name-only mouseover promotion;
    -- fast mouse sweeps across friendly clusters can otherwise copy identity
    -- into nearby already-resolved plates.
    if not self:HasPhysicalMouseoverEvidence(frame, true) then
        return false
    end

    local unitType = self:GetUnitTypeFromUnit("mouseover")
    if unitType ~= "FRIENDLY_PLAYER" or not UnitIsPlayer("mouseover") then return false end

    -- Keep this strictly friendly-player only. Do not affect NPCs, pets,
    -- enemy players, arena tokens, or group/raid token logic.
    if frame.UnitType and frame.UnitType ~= "FRIENDLY_PLAYER" then return false end

    local unitName = CleanName(UnitName("mouseover"))
    local plateName = self:GetNativePlateName(frame)
    if not unitName or unitName == "" or unitName == UNKNOWN then return false end
    if not plateName or plateName ~= unitName then return false end

    return true
end


function NP:IsPetForceRefreshPlate(frame, unit)
    if not frame or not unit or not UnitExists(unit) then return false end
    if unit ~= "target" then return false end

    local unitType = self:GetUnitTypeFromUnit(unit)
    if not IsPetUnitType(unitType) or UnitIsPlayer(unit) then return false end

    -- Targeted pets may first be classified from the native plate as NPCs. Allow
    -- only NPC/pet-looking frames to be promoted into the proper pet bucket.
    if frame.UnitType and not IsNPCOrPetUnitType(frame.UnitType) then return false end

    local unitName = CleanName(UnitName(unit))
    local plateName = self:GetNativePlateName(frame)
    if not unitName or unitName == "" or unitName == UNKNOWN then return false end
    if not plateName or plateName ~= unitName then return false end

    return true
end

function NP:IsPetPhysicalMouseoverPlate(frame, unit)
    if not frame or unit ~= "mouseover" or not UnitExists("mouseover") then return false end

    -- Pet mouseover follows the same safe model as friendly players: the native
    -- Blizzard mouseover highlight selects the physical plate first, then the
    -- mouseover token is applied only to that one frame. No name-scan mouseover.
    if not self:HasPhysicalMouseoverEvidence(frame) then
        return false
    end

    local unitType = self:GetUnitTypeFromUnit("mouseover")
    if not IsPetUnitType(unitType) or UnitIsPlayer("mouseover") then return false end

    if frame.UnitType and not IsNPCOrPetUnitType(frame.UnitType) then return false end

    local unitName = CleanName(UnitName("mouseover"))
    local plateName = self:GetNativePlateName(frame)
    if not unitName or unitName == "" or unitName == UNKNOWN then return false end
    if not plateName or plateName ~= unitName then return false end

    return true
end

function NP:IsNeutralNPCPhysicalMouseoverPlate(frame, unit)
    if not frame or unit ~= "mouseover" or not UnitExists("mouseover") then return false end

    -- NPC mouseover attackability is accepted only when the physical Blizzard
    -- mouseover highlight selected this exact frame. This avoids same-name NPC
    -- leakage while allowing neutral/yellow NPC layout to upgrade after real proof.
    if not self:HasPhysicalMouseoverEvidence(frame) then
        return false
    end

    local unitType = self:GetUnitTypeFromUnit("mouseover")
    if not IsNPCUnitType(unitType) or UnitIsPlayer("mouseover") then return false end
    if frame.UnitType and not IsNPCUnitType(frame.UnitType) then return false end

    local unitName = CleanName(UnitName("mouseover"))
    local plateName = self:GetNativePlateName(frame)
    if not unitName or unitName == "" or unitName == UNKNOWN then return false end
    if not plateName or plateName ~= unitName then return false end

    return true
end

function NP:IsStrictUnitPlate(frame, unit)
    if not frame or not unit or not UnitExists(unit) then return false end

    local unitName = CleanName(UnitName(unit))
    if not unitName or unitName == "" or unitName == UNKNOWN then return false end

    local plateName = self:GetNativePlateName(frame)
    if not plateName or plateName ~= unitName then return false end

    local unitType = self:GetUnitTypeFromUnit(unit)

    -- NPC-only safety: target NPCs must not be accepted by name alone.
    -- Several world mobs can share the same visible name, and name-only target
    -- matching would spread target highlight/cast state to all of them.
    -- Keep this restricted to the live target token and NPC-ish frames only;
    -- arena/party/raid/player logic remains unchanged.
    if unit == "target" and IsNPCUnitType(unitType) and IsNPCUnitType(frame.UnitType) then
        return self:IsNativeTargetNPCPlate(frame)
    end

    -- Open-world player target bridge. This keeps duel/player castbars awake
    -- when the normal optimized path has not copied the target token yet.
    if self:IsOpenWorldPlayerTargetPlate(frame, unit) then
        return true
    end

    -- Friendly open-world polish: hard target may promote the exact friendly-player
    -- plate immediately, even if the old recycled plate still carries stale
    -- GUID/class state. Mouseover intentionally does not use this bypass;
    -- it must keep the older strict anti-leak behavior.
    if self:IsFriendlyPlayerForceRefreshPlate(frame, unit) then
        return true
    end

    -- Open-world pet polish: hard-targeted pets may promote from the native NPC
    -- bucket into ENEMY_PET/FRIENDLY_PET immediately. This is target-only;
    -- mouseover pet resolving uses physical oldHighlight selection below.
    if self:IsPetForceRefreshPlate(frame, unit) then
        return true
    end

    if self:IsPetPhysicalMouseoverPlate(frame, unit) then
        return true
    end

    local guid = UnitGUID(unit)
    if guid and frame.guid and frame.guid ~= guid then
        -- A visible plate already trusted as a different GUID must not be
        -- rewritten just because the current mouseover/target changed.
        return false
    end

    if unitType and frame.UnitType then
        local plateIsPlayer = frame.UnitType == "ENEMY_PLAYER" or frame.UnitType == "FRIENDLY_PLAYER"
        local unitIsPlayer = UnitIsPlayer(unit)
        if plateIsPlayer ~= unitIsPlayer then
            return false
        end
    end

    return true
end

function NP:ApplyUnitTokenStrict(frame, unit)
    if not self:IsStrictUnitPlate(frame, unit) then return false end
    return self:ApplyUnitToken(frame, unit)
end

function NP:IsNativeTargetNPCPlate(frame)
    if not frame or not UnitExists("target") then return false end

    -- NPC-only physical target proof. Blizzard usually keeps the real target
    -- plate at full parent alpha while the others are dimmed. That is safer
    -- than name-only matching when several mobs share a name.
    local targetType = self:GetUnitTypeFromUnit("target")
    if not IsNPCUnitType(targetType) or not IsNPCUnitType(frame.UnitType) then
        return false
    end

    local targetName = CleanName(UnitName("target"))
    local plateName = self:GetNativePlateName(frame)
    if not targetName or targetName == "" or targetName == UNKNOWN or plateName ~= targetName then
        return false
    end

    return frame.parentAlpha and frame.parentAlpha >= 0.99
end

function NP:ApplyNativeTargetNPCUnit(frame)
    if not self:IsNativeTargetNPCPlate(frame) then return false end

    local unitType, reaction = self:GetNPCTokenTypeAndReactionFromPlate(frame, "target")
    unitType = unitType or frame.UnitType
    reaction = reaction or frame.UnitReaction

    frame.unit = "target"
    frame.guid = UnitGUID("target")
    frame.UnitName = CleanName(UnitName("target")) or frame.UnitName
    frame.UnitType = unitType
    frame.UnitReaction = reaction
    self:RefreshNeutralNPCAttackableProof(frame, "target")
    frame.UnitClass = nil
    frame.UnitClassSource = nil
    frame.UnitClassTrusted = nil

    return true
end

function NP:CountVisiblePlatesByName(name)
    name = CleanName(name)
    if not name or name == "" then return 0 end

    local count = 0
    for frame in pairs(self.VisiblePlates or {}) do
        if frame and frame.IsShown and frame:IsShown() and self:GetVisiblePlateName(frame) == name then
            count = count + 1
        end
    end

    return count
end

function NP:GetPlateMaxHealth(frame)
    if not frame then return nil end

    local hb = frame.oldHealthBar
    if hb and hb.GetMinMaxValues then
        local _, maxHealth = hb:GetMinMaxValues()
        maxHealth = tonumber(maxHealth)
        if maxHealth and maxHealth > 0 then
            return maxHealth
        end
    end

    if frame.Health and frame.Health._fruitplatesMaxHealth then
        local maxHealth = tonumber(frame.Health._fruitplatesMaxHealth)
        if maxHealth and maxHealth > 0 then
            return maxHealth
        end
    end

    return nil
end

function NP:IsMageMirrorImagePlate(frame, arenaUnit)
    if not frame or not arenaUnit or not UnitExists(arenaUnit) then return false end

    -- Only arena player Mages get this special protection. Do not affect pets,
    -- non-mage arena units, friendly plates, NPCs, or normal duplicate names.
    if not string.find(arenaUnit, "^arena%d$") then return false end

    local _, class = UnitClass(arenaUnit)
    if class ~= "MAGE" then return false end

    local arenaName = CleanName(UnitName(arenaUnit))
    local plateName = self:GetVisiblePlateName(frame)
    if not arenaName or not plateName or arenaName ~= plateName then return false end

    -- Name-only matching is unsafe only during the Mirror Image duplicate-name
    -- window. Outside of that, keep normal arena mapping behavior.
    if self:CountVisiblePlatesByName(arenaName) <= 1 then return false end

    local maxHealth = self:GetPlateMaxHealth(frame)
    if maxHealth and maxHealth > 0 and maxHealth < MIRROR_IMAGE_MAX_HEALTH_THRESHOLD then
        return true
    end

    return false
end


function NP:ApplyArenaPlayerUnit(frame)
    if not frame or not frame.UnitName then return false end

    local unit = self:GetArenaCastbarUnitByName(frame.UnitName)
    if not unit or not UnitExists(unit) then return false end

    if self:IsMageMirrorImagePlate(frame, unit) then
        if frame.castbarUnit == unit then frame.castbarUnit = nil end
        if frame.unit == unit then frame.unit = nil end
        return false
    end

    local oldType = frame.UnitType
    local oldReaction = frame.UnitReaction
    local _, class = UnitClass(unit)
    local unitType = self:GetUnitTypeFromUnit(unit) or oldType

    frame.unit = unit
    frame.isGroupUnit = true
    frame.castbarUnit = unit
    frame.guid = UnitGUID(unit) or frame.guid
    frame.UnitName = CleanName(UnitName(unit)) or frame.UnitName
    frame.UnitType = unitType
    frame.UnitReaction = UnitReaction("player", unit) or oldReaction or 2

    self:CachePetUnit(frame, unit, unitType)

    if UnitIsPlayer(unit) then
        local resolvedClass = class
        local source = class and "arena" or nil
        if not resolvedClass then
            resolvedClass = self:GetUnitClassByGUID(frame, frame.guid)
            source = resolvedClass and "guid" or nil
        end
        if resolvedClass then
            self:CacheResolvedClass(frame, resolvedClass, source or "arena")
        else
            frame.UnitClass = nil
            frame.UnitClassSource = nil
            frame.UnitClassTrusted = nil
        end
    else
        frame.UnitClass = nil
        frame.UnitClassSource = nil
        frame.UnitClassTrusted = nil
    end

    -- Arena unit tokens are authoritative. This includes arena1-5 and arenapet1-5.
    if oldType ~= frame.UnitType or oldReaction ~= frame.UnitReaction then
        frame.LayoutUnitType = nil
        self:UpdateElement_All(frame)

        local plate = frame:GetParent()
        if plate then
            self:SetSize(plate)
        end

        self:SetPlateFrameLevel(frame, frame.isTarget)
    end

    return true
end

function NP:UpdateArenaCastbarUnit(frame)
    if not frame then return nil end

    frame.castbarUnit = nil

    -- Arena players are authoritative over old nameplate reaction guesses.
    -- The raw 3.3.5a plate can occasionally look NPC-ish for one opponent.
    if self:ApplyArenaPlayerUnit(frame) then
        return frame.castbarUnit
    end

    if frame.UnitType ~= "ENEMY_PLAYER" and frame.UnitType ~= "ENEMY_PET" and frame.UnitType ~= "FRIENDLY_PET" then
        return nil
    end

    local unit = self:GetArenaCastbarUnitByName(frame.UnitName)
    if unit and not self:IsMageMirrorImagePlate(frame, unit) then
        frame.castbarUnit = unit
        return unit
    end

    return nil
end


function NP:GetGUIDByName(name, unitType)
    if not name then return nil end
    for guid, info in pairs(self.GUIDList) do
        if info.name == name and info.unitType == unitType then
            return guid
        end
    end
end

function NP:GetUnitClassByGUID(frame, guid)
    guid = guid or self:GetGUIDByName(frame.UnitName, frame.UnitType)
    if not guid or not GetPlayerInfoByGUID then return nil end

    local ok, v1, v2, v3, v4, v5, v6, v7, v8 = pcall(GetPlayerInfoByGUID, guid)
    if not ok then return nil end

    -- Return the first value that is an actual RAID_CLASS_COLORS key.
    -- Different 3.3.5a cores/builds expose GetPlayerInfoByGUID returns slightly differently,
    -- so this is safer than assuming one fixed return index.
    return ValidClass(v1) or ValidClass(v2) or ValidClass(v3) or ValidClass(v4)
        or ValidClass(v5) or ValidClass(v6) or ValidClass(v7) or ValidClass(v8)
end

function NP:UnitClass(frame, unitType)
    if unitType ~= "FRIENDLY_PLAYER" and unitType ~= "ENEMY_PLAYER" then
        return nil
    end

    -- Prefer real unit tokens whenever we have them. This makes class-coloring
    -- respond correctly for target/mouseover/arena/party/raid plates instead of
    -- relying only on Blizzard's hidden nameplate color.
    if frame.unit and UnitExists(frame.unit) then
        local _, class = UnitClass(frame.unit)
        if class then return class end
    end

    local class = self:GetUnitClassByGUID(frame, frame.guid)
    if class then return class end

    -- Enemy players can often be resolved from the green channel of the
    -- original Blizzard healthbar once class-colored nameplates are enabled.
    if unitType == "ENEMY_PLAYER" and frame.oldHealthBar then
        return self:GetClassFromHealthBarColor(frame)
    end
end

function NP:ApplyUnitToken(frame, unit)
    if not frame or not unit or not UnitExists(unit) or not frame.UnitName then return false end

    local tokenUnitType = self:GetUnitTypeFromUnit(unit)

    -- NPC-only safety: never allow the live target token to be applied to NPC
    -- plates by name alone. Several world NPCs can share the same name; using
    -- the old name fallback here briefly marked all same-name NPCs as target
    -- before the native physical-target proof corrected them on the next pass.
    -- Arena/player/group logic is intentionally untouched.
    if unit == "target" and IsNPCUnitType(tokenUnitType) and IsNPCUnitType(frame.UnitType) then
        if not self:IsNativeTargetNPCPlate(frame) then return false end
    elseif self:IsOpenWorldPlayerTargetPlate(frame, unit) then
        -- Allowed: exact raw-name hard-target token bridge for open-world player
        -- plates, used by normal duel/open-world castbars.
    elseif self:IsFriendlyPlayerForceRefreshPlate(frame, unit) then
        -- Allowed: exact raw-name hard-target promotion for open-world friendly
        -- players.
    elseif self:IsFriendlyPlayerPhysicalMouseoverPlate(frame, unit) then
        -- Allowed: friendly mouseover promotion only after the physical Blizzard
        -- mouseover highlight selected this exact frame. No name-only mouseover
        -- promotion.
    elseif self:IsPetForceRefreshPlate(frame, unit) then
        -- Allowed: target-only pet promotion from NPC-looking native plates into
        -- the proper pet bucket.
    elseif self:IsPetPhysicalMouseoverPlate(frame, unit) then
        -- Allowed: mouseover pet promotion only after physical Blizzard
        -- mouseover highlight selected this exact frame.
    elseif not self:IsUnitPlate(frame, unit) then
        return false
    end

    local unitType = tokenUnitType or frame.UnitType
    local reaction = UnitReaction("player", unit) or frame.UnitReaction
    if not UnitIsPlayer(unit) and IsNPCUnitType(unitType) then
        unitType, reaction = self:GetNPCTokenTypeAndReactionFromPlate(frame, unit)
        unitType = unitType or tokenUnitType or frame.UnitType
        reaction = reaction or frame.UnitReaction
    end
    local _, class = UnitClass(unit)

    frame.unit = unit
    frame.guid = UnitGUID(unit)
    frame.UnitName = CleanName(UnitName(unit)) or frame.UnitName
    frame.UnitType = unitType
    frame.UnitReaction = reaction
    self:RefreshNeutralNPCAttackableProof(frame, unit)

    self:CachePetUnit(frame, unit, unitType)

    if UnitIsPlayer(unit) then
        local resolvedClass = class
        local source = class and "token" or nil
        if not resolvedClass then
            resolvedClass = self:GetUnitClassByGUID(frame, frame.guid)
            source = resolvedClass and "guid" or nil
        end
        if resolvedClass then
            self:CacheResolvedClass(frame, resolvedClass, source or "token")
        else
            frame.UnitClass = nil
            frame.UnitClassSource = nil
            frame.UnitClassTrusted = nil
        end
    else
        frame.UnitClass = nil
        frame.UnitClassSource = nil
        frame.UnitClassTrusted = nil
    end

    return true
end

function NP:CheckRaidIcon(frame)
    -- First build only preserves the Blizzard raid icon texture and moves it.
    self:Update_RaidIcon(frame)
end

function NP:UpdateElement_All(frame)
    self:BumpPerf("fullUpdates")

    self:Update_HealthBar(frame)
    self:Configure_HealthBar(frame)
    self:Update_Health(frame)
    self:Update_HealthColor(frame)

    self:Configure_Name(frame)
    self:Update_Name(frame)

    self:Configure_Level(frame)
    self:Update_Level(frame)

    self:Configure_CastBar(frame)
    self:UpdateArenaCastbarUnit(frame)
    self:Update_CastBar(frame, nil, frame.unit or frame.castbarUnit)

    self:Update_RaidIcon(frame)
    self:Update_ClassIcon(frame)
    self:Update_Highlight(frame)
    self:Update_TotemIcon(frame)

    if self.Configure_Auras then self:Configure_Auras(frame) end
    if self.Update_Auras then self:Update_Auras(frame, "full-update") end
end


function NP:EnsureUnitTypeLayout(frame)
    if not frame or not frame.UnitType then return false end

    -- Track the last fully configured visual layout source, not only identity.
    -- NPC identity may remain ENEMY_NPC while layout borrows Enemy Plate or
    -- Friendly NPC settings depending on native reaction/proven attackability.
    local layoutType = self:GetLayoutUnitType(frame) or frame.UnitType
    if frame.LayoutUnitType == layoutType then
        return false
    end

    frame.LayoutUnitType = layoutType
    self:UpdateElement_All(frame)

    local plate = frame:GetParent()
    if plate then
        self:SetSize(plate)
    end
    self:SetPlateFrameLevel(frame, frame.isTarget)

    return true
end


function NP:SetPlateFrameLevel(frame, isTarget)
    if not frame or not frame.plateID then return end
    local level = isTarget and 890 or (10 + frame.plateID * 2)
    if frame._fruitplatesFrameLevelBase == level then return end
    frame._fruitplatesFrameLevelBase = level

    SetFrameLevelIfChanged(frame, level + 1)
    SetFrameLevelIfChanged(frame.Health, level + 2)
    SetFrameLevelIfChanged(frame.CastBar, level + 3)
    if frame.CastBar then SetFrameLevelIfChanged(frame.CastBar.Icon, level + 4) end

    -- Keep text above target highlight without changing highlight appearance.
    SetFrameLevelIfChanged(frame.TextLayer, level + 20)
    SetFrameLevelIfChanged(frame.ClassIcon, level + 22)
    SetFrameLevelIfChanged(frame.Auras, level + 24)
end

function NP:SetSize(plate)
    if InCombatLockdown and InCombatLockdown() then
        self.ResizeQueue[plate] = true
        return
    end

    local unitFrame = plate.UnitFrame
    if not unitFrame or not unitFrame.UnitType then return end

    local layoutType = self:GetLayoutUnitType(unitFrame) or unitFrame.UnitType
    local side = (layoutType == "FRIENDLY_PLAYER" or layoutType == "FRIENDLY_NPC") and "friendly" or "enemy"

    -- Totem icon mode replaces the visual plate, but the real Blizzard plate must
    -- remain clickable underneath. If the totem is selected, make the raw plate's
    -- clickable box match the icon. If the totem is known but unchecked, collapse it.
    if unitFrame.isTotemPlate and self.db and self.db.totems and self.db.totems.enable == false then
        SetAlphaIfChanged(plate, 1)
        SetWidthIfChanged(plate, 0.001)
        SetHeightIfChanged(plate, 0.001)
        self.ResizeQueue[plate] = nil
        return
    end

    if unitFrame.isTotemPlate and self.db and self.db.totems and self.db.totems.enable ~= false then
        SetAlphaIfChanged(plate, 1)

        local mode = self.db.totems.displayMode or (self.db.totems.enable == true and "ICONS" or "NAMEPLATES")
        if unitFrame.showTotemIcon then
            local size = (self.db.totems.size or 36) + 10
            SetWidthIfChanged(plate, size)
            SetHeightIfChanged(plate, size)
        elseif unitFrame.showTotemNameplate or mode == "NAMEPLATES" then
            local plateDB = self.db.totems.nameplate or {}
            SetWidthIfChanged(plate, (plateDB.width or 74) + 10)
            SetHeightIfChanged(plate, (plateDB.height or 7) + 28)
        else
            SetWidthIfChanged(plate, 0.001)
            SetHeightIfChanged(plate, 0.001)
        end

        self.ResizeQueue[plate] = nil
        return
    end

    local unitDB = self.db.units[layoutType]
    local healthDB = unitDB and unitDB.health
    local castDB = GetSizingCastBarDB(self.db, layoutType)
    local width = (healthDB and healthDB.width) or (side == "friendly" and self.db.plateSize.friendlyWidth or self.db.plateSize.enemyWidth) or 120
    local height = ((healthDB and healthDB.height) or 10) + ((castDB and castDB.enable and castDB.height) or 0) + 28

    -- Restore normal raw plate alpha after a reused frame leaves totem-icon mode.
    -- Do not touch raw Blizzard plate strata/framelevel here; that old fallback
    -- was confirmed to trigger native client framegaps on 3.3.5a.
    SetAlphaIfChanged(plate, 1)

    if self.db.clickThrough[side] then
        SetWidthIfChanged(plate, 0.001)
        SetHeightIfChanged(plate, 0.001)
    else
        SetWidthIfChanged(plate, width)
        SetHeightIfChanged(plate, height)
    end

    self.ResizeQueue[plate] = nil
end

function NP:OnShow(isConfig, dontHideHighlight)
    local plate = self
    local frame = plate.UnitFrame
    if not frame then return end

    NP.VisiblePlates[frame] = true

    if NP.db and NP.db.enable == false then
        frame:Hide()
        return
    end

    frame.UnitName = CleanName(frame.oldName and frame.oldName:GetText()) or UNKNOWN
    NP:ClearResolvedClass(frame, true)

    local reaction, unitType = NP:GetUnitInfo(frame)
    local oldUnitType = frame.UnitType
    local oldLayoutType = frame.LayoutUnitType
    frame.UnitReaction = reaction
    frame.UnitType = unitType
    NP:RefreshNeutralNPCAttackableProof(frame, nil)
    if oldUnitType and oldUnitType ~= unitType and NP.Clear_Auras then
        NP:Clear_Auras(frame)
    end

    local unit = NP:GetUnitByName(frame, unitType)
    if unit then
        frame.unit = unit
        frame.isGroupUnit = true
        frame.guid = UnitGUID(unit)
    else
        frame.unit = nil
        frame.isGroupUnit = nil
        frame.guid = NP:GetGUIDByName(frame.UnitName, unitType)
    end
    NP:RefreshFriendlyGroupBinding(frame)

    if frame.UnitType == "ENEMY_PLAYER" then
        local class = NP:UnitClass(frame, unitType)
        if class then NP:CacheResolvedClass(frame, class, frame.guid and "guid" or "native") end
        if not frame.UnitClass then NP:TryCachedClass(frame) end
        if not frame.UnitClass then NP:TryNativeClassProbe(frame) end
        if not frame.UnitClass then NP:QueueNativeClassProbe(frame) end
    elseif frame.UnitType == "FRIENDLY_PLAYER" then
        local class = NP:GetUnitClassByGUID(frame, frame.guid)
        if class then
            NP:CacheResolvedClass(frame, class, "guid")
        end
    else
        frame.UnitClass = nil
        frame.UnitClassSource = nil
        frame.UnitClassTrusted = nil
    end

    -- In arenas, arena1-5 tokens are more reliable than raw old-client plate reaction.
    -- Do this before the main configure pass so arena enemies never stay NPC-sized.
    NP:ApplyArenaPlayerUnit(frame)

    -- If this visible plate is the current target or mouseover, prefer the real unit token.
    -- This is required for reliable class colors on 3.3.5a because the native plate color
    -- resolver can be overwritten by class-colored Blizzard bars.
    NP:ApplyUnitToken(frame, "target")
    NP:ApplyUnitToken(frame, "mouseover")
    NP:UpdateArenaCastbarUnit(frame)

    frame.isTarget = NP:IsTargetPlate(frame)
    frame.isMouseover = NP:IsUnitPlate(frame, "mouseover")

    local layoutType = NP:GetLayoutUnitType(frame) or frame.UnitType
    if oldUnitType ~= frame.UnitType or oldLayoutType ~= layoutType or isConfig then
        NP:UpdateElement_All(frame)
    else
        NP:Update_Health(frame)
        NP:Update_HealthColor(frame)
        NP:Update_Name(frame)
        NP:Update_Level(frame)
        NP:Update_CastBar(frame, nil, frame.unit or frame.castbarUnit)
        NP:Update_RaidIcon(frame)
        NP:Update_ClassIcon(frame)
        NP:Update_Highlight(frame)
        NP:Update_TotemIcon(frame)
        if NP.Update_Auras then NP:Update_Auras(frame, "show-light") end
    end

    frame.LayoutUnitType = NP:GetLayoutUnitType(frame) or frame.UnitType

    NP:CheckRaidIcon(frame)
    NP:HideNativePlateParts(frame)
    NP:SetSize(plate)
    NP:SetPlateFrameLevel(frame, frame.isTarget)
    frame:Show()
end

function NP:OnHide()
    local plate = self
    local frame = plate.UnitFrame
    if not frame then return end

    NP.VisiblePlates[frame] = nil
    frame.unit = nil
    frame.castbarUnit = nil
    frame.isGroupUnit = nil
    frame.isTarget = nil
    frame.isMouseover = nil
    frame.UnitName = nil
    frame.UnitClass = nil
    frame.UnitClassSource = nil
    frame.UnitClassTrusted = nil
    frame.LayoutUnitType = nil
    frame.NeutralNPCLayoutAttackable = nil
    frame._fruitplatesNeutralNPCMouseoverProof = nil
    frame.UnitReaction = nil
    frame._fruitplatesFrameLevelBase = nil
    frame._fruitplatesNativeHidden = nil
    frame._fruitplatesHealthKey = nil
    frame._fruitplatesTotemKey = nil
    frame._fruitplatesRaidIconKey = nil
    frame._fruitplatesClassIconKey = nil
    NP.NativeClassProbeQueue[frame] = nil
    frame.nativeClassProbeTicks = nil
    frame.guid = nil
    frame.Health.r, frame.Health.g, frame.Health.b = nil, nil, nil
    frame.Health._fruitplatesHealthValue = nil
    frame.Health._fruitplatesMaxHealth = nil
    frame.Health._fruitplatesConfigKey = nil
    if NP.Clear_Auras then NP:Clear_Auras(frame) end
    frame.isTotemPlate = nil
    frame.showTotemIcon = nil
    if frame.Health and frame.Health.OutlineTop then
        frame.Health.OutlineTop:Hide()
        frame.Health.OutlineBottom:Hide()
        frame.Health.OutlineLeft:Hide()
        frame.Health.OutlineRight:Hide()
        frame.Health._fruitplatesOutlineT = nil
        frame.Health._fruitplatesOutlineR = nil
        frame.Health._fruitplatesOutlineG = nil
        frame.Health._fruitplatesOutlineB = nil
        frame.Health._fruitplatesOutlineGrowth = nil
    end

    if frame.ClassIcon then
        if NP.ClearClassIcon then
            NP:ClearClassIcon(frame)
        elseif NP.HideClassIconOutline then
            NP:HideClassIconOutline(frame.ClassIcon)
        end
    end

    if NP.HideTotemIcon then
        NP:HideTotemIcon(frame)
    elseif frame.TotemIcon then
        frame.TotemIcon:Hide()
        if frame.TotemIcon.TargetGlow then frame.TotemIcon.TargetGlow:Hide() end
    end
    -- Do not touch raw Blizzard plate strata/framelevel on hide. FruitPlates
    -- owns the child UnitFrame layers only.
    if frame.CastBar then
        frame.CastBar.casting = nil
        frame.CastBar.channeling = nil
        frame.CastBar:Hide()
    end
    frame:Hide()
end

function NP:QueueObject(object)
    FP:WipeObject(object)
end

function NP:SuppressNativeThreat(frame)
    -- Threat glow can be re-shown by the 3.3.5a client independently from
    -- normal nameplate updates. Keep this unthrottled and visual-only.
    -- Do not touch raw frame strata/level.
    if not frame then return end
    FP:WipeObject(frame.Threat)
end

function NP:HideNativePlateParts(frame, force)
    if not frame then return end

    self:SuppressNativeThreat(frame)


    local now = GetTime()
    if not force and frame._fruitplatesNativeHidden and frame._fruitplatesNextNativeHide and now < frame._fruitplatesNextNativeHide then
        return
    end

    self:BumpPerf("hideNativeParts")
    frame._fruitplatesNativeHidden = true
    frame._fruitplatesNextNativeHide = now + NATIVE_HIDE_INTERVAL

    -- Blizzard can re-show these pieces after our initial OnCreated wipe.
    -- Keep native healthbar alive as a hidden color sensor; wipe only non-sensor regions.
    self:MakeNativeSensorInvisible(frame)

    FP:WipeObject(frame.oldCastBar)
    if frame.oldCastBar then
        FP:WipeObject(frame.oldCastBar.Icon)
        FP:WipeObject(frame.oldCastBar.Shield)
    end
    FP:WipeObject(frame.oldHighlight)
    FP:WipeObject(frame.Threat)
    if frame.BossIcon then frame.BossIcon:SetAlpha(0) end
    if frame.EliteIcon then frame.EliteIcon:SetAlpha(0) end
end

function NP:IsUnitPlate(frame, unit)
    if not frame or not frame.UnitName or not unit or not UnitExists(unit) then return false end

    -- Do not treat frame.unit == unit as proof. If a plate was previously marked
    -- as target, frame.unit may still literally be "target" after the player
    -- changes target, and UnitIsUnit("target", "target") is always true.
    -- Only use this shortcut for stable external unit tokens, such as arena/party/raid.
    if frame.unit and frame.unit ~= unit and UnitIsUnit(frame.unit, unit) then
        return true
    end

    local guid = UnitGUID(unit)
    if guid and frame.guid and guid == frame.guid then
        return true
    end

    local unitName = UnitName(unit)
    if unitName and CleanName(unitName) == frame.UnitName then
        local unitType = self:GetUnitTypeFromUnit(unit)
        -- For players/NPCs the nameplate color gives the same family most of the time,
        -- but on some 3.3.5a situations reaction checks can be temporarily nil.
        -- Name match is still the strongest available old-client signal for target/mouseover.
        if not frame.UnitType or unitType == frame.UnitType then
            return true
        end

        local plateIsPlayer = frame.UnitType == "ENEMY_PLAYER" or frame.UnitType == "FRIENDLY_PLAYER"
        if plateIsPlayer and UnitIsPlayer(unit) then
            return true
        end

        local plateIsNPCish = frame.UnitType == "ENEMY_NPC" or frame.UnitType == "FRIENDLY_NPC" or frame.UnitType == "ENEMY_PET" or frame.UnitType == "FRIENDLY_PET"
        local unitIsPet = unitType == "ENEMY_PET" or unitType == "FRIENDLY_PET"
        if plateIsNPCish and unitIsPet then
            return true
        end
    end

    return false
end

function NP:IsTargetPlate(frame)
    if not hasTarget or not frame.UnitName then return false end

    local targetType = self:GetUnitTypeFromUnit("target")
    if IsNPCUnitType(targetType) and IsNPCUnitType(frame.UnitType) then
        -- NPC-only: avoid name-only target matching, because several world mobs
        -- can share the same name. Use the physical native target proof instead.
        return self:IsNativeTargetNPCPlate(frame)
    end

    if self:IsUnitPlate(frame, "target") then
        return true
    end


    return false
end

function NP:RefreshPlateAfterTokenTypeChange(frame, oldType, reason)
    if not frame then return false end

    local layoutType = self:GetLayoutUnitType(frame) or frame.UnitType
    if oldType == frame.UnitType and frame.LayoutUnitType == layoutType then return false end

    frame.LayoutUnitType = nil
    self:UpdateElement_All(frame)

    local plate = frame:GetParent()
    if plate then self:SetSize(plate) end

    self:SetPlateFrameLevel(frame, frame.isTarget)
    if self.Update_Auras then self:Update_Auras(frame, reason or "unit-type-changed") end
    return true
end

function NP:SetTargetFrame(frame)
    local wasTarget = frame.isTarget
    local oldType = frame.UnitType
    local tokenApplied = false
    local strictTarget = self:IsStrictUnitPlate(frame, "target")

    frame.isTarget = strictTarget or self:IsTargetPlate(frame)

    if strictTarget and not frame.isGroupUnit then
        tokenApplied = self:ApplyUnitTokenStrict(frame, "target") or tokenApplied
    elseif self:IsNativeTargetNPCPlate(frame) and not frame.isGroupUnit then
        tokenApplied = self:ApplyNativeTargetNPCUnit(frame) or tokenApplied
    elseif wasTarget and not frame.isMouseover and not frame.isGroupUnit then
        frame.unit = nil
        frame.guid = self:GetGUIDByName(frame.UnitName, frame.UnitType)
    end

    if tokenApplied and self:RefreshPlateAfterTokenTypeChange(frame, oldType, "target-type-changed") then
        return
    end

    if wasTarget ~= frame.isTarget then
        self:SetPlateFrameLevel(frame, frame.isTarget)
        self:Update_Highlight(frame)
        self:Update_CastBar(frame, nil, frame.unit or frame.castbarUnit)
        if self.Update_Auras then self:Update_Auras(frame, "target-changed") end
    end
end

function NP:RefreshMouseoverResolvedVisuals(frame, reason)
    if not frame then return end

    -- Mouseover token application can resolve a friendly player's class/GUID
    -- without changing UnitType/LayoutUnitType. Do the visible class-color/icon
    -- update immediately instead of waiting for the staggered heavy pass.
    self:Update_HealthColor(frame)
    self:Update_Name(frame)
    self:Update_RaidIcon(frame)
    self:Update_ClassIcon(frame)
    self:Update_Highlight(frame)
    self:Update_CastBar(frame, nil, frame.unit or frame.castbarUnit)
    if self.Update_Auras then self:Update_Auras(frame, reason or "mouseover-token") end
end

function NP:SetMouseoverFrame(frame)
    local oldType = frame.UnitType
    local tokenApplied = false

    -- Mouseover is physical-frame-selected first, token-resolved second.
    -- Friendly open-world mouseover must not use name-only promotion, because
    -- fast sweeps across clustered friendly plates can leak identity nearby.
    local physicalFriendlyMouseover = self:IsFriendlyPlayerPhysicalMouseoverPlate(frame, "mouseover")
    local physicalPetMouseover = self:IsPetPhysicalMouseoverPlate(frame, "mouseover")
    local physicalNeutralNPCMouseover = self:IsNeutralNPCPhysicalMouseoverPlate(frame, "mouseover")
    frame._fruitplatesNeutralNPCMouseoverProof = physicalNeutralNPCMouseover or nil

    local mouseoverType = UnitExists("mouseover") and self:GetUnitTypeFromUnit("mouseover") or nil
    local strictMouseover = false
    if mouseoverType ~= "FRIENDLY_PLAYER" and not IsPetUnitType(mouseoverType) then
        -- Keep the older strict behavior for non-friendly-player / non-pet
        -- mouseover paths. Friendly players and pets are handled only by
        -- physical oldHighlight selection to avoid name-scan leaks.
        strictMouseover = self:IsStrictUnitPlate(frame, "mouseover")
    end

    local isMouseover = physicalFriendlyMouseover or physicalPetMouseover or physicalNeutralNPCMouseover or strictMouseover
    if not isMouseover and frame.oldHighlight then
        -- Visual fallback only. This may mark hover state, but it does not copy
        -- the mouseover token into the frame unless the physical-friendly guard
        -- above accepted it.
        isMouseover = frame.oldHighlight:IsShown()
    end

    if frame.oldHighlight then
        FP:WipeObject(frame.oldHighlight)
    end
    if frame.oldCastBar then
        FP:WipeObject(frame.oldCastBar)
    end

    if frame.isMouseover ~= isMouseover then
        frame.isMouseover = isMouseover
        if physicalFriendlyMouseover and not frame.isGroupUnit then
            tokenApplied = self:ApplyUnitToken(frame, "mouseover") or tokenApplied
        elseif physicalPetMouseover and not frame.isGroupUnit then
            tokenApplied = self:ApplyUnitToken(frame, "mouseover") or tokenApplied
        elseif physicalNeutralNPCMouseover and not frame.isGroupUnit then
            tokenApplied = self:ApplyUnitToken(frame, "mouseover") or tokenApplied
        elseif strictMouseover and not frame.isGroupUnit then
            tokenApplied = self:ApplyUnitTokenStrict(frame, "mouseover") or tokenApplied
        elseif not frame.isTarget and not frame.isGroupUnit then
            frame.unit = nil
        end
        if tokenApplied then
            if self:RefreshPlateAfterTokenTypeChange(frame, oldType, "mouseover-type-changed") then
                return
            end
            self:RefreshMouseoverResolvedVisuals(frame, "mouseover-token-changed")
            tokenApplied = false
        else
            self:Update_Highlight(frame)
            self:Update_CastBar(frame, nil, frame.unit or frame.castbarUnit)
            if self.Update_Auras then self:Update_Auras(frame, "mouseover-changed") end
        end
    elseif physicalFriendlyMouseover and not frame.isGroupUnit then
        -- Same physical plate remained hovered; refresh only this frame.
        tokenApplied = self:ApplyUnitToken(frame, "mouseover") or tokenApplied
    elseif physicalPetMouseover and not frame.isGroupUnit then
        -- Same physical pet plate remained hovered; refresh only this frame.
        tokenApplied = self:ApplyUnitToken(frame, "mouseover") or tokenApplied
    elseif physicalNeutralNPCMouseover and not frame.isGroupUnit then
        -- Same physical neutral NPC plate remained hovered; refresh only this frame.
        tokenApplied = self:ApplyUnitToken(frame, "mouseover") or tokenApplied
    elseif strictMouseover and not frame.isGroupUnit then
        tokenApplied = self:ApplyUnitTokenStrict(frame, "mouseover") or tokenApplied
    end

    if tokenApplied then
        if not self:RefreshPlateAfterTokenTypeChange(frame, oldType, "mouseover-type-changed") then
            self:RefreshMouseoverResolvedVisuals(frame, "mouseover-token-refresh")
        end
    end
end

function NP:UpdateVisiblePlate(frame)
    if not frame or not frame:IsShown() then return end
    self:BumpPerf("visibleUpdates")

    local parent = frame:GetParent()
    if parent and parent.GetAlpha then
        frame.parentAlpha = parent:GetAlpha()
    else
        frame.parentAlpha = nil
    end

    if hasTarget and parent and parent.SetAlpha then
        parent:SetAlpha(1)
    end

    -- Always-run visual safety: keep the addon feeling responsive.
    self:HideNativePlateParts(frame)
    self:Update_Health(frame)
    self:Update_CastBar(frame, nil, frame.unit or frame.castbarUnit)
    self:Update_Highlight(frame)

    -- Heavy semantic/layout work is fixed-interval per plate, not FPS-bound.
    local now = GetTime()
    if frame._fruitplatesNextHeavyUpdate and now < frame._fruitplatesNextHeavyUpdate then
        self:BumpPerf("lightVisibleSkips")
        return
    end

    if heavyUpdatesThisFrame >= HEAVY_UPDATES_PER_FRAME then
        self:BumpPerf("heavyBudgetSkips")
        local defer = frame.plateID and ((frame.plateID % 7) * 0.002) or 0
        frame._fruitplatesNextHeavyUpdate = now + 0.01 + defer
        return
    end

    heavyUpdatesThisFrame = heavyUpdatesThisFrame + 1
    self:BumpPerf("heavyVisibleUpdates")
    local stagger = frame.plateID and ((frame.plateID % 17) * 0.003) or 0
    frame._fruitplatesNextHeavyUpdate = now + HEAVY_UPDATE_INTERVAL + stagger

    local nameChanged = self:RefreshNativePlateName(frame)
    if nameChanged and self.Clear_Auras then
        self:Clear_Auras(frame)
    end
    local groupBindingChanged = self:RefreshFriendlyGroupBinding(frame)

    -- Arena mapping must run before raw reaction classification. Otherwise one arena
    -- enemy can be guessed as ENEMY_NPC and keep NPC sizing even though icons/castbar know better.
    local arenaPlayerResolved = self:ApplyArenaPlayerUnit(frame)

    -- Target/mouseover resolving is identity work, not light visual safety.
    self:SetMouseoverFrame(frame)
    self:SetTargetFrame(frame)

    local reaction, unitType
    if arenaPlayerResolved then
        unitType = frame.UnitType
        reaction = frame.UnitReaction
    elseif frame.unit and UnitExists(frame.unit) then
        unitType = self:GetUnitTypeFromUnit(frame.unit)
        reaction = UnitReaction("player", frame.unit) or frame.UnitReaction
        if not UnitIsPlayer(frame.unit) and IsNPCUnitType(unitType) then
            unitType, reaction = self:GetNPCTokenTypeAndReactionFromPlate(frame, frame.unit)
            unitType = unitType or self:GetUnitTypeFromUnit(frame.unit) or frame.UnitType
            reaction = reaction or frame.UnitReaction
        end
        local _, class = UnitClass(frame.unit)
        frame.guid = UnitGUID(frame.unit) or frame.guid
        self:CachePetUnit(frame, frame.unit, unitType)
        if UnitIsPlayer(frame.unit) then
            local resolvedClass = class
            local source = class and "token" or nil
            if not resolvedClass then
                resolvedClass = self:GetUnitClassByGUID(frame, frame.guid)
                source = resolvedClass and "guid" or nil
            end
            if resolvedClass then
                self:CacheResolvedClass(frame, resolvedClass, source or "token")
            else
                frame.UnitClass = nil
                frame.UnitClassSource = nil
                frame.UnitClassTrusted = nil
            end
        else
            frame.UnitClass = nil
            frame.UnitClassSource = nil
            frame.UnitClassTrusted = nil
        end
    else
        reaction, unitType = self:GetUnitInfo(frame)
        local cachedPetType = self:GetCachedPetType(frame)
        if cachedPetType then
            unitType = cachedPetType
            if cachedPetType == "FRIENDLY_PET" then
                reaction = 5
            elseif cachedPetType == "ENEMY_PET" then
                reaction = 2
            end
        end
        frame.UnitClass = nil
        frame.UnitClassSource = nil
        frame.UnitClassTrusted = nil

        if unitType == "ENEMY_PLAYER" then
            local class = self:UnitClass(frame, unitType)
            if class then self:CacheResolvedClass(frame, class, frame.guid and "guid" or "native") end
            if not frame.UnitClass then self:TryCachedClass(frame) end
            if not frame.UnitClass then self:TryNativeClassProbe(frame) end
            if not frame.UnitClass then self:QueueNativeClassProbe(frame) end
        elseif unitType == "FRIENDLY_PLAYER" then
            -- Friendly player without a real token/GUID stays unknown.
            -- This prevents recycled PRIEST/DK/etc. icons and wrong class colors.
            local class = self:GetUnitClassByGUID(frame, frame.guid)
            if class then
                self:CacheResolvedClass(frame, class, "guid")
            end
        end
    end

    if frame.UnitType ~= unitType or frame.UnitReaction ~= reaction then
        parent.UnitFrame = frame
        self.OnShow(parent, nil, true)
        return
    end

    if self:EnsureUnitTypeLayout(frame) then
        return
    end

    if nameChanged or groupBindingChanged then
        self:UpdateArenaCastbarUnit(frame)
        if frame.UnitType == "FRIENDLY_PLAYER" and frame.UnitClassTrusted ~= true then
            self:ClearResolvedClass(frame, true)
        end
        self:Update_HealthBar(frame)
        self:Update_Health(frame)
        self:Update_HealthColor(frame)
        self:Configure_Name(frame)
        self:Update_Name(frame)
        self:Configure_Level(frame)
        self:Update_Level(frame)
        self:Update_CastBar(frame, nil, frame.unit or frame.castbarUnit)
        self:Update_RaidIcon(frame)
        self:Update_ClassIcon(frame)
        self:Update_Highlight(frame)
        self:Update_TotemIcon(frame)
        if self.Update_Auras then self:Update_Auras(frame, "name-changed") end
        return
    end

    self:UpdateArenaCastbarUnit(frame)
    if frame.UnitType == "FRIENDLY_PLAYER" and frame.UnitClassTrusted ~= true then
        self:ClearResolvedClass(frame, true)
    end
    self:Update_HealthBar(frame)
    self:Update_Health(frame)
    self:Update_HealthColor(frame)
    self:Update_Name(frame)
    self:Update_Level(frame)
    self:Update_CastBar(frame, nil, frame.unit or frame.castbarUnit)
    self:Update_RaidIcon(frame)
    self:Update_ClassIcon(frame)
    self:Update_Highlight(frame)
    self:Update_TotemIcon(frame)
end

function NP:OnCreated(plate)
    if self.CreatedPlates[plate] then return end

    plateID = plateID + 1

    local Health, CastBar = plate:GetChildren()
    local Threat, Border, CastBarBorder, CastBarShield, CastBarIcon, Highlight, Name, Level, BossIcon, RaidIcon, EliteIcon = plate:GetRegions()

    if not Health or not Name then
        FP:Debug("plate rejected: missing expected children/regions")
        return
    end

    local unitFrame = CreateFrame("Frame", "FruitPlate" .. plateID, plate)
    plate.UnitFrame = unitFrame
    unitFrame:SetAllPoints(plate)
    unitFrame:Hide()
    unitFrame.plateID = plateID

    unitFrame.oldHealthBar = Health
    unitFrame.oldCastBar = CastBar
    if unitFrame.oldCastBar then
        unitFrame.oldCastBar.Icon = CastBarIcon
        unitFrame.oldCastBar.Shield = CastBarShield
    end
    unitFrame.oldName = Name
    unitFrame.oldHighlight = Highlight
    unitFrame.oldLevel = Level
    unitFrame.Threat = Threat
    unitFrame.BossIcon = BossIcon
    unitFrame.EliteIcon = EliteIcon
    unitFrame.RaidIcon = RaidIcon

    unitFrame.Health = self:Construct_HealthBar(unitFrame)

    -- Dedicated text layer: Name/Level must sit above the target highlight/glow.
    unitFrame.TextLayer = CreateFrame("Frame", nil, unitFrame)
    unitFrame.TextLayer:SetAllPoints(unitFrame)
    unitFrame.TextLayer:SetFrameLevel(unitFrame:GetFrameLevel() + 20)

    unitFrame.Name = self:Construct_Name(unitFrame)
    unitFrame.Level = self:Construct_Level(unitFrame)
    unitFrame.TotemIcon = self:Construct_TotemIcon(unitFrame)
    unitFrame.CastBar = self:Construct_CastBar(unitFrame)
    unitFrame.Highlight = self:Construct_Highlight(unitFrame)
    unitFrame.ClassIcon = self:Construct_ClassIcon(unitFrame)
    if self.Construct_Auras then
        unitFrame.Auras = self:Construct_Auras(unitFrame)
    end

    -- Do not wipe QueueObject(Health): native healthbar is kept alive as an invisible class-color sensor.
    self:MakeNativeSensorInvisible(unitFrame)
    self:QueueObject(CastBar)
    self:QueueObject(Level)
    self:QueueObject(Name)
    self:QueueObject(Threat)
    self:QueueObject(Border)
    self:QueueObject(CastBarBorder)
    self:QueueObject(CastBarShield)
    self:QueueObject(CastBarIcon)
    self:QueueObject(Highlight)

    if BossIcon then BossIcon:SetAlpha(0) end
    if EliteIcon then EliteIcon:SetAlpha(0) end

    if RaidIcon then
        RaidIcon:SetParent(unitFrame)
    end

    plate:HookScript("OnShow", self.OnShow)
    plate:HookScript("OnHide", self.OnHide)
    if Health and Health.HookScript then
        Health:HookScript("OnValueChanged", self.Update_HealthOnValueChanged)
    end

    self.CreatedPlates[plate] = true
    self.VisiblePlates[unitFrame] = true

    self.OnShow(plate, true)
    FP:Debug("created plate", plateID, unitFrame.UnitName or "?")
end

function NP:ScanWorldFrame(force)
    -- Immediate cheap claim path:
    -- check child count every frame, but only full-scan when the count changes.
    -- This prevents brief raw Blizzard plate leaks when a plate enters range.
    self:BumpPerf("scanCalls")

    local numChildren = WorldFrame:GetNumChildren()
    if force then lastChildren = 0 end
    if lastChildren == numChildren and not force then return end

    local children = {WorldFrame:GetChildren()}
    self.RejectedWorldChildren = self.RejectedWorldChildren or setmetatable({}, {__mode = "k"})

    -- Full scan when scanning actually runs. Do not assume new WorldFrame children
    -- are appended after lastChildren; old-client child order can be unreliable.
    for i = 1, numChildren do
        local plate = children[i]
        if plate and not self.CreatedPlates[plate] and not self.RejectedWorldChildren[plate] then
            local region = plate:GetRegions()
            if region and region.GetObjectType and region:GetObjectType() == "Texture" and region:GetTexture() == OVERLAY then
                self:OnCreated(plate)
            else
                self.RejectedWorldChildren[plate] = true
            end
        end
    end

    lastChildren = numChildren
end

function NP:RunMouseoverProbe()
    if not self.MouseoverProbeUntil then return end

    if not UnitExists("mouseover") then
        self.MouseoverProbeUntil = nil
        self.MouseoverProbeNext = nil
        return
    end

    local now = GetTime()
    if now > self.MouseoverProbeUntil then
        self.MouseoverProbeUntil = nil
        self.MouseoverProbeNext = nil
        return
    end

    if self.MouseoverProbeNext and now < self.MouseoverProbeNext then return end
    self.MouseoverProbeNext = now + MOUSEOVER_PROBE_INTERVAL

    -- Short post-event physical sweep. This recovers the old responsiveness of
    -- repeated OnUpdate probing without restoring expensive always-on resolver
    -- spam or name-only friendly mouseover promotion.
    self:CacheUnitGUID("mouseover")
    for frame in pairs(self.VisiblePlates or {}) do
        if frame and frame.IsShown and frame:IsShown() then
            self:SetMouseoverFrame(frame)
        end
    end
end

function NP:OnUpdate()
    NP:BumpPerf("onUpdateCalls")
    heavyUpdatesThisFrame = 0

    if NP.db and NP.db.enable == false then
        for frame in pairs(NP.VisiblePlates) do
            if frame then frame:Hide() end
        end
        return
    end

    NP:ScanWorldFrame(false)
    NP:RunNativeClassProbes()
    if NP.ProcessAuraQueue then NP:ProcessAuraQueue() end
    NP:RunMouseoverProbe()

    local visible = 0
    for frame in pairs(NP.VisiblePlates) do
        visible = visible + 1
        NP:UpdateVisiblePlate(frame)
    end
    if NP.Perf and NP.Perf.enabled then
        NP.Perf.visible = visible
        NP:UpdatePerfSnapshot(false)
    end
end

function NP:CacheUnitGUID(unit)
    if UnitExists(unit) and not UnitIsUnit(unit, "player") then
        local name = CleanName(UnitName(unit))
        local guid = UnitGUID(unit)
        local unitType = self:GetUnitTypeFromUnit(unit)
        if name and guid then
            local info = self.GUIDList[guid]
            if not info then
                info = {}
                self.GUIDList[guid] = info
            end
            info.name = name
            info.unitType = unitType
        end
    end
end

function NP:ForceRefreshUnitPlate(unit, reason)
    if not unit or not UnitExists(unit) then return end

    self:CacheUnitGUID(unit)

    local refreshed = 0
    for frame in pairs(self.VisiblePlates or {}) do
        if frame and frame.IsShown and frame:IsShown() and self:IsStrictUnitPlate(frame, unit) then
            local oldType = frame.UnitType
            local applied = self:ApplyUnitTokenStrict(frame, unit)
            if applied then
                local layoutType = self:GetLayoutUnitType(frame) or frame.UnitType
                if oldType ~= frame.UnitType or frame.LayoutUnitType ~= layoutType then
                    frame.LayoutUnitType = nil
                    self:UpdateElement_All(frame)
                    local plate = frame:GetParent()
                    if plate then self:SetSize(plate) end
                else
                    self:Update_HealthBar(frame)
                    self:Update_Health(frame)
                    self:Update_HealthColor(frame)
                    self:Update_Name(frame)
                    self:Update_Level(frame)
                    self:Update_CastBar(frame, nil, frame.unit or frame.castbarUnit)
                    self:Update_RaidIcon(frame)
                    self:Update_ClassIcon(frame)
                    self:Update_Highlight(frame)
                    self:Update_TotemIcon(frame)
                    if self.Update_Auras then self:Update_Auras(frame, reason or "unit-force-refresh") end
                end
                refreshed = refreshed + 1
            end
        end
    end

    return refreshed
end

function NP:RefreshTargetHighlightsNow()
    local targetExists = UnitExists("target") == 1

    for frame in pairs(self.VisiblePlates or {}) do
        if frame and frame.IsShown and frame:IsShown() then
            local wasTarget = frame.isTarget
            local strictTarget = false
            local isTarget = false

            if targetExists then
                strictTarget = self:IsStrictUnitPlate(frame, "target")
                isTarget = strictTarget or self:IsTargetPlate(frame)
            end

            frame.isTarget = isTarget

            if strictTarget and not frame.isGroupUnit then
                self:ApplyUnitTokenStrict(frame, "target")
            elseif self:IsNativeTargetNPCPlate(frame) and not frame.isGroupUnit then
                self:ApplyNativeTargetNPCUnit(frame)
            elseif wasTarget and not frame.isMouseover and not frame.isGroupUnit then
                frame.unit = nil
                frame.guid = self:GetGUIDByName(frame.UnitName, frame.UnitType)
            end

            if wasTarget ~= isTarget then
                self:SetPlateFrameLevel(frame, isTarget)
                self:Update_Highlight(frame)
                self:Update_CastBar(frame, nil, frame.unit or frame.castbarUnit)
            elseif isTarget then
                self:Update_Highlight(frame)
                self:Update_CastBar(frame, nil, frame.unit or frame.castbarUnit)
            end
        end
    end
end

function NP:PLAYER_TARGET_CHANGED()
    hasTarget = UnitExists("target") == 1
    self:RefreshTargetHighlightsNow()
    self:ForceRefreshUnitPlate("target", "target-force-refresh")
end

function NP:UPDATE_MOUSEOVER_UNIT()
    -- Mouseover has to stay physical-frame based. Do not use the normal
    -- force-refresh path here; name scans leak in crowded friendly clusters.
    self:CacheUnitGUID("mouseover")
    self.MouseoverProbeUntil = GetTime() + MOUSEOVER_PROBE_DURATION
    self.MouseoverProbeNext = 0

    for frame in pairs(self.VisiblePlates or {}) do
        if frame and frame.IsShown and frame:IsShown() then
            if self:RefreshNativePlateName(frame) and self.Clear_Auras then
                self:Clear_Auras(frame)
            end
            self:SetMouseoverFrame(frame)
            if self.Update_Auras then self:Update_Auras(frame, "mouseover-event") end
        end
    end
end

function NP:QueueAuraUnit(unit)
    if not unit or not UnitExists(unit) then return end
    self.AuraDirtyUnits = self.AuraDirtyUnits or {}
    self.AuraDirtyOrder = self.AuraDirtyOrder or {}
    if not self.AuraDirtyUnits[unit] then
        self.AuraDirtyUnits[unit] = true
        table.insert(self.AuraDirtyOrder, unit)
    end
end

function NP:ProcessAuraQueue()
    if not self.AuraDirtyOrder then return end
    local processed = 0
    while processed < AURA_UNITS_PER_FRAME and #self.AuraDirtyOrder > 0 do
        local unit = table.remove(self.AuraDirtyOrder, 1)
        self.AuraDirtyUnits[unit] = nil
        if unit and UnitExists(unit) and self.RefreshAurasForUnit then
            self:RefreshAurasForUnit(unit)
        end
        processed = processed + 1
    end
end

function NP:UNIT_AURA(event, unit)
    self:QueueAuraUnit(unit)
end

function NP:CacheArenaUnits()
    ClearTable(self.ENEMY_PLAYER)
    ClearTable(self.ENEMY_NPC)

    for i = 1, 5 do
        local unit = "arena" .. i
        if UnitExists(unit) then self.ENEMY_PLAYER[CleanName(UnitName(unit))] = unit end
        unit = "arenapet" .. i
        if UnitExists(unit) then self.ENEMY_NPC[CleanName(UnitName(unit))] = unit end
    end

    self:RebuildArenaCastbarMap()
end

function NP:CacheGroupUnits()
    ClearTable(self.FRIENDLY_PLAYER)

    if GetNumRaidMembers() > 0 then
        for i = 1, 40 do
            local unit = "raid" .. i
            if UnitExists(unit) then self.FRIENDLY_PLAYER[CleanName(UnitName(unit))] = unit end
        end
    elseif GetNumPartyMembers() > 0 then
        for i = 1, 4 do
            local unit = "party" .. i
            if UnitExists(unit) then self.FRIENDLY_PLAYER[CleanName(UnitName(unit))] = unit end
        end
    end
end

function NP:CacheGroupPetUnits()
    ClearTable(self.FRIENDLY_PET)
    ClearTable(self.ENEMY_PET)

    for i = 1, 5 do
        local unit = "arenapet" .. i
        if UnitExists(unit) then self.ENEMY_PET[CleanName(UnitName(unit))] = unit end
    end

    if GetNumRaidMembers() > 0 then
        for i = 1, 40 do
            local unit = "raidpet" .. i
            if UnitExists(unit) then self.FRIENDLY_PET[CleanName(UnitName(unit))] = unit end
        end
    elseif GetNumPartyMembers() > 0 then
        for i = 1, 4 do
            local unit = "partypet" .. i
            if UnitExists(unit) then self.FRIENDLY_PET[CleanName(UnitName(unit))] = unit end
        end
    end
end

function NP:PLAYER_REGEN_ENABLED()
    for plate in pairs(self.ResizeQueue) do
        self:SetSize(plate)
    end
end

function NP:UpdateCVars()
    FP:SafeSetCVar("ShowClassColorInNameplate", "1")
    FP:SafeSetCVar("ShowClassColorInFriendlyNameplate", "1")
    FP:SafeSetCVar("showVKeyCastbar", "0")
    FP:SafeSetCVar("nameplateAllowOverlap", self.db.motionType == "STACKED" and "0" or "1")
end

function NP:RegisterCoreEvent(event, method)
    FP:RegisterEvent(event, function(...)
        self[method or event](self, ...)
    end)
end

function NP:ApplySettings()
    self.db = FP.db.nameplates
    self:UpdateCVars()

    for frame in pairs(self.VisiblePlates) do
        if frame then
            if self.db.enable == false then
                frame:Hide()
            else
                local plate = frame:GetParent()
                if plate then
                    self.OnShow(plate, true)
                    self:SetSize(plate)
                else
                    self:UpdateElement_All(frame)
                end
            end
        end
    end
end

function NP:Initialize()
    self.db = FP.db.nameplates
    if not self.db.enable then return end
    if self.Initialized then return end
    self.Initialized = true

    hasTarget = UnitExists("target") == 1
    self:UpdateCVars()
    self:CacheArenaUnits()
    self:CacheGroupUnits()
    self:CacheGroupPetUnits()
    -- Totem name map is built on demand. Avoid startup/prewarm work here.

    self.Driver = CreateFrame("Frame", "FruitPlatesDriverFrame")
    self.Driver:SetScript("OnUpdate", self.OnUpdate)

    self:RegisterCoreEvent("PLAYER_TARGET_CHANGED")
    self:RegisterCoreEvent("UPDATE_MOUSEOVER_UNIT")
    self:RegisterCoreEvent("UNIT_AURA")
    self:RegisterCoreEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterCoreEvent("PLAYER_ENTERING_WORLD", "CacheArenaUnits")
    self:RegisterCoreEvent("ARENA_OPPONENT_UPDATE", "CacheArenaUnits")
    self:RegisterCoreEvent("PARTY_MEMBERS_CHANGED", "CacheGroupUnits")
    self:RegisterCoreEvent("RAID_ROSTER_UPDATE", "CacheGroupUnits")
    self:RegisterCoreEvent("UNIT_NAME_UPDATE", "CacheGroupPetUnits")
    self:RegisterCoreEvent("PLAYER_REGEN_ENABLED")

    self:ScanWorldFrame(true)
end
