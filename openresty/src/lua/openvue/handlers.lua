--------------------------
-- @file handlers.lua
-- @brief 
-- @author yingx
-- @date 2021-06-10
--------------------------

local user = require "openvue.user"

local handler_map = {
    user = user,
}

local _M = {
    handler_map = handler_map
}

return _M
