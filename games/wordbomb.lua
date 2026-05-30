--[[
    Word Bomb DogeVoid
    Integrated into DogeHub
    Flow-Based Category System
]]

print("[WORDBOMB] Loading...")

-- ИСПОЛЬЗУЕМ СУЩЕСТВУЮЩИЙ HUB
local lib = _G.DogeLib
local tab = _G.WordBombTab

lib.makelabel("Loading Fioso Dictionary...", tab)

print("[WORDBOMB] Fetching dictionary...")

local ALLWORDS =
game:HttpGet("https://raw.githubusercontent.com/bro-pixel11/dogevoid-dictionary/main/ALLWORDSFILE.txt")

lib.makelabel("Dictionary Loaded!", tab)

local words = string.split(ALLWORDS, "\n")

print("[WORDBOMB] Dictionary loaded: " .. #words .. " words")

-- === BUILD CATEGORY CACHE ===

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

for _, word in ipairs(smoothFlowWords) do
    categoryCache[word] = "smoothFlow"
end

for _, word in ipairs(awkwardReadableWords) do
    categoryCache[word] = "awkwardReadable"
end

for _, word in ipairs(medicalEndgameWords) do
    categoryCache[word] = "medicalEndgame"
end

print("[WORDBOMB] Category cache built")

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

-- === STATE ===

local sessionUsedWords = {}
local lastcontains = ""
local numtopick = 1
local lettercap = math.huge
local enableFallback = true
local numclose = .001

-- === UI ELEMENTS ===

lib.maketextbox("# To Pick", tab, function(num)
    numtopick = tonumber(num) or 1
end)

lib.maketextbox("Letter Cap", tab, function(num)
    lettercap = tonumber(num) or math.huge
end)

lib.maketoggle("Enable Fallback", tab, function(bool)
    enableFallback = bool
    print("[WORDBOMB] Fallback: " .. (bool and "ON" or "OFF"))
end)

local wordLabel = lib.makelabel("Word", tab)

-- === HELPER FUNCTIONS ===

local function isAllCaps(word)
    if not word then return false end
    return word == word:upper() and word:match("[A-Z]")
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

local function getWordCategory(word)
    return categoryCache[word] or "neutral"
end

local function selectWord(foundwords, chunkDiff)
    if not foundwords or #foundwords == 0 then 
        return nil 
    end
    
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

local function getGameContainer()
    local success, result = pcall(function()
        local player = game.Players.LocalPlayer
        local playerGui = player:WaitForChild("PlayerGui", 5)
        local gameUI = playerGui:WaitForChild("GameUI", 5)
        local container = gameUI:WaitForChild("Container", 5)
        local gameSpace = container:WaitForChild("GameSpace", 5)
        local defaultUI = gameSpace:WaitForChild("DefaultUI", 5)
        local gameContainer = defaultUI:WaitForChild("GameContainer", 5)
        
        return gameContainer
    end)
    
    return success and result or nil
end

local function getTextFrame(gameContainer)
    if not gameContainer then return nil end
    
    local success, result = pcall(function()
        local desktop = gameContainer:WaitForChild("DesktopContainer", 3)
        if desktop then
            local infoFrameContainer = desktop:WaitForChild("InfoFrameContainer", 3)
            if infoFrameContainer and #infoFrameContainer:GetChildren() > 0 then
                return infoFrameContainer:WaitForChild("InfoFrame", 3):WaitForChild("TextFrame", 3)
            end
        end
        error("Desktop failed")
    end)
    
    if success then return result end
    
    local success2, result2 = pcall(function()
        local mobile = gameContainer:WaitForChild("Mobile", 3)
        return mobile:WaitForChild("MobileContainer", 3):WaitForChild("InfoFrame", 3):WaitForChild("TextFrame", 3)
    end)
    
    return success2 and result2 or nil
end

-- === MAIN FUNCTION ===

local function copyword(bruteforce)
    local success, err = pcall(function()
        local gameContainer = getGameContainer()
        if not gameContainer then
            lib.updatelabel("UI ERROR", wordLabel)
            return
        end
        
        local gamecontainer = getTextFrame(gameContainer)
        if not gamecontainer then
            lib.updatelabel("UI ERROR", wordLabel)
            return
        end
        
        local contains = ""
        
        for i,v in pairs(gamecontainer:GetChildren()) do
            if v:FindFirstChild("Letter") and v.Visible == true then
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
                lib.updatelabel("Word Not Found", wordLabel)
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
                    tier = "60%"
                elseif #caps_words > 0 and enableFallback then
                    finalword = selectWord(caps_words, chunkDiff)
                    tier = "CAPS"
                end
            else
                if #caps_words > 0 then
                    finalword = selectWord(caps_words, chunkDiff)
                    tier = "40%"
                elseif #lowercase_words > 0 and enableFallback then
                    finalword = selectWord(lowercase_words, chunkDiff)
                    tier = "SHORT"
                end
            end
            
            if finalword then
                sessionUsedWords[finalword:lower()] = true
                lib.updatelabel(finalword .. " [" .. tier .. "]", wordLabel)
            else
                lib.updatelabel("Word Not Found", wordLabel)
            end
        end
    end)
    
    if not success then
        print("[WORDBOMB ERROR] " .. tostring(err))
    end
end

-- === UI BUTTONS ===

lib.makebutton("Search Word", tab, function()
    copyword(true)
end)

local autocopy = false

lib.maketoggle("Auto Search", tab, function(bool)
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

print("[WORDBOMB] Fully loaded and integrated!")
