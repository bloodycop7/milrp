mrp.RegisterChatCommand("/bodygroupmanager", {
    description = "Edit yours or someone elses bodygroups",
    requiresArg = true,
    onRun = function(ply, arg, rawText)
        local name = mrp:FindPlayer(arg[1]) or ply
        net.Start("mrpBodygroupView")
            net.WriteEntity(name)
        net.Send(ply)
    end
})