TheFixesPreventer = TheFixesPreventer or {}
if TheFixesPreventer.heist_roberts_softlock or Network:is_client() then
	return
end

-- https://steamcommunity.com/app/218620/discussions/14/135513901701994436/

local cage_none = managers.mission:get_element_by_id(104214)
if not cage_none then
    log("[TheFixes] 'cage_none' element not found, fix won't be applied!")
    return
end

-- Disable debug string "ERROR! SCRIPT LOOP BROKEN!" loop
-- Call 104209 to randomly select a place (street or parking)
-- Call 103445 again to show waypoints and continue with the mission script
cage_none._values.on_executed = { 104209, 103445 }