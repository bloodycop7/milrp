mrp.Ops = mrp.Ops or {}
mrp.Ops.Reports = mrp.Ops.Reports or {}

local newReportCol = Color(173, 255, 47)
local claimedReportCol = Color(147, 112, 219)

file.CreateDir("mrp/ops")

util.AddNetworkString("opsNewReport")
util.AddNetworkString("opsReportMessage")
util.AddNetworkString("opsReportUpdate")
util.AddNetworkString("opsReportClaimed")
util.AddNetworkString("opsReportClosed")
util.AddNetworkString("opsReportAdminMessage")
util.AddNetworkString("opsReportSync")
util.AddNetworkString("opsReportDaleRepliedDo")
util.AddNetworkString("opsReportDaleReplied")
util.AddNetworkString("opsReportDaleClose")

function mrp.Ops.ReportNew(ply, arg, rawText)
	if ply.nextReport and ply.nextReport > CurTime() then
        return 
    end

    if string.len(rawText) > 600 then
        return ply:Notify("Your message is too big. (600 characters max.)")    
    end

    local reportId

    local hasActiveReport = false
    for id, data in pairs(mrp.Ops.Reports) do
        if data[1] == ply then
            hasActiveReport = true
            reportId = id
            break
        end
    end

    if hasActiveReport == false then
        reportId = nil

        for v,k in pairs(player.GetAll()) do
            if k:IsAdmin() then
                reportId = reportId or table.insert(mrp.Ops.Reports, {ply, rawText, nil, CurTime()})

                net.Start("opsNewReport")
                net.WriteEntity(ply)
                net.WriteUInt(reportId, 16)
                net.WriteString(rawText)
                net.Send(k)
            end
        end
        if reportId then
            net.Start("opsReportMessage")
            net.WriteUInt(reportId, 16)
            net.WriteUInt(1, 4)
            net.Send(ply)
            return
        else
            ply:Notify("Unfortunately, no game moderators are currently available to review your report. Please goto mrp-community.com and submit a ban request.")
        end
    else
        if string.len(mrp.Ops.Reports[reportId][2]) > 3000 then
            return ply:Notify("Your report has too many characters. You may not send any more updates for this report.")    
        end

        local reportClaimant = mrp.Ops.Reports[reportId][3]

        for v,k in pairs(player.GetAll()) do
            if k:IsAdmin() then
                net.Start("opsReportUpdate")
                net.WriteEntity(ply)
                net.WriteUInt(reportId, 16)
                net.WriteString(rawText)
                net.Send(k)
            end
        end

        mrp.Ops.Reports[reportId][2] = mrp.Ops.Reports[reportId][2].." + "..rawText

        net.Start("opsReportMessage")
        net.WriteUInt(reportId, 16)
        net.WriteUInt(2, 4)
        net.Send(ply)
    end
    ply.nextReport = CurTime() + 2
end

function mrp.Ops.ReportClaim(ply, arg, rawText)
    local reportId = tonumber(arg[1])
    local targetReport = mrp.Ops.Reports[reportId]

    if targetReport then
        local reporter = targetReport[1]
        local reportMessage = targetReport[2]
        local reportClaimant = targetReport[3]
        local reportStartTime = targetReport[4]

        if targetReport[3] and IsValid(targetReport[3]) then
            return ply:AddChatText(newReportCol, "Report #"..reportId.." has already been claimed by "..targetReport[3]:Nick())
        end

        if not IsValid(reporter) then
            return ply:AddChatText(newReportCol, "The player who submitted this report has left the game. Please close.")
        end

        local hasClaimedReport

        for id, data in pairs(mrp.Ops.Reports) do
            if data[3] and data[3] == ply then
                hasClaimedReport = id
                break
            end
        end

        if hasClaimedReport then
            return ply:AddChatText(newReportCol, "You already have a claimed report in progress. Current report #"..hasClaimedReport)
        end

        mrp.Ops.Reports[reportId] = {reporter, reportMessage, ply, reportStartTime, CurTime()}

        for v,k in pairs(player.GetAll()) do
            if k:IsAdmin() then
                net.Start("opsReportClaimed")
                net.WriteEntity(ply)
                net.WriteUInt(reportId, 16)
                net.Send(k)
            end
        end
        net.Start("opsReportMessage")
        net.WriteUInt(reportId, 16)
        net.WriteUInt(3, 4)
        net.WriteEntity(ply)
        net.Send(reporter)
    else
        ply:AddChatText(claimedReportCol, "Report #"..arg[1].." does not exist.")
    end
end

function mrp.Ops.ReportClose(ply, arg, rawText)
   local reportId = arg[1]

    if reportId then
        reportId = tonumber(reportId)
    else
        for id, data in pairs(mrp.Ops.Reports) do
            if data[3] and data[3] == ply then
                reportId = id
                break
            end
        end
    end

    if not reportId then
        return ply:AddChatText(newReportCol, "You must claim a report or specify a report ID before closing it.")
    end

    local targetReport = mrp.Ops.Reports[reportId]

    if targetReport then
        local reporter = targetReport[1]
        local reportMessage = targetReport[2]
        local reportClaimant = targetReport[3]
        local isDc = false

        if not IsValid(reporter) then
            isDc = true
        end

        mrp.Ops.Reports[reportId] = nil

        for v,k in pairs(player.GetAll()) do
        	if k:IsAdmin() then
		        net.Start("opsReportClosed")
		        net.WriteEntity(ply)
		        net.WriteUInt(reportId, 16)
		        net.Send(k)
		    end
	    end

        if not isDc then
            net.Start("opsReportMessage")
            net.WriteUInt(reportId, 16)
            net.WriteUInt(4, 4)
            net.WriteEntity(ply)
            net.Send(reporter)
        end

        if not IsValid(ply) or not ply:IsPlayer() then
            return
        end
    else
        ply:AddChatText(claimedReportCol, "Report #"..reportId.." does not exist.")
    end
end

function mrp.Ops.ReportGoto(ply, arg, rawText)
    local reportId = arg[1]

    if reportId then
        reportId = tonumber(reportId)
    else
        for id, data in pairs(mrp.Ops.Reports) do
            if data[3] and data[3] == ply then
                reportId = id
                break
            end
        end
    end

    if not reportId then
        return ply:AddChatText(newReportCol, "You must claim a report to use this command.")
    end

    local targetReport = mrp.Ops.Reports[reportId]

    if targetReport then
        local reporter = targetReport[1]

        if not IsValid(reporter) then
            return ply:AddChatText(newReportCol, "The player who submitted this report has left the game. Please close.")
        end
        
        opsGoto(ply, reporter:GetPos())
        ply:Notify("You have teleported to "..reporter:Nick()..".")
    else
        ply:AddChatText(claimedReportCol, "Report #"..reportId.." does not exist.")
    end
end

function mrp.Ops.ReportMsg(ply, arg, rawText)
    local reportId

    for id, data in pairs(mrp.Ops.Reports) do
        if data[3] and data[3] == ply then
            reportId = id
            break
        end
    end

    if not reportId then
        return ply:AddChatText(newReportCol, "You must claim a report to use this command.")
    end

    local targetReport = mrp.Ops.Reports[reportId]
    if targetReport then
        local reporter = targetReport[1]

        if not IsValid(reporter) then
            return ply:AddChatText(newReportCol, "The player who submitted this report has left the game. Please close.")
        end

        net.Start("opsReportAdminMessage")
        net.WriteEntity(ply)
        net.WriteString(rawText)
        net.Send(reporter)

        ply:Notify("Reply sent to "..reporter:Nick()..".")
    end
end

hook.Add("PostSetupPlayer", "mrpOpsReportSync", function(ply)
    if not ply:IsAdmin() then
        return
    end

    if table.Count(mrp.Ops.Reports) < 1 then
        return
    end

    local reports = {}
    reports = table.Merge(reports, mrp.Ops.Reports)

    for v,k in pairs(reports) do
        mrp.Ops.Reports[4] = nil
        mrp.Ops.Reports[5] = nil -- clients dont need this
        mrp.Ops.Reports[6] = nil
    end

    net.Start("opsReportSync")
    net.WriteTable(reports)
    net.Send(ply)
end)

net.Receive("opsReportDaleRepliedDo", function(len, ply)
    if (ply.nextDaleDoReply or 0) > CurTime() then
        return
    end

    ply.nextDaleDoReply = CurTime() + 10

    for id, data in pairs(mrp.Ops.Reports) do
        if data[1] == ply then
            if data[6] then
                return
            end

            mrp.Ops.Reports[id][6] = true
            for v,k in pairs(player.GetAll()) do
                if k:IsAdmin() then
                    net.Start("opsReportDaleReplied")
                    net.WriteUInt(id, 8)
                    net.Send(k)
                end
            end
            
            break
        end
    end
end)

net.Receive("opsReportDaleClose", function(len, ply)
    if (ply.nextDaleClose or 0) > CurTime() then
        return
    end

    ply.nextDaleClose = CurTime() + 10

    for id, data in pairs(mrp.Ops.Reports) do
        if data[1] == ply then
            if not data[6] then
                return
            end

            mrp.Ops.ReportClose(Entity(0), {id})
            
            break
        end
    end
end)