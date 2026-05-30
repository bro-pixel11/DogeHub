_G.DogeLib =
loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Lib-18698"))()

_G.DogeLib.makelib("DogeHub")

_G.HomeTab = _G.DogeLib.maketab("Home")
_G.WordBombTab = _G.DogeLib.maketab("WordBomb")

_G.DogeLib.makelabel("DogeHub Loaded", _G.HomeTab)
