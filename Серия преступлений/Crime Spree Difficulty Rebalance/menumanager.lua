if not _G.CCSD then
	_G.CCSD = _G.CCSD or {}
	CCSD.recompensa_base = {20,25,40,50}
	CCSD._path = ModPath
	CCSD._data_path = SavePath .. "CCSD_options.txt"
	CCSD.settings = {}
	CCSD.Hooks = {
		["lib/tweak_data/crimespreetweakdata"] = "difficulty.lua",
	}

	function CCSD:Save()
		local file = io.open( self._data_path, "w" )
		if file then
			file:write( json.encode( self.settings ) )
			file:close()
		end
	end

	function CCSD:Load()
		local file = io.open( self._data_path, "r" )
		if file then
			self.settings = json.decode( file:read("*all") )
			file:close()
		end
	end

	CCSD:Load()

	Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_CCSD", function( loc )
		for _, filename in pairs(file.GetFiles(CCSD._path .. "loc/")) do
			local str = filename:match('^(.*).txt$')
			if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
				loc:load_localization_file(CCSD._path .. "loc/" .. filename)
				break
			end
		end

		loc:load_localization_file(CCSD._path .. "loc/english.txt", false)
	end)

	Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_CCSD", function( menu_manager )
		
		MenuCallbackHandler.CCSD_slider = function(self, item)
			CCSD.settings.CCSD_slider_value = item:value() or 1
			CCSD:Save()
		end

		CCSD:Load()
		MenuHelper:LoadFromJsonFile( CCSD._path .. "menu/options.txt", CCSD, CCSD.settings )
	end )


	function CCSD:ResetToDefaultValues()
			CCSD.settings.CCSD_slider_value = 1
	end

	if CCSD.settings.CCSD_slider_value == nil 
	then
		CCSD:ResetToDefaultValues()
	end

	if RequiredScript then
		local requiredScript = RequiredScript:lower()
		if CCSD.Hooks[requiredScript] then
			dofile( CCSD._path .. CCSD.Hooks[requiredScript] )
		end	
	end
end
