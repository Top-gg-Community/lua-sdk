package.path = "./?/init.lua" .. package.path
local topgg = require("topgg")
local json = require("json")
topgg.Api:init(
    "",
    "647256366280474626"
);

local postStats = coroutine.create(function()
  local res = topgg.Api:postStats({serverCount = 78, shardCount = 1, shardId = 0})
  print(res);
end);

coroutine.resume(postStats)
