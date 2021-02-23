local topgg = {};

topgg.Autoposter = require('topgg/modules/autoposter');
topgg.Api = require('topgg/modules/api');

return topgg;

--- Init checker, run this before every function (that isn't an init function, or a webhook function.)
--- if not self.__r then         
---     error("[topgg-lua Autoposter] Autoposter not initialized")
--- end;
