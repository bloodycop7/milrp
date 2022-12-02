PLUGIN.name = "Seat Weaponiser"
PLUGIN.author = "BFG9000"

SEAT_WEAPONISER_VERSION2 = true

hook.Add("CanPlayerEnterVehicle", "BFG_WeaponSeats_PlayerWeaponEnabler", function(ply, vehicle, role)
	if ( ply:GetNWBool("SeatWeapon_Usage_Allowed", false) ) then
		ply:SetAllowWeaponsInVehicle(true)
	else
		ply:SetAllowWeaponsInVehicle(false)
	end
end)


hook.Add("OnEntityCreated", "BFG_WeaponSeats_VehicleThink", function(entity) 
	if ( SERVER and entity:IsVehicle() ) then
		function entity:ResetPunchThink()
			local driver = self:GetDriver()
			if ( IsValid(driver) ) then
				if ( driver:GetViewPunchAngles() != Angle(0, 0, 0) ) then
					driver:SetViewPunchAngles(driver:GetViewPunchAngles() * 0.925)
				end
			end
		end
	end
end)

local function GetAllVehicles()
	local entities = ents.GetAll()
	local vehicles = {}
	for k, v in pairs(entities) do
		if ( IsValid(v) and v:IsVehicle() ) then
			table.ForceInsert(vehicles, v)
		end
	end
	
	return vehicles
end

hook.Add("Think", "BFG_WeaponSeats_Callback2", function()
	for k, v in pairs(GetAllVehicles()) do
		if ( IsValid(v) and v.ResetPunchThink ) then
			v:ResetPunchThink()
		end
	end
end)

if not ( meta._BEyeAngles_WeaponSeatsBackup ) then
	meta._BEyeAngles_WeaponSeatsBackup = entMeta.EyeAngles
end
function meta:EyeAngles()
	if ( self:InVehicle() and self:GetNWBool("SeatWeapon_Usage_Allowed", false) ) then
		return self:GetAimVector():Angle()
	else
		return self:_BEyeAngles_WeaponSeatsBackup()
	end
end

if not ( meta._BSetEyeAngles_WeaponSeats ) then
	meta._BSetEyeAngles_WeaponSeats = meta.SetEyeAngles
end

function meta:SetEyeAngles(targetangle)
	if ( self:InVehicle() and self:GetNWBool("SeatWeapon_Usage_Allowed", false) ) then
		local calcangle = self:GetVehicle():WorldToLocalAngles(targetangle)
		self:_BSetEyeAngles_WeaponSeats(calcangle)
	else
		self:_BSetEyeAngles_WeaponSeats(targetangle)
	end
end

if not ( meta._BViewPunch_WeaponSeats ) then
	meta._BViewPunch_WeaponSeats = meta.ViewPunch
end

function meta:ViewPunch(ang)
	if ( self:InVehicle() ) then
		self:SetViewPunchAngles(ang)
	else
		return self:_BViewPunch_WeaponSeats(ang)
	end
end

if ( SERVER ) then
	util.AddNetworkString("WeaponSeats_ToggleCommand")

	net.Receive("WeaponSeats_ToggleCommand", function(len, ply)
		ply:SetNWBool("SeatWeapon_Usage_Allowed", (!ply:GetNWBool("SeatWeapon_Usage_Allowed", false)))
		if ( ply:InVehicle() ) then
			local vehicle = ply:GetVehicle()
			ply:ExitVehicle()
			ply:EnterVehicle(vehicle) 
		end
	end)

	hook.Add("EntityTakeDamage", "BFG_WeaponSeats_DamageFilter", function( target, dmginfo )
		if ( target:IsPlayer() and target:InVehicle() and target:GetNWBool("SeatWeapon_Usage_Allowed", false) ) then
			if ( dmginfo:GetAttacker() == target ) and ( not dmginfo:IsExplosionDamage() ) then
				dmginfo:ScaleDamage(0)
			end
		end
	end)
end

if ( CLIENT ) then
	hook.Add("CalcView", "BFG_WeaponSeats_CalcVehViewCompensation", function(ply, pos, ang)
		if ( IsValid(ply:GetVehicle()) and ply:GetNWBool("SeatWeapon_Usage_Allowed", false) ) then
			local oldang = ang
			
			ang:Set(ply:EyeAngles() + ply:GetViewPunchAngles())
			
			local localvec, localang = WorldToLocal( Vector(0, 0, 0), ang, Vector(0, 0, 0), ply:GetVehicle():GetAngles())
			
			ang:RotateAroundAxis( ang:Forward() * -1, localang.r)
		end
	end)

	hook.Add("CalcViewModelView", "BFG_WeaponSeats_CalcViewModelViewCompensation", function(wep, vm, oldpos, newpos, oldang, newang)
		if ( IsValid(vm:GetOwner()) ) then
			local ply = vm:GetOwner()
			if ( ply:GetNWBool("SeatWeapon_Usage_Allowed", false) ) then
				if ( ply:InVehicle() ) then
					if ( IsValid(ply:GetVehicle()) ) then
						newang:Set(ply:EyeAngles() + ply:GetViewPunchAngles())
						local localvec, localang = WorldToLocal(Vector(0, 0, 0), newang, Vector(0, 0, 0), ply:GetVehicle():GetAngles())		
						newang:RotateAroundAxis(newang:Forward() * -1, localang.r)
					end
				end
			end
		end
	end)

	hook.Add("ContextMenuOpen", "BFG_WeaponSeats_Toggle", function()
		local ply = LocalPlayer()
		if not ( ply.SeatWeaponizer_LastEnteredContextMenu ) then 
			ply.SeatWeaponizer_LastEnteredContextMenu = 0 
		end
		
		if ( CurTime() - ply.SeatWeaponizer_LastEnteredContextMenu < .5 ) then
			ply:ConCommand("weaponseats_toggle")
		end
		
		ply.SeatWeaponizer_LastEnteredContextMenu = CurTime()
	end)
		
	concommand.Add("weaponseats_toggle", function(ply, cmd, args, argstring)
		net.Start("WeaponSeats_ToggleCommand")
		net.SendToServer()
	end, nil, "Toggle using weapons in seats.")
end