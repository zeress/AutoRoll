
AutoRollUtils = {}

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
    return string.match(str, "item:(%d*)")
end

function AutoRollUtils:getRuleValue(str)
    if str:lower() == "pass" then return 0 end
    if str:lower() == "need" then return 1 end
    if str:lower() == "greed" then return 2 end

    return -1
end

function AutoRollUtils:getRuleString(num)
    if num == 0 then return "pass" end
    if num == 1 then return "need" end
    if num == 2 then return "greed" end

    return nil
end