package.path = './deps/?/init.lua;./deps/?.lua;./topgg/lib/?.lua;' .. package.path;
print(package.path)
return {
    Api = require('api'),
    test = require('test')
}