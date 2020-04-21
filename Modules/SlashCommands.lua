-- COMMANDS
SLASH_AR1 = '/ar'; 
SLASH_AR2 = '/autoroll'; 

SlashCmdList["AR"] = function(msg) 
    local cmd = msg:lower()

    local rule = string.match(cmd, "^(%S*)")
    local itemIdString = AutoRollUtils:getItemId(cmd)

    if itemIdString then 
        local itemId = tonumber(itemIdString)

        if (rule == "need") or (rule == "greed") or (rule == "pass") then
            AutoRoll.SaveRule(itemId, rule)
        end
        
        if (rule == "reset") or (rule == "ignore") then
            AutoRoll.SaveRule(itemId, nil)
        end
    end

    if cmd == "rules" then
        print("AutoRoll Rules")

        local rules = AutoRoll_Options["rules"]
        local count = 0

        for key,value in pairs(rules) do
            local itemName, itemLink = GetItemInfo(key)
            local rule = AutoRollUtils:getRuleString(value):upper()

            if rule and itemLink then
                print(rule.." on "..itemLink)
            end
            count = count + 1
        end

        if count == 0 then
            print("-- You haven't added any rules yet.")
            print("-- Use the following commands: ")
            print("--       /ar NEED [item-link]")
            print("--       /ar GREED [item-link]")
            print("--       /ar PASS [item-link]")
            print("--       /ar IGNORE [item-link]")
        end

    end

end
