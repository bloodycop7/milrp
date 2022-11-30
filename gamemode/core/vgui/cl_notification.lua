local PANEL = {}

local baseSizeW, baseSizeH = 300, 25

function PANEL:Init()
	self.message = markup.Parse("")
	self:SetSize(baseSizeW, baseSizeH)
	self.startTime = CurTime()
	self.endTime = CurTime() + 7.5
end

function PANEL:SetMessage(l, scol)
	self.Col = scol or color_white
	-- Encode message into markup
	local msg = "<font=mrp-Font22>"

	for k, v in ipairs({l}) do
		if type(v) == "table" then
			msg = msg.."<color="..v.r..","..v.g..","..v.b..">"
		elseif type(v) == "Player" then
			local col = team.GetColor(v:Team())
			msg= msg.."<color="..col.r..","..col.g..","..col.b..">"..tostring(v:Name()):gsub("<", "&lt;"):gsub(">", "&gt;").."</color>"
		else
			msg = msg..tostring(v):gsub("<", "&lt;"):gsub(">", "&gt;")
		end
	end
	msg = msg.."</font>"

	-- parse
	self.message = markup.Parse(msg, baseSizeW-20)

	-- set frame position and height to suit the markup
	local shiftHeight = self.message:GetHeight()
	self:SetHeight(shiftHeight+baseSizeH)
	surface.PlaySound("buttons/button24.wav")
end

function PANEL:Paint(w, h)
	self.message:Draw(10,10, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

	surface.SetDrawColor(Color(30, 30, 30, 100))
	surface.DrawRect(0, 0, w, h)

	local w2 = math.TimeFraction(self.startTime, self.endTime, CurTime()) * w
	surface.SetDrawColor(Color(235, 235, 235, 140))
	surface.DrawRect(w2, h - 2, w - 5 - w2, 6)

	surface.SetDrawColor(Color(50, 50, 50, 255))
	surface.DrawOutlinedRect(0, 0, w, h)

	surface.SetDrawColor(self.Col)
	surface.DrawRect(w - 5, 0, 5, h)
end

vgui.Register("mrpNotify", PANEL, "DPanel")