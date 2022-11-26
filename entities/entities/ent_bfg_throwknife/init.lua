AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

/*---------------------------------------------------------
   Name: ENT:Initialize()
---------------------------------------------------------*/
function ENT:Initialize()
	
	self.Owner = self.Entity:GetOwner()

	if !IsValid(self.Owner) then
		self:Remove()
		return
	end

	
	self:SetModel("models/weapons/yurie_cod/iw7/tactical_knife_iw7_wm.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	local phys = self.Entity:GetPhysicsObject()
	self.NextThink = CurTime() + 1
	self.Entity:DrawShadow(false)

	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(10)
	end
	

	util.PrecacheSound("weapons/yurie_cod/iw7/melee/h2h_knife_impact_other1.wav")
	util.PrecacheSound("weapons/yurie_cod/iw7/melee/h2h_knife_impact_other2.wav")
	util.PrecacheSound("weapons/yurie_cod/iw7/melee/h2h_knife_impact_other3.wav")

	self.Hit = { 
	Sound("weapons/yurie_cod/iw7/melee/h2h_knife_impact_other1.wav"),
	Sound("weapons/yurie_cod/iw7/melee/h2h_knife_impact_other2.wav"),
	Sound("weapons/yurie_cod/iw7/melee/h2h_knife_impact_other3.wav")};

	self.FleshHit = { 
	Sound("weapons/yurie_cod/iw7/melee/h2h_knife_impact_other1.wav"),
	Sound("weapons/yurie_cod/iw7/melee/h2h_knife_impact_other2.wav"),
	Sound("weapons/yurie_cod/iw7/melee/h2h_knife_impact_other3.wav")}

	self:GetPhysicsObject():SetMass(2)	

	self.Entity:SetUseType(SIMPLE_USE)
end

/*---------------------------------------------------------
   Name: ENT:Think()
---------------------------------------------------------*/
function ENT:Think()
	
	self.lifetime = self.lifetime or CurTime() + 20

	if CurTime() > self.lifetime then
		self:Remove()
	end
end

/*---------------------------------------------------------
   Name: ENT:Disable()
---------------------------------------------------------*/
function ENT:Disable()

	self.PhysicsCollide = function() end
	self.lifetime = CurTime() + 30

	self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
end

/*---------------------------------------------------------
   Name: ENT:PhysicsCollided()
---------------------------------------------------------*/
function ENT:PhysicsCollide(data, phys)
	
	local Ent = data.HitEntity
	if !(IsValid(Ent) or Ent:IsWorld()) then return end

	if Ent:IsWorld() then
			util.Decal("ManhackCut", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal)

			if self.Entity:GetVelocity():Length() > 400 then
				self:EmitSound("npc/roller/blade_out.wav", 60)
				//self:SetPos(data.HitPos - data.HitNormal * 10)
				//self:SetAngles(data.HitNormal:Angle() + Angle(40, 0, 0))
				//self:GetPhysicsObject():EnableMotion(false)
			else
				self:EmitSound(self.Hit[math.random(1, #self.Hit)])
			end

			self:Disable()

/////I extraneousized (is that a word?) the whole sticking in walls thing so that it bounces, but I am not, I repeat NOT going to allow ricochet kills. Eat that, codfags.

	elseif Ent.Health then
		if not(Ent:IsPlayer() or Ent:IsNPC() or Ent:GetClass() == "prop_ragdoll") then 
			util.Decal("ManhackCut", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal)
			self:EmitSound(self.Hit[math.random(1, #self.Hit)])
			self:Disable()
		end

		Ent:TakeDamage(420, self:GetOwner())

		if (Ent:IsPlayer() or Ent:IsNPC() or Ent:GetClass() == "prop_ragdoll") then 
			local effectdata = EffectData()
			effectdata:SetStart(data.HitPos)
			effectdata:SetOrigin(data.HitPos)
			effectdata:SetScale(1)
			util.Effect("BloodImpact", effectdata)

			self:EmitSound(self.FleshHit[math.random(1,#self.Hit)])
			self:Remove()
		end
	end

	self.Entity:SetOwner(NUL)
end

/*---------------------------------------------------------
   Name: ENT:Use()
---------------------------------------------------------*/
////This here is so that if they dont have the SWEP and they pick it off the ground, they are given the SWEP, or if they do have the SWEP and they pick it off the ground, they get ammo for it////
function ENT:Use(activator, caller)

	self.Entity:Remove()

	if (activator:IsPlayer()) then
		if activator:GetWeapon("weapon_bfg_throwknife") == NULL then
			activator:Give("weapon_bfg_throwknife")
		else
			activator:GiveAmmo(1, "HelicopterGun")
		end
	end
end
