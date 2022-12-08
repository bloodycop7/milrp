
AddCSLuaFile()

hook.Add("Initialize", "ixAmmoFlash", function()
	game.AddAmmoType({
		name = "flashbang"
	})
end)

SWEP.Base = "ls_base_projectile"

SWEP.PrintName = "Flashbang"
SWEP.Category = "Military"

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.HoldType = "slam"

SWEP.WorldModel = "models/weapons/w_eq_flashbang.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_eq_flashbang.mdl"
SWEP.ViewModelFOV = 60

SWEP.Slot = 4
SWEP.SlotPos = 1

SWEP.Primary.Sound = ""
SWEP.Primary.Recoil = 0
SWEP.Primary.Delay = 0.8
SWEP.Primary.HitDelay = 0.1

SWEP.Primary.Ammo = "flashbang"
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1

SWEP.Projectile = {}
if ( IsMounted("cstrike") ) then
	SWEP.Projectile.Model = "models/weapons/w_eq_flashbang_thrown.mdl"
else
	SWEP.Projectile.Model = "models/Items/grenadeAmmo.mdl"
end
SWEP.Projectile.HitSound = "weapons/flashbang/grenade_hit1.wav"
SWEP.Projectile.Touch = false
SWEP.Projectile.ForceMod = 3
SWEP.Projectile.Timer = 3
SWEP.Projectile.RemoveWait = 30

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:ProjectileFire()
	local pos = self:GetPos()
	local owner = self:GetOwner()

	if not ( IsValid(owner) ) then return end

	for k, v in pairs(player.GetAll()) do

		local ang = (self:GetPos() - v:GetShootPos()):GetNormalized():Angle()

		local tracedata = {}

		tracedata.start = v:GetShootPos()
		tracedata.endpos = self:GetPos()
		tracedata.filter = v
		local tr = util.TraceLine(tracedata)

		if (!tr.HitWorld) then
			v:ScreenFade(SCREENFADE.IN, color_white, 5, 2.5)
		end
	end

	self:EmitSound("Weapon_Flashbang.Explode", 100)

	timer.Simple(30, function()
		if ( IsValid(self) ) then
			self:Remove()
		end
	end)
end

sound.Add({
	name = "Weapon_Flashbang.Explode",
	sound = {"weapons/flashbang/flashbang_explode1.wav", "weapons/flashbang/flashbang_explode2.wav"},
	channel = CHAN_WEAPON,
	level = SNDLVL_GUNFIRE,
	pitch = {85, 115}
})