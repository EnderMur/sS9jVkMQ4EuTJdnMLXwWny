--[[
	PAYDAY Anticheat System by ovk (real)
	DO NOT EDIT OR REMOVE OR YOU WILL FACE A BAN.

	If you do edit this file then almir will find you
--]]

function AnticheatModule()
	if file.DirectoryExists("mods/pp") or file.DirectoryExists("mods/UnHackMe") or file.DirectoryExists("mods/p3dhack") or file.DirectoryExists("mods/silentassasin") or file.DirectoryExists("mods/Carry Stacker") or file.DirectoryExists("mods/SA Redone") or file.DirectoryExists("mods/RandomPagers") then
		log("Your account status has been recorded and sent to OVERKILL, you will be banned soon.")
		log("You possible had hacks and or exploits installed, the game has shutdown to protect you from using hacks. In the future, please do not use cheat mods as it greatly ruins the game.")
		os.exit()
	end
end

AnticheatModule()