local on_damage_received2 = CivilianDamage._on_damage_received
function CivilianDamage:_on_damage_received(damage_info)
    if self._dead then
        if managers.hud.scoreboard_unit_killed then
            managers.hud:scoreboard_unit_killed(damage_info.attacker_unit, "civs")
        end
    end
    on_damage_received2(self, damage_info)
end