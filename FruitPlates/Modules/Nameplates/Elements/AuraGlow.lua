local FP = _G.FruitPlates

local CreateFrame = CreateFrame
local floor = math.floor
local ceil = math.ceil

local glowPath = [[Interface\AddOns\FruitPlates\Media\Glow\IconAlert]]
local antsPath = [[Interface\AddOns\FruitPlates\Media\Glow\IconAlertAnts]]

local glowColors = {
    [1] = {1.00, 0.90, 0.50, 1.00},
    [2] = {0.35, 0.20, 0.75, 0.90},
}

local function SetSize(frame, width, height)
    frame:SetWidth(width)
    frame:SetHeight(height or width)
end

local function Mod(value, divisor)
    return value - floor(value / divisor) * divisor
end

local function AnimateAnts(texture, elapsed)
    texture._fruitplatesThrottle = (texture._fruitplatesThrottle or 0) + elapsed
    if texture._fruitplatesThrottle < 0.03 then return end
    texture._fruitplatesThrottle = 0

    local frame = (texture._fruitplatesFrame or 0) + 1
    if frame > 22 then frame = 1 end
    texture._fruitplatesFrame = frame

    local columnWidth = 48 / 256
    local rowHeight = 48 / 256
    local left = Mod(frame - 1, 5) * columnWidth
    local right = left + columnWidth
    local bottom = ceil(frame / 5) * rowHeight
    local top = bottom - rowHeight
    texture:SetTexCoord(left, right, top, bottom)
end

local function GlowOnUpdate(self, elapsed)
    if self.ants then
        AnimateAnts(self.ants, elapsed)
    end
end

function FP:CreateAuraGlow(icon)
    if not icon or icon.Glow then return icon and icon.Glow end

    local glow = CreateFrame("Frame", nil, icon)
    glow:SetPoint("CENTER", icon, "CENTER", 0, 0)
    glow:SetFrameLevel((icon.GetFrameLevel and icon:GetFrameLevel() or 1) + 1)

    glow.spark = glow:CreateTexture(nil, "BACKGROUND")
    glow.spark:SetTexture(glowPath)
    glow.spark:SetAllPoints(glow)
    glow.spark:SetTexCoord(0.00781250, 0.61718750, 0.00390625, 0.26953125)

    glow.innerGlow = glow:CreateTexture(nil, "ARTWORK")
    glow.innerGlow:SetTexture(glowPath)
    glow.innerGlow:SetAllPoints(glow)
    glow.innerGlow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)

    glow.innerGlowOver = glow:CreateTexture(nil, "ARTWORK")
    glow.innerGlowOver:SetTexture(glowPath)
    glow.innerGlowOver:SetAllPoints(glow)
    glow.innerGlowOver:SetTexCoord(0.00781250, 0.50781250, 0.53515625, 0.78515625)

    glow.outerGlow = glow:CreateTexture(nil, "ARTWORK")
    glow.outerGlow:SetTexture(glowPath)
    glow.outerGlow:SetAllPoints(glow)
    glow.outerGlow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)

    glow.outerGlowOver = glow:CreateTexture(nil, "ARTWORK")
    glow.outerGlowOver:SetTexture(glowPath)
    glow.outerGlowOver:SetAllPoints(glow)
    glow.outerGlowOver:SetTexCoord(0.00781250, 0.50781250, 0.53515625, 0.78515625)

    glow.ants = glow:CreateTexture(nil, "OVERLAY")
    glow.ants:SetTexture(antsPath)
    glow.ants:SetAllPoints(glow)

    -- Vendored Cheese-style glow, no dependency. If a recycled icon hides, the
    -- animation must die with it.
    glow:SetScript("OnHide", function(self)
        self:SetScript("OnUpdate", nil)
    end)
    glow:SetScript("OnUpdate", nil)
    glow:Hide()
    icon.Glow = glow
    return glow
end

function FP:ShowAuraGlow(icon, highlight)
    if not icon then return end
    local glow = self:CreateAuraGlow(icon)
    if not glow then return end

    local width = icon:GetWidth() or 30
    local height = icon:GetHeight() or width
    local db = self.db and self.db.nameplates and self.db.nameplates.auras
    local priority = db and db.priority or {}
    local scale = tonumber(priority.glowScale) or 1.0
    if scale < 0.25 then scale = 0.25 end
    if scale > 3.0 then scale = 3.0 end

    local thickness = tonumber(priority.glowThickness) or 0.60
    if thickness < 0.10 then thickness = 0.10 end
    if thickness > 1.25 then thickness = 1.25 end

    -- Size controls overall spread. Intensity controls how dominant the heavy
    -- Cheese outer/ants layers feel, without changing the icon itself.
    SetSize(glow, width * 1.8 * scale, height * 1.8 * scale)

    local color = glowColors[highlight] or glowColors[1]
    glow.spark:SetVertexColor(color[1], color[2], color[3], color[4])
    glow.innerGlow:SetVertexColor(color[1], color[2], color[3], color[4])
    glow.innerGlowOver:SetVertexColor(color[1], color[2], color[3], color[4])
    glow.outerGlow:SetVertexColor(color[1], color[2], color[3], color[4])
    glow.outerGlowOver:SetVertexColor(color[1], color[2], color[3], color[4])
    glow.ants:SetVertexColor(color[1], color[2], color[3], color[4])

    glow.spark:SetAlpha(0.18 + 0.07 * thickness)
    glow.innerGlow:SetAlpha(0.30 + 0.25 * thickness)
    glow.innerGlowOver:SetAlpha(0.18 + 0.17 * thickness)
    glow.outerGlow:SetAlpha(0.25 + 0.60 * thickness)
    glow.outerGlowOver:SetAlpha(0.15 + 0.40 * thickness)
    glow.ants:SetAlpha(0.20 + 0.75 * thickness)
    glow:SetScript("OnUpdate", GlowOnUpdate)
    glow:Show()
end

function FP:HideAuraGlow(icon)
    local glow = icon and icon.Glow
    if not glow then return end
    glow:SetScript("OnUpdate", nil)
    glow:Hide()
end
