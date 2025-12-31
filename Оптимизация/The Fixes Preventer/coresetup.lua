local coresetup_init_orig = CoreSetup.__init
function CoreSetup:__init(...)
	if TheFixesPreventerFinalize then
		TheFixesPreventerFinalize()
		TheFixesPreventerFinalize = nil
	end
	coresetup_init_orig(self, ...)
end