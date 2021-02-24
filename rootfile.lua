package.path = "./?/init.lua" .. package.path
local topgg = require("topgg")
local json = require("json")
topgg.Api:init(
    "", 
    "753688662449061919"
);

local postStats = coroutine.create(function()
  return coroutine.yield(topgg.Api:getStats("716061781172158464"));
end);
