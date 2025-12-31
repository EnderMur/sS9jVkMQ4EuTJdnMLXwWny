if not PeerModListHighlights then
	_G.PeerModListHighlights = {}
end

PeerModListHighlights.savepath = SavePath .. 'PMLH_save.txt'
PeerModListHighlights.modpath = ModPath

-- This terribleness is made this way, because i cant figure out how to make sliders in game save values properly.
-- If i make an array for a green mod list with 3 colours, it will work fine at first, but whenever i reboot the game
-- and go back to the settings, sliders will have default values for their colour, even though new values 
-- are stored properly in the save file and mod names are highlighted with changed colours. Why?
PeerModListHighlights.settings = { 
	include_mod_folder_player_menu = false,
	include_mod_folder_crimenet = true,
	include_mod_folder_join = false,
	profile_button = true,
	join_mods = true,
	Glistcolour1 = 0,
	Glistcolour2 = 255,
	Glistcolour3 = 100,
	Ylistcolour1 = 225,
	Ylistcolour2 = 200,
	Ylistcolour3 = 20,
	Rlistcolour1 = 200,
	Rlistcolour2 = 0,
	Rlistcolour3 = 0,
	
	------########################## GO HERE TO CHANGE DEFAULT COLOURS #############################------

	-- As of update 3.7 default colours are now saved to your save file, so you dont have to change them every time a patch comes out.
	
	-- You can change your default colours here. To do so, replace default values with your colour of choice.
	-- Valid format for your colour: "Color( 255, R, G, B ) / 255" (without ""), where R G and B stand for 'red' 'green' and 'blue' colour values. RGB values can not be less then 0 or more then 255.
	-- Game uses values between 0 and 1 which scale proportionally to the 255 rgb value, that's why joinList has a value of 1 1 1 1, thats just RGB for 255 255 255.
	-- That's why you can use the /255 at the end - so that you dont have to caluclate the RGB value when its converted to 0-1 range.
	-- If you are wondering, the very first value stands for transparency (i think), so keep it at 1, unless you want blurry and hard to see words.
	-- Also, don't forget about comas at the end of your values, this is an array of values after all.
	-- Reminder: 'menuDefaultColour' is for peer's mod lists and by default is set to a string "default". Crime.net default is 'Color(0.8, 0.8, 0.8)'.
	-- 'joinListDefaultColour' is for the list created when someone is joining your lobby, default value: Color(1, 1, 1, 1).
	
	menuDefaultColour = "default",
	crimenetDefaultColour = Color(0.8, 0.8, 0.8),
	joinListDefaultColour = Color(1, 1, 1, 1), -- white
	
}

-- assign list colours after we load individual values from the save file
function PeerModListHighlights:loadlistcolours()
	PeerModListHighlights.greencolour = Color( 255, PeerModListHighlights.settings.Glistcolour1, PeerModListHighlights.settings.Glistcolour2, PeerModListHighlights.settings.Glistcolour3 ) / 255
	PeerModListHighlights.yellowcolour = Color( 255, PeerModListHighlights.settings.Ylistcolour1, PeerModListHighlights.settings.Ylistcolour2, PeerModListHighlights.settings.Ylistcolour3 ) / 255
	PeerModListHighlights.redcolour = Color( 255, PeerModListHighlights.settings.Rlistcolour1, PeerModListHighlights.settings.Rlistcolour2, PeerModListHighlights.settings.Rlistcolour3 ) / 255
end

-- at this point its not only the list config, but also the additional settings, but whatevs
function PeerModListHighlights:Save_listconfig()
    local file = io.open(SavePath .. 'PMLH_save_listsconfig.txt', 'w+')
    if file then
        file:write(json.encode(PeerModListHighlights.settings))
        file:close()
    end
end
    
function PeerModListHighlights:Load_listconfig()
    local file = io.open(SavePath .. 'PMLH_save_listsconfig.txt', 'r')
    if file then
        for k, v in pairs(json.decode(file:read('*all')) or {}) do
            PeerModListHighlights.settings[k] = v
        end
        file:close()
    end
end

PeerModListHighlights:Load_listconfig()
PeerModListHighlights:Save_listconfig()
PeerModListHighlights:loadlistcolours()
	

-- This "old version upgrade" part is some legacy stuff, and most likely not needed for anyone, other then people who are somewhow still using a version from almost a year ago.
-- Still somewhat usefull if you want to add mod names i guess, but you are better of just adding them to the save file manually.

---------###################### OLD VERSION UPGRADES/MANUAL MOD ADDING GUIDE ###########################---------

-- If you did not use this mod before version 3.0, you dont need this information, unless you want to add mods manualy.

-- Allright, first - old version mod list ports.
-- Mod structure was changed, so now all of your mods are stored in a save file in mods/saves/PMLH_save.txt
-- You won't need to change it, only values below.
-- After this message you can notice a similar list pattern to that in the previous version. However, these values are not changed when you make adjustments in game,
-- all the changes are happening in the save file. These values are 'default' mods, that are written into the save file, if user does not have a save file yet.
-- If you want to move your mods from old version to the new one, or manually add mods, just add them into the values below, and start the game, and you should be good to go.
-- If you are having issues, close the game, remove the save file from saves folder, make sure that your mods are written down in lists below, and you should be fine.
--
-- Visual example on how it should be done:
--
--	Old version that you want to copy stuff from
--	PeerModListHighlights.greenlist = { -- this line is slightly different if you a porting from Crime.net list highlighter, but it does not matter.
--		"ADDEDMOD1", *Only this*
--		"ADDEDMOD2", *this*
--		"ADDEDMOD3" *and this line should be copied*
--	}
--
-- 	New mod version that you want to move stuff to
--		greenlist = {
--			*and pasted over here*
--		},
--
-- In the end your Peer list mod values should look like this:
--	PeerModListHighlights.lists ={
--		greenlist = {
--			"ADDEDMOD1",
--			"ADDEDMOD2",
--			"ADDEDMOD3"
--		},
--		yellowlist = {
--			"NEWBIES GO BACK TO OVERKILL"
--		},
--		redlist = {
--			"SILENT ASSASSIN"
--		}
--	}
--
--	P.S. Obiuously you can add mods not just to green list, i just didnt want to make a really lengthy example showcase
--
-- Manual mod adding process:
-- Some info from the message above (with porting) can be useful to you, but whatever.
-- If you want to add mods manualy, you need to add them IN CAPS into the lists below.
-- Dont forget "" symbols to put your mod name within and to put a comma after a mod's name like in example above or list below
-- However, this way you only add 'default' mods that are written into the save file if you dont have a save file yet, on the first boot up of the game with this mod installed.
-- You can remove the save file (location: mods/saves/PMLH_save.txt) and start the game to reset them to these defaults.
--
-- If you want to add mods after the save file was created, you need to go the save file mentioned above, and change values there.
-- Over there logic is pretty much the same, only caps, commas after every name. It is a bit harder to read because it's in one line though, but i believe you will manage that :)
-- If your game crashes on start up after you tinkered with save files, you probably made a typo


PeerModListHighlights.lists ={
	greenlist = {
		"SUPERBLT",
		"BEARDLIB"
	},
	yellowlist = {
		"NEWBIES GO BACK TO OVERKILL"
	},
	redlist = {
		"SILENT ASSASSIN"
	}
}

-- purely for mod names
function PeerModListHighlights:save()
    local file = io.open(PeerModListHighlights.savepath, 'w+')
    if file then
        file:write(json.encode(PeerModListHighlights.lists))
        file:close()
    end
end

function PeerModListHighlights:load()
    local file = io.open(PeerModListHighlights.savepath, 'r')
    if file then
        for k, v in pairs(json.decode(file:read('*all')) or {}) do
            PeerModListHighlights.lists[k] = v
        end
        file:close()
    end
end

PeerModListHighlights.load()
PeerModListHighlights:save()

local PMLH_List_1 = PeerModListHighlights.lists.greenlist
local PMLH_List_2 = PeerModListHighlights.lists.yellowlist
local PMLH_List_3 = PeerModListHighlights.lists.redlist

-- returns true/false if a name is found in our save file with mod names
function PeerModListHighlights:isModInGreen(text)
	return table.contains(PMLH_List_1, string.upper(text))
end

function PeerModListHighlights:isModInYellow(text)
	return table.contains(PMLH_List_2, string.upper(text))
end

function PeerModListHighlights:isModInRed(text)
	return table.contains(PMLH_List_3, string.upper(text))
end

-- functions to add, remove and move mods in between lists, using the pop up menu in crime.net/player list
function PeerModListHighlights:addModToList_1(local_pmlh_mod_name)
    local file = io.open(SavePath .. 'PMLH_save.txt', 'w+')
    if file then
		-- if we decide to add to green, and mod is not in green yet
		if not self:isModInGreen(local_pmlh_mod_name) then
		
			-- check if it's allready in yellow to remove it from there. mod can be only in 1 list
			if self:isModInYellow(local_pmlh_mod_name) then
				table.delete(PMLH_List_2, string.upper(local_pmlh_mod_name))
			end
			
			-- same as yellow but red
			if self:isModInRed(local_pmlh_mod_name) then
				table.delete(PMLH_List_3, string.upper(local_pmlh_mod_name))
			end
			
			-- finally add it to green and update the save file
			table.insert(PMLH_List_1, string.upper(local_pmlh_mod_name))
			file:write(json.encode(self.lists))
			file:close()
			
		else
			-- if mod is allready in green, remove it from green
			table.delete(PMLH_List_1, string.upper(local_pmlh_mod_name))
			file:write(json.encode(self.lists))
			file:close()
		end
    end
end

function PeerModListHighlights:addModToList_2(local_pmlh_mod_name) -- same for yellow
    local file = io.open(SavePath .. 'PMLH_save.txt', 'w+')
    if file then
		if not self:isModInYellow(local_pmlh_mod_name) then
			if self:isModInGreen(local_pmlh_mod_name) then
				table.delete(PMLH_List_1, string.upper(local_pmlh_mod_name))
			end
			if self:isModInRed(local_pmlh_mod_name) then
				table.delete(PMLH_List_3, string.upper(local_pmlh_mod_name))
			end
			table.insert(PMLH_List_2, string.upper(local_pmlh_mod_name))
			file:write(json.encode(self.lists))
			file:close()	
		else
			table.delete(PMLH_List_2, string.upper(local_pmlh_mod_name))
			file:write(json.encode(self.lists))
			file:close()
		end
    end
end

function PeerModListHighlights:addModToList_3(local_pmlh_mod_name) -- red
    local file = io.open(SavePath .. 'PMLH_save.txt', 'w+')
    if file then
		if not self:isModInRed(local_pmlh_mod_name) then
			if self:isModInYellow(local_pmlh_mod_name) then
				table.delete(PMLH_List_2, string.upper(local_pmlh_mod_name))
			end
			if self:isModInGreen(local_pmlh_mod_name) then
				table.delete(PMLH_List_1, string.upper(local_pmlh_mod_name))
			end
			table.insert(PMLH_List_3, string.upper(local_pmlh_mod_name))
			file:write(json.encode(self.lists))
			file:close()
		else
			table.delete(PMLH_List_3, string.upper(local_pmlh_mod_name))
			file:write(json.encode(self.lists))
			file:close()
		end
    end
end