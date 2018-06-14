
QUEST_BLACKLIST = {"[19+] Battle of Warsong Gulch",
					"[?] Past Victories in Arathi",
					"[?] Past Victories in Warsong Gulch",
					"[?] Past efforts in Warsong Gulch"}

function Questomatic_OnLoad()
	this:RegisterEvent("QUEST_PROGRESS");
	this:RegisterEvent("QUEST_COMPLETE");
	this:RegisterEvent("GOSSIP_SHOW");
	this:RegisterEvent("QUEST_GREETING");
	this:RegisterEvent("QUEST_DETAIL");

	print("Questomatic loaded.")
end

function Questomatic_Quest_engine()
	local numActiveGossipQuests = GetNumGossipQuests(GetGossipActiveQuests())
	print("numActiveGossipQuests "..numActiveGossipQuests)
	if(numActiveGossipQuests > 0) then
		for i=1, numActiveGossipQuests, 1 do
			SelectGossipActiveQuest(i)
			CompleteQuest()
			print("GetNumQuestChoices "..GetNumQuestChoices())
			GetQuestReward(QuestFrameRewardPanel.itemChoice)
		end
	else
		CompleteQuest()
		GetQuestReward(QuestFrameRewardPanel.itemChoice)
	end

	local numAvailableGossipQuests = GetNumGossipQuests(GetGossipAvailableQuests())
	print("numAvailableGossipQuests "..numAvailableGossipQuests)
	if(numAvailableGossipQuests > 0) then
		for i=1, numAvailableGossipQuests, 1 do
			SelectGossipAvailableQuest(i)
			AcceptQuest()
		end
	else
		AcceptQuest()
		GetQuestReward()
	end
end

function Questomatic_OnEvent(event, message)
	if(AreQuestsBlacklisted(GetGossipActiveQuests()) ~= true) then
		if	(event == "QUEST_PROGRESS") then
			print("Got QUEST_PROGRESS event")

			CompleteQuest();
		elseif	(event == "QUEST_COMPLETE") then
			print("Got QUEST_COMPLETE event")
			if (GetNumQuestChoices() > 0) then
				GetQuestReward(QuestFrameRewardPanel.itemChoice);
			else
				GetQuestReward();
			end
		elseif	(event == "GOSSIP_SHOW" or "QUEST_DETAIL") then
			print("Got "..event.." event")
			Questomatic_Quest_engine()
		elseif	(event == "QUEST_GREETING") then
			print("Got QUEST_GREETING event")

		end
	end
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

function PrintReturns(...)
	if(arg.n == 0) then
		return
	end
	print("length "..arg.n)
	for i=1, arg.n, 1 do
		print("arg"..i.." "..arg[i])
	end
end

function print(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg)
end