local PANEL = {}

function PANEL:Init()
    self:SetPos(10, ScrH() - 60)
	self:SetSize(500, 50)
	self.progress = 0
	self.message = ""

	mrpactiveActionBar = true
end

function PANEL:SetEndTime(endtime)
	self.endTime = endtime
	self.startTime = CurTime()
end

function PANEL:SetText(text)
	self.message = text

    surface.SetFont("mrp-Font21")
    local w, h = surface.GetTextSize(self.message)

    self:SetSize(w + 5, 50)
end

function PANEL:Think()
	if not self.endTime then return end
	local timeDist = self.endTime - CurTime()
	self.progress = math.Clamp(((self.startTime - CurTime()) / (self.startTime - self.endTime)), 0, 1)

	if self.progress == 1 then
		mrpactiveActionBar = false
		self:Remove()

		local endFunc = self.OnEnd
		if endFunc then
			endFunc()
		end
	end
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(Color(30, 30, 30, 100))
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(Color(92, 92, 92, 140))
	surface.DrawRect(5, 5, (w - 10) * self.progress, h - 10)

	surface.SetDrawColor(Color(50, 50, 50, 255))
	surface.DrawOutlinedRect(0, 0, w, h)

	draw.SimpleText(self.message, "mrp-Font21", 5, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("mrpActionBar", PANEL, "DPanel")