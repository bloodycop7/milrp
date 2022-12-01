local PANEL = {}
local firstMainMenuJoin = false
function PANEL:Init()
    local ply = LocalPlayer()
    self:SetPos(0, 0)
    self:SetSize(1920, 1080)
    self:MakePopup()

    mrp.gui.mainMenu = self

    self.playbutton = self:Add("DButton")
    self.playbutton:SetPos(50, 200)
    self.playbutton:SetSize(200, 100)
    self.playbutton:SetFont("mrp-Font60")
    
    if not ( steamworks.IsSubscribed("2888675922") ) then
        Derma_Query("Missing Content", "You don't have our content installed", "Download", function()
            gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=2747447138")
        end, "Close")
    end

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
            surface.SetDrawColor(0, 0, 0, 0)
            surface.DrawRect(0, 0, w, h)
        end
    
        self.playbutton.OnCursorEntered = function(s)
            s:SetTextColor(mrp.Config.BaseColor)
        end
        self.playbutton.OnCursorExited = function(s)
            s:SetTextColor(color_white)
        end
    else
        self.playbutton:SetText("Play")
        self.playbutton.DoClick = function()
            self:Remove()
            mrp.gui.mainMenu = nil
        end
        self.playbutton.Paint = function(s, w, h)
            surface.SetDrawColor(0, 0, 0, 0)
            surface.DrawRect(0, 0, w, h)
        end
    
        self.playbutton.OnCursorEntered = function(s)
            s:SetTextColor(mrp.Config.BaseColor)
        end
        self.playbutton.OnCursorExited = function(s)
            s:SetTextColor(color_white)
        end
        self.playbutton:SetTextColor(color_white) 
    end

    self.leavebutton = self:Add("DButton")
    self.leavebutton:SetTextColor(color_white)
    self.leavebutton:SetPos(65, 280)
    self.leavebutton:SetText("Leave")
    self.leavebutton:SetSize(200, 100)
    self.leavebutton:SetFont("mrp-Font60")
    self.leavebutton.DoClick = function()
        Derma_Query("Are you sure you want to leave?", "Confirm", "Leave", function()
            LocalPlayer():ConCommand("disconnect")
        end, "Close")
    end
    self.leavebutton.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 0)
        surface.DrawRect(0, 0, w, h)
    end

    self.leavebutton.OnCursorEntered = function(s)
        s:SetTextColor(mrp.Config.BaseColor)
    end
    self.leavebutton.OnCursorExited = function(s)
        s:SetTextColor(color_white)
    end

    self.optionsbutton = self:Add("DButton")
    self.optionsbutton:SetPos(35, 360)
    self.optionsbutton:SetTextColor(color_white)
    self.optionsbutton:SetText("Settings")
    self.optionsbutton:SetSize(350, 100)
    self.optionsbutton:SetFont("mrp-Font60")
    self.optionsbutton.DoClick = function()
        vgui.Create("mrpSettings")
    end
    self.optionsbutton.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 0)
        surface.DrawRect(0, 0, w, h)
    end

    self.optionsbutton.OnCursorEntered = function(s)
        s:SetTextColor(mrp.Config.BaseColor)
    end
    self.optionsbutton.OnCursorExited = function(s)
        s:SetTextColor(color_white)
    end

    self.changename = self:Add("DButton")
    self.changename:SetPos(100, 440)
    self.changename:SetText("Change RP Name")
    self.changename:SetTextColor(color_white)
    surface.SetFont("mrp-Font60")
    local w, h = surface.GetTextSize("Change RP Name")
    self.changename:SetSize(w, 100)
    self.changename:SetFont("mrp-Font60")
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
        surface.SetDrawColor(0, 0, 0, 0)
        surface.DrawRect(0, 0, w, h)
    end

    self.changename.OnCursorEntered = function(s)
        s:SetTextColor(mrp.Config.BaseColor)
    end
    self.changename.OnCursorExited = function(s)
        s:SetTextColor(color_white)
    end

    self.changecallsign = self:Add("DButton")
    self.changecallsign:SetTextColor(color_white)
    self.changecallsign:SetPos(100, 520)
    self.changecallsign:SetText("Change Callsign")
    surface.SetFont("mrp-Font60")
    local w, h = surface.GetTextSize("Change Callsign")
    self.changecallsign:SetSize(w, 100)
    self.changecallsign:SetFont("mrp-Font60")
    self.changecallsign.DoClick = function()
        vgui.Create("mrpCallsignSelect")
    end
    self.changecallsign.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 0)
        surface.DrawRect(0, 0, w, h)
    end

    self.changecallsign.OnCursorEntered = function(s)
        s:SetTextColor(mrp.Config.BaseColor)
    end
    self.changecallsign.OnCursorExited = function(s)
        s:SetTextColor(color_white)
    end

    self.teamMenu = self:Add("DButton")
    self.teamMenu:SetTextColor(color_white)
    self.teamMenu:SetPos(100, 600)
    self.teamMenu:SetText("Change Team")
    surface.SetFont("mrp-Font60")
    local w, h = surface.GetTextSize("Change Team")
    self.teamMenu:SetSize(w, 100)
    self.teamMenu:SetFont("mrp-Font60")
    self.teamMenu.DoClick = function()
        vgui.Create("mrpTeamMenu")
    end
    self.teamMenu.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 0)
        surface.DrawRect(0, 0, w, h)
    end

    self.teamMenu.OnCursorEntered = function(s)
        s:SetTextColor(mrp.Config.BaseColor)
    end
    self.teamMenu.OnCursorExited = function(s)
        s:SetTextColor(color_white)
    end
    
    self.updates = self:Add("mrpUpdates")
    self.updates:SetPos(ScrW() - 545, 100)
    self.updates:MoveToFront()
    
    self.discord = self:Add("DButton")
    self.discord:SetPos(ScrW() / 2 - 125, ScrH() - 200)
    self.discord:SetContentAlignment(5)
    self.discord:SetSize(200, 100)
    self.discord:SetFont("mrp-Font60")
    self.discord:SetText("Discord")
    self.discord:SetTextColor(mrp.Config.BaseColor)
    self.discord.DoClick = function()
        gui.OpenURL("https://discord.gg/WQzr5KJm8V")
    end
    self.discord.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 0)
        surface.DrawRect(0, 0, w, h)
    end
end

function PANEL:Paint(w, h)
    mrp.DrawBlur(self)
    local randomx
    
    if ( self.nextFlicker or 0 ) < CurTime() then
        randomx = math.random(20, 90)
        
        self.nextFlicker = CurTime() + 0.9
    end
    
    surface.SetDrawColor(20, 20, 20, 200)
    surface.DrawRect(0, 0, w, h)

    draw.DrawText("Military Project", "mrp-Font100", ScrW() / 2 - 50, 50, mrp.Config.BaseColor, TEXT_ALIGN_CENTER)
    draw.DrawText("Changelogs", "mrp-Font70", ScrW() - 300, 20, mrp.Config.BaseColor, TEXT_ALIGN_CENTER)
    if ( randomx ) then
        draw.DrawText("Military Project", "mrp-Font100", ScrW() / 2 - randomx, 50, mrp.Config.BaseColor, TEXT_ALIGN_CENTER)
    end
end

vgui.Register("MilMainMenu", PANEL, "DPanel")

hook.Add("PlayerButtonDown", "close", function(ply, btn)
    if ( btn == KEY_F1 ) then
        if not ( mrp.gui.mainMenu ) then
            mrp.gui.mainMenu = vgui.Create("MilMainMenu")
        end
    end
end)