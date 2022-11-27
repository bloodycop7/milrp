local PANEL = {}

function PANEL:Init()
    self:SetSize(500, 500)
    self:MoveToFront()
    
    self.html = self:Add("HTML")
    self.html:OpenURL("https://i1.sndcdn.com/artworks-n75FWO4AsbU9FAvp-yyB2og-t500x500.jpg")
    self.html:SetPos(0, 0)
    self.html:SetSize(500, 500)
    self.html:SizeToContents()
    self.html.PaintOver = function(s, w, h)
        surface.SetDrawColor(30, 30, 30, 190)
        surface.DrawRect(0, 0, w, h)
        mrp.DrawBlur(s)
    end
    
    self.scroll = self:Add("DScrollPanel")
    self.scroll:SetPos(0, 0)
    self.scroll:SetSize(500, 500)
    self.scroll.VBar.btnUp:SetColor(Color(255, 255, 255, 0))
    self.scroll.VBar.btnDown:SetColor(Color(255, 255, 255, 0))
    
    self.scroll.VBar.btnDown.Paint = function(s)
        s:SetColor(Color(255, 255, 255, 0))
    end
    
    self.scroll.VBar.btnUp.Paint = function(s)
        s:SetColor(Color(255, 255, 255, 0))
    end
    
    for k, v in SortedPairs(mrp.Changelogs, true) do
        local changelogTitle = self.scroll:Add("DLabel")
        changelogTitle:SetText("Version "..k..".0")
        changelogTitle:SetFont("mrp-Font45")
        changelogTitle:SetTextColor(Color(217, 255, 0))
        changelogTitle:SizeToContents()
        changelogTitle:Dock(TOP)
        changelogTitle:DockMargin(10, 0, 0, 0)

        for _, i in pairs(v) do
            local changelogText = self.scroll:Add("DLabel")
            changelogText:SetText("● "..i)
            changelogText:SetTextColor(Color(217, 255, 0))
            changelogText:SetFont("mrp-Font27")
            changelogText:SetContentAlignment(1)
            changelogText:DockMargin(10, 0, 0, 0)
            changelogText:SizeToContents()
            changelogText:Dock(TOP)
        end
    end
end

vgui.Register("mrpUpdates", PANEL, "DPanel")