Hooks:PostHook(BaseNetworkSession, "on_peer_entered_lobby", "on_peer_entered_lobby_stop_lobby_lag", function(self, peer)
    --Load the local players character for the joined peer;
    --Since there's send_to_peers_loaded and send_to_peers_loaded_except, but no function to send to a singular peer, we just do it manually;
    --Because we don't want to send info to all players, for no reason and possibly cause a lag.
    if managers.network:session() and managers.network:session():_local_peer_in_lobby() then
	    peer:send_after_load("sync_outfit", managers.blackmarket:outfit_string(), self:local_peer():outfit_version(), managers.blackmarket:signature())
    end
end)

local old_func = BaseNetworkSession.check_send_outfit
function BaseNetworkSession:check_send_outfit(peer)
    if not (managers.network:session() and managers.network:session():_local_peer_in_lobby()) then
        return old_func(self, peer)
    end

    if not managers.blackmarket:signature() then
        return
	end

    local local_peer = self:local_peer()
    local state = managers.menu:get_peer_state(local_peer:id())

    --The same usual - if player isn't "READY" then stop.
    if state and state ~= "lobby" then
        return
    end

    --This time if the player IS ready, then send outfit info to others to avoid lagging others.
    return old_func(self, peer)
end