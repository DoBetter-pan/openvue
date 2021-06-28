--------------------------
-- @file user.lua
-- @brief 
-- @author yingx
-- @date 2021-06-10
--------------------------

local cjson = require "cjson"
local xxtea = require "xxtea"
local str = require "utils.str"
local db = require "utils.mysql"
local conf = require "openvue.conf"
local lang = require "openvue.lang"

local function checkUser(context)
    local user = nil

    if context.req and context.req.args and context.req.args.token then
        local token = xxtea.decrypt(context.req.args.token, 'Adp201609203059Z')
        local infos = str.split(token, ':')
        if #infos >= 3 then
            -- 先不校验过期时间
            local sql = string.format("SELECT b.id, a.open_code, b.name, b.head_img_url, b.mobile, c.code   FROM account a, user b, user_group c, user_group_user d WHERE a.user_id = b.id AND b.id = d.user_id AND c.id = d.user_group_id AND a.deleted = 0 AND b.deleted = 0 AND c.deleted = 0 AND d.deleted = 0 AND a.open_code = '%s' and b.password = '%s'", infos[2], infos[3])
            local users = db.query(conf.db_option, sql, 10)
            if users then
                local user_map = {}
                for i, v in ipairs(users) do
                    if user_map[infos[2]] then
                        table.insert(user_map[infos[2]].roles, v.code)
                    else
                        user_map[infos[2]] = {}
                        user_map[infos[2]].name = v.name
                        user_map[infos[2]].introduction = ''
                        user_map[infos[2]].avatar = v.head_img_url
                        user_map[infos[2]].roles = {}
                        table.insert(user_map[infos[2]].roles, v.code)
                    end
                end
                user = user_map[infos[2]]
            end
        end
    end

    return user
end

local function handleLogin(context)
    local data = {}

    local sql = string.format("SELECT b.password FROM account a, user b WHERE a.user_id = b.id AND a.deleted = 0 AND b.deleted = 0 AND a.open_code = '%s'", context.params.username)
    local passwords = db.query(conf.db_option, sql, 10)
    if passwords and passwords[1] and passwords[1].password == context.params.password then
        local val = string.format("%d:%s:%s", ngx.now(), context.params.username, context.params.password)
        local token = xxtea.encrypt(val, 'Adp201609203059Z')
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

    local user = checkUser(context)
    if user then
        data.code = 20000
        data.data = user
    else
        data.code = 60204
        data.message = 'Account and password are incorrect'
    end

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
