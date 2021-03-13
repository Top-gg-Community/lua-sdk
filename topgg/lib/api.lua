local http = require('coro-http');
local request = http.request;
local json = require('json');
local f, gsub, byte = string.format, string.gsub, string.byte;
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

function Api:init(token)
   if type(token) ~= 'string' then
      error("argument 'token' must be a string");
   end
   self.token = token;
end

local function tohex(char)
   return f('%%%02X', byte(char));
end

local function urlencode(obj)
   return (gsub(tostring(obj), '%W', tohex));
end

function Api:request(method, path, body, query)
   local _, main = running();
   if main then
      error('Cannot make HTTP request outside a coroutine', 2);
   end

   local url = base_url .. path;
   
   if query and next(query) then
     for k, v in pairs(query) do
       insert(url, #url == 1 and '?' or '&');
       insert(url, urlencode(k));
       insert(url, '=');
       insert(url, urlencode(v));
     end
     url = concat(url);
   end

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
   local success, res, msg = pcall(request, method, url, req, body);

   if not success then
      return nil, res;
   end

   for i, v in ipairs(res) do
      res[v[1]:lower()] = v[2];
      res[i] = nil;
   end

   local data = res['content-type'] == JSON and json.decode(msg, 1, json.null) or msg;

   if res.code < 300 then
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
   return nil, msg;
end

function Api:postStats(stats)
   if not stats or (not stats.serverCount and not stats.server_count) then
      error('Server count missing');
   end

   if type(stats.serverCount) ~= 'number' and type(stats.server_count) ~= 'number' then
      error("'serverCount' must be a number");
   end

   local __stats = {
      server_count = stats.serverCount or stats.server_count,
   };

   if (stats.shardId or stats.shard_id) and (stats.shardCount or stats.shard_count) then
     __stats.shard_id = stats.shard_id or stats.shardId
     __stats.shard_count = stats.shard_count or stats.shardCount
   end

   local _, res = self:request('POST', '/bots/stats', __stats);
   return res;
end

function Api:getStats(id)
   if type(id) ~= 'string' then
      error("argument 'id' must be a string");
   end

   local stats = self:request('GET', f('/bots/%s/stats', id));

   return stats;
end

function Api:getBot(id)
   if type(id) ~= 'string' then
      error("argument 'id' must be a string");
   end

   return self:request('GET', f('/bots/%s', id));
end

function Api:getBots(query)
   if query then
      if type(query.fields) == 'table' then
         query.fields = concat(query.fields, ',');
      end

      if type(query.search) == 'table' then
         local search = {};
         for k, v in pairs(query.search) do
            insert(search, f('%s: %s', k, v));
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

   return self:request('GET', f('/users/%s', id));
end

function Api:getVotes()
   if not self.token then
      error('Missing token');
   end

   return self:request('GET', '/bots/votes');
end

function Api:hasVoted(id)
   if type(id) ~= 'string' then
      error("argument 'id' must be a string");
   end
   local data = self:request('GET', f('/bots/check?userId=%s', id));

   return not not data.voted;
end

function Api:isWeekend()
   local data = self:request('GET', '/weekend');
   return not not data.is_weekend;
end

return Api;
