local CMoveData = FindMetaTable("CMoveData")

function CMoveData:RemoveKeys(keys)
	-- Using bitwise operations to clear the key bits.
	local newbuttons = bit.band(self:GetButtons(), bit.bnot(keys))
	self:SetButtons(newbuttons)
end

hook.Add("DefineSettings", "MrpSettings", function()
	mrp.DefineSetting("draw_hud", {name="HUD Enabled", category="Overlay", type="tickbox", default=false})
	mrp.DefineSetting("draw_hud_lfs", {name="LFS HUD Enabled", category="Overlay", type="tickbox", default=false})
end)

function meta:IsLeadAdmin()
	return ( self:GetUserGroup() == "lmod" or self:GetUserGroup() == "superadmin" )
end