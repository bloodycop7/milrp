local PANEL = {}

function PANEL:Init()
    self:SetSize(600, 300)
    self:Center()
    self:MakePopup()
    self:MoveToFront()
    self:SetTitle("")

    self.review = self:Add("DButton")
    self.review:Dock(BOTTOM)
    self.review:SetTall(70)
    self.review:SetText("Select a Tagline and a Number")
    self.review:SetFont("mrp-Font40")
    self.review:SetTextColor(color_white)
    self.review:SetContentAlignment(5)
    self.review.DoClick = function(s)
        if ( s:GetText() == "Select a Tagline and a Number" ) then LocalPlayer():Notify("You need to specify a tagline and a number") return end

        if not ( s:GetText():find(self.tagline:GetValue()) ) then return end
        net.Start("milCallsignSet")
            net.WriteString(s:GetText())
        net.SendToServer()
    end
    self.review.Think = function(s)
        s:SetText((self.tagline:GetValue() or "VICTOR").."-"..(self.number:GetValue() or "0"))
    end
    self.review.Paint = function(s, w, h)
        surface.SetDrawColor(95, 95, 95, 150)
        surface.DrawRect(0, 0, w, h)
    end

    self.tagline = self:Add("DComboBox")
    self.tagline:SetValue("VICTOR")
    self.tagline:SetTextColor(color_white)
    self.tagline:SetSortItems(false)
    self.tagline:SetContentAlignment(5)
    self.tagline:Dock(TOP)
    self.tagline:SetTall(40)
    self.tagline:SetFont("mrp-Font22")
    self.tagline.OnSelect = function(panel, index, value)
        self.review:SetText(value)
    end
    for k, v in pairs({"ALPHA", "BRAVO", "VICTOR", "VIPER", "GHOST", "SHADOW", "FEARLESS", "JULIET", "DELTA", "SHADOW", "KILO"}) do
        self.tagline:AddChoice(v)
    end
    self.tagline.Paint = function(s, w, h)
        surface.SetDrawColor(20, 20, 20, 130)
        surface.DrawRect(0, 0, w, h) 
    end
    function self.tagline:OnMenuOpened(menu)
        menu.Paint = function(s, w, h)
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(0, 0, w, h)
        end
        
        for k, v in pairs(menu:GetCanvas():GetChildren()) do
            v:SetFont("mrp-Font23")
            v:SetTextColor(color_white)
        end
    end
    
    self.number = self:Add("DComboBox")
    self.number:SetValue("0")
    self.number:SetSortItems(false)
    self.number:SetTextColor(color_white)
    self.number:DockMargin(0, 5, 0, 0)
    self.number:Dock(TOP)
    self.number:SetContentAlignment(5)
    self.number:SetTall(40)
    self.number:SetFont("mrp-Font22")
    self.number.OnSelect = function(panel, index, value)
        self.review:SetText((self.tagline:GetValue() or "VICTOR").."-"..panel:GetValue())
    end
    for i = 0, 99 do
        self.number:AddChoice(i)
    end
    self.number.Paint = function(s, w, h)
        surface.SetDrawColor(20, 20, 20, 130)
        surface.DrawRect(0, 0, w, h) 
    end
    function self.number:OnMenuOpened(menu)
        menu.Paint = function(s, w, h)
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(0, 0, w, h)
        end
        
        for k, v in pairs(menu:GetCanvas():GetChildren()) do
            v:SetFont("mrp-Font23")
            v:SetTextColor(color_white)
        end
    end
end

vgui.Register("mrpCallsignSelect", PANEL, "DFrame")