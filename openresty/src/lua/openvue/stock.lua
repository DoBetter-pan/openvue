--------------------------
-- @file stock.lua
-- @brief 
-- @author yingx
-- @date 2021-07-02
--------------------------

local cjson = require "cjson"
local xxtea = require "xxtea"
local str = require "utils.str"
local db = require "utils.mysql"
local conf = require "openvue.conf"
local lang = require "openvue.lang"
local user = require "openvue.user"

local page_size = 50

local function handleList(context)
    local data = {}

    local u = user.checkUser(context)
    if u then
        local offset = page_size * ((context.req.args.page or 1) - 1)
        local limit = context.req.args.limit or page_size 
        local order = context.req.args.sort or '+id'
        local sql = string.format("SELECT a.id, a.code, a.name, a.description, a.province, a.city, a.industry_id, a.price, a.total_number, a.total_price, a.last_unlocked_date, a.last_unlocked_number FROM stock a where a.deleted = 0 ORDER BY %s LIMIT %d, %d", order, offset, limit)
        local stocks = db.query(conf.db_option, sql, page_size)
        if stocks then
            data.code = 20000
            data.data = {}
            data.data.total = #stocks
            data.data.items = stocks
        else
            data.code = 60205
            data.message = 'Failed to query data'
        end
    else
        data.code = 60204
        data.message = 'Account and password are incorrect'
    end

    return data
end

local function handleDetail(context)
end

local function handleCreate(context)
    local data = {}

    local u = user.checkUser(context)
    if u then
        local now = ngx.localtime(ngx.now())
        local sql = string.format('INSERT into stock (code, name, description, province, city, industry_id, price, total_number, total_price, last_unlocked_date, last_unlocked_number, created, creator, edited, editor) VALUES ("%s", "%s", "%s", "%s", "%s", %s, %s, %s, %s, "%s", %s, "%s", "%s", "%s", "%s")', context.params.code, context.params.name, context.params.description, context.params.province, context.params.city, context.params.industry_id, context.params.price, context.params.total_number, context.params.total_price, str.formatTime(context.params.last_unlocked_date), context.params.last_unlocked_number, now, u.name, now, u.name) 
        local ret = db.query(conf.db_option, sql, page_size)
        if ret then
            data.code = 20000
            local item = {}
            item.id = ret.insert_id
            item.code = context.params.code
            item.name = context.params.name
            item.description = context.params.description
            item.province = context.params.province
            item.city = context.params.city
            item.industry_id = context.params.industry_id
            item.price = context.params.price
            item.total_number = context.params.total_number
            item.total_price = context.params.total_price
            item.last_unlocked_date = context.params.last_unlocked_date
            item.last_unlocked_number = context.params.last_unlocked_number
            data.data = item
        else
            data.code = 60205
            data.message = 'Failed to query data'
        end
    else
        data.code = 60204
        data.message = 'Account and password are incorrect'
    end

    return data
end

local function handleUpdate(context)
    local data = {}

    local u = user.checkUser(context)
    if u then
        local now = ngx.localtime(ngx.now())
        local sql = string.format('UPDATE stock SET code = "%s", name = "%s", description = "%s", province = "%s", city = "%s", industry_id = %s, price = %s, total_number = %s, total_price = %s, last_unlocked_date = "%s", last_unlocked_number = %s, edited = "%s",  editor = "%s" where id=%s', context.params.code, context.params.name, context.params.description, context.params.province, context.params.city, context.params.industry_id, context.params.price, context.params.total_number, context.params.total_price, str.formatTime(context.params.last_unlocked_date), context.params.last_unlocked_number, now, u.name, context.params.id) 
        ngx.log(ngx.CRIT, "=============>sql:" .. sql)
        local ret = db.query(conf.db_option, sql, page_size)
        if ret then
            data.code = 20000
            local item = {}
            item.id = ret.insert_id
            item.code = context.params.code
            item.name = context.params.name
            item.description = context.params.description
            item.province = context.params.province
            item.city = context.params.city
            item.industry_id = context.params.industry_id
            item.price = context.params.price
            item.total_number = context.params.total_number
            item.total_price = context.params.total_price
            item.last_unlocked_date = context.params.last_unlocked_date
            item.last_unlocked_number = context.params.last_unlocked_number
            data.data = item
        else
            data.code = 60205
            data.message = 'Failed to query data'
        end
    else
        data.code = 60204
        data.message = 'Account and password are incorrect'
    end

    return data
end

local function handleDelete(context)
    local data = {}

    local u = user.checkUser(context)
    if u then
        local now = ngx.localtime(ngx.now())
        local sql = string.format('UPDATE stock SET deleted = 1, edited = "%s", editor = "%s" where id=%s', now, u.name, context.req.args.id) 
        local ret = db.query(conf.db_option, sql, page_size)
        if ret then
            data.code = 20000
            local item = {}
            item.id = context.params.id
            data.data = item
        else
            data.code = 60205
            data.message = 'Failed to query data'
        end
    else
        data.code = 60204
        data.message = 'Account and password are incorrect'
    end

    return data
end

local actions = {
    list = handleList,
    detail = handleDetail,
    create = handleCreate,
    update = handleUpdate,
    delete = handleDelete,
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
