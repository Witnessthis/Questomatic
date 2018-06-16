
function GetQuestStatus(questname)
	local i = 1
	while GetQuestLogTitle(i) do
		local questTitle, level, questTag, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle(i)
		print({msg="GetQuestStatus: Got:  '"..tostring(questTitle).."'  Expected: '"..tostring(questname).."'", debug=debug_enabled})
		if(questTitle == questname) then
			return true, isComplete
		end
		i = i + 1
	end
	print({msg="GetQuestStatus: Quest "..tostring(questname).." not tracked.", debug=debug_enabled})
	return false, nil
end

function GetGossipQuestName(gossip_index, ...)
	print({msg="GetGossipQuestName: arg"..gossip_index.." "..tostring(arg[(gossip_index-1)*2+1]), debug=debug_enabled})
	return arg[(gossip_index-1)*2+1] -- imitate zero indexing
end

function GetNumGossipQuests(...)
	return arg.n/2
end

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

function TurnInActiveGossipQuests()
	local numActiveGossipQuests = GetNumGossipQuests(GetGossipActiveQuests())
	print({msg="TurnInActiveGossipQuests: numActiveGossipQuests "..tostring(numActiveGossipQuests), debug=debug_enabled})
	for i=1, numActiveGossipQuests, 1 do
		QuestLogName, _ = gsub(GetGossipQuestName(i, GetGossipActiveQuests()), "^%[[%d%?%+]+%]% ", "")
		isTracked, _ = GetQuestStatus(QuestLogName)
		if (isTracked) then
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
		SelectGossipAvailableQuest(i)
		AcceptQuest()
	end
end

function TurnInActiveQuests()
	local numActiveQuests = GetNumActiveQuests()
	print({msg="TurnInActiveQuests: numActiveQuests "..numActiveQuests, debug=debug_enabled})
	for i=1, numActiveQuests, 1 do
		QuestLogName, _ = gsub(GetActiveTitle(i), "^%[[%d%?%+]+%]% ", "")
		isTracked, isComleted = GetQuestStatus(QuestLogName)
		print({msg="TurnInActiveQuests: isComleted "..tostring(isComleted), debug=debug_enabled})
		if ((isTracked and isComleted) or isComleted) then
			SelectActiveQuest(i)
		end
	end
end

function AcceptAvailableQuests()
	local numAvailableQuests = GetNumAvailableQuests()
	print({msg="AcceptAvailableQuests: numAvailableQuests "..numAvailableQuests, debug=debug_enabled})
	for i=1, numAvailableQuests, 1 do
		SelectAvailableQuest(i)
	end
end

debug_enabled = false

SLASH_QM1 = "/qm"
SLASH_QM2 = "/questomatic"
SlashCmdList["QM"] = function(msg)
	if (msg == "-d") then
		debug_enabled = not debug_enabled
		if (debug_enabled) then
			print({msg="|cfffc9b14/qm -d Debug enabled|r", debug=true})
		else
			print({msg="|cfffc9b14/qm -d Debug disabled|r", debug=true})
		end
	else
		print({msg="|cfffc9b14/qm [-d]|r", debug=true})
		print({msg="|cfffc9b14-d Turn debug printing on/off|r", debug=true})
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("QUEST_PROGRESS")
frame:RegisterEvent("QUEST_COMPLETE")
frame:RegisterEvent("GOSSIP_SHOW")
frame:RegisterEvent("QUEST_GREETING")
frame:RegisterEvent("QUEST_DETAIL")

local function eventHandler(...)
	if (event == "PLAYER_LOGIN") then
		print({msg="|cfffc8014Q|cfffc8414u|cfffc8814e|cfffc8b14s|cfffc9314t|cfffc9b14o|cfffc9f14m|cfffca314a|cfffcaa14t|cfffcae14i|cfffcb614c |cfffcc214l|cfffcc514o|cfffcc914a|cfffccd14d|cfffcd514e|cfffcdd14d|cfffce414.  |cfffc9b14/qm|r", debug=true})

	elseif	(event == "QUEST_PROGRESS") then
		print({msg="Got "..event.." event", debug=debug_enabled})
		QuestLogName, _ = gsub(GetTitleText(), "^%[[%d%?%+]+%]% ", "")
		isTracked, isCompleted = GetQuestStatus(QuestLogName)
		if (isTracked and isCompleted) then
			CompleteQuest();
		end

	elseif	(event == "QUEST_COMPLETE") then
		print({msg="Got "..event.." event", debug=debug_enabled})
		QuestLogName, _ = gsub(GetTitleText(), "^%[[%d%?%+]+%]% ", "")
		isTracked, _ = GetQuestStatus(QuestLogName)
		if (isTracked) then
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
		AcceptQuest()

	elseif	(event == "QUEST_GREETING") then
		print({msg="Got "..event.." event", debug=debug_enabled})
		TurnInActiveQuests(numActiveQuests)
		AcceptAvailableQuests(numAvailableQuests)
	end
end

frame:SetScript("OnEvent", eventHandler)
