--------------------------------------
-- @file xindex.lua
-- @brief 
-- @author yingx
-- @date 2020-12-04
--------------------------------------

local cjson = require "cjson"
local resty_string = require "resty.string"
local str = require "utils.str"
local red = require "utils.red"

local xindex_schema = {
    periods = {
        num = 0,
        name = "periods",
        stype = "bin",
        length = 16,
        indexed = false,
        stored = true,
        filter = true,
    },
    id = {
        num = 1,
        name = "id",
        stype = "int",
        length = 4,
        indexed = true,
        stored = true,
        filter = true,
    },
    dnf = {
        num = 2,
        name = "dnf",
        stype = "dnf",
        length = 0,
        indexed = true,
        stored = false,
        filter = false,
    },
    source = {
        num = 3,
        name = "source",
        stype = "str",
        length = 0,
        indexed = true,
        stored = true,
        filter = true,
    },
    type = {
        num = 4,
        name = "type",
        stype = "str",
        length = 0,
        indexed = true,
        stored = true,
        filter = true,
    },
    data = {
        num = 5,
        name = "data",
        stype = "str",
        length = 0,
        indexed = false,
        stored = true,
        filter = false,
    },
    priority = {
        num = 6,
        name = "priority",
        stype = "int",
        length = 4,
        indexed = false,
        stored = true,
        filter = false,
    },
    updatetime = {
        num = 7,
        name = "updatetime",
        stype = "int",
        length = 4,
        indexed = false,
        stored = true,
        filter = false,
    },
    primary = "id",
}

local xindexredis_option = {
    --redis_host = '10.19.37.218',
    redis_host = '10.19.37.218',
    redis_port = 6379,
    redis_timeout = 10000,
    redis_microseconds = 1000000,
    redis_poolsize = 200,
    redis_retry = 2,
    redis_passwd = 'video',
}

local function getStrategy(id)
    local val = red.hget("xindex", tostring(id), "", xindexredis_option)
    return val
end

local function setStrategy(value)
    local ret = false
    local id = red.incr("xindex_maxid", 0, xindexredis_option)
    if tonumber(id) > 0 then
        ret = red.hset("xindex", tostring(id), value, xindexredis_option)
    end
    return ret, id
end

local function getLastStrategyId()
    local id = red.get("xindex_maxid", 0, xindexredis_option)
    return id
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

local function transIntQueryToI32(value)
    local s = string.format("%x", value)
    local l = #s
    local m = 1
    local r = {}
    for i = l, 1, -2 do
        m = m + 1
        if i == 1 then
            local n = string.sub(s, i, i )
            table.insert(r, '0' .. n)
        else
            local n = string.sub(s, i - 1, i )
            table.insert(r, n)
        end
    end
    for j = m, 4, 1 do
        table.insert(r, '00')
    end
    return table.concat(r, "")
end

local function transIntQueryToI64(value)
    local s = string.format("%x", value)
    local l = #s
    local m = 1
    local r = {}
    for i = l, 1, -2 do
        m = m + 1
        if i == 1 then
            local n = string.sub(s, i, i )
            table.insert(r, '0' .. n)
        else
            local n = string.sub(s, i - 1, i )
            table.insert(r, n)
        end
    end
    for j = m, 8, 1 do
        table.insert(r, '00')
    end
    return table.concat(r, "")
end

local function generateDnf(dnf)
    local d = {}
    for k, v in pairs(dnf) do
        local value = {}
        if v.t == 1 then
            for ii, vv in ipairs(v.v) do
                local vmd5 = ngx.md5(vv)
                local vdnf = string.sub(vmd5, 1, 3) .. string.sub(vmd5, -3, -1)
                table.insert(value, vdnf)
            end
        else
        end
        table.insert(d, k .. '<{' .. table.concat(value, ';') .. '}')
    end
    local ret = '(' .. table.concat(d, '+') .. ')'
    return resty_string.to_hex(ret)
end

local function preProcessAddUpdate(doc)
    local data = {}
    for k, v in pairs(doc) do
        table.insert(data, {key = k, val = v})
    end
    table.sort(data, function(a, b)
        return a.key < b.key
    end)
    return data
end

local function processAddUpdate(doc)
    local dst = {
        string.char(1),
        string.char(126),
    }
    local fields = preProcessAddUpdate(doc)
    for i, v in pairs(fields) do
        local schema = xindex_schema[v.key]
        if schema then
            local val = ""
            if schema.stype ~= "str" then
                val = hex2bin_i(v.val)
            else
                val = v.val
            end
            local data_len = #val
            local field_len = schema.length
            if data_len > 0 then
                if field_len > 0 then
                    table.insert(dst, string.char(schema.num))
                    table.insert(dst, val)
                else
                    table.insert(dst, string.char(schema.num))
                    -- 写入长度
                    for i = 1, 4 do 
                        local len = bit.band(bit.rshift(data_len, (i - 1) * 8), 0xff)
                        table.insert(dst, string.char(len))
                    end
                    table.insert(dst, val)
                end
            end
        end
    end
    table.insert(dst, string.char(127))
    return resty_string.to_hex(table.concat(dst, ""))
end

local function processDelete(doc)
    local dst = {
        string.char(0),
        string.char(126),
    }
    local primary = conf.schema.primary
    local schema = conf.schema[primary]
    local val = hex2bin_i(doc[primary])
    table.insert(dst, val)
    table.insert(dst, string.char(127))
    return resty_string.to_hex(table.concat(dst, ""))
end

local function index(action, doc)
    local ret = true

    local data = "" 
    if action == "add" then
        data = processAddUpdate(doc)
    elseif action == "delete" then
        data = processDelete(doc)
    end
    local ret, messageid = setStrategy(data)

    return ret, messageid
end

local function xindex(action, doc)
    local d = {}
    d.periods = transIntQueryToI64(doc.starttime) .. transIntQueryToI64(doc.endtime)
    d.id = transIntQueryToI32(doc.id)
    d.dnf = generateDnf(doc.dnf)
    d.source = doc.source
    d.type = doc.type
    d.data = doc.data
    d.priority = transIntQueryToI32(doc.priority)
    d.updatetime = transIntQueryToI32(doc.updatetime)
    local ret, messageid = index(action, d)
    return ret, messageid
end

local function xsearch(start, length)
    local lastId = tonumber(getLastStrategyId())

    local data = {}
    local count = 0
    while (start <= lastId and count <= length) do
        local indexstrategy  = getStrategy(start)
        start = start + 1
        count = count + 1
        table.insert(data, indexstrategy)
    end

    return data
end

local _M = {
    xindex = xindex,
    xsearch = xsearch,
}

if _TEST then
    _M.setRedisOption = function(redisoption)
        xindexredis_option = redisoption
    end
end

return _M

