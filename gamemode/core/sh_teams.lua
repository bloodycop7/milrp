mrp.Teams = mrp.Teams or {}
mrp.Teams.Stored = mrp.Teams.Stored or {}

local count = 0

function mrp.Teams.Define(data)
    count = count + 1
    mrp.Teams.Stored[count] = data

    team.SetUp(count, data.name, data.color, false)
    return count
end