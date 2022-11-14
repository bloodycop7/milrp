
util.AddNetworkString("mrpBodygroupView")
util.AddNetworkString("mrpBodygroupTableSet")

net.Receive("mrpBodygroupTableSet", function(length, ply)
    if not ( ply:IsAdmin() ) then return end

    local target = net.ReadEntity() or ply

    if (!IsValid(target) or !target:IsPlayer()) then
        return
    end

    local bodygroups = net.ReadTable()

    local groups = {}

    for k, v in pairs(bodygroups) do
        target:SetBodygroup(tonumber(k) or 0, tonumber(v) or 0)
        groups[tonumber(k) or 0] = tonumber(v) or 0
    end
end)