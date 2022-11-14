for i = 15, 300 do
    surface.CreateFont("mrp-Font"..tostring(i), {
        font = "Eurostile",
        size = i,
        antialias = true,
        shadow = true,
        weight = 500,
        blursize = 0.5,
    })
    
    surface.CreateFont("mrp-Font"..tostring(i).."-Shadow", {
        font = "Eurostile",
        size = i,
        antialias = true,
        weight = 500,
        shadow = true,
        blursize = 0.5,
    })
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

	if not LocalPlayer() or not LocalPlayer().Notify then
		return
	end
	
	LocalPlayer():Notify(message)
end)