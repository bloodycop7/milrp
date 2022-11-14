local PANEL = {}

function PANEL:Init()
    self:SetSize(600, 700)
    self:Center()
    self:MakePopup()
    self:MoveToFront()
    self:SetTitle("")

    self.review = self:Add("DButton")
    self.review:Dock(BOTTOM)
    self.review:SetTall(70)
    self.review:SetText("Select a Tagline and a Number")
    self.review:SetFont("mrp-Font40")
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

    self.tagline = self:Add("DComboBox")
    self.tagline:SetValue("VICTOR")
    self.tagline:SetSortItems(false)
    self.tagline:SetContentAlignment(5)
    self.tagline:Dock(TOP)
    self.tagline:SetTall(40)
    self.tagline:SetFont("mrp-Font22")
    self.tagline.OnSelect = function(panel, index, value)
        self.review:SetText(value)
    end
    for k, v in pairs({"ALPHA", "BRAVO", "VICTOR", "VIPER", "GHOST", "SHADOW", "FEARLESS", "JULIET", "DELTA", "SHADOW"}) do
        self.tagline:AddChoice(v)
    end

    self.number = self:Add("DComboBox")
    self.number:SetValue("0")
    self.number:SetSortItems(false)
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
end

vgui.Register("mrpCallsignSelect", PANEL, "DFrame")