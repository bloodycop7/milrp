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

function meta:AddCaption(speaker, message, col, msgcol)
    local col = col or Color(0, 175, 255)
    local msgcol = msgcol or color_white
    if CLIENT then
        local notice = vgui.Create("mrpSub")
        local i = table.insert(mrp.captions, notice)

        notice:SetMessage(speaker, message, col, msgcol)
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

        MsgC(col, speaker..": ", color_white, message.."\n")
    else
        net.Start("mrpCaptionAdd")
            net.WriteString(speaker)
            net.WriteString(message)
            net.WriteColor(col)
            net.WriteColor(msgcol)
        net.Send(self)
    end
end

local entMeta = FindMetaTable("Entity")

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