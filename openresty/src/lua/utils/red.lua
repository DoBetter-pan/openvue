------------------------ 
-- @file redis.lua
-- @brief redis helper
-- @author yingx
-- @date 2019-11-08
-------------------------

local cjson = require "cjson"
local redis = require "resty.redis"

local function red_connect(option)
	local red = redis:new()
	red:set_timeout(option.timeout or 1000)
    if option.unixpath then
        local ok, err = red:connect(option.unixpath)
        if not ok then
            ngx.log(ngx.ERR, "failed to connect: " .. option.unixpath .. " the err is " .. err)
            return nil
        end
    else
        local ok, err = red:connect(option.host or "127.0.0.1", option.port or 6379)
        if not ok then
            local host = option.host or "127.0.0.1"
            local port = option.port or 6379
            ngx.log(ngx.ERR, "failed to connect: " .. host .. ":" .. port .. " the err is " .. err)
            return nil
        end
        if option.passwd then
            red:auth(option.passwd)
        end
    end

    return red
end

local function red_keepalive(red, option)
	red:set_keepalive(option.microseconds or 10000, option.poolsize or 100)
end

local function red_get(key, defaultvalue, option)
    local val = defaultvalue

    option = option or {}
    local red = red_connect(option)
    if red then
        local res, err = red:get(key)
        if res and res ~= ngx.null then
            val = res
        else
            if option.debug then
                ngx.log(ngx.ERR, "failed to get value for key: " .. key)
            end
        end
        red_keepalive(red, option)
    end

    return val
end

local function red_set(key, value, option)
    local ret, err = false, ""

    option = option or {}
    local retry = option.retry or 5
    for i = 1, retry do
        local red = red_connect(option)
        if red then
            ret, err = red:set(key, value)
            red_keepalive(red, option)
            if ret then
                break
            end
        end
    end
    if not ret then
        if option.debug then
            ngx.log(ngx.ERR, "failed to set value for key: " .. key .. ", value" .. value)
        end
    end

    return ret
end

local function red_setex(key, value, timeout, option)
    local ret, err = false, ""

    option = option or {}
    timeout = timeout or 0
    local retry = option.retry or 5
    for i = 1, retry do
        local red = red_connect(option)
        if red then
            ret, err = red:setex(key, timeout, value)
            red_keepalive(red, option)
            if ret then
                break
            end
        end
    end
    if not ret then
        if option.debug then
            ngx.log(ngx.ERR, "failed to setex value for key: " .. key .. " value" .. value)
        end
    end

    return ret
end

local function red_del(key, force, option)
    local ret, err = false, ""

    option = option or {}
    local retry = option.retry or 5
    for i = 1, retry do
        local red = red_connect(option)
        if red then
            ret, err = red:del(key)
            red_keepalive(red, option)
            if not force or ret == 1 then
                break
            end
        end
    end
    if ret == 0 and force then
        ret = false
        if option.debug then
            ngx.log(ngx.ERR, "failed to del value for key: " .. key)
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
                ngx.log(ngx.ERR, "failed to hget value for key: " .. key .. ",field: " .. field .. ",res: " ..  res .. ",err: " .. err)
            end
        end
        red_keepalive(red, option)
    end

    return val
end

local function red_hset(key, field, value, option)
    local ret, err = false, ""

    option = option or {}
    local retry = option.retry or 5
    for i = 1, retry do
        local red = red_connect(option)
        if red then
            ret, err = red:hset(key, field, value)
            red_keepalive(red, option)
            if ret then
                break
            end
        end
    end
    if not ret then
        if option.debug then
            ngx.log(ngx.ERR, "hset value for key: " .. key .. " value: " .. value .. ",err: " .. err)
        end
    end

    return ret
end

local function red_hdel(key, field, option)
    local ret, err = false, ""

    option = option or {}
    local retry = option.retry or 5
    for i = 1, retry do
        local red = red_connect(option)
        if red then
            ret, err = red:hdel(key, field)
            red_keepalive(red, option)
            if ret then
                break
            end
        end
    end
    if not ret then
        if option.debug then
            ngx.log(ngx.ERR, "hdel value for key: " .. key .. ", err: " .. err)
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
                ngx.log(ngx.ERR, "hscan key: " .. key .. "  err: " .. err)
            end
        end
        red_keepalive(red, option)
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
                ngx.log(ngx.ERR, "hgetall key: " .. key .. "  err: " .. err)
            end
        end
        red_keepalive(red, option)
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
                ngx.log(ngx.ERR, "failed to get value for key: " .. key)
            end
        end
        red_keepalive(red, option)
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
        red_keepalive(red, option)
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
