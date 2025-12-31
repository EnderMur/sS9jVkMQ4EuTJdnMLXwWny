core:import("CoreMenuNodeGui")

MenuPauseRenderer = MenuPauseRenderer or class(MenuRenderer)

function MenuPauseRenderer:_setup_bg()
end

function MenuPauseRenderer:set_bg_visible(visible)
	self._menu_bg:set_visible(invisible)
	self._blur_bg:set_visible(invisible)
end