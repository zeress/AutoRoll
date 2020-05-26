-- COMMANDS
SLASH_AR1 = '/ar'; 
SLASH_AR2 = '/autoroll'; 

SlashCmdList["AR"] = function(msg) 
    local cmd = msg:lower()

    local rule = string.match(cmd, "^(%S*)")
    local itemIdString = AutoRollUtils:getItemId(cmd)

    if (rule == "enable") then
        AutoRoll_PCDB["enabled"] = true
        print("AutoRoll Enabled.")
        return
    end

    if (rule == "disable") then
        AutoRoll_PCDB["enabled"] = false
        print("AutoRoll Disabled.")
        return
    end

    if (rule == "need") or (rule == "greed") or (rule == "pass") then
        -- Item Rarity + Item Type Rules
        if AutoRoll.CheckRuleCombinations(cmd, rule) then
            return
        end

        -- Item Type Rules
        if AutoRoll.CheckItemType(cmd, rule) then
            return
        end

        -- Item Rarity Rules
        if AutoRoll.CheckItemRarity(cmd, rule) then
            return
        end

        -- Item Link Rules
        if itemIdString then 
            AutoRoll.SaveRule(itemIdString, rule)
        end

        -- Zul'Gurub Coins
        if string.match(cmd, "coins") then
            for index,itemId in ipairs(AutoRoll.COIN_IDS) do
                AutoRoll.SaveRule(itemId, rule)
            end
        end

        -- Zul'Gurub Bijous
        if string.match(cmd, "bijous") then
            for index,itemId in ipairs(AutoRoll.BIJOUS_IDS) do
                AutoRoll.SaveRule(itemId, rule)
            end
        end
    end

    if (rule == "reset") or (rule == "ignore") or (rule == "clear") or (rule == "remove") then
        if itemIdString then 
            AutoRoll.SaveRule(itemIdString, nil)
            return
        end

        if string.match(cmd, "coins") then
            for index,itemId in ipairs(AutoRoll.COIN_IDS) do
                AutoRoll.SaveRule(itemId, nil)
            end
            return
        end

        if string.match(cmd, "bijous") then
            for index,itemId in ipairs(AutoRoll.BIJOUS_IDS) do
                AutoRoll.SaveRule(itemId, nil)
            end
            return
        end

        if string.match(cmd, "all rules") then
            local rules = AutoRoll_PCDB["rules"]

            for itemId,ruleNum in pairs(rules) do
                if itemId then
                    AutoRoll.SaveRule(itemId, nil)
                end
            end

            AutoRoll_PCDB["rules"] = {}
            return
        end
    end

    if cmd == "printing" then
        local willPrint = not AutoRoll_PCDB["printRolls"] 

        if willPrint then
            print("AutoRoll - Printing ENABLED") 
        else
            print("AutoRoll - Printing DISABLED") 
        end

        AutoRoll_PCDB["printRolls"] = willPrint
        return
    end

    if cmd == "debug" then
        local willDebug = not AutoRoll_PCDB["debug"] 

        if willDebug then
            print("AutoRoll - Debug ENABLED") 
        else
            print("AutoRoll - Debug DISABLED") 
        end

        AutoRoll_PCDB["debug"] = willDebug
        AutoRoll.RollHistory.ConfigDebugButton()
        return
    end

    if cmd == "filter rolls" then
        local willFilter = not AutoRoll_PCDB["filterRolls"] 

        if willFilter then
            print("AutoRoll - Filtering rolls ENABLED") 
        else
            print("AutoRoll - Filtering rolls DISABLED") 
        end

        AutoRoll_PCDB["filterRolls"] = willFilter
        return
    end

    if cmd == "rules" then
        print("AutoRoll Rules")

        local rules = AutoRoll_PCDB["rules"]
        if rules then           
            local count = 0

            for itemId,ruleNum in pairs(rules) do
                local _, itemLink = GetItemInfo(itemId)
                local rule = AutoRollUtils:getRuleString(ruleNum)

                if rule then
                    print(rule:upper().." on "..(itemLink or "item:"..itemId))
                end
                count = count + 1
            end

            if count == 0 then
                print("-- You haven't added any rules yet.")
                print("-- Use the following commands: ")
                print("--       /ar to show roll history")
                print("--       /ar NEED [item-link]")
                print("--       /ar GREED [item-link]")
                print("--       /ar PASS [item-link]")
                print("--       /ar CLEAR [item-link]")
            end
        end

        return
    end

    -- No rules matched, show history
    AutoRoll.RollHistory.Show()

end
