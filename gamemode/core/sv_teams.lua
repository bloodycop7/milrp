meta.OldSetTeam = meta.OldSetTeam or meta.SetTeam
function meta:SetTeam(teamID, forced)
	local teamData = mrp.Teams.Stored[teamID]

	if teamData.skin then
		self:SetSkin(teamData.skin)
	elseif not teamData.model then
		self:SetSkin(1)
	end

	if teamData.bodygroups then
		for v, bodygroupData in pairs(teamData.bodygroups) do
			self:SetBodygroup(bodygroupData[1], (bodygroupData[2] or math.random(0, self:GetBodygroupCount(bodygroupData[1]))))
		end
	else
		self:SetBodyGroups("0000000")
	end
	
	self:StripWeapons()
	
	if teamData.loadout then
		for v,weapon in pairs(teamData.loadout) do
			self:Give(weapon)
		end
	end

	if self:Team() != teamID then
		hook.Run("OnPlayerChangedTeam", self, self:Team(), teamID)
	end

	self:SetSyncVar(SYNC_CLASS, nil, true)
	self:OldSetTeam(teamID)
	self:SetupHands()

	hook.Run("UpdatePlayerSync", self)

	if teamData.onBecome then
		teamData.onBecome(self)
	end

    if teamData.model then
        if ( isstring(mrp.Teams.Stored[self:Team() or 1].model) ) then
            self:SetModel(mrp.Teams.Stored[(self:Team() or 1)].model)
        elseif ( istable(mrp.Teams.Stored[(self:Team() or 1)].model) ) then
            self:SetModel(table.Random(mrp.Teams.Stored[(self:Team() or 1)].model))
        end
	else
		self:SetModel(self:GetModel())
	end
    
	return true
end

function meta:SetTeamClass(classID, skipLoadout)
	local teamData = mrp.Teams.Stored[self:Team()]
	local classData = teamData.classes[classID]

	if classData.model then
		self:SetModel(classData.model)
	else
		self:SetModel(teamData.model or self:GetModel())
	end

	self:SetupHands()

	if classData.skin then
		self:SetSkin(classData.skin)
	else
		self:SetSkin(teamData.skin or 1)
	end

	self:SetBodyGroups("0000000")
	
	if classData.bodygroups then
		for k, v in pairs(classData.bodygroups) do
			self:SetBodygroup(k, v)
		end
	elseif teamData.bodygroups then
		for k, v in pairs(teamData.bodygroups) do
			self:SetBodygroup(k, v)
		end
	end


    if ( classData.loadout ) then
        for v,weapon in pairs(classData.loadout) do
            self:Give(weapon)
        end
    else
        if ( teamData.loadout ) then
            for v,weapon in pairs(teamData.loadout) do
                self:Give(weapon)
            end
        end

        if ( classData.loadoutAdd ) then
            for v,weapon in pairs(classData.loadoutAdd) do
                self:Give(weapon)
            end
        end
    end

	if classData.armor then
		self:SetArmor(classData.armor)
		self.MaxArmor = classData.armor
	else
		self:SetArmor(0)
		self.MaxArmor = nil
	end

	if classData.onBecome then
		classData.onBecome(self)
	end

    local oldClass = self:GetTeamClass()
    
	self:SetLocalSyncVar(SYNC_CLASS, classID, true)

	hook.Run("PlayerChangeClass", self, classID, oldClass, classData.name)

	return true
end

function GM:PlayerChangeClass(ply, class, oldclass, name)
    if ( oldclass ) then
        if ( mrp.Teams.Stored[ply:Team()].classes[oldclass].loadout ) then
            for k, v in pairs(mrp.Teams.Stored[ply:Team()].classes[oldclass].loadout) do
                if ( ply:HasWeapon(v) ) then
                    ply:StripWeapon(v)
                end
            end
        end
    end
end