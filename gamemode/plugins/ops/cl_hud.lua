local red = Color(255, 0, 0, 255)
local green = Color(0, 240, 0, 255)
local col = Color(255,255,255,120)
local dotToggleTime = 0
local hitgroups = {
	[HITGROUP_GENERIC] = "generic",
	[HITGROUP_HEAD] = "head",
	[HITGROUP_CHEST] = "chest",
	[HITGROUP_STOMACH] = "stomach",
	[HITGROUP_LEFTARM] = "leftarm",
	[HITGROUP_RIGHTARM] = "rightarm",
	[HITGROUP_LEFTLEG] = "leftleg",
	[HITGROUP_RIGHTLEG] = "rightleg",
	[HITGROUP_GEAR] = "belt"
}

hook.Add("HUDPaint", "mrpOpsHUD", function()
	if LocalPlayer():IsAdmin() and LocalPlayer():GetMoveType() == MOVETYPE_NOCLIP and !LocalPlayer():InVehicle() then

		draw.SimpleText("OBSERVER MODE", "mrp-Elements19-Shadow", 20, 10, col)

		local staffOn = 0

		for v,k in pairs(player.GetAll()) do
			if k:IsAdmin() then
				staffOn = staffOn + 1
			end
		end

		draw.SimpleText(staffOn.." STAFF ONLINE", "mrp-Elements18-Shadow", ScrW() * .5, 10, col, TEXT_ALIGN_CENTER)

		if OPS_LIGHT then
			draw.SimpleText("LIGHT ON", "mrp-Elements18-Shadow", ScrW() * .5, 30, col, TEXT_ALIGN_CENTER)
		end

		draw.SimpleText("TOTAL REPORTS: " ..#mrp.Ops.Reports, "mrp-Elements16-Shadow", 20, 30, col)

		local totalClaimed = 0
		for v,k in pairs(mrp.Ops.Reports) do
			if k[3] then
				totalClaimed = totalClaimed + 1

				if k[3] == LocalPlayer() then
					if IsValid(k[1]) then
						draw.SimpleText("REPORTEE: "..k[1]:Nick().." ("..k[1]:Name()..")", "mrp-Elements16-Shadow", 20, 80, green)
					else
						draw.SimpleText("REPORTEE IS INVALID! CLOSE THIS REPORT.", "mrp-Elements16-Shadow", 20, 80, green)
					end
				end
			end
		end

		draw.SimpleText("CLAIMED REPORTS: " ..totalClaimed, "mrp-Elements16-Shadow", 20, 50, col)

		if LocalPlayer():IsAdmin() then
			draw.SimpleText("ENTCOUNT: "..#ents.GetAll(), "mrp-Elements16-Shadow", 20, 100, col)
			draw.SimpleText("PLAYERCOUNT: "..#player.GetAll(), "mrp-Elements16-Shadow", 20, 120, col)

			local y = 160

			for v,k in pairs(player.GetAll()) do
				if k ==  LocalPlayer() then continue end
				
				local pos = (k:GetPos() + k:OBBCenter()):ToScreen()
				local col = team.GetColor(k:Team())


				if k:IsAdmin() and k:GetMoveType() == MOVETYPE_NOCLIP and k:GetNoDraw() then
					draw.SimpleText("** In Observer Mode **", "mrp-Elements18-Shadow", pos.x, pos.y, Color(255, 0, 0), TEXT_ALIGN_CENTER)
				else
					draw.SimpleText(k:Name(), "mrp-Elements18-Shadow", pos.x, pos.y, col, TEXT_ALIGN_CENTER)
				end

				draw.SimpleText(k:Nick(), "mrp-Elements16-Shadow", pos.x, pos.y + 15, mrp.Config.InteractColour, TEXT_ALIGN_CENTER)
			end
		end

		if CUR_SNAPSHOT then
			local snapData = mrp.Ops.Snapshots[CUR_SNAPSHOT]
			mrp.Ops.Snapshots[CUR_SNAPSHOT].VictimNeatName = mrp.Ops.Snapshots[CUR_SNAPSHOT].VictimNeatName or ((IsValid(snapData.Victim) and snapData.Victim:IsPlayer()) and (snapData.VictimNick.." ("..snapData.Victim:Nick()..")") or snapData.VictimID)
			mrp.Ops.Snapshots[CUR_SNAPSHOT].InflictorNeatName = mrp.Ops.Snapshots[CUR_SNAPSHOT].InflictorNeatName or ((IsValid(snapData.Inflictor) and snapData.Inflictor:IsPlayer()) and (snapData.InflictorNick.." ("..snapData.Inflictor:Nick()..")") or snapData.InflictorID)

			draw.SimpleText("VIEWING SNAPSHOT #"..CUR_SNAPSHOT.." (CLOSE WITH F2)", "mrp-Elements16-Shadow", 250, 100, col)
			draw.SimpleText("VICTIM: "..snapData.VictimNeatName.." ["..snapData.VictimID.."]", "mrp-Elements16-Shadow", 250, 120, Color(255, 0, 0))
			draw.SimpleText("ATTACKER: "..snapData.InflictorNeatName.." ["..snapData.InflictorID.."]", "mrp-Elements16-Shadow", 250, 140, Color(0, 255, 0))

			for v,k in pairs(mrp.Ops.SnapshotEnts) do
				local pos = (k:GetPos() + k:OBBCenter()):ToScreen()
				local col = k:GetColor()

				draw.SimpleText(k.IsVictim and snapData.VictimNeatName or snapData.InflictorNeatName, "mrp-Elements18-Shadow", pos.x, pos.y, col, TEXT_ALIGN_CENTER)

				if not k.IsVictim then
					draw.SimpleText("WEP: "..snapData.AttackerClass, "mrp-Elements18-Shadow", pos.x, pos.y + 20, col, TEXT_ALIGN_CENTER)
					draw.SimpleText("HP: "..snapData.InflictorHealth, "mrp-Elements18-Shadow", pos.x, pos.y + 40, col, TEXT_ALIGN_CENTER)
				else
					draw.SimpleText("HITGROUP: "..hitgroups[snapData.VictimHitGroup], "mrp-Elements18-Shadow", pos.x, pos.y + 20, col, TEXT_ALIGN_CENTER)
				end
			end
		end

		if mrp.Ops.EventManager and mrp.Ops.EventManager.GetEventMode() and mrp.Ops.EventManager.GetSequence() then
			local symb = "•"

			if dotToggleTime < CurTime() then
				symb = ""

				if dotToggleTime + 1 < CurTime() then
					dotToggleTime = CurTime() + 1
				end
			end

			draw.SimpleText(symb.." LIVE (CURRENT SEQUENCE: "..mrp.Ops.EventManager.GetSequence()..")", "mrp-Elements18-Shadow", ScrW() - 20, 20, red, TEXT_ALIGN_RIGHT)
		end
	end
end)