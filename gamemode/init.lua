DeriveGamemode("sandbox")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function GM:PlayerLoadout(ply)
    if ( ply:Team() == 0 ) then
        ply:SetTeam(TEAM_TERRORIST)
    end
    
    local modelr
	if ( isstring(mrp.Teams.Stored[ply:Team()].model) ) then
		modelr = mrp.Teams.Stored[ply:Team()].model
	elseif ( istable(mrp.Teams.Stored[ply:Team()].model) ) then
		modelr = table.Random(mrp.Teams.Stored[ply:Team()].model)
	end

    ply:Give("gmod_tool")
    ply:Give("weapon_physgun")
    ply:Give("mrp_hands")
    ply:Give("weapon_bsmod_punch")
    ply:SetModel(modelr or "models/bread/cod/characters/milsim/shadow_company.mdl")
    ply:Give("ix_rappel")
	ply:SetRunSpeed(200)
    ply:SetWalkSpeed(100)
    ply:SetJumpPower(160)
    ply:SetDuckSpeed(0.5)
    ply:SetUnDuckSpeed(0.5)
    ply:SetLadderClimbSpeed(100)
    ply:SetCrouchedWalkSpeed(0.6)
	ply:SetupHands(ply)
end