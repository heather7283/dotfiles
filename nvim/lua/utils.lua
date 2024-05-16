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

return {
    any = any,
    all = all,
    map = map
}
