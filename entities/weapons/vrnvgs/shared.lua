AddCSLuaFile()
SWEP.DrawCrosshair		= false
SWEP.DrawAmmo			= false
SWEP.PrintName			= "NVG"
SWEP.Slot 				= 15
SWEP.SlotPos 			= 15
SWEP.ViewModelFOV		= 90
SWEP.Instructions 		= ""
SWEP.Author   			= ""
SWEP.Contact        	= ""
SWEP.Weight 			= 0
SWEP.ViewModelFlip		= false
SWEP.Spawnable 			= false
SWEP.AdminSpawnable 	= false
SWEP.ViewModel			= "models/ventrische/c_quadnod2.mdl"
SWEP.WorldModel			= ""
SWEP.UseHands 			= false
SWEP.Primary.Recoil 	= 0
SWEP.Primary.Damage 	= 0
SWEP.Primary.NumShots 	= 0
SWEP.Primary.Cone 		= 0
SWEP.Primary.ClipSize 	= -1
SWEP.Primary.Delay 		= 0
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic 	= false
SWEP.Primary.Ammo 		= "none"
SWEP.Secondary.Ammo 	= "none"

function SWEP:Initialize() return true end
function SWEP:PrimaryAttack() return false end
function SWEP:SecondaryAttack() return false end

function SWEP:Deploy()
	if SERVER then
		local s = self
		local ply = self.Owner
		local viewmodel = ply:GetViewModel()
		local anim = viewmodel:LookupSequence("idleoff")
		viewmodel:SendViewModelMatchingSequence(anim)

		if viewmodel:IsValid() then
			if s.slamholdtype then
				s:SetHoldType("slam") 

				ply.vrnvgequipped = !ply.vrnvgequipped
				net.Start("vrnvgnetequip")
				net.WriteBool(ply.vrnvgequipped)
				net.Send(ply)
				if ply.vrnvgequipped then
					ply:EmitSound("ventrische/nvg/equip.mp3")
				else
					ply:EmitSound("ventrische/nvg/unequip.mp3")
				end

				timer.Simple(2, function()
					if ply:Alive() then
                                                            ply:SelectWeapon(ply.vrnvglast:GetClass())

						ply:StripWeapon(s:GetClass())
						s.slamholdtype = false
                                                  end
				end)
			elseif s.cameraholdtype then 
				s:SetHoldType("camera") 

				ply.vrnvgflipped = !ply.vrnvgflipped
				net.Start("vrnvgnetflip")
				net.WriteBool(ply.vrnvgflipped)
				net.Send(ply)

				if !ply.vrnvgflipped then
					timer.Simple(1, function()
						if ply:Alive() then
							ply:SelectWeapon(ply.vrnvglast:GetClass())

							ply:StripWeapon(s:GetClass())
							s.cameraholdtype = false
						end
					end)
				else
					if ply:FlashlightIsOn() then 
						ply:Flashlight( false )
					end

					timer.Simple(1.3, function()
						if ply:Alive() then
							ply:SelectWeapon(ply.vrnvglast:GetClass())

							ply:StripWeapon(s:GetClass())
							s.cameraholdtype = false
						end
					end)
				end
			elseif s.brokentoss and ply.vrnvgbroken then 
				s:SetHoldType("slam") 

				net.Start("vrnvgnetbreak")
				net.WriteBool(true)
				net.Send(ply)
				ply.vrnvgequipped = false
				ply.vrnvgflipped = false

				timer.Simple(4.82, function()
					if ply:Alive() then
						ply:SelectWeapon(ply.vrnvglast:GetClass())

						ply:StripWeapon(s:GetClass())
						s.brokentoss = false
						ply.vrnvgbroken = false
					end
				end)
			end
		else 
			print("viewmodel fucked")
		end
	end
end