local PANEL = {}
local firstMainMenuJoin = false
function PANEL:Init()
    local ply = LocalPlayer()
    self:SetPos(0, 0)
    self:SetSize(1920, 1080)
    self:MakePopup()

    mrp.gui.mainMenu = self

    self.playbutton = self:Add("DButton")
    self.playbutton:SetPos(ScrW() / 2 - 100, 200)
    self.playbutton:SetSize(200, 100)
    self.playbutton:SetFont("mrp-Font40")

    if ( firstMainMenuJoin ) then
        self.playbutton:SetText("Play")
        self.playbutton:SetTextColor(color_white)
        self.playbutton.DoClick = function()
            Derma_StringRequest("Name", "RP Name", "John Doe", function(str)
                if not ( str ) then return end
                if ( str == "" ) then return end
                if ( string.len(str) < 5 ) then return end 
                self:Remove()
                net.Start("milMainMenuSpawn")
                    net.WriteString(str)
                net.SendToServer()

                firstMainMenuJoin = false
                mrp.gui.mainMenu = nil
            end)
            
        end
        self.playbutton.Paint = function(s, w, h)
            surface.SetDrawColor(0, 0, 0, 170)
            surface.DrawRect(0, 0, w, h)
        end
    else
        self.playbutton:SetText("Play")
        self.playbutton.DoClick = function()
            self:Remove()
            mrp.gui.mainMenu = nil
        end
        self.playbutton.Paint = function(s, w, h)
            surface.SetDrawColor(0, 0, 0, 170)
            surface.DrawRect(0, 0, w, h)
        end
        self.playbutton:SetTextColor(color_white) 
    end

    self.leavebutton = self:Add("DButton")
    self.leavebutton:SetTextColor(color_white)
    self.leavebutton:SetPos(ScrW() / 2 - 100, 320)
    self.leavebutton:SetText("Leave")
    self.leavebutton:SetSize(200, 100)
    self.leavebutton:SetFont("mrp-Font40")
    self.leavebutton.DoClick = function()
        self:Remove()
        LocalPlayer():ConCommand("disconnect")
    end
    self.leavebutton.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 170)
        surface.DrawRect(0, 0, w, h)
    end

    self.optionsbutton = self:Add("DButton")
    self.optionsbutton:SetPos(ScrW() / 2 - 100, 440)
    self.optionsbutton:SetTextColor(color_white)
    self.optionsbutton:SetText("Settings")
    self.optionsbutton:SetSize(200, 100)
    self.optionsbutton:SetFont("mrp-Font40")
    self.optionsbutton.DoClick = function()
        vgui.Create("mrpSettings")
    end
    self.optionsbutton.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 170)
        surface.DrawRect(0, 0, w, h)
    end

    self.changename = self:Add("DButton")
    self.changename:SetPos(ScrW() / 2 - 130, 560)
    self.changename:SetText("Change RP Name")
    self.changename:SetTextColor(color_white)
    surface.SetFont("mrp-Font40")
    local w, h = surface.GetTextSize("Change RP Name")
    self.changename:SetSize(w, 100)
    self.changename:SetFont("mrp-Font40")
    self.changename.DoClick = function()
        Derma_StringRequest("Name", "RP Name", "John Doe", function(str)
            if not ( str ) then return end
            if ( str == "" ) then return end
            if ( string.len(str) < 5 ) then return end
            net.Start("milMainMenuChangeName")
                net.WriteString(str)
            net.SendToServer()
        end)
    end
    self.changename.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 170)
        surface.DrawRect(0, 0, w, h)
    end

    self.changecallsign = self:Add("DButton")
    self.changecallsign:SetTextColor(color_white)
    self.changecallsign:SetPos(ScrW() / 2 - 120, 680)
    self.changecallsign:SetText("Change Callsign")
    surface.SetFont("mrp-Font40")
    local w, h = surface.GetTextSize("Change Callsign")
    self.changecallsign:SetSize(w, 100)
    self.changecallsign:SetFont("mrp-Font40")
    self.changecallsign.DoClick = function()
        vgui.Create("mrpCallsignSelect")
    end
    self.changecallsign.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 170)
        surface.DrawRect(0, 0, w, h)
    end

    self.teamMenu = self:Add("DButton")
    self.teamMenu:SetTextColor(color_white)
    self.teamMenu:SetPos(ScrW() / 2 - 100, 800)
    self.teamMenu:SetText("Change Team")
    surface.SetFont("mrp-Font40")
    local w, h = surface.GetTextSize("Change Team")
    self.teamMenu:SetSize(w, 100)
    self.teamMenu:SetFont("mrp-Font40")
    self.teamMenu.DoClick = function()
        vgui.Create("mrpTeamMenu")
    end
    self.teamMenu.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 170)
        surface.DrawRect(0, 0, w, h)
    end
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(20, 20, 20, 200)
    surface.DrawRect(0, 0, w, h)

    draw.DrawText("Military Project", "mrp-Font70", ScrW() / 2, 50, mrp.Config.BaseColor, TEXT_ALIGN_CENTER)
end

vgui.Register("MilMainMenu", PANEL, "DPanel")

hook.Add("PlayerButtonDown", "close", function(ply, btn)
    if ( btn == KEY_F1 ) then
        if not ( mrp.gui.mainMenu ) then
            mrp.gui.mainMenu = vgui.Create("MilMainMenu")
        end
    end
end)