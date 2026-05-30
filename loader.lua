loadstring(game:HttpGet("https://raw.githubusercontent.com/bro-pixel11/DogeHub/main/ui/main.lua"))()

local WORD_BOMB = 2653064683

if game.PlaceId == WORD_BOMB then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/bro-pixel11/DogeHub/main/games/wordbomb.lua"))()
else
    game.StarterGui:SetCore("SendNotification", {
        Title = "DogeHub",
        Text = "Unsupported game",
        Duration = 5
    })
end