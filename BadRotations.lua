-- define br global that will hold the bot global background features
br = {}
-- brdata = {}
br.data = {}
br.dungeon = {}
br.raid = {}
br.data.settings = {}
br.selectedSpec = "None"
br.selectedProfile = 1
br.dropOptions = {}
br.dropOptions.Toggle = {"LeftCtrl","LeftShift","RightCtrl","RightShift","RightAlt","None"}
br.dropOptions.Toggle2 ={"LeftCtrl","LeftShift","LeftAlt","RightCtrl","RightShift","RightAlt","MMouse","Mouse4","Mouse5","None" }
br.dropOptions.CD = {"Never","CDs","Always" }
br.loadedIn = false
br.rotations = {}
-- developers debug, use /run br.data.settings[br.selectedSpec].toggles["isDebugging"] = true
br.debug = {}
-- Cache all non-nil return values from GetSpellInfo in a table to improve performance
local spellcache = setmetatable({}, {__index=function(t,v) local a = {GetSpellInfo(v)} if GetSpellInfo(v) then t[v] = a end return a end})
local function GetSpellInfo(a)
    return unpack(spellcache[a])
end
-- Custom Print
function br.debug:Print(message)
	if br.data.settings[br.selectedSpec].toggles["isDebugging"] == true then
		Print(message)
	end
end
-- Run
function br:Run()
	if br.selectedSpec == nil then br.selectedSpec = select(2,GetSpecializationInfo(GetSpecialization())) end
	-- rc = LibStub("LibRangeCheck-2.0")
	-- minRange, maxRange = rc:GetRange('target')
	--[[Init the readers codes (System/Reader.lua)]]
	-- combat log
	br.read.combatLog()
	-- other readers
	br.read.commonReaders()
	-- Globals
	classColors = {
		[1]				= {class = "Warrior", 		B=0.43,	G=0.61,	R=0.78,	hex="|cffc79c6e"},
		[2]				= {class = "Paladin", 		B=0.73,	G=0.55,	R=0.96,	hex="|cfff58cba"},
		[3]				= {class = "Hunter",		B=0.45,	G=0.83,	R=0.67,	hex="|cffabd473"},
		[4]				= {class = "Rogue",			B=0.41,	G=0.96,	R=1,	hex="|cfffff569"},
		[5]				= {class = "Priest",		B=1,	G=1,	R=1,	hex="|cffffffff"},
		[6]				= {class = "Deathknight",	B=0.23,	G=0.12,	R=0.77,	hex="|cffc41f3b"},
		[7]				= {class = "Shaman",		B=0.87,	G=0.44,	R=0,	hex="|cff0070de"},
		[8]				= {class = "Mage",			B=0.94,	G=0.8,	R=0.41,	hex="|cff69ccf0"},
		[9]				= {class = "Warlock", 		B=0.79,	G=0.51,	R=0.58,	hex="|cff9482c9"},
		[10]			= {class = "Monk",			B=0.59,	G=1,	R=0,	hex="|cff00ff96"},
		[11]			= {class = "Druid", 		B=0.04,	G=0.49,	R=1,	hex="|cffff7d0a"},
		[12] 			= {class = "Demonhunter", 	B=0.79, G=0.19, R=0.64, hex="|cffa330c9"},
	}
	br.classColor = classColors[select(3,UnitClass("player"))].hex
	qualityColors = {
		blue = "0070dd",
		green = "1eff00",
		white = "ffffff",
		grey = "9d9d9d"
	}
	-- load common used stuff on first load
 	br:loadSettings()
	-- add minimap fire icon
	br:MinimapButton()
	-- build up UI
	TogglesFrame()
	-- Build up pulse frame (hearth)
	if not br.loadedIn then
		br:Engine()
		ChatOverlay("-= BadRotations Loaded =-")
		Print("Loaded")
		br.loadedIn = true
	end
end

-- Load Settings
function br:loadSettings()
	-- Base Settings
	if br.data == nil then br.data = {} end
	if br.data.settings == nil then
		br.data.settings = {
			mainButton = {
				pos = {
					anchor = "CENTER",
					x = -75,
					y = -200
				}
			},
			buttonSize = 32,
			font = "Fonts/arialn.ttf",
			fontsize = 16,
			wiped = true,
		}
	end
	-- Settings Per Spec
    if br.data.settings[br.selectedSpec] == nil then br.data.settings[br.selectedSpec] = {} end
	if br.data.settings[br.selectedSpec].toggles == nil then br.data.settings[br.selectedSpec].toggles = {} end
    if br.data.settings[br.selectedSpec]["RotationDrop"] == nil then
        br.selectedProfile = 1
    else
        br.selectedProfile = br.data.settings[br.selectedSpec]["RotationDrop"]
    end
    if br.data.settings[br.selectedSpec][br.selectedProfile] == nil then br.data.settings[br.selectedSpec][br.selectedProfile] = {} end
end