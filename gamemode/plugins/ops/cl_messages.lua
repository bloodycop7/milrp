mrp.Ops = mrp.Ops or {}
mrp.Ops.Reports = mrp.Ops.Reports or {}
mrp.Ops.Log = mrp.Ops.Log or {}

function mrp.Ops.NewLog(msg, isMe)
	table.insert(mrp.Ops.Log, {
		message = msg,
		isMe = isMe or false,
		time = CurTime()
	})

	if not isMe then
		OPS_LASTMSG_CLOSE = false
	end
end

local uniqueReportKey = 0
net.Receive("opsReportMessage", function()
	local reportId = net.ReadUInt(16)
	local msgId = net.ReadUInt(4)

	if msgId == 1 then
		LocalPlayer():Notify("Report submitted for review. Thank you for doing your part in keeping the community clean. Report ID: #"..reportId..".")
        LocalPlayer():Notify("If you have any further requests or info for us, just send another report by pressing F3.")

        mrp.Ops.NewLog({Color(50, 205, 50), "(#"..reportId..") Report submitted", color_white, " message: "..(mrp_reportMessage or "")}, true)
        mrp.Ops.CurReport = reportId
        uniqueReportKey = uniqueReportKey + 1

        local urkCopy = uniqueReportKey + 0
        timer.Simple(360, function()
        	if mrp.Ops.CurReport and urkCopy == uniqueReportKey and not mrp.Ops.CurReportClaimed then
        		LocalPlayer():Notify("Apologies for the delay in processing your report. We will resolve your report as soon as possible.")
        		mrp.Ops.NewLog({"(#"..reportId..") Apologies for the delay in processing your report. We will resolve your report as soon as possible"}, false)

        		if mrp_userReportMenu and IsValid(mrp_userReportMenu) then
					mrp_userReportMenu:SetupUI()
				end
        	end
        end)

        timer.Simple(1, function()
        	if mrp.Ops.CurReport then
        		mrp.Ops.DaleRead(mrp_reportMessage or "")
        	end
        end)
    elseif msgId == 2 then
    	LocalPlayer():Notify("Your report has been updated. Thank you for keeping us informed. Report ID: #"..reportId..".")
    	mrp.Ops.NewLog({"(#"..reportId..") Report updated: "..mrp_reportMessage or ""}, true)

        timer.Simple(1, function()
        	if mrp.Ops.CurReport then
        		mrp.Ops.DaleRead(mrp_reportMessage or "")
        	end
        end)
    elseif msgId == 3 then
    	local claimer = net.ReadEntity()

    	if IsValid(claimer) then
    		LocalPlayer():Notify("Your report has been claimed for review by a game moderator ("..claimer:Nick()..").")
    		mrp.Ops.NewLog({Color(255, 140, 0), "(#"..reportId..") Report claimed for review by a game moderator ("..claimer:Nick()..") and currently under review"}, false)
    	end

    	mrp.Ops.CurReportClaimed = true
    elseif msgId == 4 then
    	local claimer = net.ReadEntity()

    	if IsValid(claimer) then
    		LocalPlayer():Notify("Your report has been closed by a game moderator ("..claimer:Nick().."). We hope we have managed to resolve your issue.")
    		mrp.Ops.NewLog({Color(240, 0, 0), "(#"..reportId..") Report closed by a game moderator ("..claimer:Nick()..")"}, false)
    	else
    		mrp.Ops.NewLog({Color(240, 0, 0), "(#"..reportId..") Report closed by a game moderator"}, false)
    	end

    	mrp.Ops.CurReport = nil
    	mrp.Ops.CurReportClaimed = nil
	end

	if mrp_userReportMenu and IsValid(mrp_userReportMenu) then
		mrp_userReportMenu:SetupUI()
	end
end)

net.Receive("opsReportAdminMessage", function()
	local claimer = net.ReadEntity()
	local msg = net.ReadString()

	if IsValid(claimer) and mrp.Ops.CurReport then
		LocalPlayer():Notify("A game moderator has replied to your report. Press F3 to view it.")
		mrp.Ops.NewLog({"(#"..mrp.Ops.CurReport..") ", "Game moderator reply", " ("..claimer:Nick().."): ", color_white, msg}, false)

		if mrp_userReportMenu and IsValid(mrp_userReportMenu) then
			mrp_userReportMenu:SetupUI()
		end
	end
end)

local newReportCol = Color(173, 255, 47)
local claimedReportCol = Color(147, 112, 219)

net.Receive("opsNewReport", function()
	local sender = net.ReadEntity()
	local reportId = net.ReadUInt(16)
	local message = net.ReadString()

	if not IsValid(sender) then return end

	if mrp.GetSetting("admin_onduty") then
		chat.AddText(newReportCol, "[NEW REPORT] [#"..reportId.."] ", sender:Nick(), " (", sender:Name(), "): ", message)
	    surface.PlaySound("buttons/blip1.wav")

		if WinToast then
	       	WinToast.Show("New report [#"..reportId.."] from "..sender:Nick(), message)
	    end
	end

    mrp.Ops.Reports[reportId] = {sender, message}

    if mrp_reportMenu and IsValid(mrp_reportMenu) then
    	mrp_reportMenu:ReloadReports()
    end
end)

net.Receive("opsReportUpdate", function()
	local sender = net.ReadEntity()
	local reportId = net.ReadUInt(16)
	local message = net.ReadString()

	if not IsValid(sender) then return end

	if mrp.GetSetting("admin_onduty") then
		if mrp.Ops.Reports[reportId] and mrp.Ops.Reports[reportId][3] and mrp.Ops.Reports[reportId][3] == LocalPlayer() then
			chat.AddText(claimedReportCol, "[REPORT UPDATE] [#"..reportId.."] ", sender:Nick(), " (", sender:Name(), "): ", message)
	        surface.PlaySound("buttons/blip1.wav")

	        if WinToast then
	        	WinToast.Show("Report updated [#"..reportId.."]", message)
	        end
		end
	end

	if mrp.Ops.Reports and mrp.Ops.Reports[reportId] then
		mrp.Ops.Reports[reportId][2] = mrp.Ops.Reports[reportId][2].." + "..message
	end
end)

net.Receive("opsReportClaimed", function()
	local claimer = net.ReadEntity()
	local reportId = net.ReadUInt(16)

	if not IsValid(claimer) then return end

	if mrp.GetSetting("admin_onduty") then
		if LocalPlayer() == claimer then
			chat.AddText(claimedReportCol, "[REPORT] [#"..reportId.."] claimed by "..claimer:Nick())
		else
			chat.AddText(newReportCol, "[REPORT] [#"..reportId.."] claimed by "..claimer:Nick())
		end
	end

	if mrp.Ops.Reports and mrp.Ops.Reports[reportId] then
		mrp.Ops.Reports[reportId][3] = claimer
	end

    if mrp_reportMenu and IsValid(mrp_reportMenu) then
    	mrp_reportMenu:ReloadReports()
    end
end)

net.Receive("opsReportClosed", function()
	local closer = net.ReadEntity()
	local reportId = net.ReadUInt(16)

	if not IsValid(closer) or closer == Entity(0) then
		if mrp.Ops.Reports and mrp.Ops.Reports[reportId] and (not mrp.Ops.Reports[reportId][3] or not IsValid(mrp.Ops.Reports[reportId][3])) then
			chat.AddText(newReportCol, "[REPORT] [#"..reportId.."] closed by Dale")
		end
	else
		if mrp.GetSetting("admin_onduty") then
			if mrp.Ops.Reports and mrp.Ops.Reports[reportId] and (not mrp.Ops.Reports[reportId][3] or not IsValid(mrp.Ops.Reports[reportId][3])) then
				chat.AddText(newReportCol, "[REPORT] [#"..reportId.."] closed by "..closer:Nick())
			elseif LocalPlayer() and LocalPlayer() == closer then
				chat.AddText(claimedReportCol, "[REPORT] [#"..reportId.."] closed by "..closer:Nick())
			end
		end
	end

	mrp.Ops.Reports[reportId] = nil

    if mrp_reportMenu and IsValid(mrp_reportMenu) then
    	mrp_reportMenu:ReloadReports()
    end
end)

net.Receive("opsReportDaleReplied", function()
	local reportId = net.ReadUInt(8)

	if mrp.Ops.Reports and mrp.Ops.Reports[reportId] then
		mrp.Ops.Reports[reportId][4] = true
	end

    if mrp_reportMenu and IsValid(mrp_reportMenu) then
    	mrp_reportMenu:ReloadReports()
    end
end)

net.Receive("opsReportSync", function()
	mrp.Ops.Reports = net.ReadTable() or {}
end)

net.Receive("opsGiveWarn", function()
	local reason = net.ReadString()
	local template = "You have received a warning from a Game Moderator for a violation of the server rules.\nReason: "..reason.."\nPlease read the server rules again before continuing. Repeated offences will be punished by a ban."
	local id = "warn_"..os.time()

	mrp.MenuMessage.Add(id, "Warning Notice", template, Color(238, 210, 2), "https://panel.mrp-community.com/index.php?t=violations", "View more details")
	mrp.MenuMessage.Save(id)
end)

net.Receive("opsGiveCombineBan", function()
	local time = net.ReadUInt(16)
	local endTime =  os.time() + time
	local endDate = os.date("%H:%M:%S - %d/%m/%Y", endTime)
	local template = "You have an active combine ban for a violation of the server rules.\nExpiry time: "..endDate
	local id = "combineban_"..endDate

	mrp.MenuMessage.Add(id, "Combine Ban Notice", template, Color(179, 58, 58), mrp.Config.RulesURL, "Read the rules", endTime)
	mrp.MenuMessage.Save(id)
end)

net.Receive("opsGiveOOCBan", function()
	local time = net.ReadUInt(16)
	local endTime =  os.time() + time
	local endDate = os.date("%H:%M:%S - %d/%m/%Y", endTime)
	local template = "You have an active OOC communication timeout for a violation of the server rules.\nExpiry time: "..endDate
	local id = "oocban_"..endDate

	mrp.MenuMessage.Add(id, "OOC Timeout Notice", template, Color(179, 58, 58), mrp.Config.RulesURL, "Read the rules", endTime)
	mrp.MenuMessage.Save(id)
end)

net.Receive("opsGetRecord", function()
	local warns = net.ReadUInt(8)
	local bans = net.ReadUInt(8)
	local curScore = cookie.GetNumber("ops-record-badsportscore", 0)
	local score = 0

	score = score + (bans * 2)
	score = score + warns

	if warns > 3 then
		score = score + 1
	end

	local col = Color(238, 210, 2)
	if score > 9 then
		col = Color(179, 58, 58)
	end

	local template = "You have a poor disciplinary record that consists of "..warns.." warnings and "..bans.." bans.\nPlease take time to read the server rules before continuing as further violations will result in a long-term or possibly permanent suspension."

	if curScore != score and score > 3 then
		mrp.MenuMessage.Remove("badsport")
		mrp.MenuMessage.Add("badsport", "Poor Disciplinary Record Notice", template, col, "https://panel.mrp-community.com/index.php?t=violations", "View more details")
	end

	cookie.Set("ops-record-badsportscore", score)
end)

net.Receive("opsUnderInvestigation", function()
	local template = "You are currently under investigation for possible cheating.\nOur automated systems have flagged you as a suspected cheater and your account is now under review. If you were not cheating, you don't need to worry and you can just ignore this message. You will not be informed of the outcome of this investigation when it is complete."
	mrp.MenuMessage.Add("cheater", "Cheating Investigation Notice", template, Color(238, 210, 2))
	mrp.MenuMessage.Save("cheater")
end)

net.Receive("opsE2Viewer", function()
	local count = net.ReadUInt(8)
	local e2s = {}

	for i=1, count do
		local e2 = net.ReadEntity()
		local name = net.ReadString()
		local perf = net.ReadFloat()

		table.insert(e2s, {ent = e2, name = name, perf = perf})
	end

	local pnl = vgui.Create("mrpE2Viewer")
	pnl:SetupE2S(e2s)
end)