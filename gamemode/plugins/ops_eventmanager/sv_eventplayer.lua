local function UpdateEventAdmins(eventid)
	for v,k in pairs(player.GetAll()) do
		if k:IsEventAdmin() then
			net.Start("mrpOpsEMUpdateEvent")
			net.WriteUInt(eventid, 10)
			net.Send(k)
		end
	end
end

local eventTimerNames = {}
local sequenceTime = 0

local function queueEvent(sequence, eventid)
	local event = mrp.Ops.EventManager.Sequences[sequence][eventid]
	local timerName = "mrpOpsEM-"..eventid
	local time = sequenceTime + (event.Delay or 0)
	local x = table.insert(eventTimerNames, timerName)

	timer.Create(timerName, time, 1, function()
		mrp.Ops.EventManager.PlayEvent(sequence, eventid)
		eventTimerNames[x] = nil
	end)

	sequenceTime = time
end

function mrp.Ops.EventManager.PlaySequence(name)
	local sequence = mrp.Ops.EventManager.Sequences[name]

	eventTimerNames = {}
	sequenceTime = 0

	mrp.Ops.EventManager.SetSequence(name)

	for v,k in pairs(sequence) do
		queueEvent(name, v)
	end
end

function mrp.Ops.EventManager.StopSequence()
	for v,k in pairs(eventTimerNames) do
		if k and timer.Exists(k) and not (timer.TimeLeft(k) and timer.TimeLeft(k) <= 0) then
			timer.Remove(k)
		end
	end

	mrp.Ops.EventManager.SetSequence("")
end

function mrp.Ops.EventManager.PlayEvent(sequence, eventid)
	local count = table.Count(mrp.Ops.EventManager.Sequences[sequence])
	local event = mrp.Ops.EventManager.Sequences[sequence][eventid]

	if not mrp.Ops.EventManager.Config.Events[event.Type] then
		return mrp.Ops.EventManager.StopSequence()
	end

	UpdateEventAdmins(eventid)

	if mrp.Ops.EventManager.Config.Events[event.Type].Clientside then
		net.Start("mrpOpsEMClientsideEvent")
		net.WriteString(event.Type)
		net.WriteString(event.UID or "")
		local data = pon.encode(event.Prop)
		net.WriteUInt(#data, 16)
		net.WriteData(data, #data)
		net.Broadcast()
	else
		mrp.Ops.EventManager.Config.Events[event.Type].Do(event.Prop or {}, event.UID or nil)
	end

	if eventid >= count then
		mrp.Ops.EventManager.StopSequence()
	end
end