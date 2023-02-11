function meta:SetRPName(name)
	hook.Run("PlayerRPNameChanged", self, self:Name(), name)

	self:SetSyncVar(SYNC_RPNAME, name, true)
end

function meta:GetSavedRPName()
	return self.defaultRPName
end

local function canHearCheck(listener) -- based on darkrps voice chat optomization this is called every 0.5 seconds in the think hook
	if not IsValid(listener) then return end

	listener.CanHear = listener.CanHear or {}
	local listPos = listener:GetShootPos()
	local voiceDistance = 550 ^ 2

	for _,speaker in ipairs(player.GetAll()) do
		listener.CanHear[speaker] = (listPos:DistToSqr(speaker:GetShootPos()) < voiceDistance)
		hook.Run("PlayerCanHearCheck", listener, speaker)
	end
end
util.AddNetworkString("mrpScenePVS")

net.Receive("mrpScenePVS", function(len, ply)
	if (ply.nextPVSTry or 0) > CurTime() then return end
	ply.nextPVSTry = CurTime() + 1

	if ply:Team() == 0 or ply.allowPVS then -- this code needs to be looked at later on, it trusts client too much, pvs locations should be stored in a shared tbl
		local pos = net.ReadVector()
		local last = ply.lastPVS or 1

		if last == 1 then
			ply.extraPVS = pos
			ply.lastPVS = 2
		else
			ply.extraPVS2 = pos
			ply.lastPVS = 1
		end

		timer.Simple(1.33, function()
			if not IsValid(ply) then
				return
			end

			if last == 1 then
				ply.extraPVS2 = nil
			else
				ply.extraPVS = nil
			end
		end)
	end
end)

function GM:Think()
    for k, v in ipairs(player.GetAll()) do
		if ( v and IsValid(v) and v:Alive() ) then
			
			if not v.nextHearUpdate or v.nextHearUpdate < CurTime() then -- optimized version of canhear hook based upon darkrp
				canHearCheck(v)
				v.nextHearUpdate = CurTime() + 0.65
			end
			
			if not ( v.fov ) then
				v.fov = v:GetFOV() or 95
			end

			if not ( v.runspeed ) then
				v.runspeed = 200
			end

			if not ( v.walkspeed ) then
				v.walkspeed = 100
			end

			if not ( v.isPlayingSound ) then
				v.isPlayingSound = false
			end

			if not ( v.isLazy ) then
				v.isLazy = false
			end
			
			if ( v:Health() < 100 ) then
				if ( v.canRestoreHealth or true ) then
					if ( v.nextHealthAdd or 0 ) < CurTime() then
						v:SetHealth(v:Health() + 1)
						v.nextHealthAdd = CurTime() + 0.7
					end
				end
			end

			if ( v:Health() < 10 ) then
				v.runspeed = 90
				v.walkspeed = 90
			end

			local wep = v:GetActiveWeapon()

			if ( IsValid(wep) ) then
				v:SetAmmo(9999, wep:GetPrimaryAmmoType())
			end

			if ( IsValid(v:GetActiveWeapon()) ) then
				local wep = v:GetActiveWeapon()

				if ( wep.GetToggleAim ) then
					if ( wep:GetToggleAim() ) then
						v.walkspeed = 70
					else
						v.walkspeed = 100
					end
				else
					v.walkspeed = 100
				end
			end

			if ( v:IsSprinting() and v:GetVelocity():Length() != 0 ) then
				v.runspeed = Lerp(0.0030, v.runspeed, 320)
				v.fov = Lerp(0.1, v.fov or 95, 110)
			else
				v.runspeed = Lerp(0.01, v.runspeed, 200)
				v.fov = Lerp(0.1, v.fov or 95, 95)
			end

			if ( mrp.StaminaEnabled ) then
				if ( v.isLazy ) then
					v.runspeed = 100
					v.walkspeed = 100

					if not ( v.isPlayingSound ) then
						v:EmitSound("player/breathe1.wav")
						v:EmitSound("player/heartbeat1.wav")
						v.isPlayingSound = true

						timer.Simple(SoundDuration("player/breathe1.wav"), function()
							v:StopSound("player/breathe1.wav")
							v:StopSound("player/heartbeat1.wav")
							v.isPlayingSound = false
						end)
					end
				end
				
				if not ( timer.Exists(v:SteamID64().."RunTimer") ) then
					timer.Create(v:SteamID64().."RunTimer", 0, 0, function()
						if not ( v:GetMoveType() == MOVETYPE_NOCLIP ) then
							if ( v.runspeed > 300 ) then
								v.isLazy = true
								timer.Simple(5, function()
									v.isLazy = false
								end)
							end
						end
					end)
				else
					timer.Remove(v:SteamID64().."RunTimer")
					timer.Create(v:SteamID64().."RunTimer", 0, 0, function()
						if not ( v:GetMoveType() == MOVETYPE_NOCLIP ) then
							if ( v.runspeed > 300 ) then
								v.isLazy = true
								timer.Simple(5, function()
									v.isLazy = false
								end)
							end
						end
					end)
				end
			end
			
			v:SetRunSpeed(v.runspeed)
			v:SetFOV(v.fov)
			v:SetWalkSpeed(v.walkspeed)
			local veh = v:GetVehicle()
			
			if ( veh and IsValid(veh) ) then
				local heli = veh:GetParent()
				
				if ( heli and IsValid(heli) ) then
					if ( heli.SetAmmoPrimary ) then
						heli:SetAmmoPrimary(3)
					end
					
					if ( heli.SetAmmoSecondary ) then
						heli:SetAmmoSecondary(3)
					end
					
					if ( heli.SetAmmoTertiary ) then
						heli:SetAmmoTertiary(3)
					end
				end
			end
		
		end
    end
end

function GM:PlayerDisconnected(ply)
	if ( timer.Exists(ply:SteamID64().."RunTimer") ) then
		timer.Remove(ply:SteamID64().."RunTimer")
	end

	if ( timer.Exists(ply:SteamID64().."Bleed") ) then
		timer.Remove(ply:SteamID64().."Bleed")
	end
end

function GM:PlayerInitialSpawn(ply)	
    timer.Simple(1, function()
        ply:KillSilent()
        ply:SendLua([[vgui.Create("MilMainMenu")]])
    end)
end

local talkCol = Color(255, 255, 100)
local infoCol = Color(135, 206, 250)
local strTrim = string.Trim
function GM:PlayerSay(ply, text, teamChat, newChat)
	if teamChat == true then return "" end -- disabled team chat

	text = strTrim(text, " ")

	hook.Run("iPostPlayerSay", ply, text)

	if string.StartWith(text, "/") then
		local args = string.Explode(" ", text)
		local command = mrp.chatCommands[string.lower(args[1])]
		if command then
			if command.cooldown and command.lastRan then
				if command.lastRan + command.cooldown > CurTime() then
					return ""
				end
			end

			if command.adminOnly == true and ply:IsAdmin() == false then
				ply:Notify("You must be an admin to use this command.")
				return ""
			end

			if command.leadAdminOnly == true and not ply:IsLeadAdmin() then
				ply:Notify("You must be a lead admin to use this command.")
				return ""
			end

			if command.superAdminOnly == true and ply:IsSuperAdmin() == false then
				ply:Notify("You must be a super admin to use this command.")
				return ""
			end

			if command.requiresArg and (not args[2] or string.Trim(args[2]) == "") then return "" end
			if command.requiresAlive and not ply:Alive() then return "" end

			text = string.sub(text, string.len(args[1]) + 2)

			table.remove(args, 1)
			command.onRun(ply, args, text)
		else
			ply:Notify("The command "..args[1].." does not exist.")
		end
	elseif ply:Alive() then
		text = hook.Run("ProcessICChatMessage", ply, text) or text
		text = hook.Run("ChatClassMessageSend", 1, text, ply) or text

		for v,k in pairs(player.GetAll()) do
			if (ply:GetPos() - k:GetPos()):LengthSqr() <= (300 ^ 2) then
				k:SendChatClassMessage(1, text, ply)
			end
		end

		hook.Run("PostChatClassMessageSend", 1, text, ply)
	end

	return ""
end

util.AddNetworkString("mrpChatMessage")

net.Receive("mrpChatMessage", function(len, ply) -- should implement a check on len here instead of string.len
	if (ply.nextChat or 0) < CurTime() then
		if len > 15000 then
			ply.nextChat = CurTime() + 1 
			return
		end

		local text = net.ReadString()
		ply.nextChat = CurTime() + 0.3 + math.Clamp(#text / 300, 0, 4)
		
		text = string.sub(text, 1, 1024)
		text = string.Replace(text, "\n", "")
		hook.Run("PlayerSay", ply, text, false, true)
	end
end)

util.AddNetworkString("milMainMenuSpawn")

net.Receive("milMainMenuSpawn", function(len, ply)
	if ( ply:Team() == 0 ) then
        ply:SetTeam(TEAM_SOLDIER)
    end

    if ( ply.firstMenuSpawn or true ) then
        ply:Spawn()
		ply.firstMenuSpawn = false
    end
	
	local name = net.ReadString()

	ply:SetRPName(name)
	
	hook.Run("PlayerLoadout", ply)
    
    local modelr = "models/bread/cod/characters/milsim/shadow_company.mdl"
	if ( isstring(mrp.Teams.Stored[ply:Team()].model) ) then
		modelr = mrp.Teams.Stored[ply:Team()].model
	elseif ( istable(mrp.Teams.Stored[ply:Team()].model) ) then
		modelr = table.Random(mrp.Teams.Stored[ply:Team()].model)
	end

    ply:Give("gmod_tool")
    ply:Give("weapon_physgun")
    ply:Give("mrp_hands")
    ply:Give("apexswep")
    ply:SetModel(modelr)
    ply:Give("mrp_rappel")
	ply:SetRunSpeed(200)
    ply:SetArmor(100)
    ply:SetWalkSpeed(100)
    ply:SetJumpPower(160)
    ply:SetDuckSpeed(0.5)
    ply:SetUnDuckSpeed(0.5)
    ply:SetLadderClimbSpeed(100)
    ply:SetCrouchedWalkSpeed(0.6)
	ply:SetupHands(ply)
    if ( timer.Exists(ply:SteamID64().."Bleed") ) then
        timer.Remove(ply:SteamID64().."Bleed")
    end
	
	local class = mrp.Teams.Stored[ply:Team()].classes[ply:GetTeamClass()]
    
    if ( class ) then
        if ( class.loadout ) then
            for k, v in pairs(class.loadout) do
                ply:Give(v) 
            end
        end
    end
end)

util.AddNetworkString("milMainMenuChangeName")
util.AddNetworkString("milCallsignSet")

net.Receive("milCallsignSet", function(len, ply)
	local callsign = net.ReadString()

	ply:SetSyncVar(SYNC_CALLSIGN, callsign, true)
end)

net.Receive("milMainMenuChangeName", function(len, ply)
	if (ply.nextRPNameTry or 0) > CurTime() then return end
	ply.nextRPNameTry = CurTime() + 2

	local name = net.ReadString()

	local canUseName, output = mrp.CanUseName(name)

	if canUseName then
		ply:SetRPName(output)

		hook.Run("PlayerChangeRPName", ply, output)
		
		ply:Notify("You have changed your name to "..output..".")
	else
		ply:Notify("Name rejected: "..output)
	end
end)

function GM:PostCleanupMap()
	hook.Run("InitPostEntity")
end

function GM:GetFallDamage(ply, speed)
	return (speed - 580) * (100 / 444)
end

concommand.Add("mrp_vehicle_collision", function(ply, cmd, args)
	local veh = ply:GetVehicle()

	if ( veh and IsValid(veh) ) then
		local rveh = veh:GetParent()
		if ( rveh ) then
			rveh:SetSyncVar(SYNC_COLLISIONS, (!rveh:GetSyncVar(SYNC_COLLISIONS, false)), true)
			if ( rveh:GetSyncVar(SYNC_COLLISIONS, false) ) then
				print("isOn")
				veh:SetCollisionGroup(COLLISION_GROUP_VEHICLE_CLIP)
				rveh:SetCollisionGroup(COLLISION_GROUP_VEHICLE_CLIP)
			else
				print("isOff")
				veh:SetCollisionGroup(0)
				rveh:SetCollisionGroup(0)
			end
		end
	end
end)

hook.Add("CanBreakHelicopterRotor", "TesthisLFSHook", function(ply, heli)
	if ( heli:GetCollisionGroup() == COLLISION_GROUP_VEHICLE_CLIP ) then return false end
	return true
end)

hook.Add("LFS.IsEngineStartAllowed", "alwaysAllowLFSStart", function()
	return true
end)

function GM:CanPlayerEnterVehicle(ply, vch, seatnumber)
	if ( ply:KeyDown(IN_WALK) ) then
		return false
	end

	return true
end

util.AddNetworkString("mrpLocaShow")
function GM:PlayerSpawn(ply, transition)
	if ( ply:Team() == 0 ) then
		ply:SetTeam(1)
	end
	
	local modelr = "models/bread/cod/characters/milsim/shadow_company.mdl"
	if ( isstring(mrp.Teams.Stored[ply:Team() or 1].model) ) then
		modelr = mrp.Teams.Stored[ply:Team() or 1].model
	elseif ( istable(mrp.Teams.Stored[ply:Team() or 1].model) ) then
		modelr = table.Random(mrp.Teams.Stored[ply:Team() or 1].model)
	end

    ply:Give("gmod_tool")
    ply:Give("weapon_physgun")
    ply:Give("mrp_hands")
    ply:Give("apexswep")
    ply:SetModel(modelr)
    ply:Give("mrp_rappel")
	ply:SetRunSpeed(200)
    ply:SetArmor(100)
    ply:SetWalkSpeed(100)
    ply:SetJumpPower(160)
    ply:SetDuckSpeed(0.5)
    ply:SetUnDuckSpeed(0.5)
    ply:SetLadderClimbSpeed(100)
    ply:SetCrouchedWalkSpeed(0.6)
	ply:SetupHands(ply)
    if ( timer.Exists(ply:SteamID64().."Bleed") ) then
        timer.Remove(ply:SteamID64().."Bleed")
    end
	
	local class = mrp.Teams.Stored[ply:Team()].classes[ply:GetTeamClass()]
    
    if ( class ) then
        if ( class.loadout ) then
            for k, v in pairs(class.loadout) do
                ply:Give(v) 
            end
        end
    end
	
	net.Start("mrpLocaShow")
	net.Send(ply)
end

util.AddNetworkString("mrpSetTeamIndex")
util.AddNetworkString("mrpSetTeamClass")

net.Receive("mrpSetTeamClass", function(len, ply)
	if (ply.lastTeamTry or 0) > CurTime() then return end
	ply.lastTeamTry = CurTime() + 1
	
	local classID = net.ReadUInt(8)
	local classes = mrp.Teams.Stored[ply:Team()].classes

	if classID and isnumber(classID) and classID > 0 and classes and classes[classID] then
		if ply:CanBecomeTeamClass(classID, true) then
			ply:SetTeamClass(classID)
			ply:Notify("Your class is now "..classes[classID].name..".")
		end
	end
end)

net.Receive("mrpSetTeamIndex", function(len, ply)
	if (ply.lastTeamTry or 0) > CurTime() then return end
	ply.lastTeamTry = CurTime() + 1

	local teamID = net.ReadUInt(8)

	if teamID and isnumber(teamID) and mrp.Teams.Stored[teamID] then
		if ply:CanBecomeTeam(teamID, true) then
			ply:SetTeam(teamID)
			ply:Notify("Your team is now "..team.GetName(teamID)..".")
		end
	end

	hook.Run("PlayerLoadout", ply)
end)

util.AddNetworkString("mrpNotify")
util.AddNetworkString("mrpCaptionAdd")

function GM:PlayerCanPickupItem(ply, ent)
	if ( ent:GetClass() == "item_healthkit" or ent:GetClass() == "item_healthvial" or ent:GetModel() == "models/grub_nugget_small.mdl" or ent:GetModel() == "models/grub_nugget_medium.mdl" or ent:GetModel() == "models/grub_nugget_large.mdl" or ent:GetClass() == "item_healthcharger" ) then
		if ( ply:GetSyncVar(SYNC_BLEEDING, false) ) then
			ply:SetSyncVar(SYNC_BLEEDING, false, true)
			ply:Notify("You have stopped bleeding!", Color(0, 255, 0, 255))

			if ( timer.Exists(ply:SteamID64().."Bleed") ) then
				timer.Remove(ply:SteamID64().."Bleed")
			end
		end
	end

	return true
end

function GM:PlayerCanHearPlayersVoice(listener, talker)
	if not talker:Alive() then return false end
	local canHear = listener.CanHear and listener.CanHear[talker]
	
	if ( talker:GetSyncVar(SYNC_RADIOENABLED, false) ) then
		if ( listener:GetSyncVar(SYNC_RCHANNEL, 0) == talker:GetSyncVar(SYNC_RCHANNEL, 0) ) then
			return true
		end
	end
	
	return canHear, true
end

function GM:PlayerSpawnedSENT(ply, ent)
	if ( ent:GetClass() == "hb_extended_missile_moskit" or ent:GetClass() == "hb_extended_main_mk82" or ent:GetClass() == "hb_extended_main_t12" ) then
		ent:GetPhysicsObject():SetMass(75)
	end
end

function GM:PostEntityTakeDamage(trg, damage)
	if ( mrp.BleedingEnabled ) then
		if ( trg:IsPlayer() ) then
			if not ( trg:GetMoveType() == MOVETYPE_NOCLIP ) then
				if not ( damage:GetDamageType() == DMG_BURN or damage:GetDamageType() == DMG_SLOWBURN or damage:GetDamageType() == DMG_SHOCK ) then
					if not ( trg:GetSyncVar(SYNC_BLEEDING, false) ) then
						trg:SetSyncVar(SYNC_BLEEDING, true, true)
						trg:Notify("You have started bleeding!", Color(255, 0, 0, 255))
						if not ( timer.Exists(trg:SteamID64().."Bleed") ) then
							timer.Create(trg:SteamID64().."Bleed", math.random(10, 25), 0, function()
								if ( trg:Health() > 40 ) then
									trg:SetHealth(trg:Health() - 10)
									trg:EmitSound("player/pl_pain5.wav")
								end
							end)
						end
					end
				end
			end
		end
	end
	
	if ( trg:IsPlayer() ) then
		if ( trg:GetMoveType() == MOVETYPE_NOCLIP ) then
			return false	
		end
		
		if ( trg.canRestoreHealth ) then
			trg.canRestoreHealth = false
		end
		
		if not ( timer.Exists(trg:SteamID64().."HealthRegenerate") ) then
			timer.Create(trg:SteamID64().."HealthRegenerate", 3, 1, function()
				if not ( trg.canRestoreHealth ) then
					trg.canRestoreHealth = true
				end
			end)
		else
			timer.Remove(trg:SteamID64().."HealthRegenerate")
			timer.Create(trg:SteamID64().."HealthRegenerate", 3, 1, function()
				if not ( trg.canRestoreHealth ) then
					trg.canRestoreHealth = true
				end
			end)
		end
		
		if ( mrp.EnabledDamageFlinch ) then
			if ( damage:IsBulletDamage() ) then
				trg:ViewPunch(Angle(math.Rand(-10, -5), 0, math.Rand(0, 5)))
			end
		end
	end
	
	return true
end

hook.Add("PlayerButtonDown", "HelicopterRappeling", function(ply, btn)
	if ( ply:InVehicle() ) then
		if ( ply:GetVehicle():GetParent() ) then
			local heli = ply:GetVehicle():GetParent()
			
			if not ( ply.rappelling ) then
				if ( heli.Base ) then
					if ( heli.Base:find("lunasflightschool_basescript") ) then
						if ( btn == KEY_E ) then
							if ( ply:KeyDown(IN_WALK) ) then
								if ( heli:GetEngineActive() ) then
									local useFunc = heli:Use(ply, ply)
									ply.lastVeh = ply:GetVehicle()
									ply.lastlfsVeh = heli
									ply.vehicleRappel = true
									ply.canRappel = false
									ply:ExitVehicle()
									ply:SetPos(heli:GetPos() - Vector(0, 0, 300))
									
									local attachmentIndex
					
									attachmentIndex = ply:LookupAttachment("chest")

									local attachment = ply:GetAttachment(attachmentIndex)

									if (attachmentIndex == 0 or attachmentIndex == -1) then
										attachment = {Pos = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Pelvis"))}
										attachmentIndex = ply:LookupAttachment("forward")
									end

									local rappelRope = ents.Create("keyframe_rope")

										if ( attachmentIndex ) then
											rappelRope:SetParent(heli, attachmentIndex)
										else
											rappelRope:SetParent(heli, 0)
										end
							
										hook.Add("Think", "HelicopterPosUpdate", function()
											if ( IsValid(rappelRope) ) then
												if not ( rappelRope:GetInternalVariable("EndOffset") == tostring(heli:GetPos()) ) then
													rappelRope:SetKeyValue("EndOffset", tostring(heli:GetPos()))
												end
												
												if not ( tostring(ply.rappelPos) == rappelRope:GetInternalVariable("EndOffset") ) then
													ply.rappelPos = rappelRope:GetParent():GetPos()
												end
											else
												hook.Remove("Think", "HelicopterPosUpdate")
											end
										end)
										rappelRope:SetPos(ply:GetPos())
										rappelRope:SetColor(Color(150, 150, 150))

										rappelRope:SetEntity("StartEntity", ply)
										rappelRope:SetEntity("EndEntity", Entity(0))
										rappelRope:SetKeyValue("Width", "1")
										rappelRope:SetKeyValue("Collide", "1")
										rappelRope:SetKeyValue("RopeMaterial", "cable/cable")
										rappelRope:SetKeyValue("EndOffset", tostring(heli:GetPos()))
										rappelRope:SetKeyValue("EndBone", "0")
									ply.rappelRope = rappelRope

									ply:DeleteOnRemove(rappelRope)
									heli:DeleteOnRemove(rappelRope)
									ply:EmitSound("physics/surfaces/tile_impact_bullet4.wav")
									ply.rappelling = true
									ply.rappelPos = ply:GetPos()
									heli:SetCollisionGroup(COLLISION_GROUP_WEAPON)
									timer.Simple(0.1, function()
										heli:SetCollisionGroup(0)
										ply.canRappel = true
									end)
									heli.Use = function()
										ply:EnterVehicle(ply.lastVeh)
										RemoveRope(ply)
										ply.canRappel = false
										timer.Simple(0.1, function()
											heli:SetCollisionGroup(0)
											ply.canRappel = true
										end)
									end
								end
							end
						end
					end
				end
			end
		end
	else
		local wep = ply:GetActiveWeapon()
		
		if ( IsValid(wep) ) then
			if ( btn == KEY_G ) then
				if ( ply:KeyDown(IN_WALK) ) then
					local trg = ply:GetEntityInFront()
					
					if ( trg and IsValid(trg) and trg:IsPlayer() ) then
						if not ( trg:HasWeapon(wep:GetClass()) ) then
							trg:Give(wep:GetClass())
							trg:GetWeapon(wep:GetClass()):SetClip1(wep:Clip1())
							ply:StripWeapon(wep:GetClass())
							ply:SelectWeapon("mrp_hands")
						else
							ply:Notify("This player already has this weapon!", Color(0, 185, 255))
						end
					end
				end
			end
		end
	end
end)

function GM:PlayerSwitchFlashlight(ply, bool)
	if ( ply:GetMoveType() == MOVETYPE_NOCLIP ) then 
		return false
	end
	
	return true
end

function GM:PlayerFootstep(ply, pos, foot, sound, vol, filter)
	local newsound
	if ( sound:find("concrete") ) then
		newsound = "player/mrpfootsteps/concrete"..math.random(1, 4)..".wav"
	elseif ( sound:find("dirt") ) then
		newsound = "player/mrpfootsteps/dirt"..math.random(1, 4)..".wav"
	elseif ( sound:find("grass") ) then
		newsound = "player/mrpfootsteps/grass"..math.random(1, 4)..".wav"
	elseif ( sound:find("metal") and !sound:find("metalgrate")) then
		newsound = "player/mrpfootsteps/metal"..math.random(1, 4)..".wav"
	elseif ( sound:find("metalgrate") ) then
		newsound = "player/mrpfootsteps/metalgrate"..math.random(1, 4)..".wav"
	elseif ( sound:find("sand") ) then
		newsound = "player/mrpfootsteps/sand"..math.random(1, 4)..".wav"
	elseif ( sound:find("tile") ) then
		newsound = "player/mrpfootsteps/tile"..math.random(1, 4)..".wav"
	elseif ( sound:find("wood") ) then
		newsound = "player/mrpfootsteps/wood"..math.random(1, 4)..".wav"
	else
		newsound = "player/mrpfootsteps/tile"..math.random(1, 4)..".wav"
	end
	
	local ang = Angle(-0.4, 0, 0)
	
	if ( ply:IsSprinting() ) then
		ang = Angle(2.5, 0, 0)
	end
	
	if not ( ply:KeyDown(IN_WALK) or ply:KeyDown(IN_DUCK) ) then
		ply:ViewPunch(ang)
		ply:EmitSound(newsound, 100, 100, vol)
	end
		
	return true
end

function GM:PlayerDeathSound(ply)
	return true
end

function meta:SendCL(luacode)
	self:SendLua(luacode)
end