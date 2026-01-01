local padding = 10

local function make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

ContractBrokerHeistItem = ContractBrokerHeistItem or class()

function ContractBrokerHeistItem:init(parent_panel, job_data, idx)
	self._parent = parent_panel
	self._job_data = job_data
	local job_tweak = tweak_data.narrative:job_data(job_data.job_id)
	local contact = job_tweak.contact
	local contact_tweak = tweak_data.narrative.contacts[contact]
	self._panel = parent_panel:panel({
		halign = "grow",
		layer = 10,
		h = 90,
		x = 0,
		valign = "top",
		y = 90 * (idx - 1)
	})
	self._background = self._panel:rect({
		blend_mode = "add",
		alpha = 0.4,
		halign = "grow",
		layer = -1,
		valign = "grow",
		y = padding,
		h = self._panel:h() - padding,
		color = job_data.enabled and tweak_data.screen_colors.button_stage_3 or tweak_data.screen_colors.important_1
	})

	self._background:set_visible(false)

	local img_size = self._panel:h() - padding
	self._image_panel = self._panel:panel({
		halign = "left",
		layer = 1,
		x = 0,
		valign = "top",
		y = padding,
		w = img_size * 1.7777777777777777,
		h = img_size
	})
	local has_image = false

	if job_tweak.contract_visuals and job_tweak.contract_visuals.preview_image then
		local data = job_tweak.contract_visuals.preview_image
		local path, rect = nil

		if data.id then
			path = "guis/dlcs/" .. (data.folder or "bro") .. "/textures/pd2/crimenet/" .. data.id
			rect = data.rect
		elseif data.icon then
			path, rect = tweak_data.hud_icons:get_icon_data(data.icon)
		end

		if path and DB:has(Idstring("texture"), path) then
			self._image_panel:bitmap({
				valign = "scale",
				layer = 2,
				blend_mode = "add",
				halign = "scale",
				texture = path,
				texture_rect = rect,
				w = self._image_panel:w(),
				h = self._image_panel:h(),
				color = Color.white
			})

			self._image = self._image_panel:rect({
				alpha = 1,
				layer = 1,
				color = Color.black
			})
			has_image = true
		end
	end

	if not has_image then
		local color = Color.red
		local error_message = "Missing Preview Image"

		self._image_panel:rect({
			alpha = 0.4,
			layer = 1,
			color = color
		})
		self._image_panel:text({
			vertical = "center",
			wrap = true,
			align = "center",
			word_wrap = true,
			layer = 2,
			text = error_message,
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size
		})
		BoxGuiObject:new(self._image_panel:panel({
			layer = 100
		}), {
			sides = {
				1,
				1,
				1,
				1
			}
		})
	end

	local job_name = self._panel:text({
		layer = 1,
		vertical = "top",
		align = "left",
		halign = "left",
		valign = "top",
		text = managers.localization:to_upper_text(job_tweak.name_id),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = job_data.enabled and tweak_data.screen_colors.text or tweak_data.screen_colors.important_1
	})

	make_fine_text(job_name)
	job_name:set_left(self._image_panel:right() + padding * 2)
	job_name:set_top(self._panel:h() * 0.5 + padding * 0.5)

	local contact_name = self._panel:text({
		alpha = 0.8,
		vertical = "top",
		layer = 1,
		align = "left",
		halign = "left",
		valign = "top",
		text = managers.localization:to_upper_text(contact_tweak.name_id),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size * 0.9,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(contact_name)
	contact_name:set_left(job_name:left())
	contact_name:set_bottom(job_name:top())

	local dlc_name, dlc_color = self:get_dlc_name_and_color(job_tweak)
	local dlc_name = self._panel:text({
		alpha = 1,
		vertical = "top",
		layer = 1,
		align = "left",
		halign = "left",
		valign = "top",
		text = dlc_name,
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size * 0.9,
		color = dlc_color
	})

	make_fine_text(dlc_name)
	dlc_name:set_left(contact_name:right() + 5)
	dlc_name:set_bottom(job_name:top())

	if job_data.is_new then
		local new_name = self._panel:text({
			alpha = 1,
			vertical = "top",
			layer = 1,
			align = "left",
			halign = "left",
			valign = "top",
			text = managers.localization:to_upper_text("menu_new"),
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size * 0.9,
			color = Color(255, 105, 254, 59) / 255
		})

		make_fine_text(new_name)
		new_name:set_left((dlc_name:text() ~= "" and dlc_name or contact_name):right() + 5)
		new_name:set_bottom(job_name:top())
	end

	local last_played = self._panel:text({
		alpha = 0.7,
		vertical = "top",
		layer = 1,
		align = "right",
		halign = "right",
		valign = "top",
		text = self:get_last_played_text(),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size * 0.7,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(last_played)
	last_played:set_right(self._panel:right() - padding)
	last_played:set_bottom(job_name:top())
	
	--show xp panel
	local show_xp = self._panel:text({
		alpha = 1,
		vertical = "top",
		layer = 1,
		align = "right",
		halign = "right",
		valign = "top",
		text = self:get_show_xp_text(),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size * 0.7,
		color = tweak_data.screen_colors.community_color
	})

	make_fine_text(show_xp)
	show_xp:set_left(self._panel:right() - padding - 450)
	show_xp:set_top(job_name:top() - 40)
	--end
	
	--show xp extras panel
	local show_xp_extras = self._panel:text({
		alpha = 0.8,
		vertical = "top",
		layer = 1,
		align = "right",
		halign = "right",
		valign = "top",
		text = self:get_show_xp_extras_text(),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size * 0.6,
		color = Color.white
	})

	make_fine_text(show_xp_extras)
	show_xp_extras:set_left(self._panel:right() - padding - 450)
	show_xp_extras:set_top(job_name:top() + 25)
	--end
	
	local icons_panel = self._panel:panel({
		valign = "top",
		halign = "right",
		h = job_name:h(),
		w = self._panel:w() * 0.3
	})

	icons_panel:set_right(self._panel:right() - padding)
	icons_panel:set_top(job_name:top())

	local icon_size = icons_panel:h()
	local last_icon = nil
	self._favourite = icons_panel:bitmap({
		texture = "guis/dlcs/bro/textures/pd2/favourite",
		halign = "right",
		alpha = 0.8,
		valign = "top",
		color = Color.white,
		w = icon_size,
		h = icon_size
	})

	self._favourite:set_right(icons_panel:w())

	last_icon = self._favourite
	local day_text = icons_panel:text({
		layer = 1,
		vertical = "bottom",
		align = "right",
		halign = "right",
		valign = "top",
		text = self:get_heist_day_text(),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size * 0.9,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(day_text)
	day_text:set_right(last_icon:left() - 5)
	day_text:set_bottom(icons_panel:h())

	last_icon = day_text
	local length_icon = icons_panel:text({
		layer = 1,
		vertical = "bottom",
		align = "right",
		halign = "right",
		valign = "top",
		text = self:get_heist_day_icon(),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size * 0.8,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(length_icon)
	length_icon:set_right(last_icon:left() - padding)
	length_icon:set_top(2)

	last_icon = length_icon

	if self:is_stealthable() then
		local stealth = icons_panel:text({
			layer = 1,
			vertical = "top",
			align = "right",
			halign = "right",
			valign = "top",
			text = managers.localization:get_default_macro("BTN_GHOST"),
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size,
			color = tweak_data.screen_colors.text
		})

		make_fine_text(stealth)
		stealth:set_right(last_icon:left() - padding)

		last_icon = stealth
	end

	self:refresh()
end

--show xp text for panel
function ContractBrokerHeistItem:get_show_xp_text()
	local total_xp_min, total_xp_max, dissected_xp, total_payout, base_payout, risk_payout = nil
	
	local job_data = tweak_data.narrative:job_data(self._job_data.job_id)
	local job_chain = tweak_data.narrative:job_chain(self._job_data.job_id)
	local contract_visuals = job_data.contract_visuals or {}
	
	local job_stars = math.ceil(tweak_data.narrative:job_data(self._job_data.job_id).jc / 10)
	
	if _G.diffmenuselect == nil then
	_G.diffmenuselect = 1
	end
	
	if _G.diffmenuselect == 1 or _G.diffmenuselect == 2 then
	local xp_min = contract_visuals.min_mission_xp and (type(contract_visuals.min_mission_xp) == "table" and contract_visuals.min_mission_xp[6 + 1] or contract_visuals.min_mission_xp) or 0
	local xp_max = contract_visuals.max_mission_xp and (type(contract_visuals.max_mission_xp) == "table" and contract_visuals.max_mission_xp[6 + 1] or contract_visuals.max_mission_xp) or 0
	
	total_xp_min, dissected_xp = managers.experience:get_contract_xp_by_stars(self._job_data.job_id, job_stars, 6, false, #job_chain, {
			mission_xp = xp_min
		})
	total_xp_max, dissected_xp = managers.experience:get_contract_xp_by_stars(self._job_data.job_id, job_stars, 6, false, #job_chain, {
			mission_xp = xp_max
		})
	end
	
	if _G.diffmenuselect == 3 or _G.diffmenuselect == 4 then
	local xp_min = contract_visuals.min_mission_xp and (type(contract_visuals.min_mission_xp) == "table" and contract_visuals.min_mission_xp[5 + 1] or contract_visuals.min_mission_xp) or 0
	local xp_max = contract_visuals.max_mission_xp and (type(contract_visuals.max_mission_xp) == "table" and contract_visuals.max_mission_xp[5 + 1] or contract_visuals.max_mission_xp) or 0
	
	total_xp_min, dissected_xp = managers.experience:get_contract_xp_by_stars(self._job_data.job_id, job_stars, 5, false, #job_chain, {
			mission_xp = xp_min
		})
	total_xp_max, dissected_xp = managers.experience:get_contract_xp_by_stars(self._job_data.job_id, job_stars, 5, false, #job_chain, {
			mission_xp = xp_max
		})
	end
	
	if _G.diffmenuselect == 5 or _G.diffmenuselect == 6 then
	local xp_min = contract_visuals.min_mission_xp and (type(contract_visuals.min_mission_xp) == "table" and contract_visuals.min_mission_xp[4 + 1] or contract_visuals.min_mission_xp) or 0
	local xp_max = contract_visuals.max_mission_xp and (type(contract_visuals.max_mission_xp) == "table" and contract_visuals.max_mission_xp[4 + 1] or contract_visuals.max_mission_xp) or 0
	
	total_xp_min, dissected_xp = managers.experience:get_contract_xp_by_stars(self._job_data.job_id, job_stars, 4, false, #job_chain, {
			mission_xp = xp_min
		})
	total_xp_max, dissected_xp = managers.experience:get_contract_xp_by_stars(self._job_data.job_id, job_stars, 4, false, #job_chain, {
			mission_xp = xp_max
		})
	end
	
	if _G.diffmenuselect == 7 or _G.diffmenuselect == 8 then
	local xp_min = contract_visuals.min_mission_xp and (type(contract_visuals.min_mission_xp) == "table" and contract_visuals.min_mission_xp[3 + 1] or contract_visuals.min_mission_xp) or 0
	local xp_max = contract_visuals.max_mission_xp and (type(contract_visuals.max_mission_xp) == "table" and contract_visuals.max_mission_xp[3 + 1] or contract_visuals.max_mission_xp) or 0
	
	total_xp_min, dissected_xp = managers.experience:get_contract_xp_by_stars(self._job_data.job_id, job_stars, 3, false, #job_chain, {
			mission_xp = xp_min
		})
	total_xp_max, dissected_xp = managers.experience:get_contract_xp_by_stars(self._job_data.job_id, job_stars, 3, false, #job_chain, {
			mission_xp = xp_max
		})
	end
	
	if _G.diffmenuselect == 9 or _G.diffmenuselect == 10 then
	local xp_min = contract_visuals.min_mission_xp and (type(contract_visuals.min_mission_xp) == "table" and contract_visuals.min_mission_xp[2 + 1] or contract_visuals.min_mission_xp) or 0
	local xp_max = contract_visuals.max_mission_xp and (type(contract_visuals.max_mission_xp) == "table" and contract_visuals.max_mission_xp[2 + 1] or contract_visuals.max_mission_xp) or 0
	
	total_xp_min, dissected_xp = managers.experience:get_contract_xp_by_stars(self._job_data.job_id, job_stars, 2, false, #job_chain, {
			mission_xp = xp_min
		})
	total_xp_max, dissected_xp = managers.experience:get_contract_xp_by_stars(self._job_data.job_id, job_stars, 2, false, #job_chain, {
			mission_xp = xp_max
		})
	end
	
	if _G.diffmenuselect == 11 or _G.diffmenuselect == 12 then
	local xp_min = contract_visuals.min_mission_xp and (type(contract_visuals.min_mission_xp) == "table" and contract_visuals.min_mission_xp[1 + 1] or contract_visuals.min_mission_xp) or 0
	local xp_max = contract_visuals.max_mission_xp and (type(contract_visuals.max_mission_xp) == "table" and contract_visuals.max_mission_xp[1 + 1] or contract_visuals.max_mission_xp) or 0
	
	total_xp_min, dissected_xp = managers.experience:get_contract_xp_by_stars(self._job_data.job_id, job_stars, 1, false, #job_chain, {
			mission_xp = xp_min
		})
	total_xp_max, dissected_xp = managers.experience:get_contract_xp_by_stars(self._job_data.job_id, job_stars, 1, false, #job_chain, {
			mission_xp = xp_max
		})
	end
	
	if _G.diffmenuselect == 13 or _G.diffmenuselect == 14 then
	local xp_min = contract_visuals.min_mission_xp and (type(contract_visuals.min_mission_xp) == "table" and contract_visuals.min_mission_xp[0 + 1] or contract_visuals.min_mission_xp) or 0
	local xp_max = contract_visuals.max_mission_xp and (type(contract_visuals.max_mission_xp) == "table" and contract_visuals.max_mission_xp[0 + 1] or contract_visuals.max_mission_xp) or 0
	
	total_xp_min, dissected_xp = managers.experience:get_contract_xp_by_stars(self._job_data.job_id, job_stars, 0, false, #job_chain, {
			mission_xp = xp_min
		})
	total_xp_max, dissected_xp = managers.experience:get_contract_xp_by_stars(self._job_data.job_id, job_stars, 0, false, #job_chain, {
			mission_xp = xp_max
		})
	end
	
	local gain_xp_min = total_xp_min
	local gain_xp_max = total_xp_max
	local levels_gained_min = managers.experience:get_levels_gained_from_xp(gain_xp_min)
	local levels_gained_max = managers.experience:get_levels_gained_from_xp(gain_xp_max)
	
	local levels_min = string.format("%0.1d%%", levels_gained_min * 100)
	local levels_max = string.format("%0.1d%%", levels_gained_max * 100)
	
	local ds = utf8.to_upper(managers.localization:text("menu_difficulty_sm_wish", 0))
	local dw = utf8.to_upper(managers.localization:text("menu_difficulty_apocalypse", 0))
	local mh = utf8.to_upper(managers.localization:text("menu_difficulty_easy_wish", 0))
	local ok = utf8.to_upper(managers.localization:text("menu_difficulty_overkill", 0))
	local vh = utf8.to_upper(managers.localization:text("menu_difficulty_very_hard", 0))
	local hh = utf8.to_upper(managers.localization:text("menu_difficulty_hard", 0))
	local nn = utf8.to_upper(managers.localization:text("menu_difficulty_normal", 0))
	
	if _G.diffmenuselect == 1 then
	return "(" .. ds .. ")    Min: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_min)) .. " (" .. levels_min .. ") |  Max: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_max)) .. " (" .. levels_max .. ")"
	end
	
	if _G.diffmenuselect == 2 then
	return "(" .. ds .. ")     Min: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_min)) .. " (" .. levels_min .. ") | Max: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_max)) .. " (" .. levels_max .. ")"
	end
	
	if _G.diffmenuselect == 3 then
	return "(" .. dw .. ")    Min: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_min)) .. " (" .. levels_min .. ") |  Max: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_max)) .. " (" .. levels_max .. ")"
	end
	
	if _G.diffmenuselect == 4 then
	return "(" .. dw .. ")     Min: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_min)) .. " (" .. levels_min .. ") | Max: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_max)) .. " (" .. levels_max .. ")"
	end
	
	if _G.diffmenuselect == 5 then
	return "(" .. mh .. ")    Min: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_min)) .. " (" .. levels_min .. ") |  Max: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_max)) .. " (" .. levels_max .. ")"
	end
	
	if _G.diffmenuselect == 6 then
	return "(" .. mh .. ")     Min: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_min)) .. " (" .. levels_min .. ") | Max: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_max)) .. " (" .. levels_max .. ")"
	end
	
	if _G.diffmenuselect == 7 then
	return "(" .. ok .. ")    Min: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_min)) .. " (" .. levels_min .. ") |  Max: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_max)) .. " (" .. levels_max .. ")"
	end
	
	if _G.diffmenuselect == 8 then
	return "(" .. ok .. ")     Min: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_min)) .. " (" .. levels_min .. ") | Max: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_max)) .. " (" .. levels_max .. ")"
	end
	
	if _G.diffmenuselect == 9 then
	return "(" .. vh .. ")    Min: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_min)) .. " (" .. levels_min .. ") |  Max: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_max)) .. " (" .. levels_max .. ")"
	end
	
	if _G.diffmenuselect == 10 then
	return "(" .. vh .. ")     Min: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_min)) .. " (" .. levels_min .. ") | Max: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_max)) .. " (" .. levels_max .. ")"
	end
	
	if _G.diffmenuselect == 11 then
	return "(" .. hh .. ")    Min: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_min)) .. " (" .. levels_min .. ") |  Max: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_max)) .. " (" .. levels_max .. ")"
	end
	
	if _G.diffmenuselect == 12 then
	return "(" .. hh .. ")     Min: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_min)) .. " (" .. levels_min .. ") | Max: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_max)) .. " (" .. levels_max .. ")"
	end
	
	if _G.diffmenuselect == 13 then
	return "(" .. nn .. ")    Min: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_min)) .. " (" .. levels_min .. ") |  Max: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_max)) .. " (" .. levels_max .. ")"
	end
	
	if _G.diffmenuselect == 14 then
	return "(" .. nn .. ")     Min: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_min)) .. " (" .. levels_min .. ") | Max: ".. managers.money:add_decimal_marks_to_string(tostring(total_xp_max)) .. " (" .. levels_max .. ")"
	end
	
end

--show xp extras text for panel
function ContractBrokerHeistItem:get_show_xp_extras_text()
	local job_data = tweak_data.narrative:job_data(self._job_data.job_id)
	local job_chain = tweak_data.narrative:job_chain(self._job_data.job_id)
	local contract_visuals = job_data.contract_visuals or {}

	--jc
	local job_jc = tweak_data.narrative:job_data(self._job_data.job_id).jc or 10
	
	--ghost bonus
	local ghost_multiplier = managers.job:get_ghost_bonus() * 100 or 0
	if ghost_multiplier > 0 then
		ghost_multiplier = "+".. ghost_multiplier
	end
	
	local min_ghost_bonus, max_ghost_bonus = managers.job:get_job_ghost_bonus(self._job_data.job_id)
	if min_ghost_bonus == nil then min_ghost_bonus = 0 end
	if max_ghost_bonus == nil then max_ghost_bonus = 0 end
	local min_ghost = math.round(min_ghost_bonus * 100)
	local max_ghost = math.round(max_ghost_bonus * 100)
	local ghost_bonus = 0
	if min_ghost == max_ghost then
	ghost_bonus = min_ghost .. "%"
	end
	if min_ghost ~= max_ghost then
	ghost_bonus = min_ghost .. "-" .. max_ghost .. "%"
	end
	
	--heat xp
	local job_heat_value_xp = managers.job:get_job_heat(self._job_data.job_id)
	
	if job_heat_value_xp == nil then
		job_heat_value_xp = 0
	end
	
	local job_heat_mul  = managers.job:heat_to_experience_multiplier(job_heat_value_xp) * 100 -100 or 0
	local job_heat = job_heat_value_xp or 0
	if job_heat_mul > 0 then
		job_heat_mul = "+".. job_heat_mul
	end
	
	--infamy xp bonus
	local infamy_xp = managers.player:get_infamy_exp_multiplier() * 100 -100 or 0
	if infamy_xp > 0 then
		infamy_xp = "+".. infamy_xp
	end
	
	--level limit reduction
	local job_stars = math.ceil(tweak_data.narrative:job_data(self._job_data.job_id).jc / 10)
	local player_stars = managers.experience:level_to_stars() or 0
	local is_level_limited = player_stars < job_stars

	local tweak_multiplier = 0
	local tweak_multiplier_percent = 0
	
	if is_level_limited then
		local diff_in_stars = job_stars - player_stars
		tweak_multiplier = 1 - (job_stars - player_stars) / 10
		tweak_multiplier_percent = (1 - tweak_multiplier) * 100
		if tweak_multiplier_percent > 0 then
		tweak_multiplier_percent = "-".. tweak_multiplier_percent
		end
	end
	
	return "JC: " .. job_jc .. " | LVL Limit: " .. tweak_multiplier .. " (" .. tweak_multiplier_percent .. "%) | Heat: " .. job_heat .. " (" .. job_heat_mul .. "%) | Stealth Bonus: " .. ghost_bonus .. " (Current: " .. ghost_multiplier .. "%) | Infamy Bonus: " .. infamy_xp .. "%"
	
end