local discordia = require('discordia')
local client = discordia.Client()

client:run("Bot [token]")

client:on('ready', function ()
    print(client.guilds:__len())
end)