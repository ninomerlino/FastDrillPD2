

Hooks:PostHook(TimerGui, "set_timer_multiplier", "fastdrillStart", function(self, ...)
	if not self then log("no self") end
	if not self._timer_multiplier  then log("no timer mult") end
	log("Entered hook2")
	log(tostring(self._timer_multiplier))
	log(tostring(self))
	if managers.network and managers.network:session() then
		if managers.groupai and managers.groupai:state() and managers.groupai:state():whisper_mode() then
			log("is wisper mode--------------------------------------------")
			self._timer_multiplier = 0.1
		else
			log("is loud mode--------------------------------------------")
			self._timer_multiplier = 0.2
		end
	else
		log("player is not host")
	end
end)



