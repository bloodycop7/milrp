PLUGIN.name = "Nightvision"
PLUGIN.author = "Random Workshop Guy"

local enabledofblur = CreateConVar( "vrnvg_dofblur", 1, { FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_ARCHIVE }, "i remade this command so it resets back to on for everybody who turned it off >:)" )
local enableepicblur = CreateConVar( "vrnvg_edgeblur", 1, { FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_ARCHIVE }, "blur around the edges of your screen" )
local showremindertext = CreateConVar( "vrnvg_batreminder", 1, { FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_ARCHIVE }, "cool text when recharging battery" )
local playbatteryfullsound = CreateConVar( "vrnvg_batsound", 1, { FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_ARCHIVE }, "cool custom sound when recharged" )
local showthirdpersonnvg = CreateConVar( "vrnvg_thirdperson", 0, { FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_ARCHIVE }, "show nvgs on players when they have it equipped" )
local defualtnkey = CreateConVar( "vrnvg_defaultkey", 1, { FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_ARCHIVE }, "" )
local bloomamount = CreateConVar( "vrnvg_bloom", 0.2, { FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_ARCHIVE }, "", 0, 0.5 )
local contrastamount = CreateConVar( "vrnvg_contrast", 2, { FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_ARCHIVE }, "", 1.5, 2 )
local brightnessnshit = CreateConVar( "vrnvg_brightness", 1, { FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_ARCHIVE }, "" )
local styleofnvg = CreateConVar( "vrnvg_style", 1, { FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_ARCHIVE }, "" )
local sizzlesounds = CreateConVar( "vrnvg_sizzle", 1, { FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_ARCHIVE }, "", 0, 1 )

for k, v in ipairs(engine.GetAddons()) do
	if (v.wsid == "167545348" and v.mounted) then
		print("Manual Weapon Pickup is installed. Unsubscribe from it for Modern Warfare NVGs to work.")

		timer.Create("vrnvgterribleaddon1", 7, 1, function()
                              chat.PlaySound()
			chat.AddText(Color( 0,255,200 ), "Manual Weapon Pickup is installed. Unsubscribe from it for Modern Warfare NVGs to work.")
		end)
	end
          if (v.wsid == "2818916773" and v.mounted) then
		print("Smart Interaction is installed. This addon modifies default functions that Modern Warfare NVGs uses, unsubscribe from it to fix issues.")

		timer.Create("vrnvgterribleaddon2", 7, 1, function()
                              chat.PlaySound()
			chat.AddText(Color( 0,255,200 ), "Smart Interaction is installed. This addon modifies default functions that Modern Warfare NVGs uses, unsubscribe from it to fix issues.")
		end)
	end
end

local rx, gx, bx, ry, gy, by = 0, 0, 0, 0, 0, 0
local black = Material("vrview/black.png")
local ca_r = CreateMaterial( "ca_r", "UnlitGeneric", {
	["$basetexture"] = "vgui/black",
	["$color2"] = "[1 0 0]",
	["$additive"] = 1,
	["$ignorez"] = 1
} )
local ca_g = CreateMaterial( "ca_g", "UnlitGeneric", {
	["$basetexture"] = "vgui/black",
	["$color2"] = "[0 1 0]",
	["$additive"] = 1,
	["$ignorez"] = 1
} )
local ca_b = CreateMaterial( "ca_b", "UnlitGeneric", {
	["$basetexture"] = "vgui/black",
	["$color2"] = "[0 0 1]",
	["$additive"] = 1,
	["$ignorez"] = 1
} )

local function vrnvg_chromatic( rx, gx, bx, ry, gy, by )
    	render.UpdateScreenEffectTexture()
    	local screentx = render.GetScreenEffectTexture()
    	ca_r:SetTexture( "$basetexture", screentx)
    	ca_g:SetTexture( "$basetexture", screentx)
    	ca_b:SetTexture( "$basetexture", screentx)
    	render.SetMaterial( black )
    	render.DrawScreenQuad()
    	render.SetMaterial( ca_r )
    	render.DrawScreenQuadEx( -rx / 2, -ry / 2, ScrW() + rx, ScrH() + ry )
 	render.SetMaterial( ca_g )
    	render.DrawScreenQuadEx( -gx / 2, -gy / 2, ScrW() + gx, ScrH() + gy )
    	render.SetMaterial( ca_b )
    	render.DrawScreenQuadEx( -bx / 2, -by / 2, ScrW() + bx, ScrH() + by )
end

vrnvgcolorpresettable = {
	[1] = Color(0,255,200);
	[2] = 0;
	[3] = 255;
	[4] = 200;
	[5] = .0;
	[6] = .2;
	[7] = .16;
	[8] = .5;
}
local blur = Material("pp/blurscreen")
local blurtoggle = false
local blura = 0
local function drawblur()
    local w, h = ScrW(), ScrH()
    surface.SetMaterial(blur)
    surface.SetDrawColor(255, 255, 255, 255)
    if LocalPlayer():GetViewEntity() ~= LocalPlayer() then return end

    for i = 1, blura do
          blur:SetFloat( "$blur", (i / blura ) * ( blura ) )
          blur:Recompute()
          render.UpdateScreenEffectTexture()
          surface.DrawTexturedRect(0, 0, w, h) --fades out near bottom (edit: not anymore, was h*1.2 )
    end
end

local edgeblurtex = Material("pp/toytown-top")
local function edgeblur( passed, H )
	if !enableepicblur:GetBool() then return end
	surface.SetMaterial( edgeblurtex )
	surface.SetDrawColor( 255, 255, 255, 255 )
	for i = 1, passed do
		render.CopyRenderTargetToTexture( render.GetScreenEffectTexture() )

		surface.DrawTexturedRect( 0, 0, ScrW(), H )
        		surface.DrawTexturedRectUV( 0, ScrH() - H, ScrW(), H, 0, 1, 1, 0 )
        		surface.DrawTexturedRectRotated( 0, 0, ScrW(), H*6, 90 )
        		surface.DrawTexturedRectRotated( ScrW(), 0, ScrW(), H*6, -90 )
	end
end

local function vrnvg_bluegreen() --dumb
	local ply = LocalPlayer()
	if ply.vrnvgflipped then
		blura = 15
	end
	vrnvgcolorpresettable[1] = Color(0,255,200);
	vrnvgcolorpresettable[2] = 0;
	vrnvgcolorpresettable[3] = 255;
	vrnvgcolorpresettable[4] = 200;
	vrnvgcolorpresettable[5] = 0;
	vrnvgcolorpresettable[6] = .2;
	vrnvgcolorpresettable[7] = .16;

	vrnvgcolorpresettable[8] = .5;
end
local function vrnvg_lightblue()
	local ply = LocalPlayer()
	if ply.vrnvgflipped then
		blura = 15
	end
	vrnvgcolorpresettable[1] = Color(0,150,255);
	vrnvgcolorpresettable[2] = 0;
	vrnvgcolorpresettable[3] = 150;
	vrnvgcolorpresettable[4] = 255;
	vrnvgcolorpresettable[5] = .0;
	vrnvgcolorpresettable[6] = .1;
	vrnvgcolorpresettable[7] = .2;

	vrnvgcolorpresettable[8] = .5;
end
local function vrnvg_lightred()
	local ply = LocalPlayer()
	if ply.vrnvgflipped then
		blura = 15
	end
	vrnvgcolorpresettable[1] = Color(255,35,35);
	vrnvgcolorpresettable[2] = 255;
	vrnvgcolorpresettable[3] = 35;
	vrnvgcolorpresettable[4] = 35;
	vrnvgcolorpresettable[5] = .2;
	vrnvgcolorpresettable[6] = .02;
	vrnvgcolorpresettable[7] = .02;

	vrnvgcolorpresettable[8] = .5;
end
local function vrnvg_classicgreen()
	local ply = LocalPlayer()
	if ply.vrnvgflipped then
		blura = 15
	end
	vrnvgcolorpresettable[1] = Color(25,255,25);
	vrnvgcolorpresettable[2] = 25;
	vrnvgcolorpresettable[3] = 255;
	vrnvgcolorpresettable[4] = 25;
	vrnvgcolorpresettable[5] = .01;
	vrnvgcolorpresettable[6] = .2;
	vrnvgcolorpresettable[7] = .01;

	vrnvgcolorpresettable[8] = .5;
end
local function vrnvg_closecolormenu()
	if vrnvgframe then
		vrnvgframe:AlphaTo(0, 0.25)
		timer.Simple(0.25, function()
			if vrnvgframe then
				vrnvgframe:Remove()
				vrnvgframe = nil
			end
		end)
		closedisbiatch = true
	end
end

--derma....
local classicgreenmat =Material("ventrische/nvg/greenmini.png")
local bluegreenmat = Material("ventrische/nvg/whitemini.png")
local lightredmat = Material("ventrische/nvg/redmini.png")
local bluebluemat = Material("ventrische/nvg/bluemini.png")
local function vrnvg_colormenu()
	if (vrnvgframe) then
		vrnvgframe:Remove()
		vrnvgframe = nil
	end
	vrnvgframe = vgui.Create( "DFrame" )
	vrnvgframe:SetAlpha(0)
	vrnvgframe:AlphaTo(255, 0.25)
	vrnvgframe:SetSize( 825, 250 )
	vrnvgframe:SetTitle("")
	vrnvgframe:ShowCloseButton(false)
	vrnvgframe:Center()
	vrnvgframe:MakePopup()
	vrnvgframe:SetDraggable(false)
	vrnvgframe.lerp1 = 0
	vrnvgframe.Paint = function(self)
		vrnvgframe.lerp1 = Lerp(FrameTime()*6, vrnvgframe.lerp1, 825)
		draw.RoundedBox(0, 415 - vrnvgframe.lerp1/2, 0, vrnvgframe.lerp1, self:GetTall(), Color(0,0,0,125))
	end

	vrnvgbutton1 = vgui.Create( "DButton", vrnvgframe )
	vrnvgbutton1:SetAlpha(0)
	vrnvgbutton1:AlphaTo(255, 1.5)
	vrnvgbutton1:SetPos( 25, 35 )	
	vrnvgbutton1:SetSize( 180, 186 )
	vrnvgbutton1:SetText("")
	vrnvgbutton1.lerp1 = 0
	vrnvgbutton1.lerp2 = 0
	vrnvgbutton1.lerp3 = 0
	vrnvgbutton1.Paint = function(self)
		local ft = FrameTime()
		if self:IsHovered() then 
			self.lerp1 = Lerp(ft*6, self.lerp1, 25)
			self.lerp2 = Lerp(ft*6, self.lerp2, 150)
			self.lerp3 = Lerp(ft*10, self.lerp3, 0)
		else
			self.lerp1 = Lerp(ft*6, self.lerp1, 0)
			self.lerp2 = Lerp(ft*6, self.lerp2, 0)
			self.lerp3 = Lerp(ft*6, self.lerp3, 200)
		end
		
		draw.RoundedBox(self.lerp1/2, 2, 66 - self.lerp1*2.5, 170, 30 + self.lerp2, Color(0,0,0,100))
		draw.RoundedBox(self.lerp1/2, 0, 64 - self.lerp1*2.5, 170, 30 + self.lerp2, Color(0,0,0,100))
		draw.SimpleText("RED", "vrnvgdigitsmenu", 87, 82 + self.lerp2/2.5, Color(0,0,0,100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("RED", "vrnvgdigitsmenu", 85, 80 + self.lerp2/2.5, Color(150+self.lerp2,50,50,150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
		surface.SetMaterial(lightredmat)
		surface.SetDrawColor(Color(0,0,0,self.lerp2/1.5))
		surface.DrawTexturedRect(28, 17, 112, 112)

		surface.SetDrawColor(Color(150+self.lerp2/2,50,50,self.lerp2))
		surface.DrawTexturedRect(30, 15, 112, 112)
	end
	vrnvgbutton1.DoClick = function()
		vrnvg_closecolormenu()
		vrnvg_lightred()
		surface.PlaySound("ventrische/nvg/night_vision_on_c.wav")
	end

	vrnvgbutton2 = vgui.Create( "DButton", vrnvgframe )
	vrnvgbutton2:SetAlpha(0)
	vrnvgbutton2:AlphaTo(255, 1.5)
	vrnvgbutton2:SetPos( 225, 35 )	
	vrnvgbutton2:SetSize( 180, 186 )
	vrnvgbutton2:SetText("")
	vrnvgbutton2.lerp1 = 0
	vrnvgbutton2.lerp2 = 0
	vrnvgbutton2.lerp3 = 0
	vrnvgbutton2.Paint = function(self)
		local ft = FrameTime()
		if self:IsHovered() then 
			self.lerp1 = Lerp(ft*6, self.lerp1, 25)
			self.lerp2 = Lerp(ft*6, self.lerp2, 150)
			self.lerp3 = Lerp(ft*10, self.lerp3, 0)
		else
			self.lerp1 = Lerp(ft*6, self.lerp1, 0)
			self.lerp2 = Lerp(ft*6, self.lerp2, 0)
			self.lerp3 = Lerp(ft*6, self.lerp3, 200)
		end
		
		draw.RoundedBox(self.lerp1/2, 2, 66 - self.lerp1*2.5, 170, 30 + self.lerp2, Color(0,0,0,100))
		draw.RoundedBox(self.lerp1/2, 0, 64 - self.lerp1*2.5, 170, 30 + self.lerp2, Color(0,0,0,100))
		draw.SimpleText("WHITE", "vrnvgdigitsmenu", 87, 82 + self.lerp2/2.5, Color(0,0,0,100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("WHITE", "vrnvgdigitsmenu", 85, 80 + self.lerp2/2.5, Color(0,150+self.lerp2,150+self.lerp2/2,150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
		surface.SetMaterial(bluegreenmat)
		surface.SetDrawColor(Color(0,0,0,self.lerp2/1.5))
		surface.DrawTexturedRect(28, 17, 112, 112)

		surface.SetDrawColor(Color(0,150+self.lerp2/2,150+self.lerp2/3,self.lerp2))
		surface.DrawTexturedRect(30, 15, 112, 112)
	end
	vrnvgbutton2.DoClick = function()
		vrnvg_closecolormenu()
		vrnvg_bluegreen()
		surface.PlaySound("ventrische/nvg/night_vision_on_c.wav")
	end

	vrnvgbutton3 = vgui.Create( "DButton", vrnvgframe )
	vrnvgbutton3:SetAlpha(0)
	vrnvgbutton3:AlphaTo(255, 1.5)
	vrnvgbutton3:SetPos( 425, 35 )	
	vrnvgbutton3:SetSize( 180, 186 )
	vrnvgbutton3:SetText("")
	vrnvgbutton3.lerp1 = 0
	vrnvgbutton3.lerp2 = 0
	vrnvgbutton3.lerp3 = 0
	vrnvgbutton3.Paint = function(self)
		local ft = FrameTime()
		if self:IsHovered() then 
			self.lerp1 = Lerp(ft*6, self.lerp1, 25)
			self.lerp2 = Lerp(ft*6, self.lerp2, 150)
			self.lerp3 = Lerp(ft*10, self.lerp3, 0)
		else
			self.lerp1 = Lerp(ft*6, self.lerp1, 0)
			self.lerp2 = Lerp(ft*6, self.lerp2, 0)
			self.lerp3 = Lerp(ft*6, self.lerp3, 200)
		end
		
		draw.RoundedBox(self.lerp1/2, 2, 66 - self.lerp1*2.5, 170, 30 + self.lerp2, Color(0,0,0,100))
		draw.RoundedBox(self.lerp1/2, 0, 64 - self.lerp1*2.5, 170, 30 + self.lerp2, Color(0,0,0,100))
		draw.SimpleText("BLUE", "vrnvgdigitsmenu", 87, 82 + self.lerp2/2.5, Color(0,0,0,100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("BLUE", "vrnvgdigitsmenu", 85, 80 + self.lerp2/2.5, Color(0,100+self.lerp2/2,150+self.lerp2,150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
		surface.SetMaterial(bluebluemat)
		surface.SetDrawColor(Color(0,0,0,self.lerp2/1.5))
		surface.DrawTexturedRect(28, 17, 112, 112)

		surface.SetDrawColor(Color(0,100+self.lerp2/3,150+self.lerp2/2,self.lerp2))
		surface.DrawTexturedRect(30, 15, 112, 112)
	end
	vrnvgbutton3.DoClick = function()
		vrnvg_closecolormenu()
		vrnvg_lightblue()
		surface.PlaySound("ventrische/nvg/night_vision_on_c.wav")
	end

	vrnvgbutton4 = vgui.Create( "DButton", vrnvgframe )
	vrnvgbutton4:SetAlpha(0)
	vrnvgbutton4:AlphaTo(255, 1.5)
	vrnvgbutton4:SetPos( 625, 35 )	
	vrnvgbutton4:SetSize( 180, 186 )
	vrnvgbutton4:SetText("")
	vrnvgbutton4.lerp1 = 0
	vrnvgbutton4.lerp2 = 0
	vrnvgbutton4.lerp3 = 0
	vrnvgbutton4.Paint = function(self)
		local ft = FrameTime()
		if self:IsHovered() then 
			self.lerp1 = Lerp(ft*6, self.lerp1, 25)
			self.lerp2 = Lerp(ft*6, self.lerp2, 150)
			self.lerp3 = Lerp(ft*10, self.lerp3, 0)
		else
			self.lerp1 = Lerp(ft*6, self.lerp1, 0)
			self.lerp2 = Lerp(ft*6, self.lerp2, 0)
			self.lerp3 = Lerp(ft*6, self.lerp3, 200)
		end
		
		draw.RoundedBox(self.lerp1/2, 2, 66 - self.lerp1*2.5, 170, 30 + self.lerp2, Color(0,0,0,100))
		draw.RoundedBox(self.lerp1/2, 0, 64 - self.lerp1*2.5, 170, 30 + self.lerp2, Color(0,0,0,100))
		draw.SimpleText("GREEN", "vrnvgdigitsmenu", 87, 82 + self.lerp2/2.5, Color(0,0,0,100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("GREEN", "vrnvgdigitsmenu", 85, 80 + self.lerp2/2.5, Color(0,150+self.lerp2/2,0,150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		surface.SetMaterial(classicgreenmat)
		surface.SetDrawColor(Color(0,0,0,self.lerp2/1.5))
		surface.DrawTexturedRect(28, 17, 112, 112)

		surface.SetDrawColor(Color(0,150+self.lerp2/3,0,self.lerp2))
		surface.DrawTexturedRect(30, 15, 112, 112)
	end
	vrnvgbutton4.DoClick = function()
		vrnvg_closecolormenu()
		vrnvg_classicgreen()
		surface.PlaySound("ventrische/nvg/night_vision_on_c.wav")
	end
end

sound.Add({
	name = "vrnvg_elecsizzle",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 50,
	pitch = 100,
	sound = "ventrische/nvg/sizzlesizzle.mp3"
})
sound.Add({
	name = "vrnvg_elechum",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 50,
	pitch = 100,
	sound = "ventrische/nvg/hum.wav"
})

surface.CreateFont("vrnvgdigits", {
    font = "Sicret Mono PERSONAL Light",
    extended = false,
    size = 15,
    weight = 500,
    antialias = true,
    shadow = true --awful shadow
})
surface.CreateFont("vrnvgdigitsbig", {
	font = "Futura Md BT",
	extended = false,
	size = 35,
	weight = 500,
	antialias = true,
	shadow = false
})
surface.CreateFont("vrnvgdigitsmenu", {
	font = "Futura Md BT",
	extended = false,
	size = 35,
	weight = 700,
	antialias = true,
	shadow = false
})
surface.CreateFont("vrnvgdigitsNOS", {
	font = "Sicret Mono PERSONAL Light",
	extended = false,
	size = 15,
	weight = 500,
	antialias = true,
	shadow = false
})

local vrnvgsway = {}
vrnvgsway.lerpx = 0
vrnvgsway.lerpy = 0
vrnvgsway.angle1 = 0
vrnvgsway.angle2 = 0
vrnvgsway.clampx = 0
vrnvgsway.clampy = 0
hook.Add("Think", "nvghuduiandmisc", function()
	local ply = LocalPlayer()
	local eyeang = ply:EyeAngles()
	local ft = FrameTime()
	
	if !vrnvgcolorpresettable then
		vrnvgcolorpresettable = {
			[1] = Color(0,255,200);
			[2] = 0;
			[3] = 255;
			[4] = 200;
			[5] = .0;
			[6] = .2;
			[7] = .16;
			[8] = .5;
		}
	end

	if ply:GetViewEntity() == ply or !ply:Alive() then 
		if ply.vrnvgplayermodel then
			ply.vrnvgplayermodel:Remove()
			ply.vrnvgplayermodel = nil
		end
	end

          --yoinked but its just angle lerp so who cares
	if ply.quadnodson then
		vrnvgsway.lerpx = Lerp(ft*8, vrnvgsway.lerpx, math.Clamp(vrnvgsway.clampx + math.AngleDifference(eyeang.y * 2.25, vrnvgsway.angle1) * 2, -25, 25))
		vrnvgsway.lerpy = Lerp(ft*8, vrnvgsway.lerpy, math.Clamp(vrnvgsway.clampy + math.AngleDifference(eyeang.p * 2.25, vrnvgsway.angle2) * 2, -25, 25))

		if vrnvgsway.angle1 ~= eyeang.y * 2.25 then
			vrnvgsway.angle1 = eyeang.y * 2.25
		end
		if vrnvgsway.angle2 ~= eyeang.p * 2.25 then
			vrnvgsway.angle2 = eyeang.p * 2.25
		end
	end

          --dlights for light on weapons
	if ply.quadnodsonlight and ply:Alive() then
		local vrnvgdlight = DynamicLight( ply:EntIndex() )

		if vrnvgdlight and styleofnvg:GetFloat() == 1 then
			vrnvgdlight.pos = ply:GetShootPos()
			vrnvgdlight.r = vrnvgcolorpresettable[2]
			vrnvgdlight.g = vrnvgcolorpresettable[3]
			vrnvgdlight.b = vrnvgcolorpresettable[4]
			vrnvgdlight.brightness = 0.5
			vrnvgdlight.Decay = 1000
			vrnvgdlight.Size = 250
			vrnvgdlight.DieTime = CurTime()
		elseif vrnvgdlight and styleofnvg:GetFloat() == 2 then
			vrnvgdlight.pos = ply:GetShootPos()
			vrnvgdlight.r = vrnvgcolorpresettable[2]
			vrnvgdlight.g = vrnvgcolorpresettable[3]
			vrnvgdlight.b = vrnvgcolorpresettable[4]
			vrnvgdlight.brightness = 0.5
			vrnvgdlight.Decay = 1000
			vrnvgdlight.Size = 100
			vrnvgdlight.DieTime = CurTime()
		end
	end
end)

local hide = {
    ["CHudWeaponSelection"] = true
}
local function vrnvgweaponblock(name)
    if blurtoggle then
        if ( hide[ name ] ) then
            return false
        end
    end
end;
hook.Add("HUDShouldDraw", "vrnvgweaponblock", vrnvgweaponblock)

local function vrplayanim(seq, time)
	local ply = LocalPlayer()
	if time then 
		blurtoggle = true 
		timer.Simple(time, function()
			blurtoggle = false
		end)
	end

	if ply.vrnvgcam then
		ply.vrnvgcam:ResetSequence(seq)
		ply.vrnvgcam:SetPlaybackRate(1)
		ply.vrnvgcam:SetCycle(0)
	end
	if ply.vrnvgmodel then
		ply.vrnvgmodel:ResetSequence(seq)
		ply.vrnvgmodel:SetPlaybackRate(1)
		ply.vrnvgmodel:SetCycle(0)
	end
end

net.Receive("vrnvgwarzone", function()
	RunConsoleCommand("vrnvgequip")
end)

local nvgflashlerp = 0
net.Receive("vrnvgnetequip", function()
	local boolin = net.ReadBool()
	local ply = LocalPlayer()

	ply.vrnvgequipped = boolin
	if boolin then
		vrplayanim("equip", 1.8)
	else
		vrplayanim("unequip", 1.8) --https://i.imgur.com/UnxjyWy.png
	end
end)
net.Receive("vrnvgnetflip", function()
	local boolin = net.ReadBool()
	local ply = LocalPlayer()

	ply.vrnvgflipped = boolin
	if boolin then
		surface.PlaySound("ventrische/nvg/flipdown.mp3")
		timer.Simple(.75, function()
			ply.quadnodson = true
			ply.quadnodsonlight = true

                              --nvg projectedtexture light, absolutely no nvg mod knew about this until this addon for some reason lol 
			if !ply.nvglightdraw then 
				if styleofnvg:GetFloat() == 1 then
					ply.nvglightdraw = ProjectedTexture()
					ply.nvglightdraw:SetTexture( "effects/flashlight/soft" )
					ply.nvglightdraw:SetFOV( 140 )
					ply.nvglightdraw:SetVerticalFOV(100)
					ply.nvglightdraw:SetBrightness(1 * brightnessnshit:GetFloat())
					ply.nvglightdraw:SetEnableShadows(false)
					ply.nvglightdraw:Update()
				elseif styleofnvg:GetFloat() == 2 then 
					ply.nvglightdraw = ProjectedTexture()
					ply.nvglightdraw:SetTexture( "effects/flashlight/soft" )
					ply.nvglightdraw:SetFOV( 50 )
					ply.nvglightdraw:SetVerticalFOV(45)
					ply.nvglightdraw:SetBrightness(2 * brightnessnshit:GetFloat())
					ply.nvglightdraw:SetEnableShadows(false)
					ply.nvglightdraw:Update()
				end
			end

			surface.PlaySound("ventrische/nvg/night_vision_on.wav")
			nvgflashlerp = 255
		end)

		vrplayanim("flipdown", 1.3)
	else
		if ply.nvglightdraw or ply.nvgnobattery then 
			surface.PlaySound("ventrische/nvg/flipup.mp3")
			timer.Simple(.25, function()
				ply.quadnodson = false
				if !ply.nvgnobattery then
					ply.nvglightdraw:Remove()
					ply.nvglightdraw = nil
				else 
					ply.nvgnobattery = false
				end

				surface.PlaySound("ventrische/nvg/night_vision_off.wav")
			end)
			timer.Simple(.2, function()
				ply.quadnodsonlight = false
			end)

			vrplayanim("flipup", 1.1)
		end
	end
end)
local glassposx = 0
local glassposy = 0
net.Receive("vrnvgnetbreakeasymode", function()
	local boolin = net.ReadBool()
	local ply = LocalPlayer()

	glassposx = math.random(2.5, 1.75)
	glassposy = math.random(4, 20) --https://www.youtube.com/watch?v=aAEAf60_iX8
	if boolin then
		surface.PlaySound("ventrische/nvg/night_vision_off.wav")
		surface.PlaySound("ventrische/nvg/glasscrack.mp3")
		ply.vrnvgbroken = true
		ply.nvgnobattery = false

		if ply.nvglightdraw then
			ply.nvglightdraw:Remove()
			ply.nvglightdraw = nil
		end
		ply.quadnodsonlight = false
	end
end)
net.Receive("vrnvgnetbreak", function()
	local boolin = net.ReadBool()
	local ply = LocalPlayer()

	if boolin then
		ply.vrnvgequipped = false
		ply.vrnvgflipped = false

		surface.PlaySound("ventrische/nvg/breaktoss.mp3")
		vrplayanim("breaktoss", 4.82)
		timer.Simple(.3, function()
			ply.vrnvgbroken = false
			ply.nvgnobattery = false
			ply.quadnodson = false
		end)
	end
end)

local viggy = Material("vrview/ventwhitevig")
local battery = Material("ventrische/nvg/tinybattery.png")
local linebar = Material("ventrische/nvg/linebar8.png")
local scale = Material("ventrische/nvg/scale.png")
local moon = Material("ventrische/nvg/moonnn.png")
local sun = Material("ventrische/nvg/sunnn.png")
local broken = Material("vrview/fx_distort")
local crackref = Material("vrview/glass/glasscrack")
local crack1 = Material("vrview/glass/glasscrack.png")
local crackref2 = Material("vrview/glass/glasscrack2")
local crack2 = Material("vrview/glass/glasscrack20.png") --layering the pngs and vtfs makes it look good
local crackref3 = Material("vrview/glass/glasscrack3")
local crack3 = Material("vrview/glass/glasscrack3.png")
local lightcolor = 0
local lightcolor2 = 0
local humlevel = 0.4
local batteryoffnvgs = 0
local ooga = {}

--the meat
local function vrnvgbackground()
	local ply = LocalPlayer()
	local ft = FrameTime()
	local eang, epos = EyeAngles(), EyePos()
	local w, h = ScrW(), ScrH()
	local p, q = vrnvgsway.lerpx * 1.1, -vrnvgsway.lerpy * 1.1
	local bluegreencolor = Color(vrnvgcolorpresettable[2],vrnvgcolorpresettable[3],vrnvgcolorpresettable[4],100)
	local nvgs = ply.vrnvgmodel
	local nvgcam = ply.vrnvgcam
	if !ply:Alive() or !ply:IsValid() then 
                    local viewmodel = ply:GetViewModel()
                    blura = 0
		ply:StopSound("vrnvg_elecsizzle")
		ply:StopSound("vrnvg_elechum")
		ply.quadnodson = false
		ply.vrnvgequipped = false
		ply.vrnvgflipped = false
		ply.quadnodsonlight = false
		ply.vrnvgbroken = false
		if ply.vrnvgmodel then
			ply.vrnvgmodel:Remove()
			ply.vrnvgmodel = nil
                              if ply.vrnvghand then
                                        ply.vrnvghand:Remove()
                                        ply.vrnvghand = nil
                              end
			ply.vrnvgcam:Remove()
			ply.vrnvgcam = nil
		end
		if (viewmodel and IsValid(viewmodel)) then
			if ( viewmodel:GetSequence(viewmodel:LookupSequence("idleoff")) ) then
				if viewmodel:GetSequence() != viewmodel:LookupSequence("idleoff") then
					vrplayanim("idleoff") 
				end
			end
		end
		if ply.nvglightdraw then
			ply.nvglightdraw:Remove()
			ply.nvglightdraw = nil
		end
                    return
	end

          if !ply.nvgbattery then 
                    ply.nvgbattery = 80
          end
	if ply.vrnvgequipped then
		net.Start("vrnvgnetflashlight")
		net.WriteBool(ply.vrnvgflipped and ply.nvgbattery > 0 and !ply.vrnvgbroken)
		net.SendToServer()

		ply.nvgbattery = ply:GetNW2Int("vrnvgbattery")
	end

	--[[if blura > 0 and enabledofblur:GetBool() then
		drawblur() 
	end]]
	if blurtoggle then
		blura = math.Approach(blura, 4, ft*20)
          elseif ply.quadnodson then
                    if ply.nvgbattery >= 40 then 
                              blura = math.Approach(blura, math.random(1, 2), ft*20)
                              humlevel = 0.4
                    elseif ply.nvgbattery < 40 and ply.nvgbattery >= 20 then 
                              blura = math.Approach(blura, math.random(1, 3), ft*15)
                              humlevel = 0.7
                    elseif ply.nvgbattery < 20 and ply.nvgbattery > 0 then 
                              blura = math.Approach(blura, math.random(1, 4), ft*10)
                              humlevel = 1
                    end
	else
		humlevel = 0.4
		blura = math.Approach(blura, 0, ft*25)
	end

          --reminder: ignorez wuz here 
	local nvgs = ply.vrnvgmodel
	local nvgcam = ply.vrnvgcam
	cam.Start3D( epos, eang, 100, 0, 0, w, h, 1, 35)
		if nvgs and ply.vrnvghand then
			nvgs:SetPos(epos + Vector(0,0,0.3))
			nvgs:SetAngles(eang)
			nvgs:SetupBones()
			nvgs:FrameAdvance(ft)
			ply.vrnvghand:SetupBones()
			nvgcam:SetPos(Vector(0,0,0))
			nvgcam:SetAngles(Angle(0,0,0))
			nvgcam:FrameAdvance(ft)
			ply.nvgcamattach = nvgcam:GetAttachment(nvgcam:LookupAttachment("Camera"))
			if ply:GetViewEntity() == ply and !ply:ShouldDrawLocalPlayer() and !sky3d then 
				nvgs:DrawModel() 
			end
		end
	cam.End3D()

          --broken/no battery HUD
	if ply.vrnvgbroken or ply.nvgnobattery then 
		surface.SetDrawColor(Color(255,255,255,255))
		surface.SetMaterial(broken)
		surface.DrawTexturedRect(0, 0, w, h)
	end

          --battery HUD
	if ply.vrnvgequipped and !ply.quadnodson and !ply.vrnvgbroken and showremindertext:GetBool() and ply:GetViewEntity() == ply then
		local nodbone = nvgs:LookupBone("nod")
		local nodbonep = nvgs:GetBonePosition(nodbone)
		if nodbonep == nvgs:GetPos() then
			nodbonep = nvgs:GetBoneMatrix(nodbone):GetTranslation()
		end
		ooga = nodbonep:ToScreen()
		local n, m = math.Round(ooga.x, 0), math.Round(ooga.y, 0)
		local percentage = math.Round(ply.nvgbattery*1.25, 0)

		draw.SimpleText(percentage, "vrnvgdigitsbig", n + 2, m + 150 + 2, Color(21,21,21,batteryoffnvgs/2), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(percentage, "vrnvgdigitsbig", n, m + 150, Color(255,255,255,batteryoffnvgs), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		if batterynvg2dfade or ply.nvgbattery > 75 then 
			batteryoffnvgs = Lerp(ft*6, batteryoffnvgs, 0)
		end
	end

          --misc sounds and sizzle
	if ply.quadnodson then 
		if ply.vrnvgflipped and playbatteryfullsound:GetBool() then
			rechargedsoundplayedomg = true
		end

		if (!nvghummingrepeat or CurTime() >= nvghummingrepeat) then
			nvghummingrepeat = CurTime() + 10 --lazy
			ply:EmitSound("vrnvg_elechum", 75, 100, humlevel)
		end
	else 
		if rechargedsoundplayedomg and ply.nvgbattery > 75 and !ply.vrnvgbroken and ply.nvgbattery ~= 80 then
			surface.PlaySound("ventrische/nvg/theclassicventycustomaudiorequirement/recharged.mp3")
			rechargedsoundplayedomg = false
		end
		nvghummingrepeat = CurTime()
		ply:StopSound("vrnvg_elechum")
	end

          --lens crack/glass crack
	if ply.vrnvgbroken or ply.nvgnobattery then 
		ply:StopSound("vrnvg_elechum")
		surface.SetDrawColor(Color(0,0,0,255))
		surface.SetMaterial(viggy)
		surface.DrawTexturedRect(0, 0, w, h)

		if !ply.nvgnobattery then
			surface.SetDrawColor(Color(255,255,255,50))
			surface.SetMaterial(crack1)
			surface.DrawTexturedRect(w/glassposx, h/glassposy, 1000, 1000)
			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetMaterial(crackref)
			surface.DrawTexturedRect(w/glassposx, h/glassposy, 1000, 1000)

			surface.SetDrawColor(Color(255,255,255,50))
			surface.SetMaterial(crack2)
			surface.DrawTexturedRect(w*.1-200, h/2 + 110, 1000, 1000)
			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetMaterial(crackref2)
			surface.DrawTexturedRect(w*.1-200, h/2 + 110, 1000, 1000)

			surface.SetDrawColor(Color(255,255,255,50))
			surface.SetMaterial(crack3)
			surface.DrawTexturedRect(w*.1-700, h/5 - 700, 1000, 1000)
		end
	end

          --sizzle sound, light blinding, main HUD
	if ply.nvglightdraw then
		ply.nvglightdraw:SetColor( vrnvgcolorpresettable[1] )
		ply.nvglightdraw:SetFarZ( 10000 ) 
		if ply:GetViewEntity() == ply then
			ply.nvglightdraw:SetPos( ply:GetPos() + Vector(0,0,50)) 
			ply.nvglightdraw:SetAngles( ply:EyeAngles() )
		else
			nvghummingrepeat = CurTime()
			ply:StopSound("vrnvg_elechum")
			ply.nvglightdraw:SetPos( ply:GetPos() + Vector(0,0,2400000000))
			ply.nvglightdraw:SetAngles( Angle(90,0,0) )
		end
		ply.nvglightdraw:Update()
		

        		local tr = util.QuickTrace(ply:GetShootPos() + ply:EyeAngles():Forward()*250, gui.ScreenToVector(gui.MousePos()),ply)
		local lightcolorreg = render.GetLightColor(ply:GetPos())
		local lightcoloreye = render.GetLightColor(tr.HitPos)
		local lightcolorreg2 = lightcolorreg.r/3 + lightcolorreg.g/3 + lightcolorreg.b/3
		local lightcoloreye2 = lightcoloreye.r/3 + lightcoloreye.g/3 + lightcoloreye.b/3

		local lightcolorclamp = math.Clamp(lightcolorreg2, 0.003332, .45)
		local lightcoloreyeclamp = math.Clamp(lightcoloreye2, 0.003332, .45)

		lightcolor = Lerp(ft*4, lightcolor, lightcolorclamp)
		lightcolor2 = Lerp(ft*4, lightcolor2, lightcoloreyeclamp)

		draw.RoundedBox(0, 0, 0, w, h, Color(255,255,255,nvgflashlerp))
		nvgflashlerp = math.Approach(nvgflashlerp, 0, ft*600)
		if lightcolor > 0.2 then
			if sizzlesounds:GetFloat() > 0 then
				if (!nvgsizzlerepeat or CurTime() >= nvgsizzlerepeat) then
					nvgsizzlerepeat = CurTime() + 24 --lazy
					ply:EmitSound("vrnvg_elecsizzle")
				end
			end
		elseif lightcolor > 0.1 then 
			if nvglightmeter then
				surface.PlaySound("ventrische/nvg/night_vision_lightmeter_warning.wav")
				nvglightmeter = false 
			end
			nvgsizzlerepeat = CurTime()
			ply:StopSound("vrnvg_elecsizzle")
		else
			nvglightmeter = true
			nvgsizzlerepeat = CurTime()
			ply:StopSound("vrnvg_elecsizzle")
		end

		surface.SetDrawColor(Color(0,0,0,255))
		surface.SetMaterial(viggy)
		surface.DrawTexturedRect(0, 0, w, h)

		if ply.nvgbattery < 20 then
			local capitfucker = math.Clamp(150*math.sin(CurTime()*3), 0, 150)
			surface.SetDrawColor(Color(capitfucker, 0, 0, 150))
			surface.SetMaterial(battery)
			surface.DrawTexturedRect(w/4 - 220 + p, h/1.4 + q, 80, 30)
		else
			surface.SetDrawColor(Color(21,21,21,125))
			surface.SetMaterial(battery)
			surface.DrawTexturedRect(w/4 - 220 + p, h/1.4 + q, 80, 30)

			surface.SetDrawColor(bluegreencolor)
			surface.SetMaterial(battery)
			render.SetScissorRect( 0+ p, 0+ q, w/4 - 230 + ply.nvgbattery*1.15 + p, ScrH() + q, true )
				surface.DrawTexturedRect(w/4 - 220 + p, h/1.4 + q, 80, 30)
			render.SetScissorRect( 0, 0, 0, 0, false )
		end
		local percentage = math.Round(ply.nvgbattery*1.25, 0)
		draw.SimpleText(percentage.."%", "vrnvgdigits", w/4 - 135 + p, h/1.4 + 5 + q, Color(vrnvgcolorpresettable[2],vrnvgcolorpresettable[3],vrnvgcolorpresettable[4],150), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)

		surface.SetDrawColor(bluegreencolor)
		surface.SetMaterial(scale)
		surface.DrawTexturedRect(w/4 - 190 + p, h/1.6 + q - 2 - lightcolor*500, 30, 5)
		surface.SetFont( "vrnvgdigits" )
		local tw = surface.GetTextSize( math.Round(lightcolor*3, 3) )
		draw.RoundedBox(4, w/4 - 155 + p, h/1.6 + q - 8 - lightcolor*500, tw + 10, 15, Color(vrnvgcolorpresettable[2],vrnvgcolorpresettable[3],vrnvgcolorpresettable[4],50))
		render.PushFilterMag(TEXFILTER.ANISOTROPIC)
    		render.PushFilterMin(TEXFILTER.ANISOTROPIC)
		    	draw.SimpleText(math.Round(lightcolor*3, 3), "vrnvgdigitsNOS", w/4 - 150 + p + 1, h/1.6 + q - 7 - lightcolor*500 + 1, Color(0,0,0,150), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
			draw.SimpleText(math.Round(lightcolor*3, 3), "vrnvgdigitsNOS", w/4 - 150 + p, h/1.6 + q - 7 - lightcolor*500, Color(vrnvgcolorpresettable[2],vrnvgcolorpresettable[3],vrnvgcolorpresettable[4],150), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
		render.PopFilterMag()
		render.PopFilterMin()

		surface.SetDrawColor(bluegreencolor)
		surface.SetMaterial(linebar)
		surface.DrawTexturedRect(w/4 - 225 + p, h/1.6 + q - 225, 20, 225)

		surface.SetDrawColor(bluegreencolor)
		surface.SetMaterial(moon)
		surface.DrawTexturedRect(w/4 - 200 + p, h/1.6 + 7 + q, 8, 12)

		surface.SetDrawColor(bluegreencolor)
		surface.SetMaterial(sun)
		surface.DrawTexturedRect(w/4 - 205 + p, h/1.6 - 250 + q, 20, 20)


		draw.RoundedBox(2, w/4 - 200 + p, h/1.6 + q - 225, 10, 225, Color(0,0,0,100))
		draw.RoundedBox(0, w/4 - 200 + p, h/1.6 + q - lightcolor*500, 10, lightcolor*500, bluegreencolor)
	elseif ply.vrnvgbroken or ply.nvgnobattery then 
		draw.RoundedBox(0, 0, 0, w, h, Color(255,255,255,nvgflashlerp))
		nvgflashlerp = math.Approach(nvgflashlerp, 0, ft*20)
		ply:StopSound("vrnvg_elecsizzle")
	else 
		nvgsizzlerepeat = CurTime()
		ply:StopSound("vrnvg_elecsizzle")
	end

          --chromatic abberation
	if ply.quadnodson and vrnvgcolorpresettable[2] ~= 255 and vrnvgcolorpresettable[3] ~= 150 then 
		vrnvg_chromatic( 10, 0, 10, 0, 0, 0 )
	elseif ply.quadnodson and vrnvgcolorpresettable[2] == 255 or ply.quadnodson and vrnvgcolorpresettable[3] == 150 then 
		vrnvg_chromatic( 5, 0, 5, 0, 0, 0 )
	end
end
hook.Add("HUDPaintBackground", "vrnvgbackground", vrnvgbackground)

local function vrnvgpredraweffects() --yea safe to say this experimental type of rendering fucked me HARD in the end
	local ply = LocalPlayer()
	local ft = FrameTime()
	local eang, epos = EyeAngles(), EyePos()
	local w, h = ScrW(), ScrH()
	local p, q = vrnvgsway.lerpx * 1.1, -vrnvgsway.lerpy * 1.1
	local bluegreencolor = Color(vrnvgcolorpresettable[2],vrnvgcolorpresettable[3],vrnvgcolorpresettable[4],100)

          if IsValid(ply) and ply:Alive() and ply:Health() > 0 and IsValid(ply:GetHands()) then
                    vrnvghandsmodel = string.Replace(ply:GetHands():GetModel(), "models/models/","models/") or "models/weapons/c_arms_refugee.mdl"
                    if !util.IsValidModel(vrnvghandsmodel) then
                              local modelpath = ply:GetPData(vrnvghandsmodel, 0)
                              if modelpath ~= 0 then 
                                        vrnvghandsmodel = modelpath
                              --[[else
                                        chat.PlaySound() 
                                        chat.AddText(Color(255,0,0),"Your playermodel has misconfigured hands, use another, or follow this guide (replace 'BodyAnim' with 'vrnvg' for the command) \nhttps://pastebin.com/hgNqSEcG")]]
                              end
                    end

                    if !ply.vrnvghand then 
                              ply.vrnvghand = ClientsideModel(vrnvghandsmodel, RENDERGROUP_BOTH)
                    end
                    if IsValid(ply.vrnvghand) then
                              ply.vrnvghand:SetParent(ply.vrnvgmodel)
                              ply.vrnvghand:AddEffects(EF_BONEMERGE)
                              ply.vrnvghand:SetNoDraw(true)

                              ply.vrnvghand.GetPlayerColor = ply:GetHands().GetPlayerColor
                              for i = 0, ply.vrnvghand:GetNumBodyGroups() do
                                        local bodyg = ply:GetHands():GetBodygroup(i)
                                        ply.vrnvghand:SetBodygroup(i,bodyg)
                              end

                              local skinszz = ply:GetHands():GetSkin()
                              ply.vrnvghand:SetSkin(skinszz)
                    end
          end

	if !ply.vrnvgmodel then
		ply.vrnvgmodel = ClientsideModel("models/ventrische/c_quadnod2.mdl", RENDERGROUP_BOTH)
		ply.vrnvgmodel:ResetSequence("idleoff")
		ply.vrnvgmodel:SetNoDraw(true)
		ply.vrnvgcam = ClientsideModel("models/ventrische/c_quadnod2.mdl", RENDERGROUP_BOTH)
		ply.vrnvgcam:SetNoDraw(true)
		util.PrecacheModel( "models/ventrische/c_quadnod2.mdl" )
	end

          local nvgs = ply.vrnvgmodel
	local nvgcam = ply.vrnvgcam
          
	render.SetStencilWriteMask( 0xFF )
	render.SetStencilTestMask( 0xFF )
	render.SetStencilReferenceValue( 0 )
	render.SetStencilPassOperation( STENCIL_KEEP )
	render.SetStencilZFailOperation( STENCIL_KEEP )
	render.ClearStencil()
	render.SetStencilEnable( true )
	render.SetStencilReferenceValue( 1 )
	render.SetStencilCompareFunction( STENCIL_NEVER )
	render.SetStencilFailOperation( STENCIL_REPLACE )
		cam.Start3D( epos, eang, 100, 0, 0, w, h, 1, 35)
                              if nvgs and ply.vrnvghand then
                                        nvgs:SetPos(epos + Vector(0,0,0.3))
                                        nvgs:SetAngles(eang)
                                        nvgs:SetupBones()
                                        nvgs:FrameAdvance(ft)
                                        ply.vrnvghand:SetupBones()
                                        nvgcam:SetPos(Vector(0,0,0))
                                        nvgcam:SetAngles(Angle(0,0,0))
                                        nvgcam:FrameAdvance(ft)
                                        ply.nvgcamattach = nvgcam:GetAttachment(nvgcam:LookupAttachment("Camera"))
                                        if ply:GetViewEntity() == ply and !ply:ShouldDrawLocalPlayer() and !sky3d then 
                                                  nvgs:DrawModel() 
                                                  ply.vrnvghand:DrawModel() 
                                        end
                              end
		cam.End3D()
	render.SetStencilCompareFunction( 5 )
	render.SetStencilFailOperation( STENCIL_KEEP  )
		if blura > 0 and enabledofblur:GetBool() then  --depth of field (for some reason this is slightly off, probably due to the weird fuckery im doing drawing these shitty models)
			cam.Start2D(vector_origin, angle_zero)
				drawblur() 
			cam.End2D()
		end
	--render.ClearBuffersObeyStencil( 0, 148, 133, 255, false )
	render.SetStencilEnable( false )

	cam.Start3D( epos, eang, 100, 0, 0, w, h, 1, 35)
	cam.IgnoreZ( true )
		if nvgs and ply.vrnvghand then
			nvgs:SetPos(epos + Vector(0,0,0.3))
			nvgs:SetAngles(eang)
			nvgs:SetupBones()
			nvgs:FrameAdvance(ft)
			ply.vrnvghand:SetupBones()
			nvgcam:SetPos(Vector(0,0,0))
			nvgcam:SetAngles(Angle(0,0,0))
			nvgcam:FrameAdvance(ft)
			ply.nvgcamattach = nvgcam:GetAttachment(nvgcam:LookupAttachment("Camera"))
			if ply:GetViewEntity() == ply and !ply:ShouldDrawLocalPlayer() and !sky3d then 
				--nvgs:DrawModel() 
				ply.vrnvghand:DrawModel() 
			end
		end
	cam.IgnoreZ( false )
	cam.End3D()
end
hook.Add("PreDrawEffects", "vrnvgpredraweffects_hook", vrnvgpredraweffects)

local function vrnvgcalcview(ply, origin, angles, fov)
	if !blurtoggle or !ply.nvgcamattach or LocalPlayer():GetViewEntity() ~= LocalPlayer() then return end
	if !ply:Alive() then return end

	local view = {}
	local camang = ply.nvgcamattach.Ang - Angle(0, 90, 90)
	view.angles = angles + Angle(camang.x*2, camang.y*2, camang.z*2)
	return view
end
hook.Add("CalcView", "vrnvgcalc", vrnvgcalcview)

--ez solution
local lockshittykey = false
hook.Add( "StartChat", "vrnvgchatbox1", function( isTeamChat )
	lockshittykey = true
end )
hook.Add( "FinishChat", "vrnvgchatbox2", function()
	lockshittykey = false
end )

--god awful press/hold detection for equip/dequipping
local testlerp = 0
local function vrnvgkeys() --https://i.imgur.com/JEfBmRv.png
	local ply = LocalPlayer()
	if !ply:Alive() then return end

	if defualtnkey:GetBool() and !lockshittykey then 
		if testlerp == 150 and !ply.vrnvgflipped then
			RunConsoleCommand("vrnvgequip")
		end
		if ply.vrnvgequipped then
			if testlerp < 50 and testlerp > 5 then
				if (!ply.nvgtestdelay or CurTime() >= ply.nvgtestdelay) then
					RunConsoleCommand("vrnvgflip")

					testlerp = 0
					ply.nvgtestdelay = CurTime()*9999 -- this is all fucked sorry
					if !batterynvg2dfade then -- this will 100% break at one point
						batterynvg2dfade = true 
					else
						batterynvg2dfade = false
					end
				end
			end
		end
		if input.IsKeyDown(KEY_N) then
			if !gui.IsGameUIVisible() then
				testlerp = testlerp + 1
				ply.nvgtestdelay = CurTime() + 0.2
			end
		else 
			if testlerp >= 50 then
				testlerp = 0
			end
		end
	end
end
hook.Add("CreateMove", "vrnvgkeys", vrnvgkeys)


local addrl = 0
local addgl = .2
local addbl = .16
local colourl = .5
local contrastl = 2
--rip colormod fps on shitty laptops sorry it has to be updated live
hook.Add("RenderScreenspaceEffects", "vrnvggreen", function()
	local ply = LocalPlayer()
	local ft = FrameTime()
	if !ply:Alive() then return end
    	local colormod = {
		[ "$pp_colour_addr" ] = addrl,
		[ "$pp_colour_addg" ] = addgl,
		[ "$pp_colour_addb" ] = addbl,
		[ "$pp_colour_brightness" ] = 0,
		[ "$pp_colour_contrast" ] = contrastl,
		[ "$pp_colour_colour" ] = colourl,
		[ "$pp_colour_mulr" ] = 0,
		[ "$pp_colour_mulg" ] = 0,
		[ "$pp_colour_mulb" ] = 0
    	}
	local colormod2 = {
		[ "$pp_colour_addr" ] = addrl,
		[ "$pp_colour_addg" ] = addgl,
		[ "$pp_colour_addb" ] = addbl,
		[ "$pp_colour_brightness" ] = 0,
		[ "$pp_colour_contrast" ] = contrastl,
		[ "$pp_colour_colour" ] = colourl,
		[ "$pp_colour_mulr" ] = 0,
		[ "$pp_colour_mulg" ] = 0,
		[ "$pp_colour_mulb" ] = 0
    	}
	if ply.quadnodson and !ply.vrnvgbroken and !ply.nvgnobattery then
                    addrl = Lerp(ft*4, addrl, vrnvgcolorpresettable[5])
                    addgl = Lerp(ft*4, addgl, vrnvgcolorpresettable[6])
                    addbl = Lerp(ft*4, addbl, vrnvgcolorpresettable[7])
                    colourl = Lerp(ft*4, colourl, vrnvgcolorpresettable[8])
                    contrastl = Lerp(ft*4, contrastl, contrastamount:GetFloat())
                    DrawColorModify(colormod)
                    if bloomamount:GetFloat() > 0 and render.SupportsPixelShaders_2_0() then
                              DrawBloom( 0, bloomamount:GetFloat()+lightcolor+lightcolor2*2, 9, 9, 1, 1, 1, 1, 1 )
                    end
		edgeblur(3, ScrH()*.4)
	elseif ply.vrnvgbroken or ply.nvgnobattery then
		addrl = Lerp(ft, addrl, 0)
		addgl = Lerp(ft, addgl, 0)
		addbl = Lerp(ft, addbl, 0)
		colourl = Lerp(ft, colourl, 1)
		contrastl = Lerp(ft, contrastl, 1)
		DrawColorModify(colormod2)
		edgeblur(3, ScrH()*.4)
	end
end)

hook.Add("AdjustMouseSensitivity", "vrnvgsensititvy", function()
	if blurtoggle then
    		return 0.8
	end
end)


--3rd person nvgs, i wouldnt look at this if i was u tbh
local offsetvec = Vector(-3, -2, 0 )
local offsetang = Angle( 0, -80, -90 )
local fuckthisgodforsakenthing = false
hook.Add( "PostPlayerDraw" , "vrnvgplayernvgs" , function( ply ) --terrible
	local boneid = ply:LookupBone( "ValveBiped.Bip01_Head1" )
	local matrix = ply:GetBoneMatrix( boneid )
	local newpos, newang = LocalToWorld( offsetvec, offsetang, matrix:GetTranslation(), matrix:GetAngles() )
	local pl = LocalPlayer()
	if !showthirdpersonnvg:GetBool() then return end
          
          if ply:GetViewEntity() == ply or !ply:Alive() then 
                    if ply.vrnvgplayermodel then
                              ply.vrnvgplayermodel:Remove()
                              ply.vrnvgplayermodel = nil
                    end
          end

          if IsValid(ply) then
		if ply:GetModel() ~= "models/error.mdl" and ply:Alive() then
                              if ply:GetNW2Bool("vrnvgequipped") then
                                        if !ply.vrnvgplayermodel then
                                                  ply.vrnvgplayermodel = ClientsideModel( "models/ventrische/w_quadnods.mdl" )
                                                  ply.vrnvgplayermodel:SetNoDraw( false )
                                                  if !ply:GetNW2Bool("vrnvgflipped") then
                                                            ply.vrnvgplayermodel:ResetSequence("flipdown")
                                                  else
                                                            ply.vrnvgplayermodel:ResetSequence("flipup")
                                                  end
                                        end

                                        if !ply:GetNW2Bool("vrnvgflipped") then 
                                                  if pl:GetViewEntity() == pl then
                                                            ply.vrnvgplayermodel:ResetSequence("flipdown")
                                                  elseif pl:GetViewEntity() ~= pl and !fuckthisgodforsakenthing then
                                                            ply.vrnvgplayermodel:ResetSequence("flipdown")
                                                            fuckthisgodforsakenthing = true
                                                  end
                                                  ply.vrnvgplayermodel:SetPlaybackRate(1)
                                                  ply.vrnvgplayermodel:SetCycle(0)
                                        else 
                                                  if pl:GetViewEntity() == pl then
                                                            ply.vrnvgplayermodel:ResetSequence("flipup")
                                                  elseif pl:GetViewEntity() ~= pl and fuckthisgodforsakenthing then
                                                            ply.vrnvgplayermodel:ResetSequence("flipup")
                                                            fuckthisgodforsakenthing = false
                                                  end
                                                  ply.vrnvgplayermodel:SetPlaybackRate(1)
                                                  ply.vrnvgplayermodel:SetCycle(0)
                                                  fuckthisgodforsakenthing = false
                                        end
                                        ply.vrnvgplayermodel:SetPos( newpos )
                                        ply.vrnvgplayermodel:SetAngles( newang )
                                        ply.vrnvgplayermodel:SetupBones()
                                        ply.vrnvgplayermodel:FrameAdvance(ft)
                                        ply.vrnvgplayermodel:DrawModel() 
                              else
                                        if ply.vrnvgplayermodel then 
                                                  ply.vrnvgplayermodel:Remove()
                                                  ply.vrnvgplayermodel = nil
                                        end
                              end
                    end
          end
end)

hook.Add("PopulateToolMenu", "vrnvgtoolmenu", function()
	local ply = LocalPlayer()
	
	spawnmenu.AddToolMenuOption("Options", "COD: NVGs", "ventnvgsclient", "Configure", "", "", function(panel)
		panel:ClearControls()
		panel:AddControl("Header", {Description = "Made by venty\nAnimated by rische\n"})

		panel:AddControl("Checkbox", {Label = "Animation Depth of Field", Command = "vrnvg_dofblur"})
		panel:AddControl("Checkbox", {Label = "Screen-edge blur", Command = "vrnvg_edgeblur"})
		panel:AddControl("Label", {Text = ""})
		panel:AddControl("Checkbox", {Label = "Show battery percent HUD", Command = "vrnvg_batreminder"})
		panel:AddControl("Checkbox", {Label = "Play audio on full recharge", Command = "vrnvg_batsound"})
		panel:AddControl("Checkbox", {Label = "Show NVGs on other players", Command = "vrnvg_thirdperson"})
		panel:AddControl("Checkbox", {Label = "Use the default equip/flip key [N]", Command = "vrnvg_defaultkey"})
		panel:AddControl("Checkbox", {Label = "Sizzle NVGs when in direct light", Command = "vrnvg_sizzle"})
		panel:AddControl("Slider", {Label = "Bloom Amount", Command = "vrnvg_bloom", Type="float", Min=0, Max=0.5})
		panel:AddControl("Slider", {Label = "Contrast Amount", Command = "vrnvg_contrast", Type="float", Min=1.5, Max=2})
		panel:AddControl("Slider", {Label = "Overall Brightness", Command = "vrnvg_brightness", Type="float", Min=0.1, Max=1.0})
		panel:AddControl("Slider", {Label = "Visual Style", Command = "vrnvg_style", Min=1, Max=2})
		panel:AddControl("Label", {Text = "1 - Default, 2 - IR Light"})
		panel:AddControl("Label", {Text = "Re-flip the NVGs to see style changes."})

		vrnvgqmenu1 = vgui.Create( "DButton", panel )
		vrnvgqmenu1:SetPos( -10, 495 )	
		vrnvgqmenu1:SetSize( 180, 186 )
		vrnvgqmenu1:SetText("")
		vrnvgqmenu1.Paint = function(self)
			surface.SetMaterial(lightredmat)
			surface.SetDrawColor(Color(0,0,0,200))
			surface.DrawTexturedRect(28, 17, 112, 112)

			surface.SetDrawColor(Color(225,50,50,225))
			surface.DrawTexturedRect(30, 15, 112, 112)
		end
		vrnvgqmenu1.DoClick = function()
			vrnvg_lightred()
		end

		vrnvgqmenu2 = vgui.Create( "DButton", panel )
		vrnvgqmenu2:SetPos( 135, 495 )	
		vrnvgqmenu2:SetSize( 180, 186 )
		vrnvgqmenu2:SetText("")
		vrnvgqmenu2.Paint = function(self)
			surface.SetMaterial(bluegreenmat)
			surface.SetDrawColor(Color(0,0,0,200))
			surface.DrawTexturedRect(28, 17, 112, 112)

			surface.SetDrawColor(Color(50,210,210,225))
			surface.DrawTexturedRect(30, 15, 112, 112)
		end
		vrnvgqmenu2.DoClick = function()
			vrnvg_bluegreen()
		end

		vrnvgqmenu3 = vgui.Create( "DButton", panel )
		vrnvgqmenu3:SetPos( -10, 610 )	
		vrnvgqmenu3:SetSize( 180, 186 )
		vrnvgqmenu3:SetText("")
		vrnvgqmenu3.Paint = function(self)
			surface.SetMaterial(bluebluemat)
			surface.SetDrawColor(Color(0,0,0,200))
			surface.DrawTexturedRect(28, 17, 112, 112)

			surface.SetDrawColor(Color(0,150,225,225))
			surface.DrawTexturedRect(30, 15, 112, 112)
		end
		vrnvgqmenu3.DoClick = function()
			vrnvg_lightblue()
		end

		vrnvgqmenu4 = vgui.Create( "DButton", panel )
		vrnvgqmenu4:SetPos( 135, 610 )	
		vrnvgqmenu4:SetSize( 180, 186 )
		vrnvgqmenu4:SetText("")
		vrnvgqmenu4.Paint = function(self)
			surface.SetMaterial(classicgreenmat)
			surface.SetDrawColor(Color(0,0,0,200))
			surface.DrawTexturedRect(28, 17, 112, 112)

			surface.SetDrawColor(Color(50,200,50,225))
			surface.DrawTexturedRect(30, 15, 112, 112)
		end
		vrnvgqmenu4.DoClick = function()
			vrnvg_classicgreen()
		end
	end)

	spawnmenu.AddToolMenuOption( "Options", "COD: NVGs", "ventnvgsserver", "Server Settings", "", "", function(panel)
		panel:ClearControls()
		panel:AddControl("Header", {Description = "Made by venty\nAnimated by rische\n"})

		panel:AddControl("Slider", {Label = "Battery Drain Rate", Command = "vrnvg_drainrate", Type="float", Min=0, Max=10})
		panel:AddControl("Slider", {Label = "Battery Recharge Rate", Command = "vrnvg_rechargerate", Type="float", Min=0, Max=10})
		panel:AddControl("Slider", {Label = "Sacrifice Chance", Command = "vrnvg_blockchance", Min=0, Max=100})
		panel:AddControl("Label", {Text = "^ The chance of your NVGs taking a bullet for you."})
	end)
end)

hook.Add("ShutDown","vrnvgsave", function()
	file.CreateDir("nvgs")
	file.Write("nvgs/vrnvgcolor.txt", util.TableToJSON(vrnvgcolorpresettable)) 
end)
local function LoadNVGPreset()
	local save = file.Read("nvgs/vrnvgcolor.txt", "DATA")
	if save then
		save = util.JSONToTable(save)
		vrnvgcolorpresettable = save
	end

	local update = file.Read("nvgs/vrnvgupdatethree.txt", "DATA")
	if !update then
		file.CreateDir("nvgs")
		file.Write("nvgs/vrnvgupdatethree.txt", "wow no way new update nooo way") 

		timer.Simple(5, function()
			chat.PlaySound()
			chat.AddText(Color( 0,255,200 ), "Modern Warfare NVGs has updated. \n 1. Now actually works with roleplay gamemodes. (helix, etc.)")
		end)
	end
end
LoadNVGPreset()

--this is the code i get in return after giving datae the good ideas that help him blow up
concommand.Add( "vrnvg_registerhands", function(ply,cmd, args)
	local handsmodel = ply:GetHands():GetModel()
	local modelpath = args[1] or handsmodel
	local isvalidhands = util.IsValidModel(handsmodel)
	local isvalidcustom = util.IsValidModel(modelpath)
	
	if modelpath ~= handsmodel and isvalidcustom and !isvalidhands then 
		ply:SetPData(handsmodel,modelpath)
		print("MW NVGs will now use "..modelpath.." instead of "..handsmodel.." (hands)")
	elseif isvalidhands then
		print("ERROR: "..handsmodel.." is already correct. Aborting")
	elseif !isvalidcustom then
		print("ERROR: "..modelpath.." is not a valid model")
	end
end)

concommand.Add("+vrnvgcolormenu", function(ply)
	if !closedisbiatch and ply.vrnvgflipped and !ply.vrnvgbroken and !ply.nvgnobattery then
		surface.PlaySound("ventrische/nvg/theclassicventycustomaudiorequirement/menuopen.mp3")
		vrnvg_colormenu()
		closedisbiatch = true 
	end
end)
	
concommand.Add("-vrnvgcolormenu", function(ply)
	if !vrnvgframe then 
		closedisbiatch = false 
	end
	if vrnvgframe and closedisbiatch then
		vrnvg_closecolormenu()
		closedisbiatch = false
	end
end)