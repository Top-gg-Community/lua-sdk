local Autoposter = { __r = false }

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

return Autoposter