AddCSLuaFile()

if (CLIENT) then
    SWEP.PrintName = "Button Fixer"
    SWEP.DrawAmmo = false
end

SWEP.Category = "Buttons"
SWEP.Author = "Apsys"
SWEP.Instructions = "Primary Fire: Fix a broken Button"

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.ViewModelFOV = 50
SWEP.ViewModelFlip = false
SWEP.AnimPrefix     = "rpg"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.ViewModel = Model("models/weapons/c_pistol.mdl")
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.UseHands = true

SWEP.HoldType = "pistol"

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()
    local ply = self:GetOwner()
    
    local trace = ply:GetEyeTrace().Entity
    timer.Create("SelfUsage", 0.1, 1, function()
        if ( trace:GetClass() == "func_button" ) then
            if ( trace.buttonBroken or false ) then
                if ( ply.Notify ) then
                    ply:Notify("You fixed this button!")
                elseif ( ply.notify ) then
                    ply:notify("You fixed this button!")
                else
                    ply:ChatPrint("You fixed this button!")
                end
                
                timer.Remove(trace:EntIndex().."SparkTimer")
                
                trace:Fire("Unlock")
                
                trace.buttonBroken = false
            else
                if ( ply.Notify ) then
                    ply:Notify("This button is not broken!")
                elseif ( ply.notify ) then
                    ply:notify("This button is not broken!")
                else
                    ply:ChatPrint("This button is not broken!")
                end
            end
        end
    end)
end

function SWEP:SecondaryAttack()
end