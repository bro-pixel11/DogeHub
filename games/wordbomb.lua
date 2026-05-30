--[[

    Word Bank DogeVoid

    FLOW-BASED CATEGORY SYSTEM

    v5: Optimized Performance + Category Cache

]]

 
getgenv().deletewhendupefound = true

 
print("[STARTUP] Loading lib...")

 
local lib =

loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Lib-18698"))()

 
print("[STARTUP] Lib loaded")

 
task.wait(1)

 
lib.makelib("Word Bank DogeVoid")

 
local main = lib.maketab("Main")

 
local labelstatus =

lib.makelabel("Loading Fioso Dictionary...", main)

 
print("[STARTUP] Starting dictionary load...")

 
local ALLWORDS =

game:HttpGet("https://raw.githubusercontent.com/bro-pixel11/dogevoid-dictionary/main/ALLWORDSFILE.txt")

 
print("[STARTUP] Dictionary loaded, size: " .. #ALLWORDS)

 
lib.updatelabel(

    "Loaded Fioso Dictionary!",

    labelstatus

)

 
local words =

string.split(ALLWORDS, "\n")

 
print("[STARTUP] Words split, count: " .. #words)

 
-- === BUILD CATEGORY CACHE (ONE TIME) ===

 
print("[CACHE] Building category cache...")

 
local categoryCache = {}

 
local smoothFlowWords = {

    "SUPERCALIFRAGILISTICEXPIALIDOCIOUS",

    "FLOCCINAUCINIHILIPILIFICATION",

    "PSEUDOPSEUDOHYPOPARATHYROIDISM",

    "SPHENOPALATINEGANGLIONEURALGIA",

    "PNEUMONOULTRAMICROSCOPICSILICOVOLCANOCONIOSIS",

    "HONORIFICABILITUDINITATIBUS",

    "ANTIDISESTABLISHMENTARIANISM",

    "INCOMPREHENSIBILITY",

    "SESQUIPEDALIAN",

    "INTERNATIONALIZATION",

    "UNCHARACTERISTICALLY",

    "UNCONSTITUTIONALLY",

    "UNPREPOSSESSINGLY",

    "INDEFATIGABLY",

    "SUPERCILIOUSLY",

    "OBSEQUIOUSNESS",

    "PERSPICACIOUSLY",

    "MAGNANIMOUSLY"

}

 
local awkwardReadableWords = {

    "WHATCHAMACALLIT",

    "THINGAMABOB",

    "THINGAMAJIG",

    "GOBBLEDYGOOK"

}

 
local medicalEndgameWords = {

    "KERATOCONJUNCTIVITIDES",

    "THROMBOPHLEBITIDES",

    "OTORHINOLARYNGOLOGICAL",

    "ELECTROENCEPHALOGRAPHER",

    "DICHLORODIFLUOROMETHANE",

    "ELECTROPHORETICALLY",

    "IMMUNOELECTROPHORETICALLY"

}

 
-- Cache smooth flow

for _, word in ipairs(smoothFlowWords) do

    categoryCache[word] = "smoothFlow"

end

 
-- Cache awkward

for _, word in ipairs(awkwardReadableWords) do

    categoryCache[word] = "awkwardReadable"

end

 
-- Cache medical

for _, word in ipairs(medicalEndgameWords) do

    categoryCache[word] = "medicalEndgame"

end

 
print("[CACHE] Category cache built: " .. table.concat({

    "smooth=" .. #smoothFlowWords,

    "awkward=" .. #awkwardReadableWords,

    "medical=" .. #medicalEndgameWords

}, ", "))

 
local sessionUsedWords = {}

 
local numtopick = 1

 
lib.maketextbox("# To Pick", main, function(num)

    numtopick = tonumber(num) or 1

end)

 
local lettercap = math.huge

 
lib.maketextbox("Letter Cap", main, function(num)

    lettercap = tonumber(num) or math.huge

end)

 
local enableFallback = true

 
lib.maketoggle("Enable Fallback", main, function(bool)

    enableFallback = bool

    print("[SETTINGS] Fallback: " .. (bool and "ON" or "OFF"))

end)

 
local lastcontains = ""

local labelword

 
local numclose = .001

local function isAllCaps(word)

    if not word then
        return false
    end

    return word == word:upper() and word:match("[A-Z]")
end

-- === CHUNK CATEGORIES ===

 
local ultraSafeChunks = {

    ["li"] = true, ["un"] = true, ["re"] = true, ["ing"] = true,

    ["tion"] = true, ["able"] = true, ["ment"] = true, ["ness"] = true,

    ["less"] = true, ["ful"] = true, ["ly"] = true, ["er"] = true,

    ["or"] = true, ["ous"] = true, ["al"] = true, ["ity"] = true,

    ["sion"] = true, ["ance"] = true, ["ence"] = true, ["sup"] = true,

    ["ion"] = true, ["pre"] = true, ["con"] = true, ["pro"] = true

}

 
local regularChunks = {

    ["tra"] = true, ["trans"] = true, ["form"] = true, ["port"] = true,

    ["script"] = true, ["graph"] = true, ["phone"] = true, ["logy"] = true,

    ["path"] = true, ["scope"] = true, ["ent"] = true, ["inter"] = true,

    ["over"] = true, ["under"] = true, ["the"] = true, ["and"] = true,

    ["dis"] = true

}

 
local hardChunks = {

    ["hox"] = true, ["bok"] = true, ["qal"] = true, ["kaw"] = true,

    ["qaf"] = true, ["zho"] = true, ["qua"] = true, ["xan"] = true,

    ["xylo"] = true, ["tzh"] = true, ["psych"] = true, ["kerato"] = true,

    ["conjunctiv"] = true, ["phleb"] = true, ["enceph"] = true,

    ["thromb"] = true, ["electro"] = true, ["oto"] = true, ["neuro"] = true

}

 
-- === SAFE UI FETCH ===

 

local function getGameContainer()

    local player = game.Players.LocalPlayer

    if not player then
        return nil
    end

    local playerGui = player:FindFirstChild("PlayerGui")

    if not playerGui then
        return nil
    end

    for _, obj in ipairs(playerGui:GetDescendants()) do

        if obj.Name == "GameContainer" then
            return obj
        end

    end

    return nil
end

 

local function getTextFrame(gameContainer)

    if not gameContainer then
        return nil
    end

    for _, obj in ipairs(gameContainer:GetDescendants()) do

        if obj.Name == "TextFrame" then

            if obj:FindFirstChildWhichIsA("TextLabel", true) then
                return obj
            end

        end

    end

    return nil
end

 local function getChunkDifficulty(chunk)

    if hardChunks[chunk] then

        return "hard"

    elseif regularChunks[chunk] then

        return "regular"

    elseif ultraSafeChunks[chunk] then

        return "ultraSafe"

    else

        return "regular"

    end

end

 
-- O(1) CATEGORY LOOKUP (no loops, no upper calls)

local function getWordCategory(word)

    return categoryCache[word] or "neutral"

end

 
local function selectWord(foundwords, chunkDiff)

    if not foundwords or #foundwords == 0 then 

        return nil 

    end

 
    -- SPLIT BY CATEGORY (O(n) pass, but only once)

    local smoothPool = {}

    local awkwardPool = {}

    local medicalPool = {}

    local neutralPool = {}

 
    for _, word in ipairs(foundwords) do

        local category = getWordCategory(word)

 
        if category == "smoothFlow" then

            table.insert(smoothPool, word)

        elseif category == "awkwardReadable" then

            table.insert(awkwardPool, word)

        elseif category == "medicalEndgame" then

            table.insert(medicalPool, word)

        else

            table.insert(neutralPool, word)

        end

    end

 
    local selected = nil

 
    if chunkDiff == "ultraSafe" then

        local rand = math.random(100)

        if rand <= 95 and #smoothPool > 0 then

            selected = smoothPool[math.random(1, #smoothPool)]

        elseif #neutralPool > 0 then

            selected = neutralPool[math.random(1, #neutralPool)]

        elseif #smoothPool > 0 then

            selected = smoothPool[math.random(1, #smoothPool)]

        end

 
    elseif chunkDiff == "regular" then

        local rand = math.random(100)

        if rand <= 50 and #smoothPool > 0 then

            selected = smoothPool[math.random(1, #smoothPool)]

        elseif rand <= 80 and #awkwardPool > 0 then

            selected = awkwardPool[math.random(1, #awkwardPool)]

        elseif #neutralPool > 0 then

            selected = neutralPool[math.random(1, #neutralPool)]

        elseif #smoothPool > 0 then

            selected = smoothPool[math.random(1, #smoothPool)]

        end

 
    else  -- hard

        local rand = math.random(100)

        if rand <= 70 and #medicalPool > 0 then

            selected = medicalPool[math.random(1, #medicalPool)]

        elseif rand <= 90 and #awkwardPool > 0 then

            selected = awkwardPool[math.random(1, #awkwardPool)]

        elseif #neutralPool > 0 then

            selected = neutralPool[math.random(1, #neutralPool)]

        elseif #medicalPool > 0 then

            selected = medicalPool[math.random(1, #medicalPool)]

        end

    end

 
    return selected

end

 
-- === MAIN COPYWORD FUNCTION ===

 
function copyword(bruteforce)

    local success, err = pcall(function()

     local gameContainer = getGameContainer()

if not gameContainer then
    lib.updatelabel("UI ERROR", labelword)
    return
end

       local gamecontainer = getTextFrame(gameContainer)

if not gamecontainer then

    lib.updatelabel("UI ERROR", labelword)

    return

end
 
local contains = ""

 
      for i,v in pairs(gamecontainer:GetDescendants()) do

          if v:FindFirstChild("Letter") and v:IsA("Frame") and v.Visible then

               if not v.Letter:FindFirstChild("TextLabel") then
    continue
end

local lettercolor = v.Letter.ImageColor3

                local lettercolor2 = Color3.fromRGB(142,148,171)

                local lettercolor3 = Color3.fromRGB(129,156,255)

 
                if

                (

                    math.abs(lettercolor.R - lettercolor2.R) < numclose

                    and

                    math.abs(lettercolor.G - lettercolor2.G) < numclose

                    and

                    math.abs(lettercolor.B - lettercolor2.B) < numclose

                )

                or

                (

                    math.abs(lettercolor.R - lettercolor3.R) < numclose

                    and

                    math.abs(lettercolor.G - lettercolor3.G) < numclose

                    and

                    math.abs(lettercolor.B - lettercolor3.B) < numclose

                )

                then

                    contains = contains .. v.Letter.TextLabel.Text

                end

            end

        end

 
        contains = contains:lower()

 
        if contains == "" then

            return

        end

 
        if lastcontains ~= contains or bruteforce then

            lastcontains = contains

 
            local chunkDiff = getChunkDifficulty(contains)

 
            local foundwords = {}

            for i = 1, #words do

                local v = words[i]:lower()

                if string.find(v, contains) and string.len(v) <= lettercap and not sessionUsedWords[v] then

                    table.insert(foundwords, words[i])

                end

            end

 
            if #foundwords == 0 then

                lib.updatelabel("Word Not Found", labelword)

                return

            end

 
            local lowercase_words = {}

            local caps_words = {}

 
            for _, word in ipairs(foundwords) do

                if isAllCaps(word) then

                    table.insert(caps_words, word)

                else

                    table.insert(lowercase_words, word)

                end

            end

 
            local finalword = nil

            local tier = "BALANCED"

 
            if math.random(100) <= 60 then

                if #lowercase_words > 0 then

                    finalword = selectWord(lowercase_words, chunkDiff)

                    tier = "60% SHORT"

                elseif #caps_words > 0 and enableFallback then

                    finalword = selectWord(caps_words, chunkDiff)

                    tier = "FALLBACK CAPS"

                end

            else

                if #caps_words > 0 then

                    finalword = selectWord(caps_words, chunkDiff)

                    tier = "40% CAPS"

                elseif #lowercase_words > 0 and enableFallback then

                    finalword = selectWord(lowercase_words, chunkDiff)

                    tier = "FALLBACK SHORT"

                end

            end

 
            if finalword then

                sessionUsedWords[finalword:lower()] = true

                lib.updatelabel(finalword .. " [" .. tier .. "]", labelword)

            else

                lib.updatelabel("Word Not Found", labelword)

            end

        end

    end)

 
    if not success then

        print("[ERROR] " .. tostring(err))

    end

end

 
-- === UI SETUP ===

 lib.makebutton("Search Word", main, function()

    copyword(true)

end)

lib.makebutton("Clear Memory", main, function()

    sessionUsedWords = {}

    lib.updatelabel("Memory Cleared", labelword)

end)

 
local autocopy = false

 
lib.maketoggle("Auto Search", main, function(bool)

    autocopy = bool

 
    if bool then

        sessionUsedWords = {}

    end

 
    while autocopy do

        task.wait(.1)

        pcall(function()

            copyword()

        end)

    end

end)

 
labelword = lib.makelabel("Word", main)

 
print("[STARTUP] Script fully loaded!")

 
lib.ondestroyedfunc = function()

    autocopy = false

end