util.AddNetworkString("FPDM_UpdatePlayerView")

hook.Add("EntityTakeDamage", "FPDM_Damage", function(ply, dmginfo)
    local attacker = dmginfo:GetAttacker()
    if not ( ply:IsPlayer() ) then return end
    if not ( ply or ply:IsValid() ) then return end
    if ( dmginfo:GetDamage() < ply:Health() or ply:HasGodMode() or not ply:Alive() ) then return end
    if not ( attacker or (attacker:IsPlayer() and attacker:HasGodMode()) ) then return end

    ply.fpdm_lastVel = ply:GetVelocity()
    ply.fpdm_lastForce = dmginfo:GetDamageForce()
end)

hook.Add("PlayerDeath", "FPDM_Death", function(ply, inf, att)
    if ( ply == inf ) then
        ply.fpdm_lastVel = ply:GetVelocity()
        ply.fpdm_lastForce = Vector(0, 0, 0)
    end

    local cl_ragdoll = ply:GetRagdollEntity()
    if ( cl_ragdoll and cl_ragdoll:IsValid() ) then
        cl_ragdoll:Remove()
    end

    if ( ply.deadcorpse and ply.deadcorpse:IsValid() ) then
        ply.deadcorpse:Remove()
    end

    local ragdoll = ents.Create("prop_ragdoll")
    ragdoll:SetModel(ply:GetModel())
    ragdoll:SetPos(ply:GetPos())
    ragdoll:Spawn()
    ragdoll:Activate()
    ragdoll:SetRenderMode(RENDERMODE_TRANSALPHA)

    ply.deadcorpse = ragdoll

    local data = ragdoll:GetAttachment(ragdoll:LookupAttachment("eyes"))
    local eyeEnt = ents.Create("prop_physics")
    eyeEnt:SetModel("models/props_junk/PopCan01a.mdl")
    eyeEnt:SetMoveType(MOVETYPE_NONE)
    eyeEnt:SetNotSolid(true)
    eyeEnt:SetPos(data.Pos - ragdoll:GetForward()*3)
    eyeEnt:SetAngles(data.Ang)
    eyeEnt:SetParent(ragdoll)
    eyeEnt:SetRenderMode(RENDERMODE_TRANSALPHA)
    eyeEnt:SetColor(Color(0, 0, 0, 0))
    eyeEnt:Fire("setparentattachmentmaintainoffset", "eyes", 0)

    ply:SetViewEntity(eyeEnt)

    local vel = ply.fpdm_lastVel or Vector(0, 0, 0)
    local force = ply.fpdm_lastForce or Vector(0, 0, 0)

    local weapon = ents.Create(ply.fpdm_lastWeapon)
    weapon:SetPos(ply:LocalToWorld(ply:OBBCenter()))
    weapon:Spawn()
    weapon:Activate()
    
    if ( weapon and weapon:IsValid() ) then
        ply:DropWeapon(weapon)
        local phys = weapon:GetPhysicsObject()
        if ( phys and phys:IsValid() ) then
            constraint.NoCollide(ragdoll, weapon, 0, 0)
            phys:SetVelocity(vel + force/50)
        end
        timer.Simple(60, function()
            if ( weapon and weapon:IsValid() ) then
                weapon:Remove()
            end
        end)
    end
    
    timer.Simple(0.01, function()
        ragdoll:SetAngles(ply:GetAngles())

        timer.Simple(0.01, function()
            local bonesCount = ragdoll:GetPhysicsObjectCount()
            for n = 1, bonesCount-1 do
                local bone = ragdoll:GetPhysicsObjectNum(n)
                if ( IsValid(bone) ) then
                    local pos, ang = ply:GetBonePosition(ragdoll:TranslatePhysBoneToBone(n))
                    if ( pos and ang ) then
                        bone:SetPos(pos)
                        bone:SetAngles(ang)
                        bone:EnableMotion(true)
                        bone:SetVelocity(vel + force/(3*bonesCount))
                    end
                end
            end
        end)
    end)
    
    net.Start("FPDM_UpdatePlayerView")
        net.WriteEntity(ply)
        net.WriteInt(eyeEnt:EntIndex(), 32)
        net.WriteInt(ragdoll:EntIndex(), 32)
        net.WriteVector(ply:GetPlayerColor())
    net.Broadcast()
end)

hook.Add("PlayerSpawn", "FPDM_Spawn", function(ply)
    ply:SetViewEntity(ply)
    if ( ply.deadcorpse and ply.deadcorpse:IsValid() ) then
        ply.deadcorpse:Remove()
    end
    timer.Simple(0.01, function()
        if ( ply and ply:IsValid() ) then
            local weapon = ply:GetActiveWeapon()
            if ( weapon and weapon:IsValid() ) then
                ply.fpdm_lastWeapon = weapon:GetClass()
            end
        end
    end)
end)

hook.Add("PlayerSwitchWeapon", "FPDM_WeaponSwitch", function(ply, old, new)
    ply.fpdm_lastWeapon = new:GetClass()
end)

hook.Add("PlayerDisconnected", "FPDM_Disconnected", function(ply)
    if ( ply and ply.deadcorpse and ply.deadcorpse:IsValid() ) then
        ply.deadcorpse:Remove()
    end
end)
