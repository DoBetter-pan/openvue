--------------------------
-- @file lang.lua
-- @brief 
-- @author yingx
-- @date 2021-06-10
--------------------------

local lang_string = {
    ["success"] = {
        ZH = "成功",
        EN = "success",
    },
    ["wrong parameter"] = {
        ZH = "参数错误",
        EN = "wrong parameter",
    },
    success = {
        ZH = "成功",
        EN = "success",
    },
}

local function language(str, lan)
    local ret = str
    local x = lan
    if not x then
        x = "ZH"
    end
    if lang_string[str] and lang_string[str][x] then
        ret = lang_string[str][x]
    end
    return ret
end

local _M = {
    L = language,
}

return _M
