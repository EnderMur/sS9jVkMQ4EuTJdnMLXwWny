local hook_id = "ImprovedSearch__AchievementListGui._filter_func__post"

Hooks:PostHook(AchievementListGui, "_filter_func", hook_id, function(self)
	local filters = {}

	if self._search then
		local text = utf8.to_lower(self._search.text:text())

		if #text > 0 then
			table.insert(filters, function (v)
				local v_title = utf8.to_lower(v.title)
				local v_desc = utf8.to_lower(v.desc)

				return string.find(v_title, text, nil, true) or string.find(v_desc, text, nil, true)
			end)
		end
	end

	if #filters > 0 then
		return function (v)
			for _, f in ipairs(filters) do
				if not f(v) then
					return false
				end
			end

			return true
		end
	else
		return
	end
end)