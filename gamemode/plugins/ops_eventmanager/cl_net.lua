net.Receive("mrpOpsEMMenu", function()
	local count = net.ReadUInt(8)
	local svSequences = {}

	for i=1, count do
		table.insert(svSequences, net.ReadString())
	end

	if mrp_eventmenu and IsValid(mrp_eventmenu) then
		mrp_eventmenu:Remove()
	end
	
	mrp_eventmenu = vgui.Create("mrpEventManager")
	mrp_eventmenu:SetupPlayer(svSequences)
end)

net.Receive("mrpOpsEMUpdateEvent", function()
	local event = net.ReadUInt(10)

	mrp_OpsEM_LastEvent = event

	mrp_OpsEM_CurEvents = mrp_OpsEM_CurEvents or {}
	mrp_OpsEM_CurEvents[event] = CurTime()
end)

net.Receive("mrpOpsEMClientsideEvent", function()
	local event = net.ReadString()
	local uid = net.ReadString()
	local len = net.ReadUInt(16)
	local prop = pon.decode(net.ReadData(len))

	if not mrp.Ops.EventManager then
		return
	end

	local sequenceData = mrp.Ops.EventManager.Config.Events[event]

	if not sequenceData then
		return
	end

	if not uid or uid == "" then
		uid = nil
	end

	sequenceData.Do(prop or {}, uid)
end)

net.Receive("mrpOpsEMPlayScene", function()
	local scene = net.ReadString()

	if not mrp.Ops.EventManager.Scenes[scene] then
		return print("[mrp] Error! Can't find sceneset: "..scene)
	end

	mrp.Scenes.PlaySet(mrp.Ops.EventManager.Scenes[scene])
end)

local customAnims = customAnims or {}
net.Receive("mrpOpsEMEntAnim", function()
	local entid = net.ReadUInt(16)
	local anim = net.ReadString()

	customAnims[entid] = anim

	timer.Remove("opsAnimEnt"..entid)
	timer.Create("opsAnimEnt"..entid, 0.05, 0, function()
		local ent = Entity(entid)

		if IsValid(ent) and customAnims[entid] and ent:GetSequence() == 0 then
			ent:ResetSequence(customAnims[entid])
		end
	end)
end)