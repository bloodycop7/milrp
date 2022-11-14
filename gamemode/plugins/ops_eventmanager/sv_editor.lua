concommand.Add("mrp_ops_eventmanager", function(ply)
	if not ply:IsEventAdmin() then
		return
	end

	local c = table.Count(mrp.Ops.EventManager.Sequences)

	net.Start("mrpOpsEMMenu")
	net.WriteUInt(c, 8)

	for v,k in pairs(mrp.Ops.EventManager.Sequences) do
		net.WriteString(v)	
	end

	net.Send(ply)
end)