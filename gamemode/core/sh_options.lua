mrp.Settings = mrp.Settings or {}
mrp.AdvSettings = mrp.AdvSettings or {}

function mrp.DefineSetting(name, settingdata)
	mrp.Settings[name] = settingdata
	mrp.LoadSettings()
end

local toBool = tobool
local optX = {["tickbox"] = true}

function mrp.GetSetting(name)
	local settingData = mrp.Settings[name]

	if optX[settingData.type] then
		if settingData.value == nil then
			return settingData.default
		end

		return toBool(settingData.value)
	end

	return settingData.value or settingData.default
end

function mrp.LoadSettings()
	for v,k in pairs(mrp.Settings) do
		if k.type == "tickbox" or k.type == "slider" or k.type == "plainint" then
			local def = k.default
			if k.type == "tickbox" then 
				def = tonumber(k.default) 
			end

			k.value = cookie.GetNumber("mrp-setting-"..v, def)
		elseif k.type == "dropdown" or k.type == "textbox" then
			k.value = cookie.GetString("mrp-setting-"..v, k.default)
		end

		if k.onChanged then
			k.onChanged(k.value)
		end
	end
end

function mrp.SetSetting(name, newValue)
	local settingData = mrp.Settings[name]
	if settingData then
		if type(newValue) == "boolean" then
			newValue = newValue and 1 or 0
		end

		cookie.Set("mrp-setting-"..name, newValue)
		settingData.value = newValue

		if settingData.onChanged then
			settingData.onChanged(newValue)
		end

		return
	end
	return print("[mrp] Error, could not SetSetting. You've probably got the name wrong! Attempted name: "..name)
end

function mrp.GetAdvSetting(name)
	return mrp.AdvSettings[name]
end

function mrp.LoadAdvSettings()
	if not file.Exists("mrp/adv_settings.json", "DATA") then
		return "No adv_settings.json file found."
	end
	
	local f = file.Read("mrp/adv_settings.json")

	if not f then
		return "Can't read adv_settings.json file."
	end
	
	local json = util.JSONToTable(f)

	if not json or not istable(json) then
		return "Corrupted music kit file. Check formatting."
	end

	mrp.AdvSettings = json
end

mrp.LoadAdvSettings()

concommand.Add("mrp_reloadadvsettings", function()
	print("[mrp] Attempting to reload advanced settings...")

	local try = mrp.LoadAdvSettings()

	if try then
		print("[mrp] Error when loading advanced settings: "..try)
	else
		print("[mrp] Successful reload.")
	end
end)

concommand.Add("mrp_resetsettings", function()
	for v,k in pairs(mrp.Settings) do
		mrp.SetSetting(v, k.default)
	end
	print("[mrp] Settings reset!")
end)


hook.Run("DefineSettings")