# topgg-lua
## Installation
To install this library, place the topgg folder beside your root folder and require it by using this segment of code:
```lua
package.path = './?/init.lua' .. package.path
local topgg = require('topgg')
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
luvit/secure-socket
```

## Using the library
Start using the API component of the library by using 
```lua
topgg.Api:init(token, id)
```

## Example usage
Here we use our `isWeekend()` method as an example.
```lua
local topgg = require('topgg');
local Api = topgg.Api:init('YOUR-TOP.GG-TOKEN-GOES-HERE', 'YOUR-CLIENT-ID-GOES-HERE');

local checkWeekend = coroutine.create(function()
  print(Api.isWeekend());
end);

coroutine.resume(checkWeekend()); -- This will be `false` if it's not the weekends but it'll be `true` when it's the weekends.
```

## Contributors
[Voltrex](https://github.com/VoltrexMaster)<br>[Matthew.](https://github.com/matthewthechickenman)<br>[MILLION](https://github.com/Million900o)
