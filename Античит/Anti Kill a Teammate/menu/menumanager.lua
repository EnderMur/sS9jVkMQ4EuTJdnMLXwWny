_G.AntiKillTeammates = AntiKillTeammates or {}
AntiKillTeammates.path = ModPath
AntiKillTeammates.save_path = SavePath .. "antikillteammates.txt"
AntiKillTeammates.settings = {
    action_choice = 1,
	msg_choice = 1
	
}

function AntiKillTeammates:Save()
	local file = io.open(self.save_path,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

function AntiKillTeammates:Load()
	local file = io.open(self.save_path, "r")
	if (file) then
		for k, v in pairs(json.decode(file:read("*all"))) do
			self.settings[k] = v
		end
	else
		self:Save()
	end
end

Hooks:Add("LocalizationManagerPostInit", "AntiKillTeammates_LocalizationManagerPostInit", function(loc)
	local t = AntiKillTeammates.path .. "loc/"
	for _, filename in pairs(file.GetFiles(t)) do
		local str = filename:match('^(.*).txt$')
		if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
			loc:load_localization_file(t .. filename)
			return
		end
	end
	loc:load_localization_file(t .. "english.txt")
end)

Hooks:Add("MenuManagerInitialize", "AntiKillTeammates_MenuManagerInitialize", function(menu_manager)
	MenuCallbackHandler.anti_kill_teammate_choice_callback = function(self,item)
		local value = tonumber(item:value())
		AntiKillTeammates.settings.action_choice = value
		AntiKillTeammates:Save()
	end
	
    MenuCallbackHandler.anti_kill_teammate_msg_callback = function(self,item)
		local value = tonumber(item:value())
		AntiKillTeammates.settings.msg_choice = value
		AntiKillTeammates:Save()
	end
	
	MenuCallbackHandler.anti_kill_teammate_back = function(self)
		AntiKillTeammates:Save()
	end
	
	AntiKillTeammates:Load()
	MenuHelper:LoadFromJsonFile(AntiKillTeammates.path .. "menu/options.txt", AntiKillTeammates, AntiKillTeammates.settings)
end)