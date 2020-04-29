
AutoRollUtils = {
    ROLL = {
        PASS = 0,
        NEED = 1,
        GREED = 2
    }
}

function AutoRollUtils:modulus(a,b)
    return a - math.floor(a/b)*b
end

function AutoRollUtils:deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[AutoRollUtils:deepcopy(orig_key)] = AutoRollUtils:deepcopy(orig_value)
        end
        setmetatable(copy, AutoRollUtils:deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function AutoRollUtils:getItemId(str)
    if str then
        local tmp = string.match(str, "item:(%d*)")
        if tmp then
            return string.match(tmp, "(%d*)")
        end
    end
end

function AutoRollUtils:getRuleValue(str)
    if str then
        if str:lower() == "pass" then return AutoRollUtils.ROLL.PASS end
        if str:lower() == "need" then return AutoRollUtils.ROLL.NEED end
        if str:lower() == "greed" then return AutoRollUtils.ROLL.GREED end
    end

    return -1
end

function AutoRollUtils:getRuleString(num)
    if num == AutoRollUtils.ROLL.PASS then return "pass" end
    if num == AutoRollUtils.ROLL.NEED then return "need" end
    if num == AutoRollUtils.ROLL.GREED then return "greed" end

    return nil
end

function AutoRollUtils:rollID2itemID(rollId)
    local ItemLink = GetLootRollItemLink(rollId)
    local itemString = gsub(ItemLink, "\124", "\124\124")
    local itemId = tonumber(AutoRollUtils:getItemId(itemString))
    return itemId
end