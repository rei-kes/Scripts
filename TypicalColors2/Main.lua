if _G.ScriptRan and (_G.ScriptRan == "done" or _G.ScriptRan == "init") then
    error("Script already ran")
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

_G.ScriptRan = "init"



getgenv().global = getgenv()

global.Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/Library.lua"))()
global.ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/rei-kes/Scripts/main/TypicalColors2/Other/DrawingHandler.lua"))() -- loadstring(readfile("DrawingHandler.lua"))()

loadstring(game:HttpGet("https://raw.githubusercontent.com/rei-kes/Scripts/main/TypicalColors2/Others/Globals.lua"))() -- loadstring(readfile("Globals.txt"))()

global.projectileData = loadstring(game:HttpGet("https://raw.githubusercontent.com/rei-kes/Scripts/main/TypicalColors2/Aimbot/ProjectileData.lua"))() -- loadstring(readfile("ProjectileData.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/rei-kes/Scripts/main/TypicalColors2/Other/HooksAndLoops.lua"))() -- loadstring(readfile("HooksAndLoops.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/rei-kes/Scripts/main/TypicalColors2/Other/LibraryTabs.lua"))() -- loadstring(readfile("LibraryTabs.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/rei-kes/Scripts/main/TypicalColors2/Aimbot/ProjectileAimbot.lua"))() -- loadstring(readfile("ProjectileAimbot.lua"))()

Library:Notify("Loaded")
Library:Notify("Press right shift/control to open menu")

_G.ScriptRan = "done"