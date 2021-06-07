-------------------------
-- @file logger.lua
-- @brief ngx logger
-- @author yingx
-- @date 2016-11-23
-------------------------

local bit = require "bit"
local ffi = require "ffi"
local ffi_new = ffi.new
local ffi_str = ffi.string
local C = ffi.C;
local bor = bit.bor;

local mt = { __index = _M } 

ffi.cdef[[
int write(int fd, const char *buf, int nbyte);
int open(const char *path, int access, int mode);
int close(int fd);
]]

local O_RDWR   = 0X0002; 
local O_CREAT  = 0x0040;
local O_APPEND = 0x0400;
local S_IRWXU  = 0x01C0;
local S_IRGRP  = 0x0020;
local S_IROTH  = 0x0004;

local logger = {}

local function shiftFile(log)
    local extension = os.date("%Y-%m-%d-%H")
    if extension ~= log.extension then
        C.close(log.fd);
        log.extension = extension
        log.fd = C.open(log.fullpath .. extension, bor(O_RDWR, O_CREAT, O_APPEND), bor(S_IRWXU, S_IRGRP, S_IROTH));
    end
end

local function newLogger(pathname, filename)
    local log = {}
    log.pathname = pathname
    log.filename = filename
    log.level = LVL_INFO
    log.fullpath = pathname .. filename
    log.extension = os.date("%Y-%m-%d-%H") 
    log.fd = C.open(log.fullpath .. log.extension, bor(O_RDWR, O_CREAT, O_APPEND), bor(S_IRWXU, S_IRGRP, S_IROTH));
    logger.fullpath = log
    return log
end

local function writeMessage(log, message)
    shiftFile(log);
    local c = message .. "\n"
    C.write(log.fd, c, #c);
end

local function logMessage(pathname, filename, message)
    local log
    local fullpath = pathname .. filename
    log = logger[fullpath]
    if not logger[fullpath] then
        log = newLogger(pathname, filename)
        logger[fullpath] = log
    end
    writeMessage(log, message)
end

local _M = {
    logger = logger,
    log = logMessage,
}

return _M
