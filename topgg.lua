local topgg = {}

topgg.Api = { _r: false }
topgg.Autoposter { _r: false }
topgg.Webhook = { _r: false }

function topgg.Api.init (token) {
    self._r = true
    self.token = token
}
function topgg.Autoposter.init (token) {
    self._r = true
    self.token = token
}

-- Webhooks need to be init'd differently (with a HTTP server, to listen for top.ggs http requests, duh!).

return topgg