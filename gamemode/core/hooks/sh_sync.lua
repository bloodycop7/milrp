mrp.Sync = mrp.Sync or {}
mrp.Sync.Vars = mrp.Sync.Vars or {}
mrp.Sync.VarsConditional = mrp.Sync.VarsConditional or {}
mrp.Sync.Data = mrp.Sync.Data or {}
local syncVarsID = 0

SYNC_ID_BITS = 8
SYNC_MAX_VARS = 255

SYNC_BOOL = 1
SYNC_STRING =  2
SYNC_INT = 3
SYNC_BIGINT = 4
SYNC_HUGEINT = 5
SYNC_MINITABLE = 6
SYNC_INTSTACK = 7

SYNC_TYPE_PUBLIC = 1
SYNC_TYPE_PRIVATE = 2

local entMeta = FindMetaTable("Entity")

function mrp.Sync.RegisterVar(type, conditional)
	syncVarsID = syncVarsID + 1

	if syncVarsID > SYNC_MAX_VARS then
		print("[mrp] WARNING: Sync var limit hit! (255)")
	end

	mrp.Sync.Vars[syncVarsID] = type

	if conditional then
		mrp.Sync.VarsConditional[syncVarsID] = conditional
	end

	return syncVarsID
end

local ioRegister = {}
ioRegister[SERVER] = {}
ioRegister[CLIENT] = {}

function mrp.Sync.DoType(type, value)
	return ioRegister[SERVER or CLIENT][type](value)
end

if CLIENT then
	function entMeta:GetSyncVar(varID, fallback)
		local targetData = mrp.Sync.Data[self.EntIndex(self)]

		if targetData != nil then
			if targetData[varID] != nil then
				return targetData[varID]
			end
		end
		return fallback
	end

	net.Receive("iSyncU", function(len)
		local targetID = net.ReadUInt(16)
		local varID = net.ReadUInt(SYNC_ID_BITS)
		local syncType = mrp.Sync.Vars[varID]
		local newValue = mrp.Sync.DoType(syncType)
		local targetData = mrp.Sync.Data[targetID]

		if not targetData then
			mrp.Sync.Data[targetID] = {}
			targetData = mrp.Sync.Data[targetID]
		end

		targetData[varID] = newValue

		hook.Run("OnSyncUpdate", varID, targetID, newValue)
	end)

	net.Receive("iSyncUlcl", function(len)
		local targetID = net.ReadUInt(8)
		local varID = net.ReadUInt(SYNC_ID_BITS)
		local syncType = mrp.Sync.Vars[varID]
		local newValue = mrp.Sync.DoType(syncType)
		local targetData = mrp.Sync.Data[targetID]

		if not targetData then
			mrp.Sync.Data[targetID] = {}
			targetData = mrp.Sync.Data[targetID]
		end

		targetData[varID] = newValue

		hook.Run("OnSyncUpdate", varID, targetID, newValue)
	end)

	net.Receive("iSyncR", function()
		local targetID = net.ReadUInt(16)

		mrp.Sync.Data[targetID] = nil
	end)

	net.Receive("iSyncRvar", function()
		local targetID = net.ReadUInt(16)
		local varID = net.ReadUInt(SYNC_ID_BITS)
		local syncEnt = mrp.Sync.Data[targetID]

		if syncEnt then
			if mrp.Sync.Data[targetID][varID] != nil then
				mrp.Sync.Data[targetID][varID] = nil
			end
		end

		hook.Run("OnSyncUpdate", varID, targetID)
	end)
end

ioRegister[SERVER][SYNC_BOOL] = function(val) return net.WriteBool(val) end
ioRegister[CLIENT][SYNC_BOOL] = function(val) return net.ReadBool() end
ioRegister[SERVER][SYNC_INT] = function(val) return net.WriteUInt(val, 8) end
ioRegister[CLIENT][SYNC_INT] = function(val) return net.ReadUInt(8) end
ioRegister[SERVER][SYNC_BIGINT] = function(val) return net.WriteUInt(val, 16) end
ioRegister[CLIENT][SYNC_BIGINT] = function(val) return net.ReadUInt(16) end
ioRegister[SERVER][SYNC_HUGEINT] = function(val) return net.WriteUInt(val, 32) end
ioRegister[CLIENT][SYNC_HUGEINT] = function(val) return net.ReadUInt(32) end
ioRegister[SERVER][SYNC_STRING] = function(val) return net.WriteString(val) end
ioRegister[CLIENT][SYNC_STRING] = function(val) return net.ReadString() end
ioRegister[SERVER][SYNC_MINITABLE] = function(val) return net.WriteData(pon.encode(val), 32) end
ioRegister[CLIENT][SYNC_MINITABLE] = function(val) return pon.decode(net.ReadData(32)) end
ioRegister[SERVER][SYNC_INTSTACK] = function(val) 
	local count = net.WriteUInt(#val, 8)

	for v,k in pairs(val) do
		net.WriteUInt(k, 8)
	end

	return
end
ioRegister[CLIENT][SYNC_INTSTACK] = function(val) 
	local count = net.ReadUInt(8)
	local compiled =  {}

	for k = 1, count do
		table.insert(compiled, (net.ReadUInt(8)))
	end

	return compiled
end

SYNC_RPNAME = mrp.Sync.RegisterVar(SYNC_STRING)
SYNC_CALLSIGN = mrp.Sync.RegisterVar(SYNC_STRING)
SYNC_INCOGNITO = mrp.Sync.RegisterVar(SYNC_BOOL)
SYNC_COLLISIONS = mrp.Sync.RegisterVar(SYNC_BOOL)
SYNC_BLEEDING = mrp.Sync.RegisterVar(SYNC_BOOL)

hook.Run("CreateSyncVars")