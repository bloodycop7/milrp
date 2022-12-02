local viewEnt = LocalPlayer()

local function resizeHead(ent)
    timer.Create("FPDM_NoHead", 0, 300, function()
        if ( ent and ent:IsValid() ) then
            local scale = Vector(0.01, 0.01, 0.01)
            if ( not viewEnt or not viewEnt:IsValid() or LocalPlayer():GetViewEntity() ~= viewEnt ) then
                scale = Vector(1.0, 1.0, 1.0)
            end
            
            ent:ManipulateBoneScale(ent:LookupBone("ValveBiped.Bip01_Head1"), scale)
        else
            timer.Destroy("FPDM_NoHead")
        end
    end)
end

net.Receive("FPDM_UpdatePlayerView", function(len)
    local ply = net.ReadEntity()
    local eye = net.ReadInt(32)
    local index = net.ReadInt(32)
    local color = net.ReadVector()
    
    timer.Create("FPDM_FindEnt", 0, 300, function()
        local ent = ents.GetByIndex(index)
        local eyeEnt = ents.GetByIndex(eye)
        if ( ent and ent:IsValid() and eyeEnt and eyeEnt:IsValid() and color ) then
            ent.GetPlayerColor = function(self) return color end

            if ( ply == LocalPlayer() ) then
                viewEnt = eyeEnt
                resizeHead(ent)
            end
            
            timer.Destroy("FPDM_FindEnt")
        end
    end)
end)
