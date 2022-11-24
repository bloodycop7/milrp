local tab = {
	["$pp_colour_addr"] = -1,
    ["$pp_colour_addg"] = 0,
    ["$pp_colour_addb"] = -1,
    ["$pp_colour_brightness"] = 0.01,
    ["$pp_colour_contrast"] = 4.2,
    ["$pp_colour_colour"] = 1,
    ["$pp_colour_mulr"] = 0,
    ["$pp_colour_mulg"] = 0,
    ["$pp_colour_mulb"] = 0,
}

local stab = {
    darken = 0,
    multiply = 1,
    sizex = 4,
    sizey = 4,
    passes = 1,
    colormultiply = 1,
    red = 1,
    green = 1,
    blue = 1,
}

hook.Add("RenderScreenspaceEffects", "NightVisionMRP", function()
    if ( mrp.GetSetting("nightvision_enabled", false) ) then
	    DrawColorModify(tab)

        DrawBloom(stab.darken or 0, stab.multiply or 1,
        stab.sizex or 1, stab.sizey or 1, stab.passes or 1,
        stab.colormultiply or 1,
        stab.red or 1, stab.green or 1, stab.blue or 1)

        local dlight = DynamicLight(LocalPlayer():EntIndex())

        dlight.brightness = 1
        dlight.Size = 1000
        dlight.r = 255
        dlight.g = 255
        dlight.b = 255
        dlight.Decay = 500
        dlight.pos = EyePos()
        dlight.DieTime = CurTime() + 0.1

        surface.SetDrawColor(color_white)
        surface.SetMaterial(Material("binocular.png"))
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
    end
end)