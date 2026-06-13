local FP = _G.FruitPlates

local STATUSBAR_TEXTURES = {
    {label = "FurtiPlates Shade", value = "FurtiPlates Shade", file = [[Textures\normTex.tga]]},
    {label = "FruitPlates Flat", value = "FruitPlates Flat", file = [[Textures\normTex2.tga]]},
    {label = "Aluminium", value = "Aluminium", file = [[Textures\Statusbars\Aluminium.tga]]},
    {label = "Armory", value = "Armory", file = [[Textures\Statusbars\Armory.tga]]},
    {label = "BantoBar", value = "BantoBar", file = [[Textures\Statusbars\BantoBar.tga]]},
    {label = "Bars", value = "Bars", file = [[Textures\Statusbars\Bars.tga]]},
    {label = "Button", value = "Button", file = [[Textures\Statusbars\Button.tga]]},
    {label = "Charcoal", value = "Charcoal", file = [[Textures\Statusbars\Charcoal.tga]]},
    {label = "Cilo", value = "Cilo", file = [[Textures\Statusbars\Cilo.tga]]},
    {label = "Cloud", value = "Cloud", file = [[Textures\Statusbars\Cloud.tga]]},
    {label = "DarkBottom", value = "DarkBottom", file = [[Textures\Statusbars\DarkBottom.tga]]},
    {label = "Diagonal", value = "Diagonal", file = [[Textures\Statusbars\Diagonal.tga]]},
    {label = "Glamour", value = "Glamour", file = [[Textures\Statusbars\Glamour.tga]]},
    {label = "Glass", value = "Glass", file = [[Textures\Statusbars\Glass.tga]]},
    {label = "Graphite", value = "Graphite", file = [[Textures\Statusbars\Graphite.tga]]},
    {label = "Melli", value = "Melli", file = [[Textures\Statusbars\Melli.tga]]},
    {label = "Minimalist", value = "Minimalist", file = [[Textures\Statusbars\Minimalist.tga]]},
}

FP.StatusbarTextureOptions = STATUSBAR_TEXTURES

function FP:InitializeMedia()
    local base = [[Interface\AddOns\FruitPlates\Media\]]
    self.media = {
        normTex = base .. [[Textures\normTex.tga]],
        normTex2 = base .. [[Textures\normTex2.tga]],
        blankTex = base .. [[Textures\Black8x8.tga]],
        glowTex = base .. [[Textures\glowTex.tga]],
        highlight = base .. [[Textures\Highlight.tga]],
        spark = base .. [[Textures\Spark.tga]],
        raidIcons = [[Interface\TargetingFrame\UI-RaidTargetingIcons]],
        font = [[Fonts\FRIZQT__.TTF]],
        backdropfadecolor = {0, 0, 0, 0.55},
        bordercolor = {0, 0, 0, 1},
    }

    self.media.statusbars = {}
    for _, info in ipairs(STATUSBAR_TEXTURES) do
        self.media.statusbars[info.value] = base .. info.file
    end

    -- Compatibility aliases for profiles saved with older texture labels.
    self.media.statusbars["FruitPlates Norm"] = self.media.normTex
    self.media.statusbars["FruitPlates Norm2"] = self.media.normTex2

    self.Media = {
        Textures = {
            Spark = self.media.spark,
            Highlight = self.media.highlight,
        },
    }
end

function FP:FetchMedia(kind, key)
    if kind == "statusbar" then
        local media = self.media or {}
        local statusbars = media.statusbars or {}
        return statusbars[key] or statusbars["FurtiPlates Shade"] or media.normTex
    elseif kind == "background" then
        return self.media.blankTex
    elseif kind == "border" then
        return self.media.glowTex
    elseif kind == "font" then
        return self.media.font
    end

    return self.media.blankTex
end
