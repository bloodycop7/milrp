mrp.CombineNPCs = mrp.CombineNPCs or {
    ["npc_combine_s"] = true,
    ["npc_metropolice"] = true,
    ["npc_manhack"] = true,
    ["npc_hunter"] = true,
    ["npc_helicopter"] = true,
    ["npc_combinegunship"] = true,
    ["npc_turret_floor"] = true,
    ["npc_rollermine"] = true,
    ["npc_combine_camera"] = true,
    ["npc_turret_ceiling"] = true,
    ["npc_breen"] = true,
    ["npc_manhack"] = true,
    ["npc_vj_civil_protection_z"] = true,
    ["npc_combinedropship"] = true,
    ["npc_sniper"] = true,
    ["npc_vj_combine_apc_z"] = true,
    ["npc_vj_hunterchopper_z"] = true,
    ["npc_vj_hunter2_z"] = true,
    ["npc_vj_mini_strider_synth_z"] = true,
    ["npc_vj_cremator_synth_z"] = true,
    ["npc_vj_mortar_synth_z"] = true,
    ["npc_vj_combineguard_z"] = true,
    ["npc_vj_hunterchopper_z"] = true,
    ["npc_vj_stalker_z"] = true,
    ["npc_vj_combine_turret_z"] = true,
    ["npc_vj_gunship2_z"] = true,
    ["npc_vj_dropship_z"] = true,
    ["obj_vj_hopper_mine_z"] = true,
    ["npc_vj_strider_synth_z"] = true,
    ["npc_vj_assassin_synth_z"] = true,
    ["npc_vj_overwatch_soldier_z"] = true,
    ["npc_vj_hlr2_com_civilp"] = true,
    ["npc_vj_hlr2_com_civilp_elite"] = true,
    ["npc_vj_hlr2_com_sentry"] = true,
    ["npc_vj_overwatch_elite_z"] = true,
    ["npc_vj_novaprospekt_soldier_z"] = true,
    ["npc_vj_overwatch_shotgunner_z"] = true,
    ["npc_vj_overwatch_sniper_z"] = true,
    ["npc_vj_novaprospekt_shotgunner_z"] = true,
    ["npc_vj_hlr2_com_elite"] = true,
    ["npc_vj_hlr2_com_engineer"] = true,
    ["npc_vj_hlr2_com_prospekt"] = true,
    ["npc_vj_hlr2_com_prospekt_sg"] = true,
    ["npc_vj_hlr2_com_shotgunner"] = true,
    ["npc_vj_hlr2_com_sniper"] = true,
    ["npc_vj_hlr2_com_soldier"] = true,
    ["npc_vj_hlr2b_com_soldier"] = true,
    ["npc_cscanner"] = true,
    ["npc_vj_synth_scanner_z"] = true,
    ["npc_vj_vortigaunt_synth_z"] = true,
    ["npc_vj_crabsynth2_z"] = true,
}

mrp.RebelNPCs = mrp.RebelNPCs or {
    ["npc_magnusson"] = true,
    ["npc_kleiner"] = true,
    ["npc_mossman"] = true,
    ["npc_eli"] = true,
    ["npc_citizen"] = true,
    ["npc_vortigaunt"] = true,
    ["npc_mossman"] = true,
    ["npc_vj_hlr2_rebel"] = true,
    ["npc_vj_hlr2_rebel_engineer"] = true,
    ["npc_vj_hlr2_refugee"] = true,
    ["npc_vj_hlr2_res_sentry"] = true,
    ["npc_vj_hlr2_alyx"] = true,
    ["npc_vj_hlr2_barney"] = true,
    ["npc_vj_hlr2_citizen"] = true,
    ["npc_vj_hlr2_father_grigori"] = true,
    ["npc_vj_hlr2b_merkava"] = true,
    ["npc_alyx"] = true,
    ["npc_barney"] = true,
}

function mrp.relationships.Update(npc)
    for k, v in pairs(player.GetAll()) do
        if ( v ) then
            if not ( npc.isOverriden ) then
                if ( npc.EMPd ) then
                    npc.VJ_NPC_Class = {"CLASS_REBEL"}

                    for i, d in pairs(ents.GetAll()) do
                        if ( d:IsNPC() ) then
                            if ( mrp.CombineNPCs[d:GetClass()] ) then
                                npc:AddEntityRelationship(d, D_HT, 99)
                                d:AddEntityRelationship(npc, D_HT, 99)
                            end
                        end
                    end

                    for i, d in pairs(ents.GetAll()) do
                        if ( d:IsNPC() ) then
                            if ( mrp.RebelNPCs[d:GetClass()] ) then
                                npc:AddEntityRelationship(d, D_LI, 99)
                                d:AddEntityRelationship(npc, D_LI, 99)
                            end
                        end
                    end

                    if ( v:IsCombine() ) then
                        v.VJ_NPC_Class = {"CLASS_COMBINE"}
                        npc:AddEntityRelationship(v, D_HT, 99)
                    else
                        v.VJ_NPC_Class = {"CLASS_REBEL"}
                        npc:AddEntityRelationship(v, D_LI, 99)
                    end
                    return
                end
                
                if ( mrp.CombineNPCs[npc:GetClass()] ) then
                    npc.VJ_NPC_Class = {"CLASS_COMBINE"}
                    if ( v:IsCombine() ) then
                        v.VJ_NPC_Class = {"CLASS_COMBINE"}
                        npc:AddEntityRelationship(v, D_LI, 99)
                    else
                        v.VJ_NPC_Class = {"CLASS_REBEL"}
                        npc:AddEntityRelationship(v, D_HT, 99)
                    end
                elseif ( mrp.RebelNPCs[npc:GetClass()] ) then
                    npc.VJ_NPC_Class = {"CLASS_REBEL"}
                    if ( v:IsCombine() ) then
                        v.VJ_NPC_Class = {"CLASS_COMBINE"}
                        npc:AddEntityRelationship(v, D_HT, 99)
                    else
                        v.VJ_NPC_Class = {"CLASS_REBEL"}
                        npc:AddEntityRelationship(v, D_LI, 99)
                    end
                end

                if ( v:GetMoveType() == MOVETYPE_NOCLIP ) then
                    if ( npc and IsValid(npc) ) then
                        npc:AddEntityRelationship(v, D_LI, 99)
                    end
                end
            end
        end
    end
end

function PLUGIN:Think()
    local chance = math.random(1, 4)
    if ( ( nextCheck or 0 ) < CurTime() ) then
        for k, v in ipairs(ents.GetAll()) do
            if ( v:IsNPC() ) then

                if ( v:GetClass():find("vj_*") ) then
                    v.DisableWandering = false
                    mrp.relationships.Update(v)
                    v.FollowPlayerCloseDistance = 64 -- vjbase
                    return 
                end
                
                v:SetKeyValue("spawnflags", "16384")
                v:SetKeyValue("spawnflags", "2097152")
                v:SetKeyValue("spawnflags", "8192") -- dont drop weapons

                    
                local weaponProficiency = WEAPON_PROFICIENCY_POOR
                if ( chance == 1 ) then
                    weaponProficiency = WEAPON_PROFICIENCY_AVERAGE
                elseif ( chance == 2 ) then
                    weaponProficiency = WEAPON_PROFICIENCY_GOOD
                elseif ( chance == 3 ) then
                    weaponProficiency = WEAPON_PROFICIENCY_VERY_GOOD
                elseif ( chance == 4 ) then
                    weaponProficiency = WEAPON_PROFICIENCY_PERFECT
                end

                if ( v.SetCurrentWeaponProficiency ) then
                    v:SetCurrentWeaponProficiency(weaponProficiency)
                end
                mrp.relationships.Update(v)
                nextCheck = CurTime() + 1.5
            end
        end
    end
end

function PLUGIN:PlayerTick(ply, mv)
    if ( ( nextCheck or 0 ) < CurTime() ) then
        local chance = math.random(1, 4)
        for k, v in ipairs(ents.GetAll()) do
            if ( v:IsNPC() ) then

                if ( v:GetClass():find("vj_*") ) then
                    v.DisableWandering = false
                    mrp.relationships.Update(v)
                    v.FollowPlayerCloseDistance = 64 -- vjbase
                    return 
                end
                
                v:SetKeyValue("spawnflags", "16384")
                v:SetKeyValue("spawnflags", "2097152")
                v:SetKeyValue("spawnflags", "8192") -- dont drop weapons
                    
                local weaponProficiency = WEAPON_PROFICIENCY_POOR
                if ( chance == 1 ) then
                    weaponProficiency = WEAPON_PROFICIENCY_AVERAGE
                elseif ( chance == 2 ) then
                    weaponProficiency = WEAPON_PROFICIENCY_GOOD
                elseif ( chance == 3 ) then
                    weaponProficiency = WEAPON_PROFICIENCY_VERY_GOOD
                elseif ( chance == 4 ) then
                    weaponProficiency = WEAPON_PROFICIENCY_PERFECT
                end

                if ( v.SetCurrentWeaponProficiency ) then
                    v:SetCurrentWeaponProficiency(weaponProficiency)
                end
                mrp.relationships.Update(v)

                nextCheck = CurTime() + 1.5
            end
        end
    end
end

function PLUGIN:PlayerSpawnedNPC(ply, ent)
    local chance = math.random(1, 4)
    if ( ent:GetClass():find("vj_*") ) then
        ent.DisableWandering = false
        mrp.relationships.Update(ent)
        ent.FollowPlayerCloseDistance = 64 -- vjbase
        return 
    end
    
    ent:SetKeyValue("spawnflags", "16384")
    ent:SetKeyValue("spawnflags", "2097152")
    ent:SetKeyValue("spawnflags", "8192") -- dont drop weapons
        
    local weaponProficiency = WEAPON_PROFICIENCY_POOR
    if ( chance == 1 ) then
        weaponProficiency = WEAPON_PROFICIENCY_AVERAGE
    elseif ( chance == 2 ) then
        weaponProficiency = WEAPON_PROFICIENCY_GOOD
    elseif ( chance == 3 ) then
        weaponProficiency = WEAPON_PROFICIENCY_VERY_GOOD
    elseif ( chance == 4 ) then
        weaponProficiency = WEAPON_PROFICIENCY_PERFECT
    end

    if ( ent.SetCurrentWeaponProficiency ) then
        ent:SetCurrentWeaponProficiency(weaponProficiency)
    end
    if ( ent.AddEntityRelationship ) then
        mrp.relationships.Update(ent)
    end
end