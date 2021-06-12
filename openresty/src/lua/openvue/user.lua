--------------------------
-- @file user.lua
-- @brief 
-- @author yingx
-- @date 2021-06-10
--------------------------

local function handleLogin(context)
    local data = {}

    data.code = 20000
    data.data = {}
    data.data.token = "admin-token"

    return data
end

local function handleInfo(context)
    local data = {}

    data.code = 20000
    data.data = {}
    data.data.roles = {"admin"}
    data.data.introduction = "I am a super administrator"
    data.data.avatar = "https://wpimg.wallstcn.com/f778738c-e4f8-4870-b634-56703b4acafe.gif"
    data.data.name = "Admin"

    return data
end

local actions = {
    login = handleLogin,
    info = handleInfo,
}

local function handle(context)
    local data = {}
    local found = false

    if actions[context.req.action] then
        found = true
        data = actions[context.req.action](context)
    end
    if not found then
        data.status = 50007
        data.message = 'Wrong Parameter'
    end

    return data
end

local _M = {
    handle = handle,
}

return _M
