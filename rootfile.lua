package.path = "./?/init.lua" .. package.path
local topgg = require("topgg")
topgg.Api:init(
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjcxNjA2MTc4MTE3MjE1ODQ2NCIsImJvdCI6dHJ1ZSwiaWF0IjoxNTk5ODMzODEwfQ.FQB9OiAYIjNGhwZVCQJTlfKRmV0s6FBrbwUZ3eDhwsM", 
    "716061781172158464"
);

local getUser = coroutine.create(function(id)
    print(topgg.Api:hasVoted(id));
  end);

coroutine.resume(getUser, '265925031131873281');
