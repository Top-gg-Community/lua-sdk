local timer = require('timer');

local wrap, yield = coroutine.wrap, coroutine.yield;
local resume, running = coroutine.resume, coroutine.running;
local insert, remove = table.insert, table.remove;
local setTimeout, clearTimeout = timer.setTimeout, timer.clearTimeout;
local http = require('coro-http');
local request = http.request;
local f = string.format;
local json = require('json');
local base_url = 'https://top.gg/api';
local payloadRequired = {PUT = true, PATCH = true, POST = true};

local EventEmitter = require('class')('EventEmitter');

function EventEmitter:__init()
  self._listeners = {};
end

local function new(self, name, listener)
  local listeners = self._listeners[name];
  if not listeners then
    listeners = {};
    self._listeners[name] = listeners;
  end
  insert(listeners, listener);
  return listener.fn;
end

function EventEmitter:on(name, fn)
  return new(self, name, {fn = fn});
end

function EventEmitter:once(name, fn)
  return new(self, name, {fn = fn, once = true});
end

function EventEmitter:onSync(name, fn)
  return new(self, name, {fn = fn, sync = true});
end

function EventEmitter:onceSync(name, fn)
  return new(self, name, {fn = fn, once = true, sync = true});
end

function EventEmitter:emit(name, ...)
  local listeners = self._listeners[name];
  if not listeners then return end
  for i = 1, #listeners do
    local listener = listeners[i];
    if listener then
      local fn = listener.fn;
      if listener.once then
        listeners[i] = false;
      end
      if listener.sync then
        fn(...);
      else
        wrap(fn)(...);
      end
    end
  end
  if listeners._removed then
    for i = #listeners, 1, -1 do
      if not listeners[i] then
        remove(listeners, i);
      end
    end
    if #listeners == 0 then
      self._listeners[name] = nil;
    end
    listeners._removed = nil;
  end
end

function EventEmitter:getListeners(name)
  local listeners = self._listeners[name];
  if not listeners then return function() end end
  local i = 0;
  return function()
    while i < #listeners do
      i = i + 1;
      if listeners[i] then
        return listeners[i].fn;
      end
    end
  end
end

function EventEmitter:getListenerCount(name)
  local listeners = self._listeners[name];
  if not listeners then return 0 end
  local n = 0;
  for _, listener in ipairs(listeners) do
    if listener then
      n = n + 1;
    end
  end
  return n;
end

function EventEmitter:removeListener(name, fn)
  local listeners = self._listeners[name];
  if not listeners then return end
  for i, listener in ipairs(listeners) do
    if listener and listener.fn == fn then
      listeners[i] = false;
    end
  end
  listeners._removed = true;
end

function EventEmitter:removeAllListeners(name)
  if name then
    self._listeners[name] = nil;
  else
    for k in pairs(self._listeners) do
      self._listeners[k] = nil;
    end
  end
end

function EventEmitter:waitFor(name, timeout, predicate)
  local thread = running();
  local fn;
  fn = self:onSync(name, function(...)
    if predicate and not predicate(...) then return end
    if timeout then
      clearTimeout(timeout);
    end
    self:removeListener(name, fn);
    return assert(resume(thread, true, ...));
  end);
  timeout = timeout and setTimeout(timeout, function()
    self:removeListener(name, fn);
    return assert(resume(thread, false));
  end);
  return yield();
end

local api = { __r = false };

function api:init(token, id)
  if not token or type(token) ~= 'string' then
    error('[topgg-lua API] Token must be a string');
  end;
  if not id or type(id) ~= 'string' then
    error('[topgg-lua API] Bot ID must be a string');
  end;
  self.__r = true;
  self.__bot_id = id
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

  self:_request('POST', f('/bots/%i/stats', self.__bot_id), data);

  return stats;
end

function api:getStats(id)
  if type(id) ~= 'string' then
    error("argument 'id' must be a string");
  end

  local stats = self:_request('GET', f('/bots/%i/stats', id));

  return {serverCount = stats.server_count, shardCount = stats.shard_count, shards = stats.shards};
end

function api:getBot(id)
  if type(id) ~= 'string' then
    error("argument 'id' must be a string");
  end

  return self:_request('GET', f('/bots/%i', id));
end

function api:getUser(id)
  if type(id) ~= 'string' then
    error("argument 'id' must be a string");
  end

  return self:_request('GET', f('/users/%i', id));
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

  return self:_request('GET', '/bots', query);
end

function api:getVotes()
  if type(self.token) ~= 'string' then
    error("Token missing from 'self.token'");
  end

  return self:_request('GET', '/bots/votes');
end

function api:hasVoted(id)
  if type(id) ~= 'string' then
    error("argument 'id' must be a string");
  end

  local data = self:_request('GET', '/bots/check', {userId = id});

  return not not data.voted;
end

function api:isWeekend()
  local data = self:_request('GET', '/weekend');

  return not not data.is_weekend;
end

local Autoposter = { __r = false };

function Autoposter:init (token, client)
    if type(token) ~= "string" then
        error("[topgg-lua Autoposter] Token must be a string")
    end;
    if not client.user.id or not client.guilds:__len() then 
        error("[topgg-lua Autoposter] You did not provide a valid and ready discordia client.")
    end;
    self.__r = true;
    self.__token = token;
    self.__client = client;
end;

local topgg = {Autoposter = Autoposter, Api = api};

return topgg;
