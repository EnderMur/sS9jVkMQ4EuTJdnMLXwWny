if RequiredScript == "lib/units/beings/player/huskplayermovement" and (VoidUISBStandalone.options.scoreboard and VoidUISBStandalone.options.enable_stats) then
	
	local start_bleedout = HuskPlayerMovement._perform_movement_action_enter_bleedout
	
	function HuskPlayerMovement:_perform_movement_action_enter_bleedout(...)
		local data = managers.criminals:character_data_by_unit(self._unit)
		if data and data.panel_id then
			managers.hud:player_downed(data.panel_id)
		end
	
		return start_bleedout(self, ...)
	end
	
elseif RequiredScript == "lib/units/beings/player/states/playerbleedout" and (VoidUISBStandalone.options.scoreboard and VoidUISBStandalone.options.enable_stats) then
	local start_bleedout = PlayerBleedOut._enter
	
	function PlayerBleedOut:_enter(...)
		managers.hud:player_downed(HUDManager.PLAYER_PANEL)
		return start_bleedout(self, ...)
	end
	
elseif RequiredScript == "lib/network/handlers/unitnetworkhandler" then
	if (VoidUISBStandalone.options.scoreboard and VoidUISBStandalone.options.enable_stats) then
		local doctor_bag_taken = UnitNetworkHandler.sync_doctor_bag_taken

		function UnitNetworkHandler:sync_doctor_bag_taken(unit, amount, sender, ...)
			local peer = self._verify_sender(sender)
			if peer then
				local data = managers.criminals:character_data_by_peer_id(peer:id())
				if data and data.panel_id then
					managers.hud:player_reset_downs(data.panel_id)
				end
			end
			
			return doctor_bag_taken(self, unit, amount, sender, ...)
		end
	end
elseif RequiredScript == "lib/units/equipment/doctor_bag/doctorbagbase" and (VoidUISBStandalone.options.scoreboard and VoidUISBStandalone.options.enable_stats) then
	
	local doctor_bag_taken = DoctorBagBase.take

	function DoctorBagBase:take(...)
		managers.hud:player_reset_downs(HUDManager.PLAYER_PANEL)
		
		return doctor_bag_taken(self, ...)
	end

end