---
--  LAG Authentication module.
--
--  username:role:password_md5sum
--  e.g. `user1:user:a609316768619f154ef58db4d847b75e
--
--  @module     lag.authn
--  @author     t-kenji <protect.2501@gmail.com>
--  @license    MIT
--  @copyright  2020-2021 t-kenji

local _M = {}

local authn = {
    users = setmetatable({}, {__index = table}),
}

function authn.users:index_of(username)
    for i = 1, #self do
        if self[i].username == username then
            return i
        end
    end
end

function authn.users:find(username)
    local i = self.index_of(self, username)
    return self[i]
end

local user_class = {}

function user_class.__tostring(self)
    return self.username .. ':' .. self.role .. ':' .. self.hash
end

function authn:add_user(username, role, hash)
    local user = setmetatable({
        username = username,
        role = role,
        hash = hash,
    }, user_class)
    table.insert(self.users, user)
end

function authn:remove_user(username)
    local i = self.users:index_of(username)
    if i ~= nil then
        table.remove(self.users, i)
    end
end

function authn:remove_all()
    for i = 1, #self.users do
        self.users[i] = nil
    end
end

function authn:concat(s)
    local tmp = {}
    for _, v in ipairs(self.users) do
        table.insert(tmp, tostring(v))
    end
    return table.concat(tmp, s)
end

setmetatable(_M, {
    __tostring = function (self)
        return '{\n  ' .. authn:concat(',\n  ') .. '\n}'
    end
})

function _M.add_user(username, role, hash)
    authn:add_user(username, role, hash)
end

function _M.remove_user(username)
    authn:remove_user(username)
end

function _M.remove_all()
    authn:remove_all()
end

function _M.role(username)
    local user = authn.users:find(username) or {}
    return user.role
end

function _M.load(path)
    _M.remove_all()

    local f = io.open(path, 'r')
    for r in f:lines() do
        for username, role, hash in r:gmatch('(%w+):(%w*):(%w+)') do
            _M.add_user(username, role, hash)
        end
    end
    f:close()
end

function _M.save(path)
    local f = io.open(path, 'w')
    for _, v in ipairs(authn.users) do
        f:write(v.username .. ':' .. v.role .. ':' .. v.hash .. '\n')
    end
    f:close()
end

function _M.authentication(username, hash)
    username = username or ''
    hash = hash or ''

    local user = authn.users:find(username) or {}
    if user.hash == hash then
        return true, user.role
    end
end

return _M
