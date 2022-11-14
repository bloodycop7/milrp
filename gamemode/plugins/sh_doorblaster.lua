local blastableweapons = {
    ["weapon_shotgun"] = true,
    ["ix_spas12"] = true,
    ["ix_pulse_shotgun"] = true,
    ["ix_waterpipe"] = true,
}

local ignoredamage = {
    ["weapon_crowbar"] = true,
    ["weapon_stunstick"] = true,
    ["ix_axe_blunt"] = true,
    ["ix_axe"] = true,
    ["ix_pickaxe_blunt"] = true,
    ["ix_pickaxe"] = true,
    ["ix_crowbar"] = true,
    ["ix_leadpipe"] = true,
    ["ix_tappingkit"] = true,
    ["ix_hands"] = true,
}

if (SERVER) then
    hook.Add("EntityTakeDamage", "dkadad", function(target, dmginfo) 
        if dmginfo:GetAttacker():IsPlayer() and dmginfo:GetInflictor():IsPlayer() then
            if ignoredamage[dmginfo:GetAttacker():GetActiveWeapon()] == nil then
                if target:GetClass() == "prop_door_rotating" and IsValid(dmginfo:GetInflictor()) and dmginfo:IsBulletDamage() then
                    if dmginfo:GetInflictor():GetPos():Distance( target:GetPos() ) <= 150 then
                        
                        local matrix = target:GetBoneMatrix(0)
                        local originpos = matrix:GetTranslation()
                        local hindge1 = originpos + (target:GetUp() * 34)
                        local hindge2 = originpos - (target:GetUp() * 34)
                        local dampos = dmginfo:GetDamagePosition()
                        local handle = target:LookupBone("handle")
                        local matrix = target:GetBoneMatrix(handle)
                        local handlepos = matrix:GetTranslation()
                        local distance = dampos:Distance(handlepos)
                        dmginfo:GetInflictor():SetName(dmginfo:GetInflictor():UniqueID()..CurTime())

                        if blastableweapons[dmginfo:GetAttacker():GetActiveWeapon():GetClass()] then
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
                            target:Fire("openawayfrom", dmginfo:GetInflictor():UniqueID()..CurTime())
                            target:SetCollisionGroup( 20 )
                            target:SetRenderMode( 10 )
                            Door:Spawn()
                            Door:EmitSound( "/physics/wood/wood_crate_break"..math.random(1, 4)..".wav" , 150, 50, 1)
                            Door:GetPhysicsObject():ApplyForceCenter( Door:GetForward() * 1000 )
                            target.canbeshot = false
                            target:SetPos(target:GetPos() + Vector(0,0,-1000))
                            timer.Simple(60, function()
                                target:SetCollisionGroup( 0 )
                                target:SetRenderMode( 0 )
                                target.bHindge2 = false
                                target.bHindge1 = false
                                target:SetPos(target:GetPos() - Vector(0,0,-1000))
                                if (Door) then
                                    Door:Remove()
                                    target.canbeshot = true
                                end
                            end)
                        
                        
                        -- shooting lock
                        elseif distance <= 3 then
                            target:Fire("setspeed", 350)
                            target:Fire("unlock")
                            target:Fire("openawayfrom", dmginfo:GetInflictor():UniqueID()..CurTime())
                            target:EmitSound( "/physics/wood/wood_crate_break"..math.random(1, 4)..".wav" , 150, 50, 1)
                            local effect = EffectData()
                                effect:SetStart(handlepos)
                                effect:SetOrigin(handlepos)
                                effect:SetScale(2)
                            util.Effect("GlassImpact", effect, true, true)
                            target.canbeshot = false
                            timer.Simple(0.5, function()
                                if (IsValid(target)) then
                                    target:Fire("setspeed", 100)
                                end
                            end)
                            timer.Simple(2, function()
                                target.canbeshot = true
                            end)
                        

                        -- shooting hindges
                        elseif (dampos:Distance(hindge1) <= 3 * 1.5) then
                            target.bHindge1 = true
                            local effect = EffectData()
                                effect:SetStart(hindge1)
                                effect:SetOrigin(hindge1)
                                effect:SetScale(2)
                            util.Effect("GlassImpact", effect, true, true)
                            target:EmitSound( "/physics/wood/wood_crate_break"..math.random(1, 4)..".wav" , 150, 50, 1)
                        elseif (dampos:Distance(hindge2) <= 3 * 1.5) then
                            target.bHindge2 = true
                            local effect = EffectData()
                                effect:SetStart(hindge2)
                                effect:SetOrigin(hindge2)
                                effect:SetScale(2)
                            util.Effect("GlassImpact", effect, true, true)
                            target:EmitSound( "/physics/wood/wood_crate_break"..math.random(1, 4)..".wav" , 150, 50, 1)
                        end

                        if (target.bHindge1 and target.bHindge2) then
                            local Door = ents.Create("prop_physics")
                            Door:SetAngles(target:GetAngles())
                            Door:SetPos(target:GetPos() + target:GetUp())
                            Door:SetModel(target:GetModel())
                            Door:SetSkin(target:GetSkin())
                            Door:SetCollisionGroup(0)
                            Door:SetRenderMode(RENDERMODE_TRANSALPHA)
                            target:Fire("unlock")
                            target:Fire("openawayfrom", dmginfo:GetInflictor():UniqueID()..CurTime())
                            target:SetCollisionGroup( 20 )
                            target:SetRenderMode( 10 )
                            Door:Spawn()
                            target.canbeshot = false
                            target:SetPos(target:GetPos() + Vector(0,0,-1000))
                            timer.Simple(60, function()
                                target:SetCollisionGroup( 0 )
                                target:SetRenderMode( 0 )
                                target.bHindge2 = false
                                target.bHindge1 = false
                                target:SetPos(target:GetPos() - Vector(0,0,-1000))
                                if (Door) then
                                    Door:Remove()
                                    target.canbeshot = true
                                end
                            end)
                        end
                    end
                end
            end
        end
    end)
end