local http = require('coro-http');
local request = http.request;
local running = coroutine.running;
local f = string.format;
local insert = table.insert;
local json = require('json');
local base_url = 'https://top.gg/api';
local payloadRequired = {PUT = true, PATCH = true, POST = true};

local api = { _r = false };

function api:init(token)
  if type(token) ~= 'string' then
    error('[topgg-lua API] Token must be a string');
  end;
  self._r = true;
  self.token = token;
end;

function api:_request(method, path, body)
  local _, main = running();
  if main then
    error('Cannot make HTTP request outside of a coroutine', 2);
  end

  local url = base_url .. path;

  local req = {
    {'Authorization', self.token}
  };

  if payloadRequired[method] then
    body = body and json.encode(body) or '{}';
    insert(req, {'Content-Type', 'application/json'});
    insert(req, {'Content-Length', #body});
  end

  local data, err = self:commit(method, url, req, body);

  if data then
    return data;
  else
    return nil, err;
  end
end

function api:commit(method, url, req, payload)
  local success, res, msg = pcall(request, method, url, req, payload);

  if not success then
    return nil, res;
  end

  for i, v in ipairs(res) do
    res[v[1]:lower()] = v[2];
    res[i] = nil;
  end

  local data = res['content-type'] == 'application/json' and json.decode(msg, 1, json.null) or msg;

  if res.code < 300 then
    return data, nil;
  end

  if data.code and data.message then
    msg = f('HTTP Error %i : %s', data.code, data.message);
  else
    msg = 'HTTP Error';
  end

  return nil, msg;
end

function api:postStats(stats)
  if not stats or not stats.serverCount then
    error("argument 'stats' is missing 'serverCount'");
  end

  if type(stats.serverCount) ~= 'number' then
    error("property 'serverCount' of argument 'stats' must be a number");
  end

  local data = {
    {'server_count', stats.serverCount},
    {'shard_id', stats.shardId or 0},
    {'shard_count', stats.shardCount or 0}
  };

  self:request('POST', 'bots/stats', data);

  return stats;
end

function api:getStats(id)
  if type(id) ~= 'string' then
    error("argument 'id' must be a string");
  end

  local stats = self:request('GET', f('/bots/%i/stats', id));

  return {serverCount = stats.server_count, shardCount = stats.shard_count, shards = stats.shards};
end

function api:getBot(id)
  if type(id) ~= 'string' then
    error("argument 'id' must be a string");
  end

  return self:request('GET', f('/bots/%i', id));
end

function api:getUser(id)
  if type(id) ~= 'string' then
    error("argument 'id' must be a string");
  end

  return self:request('GET', f('/users/%i', id));
end

function api:getBots(query)
  if query then
    if type(query.fields) == 'table' then query.fields = table.concat(query.fields, ',') end
    if type(query.search) == 'table' then
      local search = {};
      for k, v in pairs(query.search) do
        table.insert(search, f('%i: %s', k, v));
      end
      query.search = search;
    end
  end

  return self:request('GET', '/bots', query);
end

function api:getVotes()
  if type(self.token) ~= 'string' then
    error("Token missing from 'self.token'");
  end

  return self:request('GET', '/bots/votes');
end

function api:hasVoted(id)
  if type(id) ~= 'string' then
    error("argument 'id' must be a string");
  end

  local data = self:request('GET', '/bots/check', {userId = id});

  return not not data.voted;
end

function api:isWeekend()
  local data = self:request('GET', '/weekend');

  return not not data.is_weekend;
end

return api;
