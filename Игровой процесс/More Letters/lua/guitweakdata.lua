Hooks:PostHook(GuiTweakData, "init", "GuiTweakData_init_MoreLetters", function(self)
	self.rename_max_letters = 40 -- number of letters for weapon names, default value is 20
	self.rename_skill_set_max_letters = 30 -- number of letters for skill set names, default value is 15
end)