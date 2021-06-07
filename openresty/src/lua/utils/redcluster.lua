------------------------ 
-- @file redis.lua
-- @brief redis helper
-- @author yingx
-- @date 2019-11-08
-------------------------

local cjson = require "cjson"
local rediscluster = require "resty.rediscluster"
local adxcachex = require "adx.adxcachex"

local function red_connect(option)
    option.keepalive_timeout = option.keepalive_timeout or 60000
    option.keepalive_cons = option.keepalive_cons or 1000
    option.connect_timeout = option.connect_timeout or 1000
    option.read_timeout = option.read_timeout or 1000
    option.send_timeout = option.send_timeout or 1000
    option.max_redirection = option.max_redirection or 5
    option.max_connection_attempts = option.max_connection_attempts or 1
    local serv_list = adxcachex.getEcpmServers()
    option.serv_list = serv_list
    local red, err = rediscluster:new(option)
    if option.debug and err then
        ngx.log(ngx.ERR, "redcluster, failed to connect server: " .. (option.name or "") .. ", err:" .. err)
    end
    return red, err
end

local function red_get(key, defaultvalue, option)
    local val = defaultvalue

    option = option or {}
    local red, err = red_connect(option)
    if red then
        local res, err = red:get(key)
        if res and res ~= ngx.null then
            val = res
        else
            if option.debug then
                ngx.log(ngx.ERR, "redcluster, failed to get value for key: " .. key)
            end
        end
    end

    return val
end

local function red_set(key, value, option)
    local ret, err = false, ""

    option = option or {}
    local retry = option.cluster_retry or 5
    for i = 1, retry do
        local red = red_connect(option)
        if red then
            ret, err = red:set(key, value)
            if ret then
                break
            end
        end
    end
    if not ret then
        if option.debug then
            ngx.log(ngx.ERR, "redcluster, failed to set value for key: " .. key .. ", value" .. value)
        end
    end

    return ret
end

local function red_setex(key, value, timeout, option)
    local ret, err = false, ""

    option = option or {}
    timeout = timeout or 0
    local retry = option.cluster_retry or 5
    for i = 1, retry do
        local red = red_connect(option)
        if red then
            ret, err = red:setex(key, timeout, value)
            if ret then
                break
            end
        end
    end
    if not ret then
        if option.debug then
            ngx.log(ngx.ERR, "redcluster, failed to setex value for key: " .. key .. " value" .. value)
        end
    end

    return ret
end

local function red_del(key, force, option)
    local ret, err = false, ""

    option = option or {}
    local retry = option.cluster_retry or 5
    for i = 1, retry do
        local red = red_connect(option)
        if red then
            ret, err = red:del(key)
            if not force or ret == 1 then
                break
            end
        end
    end
    if ret == 0 and force then
        ret = false
        if option.debug then
            ngx.log(ngx.ERR, "redcluster, failed to del value for key: " .. key)
        end
    else
        ret = true
    end

    return ret
end

local function red_hget(key, field, defaultvalue, option)
    local val = defaultvalue

    option = option or {}
    local red = red_connect(option)
    if red then
        local res, err = red:hget(key, field)
        if res and res ~= ngx.null then
            val = res
        else
            if option.debug then
                ngx.log(ngx.ERR, "redcluster, failed to hget value for key: " .. key .. ",field: " .. field .. ",res: " ..  res .. ",err: " .. err)
            end
        end
    end

    return val
end

local function red_hset(key, field, value, option)
    local ret, err = false, ""

    option = option or {}
    local retry = option.cluster_retry or 5
    for i = 1, retry do
        local red = red_connect(option)
        if red then
            ret, err = red:hset(key, field, value)
            if ret then
                break
            end
        end
    end
    if not ret then
        if option.debug then
            ngx.log(ngx.ERR, "redcluster, hset value for key: " .. key .. " value: " .. value .. ",err: " .. err)
        end
    end

    return ret
end

local function red_hdel(key, field, option)
    local ret, err = false, ""

    option = option or {}
    local retry = option.cluster_retry or 5
    for i = 1, retry do
        local red = red_connect(option)
        if red then
            ret, err = red:hdel(key, field)
            if ret then
                break
            end
        end
    end
    if not ret then
        if option.debug then
            ngx.log(ngx.ERR, "redcluster, hdel value for key: " .. key .. ", err: " .. err)
        end
    end

    return ret
end

local function red_hscan(key, cursor, option)
    local val
    option = option or {}
    local red = red_connect(option)
    if red then
        local res, err = red:hscan(key, cursor)
        if res and res ~= ngx.null then
            val = res
        else
            if option.debug then
                ngx.log(ngx.ERR, "redcluster, hscan key: " .. key .. "  err: " .. err)
            end
        end
    end

    return val
end

local function red_hgetall(key, option)
    local val
    option = option or {}
    local red = red_connect(option)
    if red then
        local res, err = red:hgetall(key)
        --ngx.log(ngx.INFO, "hscan key: " .. key .. "  res: ", cjson.encode(res))
        if res and res ~= ngx.null then
            val = {}
            for i = 1, #res, 2 do
                val[res[i]] = res[i + 1]
            end
        else
            if option.debug then
                ngx.log(ngx.ERR, "redcluster, hgetall key: " .. key .. "  err: " .. err)
            end
        end
    end

    return val
end

local function red_incr(key, defaultvalue, option)
    local val = defaultvalue

    option = option or {}
    local red = red_connect(option)
    if red then
        local res, err = red:incr(key)
        if res and res ~= ngx.null then
            val = res
        else
            if option.debug then
                ngx.log(ngx.ERR, "redcluster, failed to get value for key: " .. key)
            end
        end
    end

    return val
end

local function red_call(cmd, args, option)
    local res, err, val
    
    option = option or {}
    local red = red_connect(option)
    if red then
        if args then
            res, err = red[cmd](red, unpack(args))
        else
            res, err = red[cmd](red)
        end
        if res and res ~= ngx.null then
            val = res
        end
    end

    return val, err
end

local _M = {
    get = red_get,
    set = red_set,
    del = red_del,
    setex = red_setex,
    hget = red_hget,
    hset = red_hset,
    hdel = red_hdel,
    hscan = red_hscan,
    hgetall = red_hgetall,
    incr = red_incr,
    call = red_call,
}

return _M
