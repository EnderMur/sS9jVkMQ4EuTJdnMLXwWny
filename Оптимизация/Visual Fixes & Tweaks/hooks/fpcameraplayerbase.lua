local ANIM_STATES = PlayerStandard.ANIM_STATES
function FPCameraPlayerBase:play_redirect(redirect_name, speed, offset_time)
    self:set_anims_enabled(true)
    
    local equipped_weapon = self._parent_unit and self._parent_unit:inventory() and self._parent_unit:inventory():equipped_unit()
    local current_state = self._parent_movement_ext and self._parent_movement_ext._current_state
    if alive(equipped_weapon) then
        local weap_base = equipped_weapon:base()
        if weap_base then
            if redirect_name == ANIM_STATES.standard.recoil_steelsight or redirect_name == ANIM_STATES.standard.recoil then
                speed = weap_base:fire_rate_multiplier()
            end
        end
    end
    
    self._anim_empty_state_wanted = false
    local result = self._unit:play_redirect(redirect_name, offset_time)

    if result == self.IDS_NOSTRING then
        return false
    end

    if speed then
        self._unit:anim_state_machine():set_speed(result, speed)
    end

    return result
end

-- Fix for fire rate speed mults not applying to anims, especially while aiming. So there shouldn't be a weird desync between weapon parts and the players hands.
-- Code from Restoration Mod, DMC's code.