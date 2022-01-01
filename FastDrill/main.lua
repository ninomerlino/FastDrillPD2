--modiefies the drill speed when the host starts it
Hooks:PostHook(TimerGui, "set_timer_multiplier", "fastdrillStart", function(self, ...)
	log("Entered hook")
	if Network:is_server() and self and self._timer_multiplier then 
		local multi
		if managers.groupai and managers.groupai:state() and managers.groupai:state():whisper_mode() then
			multi = 0.1
		else
			multi = 0.2
		end
		if self._timer and managers.network:session() and self._unit then
			managers.network:session():send_to_peers_synched("start_timer_gui", self._unit, self._timer*_timer_multiplier)
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
	if Network:is_server() then
		DelayedCalls:Add("FDcomunication", 2, function()
			log("Deleyed call started")
			local message = "The host has FastDrill active!"
			local targetpeer = managers.network:session() and managers.network:session():peer(peer_id)
			if targetpeer then
				targetpeer:send("send_chat_message", ChatManager.GAME, message)
			end
		end)
	end
end)

