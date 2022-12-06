local HIGHLIGHT_COLOR = Color(255, 174, 0, 50)
local UNHIGHLIGHTED_COLOR = Color(100, 100, 100, 100)

local function GetHighlightColor()
	return Color(HIGHLIGHT_COLOR.r, HIGHLIGHT_COLOR.g, HIGHLIGHT_COLOR.b, HIGHLIGHT_COLOR.a)
end

local function GetUnhighlightedColor()
	return Color(UNHIGHLIGHTED_COLOR.r, UNHIGHLIGHTED_COLOR.g, UNHIGHLIGHTED_COLOR.b, UNHIGHLIGHTED_COLOR.a)
end

function NewDrawText(text, x, y, color, alignX, alignY, font, alpha)
	color = color or color_white

	return draw.TextShadow({
		text = text,
		font = "mrp-Font25",
		pos = {x, y},
		color = color,
		xalign = alignX or TEXT_ALIGN_LEFT,
		yalign = alignY or TEXT_ALIGN_LEFT
	}, 1, alpha or (color.a * 0.575))
end

mrp.wepSelect = mrp.wepSelect or {}
mrp.wepSelect.index = mrp.wepSelect.index or 1
mrp.wepSelect.deltaIndex = mrp.wepSelect.deltaIndex or mrp.wepSelect.index
mrp.wepSelect.infoAlpha = mrp.wepSelect.infoAlpha or 0
mrp.wepSelect.alpha = mrp.wepSelect.alpha or 0
mrp.wepSelect.alphaDelta = mrp.wepSelect.alphaDelta or mrp.wepSelect.alpha
mrp.wepSelect.fadeTime = mrp.wepSelect.fadeTime or 0
mrp.wepSelect.weapons = mrp.wepSelect.weapons or {}
mrp.wepSelect.customWN = {
	--["mg_scharlie"] = "Scar 17"
}

hook.Add( "HUDShouldDraw", "mrp.wepSelect_ShouldDraw", function(name)
	if (name == "CHudWeaponSelection") then
		return false
	end
end)

hook.Add( "HUDPaint", "mrp.wepSelect_HUDPaint", function()
	local frameTime = FrameTime()

	mrp.wepSelect.alphaDelta = Lerp(frameTime * 10, mrp.wepSelect.alphaDelta, mrp.wepSelect.alpha)

	local fraction = mrp.wepSelect.alphaDelta

	if (fraction > 0.01) then
		local x, y = 100, ScrH() * .4
		local spacing = ScrH() / 380
		local radius = 240 * mrp.wepSelect.alphaDelta
		local shiftX = ScrW() * .02

		mrp.wepSelect.deltaIndex = Lerp(frameTime * 12, mrp.wepSelect.deltaIndex, mrp.wepSelect.index)

		local index = mrp.wepSelect.deltaIndex

		if (!mrp.wepSelect.weapons[mrp.wepSelect.index]) then
			mrp.wepSelect.index = #mrp.wepSelect.weapons
		end

		for i = 1, #mrp.wepSelect.weapons do
			local theta = (i - index) * 0.1

			local color2 = i == mrp.wepSelect.index and GetHighlightColor() or GetUnhighlightedColor()
			color2.a = (color2.a - math.abs(theta * 3) * color2.a) * fraction

			local color3 = ColorAlpha(
				i == mrp.wepSelect.index and Color(255, 255, 255, 255) or Color(255, 255, 255, 255),
				(255 - math.abs(theta * 3) * 255) * fraction
			)

			local ebatTextKruto = i == mrp.wepSelect.index and 10 or 10

			local lastY = 0

			if (mrp.wepSelect.markup and (i < mrp.wepSelect.index or i == 1)) then
				if (mrp.wepSelect.index != 1) then
					local _, h = mrp.wepSelect.markup:Size()
					lastY = h * fraction
				end

				if (i == 1 or i == mrp.wepSelect.index - 1) then
					mrp.wepSelect.infoAlpha = Lerp(frameTime * 3, mrp.wepSelect.infoAlpha, 255)
					mrp.wepSelect.markup:Draw(x + 6 + shiftX, y + 30, 0, 0, mrp.wepSelect.infoAlpha * fraction)
				end
			end

			surface.SetFont("mrp-Font25")
			local weaponName = mrp.wepSelect.customWN[mrp.wepSelect.weapons[i]:GetClass()] or mrp.wepSelect.weapons[i]:GetPrintName():upper()
			local _, ty = surface.GetTextSize(weaponName)
			local scale = 1 - math.abs(theta * 2)

			local matrix = Matrix()
			matrix:Translate(Vector(
				shiftX + x + math.cos(theta * spacing + math.pi) * radius + radius,
				y + lastY + math.sin(theta * spacing + math.pi) * radius - ty / 2,
				1))
			matrix:Scale(Vector(1, 1, 0) * scale)

			cam.PushModelMatrix(matrix)
				NewDrawText(weaponName, ebatTextKruto, ty / 2 - 1, color3, 0, TEXT_ALIGN_CENTER, "mrp-Font25")
				if i > mrp.wepSelect.index - 4 and i < mrp.wepSelect.index + 4 then
				surface.SetTexture(surface.GetTextureID("vgui/gradient-l"))
				surface.SetDrawColor(color2)
				surface.DrawTexturedRect(0, 0, 400, ScreenScale(16))
				end
			cam.PopModelMatrix()
		end

		if (mrp.wepSelect.fadeTime < CurTime() and mrp.wepSelect.alpha > 0) then
			mrp.wepSelect.alpha = 0
		end
	elseif (#mrp.wepSelect.weapons > 0) then
		mrp.wepSelect.weapons = {}
	end
end)

function OnIndexChanged(weapon)
	mrp.wepSelect.alpha = 1
	mrp.wepSelect.fadeTime = CurTime() + 5
	mrp.wepSelect.markup = nil

	if (IsValid(weapon)) then
		local instructions = weapon.Instructions
		local text = ""

		local source, pitch = hook.Run("WeaponCycleSound")
		LocalPlayer():EmitSound(source or "common/talk.wav", 50, pitch or 180)
	end
end

hook.Add( "PlayerBindPress", "mrp.wepSelect_PlayerBindPress", function(ply, bind, pressed)
	bind = bind:lower()

	if (!pressed or !bind:find("invprev") and !bind:find("invnext")
	and !bind:find("slot") and !bind:find("attack")) then
		return
	end

	local currentWeapon = ply:GetActiveWeapon()
	local bValid = IsValid(currentWeapon)
	local bTool

	if (ply:InVehicle() or (bValid and currentWeapon:GetClass() == "weapon_physgun" and ply:KeyDown(IN_ATTACK))) then
		return
	end

	if (bValid and currentWeapon:GetClass() == "gmod_tool") then
		local tool = ply:GetTool()
		bTool = tool and (tool.Scroll != nil)
	end

	mrp.wepSelect.weapons = {}

	for _, v in pairs(ply:GetWeapons()) do
		mrp.wepSelect.weapons[#mrp.wepSelect.weapons + 1] = v
	end

	if (bind:find("invprev") and !bTool) then
		local oldIndex = mrp.wepSelect.index
		mrp.wepSelect.index = math.min(mrp.wepSelect.index + 1, #mrp.wepSelect.weapons)

		if (mrp.wepSelect.alpha == 0 or oldIndex != mrp.wepSelect.index) then
			OnIndexChanged(mrp.wepSelect.weapons[mrp.wepSelect.index])
		end

		return true
	elseif (bind:find("invnext") and !bTool) then
		local oldIndex = mrp.wepSelect.index
		mrp.wepSelect.index = math.max(mrp.wepSelect.index - 1, 1)

		if (mrp.wepSelect.alpha == 0 or oldIndex != mrp.wepSelect.index) then
			OnIndexChanged(mrp.wepSelect.weapons[mrp.wepSelect.index])
		end

		return true
	elseif (bind:find("slot")) then
		mrp.wepSelect.index = math.Clamp(tonumber(bind:match("slot(%d)")) or 1, 1, #mrp.wepSelect.weapons)
		OnIndexChanged(mrp.wepSelect.weapons[mrp.wepSelect.index])

		return true
	elseif (bind:find("attack") and mrp.wepSelect.alpha > 0) then
		local weapon = mrp.wepSelect.weapons[mrp.wepSelect.index]

		if (IsValid(weapon)) then
			LocalPlayer():EmitSound("HL2Player.Use")

			input.SelectWeapon(weapon)
			mrp.wepSelect.alpha = 0
		end

		return true
	end
end)

hook.Add( "Think", "mrp.wepSelect_Think", function()
	local ply = LocalPlayer()
	if (!IsValid(ply) or !ply:Alive()) then
		mrp.wepSelect.alpha = 0
	end
end)

hook.Add( "ScoreboardShow", "mrp.wepSelect_ScoreboardShow", function()
	mrp.wepSelect.alpha = 0
end)