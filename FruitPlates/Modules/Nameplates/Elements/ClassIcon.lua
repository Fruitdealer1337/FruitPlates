local FP = _G.FruitPlates
local NP = FP:GetModule("NamePlates")

local CLASS_ICON_TEXTURES = {
    WARRIOR = [[Interface\AddOns\FruitPlates\Media\Textures\ClassIcons\WARRIOR.tga]],
    PALADIN = [[Interface\AddOns\FruitPlates\Media\Textures\ClassIcons\PALADIN.tga]],
    HUNTER = [[Interface\AddOns\FruitPlates\Media\Textures\ClassIcons\HUNTER.tga]],
    ROGUE = [[Interface\AddOns\FruitPlates\Media\Textures\ClassIcons\ROGUE.tga]],
    PRIEST = [[Interface\AddOns\FruitPlates\Media\Textures\ClassIcons\PRIEST.tga]],
    DEATHKNIGHT = [[Interface\AddOns\FruitPlates\Media\Textures\ClassIcons\DEATHKNIGHT.tga]],
    SHAMAN = [[Interface\AddOns\FruitPlates\Media\Textures\ClassIcons\SHAMAN.tga]],
    MAGE = [[Interface\AddOns\FruitPlates\Media\Textures\ClassIcons\MAGE.tga]],
    WARLOCK = [[Interface\AddOns\FruitPlates\Media\Textures\ClassIcons\WARLOCK.tga]],
    DRUID = [[Interface\AddOns\FruitPlates\Media\Textures\ClassIcons\DRUID.tga]],
}

local function PlateIconFamily(unitType)
    if unitType == "ENEMY_PLAYER" then return "enemy" end
    if unitType == "FRIENDLY_PLAYER" then return "friendly" end
    if unitType == "ENEMY_PET" or unitType == "FRIENDLY_PET" then return "pet" end
    return "npc"
end

local function ClassIconAllowed(frame)
    if not frame or not frame.UnitClass then return false end
    if frame.UnitType ~= "ENEMY_PLAYER" and frame.UnitType ~= "FRIENDLY_PLAYER" then return false end
    if frame.UnitType == "FRIENDLY_PLAYER" and not NP:IsFriendlyClassStylingAllowed(frame) then return false end
    if frame.unit and UnitExists(frame.unit) and not UnitIsPlayer(frame.unit) then return false end

    local db = NP.db and NP.db.icons
    if not db or db.enable == false then return false end
    if db.mode ~= "CLASS" and db.mode ~= "BOTH" then return false end

    local classDB = db.classIcons or {}
    if classDB.enable == false then return false end

    local family = PlateIconFamily(frame.UnitType)
    if classDB[family] == false then return false end

    return true
end

function NP:HideClassIconOutline(icon)
    if not icon then return end
    if icon.OutlineTop then icon.OutlineTop:Hide() end
    if icon.OutlineBottom then icon.OutlineBottom:Hide() end
    if icon.OutlineLeft then icon.OutlineLeft:Hide() end
    if icon.OutlineRight then icon.OutlineRight:Hide() end
    icon._fruitplatesOutlineEnabled = nil
end

local function HideClassIconOutline(icon)
    NP:HideClassIconOutline(icon)
end

function NP:ClearClassIcon(frame)
    local icon = frame and frame.ClassIcon
    if not icon then return end

    HideClassIconOutline(icon)
    icon._fruitplatesClass = nil
    icon._fruitplatesTexture = nil
    icon._fruitplatesLeft = nil
    icon._fruitplatesRight = nil
    icon._fruitplatesTop = nil
    icon._fruitplatesBottom = nil
    if icon.Texture then
        icon.Texture:SetTexture(nil)
    end
    if icon:IsShown() then
        icon:Hide()
    end
end

local function GetClassIconOutline(classDB, family)
    if not classDB then return {} end

    classDB.outline = classDB.outline or {}
    classDB.outline.color = classDB.outline.color or {r = 0, g = 0, b = 0}

    local outlines = classDB.outlines
    local outline = outlines and family and outlines[family] or nil
    if not outline then
        return classDB.outline
    end

    outline.color = outline.color or {}
    if outline.color.r == nil then outline.color.r = (classDB.outline.color and classDB.outline.color.r) or 0 end
    if outline.color.g == nil then outline.color.g = (classDB.outline.color and classDB.outline.color.g) or 0 end
    if outline.color.b == nil then outline.color.b = (classDB.outline.color and classDB.outline.color.b) or 0 end
    if outline.thickness == nil then outline.thickness = classDB.outline.thickness or 1 end
    if outline.growth == nil then outline.growth = classDB.outline.growth or "IN" end
    if outline.enable == nil then outline.enable = classDB.outline.enable == true end

    return outline
end


local function ApplyClassIconOutline(icon, classDB, family)
    if not icon then return end
    local outline = GetClassIconOutline(classDB, family)
    if outline.enable ~= true then
        HideClassIconOutline(icon)
        return
    end

    local t = tonumber(outline.thickness) or 1
    if t < 0.25 then t = 0.25 end
    if t > 8 then t = 8 end

    local c = outline.color or {r = 0, g = 0, b = 0}
    local r, g, b = c.r or 0, c.g or 0, c.b or 0

    if icon.OutlineTop.SetDrawLayer then icon.OutlineTop:SetDrawLayer("OVERLAY", 7) end
    if icon.OutlineBottom.SetDrawLayer then icon.OutlineBottom:SetDrawLayer("OVERLAY", 7) end
    if icon.OutlineLeft.SetDrawLayer then icon.OutlineLeft:SetDrawLayer("OVERLAY", 7) end
    if icon.OutlineRight.SetDrawLayer then icon.OutlineRight:SetDrawLayer("OVERLAY", 7) end

    local growth = outline.growth or "IN"
    local outward = growth == "OUT"
    if icon._fruitplatesOutlineEnabled
        and icon._fruitplatesOutlineT == t
        and icon._fruitplatesOutlineR == r
        and icon._fruitplatesOutlineG == g
        and icon._fruitplatesOutlineB == b
        and icon._fruitplatesOutlineGrowth == growth then
        return
    end
    icon._fruitplatesOutlineEnabled = true
    icon._fruitplatesOutlineT = t
    icon._fruitplatesOutlineR = r
    icon._fruitplatesOutlineG = g
    icon._fruitplatesOutlineB = b
    icon._fruitplatesOutlineGrowth = growth

    local x1, y1, x2, y2 = 0, 0, 0, 0
    if outward then
        x1, y1, x2, y2 = -t, t, t, -t
    end

    icon.OutlineTop:ClearAllPoints()
    icon.OutlineTop:SetPoint("TOPLEFT", icon, "TOPLEFT", x1, y1)
    icon.OutlineTop:SetPoint("TOPRIGHT", icon, "TOPRIGHT", x2, y1)
    icon.OutlineTop:SetHeight(t)
    icon.OutlineTop:SetTexture(r, g, b, 1)
    icon.OutlineTop:Show()

    icon.OutlineBottom:ClearAllPoints()
    icon.OutlineBottom:SetPoint("BOTTOMLEFT", icon, "BOTTOMLEFT", x1, y2)
    icon.OutlineBottom:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", x2, y2)
    icon.OutlineBottom:SetHeight(t)
    icon.OutlineBottom:SetTexture(r, g, b, 1)
    icon.OutlineBottom:Show()

    icon.OutlineLeft:ClearAllPoints()
    icon.OutlineLeft:SetPoint("TOPLEFT", icon, "TOPLEFT", x1, y1)
    icon.OutlineLeft:SetPoint("BOTTOMLEFT", icon, "BOTTOMLEFT", x1, y2)
    icon.OutlineLeft:SetWidth(t)
    icon.OutlineLeft:SetTexture(r, g, b, 1)
    icon.OutlineLeft:Show()

    icon.OutlineRight:ClearAllPoints()
    icon.OutlineRight:SetPoint("TOPRIGHT", icon, "TOPRIGHT", x2, y1)
    icon.OutlineRight:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", x2, y2)
    icon.OutlineRight:SetWidth(t)
    icon.OutlineRight:SetTexture(r, g, b, 1)
    icon.OutlineRight:Show()
end

function NP:Configure_ClassIcon(frame)
    if not frame or not frame.ClassIcon then return end

    local db = self.db.icons or {}
    local classDB = db.classIcons or {}
    local size = classDB.size or db.size or 18
    local x = classDB.xOffset
    local y = classDB.yOffset
    local family = PlateIconFamily(frame.UnitType)

    if family == "enemy" then
        if classDB.enemyXOffset ~= nil then x = classDB.enemyXOffset end
        if classDB.enemyYOffset ~= nil then y = classDB.enemyYOffset end
    elseif family == "friendly" then
        if classDB.friendlyXOffset ~= nil then x = classDB.friendlyXOffset end
        if classDB.friendlyYOffset ~= nil then y = classDB.friendlyYOffset end
    elseif family == "pet" then
        if classDB.petXOffset ~= nil then x = classDB.petXOffset end
        if classDB.petYOffset ~= nil then y = classDB.petYOffset end
    end

    if x == nil then x = db.xOffset or 0 end
    if y == nil then y = db.yOffset or 10 end

    local icon = frame.ClassIcon
    local parent = frame.Health or frame
    local baseLevel = (frame.Health and frame.Health:GetFrameLevel()) or frame:GetFrameLevel() or 1
    if icon._fruitplatesLayoutFamily ~= family
        or icon._fruitplatesLayoutParent ~= parent
        or icon._fruitplatesLayoutSize ~= size
        or icon._fruitplatesLayoutX ~= x
        or icon._fruitplatesLayoutY ~= y
        or icon._fruitplatesLayoutLevel ~= baseLevel + 80 then
        icon:ClearAllPoints()
        icon:SetParent(frame)

        -- ClassIcon is our own Frame, so frame level is safe here.
        -- Keep it visually above the target glow.
        if icon.SetFrameLevel then
            icon:SetFrameLevel(baseLevel + 80)
        end

        icon:SetWidth(size)
        icon:SetHeight(size)

        -- Class icon position should be stable regardless of Icon Mode.
        -- BOTH mode must not add hidden offsets or change anchor behavior.
        icon:SetPoint("BOTTOM", parent, "TOP", x, y)

        icon._fruitplatesLayoutFamily = family
        icon._fruitplatesLayoutParent = parent
        icon._fruitplatesLayoutSize = size
        icon._fruitplatesLayoutX = x
        icon._fruitplatesLayoutY = y
        icon._fruitplatesLayoutLevel = baseLevel + 80
    end

    ApplyClassIconOutline(icon, classDB, family)
end

function NP:Update_ClassIcon(frame)
    if not frame or not frame.ClassIcon then return end

    self:Configure_ClassIcon(frame)

    if not ClassIconAllowed(frame) then
        self:ClearClassIcon(frame)
        return
    end

    local texture = CLASS_ICON_TEXTURES[frame.UnitClass]
    if not texture then
        self:ClearClassIcon(frame)
        return
    end

    local db = self.db.icons or {}
    local classDB = db.classIcons or {}
    local zoom = tonumber(classDB.zoom) or 0
    if zoom < 0 then zoom = 0 end
    if zoom > 20 then zoom = 20 end

    local left, right, top, bottom = 0, 1, 0, 1
    if zoom > 0 then
        local zx = (right - left) * (zoom / 100)
        local zy = (bottom - top) * (zoom / 100)
        left = left + zx
        right = right - zx
        top = top + zy
        bottom = bottom - zy
    end

    local icon = frame.ClassIcon
    if icon._fruitplatesTexture ~= texture then
        icon.Texture:SetTexture(texture)
        icon._fruitplatesTexture = texture
    end
    if icon._fruitplatesClass ~= frame.UnitClass
        or icon._fruitplatesLeft ~= left
        or icon._fruitplatesRight ~= right
        or icon._fruitplatesTop ~= top
        or icon._fruitplatesBottom ~= bottom then
        icon.Texture:SetTexCoord(left, right, top, bottom)
        icon._fruitplatesClass = frame.UnitClass
        icon._fruitplatesLeft = left
        icon._fruitplatesRight = right
        icon._fruitplatesTop = top
        icon._fruitplatesBottom = bottom
    end
    if not icon:IsShown() then icon:Show() end
end

function NP:Construct_ClassIcon(parent)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetFrameLevel(parent:GetFrameLevel() + 80)
    frame:SetWidth(18)
    frame:SetHeight(18)

    frame.Texture = frame:CreateTexture(nil, "ARTWORK")
    frame.Texture:SetAllPoints(frame)

    FP:CreateBorder(frame)

    frame.OutlineTop = frame:CreateTexture(nil, "OVERLAY")
    frame.OutlineBottom = frame:CreateTexture(nil, "OVERLAY")
    frame.OutlineLeft = frame:CreateTexture(nil, "OVERLAY")
    frame.OutlineRight = frame:CreateTexture(nil, "OVERLAY")
    frame.OutlineTop:Hide()
    frame.OutlineBottom:Hide()
    frame.OutlineLeft:Hide()
    frame.OutlineRight:Hide()

    frame:Hide()

    return frame
end
