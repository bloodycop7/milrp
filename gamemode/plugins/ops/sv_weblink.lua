-- This file contains private info, do NOT publicise.

function opsSlackLog(message)
	if not mrp.YML.apis.slack_webhook then
		return
	end
	
	local isPreview = GetConVar("mrp_ispreview"):GetBool()

	if isPreview then
		return	
	end

	local post = {
		text = message
	}

	local struct = {
		failed = function(error) MsgC(Color(255,0,0), "mrp Slack log error: "..error) end,
		method = "post",
		url = mrp.YML.apis.slack_webhook,
		body = util.TableToJSON({post}),
		type = "application/json"
	}

	HTTP(struct)
end

function opsDiscordLog(message, embeds, webhookOverride)
	if not mrp.YML.apis.discord_ops_webhook or not mrp.Config.DiscordRelayURL then
		return
	end
	
	local isPreview = GetConVar("mrp_ispreview"):GetBool()

	if isPreview then
		return	
	end

	if embeds then
		embeds.timestamp = os.date("%Y-%m-%dT%H:%M:%S.000Z", os.time())
		embeds.footer = {}
		embeds.footer.text = "ops (GMT)"
	end

	local post = {
        webhook = webhookOverride or mrp.YML.apis.discord_ops_webhook,
        password = mrp.YML.apis.discord_relaykey,
		content = message,
		embeds = embeds and util.TableToJSON({embeds}) or nil,
		username = "open permission system (ops)"
	}

	local struct = {
		failed = function(error) MsgC(Color(255,0,0), "mrp discord log error: "..error) end,
		success = function(body) print(code) print(code) print(body) end,
		method = "post",
		url = mrp.Config.DiscordRelayURL,
		parameters = post,
		type = "application/json; charset=utf-8"
	}

	HTTP(struct)
end