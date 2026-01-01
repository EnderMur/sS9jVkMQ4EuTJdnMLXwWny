Hooks:Add( "LocalizationManagerPostInit" , "veritasLocalization_spanish" , function( self )
	self:add_localized_strings({
        ["veritas_menuTitle"] 			= "Day/Night Changes"
		,["veritas_menuDesc"] 			= "¡Cambia los ciclos de día/noche para ciertos atracos!"
 
		,["veritas_env_default"] 			= "Por defecto"
		,["veritas_env_random"] 			= "Aleatorio"
		,["veritas_env_pd2_env_hox_02"] 	= "Mañana"
		,["veritas_env_pd2_env_morning_02"]	= "Amanecer"
		,["veritas_env_pd2_env_arm_hcm_02"]	= "Noche neblinosa"
		,["veritas_env_pd2_env_n2"] 		= "Noche"
 
		,["veritas_env_pd2_env_mid_day"] 		= "Mediodía"
		,["veritas_env_pd2_env_afternoon"] 		= "Tarde"
		,["veritas_env_pd2_env_foggy_bright"] 	= "Noche neblinosa brillante"
 
		--New Environments
		,["veritas_env_pd2_indiana_basement"] 	= "Día nublado"
		,["veritas_env_pd2_indiana_diamond_room"] 	= "Puesta de sol"
		,["veritas_env_env_cage_tunnels_02"] 	= "Soleado"
		,["veritas_env_mountain"] 	= "Montaña"
		,["veritas_env_forest_night"] 	= "Día en el bosque"
		,["veritas_env_docks"] 	= "Muelles"
		,["veritas_env_midday2"] 	= "Mediodía 2"
		,["veritas_env_evening"] 	= "Anochecer"
		,["veritas_env_night1"]		= "Noche 1"
		,["veritas_env_arena1"]		= "Arena 1"
		,["veritas_env_afternoon_edited"]		= "Tarde iluminada"
		,["veritas_env_breakfast_ext"] 			= "Desayuno en Tijuana Exterior"
		,["veritas_env_rvd_d1_ext"] = "Reservoir Dogs Día 1 Exterior"
		,["veritas_bex_ext"] = "San Martín Bank Exterior"
		,["veritas_wd2_unused"] = "Watchdogs Día 2 Unused"
		,["veritas_night_beta"] = "Night Beta"
 
		,["veritas_menu_unknow"]		= "Contratos desconocidos"
		,["veritas_Reset_all"]			= "Restablecer todo Día/Noche"
		,["veritasDesc_Resetall"]		= "Reestablece los valores predeterminados a cada mapa."
		,["veritas_override"]			= "Sobreescribir"
		,["veritasDesc_override"]		= "Esta opción sobreescribirá el Día/Noche de todos los mapas\nA menos que se establezca la opción 'Por defecto'."
		,["veritasID_disable_envs_change_title"] = "Deshabilitar cambios en entornos interiores"
		,["veritasID_disable_envs_change_desc"] = "Deshabilita los cambios de ambiente en interiores\nEj: habilitado en atracos con múltiples ambientes."
		,["random_blacklist_environment"] = "Lista de entornos aleatorios"
		,["random_blacklist_environment_desc"] = "Selecciona los entornos que quieres que aparezcan en la tabla de selección aleatoria."
		,["veritas_ResetRandom"] 			= "Restablecer tabla aleatoria"
	   ,["veritasDesc_ResetRandom"] 		= "Restablece la tabla aleatoria. Debe hacer esto si elimina un mod que contiene entornos personalizados para evitar fallas."
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