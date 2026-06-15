local FP = _G.FruitPlates
local NP = FP:GetModule("NamePlates")

local function PlateIconFamily(unitType)
    if unitType == "ENEMY_PLAYER" then return "enemy" end
    if unitType == "FRIENDLY_PLAYER" then return "friendly" end
    if unitType == "ENEMY_PET" or unitType == "FRIENDLY_PET" then return "pet" end
    return "npc"
end

function NP:Configure_RaidIcon(frame)
    if not frame.RaidIcon then return end

    local db = self.db.icons or {}
    local raidDB = db.raidIcons or db
    local family = PlateIconFamily(frame.UnitType)

    local mode = "RAID"
    if family == "enemy" then
        mode = db.enemyMode or db.mode or "BOTH"
    elseif family == "friendly" then
        mode = db.friendlyMode or db.mode or "BOTH"
    end

    local enabled = db.enable ~= false
        and raidDB.enable ~= false
        and mode ~= "CLASS"
        and raidDB[family] ~= false

    if enabled then
        local size = raidDB.size or db.size or 18
        if family == "enemy" and raidDB.enemySize ~= nil then
            size = raidDB.enemySize
        elseif family == "friendly" and raidDB.friendlySize ~= nil then
            size = raidDB.friendlySize
        elseif family == "npc" and raidDB.npcSize ~= nil then
            size = raidDB.npcSize
        elseif family == "pet" and raidDB.petSize ~= nil then
            size = raidDB.petSize
        end
        local x = raidDB.xOffset
        local y = raidDB.yOffset

        if family == "enemy" then
            if raidDB.enemyXOffset ~= nil then x = raidDB.enemyXOffset end
            if raidDB.enemyYOffset ~= nil then y = raidDB.enemyYOffset end
        elseif family == "friendly" then
            if raidDB.friendlyXOffset ~= nil then x = raidDB.friendlyXOffset end
            if raidDB.friendlyYOffset ~= nil then y = raidDB.friendlyYOffset end
        elseif family == "npc" then
            if raidDB.npcXOffset ~= nil then x = raidDB.npcXOffset end
            if raidDB.npcYOffset ~= nil then y = raidDB.npcYOffset end
        elseif family == "pet" then
            if raidDB.petXOffset ~= nil then x = raidDB.petXOffset end
            if raidDB.petYOffset ~= nil then y = raidDB.petYOffset end
        end

        if x == nil then x = db.xOffset or 0 end
        if y == nil then y = db.yOffset or 10 end

        local icon = frame.RaidIcon
        local parent = frame.Health or frame
        if icon._fruitplatesLayoutFamily ~= family
            or icon._fruitplatesLayoutParent ~= parent
            or icon._fruitplatesLayoutSize ~= size
            or icon._fruitplatesLayoutX ~= x
            or icon._fruitplatesLayoutY ~= y then
            icon:ClearAllPoints()
            icon:SetParent(frame)

            -- Native Blizzard raid icon is a Texture, not a Frame.
            -- Textures cannot use SetFrameLevel(), so use draw layer instead.
            -- This keeps raid icons visually above the target glow without throwing Lua errors.
            if icon.SetDrawLayer then
                icon:SetDrawLayer("OVERLAY", 7)
            end

            -- Raid icon position should be stable regardless of Icon Mode.
            -- Enemy/Friendly plates may use dedicated offsets.
            icon:SetPoint("BOTTOM", parent, "TOP", x, y)

            icon:SetWidth(size)
            icon:SetHeight(size)
            icon._fruitplatesLayoutFamily = family
            icon._fruitplatesLayoutParent = parent
            icon._fruitplatesLayoutSize = size
            icon._fruitplatesLayoutX = x
            icon._fruitplatesLayoutY = y
        end

        if not icon.GetAlpha or icon:GetAlpha() ~= 1 then icon:SetAlpha(1) end
    else
        if not frame.RaidIcon.GetAlpha or frame.RaidIcon:GetAlpha() ~= 0 then frame.RaidIcon:SetAlpha(0) end
    end
end

function NP:Update_RaidIcon(frame)
    self:Configure_RaidIcon(frame)
end
