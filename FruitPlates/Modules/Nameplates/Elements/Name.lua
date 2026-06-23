local FP = _G.FruitPlates
local NP = FP:GetModule("NamePlates")

local function abbrev(name)
    return name
end

local function IsNPCOrPetType(unitType)
    return unitType == "ENEMY_NPC"
        or unitType == "FRIENDLY_NPC"
        or unitType == "ENEMY_PET"
        or unitType == "FRIENDLY_PET"
end

local function IsPlayerType(unitType)
    return unitType == "ENEMY_PLAYER"
        or unitType == "FRIENDLY_PLAYER"
end

local function GetNameCropDB(frame, layoutNameDB)
    if frame and IsNPCOrPetType(frame.UnitType) and NP.db and NP.db.units and NP.db.units[frame.UnitType] then
        return NP.db.units[frame.UnitType].name or layoutNameDB
    end
    return layoutNameDB
end

local function GetNameWidthCap(frame, nameDB)
    if frame and IsPlayerType(frame.UnitType) then
        return 1000
    end

    if frame and IsNPCOrPetType(frame.UnitType) then
        if not nameDB or nameDB.cropLongNames ~= true then
            return 1000
        end
    elseif nameDB and nameDB.cropLongNames == false then
        return 1000
    end

    if not frame then return 90 end

    local healthWidth
    if frame.Health and frame.Health.GetWidth then
        healthWidth = frame.Health:GetWidth()
    end

    if (not healthWidth or healthWidth <= 0) and frame.UnitType and NP.db then
        local unitDB = NP.GetLayoutUnitDB and NP:GetLayoutUnitDB(frame) or (NP.db.units and NP.db.units[frame.UnitType])
        local healthDB = unitDB and unitDB.health
        healthWidth = healthDB and healthDB.width
    end

    healthWidth = tonumber(healthWidth) or 120
    return math.max(20, healthWidth * 0.75)
end

local function GetArenaNumberFromUnit(unit)
    if not unit then return nil end

    local direct = string.match(unit, "^arena(%d)$")
    if direct then return direct end

    if UnitExists(unit) then
        for i = 1, 5 do
            local arenaUnit = "arena" .. i
            if UnitExists(arenaUnit) and UnitIsUnit(unit, arenaUnit) then
                return tostring(i)
            end
        end
    end

    return nil
end

function NP:Update_Name(frame)
    local unitDB = self:GetLayoutUnitDB(frame)
    local db = unitDB and unitDB.name
    if not db then
        frame.Name:Hide()
        return
    end

    local arenaNumber
    if db.arenaNumber then
        arenaNumber = GetArenaNumberFromUnit(frame.unit) or GetArenaNumberFromUnit(frame.castbarUnit)
    end

    -- Arena Number Name intentionally overrides Hide Name, but only when the
    -- visible plate is actually mapped to arena1-5. Normal names remain hidden.
    if not db.enable and not arenaNumber then
        frame.Name:Hide()
        return
    end

    local name = frame.Name
    local cropDB = GetNameCropDB(frame, db)
    local widthCap = GetNameWidthCap(frame, cropDB)
    if name._fruitplatesWidthCap ~= widthCap then
        name:SetWidth(widthCap)
        name._fruitplatesWidthCap = widthCap
    end

    local text = frame.UnitName or UNKNOWN
    if arenaNumber then
        text = arenaNumber
    elseif db.abbrev then
        text = abbrev(text)
    end
    if name._fruitplatesText ~= text then
        name:SetText(text)
        name._fruitplatesText = text
    end
    if name.SetDrawLayer and not name._fruitplatesDrawLayerSet then
        name:SetDrawLayer("OVERLAY", 7)
        name._fruitplatesDrawLayerSet = true
    end
    if not name:IsShown() then name:Show() end

    local parent = db.parent == "Nameplate" and frame or frame[db.parent]
    local anchor = db.anchor or "LEFT"
    local point, justify

    if anchor == "RIGHT" then
        point, justify = "BOTTOMRIGHT", "RIGHT"
    elseif anchor == "MIDDLE" or anchor == "CENTER" then
        point, justify = "BOTTOM", "CENTER"
    else
        point, justify = "BOTTOMLEFT", "LEFT"
    end

    -- Development baseline: config Y = 0 means the natural text position above the plate.
    -- Positive Y moves up, negative Y moves down.
    local y = (db.yOffset or 0) + 2

    name:SetJustifyH(justify)
    local relPoint = "TOP" .. (point == "BOTTOMLEFT" and "LEFT" or point == "BOTTOMRIGHT" and "RIGHT" or "")
    local x = db.xOffset or 0
    if name._fruitplatesLayoutPoint ~= point
        or name._fruitplatesLayoutParent ~= (parent or frame)
        or name._fruitplatesLayoutRelPoint ~= relPoint
        or name._fruitplatesLayoutX ~= x
        or name._fruitplatesLayoutY ~= y then
        name:ClearAllPoints()
        name:SetPoint(point, parent or frame, relPoint, x, y)
        name._fruitplatesLayoutPoint = point
        name._fruitplatesLayoutParent = parent or frame
        name._fruitplatesLayoutRelPoint = relPoint
        name._fruitplatesLayoutX = x
        name._fruitplatesLayoutY = y
    end

    local r, g, b = 1, 1, 1
    local classColor = frame.UnitClass and ((CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[frame.UnitClass]) or RAID_CLASS_COLORS[frame.UnitClass])
    local classColorAllowed = false
    if classColor and db.useClassColor then
        if frame.UnitType == "ENEMY_PLAYER" then
            classColorAllowed = true
        elseif frame.UnitType == "FRIENDLY_PLAYER" then
            classColorAllowed = self:IsFriendlyClassStylingAllowed(frame)
        end
    end

    if db.inheritPlateColor == false then
        local c = db.manualColor
        if c then
            r, g, b = c.r or 1, c.g or 1, c.b or 1
        end
    elseif classColorAllowed then
        r, g, b = classColor.r, classColor.g, classColor.b
    else
        local colors = self.db.colors.reactions
        local pc = self.db.plateColors or {}

        if frame.UnitType == "ENEMY_PLAYER" then
            local c = pc.enemyPlayer or colors.bad
            r, g, b = c.r, c.g, c.b
        elseif frame.UnitType == "FRIENDLY_PLAYER" then
            local c = pc.friendlyPlayer or colors.friendlyPlayer
            r, g, b = c.r, c.g, c.b
        elseif frame.UnitReaction == 4 then
            local c = pc.neutralNPC or colors.neutral
            r, g, b = c.r, c.g, c.b
        elseif frame.UnitReaction and frame.UnitReaction > 4 then
            local c = pc.friendlyNPC or colors.good
            r, g, b = c.r, c.g, c.b
        else
            local c = pc.enemyNPC or colors.bad
            r, g, b = c.r, c.g, c.b
        end
    end

    r, g, b = r or 1, g or 1, b or 1
    if name._fruitplatesR ~= r or name._fruitplatesG ~= g or name._fruitplatesB ~= b then
        name:SetTextColor(r, g, b)
        name._fruitplatesR, name._fruitplatesG, name._fruitplatesB = r, g, b
    end
end

function NP:Configure_Name(frame)
    local unitDB = self:GetLayoutUnitDB(frame)
    local db = unitDB and unitDB.name
    if not db then return end
    FP:FontTemplate(frame.Name, FP:FetchMedia("font", db.font), db.fontSize, db.fontOutline)
end

function NP:Construct_Name(frame)
    local parent = frame.TextLayer or frame
    local name = parent:CreateFontString(nil, "OVERLAY")
    name:SetJustifyV("BOTTOM")
    name:SetWordWrap(false)
    return name
end
