local class_name = "A-Anti-Crash-Loc"
local loaded = rawget(_G, class_name)
local c = not loaded and rawset(_G, class_name, {}) and _G[class_name] or loaded

if not loaded then
	function c:load_config()
		if JSON then
			local file = JSON:jsonFile(string.format(self.path, "config.json"))
			local data = JSON:decode(file)
			for _, v in pairs(data) do
				if type(v) == "table" then
					self.config = v
				end
			end
		end
	end

	function c:save_config()
		local file = JSON and io.open(string.format(self.path, "config.json"), "w")
		local data = {
			["config"] = self.config
		}

		if file then
			local contents = JSON:encode_pretty(data)
			file:write(contents)
			io.close(file)
		end
	end

	function c:init()
		self.config = {}
		self.path = ModPath.."/loc/%s"
		dofile(string.format(self.path, "JSON.lua"))
		self:load_config()
	end
end
c:init()