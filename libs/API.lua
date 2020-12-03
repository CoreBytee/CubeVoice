local Module = {}

function Module:New(JobId)

    local NewServer = {}

    local ManClient = _G.ManClient

    ManClient:createGuild("CubeVoice Server: " .. JobId)
    local Guild

    ManClient:once("guildCreate", function(GuildGotten)

        Guild = GuildGotten

    end)

    ManClient:waitFor("guildCreate")

    for i, v in pairs(Guild.categories) do
        v:delete()
    end

    for i, v in pairs(Guild.voiceChannels) do
        v:delete()
    end

    for i, v in pairs(Guild.textChannels) do
        v:delete()
    end

    local EveryoneRole = Guild.roles:toArray()[1]
    EveryoneRole:disablePermissions(0x00004000, 0x00008000, 0x00000001, 0x04000000, 0x00040000, 0x00020000)
    --print(EveryoneRole)

    ManClient:on("voiceChannelLeave", function(Member)
        
        if not Member.voiceChannel then
            Member.user:send("You disconnected!")
            Member:kick("You disconnected!")
        end

    end)

    local Role = Guild:createRole("HOST")
    Role:hoist()

    Guild.me:addRole(Role.id)

    local TextCat = Guild:createCategory("Text")

    local NoMicChat = TextCat:createTextChannel("nomic")
    local BotChat = TextCat:createTextChannel("bot")

    local VoiceCat = Guild:createCategory("Voice")

    local JoinChat = VoiceCat:createVoiceChannel("join")
    
    local RoomsCat = Guild:createCategory("Rooms")

    NewServer.JoinChat = JoinChat
    NewServer.NoMicChat = NoMicChat
    NewServer.BotChat = BotChat

    function NewServer:CreateInvite()
        return JoinChat:createInvite({temporary = false, max_uses = 1})
    end
    
    return NewServer

end


return Module