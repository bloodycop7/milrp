mrp.chatCommands = mrp.chatCommands or {}
mrp.chatClasses = mrp.chatClasses or {}

mrp.Config.RankColours = {
	["superadmin"] = Color(201, 15, 12),
	["communitymanager"] = Color(84, 204, 5),
	["leadadmin"] = Color(128, 0, 128),
	["admin"] = Color(34, 88, 216),
	["moderator"] = Color(34, 88, 216),
	["donator"] = Color(212, 185, 9)
}


function mrp.RegisterChatCommand(name, cmdData)
	if not cmdData.adminOnly then cmdData.adminOnly = false end
	if not cmdData.leadAdminOnly then cmdData.leadAdminOnly = false end
	if not cmdData.superAdminOnly then cmdData.superAdminOnly = false end
	if not cmdData.description then cmdData.description = "" end
	if not cmdData.requiresArg then cmdData.requiresArg = false end
	if not cmdData.requiresAlive then cmdData.requiresAlive = false end

    mrp.chatCommands[name] = cmdData
end

if SERVER then
	util.AddNetworkString("mrpChatNetMessage")
	function meta:SendChatClassMessage(id, message, target)
		net.Start("mrpChatNetMessage")
		net.WriteUInt(id, 8)
		net.WriteString(message)
		if target then
			net.WriteUInt(target:EntIndex(), 8)
		end
		net.Send(self)
	end
else
	function mrp.RegisterChatClass(id, onReceive)
		mrp.chatClasses[id] = onReceive
	end
end

local oocCol = color_white
local oocTagCol = Color(200, 0, 0)
local yellCol = Color(255, 140, 0)
local whisperCol = Color(65, 105, 225)
local infoCol = Color(135, 206, 250)
local talkCol = Color(255, 255, 100)
local radioCol = Color(55, 146, 21)
local pmCol = Color(45, 154, 6)

local oocCommand = {
	description = "Talk out of character globally.",
	requiresArg = true,
	onRun = function(ply, arg, rawText)
		if mrp.OOCClosed then
			return ply:Notify("OOC chat has been suspsended and will return shortly.")	
		end

		for v,k in pairs(player.GetAll()) do
			k:SendChatClassMessage(2, rawText, ply)
		end
		
		hook.Run("ProcessOOCMessage", rawText)
	end
}

mrp.RegisterChatCommand("/ooc", oocCommand)
mrp.RegisterChatCommand("//", oocCommand)

local radiocommand = {
	description = "Set your Radio Channel",
	requiresArg = true,
	onRun = function(ply, arg, rawText)
		local number = tonumber(math.Clamp(math.Round(arg[1], 1), 0, 999))

		if ( number ) then
			ply:SetSyncVar(SYNC_RCHANNEL, number, true)
			ply:Notify("You changed your TAC to "..number)
		end
	end,
}

mrp.RegisterChatCommand("/src", radiocommand)
mrp.RegisterChatCommand("/setrc", radiocommand)

mrp.RegisterChatCommand("/radiotoggle", {
	description = "Turn on/off your radio.",
	requiresArg = false,
	onRun = function(ply, arg, rawText)
		ply:SetSyncVar(SYNC_RADIOENABLED, (!ply:GetSyncVar(SYNC_RADIOENABLED, false)), true)

		if ( ply.nextRadioAttempt or 0 ) < CurTime() then
			if ( ply:GetSyncVar(SYNC_RADIOENABLED, false) ) then
				ply:Notify("You have turned your radio on!")
			else
				ply:Notify("You have turned your radio off!")
			end
		end
	end
})

if ( SERVER ) then
	util.AddNetworkString("MRPAnnouncement")
end

mrp.RegisterChatCommand("/announce", {
	description = "Announce something to the whole server.",
	requiresArg = false,
	adminOnly = true,
	onRun = function(ply, arg, rawText)
		if ( rawText != "" ) then
			net.Start("MRPAnnouncement")
				net.WriteString(rawText)
			net.Broadcast()
		end
	end
})

mrp.RegisterChatCommand("/announcement", {
	description = "Announce something to the whole server.",
	requiresArg = false,
	adminOnly = true,
	onRun = function(ply, arg, rawText)
		if ( rawText != "" ) then
			net.Start("MRPAnnouncement")
				net.WriteString(rawText)
			net.Broadcast()
		end
	end
})

mrp.RegisterChatCommand("/forceradiooff", {
	description = "Turn off someone's radio.",
	requiresArg = true,
	adminOnly = true,
	onRun = function(ply, arg, rawText)
        if not ( ply:IsAdmin() ) then return end
		local trg = mrp:FindPlayer(arg[1])
		local time = tonumber(arg[2])
		local mtime
        time = math.Clamp(time, 1, 10)
		if ( time ) then
			mtime = time * 60 -- 1 = 60 seconds
		end
		if ( ply:IsAdmin() ) then
			if ( IsValid(trg) ) then
				trg.radioOn = false

				if ( time ) then
					ply:Notify("You have turned "..trg:Nick().."'s radio off for "..time.. " minutes!")
					trg.nextRadioAttempt = CurTime() + mtime
					trg:Notify("Your radio was turned off for "..time.. " minutes!")
				else
					ply:Notify("You have turned "..trg:Nick().."'s radio off!")
					trg:Notify("Your radio was turned off!")
				end
			end
		end
	end
})

mrp.RegisterChatCommand("/forcechangetac", {
	description = "Change someone's Tac.",
	requiresArg = true,
	superAdminOnly = true,
	onRun = function(ply, arg, rawText)
        if not ( ply:IsSuperAdmin() ) then return end

		local trg = mrp:FindPlayer(arg[1])
		local tac = tonumber(arg[2])
        if ( IsValid(trg) ) then
            trg:SetSyncVar(SYNC_RCHANNEL, tac)

            ply:Notify("You have changed "..trg:Nick().."'s TAC to "..tac.."!")
            trg:Notify("Your TAC was changed to "..tac.."!")
        end
	end
})

local loocCommand = {
	description = "Talk out of character locally.",
	requiresArg = true,
	onRun = function(ply, arg, rawText)
		for v,k in pairs(player.GetAll()) do
			if (ply:GetPos() - k:GetPos()):LengthSqr() <= (300 ^ 2) then 
				k:SendChatClassMessage(3, rawText, ply)
			end
		end

		hook.Run("ProcessOOCMessage", rawText)
	end
}

mrp.RegisterChatCommand("/looc", loocCommand)
mrp.RegisterChatCommand("//.", loocCommand)

local pmCommand = {
	description = "Directly messages the player specified.",
	requiresArg = true,
	onRun = function(ply, arg, rawText)
		local name = arg[1]
		local message = string.sub(rawText, (string.len(name) + 2))
		message = string.Trim(message)

		if not message or message == "" then
			return ply:Notify("Invalid argument.")
		end

		local plyTarget = mrp:FindPlayer(name)

		if plyTarget and ply != plyTarget then
			plyTarget:SendChatClassMessage(4, message, ply)
			plyTarget.PMReply = ply

			ply:SendChatClassMessage(5, message, ply)
		else
			return ply:Notify("Could not find player: "..tostring(name))
		end
	end
}

mrp.RegisterChatCommand("/pm", pmCommand)

local yellCommand = {
	description = "Yell in character.",
	requiresArg = true,
	requiresAlive = true,
	onRun = function(ply, arg, rawText)
		rawText = hook.Run("ChatClassMessageSend", 6, rawText, ply) or rawText

		for v,k in pairs(player.GetAll()) do
			if (ply:GetPos() - k:GetPos()):LengthSqr() <= (550 ^ 2) then 
				k:SendChatClassMessage(6, rawText, ply)
			end
		end
	end
}

mrp.RegisterChatCommand("/y", yellCommand)

local whisperCommand = {
	description = "Whisper in character.",
	requiresArg = true,
	requiresAlive = true,
	onRun = function(ply, arg, rawText)
		rawText = hook.Run("ChatClassMessageSend", 7, rawText, ply) or rawText

		for v,k in pairs(player.GetAll()) do
			if (ply:GetPos() - k:GetPos()):LengthSqr() <= (90 ^ 2) then 
				k:SendChatClassMessage(7, rawText, ply)
			end
		end
	end
}

mrp.RegisterChatCommand("/w", whisperCommand)

local replyCommand = {
	description = "Replies to the last player who directly messaged you.",
	requiresArg = true,
	onRun = function(ply, arg, rawText)
		local message = rawText

		if not message or message == "" then
			return ply:Notify("Invalid argument.")
		end

		if not ply.PMReply or not IsValid(ply.PMReply) then
			return ply:Notify("Target not found.")
		end

		local plyTarget = ply.PMReply

		if plyTarget and ply != plyTarget then
			plyTarget:SendChatClassMessage(4, message, ply)
			plyTarget.PMReply = ply

			ply:SendChatClassMessage(5, message, ply)
		end
	end
}

mrp.RegisterChatCommand("/reply", replyCommand)

local radioCommand = {
	description = "Send a radio message to all units.",
	requiresArg = true,
	requiresAlive = true,
	onRun = function(ply, arg, rawText)
		rawText = hook.Run("ChatClassMessageSend", 8, rawText, ply) or rawText

		if ply:IsSoldier() then
			for v,k in pairs(player.GetAll()) do
				if ( k:GetSyncVar(SYNC_RCHANNEL, 0) == ply:GetSyncVar(SYNC_RCHANNEL, 0) ) then
					k:SendChatClassMessage(8, rawText, ply)
				end
			end
		elseif ( ply:IsTerrorist() ) then
			for v,k in pairs(player.GetAll()) do
				if ( k:GetSyncVar(SYNC_RCHANNEL, 0) == ply:GetSyncVar(SYNC_RCHANNEL, 0) ) then
					k:SendChatClassMessage(8, rawText, ply)
				end
			end
		else
			hook.Run("RadioMessageFallback", ply, rawText)
		end
	end
}

mrp.RegisterChatCommand("/radio", radioCommand)
mrp.RegisterChatCommand("/r", radioCommand)

local itCommand = {
	description = "Perform an action from a third party.",
	requiresArg = true,
	requiresAlive = true,
	onRun = function(ply, arg, rawText)
		for v,k in pairs(player.GetAll()) do
			if (ply:GetPos() - k:GetPos()):LengthSqr() <= (300 ^ 2) then 
				k:SendChatClassMessage(10, rawText, ply)
			end
		end
	end
}

mrp.RegisterChatCommand("/it", itCommand)

local eventCommand = {
	description = "Sends a global chat message to all players. Only for use in events.",
	leadAdminOnly = true,
	requiresArg = true,
	onRun = function(ply, arg, rawText)
		if ply:GetUserGroup() == "leadadmin" then
			return
		end
		
		for v,k in pairs(player.GetAll()) do
			k:SendChatClassMessage(14, rawText, ply)
		end
	end
}

mrp.RegisterChatCommand("/event", eventCommand)

if CLIENT then
	local talkCol = Color(255, 255, 100)
	local infoCol = Color(135, 206, 250)
	local oocCol = color_white
	local oocTagCol = Color(200, 0, 0)
	local yellCol = Color(255, 140, 0)
	local whisperCol = Color(65, 105, 225)
	local infoCol = Color(135, 206, 250)
	local talkCol = Color(255, 255, 100)
	local radioCol = Color(65, 120, 200)
	local pmCol = Color(45, 154, 6)
	local acCol = Color(0, 235, 0, 255)
	local eventCol = Color(255, 69, 0)
	local fallbackRankCol = Color(211, 211, 211)
	local rankCols = mrp.Config.RankColours

	mrp.RegisterChatClass(1, function(message, speaker)
		message = hook.Run("ProcessICChatMessage", speaker, message) or message

		--chat.AddText(speaker, talkCol, " says: ", message)

        speaker:AddCaption({
			speaker = speaker:Nick(), 
			message = message, 
			speakercol = Color(0, 0, 0), 
			msgcol = color_white,
			dots = true
		})
	end)

	local strFind = string.find
	mrp.RegisterChatClass(2, function(message, speaker)
		mrp.customChatPlayer = speaker

		--chat.AddText(oocTagCol, "[OOC] ", (rankCols[speaker:IsIncognito() and "user" or speaker:GetUserGroup()] or fallbackRankCol), speaker:Nick(), oocCol, ": ", message)
        speaker:AddCaption({
			speaker = "[OOC] "..speaker:Nick(), 
			message = message, 
			speakercol = (rankCols[speaker:IsIncognito() and "user" or speaker:GetUserGroup()] or fallbackRankCol),
			msgcol = oocCol,
			dots = true
		})
	end)

	mrp.RegisterChatClass(3, function(message, speaker)
		mrp.customChatPlayer = speaker
		--chat.AddText(oocTagCol, "[LOOC] ", (rankCols[speaker:IsIncognito() and "user" or speaker:GetUserGroup()] or fallbackRankCol), speaker:Nick(), (team.GetColor(speaker:Team())), " (", speaker:Name(), ")", oocCol, ": ",  message)

        speaker:AddCaption({
			speaker = "[LOOC] "..speaker:Nick(), 
			message = message, 
			speakercol = (rankCols[speaker:IsIncognito() and "user" or speaker:GetUserGroup()] or fallbackRankCol),
			msgcol = oocCol,
			dots = true
		})
	end)

	mrp.RegisterChatClass(4, function(message, speaker)
		--chat.AddText(pmCol, "[PM] ", speaker:Nick(), (team.GetColor(speaker:Team())), " (", speaker:Name(), ")", pmCol, ": ", message)

        speaker:AddCaption({
			speaker = "[PM] "..speaker:Nick(), 
			message = message, 
			speakercol = pmCol, 
			msgcol = pmCol,
			dots = true
		})
	end)

	mrp.RegisterChatClass(5, function(message, speaker)
		surface.PlaySound("buttons/blip1.wav")
		--chat.AddText(pmCol, "[PM SENT] ", speaker:Nick(), (team.GetColor(speaker:Team())), " (", speaker:Name(), ")", pmCol, ": ", message)
        speaker:AddCaption({
			speaker = "[PM SENT] "..speaker:Nick(), 
			message = message, 
			speakercol = pmCol, 
			msgcol = pmCol,
			dots = true
		})
	end)
	
	mrp.RegisterChatClass(6, function(message, speaker)
		message = hook.Run("ProcessICChatMessage", speaker, message) or message

		mrp.customChatFont = "mrp-Font25"
		
		speaker:AddCaption({
			speaker = speaker:Nick(), 
			message = message, 
			speakercol = yellCol, 
			msgcol = yellCol,
			dots = true
		})
	end)

	mrp.RegisterChatClass(7, function(message, speaker)
		message = hook.Run("ProcessICChatMessage", speaker, message) or message
		
		mrp.customChatFont = "mrp-Font19"
		speaker:AddCaption({
			speaker = speaker:Nick(), 
			message = message, 
			speakercol = whisperCol, 
			msgcol = whisperCol,
			dots = true
		})
	end)

	mrp.RegisterChatClass(8, function(message, speaker)
		--mrp.customChatFont = "mrp-Font20" 
		--chat.AddText(radioCol, "[RADIO] ", speaker:Name(), ": ", message)
        speaker:AddCaption({
			speaker = "[RADIO] "..speaker:Nick(), 
			message = message, 
			speakercol = radioCol, 
			msgcol = radioCol,
			dots = true
		})
	end)

	mrp.RegisterChatClass(10, function(message, speaker)
		--chat.AddText(infoCol, "** ", message)
        speaker:AddCaption({
			speaker = "", 
			message = message, 
			speakercol = Color(255, 255, 255, 0), 
			msgcol = infoCol
		})
	end)

	mrp.RegisterChatClass(13, function(message, speaker)
		--chat.AddText(acCol, "[Admin Chat] ", speaker:Nick(), ": ", acCol, message)
        speaker:AddCaption({
			speaker = "[Admin Chat]"..speaker:Nick(), 
			message = message, 
			speakercol = acCol, 
			msgcol = color_white,
			dots = true
		})
	end)

	mrp.RegisterChatClass(14, function(message, speaker)
		--chat.AddText(eventCol, "[EVENT] ", message)
        speaker:AddCaption({
			speaker = "[EVENT]", 
			message = message, 
			speakercol = eventCol, 
			msgcol = eventCol,
			dots = true
		})
	end)
end