local PLUGIN = PLUGIN

PLUGIN.name = "Map Configs"
PLUGIN.author = "Drobcho"

mrp.MapConfig = mrp.MapConfig or {}

function PLUGIN:InitPostEntity()
    local mapPath = "milrp/gamemode/plugins/mapconfigs/maps/"..game.GetMap()..".lua"

    if ( file.Exists("gamemodes/"..mapPath, "GAME") ) then
        if ( SERVER ) then
            include(mapPath)
            AddCSLuaFile(mapPath)
            
            if mrp.MapConfig.MapWorkshopID then
                resource.AddWorkshop(mrp.MapConfig.MapWorkshopID)
            end

            if ( mrp.MapConfig.MapContentWorkshopID ) then
                if (istable(mrp.MapConfig.MapContentWorkshopID)) then
                    for k, v in pairs(mrp.MapConfig.MapContentWorkshopID) do
                        resource.AddWorkshop(v)
                    end
                else
                    resource.AddWorkshop(mrp.MapConfig.MapContentWorkshopID)
                end
            end

            if ( mrp.MapConfig.InitScript ) then
                mrp.MapConfig.InitScript()
            end
        elseif ( CLIENT ) then
            include(mapPath)
            AddCSLuaFile(mapPath) 
        end
    end

    hook.Run("PostConfigLoad", game.GetMap())
end

function PLUGIN:OnReloaded()
    local mapPath = "milrp/gamemode/plugins/mapconfigs/maps/"..game.GetMap()..".lua"

    if ( file.Exists("gamemodes/"..mapPath, "GAME") ) then
        if ( SERVER ) then
            include(mapPath)
            AddCSLuaFile(mapPath)
            
            if mrp.MapConfig.MapWorkshopID then
                resource.AddWorkshop(mrp.MapConfig.MapWorkshopID)
            end

            if ( mrp.MapConfig.MapContentWorkshopID ) then
                if (istable(mrp.MapConfig.MapContentWorkshopID)) then
                    for k, v in pairs(mrp.MapConfig.MapContentWorkshopID) do
                        resource.AddWorkshop(v)
                    end
                else
                    resource.AddWorkshop(mrp.MapConfig.MapContentWorkshopID)
                end
            end

            if ( mrp.MapConfig.InitScript ) then
                mrp.MapConfig.InitScript()
            end
        elseif ( CLIENT ) then
            include(mapPath)
            AddCSLuaFile(mapPath) 
        end
    end

    hook.Run("PostConfigLoad", game.GetMap())
end

if ( CLIENT ) then
    function PLUGIN:CalcView(ply, origin, angle, fov)
        if not ( mrp.MapConfig.MPos and mrp.MapConfig.MAng ) then return end

        local viewpos = {
            origin = mrp.MapConfig.MPos,
            angles = mrp.MapConfig.MAng,
            fov = 80
        }

        return viewpos
    end
end