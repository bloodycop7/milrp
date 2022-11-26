for i = 15, 300 do
    surface.CreateFont("mrp-Font"..tostring(i), {
        font = "Neusa Next Pro Light",
        size = i,
        shadow = true,
        additive = true,
        antialias = true,
        extended = true
    })

    surface.CreateFont("mrp-Font"..tostring(i).."-Shadow", {
        font = "Neusa Next Pro Light",
        size = i,
        shadow = true,
        antialias = true,
        additive = true,
        extended = true
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

function GM:DefineSettings()
    mrp.DefineSetting("nightvision_enabled", {name="Enable Nightvision", category="HUD", type="tickbox", default=false})
    mrp.DefineSetting("bodycam_mode", {name="Body Cam Mode Enabled", category="HUD", type="tickbox", default=false})
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