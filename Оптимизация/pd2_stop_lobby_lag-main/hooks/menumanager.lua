Hooks:PostHook(MenuManager, "_set_peer_sync_state", "_set_peer_sync_state_stop_lobby_lag", function(self, peer_id, state)
    if (state and state ~= "lobby") or (not peer_id) or (not (managers.network and managers.network:session() and managers.network:session():_local_peer_in_lobby())) then
        return
    end

    local local_peer = managers.network:session():local_peer():id() == peer_id
    if local_peer then
        --Calls the function, that sends info about your outfit to other players
        managers.network:session():check_send_outfit()
        return
    end

    local peer = managers.network:session():peer(peer_id)
    local sync_outfit_data = peer and peer._stop_lobby_lag

    if sync_outfit_data then
        --Call the sync function with the saved info as the function runs on item change
        --Means we have to call it ourselves to load the character when they change state
        managers.network._handlers.connection:sync_outfit(unpack(sync_outfit_data))
    end
end)