package.path = "./?/init.lua" .. package.path
local topgg = require("topgg")
local json = require("json")
topgg.Api:init(
    "",
    ""
);

local postStats = coroutine.create(function()
  local res = topgg.Api:isWeekend("265925031131873281")
  print(res);
end);

coroutine.resume(postStats)
