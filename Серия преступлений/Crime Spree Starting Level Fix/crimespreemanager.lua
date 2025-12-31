--normally winning streak is not defined in this function, but rather in reset_crime_spree() which is called. this immediately sets it to 0.
--however, winning streak is supposed to be relative to the level. by setting it to 0 right away, starting a crime spree at any level above 0 has no point.
--in fact, you could argue it is detrimental since starting at a higher level is harder but yields the same rewards as starting at level 0.
--to fix this, we set it to start out where it is supposed to be (as if the player had worked up from 0) so it gives the proper rewards.
--we also have to make it so the player can not abuse the starting cost being cheaper than the continue cost (by making them the same in tweakdata).
--its not perfect, since we have to make the starting costs higher to address the problem. however, i'd argue its a lot better than the current system.
function CrimeSpreeManager:start_crime_spree(starting_level)
	print("CrimeSpreeManager:start_crime_spree")

	if not self:can_start_spree(starting_level) then
		return false
	end

	local cost = self:get_start_cost(starting_level)

	managers.custom_safehouse:deduct_coins(cost)
	self:reset_crime_spree()

	self._global.in_progress = true
	self._global.spree_level = starting_level or 0
	if tweak_data.crime_spree.catchup_min_level <= managers.experience:current_level() then
		self._global.winning_streak = ((starting_level * tweak_data.crime_spree.winning_streak) + 1) or 0
	else
		log("User is trying to start a crime spree while below level 100, make sure you are level 100 first for proper rewards!")
	end

	self:generate_new_mission_set()

	return true
end