local hook_1_id = "ImprovedSearch__BlackMarketGui._setup__pre"

Hooks:PreHook(BlackMarketGui, "_setup", hook_1_id, function(self, is_start_page, component_data)
	if component_data and component_data.topic_id == "bm_menu_melee_weapons" then
		component_data.search_box_disconnect_callback_name = "on_search_item"
	end
end)

local hook_2_id = "ImprovedSearch__BlackMarketGui.populate_melee_weapons_new__post"

Hooks:PostHook(BlackMarketGui, "populate_melee_weapons_new", hook_2_id, function(self, data)
	if self._data.search_string and self._data.search_string ~= "" then
		for _, weapon in ipairs(data) do
			local search_text = utf8.to_lower(self._data.search_string)
			local weapon_name = utf8.to_lower(weapon.name_localized)

			if string.find(weapon_name, search_text) ~= nil then
				weapon.search_rect = true
			end
		end
	end
end)