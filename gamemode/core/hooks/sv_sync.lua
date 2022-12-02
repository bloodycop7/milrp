util.AddNetworkString("iSyncU")
util.AddNetworkString("iSyncUlcl")
util.AddNetworkString("iSyncR")
util.AddNetworkString("iSyncRvar")

function entMeta:Sync(target)
	local targetID = self:EntIndex()
	local syncUser = mrp.Sync.Data[targetID]

	for varID, syncData in pairs(syncUser) do
		local value = syncData[1]
		local syncRealm = syncData[2]
		local syncType = mrp.Sync.Vars[varID]
		local syncCondition = mrp.Sync.VarsConditional[varID]

		if target and syncCondition and not syncCondition(target) then
			return
		end
		
		if syncRealm == SYNC_TYPE_PUBLIC then
			if target then
				if value == nil then
					net.Start("iSyncRvar")
						net.WriteUInt(targetID, 16)
						net.WriteUInt(varID, SYNC_ID_BITS)
					net.Send(target)
				else
					net.Start("iSyncU")
						net.WriteUInt(targetID, 16)
						net.WriteUInt(varID, SYNC_ID_BITS)
						mrp.Sync.DoType(syncType, value)
					net.Send(target)
				end
			else
				local recipFilter = RecipientFilter()

				if syncCondition then
					for v,k in pairs(player.GetAll()) do
						if syncCondition(k) then
							recipFilter:AddPlayer(k)
						end
					end
				else
					recipFilter:AddAllPlayers()
				end

				if value == nil then
					net.Start("iSyncRvar")
						net.WriteUInt(targetID, 16)
						net.WriteUInt(varID, SYNC_ID_BITS)
					net.Send(recipFilter)
				else
					net.Start("iSyncU")
						net.WriteUInt(targetID, 16)
						net.WriteUInt(varID, SYNC_ID_BITS)
						mrp.Sync.DoType(syncType, value)
					net.Send(recipFilter)
				end
			end
		elseif target and target:IsPlayer() and target:EntIndex() == targetID then
			if value == nil then
				net.Start("iSyncRvar")
					net.WriteUInt(targetID, 16)
					net.WriteUInt(varID, SYNC_ID_BITS)
				net.Send(target)
			else
				net.Start("iSyncUlcl")
					net.WriteUInt(targetID, 8)
					net.WriteUInt(varID, SYNC_ID_BITS)
					mrp.Sync.DoType(syncType, value)
				net.Send(target)
			end
		end
	end
end

function entMeta:SyncSingle(varID, target)
	local targetID = self:EntIndex()
	local syncUser = mrp.Sync.Data[targetID]
	local syncData = syncUser[varID]
	local value = syncData[1]
	local syncRealm = syncData[2]
	local syncType = mrp.Sync.Vars[varID]
	local syncCondition = mrp.Sync.VarsConditional[varID]

	if target and syncCondition and not syncCondition(target) then
		return
	end

	if syncRealm == SYNC_TYPE_PUBLIC then
		if target then
			if value == nil then
				net.Start("iSyncRvar")
					net.WriteUInt(targetID, 16)
					net.WriteUInt(varID, SYNC_ID_BITS)
				net.Send(target)
			else
				net.Start("iSyncU")
					net.WriteUInt(targetID, 16)
					net.WriteUInt(varID, SYNC_ID_BITS)
					mrp.Sync.DoType(syncType, value)
				net.Send(target)
			end
		else
			local recipFilter = RecipientFilter()

			if syncCondition then
				for v,k in pairs(player.GetAll()) do
					if syncCondition(k) then
						recipFilter:AddPlayer(k)
					end
				end
			else
				recipFilter:AddAllPlayers()
			end

			if value == nil then
				net.Start("iSyncRvar")
					net.WriteUInt(targetID, 16)
					net.WriteUInt(varID, SYNC_ID_BITS)
				net.Send(recipFilter)
			else
				net.Start("iSyncU")
					net.WriteUInt(targetID, 16)
					net.WriteUInt(varID, SYNC_ID_BITS)
					mrp.Sync.DoType(syncType, value)
				net.Send(recipFilter)
			end
		end
	elseif target and target:IsPlayer() and target:EntIndex() == targetID then
		if value == nil then
			net.Start("iSyncRvar")
				net.WriteUInt(targetID, 16)
				net.WriteUInt(varID, SYNC_ID_BITS)
			net.Send(target)
		else
			net.Start("iSyncUlcl")
				net.WriteUInt(targetID, 8)
				net.WriteUInt(varID, SYNC_ID_BITS)
				mrp.Sync.DoType(syncType, value)
			net.Send(target)
		end
	end
end

function entMeta:SyncRemove()
	local targetID = self:EntIndex()

	mrp.Sync.Data[targetID] = nil

	net.Start("iSyncR")
		net.WriteUInt(targetID, 16)
	net.Broadcast()	
end

function entMeta:SyncRemoveVar(varID)
	local targetID = self:EntIndex()

	mrp.Sync.Data[targetID][varID] = nil

	net.Start("iSyncRvar")
		net.WriteUInt(targetID, 16)
		net.WriteUInt(varID, SYNC_ID_BITS)
	net.Broadcast()	
end

function entMeta:SetSyncVar(varID, newValue, instantSync)
	local targetID = self:EntIndex()
	local targetData = mrp.Sync.Data[targetID]

	if not targetData then
		mrp.Sync.Data[targetID] = {}
		targetData = mrp.Sync.Data[targetID]
	elseif targetData[varID] and (type(newValue) != "table" and targetData[varID][1] == newValue) then
		return
	end

	targetData[varID] = {newValue, SYNC_TYPE_PUBLIC}

	if instantSync then
		self:SyncSingle(varID)
	end
end

function meta:SetLocalSyncVar(varID, newValue)
	local targetID = self:EntIndex()
	local targetData = mrp.Sync.Data[targetID]
	targetData[varID] = {newValue, SYNC_TYPE_PRIVATE}

	self:SyncSingle(varID, self)
end

function entMeta:GetSyncVar(varID, fallback)
	local targetData = mrp.Sync.Data[self.EntIndex(self)]

	if targetData != nil then
		if targetData[varID] != nil then
			return targetData[varID][1]
		end
	end
	return fallback
end