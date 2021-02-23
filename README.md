# topgg-lua
## Installation
To install this library, place the topgg folder beside your root folder and require it by using this segment of code:
```lua
package.path = "./?/init.lua" .. package.path
local topgg = require("topgg")
```
to ensure that it ran successfully, you can run
```lua
topgg.test()
```

## Dependencies
Install the following dependencies from the lit repository:
```
creationix/coro-http@3.2.0
luvit/json
```

## Using the library
Start using the API component of the library by using 
```lua
topgg.Api:init(token, id)
```
token being your top.gg token and id being your bot id.
