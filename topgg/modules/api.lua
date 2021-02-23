local api = { _r = false }


function api:init (token)
    if type(token) ~= "string" then
        error("[topgg-lua API] Token must be a string")
    end;
    self._r = true;
    self.token = token;
end;


return api