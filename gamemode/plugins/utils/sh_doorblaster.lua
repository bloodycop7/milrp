PLUGIN.name = "Door Blaster"
PLUGIN.author = "Apsys"

local blastableweapons = {
    ["weapon_shotgun"] = true,
    ["mg_romeo870"] = true,
    ["mg_charlie725"] = true,
    ["mg_dpapa12"] = true,
    ["mg_oscar12"] = true
}

local ignoredamage = {
    ["weapon_crowbar"] = true,
    ["weapon_stunstick"] = true
}

if (SERVER) then
    hook.Add("EntityTakeDamage", "mrpDoorBlast", function(target, dmginfo) 
        if ( dmginfo:GetAttacker():IsPlayer() ) then
            if ( ignoredamage[dmginfo:GetAttacker():GetActiveWeapon()] == nil ) then
                if ( target:GetClass() == "prop_door_rotating" and IsValid(dmginfo:GetInflictor()) and dmginfo:IsBulletDamage() ) then
                    if ( dmginfo:GetInflictor():GetPos():Distance( target:GetPos() ) <= 150 ) then
                        local matrix = target:GetBoneMatrix(0)
                        local originpos = matrix:GetTranslation()
                        local hindge1 = originpos + (target:GetUp() * 34)
                        local hindge2 = originpos - (target:GetUp() * 34)
                        local dampos = dmginfo:GetDamagePosition()
                        local handle = target:LookupBone("handle")
                        local matrix = target:GetBoneMatrix(handle)
                        local handlepos = matrix:GetTranslation()
                        local distance = dampos:Distance(handlepos)
                        dmginfo:GetInflictor():SetName(dmginfo:GetInflictor():MapCreationID()..CurTime())

                        if ( blastableweapons[dmginfo:GetAttacker():GetActiveWeapon():GetClass()] ) then
                            local effect = EffectData()
                                effect:SetStart(dampos)
                                effect:SetOrigin(dampos)
                                effect:SetScale(2)
                            util.Effect("GlassImpact", effect, true, true)
                            local Door = ents.Create("prop_physics")
                            local TargetDoorsPos = target:GetPos()
                            Door:SetAngles(target:GetAngles())
                            Door:SetPos(target:GetPos() + target:GetUp())
                            Door:SetModel(target:GetModel())
                            Door:SetSkin(target:GetSkin())
                            Door:SetCollisionGroup(0)
                            Door:SetRenderMode(RENDERMODE_TRANSALPHA)
                            target:Fire("unlock")
                            target:Fire("openawayfrom", dmginfo:GetInflictor():MapCreationID()..CurTime())
                            target:SetCollisionGroup( 20 )
                            target:SetRenderMode( 10 )
                            Door:Spawn()
                            Door:EmitSound( "/physics/wood/wood_crate_break"..math.random(1, 4)..".wav" , 150, 50, 1)
                            Door:GetPhysicsObject():ApplyForceCenter( Door:GetForward() * 1000 )
                            target:SetPos(target:GetPos() + Vector(0,0,-1000))
                            timer.Simple(60, function()
                                target:SetCollisionGroup( 0 )
                                target:SetRenderMode( 0 )
                                target.bHindge2 = false
                                target.bHindge1 = false
                                target:SetPos(target:GetPos() - Vector(0,0,-1000))
                                if (Door) then
                                    Door:Remove()
                                end
                            end)
                        
                        
                        -- shooting lock
                        elseif ( distance <= 3 ) then
                            target:Fire("setspeed", 350)
                            target:Fire("unlock")
                            target:Fire("openawayfrom", dmginfo:GetInflictor():MapCreationID()..CurTime())
                            target:EmitSound( "/physics/wood/wood_crate_break"..math.random(1, 4)..".wav" , 150, 50, 1)
                            local effect = EffectData()
                                effect:SetStart(handlepos)
                                effect:SetOrigin(handlepos)
                                effect:SetScale(2)
                            util.Effect("GlassImpact", effect, true, true)
                            timer.Simple(0.5, function()
                                if (IsValid(target)) then
                                    target:Fire("setspeed", 100)
                                end
                            end)
                        

                        -- shooting hindges
                        elseif ( dampos:Distance(hindge1) <= 3 * 1.5 ) then
                            target.bHindge1 = true
                            local effect = EffectData()
                                effect:SetStart(hindge1)
                                effect:SetOrigin(hindge1)
                                effect:SetScale(2)
                            util.Effect("GlassImpact", effect, true, true)
                            target:EmitSound( "/physics/wood/wood_crate_break"..math.random(1, 4)..".wav" , 150, 50, 1)
                        elseif ( dampos:Distance(hindge2) <= 3 * 1.5 ) then
                            target.bHindge2 = true
                            local effect = EffectData()
                                effect:SetStart(hindge2)
                                effect:SetOrigin(hindge2)
                                effect:SetScale(2)
                            util.Effect("GlassImpact", effect, true, true)
                            target:EmitSound( "/physics/wood/wood_crate_break"..math.random(1, 4)..".wav" , 150, 50, 1)
                        end

                        if ( target.bHindge1 and target.bHindge2 ) then
                            local Door = ents.Create("prop_physics")
                            Door:SetAngles(target:GetAngles())
                            Door:SetPos(target:GetPos() + target:GetUp())
                            Door:SetModel(target:GetModel())
                            Door:SetSkin(target:GetSkin())
                            Door:SetCollisionGroup(0)
                            Door:SetRenderMode(RENDERMODE_TRANSALPHA)
                            target:Fire("unlock")
                            target:Fire("openawayfrom", dmginfo:GetInflictor():MapCreationID()..CurTime())
                            target:SetCollisionGroup( 20 )
                            target:SetRenderMode( 10 )
                            Door:Spawn()
                            target:SetPos(target:GetPos() + Vector(0,0,-1000))
                            timer.Simple(60, function()
                                target:SetCollisionGroup( 0 )
                                target:SetRenderMode( 0 )
                                target.bHindge2 = false
                                target.bHindge1 = false
                                target:SetPos(target:GetPos() - Vector(0,0,-1000))
                                if (Door) then
                                    Door:Remove()
                                end
                            end)
                        end
                    end
                end
            end
        end
        
        if ( target:GetClass() == "func_button" ) then
            target.sparks = EffectData()
            target.sparks:SetOrigin(target:GetPos())
            target.sparks:SetNormal(target:GetAngles():Forward())
            target.sparks:SetMagnitude(math.Rand(1, 3))
            target.sparks:SetEntity(target)
            
            util.Effect( "ElectricSpark", target.sparks, true, true )
                
            if not ( ( target.buttonBroken or false ) or timer.Exists("Entity"..tostring(target:EntIndex()).."SparkTimer") ) then
                target:Fire("Press")
                
                target:Fire("Lock")
                
                timer.Create("Entity"..tostring(target:EntIndex()).."SparkTimer", math.Rand(1, 2), 0, function()
                    target.sparks = EffectData()
                    target.sparks:SetOrigin(target:GetPos())
                    target.sparks:SetNormal(target:GetAngles():Forward())
                    target.sparks:SetMagnitude(math.Rand(1, 3))
                    target.sparks:SetEntity(target)
                    
                    util.Effect( "ElectricSpark", target.sparks, true, true )
                end)
                target.buttonBroken = true
            end
        end
    end)
    
    hook.Add("PlayerUse", "ButtonInteractHurting", function(ply, ent)
        if ( ent:GetClass() == "func_button" or timer.Exists("Entity"..tostring(ent:EntIndex()).."SparkTimer") ) then
            if ( ( ent.buttonBroken or false ) or timer.Exists("Entity"..tostring(ent:EntIndex()).."SparkTimer") ) then
                timer.Create(tostring(ply).."ButtonHurt", 0.5, 1, function()
                    local dmginfo = DamageInfo()
                    dmginfo:SetDamage(15)
                    dmginfo:SetAttacker(ent)
                    dmginfo:SetDamageType(DMG_SHOCK)
                    
                    ply:TakeDamageInfo(dmginfo)
                end)
            end
        end
    end)
end