----------------------------
-- @file experiment.lua
-- @brief 
-- @author yingx
-- @date 2020-06-05
----------------------------

local cjson = require "cjson"
local hash = require "hash"
local lfs = require "lfs"
local str = require "utils.str"

local conf = {
    delay = 120,
    count = 15,
    filename = "/opt/openresty/services/enginedata/experiment.json"
}

local experiment_loadcount = 0

local exp_reason = {
    ERR_SUCC                   =  0,      -- 成功状态
    ERR_PARAMS                 =  1,      -- 参数错误
    ERR_NOTUPDATED             =  2,      -- 未更新数据
    ERR_PARSEERROR             =  3,      -- 解析错误
}

local experiments_context = {
    data = nil,
    data_md5 = nil,
    lastmodifiedtime = nil,
}

local function isValidString(str)
    return (type(str) == "string" and str ~= "")
end

local function isValidExp(v, now)
    local ret = false

    if v.status == 1 and now >= v.begin_time and now < v.end_time  then
        ret = true
    end

    return ret
end

local function handleLayerParam(layer_param)
    local ops = {}
    ops.keys = {}

    local j = 0
    local params = str.split(layer_param, "&")
    for i, v in ipairs(params) do
        local keyvalue = str.split(v, "=")
        if #keyvalue == 2 then
            local items = str.split(keyvalue[2], ",")
            if string.sub(keyvalue[1], 1, 1) == "!" then
                local key = string.sub(keyvalue[1], 2)
                for j, m in ipairs(items) do
                    ops[string.format("%s_%s", key, m)] =  -1
                end
                ops[key] = 1
                table.insert(ops.keys, key)
            else
                local key = keyvalue[1]
                for j, m in ipairs(items) do
                    ops[string.format("%s_%s", key, m)] =  1
                end
                ops[key] = 0
                table.insert(ops.keys, key)
            end
            j = j + 1
        end
    end
    ops.total = j

    return ops
end

local function queryLayerParam(params, ops)
    local ret = true
    
    for i, v in ipairs(ops.keys) do
        local value = params[v] or "==="
        local keyvalue = string.format("%s_%s", v, value)
        local count = (ops[v] or 0) + (ops[keyvalue] or 0)
        if count ~= 1 then
            ret = false
            break
        end
    end
    
    return ret
end

local function loadExperiments(data, force)
    local ret = exp_reason.ERR_SUCC

    local data_md5 = ngx.md5(data)
    if force or data_md5 ~= experiments_context.data_md5 then
        local ok, value = pcall(cjson.decode, data)
        if ok then
            local now = os.date("%Y%m%d%H%M")
            experiments_context.data = data
            experiments_context.data_md5 = data_md5
            local scenes = {}
            local layers = {}
            local exps = {}
            -- 提取数据
            for i, v in ipairs(value) do
                if v.tag == "scene" then
                    for j, m in ipairs(v.dataList) do
                        if isValidString(m.scene_id) and isValidString(m.uid) then 
                            m.scene_id = str.trim(m.scene_id)
                            m.uid = str.trim(m.uid)
                            scenes[m.scene_id] = m 
                        else
                            ret = exp_reason.ERR_PARAMS
                            break
                        end
                    end
                elseif v.tag == "layer" then
                    for j, m in ipairs(v.dataList) do
                        if isValidString(m.layer_id)
                            and isValidString(m.scene_id)
                            and isValidString(m.layer_param)
                            and isValidString(m.begin_time)
                            and isValidString(m.end_time) then
                            m.layer_id = str.trim(m.layer_id)
                            m.scene_id = str.trim(m.scene_id)
                            m.layer_param = str.trim(m.layer_param)
                            m.begin_time = str.trim(m.begin_time)
                            m.end_time = str.trim(m.end_time)
                            table.insert(layers, m)
                        else
                            ret = exp_reason.ERR_PARAMS
                            break
                        end
                    end
                elseif v.tag == "exp" then
                    for j, m in ipairs(v.dataList) do
                        if isValidString(m.exp_id)
                            and isValidString(m.layer_id)
                            and m.min_bucketnum and m.max_bucketnum
                            and isValidString(m.begin_time)
                            and isValidString(m.end_time) then
                            m.exp_id = str.trim(m.exp_id)
                            m.layer_id = str.trim(m.layer_id)
                            m.begin_time = str.trim(m.begin_time)
                            m.end_time = str.trim(m.end_time)
                            exps[m.layer_id] = exps[m.layer_id] or {}
                            table.insert(exps[m.layer_id], m)
                        else
                            ret = exp_reason.ERR_PARAMS
                            break
                        end
                    end
                end
                if ret ~= exp_reason.ERR_SUCC then
                    break
                end
            end

            if ret == exp_reason.ERR_SUCC then
                -- 预处理数据
                local valid_layers = {}
                for i, v in ipairs(layers) do
                    local scene_id = v.scene_id
                    if v.status == 1 and now <= v.end_time and scenes[scene_id].status == 1 then
                        v.operations = handleLayerParam(v.layer_param)
                        v.scene = scenes[scene_id]
                        v.exps = exps[v.layer_id] or {}
                        table.sort(v.exps, function(a, b)
                            return a.exp_id < b.exp_id
                        end)
                        table.insert(valid_layers, v)
                    end
                end
                table.sort(valid_layers, function(a, b)
                    return a.layer_id < b.layer_id
                end)
                experiments_context.scenes = scenes
                experiments_context.layers = layers
                experiments_context.exps = exps
                experiments_context.valid_layers = valid_layers
            end
        else
            ret = exp_reason.ERR_PARSEERROR
        end
    else
        ret = exp_reason.ERR_NOTUPDATED
    end

    return ret
end

local function initExperiments()
    local load_data

    load_data = function(premature)
        local lastmodifiedtime = lfs.attributes(conf.filename, "modification")
        if lastmodifiedtime then
            if lastmodifiedtime ~= experiments_context.lastmodifiedtime  then
                experiments_context.lastmodifiedtime = lastmodifiedtime
                local f = io.open(conf.filename, "r")
                if f then
                    local data = f:read("*a")
                    f:close()
                    local force = false
                    experiment_loadcount = experiment_loadcount + 1
                    if experiment_loadcount % conf.count == 0 then
                        force = true
                    end
                    local ret = loadExperiments(data, force)
                    if ret == exp_reason.ERR_SUCC then
                        ngx.log(ngx.ERR, "succeed to load experiments, status:" .. ret .. ", data:" .. data)
                    elseif ret ~= exp_reason.ERR_SUCC and ret ~= exp_reason.ERR_NOTUPDATED then
                        ngx.log(ngx.ERR, "failed to load experiments, status:" .. ret .. ", data:" .. data)
                    end
                else
                    ngx.log(ngx.ERR, "failed to open file:" .. conf.filename)
                end
            end
        else
            ngx.log(ngx.ERR, "failed to open file:" .. conf.filename)
        end
    end

    local ok, err = ngx.timer.every(conf.delay, load_data)
    if not ok then
        ngx.log(ngx.ERR, "failed to start timer:" .. err)
    end
    local ok, err = ngx.timer.at(1, load_data)
    if not ok then
        ngx.log(ngx.ERR, "failed to start 0 timer:" .. err)
    end
end

local function getExperiments(params)
    local experiments = {}

    local now = os.date("%Y%m%d%H%M")
    if experiments_context and experiments_context.valid_layers then
        for i, v in ipairs(experiments_context.valid_layers) do
            local hashvalue = params[v.scene.uid] or ""
            if hashvalue ~= "" and isValidExp(v, now) and queryLayerParam(params, v.operations) then
                local hashcode = hash.bkdrhash(v.layer_id .. hashvalue .. v.layer_id) % 100
                for j, m in ipairs(v.exps) do
                    if hashcode >= m.min_bucketnum and hashcode < m.max_bucketnum and isValidExp(m, now) then
                        table.insert(experiments, {
                            exp_id = m.exp_id,
                            exp_param = m.exp_param,
                        })
                    end
                end
            end
        end
    end

    return experiments
end

local _M = {
    exp_reason = exp_reason,
    loadExperiments = loadExperiments,
    getExperiments = getExperiments,
    initExperiments = initExperiments,
}

if _TEST then
    _M.isValidString = isValidString
    _M.isValidExp = isValidExp
    _M.experiments_context = experiments_context
    _M.handleLayerParam = handleLayerParam
    _M.queryLayerParam = queryLayerParam
end

return _M
