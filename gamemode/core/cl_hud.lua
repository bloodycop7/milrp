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

function mrp.DrawCrosshair(x, y, radius, quality, color)
    x = x or 0
    y = y or 0
    radius = radius or 3
    quality = quality or 50
    color = color or color_white
    local circle = {}
    local temp = 0
    for i = 1, quality do
        temp = math.rad(i*360)/quality
        circle[i] = {
            x = x + math.cos(temp) * radius/2,
            y = y + math.sin(temp) * radius/2
        }
    end
    
    surface.SetDrawColor(color)
    draw.NoTexture()
    surface.DrawPoly(circle)
end

local hp = 100
local armor = 0
local crosshaircolor = Color(255, 255, 255, 255)
hook.Add("HUDPaint", "DisableStuff", function()
	local ply = LocalPlayer()

	if not ( ply ) then return end

	if ( IsValid(mrp.gui.mainMenu) ) then return end
	if not ( ply:Alive() ) then return end
	if not ( IsValid(ply) ) then return end

	hp = Lerp(0.01, hp, ply:Health())
	armor = Lerp(0.01, armor, ply:Armor())

	local wep = ply:GetActiveWeapon()

	for k, v in pairs(ply:GetPlayersInRadius(120)) do
		if ( IsValid(v) ) then
			if ( v == LocalPlayer() ) then continue end
			if ( v:GetMoveType() == MOVETYPE_NOCLIP ) then continue end
			if not ( ply:Alive() ) then continue end
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
				w = cw + 2,
				h = 25,
				col = Color(0, 120, 255)
			})
			draw.DrawText(v:Nick(), "mrp-Font20", pos.x + 53, pos.y + 3, color_white, TEXT_ALIGN_LEFT)
			draw.DrawText(v:GetSyncVar(SYNC_CALLSIGN, "UNDEFINED-0"), "mrp-Font19", pos.x + 53, pos.y + 43, color_white, TEXT_ALIGN_LEFT)
		end
	end

	if ( IsValid(wep) ) then
		local clip = wep:Clip1()
		local ammo = ply:GetAmmoCount(wep:GetPrimaryAmmoType())

		if not ( clip == 0 or clip == -1 ) then
			draw.DrawText(clip, "mrp-Font60", ScrW() - 15, ScrH() - 70, color_white, TEXT_ALIGN_RIGHT)
		end
	end

	crosshaircolor.a = hook.Run("GetCrosshairAlpha", ply, wep, crosshaircolor, crosshaircolor.a)

	if ( mrp.GetSetting("bodycam_mode", false) ) then
		local p = LocalPlayer():GetEyeTrace().HitPos:ToScreen()
		mrp.DrawCrosshair(p.x, p.y, 3, 50, crosshaircolor)
	else
		mrp.DrawCrosshair(ScrW() / 2, ScrH() / 2, 3, 50, crosshaircolor)
	end
end)

function GM:GetCrosshairAlpha(ply, wep, color, alpha)
	if ( wep.GetToggleAim ) then
		if ( wep:GetToggleAim() ) then
			return Lerp(0.1, alpha, 0)
		end
	elseif ( wep.GetIsHolstering ) then
		if ( wep:GetIsHolstering() ) then
			return Lerp(0.1, alpha, 0)
		end
	end

	return Lerp(0.1, alpha, 255)
end

function meta:GetHPColor()
	if ( self:Health() >= 60 ) then
        return Color(170, 100, 0)
    elseif ( self:Health() >= 50 ) then
        return Color(190, 90, 0)
    elseif ( self:Health() >= 45 ) then
        return Color(200, 70, 0)
    elseif ( self:Health() >= 40 ) then
        return Color(200, 60, 0)
    elseif ( self:Health() >= 35 ) then
        return Color(200, 50, 0)
    elseif ( self:Health() >= 30 ) then
        return  Color(200, 40, 0)
    elseif ( self:Health() >= 20 ) then
        return Color(200, 30, 0)
    elseif ( self:Health() >= 15 ) then
        return Color(200, 20, 0)
    elseif ( self:Health() >= 10 ) then
        return Color(200, 10, 0)
    elseif ( self:Health() >= 5 ) then
        return Color(200, 0, 0)
    elseif ( self:Health() >= 1 ) then
        return Color(255, 0, 0)
	end
end

function GM:HUDPaintBackground()
	if ( IsValid(mrp.gui.mainMenu) ) then return end
	if not ( LocalPlayer():Alive() ) then return end
	if not ( IsValid(LocalPlayer()) ) then return end
	local col = color_black

	if ( LocalPlayer():Health() <= 60 ) then
		col = LocalPlayer():GetHPColor()
	end

	surface.SetDrawColor(col or color_black)
	surface.SetMaterial(Material("helix/gui/vignette.png"))
	surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
end