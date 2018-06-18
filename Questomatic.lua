-----------------------------------------------------------
-- Name: Questomatic
-- Author: Witnessthis
-- WoW version: 1.12.1
-- Description: World of Warcraft Addon to automatically deliver and accept quests.
--
-----------------------------------------------------------

-----------------------------------------------------------
-- Default variable assignments
-----------------------------------------------------------
debug_enabled = false
events_on = true
quest_level_preamble_pattern = "^%[[%d%?%+%-]+%]% "


-----------------------------------------------------------
-- WoW environment functions
-----------------------------------------------------------
function ListAddons()
	numAddons = GetNumAddOns()
	for i=1, numAddons, 1 do
		name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(i)
		print({msg="ListAddons: GetAddOnInfo "..tostring(name), debug=debug_enabled})
	end
	PrintReturns(GetAddOnInfo("Questomatic"))
end

function DisableQuestomatic(frame)
	UnregisterEvents(frame)
end

function EnableQuestomatic(frame)
	RegisterEvents(frame)
end


-----------------------------------------------------------
-- Print functions
-----------------------------------------------------------
-- Mainly used for debugging purposes
function PrintReturns(...)
	print({msg="PrintReturns: length "..tostring(arg.n), debug=debug_enabled})
	if(arg.n == 0) then
		return
	end
	for i=1, arg.n, 1 do
		print({msg="PrintReturns: arg"..tostring(i).." "..tostring(arg[i]), debug=debug_enabled})
	end
end

function print(t)
	setmetatable(t,{__index={msg="test ",debug=false}})
	if t.debug then
		DEFAULT_CHAT_FRAME:AddMessage(t.msg)
	end
end

function dbgprint(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg)
end


-----------------------------------------------------------
-- Quest info functions
-----------------------------------------------------------
function GetQuestStatus(questname)
	local i = 1
	while GetQuestLogTitle(i) do
		local questTitle, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(i)
		if (not isHeader) then
			print({msg="GetQuestStatus: Got:  '"..tostring(questTitle).."'  Expected: '"..tostring(questname).."'", debug=debug_enabled})
			if(questTitle == questname) then
				return true, isComplete
			end
		end
		i = i + 1
	end
	print({msg="GetQuestStatus: Quest "..tostring(questname).." not tracked. Completed="..tostring(isComplete), debug=debug_enabled})
	return false, isComplete
end

function GetGossipQuestName(gossip_index, ...)
	print({msg="GetGossipQuestName: arg"..gossip_index.." "..tostring(arg[(gossip_index-1)*2+1]), debug=debug_enabled})
	return arg[(gossip_index-1)*2+1] -- imitate zero indexing
end

function GetNumGossipQuests(...)
	return arg.n/2
end


-----------------------------------------------------------
-- Turn in and accept quest functions
-----------------------------------------------------------
function TurnInActiveGossipQuests()
	local numActiveGossipQuests = GetNumGossipQuests(GetGossipActiveQuests())
	print({msg="TurnInActiveGossipQuests: numActiveGossipQuests "..tostring(numActiveGossipQuests), debug=debug_enabled})
	for i=1, numActiveGossipQuests, 1 do
		QuestLogName, _ = gsub(GetGossipQuestName(i, GetGossipActiveQuests()), quest_level_preamble_pattern, "")
		isTracked, isComleted = GetQuestStatus(QuestLogName)
		print({msg="TurnInActiveGossipQuests: isTracked "..tostring(isTracked).." isCompleted "..tostring(isCompleted), debug=debug_enabled})
		if ((isTracked and isComleted) or isComleted) then
			SelectGossipActiveQuest(i)
			CompleteQuest()
			GetQuestReward(QuestFrameRewardPanel.itemChoice)
		end
	end
end

function AcceptAvailableGossipQuests()
	local numAvailableGossipQuests = GetNumGossipQuests(GetGossipAvailableQuests())
	print({msg="AcceptAvailableGossipQuests: numAvailableGossipQuests "..tostring(numAvailableGossipQuests), debug=debug_enabled})
	for i=1, numAvailableGossipQuests, 1 do
		_, numQuests = GetNumQuestLogEntries();
		if (numQuests < 20) then
			SelectGossipAvailableQuest(i)
			AcceptQuest()
		else
			print({msg="Quest log full", debug=true})
		end
	end
end

function TurnInActiveQuests()
	local numActiveQuests = GetNumActiveQuests()
	print({msg="TurnInActiveQuests: numActiveQuests "..numActiveQuests, debug=debug_enabled})
	for i=1, numActiveQuests, 1 do
		QuestLogName, _ = gsub(GetActiveTitle(i), quest_level_preamble_pattern, "")
		isTracked, isComleted = GetQuestStatus(QuestLogName)
		print({msg="TurnInActiveQuests: isTracked "..tostring(isTracked).." isCompleted "..tostring(isCompleted), debug=debug_enabled})
		if ((isTracked and isComleted) or isComleted) then
			SelectActiveQuest(i)
		end
	end
end

function AcceptAvailableQuests()
	local numAvailableQuests = GetNumAvailableQuests()
	print({msg="AcceptAvailableQuests: numAvailableQuests "..numAvailableQuests, debug=debug_enabled})
	_, numQuests = GetNumQuestLogEntries();
	for i=1, numAvailableQuests, 1 do
		if (numQuests < 20) then
			SelectAvailableQuest(i)
		else
			print({msg="Quest log full", debug=true})
		end
	end
end


-----------------------------------------------------------
-- Register Events
-----------------------------------------------------------
function RegisterEvents(frame)
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:RegisterEvent("QUEST_PROGRESS")
	frame:RegisterEvent("QUEST_COMPLETE")
	frame:RegisterEvent("GOSSIP_SHOW")
	frame:RegisterEvent("QUEST_GREETING")
	frame:RegisterEvent("QUEST_DETAIL")
end

function UnregisterEvents(frame)
	frame:UnregisterEvent("PLAYER_LOGIN")
	frame:UnregisterEvent("QUEST_PROGRESS")
	frame:UnregisterEvent("QUEST_COMPLETE")
	frame:UnregisterEvent("GOSSIP_SHOW")
	frame:UnregisterEvent("QUEST_GREETING")
	frame:UnregisterEvent("QUEST_DETAIL")
end

local frame = CreateFrame("Frame")
RegisterEvents(frame)


-----------------------------------------------------------
-- Event Handler
-----------------------------------------------------------
local function eventHandler(...)
	if (event == "PLAYER_LOGIN") then
		print({msg="|cfffc8014Q|cfffc8414u|cfffc8814e|cfffc8b14s|cfffc9314t|cfffc9b14o|cfffc9f14m|cfffca314a|cfffcaa14t|cfffcae14i|cfffcb614c |cfffcc214l|cfffcc514o|cfffcc914a|cfffccd14d|cfffcd514e|cfffcdd14d|cfffce414.  |cfffc9b14/qm -h for help|r", debug=true})

	elseif	(event == "QUEST_PROGRESS") then
		print({msg="Got "..event.." event", debug=debug_enabled})
		QuestLogName, _ = gsub(GetTitleText(), quest_level_preamble_pattern, "")
		isTracked, isCompleted = GetQuestStatus(QuestLogName)
		print({msg="isTracked "..tostring(isTracked).." isCompleted "..tostring(isCompleted), debug=debug_enabled})
		if ((isTracked and isCompleted) or isCompleted) then -- We should have already checked this, but just to be safe.
			CompleteQuest();
		end

	elseif	(event == "QUEST_COMPLETE") then
		print({msg="Got "..event.." event", debug=debug_enabled})
		QuestLogName, _ = gsub(GetTitleText(), quest_level_preamble_pattern, "")
		isTracked, _ = GetQuestStatus(QuestLogName)
		print({msg="isTracked "..tostring(isTracked), debug=debug_enabled})
		if (isTracked) then -- isCompleted may be nil here, but it's ok. We did get the dialog after all.
			numQuestChoices = GetNumQuestChoices()
			print({msg="numQuestChoices "..tostring(numQuestChoices), debug=debug_enabled})
			if (numQuestChoices == 0) then
				GetQuestReward()
			end
		end

	elseif	(event == "GOSSIP_SHOW") then
		print({msg="Got "..event.." event", debug=debug_enabled})

		TurnInActiveGossipQuests()
		AcceptAvailableGossipQuests()

	elseif	(event == "QUEST_DETAIL") then
		print({msg="Got "..event.." event", debug=debug_enabled})
		_, numQuests = GetNumQuestLogEntries();
		if (numQuests < 20) then
			AcceptQuest()
		else
			print({msg="eventHandler: Quest log full ", debug=debug_enabled})
		end

	elseif	(event == "QUEST_GREETING") then
		print({msg="Got "..event.." event", debug=debug_enabled})
		TurnInActiveQuests(numActiveQuests)
		AcceptAvailableQuests(numAvailableQuests)
	end
end

frame:SetScript("OnEvent", eventHandler)


-----------------------------------------------------------
-- Slash command handler
-----------------------------------------------------------
SLASH_QM1 = "/qm"
SLASH_QM2 = "/questomatic"
SlashCmdList["QM"] = function(msg)
	if (msg == "-h" or msg == "--help") then
		print({msg="|cfffc9b14/qm (-h, --help | -d, --debug)|r", debug=true})
		print({msg="|cfffc9b14/qm  Toggle Questomatic on/off|r", debug=true})
		print({msg="|cfffc9b14/qm -h, --help  Prints Questomatic CLI overview.|r", debug=true})
		print({msg="|cfffc9b14/qm -d, --debug  Turn debug printing on/off|r", debug=true})
	elseif (msg == "-d" or msg == "--debug") then
		debug_enabled = not debug_enabled
		if (debug_enabled) then
			print({msg="|cfffc9b14Questomatic: Debug enabled|r", debug=true})
		else
			print({msg="|cfffc9b14Questomatic: Debug disabled|r", debug=true})
		end
	else
		if (events_on) then
			print({msg="|cfffc9b14Questomatic off|r", debug=true})
			events_on = not events_on
			DisableQuestomatic(frame)
		else
			print({msg="|cfffc9b14Questomatic on|r", debug=true})
			events_on = not events_on
			EnableQuestomatic(frame)
		end
	end
end