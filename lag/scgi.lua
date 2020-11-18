---
--  LAG SCGI module.
--
--  @module     lag.scgi
--  @author     t-kenji <protect.2501@gmail.com>
--  @license    MIT
--  @copyright  2021 t-kenji

local scgi = require('scgi')
scgi.request = require('scgi.request')

local _M = {
    persistence = false,
}

local function make_response(status, headers)
    local function add_header(name, value)
        if headers[name] ~= nil then
            if type(headers[name]) ~= 'table' then
                headers[name] = {headers[name]}
            end
            table.insert(headers[name], value)
        else
            headers[name] = value
        end
    end

    local mt = setmetatable({}, {
        __add = function (self, new)
            for k, v in pairs(new) do
                add_header(k, v)
            end
            return self
        end,

        __index = function (self, key)
            return headers[key]
        end,

        __newindex = function (self, key, value)
            headers[key] = value
        end,

        __pairs = function (self)
            return next, headers, nil
        end,
    })

    return {
        status = status,
        headers = mt,
    }
end

local routes = {}

local function simple_application(environ, start_response)
    local response = make_response('200 OK', {
        ['Content-type'] = 'text/html; charset=utf-8',
    })
    local body = ''

    local callback = routes[environ.SCRIPT_NAME]
    if callback == nil or type(callback) ~= 'function' then
        response.status = '404 Not Found'
    else
        local ok, err = pcall(function ()
            body = callback({
                [0] = environ,
                request = scgi.request.parse(environ),
                response = response,
            })
        end)
        if not ok then
            response.status = '500 Internal Server Error'
            body = err
        end
    end

    start_response(response.status, response.headers)

    return body
end

function _M.post(route, callback)
    routes[route] = callback
end

function _M.run(application, ...)
    application = application or simple_application
    return scgi.run(application, ...)
end

function _M.errors(...)
    return scgi.errors(...)
end

return _M
