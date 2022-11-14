hook.Add("PostPlayerDeath", "thingy", function(ply)
    if (ply.rappelling) then
        EndRappel(ply)
    end
end)

hook.Add("PlayerLoadout", "adad", function(ply)
    if (ply.rappelling) then
        EndRappel(ply)
    end
end)

hook.Add("DoAnimationEvent", "THJINGY", function(ply)
    if (ply:GetPData("forcedSequence") == ply:LookupSequence("rappelloop")) then
        return ACT_INVALID
    end
end)

hook.Add("OnPlayerHitGround", "daodahjd", function(ply, inWater, onFloater, speed)
    if (ply.rappelling and ply.rappelPos.z - ply:GetPos().z > 64) then
        EndRappel(ply)

        if ( SERVER ) then
            ply:EmitSound("npc/combine_soldier/zipline_hitground" .. math.random(2) .. ".wav")
        end

        if (speed >= 196) then
            ply:ViewPunch(Angle(7, 0, 0))
        end
    end
end)

hook.Add("PlayerTick", "gpasgoishgsoghsduigh", function(ply, moveData)
    if (ply:HasWeapon("mrp_rappel")) then
        local onGround = ply:OnGround()

        if (onGround and !ply.wasOnGround) then
            ply.wasOnGround = true
        elseif (!onGround and ply.wasOnGround) then
            ply.wasOnGround = false

            if (!ply.rappelling and moveData:KeyDown(IN_WALK) and ply:GetMoveType() != MOVETYPE_NOCLIP) then
                StartRappel(ply)
            end
        end
    end
end)

hook.Add("Move", "noadad", function(ply, moveData)
    if (ply.rappelling) then
        local vel = moveData:GetVelocity()

        local dir = (ply.rappelPos - ply:GetPos()) * 0.1

        vel.x = (vel.x + dir.x) * 0.95
        vel.y = (vel.y +  dir.y) * 0.95

        local rappelFalling = false

        if (!ply:OnGround() and (ply:EyePos().z) < ply.rappelPos.z) then
            rappelFalling = true

            if (moveData:KeyDown(IN_WALK)) then
                moveData:SetForwardSpeed(0)
                moveData:SetSideSpeed(0)

                vel.z = math.max(vel.z - 16, -128)
            else
                vel.z = math.max(vel.z - 16, -256)
            end
        end

        moveData:SetVelocity(vel)

        if (rappelFalling) then
            if ( SERVER ) then
                local sequence = ply:LookupSequence("rappelloop")

                if (sequence != -1) then
                    ply:SetPData("forcedSequence", sequence)
                end

                if (!ply.oneTimeRappelSound) then
                    ply.oneTimeRappelSound = true

                    ply:EmitSound("npc/combine_soldier/zipline" .. math.random(2) .. ".wav")
                end
            end

            if (ply:WaterLevel() >= 1) then
                EndRappel(ply)
            end
        else
            if ( SERVER ) then
                local sequence = ply:LookupSequence("rappelloop")

                if (sequence != 1 and ply:GetPData("forcedSequence") == sequence) then
                    ply:SetPData("forcedSequence", nil)
                end
            end

            local origin = moveData:GetOrigin()

            if (math.Distance(origin.x, origin.y, ply.rappelPos.x, ply.rappelPos.y) > 256) then
                EndRappel(ply)
            end
        end
    end
end)