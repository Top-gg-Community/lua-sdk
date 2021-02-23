local topgg = {}

topgg.Api = { _r = false };
topgg.Autoposter = { _r = false };
topgg.Webhook = { _r = false };

function topgg.Api:init (token)
    if type(token) ~= "string" then
        error("[topgg-lua API] Token must be a string")
    end;
    self._r = true;
    self.token = token;
end;

function topgg.Autoposter:init (token)
    if type(token) ~= "string" then
        error("[topgg-lua API] Token must be a string")
    end;
    self._r = true;
    self.token = token;
end;


-- Webhooks need to be init'd differently (with a HTTP server, to listen for top.ggs http requests, duh!).

return topgg