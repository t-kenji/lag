---
--  LAG JSON-RPC module.
--
--  @module     lag.jsonrpc
--  @author     t-kenji <protect.2501@gmail.com>
--  @license    MIT
--  @copyright  2021 t-kenji

local jsonrpc = require('jsonrpc')
jsonrpc.errors = require('jsonrpc.errors')

local _M = {
    persistence = false,
}

local methods = {}
local onclose = function () end

local function simple_application(environ)
    local callback = methods[environ.method]
    if callback == nil or type(callback) ~= 'function' then
        return nil, jsonrpc.errors.code.METHOD_NOT_FOUND
    end

    local result, error_code
    local ok, err = pcall(function ()
        result = callback({
            [0] = environ,
            request = {
                jsonrpc = environ.jsonrpc,
                method = environ.method,
                params = environ.params,
                id = environ.id,
            },
        })
        assert(result)
    end)
    if not ok then
        print(err)
        error_code = jsonrpc.errors.code.INTERNAL_ERROR
    end

    return result, error_code
end

function _M.request(method, callback)
    methods[method] = callback
end

function _M.run(application, ...)
    application = application or simple_application
    return jsonrpc.run(application, ...)
end

function _M.onclose(handler)
    onclose = handler or function () end
end

function _M.errors(message, s, ...)
    if string.find(message, 'closed$') then
        onclose(s)
    else
        return jsonrpc.errors(message, s, ...)
    end
end

return _M
