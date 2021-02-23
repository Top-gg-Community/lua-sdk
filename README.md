# topgg-lua
## Installation
To install this library, place it in a topgg folder beside your root folder and require it by using this segment of code:
```lua
package.path = "./?/init.lua;" .. package.path
local topgg = require("topgg")
```
to ensure that it ran successfully, you can run
```lua
topgg.test()
```