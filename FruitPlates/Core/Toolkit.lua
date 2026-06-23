local FP = _G.FruitPlates

function FP:FontTemplate(fs, font, size, flags)
    font = font or self.media.font
    size = size or 10
    flags = flags or "OUTLINE"

    local key = font .. "|" .. tostring(size) .. "|" .. tostring(flags)
    if fs._fruitplatesFontKey ~= key then
        fs:SetFont(font, size, flags)
        fs:SetShadowOffset(0, 0)
        fs._fruitplatesFontKey = key
    end
end

function FP:CreateBorder(frame, point)
    point = point or frame
    if point.bordertop then return end

    local border = self.media and self.media.bordercolor or {0, 0, 0, 1}
    local backdrop = self.media and self.media.backdropfadecolor or {0, 0, 0, 0.55}
    local m = self.mult or 1

    point.backdrop = frame:CreateTexture(nil, "BACKGROUND")
    point.backdrop:SetAllPoints(point)
    point.backdrop:SetTexture(unpack(backdrop))

    point.bordertop = frame:CreateTexture(nil, "OVERLAY")
    point.bordertop:SetPoint("TOPLEFT", point, "TOPLEFT", -m, m)
    point.bordertop:SetPoint("TOPRIGHT", point, "TOPRIGHT", m, m)
    point.bordertop:SetHeight(m)
    point.bordertop:SetTexture(unpack(border))

    point.borderbottom = frame:CreateTexture(nil, "OVERLAY")
    point.borderbottom:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", -m, -m)
    point.borderbottom:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", m, -m)
    point.borderbottom:SetHeight(m)
    point.borderbottom:SetTexture(unpack(border))

    point.borderleft = frame:CreateTexture(nil, "OVERLAY")
    point.borderleft:SetPoint("TOPLEFT", point, "TOPLEFT", -m, m)
    point.borderleft:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", -m, -m)
    point.borderleft:SetWidth(m)
    point.borderleft:SetTexture(unpack(border))

    point.borderright = frame:CreateTexture(nil, "OVERLAY")
    point.borderright:SetPoint("TOPRIGHT", point, "TOPRIGHT", m, m)
    point.borderright:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", m, -m)
    point.borderright:SetWidth(m)
    point.borderright:SetTexture(unpack(border))
end

function FP:SetBorderColor(point, r, g, b, a)
    if not point or not point.bordertop then return end
    point.bordertop:SetTexture(r, g, b, a or 1)
    point.borderbottom:SetTexture(r, g, b, a or 1)
    point.borderleft:SetTexture(r, g, b, a or 1)
    point.borderright:SetTexture(r, g, b, a or 1)
end

function FP:GetFormattedText(formatType, current, maximum)
    current = tonumber(current) or 0
    maximum = tonumber(maximum) or 0
    if maximum <= 0 then return "" end

    if formatType == "CURRENT" then
        return tostring(current)
    elseif formatType == "PERCENT" then
        return string.format("%d%%", (current / maximum) * 100)
    else
        return string.format("%d - %d%%", current, (current / maximum) * 100)
    end
end

function FP:SafeSetCVar(cvar, value)
    if SetCVar then pcall(SetCVar, cvar, value) end
end

function FP:WipeObject(object)
    if not object then return end

    -- Keep the original texture/text data on Blizzard regions.
    -- Some 3.3.5a nameplate libs still read those paths to identify plates,
    -- so we only hide native pieces instead of blanking them out.
    local objectType = object.GetObjectType and object:GetObjectType()

    if object.SetAlpha and (not object.GetAlpha or object:GetAlpha() ~= 0) then
        object:SetAlpha(0)
    end

    if objectType == "FontString" and object.SetWidth and (not object.GetWidth or object:GetWidth() > 0.001) then
        object:SetWidth(0.001)
    end

    if object.Hide and (not object.IsShown or object:IsShown()) then
        object:Hide()
    end
end
