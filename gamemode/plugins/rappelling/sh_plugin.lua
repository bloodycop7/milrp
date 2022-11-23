
local PLUGIN = PLUGIN

function StartRappel(ply, rappelpoint)
    ply.rappelling = true
    ply.rappelPos = ply:GetPos()

    if ( SERVER ) then
        CreateRope(ply)
    end
end

function EndRappel(ply)
    ply.rappelling = nil

    if ( SERVER ) then
        RemoveRope(ply)
    end
end
