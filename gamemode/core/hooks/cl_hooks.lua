for i = 15, 300 do
    surface.CreateFont("mrp-Font"..tostring(i), {
        font = "Montserrat",
        size = i,
        antialias = true,
        shadow = true,
        weight = 500,
        additive = true,
        blursize = 0.5,
    })

    surface.CreateFont("mrp-Font"..tostring(i).."-Shadow", {
        font = "Montserrat",
        size = i,
        antialias = true,
        weight = 500,
        shadow = true,
        additive = true,
        blursize = 0.5,
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

function GM:PlayerStartVoice(ply)
    if ( IsValid(g_VoicePanelList) ) then
        g_VoicePanelList:Remove()
    end
end

net.Receive("mrpNotify", function(len)
	local message = net.ReadString()
    local col = net.ReadColor()

	if not LocalPlayer() or not LocalPlayer().Notify then
		return
	end
	
	LocalPlayer():Notify(message, col)
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

net.Receive("PlayerMoreFPS", function()
    RunConsoleCommand("mat_queue_mode", "-1")
    RunConsoleCommand("cl_threaded_bone_setup", "1")
    RunConsoleCommand("r_shadows", "1")
    RunConsoleCommand("r_dynamic", "1")
end)