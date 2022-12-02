local CMoveData = FindMetaTable("CMoveData")

function CMoveData:RemoveKeys(keys)
	local newbuttons = bit.band(self:GetButtons(), bit.bnot(keys))
	self:SetButtons(newbuttons)
end

function meta:IsLeadAdmin()
	return ( self:GetUserGroup() == "lmod" or self:GetUserGroup() == "superadmin" )
end

mrp.notices = mrp.notices or {}

local function OrganizeNotices(i)
    local scrW = ScrW()
    local lastHeight = ScrH() - 100

    for k, v in ipairs(mrp.notices) do
        local height = lastHeight - v:GetTall() - 10
        v:MoveTo(scrW - (v:GetWide()), height, 0.15, (k / #mrp.notices) * 0.25, nil)
        lastHeight = height
    end
end

function meta:Notify(message, col)
    local col = col or color_white
    if CLIENT then
        local notice = vgui.Create("mrpNotify")
        local i = table.insert(mrp.notices, notice)

        notice:SetMessage(message, col)
        notice:SetPos(ScrW(), ScrH() - (i - 1) * (notice:GetTall() + 4) + 4) -- needs to be recoded to support variable heights
        notice:MoveToFront() 
        OrganizeNotices(i)

        timer.Simple(7.5, function()
            if IsValid(notice) then
                notice:AlphaTo(0, 1, 0, function() 
                    notice:Remove()

                    for v,k in pairs(mrp.notices) do
                        if k == notice then
                            table.remove(mrp.notices, v)
                        end
                    end

                    OrganizeNotices(i)
                end)
            end
        end)

        MsgN(message)
    else
        net.Start("mrpNotify")
        net.WriteString(message)
        net.WriteColor(col)
        net.Send(self)
    end
end

mrp.captions = mrp.captions or {}

local function OrganizeCaptions(i)
    local scrW = ScrW()
    local lastHeight = ScrH() - 100

    for k, v in ipairs(mrp.captions) do
        local height = lastHeight - v:GetTall() + 15
        v:MoveTo(scrW - (v:GetWide()), height + 50, 0.15, (k / #mrp.captions) * 0.25, nil)
        lastHeight = height
    end
end

function meta:AddCaption(tbl)
    local scol = tbl.speakercol or Color(0, 175, 255)
    local smsgcol = tbl.msgcol or color_white
    if CLIENT then
        local notice = vgui.Create("mrpSub")
        local i = table.insert(mrp.captions, notice)

        notice:SetMessage({
            speaker = tbl.speaker, 
            message = (tbl.dots and ": "..tbl.message) or tbl.message, 
            speakercol = scol, 
            msgcol = smsgcol
        })
        notice:SetPos(ScrW(), ScrH() - (i - 1) * (notice:GetTall() + 4) + 4) -- needs to be recoded to support variable heights
        notice:MoveToFront() 
        OrganizeCaptions(i)

        timer.Simple(7.5, function()
            if IsValid(notice) then
                notice:AlphaTo(0, 1, 0, function() 
                    notice:Remove()

                    for v,k in pairs(mrp.captions) do
                        if k == notice then
                            table.remove(mrp.captions, v)
                        end
                    end

                    OrganizeCaptions(i)
                end)
            end
        end)

        MsgC(scol, tbl.speaker..": ", smsgcol, tbl.message.."\n" or (tbl.dots and ": "..tbl.message).."\n")
    else
        net.Start("mrpCaptionAdd")
            net.WriteString(tbl.speaker)
            net.WriteString((tbl.dots and ": "..tbl.message) or tbl.message)
            net.WriteColor(scol)
            net.WriteColor(smsgcol)
        net.Send(self)
    end
end

function entMeta:IsLocked()
	if (self:IsVehicle()) then
		local datatable = self:GetSaveTable()

		if (datatable) then
			return datatable.VehicleLocked
		end
	else
		local datatable = self:GetSaveTable()
		
		if (datatable) then
			return datatable.m_bLocked
		end
	end

	return false
end

if ( SERVER ) then
    util.AddNetworkString("PlayerActionBar")
end

function meta:DoAction(text, time, OnFinished, freeze)
    if ( CLIENT ) then
        if not ( ( mrpactiveActionBar or false ) ) then
            local actionvgui = vgui.Create("mrpActionBar")
            actionvgui:SetEndTime(CurTime() + time)

            if text then
                actionvgui:SetText(text)
            end
            
            if OnFinished then
                actionvgui.OnEnd = OnFinished
            end

            if freeze then
                actionvgui:MakePopup()
            end
        end
    else
        if not ( ( mrpactiveActionBar or false ) ) then
            mrpactiveActionBar = true
            net.Start("PlayerActionBar")
                if ( text ) then
                    net.WriteString(text)
                else
                    net.WriteString("")
                end

                if ( freeze ) then
                    net.WriteBool(true)
                else
                    net.WriteBool(false)
                end

                if ( time ) then
                    net.WriteUInt(time, 32)
                else
                    net.WriteUInt(5, 32)
                end
            net.Send(self)

            timer.Simple(time or 5, function()
                mrpactiveActionBar = false
            end)
        end
    end
end

if ( CLIENT ) then
    net.Receive("PlayerActionBar", function()
        local text = net.ReadString()
        local freeze = net.ReadBool()
        local time = net.ReadUInt(32)

        local actionvgui = vgui.Create("mrpActionBar")
        actionvgui:SetEndTime(CurTime() + time)

        if text then
            actionvgui:SetText(text)
        end
        
        if freeze then
            actionvgui:MakePopup()
        end
    end)
end

function meta:IsRunning()
    if ( self:IsSprinting() and self:GetVelocity():Length() != 0 or ( self:GetActiveWeapon().GetIsSprinting and self:GetActiveWeapon():GetIsSprinting() ) ) then
        return true
    end

    return false
end

function meta:GetEntityInFront(radius)
    local data = {}
        data.start = self:GetShootPos()
        data.endpos = data.start + self:GetAimVector() * (radius or 96)
        data.filter = self
    local target = util.TraceLine(data).Entity

    if ( target and IsValid(target) ) then
        return target
    end
end

function meta:GetThrowPos(radius)
    local data = {}
        data.start = self:GetShootPos()
        data.endpos = data.start + self:GetAimVector() * (radius or 120)
        data.filter = self
    local target = util.TraceLine(data).HitPos 
end

if SERVER then
	util.AddNetworkString("GM-ColoredMessage")

	function meta:AddChatText(...)
		local package = {...}
		net.Start("GM-ColoredMessage")
            net.WriteTable(package)
        net.Send(self)
	end
else
    net.Receive("GM-ColoredMessage", function()
        local package = net.ReadTable()
        
        LocalPlayer():AddCaption(package)
    end)
end

local blacklistedweps = {}
blacklistedweps["gmod_tool"] = true
blacklistedweps["weapon_physgun"] = true
blacklistedweps["mrp_hands"] = true
blacklistedweps["mg_fist"] = true

concommand.Add("dropweapon", function(ply, cmd, args)
    local target = ply:GetThrowPos()
    
    if ( SERVER ) then
        if ( IsValid(ply:GetActiveWeapon()) ) then
            if not ( blacklistedweps[ply:GetActiveWeapon():GetClass()] ) then
                ply:DropWeapon(ply:GetActiveWeapon(), target, target)
            else
                ply:Notify("You cannot drop that weapon!")
            end
        end
    end
end)

if ( CLIENT ) then
    net.Receive("MRPAnnouncement", function()
        if ( ( announcebeingdisplayed or false ) ) then return end
        local msg = net.ReadString()
        local notice = vgui.Create("mrpAnnouncement")
    
        notice:SetMessage({
            speaker = LocalPlayer():Nick(), 
            message = msg, 
        })
        
        notice:SetPos(0, 70)
        notice:MoveToFront() 
    
        announcebeingdisplayed = true
        timer.Simple(7.5, function()
            if IsValid(notice) then
                notice:AlphaTo(0, 1, 0, function() 
                    notice:Remove()
                    announcebeingdisplayed = false
                end)
            end
        end)
    end) 
end

if ( SERVER ) then
    util.AddNetworkString("mrpCinematicMessage")
    function mrp.CinematicIntro(message)
        net.Start("mrpCinematicMessage")
        net.WriteString(message)
        net.Broadcast()
    end

    concommand.Add("mrp_cinemessage", function(ply, cmd, args)
        if not ply:IsSuperAdmin() then return end
        
        mrp.CinematicIntro(args[1] or "")
    end)

    function meta:AllowScenePVSControl(bool)
        self.allowPVS = bool

        if not bool then
            self.extraPVS = nil
            self.extraPVS2 = nil
        end
    end 
end