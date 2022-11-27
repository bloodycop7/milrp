
local PLUGIN = PLUGIN

function StartRappel(ply)
    ply.rappelling = true
    ply.rappelPos = ply:GetEyeTrace().HitPos
    local hitposent = ply:GetEyeTrace().Entity
    
    if ( hitposent and IsValid(hitposent) ) then
        ply.vehicleRappel = true
        hook.Add("Think", "HelicopterPosUpdateStart", function()
            if ( IsValid(hitposent) ) then
                if ( IsValid(ply.rappelRope) ) then
                    if not ( ply.rappelRope:GetInternalVariable("EndOffset") == tostring(hitposent:GetPos()) ) then
                        ply.rappelRope:SetKeyValue("EndOffset", tostring(hitposent:GetPos()))
                    end
                    
                    if not ( tostring(ply.rappelPos) == ply.rappelRope:GetInternalVariable("EndOffset") ) then
                        ply.rappelPos = hitposent:GetPos()
                    end
                else
                    ply.vehicleRappel = false
                    hook.Remove("Think", "HelicopterPosUpdateStart")
                end
            else
                EndRappel(ply)
                hook.Remove("Think", "HelicopterPosUpdateStart")
            end
        end) 
    end  

    if ( SERVER ) then
        CreateRope(ply)
    end
end

function EndRappel(ply)
    ply.rappelling = nil
    ply.vehicleRappel = false
    
    hook.Remove("Think", "HelicopterPosUpdateStart")

    if ( SERVER ) then
        RemoveRope(ply)
    end
end
