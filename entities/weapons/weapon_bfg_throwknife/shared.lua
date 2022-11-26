// Variables that are used on both client and server
//DISCLAIMER: I would like to state right here and right now that 90% of the code here is WorshipperQC's, and the base and knife entity is Mad Cow's so pretty much the entire SWEP and entity is done by him. All I am doing here is moving around and editing some functions, adding a little feature here and there, as well as applying a tube trail texture onto the knife entity so I can see how many CODfags I get to impress with my crappy 5-second SWEP.//

SWEP.Author				= "BFG/Kalashnikov"
SWEP.Instructions			= "M1 to throw, USE to pick up after throwing. Ammo can be found under entities tab"
SWEP.Category				= "Kalashnikov's Weapons"
SWEP.Contact				= "http://steamcommunity.com/id/bfg/"

SWEP.Base 				= "weapon_mad_base"

SWEP.ViewModelFlip		= true      //b3c4uz ur a fcuking iDi0t scrub who dosnt kn0w th4t teh MW2 tr0w1ng kn1v3 is thr0wn3d l3ft h4nd3d
SWEP.ViewModel			= "models/weapons/yurie_cod/iw7/tactical_knife_iw7_vm.mdl"
SWEP.WorldModel			= "models/weapons/yurie_cod/iw7/tactical_knife_iw7_wm.mdl"
SWEP.HoldType				= "grenade"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.UseHands = true

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Primary.Recoil		= 5
SWEP.Primary.Damage		= 0
SWEP.Primary.NumShots		= 0
SWEP.Primary.Cone			= 0.01  //3very0ne kn0ws th4t tr0whing kn4ve h4s p3rfect spread, fcuking idiot//
SWEP.ConstantAccuracy		= true
SWEP.Primary.Delay 		= 1.337    //TO0 L337 4 U

SWEP.Primary.ClipSize		= -1					// Size of a clip
SWEP.Primary.DefaultClip	= 1					// Default number of bullets in a clip
SWEP.Primary.Automatic		= false				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "HelicopterGun"

SWEP.Secondary.ClipSize		= -1					// Size of a clip
SWEP.Secondary.DefaultClip	= -1					// Default number of bullets in a clip
SWEP.Secondary.Automatic	= false				// Automatic/Semi Auto
SWEP.Secondary.Ammo		= "none"

SWEP.ShellEffect			= "none"				// "effect_mad_shell_pistol" or "effect_mad_shell_rifle" or "effect_mad_shell_shotgun"
SWEP.ShellDelay			= 0

SWEP.Pistol				= true
SWEP.Rifle				= false
SWEP.Shotgun			= false
SWEP.Sniper				= false

SWEP.RunArmOffset 		= Vector (0.3671, 0.1571, 5.7856)
SWEP.RunArmAngle	 		= Vector (-37.4833, 2.7476, 0)

SWEP.Sequence			= 0

/*---------------------------------------------------------
   Name: SWEP:Precache()
---------------------------------------------------------*/
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

/*---------------------------------------------------------
   Name: SWEP:Deploy()
---------------------------------------------------------*/
function SWEP:Deploy()

	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)

	self.Weapon:EmitSound("weapons/knife/knife_deploy1.wav", 50, 100)

	self:IdleAnimation(1)

	return true
end

/*---------------------------------------------------------
   Name: SWEP:EntityFaceBack
   Desc: Is the entity face back to the player?
---------------------------------------------------------*/
function SWEP:EntsInSphereBack(pos, range)

	local ents = ents.FindInSphere(pos, range)

	for k, v in pairs(ents) do
		if v ~= self and v ~= self.Owner and (v:IsNPC() or v:IsPlayer()) and IsValid(v) and self:EntityFaceBack(v) then
			return true
		end
	end

	return false
end

/*---------------------------------------------------------
   Name: SWEP:EntityFaceBack
   Desc: Is the entity face back to the player?
---------------------------------------------------------*/
function SWEP:EntityFaceBack(ent)

	local angle = self.Owner:GetAngles().y - ent:GetAngles().y

	if angle < -180 then angle = 360 + angle end
	if angle <= 90 and angle >= -90 then return true end

	return false
end

/*---------------------------------------------------------
   Name: SWEP:PrimaryAttack()
   Desc: +attack1 has been pressed.
---------------------------------------------------------*/
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

//		if (self:GetIronsights() == false) then
			local pos = self.Owner:GetShootPos()
				pos = pos + self.Owner:GetForward() * 0
				pos = pos + self.Owner:GetRight() * -10
				pos = pos + self.Owner:GetUp() * -5
			knife:SetPos(pos)
//		else
//			knife:SetPos (self.Owner:EyePos() + (self.Owner:GetAimVector()))
//		end

		knife:SetOwner(self.Owner)
		knife:SetPhysicsAttacker(self.Owner)
		knife:Spawn()
		knife:Activate()

		self.Owner:SetAnimation(PLAYER_ATTACK1)

		local phys = knife:GetPhysicsObject()
		phys:SetVelocity(self.Owner:GetAimVector() * 1776)
		phys:AddAngleVelocity(Vector(0, 500, 0))
	end
////A little something that I added so that if the player throws their knife and has no knives remaining, the SWEP itself is removed until they pick up one of their knives off the ground, which makes it more R34L1571C//
		if(self.Weapon:IsValid() && self.Owner:IsValid()) then
			if (self.Owner:GetAmmoCount(self.Primary.Ammo) < 1) then
				self.Owner:StripWeapon("weapon_bfg_throwknife")
			end
		end

end

/*---------------------------------------------------------
   Name: SWEP:SecondaryAttack()
   Desc: +attack2 has been pressed.
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
end
