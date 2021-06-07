----------------------------
-- @file http.lua
-- @brief 
-- @author yingx
-- @date 2019-11-18
----------------------------

local http = require "resty.http"

local function request_uri(url, headers, body, timeout, keepalive_time, keepalive_pool)
    local method = "GET"
    if body then
        method = "POST"
    end
    local httpc = http.new()
    httpc:set_timeout(timeout)
    local rsp, err = httpc:request_uri(url, {
        method = method,
        body = body,
        headers = headers,
        keepalive_time = keepalive_time or 60,
        keepalive_pool = keepalive_pool or 10,

    })
    if not rsp then
        ngx.log(ngx.CRIT, "failed to request:" .. err)
    end
    return rsp
end

local _M = {
    request_uri = request_uri,
}

return _M
