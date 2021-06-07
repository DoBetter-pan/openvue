----------------------------
-- @file str.lua
-- @brief 
-- @author yingx
-- @date 2019-08-15
----------------------------

local function split(input, delimiter)
    if type(delimiter) ~= "string" or string.len(delimiter) <= 0 then
        return {input}
    end
    local result = {}
    local from  = 1
    local count = 1
    local delim_from, delim_to = string.find(input, delimiter, from, true)
    while delim_from do
        result[count] = string.sub(input,from, delim_from - 1, true)
        count = count + 1
        from  = delim_to + 1
        delim_from, delim_to = string.find(input, delimiter, from, true)
    end
    result[count] = string.sub(input, from)
    return result
end

local function ltrim(s)
    return s:gsub("^%s+", "")
end

local function rtrim(s)
    return s:gsub("%s+$", "")
end

local function trim(s)
    return s:gsub("^%s+", ""):gsub("%s+$", "")
end

local function handleUrlArgs(uri)
    local data = {}
    if uri and uri ~= "" then
        local args = split(uri, "&")
        for i, v in ipairs(args) do
            local val = split(v, "=")
            if #val == 2 then
                data[val[1]] = ngx.unescape_uri(val[2])
            end
        end
    end
    return data
end

local function bin2hex(s)
    local r = string.gsub(s,"(.)",function (x) return string.format("%02X",string.byte(x)) end)
    return r
end

local h2b = {
    ["0"] = 0,
    ["1"] = 1,
    ["2"] = 2,
    ["3"] = 3,
    ["4"] = 4,
    ["5"] = 5,
    ["6"] = 6,
    ["7"] = 7,
    ["8"] = 8,
    ["9"] = 9,
    ["A"] = 10,
    ["B"] = 11,
    ["C"] = 12,
    ["D"] = 13,
    ["E"] = 14,
    ["F"] = 15,
    ["a"] = 10,
    ["b"] = 11,
    ["c"] = 12,
    ["d"] = 13,
    ["e"] = 14,
    ["f"] = 15,
}

local function hex2bin(hexstr)
    local s = string.gsub(hexstr, "(.)(.)", function ( h, l )
        return string.char(h2b[h]*16+h2b[l])
    end)
    return s
end

local function hex2bin_i(hexstr)
    local s = {}
    for i = 1, string.len(hexstr), 2 do
        local h = string.sub(hexstr, i, i )
        local l = string.sub(hexstr, i + 1, i + 1 )
        if h and l then
            table.insert(s, string.char(h2b[h] * 16 + h2b[l]))
        end
    end
    return table.concat(s, "")
end

local function getUrlArgs(uri, key)
    local ret = nil
    local s, e = string.find(uri, key, 1, true)
    if e then
        local s2, e2 = string.find(uri, "&", e + 1, true)
        if s2 then
            ret = string.sub(uri, e + 1, s2 - 1)
        else
            ret = string.sub(uri, e + 1)
        end
    end
    return ret
end

local function versionCompare(a, b, deli)
    local ret = 0
    local va = split(a, (deli or '.'))
    local vb = split(b, (deli or '.'))
    local l = (#va > #vb) and #va or #vb
    for i = 1, l do
        local m = tonumber(va[i]) or 0
        local n = tonumber(vb[i]) or 0
        if m > n then
            ret = 1
            break
        elseif m < n then
            ret = -1
            break
        end
    end
    return ret
end

local function getDomain(url)
    local s = string.find(url, "://", 1, true)
    if s then
        s = s + 3
    else
        s = 1
    end
    local s2 = string.find(url, "/", s, true)
    if s2 then
        return string.sub(url, s, s2 - 1)
    else
        return string.sub(url, s)
    end
end

local _M = {
    split = split,
    ltrim = ltrim,
    rtrim = rtrim,
    trim = trim,
    handleUrlArgs = handleUrlArgs,
    bin2hex = bin2hex,
    hex2bin = hex2bin,
    hex2bin_i = hex2bin_i,
    getUrlArgs = getUrlArgs,
    versionCompare = versionCompare,
    getDomain = getDomain,
}

return _M

