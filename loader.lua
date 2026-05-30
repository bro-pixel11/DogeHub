print("loader started")

local place = game.PlaceId

print(place)

local WORD_BOMB = 2653064683

if place == WORD_BOMB then
    print("loading wordbomb")

    loadstring(game:HttpGet("https://raw.githubusercontent.com/bro-pixel11/DogeHub/main/games/wordbomb.lua"))()
else
    print("loading universal")

    loadstring(game:HttpGet("https://raw.githubusercontent.com/bro-pixel11/DogeHub/main/games/universal.lua"))()
end