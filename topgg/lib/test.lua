local http = require('coro-http')
local request = http.request
return function ()
    print("[topgg-lua TEST] Library was loaded successfully")
end
