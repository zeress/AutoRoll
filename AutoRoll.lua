-- NAMESPACE / CLASS: AutoRoll   
-- OPTIONS: AutoRoll_Options      

AutoRoll = CreateFrame("Frame")

do -- Private Scope

    local ADDON_NAME = "AutoRoll"
    local ORG_CONFIRM_DIALOG = StaticPopupDialogs["CONFIRM_LOOT_ROLL"]

    local defaults = {
        ["rules"] = {},
        ["enableRememberCheckbox"] = false
    }

    -- STATE
    ROLLS = {} -- {remember, itemId, rule, itemLink}

    -- REGISTER EVENTS
    AutoRoll:RegisterEvent("ADDON_LOADED")
    AutoRoll:RegisterEvent("START_LOOT_ROLL")
    AutoRoll:RegisterEvent("CONFIRM_LOOT_ROLL")
    AutoRoll:RegisterEvent("CONFIRM_LOOT_ROLL")

    AutoRoll:SetScript("OnEvent", function(self, event, arg1, ...) 
         onEvent2(self, event, arg1, ...) 
    end);

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

    function onEvent2(self, event, ...)
        if event == "ADDON_LOADED" then
            if select(1, ...) == ADDON_NAME then
                Init()
                PrintHelp()
            end
        end

        if event == "START_LOOT_ROLL" then

            local pendingLootRollIDs = GetActiveLootRollIDs()

            for index,value in ipairs(pendingLootRollIDs) do
                local RollID = value

                --local RollID = select(1, ...)

                local ItemLink = GetLootRollItemLink(RollID)
                local itemString = gsub(ItemLink, "\124", "\124\124")
                local itemId = tonumber(AutoRollUtils:getItemId(itemString))

                --print("("..RollID..") Rolling on "..ItemLink)

                ROLLS[RollID] = {
                    ["remember"] = false,
                    ["itemId"] = itemId,
                    ["itemLink"] = ItemLink
                }

                local texture, name, count, quality, bindOnPickUp, canNeed, canGreed, canDisenchant = GetLootRollItemInfo(RollID)	

                local rule = AutoRoll_Options["rules"][itemId]

                -- If we already have established a rule for this item
                if rule then
                    if rule > -1 then
                        --print("AutoRoll: "..AutoRoll_Options["rules"][itemId].." on "..ItemLink)
                        RollOnLoot(RollID, rule)
                    end
                else
                    if AutoRoll_Options.enableRememberCheckbox then
                        CreateFrames()
                    end
                end

            end
     
            
        end

        if event == "CONFIRM_LOOT_ROLL" then
            local pendingLootRollIDs = GetActiveLootRollIDs()

            for index,value in ipairs(pendingLootRollIDs) do
                local RollID = value
                --local RollID = select(1, ...)
                local roll = select(2, ...)
                local itemId = ROLLS[RollID]
    
                local rule = AutoRoll_Options["rules"][itemId]
                ConfirmLootRoll( RollID, roll )

                --[[
                if rule then
                    StaticPopupDialogs["CONFIRM_LOOT_ROLL"] = nil
                    ConfirmLootRoll( RollID, roll )
                else
                    StaticPopupDialogs["CONFIRM_LOOT_ROLL"] = ORG_CONFIRM_DIALOG
                end
                ]]--
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

    -- Expose Field Variables and Functions


    function CreateRememberCheckbox(lootFrame, rollId)
        local left, top, bottom, right;
        left = lootFrame:GetLeft()
        top = lootFrame:GetTop() - 25 - 20
        right = lootFrame:GetRight()
        bottom = lootFrame:GetBottom()

        local container = CreateFrame("Frame", "AutoRollRememberCheckbox_Frame"..rollId, UIParent)
        container:SetFrameStrata("DIALOG")
        container:ClearAllPoints()
        container:SetPoint("BOTTOMLEFT", lootFrame, "TOPLEFT", 0, 0)
        container:SetHeight(25)
        container:SetWidth(120)

        local remember = MakeCheckbox(ADDON_NAME.."RememberRoll"..rollId, container, "Check to create an Auto Roll rule based on your choice below.")
        remember:ClearAllPoints()
        remember:SetChecked(false)
        remember.label:SetText("Remember")
        remember:SetPoint("TOPLEFT", 0, 0)

        remember:SetScript("OnClick",function(self,button)
      
            if rollId == nil then
                return
            end

            local roll = ROLLS[rollId]

            roll.remember = self:GetChecked()

            if roll.remember then

                lootFrame.PassButton:HookScript("OnClick", function() 
                    local roll = ROLLS[rollId]

                    if roll then
                        if roll.remember then
                            SaveRule(roll.itemId, "pass")
                        end

                        ROLLS[rollId] = nil
                    end
                end)

                lootFrame.GreedButton:HookScript("OnClick", function() 
                    local roll = ROLLS[rollId]

                    if roll then
                        if roll.remember then
                            SaveRule(roll.itemId, "greed")
                            print("("..roll.itemId..") Remembered GREED on "..roll.itemLink)
                        end

                        ROLLS[rollId] = nil
                    end
                end)

                lootFrame.NeedButton:HookScript("OnClick", function() 
                    local roll = ROLLS[rollId]

                    if roll then
                        if roll.remember then
                            SaveRule(roll.itemId, "need")
                            print("("..roll.itemId..") Remembered NEED on "..roll.itemLink)
                        end

                        ROLLS[rollId] = nil
                    end
                end)
            end

        end)

        lootFrame:HookScript("OnShow", function() 
            remember:SetChecked(false)
            container:Show()
        end)
        lootFrame:HookScript("OnHide", function() 
            remember:SetChecked(false)
            container:Hide()
        end)

        container:Show()
        remember:Show()
        
        lootFrame.autoRollRememberCheckbox = container
    end


    function MakeCheckbox(name, parent, tooltip_text)
        local cb = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
        cb:SetWidth(25)
        cb:SetHeight(25)
        cb:Show()
    
        local cblabel = cb:CreateFontString(nil, "OVERLAY")
        cblabel:SetFontObject("GameFontHighlight")
        cblabel:SetPoint("LEFT", cb,"RIGHT", 5,0)
        cb.label = cblabel
    
        cb.tooltip = tooltip_text
    
        return cb
    end

    function CreateFrames()
        local pendingLootRollIDs = GetActiveLootRollIDs();

        for index,value in ipairs(pendingLootRollIDs) do
            local frame = _G["GroupLootFrame"..index];
            if ( frame:IsShown() ) then
                local rollId = frame.rollID

                CreateRememberCheckbox(frame, rollId)

                return
            end
        end
    end

    function SaveRule(itemId, rule)
        -- Get Existing
        local rules = AutoRoll_Options["rules"]

        local itemName, itemLink = GetItemInfo(itemId)

        -- Make Mutations
        if rule == nil then
            print("Removed rule for "..itemLink)
            rules[tonumber(itemId)] = nil
        else
            rules[tonumber(itemId)] = AutoRollUtils:getRuleValue(rule)
            print("Remembered "..rule:upper().." on "..itemLink)
        end

        -- Save
        AutoRoll_Options["rules"] = rules
    end


    -- Expose Functions
    AutoRoll.SaveRule = SaveRule
    
      
end

return AutoRoll