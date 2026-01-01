veritasreborn = veritasreborn or 
{
	 mod_path 	= ModPath
	,save_path 	= SavePath .. "veritasrebornNew.lua"
	,main_menu 	= "veritas_menu"
	,veritas_random_table_menu = "veritas_random_table_menu"
	,options 	= { random_table = {} }
	,levels		= {}
	,levels_data= {}
	,contracts	= { ["unknow"] = 0 }
	,override_all_value = {}
    ,override_all = {}
	,exclude_form_random_env = {}
}

--[[
	https://github.com/hipe/lua-table-persistence
	Copyright (c) 2010 Gerhard Roethlin
]]

function load_localization_lua()
	local loc_path = veritasreborn.mod_path .. "loc/"

	if file.DirectoryExists(loc_path) then
		if BLT.Localization._current == 'pt-br' then
			-- dofile(loc_path .. "portuguese.lua")
		else
			for _, filename in pairs(file.GetFiles(loc_path)) do
				local str = filename:match('^(.*).lua$')
				if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
					dofile(loc_path .. filename)
					break
				else
					dofile(loc_path .. "english.lua")
				end
			end
		end
	else
		log("Localization folder seems to be missing!")
	end
end

load_localization_lua()

local write, writeIndent, writers, refCount;

persistence =
{
	store = function (path, ...)
		local file, e = io.open(path, "w");
		if not file then
			return error(e);
		end
		local n = select("#", ...);
		-- Count references
		local objRefCount = {}; -- Stores reference that will be exported
		for i = 1, n do
			refCount(objRefCount, (select(i,...)));
		end;
		-- Export Objects with more than one ref and assign name
		-- First, create empty tables for each
		local objRefNames = {};
		local objRefIdx = 0;
		file:write("-- Persistent Data\n");
		file:write("local multiRefObjects = {\n");
		for obj, count in pairs(objRefCount) do
			if count > 1 then
				objRefIdx = objRefIdx + 1;
				objRefNames[obj] = objRefIdx;
				file:write("{};"); -- table objRefIdx
			end;
		end;
		file:write("\n} -- multiRefObjects\n");
		-- Then fill them (this requires all empty multiRefObjects to exist)
		for obj, idx in pairs(objRefNames) do
			for k, v in pairs(obj) do
				file:write("multiRefObjects["..idx.."][");
				write(file, k, 0, objRefNames);
				file:write("] = ");
				write(file, v, 0, objRefNames);
				file:write(";\n");
			end;
		end;
		-- Create the remaining objects
		for i = 1, n do
			file:write("local ".."obj"..i.." = ");
			write(file, (select(i,...)), 0, objRefNames);
			file:write("\n");
		end
		-- Return them
		if n > 0 then
			file:write("return obj1");
			for i = 2, n do
				file:write(" ,obj"..i);
			end;
			file:write("\n");
		else
			file:write("return\n");
		end;
		if type(path) == "string" then
			file:close();
		end;
	end;

	load = function (path)
		local f, e;
		if type(path) == "string" then
			f, e = blt.vm.loadfile(path);
		else
			f, e = path:read('*a')
		end
		if f then
			return f();
		else
			return nil, e;
		end;
	end;
}

-- Private methods

-- write thing (dispatcher)
write = function (file, item, level, objRefNames)
	writers[type(item)](file, item, level, objRefNames);
end;

-- write indent
writeIndent = function (file, level)
	for i = 1, level do
		file:write("\t");
	end;
end;

-- recursively count references
refCount = function (objRefCount, item)
	-- only count reference types (tables)
	if type(item) == "table" then
		-- Increase ref count
		if objRefCount[item] then
			objRefCount[item] = objRefCount[item] + 1;
		else
			objRefCount[item] = 1;
			-- If first encounter, traverse
			for k, v in pairs(item) do
				refCount(objRefCount, k);
				refCount(objRefCount, v);
			end;
		end;
	end;
end;

-- Format items for the purpose of restoring
writers = {
	["nil"] = function (file, item)
			file:write("nil");
		end;
	["number"] = function (file, item)
			file:write(tostring(item));
		end;
	["string"] = function (file, item)
			file:write(string.format("%q", item));
		end;
	["boolean"] = function (file, item)
			if item then
				file:write("true");
			else
				file:write("false");
			end
		end;
	["table"] = function (file, item, level, objRefNames)
			local refIdx = objRefNames[item];
			if refIdx then
				-- Table with multiple references
				file:write("multiRefObjects["..refIdx.."]");
			else
				-- Single use table
				file:write("{\n");
				for k, v in pairs(item) do
					writeIndent(file, level+1);
					file:write("[");
					write(file, k, level+1, objRefNames);
					file:write("] = ");
					write(file, v, level+1, objRefNames);
					file:write(";\n");
				end
				writeIndent(file, level);
				file:write("}");
			end;
		end;
	["function"] = function (file, item)
			-- Does only work for "normal" functions, not those
			-- with upvalues or c functions
			local dInfo = debug.getinfo(item, "uS");
			if dInfo.nups > 0 then
				file:write("nil --[[functions with upvalue not supported]]");
			elseif dInfo.what ~= "Lua" then
				file:write("nil --[[non-lua function not supported]]");
			else
				local r, s = pcall(string.dump,item);
				if r then
					file:write(string.format("loadstring(%q)", s));
				else
					file:write("nil --[[function could not be dumped]]");
				end
			end
		end;
	["thread"] = function (file, item)
			file:write("nil --[[thread]]\n");
		end;
	["userdata"] = function (file, item)
			file:write("nil --[[userdata]]\n");
		end;
}

function veritasreborn:Load()
	local settings = persistence.load(self.save_path);
	if not settings then return end
	self.options = settings
	return settings
end

function veritasreborn:Save()
	persistence.store(self.save_path, self.options);
end
veritasreborn:Load()

function veritasreborn:LevelsByVal(fValue, tValue)
	if fValue == "all" then return self.levels end
	local levels = {}
	for k , v in pairs( self.levels_data or {} ) do
		if 		self.levels_data[k][fValue] == tValue 
		then	levels[v.level_id] = self.levels[v.level_id] end
	end
	if levels == {} then return nil end
	return levels
	--log(tostring(levels == {} and nil or levels))
	--return levels == {} and nil or levels
end

function veritasreborn:SetOptions(target, num, by)
	--if num == 1 then num = nil end
	local levels = target or {}
	if by == "contract" then levels = self:LevelsByVal("contact", target) 	end
	if by == "all"		then levels = self:LevelsByVal("all")				end
	
	for level_id, v in pairs( levels or {} ) do 
		self.options[level_id] = num
	end
	self:Save(veritasreborn.options)
	
	return levels
end

--------------------------------------------------------------------------------------------------------------

function GetTableValue(table,value)
	if table ~= nil then return table[value] end
	return nil
end

function ParseJob(data)
	for i , v in pairs( data.tables or {} ) do
		if v.level_id ~= nil then --log("level_id " ..tostring(v.level_id))
			--log("/ " .. v.level_id )
			veritasreborn.levels_data[ v.level_id ] = veritasreborn.levels_data[ v.level_id ] or 
			{
				 level_id 		= v.level_id
				,job_id 		= data.job_id
				,job_name_id	= GetTableValue(tweak_data.narrative.jobs[ data.job_id ], "name_id")
				,stage			= i + ( ( data.i and data.i - 1 ) or 0 )
				,contact		= GetTableValue(tweak_data.narrative.jobs[ data.job_id ], "contact") or "unknow"
			}
		elseif type(v) == "table" and v.level_id == nil then 
			ParseJob({ tables = v or {} , job_id = data.job_id , i = i })
		end
	end
end

function create_env_table()
    for k, v in pairs(tweak_data.veritas_environments_table) do
        veritasreborn.override_all_value[k] = v.text_id
		veritasreborn.override_all[k] = v.value
    end
    return veritasreborn.override_all_value, veritasreborn.override_all
end

function VeritasSet()
	local 	CustomLoaded = 0

	if veritasreborn.options.disable_envs_change == nil then
		veritasreborn.options.disable_envs_change = true
	end

	local normal2

	for g in pairs (veritasreborn.options.random_table or {}) do
        table.insert(veritasreborn.exclude_form_random_env, g)
    end

	normal2 = veritasreborn.exclude_form_random_env[ math.random( #veritasreborn.exclude_form_random_env ) ]
	
	for i , level_id in pairs( tweak_data.levels._level_index ) do
		-- Override Set
		if		tweak_data.levels[ level_id ] 
		and		veritasreborn.options[ "override" ] ~= nil
		and 	veritasreborn.options[ "override" ] >  1 then	
			if 	veritasreborn.options[ "override" ] == 2 then
				tweak_data.levels[ level_id ].env_params = { environment = normal2 }
				-- log(normal)
			else	tweak_data.levels[ level_id ].env_params = { environment = veritasreborn.override_all[ veritasreborn.options[ "override" ] or 1 ] } end
		--end
		-- set per map
		elseif	tweak_data.levels[ level_id ] 
		and		veritasreborn.options[ level_id ] ~= nil
		and 	veritasreborn.options[ level_id ] ~= 1 then
			if 	veritasreborn.options[ level_id ] == 2 then
				tweak_data.levels[ level_id ].env_params = { environment = normal2 }
			else	tweak_data.levels[ level_id ].env_params = { environment = veritasreborn.override_all[ veritasreborn.options[ level_id ] ] } end
					CustomLoaded = CustomLoaded + 1
			--log( "Custom Time Loaded: " .. level_id )
		end
	end
	if CustomLoaded > 0 then log( "/Custom Time Loaded: " .. tostring( CustomLoaded ) ) end
end
function VeritasInstant()
	if not managers.worlddefinition then
		return
	end
	
	local 	CustomLoaded = 0

	if veritasreborn.options.disable_envs_change == nil then
		veritasreborn.options.disable_envs_change = true
	end

	local normal2

	for k in pairs (veritasreborn.options.random_table or {}) do
        table.insert(veritasreborn.exclude_form_random_env, k)
    end

	normal2 = veritasreborn.exclude_form_random_env[ math.random( #veritasreborn.exclude_form_random_env ) ]  

	local heist_name = managers.job:current_level_id()
	
	for i , level_id in pairs( tweak_data.levels._level_index ) do
		-- Override Set
		if		tweak_data.levels[ level_id ] 
		and		veritasreborn.options[ "override" ] ~= nil
		and 	veritasreborn.options[ "override" ] >  1 then	
			if 	veritasreborn.options[ "override" ] == 2 then
				if normal2 then
					managers.worlddefinition:_set_environment(normal2)
				end
				-- log(normal)
			elseif veritasreborn.options[ "override" ] > 2 then
				local sel_override = veritasreborn.override_all[ veritasreborn.options[ "override" ] ]
				if sel_override then
					managers.worlddefinition:_set_environment(sel_override)
				end
			end
		--end
		-- set per map
		elseif	tweak_data.levels[ level_id ] 
		and		veritasreborn.options[ level_id ] ~= nil
		and 	veritasreborn.options[ level_id ] ~= 1 then
			if 	veritasreborn.options[ level_id ] == 2 then
				if heist_name == level_id and normal2 then
					managers.worlddefinition:_set_environment(normal2)
				end
			elseif veritasreborn.options[ level_id ] > 2 then
				local sel_env = veritasreborn.override_all[ veritasreborn.options[ level_id ] ]
				if heist_name == level_id then
					if sel_env then
						managers.worlddefinition:_set_environment(sel_env)
					end 
				end
			end
					CustomLoaded = CustomLoaded + 1
			--log( "Custom Time Loaded: " .. level_id )
		end
	end
	if CustomLoaded > 0 then log( "/Custom Time Loaded: " .. tostring( CustomLoaded ) ) end
end
function OverTex()
	if not Global.load_level then
		return
	end
	local level_id = Global.game_settings.level_id
	if level_id == "jerry" then -- Birth of Sky
	   managers.global_texture:set_texture("current_global_world_overlay_texture", "units/pd2_dlc_jerry/terrain/jry_terrain_df", "texture")
   elseif level_id == "peta2" then -- Goat Simulator Day 2
	   managers.global_texture:set_texture("current_global_world_overlay_texture", "environments/world_textures/peta/pta_terrain_overlay_df", "texture")
   elseif level_id == "ranc" then -- MidLand Ranch
	   managers.global_texture:set_texture("current_global_world_overlay_texture", "units/pd2_dlc_ranc/architecture/ext/ranc_ext_ground/ranc_terrain_playable_df", "texture")
   elseif level_id == "trai" then -- Lost In Transit
	   managers.global_texture:set_texture("current_global_world_overlay_texture", "units/pd2_dlc_trai/architecture/ext/ext_textures/ground/trai_ext_ground_terrain_df", "texture")
   end
end
function OverMask()
	if not Global.load_level then
		return
	end
	local level_id = Global.game_settings.level_id
   if level_id == "jerry" then -- Birth of Sky
	   managers.global_texture:set_texture("global_world_overlay_mask_texture", "units/pd2_dlc_jerry/terrain/jry_terrain_weight_df", "texture")
   elseif level_id == "peta2" then -- Goat Simulator Day 2
	   managers.global_texture:set_texture("global_world_overlay_mask_texture", "environments/world_textures/peta/pta_terrain_weight_df", "texture")
   elseif level_id == "ranc" then -- MidLand Ranch
	   managers.global_texture:set_texture("global_world_overlay_mask_texture", "units/pd2_dlc_ranc/architecture/ext/ranc_ext_ground/ranc_terrain_playable", "texture")
   elseif level_id == "trai" then -- Lost In Transit
	   managers.global_texture:set_texture("global_world_overlay_mask_texture", "units/pd2_dlc_trai/architecture/ext/ext_textures/ground/trai_ext_ground_terrain", "texture")
   end
end
--[[
function PrintTableNameList(table)
	for k , v in pairs(table) do
		log("/ " .. tostring(k) .. " /// " .. tostring(v) )
	end
end
--]]
	
-------------------------------------------------------------------------------------------------------------------
--managers.menu:open_node(veritasreborn.main_menu .. "_" .. type)
Hooks:Add("MenuManagerInitialize", "tDNCF_MMI", function(menu_manager)
	MenuCallbackHandler.DNF_Close_Options 	= function(self)
		--log("// DNF_Close_Options")
		VeritasSet()
		VeritasInstant()
	end
	MenuCallbackHandler.DNF_Config_Reset 	= function(self, item) 	
		local type = item:name():sub(string.len("veritasID_Reset_") + 1)
		
		local levels = {}
		if   type == "all" 
		then levels = veritasreborn:SetOptions({}	 , 1, "all")
		else levels = veritasreborn:SetOptions(type, 1, "contract") end
		
		levels["override"] = ""
		
		if type == "all" then
			for k , v in pairs( veritasreborn.contracts or {} ) do 
				local menu = MenuHelper:GetMenu( veritasreborn.main_menu .. "_" .. k )
				ResetItems(menu, levels, 1)
			end
		end
		
		local menu_id = type == "all" and veritasreborn.main_menu or veritasreborn.main_menu .. "_" .. type
		local menu = MenuHelper:GetMenu( menu_id )
		
		ResetItems(menu, levels, 1)
	end

	MenuCallbackHandler.veritas_resetrandomtable = function(self, item)
		veritasreborn.options.random_table = {}
		veritasreborn:Save()
	end
	
	function ResetItems(menu, items, value)
		for k , v in pairs( items or {} ) do 
			local item = menu:item("veritasID_" .. k)
			if   item 
			then item._current_index = value or 1
				 item:dirty()
			end--item:set_enabled(false)
		end
	end
	
	MenuCallbackHandler.DNF_ValueSet 		= function(self, item)
		veritasreborn.options[ item:name():sub(11) ] = item:value()
		VeritasSet()
		VeritasInstant()
		veritasreborn:Save()
	end

	MenuCallbackHandler.DNF_disable_envs_change 		= function(self, item)
		veritasreborn.options.disable_envs_change = item:value() == "on" and true or false
		veritasreborn:Save()
	end

	veritasreborn:Load()

end)

Hooks:Add("MenuManagerSetupCustomMenus", "tDNCF_MMSC", function( menu_manager, nodes )
	MenuHelper:NewMenu( veritasreborn.main_menu )
	MenuHelper:NewMenu( veritasreborn.main_menu .. "_unknow" )
	MenuHelper:NewMenu( veritasreborn.veritas_random_table_menu )
	
	for k , v in pairs( tweak_data.narrative.contacts ) do 
		veritasreborn.contracts[k] = 0
		MenuHelper.menus = MenuHelper.menus or {}

		local new_menu = deep_clone( MenuHelper.menu_to_clone )
		-- local new_menu = deep_clone( MenuHelper.menus[veritasreborn.main_menu] )
		new_menu._items = {}
		MenuHelper.menus[veritasreborn.main_menu .. "_" .. k] = new_menu
	end
end)

function create_random_env_table()
    for k, v in pairs(tweak_data.veritas_environments_table) do
        veritasreborn.override_all_value[k] = v.text_id
		veritasreborn.override_all[k] = v.value
    end
    return veritasreborn.override_all,veritasreborn.override_all_value
end

Hooks:Add("MenuManagerPopulateCustomMenus", "PopulateCustomMenus_VeritasRandomTable", function(menu_manager, nodes)
	MenuCallbackHandler.veritas_selected_random = function(self, item)
		veritasreborn.options.random_table[item:name()] = (item:value() == "on") or nil
		veritasreborn:Save()
	end
	
	veritasreborn:Load()
	
	for k, v in pairs(create_random_env_table()) do
		local random_env_prefix = "" 
        local random_env = v
		local get_environments_ids = random_env:gsub('[.].-$', ''):gsub('^[0-9]-environments/', '')
		-- if string.match(random_env, "veritas_env_") then
		-- 	get_environments_ids = get_environments_ids:gsub('_', ' ')
		-- end
		-- if managers.localization:exists("veritas_env_" .. random_env) then
		-- 	random_env_prefix = managers.localization:text("veritas_env_" .. random_env)
		-- end
		MenuHelper:AddToggle({
			id = random_env,
			title = get_environments_ids:gsub('_', ' '),
			desc = "Select the environments you want to appear in the random selection table",
			callback = "veritas_selected_random",
			menu_id = veritasreborn.veritas_random_table_menu,
			value = veritasreborn.options.random_table[random_env] or nil,
			localized = false
		})
	end
end)

Hooks:Add("MenuManagerBuildCustomMenus", "tDNCF_MMBCM", function( menu_manager, nodes )
	MenuHelper:AddButton({
		id 			= "veritasID_Reset_Random",
		title 		= "veritas_ResetRandom",
		desc 		= "veritasDesc_ResetRandom",
		callback 	= "veritas_resetrandomtable",
		menu_id 	= veritasreborn.veritas_random_table_menu,
		priority 	= 1,
		localized	= true
	})

	MenuHelper:AddDivider({ id = "veritasID_divider_main2", size = 20, menu_id = veritasreborn.veritas_random_table_menu })
	
	MenuHelper:AddButton({
		id 			= "veritasID_Reset_all",
		title 		= "veritas_Reset_all",
		desc 		= "veritasDesc_Resetall",
		callback 	= "DNF_Config_Reset",
		menu_id 	= veritasreborn.main_menu,
		priority 	= 100,
		localized	= true
	})
	
	MenuHelper:AddMultipleChoice( {
		id 			= "veritasID_override",
		title 		= "veritas_override",
		desc 		= "veritasDesc_override",
		callback 	= "DNF_ValueSet",
		items 		= create_env_table(),
		menu_id 	= veritasreborn.main_menu,
		value 		= veritasreborn.options[ "override" ] or 1,
		priority 	= 99,
		localized	= true
	})

	MenuHelper:AddToggle({
		id       = "veritasID_disable_envs_change",
		title    = "veritasID_disable_envs_change_title",
		desc     = "veritasID_disable_envs_change_desc",
		callback = "DNF_disable_envs_change",
		value    = veritasreborn.options.disable_envs_change,
		menu_id  = veritasreborn.main_menu,
		priority = 98,
		localized	= true
	})
	
	MenuHelper:AddDivider({ id = "veritasID_divider_main", size = 20, menu_id = veritasreborn.main_menu, priority = 98 })
	
	for level_id , name_id in pairs( veritasreborn.levels ) do
		local contract	= GetTableValue(veritasreborn.levels_data[ level_id ],"contact") or "unknow"
		local menu_id 	= veritasreborn.main_menu .. "_" .. contract
		
		veritasreborn.contracts[contract] = true
		
		MenuHelper:AddMultipleChoice( {
			id 			= "veritasID_" 		.. level_id,
			title 		= "veritas_" 		.. level_id,
			desc 		= "veritasDesc_" 	.. level_id,
			callback 	= "DNF_ValueSet",
			items 		= create_env_table(),
			menu_id 	= menu_id,
			value 		= veritasreborn.options[ level_id ] or 1,
			localized	= true
		} )
	end
	
	nodes[veritasreborn.main_menu] = 
		MenuHelper:BuildMenu	( veritasreborn.main_menu, { area_bg = "none" } )  
		MenuHelper:AddMenuItem	( nodes.blt_options, veritasreborn.main_menu, "veritas_menuTitle", "veritas_menuDesc")
	
	for k , v in pairs( veritasreborn.contracts ) do
		if v == true then
			local menu_id = veritasreborn.main_menu .. "_" .. k
			
			MenuHelper:AddButton({
				id 			= "veritasID_Reset_" 	.. k,
				--title 		= "veritas_Reset_" 		.. k,
				--desc 		= "veritasDesc_Reset_" 	.. k,
				title 		= "veritas_Reset_all",
				desc 		= "veritasDesc_Resetall",
				callback 	= "DNF_Config_Reset",
				menu_id 	= menu_id,
				priority 	= 100,
				localized	= true
			})
			
			MenuHelper:AddDivider({ id = "veritasID_divider_" .. k, size = 20, menu_id = menu_id,priority = 99 })
			
			nodes[menu_id] = 
			MenuHelper:BuildMenu	( menu_id, { area_bg = "half" } )  
			MenuHelper:AddMenuItem	( nodes[veritasreborn.main_menu], menu_id, menu_id, "veritas_menuDesc")
		end
	end

	nodes[veritasreborn.veritas_random_table_menu] = MenuHelper:BuildMenu( veritasreborn.veritas_random_table_menu )
	MenuHelper:AddMenuItem( nodes[veritasreborn.main_menu], veritasreborn.veritas_random_table_menu, "random_blacklist_environment", "random_blacklist_environment_desc" )
end)

-- local english = Idstring("english"):key() == SystemInfo:language():key()
-- local spanish = Idstring("spanish"):key() == SystemInfo:language():key()

-- local mod_path = tostring(veritasreborn.mod_path)

-- if english then
--     dofile(ModPath .. "loc/english.lua")
-- elseif spanish then
--     dofile(ModPath .. "loc/spanish.lua")
-- else
-- 	dofile(ModPath .. "loc/english.lua")
-- end

--------------------------------------------------------------------------------------------------------------
if not PackageManager:loaded("packages/skiesnewpack") then
	PackageManager:load("packages/skiesnewpack")
end

Hooks:Add("BeardLibCreateScriptDataMods", "VeritasCallBeardLibSequenceFuncs", function()
	local mod_path = tostring(veritasreborn.mod_path)
	
	BeardLib:ReplaceScriptData(mod_path .. "assets/environments/earlymorning.environment", "custom_xml", "environments/early_morning", "environment", true)
	BeardLib:ReplaceScriptData(mod_path .. "assets/environments/morning.environment", "custom_xml", "environments/morning", "environment", true)
	BeardLib:ReplaceScriptData(mod_path .. "assets/environments/foggyevening.environment", "custom_xml", "environments/foggy_evening", "environment", true)
	BeardLib:ReplaceScriptData(mod_path .. "assets/environments/night.environment", "custom_xml", "environments/night", "environment", true)
	BeardLib:ReplaceScriptData(mod_path .. "assets/environments/midday.environment", "custom_xml", "environments/mid_day", "environment", true)
	BeardLib:ReplaceScriptData(mod_path .. "assets/environments/afternoon.environment", "custom_xml", "environments/afternoon", "environment", true)
	BeardLib:ReplaceScriptData(mod_path .. "assets/environments/foggybrightevening.environment", "custom_xml", "environments/foggy_bright_evening", "environment", true)
	BeardLib:ReplaceScriptData(mod_path .. "assets/environments/foggyday.environment", "custom_xml", "environments/foggy_day", "environment", true)
	BeardLib:ReplaceScriptData(mod_path .. "assets/environments/sunset.environment", "custom_xml", "environments/sunset", "environment", true)
	BeardLib:ReplaceScriptData(mod_path .. "assets/environments/sunny.environment", "custom_xml", "environments/sunny", "environment", true)
	BeardLib:ReplaceScriptData(mod_path .. "assets/environments/mountain.environment", "custom_xml", "environments/mountain", "environment", true)
	BeardLib:ReplaceScriptData(mod_path .. "assets/environments/forestnight.environment", "custom_xml", "environments/forest_night", "environment", true)
	BeardLib:ReplaceScriptData(mod_path .. "assets/environments/docks.environment", "custom_xml", "environments/docks", "environment", true)
	BeardLib:ReplaceScriptData(mod_path .. "assets/environments/midday2.environment", "custom_xml", "environments/mid_day_2", "environment", true)
	BeardLib:ReplaceScriptData(mod_path .. "assets/environments/evening.environment", "custom_xml", "environments/evening", "environment", true)
	BeardLib:ReplaceScriptData(mod_path .. "assets/environments/night1.environment", "custom_xml", "environments/night_1", "environment", true)
	BeardLib:ReplaceScriptData(mod_path .. "assets/environments/arena1.environment", "custom_xml", "environments/alesso_arena", "environment", true)
	BeardLib:ReplaceScriptData(mod_path .. "assets/environments/afternoon_edited.environment", "custom_xml", "environments/afternoon_edited", "environment", true)
	BeardLib:ReplaceScriptData(mod_path .. "assets/environments/breakfast_ext.environment", "custom_xml", "environments/breakfast_ext", "environment", true)
	BeardLib:ReplaceScriptData(mod_path .. "assets/environments/rvd_d1_ext.environment", "custom_xml", "environments/rvd_d1_ext", "environment", true)
	BeardLib:ReplaceScriptData(mod_path .. "assets/environments/bex_ext.environment", "custom_xml", "environments/bex_ext", "environment", true)
	BeardLib:ReplaceScriptData(mod_path .. "assets/environments/wd2_unused.environment", "custom_xml", "environments/wd2_unused", "environment", true)
	BeardLib:ReplaceScriptData(mod_path .. "assets/environments/night_beta.environment", "custom_xml", "environments/night_beta", "environment", true)
end)