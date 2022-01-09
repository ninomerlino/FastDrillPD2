--modiefies the drill speed when the host starts it
_G.FastDrill = _G.FastDrill or {}
FastDrill.config = FastDrill.config or {}
FastDrill.path = FastDrill.path or ModPath
FastDrill.configPath = FastDrill.configPath or SavePath .. "/fastDrill.cfg"


--function tableHasKey(table,key)
--    return table[key] ~= nil
--end

--Set up config interface
function FastDrill:loadConfig(forceDefault)
	forceDefault = forceDefault or false
	FastDrill.config = {}
	local file = io.open(FastDrill.configPath, 'r')
	if file and not forceDefault then
		FastDrill.config = json.decode(file:read("a"))
		file:close()
	else
		FastDrill.config['active'] = true
		FastDrill.config['stealthMod'] = 0.1
		FastDrill.config['loudMod'] = 0.2
	end
end

function FastDrill:storeConfig()
	local file = io.open(FastDrill.configPath, 'w')
	file:write(json.encode(FastDrill.config))
	file:close()
end

function FastDrill:Active()
	if not FastDrill.config then FastDrill:loadConfig() end
	if not FastDrill.config['active'] then FastDrill:loadConfig(true) end
	return FastDrill.config['active']
end

function FastDrill:StealthMod()
	if not FastDrill.config then FastDrill:loadConfig() end
	if not FastDrill.config['stealthMod'] then FastDrill:loadConfig(true) end
	return FastDrill.config['stealthMod']
end

function FastDrill:LoudMod()
	if not FastDrill.config then FastDrill:loadConfig() end
	if not FastDrill.config['loudMod'] then FastDrill:loadConfig(true) end
	return FastDrill.config['loudMod']
end
--localization needed for mod options
Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_SilentAssassin", function(loc)
    loc:load_localization_file(FastDrill.path.."loc/english.json")
end)
--set up mod option menu
function toggleActive(this, item)
	if item:value() == "on" then
		FastDrill.config['active'] = true
	else
		FastDrill.config['active'] = false
	end
end

function setStealthMod(this, item)
	FastDrill.config['stealthMod'] = item:value()
end

function setLoudMod(this, item)
	FastDrill.config['loudMod'] = item:value()
end

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_FastDrill", function(menu_manager)
    MenuCallbackHandler.FastDrill_toggleActive = toggleActive
	MenuCallbackHandler.FastDrill_setStealthMod = setStealthMod
	MenuCallbackHandler.FastDrill_setLoudMod = setLoudMod
    MenuCallbackHandler.FastDrill_save = function(this)
        FastDrill:storeConfig()
    end
    FastDrill:loadConfig()
    MenuHelper:LoadFromJsonFile(FastDrill.path.."options.txt", FastDrill, FastDrill.config)
end)

--Change drill speed modifier
Hooks:PostHook(TimerGui, "set_timer_multiplier", "fastdrillStart", function(self, ...)
	log("Entered hook")
	if Network:is_server() and self and self._timer_multiplier and FastDrill:Active() then 
		if managers.groupai and managers.groupai:state() and managers.groupai:state():whisper_mode() then
			self._timer_multiplier = FastDrill:StealthMod()
		else
			self._timer_multiplier = FastDrill:LoudMod()
		end
		if self._timer and managers.network:session() and self._unit then
			managers.network:session():send_to_peers_synched("start_timer_gui", self._unit, self._timer*self._timer_multiplier)
		else
			log("no timer")
		end
	else
		log("----------------------Server----------------------")
		log(tostring(Network:is_server()))
		log("----------------------Self----------------------")
		if self then log(tostring(self)) else log("No self") end
		log("----------------------Multi----------------------")
		if self._timer_multiplier then log(tostring(self._timer_multiplier)) else log("No time multiplier") end
	end
end)

--send message to people who join the lobby
Hooks:PostHook(NetworkManager, "on_peer_added", "fastdrillJoinLobby", function(self, peer, peer_id)
	if Network:is_server() and FastDrill:Active() then
		DelayedCalls:Add("FDcomunication", 2, function()
			log("Deleyed call started")
			local message = managers.localization:text("fd_lobby_welcome")
			local targetpeer = managers.network:session() and managers.network:session():peer(peer_id)
			if targetpeer then
				targetpeer:send("send_chat_message", ChatManager.GAME, message)
			end
		end)
	end
end)

