DeriveGamemode("sandbox")
include("shared.lua")

mrp.gui = mrp.gui or {}

function GM:PlayerStartVoice(ply)
    if ( IsValid(g_VoicePanelList) ) then
        g_VoicePanelList:Remove()
    end
    
    return true
end