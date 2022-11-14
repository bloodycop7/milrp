local CMoveData = FindMetaTable("CMoveData")

function CMoveData:RemoveKeys(keys)
	-- Using bitwise operations to clear the key bits.
	local newbuttons = bit.band(self:GetButtons(), bit.bnot(keys))
	self:SetButtons(newbuttons)
end

hook.Add("DefineSettings", "MrpSettings", function()
	mrp.DefineSetting("draw_hud", {name="HUD Enabled", category="Overlay", type="tickbox", default=false})
	mrp.DefineSetting("draw_hud_lfs", {name="LFS HUD Enabled", category="Overlay", type="tickbox", default=false})
end)

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

function meta:Notify(message)
    if CLIENT then
        local notice = vgui.Create("mrpNotify")
        local i = table.insert(mrp.notices, notice)

        notice:SetMessage(message)
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
        net.Send(self)
    end
end