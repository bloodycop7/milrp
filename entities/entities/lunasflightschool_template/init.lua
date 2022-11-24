-- YOU CAN EDIT AND REUPLOAD THIS FILE. 
-- HOWEVER MAKE SURE TO RENAME THE FOLDER TO AVOID CONFLICTS

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:SpawnFunction( ply, tr, ClassName ) -- called by garry
	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent.dOwnerEntLFS = ply  -- this is important
	ent:SetPos( tr.HitPos + tr.HitNormal * 20 ) -- spawn 20 units above ground
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:OnTick() -- use this instead of "think"
end

--[[
function ENT:CalcFlightOverride( Pitch, Yaw, Roll, Stability ) -- overwrite flight mechanics?
	return Pitch,Yaw,Roll,Stability,Stability,Stability
end
]]--

function ENT:RunOnSpawn() -- called when the vehicle is spawned
	--[[
	local SpawnedPod = self:AddPassengerSeat( Vector(0,0,50), Angle(0,-90,0) ) -- add a passenger seat, store it inside "SpawnedPod" local variable
	
	SpawnedPod.ExitPos = Vector(0,80,20)  -- assigns an exit pos for SpawnedPod
	
	self:SetGunnerSeat( SpawnedPod ) -- set our SpawnedPod as gunner seat using the inbuild gunner functions. 
							-- Gunner seat will automatically trigger crosshair enable for the player who is sitting in it. 
							-- You can get the player who sitting in this pod using self:GetGunner()
							-- If you want to add more gunners you will have to write your own functions
	]]--
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:SetNextPrimary( 0.15 )
	
	--[[ do primary attack code here ]]--
	
	self:EmitSound( "Weapon_SMG1.NPC_Single" )
	
	local Driver = self:GetDriver()
	
	local bullet = {}
	bullet.Num 	= 1
	bullet.Src 	= self:LocalToWorld( Vector(20,0,10) )
	bullet.Dir 	= self:GetForward()
	bullet.Spread 	= Vector( 0.015,  0.015, 0 )
	bullet.Tracer	= 1
	bullet.TracerName	= "lfs_tracer_green"
	bullet.Force	= 10
	bullet.HullSize 	= 5
	bullet.Damage	= 5
	bullet.Attacker 	= Driver
	bullet.AmmoType = "Pistol"
	
	self:FireBullets( bullet )
	
	self:TakePrimaryAmmo()
end

function ENT:SecondaryAttack()
	if not self:CanSecondaryAttack() then return end
	
	self:SetNextSecondary( 0.15 )

	--[[ do secondary attack code here ]]--
	
	self:TakeSecondaryAmmo()
end

function ENT:CreateAI() -- called when the ai gets enabled
end

function ENT:RemoveAI() -- called when the ai gets disabled
end

function ENT:OnKeyThrottle( bPressed )
	if self:CanSound() then -- makes sure the player cant spam sounds
		if bPressed then -- if throttle key is pressed
			--self:EmitSound( "buttons/button3.wav" )
			--self:DelayNextSound( 1 ) -- when the next sound should be allowed to be played
		else
			--self:EmitSound( "buttons/button11.wav" )
			--self:DelayNextSound( 0.5 )
		end
	end
end

--[[
function ENT:OnReloadWeapon()
	self:EmitSound("lfs/weapons_reload.wav")
end

function ENT:OnUnloadWeapon()
	self:EmitSound("weapons/357/357_reload4.wav")
end
]]--

--[[
function ENT:ApplyThrustVtol( PhysObj, vDirection, fForce )
	PhysObj:ApplyForceOffset( vDirection * fForce,  self:GetElevatorPos() )
	PhysObj:ApplyForceOffset( vDirection * fForce,  self:GetWingPos() )
end

function ENT:ApplyThrust( PhysObj, vDirection, fForce )
	PhysObj:ApplyForceOffset( vDirection * fForce, self:GetRotorPos() )
end
]]--

function ENT:OnEngineStarted()
	--[[ play engine start sound? ]]--
	self:EmitSound( "vehicles/airboat/fan_motor_start1.wav" )
end

function ENT:OnEngineStopped()
	--[[ play engine stop sound? ]]--
	self:EmitSound( "vehicles/airboat/fan_motor_shut_off1.wav" )
end

function ENT:OnVtolMode( IsOn )
	--[[ called when vtol mode is activated / deactivated ]]--
end

function ENT:OnLandingGearToggled( bOn )
	self:EmitSound( "vehicles/tank_readyfire1.wav" )
	
	if bOn then
		--[[ set bodygroup of landing gear down? ]]--
	else
		--[[ set bodygroup of landing gear up? ]]--
	end
end

--[[
function ENT:OnStartMaintenance()
	if not self:GetRepairMode() and self:GetAmmoMode() then
		self:UnloadWeapon()
	end
end

function ENT:OnStopMaintenance()
end
]]
