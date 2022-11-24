--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:SpawnFunction( ply, tr, ClassName )
	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent.dOwnerEntLFS = ply
	ent:SetPos( tr.HitPos + tr.HitNormal * 50 )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()
	self:SetModel( self.MDL )
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	self:AddFlags( FL_OBJECT ) -- this allows npcs to see this entity
	
	local PObj = self:GetPhysicsObject()
	
	if not IsValid( PObj ) then 
		self:Remove()
		
		print("LFS: missing model. Plane terminated.")
		
		return
	end
	
	PObj:EnableMotion( false )
	PObj:SetMass( self.Mass ) 
	PObj:SetDragCoefficient( self.Drag ) 
	self.LFSInertiaDefault = PObj:GetInertia()
	PObj:SetInertia( self.Inertia ) 
	
	self:InitPod()
	self:InitWheels()
	self:RunOnSpawn()
	
	self.Inertia = self.LFSInertiaDefault
	self:SetIsGroundTouching( true )
	self:AutoAI()
end

function ENT:MainGunPoser( EyeAngles )
end

local function CalcFlight(self, PhysObj, vDirection, fForce )
	local Pod = self:GetDriverSeat()
	if not IsValid( Pod ) then return end
	
	local Mass = PhysObj:GetMass()
	local Driver = Pod:GetDriver()
	
	local AI = self:GetAI()
	local EyeAngles = Angle(0,0,0)
	local VtolMovement = Vector(0,0,0)
	
	local Vel = self:GetVelocity()
	local FT =  FrameTime()
	local OnGround = self:HitGround()
	local IsVtolActive = self:IsVtolModeActive()
	local Up = 0
	
	if self.oldVtolMode ~= IsVtolActive then
		self.oldVtolMode = IsVtolActive
		self:OnVtolMode( IsVtolActive )
	end
	
	if IsValid( Driver ) then 
		EyeAngles = Pod:WorldToLocalAngles( Driver:EyeAngles() )
		
		self:MainGunPoser( EyeAngles )
		
		if Driver:lfsGetInput( "FREELOOK" ) then
			if isangle( self.StoredEyeAngles ) then
				EyeAngles = self.StoredEyeAngles
				EyeAngles.r = 0
			end
		else
			self.StoredEyeAngles = EyeAngles
		end
		
		if IsVtolActive then
			local Thrust = self:GetThrustVtol()
			
			Up = (OnGround and Driver:lfsGetInput( "+THROTTLE" ) or Driver:lfsGetInput( "+PITCH" )) and Thrust or 0
			local Down = ((Driver:lfsGetInput( "-THROTTLE" ) and self:GetThrottlePercent() <= 10) or Driver:lfsGetInput( "-PITCH" )) and -Thrust or 0
			local Right = Driver:lfsGetInput( "+ROLL" ) and Thrust or 0
			local Left = Driver:lfsGetInput( "-ROLL" ) and -Thrust or 0
			
			VtolMovement = self:GetRight() * (Left + Right) + self:GetUp() * (Up + Down)
		end
	else
		EyeAngles = self:GetAngles()
		
		if AI then
			EyeAngles = self:RunAI()
			OnGround = false
		end
		
		self:MainGunPoser( EyeAngles )
	end
	
	if self:GetThrottlePercent() > 10 then
		EyeAngles.r = EyeAngles.r + math.Clamp( -self:GetAngVel().y * (math.min(self:GetThrottlePercent(),100) / 100) + math.cos(CurTime()), -90,90 )
	end
	
	local Angles = self:GetAngles()
	local TargetAngle = EyeAngles
	
	self.smP = self.smP and math.ApproachAngle( self.smP, TargetAngle.p, self.MaxTurnPitch * FT ) or Angles.p
	self.smY = self.smY and math.ApproachAngle( self.smY, TargetAngle.y, self.MaxTurnYaw * FT ) or Angles.y
	self.smR = self.smR and math.ApproachAngle( self.smR, TargetAngle.r, self.MaxTurnRoll * FT ) or Angles.r

	local LocalAngles = self:WorldToLocalAngles( Angle(self.smP,self.smY,self.smR) )
	
	LocalAngles.p = LocalAngles.p * 4 + math.cos(CurTime() * 0.98)
	LocalAngles.y = LocalAngles.y * 4
	LocalAngles.r = LocalAngles.r * 4
	
	if OnGround and self:GetThrottlePercent() <= 10 then
		self:SetRPM( 0 )
		
		if Up <= 0 then 
			self:SetGravityMode( true )
			
			return
		else
			self:SetGravityMode( false )
		end
	else
		self:SetGravityMode( false )
	end
	local AngVel = self:GetAngVel()
	AngVel.p = AngVel.p * self.PitchDamping 
	AngVel.y = AngVel.y * self.YawDamping 
	AngVel.r = AngVel.r * self.RollDamping 
	
	local AngForce = (LocalAngles - AngVel)
	AngForce.p = AngForce.p * self.TurnForcePitch
	AngForce.y = AngForce.y * self.TurnForceYaw
	AngForce.r = AngForce.r * self.TurnForceRoll
	
	self:ApplyAngForce( AngForce *  Mass * FT )
	PhysObj:ApplyForceCenter( (-Vel * 0.7 + vDirection * fForce + VtolMovement) * Mass * FT ) 
end

function ENT:OnGravityModeChanged( b )
end

function ENT:SetGravityMode( b )
	local PhysObj = self:GetPhysicsObject()
	if not IsValid( PhysObj ) then return end
	
	self:SetIsGroundTouching( b )
	
	if PhysObj:IsGravityEnabled() ~= b then
		PhysObj:EnableGravity( b )
	end
end

function ENT:CreateAI()
end

function ENT:RemoveAI()
end

function ENT:OnKeyThrottle( bPressed )
end

function ENT:OnVtolMode( IsOn )
end

function ENT:OnLandingGearToggled( bOn )
end

function ENT:OnTick()
end

function ENT:ApplyThrustVtol( PhysObj, vDirection, fForce )
end

function ENT:ApplyThrust( PhysObj, vDirection, fForce ) 
	if self:GetEngineActive() and not self:IsDestroyed() then
		CalcFlight(self, PhysObj, vDirection, fForce )
	end
end

function ENT:CalcFlightOverride( Pitch, Yaw, Roll, Stability )
	return 0,0,0,0,0,0
end

function ENT:RunOnSpawn()
end
