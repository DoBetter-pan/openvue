----------------------------------
-- @file prot_pb.lua
-- @brief 与vue的协议处理
-- @author yingx
-- @date 2019-08-13
----------------------------------

local pb = require "pb"
local protoc = require "protoc"

local f = io.open("src/proto/openvue.proto")
if f then
    local data = f:read("*a")
    f:close()
    local ret = protoc:load(data)
    if not ret then
        ngx.log(ngx.ERR, "failed to load src/proto/openvue.proto")
    end
end

local function encode_request(data)
    return pb.encode("sohussp.Request", data)
end

local function decode_request(data)
    return pb.decode("sohussp.Request", data)
end

local function encode_response(data)
    return pb.encode("sohussp.Response", data)
end

local function decode_response(data)
    return pb.decode("sohussp.Response", data)
end

local _M = {
    encode_request = encode_request,
    decode_request = decode_request,
    encode_response = encode_response,
    decode_response = decode_response,
}

return _M
