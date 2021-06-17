--------------------------
-- @file conf.lua
-- @brief 
-- @author yingx
-- @date 2021-06-10
--------------------------

local db_option = {
    host = "127.0.0.1",
    port = 3306,
    -- path = "/path/to/mysql.sock",
    database = "ngx_test",
    user = "ngx_test",
    password = "ngx_test",
    charset = "utf8",
    max_packet_size = 1024 * 1024,
    timeout = 1000,
    max_idle_timeout = 10000,
    pool_size = 100,
}

local _M = {
    db_option = db_option,
}

return _M
