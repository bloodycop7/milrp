local PANEL = {}

local baseSizeW, baseSizeH = 1920, 25

function PANEL:Init()
	self.message = markup.Parse("")
	self:SetSize(baseSizeW, baseSizeH)
	self.startTime = CurTime()
	self.endTime = CurTime() + 7.5
end

function PANEL:SetMessage(tbl)
	self.Col = tbl.speakercol or Color(0, 175, 255)
	self.MsgCol = tbl.msgcol or color_white
	-- Encode message into markup
	local msg = "<font=mrp-Font23>"

    msg = msg.."<color="..self.Col.r..","..self.Col.g..","..self.Col.b..">"..tostring(tbl.speaker):gsub("<", "&lt;"):gsub(">", "&gt;").."<color="..self.MsgCol.r..","..self.MsgCol.g..","..self.MsgCol.b..">"

	if ( tbl.dots ) then
		msg = msg..": "..tbl.message
	else
		msg = msg..tbl.message
	end
	
	if not ( string.Right(tbl.message, 1) == "." or string.Right(tbl.message, 1) == "?" or string.Right(tbl.message, 1) == "!" ) then
		msg = msg.."."
	end

	msg = msg.."</font>"

	-- parse
	self.message = markup.Parse(msg, baseSizeW-20)

	-- set frame position and height to suit the markup
	local shiftHeight = self.message:GetHeight()
	self:SetHeight(shiftHeight+baseSizeH)
	surface.PlaySound("buttons/button16.wav")
end

function PANEL:Paint(w, h)
	self.message:Draw(w / 2,10, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end

vgui.Register("mrpSub", PANEL, "DPanel")