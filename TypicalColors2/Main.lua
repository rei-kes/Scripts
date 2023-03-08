if _G.ScriptRan and (_G.ScriptRan == "done" or _G.ScriptRan == "init") then
    error("Script already ran")
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

_G.ScriptRan = "init"



-- defining

getgenv().workSpace = game:GetService("Workspace")
getgenv().players = game:GetService("Players")
getgenv().player = players.LocalPlayer
getgenv().playerGui = player.PlayerGui
getgenv().replicatedStorage = game:GetService("ReplicatedStorage")
getgenv().userInput = game:GetService("UserInputService")
getgenv().run = game:GetService("RunService")
getgenv().stats = game:GetService("Stats")
getgenv().client = playerGui:WaitForChild("GUI"):WaitForChild("Client")
getgenv().variables = client:WaitForChild("Variables")

getgenv().weaponsScript = client:WaitForChild("Functions"):WaitForChild("Weapons")
getgenv().weaponsRequire = require(weaponsScript)



getgenv().Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/Library.lua"))()
getgenv().ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/rei-kes/Scripts/main/TypicalColors2/Other/ESPHandler.lua"))()

getgenv().projectileData = loadstring(game:HttpGet("https://raw.githubusercontent.com/rei-kes/Scripts/main/TypicalColors2/Aimbot/ProjectileData.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/rei-kes/Scripts/main/TypicalColors2/Other/HooksAndLoops.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/rei-kes/Scripts/main/TypicalColors2/Other/LibraryTabs.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/rei-kes/Scripts/main/TypicalColors2/Aimbot/ProjectileAimbot.lua"))()



-- shared variables

getgenv().getPlayers = function()
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
getgenv().checkPlayer = function(playerName)
    if Options.PlayerListMode.Value == "Whitelist" and not Options.PlayerList.Value[playerName] then
        return true
    elseif Options.PlayerListMode.Value == "Blacklist" and Options.PlayerList.Value[playerName] then
        return true
    end
    return false
end

getgenv().getTargets = function(teammates, accountFov)
    local targets = {}
    for _,v in next, getPlayers() do
        if v ~= player and v.Character and
        v.Character:FindFirstChild("UpperTorso") and v.Character:FindFirstChild("Hitbox") and v.Character:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Status") and v.Character:FindFirstChild("Dead") and v.Character.Dead.Value == false and
        (Toggles.ProjectileTargetInvisibles.Value or v.Character.UpperTorso.Transparency < 0.9) and
        (not teammates and v.Status.Team.Value ~= player.Status.Team.Value or teammates and v.Status.Team.Value == player.Status.Team.Value) and
        (not accountFov or accountFov and math.acos(workSpace.Camera.CFrame.LookVector:Dot(CFrame.lookAt(workSpace.Camera.CFrame.Position, v.Character.Hitbox.Position).LookVector)) * (180 / math.pi) < Options.ProjectileFieldOfView.Value) then
            local insert = true
            if Toggles.ProjectileVisibilityCheck.Value then
                local hit = workSpace:FindPartOnRayWithWhitelist(Ray.new(workSpace.CurrentCamera.CFrame.Position, v.Character.Hitbox.Position - workSpace.CurrentCamera.CFrame.Position), {workSpace.Map.Clips, workSpace.Map.Geometry})
                if hit then
                    insert = false
                end
            end

            if insert then
                table.insert(targets, v)
            end
        end
    end
    for _,v in next, workSpace:GetChildren() do
        if Toggles.ProjectileTargetBuildings.Value and v:FindFirstChild("IsABldg") and checkPlayer(v.Owner.Value) and
        players:FindFirstChild(v.Owner.Value) and v:FindFirstChild("Hitbox") and players[v.Owner.Value] ~= player and players[v.Owner.Value]:FindFirstChild("Status") and
        (not teammates and players[v.Owner.Value].Status.Team.Value ~= player.Status.Team.Value or teammates and players[v.Owner.Value].Status.Team.Value == player.Status.Team.Value) and
        (not accountFov or accountFov and math.acos(workSpace.Camera.CFrame.LookVector:Dot(CFrame.lookAt(workSpace.Camera.CFrame.Position, v.Hitbox.Position).LookVector)) * (180 / math.pi) < Options.ProjectileFieldOfView.Value) then
            table.insert(targets, v)
        end
    end
    return targets
end

getgenv().lookVectorOVERRIDE = nil
getgenv().cameraOVERRIDE = nil

Library:Notify("Loaded")
Library:Notify("Press right shift/control to open menu")

_G.ScriptRan = "done"
