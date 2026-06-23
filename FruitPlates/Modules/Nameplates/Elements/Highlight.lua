local FP = _G.FruitPlates
local NP = FP:GetModule("NamePlates")

local CreateFrame = CreateFrame
local math_max = math.max

local function HideGlow(glow)
    if glow then glow:Hide() end
end

local function RegionVisible(region)
    if not region then return false end
    if region.IsShown and not region:IsShown() then return false end
    if region.GetAlpha and region:GetAlpha() <= 0.01 then return false end
    return true
end

local function RegionBounds(region)
    if not RegionVisible(region) or not region.GetLeft then return nil end

    local left, right, top, bottom = region:GetLeft(), region:GetRight(), region:GetTop(), region:GetBottom()
    if not left or not right or not top or not bottom then return nil end
    if right <= left or top <= bottom then return nil end

    return left, right, top, bottom
end

local function IconLooksAttached(health, icon)
    local hl, hr, ht, hb = RegionBounds(health)
    local il, ir, it, ib = RegionBounds(icon)
    if not hl or not il then return false end

    local horizontalGap = 0
    if il > hr then
        horizontalGap = il - hr
    elseif hl > ir then
        horizontalGap = hl - ir
    end

    local verticalGap = 0
    if ib > ht then
        verticalGap = ib - ht
    elseif hb > it then
        verticalGap = hb - it
    end

    local iconWidth = ir - il
    local iconHeight = it - ib
    local allowedGap = math_max(iconWidth or 0, iconHeight or 0, 24)

    return horizontalGap <= allowedGap and verticalGap <= allowedGap
end

local function PickHighlightIcon(frame)
    local healthVisible = frame and RegionVisible(frame.Health)
    local classIcon = frame and frame.ClassIcon

    if classIcon and classIcon._fruitplatesStyle ~= "CIRCLE" and RegionVisible(classIcon) and (not healthVisible or IconLooksAttached(frame.Health, classIcon)) then
        return classIcon
    end

    if frame.RaidIcon and RegionVisible(frame.RaidIcon) and (not healthVisible or IconLooksAttached(frame.Health, frame.RaidIcon)) then
        return frame.RaidIcon
    end
end

local function IsNPCUnitType(unitType)
    return unitType == "ENEMY_NPC" or unitType == "FRIENDLY_NPC"
end

local function HideHighlightFrame(hl)
    HideGlow(hl.HealthGlow)
    HideGlow(hl.IconGlow)
    hl:Hide()
end

local function SetOutside(frame, anchor, x, y)
    if not frame or not anchor then return end

    x = tonumber(x) or 8
    y = tonumber(y) or x

    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", anchor, "TOPLEFT", -x, y)
    frame:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", x, -y)
end

local function ConfigureBackdrop(glow, edgeSize)
    edgeSize = tonumber(edgeSize) or 6
    if edgeSize < 3 then edgeSize = 3 end
    if edgeSize > 14 then edgeSize = 14 end

    local key = tostring(edgeSize)
    if glow._fruitplatesGlowEdgeSize == key then return end

    -- Edge only, no filled center. Gives a real glow without boxing the bar.
    glow:SetBackdrop({
        edgeFile = FP:FetchMedia("border", "GlowBorder"),
        edgeSize = edgeSize,
        insets = {left = 0, right = 0, top = 0, bottom = 0},
    })

    glow._fruitplatesGlowEdgeSize = key
end

local function ShowGlow(glow, anchor, frame, size, alpha, color)
    if not glow or not anchor then return false end

    -- Backdrop edgeSize grows inward from the glow frame edge.
    -- If outside padding is smaller than edgeSize, the glow bleeds into the healthbar/missing-health area.
    -- Keep the outside offset tied to edgeSize so bigger glow grows outward instead of inward.
    local edgeSize = math_max(3, size - 2)
    ConfigureBackdrop(glow, edgeSize)

    local level = frame.Health:GetFrameLevel() or frame:GetFrameLevel() or 1
    glow:SetFrameLevel(math_max(level - 1, 0))
    color = color or {}
    glow:SetBackdropBorderColor(color.r or 1, color.g or 1, color.b or 1, alpha)
    glow:SetAlpha(alpha)

    local outside = edgeSize
    SetOutside(glow, anchor, outside, outside)
    glow:Show()

    return true
end

function NP:Construct_Highlight(parent)
    local hl = CreateFrame("Frame", nil, parent)
    hl:Hide()

    hl.HealthGlow = CreateFrame("Frame", "$parentFruitTargetHealthGlow", parent)
    hl.HealthGlow:SetBackdrop({
        edgeFile = FP:FetchMedia("border", "GlowBorder"),
        edgeSize = 6,
        insets = {left = 0, right = 0, top = 0, bottom = 0},
    })
    hl.HealthGlow:Hide()

    hl.IconGlow = CreateFrame("Frame", "$parentFruitTargetIconGlow", parent)
    hl.IconGlow:SetBackdrop({
        edgeFile = FP:FetchMedia("border", "GlowBorder"),
        edgeSize = 6,
        insets = {left = 0, right = 0, top = 0, bottom = 0},
    })
    hl.IconGlow:Hide()

    return hl
end

function NP:GetHighlightDBForFrame(frame)
    local root = self.db or {}

    if frame and frame.UnitType and root.units and root.units[frame.UnitType] and root.units[frame.UnitType].highlight then
        return root.units[frame.UnitType].highlight
    end

    local db = root.highlight or {}
    return db.target or {}
end

function NP:Update_Highlight(frame)
    local hl = frame.Highlight
    if not hl or not frame.Health then return end

    local targetDB = self:GetHighlightDBForFrame(frame) or {}

    if frame.isTotemPlate or frame.showTotemIcon then
        HideHighlightFrame(hl)
        return
    end

    if targetDB.enable == false or not frame.isTarget then
        HideHighlightFrame(hl)
        return
    end

    -- NPC-only hard render gate: never draw FruitPlates target highlight from
    -- name-only target state. Same-name world NPCs can briefly inherit isTarget
    -- during old-client target churn, so require the NPC path to have promoted
    -- the actual physical native target plate to frame.unit == "target".
    -- Player/arena/group target highlighting is intentionally untouched.
    if IsNPCUnitType(frame.UnitType) then
        local confirmedNPC = frame.unit == "target" and UnitExists("target")
        if confirmedNPC and self.IsNativeTargetNPCPlate then
            confirmedNPC = self:IsNativeTargetNPCPlate(frame)
        end
        if not confirmedNPC then
            HideHighlightFrame(hl)
            return
        end
    end

    local healthShown = frame.Health and frame.Health:IsShown()
    local mode = targetDB.mode or "HEALTHBAR_ICON"
    local size = tonumber(targetDB.padding) or 8
    if size < 2 then size = 2 end
    if size > 14 then size = 14 end

    local alpha = tonumber(targetDB.alpha) or 0.85
    if alpha < 0.05 then alpha = 0.05 end
    if alpha > 1 then alpha = 1 end
    local color = targetDB.color or {}

    local icon = PickHighlightIcon(frame)
    local shown = false

    if mode == "HEALTHBAR" then
        if healthShown then
            shown = ShowGlow(hl.HealthGlow, frame.Health, frame, size, alpha, color)
        else
            HideGlow(hl.HealthGlow)
        end
        HideGlow(hl.IconGlow)

    elseif mode == "ICON" then
        HideGlow(hl.HealthGlow)
        if icon then
            shown = ShowGlow(hl.IconGlow, icon, frame, size, alpha, color)
        else
            HideGlow(hl.IconGlow)
        end

    else
        -- Healthbar + Class Icon:
        -- don't use one big anchor. The icon is taller than the bar and makes
        -- empty glow boxes, so draw two glows instead.
        if healthShown then
            shown = ShowGlow(hl.HealthGlow, frame.Health, frame, size, alpha, color)
        else
            HideGlow(hl.HealthGlow)
        end
        if icon then
            shown = ShowGlow(hl.IconGlow, icon, frame, size, alpha, color) or shown
        else
            HideGlow(hl.IconGlow)
        end
    end

    if shown then
        hl:Show()
    else
        hl:Hide()
    end
end
