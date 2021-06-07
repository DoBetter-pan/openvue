local cjson = require "cjson"
local ahocorasick = require "ahocorasick"

local t = {
    "123",
    "456",
    "789",
}
local x = ahocorasick.search("x45123y", t)
print(cjson.encode(x))

local y = ahocorasick.search("abcdef", t)
print(cjson.encode(y))
