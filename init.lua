package.path = './topgg/lib/?.lua;' .. package.path;
return {
    Api = require('api'),
    test = require('test')
}