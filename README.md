# LAG - Lua Application Gateway

LAG is general purpose, Application Gateway implemented by Lua.

## Features

- Implemented in pure Lua: works with 5.4

## Dependencies

- [lua-stream](https://github.com/t-kenji/lua-stream)
- [lua-scgi](https://github.com/t-kenji/lua-scgi)
- [lua-jsonrpc](https://github.com/t-kenji/lua-jsonrpc)

## Usage

The `lag.lua` file should be download into an `package.path` directory and required by it:

```lua
local lag = require('lag')
```

The module provides the following functions:

### lag.run_with_unix(services)

```lua
lag.route['SCGI']['/'] = function ()
    return 'Hello,World!'
end

lag.route['JSON-RPC']['method'] = function ()
    return 'success'
end

lag.run_with_unix({
    ['SCGI'] = {
        path = '/path/to/scgi.sock',
    },
    ['JSON-RPC'] = {
        path = '/path/to/jsonrpc.sock',
    },
})
```

## License

This module is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See [LICENSE](LICENSE) for details.

