local timer = require('timer');

local wrap, yield = coroutine.wrap, coroutine.yield;
local resume, running = coroutine.resume, coroutine.running;
local insert, remove = table.insert, table.remove;
local setTimeout, clearTimeout = timer.setTimeout, timer.clearTimeout;

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

return EventEmitter;
