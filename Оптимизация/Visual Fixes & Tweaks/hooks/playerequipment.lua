function PlayerEquipment:use_bodybags_bag()
	local ray = self:valid_shape_placement("bodybags_bag")

	if ray then
		local pos = ray.position
		local rot = self:_m_deploy_rot()
		rot = Rotation(rot:yaw() - 90, 0, 0)

		PlayerStandard.say_line(self, "s13")
		managers.mission:call_global_event("player_deploy_bodybagsbag")
		managers.statistics:use_body_bag()

		local amount_upgrade_lvl = 0

		if Network:is_client() then
			managers.network:session():send_to_host("place_deployable_bag", "BodyBagsBagBase", pos, rot, amount_upgrade_lvl)
		else
			local unit = BodyBagsBagBase.spawn(pos, rot, amount_upgrade_lvl, managers.network:session():local_peer():id())
		end

		return true
	end

	return false
end

local valid_shape_placement = PlayerEquipment.valid_shape_placement
function PlayerEquipment:valid_shape_placement(equipment_id, equipment_data, ...)
	local valid, ray = valid_shape_placement(self, equipment_id, equipment_data, ...)

	if valid and equipment_id == "bodybags_bag" then
		local rot = self._unit:movement():m_head_rot()
		rot = Rotation(rot:yaw() - 90, 0, 0)
		self._dummy_unit:set_rotation(rot)
	end

	return valid, ray
end

-- Fixes the bodybag case where it was facing off to it's side rather than towards the player. 
-- Code from Hinaomi.