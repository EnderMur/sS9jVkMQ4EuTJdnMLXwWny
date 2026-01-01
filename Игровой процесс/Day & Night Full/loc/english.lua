Hooks:Add( "LocalizationManagerPostInit" , "veritasLocalization_english" , function( self )
	self:add_localized_strings({
		 ["veritas_menuTitle"] 			= "Day/Night Changes"
		,["veritas_menuDesc"] 			= "Change the day/night cycles for certain heists!"
		
		,["veritas_env_default"] 			= "Default"
		,["veritas_env_random"] 			= "Random"
		,["veritas_env_pd2_env_hox_02"] 	= "Early Morning"
		,["veritas_env_pd2_env_morning_02"]	= "Morning"
		,["veritas_env_pd2_env_arm_hcm_02"]	= "Foggy Evening"
		,["veritas_env_pd2_env_n2"] 		= "Night"
		
		,["veritas_env_pd2_env_mid_day"] 		= "Mid Day"
		,["veritas_env_pd2_env_afternoon"] 		= "AfterNoon"
		,["veritas_env_pd2_env_foggy_bright"] 	= "Foggy Bright Evening"

		--New Environments
		,["veritas_env_pd2_indiana_basement"] 	= "Foggy Day"
		,["veritas_env_pd2_indiana_diamond_room"] 	= "Sunset"
		,["veritas_env_env_cage_tunnels_02"] 	= "Sunny"
		,["veritas_env_mountain"] 	= "Mountain"
		,["veritas_env_forest_night"] 	= "Forest Night"
		,["veritas_env_docks"] 	= "Docks"
		,["veritas_env_midday2"] 	= "Mid Day 2"
		,["veritas_env_evening"] 	= "Evening"
		,["veritas_env_night1"]		= "Night 1"
		,["veritas_env_arena1"]		= "Arena 1"
		,["veritas_env_afternoon_edited"]		= "Afternoon Lighter"
		,["veritas_env_breakfast_ext"] 			= "Breakfast in Tijuana Exterior"
		,["veritas_env_rvd_d1_ext"] = "Reservoir Dogs Day 1 Exterior"
		,["veritas_bex_ext"] = "San Martín Bank Exterior"
		,["veritas_wd2_unused"] = "Watchdogs Day 2 Unused"
		,["veritas_night_beta"] = "Night Beta"
		
		,["veritas_menu_unknow"]		= "Unknown Contracts"
		,["veritas_Reset_all"]			= "Reset All DayNight"
		,["veritasDesc_Resetall"]		= "set all to default"
		,["veritas_override"]			= "override"
		,["veritasDesc_override"]		= "This option will override all map's Day/Night\nUnless set it to default."
		,["veritasID_disable_envs_change_title"] = "Disable Indoors Environment Changes"
		,["veritasID_disable_envs_change_desc"] = "Disables the indoor environment changes\nEx enable on heists with multiple environments"
		,["random_blacklist_environment"] = "Random Environment List"
		,["random_blacklist_environment_desc"] = "Select the environments you want to appear in the random selection table"
		,["veritas_ResetRandom"] 			= "Reset Random Table"
	   ,["veritasDesc_ResetRandom"] 		= "Resets the random table\nYou need to do this if you remove a mod that contains custom environments to prevent crashing"
	})
	
		for job_id , v in pairs( tweak_data.narrative.jobs ) do 
			for i , job_id2 in pairs( tweak_data.narrative.jobs[job_id].job_wrapper or {} ) do
				if tweak_data.narrative.jobs[ job_id2 ].name_id == nil then 
					ParseJob({ tables = tweak_data.narrative.jobs[job_id2].chain or {} , job_id = job_id })
				end
			end
		end
		
		for job_id , v in pairs( tweak_data.narrative.jobs ) do 
			ParseJob({ tables = tweak_data.narrative.jobs[job_id].chain or {} , job_id = job_id })
		end

		local 	CustomLoaded = 0
			for i , level_id in pairs( tweak_data.levels._level_index ) do
				-- Get levels id
				if 		tweak_data.levels[ level_id ] 
				and 	tweak_data.levels[ level_id ].name_id 
				--and not self[ level_id ].env_params 
				then	veritasreborn.levels[ level_id ] = tweak_data.levels[ level_id ].name_id end
			end
		
	VeritasSet()
	--tweak_data.levels[ level_id ].name_id
	
	for k , v in pairs( tweak_data.narrative.contacts ) do 
		self:add_localized_strings({ [veritasreborn.main_menu .. "_" .. k] = k:gsub('_', ' ') .. " Contracts" })
	end


	
	for level_id , name_id in pairs( veritasreborn.levels ) do 
		if veritasreborn.levels_data[ level_id ] then
			local job_name_id 	= veritasreborn.levels_data[ level_id ].job_name_id 	or ""
			local stage			= veritasreborn.levels_data[ level_id ].stage			or 0
			local LocText		= level_id
			local LocTextFull	= self:text(job_name_id)
			
			if Localizer:exists(Idstring(job_name_id)) then LocText = Localizer:lookup(Idstring(job_name_id)) end
			LocText = LocText .. " [" .. stage .. "]"
			
			self:add_localized_strings({ 
				 ["veritas_"		.. level_id] = LocText
				,["veritasDesc_" 	.. level_id] = level_id .. " :level_id\n" .. LocTextFull
			}) 
			
			--log("/ " .. level_id .. " //* " .. tostring(job_name_id) .. " */ " .. LocText)
		else
			self:add_localized_strings({ 
				 ["veritas_"		.. level_id] = level_id .. " [?]"
				,["veritasDesc_" 	.. level_id] = level_id .. " : unknow"
			}) 
		end
	end
end )