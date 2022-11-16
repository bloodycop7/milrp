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

function GM:DefineSettings()
	mrp.DefineSetting("perf_mcore", {name="Multi-core rendering enabled", category="Performance", type="tickbox", default=false, onChanged = function(newValue)
		RunConsoleCommand("gmod_mcore_test", tostring(tonumber(newValue)))

		if newValue == 1 then
			RunConsoleCommand("mat_queue_mode", "-1")
			RunConsoleCommand("cl_threaded_bone_setup", "1")
		else
			RunConsoleCommand("cl_threaded_bone_setup", "0")
		end
	end})
	mrp.DefineSetting("perf_dynlight", {name="Dynamic light rendering enabled", category="Performance", type="tickbox", default=true, onChanged = function(newValue)
		local v = 0
		if newValue == 1 then
			v = 1
		end

		RunConsoleCommand("r_shadows", v)
		RunConsoleCommand("r_dynamic", v)
	end})
end