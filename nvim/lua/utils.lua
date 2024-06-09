-- python-like any
function any(tbl)
    for _, v in ipairs(tbl) do
        if v then
            return true
        end
    end
    return false
end

-- python-like all
function all(tbl)
    for _, v in ipairs(tbl) do
        if not v then
            return false
        end
    end
    return true
end

-- python-like map (use with arrays)
function map(func, tbl)
    local result = {}
    for _, v in ipairs(tbl) do
        table.insert(result, func(v))
    end
    return result
end

-- merge 2 tables recursively, values from second take precedence 
function merge_tables(t1, t2)
    local result = {} -- Initialize an empty table to hold the merged data

    -- First, copy all key-value pairs from t1 into the result table
    for k, v in pairs(t1) do
        result[k] = v
    end

    -- Iterate over the keys in the second table
    for k, v in pairs(t2) do
        -- Check if the key already exists in result 
        if result[k] == nil then
            -- If not, just copy the key-value pair from the second table
            result[k] = v
        else
            -- If the key exists, check if both values are tables
            if type(v) == 'table' and type(result[k]) == 'table' then
                -- If both are tables, merge them recursively
                result[k] = merge_tables(result[k], v)
            end
        end
    end

    -- Return the merged table
    return result
end

function print_table(tbl, indentLevel)
    -- Default to 0 if no indent level is provided
    indentLevel = indentLevel or 0
    
    -- Start building the output string
    local output = ""
    
    -- Iterate over the keys and values in the table
    for k, v in pairs(tbl) do
        -- Determine the next indent level for nested tables
        local newIndentLevel = indentLevel + 1
        
        -- Convert the key to a string
        local keyStr = tostring(k)
        
        -- Add the key and its value to the output string
        output = output.. string.rep("  ", indentLevel).. keyStr.. ": "
        
        -- Check if the value is a table
        if type(v) == "table" then
            -- If it is, add a newline and recursively pretty-print the nested table
            output = output.. "\n".. print_table(v, newIndentLevel)
        else
            -- If it's not a table, just convert it to a string and add it to the output
            output = output.. tostring(v).. "\n"
        end
    end
    
    return output
end

return {
    any = any,
    all = all,
    map = map,
    merge_tables = merge_tables,
    print_table = print_table,
}
