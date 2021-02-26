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
Here we use our `isWeekend()` and `getStats()` method as an example.
```lua
local topgg = require('topgg');
local Api = topgg.Api:init('YOUR-TOP.GG-TOKEN-GOES-HERE', 'YOUR-CLIENT-ID-GOES-HERE');

local checkWeekend = coroutine.create(function()
  print(topgg.Api:isWeekend());
end);

coroutine.resume(checkWeekend); -- This will print `false` if it's not the weekends but it'll be `true` when it's the weekends.

local getBotStats = coroutine.create(function(id)
  print(topgg.Api:getStats(id));
end);

coroutine.resume(getBotStats, '716061781172158464'); -- This will print a value that can be encoded into a table by using json.decode()
```

## Documentation (Api)
`Api:init(token, id)`
Params | Type | Required | Description
--- | --- | --- | ---
`token` | `string` | ✅ | Your top.gg token
`id` | `string` | ✅ | Your client ID
---
`Api:request(method, path, body, query)`
Params | Type | Required | Description
--- | --- | --- | ---
`method` | `string` | ✅ | The HTTP request method (e.g. `GET`)
`path` | `string` | ✅ | The top.gg endpoint
`body` | `table` | ❌ | The payload to send while making a `POST`, `PATCH` or `PUT` request
`query` | `table` | ❌ | The query for the passed endpoint
---
`Api:commit(method, url, req, body)`
Params | Type | Required | Description
--- | --- | --- | ---
`method` | `string` | ✅ | The HTTP request method (e.g. `GET`)
`url` | `string` | ✅ | The URL to make a request to
`req` | `table` | ❌ | The headers of the request
`body` | `table` | ❌ | The payload to send while making a `POST`, `PATCH` or `PUT` request
---
`Api:postStats(stats)`
Params | Type | Required | Description
--- | --- | --- | ---
`stats` | `table` | ✅ | The stats object
`stats.serverCount` / `stats.server_count` | `number` | ✅ | The client's server count
`stats.shardId` / `stats.shard_id` | `number` | ❌ | The client's shard ID
`stats.shardCount` / `stats.shard_count` | `number` | ❌ | The client's shard count
---
`Api:getStats(id)`
Params | Type | Required | Description
--- | --- | --- | ---
`id` | `string` | ✅ | The ID of the bot to get stats of
---
`Api:getBot(id)`
Params | Type | Required | Description
--- | --- | --- | ---
`id` | `string` | ✅ | The ID of the bot to get information of
---
`Api:getBots(query)`
Params | Type | Required | Description
--- | --- | --- | ---
`query` | `table` | ❌ | The query object
`query.fields` | `any` | ❌ | The fields of the query
`query.search` | `any` | ❌ | The search query
---
`Api:getUser(id)`
Params | Type | Required | Description
--- | --- | --- | ---
`id` | `string` | ✅ | The ID of the user to get information of (top.gg user info)
---
`Api:getVotes()`<br>No params.
---
`Api:hasVoted(id)`
Params | Type | Required | Description
--- | --- | --- | ---
`id` | `string` | ✅ | The ID of the user to check if they have voted for the bot the `Api` class was invoked with
---
`Api:isWeekend()`<br>No params.

## Contributors
[Voltrex](https://github.com/VoltrexMaster)<br>[Matthew.](https://github.com/matthewthechickenman)<br>[MILLION](https://github.com/Million900o)
