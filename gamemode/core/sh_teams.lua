mrp.Teams = mrp.Teams or {}
mrp.Teams.Stored = mrp.Teams.Stored or {}

local count = 0

function mrp.Teams.Define(data)
    count = count + 1
    mrp.Teams.Stored[count] = data

    team.SetUp(count, data.name, data.color, false)
    return count
end

function meta:CanBecomeTeam(teamID, notify)
	local teamData = mrp.Teams.Stored[teamID]

	if not self:Alive() then return false end

	if teamID == self:Team() then
		return false
	end

	local canSwitch = hook.Run("CanPlayerChangeTeam", self, teamID)

	if canSwitch != nil and canSwitch == false then
		return false
	end

	if teamData.customCheck then
		local r = teamData.customCheck(self, teamID)

		if r != nil and r == false then
			return false
		end
	end

	return true
end

function meta:GetTeamClass()
	return self:GetSyncVar(SYNC_CLASS, 0)
end

function meta:CanBecomeTeamClass(classID, notify)
	local teamData = mrp.Teams.Stored[self:Team()]
	local classData = teamData.classes[classID]

	if not self:Alive() then return false end

	if self:GetTeamClass() == classID then return false end

	if classData.customCheck then
		local r = classData.customCheck(self, classID)

		if r != nil and r == false then
			return false
		end
	end

	return true
end