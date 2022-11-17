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
    AddCSLuaFile("sh_legs.lua")
end

if (CLIENT) then
    hook.Add("ShouldDisableLegs", "GML::Support::Prone", function()
        if (!LocalPlayer().IsProne) then
            return
        end

        if (LocalPlayer():IsProne()) then
            return true
        end
    end)

    hook.Add("ShouldDisableLegs", "GML::Support::MorphMod", function()
        if (!pk_pills) then
            return
        end

        if (pk_pills.getMappedEnt(LocalPlayer())) then
            return true
        end
    end)

	hook.Add("ShouldDisableLegs", "GML::Support::VWallrun", function()
        if (VWallrunning) then
            return true
        end
    end)
    
    hook.Add("ShouldDisableLegs", "GML::Support::Mantle", function()
        if (inmantle) then
            return true
        end
	end)
end
