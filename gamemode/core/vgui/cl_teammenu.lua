local PANEL = {}

function PANEL:Init()
    local ply = LocalPlayer()
    self:SetSize(600, 700)
    self:Center()
    self:MakePopup()
    self:MoveToFront()
    self:SetTitle("")

    self.scroll = self:Add("DScrollPanel")
    self.scroll:Dock(FILL)

    for k, v in pairs(mrp.Teams.Stored) do
        surface.SetFont("mrp-Font22")
        local w, h = surface.GetTextSize(v.name)
        self.teamButton = self.scroll:Add("DButton")
        self.teamButton:Dock(TOP)
        self.teamButton:SetText(v.name)
        self.teamButton:SetColor(color_white)
        self.teamButton:SetSize(w, 70)
        self.teamButton:SetFont("mrp-Font22")
        self.teamButton:SetContentAlignment(5)
        self.teamButton.Paint = function(s, wi, he)
            surface.SetDrawColor(ColorAlpha(v.color, 70))
            surface.DrawRect(0, 0, wi, he)
        end
        self.teamButton.DoClick = function()
            net.Start("mrpSetTeamIndex")
                net.WriteUInt(k, 8)
            net.SendToServer()
        end
        if ( v.classes ) then
            if ( ply:Team() == k ) then
                for a, b in pairs(v.classes) do
                    local class = self.scroll:Add("DButton")
                    class:Dock(TOP)
                    class:SetTall(50)
                    class:SetText(b.name or "UNKNOWN")
                    class:SetFont("mrp-Font23")
                    class:SetTextColor(color_white)
                    class.Paint = function(s, wi, he)
                        surface.SetDrawColor(Color(20, 20, 20, 150))
                        surface.DrawRect(0, 0, wi, he)
                    end
                    class.DoClick = function()
                        net.Start("mrpSetTeamClass")
                            net.WriteUInt(a, 8)
                        net.SendToServer() 
                    end
                end
            end
        end
    end
end

vgui.Register("mrpTeamMenu", PANEL, "DFrame")