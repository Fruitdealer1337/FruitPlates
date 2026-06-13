local FP = _G.FruitPlates
local NP = FP:GetModule("NamePlates")

function NP:Update_Level(frame)
    local unitDB = self:GetLayoutUnitDB(frame)
    local db = unitDB and unitDB.level
    if not db or not db.enable then
        frame.Level:Hide()
        return
    end

    local levelText, r, g, b = self:UnitLevel(frame)
    local level = frame.Level
    if level.SetDrawLayer and not level._fruitplatesDrawLayerSet then
        level:SetDrawLayer("OVERLAY", 7)
        level._fruitplatesDrawLayerSet = true
    end
    if not level:IsShown() then level:Show() end

    if frame.Health:IsShown() then
        local parent = db.parent == "Nameplate" and frame or frame[db.parent]
        local anchor = db.anchor or "RIGHT"
        local point, justify

        if anchor == "LEFT" then
            point, justify = "BOTTOMLEFT", "LEFT"
        elseif anchor == "MIDDLE" or anchor == "CENTER" then
            point, justify = "BOTTOM", "CENTER"
        else
            point, justify = "BOTTOMRIGHT", "RIGHT"
        end

        -- Development baseline: config Y = 0 means the natural text position above the plate.
        -- Positive Y moves up, negative Y moves down.
        local y = (db.yOffset or 0) + 2

        level:SetJustifyH(justify)
        local relPoint = "TOP" .. (point == "BOTTOMLEFT" and "LEFT" or point == "BOTTOMRIGHT" and "RIGHT" or "")
        local x = db.xOffset or 0
        if level._fruitplatesLayoutPoint ~= point
            or level._fruitplatesLayoutParent ~= (parent or frame)
            or level._fruitplatesLayoutRelPoint ~= relPoint
            or level._fruitplatesLayoutX ~= x
            or level._fruitplatesLayoutY ~= y then
            level:ClearAllPoints()
            level:SetPoint(point, parent or frame, relPoint, x, y)
            level._fruitplatesLayoutPoint = point
            level._fruitplatesLayoutParent = parent or frame
            level._fruitplatesLayoutRelPoint = relPoint
            level._fruitplatesLayoutX = x
            level._fruitplatesLayoutY = y
        end
        if level._fruitplatesText ~= levelText then
            level:SetText(levelText)
            level._fruitplatesText = levelText
        end
    else
        level:SetJustifyH("LEFT")
        if level._fruitplatesLayoutPoint ~= "LEFT"
            or level._fruitplatesLayoutParent ~= frame.Name
            or level._fruitplatesLayoutRelPoint ~= "RIGHT"
            or level._fruitplatesLayoutX ~= 0
            or level._fruitplatesLayoutY ~= 0 then
            level:ClearAllPoints()
            level:SetPoint("LEFT", frame.Name, "RIGHT", 0, 0)
            level._fruitplatesLayoutPoint = "LEFT"
            level._fruitplatesLayoutParent = frame.Name
            level._fruitplatesLayoutRelPoint = "RIGHT"
            level._fruitplatesLayoutX = 0
            level._fruitplatesLayoutY = 0
        end
        local text = " [" .. tostring(levelText) .. "]"
        if level._fruitplatesText ~= text then
            level:SetText(text)
            level._fruitplatesText = text
        end
    end

    local color = db.manualColor
    if color then
        r, g, b = color.r or 1, color.g or 1, color.b or 1
    else
        r, g, b = r or 1, g or 1, b or 1
    end
    if level._fruitplatesR ~= r or level._fruitplatesG ~= g or level._fruitplatesB ~= b then
        level:SetTextColor(r, g, b)
        level._fruitplatesR, level._fruitplatesG, level._fruitplatesB = r, g, b
    end
end

function NP:Configure_Level(frame)
    local unitDB = self:GetLayoutUnitDB(frame)
    local db = unitDB and unitDB.level
    if not db then return end
    FP:FontTemplate(frame.Level, FP:FetchMedia("font", db.font), db.fontSize, db.fontOutline)
end

function NP:Construct_Level(frame)
    local parent = frame.TextLayer or frame
    local level = parent:CreateFontString(nil, "OVERLAY")
    level:SetWordWrap(false)
    return level
end
