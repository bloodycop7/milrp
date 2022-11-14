mrp.Ops = mrp.Ops or {}
mrp.Ops.Snapshots = mrp.Ops.Snapshots or {}

local snapshotCommand = {
    description = "Plays the snapshot specified by the snapshot ID.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local id = arg[1]

        if not tonumber(id) then
        	return ply:Notify("ID must be a number.")
        end

        id = tonumber(id)

        if not mrp.Ops.Snapshots[id] then
        	return ply:Notify("Snapshot could not be found with that ID.")
        end

        ply:Notify("Downloading snapshot #"..id.."...")

        local snapshot = mrp.Ops.Snapshots[id]
        snapshot = pon.encode(snapshot)
		
		net.Start("opsSnapshot")
		net.WriteUInt(id, 16)
		net.WriteUInt(#snapshot, 32)
		net.WriteData(snapshot, #snapshot)
		net.Send(ply)
    end
}

mrp.RegisterChatCommand("/snapshot", snapshotCommand)