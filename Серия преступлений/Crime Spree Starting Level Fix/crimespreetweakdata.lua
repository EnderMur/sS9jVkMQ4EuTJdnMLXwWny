local old_init = CrimeSpreeTweakData.init
function CrimeSpreeTweakData:init(tweak_data)
	old_init(self, tweak_data)
	self.initial_cost = 6
	self.cost_per_level = 0.7
end