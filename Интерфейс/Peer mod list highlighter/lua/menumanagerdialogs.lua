if not PeerModListHighlights then
	dofile(ModPath .. "lua/base.lua")
end

-- Yep, its mostly taken from void ui, but tweaked into this horrible mess to make sure that coloured mods go on top of the list
-- Oh and for some reason id and nick seem to be reversed?
Hooks:PostHook(MenuManager,"show_person_joining","PMLHjoinmodlistOn",function(id, nick)
	if not managers.hud or not managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2) or managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2).panel:child("user_dropin" .. tostring(id)) then
		return
	end
	local peer = managers.network:session():peer(nick)
	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
	local panel = hud.panel:panel({name = "user_dropin" .. tostring(id), layer = 10000})
	if PeerModListHighlights.settings.join_mods == true and peer and peer:synced_mods() and #peer:synced_mods() > 0 then -- if peer has mods create a panel
		local mods_fade = panel:gradient({
			name = "mods_fade1",
			layer = 1,
			gradient_points = {0,Color.black:with_alpha(0),0.85,Color.black:with_alpha(0.5),1,Color.black:with_alpha(0.7)}
		})
		local modslist_panel = panel:panel({name = "PMLHmodslist_panel", x = -15})
		modslist_panel:text({
			name = "PMLHmods_title",
			font_size = 21,
			font = tweak_data.menu.pd2_large_font,
			text = managers.localization:text("PMLH_joinplayer_list_mods_1")..tostring(peer:name())..managers.localization:text("PMLH_joinplayer_list_mods_2"),
			align = "right",
			y = 5,
			layer = 2,
			color = Color.white
		})
		
		local last_mod
		local topmodcounter = 0
		PeerModListHighlights._joining_mods = {}
		for i, mod in ipairs(peer:synced_mods()) do -- cycle every mod, search for green ones, put on top of the list Y postition wise, and into our array(table)
			local mod_name = mod.name
			if PeerModListHighlights.settings.include_mod_folder_join then
				mod_name = mod_name.." ("..mod.id..")"
			end
			if PeerModListHighlights:isModInGreen(mod.name) then
				last_mod = modslist_panel:text({
					name = "PMLHmod_" .. tostring(i),
					font_size = 21,
					font = tweak_data.menu.pd2_large_font,
					text = mod_name,
					align = "right",
					y = topmodcounter * (21) + 30,
					layer = 2,
					color = PeerModListHighlights.greencolour
				})
				topmodcounter = topmodcounter + 1
				table.insert(PeerModListHighlights._joining_mods, last_mod)
			end
		end
		for i, mod in ipairs(peer:synced_mods()) do -- same as green but yellow
			local mod_name = mod.name
			if PeerModListHighlights.settings.include_mod_folder_join then
				mod_name = mod_name.." ("..mod.id..")"
			end
			if PeerModListHighlights:isModInYellow(mod.name) then		
				last_mod = modslist_panel:text({
					name = "PMLHmod_" .. tostring(i),
					font_size = 21,
					font = tweak_data.menu.pd2_large_font,
					text = mod_name,
					align = "right",
					y = topmodcounter * (21) + 30,
					layer = 2,
					color = PeerModListHighlights.yellowcolour
				})
				topmodcounter = topmodcounter + 1
				table.insert(PeerModListHighlights._joining_mods, last_mod)
			end
		end
		for i, mod in ipairs(peer:synced_mods()) do -- red
			local mod_name = mod.name
			if PeerModListHighlights.settings.include_mod_folder_join then
				mod_name = mod_name.." ("..mod.id..")"
			end
			if PeerModListHighlights:isModInRed(mod.name) then
				last_mod = modslist_panel:text({
					name = "PMLHmod_" .. tostring(i),
					font_size = 21,
					font = tweak_data.menu.pd2_large_font,
					text = mod_name,
					align = "right",
					y = topmodcounter * (21) + 30,
					layer = 2,
					color = PeerModListHighlights.redcolour
				})
				topmodcounter = topmodcounter + 1
				table.insert(PeerModListHighlights._joining_mods, last_mod)
			end
		end
		for i, mod in ipairs(peer:synced_mods()) do -- all the other mods
			local mod_name = mod.name
			if PeerModListHighlights.settings.include_mod_folder_join then
				mod_name = mod_name.." ("..mod.id..")"
			end
			if not PeerModListHighlights:isModInGreen(mod.name) and not PeerModListHighlights:isModInYellow(mod.name) and not PeerModListHighlights:isModInRed(mod.name) then
				last_mod = modslist_panel:text({
					name = "PMLHmod_" .. tostring(i),
					font_size = 21,
					font = tweak_data.menu.pd2_large_font,
					text = mod_name,
					align = "right",
					y = topmodcounter * (21) + 30,
					layer = 2,
					color = PeerModListHighlights.settings.joinListDefaultColour
				})
				topmodcounter = topmodcounter + 1
				table.insert(PeerModListHighlights._joining_mods, last_mod)
			end
		end
		
		for i=1, table.getn(PeerModListHighlights._joining_mods) do -- display all mods
			managers.hud:make_fine_text(PeerModListHighlights._joining_mods[i])
			PeerModListHighlights._joining_mods[i]:set_right(modslist_panel:w())
		end
		if last_mod then
			modslist_panel:set_h(last_mod:bottom())
		end
	end
end)


Hooks:PostHook(MenuManager,"close_person_joining","PMLHjoinmodlistOff",function(id) -- remove our panel when load is complete
	if not managers.hud or not managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2) then
		return
	end
	local hud =	managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
	local panel = hud.panel:child("user_dropin" .. tostring(id))
	if panel then
		managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2).panel:remove(panel)
		PeerModListHighlights._joining_mods = nil
	end
end)