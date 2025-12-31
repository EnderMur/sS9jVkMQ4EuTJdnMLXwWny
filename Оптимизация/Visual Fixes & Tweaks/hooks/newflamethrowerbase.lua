local original_spawn_flame_effect = NewFlamethrowerBase._spawn_flame_effect

-- skip cooldowncheck
function NewFlamethrowerBase:_spawn_flame_effect(to_pos, direction, skip_t_check)

	return original_spawn_flame_effect(self, to_pos, direction, true)
end