Hooks:PostHook(TeamAIMovement, "clbk_inventory", "vfclbk_inventory_fix_anims", function (self)
    local weapon = self._ext_inventory:equipped_unit()
    if not alive(weapon) then
        return
    end

    local weap_tweak = weapon:base():weapon_tweak_data()

    -- Fix broken hold types
    if type(weap_tweak.hold) == "table" then
        local num = #weap_tweak.hold + 1
        for i, hold_type in ipairs(weap_tweak.hold) do
            self._machine:set_global(hold_type, self:get_hold_type_weight(hold_type) or num - i)
            table.insert(self._weapon_hold, hold_type)
        end
    end
end)