TheFixesPreventer = TheFixesPreventer or {}

local thisPath
local thisDir
local upDir
local function Dirs()
	thisPath = debug.getinfo(2, "S").source:sub(2)
	thisDir = string.match(thisPath, '.*/')
	upDir = thisDir:match('(.*/).-/')
end
Dirs()
Dirs = nil

-- This stores keys and values provided by other mods
local existed_before = {}
for k,v in pairs(TheFixesPreventer) do
	existed_before[k] = v
end
local toggled_by_user = {} -- This stores the changes user made during this menu 'session'

local loaded_result = {} -- Save file contents, used later on
local function LoadSettings()
	local file = io.open(SavePath .. 'The Fixes Preventer.txt', "r")
	if file then
		loaded_result = json.decode(file:read("*all"))
		file:close()
	end
	TheFixesPreventerLanguage = loaded_result.language or 1
	loaded_result.language = nil
end
LoadSettings()

local function SaveSettings()
	local data = {}
	for k,v in pairs(TheFixesPreventer or {}) do
		data[k] = v
	end
	for k,v in pairs(existed_before) do
		if loaded_result[k] == nil then
			if toggled_by_user[k] == nil then
				data[k] = nil
			else
				data[k] = toggled_by_user[k]
			end
		end
	end
	data.language = TheFixesPreventerLanguage or 1
	local file = io.open(SavePath .. 'The Fixes Preventer.txt', "w")
	if file then
		file:write(json.encode(data))
		file:close()
	end
end

local _languages = { 'blt', 'en', 'cn' }
local function GetBestLanguageCode()
	local lang = 'en'

	if not TheFixesPreventerLanguage then
		TheFixesPreventerLanguage = 1
	end

	if _languages[TheFixesPreventerLanguage] and _languages[TheFixesPreventerLanguage] == 'blt' then
		if BLT and BLT.Localization and BLT.Localization.get_language then
			lang = BLT.Localization:get_language().language or 'en'
		end

		if BLT and BLT.Mods and BLT.Mods.GetMod and BLT.Mods:GetMod('PD2TH') then
			lang = 'th'
		end
		
		if lang == 'cht' or lang == 'zh-cn' then
			lang = 'cn'
		end
	else
		lang = _languages[TheFixesPreventerLanguage] or 'en'
	end

	return lang or 'en'
end

local function TryLoadLocFile(filename)
	local f,err = io.open(filename, 'r')
	if f then
		f:close()
		dofile(filename)
		return true
	end
	return false
end

local function LoadLoc()
	local lang = GetBestLanguageCode()
	if not TryLoadLocFile(thisDir .. 'loc/' .. lang .. '.lua') then
		TryLoadLocFile(thisDir .. 'loc/en.lua')
	end
	TheFixesPreventerLoc = TheFixesPreventerLoc or {}
	LocalizationManager:add_localized_strings({
		the_fixes_preventer = TheFixesPreventerLoc.name or 'The Fixes Preventer',
		the_fixes_crashes = TheFixesPreventerLoc.crashes or 'Crashes',
		the_fixes_heists = TheFixesPreventerLoc.heists or 'Heists',
		the_fixes_achievements = TheFixesPreventerLoc.achievements or 'Achievements',
		the_fixes_readme = TheFixesPreventerLoc.readme or 'Read Me',
		the_fixes_status = TheFixesPreventerLoc.status or 'Status',
		the_fixes_other = TheFixesPreventerLoc.other or 'Other'
	})
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_TheFixesPreventer", function()
	LoadLoc()
	local langNamesFile = thisDir .. 'loc/lang_names.json'
	local f,err = io.open(langNamesFile, 'r')
	if f then
		f:close()
		LocalizationManager:load_localization_file(langNamesFile)
	end
end)

local preventer_disabled = false
local run_hook_file_orig = BLT.RunHookFile
function BLT:RunHookFile(path, hook_data, ...)
	if preventer_disabled then
		return run_hook_file_orig(BLT, path, hook_data, ...)
	end

	local blt_mod = hook_data and hook_data.mod and hook_data.mod._blt_mod ~= false and hook_data.mod.GetName

	local the_fixes = false
	if blt_mod then
		the_fixes = hook_data.mod:GetName() == 'The Fixes'
	end

	if the_fixes then
		TheFixesPreventer = TheFixesPreventer or {}
		for k,v in pairs(existed_before) do
			TheFixesPreventer[k] = v
		end
		for k,v in pairs(loaded_result or {}) do
			TheFixesPreventer[k] = v
		end
	else
		TheFixesPreventer = nil
	end

	run_hook_file_orig(BLT, path, hook_data, ...)

	if not the_fixes and TheFixesPreventer then
		for k,v in pairs(TheFixesPreventer) do
			existed_before[k] = v
		end
	end
	TheFixesPreventer = nil
end

local function CreateSubMenus()
	local menu_by_prefix = {
		achi = 'the_fixes_preventer_opt_achievements',
		heist = 'the_fixes_preventer_opt_heists',
		crash = 'the_fixes_preventer_opt_crashes',
		crashes = 'the_fixes_preventer_opt_crashes'
	}

	for k, v in pairs(menu_by_prefix) do
		local m = MenuHelper:GetMenu(v)
		if m then
			m._items_list = {}
			m:clean_items()
		end
	end

	local otherMenu = MenuHelper:GetMenu('the_fixes_preventer_opt_other')
	if otherMenu then
		otherMenu._items_list = {}
		otherMenu:clean_items()
	end

	for k,v in pairs(TheFixesPreventerFixes or {}) do
		if k ~= 'language' then
			local menu = 'the_fixes_preventer_opt_other'
			local prefix = k:match('^[^_]+')
			menu = menu_by_prefix[prefix] or menu

			MenuHelper:AddToggle({
									id = k,
									title = k:gsub('_',' '),
									desc = v,
									callback = 'the_fixes_preventer_toggle',
									value = TheFixesPreventer[k] or false,
									default_value = false,
									menu_id = menu,
									localized = false
								})
		end
	end

	-- In normal BLT 'localized' value (4 lines above) does not affect description
	if not BLTSuperMod then
		menu_by_prefix.other = 'the_fixes_preventer_opt_other'
		for k,v in pairs(menu_by_prefix) do
			local menu_msgs = MenuHelper:GetMenu(v)
			for k2,v2 in pairs(menu_msgs._items_list or {}) do
				v2:set_parameter('localize_help', false)
			end
		end
	end

	menu_by_prefix.other = 'the_fixes_preventer_opt_other'
	for k, v in pairs(menu_by_prefix) do
		MenuHelper:BuildMenu(v)
	end
end

local function CreateCallbacks()
	function MenuCallbackHandler:the_fixes_preventer_toggle(item)
		local index = item._parameters.name
		if TheFixesPreventer then
			local val = item:value() == 'on'
			toggled_by_user[index] = val
			TheFixesPreventer[index] = val and true or nil -- TFP only stores prevented (true) keys
		end
	end

	function MenuCallbackHandler:the_fixes_preventer_save()
		SaveSettings()
		toggled_by_user = {}
	end

	function MenuCallbackHandler:the_fixes_preventer_show_read_me()
		TheFixesPreventerLoc = TheFixesPreventerLoc or {}
		QuickMenu:new(
					TheFixesPreventerLoc.name or 'The Fixes Preventer',
					TheFixesPreventerLoc.readme_text or 'If a fix entry is ticked that means that the fix won\'t be loaded.\nUnticked state means that the fix will be loaded.\n\nIf an entry is ticked and you didn\'t tick it then the relevant fix was disabled by another mod.',
					 {{text = TheFixesPreventerLoc.ok or 'OK', is_cancel_button = true}}
			):Show()
	end

	function MenuCallbackHandler:the_fixes_preventer_status()
		TheFixesPreventerLoc = TheFixesPreventerLoc or {}
		LoadSettings()
		local message = ''
		local have_new = false
		for k,v in pairs(existed_before) do
			if v then
				message = message..'\n'..k
				have_new = true
			end
		end
		if have_new then
			message = (TheFixesPreventerLoc.disabled_by_other_mods or 'Disabled by other mods:')..message..'\n\n'
		end
		have_new = false
		local message2 = ''
		for k,v in pairs(toggled_by_user) do
			message2 = message2..'\n'..k..' --> '..(v and 'true' or 'false')
			have_new = true
		end
		if have_new then
			message2 = (TheFixesPreventerLoc.changed_now or 'Changed just now:')..message2..'\n\n'
			message = message..message2
		end
		have_new = false
		message2 = ''
		for k,v in pairs(loaded_result or {}) do
			message2 = message2..'\n'..k..' = '..(v and 'true' or 'false')
			have_new = true
		end
		if have_new then
			message2 = (TheFixesPreventerLoc.save_file or 'Save file:')..message2..'\n\n'
			message = message..message2
		end
		if message == '' then
			message = TheFixesPreventerLoc.all_enabled or 'Everything is enabled. All of The Fixes will be loaded.'
		end
		QuickMenu:new(
					TheFixesPreventerLoc.name or 'The Fixes Preventer',
					message,
					 {{text = TheFixesPreventerLoc.ok or 'OK', is_cancel_button = true}}
			):Show()
	end

	function MenuCallbackHandler:the_fixes_preventer_language(item)
		TheFixesPreventerLanguage = item:value() or 1
		LoadLoc()
		CreateSubMenus()
		managers.menu:back()
		managers.menu:open_node('the_fixes_preventer_opt')
	end
end

TheFixesPreventerFinalize = function()
	preventer_disabled = true
	TheFixesPreventer = {}
	for k,v in pairs(existed_before) do
		TheFixesPreventer[k] = v
	end
	for k,v in pairs(loaded_result or {}) do
		TheFixesPreventer[k] = v
	end
end

Hooks:Add("MenuManagerPostInitialize", "MenuManagerPostInitialize_TheFixesPreventer", function( menu_manager )
	CreateCallbacks()
	MenuHelper:LoadFromJsonFile(thisDir .. 'main.json', TheFixesPreventer, TheFixesPreventer)
	MenuHelper:LoadFromJsonFile(thisDir .. 'crashes.json', TheFixesPreventer, TheFixesPreventer)
	MenuHelper:LoadFromJsonFile(thisDir .. 'achievements.json', TheFixesPreventer, TheFixesPreventer)
	MenuHelper:LoadFromJsonFile(thisDir .. 'heists.json', TheFixesPreventer, TheFixesPreventer)
	MenuHelper:LoadFromJsonFile(thisDir .. 'other.json', TheFixesPreventer, TheFixesPreventer)
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "PopulateCustomMenus_TheFixesPreventer", function( menu_manager, nodes )
	local languageItems = {}
	for k,v in pairs(_languages) do
		languageItems[k] = 'the_fixes_preventer_lang_name_'..v
	end
	MenuHelper:AddMultipleChoice({
		id = 'language',
		title = 'LANGUAGE',
		desc = 'Set the prefered mod language',
		callback = 'the_fixes_preventer_language',
		items = languageItems,
		value = TheFixesPreventerLanguage or 1,
		default_value = 1,
		menu_id = 'the_fixes_preventer_opt',
		localized = false,
		priority = 100
	})

	CreateSubMenus()
end)
