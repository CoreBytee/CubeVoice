local Token = require("GetEnv")("Token")
local ManToken = require("GetEnv")("Man+Token")

local Discordia = require("discordia")
local Client = Discordia.Client()
local ManClient = Discordia.Client()

_G.Client = Client
_G.ManClient = ManClient

Client:run("Bot " .. Token)
ManClient:run("Bot " .. ManToken)