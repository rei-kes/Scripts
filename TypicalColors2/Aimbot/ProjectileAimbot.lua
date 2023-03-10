local INTERVAL = 1 / 30            -- of simulated character movement
local timeWindow = INTERVAL + 0.01

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
local movement = function(character)
    local progression = 0
    for i = 1, 3 do
        if progression >= 1 or character.Velocity.Magnitude < 0.001 then
            break
        end
        local distance = character.Velocity.Magnitude * INTERVAL
    
        local offset
        do
            local ray = Ray.new(character.Position, Vector3.new(0, character.Velocity.Y < 0.01 and -2.75 or 2.75, 0))
            local hit, position = workSpace:FindPartOnRayWithWhitelist(ray, {workSpace.Map.Clips, workSpace.Map.Geometry})
            local verticalDist = math.abs(character.Position.Y - position.Y) - 0.01
            offset = Vector3.new(0, character.Velocity.Y < 0.01 and -verticalDist or verticalDist, 0)
        end

        do
            local ray = Ray.new(character.Position + offset, character.Velocity * INTERVAL)
            local hit, position, normal = workSpace:FindPartOnRayWithWhitelist(ray, {workSpace.Map.Clips, workSpace.Map.Geometry})
            if hit then
                distance = (character.Position + offset - position).Magnitude - 0.001
            end
            
            local percent = distance / (character.Velocity.Magnitude * INTERVAL)
            if progression + percent > 1 then
                distance = character.Velocity.Magnitude * INTERVAL * (percent - (progression + percent) % 1)
            end
            progression += percent

            character.Position += character.Velocity.Unit * distance
            if (not normal or normal.Y < 0.7) and i == 1 then
                character.Velocity -= Vector3.new(0, 50 * INTERVAL, 0)
            end
            if normal then
                character.Velocity = clipVelocity(character.Velocity, normal)
            end
        end
    end

    if character.Rotation ~= 0 then
        character.Velocity = (CFrame.Angles(0, character.Rotation * INTERVAL, 0) * CFrame.new(character.Velocity)).Position
    end
    
    return character
end

local projectile = function(from, to, simulatedTime, projStats)
    if projStats.Drop == 0 then
        if projStats.Acceleration.Amount == 0 then
            local timeToReach = (from - to).Magnitude / projStats.Speed
            if timeToReach > simulatedTime - timeWindow and timeToReach < simulatedTime then
                return CFrame.lookAt(from, to).LookVector
            end
        else
            
        end
    else
        local x, y = toXY(from, to)
        local rad1 = optimalAngle(x, y, projStats.Speed, projStats.Drop)
        if rad1 then
            local timeToReach = travelTime(x, rad1, projStats.Speed)
            if timeToReach > simulatedTime - timeWindow and timeToReach < simulatedTime then
                return toXYZ(from, to, rad1)
            end
        end
        --[[
        local rad2 = lobAngle(x, y, projStats.Speed, projStats.Drop)
        if rad2 then
            local timeToReach = travelTime(x, rad2, projStats.Speed)
            if timeToReach > simulatedTime - timeWindow and timeToReach < simulatedTime then
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
                playerStorage.History[v] = {Current = {Position = v.Character.Hitbox.Position, Velocity = v.Character.HumanoidRootPart.AssemblyLinearVelocity--[[(v.Character.Hitbox.Position - playerStorage.History[v].Current.Position) * 10]]}, Past = playerStorage.History[v].Current} -- dictionary hell starts here
            else
                playerStorage.History[v] = {Current = {Position = v.Character.Hitbox.Position, Velocity = v.Character.HumanoidRootPart.AssemblyLinearVelocity}, Past = {Position = v.Character.Hitbox.Position, Velocity = v.Character.HumanoidRootPart.AssemblyLinearVelocity}}
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
            local direction = (playerStorage.History[v].Current.Velocity * Vector3.new(1, 0, 1)).Unit
            local rotation = -direction:Angle(playerStorage.History[v].Past.Velocity * Vector3.new(1, 0, 1), Vector3.new(0, 1, 0)) * 10 -- correct 0.1 second diffs

            table.insert(playerStorage.Characters, {Position = playerStorage.History[v].Current.Position, Velocity = playerStorage.History[v].Current.Velocity, Rotation = rotation == rotation and rotation or 0, Origin = playerStorage.History[v].Current.Position, Name = v.Name})
        else
            table.insert(playerStorage.Characters, {Position = v.Hitbox.Position, Velocity = Vector3.new(), Rotation = 0, Origin = v.Hitbox.Position, NoPositions = v.Hitbox.Size.Y < 3})
        end
    end
end

local getCandidates = function(targets)
    local candidates = {}

    local positions = {Options.PrimaryPosition.Value == "Head" and Vector3.new(0, 2, 0) or Options.PrimaryPosition.Value == "Feet" and Vector3.new(0, -2, 0) or Vector3.new()}
    for i,_ in next, Options.ProjectilePositions.Value do
        if i ~= Options.PrimaryPosition.Value then
            table.insert(positions, i == "Head" and Vector3.new(0, 2, 0) or i == "Feet" and Vector3.new(0, -2, 0) or Vector3.new())
        end
    end

    if variables.gun.Value and projectileData[variables.gun.Value.Name] then
        local projStats = {Speed = projectileData[variables.gun.Value.Name].Speed, Drop = projectileData[variables.gun.Value.Name].Drop or 0, Acceleration = projectileData[variables.gun.Value.Name].Acceleration or {Amount = 0}, Offset = projectileData[variables.gun.Value.Name].Offset}
        if typeof(projStats.Speed) == "function" then
            projStats.Speed = projStats.Speed(true)
        end
        if typeof(projStats.Drop) == "function" then
            projStats.Drop = projStats.Drop()
        end
        if projStats.Speed == 0 then
            return {}
        end

        for _,character in next, playerStorage.Characters do
            local simulatedTime, candidate = 0, nil

            local polyPoints = {}
            repeat
                simulatedTime += INTERVAL

                character = movement(character)
                table.insert(polyPoints, Point3D.new(character.Position - Vector3.new(0, 2, 0)))

                local camera, angles = (CFrame.lookAt(workSpace.CurrentCamera.CFrame.Position, character.Position) * projStats.Offset).Position, {}
                if character.NoPositions then
                    local angle = projectile(camera, character.Position, simulatedTime - ping, projStats)
                    if angle then
                        angles[#angles + 1] = {angle = angle, position = character.Position}
                    end
                else
                    for _,position in positions do
                        local angle = projectile(camera, character.Position + position, simulatedTime - ping, projStats)
                        if angle then
                            angles[#angles + 1] = {angle = angle, position = character.Position + position}
                        end
                    end
                end
                for _,v in angles do
                    if projectileRaycast(camera, v.position, v.angle, simulatedTime, projStats) then
                        candidate = {Position = Toggles.TargetLeadingPosition.Value and character.Position or character.Origin, Angle = v.angle, Camera = camera, Name = character.Name}
                        break
                    end
                end
            until simulatedTime > Options.MaximumTravelTime.Value / 1000 or candidate
            if candidate then
                candidates[#candidates + 1] = {Candidate = candidate, Points = polyPoints}
            end
        end
    end

    return candidates
end

Ticks["ProjectileAimbot"] = function(manualCall)
    lookVectorOVERRIDE, cameraOVERRIDE = nil, nil

    local targets = getTargets(false, not Toggles.TargetLeadingPosition.Value)
    playerPredictor(targets)

    if Toggles.ProjectileSilentAim.Value and Options.ProjectileSilentAimKey:GetState() and not variables.DISABLED.Value and (Toggles.ProjectileAutoShoot.Value or manualCall) then
        local candidates = getCandidates(targets)
        if #candidates > 0 then
            table.sort(candidates, function(a, b)
                local angle_a = workSpace.Camera.CFrame.LookVector:Angle(CFrame.lookAt(workSpace.Camera.CFrame.Position, a.Candidate.Position).LookVector)
                local angle_b = workSpace.Camera.CFrame.LookVector:Angle(CFrame.lookAt(workSpace.Camera.CFrame.Position, b.Candidate.Position).LookVector)

                return angle_a < angle_b
            end)

            local target = candidates[1]
            local fovAngle = Toggles.TargetLeadingPosition.Value and math.acos(workSpace.Camera.CFrame.LookVector:Dot(CFrame.lookAt(workSpace.Camera.CFrame.Position, target.Candidate.Position).LookVector)) * (180 / math.pi) or 0
            if fovAngle < Options.ProjectileFieldOfView.Value then
                if Toggles.PlayerPredictionLine.Value and target.Candidate.Name then
                    ESP:UpdateObject({
                        Key = target.Candidate.Name .. ".PlayerPredictionLine",
                        Drawing = PolyLineDynamic,
                        Properties = {Color = Options.PlayerPredictionLineColor.Value},
                        LifeTime = 1
                    }, target.Points)
                end

                lookVectorOVERRIDE, cameraOVERRIDE = target.Candidate.Angle, target.Candidate.Camera
                if Toggles.ProjectileAutoShoot.Value then
                    spawn(function()
                        weaponsRequire.firebullet(projectileData[variables.gun.Value.Name].Alt)
                    end)
                end
            end
        end
    end
end
