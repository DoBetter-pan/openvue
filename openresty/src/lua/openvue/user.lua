--------------------------
-- @file user.lua
-- @brief 
-- @author yingx
-- @date 2021-06-10
--------------------------

local cjson = require "cjson"
local xxtea = require "xxtea"
local db = require "utils.mysql"
local conf = require "openvue.conf"
local lang = require "openvue.lang"

local function handleLogin(context)
    local data = {}

    local sql = string.format("SELECT b.password FROM account a, user b WHERE a.user_id = b.id AND a.deleted = 0 AND b.deleted = 0 AND a.open_code = '%s'", context.params.username)
    local passwords = db.query(conf.db_option, sql, 10)
    if passwords and passwords[1] and passwords[1].password == context.params.password then
        local val = string.format("%d:%s:%s", ngx.now(), context.params.username, context.params.password)
        local token = xxtea.encrypt(val, "Adp201609203059Z")
        data.code = 20000
        data.data = {}
        data.data.token = token
    else
        data.code = 60204
        data.message = 'Account and password are incorrect'
    end

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

local function handleLogout(context)
    local data = {}

    data.code = 20000
    data.data = {}

    return data
end

local actions = {
    login = handleLogin,
    info = handleInfo,
    logout = handleLogout,
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
        data.message = lang.L("wrong parameter")
    end

    return data
end

local _M = {
    handle = handle,
}

return _M
