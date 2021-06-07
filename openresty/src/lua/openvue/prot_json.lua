----------------------------------
-- @file prot_json.lua
-- @brief
-- @author yingx
-- @date 2019-11-12
----------------------------------

local cjson = require "cjson"

local function encode_request(data)
    return cjson.encode(data)
end

local function decode_request(data)
    local ok, r = pcall(cjson.decode, data)
    if not ok then
        r = {}
    end
    return r
end

local function encode_response(data)
    return cjson.encode(data)
end

local function decode_response(data)
    local ok, r = pcall(cjson.decode, data)
    if not ok then
        r = {}
    end
    return r
end

local _M = {
    encode_request = encode_request,
    decode_request = decode_request,
    encode_response = encode_response,
    decode_response = decode_response,
}

return _M
