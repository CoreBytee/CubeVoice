local Token = require("GetEnv")("Token")
local ManToken = require("GetEnv")("ManToken")
local AuthToken = require("GetEnv")("AuthToken")

local Discordia = require("discordia")
local Client = Discordia.Client()
local ManClient = Discordia.Client()
local pathJoin = require('luvi').path.join


local API = require("API")

local Read = require("fs").readFileSync
local Replace = require("ReplaceString")

_G.Client = Client
_G.ManClient = ManClient

local App = require('weblit-app')
local Static = require("weblit-static")

App.bind({host = "0.0.0.0", port = 8080})

App.use(require('weblit-auto-headers'))
App.use(require('weblit-etag-cache'))
--App.use(Static("./Assets"))

App.route({method = "GET", path = "/assets/:path:"}, Static(pathJoin(module.dir, "assets")))

App.route({method = "GET", path = "/"}, function (req, res, go)
    res.body = Read("./Pages/Home.html")
    res.code = 200
    res.headers["Content-Type"] = "text/html"
end)

App.route({method = "GET", path = "/notfound"}, function (req, res, go)
    res.body = Read("./Pages/NotFound.html")
    res.code = 200
    res.headers["Content-Type"] = "text/html"
end)

App.route({method = "GET", path = "/gamenotfound"}, function (req, res, go)
    res.body = Read("./Pages/GameNotFound.html")
    res.code = 200
    res.headers["Content-Type"] = "text/html"
end)

App.route({method = "GET", path = "/enter"}, function (req, res, go)

    local Params = {
        client_id = "783608100958633996", redirect_uri = "http://localhost:8080/login", response_type = "code", scope = "identify guilds"
    }

    local BaseLink = "https://discord.com/api/oauth2/authorize?" .. require("querystring").stringify(Params)

    res.body = '<meta http-equiv="refresh" content="0; url=' .. BaseLink .. '" />'
    res.code = 200
    res.headers["Content-Type"] = "text/html"
end)

App.route({method = "GET", path = "/login"}, function (req, res, go)

    local Code 
    if req.query then
        Code = req.query.code
    end
    res.code = 200
    res.headers["Content-Type"] = "text/html"
    if not Code then 
        res.body = '<meta http-equiv="refresh" content="0; url=/" />'
        return
    end

    local ClientId = "783608100958633996"

    local Data = {
        grant_type =  "client_credentials",
        scope = "identify guilds",
        client_id = ClientId,
        client_secret = AuthToken,
        redirect_uri = "http://localhost:8080/login",
        code = Code
    }

    local Http = require("coro-http")

    local Res, AuthDataBody = Http.request("POST", "https://discord.com/api/oauth2/token", {{"Content-Type", "application/x-www-form-urlencoded"}}, require("querystring").stringify(Data))
    --print(AuthDataBody)

    local AuthData = require("json").decode(AuthDataBody)

    local Res, DataBody = Http.request("GET", "https://discord.com/api/users/@me", {{"Content-Type", "application/x-www-form-urlencoded"}, {"Authorization", AuthData.token_type .. " " .. AuthData.access_token}})
    --print(DataBody)

    local Data = require("json").decode(DataBody)

    local HtmlData = Read("./Pages/UserPageFound.html")
    local RobloxData = API:GetRobloxId(Client:getUser(Data.id))

    --if not RobloxData then
    res.body = '<meta http-equiv="refresh" content="0; url=/notfound" />'
        --return
    --end
    
    local Res, AvatarDataBody = Http.request("GET", "https://thumbnails.roblox.com/v1/users/avatar?userIds=" .. RobloxData.robloxId .. "&size=60x60&format=Png&isCircular=false", {{"Content-Type", "application/json"}})
    local AvatarData = require("json").decode(AvatarDataBody)
    --print(AvatarDataBody)


    res.body = Replace(HtmlData, {

        ["DiscordName"] = Data.username,
        ["DiscordIcon"] = "https://cdn.discordapp.com/avatars/" .. Data.id .. "/" .. Data.avatar,

        ["RobloxName"] = RobloxData.robloxUsername,
        ["RobloxIcon"] = AvatarData.data[1].imageUrl


    })


end)

App.start()

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
    --print(require("json").encode(API:GetRobloxId(ToDM)))
    local NewServer = API:New("test")
	

    --ToDM:send("http://discord.gg/" .. NewServer:CreateInvite().code)

    print("sent")

end)()