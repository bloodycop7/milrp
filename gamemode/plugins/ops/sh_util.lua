local setHealthCommand = {
    description = "Sets health of the specified player.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local targ = mrp:FindPlayer(arg[1])
        local hp = arg[2]

        if not hp or not tonumber(hp) then
            return
        end

        if not ply:IsLeadAdmin() then
            hp = math.Clamp(hp, 1, 100)
        end


        if targ and IsValid(targ) then
            targ:SetHealth(hp)
            ply:Notify("You have set "..targ:Nick().."'s health to "..hp..".")

            if targ == ply then
                for v,k in pairs(player.GetAll()) do
                    if k:IsLeadAdmin() then
                        k:AddChatText(Color(135, 206, 235), "[ops] Moderator "..ply:Nick().." set their health to "..hp..".")
                    end
                end
            end
        else
            return ply:Notify("Could not find player: "..tostring(arg[1]))
        end
    end
}

mrp.RegisterChatCommand("/sethp", setHealthCommand)

local kickCommand = {
    description = "Kicks the specified player from the server.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local name = arg[1]
        local plyTarget = mrp:FindPlayer(name)

        local reason = ""

        for v,k in pairs(arg) do
            if v != 1 then
                reason = reason.." "..k
            end
        end

        reason = string.Trim(reason)

        if reason == "" then reason = nil end

        if plyTarget and ply != plyTarget then
            ply:Notify("You have kicked "..plyTarget:Name().." from the server.")
            plyTarget:Kick(reason or "Kicked by a game moderator.")
        else
            return ply:Notify("Could not find player: "..tostring(name))
        end
    end
}

mrp.RegisterChatCommand("/kick", kickCommand)