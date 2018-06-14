
function isQuestCompleted(questname)
	local i = 1
	while GetQuestLogTitle(i) do
		local questTitle, level, questTag, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle(i)
		if(questTitle == questname) then
			return isComplete
		end
		i = i + 1
	end
	print({msg="Quest "..questname.." not tracked.", debug=debug_enabled})
	return
end

function GetNumGossipQuests(...)
	return arg.n/2
end

function AreQuestsBlacklisted(...)
	for i=1, arg.n, 2 do
		for j=1, getn(QUEST_BLACKLIST), 1 do
			if(QUEST_BLACKLIST[j] == arg[i]) then
				return true
			end
		end
	end
end

-- Mainly used for debugging purposes
function PrintReturns(...)
	if(arg.n == 0) then
		return
	end
	print({msg="length "..arg.n, debug=debug_enabled})
	for i=1, arg.n, 1 do
		print({msg="arg"..i.." "..tostring(arg[i]), debug=debug_enabled})
	end
end

function print(t)
	setmetatable(t,{__index={msg="test ",debug=false}})
	if t.debug then
		DEFAULT_CHAT_FRAME:AddMessage(t.msg)
	end
end

function TurnInActiveGossipQuests()
	local numActiveGossipQuests = GetNumGossipQuests(GetGossipActiveQuests())
	print({msg="numActiveGossipQuests "..numActiveGossipQuests, debug=debug_enabled})
	for i=1, numActiveGossipQuests, 1 do
		SelectGossipActiveQuest(i)
		CompleteQuest()
		GetQuestReward(QuestFrameRewardPanel.itemChoice)
	end
end

function AcceptAvailableGossipQuests()
	local numAvailableGossipQuests = GetNumGossipQuests(GetGossipAvailableQuests())
	print({msg="numAvailableGossipQuests "..numAvailableGossipQuests, debug=debug_enabled})
	for i=1, numAvailableGossipQuests, 1 do
		SelectGossipAvailableQuest(i)
		AcceptQuest()
	end
end

function TurnInActiveQuests()
	local numActiveQuests = GetNumActiveQuests()
	print({msg="numActiveQuests "..numActiveQuests, debug=debug_enabled})
	for i=1, numActiveQuests, 1 do
		is_comlete = isQuestCompleted(GetActiveTitle(i))
		print({msg="is_comlete "..tostring(is_comlete), debug=debug_enabled})
		if (is_comlete) then
			SelectActiveQuest(i)
		end
	end
end

function AcceptAvailableQuests()
	local numAvailableQuests = GetNumAvailableQuests()
	print({msg="numAvailableQuests "..numAvailableQuests, debug=debug_enabled})
	for i=1, numAvailableQuests, 1 do
		SelectAvailableQuest(i)
	end
end

QUEST_BLACKLIST = {"[19+] Battle of Warsong Gulch",
					"[?] Past Victories in Arathi",
					"[?] Past Victories in Warsong Gulch",
					"[?] Past efforts in Warsong Gulch"}

debug_enabled = false

SLASH_QM1 = "/qm"
SLASH_QM2 = "/questomatic"
SlashCmdList["QM"] = function(msg)
	if (msg == "-d") then
		debug_enabled = not debug_enabled
	else
		print({msg="/qm [-d]", debug=true})
		print({msg="-d Turn debug printing on/off", debug=true})
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
	if(AreQuestsBlacklisted(GetGossipActiveQuests()) ~= true) then
		if (event == "PLAYER_LOGIN") then
			print({msg="Questomatic loaded. /qm", debug=true})

		elseif	(event == "QUEST_PROGRESS") then
			print({msg="Got "..event.." event", debug=debug_enabled})
			CompleteQuest();

		elseif	(event == "QUEST_COMPLETE") then
			print({msg="Got "..event.." event", debug=debug_enabled})
			numQuestChoices = GetNumQuestChoices()
			print({msg="numQuestChoices "..tostring(numQuestChoices), debug=debug_enabled})
			if (numQuestChoices == 0) then
				GetQuestReward()
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
end

frame:SetScript("OnEvent", eventHandler)
