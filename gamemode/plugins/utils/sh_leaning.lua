PLUGIN.name = "Leaning"
PLUGIN.author = "Random Workshop Guy"
if SERVER and game.SinglePlayer() then --https://www.youtube.com/watch?v=Z-E6ynKM7Lo
	hook.Add("FinishMove", "EZLeanFMoveSP", function(ply, mv)
		ply:SetNW2Float("SPLeanSide", mv:GetSideSpeed())
	end)
end

if CLIENT then

	local leandir = 0 -- -1 left, 0 no, 1 right
	local lastleandir = 0

	local leanroll = 0
	local leanroll_lerp = 0
	local leanroll_lerpsmooth = 0
	local leanlastdelta = 0
	local leanlerpsmoothtime = 0

	local leandistcvar = CreateClientConVar("cl_leaning_distance", 1000, true, false)

	local leantargetdist = leandistcvar:GetFloat() * ((1 / engine.TickInterval()) / 66.66)
	local leanlasttargetdist = leantargetdist
	local leantarget = leantargetdist
	local leandone = false

	cvars.AddChangeCallback("cl_leaning_distance", function(name,old,new)
		if new == old then return end
		new = tonumber(new)
		if new <= 0 then new = 1 end
		local tickfix = new*((1 / engine.TickInterval()) / 66.66)
		if tickfix <= 0 then tickfix = 1 end
		leantargetdist = tickfix	
	end)

	local function IsLeaning()
		return leandir != 0
	end

	concommand.Add("+leanleft", function()
		local ply = LocalPlayer()
		if !ply:OnGround() or !ply:Alive() or ply:InVehicle() then return end
		if IsLeaning() then return end
		if leandir == 1 then return end
		if math.abs(leanroll_lerp) > 5 then return end
		leandir = -1
		leantarget = 0
		leandone = false
		leanlerpsmoothtime = CurTime()+0.25
	end)
	concommand.Add("-leanleft", function()
		if leandir == 1 or leandir == 0 then return end
		leandir = 0
		leanroll = 0
		lastleandir = -1
		leanlasttargetdist = math.abs(leantarget)
		leanlastdelta = math.abs(leantarget / leanlasttargetdist)
		leantarget = 0
		leanlerpsmoothtime = CurTime()+0.25
		
		leandone = false
	end)

	concommand.Add("+leanright", function()
		local ply = LocalPlayer()
		if !ply:OnGround() or !ply:Alive() or ply:InVehicle() then return end
		if IsLeaning() then return end
		if leandir == -1 then return end
		if math.abs(leanroll_lerp) > 5 then return end
		leandir = 1
		leantarget = 0
		leandone = false
		leanlerpsmoothtime = CurTime()+0.25
	end)
	concommand.Add("-leanright", function()
		if leandir == -1 or leandir == 0 then return end
		leandir = 0
		leanroll = 0
		lastleandir = 1
		leanlasttargetdist = math.abs(leantarget)
		leanlastdelta = math.abs(leantarget / leanlasttargetdist)
		leantarget = 0
		leanlerpsmoothtime = CurTime()+0.25
		
		leandone = false
	end)

	if game.SinglePlayer() then
		hook.Add("Tick","EZLeanFMove", function()
			local reachedtarget = !(math.abs(leantarget) < leanlasttargetdist)
			if (IsLeaning() or !reachedtarget) and !leandone then
				leantarget = leantarget + LocalPlayer():GetNW2Float("SPLeanSide")
			end
		end)
	else
		hook.Add("FinishMove","EZLeanFMove", function(ply, mv)
			if not IsFirstTimePredicted() then return end
			local reachedtarget = !(math.abs(leantarget) < leanlasttargetdist)
			if (IsLeaning() or !reachedtarget) and !leandone then
				leantarget = leantarget + mv:GetSideSpeed()
			end
		end)
	end

	hook.Add("CreateMove", "EZLeanMove", function(cmd)
		if IsLeaning() then
			local reachedtarget = !(math.abs(leantarget) < leantargetdist)
			local delta = math.abs(leantarget / leantargetdist)
			
			if reachedtarget then
				leandone = true
			end
			
			if (!reachedtarget) and !leandone then
				cmd:SetSideMove(300*leandir)
				cmd:SetForwardMove(0)
			end
		elseif (math.abs(leantarget) < leanlasttargetdist) then
			local delta = math.abs(leantarget / leanlasttargetdist)
			cmd:SetSideMove(300*-lastleandir)
			cmd:SetForwardMove(0)
		end

		if IsLeaning() then
			local eyeang = cmd:GetViewAngles()
			local delta = math.abs(leantarget / leantargetdist)
			if leandone then delta = 1 end

			leanroll = 15*leandir
			leanroll_lerp = Lerp(delta, 0, leanroll)
			leanroll_lerpsmooth = Lerp(0.1, leanroll_lerpsmooth, leanroll_lerp)
			eyeang.z = leanroll_lerpsmooth
			cmd:SetViewAngles(eyeang)
		elseif leanroll_lerp != 0 or leanroll_lerpsmooth != 0 then
			local eyeang = cmd:GetViewAngles()
			local delta = math.abs(leantarget / leanlasttargetdist)
			local deltasmooth = math.max(0, (CurTime() - leanlerpsmoothtime) * 4)

			leanroll_lerp = Lerp(delta, 15*lastleandir*leanlastdelta, leanroll)
			leanroll_lerpsmooth = Lerp(0.1+deltasmooth, leanroll_lerpsmooth, leanroll_lerp)
			eyeang.z = leanroll_lerpsmooth
			cmd:SetViewAngles(eyeang)
		end
	end)

end