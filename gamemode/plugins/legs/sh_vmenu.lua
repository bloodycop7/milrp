--[[ 
	 _    __      ____              _     _          __  ___                
	| |  / /___ _/ / /____  _______(_)__ ( )_____   /  |/  /__  ____  __  __
	| | / / __ `/ / //_/ / / / ___/ / _ \|// ___/  / /|_/ / _ \/ __ \/ / / /
	| |/ / /_/ / / ,< / /_/ / /  / /  __/ (__  )  / /  / /  __/ / / / /_/ / 
	|___/\__,_/_/_/|_|\__, /_/  /_/\___/ /____/  /_/  /_/\___/_/ /_/\__,_/  
	                 /____/                                                 
	v2.0
]]--

g_vMenuVer = "2.0"
g_vMenuAddons = g_vMenuAddons or {}

if (SERVER) then
	AddCSLuaFile( "sh_vmenu.lua" )
end

if (CLIENT) then
	function ScaleToWideScreen( size )
		return math.min(math.max( ScreenScale(size / 2.62467192), math.min(size, 14) ), size)
	end

	surface.CreateFont( "VAddonsCredits",  {font='Roboto Condensed', size=ScaleToWideScreen(22), weight=500, antialias=true, additive=false})
	surface.CreateFont( "VAddonsHeader",  {font='Roboto Condensed', size=ScaleToWideScreen(26), weight=500, antialias=true, additive=false})
	surface.CreateFont( "VAddonsMenuBar",  {font='Roboto Condensed', size=ScaleToWideScreen(20), weight=500, antialias=true, additive=false})
	
	local TitleBarSize = 35
	list.Set( "DesktopWindows", "GmodLegsEditor", 
	{
		title		= "VAddons",
		icon		= "icon64/playermodel.png",
		width	   	= 960,
		height	  	= 700,
		onewindow   = true,
		init		= function( icon, window )

			window:SetTitle("")
			window.Paint = function()
				draw.RoundedBox(0, 0, 0, window:GetWide(), window:GetTall(), Color( 37, 37, 37, 255 ) )
				draw.RoundedBox(0, 0, 0, window:GetWide(), TitleBarSize, Color( 50, 50, 50, 255 ))
				draw.SimpleText("Valkyrie's Addons", "VAddonsMenuBar", window:GetWide()/2, TitleBarSize/2 -2, Color(142, 142, 142), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)	
			end

			local tabs = vgui.Create( "DPropertySheet", window )
			tabs.Paint = function(this, w, h)
				draw.RoundedBox(0, 0, 0, w, h, Color( 37, 37, 37, 255 ) )
			end
			tabs.AddSheet = function(this, label, panel, material, NoStretchX, NoStretchY, Tooltip )
				if ( !IsValid( panel ) ) then
					ErrorNoHalt( "DPropertySheet:AddSheet tried to add invalid panel!" )
					debug.Trace()
					return
				end

				local Sheet = {}

				Sheet.Name = label

				Sheet.Tab = vgui.Create( "DTab", this )
				Sheet.Tab.Paint = function(_tab, w, h)
					if ( _tab:IsActive() ) then
						draw.RoundedBox(0, 0, 0, w, h, Color( 30, 30, 30 ) )
						return
					end
					draw.RoundedBox(0, 0, 0, w, h, Color( 45, 45, 45 ) )
				end
				Sheet.Tab.GetTabHeight = function(_tab, w, h)
					return 48
				end

				Sheet.Tab:Setup( label, this, panel, material )

				Sheet.Panel = panel
				Sheet.Panel.NoStretchX = NoStretchX
				Sheet.Panel.NoStretchY = NoStretchY
				Sheet.Panel:SetPos( this:GetPadding(), 20 + this:GetPadding() )
				Sheet.Panel:SetVisible( false )

				panel:SetParent( this )

				table.insert( this.Items, Sheet )

				if ( !this:GetActiveTab() ) then
					this:SetActiveTab( Sheet.Tab )
					Sheet.Panel:SetVisible( true )
				end

				this.tabScroller:AddPanel( Sheet.Tab )

				return Sheet
			end
			tabs:SetPos(0, TitleBarSize)
			tabs:SetSize(window:GetWide(), window:GetTall() - TitleBarSize)
			tabs:SetPadding(0)
			
			hook.Run( "GetVMenuTabs", window, tabs )	
		end
	} )
end	