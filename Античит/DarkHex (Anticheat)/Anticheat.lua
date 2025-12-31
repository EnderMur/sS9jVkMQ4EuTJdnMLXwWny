local blockedMods = {
    "Realtime XP",
    "Infamy Pool Overflow",
    "Print Faster",
    "Berserk Helper",
    "STOL3NH4CK",
    "STOLENHACK",
    "Buy More Gage Asset",
    "Infamy with active Crime Spree",
    "Go Infamous with active Crime Spree",
    "[Big Bank] PC Helper",
    "Big Bank Computer Hack BLT",
    "Lock Smasher",
    "More Infamy XP",
    "Ultimate Trainer",
    "Berserker Live Matters",
    "Meth Helper",
    "Meth Helper (Updated)",
    "Better Bots",
    "The Cooker",
    "AutoCooker",
    "Cook Faster",
    "Carry Stacker Reloaded",
    "CARRY STACKER: LIVE AND RELOADED",
    "p3dhack",
    "p3dhack free",
    "P3DHack Free Version",
    "p3dunlocker",
    "Safe Crash Fix",
	"Pirate Perfection Reborn Trainer!",
	"Pirate Perfection Reborn Trainer! Free Edition",
	"Pirate Perfection Reborn Trainer! V.I.P. Edition",
    "CC and Money Generator",
    "LowCostSkill",
    "Instant overdrill",
    "InstaWin",
    "Nokick4u",
    "FUCK THE Flashbangs",
    "Kill Teammates :)",
    "Tactical Movement",
    "Hello world!",
    "Stay there, Twitch!!",
    "System: Meth Helper(RU)",
    "overkill mod",
    "ultimate trainer 4",
    "no pager on domination",
    "mvp",
    "hack",
    "cheat",
    "god",
    "Beyond Cheats",
    "the great skin unlock",
    "multijump",
    "unhittable armour",
    "mod that removes turrets actually",
    "spawn addition loots on gage package",
    "aimbot",
    "wolfhud-master",
    "Toolkit",
    "Infinite Ammo",
    "Funny Skill Points",
    "Auto Marker",
    "Gold Worh Booster",
    "slot machine cheat",
    "multijump",
    "Pro"
}

local exceptionMods = {
    "no weather - gab",
    "double tick rate - gab",
    "no slow motion - gab",
    "disable corpses - gab",
    "disable corpses + shields - gab",
    "no head bobbing - gab",
    "no rename limit - gab",
    "no skins - gab",
    "remove dead shields instantly - gab",
    "weapon laser defaults to full strength - gab"
}

function getSkillPoints(peer_id)
    if not managers.network._session or type(peer_id) ~= "number" or peer_id < 1 then
        return 0
    end
    local peer = managers.network:session():peer(peer_id)
    if peer then
        local pskills = peer:skills()
        if pskills then
        	local skills_perks = string.split(pskills, '-')
        	if #skills_perks == 2 then
        		local skillpoints = 0
        		skills_string = skills_perks[1]
        		local skills = string.split(skills_string, '_')
        		if #skills >= 15 then
        			for i = 1, #skills do
        				skillpoints = skillpoints + tonumber(skills[i])
        			end
                    return skillpoints
        		end
        	end
        end
    end
    return 0
end

function kickPeerCheated(id, peer, mod)
    local session = managers.network:session()
    local getPeer = managers.network:session():peer(id)
	local text = peer:name() .. " sera expulsado por usar un mod prohibido: " .. mod
    session:send_to_peers_except(id, "send_chat_message", ChatManager.GAME, "[ANTICHEAT] " .. text)
	managers.chat:_receive_message(ChatManager.GAME, "ANTICHEAT", text, Color('ff3300'))
    DelayedCalls:Add( peer:name() .. "send_msg_bannedmods", 2, function()
        if getPeer then peer:send("send_chat_message", ChatManager.GAME, "[ANTICHEAT] Seras expulsado por usar un mod prohibido (" .. mod .. "). Deberas quitarte el mod para poder ingresar.") end
    end)
    DelayedCalls:Add( peer:name() .. "kick_peer_bannedmods", 6, function()
        if getPeer then session:send_to_peers("kick_peer", id, 4) session:on_peer_kicked(peer, id, 4) end
    end)
end

-- Check player mods and skillpoints [Host]
Hooks:PostHook(NetworkPeer, "sync_lobby_data", "mods_list", function (self, peer)
	if not Network:is_server() then
		return
	end

    --Check player mods
    DelayedCalls:Add( peer:user_id() .. "CheckPeerMods", 1, function()
        local checkedException = false
        if peer and #peer._mods > 0 then
            for i, mod in ipairs(peer._mods) do
                for _, blocked in pairs(blockedMods) do
                    if mod.name:lower() == blocked:lower() or string.find(mod.name:lower(), "gab") or string.find(mod.name:lower(), "payday2.pw") then
                        --Exeptions
                        if string.find(mod.name:lower(), "gab") or string.find(mod.name:lower(), "payday2.pw") then
                            for _, gabs in pairs(exceptionMods) do
                                if mod.name:lower() == gabs:lower() then
                                    checkedException = true
                                end
                            end
                        end
                        --Result cheater kick
                        if not checkedException then
                            kickPeerCheated(peer:id(), peer, mod.name)
                            return
                        end
	    				checkedException = false
                    end
                end
            end
        end
    end)

    --Check player hiding mods
    DelayedCalls:Add( peer:user_id() .. "CheckPlayerHiddenMods", 8, function()
        if not peer then return end
        if moddedPeersList[peer:user_id()] and #peer._mods == 0 then
            managers.chat:_receive_message(ChatManager.GAME, "ANTICHEAT", "Se detecto que " .. peer:name() .. " tiene SuperBLT instalado pero su lista de mods esta vacia. Podria estar ocultando sus mods", Color('ff3300'))
        end
    end)

end)


--Check banned mods [No host]
local peersWBlockedMods = {}
Hooks:PostHook(NetworkPeer, "sync_lobby_data", "mods_list_nohost", function (self, peer)
    if Network:is_server() then
		return
	end

    --Check player mods
    DelayedCalls:Add( peer:user_id() .. "CheckPlayerMods", 1, function()
        if peer and #peer._mods > 0 then
            peersWBlockedMods[peer:user_id()] = {}
            for _, mod in ipairs(peer._mods) do
                --Blocked mods
                for _, blocked in pairs(blockedMods) do
                    if mod.name:lower() == blocked:lower() then
                        table.insert(peersWBlockedMods[peer:user_id()], mod.name)
                    end
                end
                --Gab mods
                if string.find(mod.name:lower(), "gab") or string.find(mod.name:lower(), "payday2.pw") then
                    if not string.find(mod.name:lower(), table.concat(exceptionMods, ", "):lower()) then
                        table.insert(peersWBlockedMods[peer:user_id()], mod.name)
                    end
                end
            end
            if #peersWBlockedMods[peer:user_id()] > 0 then
                local text = ""
                for _, blkdMod in pairs(peersWBlockedMods[peer:user_id()]) do
                    text = #text == 0 and text .. blkdMod or text .. ", " .. blkdMod
                end
                managers.chat:_receive_message(ChatManager.GAME, "ANTICHEAT", peer:name() .. " tiene mods prohibidos es un cheater: " .. text, Color('ff3300'))
                peersWBlockedMods[peer:user_id()] = nil
                text = ""
            end
        end
    end)

    --Check player hiding mods
    DelayedCalls:Add( peer:user_id() .. "CheckPlayerHiddenMods", 8, function()
        if not peer then return end
        if moddedPeersList[peer:user_id()] and #peer._mods == 0 then
            managers.chat:_receive_message(ChatManager.GAME, "ANTICHEAT", "Se detecto que " .. peer:name() .. " tiene SuperBLT instalado pero su lista de mods esta vacia. Puede estar ocultando sus mods con un cheat", Color('ff3300'))
        end
    end)

end)

--Check player skillpoints [Host & No host]
Hooks:PostHook(ConnectionNetworkHandler, "sync_outfit", "CheckHackedSkillpoints", function(self, outfit_string, outfit_version, outfit_signature, sender)
    local peer = self._verify_sender(sender)
    if not peer then return end
    DelayedCalls:Add( peer:user_id() .. "CheckHackedSkillpoints", 2, function()
        local current_level = peer._level
        if current_level then
            local max_points = current_level + (math.floor(current_level / 10) * 2)
            local userSkillPoints = getSkillPoints(peer:id() or 0)
            if userSkillPoints and userSkillPoints > max_points  then
                local text = peer:name() .. " hizo trampa asignandose " .. userSkillPoints .. " puntos de habilidad (Maximo ".. max_points .. "pts para su nivel)"
                local getPeer = managers.network:session():peer(peer:id())
                if Network:is_server() then
                    local session = managers.network:session()
                    text = peer:name() .. " sera expulsado por hacer trampa asignandose " .. userSkillPoints .. " puntos de habilidad (Maximo ".. max_points .. "pts para su nivel)"
                    session:send_to_peers_except(peer:id(), "send_chat_message", ChatManager.GAME, "[ANTICHEAT] " .. text)
                    
                    DelayedCalls:Add( peer:name() .. "send_msg_cheatedskills", 2, function()
                        if getPeer then peer:send("send_chat_message", ChatManager.GAME, "[ANTICHEAT] Seras expulsado por tener " .. userSkillPoints .. " puntos de habilidad asignados. El maximo para tu nivel es " .. max_points .. " puntos de habilidad.") end
                    end)
                    
                    DelayedCalls:Add( peer:name() .. "kick_peer_cheatedskills", 6, function()
                        if getPeer then session:send_to_peers("kick_peer", peer:id(), 4) session:on_peer_kicked(peer, peer:id(), 4) end
                    end)
                end
                managers.chat:_receive_message(ChatManager.GAME, "ANTICHEAT", text, Color('ff3300'))
            end
        end
    end)
end)

--Detect modded lobby on crime.net
Hooks:PostHook(CrimeNetGui, "add_server_job", "DetectModdedLobby", function(self, __data, ...)
    if type(__data) == "table" and __data.id and __data.room_id then
        local job = self._jobs[__data.id]
        if type(job) == "table" and type(job.icon_panel) == "userdata" and type(job.side_panel.child) == "function" then
            local host_name = job.side_panel:child("host_name")
            local mod_list = __data.mods
            local has_banned_mods = false
            if mod_list ~= "7d66a433be3a1fe2" then
                for _, blocked in pairs(blockedMods) do
                    if string.find(mod_list, blocked) then
                        has_banned_mods = true
                        break
                    end
                end
                host_name:set_color(has_banned_mods and Color.red or Color.green)
            end
        end
    end
end)

--Anti Modding Detection Detection
moddedPeersList = {}
Hooks:Add("ChatManagerOnReceiveMessage","CheckHiddenMods", function(channel_id, name, message, color, icon)
    if tonumber(channel_id) ~= LuaNetworking.HiddenChannel then
		return
	end
    
    local senderID
    for k, v in pairs(LuaNetworking:GetPeers()) do
        if v:name() == name then
            senderID = v
        end
    end
    moddedPeersList[tostring(senderID:user_id())] = true
end)