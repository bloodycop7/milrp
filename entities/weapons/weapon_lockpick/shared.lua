AddCSLuaFile()

if CLIENT then
    SWEP.PrintName = "Lockpick"
    SWEP.Slot = 5
    SWEP.SlotPos = 1
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false
end

SWEP.Author = "Maxouuuuu.#7316"

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/weapons/c_crowbar.mdl")
SWEP.WorldModel = Model("models/weapons/w_crowbar.mdl")

SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "Military RP"

SWEP.Sound = Sound("physics/wood/wood_box_impact_hard3.wav")

SWEP.Primary.ClipSize = -1      -- Size of a clip
SWEP.Primary.DefaultClip = 0        -- Default number of bullets in a clip
SWEP.Primary.Automatic = false      -- Automatic/Semi Auto
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1        -- Size of a clip
SWEP.Secondary.DefaultClip = -1     -- Default number of bullets in a clip
SWEP.Secondary.Automatic = false        -- Automatic/Semi Auto
SWEP.Secondary.Ammo = ""

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "IsLockpicking")
    self:NetworkVar("Float", 0, "LockpickStartTime")
    self:NetworkVar("Float", 1, "LockpickEndTime")
    self:NetworkVar("Float", 2, "NextSoundTime")
    self:NetworkVar("Int", 0, "TotalLockpicks")
    self:NetworkVar("Entity", 0, "LockpickEnt")
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 2)
    if self:GetIsLockpicking() then return end

    self:GetOwner():LagCompensation(true)
    local trace = self:GetOwner():GetEyeTrace()
    self:GetOwner():LagCompensation(false)
    local ent = trace.Entity

    if not IsValid(ent) then return end
	if ( ent:IsLocked() ) then return end

    self:SetHoldType("pistol")

	self:SetTotalLockpicks(self:GetTotalLockpicks() + 1)

	if ( self:GetTotalLockpicks() >= 5 ) then
		self:GetOwner():Notify("You lockpick broke!", Color(255, 0, 0))
		self:GetOwner():SelectWeapon("weapon_physgun")
		self:GetOwner():StripWeapon("weapon_lockpick")
		return
	end

    self:SetIsLockpicking(true)
    self:SetLockpickEnt(ent)
    self:SetLockpickStartTime(CurTime())
    local endDelta = 10
    self:SetLockpickEndTime(CurTime() + 10)
    

	self:GetOwner():DoAction("Lockpicking ", 10, nil, true)

    if IsFirstTimePredicted() then
        hook.Run("OnPlayerStartLockpic", nil, self:GetOwner(), ent, trace)
    end

    if CLIENT then
        self.Dots = ""
        self.NextDotsTime = SysTime() + 0.5
        return
    end

    local onFail = function(ply) if ply == self:GetOwner() then hook.Run("OnLockpickCompleted", nil, ply, false, ent) end end

    -- Lockpick fails when dying or disconnecting
    hook.Add("PlayerDeath", self, function( ply, ent, attacker)
		if ( self:GetIsLockpicking() or self:GetLockpickEndTime() != 0 ) then
			self:SetIsLockpicking(false)
			self:SetLockpickEndTime(0)
		end
	end)
    hook.Add("PlayerDisconnected", self, function()
		if ( self:GetIsLockpicking() or self:GetLockpickEndTime() != 0 ) then
			self:SetIsLockpicking(false)
			self:SetLockpickEndTime(0)
		end
	end)
    hook.Add("OnLockpickCompleted", self, function()
		hook.Remove("PlayerDisconnected", self)
		hook.Remove("PlayerDeath", self)
	end)

	timer.Simple(10, function()
		self.LockPickChance = math.random(1, 3)
		if not IsValid(ent) or ent ~= self:GetLockpickEnt() or trace.HitPos:DistToSqr(self:GetOwner():GetShootPos()) > 10000 or self.LockPickChance == 1 then
			self:GetOwner():Notify("You have failed to lock-pick the door!", Color(255, 200, 0))

			self:Fail()
		elseif self:GetLockpickEndTime() <= CurTime() then
			self:GetOwner():Notify("You have successfully lock-picked the door!", Color(0, 255, 0))

			self:Succeed()
		end

		self:SetIsLockpicking(false)
	end)
end

function SWEP:Holster()
    self:SetIsLockpicking(false)
    self:SetLockpickEnt(nil)
    return true
end

function SWEP:Succeed()
    self:SetHoldType("normal")

    local ent = self:GetLockpickEnt()
    self:SetIsLockpicking(false)
    self:SetLockpickEnt(nil)

    if not IsValid(ent) then return end

    local override = hook.Run("OnLockpickCompleted", nil, self:GetOwner(), true, ent)

    if ent.Fire then
        ent:Fire("unlock")
        ent:Fire("open", "", .6)
        ent:Fire("setanimation", "open", .6)
    end
end

function SWEP:Fail()
    self:SetIsLockpicking(false)
    self:SetHoldType("normal")

    hook.Run("OnLockpickCompleted", nil, self:GetOwner(), false, self:GetLockpickEnt())
    self:SetLockpickEnt(nil)
end

function SWEP:SecondaryAttack()
    self:PrimaryAttack()
end