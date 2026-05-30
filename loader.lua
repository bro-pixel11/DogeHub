local place = game.PlaceId

local WORD_BOMB = 2653064683

if place == WORD_BOMB then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/bro-pixel11/DogeHub/main/games/wordbomb.lua"))()
else
    loadstring(game:HttpGet("https://raw.githubusercontent.com/bro-pixel11/DogeHub/main/games/universal.lua"))()
end