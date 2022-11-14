local PANEL = {}

function PANEL:Init()
    self:SetPos(0, 0)
    self:SetSize(ScrW(), ScrH())
    self:MakePopup()
    self:MoveToFront()
    
    self.lowerPanel = self:Add("DScrollPanel")
    self.lowerPanel:SetPos(ScrW() / 2 - 900, 60)
    self.lowerPanel:SetSize(1800, 1000)
    self.lowerPanel.Paint = function(s, w, h)
        surface.SetDrawColor(20, 20, 20, 240)
        surface.DrawRect(0, 0, w, h)
    end

    for k, v in pairs(player.GetAll()) do
        self.panel = self.lowerPanel:Add("DPanel")
        self.panel:Dock(TOP)
        self.panel:DockMargin(0, 5, 0, 0)
        self.panel:SetTall(120)
        self.panel.Paint = function(s, w, h)
            surface.SetDrawColor(mrp.Config.BaseColor)
            surface.DrawOutlinedRect(0, 0, w, h, 2)

            draw.DrawText(v:Nick(), "mrp-Font30", 100, h / 2 - 15, color_white, TEXT_ALIGN_LEFT)

            draw.DrawText(v:Ping(), "mrp-Font30", w - 15, h / 2 - 15, color_white, TEXT_ALIGN_RIGHT)

            draw.DrawText(v:SteamID64() or "", "mrp-Font30", w / 2, h / 2 - 15, color_white, TEXT_ALIGN_CENTER)
        end

        self.model = self.panel:Add("DModelPanel")
        self.model:SetModel(v:GetModel(), v:GetSkin())
        self.model:SetPos(0, 0)
        self.model:SetSize(80, 120)
        self.model:SetFOV(42)
    end
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(20, 20, 20, 200)
    surface.DrawRect(0, 0, w, h)
    draw.DrawText("SCOREBOARD", "mrp-Font40", ScrW() / 2, 15, color_white, TEXT_ALIGN_CENTER)
end

vgui.Register("mrpScoreboard", PANEL, "DPanel")