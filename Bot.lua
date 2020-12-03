local Token = require("GetEnv")("Token")
local ManToken = require("GetEnv")("ManToken")

local Discordia = require("discordia")
local Client = Discordia.Client()
local ManClient = Discordia.Client()

local API = require("API")

_G.Client = Client
_G.ManClient = ManClient

coroutine.wrap(function()

    Client:run("Bot " .. Token)
    Client:waitFor("ready")
    print("Client ready!")

    ManClient:run("Bot " .. ManToken)
    ManClient:waitFor("ready")
    print("ManClient ready!")

    for i, v in pairs(ManClient.guilds) do 
        v:delete()
    end

    print("Deleted guilds")

    local ToDM = Client:getUser("533536581055938580")

    local NewServer = API:New("test")

    ToDM:send("http://discord.gg/" .. NewServer:CreateInvite().code)

    print("sent")

end)()