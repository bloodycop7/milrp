for i = 15, 300 do
    surface.CreateFont("mrp-Font"..tostring(i), {
        font = "Consolas",
        size = i,
        antialias = true,
		shadow = true,
    })

    surface.CreateFont("mrp-Font"..tostring(i).."-Shadow", {
        font = "Consolas",
        size = i,
        antialias = true,
		shadow = true,
    })
end

function notification.AddLegacy(text, otherone, _othertwo)
    LocalPlayer():Notify(tostring(text))
end

net.Receive("mrpChatNetMessage", function(len)
	local id = net.ReadUInt(8)
	local message = net.ReadString()
	local target = net.ReadUInt(8)
	local chatClass = mrp.chatClasses[id]
	local plyTarget = Entity(target)

	if target == 0 then
		chatClass(message)
	elseif IsValid(plyTarget) then
		chatClass(message, plyTarget)
	end
end)

function GM:ForceDermaSkin()
    return "milrp"
end

function GM:ScoreboardShow()
    militaryscorboard = vgui.Create("mrpScoreboard")
end

function GM:ScoreboardHide()
    militaryscorboard:Remove()
end

net.Receive("mrpNotify", function(len)
	local message = net.ReadString()
    local col = net.ReadColor()

	if not LocalPlayer() or not LocalPlayer().Notify then
		return
	end
	
	LocalPlayer():Notify(message, col)
end)

net.Receive("mrpCaptionAdd", function(len)
    local sayer = net.ReadString()
	local text = net.ReadString()
    local col = net.ReadColor()
    local msgcolor = net.ReadColor()

	if not LocalPlayer() or not LocalPlayer().AddCaption then
		return
	end
	
	LocalPlayer():AddCaption({
        speaker = sayer, 
        message = text, 
        speakercol = col, 
        msgcol = msgcolor
    })
end)

function GM:OnContextMenuOpen()
	if LocalPlayer():Team() == 0 or not LocalPlayer():Alive() then return end

    if IsValid(g_ContextMenu) and not g_ContextMenu:IsVisible() then
        g_ContextMenu:Open()
        menubar.ParentTo(g_ContextMenu)

        hook.Call("ContextMenuOpened", self)
    end
end

function GM:OnContextMenuClose()
	if IsValid(g_ContextMenu) then 
		g_ContextMenu:Close()
		hook.Call("ContextMenuClosed", self)
	end
end

hook.Add("OnReloaded", "SettingsReset", function()
    if not ( table.IsEmpty(mrp.Settings) ) then
        table.Empty(mrp.Settings)
    end
    hook.Run("DefineSettings")
end)

hook.Add("Think", "VoiceIconAlwaysOff", function()
    RunConsoleCommand("mp_show_voice_icons", "0")
end)

local blur = Material("pp/blurscreen")

function mrp.DrawBlur(panel, amount, passes, alpha)
    amount = amount or 5

    surface.SetMaterial(blur)
    surface.SetDrawColor(255, 255, 255, alpha or 255)

    local x, y = panel:LocalToScreen(0, 0)

    for i = -(passes or 0.2), 1, 0.2 do
        -- Do things to the blur material to make it blurry.
        blur:SetFloat("$blur", i * amount)
        blur:Recompute()

        -- Draw the blur material over the screen.
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
    end

end

function mrp.DrawBlurAt(x, y, width, height, amount, passes, alpha)
    amount = amount or 5

    surface.SetMaterial(blur)
    surface.SetDrawColor(255, 255, 255, alpha or 255)

    local scrW, scrH = ScrW(), ScrH()
    local x2, y2 = x / scrW, y / scrH
    local w2, h2 = (x + width) / scrW, (y + height) / scrH

    for i = -(passes or 0.2), 1, 0.2 do
        blur:SetFloat("$blur", i * amount)
        blur:Recompute()

        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRectUV(x, y, width, height, x2, y2, w2, h2)
    end
end

net.Receive("mrpCinematicMessage", function()
	local title = net.ReadString()

	mrp.CinematicIntro = true
	mrp.CinematicTitle = title
end)

local loweredAngles = Angle(35, -40, -25)

local customAngles = {
    ["mg_m9"] = Angle(0, -10, -5),
    ["mg_357"] = Angle(0, 0, -5),
    ["mg_p320"] = Angle(0, 0, -5),
    ["mg_deagle"] = Angle(0, 0, -5),
    ["mg_glock"] = Angle(0, 0, -5),
    ["mg_cususpmatch"] = Angle(0, 0, -5),
    ["mg_makarov"] = Angle(0, 0, -5),
    ["mg_m1911"] = Angle(0, 0, -5)
}
function GM:CalcViewModelView(weapon, viewmodel, oldEyePos, oldEyeAng, eyePos, eyeAngles)
	if not IsValid(weapon) then return end

	local vm_origin, vm_angles = eyePos, eyeAngles

	do
		local lp = LocalPlayer()
		local raiseTarg = 0

		if !lp:IsWeaponRaised() then
			raiseTarg = 100
		end

		local frac = (lp.raiseFraction or 0) / 100
		local rot = ( weapon.LowerAngles or customAngles[weapon:GetClass()] ) or loweredAngles

		vm_angles:RotateAroundAxis(vm_angles:Up(), rot.p * frac)
		vm_angles:RotateAroundAxis(vm_angles:Forward(), rot.y * frac)
		vm_angles:RotateAroundAxis(vm_angles:Right(), rot.r * frac)

		lp.raiseFraction = Lerp(FrameTime() * 2, lp.raiseFraction or 0, raiseTarg)
	end

	--The original code of the hook.
	do
		local func = weapon.GetViewModelPosition
		if (func) then
			local pos, ang = func( weapon, eyePos*1, eyeAngles*1 )
			vm_origin = pos or vm_origin
			vm_angles = ang or vm_angles
		end

		func = weapon.CalcViewModelView
		if (func) then
			local pos, ang = func( weapon, viewModel, oldEyePos*1, oldEyeAngles*1, eyePos*1, eyeAngles*1 )
			vm_origin = pos or vm_origin
			vm_angles = ang or vm_angles
		end
	end

	return vm_origin, vm_angles
end