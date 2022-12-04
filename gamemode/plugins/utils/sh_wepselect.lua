
PLUGIN.name = "Weapon Select"
PLUGIN.author = "Chessnut"
PLUGIN.desc = "A replacement for the default weapon selection."

mrp.wepSelect = mrp.wepSelect or {}

if (CLIENT) then
	mrp.wepSelect.index = mrp.wepSelect.index or 1
	mrp.wepSelect.deltaIndex = mrp.wepSelect.deltaIndex or mrp.wepSelect.index
	mrp.wepSelect.infoAlpha = mrp.wepSelect.infoAlpha or 0
	mrp.wepSelect.alpha = mrp.wepSelect.alpha or 0
	mrp.wepSelect.alphaDelta = mrp.wepSelect.alphaDelta or mrp.wepSelect.alpha
	mrp.wepSelect.fadeTime = mrp.wepSelect.fadeTime or 0

	local matrixScale = Vector(1, 1, 0)

	function PLUGIN:HUDShouldDraw(name)
		if (name == "CHudWeaponSelection") then
			return false
		end
	end

	function PLUGIN:HUDPaint()
		local frameTime = FrameTime()

		mrp.wepSelect.alphaDelta = Lerp(frameTime * 10, mrp.wepSelect.alphaDelta, mrp.wepSelect.alpha)

		local fraction = mrp.wepSelect.alphaDelta

		if (fraction > 0.01) then
			local x, y = ScrW() * 0.5, ScrH() * 0.5
			local spacing = math.pi * 0.85
			local radius = 240 * mrp.wepSelect.alphaDelta
			local shiftX = ScrW() * .02

			mrp.wepSelect.deltaIndex = Lerp(frameTime * 12, mrp.wepSelect.deltaIndex, mrp.wepSelect.index)

			local weapons = LocalPlayer():GetWeapons()
			local index = mrp.wepSelect.deltaIndex

			if (!weapons[mrp.wepSelect.index]) then
				mrp.wepSelect.index = #weapons
			end

			for i = 1, #weapons do
				local theta = (i - index) * 0.1
				local color = ColorAlpha(
					i == mrp.wepSelect.index and mrp.Config.BaseColor or color_white,
					(255 - math.abs(theta * 3) * 255) * fraction
				)

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
				local weaponName = string.upper(weapons[i]:GetPrintName())
				local _, ty = surface.GetTextSize(weaponName)
				local scale = 1 - math.abs(theta * 2)

				local matrix = Matrix()
				matrix:Translate(Vector(
					shiftX + x + math.cos(theta * spacing + math.pi) * radius + radius,
					y + lastY + math.sin(theta * spacing + math.pi) * radius - ty / 2 ,
					1))
				matrix:Scale(matrixScale * scale)

				cam.PushModelMatrix(matrix)
					draw.DrawText(weaponName, "mrp-Font25", 2, ty / 2, color, TEXT_ALIGN_LEFT)
				cam.PopModelMatrix()
			end

			if (mrp.wepSelect.fadeTime < CurTime() and mrp.wepSelect.alpha > 0) then
				mrp.wepSelect.alpha = 0
			end
		end
	end

	function OnIndexChanged(weapon)
		mrp.wepSelect.alpha = 1
		mrp.wepSelect.fadeTime = CurTime() + 5
		mrp.wepSelect.markup = nil

		if (IsValid(weapon)) then
			local instructions = weapon.Instructions
			local text = ""

			if (instructions != nil and instructions:find("%S")) then
				local color = mrp.Config.BaseColor
				text = text .. string.format(
					"<font=mrp-Font21><color=%d,%d,%d>%s</font></color>\n%s\n",
					color.r, color.g, color.b, "Instructions", instructions
				)
			end

			if (text != "") then
				mrp.wepSelect.markup = markup.Parse("<font=mrp-Font21>"..text, ScrW() * 0.3)
				mrp.wepSelect.infoAlpha = 0
			end

			local source, pitch = hook.Run("WeaponCycleSound")
			LocalPlayer():EmitSound(source or "common/talk.wav", 50, pitch or 180)
		end
	end

	function PLUGIN:PlayerBindPress(client, bind, pressed)
		bind = bind:lower()

		if (!pressed or !bind:find("invprev") and !bind:find("invnext")
		and !bind:find("slot") and !bind:find("attack")) then
			return
		end

		local currentWeapon = client:GetActiveWeapon()
		local bValid = IsValid(currentWeapon)
		local bTool

		if (client:InVehicle() or (bValid and currentWeapon:GetClass() == "weapon_physgun" and client:KeyDown(IN_ATTACK))) then
			return
		end

		if (bValid and currentWeapon:GetClass() == "gmod_tool") then
			local tool = client:GetTool()
			bTool = tool and (tool.Scroll != nil)
		end

		local weapons = client:GetWeapons()

		if (bind:find("invprev") and !bTool) then
			local oldIndex = mrp.wepSelect.index
			mrp.wepSelect.index = math.min(mrp.wepSelect.index + 1, #weapons)

			if (mrp.wepSelect.alpha == 0 or oldIndex != mrp.wepSelect.index) then
				OnIndexChanged(weapons[mrp.wepSelect.index])
			end

			return true
		elseif (bind:find("invnext") and !bTool) then
			local oldIndex = mrp.wepSelect.index
			mrp.wepSelect.index = math.max(mrp.wepSelect.index - 1, 1)

			if (mrp.wepSelect.alpha == 0 or oldIndex != mrp.wepSelect.index) then
				OnIndexChanged(weapons[mrp.wepSelect.index])
			end

			return true
		elseif (bind:find("slot")) then
			mrp.wepSelect.index = math.Clamp(tonumber(bind:match("slot(%d)")) or 1, 1, #weapons)
			OnIndexChanged(weapons[mrp.wepSelect.index])

			return true
		elseif (bind:find("attack") and mrp.wepSelect.alpha > 0) then
			local weapon = weapons[mrp.wepSelect.index]

			if (IsValid(weapon)) then
				LocalPlayer():EmitSound(hook.Run("WeaponSelectSound", weapon) or "HL2Player.Use")

				input.SelectWeapon(weapon)
				mrp.wepSelect.alpha = 0
			end

			return true
		end
	end

	function PLUGIN:Think()
		local client = LocalPlayer()
		if (!IsValid(client) or !client:Alive()) then
			mrp.wepSelect.alpha = 0
		end
	end

	function PLUGIN:ScoreboardShow()
		mrp.wepSelect.alpha = 0
	end
end
