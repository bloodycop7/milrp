hook.Add("CalcView", "ViewBobPlugin", function(ply, pos, ang, fov)
    if ( IsValid(mrp.gui.mainMenu) ) then return end
    if not ( ply:Alive() ) then return end
    if ( ply:InVehicle() ) then return end
    if not ( mrp.GetSetting("bodycam_mode", false) ) then return end
    
    local view = {}
    view.origin = pos-(ang:Forward()*2) + (ang:Right() * 13)
    view.angles = ang
    view.fov = 85

    if ( ply:Crouching() ) then
        view.origin = pos-(ang:Forward()*2) + (ang:Right() * 13) + (ang:Up() * 14)

        if ( ply:GetVelocity():Length() != 0 ) then
            view.origin = pos-(ang:Forward()*2) + (ang:Right() * 19) + (ang:Up() * 14)
        end
    end
 
    return view
end)

hook.Add("ShouldDrawLocalPlayer", "BodyCamLEEE", function()
    if ( mrp.GetSetting("bodycam_mode", false) ) then return true end
end)

hook.Add("HUDPaint", "BodyCamHUD", function()
    local ply = LocalPlayer()

	if not ( ply ) then return end

	if ( IsValid(mrp.gui.mainMenu) ) then return end
	if not ( ply:Alive() ) then return end
	if not ( IsValid(ply) ) then return end

    if not ( mrp.GetSetting("bodycam_mode", false) ) then return end

    surface.SetDrawColor(color_white)
    surface.SetMaterial(Material("vgui/bodycamicon.png"))
    surface.DrawTexturedRect(ScrW() - 140, 15, 125, 125)

    surface.SetDrawColor(Color(50, 50, 50, 160))
    surface.DrawRect(ScrW() - 450, 15, 310, 125)

    draw.DrawText(os.date("%d-%m-%y", os.time()), "mrp-Font23", ScrW() - 445, 20, color_white, TEXT_ALIGN_LEFT)
    draw.DrawText(os.date("%H-%M-%S", os.time()), "mrp-Font23", ScrW() - 145, 20, color_white, TEXT_ALIGN_RIGHT)
    draw.DrawText(os.date("%Y", os.time()), "mrp-Font23", ScrW() - 297, 20, color_white, TEXT_ALIGN_CENTER)
    draw.DrawText(os.date("%A", os.time()), "mrp-Font23", ScrW() - 297, 50, color_white, TEXT_ALIGN_CENTER)
    draw.DrawText("BODYCAM ACTIVE & RECORDING", "mrp-Font23", ScrW() - 297, 100, color_white, TEXT_ALIGN_CENTER)

    draw.DrawText((ply:GetSyncVar(SYNC_CALLSIGN, "UNKNOWN-0")), "mrp-Font23", ScrW() - 297, 75, color_white, TEXT_ALIGN_CENTER)
end)