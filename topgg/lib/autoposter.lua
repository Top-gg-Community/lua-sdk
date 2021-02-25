local timer = require('timer');
local setInterval = timer.setInterval;
local Api = require('api');
local EventEmitter = require('EventEmitter');

local AutoPoster = require('class')('AutoPoster', EventEmitter);

function AutoPoster:init(apiToken, client)
  if not client or not client.user or not client.user.id or not client.guilds or not client.guilds.__len() then
    error("argument 'client' must be a discordia/discordia-like client instance");
  end

  Api:init(apiToken, client.user.id)

  setInterval(function()
    local poster = coroutine.create(function()
    local stats = {serverCount = client.guilds.__len()}
    if client.totalShardCount then
        stats.shardCount = client.totalShardCount
    end
    Api:postStats(stats);
    self:emit('posted');
  end);
    coroutine.resume(poster);
  end, 900000);

  return self;
end

return AutoPoster;
