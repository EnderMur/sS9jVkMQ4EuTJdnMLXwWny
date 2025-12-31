if RequiredScript == "lib/managers/hudmanager" then

	local setup_player_info_hud_pd2 = HUDManager._setup_player_info_hud_pd2
	function HUDManager:_setup_player_info_hud_pd2()
		setup_player_info_hud_pd2(self)
		if VoidUISBStandalone.options.scoreboard and VoidUISBStandalone.options.enable_stats and not self._hud_statsscreen then
			self:_setup_stats_screen()
		end
	end

	--Stat Panel
	if VoidUISBStandalone.options.scoreboard and VoidUISBStandalone.options.enable_stats then
		local reset_player_hpbar = HUDManager.reset_player_hpbar
		function HUDManager:reset_player_hpbar()
			reset_player_hpbar(self)
			local character_name = managers.criminals:local_character_name()
			local crim_entry = managers.criminals:character_static_data_by_name(character_name)
			if self._hud_statsscreen and self._hud_statsscreen._scoreboard_panels and self._hud_statsscreen._scoreboard_panels[HUDManager.PLAYER_PANEL] then
				self._hud_statsscreen._scoreboard_panels[HUDManager.PLAYER_PANEL]:set_player(character_name, managers.network:session():local_peer():name(), false, managers.network:session():local_peer():id())
			end
		end

		local update = HUDManager.update
		function HUDManager:update(t, dt)
			update(self, t, dt)
			self._last_sc_update = self._last_sc_update or t
			local peers = managers.network:session() and managers.network:session():peers()
			if self._hud_statsscreen and peers and self._last_sc_update + VoidUISBStandalone.options.ping_frequency < t then
				self._last_sc_update = t
				for _, peer in pairs(peers) do
					if peer and peer:id() and peer:rpc() then
						local panel = self._hud_statsscreen:get_scoreboard_panel_by_peer_id(peer:id())
						if panel then panel:set_ping(math.floor(Network:qos(peer:rpc()).ping)) end
					end
				end
			end
		end

		Hooks:PostHook(HUDManager, "setup_mission_briefing_hud", "void_create_scoreboard", function(self)
			self:show_stats_screen()
			self:hide_stats_screen()
		end)
	end

elseif RequiredScript == "lib/managers/hudmanagerpd2" then

	if VoidUISBStandalone.options.teammate_panels or (VoidUISBStandalone.options.scoreboard and VoidUISBStandalone.options.enable_stats) then
		HUDManager.player_downed = HUDManager.player_downed or function(self, i)
			if self._hud_statsscreen and self._hud_statsscreen._scoreboard_panels then
				self._hud_statsscreen._scoreboard_panels[i]:add_stat("downs")
			end
		end

		HUDManager.player_reset_downs = HUDManager.player_reset_downs or function(self, i)
			if self._hud_statsscreen and self._hud_statsscreen._scoreboard_panels then
				self._hud_statsscreen._scoreboard_panels[i]:reset_downs_stat("downs")
			end
		end
	end

	--Stat Screen and Scoreboard
	if VoidUISBStandalone.options.scoreboard and VoidUISBStandalone.options.enable_stats then
		local add_teammate_panel = HUDManager.add_teammate_panel
		function HUDManager:add_teammate_panel(character_name, player_name, ai, peer_id)
			local add_panel = add_teammate_panel(self, character_name, player_name, ai, peer_id)
			self._hud_statsscreen:add_scoreboard_panel(character_name, player_name, ai, peer_id)
			return add_panel
		end

		function HUDManager:scoreboard_unit_killed(killer_unit, stat)

			if alive(killer_unit) and killer_unit:base() and self._hud_statsscreen  then
				if killer_unit:base().thrower_unit then
					killer_unit = killer_unit:base():thrower_unit()
				elseif killer_unit:base().sentry_gun then
					killer_unit = killer_unit:base():get_owner()
				end
				if killer_unit == nil then return end

				local character_data = managers.criminals:character_data_by_unit(killer_unit)
				if character_data then
					local panel_id = (managers.criminals:character_peer_id_by_unit(killer_unit) == managers.network:session():local_peer():id() and HUDManager.PLAYER_PANEL) or (character_data and character_data.panel_id and character_data.panel_id)
					self._hud_statsscreen._scoreboard_panels[panel_id]:add_stat(stat)
					if stat == "civs" or (stat == "specials" and VoidUISBStandalone.options.scoreboard_kills == 3) then self._hud_statsscreen._scoreboard_panels[panel_id]:add_stat("kills") end
				end
			end
		end

		function HUDManager:remove_teammate_scoreboard_panel(id)
			if self._hud_statsscreen then
				self._hud_statsscreen:remove_scoreboard_panel(id)
			end
		end

		local remove_teammate_panel = HUDManager.remove_teammate_panel
		function HUDManager:remove_teammate_panel(id)
			self._hud_statsscreen:free_scoreboard_panel(id)
			remove_teammate_panel(self, id)
		end
	end

elseif RequiredScript == "lib/units/player_team/teamaidamage" then

	if VoidUISBStandalone.options.enable_stats and VoidUISBStandalone.options.scoreboard then
		local check_bleed_out = TeamAIDamage._check_bleed_out
		function TeamAIDamage:_check_bleed_out()
			if self._health <= 0 then
				local i = managers.criminals:character_data_by_unit(self._unit).panel_id
				if managers.hud._hud_statsscreen then
					managers.hud._hud_statsscreen._scoreboard_panels[i]:add_stat("downs")
				end
			end
			check_bleed_out(self)
		end
	end

elseif RequiredScript == "lib/units/player_team/huskteamaidamage" and VoidUISBStandalone.options.enable_stats and VoidUISBStandalone.options.scoreboard then
	local on_bleedout = HuskTeamAIDamage._on_bleedout
	function HuskTeamAIDamage:_on_bleedout()
		on_bleedout(self)
		local i = managers.criminals:character_data_by_unit(self._unit).panel_id
		if managers.hud._hud_statsscreen then
			managers.hud._hud_statsscreen._scoreboard_panels[i]:add_stat("downs")
		end
	end

elseif RequiredScript == "lib/units/player_team/teamaiinventory" and VoidUISBStandalone.options.scoreboard and VoidUISBStandalone.options.enable_stats then
	local _ensure_weapon_visibility = TeamAIInventory._ensure_weapon_visibility
	function TeamAIInventory:_ensure_weapon_visibility(override_weapon, override)
		_ensure_weapon_visibility(self, override_weapon, override)
		local panel = managers.hud and managers.hud._hud_statsscreen:get_scoreboard_panel_by_character(managers.criminals:character_name_by_unit(self._unit))
		if panel then panel:sync_bot_loadout(panel._character) end
	end

elseif RequiredScript == "lib/managers/achievmentmanager" and VoidUISBStandalone.options.enable_stats and VoidUISBStandalone.options.scoreboard then
	AchievmentManager.MAX_TRACKED = 7

elseif RequiredScript == "lib/network/base/basenetworksession" and VoidUISBStandalone.options.scoreboard and VoidUISBStandalone.options.enable_stats then
	local remove_peer = BaseNetworkSession.remove_peer
	function BaseNetworkSession:remove_peer(peer, peer_id, reason)
		if managers.criminals and peer_id then
			local character_data = managers.criminals:character_data_by_peer_id(peer_id)

			if character_data and character_data.panel_id then
				managers.hud:remove_teammate_scoreboard_panel(character_data.panel_id)
			end
		end
		return remove_peer(self, peer, peer_id, reason)
	end
end

