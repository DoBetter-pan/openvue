----------------------------
-- @file utils.lua
-- @brief 
-- @author yingx
-- @date 2019-08-15
----------------------------

--执行随机种子
math.randomseed(ngx.now())

local invalid_mobile_id = {
    ["000000000000000"] = 1,
    ["111111111111111"] = 1,
    ["012345678912345"] = 1,
    ["null"] = 1,
    ["null_imei"] = 1,
    ["9774d56d682e549c"] = 1,
    ["00:00:00:00:00:00"] = 1,
    ["02:00:00:00:00:00"] = 1,
    ["00000000-0000-0000-0000-000000000000"] = 1,
    ["0"] = 1,
    ["00000000"] = 1,
    ["unknow"] = 1,
    ["unknown"] = 1,
}

local function filterInvalidMobileId(devid)
    local id = string.lower(devid)
    if invalid_mobile_id[id] == 1 then
        return ""
    else
        return devid
    end
end

local function isValidString(str)
    return (str ~= nil and str ~= "")
end

local function isValidTable(v)
    return (type(v) == "table")
end

local function genSuv()
    local str = ngx.localtime()
    local pat = {
        ["-"] = "",
        [":"] = "",
        [" "] = "",
    }
    str = string.gsub(str, "[%W+]", pat)
    local n = math.random(10000)
    return string.format("%s%05d", str, n)
end

local function generateImpId(pid)
    local id
    local n = #pid
    if n <= 8 then
        id = string.rep("0", 8 - n)
        id = id .. pid
    else
        id = string.sub(pid, 1, 8)
    end
    local str = '0123456789abcdef'

    for i = 1, 24 do
        local r = math.random(1, 16)
        id = id .. string.sub(str, r, r)
    end

    return id
end

local function calulateRespTime(context, resp)
    local elaspe_time = 0
    local end_time = 0
    if resp and resp.header then
        end_time = tonumber(resp.header["Elapse-Time"] or "0")
    end
    if end_time == 0 then
        end_time = ngx.now() * 1000
    end
    elaspe_time = end_time - (context.start_time or 0)
    if elaspe_time < 0 then
        elaspe_time = -1
    end
    return elaspe_time
end

local _M = {
    filterInvalidMobileId = filterInvalidMobileId,
    isValidString = isValidString,
    isValidTable = isValidTable,
    genSuv = genSuv,
    generateImpId = generateImpId,
    calulateRespTime = calulateRespTime,
}

return _M
