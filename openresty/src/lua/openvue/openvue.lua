--------------------------
-- @file openvue.lua
-- @brief 
-- @author yingx
-- @date 2020-03-10
--------------------------

local cjson = require "cjson"
local str = require "utils.str"
local prot_json = require "openvue.prot_json"
local prot_pb = require "openvue.prot_pb"

local function queryService(context)
    local data = {
        status = 0,
        message = "hello world",
    }
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
        time = {},
        status = {},
        log = {},
        params = {},
    }

    ngx.req.read_body()
    local data = ngx.req.get_body_data()
    if ngx.var.arg_prot == "pb" then
        context.protocol = prot_pb
    else
        context.protocol = prot_json
    end
    context.params = context.protocol.decode_request(data)

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
