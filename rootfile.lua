package.path = "./?/init.lua" .. package.path
local topgg = require("topgg")
topgg.Api:init(
    "", 
    "753688662449061919"
);

local getUser = coroutine.create(function(server_count)
    print(topgg.Api:getUser("544676649510371328"));
  end);

coroutine.resume(getUser, 1);
