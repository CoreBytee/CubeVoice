local Module = {}

local Read = require("fs").readSync
local Write = require("fs").writeSync

function Module:GetKey(Store, Key)

    local Data = Read("../Data.json")

end

return Module