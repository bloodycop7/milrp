
local PLUGIN = PLUGIN

hook.Add("PlayerNoClip", "fandad", function(ply, state)
    if ( state ) then
        EndRappel(ply)
    end
end)