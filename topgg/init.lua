package.path = './deps/?/init.lua;./deps/?.lua;./topgg/lib/?.lua;./deps/secure-socket/?.lua;' .. package.path;
return {
    Api = require('api'),
    test = require('test')
}