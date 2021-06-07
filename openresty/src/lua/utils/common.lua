local function randomHit(percent, scope)
    if not tonumber(percent) then
        ngx.log(ngx.CRIT, 'random parameter error: percent=' .. tostring(percent))
        return false
    end

    local scope = tonumber(scope) or 100
    local rnd = math.random(scope)
    --ngx.log(ngx.INFO, "[randomHit] random:" .. rnd .. " current:" .. percent)

    return rnd <= percent
end


local _M = {
    randomHit = randomHit,
}

return _M