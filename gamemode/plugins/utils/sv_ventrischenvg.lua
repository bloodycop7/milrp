util.AddNetworkString("vrnvgnetequip")
util.AddNetworkString("vrnvgnetflip")
util.AddNetworkString("vrnvgnetbreak")
util.AddNetworkString("vrnvgnetflashlight")
util.AddNetworkString("vrnvgnetbreakeasymode")

util.AddNetworkString("vrnvgnetloadhands")

util.AddNetworkString("vrnvgwarzone")
local drainrate = CreateConVar( "vrnvg_drainrate", 1, {FCVAR_CLIENTCMD_CAN_EXECUTE,FCVAR_ARCHIVE,FCVAR_PROTECTED}, "The battery drain rate for the NVGs.", 0, 10 )
local rechargerate = CreateConVar( "vrnvg_rechargerate", 1, {FCVAR_CLIENTCMD_CAN_EXECUTE,FCVAR_ARCHIVE,FCVAR_PROTECTED}, "The battery recharge rate for the NVGs.", 0, 10 )
local blockchance = CreateConVar( "vrnvg_blockchance", 25, {FCVAR_CLIENTCMD_CAN_EXECUTE,FCVAR_ARCHIVE,FCVAR_PROTECTED}, "The chance of the NVGs taking a bullet for you.", 0, 100 )
util.PrecacheModel( "models/ventrische/c_quadnod2.mdl" )

net.Receive("vrnvgnetflashlight", function(len, ply)
	local bool = net.ReadBool()
	if bool then 
		ply:AllowFlashlight( false )
	else
		ply:AllowFlashlight( true )
	end
end)

concommand.Add("vrnvgequip", function(ply)
	local gun = ply:GetActiveWeapon()

	if gun:IsValid() and !ply.vrnvgbroken and !ply.vrnvgflipped then
		ply.vrnvglast = gun
		ply:SetSuppressPickupNotices(true)
			local vrnvgs = ply:Give("vrnvgs")
			if !IsValid(vrnvgs) then
				vrnvgs = ply:GetWeapon("vrnvgs")
			end

			if IsValid(vrnvgs) then
				vrnvgs.slamholdtype = true
				ply:SelectWeapon("vrnvgs")
			else
				print("broken by another mod, look for a weapon pickup related addon in your addons and disable it")
			end
		ply:SetSuppressPickupNotices(false)
	end
end)

concommand.Add("vrnvgflip", function(ply)
	local gun = ply:GetActiveWeapon()

	if gun:IsValid() and ply.vrnvgequipped and !ply.vrnvgbroken then
		ply.vrnvglast = gun
		ply:SetSuppressPickupNotices(true)
			local vrnvgs = ply:Give("vrnvgs")
			if !IsValid(vrnvgs) then
				vrnvgs = ply:GetWeapon("vrnvgs")
			end

			if IsValid(vrnvgs) then
				vrnvgs.cameraholdtype = true
				ply:SelectWeapon("vrnvgs")
			else
				print("broken by another mod, look for a weapon pickup related addon in your addons and disable it")
			end
		ply:SetSuppressPickupNotices(false)
	elseif gun:IsValid() and ply.vrnvgbroken then 
		ply.vrnvglast = gun
		ply:SetSuppressPickupNotices(true)
			local vrnvgs = ply:Give("vrnvgs")
			if !IsValid(vrnvgs) then
				vrnvgs = ply:GetWeapon("vrnvgs")
			end

			if IsValid(vrnvgs) then
				vrnvgs.brokentoss = true
				ply:SelectWeapon("vrnvgs")
			else
				print("broken by another mod, look for a weapon pickup related addon in your addons and disable it")
			end
		ply:SetSuppressPickupNotices(false)

		timer.Simple(4.5, function()
			if ply:Alive() then
				local brokennvgs = ents.Create( "prop_physics" )
				brokennvgs:SetModel( "models/ventrische/w_quadnods.mdl" )
				brokennvgs:SetPos( ply:GetPos() + Vector(0,0,20) )
				brokennvgs:SetCollisionGroup( COLLISION_GROUP_WEAPON )
				brokennvgs:Spawn()
				local phys = brokennvgs:GetPhysicsObject()
				if IsValid(phys) then
					phys:SetVelocity(ply:EyeAngles():Forward() * 200 - ply:EyeAngles():Right() * 100)
				end

				timer.Simple(15, function()
					if IsValid(brokennvgs) then 
						brokennvgs:Remove()
					end
				end)	
			end
		end)
	end
end)

hook.Add( "ScalePlayerDamage", "vrnvgbrokentosser", function( ply, hitgroup, dmginfo )
	local chance = math.random(0, 100)
	local attacker = dmginfo:GetAttacker()
	--if hitgroup == HITGROUP_HEAD and ply.vrnvgflipped then
	if !attacker:IsPlayer() and ply.vrnvgflipped and chance < blockchance:GetFloat() or attacker:IsPlayer() and hitgroup == HITGROUP_HEAD and ply.vrnvgflipped and chance < blockchance:GetFloat() then
		if dmginfo:IsExplosionDamage() or dmginfo:IsBulletDamage() then
			if !ply.vrnvgbroken then 
				ply.vrnvgbroken = true
	 			net.Start("vrnvgnetbreakeasymode")
				net.WriteBool(true)
				net.Send(ply)

				dmginfo:ScaleDamage(0)
				ply:ViewPunch(Angle(-8,0,0))

				return true
			end
		end
	end
end )

hook.Add( "PlayerDeath", "vrnvgplayerdeath", function( victim, inflictor, attacker )
	if victim.vrnvgequipped or victim.vrnvgbroken then 
		victim.vrnvgflipped = false
		victim.vrnvgequipped = false
		victim.vrnvgbroken = false
	end	
end )

hook.Add( "Think", "vrnvgplayerthinkugh", function(  )
	for k, v in pairs(player.GetAll()) do
		if v.vrnvgequipped and !v.vrnvgflipped and v.vowarzoneenabled then 
			net.Start("vrnvgwarzone")
			net.Send(v)
		end

		if !v.nvgbattery then 
			v.nvgbattery = 80
		end
		
		if v.vrnvgequipped then
			v:SetNW2Bool("vrnvgequipped", true)
			if v.vrnvgflipped then 
				v:SetNW2Bool("vrnvgflipped", true)
			else 
				v:SetNW2Bool("vrnvgflipped", false)
			end
			v:SetNW2Int("vrnvgbattery", 80)
		else 
			v:SetNW2Bool("vrnvgequipped", false)
		end
	end
end )

local function nvgspawnloadhands( ply ) --thank u rp modes
	net.Start("vrnvgnetloadhands")
          net.Send(ply)
end
hook.Add( "PlayerSpawn", "nvgspawnloadhands_hook", nvgspawnloadhands )