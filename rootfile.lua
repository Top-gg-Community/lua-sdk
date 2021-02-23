package.path = "./?/init.lua" .. package.path
local topgg = require("topgg")
topgg.Api:init(
    "token", 
    "id"
);

local getUser = coroutine.create(function(id)
    print(topgg.Api:hasVoted(id));
  end);

coroutine.resume(getUser, '265925031131873281');
