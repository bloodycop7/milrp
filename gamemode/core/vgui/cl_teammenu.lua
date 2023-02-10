local PANEL = {}

function PANEL:Init()
    local ply = LocalPlayer()
    self:SetSize(600, 700)
    self:Center()
    self:MakePopup()
    self:MoveToFront()
    self:SetTitle("")
    
    local selectedTeam
    
    self.teamPanel = self:Add("DPanel")
    self.teamPanel:SetPos(200, 30)
    self.teamPanel:SetSize(400, 670)
    self.teamPanel.Paint = function(s, w, h)
        surface.SetDrawColor(Color(20, 20, 20, 150))
        surface.DrawRect(0, 0, w, h)
    end

    self.scroll = self.teamPanel:Add("DScrollPanel")
    self.scroll:Dock(FILL)
    
    local panel = self
    
    for k, v in pairs(mrp.Teams.Stored) do
        surface.SetFont("mrp-Font22")
        local w, h = surface.GetTextSize(v.name)
        local teamButton = self.scroll:Add("DButton")
        teamButton:Dock(TOP)
        teamButton:SetTall(50)
        teamButton:SetText("")
        teamButton:DockMargin(0, 10, 0, 0)
        teamButton:SetContentAlignment(8)
        teamButton:MoveToFront()
        teamButton.Paint = function(s, wi, he)
            surface.SetDrawColor(ColorAlpha(v.color, 70))
            surface.DrawRect(0, 0, wi, he)
            
            draw.DrawText("Become", "mrp-Font40", wi / 2, he / 2 - 25, color_white, TEXT_ALIGN_CENTER)
        end
        
        function teamButton:OnCursorEntered()
            panel.desclabel:SetText(v.description)
            panel.desclabel:SetWrap(true)
            panel.desclabel:SizeToContents()
            
            panel.namelabel:SetText(v.name)
            panel.namelabel:SetWrap(true)
            panel.namelabel:SizeToContents()
        end
        function teamButton:DoClick()
            net.Start("mrpSetTeamIndex")
                net.WriteUInt(k, 8)
            net.SendToServer()
        end
        
        local model = v.model
        
        if ( istable(v.model) ) then
            model = v.model[math.random(1, #v.model)] 
        end
        
        self.model = self.scroll:Add("DModelPanel")
        self.model:SetModel(model, (v.skin or 0))
        self.model:SetFOV(20)
        self.model:SetTall(200)
        
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
    
    self.descpanel = self:Add("DScrollPanel")
    self.descpanel:SetPos(0, 450)
    self.descpanel:SetSize(200, 250)
    self.descpanel.Paint = function(s, w, h)
        --surface.SetDrawColor(Color(0, 0, 0))
        --surface.DrawRect(0, 0, w, h) 
    end
    
    self.namelabel = self.descpanel:Add("DLabel")
    self.namelabel:SetTextColor(color_white)
    self.namelabel:Dock(TOP)
    self.namelabel:SetTall(100)
    self.namelabel:SetText("")
    self.namelabel:SetWrap(true)
    self.namelabel:SetFont("mrp-Font23")
    self.namelabel:SizeToContents()
    
    self.desclabel = self.descpanel:Add("DLabel")
    self.desclabel:SetTextColor(color_white)
    self.desclabel:Dock(TOP)
    self.desclabel:SetTall(150)
    self.desclabel:SetText("")
    self.desclabel:SetWrap(true)
    self.desclabel:SetFont("mrp-Font23")
    self.desclabel:SizeToContents()
end

vgui.Register("mrpTeamMenu", PANEL, "DFrame")