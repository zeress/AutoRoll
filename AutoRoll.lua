-- NAMESPACE / CLASS: AutoRoll   
-- OPTIONS: AutoRoll_Options      

AutoRoll = CreateFrame("Frame")

AutoRoll.COIN_IDS = {
    19698, -- Zulian Coin
    19699, -- Razzashi Coin
    19700, -- Hakkari Coin
    19701, -- Gurubashi Coin
    19702, -- Vilebranch Coin
    19703, -- Witherbark Coin
    19704, -- Sandfury Coin
    19705, -- Skullsplitter Coin
    19706, -- Bloodscalp Coin
}
  
AutoRoll.BIJOUS_IDS = {
    19707, -- Red Hakkari Bijou
    19708, -- Blue Hakkari Bijou
    19709, -- Yellow Hakkari Bijou
    19710, -- Orange Hakkari Bijou
    19711, -- Green Hakkari Bijou
    19712, -- Purple Hakkari Bijou
    19713, -- Bronze Hakkari Bijou
    19714, -- Silver Hakkari Bijou
    19715, -- Gold Hakkari Bijou
}


do -- Private Scope

    local ADDON_NAME = "AutoRoll"

    local defaults = {
        ["rules"] = {},
        ["printRolls"] = false,
        ["enabled"] = true,
    }

    -- REGISTER EVENTS
    AutoRoll:RegisterEvent("ADDON_LOADED")
    AutoRoll:RegisterEvent("START_LOOT_ROLL")
    AutoRoll:RegisterEvent("CONFIRM_LOOT_ROLL")
    AutoRoll:RegisterEvent("PLAYER_ENTERING_WORLD")

    AutoRoll:SetScript("OnEvent", function(self, event, arg1, ...) 
        AutoRoll:onEvent(self, event, arg1, ...) 
    end)

    -- INITIALIZATION
    function Init()  
        LoadOptions()
    end

    function LoadOptions()
        if AutoRoll_Options == nil then
            AutoRoll_Options = AutoRollUtils:deepcopy(defaults)
        end

        for key,value in pairs(defaults) do
            if (AutoRoll_Options[key] == nil) then
                AutoRoll_Options[key] = value
            end
        end
    end

    function AutoRoll:onEvent(self, event, ...)
        if event == "ADDON_LOADED" then
            if select(1, ...) == ADDON_NAME then
                Init()
                PrintHelp()
            end
        end

        if AutoRoll_Options["rules"]["enabled"] then
            if event == "START_LOOT_ROLL" then
                EvaluateActiveRolls()
            end

            if event == "PLAYER_ENTERING_WORLD" then
                EvaluateActiveRolls()
            end

            if event == "CONFIRM_LOOT_ROLL" then
                local rollId = select(1, ...)
                local roll = select(2, ...)

                ConfirmLootRoll(rollId, roll)
            end  
        end
    end

    function PrintHelp()
        local colorHex = "2979ff"
        print("|cff"..colorHex.."AutoRoll loaded")
        print("-- Use the following commands: ")
        print("--       /ar NEED [item-link]")
        print("--       /ar GREED [item-link]")
        print("--       /ar PASS [item-link]")
        print("--       /ar IGNORE [item-link]")
    end

    function SaveRule(key, rule)
        -- Get Existing
        local rules = AutoRoll_Options["rules"]

        -- Make Mutations
        if (type(key) == "number") then
            local itemName, itemLink = GetItemInfo(key)

            if rule == nil then
                print("Removed rule for "..(itemLink or "item:"..key))
                rules[tonumber(key)] = nil
            else
                rules[tonumber(key)] = AutoRollUtils:getRuleValue(rule)
                print("Remembered "..rule:upper().." on "..(itemLink or "item:"..key))
            end
        elseif (type(key) == "string") then
            if rule == nil then
                print("Removed rule for "..key)
                rules[key:lower()] = nil
            else
                rules[key:lower()] = AutoRollUtils:getRuleValue(rule)
                print("Remembered "..rule:upper().." on "..key)
            end 
        end

        -- Save
        AutoRoll_Options["rules"] = rules
    end

    function EvaluateActiveRolls()      
        local rules = AutoRoll_Options["rules"]

        for index,RollID in ipairs(GetActiveLootRollIDs()) do
            local itemId = AutoRollUtils:rollID2itemID(RollID)
            local _, _, _, quality, bindOnPickUp, canNeed, canGreed, _ = GetLootRollItemInfo(RollID)	
            local itemName, itemLink, itemRarity, _, _, _, itemSubType = GetItemInfo(itemId)

            -- start by checking the exact item ID
            local rule = rules[itemId]

            -- In case it's not found, check item sub type
            if not rule then
                if itemSubType then
                    rule = rules[itemSubType]
                end
            end

            -- In case it's not found, check item rarity
            if not rule then
                if itemRarity then
                    local key = AutoRollUtils:getRarityStringFromInteger(itemRarity)
                    rule = rules[key]
                end
            end

            -- Proceed only if we found an established rule
            if rule then
                if rule > -1 then
                    local shouldRoll = (rule == AutoRollUtils.ROLL.NEED and canNeed) or (rule == AutoRollUtils.ROLL.GREED and canGreed) or (rule == AutoRollUtils.ROLL.PASS)

                    if shouldRoll then
                        if AutoRoll_Options["printRolls"] then
                            print("AutoRoll: "..AutoRoll_Options["rules"][itemId].." on "..GetLootRollItemLink(RollID))
                        end
                        
                        RollOnLoot(RollID, rule)
                    end
                end
            end
        end
    end
    
    function CheckItemType(cmd, rule) 
        return SaveIfFound(cmd, rule, "cloth")
        or SaveIfFound(cmd, rule, "leather")
        or SaveIfFound(cmd, rule, "mail")
        or SaveIfFound(cmd, rule, "plate")
        or SaveIfFound(cmd, rule, "shields")
        or SaveIfFound(cmd, rule, "librams")
        or SaveIfFound(cmd, rule, "idols")
        or SaveIfFound(cmd, rule, "totems")
        or SaveIfFound(cmd, rule, "sigils")
    end

    function CheckItemRarity(cmd, rule) 
        return SaveIfFound(cmd, rule, "uncommon")
        or SaveIfFound(cmd, rule, "rare")
        or SaveIfFound(cmd, rule, "epic")
        or SaveIfFound(cmd, rule, "legendary")
    end

    function SaveIfFound(cmd, rule, keyword)
        if string.match(cmd, keyword) then
            AutoRoll.SaveRule(keyword, rule)
            return true
        end
        return false
    end

    -- Expose Functions
    AutoRoll.SaveRule = SaveRule
    AutoRoll.CheckItemType = CheckItemType
    AutoRoll.CheckItemRarity = CheckItemRarity

end

return AutoRoll