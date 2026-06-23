local FP = _G.FruitPlates
local NP = FP:RegisterModule("NamePlates", FP:GetModule("NamePlates") or {})

local HideHealthOutline
local ApplyHealthOutline

local function GetLayoutUnitType(frame)
    if not frame then return nil end
    local unitType = frame.UnitType

    -- NPC-only visual inheritance. Identity remains frame.UnitType; this helper
    -- only chooses which DB bucket supplies size/text/castbar layout.
    if unitType == "ENEMY_NPC" then
        if frame.UnitReaction == 4 then
            if frame.NeutralNPCLayoutAttackable == true then
                return "ENEMY_PLAYER"
            end
            return "FRIENDLY_NPC"
        elseif frame.UnitReaction and frame.UnitReaction < 4 then
            return "ENEMY_PLAYER"
        end
    elseif unitType == "FRIENDLY_NPC" then
        return "FRIENDLY_NPC"
    end

    return unitType
end

function NP:GetLayoutUnitType(frame)
    return GetLayoutUnitType(frame)
end

function NP:GetLayoutUnitDB(frame)
    local layoutType = GetLayoutUnitType(frame)
    return layoutType and self.db and self.db.units and self.db.units[layoutType] or nil, layoutType
end

function NP:Update_HealthOnValueChanged()
    local parent = self:GetParent()
    local frame = parent and parent.UnitFrame
    if frame and frame.UnitType then
        NP:Update_Health(frame)
        NP:Update_HealthColor(frame)
    end
end

function NP:Update_HealthColor(frame)
    if not frame.Health or not frame.Health:IsShown() then return end

    local r, g, b
    local db = self.db.colors
    local unitDB = self.db.units[frame.UnitType]
    local class = frame.UnitClass
    local classColor = class and ((CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class]) or RAID_CLASS_COLORS[class])

    local classColorAllowed = false
    if classColor and unitDB.health.useClassColor then
        if frame.UnitType == "ENEMY_PLAYER" then
            classColorAllowed = true
        elseif frame.UnitType == "FRIENDLY_PLAYER" then
            classColorAllowed = self:IsFriendlyClassStylingAllowed(frame)
        end
    end

    if classColorAllowed then
        r, g, b = classColor.r, classColor.g, classColor.b
    else
        local pc = self.db.plateColors or {}

        if frame.UnitType == "ENEMY_PLAYER" then
            local c = pc.enemyPlayer or db.reactions.bad
            r, g, b = c.r, c.g, c.b
        elseif frame.UnitType == "FRIENDLY_PLAYER" then
            local c = pc.friendlyPlayer or db.reactions.friendlyPlayer
            r, g, b = c.r, c.g, c.b
        elseif frame.UnitType == "ENEMY_PET" then
            local c = pc.enemyPet or pc.enemyNPC or db.reactions.bad
            r, g, b = c.r, c.g, c.b
        elseif frame.UnitType == "FRIENDLY_PET" then
            local c = pc.friendlyPet or pc.friendlyNPC or db.reactions.good
            r, g, b = c.r, c.g, c.b
        elseif frame.UnitReaction == 4 then
            local c = pc.neutralNPC or db.reactions.neutral
            r, g, b = c.r, c.g, c.b
        elseif frame.UnitReaction and frame.UnitReaction > 4 then
            local c = pc.friendlyNPC or db.reactions.good
            r, g, b = c.r, c.g, c.b
        else
            local c = pc.enemyNPC or db.reactions.bad
            r, g, b = c.r, c.g, c.b
        end
    end

    r, g, b = r or 1, g or 1, b or 1
    if frame.Health.r ~= r or frame.Health.g ~= g or frame.Health.b ~= b then
        frame.Health:SetStatusBarColor(r, g, b)
        frame.Health.r, frame.Health.g, frame.Health.b = r, g, b
    end
end

function NP:Update_Health(frame)
    if not frame.oldHealthBar or not frame.Health then return end

    local health = frame.oldHealthBar:GetValue() or 0
    local _, maxHealth = frame.oldHealthBar:GetMinMaxValues()
    maxHealth = maxHealth or 1

    if frame.Health._fruitplatesMaxHealth ~= maxHealth then
        frame.Health:SetMinMaxValues(0, maxHealth)
        frame.Health._fruitplatesMaxHealth = maxHealth
    end
    if frame.Health._fruitplatesHealthValue ~= health then
        frame.Health:SetValue(health)
        frame.Health._fruitplatesHealthValue = health
    end

    local layoutDB = self:GetLayoutUnitDB(frame)
    local textDB = layoutDB and layoutDB.health and layoutDB.health.text
    if textDB and textDB.enable then
        local text = FP:GetFormattedText(textDB.format, health, maxHealth)
        if frame.Health.Text._fruitplatesText ~= text then
            frame.Health.Text:SetText(text)
            frame.Health.Text._fruitplatesText = text
        end
    end
end

function NP:Update_HealthBar(frame)
    local db = self:GetLayoutUnitDB(frame)
    if db and db.health and db.health.enable == true then
        if not frame.Health:IsShown() then frame.Health:Show() end
        self:Refresh_HealthOutline(frame)
    else
        if frame.Health:IsShown() then frame.Health:Hide() end
        HideHealthOutline(frame.Health)
    end
end

HideHealthOutline = function(healthBar)
    if not healthBar then return end
    if healthBar.OutlineTop then healthBar.OutlineTop:Hide() end
    if healthBar.OutlineBottom then healthBar.OutlineBottom:Hide() end
    if healthBar.OutlineLeft then healthBar.OutlineLeft:Hide() end
    if healthBar.OutlineRight then healthBar.OutlineRight:Hide() end
    healthBar._fruitplatesOutlineT = nil
    healthBar._fruitplatesOutlineR = nil
    healthBar._fruitplatesOutlineG = nil
    healthBar._fruitplatesOutlineB = nil
    healthBar._fruitplatesOutlineGrowth = nil
end

ApplyHealthOutline = function(healthBar, db)
    if not healthBar or not db then return end
    local outline = db.outline or {}
    if outline.enable ~= true then
        HideHealthOutline(healthBar)
        return
    end

    local t = tonumber(outline.thickness) or 1
    if t < 0.25 then t = 0.25 end
    if t > 8 then t = 8 end

    local c = outline.color or {r = 0, g = 0, b = 0}
    local r, g, b = c.r or 0, c.g or 0, c.b or 0

    if healthBar.OutlineTop.SetDrawLayer then healthBar.OutlineTop:SetDrawLayer("OVERLAY", 2) end
    if healthBar.OutlineBottom.SetDrawLayer then healthBar.OutlineBottom:SetDrawLayer("OVERLAY", 2) end
    if healthBar.OutlineLeft.SetDrawLayer then healthBar.OutlineLeft:SetDrawLayer("OVERLAY", 2) end
    if healthBar.OutlineRight.SetDrawLayer then healthBar.OutlineRight:SetDrawLayer("OVERLAY", 2) end

    local growth = outline.growth or "IN"
    local outward = growth == "OUT"
    if healthBar._fruitplatesOutlineT == t
        and healthBar._fruitplatesOutlineR == r
        and healthBar._fruitplatesOutlineG == g
        and healthBar._fruitplatesOutlineB == b
        and healthBar._fruitplatesOutlineGrowth == growth then
        return
    end
    healthBar._fruitplatesOutlineT = t
    healthBar._fruitplatesOutlineR = r
    healthBar._fruitplatesOutlineG = g
    healthBar._fruitplatesOutlineB = b
    healthBar._fruitplatesOutlineGrowth = growth

    local x1, y1, x2, y2 = 0, 0, 0, 0
    if outward then
        x1, y1, x2, y2 = -t, t, t, -t
    end

    healthBar.OutlineTop:ClearAllPoints()
    healthBar.OutlineTop:SetPoint("TOPLEFT", healthBar, "TOPLEFT", x1, y1)
    healthBar.OutlineTop:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT", x2, y1)
    healthBar.OutlineTop:SetHeight(t)
    healthBar.OutlineTop:SetTexture(r, g, b, 1)
    healthBar.OutlineTop:Show()

    healthBar.OutlineBottom:ClearAllPoints()
    healthBar.OutlineBottom:SetPoint("BOTTOMLEFT", healthBar, "BOTTOMLEFT", x1, y2)
    healthBar.OutlineBottom:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", x2, y2)
    healthBar.OutlineBottom:SetHeight(t)
    healthBar.OutlineBottom:SetTexture(r, g, b, 1)
    healthBar.OutlineBottom:Show()

    healthBar.OutlineLeft:ClearAllPoints()
    healthBar.OutlineLeft:SetPoint("TOPLEFT", healthBar, "TOPLEFT", x1, y1)
    healthBar.OutlineLeft:SetPoint("BOTTOMLEFT", healthBar, "BOTTOMLEFT", x1, y2)
    healthBar.OutlineLeft:SetWidth(t)
    healthBar.OutlineLeft:SetTexture(r, g, b, 1)
    healthBar.OutlineLeft:Show()

    healthBar.OutlineRight:ClearAllPoints()
    healthBar.OutlineRight:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT", x2, y1)
    healthBar.OutlineRight:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", x2, y2)
    healthBar.OutlineRight:SetWidth(t)
    healthBar.OutlineRight:SetTexture(r, g, b, 1)
    healthBar.OutlineRight:Show()
end

function NP:Refresh_HealthOutline(frame)
    if not frame or not frame.Health then return end

    local unitDB = self:GetLayoutUnitDB(frame)
    local healthDB = unitDB and unitDB.health

    if not healthDB or not frame.Health:IsShown() then
        HideHealthOutline(frame.Health)
        return
    end

    ApplyHealthOutline(frame.Health, healthDB)
end

function NP:Configure_HealthBar(frame)
    local layoutType
    local unitDB
    unitDB, layoutType = self:GetLayoutUnitDB(frame)
    if not unitDB or not unitDB.health then return end
    local db = unitDB.health
    local healthBar = frame.Health
    self:BumpPerf("configureHealthBar")

    local statusbar = FP:FetchMedia("statusbar", db.statusbar or self.db.statusbar)
    local textDB = db.text
    local key = (layoutType or frame.UnitType or "") .. "|"
        .. (statusbar or "") .. "|"
        .. tostring(db.width or "") .. "|"
        .. tostring(db.height or "") .. "|"
        .. tostring(db.xOffset or 0) .. "|"
        .. tostring(db.yOffset or 0) .. "|"
        .. (textDB and tostring(textDB.enable) or "") .. "|"
        .. (textDB and (textDB.parent or "") or "") .. "|"
        .. (textDB and (textDB.position or "") or "") .. "|"
        .. tostring(textDB and (textDB.xOffset or 0) or "") .. "|"
        .. tostring(textDB and (textDB.yOffset or 0) or "") .. "|"
        .. (textDB and (textDB.font or "") or "") .. "|"
        .. tostring(textDB and (textDB.fontSize or "") or "") .. "|"
        .. (textDB and (textDB.fontOutline or "") or "")

    if healthBar._fruitplatesConfigKey ~= key then
        healthBar:ClearAllPoints()
        healthBar:SetPoint("TOP", frame, "TOP", db.xOffset or 0, db.yOffset or 0)
        healthBar:SetStatusBarTexture(statusbar, "BORDER")
        healthBar:SetWidth(db.width)
        healthBar:SetHeight(db.height)
        healthBar._fruitplatesConfigKey = key
        healthBar._fruitplatesOutlineT = nil

        if textDB and textDB.enable then
            healthBar.Text:ClearAllPoints()
            healthBar.Text:SetPoint(textDB.position, textDB.parent == "Nameplate" and frame or frame[textDB.parent], textDB.position, textDB.xOffset, textDB.yOffset)
            FP:FontTemplate(healthBar.Text, FP:FetchMedia("font", textDB.font), textDB.fontSize, textDB.fontOutline)
            healthBar.Text:Show()
        else
            healthBar.Text:Hide()
            healthBar.Text._fruitplatesText = nil
        end
    end

    self:Refresh_HealthOutline(frame)
end

local function HealthBar_OnSizeChanged(self, width)
    local health = self:GetValue() or 0
    local _, maxHealth = self:GetMinMaxValues()
    maxHealth = maxHealth or 1
    if maxHealth <= 0 then maxHealth = 1 end
    local tex = self:GetStatusBarTexture()
    if tex then
        tex:SetPoint("TOPRIGHT", -(width * ((maxHealth - health) / maxHealth)), 0)
    end
end

function NP:Construct_HealthBar(parent)
    local frame = CreateFrame("StatusBar", nil, parent)
    frame:SetStatusBarTexture(FP:FetchMedia("statusbar", self.db.statusbar), "BORDER")
    frame:SetMinMaxValues(0, 1)
    frame:SetValue(1)
    frame:SetFrameLevel(parent:GetFrameLevel() + 1)
    FP:CreateBorder(frame)

    frame.OutlineTop = frame:CreateTexture(nil, "OVERLAY")
    frame.OutlineBottom = frame:CreateTexture(nil, "OVERLAY")
    frame.OutlineLeft = frame:CreateTexture(nil, "OVERLAY")
    frame.OutlineRight = frame:CreateTexture(nil, "OVERLAY")
    frame.OutlineTop:Hide()
    frame.OutlineBottom:Hide()
    frame.OutlineLeft:Hide()
    frame.OutlineRight:Hide()

    frame:SetScript("OnSizeChanged", HealthBar_OnSizeChanged)

    frame.Text = frame:CreateFontString(nil, "OVERLAY")
    frame.Text:SetAllPoints(frame)
    frame.Text:SetWordWrap(false)

    frame:Hide()
    return frame
end
