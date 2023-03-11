local INTERVAL = 1 / 30            -- of simulated character movement
local timeWindow = INTERVAL + 0.01

local getPositions = function()
    local positions = {Options.PrimaryPosition.Value == "Head" and Vector3.new(0, 2, 0) or Options.PrimaryPosition.Value == "Feet" and Vector3.new(0, -2, 0) or Vector3.new()}
    for i,_ in next, Options.ProjectilePositions.Value do
        if i ~= Options.PrimaryPosition.Value then
            table.insert(positions, i == "Head" and Vector3.new(0, 2, 0) or i == "Feet" and Vector3.new(0, -2, 0) or Vector3.new())
        end
    end
    return positions
end

local toXY = function(to, from)
    return (to * Vector3.new(1, 0, 1) - from * Vector3.new(1, 0, 1)).Magnitude, from.Y - to.Y
end
local toXYZ = function(to, from, angle)
    return (CFrame.lookAt(to * Vector3.new(1, 0, 1), from * Vector3.new(1, 0, 1)).Rotation * CFrame.Angles(angle, 0, 0)).LookVector
end

local optimalAngle = function(x, y, v, g)
    local root = v^4 - g * (g * x^2 + 2 * y * v^2)
    if root < 0 then
        return
    end
    root = math.sqrt(root)
    return math.atan((v^2 - root) / (g * x))
end
local lobAngle = function(x, y, v, g)
    local root = v^4 - g * (g * x^2 + 2 * y * v^2)
    if root < 0 then
        return nil
    end
    root = math.sqrt(root)
    return math.atan((v^2 + root) / (g * x))
end
local travelTime = function(x, angle, v)
    return x / (math.cos(angle) * v)
end

local clipVelocity = function(vector, normal)
    local dot = vector:Dot(normal)

    return Vector3.new(vector.X - (normal.X * dot), vector.Y - (normal.Y * dot), vector.Z - (normal.Z * dot))
end
local movement = function(prediction, rotation)
    local progression = 0
    for i = 1, 3 do
        if progression >= 1 or prediction.Velocity.Magnitude < 0.001 then
            break
        end
        local distance = prediction.Velocity.Magnitude * INTERVAL
    
        local offset
        do
            local ray = Ray.new(prediction.Position, Vector3.new(0, prediction.Velocity.Y < 0.01 and -2.75 or 2.75, 0))
            local hit, position = workSpace:FindPartOnRayWithWhitelist(ray, {workSpace.Map.Clips, workSpace.Map.Geometry})
            local verticalDist = math.abs(prediction.Position.Y - position.Y) - 0.01
            offset = Vector3.new(0, prediction.Velocity.Y < 0.01 and -verticalDist or verticalDist, 0)
        end

        do
            local ray = Ray.new(prediction.Position + offset, prediction.Velocity * INTERVAL)
            local hit, position, normal = workSpace:FindPartOnRayWithWhitelist(ray, {workSpace.Map.Clips, workSpace.Map.Geometry})
            if hit then
                distance = (prediction.Position + offset - position).Magnitude - 0.001
            end
            
            local percent = distance / (prediction.Velocity.Magnitude * INTERVAL)
            if progression + percent > 1 then
                distance = prediction.Velocity.Magnitude * INTERVAL * (percent - (progression + percent) % 1)
            end
            progression += percent

            prediction.Position += prediction.Velocity.Unit * distance
            if (not normal or normal.Y < 0.7) and i == 1 then
                prediction.Velocity -= Vector3.new(0, 50 * INTERVAL, 0)
            end
            if normal then
                prediction.Velocity = clipVelocity(prediction.Velocity, normal)
            end
        end
    end

    if rotation and rotation ~= 0 then
        prediction.Velocity = (CFrame.Angles(0, rotation * INTERVAL, 0) * CFrame.new(prediction.Velocity)).Position
    end
    
    return prediction
end

local projectile = function(from, to, simulatedTime, projStats)
    if projStats.Drop == 0 then
        if projStats.Acceleration.Amount == 0 then
            local timeToReach = (from - to).Magnitude / projStats.Speed
            if not simulatedTime and timeToReach < Options.MaximumTravelTime.Value or timeToReach > simulatedTime - timeWindow and timeToReach < simulatedTime then
                return CFrame.lookAt(from, to).LookVector
            end
        else
            
        end
    else
        local x, y = toXY(from, to)
        local rad1 = optimalAngle(x, y, projStats.Speed, projStats.Drop)
        if rad1 then
            local timeToReach = travelTime(x, rad1, projStats.Speed)
            if not simulatedTime and timeToReach < Options.MaximumTravelTime.Value or timeToReach > simulatedTime - timeWindow and timeToReach < simulatedTime then
                return toXYZ(from, to, rad1)
            end
        end
        --[[
        local rad2 = lobAngle(x, y, projStats.Speed, projStats.Drop)
        if rad2 then
            local timeToReach = travelTime(x, rad2, projStats.Speed)
            if not simulatedTime and timeToReach < Options.MaximumTravelTime.Value or timeToReach > simulatedTime - timeWindow and timeToReach < simulatedTime then
                return toXYZ(from, to, rad2)
            end
        end
        ]]
    end
end
local projectileRaycast = function(from, to, angle, simulatedTime, projStats)
    local polyPoints = {Point3D.new(from)}
    if projStats.Drop == 0 then
        local ray = Ray.new(from, to - from)
        local hit = workSpace:FindPartOnRayWithWhitelist(ray, {workSpace.Map.Clips, workSpace.Map.Geometry})
        if hit then
            return false
        end

        table.insert(polyPoints, Point3D.new(to))
    else
        if not simulatedTime then
            local x, y = toXY(from, to) -- lazy, just doing it for a second time
            local rad1 = optimalAngle(x, y, projStats.Speed, projStats.Drop)
            simulatedTime = travelTime(x, rad1, projStats.Speed)
        end
        local momentum = angle * projStats.Speed
        for _ = 1, simulatedTime / INTERVAL do
            local ray = Ray.new(from, momentum * INTERVAL)
            local hit, pos = workSpace:FindPartOnRayWithWhitelist(ray, {workSpace.Map.Clips, workSpace.Map.Geometry})
            if hit then
                return false
            end

            from = pos
            momentum -= Vector3.new(0, projStats.Drop, 0) * INTERVAL

            table.insert(polyPoints, Point3D.new(from))
        end
    end

    if Toggles.ProjectilePredictionLine.Value and not lookVectorOVERRIDE then
        ESP:UpdateObject({
            Key = "ProjectilePredictionLine",
            Drawing = PolyLineDynamic,
            Properties = {Color = Options.ProjectilePredictionLineColor.Value},
            LifeTime = 1
        }, polyPoints)
    end
    return true
end

local playerStorage = {History = {}, Characters = {}}
local playerPredictor = function(targets)
    playerStorage.Characters = {}
    for _,v in next, getPlayers() do
        if v ~= player and v.Character and v.Character:FindFirstChild("Hitbox") and v.Character:FindFirstChild("HumanoidRootPart") then
            if playerStorage.History[v] then
                playerStorage.History[v].Previous = {
                    Position = playerStorage.History[v].Position, 
                    Velocity = playerStorage.History[v].Velocity, 
                }

                playerStorage.History[v].Position = v.Character.Hitbox.Position
                playerStorage.History[v].Velocity = v.Character.HumanoidRootPart.AssemblyLinearVelocity

                if Options.StrafeSamples.Value > 0 and playerStorage.History[v].Velocity.Magnitude > 0.001 then
                    local direction1 = playerStorage.History[v].Velocity * Vector3.new(1, 0, 1)
                    local direction2 = playerStorage.History[v].Previous.Velocity * Vector3.new(1, 0, 1)
                    local rotation = -direction1:Angle(direction2, Vector3.new(0, 1, 0)) * 10 -- correct 0.1 second diffs
                    rotation = rotation == rotation and math.abs(rotation) < 25 and math.clamp(rotation, -5, 5) or 0 -- goofy

                    table.insert(playerStorage.History[v].StrafeSamples, rotation)
                    while #playerStorage.History[v].StrafeSamples > Options.StrafeSamples.Value do
                        table.remove(playerStorage.History[v].StrafeSamples, 1)
                    end

                    local collectiveRotation = 0
                    for _,v in playerStorage.History[v].StrafeSamples do
                        collectiveRotation += v
                    end
                    playerStorage.History[v].Rotation = collectiveRotation / #playerStorage.History[v].StrafeSamples
                else
                    playerStorage.History[v].StrafeSamples = {}
                    playerStorage.History[v].Rotation = 0
                end
            else
                playerStorage.History[v] = {
                    Name = v.Name, 

                    Position = v.Character.Hitbox.Position, 
                    Prediction = v.Character.Hitbox.Position, -- changing position
                    Velocity = v.Character.HumanoidRootPart.AssemblyLinearVelocity, -- (v.Character.Hitbox.Position - playerStorage.History[v].Previous.Position) * 10

                    StrafeSamples = {}
                }
            end
        end
    end

    for i,_ in playerStorage.History do
        if not players:FindFirstChild(i.Name) or not i.Character or not i.Character:FindFirstChild("Hitbox") or not i.Character:FindFirstChild("HumanoidRootPart") then
            playerStorage.History[i] = nil
        end
    end

    for _,v in next, targets do
        if v:IsA("Player") then
            playerStorage.History[v].Prediction = {
                Position = playerStorage.History[v].Position, 
                Velocity = playerStorage.History[v].Velocity
            }

            table.insert(playerStorage.Characters, playerStorage.History[v])
        else
            table.insert(playerStorage.Characters, {
                Position = v.Hitbox.Position, 
                SinglePoint = v.Hitbox.Size.Y < 3, 

                Prediction = {
                    Position = v.Hitbox.Position, 
                    Velocity = v.Hitbox.Position, 
                }
            })
        end
    end
end

local getCandidates = function()
    local candidates = {}

    if variables.gun.Value and projectileData[variables.gun.Value.Name] then
        local projStats = {Speed = projectileData[variables.gun.Value.Name].Speed, Drop = projectileData[variables.gun.Value.Name].Drop or 0, Acceleration = projectileData[variables.gun.Value.Name].Acceleration or {Amount = 0}, Offset = projectileData[variables.gun.Value.Name].Offset}
        if typeof(projStats.Speed) == "function" then
            projStats.Speed = projStats.Speed(true)
        end
        if typeof(projStats.Drop) == "function" then
            projStats.Drop = projStats.Drop()
        end

        for _,character in next, playerStorage.Characters do
            local simulatedTime, stopTime, multipoints, positions = 0, Options.MaximumTravelTime.Value / 1000, {}, getPositions()

            if character.SinglePoint then
                positions = {Vector3.new()}
            end

            local polyPoints = {}
            repeat
                simulatedTime += INTERVAL
                if not character.Name then -- building, only loop once
                    simulatedTime = nil
                end

                character.Prediction = movement(character.Prediction, character.Rotation)
                table.insert(polyPoints, Point3D.new(character.Prediction.Position - Vector3.new(0, 2, 0)))

                local camera, angles = (CFrame.lookAt(workSpace.CurrentCamera.CFrame.Position, character.Prediction.Position) * projStats.Offset).Position, {}
                for i,position in positions do
                    local angle = projectile(camera, character.Prediction.Position + position, simulatedTime, projStats)
                    if angle then
                        angles[#angles + 1] = {angle = angle, position = i}
                    end
                end
                for _,v in angles do
                    if projectileRaycast(camera, character.Prediction.Position + positions[v.position], v.angle, simulatedTime, projStats) then
                        if #multipoints == 0 then
                            stopTime = simulatedTime -- loop 1 more tick to get possibly better positions
                        end

                        character.Position = Toggles.TargetLeadingPosition.Value and character.Prediction.Position or character.Position
                        character.Angle, character.Camera = v.angle, camera
                        character.Points = polyPoints

                        table.insert(multipoints, {Character = character, Point = positions[v.position].Y})
                        positions[v.position] = nil
                        break
                    end
                end
            until not simulatedTime or simulatedTime > stopTime

            if #multipoints ~= 0 then
                for _,v in multipoints do
                    print(v.Point)
                end
                table.sort(candidates, function(a, b)
                    return a.Point < b.Point
                end)
                table.insert(candidates, multipoints[1].Character)
            end
        end
    end

    return candidates
end

Ticks["ProjectileAimbot"] = function(manualCall)
    lookVectorOVERRIDE, cameraOVERRIDE = nil, nil

    playerPredictor(getTargets({
        Teammates = false, 
        AccountFov = not Toggles.TargetLeadingPosition.Value, 
        FOV = Options.ProjectileFieldOfView.Value, 
        Raycast = Toggles.ProjectileVisibilityCheck.Value, 
        TargetBuildings = Toggles.ProjectileTargetBuildings.Value,
        TargetInvisibles = Toggles.ProjectileTargetInvisibles.Value
    }))

    if Toggles.ProjectileSilentAim.Value and Options.ProjectileSilentAimKey:GetState() and not variables.DISABLED.Value and (Toggles.ProjectileAutoShoot.Value or manualCall) then
        local candidates = getCandidates()
        if #candidates > 0 then
            if Options.ProjectileTargeting.Value == "Closest to Cursor" then
                table.sort(candidates, function(a, b)
                    local angle_a = workSpace.Camera.CFrame.LookVector:Angle(CFrame.lookAt(workSpace.Camera.CFrame.Position, a.Position).LookVector)
                    local angle_b = workSpace.Camera.CFrame.LookVector:Angle(CFrame.lookAt(workSpace.Camera.CFrame.Position, b.Position).LookVector)

                    return angle_a < angle_b
                end)
            else
                table.sort(candidates, function(a, b)
                    local distance_a = (workSpace.Camera.CFrame - a.Position).Magnitude
                    local distance_b = (workSpace.Camera.CFrame - b.Position).Magnitude

                    return distance_a < distance_b
                end)
            end

            local target = candidates[1]
            local fovAngle = Toggles.TargetLeadingPosition.Value and math.acos(workSpace.Camera.CFrame.LookVector:Dot(CFrame.lookAt(workSpace.Camera.CFrame.Position, target.Position).LookVector)) * (180 / math.pi) or 0
            if fovAngle < Options.ProjectileFieldOfView.Value then
                if Toggles.PlayerPredictionLine.Value and target.Name then
                    ESP:UpdateObject({
                        Key = target.Name .. ".PlayerPredictionLine",
                        Drawing = PolyLineDynamic,
                        Properties = {Color = Options.PlayerPredictionLineColor.Value},
                        LifeTime = 1
                    }, target.Points)
                end

                lookVectorOVERRIDE, cameraOVERRIDE = target.Angle, target.Camera
                if Toggles.ProjectileAutoShoot.Value then
                    weaponsRequire.firebullet(projectileData[variables.gun.Value.Name].Alt)
                end
            end
        end
    end
end
