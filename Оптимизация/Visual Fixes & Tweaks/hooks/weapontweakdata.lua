Hooks:PostHook(WeaponTweakData, "init", "epicreloadfix", function(self)
	
	self.mac10_crew.reload = "pistol"
	self.tkb_crew.reload = "bullpup"
	self.tkb_crew.pull_magazine_during_reload = "rifle"
	self.rpk_crew.pull_magazine_during_reload = "rifle"
	self.par_crew.pull_magazine_during_reload = "rifle"
	self.m60_crew.pull_magazine_during_reload = "rifle"
	self.m249_crew.pull_magazine_during_reload = "rifle"
	self.hk21_crew.pull_magazine_during_reload = "rifle"
	
end)

-- Some minor animation tweaks when players hold certain weapons, also enables some weapons to actually drop magazines rather than nothing happening.
-- Code from Hoppip