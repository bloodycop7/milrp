TEAM_SOLDIER = mrp.Teams.Define({
    name = "Soldier",
    color = Color(40, 85, 55),
    model = "models/bread/cod/characters/milsim/shadow_company.mdl",
    description = [[A trained soldier ready for deployment.]],
    classes = {
        {
            name = "Leader"
        },
        {
            name = "Medic",
            loadout = {"weapon_medkit"}
        },
        {
            name = "Heavy",
            loadout = {"mg_romeo870"},
            armor = 150
        }
    }
})