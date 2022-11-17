-- Shared file.

mrp.Compass = mrp.Compass or {}
mrp.Compass_Settings = {}

-- Enables/Disables compass for everyone in the entire server
mrp.Compass_Settings.Compass_Enabled = true
mrp.Compass_Settings.Force_Server_Style = false -- Force the below compass settings on the client.
mrp.Compass_Settings.Use_FastDL = true -- Auto download the nessesary content for clients.

mrp.Compass_Settings.Style_Selected = "squad"
mrp.Compass_Settings.Allow_Entity_Spotting = false -- Not yet working.
mrp.Compass_Settings.Spot_Duration = 10 -- In seconds

mrp.Compass_Settings.Styles = {
	["squad"] = {
		heading = true,		-- Whether or not the precise bearing is displayed. (Default: true)
		compassX = 0.5,		-- This value is multiplied by users screen width. (Default: 0.5)
		compassY = 0.9,		-- This value is multiplied by users screen height. (Default: 0.9)
		width = 0.25,		-- This value is multiplied by users screen width. (Default: 0.25)
		height = 0.03,		-- This value is multiplied by users screen height. (Default: 0.03)
		spacing = 2,		-- This value changes the spacing between lines. (Default: 2.5)
		ratio = 1.8,		-- The is the ratio of the size of the letters and numbers text. (Default: 1.8)
		offset = 0,			-- The number of degrees the compass will offset by. (Default: 0)
		maxMarkerSize = 1,	-- Maximum size of the marker, note that this affects scaling (Default: 1)
		minMarkerSize = 0.5, -- Minimum size of the marker, note that this affects scaling (Default: 0.5)
		color = Color(255, 255, 255) -- The color of the compass.
	}
}

--------------------------------------------------------------
-- Dont edit anything below this line.
--------------------------------------------------------------

if SERVER then

	util.AddNetworkString("mrp.Compass_AddMarker")
	util.AddNetworkString("mrp.Compass_RemoveMarker")

	local MarkerTable = MarkerTable or {}

	function mrp.Compass_AddMarker(ply, pos, players, time, color, icon, name)
		name = name or ""
		icon = icon or ""
		color = color or Color(255, 0, 0)
		players = players or (ply and ply:IsPlayer()) and team.GetPlayers(ply:Team())

		local id = #MarkerTable + 1
		if players then
			for k, v in pairs(players) do
				net.Start("mrp.Compass_AddMarker")
					net.WriteInt(id, 4)
					net.WriteBool(false) -- IsEntity
					net.WriteVector(pos)
					net.WriteFloat(time)
					net.WriteColor(color)
					net.WriteString(icon)
					net.WriteString(name)
				net.Send(v)
			end
		else
			net.Start("mrp.Compass_AddMarker")
				net.WriteInt(id, 4)
				net.WriteBool(false) -- IsEntity
				net.WriteVector(pos)
				net.WriteFloat(time)
				net.WriteColor(color)
				net.WriteString(icon)
				net.WriteString(name)
			net.Broadcast()
		end
		table.insert(MarkerTable, {id, pos, time, color, icon, name})
		return id
	end

	function mrp.Compass_AddEntityMarker(ply, ent, players, time, color, icon, name)
		name = name or ""
		icon = icon or ""
		color = color or Color(255, 0, 0)
		players = players or (ply and ply:IsPlayer()) and team.GetPlayers(ply:Team())

		local id = #MarkerTable + 1
		if players then
			for k, v in pairs(players) do
				net.Start("mrp.Compass_AddMarker")
					net.WriteInt(id, 4)
					net.WriteBool(true) -- IsEntity
					net.WriteEntity(ent)
					net.WriteFloat(time)
					net.WriteColor(color)
					net.WriteString(icon)
					net.WriteString(name)
				net.Send(v)
			end
		else
			net.Start("mrp.Compass_AddMarker")
				net.WriteInt(id, 4)
				net.WriteBool(true) -- IsEntity
				net.WriteEntity(ent)
				net.WriteFloat(time)
				net.WriteColor(color)
				net.WriteString(icon)
				net.WriteString(name)
			net.Broadcast()
		end
		table.insert(MarkerTable, {id, pos, time, color, icon, name})
		return id
	end

	function Adv_Compass_RemoveMarker(markerID)
		for k, v in pairs(MarkerTable) do
			if markerID == v[1] then
				net.Start("mrp.Compass_RemoveMarker")
					net.WriteInt(markerID, 4)
				net.Broadcast()
				table.remove(MarkerTable, k)
			end
		end
	end

    resource.AddFile("resource/fonts/exo/Exo-Regular.ttf")

	local function v(arg)
		local arg = tonumber(arg)
		return math.Clamp(arg and arg or 255, 0, 255)
	end

	concommand.Add("mrp.Compass_spot", function(ply, cmd, args)
        local color = string.ToColor(v(args[1]).." "..v(args[2]).." "..v(args[3]).." "..v(args[4]))
        local tr = util.TraceLine({
            start = ply:EyePos(),
            endpos = ply:EyePos() + ply:EyeAngles():Forward() * 15748.03,
            filter = ply
        })
        local id
        local t = CurTime() + mrp.Compass_Settings.Spot_Duration
        if tr.Entity and !tr.HitWorld then
            id = mrp.Compass_AddEntityMarker(ply, tr.Entity, nil, t)
        else
            id = mrp.Compass_AddMarker(ply, tr.HitPos, nil, t)
        end
	end)

end

if CLIENT then
	local function loadFonts()
		local returnVal = hook.Call("mrp.Compass_loadFonts")
	end
	
	-- not cvars
	local cl_style_selected_str, compass_style

	local function updateCompassSettings()
		-- ternary operators sorry not sorry
		cl_style_selected_str = "squad"
		compass_style = mrp.Compass_Settings.Force_Server_Style
			and mrp.Compass_Settings.Styles["squad"]
			or {
				style = "squad",
                heading = true,		-- Whether or not the precise bearing is displayed. (Default: true)
                compassX = 0.5,		-- This value is multiplied by users screen width. (Default: 0.5)
                compassY = 0.9,		-- This value is multiplied by users screen height. (Default: 0.9)
                width = 0.25,		-- This value is multiplied by users screen width. (Default: 0.25)
                height = 0.03,		-- This value is multiplied by users screen height. (Default: 0.03)
                spacing = 2,		-- This value changes the spacing between lines. (Default: 2.5)
                ratio = 1.8,		-- The is the ratio of the size of the letters and numbers text. (Default: 1.8)
                offset = 0,			-- The number of degrees the compass will offset by. (Default: 0)
                maxMarkerSize = 1,	-- Maximum size of the marker, note that this affects scaling (Default: 1)
                minMarkerSize = 0.5, -- Minimum size of the marker, note that this affects scaling (Default: 0.5)
                color = Color(255, 255, 255) -- The color of the compass.
			}

        compass_style.style = "squad"
		loadFonts()
	end

	local function v(arg)
		local arg = tonumber(arg)
		return math.Clamp(arg and arg or 255, 0, 255)
	end

    updateCompassSettings()

	displayDistanceFontTable = displayDistanceFontTable or {}

	-- Function that handles fonts for the spot marker.
	local function markerScaleFunc(markerSizeScale)
		local returnVal
		local n = math.Round(markerSizeScale)
		if !oldMarkerSizeScale or oldMarkerSizeScale != n then
			if displayDistanceFontTable[n] then
				returnVal = displayDistanceFontTable[n].name
			else
				local newFontName = tostring("exo_compass_DDN_"..n)
				displayDistanceFontTable[n] = {
					name = newFontName,
					size = n
				}
				surface.CreateFont(newFontName, {
					font = "Exo",
					size = n,
					antialias = true
				})
				returnVal = displayDistanceFontTable[n].name
			end
			oldMarkerSizeScale = n
		else
			return displayDistanceFontTable[oldMarkerSizeScale].name
		end
		return returnVal
	end

	-- This table is just going to hold all of the generated fonts for later use.
	fontRatioChangeTable = fontRatioChangeTable or {}

	-- Doing this just so we could remake fonts and see ratio effects live. Kinda messy, sorry :/
	hook.Add("mrp.Compass_loadFonts", "mrp.Compass_loadFonts_addon", function()
		local h = compass_style.height
		local r = compass_style.ratio
		local ms = ScrH() * (compass_style.maxMarkerSize / 45)
		if r != mrp.Compass_oldFontRatio then
			for k, v in pairs(fontRatioChangeTable) do
				if "exo_compass_Numbers_"..r == v.numberName then
					mrp.Compass_oldFontRatio = r
					return v
				end
			end
			surface.CreateFont("exo_compass_Numbers_"..r, {
				font = "Exo",
				size = math.Round((ScrH() * h) / r),
				antialias = true
			})
			surface.CreateFont("exo_compass_Distance-Display-Numbers_"..r, {
				font = "Exo",
				size = (ScrH() * (h / r)) * compass_style.maxMarkerSize,
				antialias = true
			})
			surface.CreateFont("exo_compass_Letters", {
				font = "Exo",
				size = ScrH() * h,
				antialias = true
			})
			local t = {
				ratio = r,
				numberName = "exo_compass_Numbers_"..r
			}
			table.insert(fontRatioChangeTable, t)
			mrp.Compass_oldFontRatio = r
		end
	end)

	updateCompassSettings()

	----------------------------------------------------------------------------------------------------------------

	local cl_MarkerTable = cl_MarkerTable or {}

	local mat = Material("compass/compass_marker_01")
	local mat2 = Material("compass/compass_marker_02")

	net.Receive("mrp.Compass_AddMarker", function(len)
		local id = net.ReadInt(4)
		local isEntity = net.ReadBool()
		local pos = (!isEntity and net.ReadVector() or nil)
		local ent = (isEntity and net.ReadEntity() or nil)
		local time = net.ReadFloat()
		local color = net.ReadColor()
		local icon_mat = net.ReadString()
		local icon_name = net.ReadString()
		icon_mat = (icon_mat == "") and mat or Material(icon_mat)
		icon_name = icon_name or ""
		table.insert(cl_MarkerTable, {isEntity, (pos or (ent or nil)), time, color, id, icon_mat, icon_name})
	end)

	net.Receive("mrp.Compass_RemoveMarker", function(len)
		local id = net.ReadInt(4)
		for k, v in pairs(cl_MarkerTable) do
			if id == v[5] then
				table.remove(cl_MarkerTable, k)
			end
		end
	end)

	local function getMetricValue(units)
		local meters = math.Round(units * 0.01905)
		local kilometers = math.Round(meters / 1000, 2)
		return (kilometers > 1) and kilometers.."km" or meters.."m"
	end

	local function getTextSize(font, text)
		surface.SetFont(font)
		local w, h = surface.GetTextSize(text)
		return w, h
	end

	-- Basically draws lines with two masks that limit where the lines can be drawn
	-- Not entirely sure how this affects performance... yolo
	local function custom_compass_DrawLineFunc(mask1, mask2, line, color)
		render.ClearStencil()
		render.SetStencilEnable(true)
			render.SetStencilFailOperation(STENCILOPERATION_KEEP)
			render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
			render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)

			render.SetStencilWriteMask(1)
			render.SetStencilReferenceValue(1)

			surface.SetDrawColor(Color(0, 0, 0, 1))
			surface.DrawRect(mask1[1], mask1[2], mask1[3], mask1[4]) -- left
			surface.DrawRect(mask2[1], mask2[2], mask2[3], mask2[4]) -- right

			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
			render.SetStencilTestMask(1)

			surface.SetDrawColor(color)
			surface.DrawLine(line[1], line[2], line[3], line[4])
		render.SetStencilEnable(false)
	end

	local adv_compass_tbl = {
		[0] = "N",
		[45] = "NE",
		[90] = "E",
		[135] = "SE",
		[180] = "S",
		[225] = "SW",
		[270] = "W",
		[315] = "NW",
		[360] = "N"
	}

	hook.Add("HUDPaint", "HUDPaint_Compass", function()
		if ( IsValid(mrp.gui.mainMenu) ) then return end
		
		local ply = LocalPlayer()

        local ang = ply:GetAngles()
        local compassX, compassY = ScrW() * compass_style.compassX, ScrH() * compass_style.compassY
        local width, height = ScrW() * compass_style.width, ScrH() * compass_style.height
        local cl_spacing = compass_style.spacing
        local ratio = compass_style.ratio
        local color = compass_style.color
        local minMarkerSize = ScrH() * (compass_style.minMarkerSize / 45)
        local maxMarkerSize = ScrH() * (compass_style.maxMarkerSize / 45)
        local heading = compass_style.heading
        local offset = compass_style.offset

        spacing = (width * cl_spacing) / 360
        numOfLines = width / spacing
        fadeDistMultiplier = 1
        fadeDistance = (width / 2) / fadeDistMultiplier

        surface.SetFont("exo_compass_Numbers_"..ratio)


        local text = math.Round(360 - ((ang.y - offset) % 360))
        local font = "exo_compass_Numbers_"..ratio
        compassBearingTextW, compassBearingTextH = getTextSize(font, text)
        surface.SetFont(font)
        surface.SetTextColor(Color(255, 255, 255))
        surface.SetTextPos(compassX - compassBearingTextW / 2, 15)
        surface.DrawText(text)

        for i = math.Round(-ang.y) % 360, (math.Round(-ang.y) % 360) + numOfLines do
            -- DEBUGGING LINES
            -- local compassStart = compassX - width / 2
            -- local compassEnd = compassX + width / 2
            -- surface.SetDrawColor(Color(0, 255, 0))
            -- surface.DrawLine(compassStart, compassY, compassStart, compassY + height * 2)
            -- surface.DrawLine(compassEnd, compassY, compassEnd, compassY + height * 2)

            local x = ((compassX - (width / 2)) + (((i + ang.y) % 360) * spacing))
            local value = math.abs(x - compassX)
            local calc = 1 - ((value + (value - fadeDistance)) / (width / 2))
            local calculation = 255 * math.Clamp(calc, 0.001, 1)

            local i_offset = -(math.Round(i - offset - (numOfLines / 2))) % 360
            if i_offset % 15 == 0 and i_offset >= 0 then
                local a = i_offset
                local text = adv_compass_tbl[360 - (a % 360)] and adv_compass_tbl[360 - (a % 360)] or 360 - (a % 360)
                local font = type(text) == "string" and "exo_compass_Letters" or "exo_compass_Numbers_"..ratio
                local w, h = getTextSize(font, text)

                surface.SetDrawColor(Color(color.r, color.g, color.b, calculation))
                surface.SetTextColor(Color(color.r, color.g, color.b, calculation))
                surface.SetFont(font)

                surface.SetTextPos(x - w / 2, compassY + height * 0.55 - 950)
                surface.DrawText(text)
            end
        end
	end)
end