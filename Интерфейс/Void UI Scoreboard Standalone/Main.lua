_G.VoidUISBStandalone = _G.VoidUISBStandalone or {}
VoidUISBStandalone.Warning = 0
VoidUISBStandalone.loaded = false
VoidUISBStandalone.mod_path = ModPath
VoidUISBStandalone.options_path = SavePath .. "VoidUISBStandalone.txt"
VoidUISBStandalone.options = {} 
VoidUISBStandalone.menus = {}
VoidUISBStandalone.hook_files = {
	["lib/managers/hudmanager"] = {"managers/HudManager.lua"},
	["lib/units/player_team/teamaidamage"] = {"managers/HudManager.lua"},
	["lib/units/player_team/huskteamaidamage"] = {"managers/HudManager.lua"},
	["lib/units/player_team/teamaiinventory"] = {"managers/HudManager.lua"},
	["lib/managers/achievmentmanager"] = {"managers/HudManager.lua"},
	["lib/network/base/basenetworksession"] = {"managers/HudManager.lua"},
	["lib/units/enemies/cop/copdamage"] = {"hud/HudScoreboard.lua"},
	["lib/managers/hudmanagerpd2"] = {"managers/HudManager.lua", "hud/HudScoreboard.lua"},
	["lib/units/civilians/civiliandamage"] = {"hud/CivKill.lua"},
	["lib/managers/hud/newhudstatsscreen"] = {"hud/HudScoreboard.lua"},
	["lib/managers/hud/hudstatsscreenskirmish"] = {"hud/HudScoreboard.lua"},
	["lib/units/beings/player/huskplayermovement"] = {"hud/HudPlayerDowned.lua"},
	["lib/units/beings/player/states/playerbleedout"] = {"hud/HudPlayerDowned.lua"},
	["lib/network/handlers/unitnetworkhandler"] = {"hud/HudPlayerDowned.lua"},
	["lib/units/equipment/doctor_bag/doctorbagbase"] = {"hud/HudPlayerDowned.lua"},
	["lib/managers/hud/hudplayerdowned"] = {"hud/HudPlayerDowned.lua"},
	["lib/managers/menumanager"] = {"menu/CustomMenu.lua"}
}



function VoidUISBStandalone:Save()
	local file = io.open( self.options_path, "w+" )
	if file then
		file:write( json.encode( self.options ) )
		file:close()
	end
end
function VoidUISBStandalone:Load()
	local file = io.open( self.options_path, "r" )
	if file then
		self.options_temp = json.decode( file:read("*all") )
		file:close()
		for k,v in pairs(self.options_temp) do 
			self.options[k] = v 
		end
		self.options_temp = nil
	else
		VoidUISBStandalone:DefaultConfig()
		VoidUISBStandalone:Save()
	end
end
function VoidUISBStandalone:LoadTextures()
	for _, file in pairs(file.GetFiles(VoidUISBStandalone.mod_path.. "guis/textures/VoidUISBStandalone")) do
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/VoidUISBStandalone/".. file:gsub(".texture", "")), VoidUISBStandalone.mod_path.. "guis/textures/VoidUISBStandalone/".. file)
	end
end
Hooks:Add("LocalizationManagerPostInit", "VoidUI_Localization", function(loc)
	local loc_path = VoidUISBStandalone.mod_path .. "loc/"

	if file.DirectoryExists(loc_path) then
		if BLT.Localization._current == 'cht' or BLT.Localization._current == 'zh-cn' then
			loc:load_localization_file(loc_path .. "chinese.json")
		else
			for _, filename in pairs(file.GetFiles(loc_path)) do
				local str = filename:match('^(.*).json$')
				if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
					loc:load_localization_file(loc_path .. filename)
					break
				end
			end
		end
		loc:load_localization_file(loc_path .. "english.json", false)
	else
		log("Localization folder seems to be missing!")
	end
end)

function VoidUISBStandalone:DefaultConfig()
	VoidUISBStandalone.options = {
		hud_scale = 1,
		hud_main_scale = 1,
		hud_mate_scale = 1,
		hud_chat_scale = 1,
		scoreboard_scale = 1,
		hud_assault_scale = 1,
		hud_objectives_scale = 1,
		presenter_scale = 1,
		suspicion_scale = 1,
		interact_scale = 1,
		challanges_scale = 1,
		hint_scale = 1,
		label_scale = 1,
		waypoint_scale = 0.8,
		subtitle_scale = 0.9,
		joining_mods_scale = 1,
		voice_scale = 1,
		teammate_panels = true,
		enable_interact = true,
		enable_suspicion = true,
		enable_assault = true,
		enable_chat = true,
		enable_labels = true,
		enable_timer = true,
		enable_objectives = true,
		enable_presenter = true,
		enable_hint = true,
		enable_blackscreen = true,
		enable_stats = true,
		enable_subtitles = true,
		enable_challanges = true,
		enable_loadingscreen = true,
		enable_joining = true,
		enable_waypoints = true,
		enable_voice = true,
		loading_heistinfo = true,
		loading_players = true,
		loading_briefing = false,
		totalammo = true,
		main_loud = true,
		main_stealth = true,
		mate_loud = true,
		mate_stealth = true,
		mate_name = true,
		show_levelname = true,
		show_ghost_icon = true,
		show_badge = true,
		anim_badge = true,
		show_charactername = true,
		label_jokers = true,
		label_minmode = true,
		label_minrank = true,
		label_upper = false,
		mate_upper = false,
		label_waypoint_offscreen = true,
		chat_mouse = true,
		mate_interact = true,
		ammo_pickup = true,
		show_loot = true,
		hostages = true,
		pagers = true,
		outlines = true,
		health_jokers = true,
		show_interact = true,
		scoreboard_blur = true,
		scoreboard = true,
		scoreboard_accuracy = true,
		scoreboard_delay = false,
		scoreboard_character = true,
		scoreboard_skills = true,
		scoreboard_specials = true,
		scoreboard_civs = true,
		scoreboard_downs = true,
		scoreboard_weapons = true,
		scoreboard_armor = true,
		scoreboard_perk = true,
		scoreboard_playtime = true,
		scoreboard_ping = true,
		scoreboard_toggle = 1,
		save_warning = false,
		presenter_sound = false,
		hint_color = true,
		hint_anim = true,
		vape_hints = true,
		blackscreen_map = true,
		blackscreen_risk = true,
		blackscreen_skull = true,
		blackscreen_linger = true,
		scoreboard_maxlevel = true,
		joining_rank = true,
		joining_time = true,
		joining_border = true,
		joining_mods = false,
		joining_drawing = true,
		voice_name = true,
		joining_anim = 4,
		blackscreen_time = 0,
		scoreboard_skins = 2,
		scoreboard_kills = 3,
		show_objectives = 3,
		subtitles_bg = 2,
		show_timer = 3,
		ping_frequency = 2,
		jammers = 2,
		label_minscale = 1,
		hud_objective_history = 3,
		presenter_buffer = 5,
		label_minmode_dist = 7,
		label_minmode_dot = 1,
		chat_copy = 5,
		main_health = 2,
		mate_health = 2,
		mate_show = 3,
		chattime = 1,
		main_armor = 2,
		mate_armor = 1,
		assault_lines = 3,
		waypoint_radius = 200,
		suspicion_y = 160,
		interact_y = 40,
		main_anim_time = 0.2,
		mate_anim_time = 0.2,
		scoreboard_downs_no_reset = false
		--c_main_fg = {1,1,1}
	}
end

if not VoidUISBStandalone.loaded then
	VoidUISBStandalone.loaded = true
	VoidUISBStandalone:DefaultConfig()
	VoidUISBStandalone:Load()
	VoidUISBStandalone:LoadTextures()
end

function VoidUISBStandalone:GetColor(name)
	if VoidUISBStandalone.options[name] then
		local color = VoidUISBStandalone.options[name]
		return Color(unpack(color))
	else
		return Color.white
	end
end
Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_VoidUI", function(menu_manager, nodes)	
	MenuCallbackHandler.OpenVoidOptions = function(self, item)
		VoidUISBStandalone.Menu = VoidUISBStandalone.Menu or VoidUIMenu:new()
		VoidUISBStandalone.Menu:Open()
	end
	
	local node = nodes["blt_options"]

	local item_params = {
		name = "VoidUI_OpenMenu",
		text_id = "VoidUI_options_title",
		help_id = "VoidUI_options_desc",
		callback = "OpenVoidOptions",
		localize = true,
	}
	local item = node:create_item({type = "CoreMenuItem.Item"}, item_params)
    node:add_item(item)
	
	local menus = SystemFS:list(VoidUISBStandalone.mod_path.. "menu/")
	for i= 1, #menus do
		table.insert(VoidUISBStandalone.menus, VoidUISBStandalone.mod_path .. "menu/"..menus[i])
	end
end)

Hooks:PostHook(MenuManager, "update", "update_menu", function(self, t, dt)
	if VoidUISBStandalone.Menu and VoidUISBStandalone.Menu.update and VoidUISBStandalone.Menu._enabled then
		VoidUISBStandalone.Menu:update(t, dt)
	end
end)

if RequiredScript then
	local requiredScript = RequiredScript:lower()
		if VoidUISBStandalone.hook_files[requiredScript] then
			for _, file in ipairs(VoidUISBStandalone.hook_files[requiredScript]) do
			dofile( VoidUISBStandalone.mod_path .. "lua/" .. file )
		end
	end
end