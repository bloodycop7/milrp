include('shared.lua')

SWEP.PrintName = "Throwing Knife"	
SWEP.Slot = 0
SWEP.SlotPos = 2

if (file.Exists("materials/weapons/weapon_mad_knife.vmt","GAME")) then
	SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_knife")
end