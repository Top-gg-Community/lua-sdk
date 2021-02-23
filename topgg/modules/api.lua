local api = { _r = false }


function api:init (token, bot_id)
    if not token then
        error("[topgg-lua API] No token provided.");
    end;
    if type(token) ~= "string" then
        error("[topgg-lua API] Token must be a string");
    end;
    if not bot_id then
        error("[topgg-lua ID] No ID provided.");
    end;
    if type(bot_id) ~= "string" then
        error("[topgg-lua API] ID must be a string");
    end;
    self._r = true;
    self.token = token;
    self.bot_id = bot_id
end;

function api:getBots (query, options)
    local _options = options;
    if not _options then
        _options = {};
    end;
end;

function api:getBot (id)
    if not id then
        error("[topgg-lua API] No ID provided");
    end;
end;


function api:checkVote (id)
    if not id then
        error("[topgg-lua API] No ID provided");
    end;
end;

function api:postStats (stats)
    if not stats.servers then
        error("[topgg-lua API] You must provide at least a server count");
    end;
end;

function api:getUser (id)
    if not id then
        error("[topgg-lua API] No ID provided");
    end;
end;

return api