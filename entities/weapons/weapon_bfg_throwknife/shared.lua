SWEP.Author = "BFG/Kalashnikov"
SWEP.Instructions = "M1 to throw, USE to pick up after throwing. Ammo can be found under entities tab"
SWEP.Category = "Kalashnikov's Weapons"
SWEP.Contact = "http://steamcommunity.com/id/bfg/"

SWEP.Base = "weapon_mad_base"

SWEP.ViewModelFlip = true 
SWEP.ViewModel = "models/weapons/yurie_cod/iw7/tactical_knife_iw7_vm.mdl"
SWEP.WorldModel = "models/weapons/yurie_cod/iw7/tactical_knife_iw7_wm.mdl"
SWEP.HoldType = "grenade"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.UseHands = true

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Primary.Recoil = 5
SWEP.Primary.Damage	= 0
SWEP.Primary.NumShots = 0
SWEP.Primary.Cone = 0.01
SWEP.ConstantAccuracy = true
SWEP.Primary.Delay = 1.337

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "HelicopterGun"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.ShellEffect = "none"
SWEP.ShellDelay	= 0

SWEP.Pistol = true
SWEP.Rifle = false
SWEP.Shotgun = false
SWEP.Sniper = false

SWEP.RunArmOffset = Vector (0.3671, 0.1571, 5.7856)
SWEP.RunArmAngle = Vector (-37.4833, 2.7476, 0)

SWEP.Sequence = 0

function SWEP:Precache()
	util.PrecacheSound("weapons/knife/knife_slash1.wav")
	util.PrecacheSound("weapons/knife/knife_hitwall1.wav")
	util.PrecacheSound("weapons/knife/knife_deploy1.wav")
	util.PrecacheSound("weapons/knife/knife_hit1.wav")
	util.PrecacheSound("weapons/knife/knife_hit2.wav")
	util.PrecacheSound("weapons/knife/knife_hit3.wav")
	util.PrecacheSound("weapons/knife/knife_hit4.wav")
	util.PrecacheSound("weapons/iceaxe/iceaxe_swing1.wav")
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)

	self.Weapon:EmitSound("weapons/knife/knife_deploy1.wav", 50, 100)

	self:IdleAnimation(1)

	return true
end

function SWEP:EntsInSphereBack(pos, range)
	local ents = ents.FindInSphere(pos, range)

	for k, v in pairs(ents) do
		if v ~= self and v ~= self.Owner and (v:IsNPC() or v:IsPlayer()) and IsValid(v) and self:EntityFaceBack(v) then
			return true
		end
	end

	return false
end

function SWEP:EntityFaceBack(ent)
	local angle = self.Owner:GetAngles().y - ent:GetAngles().y

	if angle < -180 then angle = 360 + angle end
	if angle <= 90 and angle >= -90 then return true end

	return false
end

function SWEP:PrimaryAttack()
	if self.Weapon:GetNetworkedBool("Holsted") or self.Owner:KeyDown(IN_SPEED) or self.Owner:GetAmmoCount(self.Primary.Ammo) <= -1 then return end

	self.Weapon:EmitSound("weapons/iceaxe/iceaxe_swing1.wav")
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	self.Weapon:SetNextSecondaryFire(CurTime() + 1)
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self.Owner:RemoveAmmo(1, self.Primary.Ammo)

	if (SERVER) then
		local knife = ents.Create("ent_bfg_throwknife")
		knife:SetAngles(self.Owner:EyeAngles())

		local pos = self.Owner:GetShootPos()
			pos = pos + self.Owner:GetForward() * 0
			pos = pos + self.Owner:GetRight() * -10
			pos = pos + self.Owner:GetUp() * -5
		knife:SetPos(pos)

		knife:SetOwner(self.Owner)
		knife:SetPhysicsAttacker(self.Owner)
		knife:Spawn()
		knife:Activate()

		self.Owner:SetAnimation(PLAYER_ATTACK1)

		local phys = knife:GetPhysicsObject()
		phys:SetVelocity(self.Owner:GetAimVector() * 1776)
		phys:AddAngleVelocity(Vector(0, 500, 0))
	end

	if (self.Weapon:IsValid() && self.Owner:IsValid()) then
		if (self.Owner:GetAmmoCount(self.Primary.Ammo) < 1) then
			self.Owner:StripWeapon("weapon_bfg_throwknife")
		end
	end
end

function SWEP:SecondaryAttack()
end