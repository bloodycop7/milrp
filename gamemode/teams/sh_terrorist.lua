TEAM_TERRORIST = mrp.Teams.Define({
    name = "Terrorist",
    color = Color(100, 25, 25),
    model = {"models/player/arctic.mdl", "models/player/guerilla.mdl", "models/player/leet.mdl", "models/player/phoenix.mdl"},
    description = "terrorist description",
    canJoin = function(self, ply)
        return false 
    end
})
