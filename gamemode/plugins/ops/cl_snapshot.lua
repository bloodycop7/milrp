mrp.Ops = mrp.Ops or {}
mrp.Ops.SnapshotEnts = mrp.Ops.SnapshotEnts or {}

function mrp.Ops.ClearSnapshot()
	for v,k in pairs(mrp.Ops.SnapshotEnts) do
		k:Remove()
	end

	mrp.Ops.SnapshotEnts = {}
	CUR_SNAPSHOT = nil
end

function mrp.Ops.StartSnapshot(id)
	local data = mrp.Ops.Snapshots[id]

	CUR_SNAPSHOT = id

	local victim = ClientsideModel(data.VictimModel, RENDERGROUP_OPAQUE)
	victim:SetPos(data.VictimPos)
	victim:SetAngles(data.VictimAng)
	victim:SetColor(Color(255, 0, 0))
	victim.IsVictim = true

	for v,k in pairs(data.VictimBodygroups) do
		victim:SetBodygroup(v, k)
	end

	table.insert(mrp.Ops.SnapshotEnts, victim)

	local attacker = ClientsideModel(data.InflictorModel, RENDERGROUP_OPAQUE)
	attacker:SetPos(data.InflictorPos)
	attacker:SetAngles(data.InflictorAng)
	attacker:SetColor(Color(0, 255, 0))

	for v,k in pairs(data.InflictorBodygroups) do
		attacker:SetBodygroup(v, k)
	end

	table.insert(mrp.Ops.SnapshotEnts, attacker)
end

hook.Add("PostDrawTranslucentRenderables", "opsSnapshot3DRender", function()
	if CUR_SNAPSHOT then
		local data = mrp.Ops.Snapshots[CUR_SNAPSHOT]
		render.DrawLine(data.VictimLastPos, data.VictimPos, Color(255, 0, 0))
		render.DrawLine(data.InflictorLastPos, data.InflictorPos, Color(0, 255, 0))

		local tr = util.TraceLine({
			start = data.InflictorEyePos,
			endpos = data.InflictorEyePos + data.InflictorEyeAng:Forward() * 10000
		})

		render.DrawLine(data.InflictorEyePos, tr.HitPos, Color(204, 204, 0))
	end
end)

net.Receive("opsSnapshot", function()
	local id = net.ReadUInt(16)
	local len = net.ReadUInt(32)
	local snapshot = pon.decode(net.ReadData(len))

	mrp.Ops.Snapshots[id] = snapshot

	mrp.Ops.ClearSnapshot()
	mrp.Ops.StartSnapshot(id)

	LocalPlayer():Notify("Loaded snapshot #"..id..".")
end)