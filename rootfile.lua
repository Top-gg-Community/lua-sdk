package.path = "./?/init.lua" .. package.path
local topgg = require("topgg")
local json = require("json")
topgg.Api:init(
    "",
    "753688662449061919"
);

local postStats = coroutine.create(function()
  local res = topgg.Api:postStats({serverCount = 1})
  print(res);
end);

coroutine.resume(postStats)
