local FP = _G.FruitPlates

function FP:InitializeSlash()
    SLASH_FRUITPLATES1 = "/fp"
    SLASH_FRUITPLATES2 = "/fruitplates"

    SlashCmdList.FRUITPLATES = function(msg)
        msg = string.lower(tostring(msg or ""))
        local NP = FP:GetModule("NamePlates")

        if msg == "" or msg == "config" or msg == "options" then
            FP:ToggleConfig()
        elseif msg == "debug" then
            FP.debug = not FP.debug
            FP.db.debug = FP.debug
            FP:Print("debug", FP.debug and "enabled" or "disabled")
        elseif msg == "rescan" then
            if NP and NP.ScanWorldFrame then NP:ScanWorldFrame(true) end
            FP:Print("rescan requested")
        elseif msg == "count" then
            local created, visible = 0, 0
            if NP then
                for _ in pairs(NP.CreatedPlates) do created = created + 1 end
                for _ in pairs(NP.VisiblePlates) do visible = visible + 1 end
            end
            FP:Print("created:", created, "visible:", visible)
        elseif msg == "perf" then
            if NP and NP.TogglePerf then
                NP:TogglePerf()
            else
                FP:Print("nameplate performance counters are not available yet")
            end
        elseif msg == "reset" then
            FruitPlatesDB = nil
            ReloadUI()
        else
            FP:Print("commands: /fp, /fp config, /fp debug, /fp rescan, /fp count, /fp perf, /fp reset")
        end
    end
end
