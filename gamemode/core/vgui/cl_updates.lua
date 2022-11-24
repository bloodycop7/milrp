local PANEL = {}

function PANEL:Init()
    self:SetSize(500, 250)
    self:MoveToFront()
    
    self.html = self:Add("HTML")
    self.html:OpenURL("https://initiate.alphacoders.com/images/540/cropped-500-250-540196.jpg?6860")
    self.html:SetPos(0, 0)
    self.html:SetSize(500, 250)
    self.html:SizeToContents()
    
    self.scroll = self:Add("DScrollPanel")
    self.scroll:SetPos(0, 0)
    self.scroll:SetSize(500, 250)
    self.scroll.VBar.btnUp:SetColor(Color(255, 255, 255, 0))
    self.scroll.VBar.btnDown:SetColor(Color(255, 255, 255, 0))
    
    self.scroll.VBar.btnDown.Paint = function(s)
        s:SetColor(Color(255, 255, 255, 0))
    end
    
    self.scroll.VBar.btnUp.Paint = function(s)
        s:SetColor(Color(255, 255, 255, 0))
    end
    
    for k, v in pairs(mrp.Changelogs) do
        local changelogTitle = self.scroll:Add("DLabel")
        changelogTitle:SetText("Version "..k)
        changelogTitle:SetFont("mrp-Font60")
        changelogTitle:SetTextColor(Color(210, 210, 210))
        changelogTitle:SizeToContents()
        changelogTitle:Dock(TOP)

        for _, i in pairs(v) do
            
            local changelogText = self.scroll:Add("DLabel")
            changelogText:SetText("⏺ "..i)
            --changelogText:SetText(btnUp"        ".. i)
            changelogText:SetFont("mrp-Font25")
            changelogText:SetContentAlignment(1)
            changelogText:SizeToContents()
            changelogText:Dock(TOP)
        end
    end
end



function PANEL:Paint(w, h)
    surface.SetDrawColor(20, 20, 20, 160)
    surface.DrawRect(0, 0, w, h)
end

vgui.Register("mrpUpdates", PANEL, "DPanel")