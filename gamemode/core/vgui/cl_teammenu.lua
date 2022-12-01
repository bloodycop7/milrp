local PANEL = {}

function PANEL:Init()
    local ply = LocalPlayer()
    self:SetSize(600, 700)
    self:Center()
    self:MakePopup()
    self:MoveToFront()
    self:SetTitle("")
    
    self.teamPanel = self:Add("DPanel")
    self.teamPanel:SetPos(200, 30)
    self.teamPanel:SetSize(400, 670)
    self.teamPanel.Paint = function(s, w, h)
        surface.SetDrawColor(Color(20, 20, 20, 150))
        surface.DrawRect(0, 0, w, h)
    end

    self.scroll = self.teamPanel:Add("DScrollPanel")
    self.scroll:Dock(FILL)
    
    for k, v in pairs(mrp.Teams.Stored) do
        surface.SetFont("mrp-Font22")
        local w, h = surface.GetTextSize(v.name)
        self.teamButton = self.scroll:Add("DButton")
        self.teamButton:Dock(TOP)
        self.teamButton:DockMargin(0, 10, 0, 0)
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
        self.model:SetPos(150, 50)
        self.model:SetSize(80, 240)
        self.model:SetFOV(20)
        if ( v.classes ) then
            if ( ply:Team() == k ) then
                self.classespanel = self:Add("DPanel")
                self.classespanel:SetPos(0, 30)
                self.classespanel:SetSize(200, 420)
                self.classespanel:DockPadding(0, 50, 0, 0)
                self.classespanel.Paint = function(s, w, h)
                    surface.SetDrawColor(Color(30, 30, 30))
                    surface.DrawRect(0, 0, w, h)
                    
                    draw.DrawText("Classes", "mrp-Font28", w / 2, 15, Color(170, 170, 170), TEXT_ALIGN_CENTER)
                end
                
                self.classesscroll = self.classespanel:Add("DScrollPanel")
                self.classesscroll:Dock(FILL)
                
                for a, b in pairs(v.classes) do
                    local class = self.classesscroll:Add("DButton")
                    class:Dock(TOP)
                    class:SetContentAlignment(5)
                    class:SetSize(60, 40)
                    class:DockMargin(0, 10, 0, 0)
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
    
    if ( mrp.Teams.Stored[ply:Team()].description ) then
        self.descpanel = self:Add("DScrollPanel")
        self.descpanel:SetPos(0, 450)
        self.descpanel:SetSize(200, 250)
        self.descpanel.Paint = function(s, w, h)
            --surface.SetDrawColor(Color(0, 0, 0))
            --surface.DrawRect(0, 0, w, h) 
        end

        self.desclabel = self.descpanel:Add("DTextEntry")
        self.desclabel:SetMultiline(true)
        --self.desclabel:SetEditable(false)
        self.desclabel:SetDisabled(true)
        self.desclabel:SetTextColor(color_white)
        self.desclabel:SetPos(0, 0)
        self.desclabel:SetSize(200, 250)
        self.desclabel:SetValue(mrp.Teams.Stored[ply:Team()].description)
        self.desclabel:SetFont("mrp-Font23")
        self.desclabel:SetPaintBackground(false)
    end
end

vgui.Register("mrpTeamMenu", PANEL, "DFrame")