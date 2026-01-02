Hooks:Add( "LocalizationManagerPostInit" , "veritasLocalization_english" , function( self )
	self:add_localized_strings({
		 ["veritas_menuTitle"] 			= "Изменения дня/ночи"
		,["veritas_menuDesc"] 			= "Изменяйте циклы дня и ночи для определённых ограблений!"
		
		,["veritas_env_default"] 			= "По умолчанию"
		,["veritas_env_random"] 			= "Случайно"
		,["veritas_env_pd2_env_hox_02"] 	= "Раннее утро"
		,["veritas_env_pd2_env_morning_02"]	= "Утро"
		,["veritas_env_pd2_env_arm_hcm_02"]	= "Туманный вечер"
		,["veritas_env_pd2_env_n2"] 		= "Ночь"
		
		,["veritas_env_pd2_env_mid_day"] 		= "Полдень"
		,["veritas_env_pd2_env_afternoon"] 		= "Послеполуденное время"
		,["veritas_env_pd2_env_foggy_bright"] 	= "Туманный яркий вечер"

		--New Environments
		,["veritas_env_pd2_indiana_basement"] 	= "Туманный день"
		,["veritas_env_pd2_indiana_diamond_room"] 	= "Закат"
		,["veritas_env_env_cage_tunnels_02"] 	= "Солнечно"
		,["veritas_env_mountain"] 	= "Гора"
		,["veritas_env_forest_night"] 	= "Лесная ночь"
		,["veritas_env_docks"] 	= "Доки"
		,["veritas_env_midday2"] 	= "Полдень 2"
		,["veritas_env_evening"] 	= "Вечер"
		,["veritas_env_night1"]		= "Ночь 1"
		,["veritas_env_arena1"]		= "Арена 1"
		,["veritas_env_afternoon_edited"]		= "Послеполуденное время (светлее)"
		,["veritas_env_breakfast_ext"] 			= "Завтрак в Тихуане (экстерьер)"
		,["veritas_env_rvd_d1_ext"] = "Бешеные псы, день 1 (экстерьер)"
		,["veritas_bex_ext"] = "Банк Сан-Мартин (экстерьер)"
		,["veritas_wd2_unused"] = "Сторожевые псы, день 2 (неиспользуемый)"
		,["veritas_night_beta"] = "Ночь (бета)"
		
		,["veritas_menu_unknow"]		= "Неизвестные контракты"
		,["veritas_Reset_all"]			= "Сбросить все день/ночь"
		,["veritasDesc_Resetall"]		= "установить всё по умолчанию"
		,["veritas_override"]			= "переопределить"
		,["veritasDesc_override"]		= "Эта опция переопределит день/ночь для всех карт\nЕсли не установить по умолчанию."
		,["veritasID_disable_envs_change_title"] = "Отключить изменения окружения в помещениях"
		,["veritasID_disable_envs_change_desc"] = "Отключает изменения окружения в помещениях\nНапример, включите для ограблений с несколькими окружениями"
		,["random_blacklist_environment"] = "Список случайных окружений"
		,["random_blacklist_environment_desc"] = "Выберите окружения, которые хотите видеть в таблице случайного выбора"
		,["veritas_ResetRandom"] 			= "Сбросить таблицу случайных"
	   ,["veritasDesc_ResetRandom"] 		= "Сбрасывает таблицу случайных\nНужно сделать это, если вы удалите мод с кастомными окружениями, чтобы предотвратить краши"
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