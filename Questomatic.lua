-----------------------------------------------------------
-- Name: Questomatic
-- Author: Witnessthis
-- WoW version: 1.12.1
-- Description: World of Warcraft Addon to automatically deliver and accept quests.
--
-----------------------------------------------------------

local qm_ns = {}

-----------------------------------------------------------
-- Default variable assignments
-----------------------------------------------------------
debug_enabled = false
events_on = true
quest_level_preamble_pattern = "^%[[%d%?%+%-]+%]% "


-----------------------------------------------------------
-- WoW environment functions
-----------------------------------------------------------
function qm_ns.ListAddons()
	numAddons = GetNumAddOns()
	for i=1, numAddons, 1 do
		name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(i)
		qm_ns:print({msg="ListAddons: GetAddOnInfo "..tostring(name), debug=debug_enabled})
	end
	qm_ns.PrintReturns(GetAddOnInfo("Questomatic"))
end

function qm_ns.DisableQuestomatic(frame)
	qm_ns.UnregisterEvents(frame)
end

function qm_ns.EnableQuestomatic(frame)
	qm_ns.RegisterEvents(frame)
end


-----------------------------------------------------------
-- Print functions
-----------------------------------------------------------
-- Mainly used for debugging purposes
function qm_ns.PrintReturns(...)
	qm_ns:print({msg="PrintReturns: length "..tostring(arg.n), debug=debug_enabled})
	if(arg.n == 0) then
		return
	end
	for i=1, arg.n, 1 do
		qm_ns:print({msg="PrintReturns: arg"..tostring(i).." "..tostring(arg[i]), debug=debug_enabled})
	end
end

function qm_ns:print(t)
	setmetatable(t,{__index={msg="test ",debug=false}})
	if t.debug then
		DEFAULT_CHAT_FRAME:AddMessage(t.msg)
	end
end

function qm_ns.dbgprint(msg)
	DEFAULT_CHAT_FRAME.AddMessage(tostring(msg))
end


-----------------------------------------------------------
-- Debug functions
-----------------------------------------------------------
function qm_ns.wait(seconds)
	local start = time()
	while start + seconds > time() do
	end
	qm_ns:print({msg="done waiting for "..tostring(seconds), debug=debug_enabled})
end


-----------------------------------------------------------
-- Quest info functions
-----------------------------------------------------------
function qm_ns.GetQuestStatus(questname)
	local i = 1
	while GetQuestLogTitle(i) do
		local questTitle, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(i)
		if (not isHeader) then
			qm_ns:print({msg="GetQuestStatus: Got:  '"..tostring(questTitle).."'  Expected: '"..tostring(questname).."'", debug=debug_enabled})
			if(questTitle == questname) then
				return true, isComplete
			end
		end
		i = i + 1
	end
	qm_ns:print({msg="GetQuestStatus: Quest "..tostring(questname).." not tracked. Completed="..tostring(isComplete), debug=debug_enabled})
	return false, isComplete
end

function  qm_ns.GetGossipQuestName(gossip_index, ...)
	qm_ns:print({msg="GetGossipQuestName: arg"..gossip_index.." "..tostring(arg[(gossip_index-1)*2+1]), debug=debug_enabled})
	return arg[(gossip_index-1)*2+1] -- imitate zero indexing
end

function qm_ns.GetNumGossipQuests(...)
	return arg.n/2
end


-----------------------------------------------------------
-- Turn in and accept quest functions
-----------------------------------------------------------
function qm_ns.TurnInActiveGossipQuests()
	local numActiveGossipQuests = qm_ns.GetNumGossipQuests(GetGossipActiveQuests())
	qm_ns:print({msg="TurnInActiveGossipQuests: numActiveGossipQuests "..tostring(numActiveGossipQuests), debug=debug_enabled})
	for i=1, numActiveGossipQuests, 1 do
		QuestLogName, _ = gsub(qm_ns.GetGossipQuestName(i, GetGossipActiveQuests()), quest_level_preamble_pattern, "")
		isTracked, isComleted = qm_ns.GetQuestStatus(QuestLogName)
		qm_ns:print({msg="TurnInActiveGossipQuests: isTracked "..tostring(isTracked).." isCompleted "..tostring(isCompleted), debug=debug_enabled})
		if ((isTracked and isComleted) or isComleted) then
			SelectGossipActiveQuest(i)
			CompleteQuest()
			GetQuestReward(QuestFrameRewardPanel.itemChoice)
		end
	end
	qm_ns:print({msg="TurnInActiveGossipQuests: returning", debug=debug_enabled})
end

function qm_ns.AcceptAvailableGossipQuests()
	local numAvailableGossipQuests = qm_ns.GetNumGossipQuests(GetGossipAvailableQuests())
	qm_ns:print({msg="AcceptAvailableGossipQuests: numAvailableGossipQuests "..tostring(numAvailableGossipQuests), debug=debug_enabled})
	for i=1, numAvailableGossipQuests, 1 do
		_, numQuests = GetNumQuestLogEntries();
		if (numQuests < 20) then
			SelectGossipAvailableQuest(i)
			AcceptQuest()
		else
			qm_ns:print({msg="Quest log full", debug=true})
		end
	end
	qm_ns:print({msg="AcceptAvailableGossipQuests: returning", debug=debug_enabled})
end

function qm_ns.TurnInActiveQuests()
	local numActiveQuests = GetNumActiveQuests()
	qm_ns:print({msg="TurnInActiveQuests: numActiveQuests "..numActiveQuests, debug=debug_enabled})
	for i=1, numActiveQuests, 1 do
		QuestLogName, _ = gsub(GetActiveTitle(i), quest_level_preamble_pattern, "")
		isTracked, isComleted = qm_ns.GetQuestStatus(QuestLogName)
		qm_ns:print({msg="TurnInActiveQuests: isTracked "..tostring(isTracked).." isCompleted "..tostring(isCompleted), debug=debug_enabled})
		if ((isTracked and isComleted) or isComleted) then
			SelectActiveQuest(i)
		end
	end
	qm_ns:print({msg="TurnInActiveQuests: returning", debug=debug_enabled})
end

function qm_ns.AcceptAvailableQuests()
	local numAvailableQuests = GetNumAvailableQuests()
	qm_ns:print({msg="AcceptAvailableQuests: numAvailableQuests "..numAvailableQuests, debug=debug_enabled})
	_, numQuests = GetNumQuestLogEntries();
	for i=1, numAvailableQuests, 1 do
		if (numQuests < 20) then
			SelectAvailableQuest(i)
		else
			qm_ns:print({msg="Quest log full", debug=true})
		end
	end
	qm_ns:print({msg="AcceptAvailableQuests: returning", debug=debug_enabled})
end


-----------------------------------------------------------
-- Register Events
-----------------------------------------------------------
function qm_ns.RegisterEvents(frame)
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:RegisterEvent("QUEST_PROGRESS")
	frame:RegisterEvent("QUEST_COMPLETE")
	frame:RegisterEvent("GOSSIP_SHOW")
	frame:RegisterEvent("QUEST_GREETING")
	frame:RegisterEvent("QUEST_DETAIL")
end

function qm_ns.UnregisterEvents(frame)
	frame:UnregisterEvent("PLAYER_LOGIN")
	frame:UnregisterEvent("QUEST_PROGRESS")
	frame:UnregisterEvent("QUEST_COMPLETE")
	frame:UnregisterEvent("GOSSIP_SHOW")
	frame:UnregisterEvent("QUEST_GREETING")
	frame:UnregisterEvent("QUEST_DETAIL")
end

qm_ns.frame = CreateFrame("Frame")
qm_ns.RegisterEvents(qm_ns.frame)


-----------------------------------------------------------
-- Event Handler
-----------------------------------------------------------
function qm_ns.eventHandler(...)
	if (event == "PLAYER_LOGIN") then
		qm_ns:print({msg="|cfffc8014Q|cfffc8414u|cfffc8814e|cfffc8b14s|cfffc9314t|cfffc9b14o|cfffc9f14m|cfffca314a|cfffcaa14t|cfffcae14i|cfffcb614c |cfffcc214l|cfffcc514o|cfffcc914a|cfffccd14d|cfffcd514e|cfffcdd14d|cfffce414.  |cfffc9b14/qm -h for help|r", debug=true})
		qm_ns:print({msg="End "..event.." event", debug=debug_enabled})
	elseif	(event == "QUEST_PROGRESS") then
		qm_ns:print({msg="Got "..event.." event", debug=debug_enabled})
		completable = IsQuestCompletable()
		qm_ns:print({msg="completable "..tostring(completable), debug=debug_enabled})
		if (completable) then
			CompleteQuest();
		end
		qm_ns:print({msg="End "..event.." event", debug=debug_enabled})
	elseif	(event == "QUEST_COMPLETE") then
		qm_ns:print({msg="Got "..event.." event", debug=debug_enabled})
		QuestLogName, _ = gsub(GetTitleText(), quest_level_preamble_pattern, "")
		isTracked, _ = qm_ns.GetQuestStatus(QuestLogName)
		qm_ns:print({msg="isTracked "..tostring(isTracked), debug=debug_enabled})
		if (isTracked) then -- isCompleted may be nil here, but it's ok. We did get the dialog after all.
			numQuestChoices = GetNumQuestChoices()
			qm_ns:print({msg="numQuestChoices "..tostring(numQuestChoices), debug=debug_enabled})
			if (numQuestChoices == 0) then
				GetQuestReward()
			end
		end
		qm_ns:print({msg="End "..event.." event", debug=debug_enabled})
	elseif	(event == "GOSSIP_SHOW") then
		qm_ns:print({msg="Got "..event.." event", debug=debug_enabled})

		qm_ns.TurnInActiveGossipQuests()
		qm_ns.AcceptAvailableGossipQuests()
		qm_ns:print({msg="End "..event.." event", debug=debug_enabled})
	elseif	(event == "QUEST_DETAIL") then
		qm_ns:print({msg="Got "..event.." event", debug=debug_enabled})
		_, numQuests = GetNumQuestLogEntries();
		if (numQuests < 20) then
			AcceptQuest()
		else
			qm_ns:print({msg="eventHandler: Quest log full ", debug=debug_enabled})
		end
		qm_ns:print({msg="End "..event.." event", debug=debug_enabled})
	elseif	(event == "QUEST_GREETING") then
		qm_ns:print({msg="Got "..event.." event", debug=debug_enabled})
		qm_ns.TurnInActiveQuests(numActiveQuests)
		qm_ns.AcceptAvailableQuests(numAvailableQuests)
		qm_ns:print({msg="End "..event.." event", debug=debug_enabled})
	end
end

qm_ns.frame:SetScript("OnEvent", qm_ns.eventHandler)


-----------------------------------------------------------
-- Slash command handler
-----------------------------------------------------------
SLASH_QM1 = "/qm"
SLASH_QM2 = "/questomatic"
SlashCmdList["QM"] = function(msg)
	if (msg == "-h" or msg == "--help") then
		qm_ns:print({msg="|cfffc9b14/qm (-h, --help | -d, --debug)|r", debug=true})
		qm_ns:print({msg="|cfffc9b14/qm  Toggle Questomatic on/off|r", debug=true})
		qm_ns:print({msg="|cfffc9b14/qm -h, --help  Prints Questomatic CLI overview.|r", debug=true})
		qm_ns:print({msg="|cfffc9b14/qm -d, --debug  Turn debug printing on/off|r", debug=true})
	elseif (msg == "-d" or msg == "--debug") then
		debug_enabled = not debug_enabled
		if (debug_enabled) then
			qm_ns:print({msg="|cfffc9b14Questomatic: Debug enabled|r", debug=true})
		else
			qm_ns:print({msg="|cfffc9b14Questomatic: Debug disabled|r", debug=true})
		end
	else
		if (events_on) then
			qm_ns:print({msg="|cfffc9b14Questomatic off|r", debug=true})
			events_on = not events_on
			qm_ns.DisableQuestomatic(qm_ns.frame)
		else
			qm_ns:print({msg="|cfffc9b14Questomatic on|r", debug=true})
			events_on = not events_on
			qm_ns.EnableQuestomatic(qm_ns.frame)
		end
	end
end
