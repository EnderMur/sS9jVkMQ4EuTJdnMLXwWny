local old_init = CrimeSpreeTweakData.init

function CrimeSpreeTweakData:init(tweak_data)
	old_init(self, tweak_data)
	if CCSD.settings.CCSD_slider_value == 2 then
		self.base_difficulty = "easy_wish"	
	elseif CCSD.settings.CCSD_slider_value == 3 then
		self.base_difficulty = "overkill_290"	
	elseif CCSD.settings.CCSD_slider_value == 4 then
		self.base_difficulty = "sm_wish"	
	else
		self.base_difficulty = "overkill_145"
	end
end

Hooks:PostHook(CrimeSpreeTweakData,"init_missions", "CrimeSpreeRebalance_HOOK", function(self, tweak_data)
	if not _G.MHiCS then
		for i,v in pairs(self.missions) do
			for i2,v in pairs(self.missions[i]) do
				if self.missions[i][i2].add then
					self.missions[i][i2].add = CCSD.recompensa_base[CCSD.settings.CCSD_slider_value]
				end
			end
		end
	end
end)
