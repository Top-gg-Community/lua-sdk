local http = require('coro-http');
local request = http.request;
local json = require('json');
local f = string.format;
local insert, concat = table.insert, table.concat;
local running = coroutine.running;

local base_url = 'https://top.gg/api';

local JSON = 'application/json';
local payloadRequired = {PUT = true, PATCH = true, POST = true};

local function parseErrors(ret, errors, key)
   for k, v in pairs(errors) do
      if k == '_errors' then
         for _, err in ipairs(v) do
            insert(ret, f('%s in %s : %s', err.code, key or 'payload', err.message));
         end
      else
         if key then
            parseErrors(ret, v, f(k:find('^[%a_][%a%d_]*$') and '%s.%s' or tonumber(k) and '%s[%d]' or '%s[%q]', k, v));
         else
            parseErrors(ret, v, k);
         end
      end
   end
   return concat(ret, '\n\t');
end

local Api = require('class')('Api');

function Api:init(token, id)
   if type(token) ~= 'string' then
      error("argument 'token' must be a string");
   end
   if type(id) ~= "string" then
    error("argument 'id' must be a string");
   end

   self.token = token;
   self.__id = id;
end

function Api:request(method, path, body)
   local _, main = running();
   if main then
      error('Cannot make HTTP request outside a coroutine', 2);
   end

   local url = base_url .. path;

   local req = {
      {'Authorization', self.token}
   };

   if payloadRequired[method] then
      body = body and json.encode(body) or '{}';
      insert(req, {'Content-Type', JSON});
      insert(req, {'Content-Length', #body});
   end

   local data, err = self:commit(method, url, req, body);
   
   if data then
      return data;
   else
      return nil, err;
   end
end

function Api:commit(method, url, req, body)
   local success, res, msg = assert(pcall(request, method, url, req, body));

   if not success then
      return nil, res;
   end

   for i, v in ipairs(res) do
      res[v[1]:lower()] = v[2];
      res[i] = nil;
   end

   local data = res['content-type'] == JSON and json.decode(msg, 1, json.null) or msg;

   if res.code < 300 then
      print(f('%i - %s : %s %s', res.code, res.reason, method, url));
      return data, nil;
   else if type(data) == 'table' then
      if data.code and data.message then
         msg = f('HTTP Error %i : %s', data.code, data.message);
      else
         msg = 'HTTP Error';
      end

      if data.errors then
         msg = parseErrors({msg}, data.errors);
      end
   end
end
   print(f('%i - %s : %s %s', res.code, res.reason, method, url));
   return nil, msg;
end

function Api:postStats(stats)
   if not stats or not stats.serverCount then
      error('Server count missing');
   end

   if type(stats.serverCount) ~= 'number' then
      error("'serverCount' must be a number");
   end

   stats = {
      {'server_count', stats.serverCount},
      {'shard_id', stats.shardId or 0},
      {'shard_count', stats.shardCount or 0}
   };

   self:request('POST', f('/bots/%i/stats', self.__id), stats);

   return stats;
end

function Api:getStats(id)
   if type(id) ~= 'string' then
      error("argument 'id' must be a string");
   end

   local stats = self:request('GET', f('/bots/%i/stats', id));

   stats = {
      serverCount = stats.server_count,
      shardCount = stats.shard_count,
      shards = stats.shards
   };

   return stats;
end

function Api:getBot(id)
   if type(id) ~= 'string' then
      error("argument 'id' must be a string");
   end

   return self:request('GET', f('/bots/%i', id));
end

function Api:getBots(query)
   if query then
      if type(query.fields) == 'table' then
         query.fields = concat(query.fields, ',');
      end

      if type(query.search) == 'table' then
         local search = {};
         for k, v in pairs(query.search) do
            insert(search, f('%i: %s', k, v));
         end
         query.search = search;
      end
   end

   return self:request('GET', '/bots', query);
end

function Api:getUser(id)
   if type(id) ~= 'string' then
      error("argument 'id' must be a string");
   end

   return self:request('GET', f('/users/%i', id));
end

function Api:getVotes()
   if not self.token then
      error('Missing token');
   end

   return self:request('GET', f('/bots/%i/votes', self.__id));
end

function Api:hasVoted(id)
   if type(id) ~= 'string' then
      error("argument 'id' must be a string");
   end

   local data = self:request('GET', f('/bots/%i/check', self.__id), {{'userId', id}});

   return not not data.voted;
end

function Api:isWeekend()
   local data = self:request('GET', '/weekend');
   return not not data.is_weekend;
end

return Api;
