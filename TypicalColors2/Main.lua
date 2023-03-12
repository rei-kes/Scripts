if _G.ScriptRan and (_G.ScriptRan == "done" or _G.ScriptRan == "init") then
    error("Script already ran")
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

_G.ScriptRan = "init"



-- defining

getgenv().global = getgenv()

global.workSpace = game:GetService("Workspace")
global.players = game:GetService("Players")
global.player = players.LocalPlayer
global.playerGui = player.PlayerGui
global.replicatedStorage = game:GetService("ReplicatedStorage")
global.userInput = game:GetService("UserInputService")
global.run = game:GetService("RunService")
global._stats = game:GetService("Stats")
global.client = playerGui:WaitForChild("GUI"):WaitForChild("Client")
global.variables = client:WaitForChild("Variables")

global.weaponsScript = client:WaitForChild("Functions"):WaitForChild("Weapons")
global.weaponsRequire = require(weaponsScript)



global.Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/Library.lua"))()
global.ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/rei-kes/Scripts/main/TypicalColors2/Other/DrawingHandler.lua"))() -- loadstring(readfile("DrawingHandler.lua"))()

global.projectileData = loadstring(game:HttpGet("https://raw.githubusercontent.com/rei-kes/Scripts/main/TypicalColors2/Aimbot/ProjectileData.lua"))() -- loadstring(readfile("ProjectileData.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/rei-kes/Scripts/main/TypicalColors2/Other/HooksAndLoops.lua"))() -- loadstring(readfile("HooksAndLoops.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/rei-kes/Scripts/main/TypicalColors2/Other/LibraryTabs.lua"))() -- loadstring(readfile("LibraryTabs.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/rei-kes/Scripts/main/TypicalColors2/Aimbot/ProjectileAimbot.lua"))() -- loadstring(readfile("ProjectileAimbot.lua"))()



-- shared variables

global.getPlayers = function()
    local prunedList = {}
    for _,v in next, players:GetPlayers() do
        if Options.PlayerListMode.Value == "Whitelist" and not Options.PlayerList.Value[v.Name] then
            table.insert(prunedList, v)
        elseif Options.PlayerListMode.Value == "Blacklist" and Options.PlayerList.Value[v.Name] then
            table.insert(prunedList, v)
        end
    end
    return prunedList
end
global.checkPlayer = function(playerName)
    if Options.PlayerListMode.Value == "Whitelist" and not Options.PlayerList.Value[playerName] then
        return true
    elseif Options.PlayerListMode.Value == "Blacklist" and Options.PlayerList.Value[playerName] then
        return true
    end
    return false
end

global.getTargets = function(info) -- Teammates, AccountFov, FOV, Raycast, TargetBuildings, TargetInvisibles
    local targets = {}

    for _,v in next, getPlayers() do
        if v ~= player and v.Character and
        v.Character:FindFirstChild("UpperTorso") and v.Character:FindFirstChild("Hitbox") and v.Character:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Status") and v.Character:FindFirstChild("Dead") and v.Character.Dead.Value == false and
        (info.TargetInvisibles or v.Character.UpperTorso.Transparency < 0.9) and
        (not info.Teammates and v.Status.Team.Value ~= player.Status.Team.Value or info.Teammates and v.Status.Team.Value == player.Status.Team.Value) and
        (not info.AccountFov or info.AccountFov and workSpace.Camera.CFrame.LookVector:Angle(CFrame.lookAt(workSpace.Camera.CFrame.Position, v.Character.Hitbox.Position).LookVector) * (180 / math.pi) < info.FOV) then
            table.insert(targets, v)
        end
    end
    for _,v in next, workSpace:GetChildren() do
        if info.TargetBuildings and v:FindFirstChild("IsABldg") and checkPlayer(v.Owner.Value) and
        players:FindFirstChild(v.Owner.Value) and v:FindFirstChild("Hitbox") and players[v.Owner.Value] ~= player and players[v.Owner.Value]:FindFirstChild("Status") and
        (not info.Teammates and players[v.Owner.Value].Status.Team.Value ~= player.Status.Team.Value or info.Teammates and players[v.Owner.Value].Status.Team.Value == player.Status.Team.Value) and
        (not info.AccountFov or info.AccountFov and workSpace.Camera.CFrame.LookVector:Angle(CFrame.lookAt(workSpace.Camera.CFrame.Position, v.Hitbox.Position).LookVector) * (180 / math.pi) < info.FOV) then
            table.insert(targets, v)
        end
    end

    if info.Raycast then
        for i,v in targets do
            local hit = workSpace:FindPartOnRayWithWhitelist(Ray.new(workSpace.CurrentCamera.CFrame.Position, v.Character.Hitbox.Position - workSpace.CurrentCamera.CFrame.Position), {workSpace.Map.Clips, workSpace.Map.Geometry})
            if hit then
                targets[i] = nil
            end
        end
    end

    return targets
end

global.lookVectorOVERRIDE = nil
global.cameraOVERRIDE = nil

Library:Notify("Loaded")
Library:Notify("Press right shift/control to open menu")

_G.ScriptRan = "done"
