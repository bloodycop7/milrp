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
    end
end

vgui.Register("mrpTeamMenu", PANEL, "DFrame")