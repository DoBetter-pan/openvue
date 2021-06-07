----------------------------
-- @file timedot.lua
-- @brief 
-- @author yingx
-- @date 2020-05-25
----------------------------

local ffi = require "ffi"

ffi.cdef[[
struct timeval {
    long int tv_sec;
    long int tv_usec;
};
int gettimeofday(struct timeval *tv, void *tz);
]];

local function usec()
    local tm = ffi.new("struct timeval")
    ffi.C.gettimeofday(tm, nil)
    local s =  tonumber(tm.tv_sec)
    local u =  tonumber(tm.tv_usec)
    return s * 10^6 + u
end

local function start(t)
    t.start_time = ngx.now() * 1000
    t.last_time = usec()
    t.dots = {}
end

local function dot(t, key, native)
    local now = usec()
    local elaspe_time = now - t.last_time
    t.last_time = now
    local dot = {
        name = key,
        now = now,
        used = elaspe_time,
        native = native or 1
    }
    table.insert(t.dots, dot)
end

local function dots2String(t)
    local log_dots = {}
    local native = 0
    local total = 0
    for i, v in ipairs(t.dots) do
        local log = v.name .. "_" .. v.used
        table.insert(log_dots, log)
        if v.native == 1 then
            native = native + v.used
        end
        total = total + v.used
    end
    --native 
    table.insert(log_dots, "native_" .. native)
    --total 
    table.insert(log_dots, "total_" .. total)
    return table.concat(log_dots, ";")
end

local _M = {
    usec = usec,
    start = start,
    dot = dot,
    dots2String = dots2String,
}

return _M
