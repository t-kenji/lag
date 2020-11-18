---
--  LAG - Lua Application Gateway.
--
--  @module     lag
--  @author     t-kenji <protect.2501@gmail.com>
--  @license    MIT
--  @copyright  2020-2021 t-kenji

local stream = require('stream')
local scgi = require('lag.scgi')
local jsonrpc = require('lag.jsonrpc')

local _M = {
    _VERSION = "Lag 0.2.0",
}

local protocols = {
    ['scgi'] = scgi,
    ['jsonrpc'] = jsonrpc,
}

_M.scgi = {}

function _M.scgi.post(route, callback)
    scgi.post(route, callback)
end

setmetatable(_M.scgi, {
    __index = function (self, key)
        return scgi[key]
    end,
    __newindex = function (self, key, value)
        scgi[key] = value
    end
})

_M.jsonrpc = {}

function _M.jsonrpc.request(method, callback)
    jsonrpc.request(method, callback)
end

setmetatable(_M.jsonrpc, {
    __index = function (self, key)
        return jsonrpc[key]
    end,
    __newindex = function (self, key, value)
        jsonrpc[key] = value
    end,
})

function _M.run_with_unix(services)
    for k, v in pairs(services) do
        local proto = protocols[k]
        if not proto then
            error('Not Supported Protocol: ' .. k)
        end

        local sock = stream.unix(v.path)
        stream.onaccept(sock, function (stream_)
            stream_:onreceive(function (s)
                proto.run(v.application, s, s)
            end, not proto.persistence):onerror(function (s, message)
                proto.errors(message, s, s)
            end)
        end)
    end

    stream.serve()
end

return _M
