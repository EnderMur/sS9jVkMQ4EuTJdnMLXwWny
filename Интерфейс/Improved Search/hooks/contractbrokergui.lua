local hook_id = "ImprovedSearch__ContractBrokerGui.perform_filter_search__post"

Hooks:PostHook(ContractBrokerGui, "perform_filter_search", hook_id, function(self, job_tweak, optional_search_text)
	local search_text = optional_search_text or self._search and alive(self._search.text) and utf8.to_lower(self._search.text:text())

	if search_text and #search_text > 0 then
		local job_name = utf8.to_lower(managers.localization:text(job_tweak.name_id or "no name_id"))

		if string.find(job_name, search_text, nil, true) then
			return true
		end

		local contact_tweak = tweak_data.narrative.contacts[job_tweak.contact]

		if contact_tweak then
			local contact_name = utf8.to_lower(managers.localization:text(contact_tweak.name_id or "no name_id"))

			if string.find(contact_name, search_text, nil, true) then
				return true
			end
		end

		return false
	end

	return true
end)