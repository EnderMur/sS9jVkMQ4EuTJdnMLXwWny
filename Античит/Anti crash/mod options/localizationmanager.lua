local loc = _G["A-Anti-Crash-Loc"]
local class_name = loc and loc.config and loc.config.base and loc.config.base.class_name

if not class_name then
	return
end

local punishments = {
	[class_name.."punishment_1"] = "warn",
	[class_name.."punishment_2"] = "kick",
	[class_name.."punishment_3"] = "ban",
	[class_name.."punishment_4"] = "nothing"
}

local function sort_items(menu)
	local result = {}
	for k, v in pairs(punishments) do
		result[#result + 1] = (menu and v or class_name.."punishment_"..#result + 1)
	end
	return result
end

Hooks:Add("LocalizationManagerPostInit", class_name.."Loc", function(loc)
	local string_desc = "How many times the notifications message will stack/show."
	
	LocalizationManager:add_localized_strings({
		[class_name.."_menu_title"] = "Anti Crash",
		[class_name.."_menu_desc"] = "",
		
		
		[class_name.."punishment_title"] = "Punishment",
		[class_name.."punishment_desc"] = "Set how you would like to take action on crash prevention.",
			
		[class_name.."crash_notifications_title"] = "Crash Notify",
		[class_name.."crash_notifications_desc"] = string_desc,
		[class_name.."error_notifications_title"] = "Error Notify",
		[class_name.."error_notifications_desc"] = string_desc,
		
		[class_name.."chat_message_title"] = "Display Chat",
		[class_name.."chat_message_desc"] = "'On' to display in chat window or 'Off' to display in debug window."
	})
	
	for id, loc in pairs(punishments) do
		LocalizationManager:add_localized_strings({[id] = loc})
	end
end)

Hooks:Add("MenuManagerSetupCustomMenus", class_name.."Menu", function(menu_manager, nodes)
	MenuHelper:NewMenu(class_name)
end)

Hooks:Add("MenuManagerPopulateCustomMenus", class_name.."Menu", function(menu_manager, nodes)
	MenuCallbackHandler.A_Anti_Crash_punishment = function(self, item)
		loc.config.safecaller.punishment = tonumber(item:value())
		loc:save_config()
	end
	
	MenuHelper:AddMultipleChoice({
		id = class_name.."punishment",
		title = class_name.."punishment_title",
		desc = class_name.."punishment_desc",
		callback = class_name.."_punishment",
		items = sort_items(),
		value = loc.config.safecaller.punishment,
		menu_id = class_name,
		priority = 1000
	})

	MenuCallbackHandler.A_Anti_Crash_crash_notifications = function(self, item)
		loc.config.safecaller.crash_notifications = tonumber(item:value()) * 10
		loc:save_config()
	end

	MenuHelper:AddSlider({
		id = class_name.."crash_notifications",
		title = class_name.."crash_notifications_title",
		desc = class_name.."crash_notifications_desc",
		callback = class_name.."_crash_notifications",
		value = tonumber(loc.config.safecaller.crash_notifications),
		min = 1,
		max = 100,
		step = 1,
		show_value = true,
		menu_id = class_name,
		priority = 2000
	})
	
	MenuCallbackHandler.A_Anti_Crash_error_notifications = function(self, item)
		loc.config.safecaller.error_notifications = tonumber(item:value()) * 10
		loc:save_config()
	end

	MenuHelper:AddSlider({
		id = class_name.."error_notifications",
		title = class_name.."error_notifications_title",
		desc = class_name.."error_notifications_desc",
		callback = class_name.."_error_notifications",
		value = tonumber(loc.config.safecaller.error_notifications),
		min = 1,
		max = 100,
		step = 1,
		show_value = true,
		menu_id = class_name,
		priority = 2001
	})
	
	MenuCallbackHandler.A_Anti_Crash_chat_message = function(self, item)
		loc.config.safecaller.chat_message = not loc.config.safecaller.chat_message
		loc:save_config()
	end
	
	MenuHelper:AddToggle({
		id = class_name.."chat_message",
		title = class_name.."chat_message_title",
		desc = class_name.."chat_message_desc",
		callback = class_name.."_chat_message",
		value = loc.config.safecaller.chat_message,
		menu_id = class_name,  
		priority = 2002
	})
end)

Hooks:Add("MenuManagerBuildCustomMenus", class_name.."Menu", function(menu_manager, nodes)
	nodes[class_name] = MenuHelper:BuildMenu(class_name)
	MenuHelper:AddMenuItem(nodes["blt_options"], class_name, class_name.."_menu_title", class_name.."_menu_desc")
end)