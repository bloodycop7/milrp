
local PLUGIN = PLUGIN

function CreateRope(ply)
    if ( math.Round(ply:GetEyeTrace().HitPos:Distance(ply:GetPos()), 0) < 80 ) then
        local hitpos = ply:GetEyeTrace().HitPos
        local attachmentIndex
        
        attachmentIndex = ply:LookupAttachment("chest")

        local attachment = ply:GetAttachment(attachmentIndex)

        if (attachmentIndex == 0 or attachmentIndex == -1) then
            attachment = {Pos = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Pelvis"))}
            attachmentIndex = ply:LookupAttachment("forward")
        end

        local rappelRope = ents.Create("keyframe_rope")

            rappelRope:SetParent(ply, attachmentIndex)
  
            rappelRope:SetPos(ply:GetPos())
            rappelRope:SetColor(Color(150, 150, 150))

            rappelRope:SetEntity("StartEntity", ply)
            rappelRope:SetEntity("EndEntity", Entity(0))
            rappelRope:SetKeyValue("Width", "1")
            rappelRope:SetKeyValue("Collide", "1")
            rappelRope:SetKeyValue("RopeMaterial", "cable/cable")
            rappelRope:SetKeyValue("EndOffset", tostring(hitpos))
            rappelRope:SetKeyValue("EndBone", "0")
        ply.rappelRope = rappelRope

        ply:DeleteOnRemove(rappelRope)
        ply:EmitSound("npc/combine_soldier/zipline_clip" .. math.random(2) .. ".wav")
    end
end

function RemoveRope(ply)
    if (IsValid(ply.rappelRope)) then
        ply.rappelRope:Remove()
    end

    ply.rappelRope = nil
    ply.oneTimeRappelSound = nil

    local sequence = ply:LookupSequence("rappelloop")

    if (sequence != 1 and ply:GetPData("forcedSequence") == sequence) then
        ply:SetPData("forcedSequence", nil)
    end
    
    ply.vehicleRappel = false
    
    hook.Remove("Think", "HelicopterPosUpdate")
end
