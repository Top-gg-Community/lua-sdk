local autoposter = { __r = false }

function autoposter:init (token)
    if type(token) ~= "string" then
        error("[topgg-lua Autoposter] Token must be a string")
    end;
    self.__r = true;
    self.token = token;
end;

return autoposter