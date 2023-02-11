DeriveGamemode("sandbox")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function GM:PlayerLoadout(ply)
    if ( ply:Team() == 0 ) then
        ply:SetTeam(TEAM_SOLDIER)
    end
    
    local modelr = "models/bread/cod/characters/milsim/shadow_company.mdl"
	if ( isstring(mrp.Teams.Stored[ply:Team()].model) ) then
		modelr = mrp.Teams.Stored[ply:Team()].model
	elseif ( istable(mrp.Teams.Stored[ply:Team()].model) ) then
		modelr = table.Random(mrp.Teams.Stored[ply:Team()].model)
	end

    ply:Give("gmod_tool")
    ply:Give("weapon_physgun")
    ply:Give("apexswep")
    ply:SetModel(modelr)
    ply:Give("mrp_rappel")
	ply:SetRunSpeed(200)
    ply:SetArmor(100)
    ply:SetWalkSpeed(100)
    ply:SetJumpPower(160)
    ply:SetDuckSpeed(0.5)
    ply:SetUnDuckSpeed(0.5)
    ply:SetLadderClimbSpeed(100)
    ply:SetCrouchedWalkSpeed(0.6)
	ply:SetupHands(ply)
    if ( timer.Exists(ply:SteamID64().."Bleed") ) then
        timer.Remove(ply:SteamID64().."Bleed")
    end
    
    local class = mrp.Teams.Stored[ply:Team()].classes[ply:GetTeamClass()]
    
    if ( class ) then
        if ( class.loadout ) then
            for k, v in pairs(class.loadout) do
                ply:Give(v) 
            end
        end
    end
end