if not PeerModListHighlights then
	dofile(ModPath .. "lua/base.lua")
end

local nodeinfo = nil
local steam_id = ""
local local_pmlh_mod_id = nil
local local_pmlh_mod_name = nil
local original_modify_node = InspectPlayerInitiator.modify_node

function InspectPlayerInitiator:modify_node_PMLH(node, inspect_peer)

	-- changes begin @143
	node:clean_items()
	
	if not inspect_peer then
		Application:error("Can not open inpsect player without a specified peer!")
		managers.menu:back()
	end

	local is_local_peer = inspect_peer == managers.network:session():local_peer()
	local text_id, color_ranges = PlayerListInitiator.get_peer_name(self, inspect_peer)
	local params = {
		name = "peer_name",
		localize = false,
		no_text = false,
		text_id = text_id,
		color_ranges = color_ranges,
		color = tweak_data.screen_colors.text
	}
	local data_node = {
		type = "MenuItemDivider"
	}
	local new_item = node:create_item(data_node, params)

	node:add_item(new_item)

	if MenuCallbackHandler:is_steam() and inspect_peer:account_type() == Idstring("STEAM") then
		local params = {
			callback = "on_visit_fbi_files_suspect",
			help_id = "menu_visit_fbi_files_help",
			text_id = "menu_visit_fbi_files",
			name = inspect_peer:account_id()
		}
		local new_item = node:create_item(nil, params)

		node:add_item(new_item)
		self:create_divider(node, "fbi_spacer")
	end

	if not is_local_peer and Network:is_server() then
		if MenuCallbackHandler:kick_player_visible() or MenuCallbackHandler:kick_vote_visible() then
			local params = {
				callback = "kick_player",
				name = "kick_player",
				text_id = MenuCallbackHandler:kick_player_visible() and "menu_kick_player" or "menu_kick_vote",
				rpc = inspect_peer:rpc(),
				peer = inspect_peer
			}
			local new_item = node:create_item(nil, params)

			node:add_item(new_item)
		end

		local function get_identifier(peer)
			return SystemInfo:platform() == Idstring("WIN32") and peer:account_id() or peer:name()
		end

		local params = {
			callback = "kick_ban_player",
			text_id = "menu_players_list_ban",
			name = inspect_peer:name(),
			identifier = get_identifier(inspect_peer),
			rpc = inspect_peer:rpc(),
			peer = inspect_peer
		}
		local new_item = node:create_item(nil, params)

		node:add_item(new_item)
	end

	if not is_local_peer then
		local toggle_mute = self:create_toggle(node, {
			localize = true,
			name = "toggle_mute",
			enabled = true,
			text_id = "menu_players_list_mute",
			callback = "mute_player",
			rpc = inspect_peer:rpc(),
			peer = inspect_peer
		})

		toggle_mute:set_value(inspect_peer:is_muted() and "on" or "off")
	end
	
	self:create_divider(node, "socialhub_spacer")

	if not is_local_peer and not managers.socialhub:is_user_platform_friend(inspect_peer._user_id, true) then
		if not managers.socialhub:is_user_friend(inspect_peer._user_id) then
			local add_user = {
				callback = "on_add_user_socialhub",
				name = "shub_add_user",
				text_id = "menu_players_socialhub_add_user",
				help_id = "menu_players_socialhub_add_user_help",
				peer_name = inspect_peer:name(),
				user_id = inspect_peer._user_id
			}
			local new_item = node:create_item(nil, add_user)

			node:add_item(new_item)

			local block_user = {
				callback = "on_block_user_socialhub",
				name = "shub_block_user",
				text_id = "menu_players_socialhub_block_user",
				help_id = "menu_players_socialhub_block_user_help",
				peer_name = inspect_peer:name(),
				user_id = inspect_peer._user_id
			}
			local new_item = node:create_item(nil, block_user)

			node:add_item(new_item)
		else
			local remove_user = {
				callback = "on_remove_user_socialhub",
				name = "shub_remove_user",
				text_id = "menu_players_socialhub_remove_user",
				help_id = "menu_players_socialhub_remove_friend_help",
				peer_name = inspect_peer:name(),
				user_id = inspect_peer._user_id
			}
			local new_item = node:create_item(nil, remove_user)

			node:add_item(new_item)
		end
	end
	
	--###########################################################################################################################################################--
	--###########################################################################################################################################################--
	--###########################################################################################################################################################--
	--###########################################################################################################################################################--
	--###########################################################################################################################################################--
	-- everything bellow is the new code, everything before is base game copypasta
	
	if PeerModListHighlights.settings.profile_button then
		if inspect_peer:account_type() == Idstring("STEAM") then
			self:create_divider(node, "admin_spacer")
			steam_id = inspect_peer._account_id
			local params = {
				callback = "PMLH_open_steam_profile_in_browser",
				help_id = "PMLH_player_profile_inspect_help",
				text_id = "PMLH_player_profile_inspect_text",
				name = "PMLH_PROFILE_"..inspect_peer:account_id()
			}
			local new_item = node:create_item(nil, params)

			node:add_item(new_item)
		elseif inspect_peer:account_type() == Idstring("EPIC") then
			self:create_divider(node, "admin_spacer")
			local params = {
				callback = "PMLH_epic_profile_empty_callback",
				help_id = "PMLH_player_profile_inspect_help_epic",
				text_id = "PMLH_player_profile_inspect_text_epic",
				name = "PMLH_PROFILE_"..inspect_peer:account_id()
			}
			local new_item = node:create_item(nil, params)

			node:add_item(new_item)
		end
	end

	self:create_divider(node, "admin_spacer")

	local user = SystemInfo:distribution() == Idstring("STEAM") and Steam:user(inspect_peer:ip())

	if user and user:rich_presence("is_modded") == "1" or inspect_peer:is_modded() then
		local params = {
			text_id = "menu_players_list_mods",
			name = "peer_mods",
			no_text = false,
			size = 8,
			color = tweak_data.screen_colors.text
		}
		local data_node = {
			type = "MenuItemDivider"
		}
		local new_item = node:create_item(data_node, params)

		node:add_item(new_item)
		
		-- How this stuff works: during the menu build process we check if mod's name = to a name from any of our lists, if so apply colour.
		for i, mod in ipairs(inspect_peer:synced_mods()) do
			local params = nil
			local mod_name = mod.name
			if PeerModListHighlights.settings.include_mod_folder_player_menu then
				mod_name = mod_name.." ("..mod.id..")"
			end
			local modnamelength = string.len(mod_name)
			if PeerModListHighlights:isModInGreen(mod.name) then -- check if name = any name from green list
				params = {
					callback = "PMLH_new_inspect_mod",
					localize = false,
					name = "mod_" .. tostring(i),
					text_id = mod_name,
					mod_id = mod.id,
					color_ranges = {{ -- this part adds colours starting at 0 and ending at modname's last letter. This method seems to be only used by a function that adds purple colour to player's infamy level
						start = 0,
						stop = modnamelength,
						color = PeerModListHighlights.greencolour
					}}
					}
				local new_item = node:create_item(nil, params)
				node:add_item(new_item)
			end
		end
		for i, mod in ipairs(inspect_peer:synced_mods()) do
			local params = nil
			local mod_name = mod.name
			if PeerModListHighlights.settings.include_mod_folder_player_menu then
				mod_name = mod_name.." ("..mod.id..")"
			end
			local modnamelength = string.len(mod_name)
			if PeerModListHighlights:isModInYellow(mod.name) then -- same as above
				params = {
					callback = "PMLH_new_inspect_mod",
					localize = false,
					name = "mod_" .. tostring(i),
					text_id = mod_name,
					mod_id = mod.id,
					color_ranges = {{
						start = 0,
						stop = modnamelength,
						color = PeerModListHighlights.yellowcolour
					}}
					}
				local new_item = node:create_item(nil, params)
				node:add_item(new_item)
			end
		end
		for i, mod in ipairs(inspect_peer:synced_mods()) do
			local params = nil
			local mod_name = mod.name
			if PeerModListHighlights.settings.include_mod_folder_player_menu then
				mod_name = mod_name.." ("..mod.id..")"
			end
			local modnamelength = string.len(mod_name)
			if PeerModListHighlights:isModInRed(mod.name) then
				params = {
					callback = "PMLH_new_inspect_mod",
					localize = false,
					name = "mod_" .. tostring(i),
					text_id = mod_name,
					mod_id = mod.id,
					color_ranges = {{
						start = 0,
						stop = modnamelength,
						color = PeerModListHighlights.redcolour
					}}
					}
				local new_item = node:create_item(nil, params)
				node:add_item(new_item)
			end
		end
		for i, mod in ipairs(inspect_peer:synced_mods()) do
			local params = nil
			local mod_name = mod.name
			if PeerModListHighlights.settings.include_mod_folder_player_menu then
				mod_name = mod_name.." ("..mod.id..")"
			end
			local modnamelength = string.len(mod_name)
			if not PeerModListHighlights:isModInGreen(mod.name) and not PeerModListHighlights:isModInYellow(mod.name) and not PeerModListHighlights:isModInRed(mod.name) then
				if PeerModListHighlights.settings.menuDefaultColour ~= "default" then -- check if we have custom colour for non-listed mods
					params = {
						callback = "PMLH_new_inspect_mod",
						localize = false,
						name = "mod_" .. tostring(i),
						text_id = mod_name,
						mod_id = mod.id,
						color_ranges = {{
							start = 0,
							stop = modnamelength,
							color = PeerModListHighlights.settings.menuDefaultColour
						}}
						}
				else -- this is how mods are normaly build with default blue colour. if we dont specify colour, it will default to blue
					params = {
						callback = "PMLH_new_inspect_mod",
						localize = false,
						name = "mod_" .. tostring(i),
						text_id = mod_name,
						mod_id = mod.id,
						}
				end
				local new_item = node:create_item(nil, params)
				node:add_item(new_item)
			end
		end
	end
	
	managers.menu:add_back_button(node)
	node:set_default_item_name("back")
	
	nodeinfo = {node,inspect_peer} -- save info about our node, to refresh it later
	
	return node
end

-- similar failsafe to the one in crimenet, just in case
function InspectPlayerInitiator:modify_node(node, inspect_peer)

	if pcall(function() self:modify_node_PMLH(node, inspect_peer) end) then
		return self:modify_node_PMLH(node, inspect_peer)
	else
		log("[PMLH] ERROR: InspectPlayerInitiator:modify_node function override is damaged, using default function. Check PMLH for updates.")
		return original_modify_node(self, node, inspect_peer)
	end

end

function MenuCallbackHandler:PMLH_new_inspect_mod(item)
	local menu_options = {}
	local_pmlh_mod_id = item:parameters().mod_id
	local_pmlh_mod_name = item:parameters().text_id
	menu_options[#menu_options+1] ={text = managers.localization:text("PMLH_searchmodname"), data = nil, callback = PeerModListHighlights.checkmod}
	menu_options[#menu_options+1] ={text = managers.localization:text("PMLH_searchmodfolder"), data = nil, callback = PeerModListHighlights.checkmodbyid}
	menu_options[#menu_options+1] ={text = "", is_cancel_button = false}
	menu_options[#menu_options+1] ={text = managers.localization:text("PMLH_adjustmod") .. managers.localization:text("PMLH_list1name") .. managers.localization:text("PMLH_list"), data = nil, callback = PeerModListHighlights.addModToList_1_PM}
	menu_options[#menu_options+1] ={text = managers.localization:text("PMLH_adjustmod") .. managers.localization:text("PMLH_list2name") .. managers.localization:text("PMLH_list"), data = nil, callback = PeerModListHighlights.addModToList_2_PM}
	menu_options[#menu_options+1] ={text = managers.localization:text("PMLH_adjustmod") .. managers.localization:text("PMLH_list3name") .. managers.localization:text("PMLH_list"), data = nil, callback = PeerModListHighlights.addModToList_3_PM}
	menu_options[#menu_options+1] ={text = managers.localization:text("PMLH_cancelbutton"), is_cancel_button = true}
	local menu = QuickMenu:new(managers.localization:text("PMLH_adjustmenutitle"), managers.localization:text("PMLH_adjustmenuquestion"), menu_options)
	menu:Show()
end

function MenuCallbackHandler:PMLH_open_steam_profile_in_browser()
	if steam_id ~= "" then
		managers.network.account:overlay_activate("url", "http://steamcommunity.com/profiles/".. steam_id)
	end
end

function MenuCallbackHandler:PMLH_epic_profile_empty_callback()
	-- do nothing
end

function PeerModListHighlights:checkmod()
	if local_pmlh_mod_name ~= nil then
		managers.network.account:overlay_activate("url", "https://modworkshop.net/search/mods?query=" .. local_pmlh_mod_name)
	else
		managers.network.account:overlay_activate("url", "https://modworkshop.net")
	end
end

function PeerModListHighlights:checkmodbyid()
	if local_pmlh_mod_id ~= nil then
		managers.network.account:overlay_activate("url", "https://modworkshop.net/search/mods?query=" .. local_pmlh_mod_id)
	else
		managers.network.account:overlay_activate("url", "https://modworkshop.net")
	end
end

-- calls for the function that updates the lists, then refreshes UI
function PeerModListHighlights.addModToList_1_PM()
	PeerModListHighlights:addModToList_1(local_pmlh_mod_name)
	-- UI
	InspectPlayerInitiator.modify_node(InspectPlayerInitiator, nodeinfo[1],nodeinfo[2])
	managers.menu:active_menu().renderer:active_node_gui():refresh_gui(nodeinfo[1])
end

function PeerModListHighlights.addModToList_2_PM()
	PeerModListHighlights:addModToList_2(local_pmlh_mod_name)
	InspectPlayerInitiator.modify_node(InspectPlayerInitiator, nodeinfo[1],nodeinfo[2])
	managers.menu:active_menu().renderer:active_node_gui():refresh_gui(nodeinfo[1])
end

function PeerModListHighlights.addModToList_3_PM()
	PeerModListHighlights:addModToList_3(local_pmlh_mod_name)
	InspectPlayerInitiator.modify_node(InspectPlayerInitiator, nodeinfo[1],nodeinfo[2])
	managers.menu:active_menu().renderer:active_node_gui():refresh_gui(nodeinfo[1])
end