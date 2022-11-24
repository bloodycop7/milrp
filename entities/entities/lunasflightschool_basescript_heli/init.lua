--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:CalcFlight()
	if not self:GetEngineActive() or self:IsStartStopping() then return end
	
	self:InWater()
	
	if self:IsDestroyed() or self:GetRotorDestroyed() then
		self:StopEngine()
		
		return
	end
	
	self:CheckRotorClearance()
	
	local MaxTurnSpeed = self:GetMaxTurnSpeedHeli()
	local MaxPitch = MaxTurnSpeed.p
	local MaxYaw = MaxTurnSpeed.y
	local MaxRoll = MaxTurnSpeed.r
	
	local PhysObj = self:GetPhysicsObject()
	if not IsValid( PhysObj ) then return end
	
	local Pod = self:GetDriverSeat()
	if not IsValid( Pod ) then return end
	
	local LocalVel = self:WorldToLocal( self:GetVelocity() + self:GetPos() )
	local AngVel = self:GetAngVel()
	
	local Mass = PhysObj:GetMass()
	
	local Driver = Pod:GetDriver()
	
	local EyeAngles = self:GetAngles()

	local OnGround = self:HitGround()
	
	local ThrInc = false
	local ThrDec = OnGround
	local PitchUp = false
	local PitchDn = false
	local YawL = false
	local YawR = false
	local RollL = false
	local RollR = false
	
	local HoverMode = false
	local unlockYaw = false
	
	local TargetThrust = 0
	
	local FT = FrameTime()
	
	if IsValid( Driver ) then
		EyeAngles = Pod:WorldToLocalAngles( Driver:EyeAngles() )
		
		if Driver:lfsGetInput( "FREELOOK" ) then
			if isangle( self.StoredEyeAngles ) then
				EyeAngles = self.StoredEyeAngles
			end
			unlockYaw = true
		else
			self.StoredEyeAngles = EyeAngles
			unlockYaw = false
		end
		
		ThrInc = Driver:lfsGetInput( "+THROTTLE_HELI" )
		ThrDec = not ThrInc and OnGround or Driver:lfsGetInput( "-THROTTLE_HELI" )
		
		PitchUp = Driver:lfsGetInput( "+PITCH_HELI" )
		PitchDn = Driver:lfsGetInput( "-PITCH_HELI" )
		
		YawL  = Driver:lfsGetInput( "-YAW_HELI" )
		YawR  = Driver:lfsGetInput( "+YAW_HELI" )
		
		RollL = Driver:lfsGetInput( "-ROLL_HELI" )
		RollR = Driver:lfsGetInput( "+ROLL_HELI" )
		
		HoverMode = Driver:lfsGetInput( "HOVERMODE" )
		
		TargetThrust = self:GetMaxThrustHeli() * ((ThrInc and 1 or 0)  - (ThrDec and 1 or 0))
	else
		local HasAI = self:GetAI()
		if HasAI then
			local TPos =  self:RunAI()
			local LPos = self:WorldToLocal( TPos )
			
			local Target = self:AIGetTarget()
			
			local P = math.Clamp(LPos.x * 0.02 - LocalVel.x * 0.1,-40,40)
			local Y = ((IsValid( Target ) and Target:GetPos() or TPos) - self:GetPos()):Angle().y
			local R = math.Clamp(-LPos.y * 0.02 + LocalVel.y * 0.1,-40,40)
			
			EyeAngles = Angle(P,Y,R)
			self.Roll = R
			
			TargetThrust = math.Clamp( LPos.z -LocalVel.z,-self:GetMaxThrustHeli(),self:GetMaxThrustHeli())
		else
			TargetThrust = self:GetMaxThrustHeli() * ((ThrInc and 1 or 0)  - (ThrDec and 1 or 0))
		end
	end
	
	local Rate = FrameTime() * 8
	self.Thrust = self.Thrust and ( self.Thrust + math.Clamp( TargetThrust - self.Thrust,-Rate,Rate ) ) or 0
	
	local cForce = self:GetZForce()
	local Force = Vector(0,0,cForce * (1 - self:GetThrustEfficiency())) + self:GetUp() * (cForce * self:GetThrustEfficiency() - LocalVel.z * 0.01 + self.Thrust)
	
	--self.Pitch = (PitchDn or PitchUp) and (self.Pitch and self.Pitch + ((PitchDn and MaxPitch or 0) - (PitchUp and MaxPitch or 0)) * FT or EyeAngles.p) or EyeAngles.p
	--self.Yaw = (YawR or YawL) and (self.Yaw and self.Yaw + ((YawL and MaxYaw or 0) - (YawR and MaxYaw or 0)) * FT or EyeAngles.y) or EyeAngles.y
	
	self.Roll = self.Roll and self.Roll + ((RollR and MaxRoll or 0) - (RollL and MaxRoll or 0)) * FT or 0

	--local AngForce = self:WorldToLocalAngles( Angle(self.Pitch,self.Yaw,self.Roll) )
	local AngForce = self:WorldToLocalAngles( Angle(EyeAngles.p,EyeAngles.y,self.Roll) )
	
	if HoverMode then
		local P = math.Clamp(-LocalVel.x * 0.1,-40,40)
		local Y = EyeAngles.y
		local R = math.Clamp(LocalVel.y * 0.1,-40,40)
		
		if PitchUp or PitchDn then
			P = (PitchDn and 40 or 0) - (PitchUp and 40 or 0)
		end
		
		if YawL or YawR then
			Y = Y + (YawL and 45 or 0) - (YawR and 45 or 0)
		end
		
		if RollL or RollR then
			R = (RollR and 60 or 0) - (RollL and 60 or 0)
		end
		
		if unlockYaw then
			self.Yaw = self.Yaw and self.Yaw + ((YawL and MaxYaw or 0) - (YawR and MaxYaw or 0)) * FT or EyeAngles.y
			Y = self.Yaw
		else
			self.Yaw = Y
		end
		
		AngForce = self:WorldToLocalAngles( Angle(P,Y,R) )
		
		self.Roll = 0
	end

	self:SetRPM( self:GetLimitRPM() * math.max((self.Thrust + cForce) / (self:GetMaxThrustHeli() + cForce),0.12) )
	
	local P = math.Clamp(AngForce.p,-MaxPitch,MaxPitch)
	local Y = math.Clamp(AngForce.y,-MaxYaw,MaxYaw)
	local R = math.Clamp(AngForce.r + math.cos(CurTime()) * 2,-MaxRoll,MaxRoll)
	
	AngForce.p,AngForce.y,AngForce.r = self:CalcFlightOverride( P, Y, R )
	
	PhysObj:ApplyForceCenter( Force * Mass )
	
	if (OnGround and (ThrInc or RollL or RollR or HoverMode)) or not OnGround then
		self:ApplyAngForce( (AngForce * 2 - AngVel) * FT * Mass * 500 )
	else
		self:ApplyAngForce( -AngVel * Mass * FT * 500 )
	end
	
	self:SetRotPitch( AngForce.p / MaxPitch )
	self:SetRotYaw( AngForce.y / MaxYaw)
	self:SetRotRoll( AngForce.r / MaxRoll )
end

function ENT:Think()
	
	self:HandleActive()
	self:HandleStart()
	self:HandleLandingGear()
	self:HandleWeapons()
	self:HandleMaintenance()
	self:CalcFlight()
	self:PrepExplode()
	self:RechargeShield()
	self:OnTick()
	self:CalcEngineStart()
	self:CalcEngineStop()
	
	self:NextThink( CurTime() )
	
	return true
end

function ENT:OnRotorDestroyed()
	self:EmitSound( "physics/metal/metal_box_break2.wav" )
	
	self:SetHP(1)
	
	timer.Simple(2, function()
		if not IsValid( self ) then return end
		self:Destroy()
	end)
end

function ENT:OnRotorCollide( Pos, Dir )
	local effectdata = EffectData()
		effectdata:SetOrigin( Pos )
		effectdata:SetNormal( Dir )
	util.Effect( "manhacksparks", effectdata, true, true )

	self:EmitSound( "ambient/materials/roust_crash"..math.random(1,2)..".wav" )
end

function ENT:CheckRotorClearance()
	if self.BreakRotor then
		if self.BreakRotor ~= self:GetRotorDestroyed() then
			self:SetRotorDestroyed( self.BreakRotor )
			self:OnRotorDestroyed()
		end
		
		return
	end
	
	local angUp = self:GetRotorAngle()
	local Up = angUp:Up()
	local Forward = angUp
	Forward:RotateAroundAxis( Up, -CurTime() * 2000 )
	Forward = Forward:Forward()
	
	local position = self:GetRotorPos()

	local tr = util.TraceLine( {
		start = position,
		endpos = (position + Forward * self:GetRotorRadius()),
		filter = function( ent ) 
			if ent == self or ent:IsPlayer() then 
				return false
			end
			
			return true
		end
	} )
	
	self.RotorHitCount = self.RotorHitCount or 0
	
	if tr.Hit then
		if ( hook.Run("CanBreakHelicopterRotor", self:GetDriver(), self) == true ) then
			self.RotorHit = true
			
			self.RotorHitCount = self.RotorHitCount + 1
		end
	else 
		self.RotorHit = false
		
		self.RotorHitCount = math.max(self.RotorHitCount - 1 * FrameTime(),0)
	end
	
	if self.RotorHitCount > 20 then
		self.BreakRotor = true
	end
	
	if self.RotorHit ~= self.oldRotorHit then
		self.oldRotorHit = self.RotorHit
		if self.RotorHit then
			self:OnRotorCollide( tr.HitPos, tr.HitNormal )
		end
	end
end

function ENT:GetZForce()
	if not isnumber( self.ZForce ) then
		self.ZForce = 600 * FrameTime()
	end
	return self.ZForce
end

function ENT:RunAI()
	local RangerLength = 15000
	
	local mySpeed = self:GetVelocity():Length()
	local myPos = self:GetPos()
	local myRadius = self:BoundingRadius() 
	local myDir = self:GetForward()
	
	local MinDist = 1500 + mySpeed
	local StartPos = self:GetPos()
	
	local FrontLeft = util.TraceLine( { start = StartPos, filter = self, endpos = StartPos + self:LocalToWorldAngles( Angle(0,20,0) ):Forward() * RangerLength } )
	local FrontRight = util.TraceLine( { start = StartPos, filter = self, endpos = StartPos + self:LocalToWorldAngles( Angle(0,-20,0) ):Forward() * RangerLength } )
	
	local FrontLeft2 = util.TraceLine( { start = StartPos, filter = self, endpos = StartPos + self:LocalToWorldAngles( Angle(25,65,0) ):Forward() * RangerLength } )
	local FrontRight2 = util.TraceLine( { start = StartPos, filter = self, endpos = StartPos + self:LocalToWorldAngles( Angle(25,-65,0) ):Forward() * RangerLength } )
	
	local FrontLeft3 = util.TraceLine( { start = StartPos, filter = self, endpos = StartPos + self:LocalToWorldAngles( Angle(-25,65,0) ):Forward() * RangerLength } )
	local FrontRight3 = util.TraceLine( { start = StartPos, filter = self, endpos = StartPos + self:LocalToWorldAngles( Angle(-25,-65,0) ):Forward() * RangerLength } )
	
	local FrontUp = util.TraceLine( { start = StartPos, filter = self, endpos = StartPos + self:LocalToWorldAngles( Angle(-20,0,0) ):Forward() * RangerLength } )
	local FrontDown = util.TraceLine( { start = StartPos, filter = self, endpos = StartPos + self:LocalToWorldAngles( Angle(20,0,0) ):Forward() * RangerLength } )

	local Up = util.TraceLine( { start = StartPos, filter = self, endpos = StartPos + self:GetUp() * RangerLength } )
	local Down = util.TraceLine( { start = StartPos, filter = self, endpos = StartPos - self:GetUp() * RangerLength } )
	
	local Down2 = util.TraceLine( { start = self:LocalToWorld( Vector(0,0,100) ), filter = self, endpos = StartPos + Vector(0,0,-RangerLength) } )
	
	local cAvoid = Vector(0,0,0)
	if istable( self.FoundPlanes ) then
		for _, v in pairs( self.FoundPlanes ) do
			if IsValid( v ) and v ~= self and v.LFS then
				local theirRadius = v:BoundingRadius() 
				local Sub = (myPos - v:GetPos())
				local Dir = Sub:GetNormalized()
				local Dist = Sub:Length()
				
				if Dist < (theirRadius + myRadius + 200) then
					if math.deg( math.acos( math.Clamp( myDir:Dot( -Dir ) ,-1,1) ) ) < 90 then
						cAvoid = cAvoid + Dir * (theirRadius + myRadius + 500)
					end
				end
			end
		end
	end
	
	local FLp = FrontLeft.HitPos + FrontLeft.HitNormal * MinDist + cAvoid * 8
	local FRp = FrontRight.HitPos + FrontRight.HitNormal * MinDist + cAvoid * 8
	
	local FL2p = FrontLeft2.HitPos + FrontLeft2.HitNormal * MinDist
	local FR2p = FrontRight2.HitPos + FrontRight2.HitNormal * MinDist
	
	local FL3p = FrontLeft3.HitPos + FrontLeft3.HitNormal * MinDist
	local FR3p = FrontRight3.HitPos + FrontRight3.HitNormal * MinDist
	
	local FUp = FrontUp.HitPos + FrontUp.HitNormal * MinDist
	local FDp = FrontDown.HitPos + FrontDown.HitNormal * MinDist
	
	local Up = Up.HitPos + Up.HitNormal * MinDist
	local Dp = Down.HitPos + Down.HitNormal * MinDist
	
	local TargetPos = (FLp+FRp+FL2p+FR2p+FL3p+FR3p+FUp+FDp+Up+Dp) / 10
	
	local alt = (myPos - Down2.HitPos):Length()
	
	if alt < 600 then 
		TargetPos.z = myPos.z + 2000
	else
		local Target = self:AIGetTarget()
		
		if IsValid( Target ) then
			local HisRadius = Target:BoundingRadius() 
			local HisPos = Target:GetPos() + Vector(0,0,600)
			
			TargetPos = HisPos + (myPos - HisPos):GetNormalized() * (myRadius + HisRadius + 500) + cAvoid * 8
			
			local startpos =  self:GetRotorPos()
			local tr = util.TraceHull( {
				start = startpos,
				endpos = (startpos + self:GetForward() * 50000),
				mins = Vector( -30, -30, -30 ),
				maxs = Vector( 30, 30, 30 ),
				filter = self
			} )
		end
	end
	
	return TargetPos
end

function ENT:IsStartStopping()
	return self.bDoStopStored or self.bDoStartStored
end

function ENT:OnToggleAI( name, old, new)
	if new == old then return end
	
	if new == true then
		local Driver = self:GetDriver()
		
		if IsValid( Driver ) then
			Driver:ExitVehicle()
		end
		
		self:SetActive( true )
		self:CalcEngineStart( true )
		self:CreateAI()
	else
		self:SetActive( false )
		self:CalcEngineStop( true )
		self:RemoveAI()
	end
end

function ENT:CalcEngineStart( bDoStart )
	if bDoStart == true then 
		if not self.bDoStartStored then
			self.bDoStartStored = true
			
			self:OnEngineStartInitialized()
		end
		
		self.bDoStopStored = false
	end
	
	if not self.bDoStartStored then return end
	
	if self:InWater() then
		self:CalcEngineStop( true )
	end
	
	local RPM = self:GetRPM()
	local IdleRPM = self:GetIdleRPM()
	
	if RPM < IdleRPM then
		self:SetRPM( math.min(RPM + FrameTime() * 130,IdleRPM ) )
		self.Thrust = -self:GetMaxThrustHeli()
	else
		self:StartEngine()
		self.bDoStartStored = false
	end
end

function ENT:CalcEngineStop( bDoStop )
	if bDoStop== true then 
		self.bDoStartStored = false
		
		if not self.bDoStopStored then
			self.bDoStopStored = true
			
			self:OnEngineStopInitialized()
			
			if IsValid( self.RotorWashEnt ) then
				self.RotorWashEnt:Remove()
			end
		end
	end
	
	if not self.bDoStopStored then return end
	
	local RPM = self:GetRPM()
	
	if RPM > 0 then
		self:SetRPM( math.Clamp(RPM - FrameTime() * 130 ,0,self:GetIdleRPM() ) )
		self.Thrust = -self:GetMaxThrustHeli()
	else
		self:StopEngine()
		self.bDoStopStored = false
	end
end

function ENT:ToggleEngine()
	if self:GetEngineActive() then
		self:CalcEngineStop( true )
		self:StartMaintenance()
	else
		if self:IsEngineStartAllowed() and not self:IsDestroyed() and not self:InWater() and not self:GetRotorDestroyed() then
			self:CalcEngineStart( true )
			self:StopMaintenance()
		end
	end
end

function ENT:StartEngine()
	if self:GetEngineActive() or self:IsDestroyed() or self:InWater() or self:GetRotorDestroyed() then return end

	self:SetEngineActive( true )
	self:OnEngineStarted()

	local RotorWash = ents.Create( "env_rotorwash_emitter" )

	if IsValid( RotorWash ) then
		RotorWash:SetPos( self:GetRotorPos() )
		RotorWash:SetAngles( Angle(0,0,0) )
		RotorWash:Spawn()
		RotorWash:Activate()
		RotorWash:SetParent( self )
		
		RotorWash.DoNotDuplicate = true
		self:DeleteOnRemove( RotorWash )
		self:dOwner( RotorWash )
		
		self.RotorWashEnt = RotorWash
	end
end

function ENT:StopEngine()
	if not self:GetEngineActive() then return end

	self:SetEngineActive( false )
	self:OnEngineStopped()

	if IsValid( self.RotorWashEnt ) then
		self.RotorWashEnt:Remove()
	end
	
	self:SetRPM( 0 )
end

function ENT:OnEngineStartInitialized()
end

function ENT:OnEngineStopInitialized()
end

function ENT:ToggleLandingGear()
end

function ENT:RaiseLandingGear()
end

function ENT:OnLandingGearToggled( bOn )
end
