-----------------------------------------------------------
-- Name: Questomatic
-- Author: Witnessthis
-- WoW version: 1.13.2
-- Description: World of Warcraft Addon to automatically deliver and accept quests.
--
-----------------------------------------------------------

local qm_ns = {}

-----------------------------------------------------------
-- Default variable assignments
-----------------------------------------------------------
debug_enabled = false
events_on = true

-----------------------------------------------------------
-- WoW environment functions
-----------------------------------------------------------
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
function qm_ns:write(t)
    setmetatable(t,{__index={msg="test ",debug=false}})
    if t.debug then
        print(t.msg)
    end
end


-----------------------------------------------------------
-- Quest info functions
-----------------------------------------------------------
function qm_ns.GetQuestStatus(questname)
    local i = 1
    while GetQuestLogTitle(i) do
        local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory, isHidden, isScaling = GetQuestLogTitle(i)
        if (not isHeader) then
            qm_ns:write({msg="GetQuestStatus: Got:  '"..tostring(title).."'  Expected: '"..tostring(questname).."'", debug=debug_enabled})
            if(title == questname) then
                isComplete = IsQuestComplete(questID)
                return true, isComplete
            end
        end
        i = i + 1
    end
    qm_ns:write({msg="GetQuestStatus: Quest "..tostring(questname).." not tracked. Completed="..tostring(isComplete), debug=debug_enabled})
    return false, isComplete
end


-----------------------------------------------------------
-- Turn in and accept quest functions
-----------------------------------------------------------
function qm_ns.TurnInActiveGossipQuests()
    local numActiveQuests = GetNumGossipActiveQuests()
    qm_ns:write({msg="TurnInActiveGossipQuests: numActiveQuests "..tostring(numActiveQuests), debug=debug_enabled})
    local quests = {GetGossipActiveQuests()}
    for i = 1, numActiveQuests, 1 do
        local title = quests[(i-1)*6+1] -- Select nr 1 outof every 6th argument, title.
        local isTracked, isComplete = qm_ns.GetQuestStatus(title)
        qm_ns:write({msg="TurnInActiveGossipQuests: isTracked "..tostring(isTracked), debug=debug_enabled})
        qm_ns:write({msg="TurnInActiveGossipQuests: isCompleted "..tostring(isComplete), debug=debug_enabled})
        if (isTracked and isComplete) then
            SelectGossipActiveQuest(i)
        end
    end
    qm_ns:write({msg="TurnInActiveGossipQuests: returning", debug=debug_enabled})
end

function qm_ns.AcceptAvailableGossipQuests()
    local numNewQuests = GetNumGossipAvailableQuests()
    local quests = {GetGossipAvailableQuests()}
    qm_ns:write({msg="AcceptAvailableGossipQuests: numNewQuests "..tostring(numNewQuests), debug=debug_enabled})
    for i=1, numNewQuests, 1 do
        local isRepeatable = quests[(i-1)*7+5] -- select every 5th out of 7 arguments, isRepeatable.
        if not isRepeatable then
            _, numQuests = GetNumQuestLogEntries();
            if (numQuests < 25) then
                SelectGossipAvailableQuest(i)
            else
                DeclineQuest()
                qm_ns:write({msg="|cfffc9b14Quest log full|r", debug=true})
            end
        end
    end
    qm_ns:write({msg="AcceptAvailableGossipQuests: returning", debug=debug_enabled})
end

function qm_ns.TurnInActiveQuests()
    local numActiveQuests = GetNumActiveQuests()
    qm_ns:write({msg="TurnInActiveQuests: numActiveQuests "..numActiveQuests, debug=debug_enabled})
    for i=1, numActiveQuests, 1 do
        QuestName = GetActiveTitle(i)
        isTracked, isComplete = qm_ns.GetQuestStatus(QuestName)
        qm_ns:write({msg="TurnInActiveQuests: isTracked "..tostring(isTracked).." isComplete "..tostring(isComplete), debug=debug_enabled})
        if (isTracked and isComplete) then
            SelectActiveQuest(i)
        end
    end
    qm_ns:write({msg="TurnInActiveQuests: returning", debug=debug_enabled})
end

function qm_ns.AcceptAvailableQuests()
    local numAvailableQuests = GetNumAvailableQuests()
    qm_ns:write({msg="AcceptAvailableQuests: numAvailableQuests "..numAvailableQuests, debug=debug_enabled})
    for i=1, numAvailableQuests, 1 do
        SelectAvailableQuest(i)
    end
    qm_ns:write({msg="AcceptAvailableQuests: returning", debug=debug_enabled})
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
function qm_ns.eventHandler(self, event, ...)
    if not IsShiftKeyDown() then
        if (event == "PLAYER_LOGIN") then
            qm_ns:write({msg="|cfffc8014Q|cfffc8414u|cfffc8814e|cfffc8b14s|cfffc9314t|cfffc9b14o|cfffc9f14m|cfffca314a|cfffcaa14t|cfffcae14i|cfffcb614c |cfffcc214l|cfffcc514o|cfffcc914a|cfffccd14d|cfffcd514e|cfffcdd14d|cfffce414.  |cfffc9b14/qm -h for help|r", debug=true})
            qm_ns:write({msg="End "..event.." event", debug=debug_enabled})
        elseif (event == "QUEST_PROGRESS") then
            qm_ns:write({msg="Got "..event.." event", debug=debug_enabled})
            --isQuestComplete()?
            completable = IsQuestCompletable()
            qm_ns:write({msg="completable "..tostring(completable), debug=debug_enabled})
            if (completable) then
                CompleteQuest();
            end
            qm_ns:write({msg="End "..event.." event", debug=debug_enabled})
        elseif (event == "QUEST_COMPLETE") then
            qm_ns:write({msg="Got "..event.." event", debug=debug_enabled})
            local questID = GetQuestID()
            local isComplete = IsQuestComplete(questID)
            qm_ns:write({msg="isComplete "..tostring(isComplete), debug=debug_enabled})
            if (isComplete) then
                numQuestChoices = GetNumQuestChoices()
                qm_ns:write({msg="numQuestChoices "..tostring(numQuestChoices), debug=debug_enabled})
                if (numQuestChoices == 0) then
                    GetQuestReward()
                end
            end
            qm_ns:write({msg="End "..event.." event", debug=debug_enabled})
        elseif (event == "GOSSIP_SHOW") then
            qm_ns:write({msg="Got "..event.." event", debug=debug_enabled})
            qm_ns.TurnInActiveGossipQuests()
            qm_ns.AcceptAvailableGossipQuests()
            qm_ns:write({msg="End "..event.." event", debug=debug_enabled})
        elseif (event == "QUEST_DETAIL") then
            qm_ns:write({msg="Got "..event.." event", debug=debug_enabled})
            _, numQuests = GetNumQuestLogEntries();
            if (numQuests < 25) then
                AcceptQuest()
            else
                qm_ns:write({msg="|cfffc9b14Quest log full|r", debug=true})
            end
            qm_ns:write({msg="End "..event.." event", debug=debug_enabled})
        elseif (event == "QUEST_GREETING") then
            qm_ns:write({msg="Got "..event.." event", debug=debug_enabled})
            qm_ns.TurnInActiveQuests()
            qm_ns.AcceptAvailableQuests()
            qm_ns:write({msg="End "..event.." event", debug=debug_enabled})
        end
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
        qm_ns:write({msg="|cfffc9b14/qm (-h, --help | -d, --debug)|r", debug=true})
        qm_ns:write({msg="|cfffc9b14Hold shift when talking to a questgiver to disable Questomatic.|r", debug=true})
        qm_ns:write({msg="|cfffc9b14/qm  Toggle Questomatic on/off|r", debug=true})
        qm_ns:write({msg="|cfffc9b14/qm -h, --help  Prints Questomatic CLI overview.|r", debug=true})
        qm_ns:write({msg="|cfffc9b14/qm -d, --debug  Turn debug writeing on/off|r", debug=true})
    elseif (msg == "-d" or msg == "--debug") then
        debug_enabled = not debug_enabled
        if (debug_enabled) then
            qm_ns:write({msg="|cfffc9b14Questomatic: Debug enabled|r", debug=true})
        else
            qm_ns:write({msg="|cfffc9b14Questomatic: Debug disabled|r", debug=true})
        end
    else
        if (events_on) then
            qm_ns:write({msg="|cfffc9b14Questomatic off|r", debug=true})
            events_on = not events_on
            qm_ns.DisableQuestomatic(qm_ns.frame)
        else
            qm_ns:write({msg="|cfffc9b14Questomatic on|r", debug=true})
            events_on = not events_on
            qm_ns.EnableQuestomatic(qm_ns.frame)
        end
    end
end
