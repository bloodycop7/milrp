-- mrp's chatbox is based uponmrp.chatBox by Exho
-- Author: vin, Exho (obviously), Tomelyr, LuaTenshi
-- Version: 4/12/15

if mrp.chatBox and IsValid(mrp.chatBox.frame) then
	mrp.chatBox.frame:Remove()
end

mrp.chatBox = {}

--// Builds the chatbox but doesn't display it
function mrp.chatBox.buildBox()
	mrp.chatBox.frame = vgui.Create("DFrame")
	mrp.chatBox.frame:SetSize( ScrW()*0.375, ScrH()*0.35 )
	mrp.chatBox.frame:SetTitle("")
	mrp.chatBox.frame:ShowCloseButton( false )
	mrp.chatBox.frame:SetDraggable( true )
	mrp.chatBox.frame:SetSizable( true )
	mrp.chatBox.frame:SetPos( 15, (ScrH() - mrp.chatBox.frame:GetTall()) - 200)
	mrp.chatBox.frame:SetMinWidth( 300 )
	mrp.chatBox.frame:SetMinHeight( 100 )
	mrp.chatBox.frame:SetPopupStayAtBack(true)
	mrp.chatBox.frame.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 200 ) )
		
		draw.RoundedBox( 0, 0, 0, w, 25, Color( 0,110,255) )

		surface.SetDrawColor(0,0,51, 100)
		surface.DrawOutlinedRect(0,0,w,h,1)
	end
	mrp.chatBox.oldPaint = mrp.chatBox.frame.Paint
	mrp.chatBox.frame.Think = function()
		if input.IsKeyDown( KEY_ESCAPE ) then
			mrp.chatBox.hideBox()
		end
	end
	
	mrp.chatBox.entry = vgui.Create("DTextEntry", mrp.chatBox.frame) 
	mrp.chatBox.entry:SetSize(mrp.chatBox.frame:GetWide() - 50, 20)
	mrp.chatBox.entry:SetTextColor( color_white )
	mrp.chatBox.entry:SetFont("mrp-Font23")
	mrp.chatBox.entry:SetDrawBorder( false )
	mrp.chatBox.entry:SetDrawBackground( false )
	mrp.chatBox.entry:SetCursorColor( color_white )
	mrp.chatBox.entry:SetHighlightColor( Color(52, 152, 219) )
	mrp.chatBox.entry:SetPos( 45, mrp.chatBox.frame:GetTall() - mrp.chatBox.entry:GetTall() - 5 )
	mrp.chatBox.entry.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 100 ) )
		derma.SkinHook( "Paint", "TextEntry", self, w, h )
	end

	mrp.chatBox.entry.OnTextChanged = function( self )
		if self and self.GetText then 
			gamemode.Call( "ChatTextChanged", self:GetText() or "" )
		end
	end

	mrp.chatBox.entry.OnKeyCodeTyped = function( self, code )
		local types = {"", "radio"}

		if code == KEY_ESCAPE then

			mrp.chatBox.hideBox()
			gui.HideGameUI()

		elseif code == KEY_TAB then
			
			mrp.chatBox.TypeSelector = (mrp.chatBox.TypeSelector and mrp.chatBox.TypeSelector + 1) or 1
			
			if mrp.chatBox.TypeSelector > 2 then mrp.chatBox.TypeSelector = 1 end
			if mrp.chatBox.TypeSelector < 1 then mrp.chatBox.TypeSelector = 2 end
			
			mrp.chatBox.ChatType = types[mrp.chatBox.TypeSelector]

			timer.Simple(0.001, function() mrp.chatBox.entry:RequestFocus() end)

		elseif code == KEY_UP then
			if self.LastMessage then
				self:SetText(self.LastMessage)
				self:SetCaretPos(self.LastMessage:len())
			end
		elseif code == KEY_ENTER then
			-- Replicate the client pressing enter
			
			if string.Trim(self:GetText()) != "" then
				if mrp.chatBox.ChatType == types[2] then
					net.Start("mrpChatMessage")
					net.WriteString("/r "..self:GetText())
					net.SendToServer()

					self.LastMessage = "/r "..self:GetText()
				else
					net.Start("mrpChatMessage")
					net.WriteString(self:GetText())
					net.SendToServer()

					self.LastMessage = self:GetText()
				end
			end

			mrp.chatBox.TypeSelector = 1
			mrp.chatBox.hideBox()
		end
	end

	mrp.chatBox.chatLog = vgui.Create("mrpRichText", mrp.chatBox.frame)
	mrp.chatBox.chatLog:SetPos(5, 30)
	mrp.chatBox.chatLog:SetSize(mrp.chatBox.frame:GetWide() - 10, mrp.chatBox.frame:GetTall() - 70)
	local strFind = string.find
	mrp.chatBox.chatLog.PaintOver = function(self, w, h)
		local entry = mrp.chatBox.entry

		if (mrp.chatBox.frame:IsActive() and IsValid(entry)) then
			local text = string.Explode(" ", entry:GetValue())
			text = text[1] or ""

			if (text:sub(1, 1) == "/") then
				local command = string.PatternSafe(string.lower(text))


				surface.SetDrawColor(0, 0, 0, 200)
				surface.DrawRect(0, 0, w, h)

				if text == "//" or text == "/ooc" then
					self:GetParent().TypingInOOC = true
				else
					self:GetParent().TypingInOOC = false
				end

				local i = 0
				local showing = 0
				local isAdmin = LocalPlayer():IsAdmin()
				local isLeadAdmin = LocalPlayer():IsSuperAdmin()
				local isSuperAdmin = LocalPlayer():IsSuperAdmin()

 				for k, v in pairs(mrp.chatCommands) do
 					if (strFind(k, command)) then
 						local c = mrp.Config.MainColour or Color(255, 255, 255)
 						
 						if v.adminOnly then
 							if isAdmin then
 								c = mrp.Config.InteractColour or Color(35, 100, 125)
 							else
 								continue 
 							end
 						end

   						if v.leadAdminOnly then
 							if isLeadAdmin or isSuperAdmin then
 								c = Color(128, 0, 128)
 							else
 								continue
 							end
 						end
 						
  						if v.superAdminOnly then
 							if isSuperAdmin then
 								c = Color(255, 0, 0, 255)
 							else
 								continue 
 							end
 						end
 
						draw.DrawText(k.." - "..v.description, "mrp-Font21", 10, 10 + i, c, TEXT_ALIGN_LEFT)
						i = i + (15)
						showing = showing + 1

						if showing > 24 then
							break
						end
 					end
 				end
			end
		end
	end
	mrp.chatBox.chatLog.Think = function( self )
		self:SetSize( mrp.chatBox.frame:GetWide() - 10, mrp.chatBox.frame:GetTall() - mrp.chatBox.entry:GetTall() - 40 )
	end
	
	local text = "Say:"

	local say = vgui.Create("DLabel", mrp.chatBox.frame)
	say:SetText("")
	surface.SetFont("mrp-Font23")
	local w, h = surface.GetTextSize( text )
	say:SetSize( w + 5, 20 )
	say:SetPos( 5, mrp.chatBox.frame:GetTall() - mrp.chatBox.entry:GetTall() - 5 )
	
	say.Paint = function( self, w, h )
		draw.DrawText( text, "mrp-Font23", 2, 1, color_white )
	end

	say.Think = function( self )
		local types = {"", "radio", "console"}
		local s = {}

		if mrp.chatBox.ChatType == types[2] then 
			text = "Radio:"	
		else
			text = "Say:"
			s.pw = 45
			s.sw = mrp.chatBox.frame:GetWide() - 50
		end

		if s then
			if not s.pw then s.pw = self:GetWide() + 10 end
			if not s.sw then s.sw = mrp.chatBox.frame:GetWide() - self:GetWide() - 15 end
		end

		local w, h = surface.GetTextSize( text )
		self:SetSize( w + 5, 20 )
		self:SetPos( 5, mrp.chatBox.frame:GetTall() - mrp.chatBox.entry:GetTall() - 5 )

		mrp.chatBox.entry:SetSize( s.sw, 20 )
		mrp.chatBox.entry:SetPos( s.pw, mrp.chatBox.frame:GetTall() - mrp.chatBox.entry:GetTall() - 5 )
	end	
	
	mrp.chatBox.hideBox()
end

--// Hides the chat box but not the messages
function mrp.chatBox.hideBox()
	mrp.chatBox.frame.Paint = function() end
	mrp.chatBox.chatLog:SetScrollBarVisible(false)
	mrp.chatBox.chatLog.active = false

	if mrp.chatBox.chatLog.lastChildMessage then
		mrp.chatBox.chatLog:ScrollToChild(mrp.chatBox.chatLog.lastChildMessage)
	end
	
	--mrp.chatBox.chatLog:GotoTextEnd()
	
	mrp.chatBox.lastMessage = mrp.chatBox.lastMessage or CurTime() - 12
	
	-- Hide the chatbox except the log
	local children = mrp.chatBox.frame:GetChildren()
	for _, pnl in pairs( children ) do
		if pnl == mrp.chatBox.frame.btnMaxim or pnl == mrp.chatBox.frame.btnClose or pnl == mrp.chatBox.frame.btnMinim then continue end
		
		if pnl != mrp.chatBox.chatLog then
			pnl:SetVisible( false )
		end
	end
	
	-- Give the player control again
	mrp.chatBox.frame:SetMouseInputEnabled( false )
	mrp.chatBox.frame:SetKeyboardInputEnabled( false )
	gui.EnableScreenClicker( false )

	-- We are done chatting
	hook.Run("FinishChat")
	
	-- Clear the text entry
	mrp.chatBox.entry:SetText( "" )
	hook.Run( "ChatTextChanged", "" )
end

--// Shows the chat box
function mrp.chatBox.showBox()
	-- Draw the chat box again
	mrp.chatBox.frame.Paint = mrp.chatBox.oldPaint

	mrp.chatBox.chatLog:SetScrollBarVisible(true)
	mrp.chatBox.chatLog.active = true
	
	mrp.chatBox.lastMessage = nil
	
	-- Show any hidden children
	local children = mrp.chatBox.frame:GetChildren()
	for _, pnl in pairs( children ) do
		if pnl == mrp.chatBox.frame.btnMaxim or pnl == mrp.chatBox.frame.btnClose or pnl == mrp.chatBox.frame.btnMinim then continue end
		
		pnl:SetVisible( true )
	end
	
	-- MakePopup calls the input functions so we don't need to call those
	mrp.chatBox.frame:MakePopup()
	mrp.chatBox.entry:RequestFocus()

	-- Make sure other addons know we are chatting
	hook.Run("StartChat")
end

chat.oldAddText = chat.oldAddText or chat.AddText

--// Overwrite chat.AddText to detour it into my chatbox
function chat.AddText(...)
	if not mrp.chatBox.chatLog then
		mrp.chatBox.buildBox()
	end

	if mrp.chatBox.chatLog.active and not mrp.chatBox.entry:IsEditing() then
		mrp.chatBox.chatLog.BlockScroll = true
	end
	
	mrp.chatBox.chatLog:AddText(...)
	--chat.oldAddText(...)

	if mrp.hudEnabled then
		chat.PlaySound()
	end
end

--// Stops the default chat box from being opened
hook.Remove("PlayerBindPress", "mrp.chatBox_hijackbind")
hook.Add("PlayerBindPress", "mrp.chatBox_hijackbind", function(ply, bind, pressed)
	if string.sub( bind, 1, 11 ) == "messagemode" then
		if ply:InVehicle() then -- piano compatablity kill me
			local p1 = ply:GetVehicle():GetParent()

			if p1 and IsValid(p1) then
				local p2 = p1:GetParent()

				if p2 and IsValid(p2) and p2:GetClass() == "gmt_instrument_piano" then
					return true
				end	
			end
		end

		if bind == "messagemode2" then 
			mrp.chatBox.ChatType = "radio"
		else
			mrp.chatBox.ChatType = ""
		end
		
		if IsValid( mrp.chatBox.frame ) then
			mrp.chatBox.showBox()
		else
			mrp.chatBox.buildBox()
			mrp.chatBox.showBox()
		end
		return true
	end
end)

--// Hide the default chat too in case that pops up
hook.Remove("HUDShouldDraw", "mrp.chatBox_hidedefault")
hook.Add("HUDShouldDraw", "mrp.chatBox_hidedefault", function( name )
	if name == "CHudChat" then
		return false
	end
end)

 --// Modify the Chatbox for align.
local oldGetChatBoxPos = chat.GetChatBoxPos
function chat.GetChatBoxPos()
	return mrp.chatBox.frame:GetPos()
end

function chat.GetChatBoxSize()
	return mrp.chatBox.frame:GetSize()
end

chat.Open = mrp.chatBox.showBox
function chat.Close(...)
	if IsValid( mrp.chatBox.frame ) then 
		mrp.chatBox.hideBox(...)
	else
		mrp.chatBox.buildBox()
		mrp.chatBox.showBox()
	end
end
