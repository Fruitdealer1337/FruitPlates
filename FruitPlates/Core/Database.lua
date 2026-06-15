local FP = _G.FruitPlates

local function NormalizeStatusbarKey(value)
    if value == "FruitPlates Norm" then return "FurtiPlates Shade" end
    if value == "FruitPlates Norm2" then return "FruitPlates Flat" end
    if value == nil or value == "" then return "FurtiPlates Shade" end
    return value
end

function FP:NormalizeHealthbarStatusbarDB()
    local nameplates = self.db and self.db.nameplates
    if not nameplates then return end

    nameplates.statusbar = NormalizeStatusbarKey(nameplates.statusbar)

    local units = nameplates.units or {}
    for _, unitDB in pairs(units) do
        local health = unitDB and unitDB.health
        if health then
            if health.statusbar == nil or health.statusbar == "" then
                health.statusbar = nameplates.statusbar or "FurtiPlates Shade"
            else
                health.statusbar = NormalizeStatusbarKey(health.statusbar)
            end
        end
    end
end


function FP:CleanupAurasDB()
    local nameplates = self.db and self.db.nameplates
    local auras = nameplates and nameplates.auras
    if not nameplates then return end

    if auras then
        -- Enemy auras now use the priority layout only. Old row-mode keys can be dropped on load.
        auras.displayStyle = nil
        auras.showDebuffs = nil
        auras.showBuffs = nil
        auras.spells = nil
        auras.colorTypes = nil
        auras.showOnPlayers = nil
        auras.showOnPets = nil
        auras.showOnNPC = nil
        auras.showOnEnemy = nil
        auras.showOnFriend = nil
        auras.showOnNeutral = nil

        auras.units = auras.units or {}
        local units = auras.units
        units.enemyPlayer = units.enemyPlayer or {}
        units.enemyPet = units.enemyPet or {}
        units.npcTarget = units.npcTarget or {}
        if units.enemyPlayer.enable == nil then units.enemyPlayer.enable = true end
        if units.enemyPet.enable == nil then units.enemyPet.enable = true end
        if units.npcTarget.enable == nil then units.npcTarget.enable = true end
        units.friendlyPlayer = nil
        units.friendlyPet = nil
        units.enemyNPC = nil
        units.friendlyNPC = nil
    end

    local friendly = nameplates.friendlyAuras
    if not friendly then return end

    friendly.units = friendly.units or {}
    friendly.units.friendlyPlayer = friendly.units.friendlyPlayer or {}
    friendly.units.friendlyPet = friendly.units.friendlyPet or {}
    if friendly.units.friendlyPlayer.enable == nil then friendly.units.friendlyPlayer.enable = true end
    if friendly.units.friendlyPet.enable == nil then friendly.units.friendlyPet.enable = true end
    friendly.whitelist = friendly.whitelist or {}
    friendly.whitelist.spells = friendly.whitelist.spells or {}
    friendly.whitelist.names = friendly.whitelist.names or {}
    friendly.row = friendly.row or {}
    if friendly.row.enable == nil then friendly.row.enable = true end
end


function FP:MigrateIconDB()
    local profile = FruitPlatesDB and FruitPlatesDB.profile
    local icons = profile and profile.nameplates and profile.nameplates.icons
    if not icons then return end

    icons.raidIcons = icons.raidIcons or {}
    icons.classIcons = icons.classIcons or {}

    local raidDB = icons.raidIcons
    local classDB = icons.classIcons

    if icons.enemyMode == nil then icons.enemyMode = icons.mode or "BOTH" end
    if icons.friendlyMode == nil then icons.friendlyMode = icons.mode or "BOTH" end

    local oldRaidSize = raidDB.size or icons.size or 18
    if raidDB.enemySize == nil then raidDB.enemySize = oldRaidSize end
    if raidDB.friendlySize == nil then raidDB.friendlySize = oldRaidSize end
    if raidDB.npcSize == nil then raidDB.npcSize = oldRaidSize end
    if raidDB.petSize == nil then raidDB.petSize = oldRaidSize end

    local oldClassSize = classDB.size or icons.size or 17
    if classDB.enemySize == nil then classDB.enemySize = oldClassSize end
    if classDB.friendlySize == nil then classDB.friendlySize = oldClassSize end

    local oldClassZoom = classDB.zoom or 0
    if classDB.enemyZoom == nil then classDB.enemyZoom = oldClassZoom end
    if classDB.friendlyZoom == nil then classDB.friendlyZoom = oldClassZoom end
end

function FP:InitializeDatabase()
    FruitPlatesDB = FruitPlatesDB or {}
    self:MigrateIconDB()
    FruitPlatesDB.profile = self:MergeDefaults(self.Defaults, FruitPlatesDB.profile)
    self.db = FruitPlatesDB.profile
    self:CleanupAurasDB()
    self:NormalizeHealthbarStatusbarDB()
    self.debug = self.db.debug and true or false
end
