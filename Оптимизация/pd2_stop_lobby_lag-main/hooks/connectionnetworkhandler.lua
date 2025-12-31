local old_func = ConnectionNetworkHandler.sync_outfit

local skip_first = {}
function ConnectionNetworkHandler:sync_outfit(outfit_string, outfit_version, outfit_signature, sender)
    --If player isn't in lobby, then why would we do our lobby lag check?
    if not (managers.network:session() and managers.network:session():_local_peer_in_lobby()) then
        return old_func(self, outfit_string, outfit_version, outfit_signature, sender)
    end

    local peer = self._verify_sender(sender)

	if not peer then
		return
	end

    --Check if the peer has been loaded.
    if not skip_first[peer:id()] then
        --If we don't do this then the character won't be loaded and there will be an empty space with a name tag;
        --After loading into the lobby when the peer is already in inventory;
        --So we skip the first check and let the original run for that matter for each connected peer;
        --No need to check for future connecting peers after we are loaded as those will be put into "lobby" state and will run the original.
        skip_first[peer:id()] = true
        return old_func(self, outfit_string, outfit_version, outfit_signature, sender)
    end

    local state = managers.menu:get_peer_state(peer:id())

    --If peer isn't in the ready state ("lobby");
    --Or isn't fully loaded yet, resulting in state being nil.
    if state and state ~= "lobby" then
        --When syncing over and over this info will be overwritten, so no need to make other checks.
        peer._stop_lobby_lag = {
            outfit_string,
            outfit_version,
            outfit_signature,
            sender
        }
        return
    end

    return old_func(self, outfit_string, outfit_version, outfit_signature, sender)
end