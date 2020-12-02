local Token = require("GetEnv")("Token")
local Discordia = require("discordia")
local Client = Discordia.Client()



Client:run("Bot " .. Token)