function TastNightDayReborn:init()
    
end

if not Global.load_level then 
    return
end
local level_id = Global.game_settings.level_id

function TastNightDayReborn:ramfix()
	if level_id == "ranc" then
		return true
	end
end