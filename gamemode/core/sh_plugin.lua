HOOK_CACHE = {}

function mrp.LoadEntites(path)
    local files, folders

    local function IncludeFiles(path2, clientOnly)
        if (SERVER and file.Exists(path2.."init.lua", "LUA") or CLIENT) then
            if (clientOnly and CLIENT) or SERVER then
                include(path2.."init.lua")
            end

            if (file.Exists(path2.."cl_init.lua", "LUA")) then
                if SERVER then
                    AddCSLuaFile(path2.."cl_init.lua")
                else
                    include(path2.."cl_init.lua")
                end
            end

            return true
        elseif (file.Exists(path2.."shared.lua", "LUA")) then
            AddCSLuaFile(path2.."shared.lua")
            include(path2.."shared.lua")

            return true
        end

        return false
    end

    local function HandleEntityInclusion(folder, variable, register, default, clientOnly)
        files, folders = file.Find(path.."/"..folder.."/*", "LUA")
        default = default or {}

        for k, v in ipairs(folders) do
            local path2 = path.."/"..folder.."/"..v.."/"

            _G[variable] = table.Copy(default)
                _G[variable].ClassName = v

                if (IncludeFiles(path2, clientOnly) and !client) then
                    if (clientOnly) then
                        if (CLIENT) then
                            register(_G[variable], v)
                        end
                    else
                        register(_G[variable], v)
                    end
                end
            _G[variable] = nil
        end

        for k, v in ipairs(files) do
            local niceName = string.StripExtension(v)

            _G[variable] = table.Copy(default)
                _G[variable].ClassName = niceName
                AddCSLuaFile(path.."/"..folder.."/"..v)
                include(path.."/"..folder.."/"..v)

                if (clientOnly) then
                    if (CLIENT) then
                        register(_G[variable], niceName)
                    end
                else
                    register(_G[variable], niceName)
                end
            _G[variable] = nil
        end
    end

    -- Include entities.
    HandleEntityInclusion("entities", "ENT", scripted_ents.Register, {
        Type = "anim",
        Base = "base_gmodentity",
        Spawnable = true
    })

    -- Include weapons.
    HandleEntityInclusion("weapons", "SWEP", weapons.Register, {
        Primary = {},
        Secondary = {},
        Base = "weapon_base"
    })

    -- Include effects.
    HandleEntityInclusion("effects", "EFFECT", effects and effects.Register, nil, true)
end

function mrp.LoadHooks(file, variable, uid)
    local PLUGIN = {}
    _G[variable] = PLUGIN
    PLUGIN.mrpLoading = true

    mrp.LoadFile(file)

    local c = 0

    for v,k in pairs(PLUGIN) do
        if type(k) == "function" then
            c = c + 1
            hook.Add(v, "mrp"..uid..c, function(...)
                return k(nil, ...)
            end)
        end
    end

    if PLUGIN.OnLoaded then
        PLUGIN.OnLoaded()
    end

    PLUGIN.mrpLoading = nil
    _G[variable] = nil
end

function mrp.LoadPlugin(path, name)
    mrp.IncludeDir(path.."/setup", true, "PLUGIN", name)
    mrp.IncludeDir(path, true, "PLUGIN", name)
    mrp.IncludeDir(path.."/vgui", true, "PLUGIN", name)
    mrp.LoadEntites(path.."/entities")
    mrp.IncludeDir(path.."/hooks", true, "PLUGIN", name)
end

local files, plugins = file.Find("milrp/gamemode/plugins/*", "LUA")

mrp.Plugins = mrp.Plugins or {}

for v, dir in ipairs(plugins) do
	if mrp.Config.DisabledPlugins and mrp.Config.DisabledPlugins[dir] then
		continue
	end
	
	mrp.Log("Loading Plugin "..dir)
	mrp.LoadPlugin("milrp/gamemode/plugins/"..dir, dir)
    table.Empty(mrp.Plugins)
    table.insert(mrp.Plugins, dir)
end