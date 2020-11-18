---
--  LAG Session module.
--
--  @module     lag.session
--  @author     t-kenji <protect.2501@gmail.com>
--  @license    MIT
--  @copyright  2020 t-kenji

local _M = {}

math.randomseed(os.time())

local alnum = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'

_M.sessions = setmetatable({
    remove = function (self, id)
        for i = 1, #self do
            if self[i].id == id then
                self[i] = nil
            end
        end
    end,
}, {__index = table})

function _M.generate(length)
    local len = length or 20
    local key = ""
    for _ = 1, len do
        key = key .. string.char(alnum:byte(math.random(1,#alnum)))
    end
    return key
end

function _M.find_by_id(id)
    local s = _M.sessions
    for i = 1, #s do
        if s[i].id == id then
            return s[i]
        end
    end
end

function _M.find_by_user(username)
    local s = _M.sessions
    for i = 1, #s do
        if s[i].username == username then
            return s[i]
        end
    end
end

function _M.add(id, username)
    if _M.find_by_id(id) ~= nil then
        return false, id .. ' is already exists'
    end

    local now = os.time()
    local s = {
        id = id,
        username = username,
        timestamp = {
            login = now,
            access = now,
        },
    }
    setmetatable(s, {
        __tostring = function (self)
            return '{' .. self.id .. ',' ..
                   self.username .. ',' ..
                   self.timestamp.login .. ',' ..
                   self.timestamp.access .. '}'
        end,
    })
    function s:update(username)
        self.timestamp.access = os.time()
        if username then
            self.username = username
        end
    end
    table.insert(_M.sessions, s)

    return s
end

function _M.del(id)
    _M.sessions:remove(id)
end

function _M.dump()
    print('sessions:')
    for i, v in ipairs(_M.sessions) do
        print(i, v.id, v.username, v.timestamp.login, v.timestamp.access)
    end
end

return _M
