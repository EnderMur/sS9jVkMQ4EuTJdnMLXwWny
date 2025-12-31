function CrimeSpreeTweakData:init_exclusion_data()
	self.excluded_enemies = {
		damage = table.list_to_set({}),
		health = table.list_to_set({})
	}
end