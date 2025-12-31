local Check_sync_friendly_fire_damage = UnitNetworkHandler.sync_friendly_fire_damage

function UnitNetworkHandler:sync_friendly_fire_damage(peer_id, unit, damage, variant, sender)
    local peer_sender = self._verify_sender(sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer_sender then
		return
	end
	variant = tostring(variant)
	if variant:find("fire") or variant:find("fall") or variant:find("explosion") or variant:find("delayed_tick") or variant:find("tase") or variant:find("bullet") or variant:find("killzone") or variant:find("melee") or variant:find("projectile")then
		local abs_damage = math.abs(damage) * 10
		if abs_damage > 0 then
			damage = 0
		end
		local peer_name = tostring(peer_sender:name())
		local peer = managers.network._session:peer(peer_sender:id())
		if AntiKillTeammates.settings.msg_choice == 1 then
		    managers.chat:_receive_message(1,"AKT","Has prevented you from "..peer_name.. "'s "..abs_damage.." "..variant.." damage.",Color.red)
		elseif AntiKillTeammates.settings.msg_choice == 2 then
		    managers.chat:send_message(ChatManager.GAME, managers.network.account:username() or "Offline", "[AKT]:Has prevented you from "..peer_name.. "'s "..abs_damage.." "..variant.." damage.")
		end
		if AntiKillTeammates.settings.action_choice == 1 then
		   if peer and Network:is_server() then
			    managers.network:session():send_to_peers('kick_peer', peer_sender:id(), 0)
			    managers.network:session():on_peer_kicked(peer, peer_sender:id(), 0)
	        end
		elseif	AntiKillTeammates.settings.action_choice == 2 then
			if peer and not managers.ban_list:banned(peer_sender:user_id()) then
			managers.ban_list:ban(peer_sender:user_id(), peer_sender:name())
		    end
		    if peer and Network:is_server() then
			    managers.network:session():send_to_peers('kick_peer', peer_sender:id(), 6)
			    managers.network:session():on_peer_kicked(peer, peer_sender:id(), 6)
		    end
	
		end
    end
	Check_sync_friendly_fire_damage(self, peer_id, unit, damage, variant, sender)
end