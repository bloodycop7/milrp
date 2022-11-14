mrp.Ops = mrp.Ops or {}
mrp.Ops.QuickTools = mrp.Ops.QuickTools or {}

function mrp.Ops.RegisterAction(command, cmdData, qtName, qtIcon, qtDo)
	mrp.RegisterChatCommand(command, cmdData)

	if qtName and qtDo then
		mrp.Ops.QuickTools[qtName] = {name = qtName, icon = qtIcon, onRun = qtDo}
	end
end

if CLIENT then
	-- load up windows toast notifications for reports if staff have it
	if file.Exists("garrysmod/lua/bin/gmcl_win_toast_win32.dll", "BASE_PATH") or file.Exists("garrysmod/lua/bin/gmcl_win_toast_win64.dll", "BASE_PATH") then
		require("win_toast")
	end
end