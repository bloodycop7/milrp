include('shared.lua')

SWEP.PrintName			= "Throwing Knife"						// 'Nice' Weapon name (Shown on HUD)	
SWEP.Slot				= 0							// Slot in the weapon selection menu
SWEP.SlotPos			= 2							// Position in the slot

// Override this in your SWEP to set the icon in the weapon selection
if (file.Exists("materials/weapons/weapon_mad_knife.vmt","GAME")) then
	SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_knife")
end