local reportCommand = {
    description = "Sends (or updates) a report to the game moderators.",
    requiresArg = true,
    onRun = function(ply, arg, rawText)
        mrp.Ops.ReportNew(ply, arg, rawText)
    end
}

mrp.RegisterChatCommand("/report", reportCommand)

local claimReportCommand = {
    description = "Claims a report for review.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        mrp.Ops.ReportClaim(ply, arg, rawText)
    end
}

mrp.RegisterChatCommand("/rc", claimReportCommand)

local closeReportCommand = {
    description = "Closes a report.",
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        mrp.Ops.ReportClose(ply, arg, rawText)
    end
}

mrp.RegisterChatCommand("/rcl", closeReportCommand)

local gotoReportCommand = {
    description = "Teleports yourself to the reportee of your claimed report.",
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        mrp.Ops.ReportGoto(ply, arg, rawText)
    end
}

mrp.RegisterChatCommand("/rgoto", gotoReportCommand)

local msgReportCommand = {
    description = "Messages the reporter of your claimed report.",
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        mrp.Ops.ReportMsg(ply, arg, rawText)
    end
}

mrp.RegisterChatCommand("/rmsg", msgReportCommand)