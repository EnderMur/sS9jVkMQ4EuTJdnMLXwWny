local loc = _G["A-Anti-Crash-Loc"]
local class_name = loc and loc.config and loc.config.base and loc.config.base.class_name

if not class_name then
	return
end

local debug_msgs = false
local loaded = rawget(_G, class_name)
local c = loaded or rawset(_G, class_name, {}) and _G[class_name]
local amount_of_errors_to_show = loc.config.safecaller.error_notifications
local amount_of_crashed_to_show = loc.config.safecaller.crash_notifications
local punishment = loc.config.safecaller.punishment
local anti_spam_msg = {}
local anti_spam_msg_errors = {}
local toggle_classes = true
local toggle_functions = true

c.classes_to_safe_call = {
	{class = _G["UnitNetworkHandler"], path = {[string.lower("unitnetworkhandler")] = toggle_classes}},
	{class = _G["ConnectionNetworkHandler"], path = {[string.lower("connectionnetworkhandler")] = toggle_classes}},
	{class = _G["HostNetworkSession"], path = {[string.lower("HostNetworkSession")] = toggle_classes}, funcs_to_run = {
		["on_join_request_received"] = toggle_functions,
		["on_peer_connection_established"] = toggle_functions,
		["chk_spawn_member_unit"] = toggle_functions,
		["on_drop_in_pause_confirmation_received"] = toggle_functions, 
		["on_peer_finished_loading_outfit"] = toggle_functions,
		["on_set_member_ready"] = toggle_functions
	}},
	{class = _G["PlayerManager"], path = {[string.lower("PlayerManager")] = toggle_classes}, funcs_to_run = {
		["select_next_item"] = toggle_functions,
		["select_previous_item"] = toggle_functions,
		["add_sentry_gun"] = toggle_functions,
		["remove_equipment"] = toggle_functions
	}},
	{class = _G["WeaponFactoryManager"], path = {[string.lower("WeaponFactoryManager")] = toggle_classes}, funcs_to_run = {
		["_preload_part"] = toggle_functions
	}},
	{class = _G["PlayerTurret"], path = {[string.lower("PlayerTurret")] = toggle_classes}, funcs_to_run = {
		["_postion_player_on_turret"] = toggle_functions
	}},
	{class = _G["EnemyManager"], path = {[string.lower("EnemyManager")] = toggle_classes}, funcs_to_run = {
		["set_gfx_lod_enabled"] = toggle_functions
	}}
}
c.r_script = table.remove(RequiredScript:split("/")):lower()

if not loaded then
	c.total_loaded = 0
	c.table_total_not_loaded = {}
	c.orig_func_table = {}

	local function_not_to_run = {
		["first_aid_kit_sync"] = true,
		["new"] = true,
		["init"] = true,
		["_setup"] = true,
		["update"] = false,
		["save"] = true,
		["load"] = true,
		["chk_action_forbidden"] = true,
		["init_finalize"] = true,
		["_add_string_macros"] = true,
		["_interact_blocked"] = true,
		["get_unsecured_bag_value"] = true,
		["would_be_bonus_bag"] = true,
		["selected"] = true,
		["_upd_actions"] = true,
		["process_dead_con_reports"] = true,
		["action_request"] = true,
		["get_weapon"] = true,
		["say"] = true,
		["suppressed_state"] = true,
		["action_walk_nav_point"] = true,
		["post_init"] = true,
		["action_aim_state"] = true
	}
	
	local chat_tag = class_name
	
	function c:print_msg(msg, chat, color)
		if loc.config.safecaller.chat_message and chat and managers.chat and managers.chat._receive_message then
			managers.chat:_receive_message(1, chat_tag, msg, (color or tweak_data.system_chat_color))
		elseif managers.mission and managers.mission._fading_debug_output then
			managers.mission._fading_debug_output:script().log(string.format("[%s]: %s", chat_tag, msg), (color or Color.red))
		end
	end
	
	function c:count_lines(t)
		local num = t.spam_counter
		local s = 0
		for i = 0, 1000, 10 do
			s = i
			if num < s then
				s = 0
				break
			elseif s == num then
				break
			end
		end
		return s
	end
	
	function c:kick_peers(peer, data2)
		local session = managers.network and managers.network:session()

		if peer and session then
			local user_id = peer:user_id()
			local peer_name = peer:name()
			if anti_spam_msg[user_id] ~= nil then
				if (anti_spam_msg[user_id].spam_counter == self:count_lines(anti_spam_msg[user_id])) and (anti_spam_msg[user_id].spam_counter == amount_of_crashed_to_show) then
					local msg_string = string.format("Prevented a crash from %s with [%s] - [%s / %s] time(s).", (peer_name or "Unknown player"), (data2 or "an unknown function"), (anti_spam_msg[user_id].spam_counter or "Unknown"), tostring(amount_of_crashed_to_show))
					self:print_msg(msg_string, true, Color.green)
				end
				anti_spam_msg[user_id].spam_counter = anti_spam_msg[user_id].spam_counter + 1
			elseif user_id and anti_spam_msg[user_id] == nil then
				anti_spam_msg[user_id] = {}
				anti_spam_msg[user_id].spam_counter = 1
				
				if Network:is_server() then					
					local message_id = 0
					if punishment == 3 and not managers.ban_list:banned(user_id) then
						managers.ban_list:ban(user_id, peer_name)
						message_id = 6
					end
					
					if message_id == 6 or punishment == 2 then
						session:send_to_peers("kick_peer", peer:id(), message_id)
						session:on_peer_kicked(peer, peer:id(), message_id)
					end
				end
				
				if punishment == 1 then
					local to_target = string.format("[PRIVATE]: AAC prevented %s from crashing my game. You can ignore this if you have no mods installed.", (data2 or "an unknown function"))
					local to_me = string.format("Private Message Sent.\nTarget: %s\n%s", peer_name, to_target)
					session:send_to_peer(peer, "send_chat_message", 1, to_target)
					self:print_msg(to_me, true, Color.green)
				end
				
				local msg_string = string.format("Prevented a crash from %s with [%s].", (peer_name or "Unknown player"), (data2 or "an unknown function"))
				self:print_msg(msg_string, true, Color.green)
			end
		else
			local msg_string = string.format("Prevented a crash from an unknown player with [%s].", (data2 or "an unknown function"))
			self:print_msg(msg_string, true, Color.green)
		end
	end
	
	function c:get_and_replace_orig_func(class, funcs_to_run, k)
		self.orig_func_table[class] = self.orig_func_table[class] or {}

		for func_name, func in pairs(class) do
			if self.orig_func_table[class][func_name] == nil and type(func) == "function" and not function_not_to_run[func_name] and (type(funcs_to_run) == "table" and funcs_to_run[func_name] or funcs_to_run == nil) then
				self.orig_func_table[class][func_name] = class[func_name]
				
				class[func_name] = function(self, ...)
					local is_valid = {pcall(c.orig_func_table[class][func_name], self, ...)}

					if table.remove(is_valid, 1) then
           				return unpack(is_valid)
					else
						local args = {...}
						local sender = args[#args]
						local peer = sender and BaseNetworkHandler and BaseNetworkHandler._verify_sender(sender)

						c:kick_peers(peer, func_name)
					end
				end
				
				if debug_msgs then
					self.total_loaded = self.total_loaded + 1
					if self.table_total_not_loaded[k] then
						self.table_total_not_loaded[k] = nil
					end
				end
			end
		end
	end
	
	function c:init()
		for k, v in pairs(self.classes_to_safe_call) do
			if v.path[self.r_script] and type(v.class) == "table" then
				if debug_msgs and self.table_total_not_loaded[k] == nil then
					self.table_total_not_loaded[k] = true
				end
				
				self:get_and_replace_orig_func(v.class, v.funcs_to_run, k)
			end
		end
	end
end
c:init()
