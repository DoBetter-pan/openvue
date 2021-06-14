--------------------------
-- @file openvue.lua
-- @brief 
-- @author yingx
-- @date 2020-03-10
--------------------------

local cjson = require "cjson"
local str = require "utils.str"
local lang = require "openvue.lang"
local prot_json = require "openvue.prot_json"
local prot_pb = require "openvue.prot_pb"
local handlers = require "openvue.handlers"

local function queryService(context)
    local data = {}
    local found = false
    local path = str.split(context.req.uri, '/')
    if #path >= 4 then
        context.req.module = path[3]
        context.req.action = path[4]
        if handlers.handler_map[context.req.module] then
            found = true
            data = handlers.handler_map[context.req.module].handle(context)
        end
    end
    if not found then
        data.status = 50007
        data.message = lang.L("wrong parameter")
    end
    return data
end

local function pqueryService(context)
    local ok, data = pcall(queryService, context)
    if not ok then
        ngx.log(ngx.CRIT, "@pqueryService, An error happens:" .. data)
        data = {}
    end
    return data
end

local function serve()
    local context = {
        info = {
            rate = math.random(10000),
        },
        req = {},
        time = {},
        status = {},
        log = {},
        params = {},
    }

    if ngx.var.arg_prot == "pb" then
        context.protocol = prot_pb
    else
        context.protocol = prot_json
    end

    context.req.method = ngx.req.get_method()
    context.req.uri = ngx.var.uri
    context.req.args = ngx.req.get_uri_args() or {}

    if ngx.req.get_method() == 'POST' then
        ngx.req.read_body()
        local params = ngx.req.get_body_data()
        context.params = context.protocol.decode_request(params)
    end

    local data = pqueryService(context)
    local response_data = context.protocol.encode_response(data)
    --[[
    local f = io.open("/tmp/x.pb", "w")
    if f then
    f:write(cjson.encode(data))
    f:close()
    end
    ]]
    ngx.header.Content_Length = string.len(response_data)
    ngx.header.Content_Type = "application/json"
    ngx.print(response_data)
    ngx.eof()

    --local access_log = buildAccessLog(context)
    --ngx.var.appdata = table.concat(access_log, "^")
end

local service = {
    serve = serve,
}

return service
