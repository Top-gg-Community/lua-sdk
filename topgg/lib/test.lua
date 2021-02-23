local http = require('coro-http')
local request = http.request
return function ()
    print("[topgg-lua TEST] Library was loaded successfully")
    local text = request("GET", "https://top.gg/api")
    print('[topgg-lua TEST] Made request to top.gg/api with status ' .. text.code)
end
