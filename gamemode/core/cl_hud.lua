local hidden = {}
hidden["CHudHealth"] = true
hidden["CHudBattery"] = true
hidden["CHudAmmo"] = true
hidden["CHudSecondaryAmmo"] = true
hidden["CHudCrosshair"] = true
hidden["CHudHistoryResource"] = true
hidden["CHudPoisonDamageIndicator"] = true
hidden["CHudSquadStatus"] = true
hidden["CHUDQuickInfo"] = true
hidden["CHudCloseCaption"] = true

function mrp.DrawBox(tbl)
	surface.SetDrawColor(0, 0, 0, 190)
    surface.DrawRect(tbl.x, tbl.y, tbl.w, tbl.h)
    
    surface.SetDrawColor(tbl.col or color_white)
    surface.DrawRect(tbl.x, tbl.y, 9, 3)
    surface.DrawRect(tbl.x + tbl.w - 9, tbl.y, 9, 3)

    surface.DrawRect(tbl.x, tbl.y, 3, 9)
    surface.DrawRect(tbl.x + tbl.w - 3, tbl.y, 3, 9)

    surface.DrawRect(tbl.x, tbl.y + tbl.h - 3, 9, 3)
    surface.DrawRect(tbl.x + tbl.w - 9, tbl.y + tbl.h - 3, 9, 3)

    surface.DrawRect(tbl.x, tbl.y + tbl.h - 9, 3, 9)
    surface.DrawRect(tbl.x + tbl.w - 3, tbl.y + tbl.h - 9, 3, 9)
end

function GM:HUDShouldDraw(element)
	if (hidden[element]) then
		return false
	end

	return true
end

function GM:DrawDeathNotice()
	return false
end

function GM:HUDAmmoPickedUp()
	return false
end

function GM:HUDDrawPickupHistory()
	return false
end

function GM:HUDDrawTargetID()
	return false
end

local hp = 100
local armor = 0
hook.Add("HUDPaint", "DisableStuff", function()
	local ply = LocalPlayer()

	if not ( ply ) then return end

	if ( IsValid(mrp.gui.mainMenu) ) then return end

	hp = Lerp(0.01, hp, ply:Health())
	armor = Lerp(0.01, armor, ply:Armor())

	--[[draw.RoundedBox(7, 50, ScrH() - 15 - 200, 8.5, 200, Color(20, 20, 20, 200))
	draw.RoundedBox(7, 50, ScrH() - 15 - hp * 2, 8.5, hp * 2, Color(255, 0, 0))

	draw.RoundedBox(7, 70, ScrH() - 15 - 200, 8.5, 200, Color(20, 20, 20, 200))
	if ( ply:Armor() > 0 ) then
		draw.RoundedBox(7, 70, ScrH() - 15 - armor * 2, 8.5, armor * 2, Color(0, 90, 255))
	end]]

	for k, v in pairs(ply:GetPlayersInRadius(120)) do
		if ( IsValid(v) ) then
			if ( v == LocalPlayer() ) then continue end
			if ( v:GetMoveType() == MOVETYPE_NOCLIP ) then continue end
			local pos = v:GetBonePosition(v:LookupBone("ValveBiped.Bip01_R_Clavicle")):ToScreen()
			surface.SetFont("mrp-Font20")
			local nw, nh = surface.GetTextSize(v:Nick())
			local cw, ch = surface.GetTextSize(v:GetSyncVar(SYNC_CALLSIGN, "UNDEFINED-0"))
			mrp.DrawBox({
				x = pos.x + 50,
				y = pos.y,
				w = nw + 7,
				h = 30,
				col = Color(30, 95, 30)
			})

			mrp.DrawBox({
				x = pos.x + 50,
				y = pos.y + 40,
				w = cw - 6,
				h = 25,
				col = Color(0, 120, 255)
			})
			draw.DrawText(v:Nick(), "mrp-Font20", pos.x + 53, pos.y + 3, color_white, TEXT_ALIGN_LEFT)
			draw.DrawText(v:GetSyncVar(SYNC_CALLSIGN, "UNDEFINED-0"), "mrp-Font18", pos.x + 53, pos.y + 43, color_white, TEXT_ALIGN_LEFT)
		end
	end
end)

function GM:HUDPaintBackground()
	surface.SetDrawColor(color_black)
	surface.SetMaterial(Material("helix/gui/vignette.png"))
	surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
end