GM.Name = "Mil RP"
GM.Author = "Drobcho"
GM.Website = "fuck you"

mrp = mrp or {}
mrp.Config = mrp.Config or {}
mrp.Config.BaseColor = Color(255, 166, 0)

meta = meta or FindMetaTable("Player")

function mrp.Notify(message, col, ply)
	if not ( ply ) then
		if ( SERVER ) then
			return MsgC(Color(0, 105, 255), "[Military RP] > ", col or color_white, message.."\n")
		end

		return MsgC(Color(0, 105, 255), "[Military RP] > ", col or color_white, message.."\n")
	else
		ply:SendLua([[MsgC(Color(0, 105, 255), "[Military RP] > ", col or color_white, message.."\n")]])
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

	mrp.Notify("Loaded File: "..fileName)
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
mrp.IncludeDir("milrp/gamemode/plugins")
mrp.IncludeDir("milrp/gamemode/teams")

function GM:OnReloaded()
	mrp.IncludeDir("milrp/gamemode/core")
	mrp.IncludeDir("milrp/gamemode/core/vgui")
	mrp.IncludeDir("milrp/gamemode/core/hooks")
	mrp.IncludeDir("milrp/gamemode/plugins")
	mrp.IncludeDir("milrp/gamemode/teams")
end

function meta:IsCombine()
	return self:GetModel():find("combine")
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

function meta:Notify(message)
	self:ChatPrint(message)
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