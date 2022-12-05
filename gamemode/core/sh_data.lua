mrp.data = mrp.data or {}
mrp.data.stored = mrp.data.stored or {}

file.CreateDir("mrp")

function mrp.data.Set(key, value, bGlobal, bIgnoreMap)
	local path = "mrp/" .. (bGlobal and "" or engine.ActiveGamemode() .. "/") .. (bIgnoreMap and "" or game.GetMap() .. "/")

	if (!bGlobal) then
		file.CreateDir("mrp/" .. engine.ActiveGamemode() .. "/")
	end
    
	file.CreateDir(path)
	file.Write(path .. key .. ".txt", util.TableToJSON({value}))

	mrp.data.stored[key] = value

	return path
end

function mrp.data.Get(key, default, bGlobal, bIgnoreMap, bRefresh)
	if (!bRefresh) then
		local stored = mrp.data.stored[key]

		if (stored != nil) then
			return stored
		end
	end

	local path = "mrp/" .. (bGlobal and "" or engine.ActiveGamemode() .. "/") .. (bIgnoreMap and "" or game.GetMap() .. "/")
    
	local contents = file.Read(path .. key .. ".txt", "DATA")

	if (contents and contents != "") then
		local status, decoded = pcall(util.JSONToTable, contents)

		if (status and decoded) then
			local value = decoded[1]

			if (value != nil) then
				return value
			end
		end

		status, decoded = pcall(pon.decode, contents)

		if (status and decoded) then
			local value = decoded[1]

			if (value != nil) then
				return value
			end
		end
	end

	return default
end

function mrp.data.Delete(key, bGlobal, bIgnoreMap)
	local path = "mrp/" .. (bGlobal and "" or engine.ActiveGamemode() .. "/") .. (bIgnoreMap and "" or game.GetMap() .. "/")

	local contents = file.Read(path .. key .. ".txt", "DATA")

	if (contents and contents != "") then
		file.Delete(path .. key .. ".txt")
		mrp.data.stored[key] = nil
		return true
	end

	return false
end

if (SERVER) then
	timer.Create("mrpSaveData", 600, 0, function()
		hook.Run("SaveData")
	end)
end
