-- COMMANDS
SLASH_AR1 = '/ar'; 
SLASH_AR2 = '/autoroll'; 

SlashCmdList["AR"] = function(msg) 
    local cmd = msg:lower()

    local rule = string.match(cmd, "^(%S*)")
    local itemIdString = AutoRollUtils:getItemId(cmd)

    if (rule == "enable") then
        AutoRoll_Options["enabled"] = true
        print("AutoRoll Enabled.")
        return
    end

    if (rule == "disable") then
        AutoRoll_Options["enabled"] = false
        print("AutoRoll Disabled.")
        return
    end

    if (rule == "need") or (rule == "greed") or (rule == "pass") then
        if itemIdString then 
            AutoRoll.SaveRule(itemIdString, rule)
        end

        if string.match(cmd, "coins") then
            for index,itemId in ipairs(AutoRoll.COIN_IDS) do
                AutoRoll.SaveRule(itemId, rule)
            end
        end

        if string.match(cmd, "bijous") then
            for index,itemId in ipairs(AutoRoll.BIJOUS_IDS) do
                AutoRoll.SaveRule(itemId, rule)
            end
        end
    end

    if (rule == "reset") or (rule == "ignore") or (rule == "clear") or (rule == "remove") then
        if itemIdString then 
            AutoRoll.SaveRule(itemIdString, nil)
        end

        if string.match(cmd, "coins") then
            for index,itemId in ipairs(AutoRoll.COIN_IDS) do
                AutoRoll.SaveRule(itemId, nil)
            end
        end

        if string.match(cmd, "bijous") then
            for index,itemId in ipairs(AutoRoll.BIJOUS_IDS) do
                AutoRoll.SaveRule(itemId, nil)
            end
        end

        if string.match(cmd, "all rules") then
            local rules = AutoRoll_Options["rules"]

            for itemId,ruleNum in pairs(rules) do
                if itemId then
                    AutoRoll.SaveRule(itemId, nil)
                end
            end

            AutoRoll_Options["rules"] = {}
        end
    end

    if cmd == "printing" then
        local willPrint = not AutoRoll_Options["printRolls"] 

        if willPrint then
            print("AutoRoll - Printing ENABLED") 
        else
            print("AutoRoll - Printing DISABLED") 
        end

        AutoRoll_Options["printRolls"] = willPrint
    end

    if cmd == "rules" then
        print("AutoRoll Rules")

        local rules = AutoRoll_Options["rules"]
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
                print("--       /ar NEED [item-link]")
                print("--       /ar GREED [item-link]")
                print("--       /ar PASS [item-link]")
                print("--       /ar CLEAR [item-link]")
            end
        end

    end

end
