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
        self.teamButton:Dock(RIGHT)
        self.teamButton:SetText(v.name)
        self.teamButton:SetColor(color_white)
        self.teamButton:SetSize(w + 100, 300)
        self.teamButton:SetFont("mrp-Font22")
        self.teamButton:SetContentAlignment(8)
        self.teamButton.Paint = function(s, wi, he)
            surface.SetDrawColor(ColorAlpha(v.color, 70))
            surface.DrawRect(0, 0, wi, he)
        end
        self.teamButton.DoClick = function()
            net.Start("mrpSetTeamIndex")
                net.WriteUInt(k, 8)
            net.SendToServer()
        end
        self.model = self.teamButton:Add("DModelPanel")
        local mdl = v.model
        
        if ( istable(mdl) ) then
            mdl = table.Random(v.model) 
        end
        
        self.model:SetModel(mdl, (v.skin or 1))
        self.model:SetPos(40, 50)
        self.model:SetSize(80, 240)
        self.model:SetFOV(20)
        if ( v.classes ) then
            if ( ply:Team() == k ) then
                self.classespanel = self:Add("DPanel")
                self.classespanel:SetPos(0, 30)
                self.classespanel:SetSize(200, 670)
                self.classespanel.Paint = function(s, w, h)
                    surface.SetDrawColor(Color(30, 30, 30))
                    surface.DrawRect(0, 0, w, h) 
                end
                
                self.classesscroll = self.classespanel:Add("DScrollPanel")
                self.classesscroll:Dock(FILL)
                
                for a, b in pairs(v.classes) do
                    local class = self.classesscroll:Add("DButton")
                    class:Dock(TOP)
                    class:SetContentAlignment(5)
                    class:SetSize(60, 40)
                    class:DockMargin(10, 10, 0, 0)
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