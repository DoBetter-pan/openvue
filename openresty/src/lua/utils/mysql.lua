--------------------------
-- @file mysql.lua
-- @brief 
-- @author yingx
-- @date 2021-06-10
--------------------------

local mysql = require "resty.mysql"

local function query(mysql_option, sql, num)
    local db, ok, res, err, errcode, sqlstate 
    db, err = mysql:new()
    if not db then
        return nil, "failed to instantiate mysql: " ..  err
    end
    db:set_timeout(mysql_option.timeout)
    ok, err, errcode, sqlstate = db:connect(mysql_option)
    if not ok then
        return nil, "failed to connect: " .. err .. ", " .. errcode .. " " .. sqlstate
    end
    res, err, errcode, sqlstate = db:query(sql, num)
    if not res then
        return nil, "bad result: " .. err .. ", " .. errcode .. " " .. sqlstate
    end
    ok, err = db:set_keepalive(mysql_option.max_idle_timeout, mysql_option.pool_size)
    -- res.affected_rows,  res.insert_id
    return res
end

local _M = {
    query = query,
}

return _M
