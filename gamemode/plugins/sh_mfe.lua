AddCSLuaFile()

util.PrecacheModel("models/weapons/tfa_kick.mdl")
util.PrecacheModel("models/c_vmaniplegs.mdl")
util.PrecacheModel("models/weapons/c_legs_apex.mdl")

local tick = engine.TickInterval()

function CalcPlayerModelsAngle(ply)
    local defans = Angle(-90, 0, 0)
    if not ply:Alive() then return defans end
    local StartAngle = ply:EyeAngles()
    if not StartAngle then return defans end
    local CalcAngle = Angle(StartAngle.p / 1.1 - 20, StartAngle.y, 0)
    if not CalcAngle then return StartAngle end

    return CalcAngle
end

-- DON'T SOUND.ADD MULTIPLE SOUNDS FOR A SINGLE THING, sound ACCEPTS TABLES AND WILL DO JUST FINE
sound.Add({
    name = "mightyfoot.kickbody",
    channel = CHAN_AUTO,
    level = 65,
    volume = 1,
    pitch = {80, 110},
    sound = "player/smod_kick/foot_kickbody.wav"
})

sound.Add({
    name = "mightyfoot.kickwall",
    channel = CHAN_AUTO,
    level = 65,
    volume = 1,
    pitch = {80, 110},
    sound = "player/smod_kick/foot_kickwall.wav"
})

sound.Add({
    name = "mightyfoot.fire",
    channel = CHAN_AUTO,
    level = 65,
    volume = 1,
    pitch = {80, 110},
    sound = "player/smod_kick/foot_fire.wav"
})

util.PrecacheSound("mightyfoot.kickbody")
util.PrecacheSound("mightyfoot.kickwall")
util.PrecacheSound("mightyfoot.fire")

if CLIENT then
    local function MFEngaged()
        local ply = LocalPlayer()
        local kicktime = 1
        if not IsValid(ply) then return end

        if not ply.MFStopKick then
            ply.MFStopKick = CurTime() + kicktime
        elseif ply.MFStopKick and ply.MFStopKick < CurTime() then
            ply:SetNWInt("EngageMF", net.ReadUInt(2))
            ply.MFKickTime = CurTime()
            ply.MFStopKick = ply.MFKickTime + kicktime
            ply.MFDrawTime = CurTime() + 0.75 / 1
        end
    end

    net.Receive("EngageMF", MFEngaged)
    local kickvmoffset = Vector()
    local legtable = {"models/weapons/tfa_kick.mdl", "models/c_vmaniplegs.mdl", "models/weapons/c_legs_apex.mdl"}

    function MFCreate(pos, ang, ...)
        local kickfov = (100 - LocalPlayer():GetFOV()) / 5
        local speed = 1
        local model = "models/c_vmaniplegs.mdl"

        pos = ang

        if model == -1 then legmodel = legtable[math.random(#legtable)] end
        if !util.IsValidModel(legmodel) then legmodel = "models/weapons/tfa_kick.mdl" end

        for k, v in pairs(player.GetAll()) do
            -- print(k)
            local KickState = v:GetNWInt("EngageMF", 0)

            if v:Alive() and GetViewEntity() == v and (not v.ShouldDrawLocalPlayer or not v:ShouldDrawLocalPlayer()) and KickState > 0 and v.MFDrawTime and v.MFDrawTime > CurTime() then
                local off = Vector(kickvmoffset.x, kickvmoffset.y, kickvmoffset.z)
                off:Rotate(CalcPlayerModelsAngle(v))
                local trace = v:GetEyeTraceNoCursor()

                if not IsValid(v.MFRig) and util.IsValidModel(legmodel) then
                    v.MFRig = ClientsideModel(legmodel, RENDERGROUP_TRANSLUCENT)
                    v.MFRig:Spawn()
                    v.MFRig:UseClientSideAnimation()
                    v.MFRig:SetPos(pos + off)
                    v.MFRig:SetAngles(CalcPlayerModelsAngle(v))
                    v.MFRig:SetParent(v)
                    v.MFRig:SetNoDraw(true)
                    v.MFRig:DrawModel()
                    v.MFRig:SetCycle(0)

                    --print(kickfov)
                    -- AT LEAST TRY TO MAKE SENSE WHEN YOU FUCK WITH THIS
                    if legmodel == legtable[2] then
                        v.MFRig:SetPlaybackRate(0.5)

                        if KickState == 3 then
                            v.MFRig:SetSequence("dropkick")
                            kickvmoffset = Vector(kickfov, 0, -4)
                        else
                            v.MFRig:SetSequence("standkick")
                            kickvmoffset = Vector(kickfov, -2, -6)
                        end
                    end

                    v.MFRig:SetPlaybackRate(v.MFRig:GetPlaybackRate() * speed)
                    v.MFRig.LastTick = CurTime()
                else
                    --print("Updating Main Leg")
                    v.MFRig:SetPos(pos + off)
                    v.MFRig:SetAngles(CalcPlayerModelsAngle(v))
                    v.MFRig:FrameAdvance(RealFrameTime())
                    v.MFRig.LastTick = CurTime()
                end

                if not IsValid(v.MFLeg) then
                    --print("Creating PM Leg")
                    v.MFLeg = ClientsideModel(string.Replace(v:GetModel(), "models/models/", "models/"), RENDERGROUP_TRANSLUCENT)

                    function v.MFLeg:GetPlayerColor()
                        if (not IsValid(v)) then return end
                        if (not v.GetPlayerColor) then return end

                        return v:GetPlayerColor()
                    end

                    --shamelessly stolen from gmod_hands.lua
                    v.MFLeg:Spawn()
                    v.MFLeg:UseClientSideAnimation()
                    v.MFLeg:SetSkin(v:GetSkin())

                    for i = 0, v.MFLeg:GetNumBodyGroups() do
                        local bgi = v:GetBodygroup(i)
                        v.MFLeg:SetBodygroup(i, bgi)
                        -- print(v.MFLeg:GetBodygroup(i), v:GetBodygroup(i))
                    end

                    v.MFLeg:SetParent(v.MFRig)
                    v.MFLeg:SetPos(pos + off)
                    v.MFLeg:SetAngles(CalcPlayerModelsAngle(v))
                    v.MFLeg:SetNoDraw(false)
                    v.MFLeg:AddEffects(EF_BONEMERGE)
                    v.MFLeg:DrawModel()
                    v.MFLeg:SetPlaybackRate(1)
                    v.MFLeg.LastTick = CurTime()
                else
                    --print("Updating PM Leg")
                    v.MFLeg:SetPos(pos + off)
                    v.MFLeg:SetAngles(CalcPlayerModelsAngle(v))
                    v.MFLeg:FrameAdvance(RealFrameTime())
                    v.MFLeg:DrawModel()
                    v.MFLeg.LastTick = CurTime()
                end
            else
                if v.MFRig then
                    if IsValid(v.MFRig) then
                        v.MFRig.SetNoDraw(v.MFRig, true)
                        v.MFRig.SetPos(v.MFRig, Vector(0, 0, 0))
                        v.MFRig.SetAngles(v.MFRig, Angle(0, 0, 0))
                        v.MFRig.SetRenderOrigin(v.MFRig, Vector(0, 0, 0))
                        v.MFRig.SetRenderAngles(v.MFRig, Angle(0, 0, 0))
                    end

                    local tmpcreatelegs = v.MFRig

                    timer.Simple(tick, function()
                        if tmpcreatelegs then
                            tmpcreatelegs:Remove()
                        end
                    end)

                    v.MFRig = nil
                end

                if v.MFLeg then
                    --print("Removing Created PM Leg")
                    if IsValid(v.MFLeg) then
                        v.MFLeg.SetNoDraw(v.MFLeg, true)
                        v.MFLeg.SetPos(v.MFLeg, Vector(0, 0, 0))
                        v.MFLeg.SetAngles(v.MFLeg, Angle(0, 0, 0))
                        v.MFLeg.SetRenderOrigin(v.MFLeg, Vector(0, 0, 0))
                        v.MFLeg.SetRenderAngles(v.MFLeg, Angle(0, 0, 0))
                    end

                    local tmpcreatelegs = v.MFLeg

                    timer.Simple(tick, function()
                        if tmpcreatelegs then
                            tmpcreatelegs:Remove()
                        end
                    end)

                    v.MFLeg = nil
                end

                KickState = 0
            end
        end
    end

    hook.Add("ShouldDisableLegs", "MFDisableLegs", function()
        if (LocalPlayer().MFDrawTime > CurTime()) then
            return true
        end
    end)
    hook.Add("InitPostEntity", "MFPostInitHook", function()
        LocalPlayer().MFKickTime = 0
        LocalPlayer().MFStopKick = 0
        LocalPlayer().MFDrawTime = 0
        
        hook.Add("StartCommand", "MFMoveHook", function(ply, cmd)
            local stopmove = 0
            local time = ply.MFKickTime + (0.6 / 1)
            if stopmove >= 0 and time > CurTime() then
                if stopmove == 2 then
                    cmd:ClearMovement()
                elseif stopmove == 1 then
                    cmd:AddKey(IN_WALK)
                end
                cmd:RemoveKey(IN_SPEED)
            end
        end)
    end)
end

function MFEffect(trace)
    local fx = EffectData()
    fx:SetStart(trace.HitPos)
    fx:SetOrigin(trace.HitPos)
    fx:SetNormal(trace.HitNormal)
    util.Effect("mf_groundhit", fx)

end

function MFHit(ply)
    --	local trace = ply:GetEyeTraceNoCursor()
    --	if trace == nil then return end
    ply:LagCompensation(true)
    local damage = 20, 30 * 1
    local a, b = ply:GetHull()
    local kickrange = b.z * 1

    tracestart = ply:EyePos()

    local dropkickmult = 2
    --local dropkicking = (!ply:OnGround() && ply:WaterLevel() < 1) && ply:GetMoveType() ~= MOVETYPE_LADDER
    local scaledforce = false
    local rangesqr = kickrange * kickrange
    local basemult = 1000
    local aimvector = ply:GetAimVector() * 1
    local physforce = aimvector * 10 * basemult
    local ragforce = aimvector * 10 * basemult

    local trace = util.TraceLine({
        start = tracestart,
        endpos = ply:GetEyeTraceNoCursor().HitPos,
        filter = {ply},
        mask = MASK_SHOT_HULL
    })

    if (not IsValid(trace.Entity)) then
        trace = util.TraceHull({
            start = tracestart,
            endpos = ply:GetEyeTraceNoCursor().HitPos,
            filter = {ply},
            mins = Vector(-4, -4, -8),
            maxs = Vector(4, 4, 8),
            mask = MASK_SHOT_HULL
        })
    end

    local doorforce = (-trace.HitNormal * 10 * basemult)

    damage = 30 + 75

    if SERVER then
        ply:ViewPunch(Angle(-10, math.Rand(-2, 2), 0) * 1)

        if trace.Hit and trace.HitPos:DistToSqr(trace.StartPos) <= rangesqr and not trace.HitSky then
            local phys = trace.Entity:GetPhysicsObject()
            local physbone = trace.Entity:GetPhysicsObjectNum(trace.PhysicsBone)
            local isliving = trace.Entity:IsPlayer() or trace.Entity:IsNextBot() or trace.Entity:IsNPC()

            if ply:GetNWInt("EngageMF", 0) == 3 then
                damage = damage * dropkickmult
                aimvector = aimvector * dropkickmult
                physforce = physforce * dropkickmult
                ragforce = ragforce * dropkickmult
            end

            --print(ply:GetNWInt("EngageMF", 0))
            local kickinfo = DamageInfo()
            kickinfo:SetDamage(damage)
            kickinfo:SetAttacker(ply)
            kickinfo:SetDamageType(DMG_CLUB)
            kickinfo:SetInflictor(ply)

            local surfprop = util.GetSurfaceData(trace.SurfaceProps)

            if surfprop == nil then
                surfprop = util.GetSurfaceData(0)
            end

            if string.find(surfprop.name, "flesh", 1, true) ~= nil then
                sound.Play("mightyfoot.kickbody", trace.HitPos, 65, math.random(90, 110), 1)
            else
                MFEffect(trace)
                sound.Play("mightyfoot.kickwall", trace.HitPos, 65, math.random(90, 110), 1)
            end

            --print(surfprop.name .. " " .. surfprop.impactHardSound .. " " .. trace.SurfaceProps)
            sound.Play(table.Random({surfprop.stepRightSound, surfprop.stepLeftSound}), trace.HitPos, 65, math.random(90, 110), 1)

            if phys:IsValid() then
                DropEntityIfHeld(trace.Entity)

                if trace.Entity:IsRagdoll() then
                    if scaledforce then
                        physbone:ApplyForceCenter(phys:GetMass() * ragforce / 10, trace.HitPos)
                    else
                        physbone:ApplyForceCenter(ragforce, trace.HitPos)
                    end
                else
                    if scaledforce then
                        phys:ApplyForceOffset(phys:GetMass() * physforce / 10, trace.HitPos)
                    else
                        phys:ApplyForceOffset(physforce, trace.HitPos)
                    end
                end
            end

            if trace.Entity:Health() then
                if isliving then
                    kickinfo:SetDamageForce(ragforce)
                end

                trace.Entity:TakeDamageInfo(kickinfo)
            end

            if isliving then
                trace.Entity:SetVelocity(aimvector * 100)
            elseif ((trace.Entity:GetClass() == "func_door_rotating" and (trace.Entity:HasSpawnFlags(256) or trace.Entity:HasSpawnFlags(1024))) or (trace.Entity:GetClass() == "prop_door_rotating" and not trace.Entity:HasSpawnFlags(32768))) then
                trace.Entity:EmitSound("ambient/materials/door_hit1.wav", 80, math.random(80, 120))
                ply.oldname = ply:GetName()
                ply:SetName("kickingpl" .. ply:EntIndex())

                if trace.Entity:GetNWBool("Locked") then
                    trace.Entity:Fire("unlock")
                    trace.Entity:SetNWBool("Locked", false)
                end

                if (math.Rand(0, 100) <= 20) and trace.Entity:GetClass() == "prop_door_rotating" then
                    MFDoorBust(trace.Entity, ply, damage, doorforce)
                end

                if not trace.Entity:GetNWBool("Locked") then
                    local oldSpeed = trace.Entity:GetInternalVariable("m_flSpeed")
                    local oldDirection = trace.Entity:GetInternalVariable("opendir")
                    local oldDmg = trace.Entity:GetInternalVariable("dmg")
                    local opentype = "open"

                    if trace.Entity:GetClass() == "prop_door_rotating" then
                        opentype = "openawayfrom"
                    end

                    trace.Entity:SetKeyValue("opendir", 0)
                    trace.Entity:Fire("SetSpeed", tostring(oldSpeed * 5), 0)
                    trace.Entity:Fire(opentype, "kickingpl" .. ply:EntIndex(), 0)

                    if trace.Entity:GetClass() == "func_door_rotating" then
                        trace.Entity:SetKeyValue("dmg", oldSpeed*5)
                        timer.Simple(0.1, function()
                            trace.Entity:SetKeyValue("dmg", oldDmg)
                        end)
                    end

                    if IsValid(trace.Entity) then
                        timer.Simple(0.1, function()
                            trace.Entity:Fire("SetSpeed", oldSpeed, 0.3)
                            if trace.Entity:GetInternalVariable("opendir") ~= nil then
                                trace.Entity:SetKeyValue("opendir", oldDirection)
                            end
                        end)
                    end
                end
            elseif trace.Entity:GetClass() == "func_button" then
                trace.Entity:Use(ply)
            elseif trace.Entity:GetClass() == "func_breakable_surf" then
                trace.Entity:Fire("Shatter", "0.5 0.5 256")
            end

            ply:SetVelocity(aimvector * -100)
            debugoverlay.Cross(trace.HitPos, 10, 3, Color(255, 255, 255), true)
        else
            return
        end
    end

    ply:LagCompensation(false)

    return
end

-- thanks worshipper 8D
-- Don't fuck with this.
function MFDoorBust(Door, attacker, amount, force)
    if IsValid(Door:GetPhysicsObject()) then
        local pos = Door:GetPos()
        local ang = Door:GetAngles()
        local model = Door:GetModel()
        local skin = Door:GetSkin()
        local bg = Door:GetBodygroup(1)
        local rendermode = Door:GetRenderMode()
        local renderfx = Door:GetRenderFX()
        local color = Door:GetColor()
        Door:SetNotSolid(true)
        Door:SetNoDraw(true)
        -- force.z = 0
        --[[local function ResetDoor(door, fakedoor)
        if door:IsValid() then
            local mass = door:GetNWInt("DoorHealthMaxHealth")
            door:SetNotSolid(false)
            door:SetNoDraw(false)
            door.DoorHealth = mass
            door:SetNWInt("DoorHealth", door.DoorHealth)
        end

        if fakedoor:IsValid() then
            fakedoor:Remove()
        end
    end]]
        local ent = ents.Create("prop_physics")
        ent:SetPos(pos)
        ent:SetAngles(ang)
        ent:SetModel(model)
        ent:SetSkin(skin)
        ent:SetBodygroup(1,bg)
        ent:SetRenderMode(rendermode)
        ent:SetRenderFX(renderfx)
        ent:SetColor(Color(color.r, color.g, color.b, color.a))
        ent:Spawn()
        ent:SetHealth(Door:Health())
        ent:EmitSound("physics/wood/wood_furniture_break" .. math.random(1, 2) .. ".wav", 75, math.random(70, 140))
        ent:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

        --ensure the door won't get stuck in the door frame
        timer.Simple(tick, function()
            ent:SetCollisionGroup(COLLISION_GROUP_NONE)
        end)

        timer.Create("MFDoorBust" .. ent:EntIndex(), 2, 1, function()
            if IsValid(ent) then
                ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
            end

            timer.Remove("MFDoorBust" .. ent:EntIndex())
        end)

        timer.Create("MFDoorTimer" .. ent:EntIndex(), 25, 1, function()
            if Door:IsValid() then
                Door:SetNotSolid(false)
                Door:SetNoDraw(false)
            end

            if ent:IsValid() then
                ent:Remove()
            end

            timer.Remove("MFDoorTimer" .. ent:EntIndex())
        end)

        ent:GetPhysicsObject():ApplyForceCenter(force * 1)
    end
end

if (SERVER) then
    util.AddNetworkString("EngageMF")
    -- THIS IS HOW IT WORKS ITS MAGIC ON THE SERVER, WATCH.
    function MightyFootEngaged(ply)
        local kickspeed = 1
        local kicktime = 1 / kickspeed
        if not ply:GetObserverMode(0) or not ply:Alive() or ply:IsFrozen() or ply:InVehicle() then return false end
        local dropkicking = (not ply:OnGround() and ply:WaterLevel() < 2) and ply:GetMoveType() ~= MOVETYPE_LADDER and ply:GetMoveType() ~= MOVETYPE_NOCLIP
        local kickstate = 1

        if dropkicking then
            kickstate = 3
        end

        if ply.MFStopKick and ply.MFStopKick < CurTime() then
            ply:SetNWInt("EngageMF", kickstate)
            ply.MFKickTime = CurTime()
            ply.MFStopKick = ply.MFKickTime + kicktime

            timer.Simple(kicktime, function()
                if IsValid(ply) then
                    ply:SetNWInt("EngageMF", 0)
                end
            end)

            net.Start("EngageMF")
            net.WriteUInt(kickstate, 2)
            net.Send(ply)
            ply:DoAnimationEvent(ACT_GMOD_GESTURE_MELEE_SHOVE_1HAND)

            timer.Simple(0.2/kickspeed, function()
                ply:EmitSound("mightyfoot.fire")
            end)

            timer.Simple(0.3/kickspeed, function()
                MFHit(ply)
            end, ply)
        end
    end

    concommand.Add("mightyfootengaged", MightyFootEngaged)

    function MFInitState(ply)
        local kicktime = 1/ 1
        ply.MFKickTime = -1
        ply.MFStopKick = ply.MFKickTime + kicktime
    end

    hook.Add("PlayerSpawn", "MFInitState", MFInitState)
    hook.Add("PlayerDeath", "MFInitState", MFInitState)
end