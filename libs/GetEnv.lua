return function(Token)

    return require("../Tokens")[Token] or os.getenv(Token)

end