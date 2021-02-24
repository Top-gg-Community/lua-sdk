package.path = "./?/init.lua" .. package.path
local topgg = require("topgg")
topgg.Api:init(
    "", 
    "753688662449061919"
);

local getUser = coroutine.create(function(server_count)
    print(topgg.Api:postStats({server_count = server_count}));
  end);

coroutine.resume(getUser, 1);
