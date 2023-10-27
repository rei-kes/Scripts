local quickReference = {}
local isRelatedTo = function(name, ident)
    if quickReference[ident] then
        local str
        pcall(function()
            str = getfenv(quickReference[ident]).script.Name
        end)
        if str == name then
            return true
        end
    else
        local index = 0
        repeat
            index += 1

            local str
            pcall(function()
                str = getfenv(index).script.Name
            end)
            if str == name then
                quickReference[ident] = index
                return true
            end
        until not str
    end
    return false
end



-- metamethods

local OldNameCall;OldNameCall = hookmetamethod(game, "__namecall", function(...)
    local Args = {...}
    local Self = Args[1]
    if Self and typeof(Self) == "Instance" and getnamecallmethod():lower() == "fireserver" then
        if Self.Name == "BeanBoozled" then -- literally the entire anticheat
            return wait(9e9)

        elseif Self.Name == "CreateProjectile" then
            --Args[11] Toggles.SpoofWeaponCharge.Value and Args[2] == "Stickybomb" and 1

            if overrides.cameraPos then
                Args[3] = workSpace.CurrentCamera.CFrame.Position + overrides.lookVector * 100
                Args[4] = CFrame.lookAt(overrides.cameraPos, Args[3])

                return OldNameCall(unpack(Args, 1, select("#", ...)))
            end
        end
    end
    return OldNameCall(...)
end)

local OldIndex;OldIndex = hookmetamethod(game, "__index", function(Self, Key)
    if Key == "CoordinateFrame" and typeof(Self) == "Instance" and Self.Name == "Camera" and isRelatedTo("Weapons", "Camera") and overrides.lookVector then
        return CFrame.lookAt(Self.CFrame.Position, Self.CFrame.Position + overrides.lookVector)
    end
    return OldIndex(Self, Key)
end)

-- other hooks

do
    local _function = weaponsRequire.firebullet
    weaponsRequire.firebullet = function(...)
        pcall(function()
            if not Toggles.ProjectileAutoShoot.Value and projectileData[variables.gun.Value.Name] then
                Ticks["ProjectileAimbot"].Function(true)
            end
        end)

        _function(...)
    end
end

do
    local _function = getsenv(weaponsScript)["RotCamera"]
    getsenv(weaponsScript)["RotCamera"] = function(...)
        if not overrides.lookVector then
            _function(...)
        end
    end
end



-- loops

global.Ticks = {} --{Function(DeltaTime, ManualCall), <optional> DelayTime}
run.Heartbeat:Connect(function(deltaTime)
    for _,v in Ticks do
        task.spawn(function()
            if not v.DelayTime or not v.LastTime or tick() > v.LastTime + v.DelayTime then
                if v.DelayTime then
                    deltaTime = v.LastTime and tick() - v.LastTime
                    v.LastTime = tick()
                end
                if deltaTime then
                    v.Function(deltaTime)
                end
            end
        end)
    end
end)

    -- specific loops

    Ticks["Ping"] = {Function = function()
        global.ping = _stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    end}