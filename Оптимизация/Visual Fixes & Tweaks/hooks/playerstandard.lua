local function set_hos(self)
    self._ext_network:send("set_stance", 2, false, false)
end

local get_animation = PlayerStandard.get_animation
function PlayerStandard:get_animation(anim, ...)
    if (anim == "recoil") and self._state_data.in_steelsight then
        return get_animation(self, "recoil_steelsight", ...)
    end
    return get_animation(self, anim, ...)
end

-- Fixes Canted Sights / Angled Sights incorrectly using hipfire firing animations rather than ADS firing animations. This looks especially bad on the new ajustable zoom scopes.

Hooks:PostHook(PlayerStandard, "_enter", "_enter_hos", set_hos)
Hooks:PostHook(PlayerStandard, "_end_action_steelsight", "_end_action_steelsight_hos", set_hos)
Hooks:PostHook(PlayerStandard, "set_running", "set_running_hos", set_hos)

-- Fixes the issue where players were constantly aiming their guns even after shooting, after a while players will "lower" their weapons. This doesn't work for weapons that use the Bulpup animations as there was no idle animations made for that set sadly.

-- Stance code from Hoppip.
-- Fixed Canted Sights / Angled Sights from krimzin.