----------------------------
-- @file cache.lua
-- @brief 
-- @author yingx
-- @date 2019-11-11
----------------------------
--

local cjson = require "cjson"
local lrucache = require "resty.lrucache.pureffi"

--[[
-- 返回数组
local function getDspInfos()
    --{
    --key= vale
    --}
end

local cache_data = {
    dsp = {
        tname = dsp, 
        getData = getDspInfos, 
        ctype = 1, -- 1:全量，2: LRU
        fullcache = {},
        partcache = nil,
        size = 5000,
        ttl = 300,
        minUpdateTime = 240,
        maxUpdateTime = 360,
        nextUpdateTime = 300,
    },
} 
]]

local function cache_get(cache_data, tname, key)
    local ret = nil
    local cache_table = cache_data[tname]
    if cache_table then
        if cache_table.ctype == 1 then
            if key then
                ret =  cache_table.fullcache[key]
            else
                ret =  cache_table.fullcache
            end
        else
            local err
            if not cache_table.partcache then
                cache_table.ttl = cache_table.ttl or 300
                cache_table.size = cache_table.size or 5000
                cache_table.partcache, err = lrucache.new(cache_table.size)
                if not cache_table.partcache then
                    ngx.log(ngx.CRIT, "LRU cache new error:" .. tostring(err))
                end
            end
            if cache_table.partcache then
                local value, elapse_value = cache_table.partcache:get(key)
                if not value then
                    if elapse_value then
                        cache_table.partcache:delete(key)
                    end
                    -- 回源数据
                    value = cache_table.getData(key)
                    if value then
                        cache_table.partcache:set(key, value, cache_table.ttl)
                    end
                    ret = value
                else
                    ret = value
                end

            end
        end
    end
    return ret
end

local function cache_set(cache_data, tname, key, value)
    local ret = false
    local cache_table = cache_data[tname]
    if cache_table then
        if cache_table.ctype == 1 then
            cache_table.fullcache[key] = value
            ret = true
        else
            local err
            if not cache_table.partcache then
                cache_table.ttl = cache_table.ttl or 300
                cache_table.size = cache_table.size or 5000
                cache_table.partcache, err = lrucache.new(cache_table.size)
                if not cache_table.partcache then
                    ngx.log(ngx.CRIT, "LRU cache new error:" .. tostring(err))
                end
            end
            if cache_table.partcache then
                cache_table.partcache:set(key, value, cache_table.ttl)
            end
        end
    else
        ngx.log(ngx.CRIT, "not have this table:" .. tname)
    end
    return ret
end

local function cache_del(cache_data, tname, key)
    local ret = false
    local cache_table = cache_data[tname]
    if cache_table then
        if cache_table.ctype == 1 then
            cache_table.fullcache[key] = nil
            ret = true
        else
            local err
            if not cache_table.partcache then
                cache_table.ttl = cache_table.ttl or 300
                cache_table.size = cache_table.size or 5000
                cache_table.partcache, err = lrucache.new(cache_table.size)
                if not cache_table.partcache then
                    ngx.log(ngx.CRIT, "LRU cache new error:" .. tostring(err))
                end
            end
            if cache_table.partcache then
                cache_table.partcache:del(key)
            end
        end
    else
        ngx.log(ngx.CRIT, "not have this table:" .. tname)
    end
    return ret
end

local function cache_update_one(cache_data, tname, now)
    local cache_table = cache_data[tname]
    if cache_table then
        if cache_table.ctype == 1 and cache_table.getData then
            if now >= cache_table.nextUpdateTime then
                if cache_table.nextUpdateTime == 0 then
                    math.randomseed(ngx.worker.pid())
                end
                cache_table.nextUpdateTime = now + math.random((cache_table.minUpdateTime or 240), (cache_table.maxUpdateTime or 360))
                cache_table.count = cache_table.count + 1
                if cache_table.count % 10 == 1 then
                    cache_table.fullcache["lastModifiedTime"] = 0
                end
                local need_update = false
                if cache_table.checkLastModifiedTime then
                    if cache_table.checkLastModifiedTime(cache_table.fullcache["lastModifiedTime"]) then
                        need_update = true
                    end
                else
                    need_update = true
                end
                if need_update then
                    local data = cache_table.getData()
                    if data then
                        -- 清空fullcache
                        cache_table.fullcache = {}
                        for k,v in pairs(data) do
                            if cache_table.postHandle and k ~= "lastModifiedTime" then
                                cache_table.fullcache[k] = cache_table.postHandle(v)
                            else
                                cache_table.fullcache[k] = v
                            end
                        end
                    end
                end
            end
        end
    end
end

local function cache_update(cache_data, now)
    for k, v in pairs(cache_data) do
        cache_update_one(cache_data, k, now)
    end
end

local _M = {
    cache_get = cache_get,
    cache_set = cache_set,
    cache_del = cache_del,
    cache_update_one = cache_update_one,
    cache_update = cache_update,
}

return _M
