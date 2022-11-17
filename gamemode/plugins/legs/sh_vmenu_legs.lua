--[[
	   ______                    __   __                   
	  / ____/___ ___  ____  ____/ /  / /   ___  ____ ______
	 / / __/ __ `__ \/ __ \/ __  /  / /   / _ \/ __ `/ ___/
	/ /_/ / / / / / / /_/ / /_/ /  / /___/  __/ /_/ (__  ) 
	\____/_/ /_/ /_/\____/\__,_/  /_____/\___/\__, /____/  
	                                         /____/        
	@Valkyrie, @blackops7799
]]--

if (SERVER) then
	AddCSLuaFile( "sh_vmenu_legs.lua" )
end

if (CLIENT) then
	local function AddText(font, color, text)		 
		local label = vgui.Create("DLabel", g_GMLOptions)
		label:Dock( TOP )	
		label:SetFont(font)
		label:SetText(text)
		label:SetTextColor(color)
		label:SizeToContents()

		return label
	end

	local function AddOptions( text, cvar )	 
		local option = vgui.Create("DCheckBoxLabel", g_GMLOptions)
		option:SetText(text)
		option:SetTextColor(Color(194,194,194))
		option:SetConVar( cvar )
		option:Dock( TOP )
		option:DockMargin(30, 0, 0, 0)
		option:SizeToContents()

		return label
	end

	local function AddHeader( text )
		AddText("VAddonsHeader", Color(194,194,194), text):DockMargin(12, 0, 0, 0)
	end

	hook.Add( "GetVMenuTabs", "GMLTabs", function(parent, tabs) 
		g_GMLOptions = vgui.Create( "DScrollPanel", parent )
		g_GMLOptions.Paint = function(this, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color( 30, 30, 30 ) )
		end

		AddHeader(string.format("\nWhats new in Gmod Legs %s?", g_LegsVer))
		AddText("VAddonsCredits", Color(194,194,194), g_LegsLog):DockMargin(30, 0, 0, 0)

		AddHeader("Settings")
		AddOptions( "Enable rendering of Legs?", "cl_legs" )
		AddOptions( "Enable rendering of Legs in vehicles?", "cl_vehlegs" )

		AddHeader("\nCredits")
		AddText("VAddonsCredits", Color(194,194,194), "Valkyrie\n\tblackops7799"):DockMargin(30, 0, 0, 0)
		
		tabs:AddSheet(string.format("Gmod Legs %s", g_LegsVer), g_GMLOptions, "icon16/user.png")
	end)
end