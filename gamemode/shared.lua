GM.Name = "Mil RP"
GM.Author = "Drobcho"
GM.Website = "fuck you"

mrp = mrp or {}
mrp.Config = mrp.Config or {}
mrp.Config.BaseColor = Color(255, 166, 0)

meta = meta or FindMetaTable("Player")

if ( SERVER ) then
	util.AddNetworkString("mrpLogPlayer")
else
	net.Receive("mrpLogPlayer", function(len)
		local msg = net.ReadString()
		local col = net.ReadColor()

		MsgC(mrp.Config.BaseColor, "[Military RP] > ", col, msg)
	end)
end

function mrp.Log(message, col, ply)
	if not ( ply ) then
		if ( SERVER ) then
			return MsgC(mrp.Config.BaseColor, "[Military RP] > ", col or color_white, message.."\n" or "Add Message\n")
		end

		return MsgC(mrp.Config.BaseColor, "[Military RP] > ", col or color_white, message.."\n" or "Add Message\n")
	else
		if ( SERVER ) then
			if ( IsValid(ply) ) then
				net.Start("mrpLogPlayer")
					net.WriteString(message.."\n" or "Add Message\n")
					net.WriteColor(col or color_white)
				net.Send(ply)
			end
		end
	end
end

function widgets.PlayerTick()
end

hook.Remove("PlayerTick", "TickWidgets")

function mrp.LoadFile(fileName)
	if (!fileName) then
		error("[mrp] File to include has no name!")
	end

	if fileName:find("sv_") then
		if (SERVER) then
			include(fileName)
		end
	elseif fileName:find("sh_") then
		if (SERVER) then
			AddCSLuaFile(fileName)
		end
		include(fileName)
	elseif fileName:find("cl_") then
		if (SERVER) then
			AddCSLuaFile(fileName)
		else
			include(fileName)
		end
	elseif fileName:find("rq_") then
		if (SERVER) then
			AddCSLuaFile(fileName)
		end

		_G[string.sub(fileName, 26, string.len(fileName) - 4)] = include(fileName)
	end

	mrp.Log("Loaded File: "..fileName)
end

function mrp.IncludeDir(directory, hookMode, variable, uid)
	for k, v in ipairs(file.Find(directory.."/*.lua", "LUA")) do
        if hookMode then
    		mrp.LoadHooks(directory.."/"..v, variable, uid)
    	else
    		mrp.LoadFile(directory.."/"..v)
    	end
	end
end

mrp.IncludeDir("milrp/gamemode/core")
mrp.IncludeDir("milrp/gamemode/core/vgui")
mrp.IncludeDir("milrp/gamemode/core/hooks")
mrp.IncludeDir("milrp/gamemode/teams")

function GM:OnReloaded()
	mrp.IncludeDir("milrp/gamemode/core")
	mrp.IncludeDir("milrp/gamemode/core/vgui")
	mrp.IncludeDir("milrp/gamemode/core/hooks")
	mrp.IncludeDir("milrp/gamemode/teams")

	RunConsoleCommand("mat_queue_mode", "-1")
	RunConsoleCommand("cl_threaded_bone_setup", "1")
	RunConsoleCommand("r_shadows", "1")
	RunConsoleCommand("r_dynamic", "1")

	RunConsoleCommand("bsmod_kick_enabled", "0")
	RunConsoleCommand("bsmod_killmove_anytime", "1")
	RunConsoleCommand("bsmod_killmove_anytime_behind", "1")
	RunConsoleCommand("bsmod_killmove_glow", "0")
	
	RunConsoleCommand("gmod_mcore_test", "1")
end

function meta:IsCombine()
	return self:GetModel():find("combine")
end

local blacklistNames = {
	["ooc"] = true,
	["shared"] = true,
	["world"] = true,
	["world prop"] = true,
	["blocked"] = true,
	["admin"] = true,
	["server admin"] = true,
	["mod"] = true,
	["game moderator"] = true,
	["adolf hitler"] = true,
	["masked person"] = true,
	["masked player"] = true,
	["unknown"] = true,
	["nigger"] = true,
	["tyrone jenson"] = true
}

function mrp.SafeString(str)
    local pattern = "[^0-9a-zA-Z%s]+"
    local clean = tostring(str)
    local first, last = string.find(str, pattern)

    if first != nil and last != nil then
        clean = string.gsub(clean, pattern, "") -- remove bad sequences
    end

    return clean
end

function mrp.CanUseName(name)
	if name:len() >= 24 then
		return false, "Name too long. (max. 24)" 
	end

	name = name:Trim()
	name = mrp.SafeString(name)

	if name:len() <= 6 then
		return false, "Name too short. (min. 6)"
	end

	if name == "" then
		return false, "No name was provided."
	end


	local numFound = string.match(name, "%d") -- no numerics

	if numFound then
		return false, "Name contains numbers."
	end
	
	if blacklistNames[name:lower()] then
		return false, "Blacklisted/reserved name."	
	end

	return true, name
end

function mrp:FindPlayer(searchKey)
    if not searchKey or searchKey == "" then return nil end
    local searchPlayers = player.GetAll()
    local lowerKey = string.lower(tostring(searchKey))

    for k = 1, #searchPlayers do
        local v = searchPlayers[k]

        if searchKey == v:SteamID() then
            return v
        end

        if string.find(string.lower(v:Name()), lowerKey, 1, true) ~= nil then
            return v
        end

        if string.find(string.lower(v:SteamName()), lowerKey, 1, true) ~= nil then
            return v
        end
    end
    return nil
end

function mrp.IsEmpty(vector, ignore) -- findpos and isempty are from darkrp
    ignore = ignore or {}

    local point = util.PointContents(vector)
    local a = point ~= CONTENTS_SOLID
        and point ~= CONTENTS_MOVEABLE
        and point ~= CONTENTS_LADDER
        and point ~= CONTENTS_PLAYERCLIP
        and point ~= CONTENTS_MONSTERCLIP
    if not a then return false end

    local b = true

    for _, v in ipairs(ents.FindInSphere(vector, 35)) do
        if (v:IsNPC() or v:IsPlayer() or v:GetClass() == "prop_physics" or v.NotEmptyPos) and not table.HasValue(ignore, v) then
            b = false
            break
        end
    end

	return a and b
end

function mrp.FindEmptyPos(pos, ignore, distance, step, area)
    if mrp.IsEmpty(pos, ignore) and mrp.IsEmpty(pos + area, ignore) then
        return pos
    end

    for j = step, distance, step do
        for i = -1, 1, 2 do -- alternate in direction
            local k = j * i

            -- Look North/South
            if mrp.IsEmpty(pos + Vector(k, 0, 0), ignore) and mrp.IsEmpty(pos + Vector(k, 0, 0) + area, ignore) then
                return pos + Vector(k, 0, 0)
            end

            -- Look East/West
            if mrp.IsEmpty(pos + Vector(0, k, 0), ignore) and mrp.IsEmpty(pos + Vector(0, k, 0) + area, ignore) then
                return pos + Vector(0, k, 0)
            end

            -- Look Up/Down
            if mrp.IsEmpty(pos + Vector(0, 0, k), ignore) and mrp.IsEmpty(pos + Vector(0, 0, k) + area, ignore) then
                return pos + Vector(0, 0, k)
            end
        end
    end

    return pos
end

meta.steamName = meta.steamName or meta.Name
function meta:SteamName()
	return self.steamName(self)
end

function meta:Name()
    return self:GetSyncVar(SYNC_RPNAME, self:SteamName())
end

function meta:KnownName()
	local custom = hook.Run("PlayerGetKnownName", self)
	return custom or self:GetSyncVar(SYNC_RPNAME, self:SteamName())
end

meta.GetName = meta.Name
meta.Nick = meta.Name

function meta:GetEntsInRadius(radius)
	local ent = {}

	for k, v in pairs(ents.FindInSphere(self:GetPos(), radius or 96)) do
		table.insert(ent, v)
	end

	return ent
end

function meta:GetPlayersInRadius(radius)
	local ent = {}

	for k, v in pairs(ents.FindInSphere(self:GetPos(), radius or 96)) do
		if ( v:IsPlayer() ) then
			table.insert(ent, v)
		end
	end

	return ent
end

function meta:IsSoldier()
	return ( self:Team() == TEAM_SOLDIER )
end

function meta:IsTerrorist()
	return ( self:Team() == TEAM_TERRORIST )
end

mrp.Changelogs = {
	[4] = {
		"Added Freelook",
	},
	[3] = {
		"Changed the font for the gamemode",
		"Fixed gamemode breaking error"
	},
	[2] = {
		"Added Team System",
		"Added Class System",
		"Added NVG",
		"Added Door Blasting Plugin",
		"Added Throwing Knives",
		"Added Bodycam System",
		"Added Compass",
		"Added Leaning",
	},
	[1] = {
		"Added HUD",
		"Added Crosshair",
		"Added Rappeling",
		"Added Helicopter Rappeling",
		"Added Bleeding System ( Toggable )",
		"Added Whitelist System ( Toggable )",
		"Added Relationship System",
		"Integrated Quick Slide Addon",
		"Ported OPS Administration System",
		"Added Mapconfig System",
		"Added Chatbox",
		"Added Bodygroup Manager Plugin",
	},
	
	
}

mrp.BleedingEnabled = false -- Should you bleed when you take damage.
mrp.StaminaEnabled = false -- Should Stamina System Be Enabled.
mrp.EnabledDamageFlinch = false -- Should you flinch when you get shot

player_manager.AddValidHands("SoldierHands", "models/weapons/scmilsimarms.mdl", 1, "000000")
player_manager.AddValidModel("SoldierHands", "models/bread/cod/characters/milsim/shadow_company.mdl")