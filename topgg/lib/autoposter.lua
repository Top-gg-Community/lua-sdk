local timer = require('timer');
local setInterval = timer.setInterval;
local Api = require('api');
local EventEmitter = require('EventEmitter');

local AutoPoster = require('class')('AutoPoster', EventEmitter);

function AutoPoster:init(client)
  if not client or not client._user or not client._user.id or not client._token then
    error("argument 'client' must be a client instance");
  end

  self.__post = Api:init(client._token, client._user.id):postStats;

  setInterval(function()
    local poster = coroutine.create(function()
    self.__post({serverCount = client._guilds.__len(), shardCount = client._shard_count});
    self:emit('posted');
  end);
    coroutine.resume(poster);
  end, 900000);

  return self;
end

return AutoPoster;
