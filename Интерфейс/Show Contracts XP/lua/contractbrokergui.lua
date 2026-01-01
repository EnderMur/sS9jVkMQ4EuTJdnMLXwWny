require("lib/managers/menu/items/ContractBrokerHeistItem")

local padding = 10

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

local example_string = utf8.char(0x65, 0x78, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0x20, 0x73, 0x74, 0x72, 0x69, 0x6e, 0x67) .. " " .. utf8.char(57363)

ContractBrokerGui = ContractBrokerGui or class(MenuGuiComponent)
ContractBrokerGui.tabs = {
	{
		"menu_filter_contractor",
		"_setup_filter_contact"
	},
	{
		"menu_filter_time",
		"_setup_filter_time"
	},
	{
		"menu_filter_tactic",
		"_setup_filter_tactic"
	},
	{
		"menu_filter_most_played",
		"_setup_filter_most_played"
	},
	{
		"menu_filter_favourite",
		"_setup_filter_favourite"
	},
	{
		"bm_menu_inventory_tradable_all",
		"_setup_filter_xp"
	}
}
ContractBrokerGui.MAX_SEARCH_LENGTH = 20
ContractBrokerGui.RELEASE_WINDOW = 7

function ContractBrokerGui:init(ws, fullscreen_ws, node)
	self._fullscreen_ws = managers.gui_data:create_fullscreen_16_9_workspace()
	self._ws = managers.gui_data:create_saferect_workspace()
	self._node = node
	self._fullscreen_panel = self._fullscreen_ws:panel():panel({
		layer = 1000
	})
	self._panel = self._ws:panel():panel({
		layer = 1100
	})
	self.make_fine_text = BlackMarketGui.make_fine_text
	local component_data = node:parameters().menu_component_data or {}
	self._hide_title = component_data.hide_title or false
	self._hide_filters = component_data.hide_filters or false
	self._panel_align = component_data.align or "center"
	self.tabs = component_data.tabs or self.tabs

	if component_data.job_filter then
		self._job_filter = callback(self, self, component_data.job_filter)
	end

	self._enabled = true
	self._current_filter = Global.contract_broker and Global.contract_broker.filter or 1
	self._highlighted_filter = Global.contract_broker and Global.contract_broker.filter or 1
	self._current_tab = Global.contract_broker and Global.contract_broker.tab or 1
	self._highlighted_tab = Global.contract_broker and Global.contract_broker.tab or 1
	self._current_selection = 0
	self._job_data = {}
	self._contact_data = {}
	self._active_filters = {}
	self._buttons = {}
	self._tab_buttons = {}
	self._filter_buttons = {}
	self._heist_items = {}

	managers.menu_component:disable_crimenet()
	managers.menu:active_menu().input:deactivate_controller_mouse()
	self:setup()

	if Global.contract_broker and Global.contract_broker.job_id then
		for idx, item in ipairs(self._heist_items) do
			if item._job_data and item._job_data.job_id == Global.contract_broker.job_id then
				self._panels.scroll:scroll_to(item._panel:y())
				self:_set_selection(idx)

				break
			end
		end
	end

	Global.contract_broker = nil
end

function ContractBrokerGui:close()
	self:disconnect_search_input()

	self._enabled = false

	managers.menu:active_menu().input:activate_controller_mouse()
	managers.menu_component:enable_crimenet()

	if alive(self._ws) then
		managers.gui_data:destroy_workspace(self._ws)

		self._ws = nil
	end

	if alive(self._fullscreen_ws) then
		managers.gui_data:destroy_workspace(self._fullscreen_ws)

		self._fullscreen_ws = nil
	end
end

function ContractBrokerGui:enabled()
	return self._enabled
end

function ContractBrokerGui:setup()
	self:_create_job_data()
	self:_create_background()

	if not self._hide_title then
		self:_create_title()
	end

	self:_create_panels()
	self:_create_back_button()
	self:_create_legend()
	self:_setup_tabs()
	self:_setup_filters()
	self:_setup_jobs()
	
	--create xp butons
	self:_create_xp_ds_min_button()
	self:_create_xp_dw_min_button()
	self:_create_xp_mh_min_button()
	self:_create_xp_ok_min_button()
	self:_create_xp_vh_min_button()
	self:_create_xp_hh_min_button()
	self:_create_xp_nn_min_button()
	self:_create_xp_ds_max_button()
	self:_create_xp_dw_max_button()
	self:_create_xp_mh_max_button()
	self:_create_xp_ok_max_button()
	self:_create_xp_vh_max_button()
	self:_create_xp_hh_max_button()
	self:_create_xp_nn_max_button()
	
	local default_to_search = managers.menu:is_pc_controller()
	default_to_search = default_to_search and not _G.IS_VR

	if default_to_search then
		self:connect_search_input()
	else
		self:_set_selection(1)
	end

	self:refresh()
end

--create ds min button
function ContractBrokerGui:_create_xp_ds_min_button()
	local back_panel = self._panel:panel({
		w = self._panels.main:w(),
		h = tweak_data.menu.pd2_small_font_size
	})

	back_panel:set_right(self._panels.main:right() - padding + 220)
	back_panel:set_top(self._panels.main:top())

	if managers.menu:is_pc_controller() then
		self._xp_ds_min_button = back_panel:text({
			vertical = "top",
			align = "right",
			layer = 1,
			text = managers.localization:to_upper_text("menu_difficulty_sm_wish") .. " - Min",
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.button_stage_3
		})

		make_fine_text(self._xp_ds_min_button)
		self._xp_ds_min_button:set_right(back_panel:w())
	end
end

--create ds max button
function ContractBrokerGui:_create_xp_ds_max_button()
	local back_panel = self._panel:panel({
		w = self._panels.main:w(),
		h = tweak_data.menu.pd2_small_font_size
	})

	back_panel:set_right(self._panels.main:right() - padding + 220)
	back_panel:set_top(self._panels.main:top() + 20)

	if managers.menu:is_pc_controller() then
		self._xp_ds_max_button = back_panel:text({
			vertical = "top",
			align = "right",
			layer = 1,
			text = managers.localization:to_upper_text("menu_difficulty_sm_wish") .. " - Max",
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.button_stage_3
		})

		make_fine_text(self._xp_ds_max_button)
		self._xp_ds_max_button:set_right(back_panel:w())
	end
end

--create dw min button
function ContractBrokerGui:_create_xp_dw_min_button()
	local back_panel = self._panel:panel({
		w = self._panels.main:w(),
		h = tweak_data.menu.pd2_small_font_size
	})

	back_panel:set_right(self._panels.main:right() - padding + 220)
	back_panel:set_top(self._panels.main:top() + 50)

	if managers.menu:is_pc_controller() then
		self._xp_dw_min_button = back_panel:text({
			vertical = "top",
			align = "right",
			layer = 1,
			text = managers.localization:to_upper_text("menu_difficulty_apocalypse") .. " - Min",
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.button_stage_3
		})

		make_fine_text(self._xp_dw_min_button)
		self._xp_dw_min_button:set_right(back_panel:w())
	end
end

--create dw max button
function ContractBrokerGui:_create_xp_dw_max_button()
	local back_panel = self._panel:panel({
		w = self._panels.main:w(),
		h = tweak_data.menu.pd2_small_font_size
	})

	back_panel:set_right(self._panels.main:right() - padding + 220)
	back_panel:set_top(self._panels.main:top() + 70)

	if managers.menu:is_pc_controller() then
		self._xp_dw_max_button = back_panel:text({
			vertical = "top",
			align = "right",
			layer = 1,
			text = managers.localization:to_upper_text("menu_difficulty_apocalypse") .. " - Max",
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.button_stage_3
		})

		make_fine_text(self._xp_dw_max_button)
		self._xp_dw_max_button:set_right(back_panel:w())
	end
end

--create mh min button
function ContractBrokerGui:_create_xp_mh_min_button()
	local back_panel = self._panel:panel({
		w = self._panels.main:w(),
		h = tweak_data.menu.pd2_small_font_size
	})

	back_panel:set_right(self._panels.main:right() - padding + 220)
	back_panel:set_top(self._panels.main:top() + 100)

	if managers.menu:is_pc_controller() then
		self._xp_mh_min_button = back_panel:text({
			vertical = "top",
			align = "right",
			layer = 1,
			text = managers.localization:to_upper_text("menu_difficulty_easy_wish") .. " - Min",
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.button_stage_3
		})

		make_fine_text(self._xp_mh_min_button)
		self._xp_mh_min_button:set_right(back_panel:w())
	end
end

--create mh max button
function ContractBrokerGui:_create_xp_mh_max_button()
	local back_panel = self._panel:panel({
		w = self._panels.main:w(),
		h = tweak_data.menu.pd2_small_font_size
	})

	back_panel:set_right(self._panels.main:right() - padding + 220)
	back_panel:set_top(self._panels.main:top() + 120)

	if managers.menu:is_pc_controller() then
		self._xp_mh_max_button = back_panel:text({
			vertical = "top",
			align = "right",
			layer = 1,
			text = managers.localization:to_upper_text("menu_difficulty_easy_wish") .. " - Max",
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.button_stage_3
		})

		make_fine_text(self._xp_mh_max_button)
		self._xp_mh_max_button:set_right(back_panel:w())
	end
end

--create ok min button
function ContractBrokerGui:_create_xp_ok_min_button()
	local back_panel = self._panel:panel({
		w = self._panels.main:w(),
		h = tweak_data.menu.pd2_small_font_size
	})

	back_panel:set_right(self._panels.main:right() - padding + 220)
	back_panel:set_top(self._panels.main:top() + 150)

	if managers.menu:is_pc_controller() then
		self._xp_ok_min_button = back_panel:text({
			vertical = "top",
			align = "right",
			layer = 1,
			text = managers.localization:to_upper_text("menu_difficulty_overkill") .. " - Min",
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.button_stage_3
		})

		make_fine_text(self._xp_ok_min_button)
		self._xp_ok_min_button:set_right(back_panel:w())
	end
end

--create ok max button
function ContractBrokerGui:_create_xp_ok_max_button()
	local back_panel = self._panel:panel({
		w = self._panels.main:w(),
		h = tweak_data.menu.pd2_small_font_size
	})

	back_panel:set_right(self._panels.main:right() - padding + 220)
	back_panel:set_top(self._panels.main:top() + 170)

	if managers.menu:is_pc_controller() then
		self._xp_ok_max_button = back_panel:text({
			vertical = "top",
			align = "right",
			layer = 1,
			text = managers.localization:to_upper_text("menu_difficulty_overkill") .. " - Max",
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.button_stage_3
		})

		make_fine_text(self._xp_ok_max_button)
		self._xp_ok_max_button:set_right(back_panel:w())
	end
end

--create vh min button
function ContractBrokerGui:_create_xp_vh_min_button()
	local back_panel = self._panel:panel({
		w = self._panels.main:w(),
		h = tweak_data.menu.pd2_small_font_size
	})

	back_panel:set_right(self._panels.main:right() - padding + 220)
	back_panel:set_top(self._panels.main:top() + 200)

	if managers.menu:is_pc_controller() then
		self._xp_vh_min_button = back_panel:text({
			vertical = "top",
			align = "right",
			layer = 1,
			text = managers.localization:to_upper_text("menu_difficulty_very_hard") .. " - Min",
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.button_stage_3
		})

		make_fine_text(self._xp_vh_min_button)
		self._xp_vh_min_button:set_right(back_panel:w())
	end
end

--create vh max button
function ContractBrokerGui:_create_xp_vh_max_button()
	local back_panel = self._panel:panel({
		w = self._panels.main:w(),
		h = tweak_data.menu.pd2_small_font_size
	})

	back_panel:set_right(self._panels.main:right() - padding + 220)
	back_panel:set_top(self._panels.main:top() + 220)

	if managers.menu:is_pc_controller() then
		self._xp_vh_max_button = back_panel:text({
			vertical = "top",
			align = "right",
			layer = 1,
			text = managers.localization:to_upper_text("menu_difficulty_very_hard") .. " - Max",
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.button_stage_3
		})

		make_fine_text(self._xp_vh_max_button)
		self._xp_vh_max_button:set_right(back_panel:w())
	end
end

--create hh min button
function ContractBrokerGui:_create_xp_hh_min_button()
	local back_panel = self._panel:panel({
		w = self._panels.main:w(),
		h = tweak_data.menu.pd2_small_font_size
	})

	back_panel:set_right(self._panels.main:right() - padding + 220)
	back_panel:set_top(self._panels.main:top() + 250)

	if managers.menu:is_pc_controller() then
		self._xp_hh_min_button = back_panel:text({
			vertical = "top",
			align = "right",
			layer = 1,
			text = managers.localization:to_upper_text("menu_difficulty_hard") .. " - Min",
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.button_stage_3
		})

		make_fine_text(self._xp_hh_min_button)
		self._xp_hh_min_button:set_right(back_panel:w())
	end
end

--create hh max button
function ContractBrokerGui:_create_xp_hh_max_button()
	local back_panel = self._panel:panel({
		w = self._panels.main:w(),
		h = tweak_data.menu.pd2_small_font_size
	})

	back_panel:set_right(self._panels.main:right() - padding + 220)
	back_panel:set_top(self._panels.main:top() + 270)

	if managers.menu:is_pc_controller() then
		self._xp_hh_max_button = back_panel:text({
			vertical = "top",
			align = "right",
			layer = 1,
			text = managers.localization:to_upper_text("menu_difficulty_hard") .. " - Max",
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.button_stage_3
		})

		make_fine_text(self._xp_hh_max_button)
		self._xp_hh_max_button:set_right(back_panel:w())
	end
end

--create nn min button
function ContractBrokerGui:_create_xp_nn_min_button()
	local back_panel = self._panel:panel({
		w = self._panels.main:w(),
		h = tweak_data.menu.pd2_small_font_size
	})

	back_panel:set_right(self._panels.main:right() - padding + 220)
	back_panel:set_top(self._panels.main:top() + 300)

	if managers.menu:is_pc_controller() then
		self._xp_nn_min_button = back_panel:text({
			vertical = "top",
			align = "right",
			layer = 1,
			text = managers.localization:to_upper_text("menu_difficulty_normal") .. " - Min",
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.button_stage_3
		})

		make_fine_text(self._xp_nn_min_button)
		self._xp_nn_min_button:set_right(back_panel:w())
	end
end

--create nn max button
function ContractBrokerGui:_create_xp_nn_max_button()
	local back_panel = self._panel:panel({
		w = self._panels.main:w(),
		h = tweak_data.menu.pd2_small_font_size
	})

	back_panel:set_right(self._panels.main:right() - padding + 220)
	back_panel:set_top(self._panels.main:top() + 320)

	if managers.menu:is_pc_controller() then
		self._xp_nn_max_button = back_panel:text({
			vertical = "top",
			align = "right",
			layer = 1,
			text = managers.localization:to_upper_text("menu_difficulty_normal") .. " - Max",
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.button_stage_3
		})

		make_fine_text(self._xp_nn_max_button)
		self._xp_nn_max_button:set_right(back_panel:w())
	end
end

function ContractBrokerGui:_setup_filter_contact()
	local contacts = {}
	local filters = {}

	for index, job_id in ipairs(tweak_data.narrative:get_jobs_index()) do
		local job_tweak = tweak_data.narrative:job_data(job_id)
		local contact = job_tweak.contact
		local contact_tweak = tweak_data.narrative.contacts[contact]

		if contact then
			local allow_contact = true
			allow_contact = not table.contains(contacts, contact) and (not contact_tweak or not contact_tweak.hidden)

			if allow_contact then
				table.insert(contacts, contact)
				table.insert(filters, {
					id = contact,
					data = contact_tweak
				})
			end
		end
	end

	table.sort(filters, function (a, b)
		return managers.localization:to_upper_text(a.data.name_id) < managers.localization:to_upper_text(b.data.name_id)
	end)

	local last_y = 0
	local check_new_job_data = {
		filter_key = "contact",
		filter_func = ContractBrokerGui.perform_filter_contact
	}

	for filter_index, contact in ipairs(filters) do
		check_new_job_data.filter_param = contact
		local text = self:_add_filter_button(contact.data.name_id, last_y, {
			check_new_job_data = check_new_job_data
		})
		last_y = text:bottom() + 1
	end

	self._contact_filter_list = filters

	self:add_filter("contact", ContractBrokerGui.perform_filter_contact)
	--self:set_sorting_function(ContractBrokerGui.perform_standard_sort)
	self:set_sorting_function(ContractBrokerGui.perform_xp_sort_all)
end

function ContractBrokerGui:_setup_filter_time()
	local times = {
		{
			"menu_filter_heist_short"
		},
		{
			"menu_filter_heist_medium"
		},
		{
			"menu_filter_heist_long"
		}
	}
	local last_y = 0
	local check_new_job_data = {
		filter_key = "job_id",
		filter_func = ContractBrokerGui.perform_filter_time
	}

	for index, filter in ipairs(times) do
		check_new_job_data.filter_param = index
		local text = self:_add_filter_button(filter[1], last_y, {
			extra_h = 4,
			check_new_job_data = check_new_job_data
		})
		last_y = text:bottom() + 1
	end

	self:add_filter("job_id", ContractBrokerGui.perform_filter_time)
	--self:set_sorting_function(ContractBrokerGui.perform_standard_sort)
	self:set_sorting_function(ContractBrokerGui.perform_xp_sort_all)
end

function ContractBrokerGui:_setup_filter_tactic()
	local tactics = {
		{
			"menu_filter_tactic_loud_only"
		},
		{
			"menu_filter_tactic_stealth_only"
		},
		{
			"menu_filter_tactic_stealthable"
		}
	}
	local last_y = 0
	local check_new_job_data = {
		filter_key = "job",
		filter_func = ContractBrokerGui.perform_filter_tactic
	}

	for index, filter in ipairs(tactics) do
		check_new_job_data.filter_param = index
		local text = self:_add_filter_button(filter[1], last_y, {
			check_new_job_data = check_new_job_data,
			text_macros = filter[2]
		})
		last_y = text:bottom() + 1
	end

	self:add_filter("job", ContractBrokerGui.perform_filter_tactic)
	--self:set_sorting_function(ContractBrokerGui.perform_standard_sort)
	self:set_sorting_function(ContractBrokerGui.perform_xp_sort_all)
end

--new xp menu
function ContractBrokerGui:_setup_filter_xp()
	
	self:set_sorting_function(ContractBrokerGui.perform_xp_sort_all)
end

function ContractBrokerGui:_setup_filter_favourite()
	self._favourite_jobs = managers.crimenet:get_favourite_jobs()

	self:add_filter("job_id", ContractBrokerGui.perform_filter_favourites)
	--self:set_sorting_function(ContractBrokerGui.perform_standard_sort)
	self:set_sorting_function(ContractBrokerGui.perform_xp_sort_all)
end

function ContractBrokerGui:_setup_filter_skirmish()
	self:_add_filter_button("menu_skirmish_selected", 0)
	self:add_filter("contact", ContractBrokerGui.perform_filter_skirmish)
	--self:set_sorting_function(ContractBrokerGui.perform_standard_sort)
	self:set_sorting_function(ContractBrokerGui.perform_xp_sort_all)
end

--xp filter for all difficults
function ContractBrokerGui.perform_xp_sort_all(x, y)
	local difficulty_stars = 6
	
	local x_job_data = tweak_data.narrative:job_data(x.job_id)
	local x_contract_visuals = x_job_data.contract_visuals or {}
	
	local y_job_data = tweak_data.narrative:job_data(y.job_id)
	local y_contract_visuals = y_job_data.contract_visuals or {}

	local job_days_x = x_job_data and x_job_data.chain and table.size(x_job_data.chain) or 1
	local job_days_y = y_job_data and y_job_data.chain and table.size(y_job_data.chain) or 1

	local job_name_x = x_job_data and x_job_data.name_id or "no_briefheist"
	local job_name_y = y_job_data and y_job_data.name_id or "no_briefheist"
	
	--watchdogs and bigoil days fix
	if job_name_x == "heist_watchdogs" or job_name_x == "heist_welcome_to_the_jungle" then
	job_days_x = 2
	end
	
	if job_name_y == "heist_watchdogs" or job_name_y == "heist_welcome_to_the_jungle" then
	job_days_y = 2
	end
	--end
	
	--local x_custom = x_job_data.customize_contract or false
	--local y_custom = y_job_data.customize_contract or false
	
	local job_heat_value_x = managers.job:get_job_heat(x.job_id)
	local job_heat_value_y = managers.job:get_job_heat(y.job_id)
	
	if job_heat_value_x == nil then
		job_heat_value_x = 0
	end
	
	if job_heat_value_y == nil then
		job_heat_value_y = 0
	end
	
	local x_heat = managers.job:heat_to_experience_multiplier(job_heat_value_x) 
	local y_heat = managers.job:heat_to_experience_multiplier(job_heat_value_y)

	local x_xp_min = x_contract_visuals.min_mission_xp and (type(x_contract_visuals.min_mission_xp) == "table" and x_contract_visuals.min_mission_xp[difficulty_stars + 1] or x_contract_visuals.min_mission_xp) or 0
	
	local y_xp_min = y_contract_visuals.min_mission_xp and (type(y_contract_visuals.min_mission_xp) == "table" and y_contract_visuals.min_mission_xp[difficulty_stars + 1] or y_contract_visuals.min_mission_xp) or 0

	local x_xp_max = x_contract_visuals.max_mission_xp and (type(x_contract_visuals.max_mission_xp) == "table" and x_contract_visuals.max_mission_xp[difficulty_stars + 1] or x_contract_visuals.max_mission_xp) or 0
	
	local y_xp_max = y_contract_visuals.max_mission_xp and (type(y_contract_visuals.max_mission_xp) == "table" and y_contract_visuals.max_mission_xp[difficulty_stars + 1] or y_contract_visuals.max_mission_xp) or 0
	
	local x_xp_min_total = x_xp_min * job_days_x * x_heat
	local x_xp_max_total = x_xp_max * job_days_x * x_heat
	local y_xp_min_total = y_xp_min * job_days_y * y_heat
	local y_xp_max_total = y_xp_max * job_days_y * y_heat
	
	--player level reduction
	local x_job_stars = math.ceil(tweak_data.narrative:job_data(x.job_id).jc / 10)
	local y_job_stars = math.ceil(tweak_data.narrative:job_data(y.job_id).jc / 10)
	
	local player_stars = managers.experience:level_to_stars() or 0
	local x_is_level_limited = player_stars < x_job_stars
	local y_is_level_limited = player_stars < y_job_stars

	if x_is_level_limited then
		local x_diff_in_stars = x_job_stars - player_stars
		local x_tweak_multiplier = tweak_data:get_value("experience_manager", "level_limit", "pc_difference_multipliers", x_diff_in_stars) or 0
		local x_xp_min_reduc = math.round(x_xp_min_total * x_tweak_multiplier)
		local x_xp_max_reduc = math.round(x_xp_max_total * x_tweak_multiplier)
		
		x_xp_min_total = x_xp_min_reduc
		x_xp_max_total = x_xp_max_reduc
	end
	if y_is_level_limited then
		local y_diff_in_stars = y_job_stars - player_stars
		local y_tweak_multiplier = tweak_data:get_value("experience_manager", "level_limit", "pc_difference_multipliers", y_diff_in_stars) or 0
		local y_xp_min_reduc = math.round(y_xp_min_total * y_tweak_multiplier)
		local y_xp_max_reduc = math.round(y_xp_max_total * y_tweak_multiplier)
		
		y_xp_min_total = y_xp_min_reduc
		y_xp_max_total = y_xp_max_reduc
	end
	--end
	
		if _G.diffmenuselect == nil then
			_G.diffmenuselect = 1
			return y_xp_min_total < x_xp_min_total
		end
		if _G.diffmenuselect == 1 or _G.diffmenuselect == 3 or _G.diffmenuselect == 5 or _G.diffmenuselect == 7 or _G.diffmenuselect == 9 or _G.diffmenuselect == 11 or _G.diffmenuselect == 13 then
			return y_xp_min_total < x_xp_min_total
		end
		if _G.diffmenuselect == 2 or _G.diffmenuselect == 4 or _G.diffmenuselect == 6 or _G.diffmenuselect == 8 or _G.diffmenuselect == 10 or _G.diffmenuselect == 12 or _G.diffmenuselect == 14 then
			return y_xp_max_total < x_xp_max_total
		end
end

function ContractBrokerGui:mouse_moved(button, x, y)
	local used, pointer = nil

	if not used then
		local u, p = self._panels.scroll:mouse_moved(button, x, y)

		if u then
			used = u
			pointer = p or pointer
		end
	end

	if self._panels.filters:visible() then
		if self._filter_buttons[self._current_filter] then
			self._filter_selection_bg:set_y(self._filter_buttons[self._current_filter]:y())
			self._filter_selection_bg:set_visible(true)
		else
			self._filter_selection_bg:set_visible(false)
		end

		local btn = nil

		for idx, panel in ipairs(self._filter_buttons) do
			btn = panel:child("text")

			if not used and self._current_filter ~= idx and panel:inside(x, y) then
				pointer = "link"
				used = true

				btn:set_color(tweak_data.screen_colors.button_stage_2)
				btn:set_blend_mode("add")
				self._filter_selection_bg:set_y(panel:y())

				if self._highlighted_filter ~= idx then
					self._highlighted_filter = idx

					managers.menu:post_event("highlight")
				end
			elseif idx == self._current_filter then
				btn:set_color(tweak_data.screen_colors.button_stage_2)
				btn:set_blend_mode("add")
			else
				btn:set_color(tweak_data.screen_colors.button_stage_3)
				btn:set_blend_mode("normal")
			end
		end
	end

	for idx, btn in ipairs(self._tab_buttons) do
		if not used and self._current_tab ~= idx and btn:inside(x, y) then
			pointer = "link"
			used = true

			btn:set_alpha(1)

			if self._highlighted_tab ~= idx then
				self._highlighted_tab = idx

				managers.menu:post_event("highlight")
			end
		elseif idx == self._current_tab then
			btn:set_alpha(1)
		else
			btn:set_alpha(0.7)
		end
	end

	if self._panels.main:inside(x, y) then
		for _, item in ipairs(self._heist_items) do
			local u, p = item:mouse_moved(button, x, y, used)

			if u then
				used = u
				pointer = p or pointer
			end
		end
	else
		for _, item in ipairs(self._heist_items) do
			item:deselect()
		end
	end

	if self._search and alive(self._search.panel) and not used and self._search.panel:inside(x, y) then
		used = true
		pointer = "link"
	end

	if alive(self._back_button) then
		if not used and self._back_button:inside(x, y) then
			pointer = "link"
			used = true

			if self._back_button:color() ~= tweak_data.screen_colors.button_stage_2 then
				managers.menu:post_event("highlight")
				self._back_button:set_color(tweak_data.screen_colors.button_stage_2)
				self._back_button:set_blend_mode("add")
			end
		else
			self._back_button:set_color(tweak_data.screen_colors.button_stage_3)
			self._back_button:set_blend_mode("normal")
		end
	end
	
	--highlight button min ds
	if alive(self._xp_ds_min_button) then
		if not used and self._xp_ds_min_button:inside(x, y) then
			pointer = "link"
			used = true

			if self._xp_ds_min_button:color() ~= tweak_data.screen_colors.button_stage_2 then
				managers.menu:post_event("highlight")
				self._xp_ds_min_button:set_color(tweak_data.screen_colors.button_stage_2)
				self._xp_ds_min_button:set_blend_mode("add")
			end
		else
			self._xp_ds_min_button:set_color(tweak_data.screen_colors.button_stage_3)
			self._xp_ds_min_button:set_blend_mode("normal")
		end
	end
	
		--highlight button max ds
	if alive(self._xp_ds_max_button) then
		if not used and self._xp_ds_max_button:inside(x, y) then
			pointer = "link"
			used = true

			if self._xp_ds_max_button:color() ~= tweak_data.screen_colors.button_stage_2 then
				managers.menu:post_event("highlight")
				self._xp_ds_max_button:set_color(tweak_data.screen_colors.button_stage_2)
				self._xp_ds_max_button:set_blend_mode("add")
			end
		else
			self._xp_ds_max_button:set_color(tweak_data.screen_colors.button_stage_3)
			self._xp_ds_max_button:set_blend_mode("normal")
		end
	end
	
	--highlight button min dw
	if alive(self._xp_dw_min_button) then
		if not used and self._xp_dw_min_button:inside(x, y) then
			pointer = "link"
			used = true

			if self._xp_dw_min_button:color() ~= tweak_data.screen_colors.button_stage_2 then
				managers.menu:post_event("highlight")
				self._xp_dw_min_button:set_color(tweak_data.screen_colors.button_stage_2)
				self._xp_dw_min_button:set_blend_mode("add")
			end
		else
			self._xp_dw_min_button:set_color(tweak_data.screen_colors.button_stage_3)
			self._xp_dw_min_button:set_blend_mode("normal")
		end
	end
	
	--highlight button max dw
	if alive(self._xp_dw_max_button) then
		if not used and self._xp_dw_max_button:inside(x, y) then
			pointer = "link"
			used = true

			if self._xp_dw_max_button:color() ~= tweak_data.screen_colors.button_stage_2 then
				managers.menu:post_event("highlight")
				self._xp_dw_max_button:set_color(tweak_data.screen_colors.button_stage_2)
				self._xp_dw_max_button:set_blend_mode("add")
			end
		else
			self._xp_dw_max_button:set_color(tweak_data.screen_colors.button_stage_3)
			self._xp_dw_max_button:set_blend_mode("normal")
		end
	end
	
	--highlight button min mh
	if alive(self._xp_mh_min_button) then
		if not used and self._xp_mh_min_button:inside(x, y) then
			pointer = "link"
			used = true

			if self._xp_mh_min_button:color() ~= tweak_data.screen_colors.button_stage_2 then
				managers.menu:post_event("highlight")
				self._xp_mh_min_button:set_color(tweak_data.screen_colors.button_stage_2)
				self._xp_mh_min_button:set_blend_mode("add")
			end
		else
			self._xp_mh_min_button:set_color(tweak_data.screen_colors.button_stage_3)
			self._xp_mh_min_button:set_blend_mode("normal")
		end
	end
	
	--highlight button max mh
	if alive(self._xp_mh_max_button) then
		if not used and self._xp_mh_max_button:inside(x, y) then
			pointer = "link"
			used = true

			if self._xp_mh_max_button:color() ~= tweak_data.screen_colors.button_stage_2 then
				managers.menu:post_event("highlight")
				self._xp_mh_max_button:set_color(tweak_data.screen_colors.button_stage_2)
				self._xp_mh_max_button:set_blend_mode("add")
			end
		else
			self._xp_mh_max_button:set_color(tweak_data.screen_colors.button_stage_3)
			self._xp_mh_max_button:set_blend_mode("normal")
		end
	end
	
	--highlight button min ok
	if alive(self._xp_ok_min_button) then
		if not used and self._xp_ok_min_button:inside(x, y) then
			pointer = "link"
			used = true

			if self._xp_ok_min_button:color() ~= tweak_data.screen_colors.button_stage_2 then
				managers.menu:post_event("highlight")
				self._xp_ok_min_button:set_color(tweak_data.screen_colors.button_stage_2)
				self._xp_ok_min_button:set_blend_mode("add")
			end
		else
			self._xp_ok_min_button:set_color(tweak_data.screen_colors.button_stage_3)
			self._xp_ok_min_button:set_blend_mode("normal")
		end
	end
	
	--highlight button max ok
	if alive(self._xp_ok_max_button) then
		if not used and self._xp_ok_max_button:inside(x, y) then
			pointer = "link"
			used = true

			if self._xp_ok_max_button:color() ~= tweak_data.screen_colors.button_stage_2 then
				managers.menu:post_event("highlight")
				self._xp_ok_max_button:set_color(tweak_data.screen_colors.button_stage_2)
				self._xp_ok_max_button:set_blend_mode("add")
			end
		else
			self._xp_ok_max_button:set_color(tweak_data.screen_colors.button_stage_3)
			self._xp_ok_max_button:set_blend_mode("normal")
		end
	end
	
	--highlight button min vh
	if alive(self._xp_vh_min_button) then
		if not used and self._xp_vh_min_button:inside(x, y) then
			pointer = "link"
			used = true

			if self._xp_vh_min_button:color() ~= tweak_data.screen_colors.button_stage_2 then
				managers.menu:post_event("highlight")
				self._xp_vh_min_button:set_color(tweak_data.screen_colors.button_stage_2)
				self._xp_vh_min_button:set_blend_mode("add")
			end
		else
			self._xp_vh_min_button:set_color(tweak_data.screen_colors.button_stage_3)
			self._xp_vh_min_button:set_blend_mode("normal")
		end
	end
	
	--highlight button max vh
	if alive(self._xp_vh_max_button) then
		if not used and self._xp_vh_max_button:inside(x, y) then
			pointer = "link"
			used = true

			if self._xp_vh_max_button:color() ~= tweak_data.screen_colors.button_stage_2 then
				managers.menu:post_event("highlight")
				self._xp_vh_max_button:set_color(tweak_data.screen_colors.button_stage_2)
				self._xp_vh_max_button:set_blend_mode("add")
			end
		else
			self._xp_vh_max_button:set_color(tweak_data.screen_colors.button_stage_3)
			self._xp_vh_max_button:set_blend_mode("normal")
		end
	end
	
	--highlight button min hh
	if alive(self._xp_hh_min_button) then
		if not used and self._xp_hh_min_button:inside(x, y) then
			pointer = "link"
			used = true

			if self._xp_hh_min_button:color() ~= tweak_data.screen_colors.button_stage_2 then
				managers.menu:post_event("highlight")
				self._xp_hh_min_button:set_color(tweak_data.screen_colors.button_stage_2)
				self._xp_hh_min_button:set_blend_mode("add")
			end
		else
			self._xp_hh_min_button:set_color(tweak_data.screen_colors.button_stage_3)
			self._xp_hh_min_button:set_blend_mode("normal")
		end
	end
	
	--highlight button max hh
	if alive(self._xp_hh_max_button) then
		if not used and self._xp_hh_max_button:inside(x, y) then
			pointer = "link"
			used = true

			if self._xp_hh_max_button:color() ~= tweak_data.screen_colors.button_stage_2 then
				managers.menu:post_event("highlight")
				self._xp_hh_max_button:set_color(tweak_data.screen_colors.button_stage_2)
				self._xp_hh_max_button:set_blend_mode("add")
			end
		else
			self._xp_hh_max_button:set_color(tweak_data.screen_colors.button_stage_3)
			self._xp_hh_max_button:set_blend_mode("normal")
		end
	end
	
	--highlight button min nn
	if alive(self._xp_nn_min_button) then
		if not used and self._xp_nn_min_button:inside(x, y) then
			pointer = "link"
			used = true

			if self._xp_nn_min_button:color() ~= tweak_data.screen_colors.button_stage_2 then
				managers.menu:post_event("highlight")
				self._xp_nn_min_button:set_color(tweak_data.screen_colors.button_stage_2)
				self._xp_nn_min_button:set_blend_mode("add")
			end
		else
			self._xp_nn_min_button:set_color(tweak_data.screen_colors.button_stage_3)
			self._xp_nn_min_button:set_blend_mode("normal")
		end
	end
	
	--highlight button max nn
	if alive(self._xp_nn_max_button) then
		if not used and self._xp_nn_max_button:inside(x, y) then
			pointer = "link"
			used = true

			if self._xp_nn_max_button:color() ~= tweak_data.screen_colors.button_stage_2 then
				managers.menu:post_event("highlight")
				self._xp_nn_max_button:set_color(tweak_data.screen_colors.button_stage_2)
				self._xp_nn_max_button:set_blend_mode("add")
			end
		else
			self._xp_nn_max_button:set_color(tweak_data.screen_colors.button_stage_3)
			self._xp_nn_max_button:set_blend_mode("normal")
		end
	end
	
	return used, pointer
end

function ContractBrokerGui:mouse_clicked(o, button, x, y)
	self:disconnect_search_input()

	if self._scroll_event then
		self._scroll_event = nil

		return
	end

	if self._panels.scroll:mouse_clicked(o, button, x, y) then
		self._scroll_event = true

		return true
	end

	if self._panels.filters:visible() then
		for idx, btn in ipairs(self._filter_buttons) do
			if self._current_filter ~= idx and btn:inside(x, y) then
				self._current_filter = idx

				self:_setup_change_filter()
				managers.menu:post_event("menu_enter")

				return true
			end
		end
	end

	for idx, btn in ipairs(self._tab_buttons) do
		if self._current_tab ~= idx and btn:inside(x, y) then
			self._current_tab = idx

			self:_setup_change_tab()
			managers.menu:post_event("menu_enter")

			return true
		end
	end

	if self._panels.main:inside(x, y) then
		for _, item in ipairs(self._heist_items) do
			if item:mouse_clicked(o, button, x, y) then
				return true
			end
		end
	end

	if self._search and alive(self._search.panel) and self._search.panel:inside(x, y) then
		self:connect_search_input()

		return true
	end

	if alive(self._back_button) and self._back_button:inside(x, y) then
		managers.menu:back()
	
		return true
	end
	
	--show ds min xp
	if alive(self._xp_ds_min_button) and self._xp_ds_min_button:inside(x, y) then
		_G.diffmenuselect = 1
		self:set_sorting_function(ContractBrokerGui.perform_xp_sort_all)

		self:_setup_jobs()
		self:refresh()
		
		return true
	end
	
	--show ds max xp
	if alive(self._xp_ds_max_button) and self._xp_ds_max_button:inside(x, y) then
		_G.diffmenuselect = 2
		self:set_sorting_function(ContractBrokerGui.perform_xp_sort_all)
		
		self:_setup_jobs()
		self:refresh()
		
		return true
	end
	
	--show dw min xp
	if alive(self._xp_dw_min_button) and self._xp_dw_min_button:inside(x, y) then
		_G.diffmenuselect = 3
		self:set_sorting_function(ContractBrokerGui.perform_xp_sort_all)
		
		self:_setup_jobs()
		self:refresh()
		
		return true
	end
	
	--show dw max xp
	if alive(self._xp_dw_max_button) and self._xp_dw_max_button:inside(x, y) then
		_G.diffmenuselect = 4
		self:set_sorting_function(ContractBrokerGui.perform_xp_sort_all)
		
		self:_setup_jobs()
		self:refresh()
		
		return true
	end
	
	--show mh min xp
	if alive(self._xp_mh_min_button) and self._xp_mh_min_button:inside(x, y) then
		_G.diffmenuselect = 5
		self:set_sorting_function(ContractBrokerGui.perform_xp_sort_all)
		
		self:_setup_jobs()
		self:refresh()
		
		return true
	end
	
	--show mh max xp
	if alive(self._xp_mh_max_button) and self._xp_mh_max_button:inside(x, y) then
		_G.diffmenuselect = 6
		self:set_sorting_function(ContractBrokerGui.perform_xp_sort_all)
		
		self:_setup_jobs()
		self:refresh()
		
		return true
	end
	
	--show ok min xp
	if alive(self._xp_ok_min_button) and self._xp_ok_min_button:inside(x, y) then
		_G.diffmenuselect = 7
		self:set_sorting_function(ContractBrokerGui.perform_xp_sort_all)
		
		self:_setup_jobs()
		self:refresh()
		
		return true
	end
	
	--show ok max xp
	if alive(self._xp_ok_max_button) and self._xp_ok_max_button:inside(x, y) then
		_G.diffmenuselect = 8
		self:set_sorting_function(ContractBrokerGui.perform_xp_sort_all)
		
		self:_setup_jobs()
		self:refresh()
		
		return true
	end
	
	--show vh min xp
	if alive(self._xp_vh_min_button) and self._xp_vh_min_button:inside(x, y) then
		_G.diffmenuselect = 9
		self:set_sorting_function(ContractBrokerGui.perform_xp_sort_all)
		
		self:_setup_jobs()
		self:refresh()
		
		return true
	end
	
	--show vh max xp
	if alive(self._xp_vh_max_button) and self._xp_vh_max_button:inside(x, y) then
		_G.diffmenuselect = 10
		self:set_sorting_function(ContractBrokerGui.perform_xp_sort_all)
		
		self:_setup_jobs()
		self:refresh()
		
		return true
	end
	
	--show hh min xp
	if alive(self._xp_hh_min_button) and self._xp_hh_min_button:inside(x, y) then
		_G.diffmenuselect = 11
		self:set_sorting_function(ContractBrokerGui.perform_xp_sort_all)
		
		self:_setup_jobs()
		self:refresh()
		
		return true
	end
	
	--show hh max xp
	if alive(self._xp_hh_max_button) and self._xp_hh_max_button:inside(x, y) then
		_G.diffmenuselect = 12
		self:set_sorting_function(ContractBrokerGui.perform_xp_sort_all)
		
		self:_setup_jobs()
		self:refresh()
		
		return true
	end
	
	--show nn min xp
	if alive(self._xp_nn_min_button) and self._xp_nn_min_button:inside(x, y) then
		_G.diffmenuselect = 13
		self:set_sorting_function(ContractBrokerGui.perform_xp_sort_all)
		
		self:_setup_jobs()
		self:refresh()
		
		return true
	end
	
	--show nn max xp
	if alive(self._xp_nn_max_button) and self._xp_nn_max_button:inside(x, y) then
		_G.diffmenuselect = 14
		self:set_sorting_function(ContractBrokerGui.perform_xp_sort_all)
		
		self:_setup_jobs()
		self:refresh()
		
		return true
	end
	
end