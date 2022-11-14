local PLUGIN = PLUGIN

AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
ENT.PrintName = "Ammo Crate"
ENT.Author = "Apsy"
ENT.Category = "Military"

ENT.AutomaticFrameAdvance = true
ENT.Spawnable = true
ENT.AdminOnly = true

local ammocrateammo = {
    ["AR2"] = 300,
    ["Pistol"] = 150,
    ["357"] = 32,
    ["Buckshot"] = 64,
    ["SMG1"] = 500,
}

if ( SERVER ) then
    function ENT:Initialize()
        self:SetModel("models/items/ammocrate_smg1.mdl")
        self:PhysicsInit(SOLID_VPHYSICS) 
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)

        local phys = self:GetPhysicsObject()
        if ( phys:IsValid() ) then
            phys:Wake()
            phys:EnableMotion(false)
        end
    end
    
    function ENT:SpawnFunction(ply, trace)
        local angles = ply:GetAngles()

        local entity = ents.Create("ix_ammocrate")
        entity:SetPos(trace.HitPos)
        entity:SetAngles(Angle(0, (entity:GetPos() - ply:GetPos()):Angle().y - 180, 0))
        entity:Spawn()
        entity:Activate()

        return entity
    end
    
    function ENT:Use(ply)
        if ( IsValid(self) ) then
            if ( ( self.nextopen or 0 ) > CurTime() ) then return end
            local ammo = ammocrateammo[game.GetAmmoName(ply:GetActiveWeapon():GetPrimaryAmmoType())]
            if not ( ammo ) then
                ply:Notify("You aren't holding a weapon that has the type of ammunition inside the box.")
                return
            else
                local weapon = ply:GetActiveWeapon()
                if not ( IsValid( weapon ) ) then return end

                timer.Simple(0.25, function()
                    if not ( IsValid(self) and IsValid(ply) and ply:Alive() ) then return end
        
                    self:EmitSound("items/ammo_pickup.wav")
                    ply:EmitSound("items/ammo_pickup.wav")
                    ply:SetAmmo(ammo, weapon:GetPrimaryAmmoType())
                end)
        
                if ( ( self.animationCooldown or 0 ) > CurTime() ) then return end
                self:ResetSequence("open")
                self:EmitSound("items/ammocrate_open.wav")
                timer.Simple(0.5, function()
                    if not ( IsValid(self) and IsValid(ply) and ply:Alive() ) then return end
                    
                    self:ResetSequence("close")
                    self:EmitSound("items/ammocrate_close.wav")
                end)
                self.animationCooldown = CurTime() + 1
            end
            self.nextopen = CurTime() + 1
        end
    end
end