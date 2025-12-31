Hooks:PostHook(BaseNetworkSession, "add_peer", "BaseNetworkSession_add_peer_RecentlyPlayedFix", function(self, name, rpc, in_lobby, loading, synched, id, ...)
	local peer = managers.network:session():peer(id)
	if peer and peer:account_type_str() == "STEAM" then
		Steam:set_played_with(peer:account_id())
	end
end)