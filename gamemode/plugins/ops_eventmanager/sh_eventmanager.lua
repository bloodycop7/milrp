function mrp.Ops.EventManager.GetEventMode()
    return GetGlobalBool("opsEventMode", false)
end

function mrp.Ops.EventManager.GetSequence()
	local val = GetGlobalString("opsEventSequence", "")

	if val == "" then
		return
	end

    return val
end

function mrp.Ops.EventManager.SetEventMode(val)
	return SetGlobalBool("opsEventMode", val)
end

function mrp.Ops.EventManager.SetSequence(val)
	return SetGlobalString("opsEventSequence", val)
end

function mrp.Ops.EventManager.GetCurEvents()
	return mrp_OpsEM_CurEvents
end

function meta:IsEventAdmin()
	return self:IsSuperAdmin() or (self:IsAdmin() and mrp.Ops.EventManager.GetEventMode())
end

if SERVER then
	concommand.Add("mrp_ops_eventmode", function(ply, cmd, args)
		if not IsValid(ply) or ply:IsSuperAdmin() then
			if args[1] == "1" then
				mrp.Ops.EventManager.SetEventMode(true)
				print("[ops-em] Event mode ON")
			else
				mrp.Ops.EventManager.SetEventMode(false)
				print("[ops-em] Event mode OFF")
			end
		end
	end)
end