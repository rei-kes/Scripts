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
        if Self.Name == "BeanBoozled" or Self.Name == "empty" then -- literally the entire anticheat
            return wait(9e9)

        elseif Self.Name == "CreateProjectile" then
            --Args[11] Toggles.SpoofWeaponCharge.Value and Args[2] == "Stickybomb" and 1

            if cameraOVERRIDE then
                Args[3] = workSpace.CurrentCamera.CFrame.Position + lookVectorOVERRIDE * 100
                Args[4] = CFrame.lookAt(cameraOVERRIDE, Args[3])

                return OldNameCall(unpack(Args))
            end
        end
    end
    return OldNameCall(...)
end)

local OldIndex;OldIndex = hookmetamethod(game, "__index", function(Self, Key)
    if Key == "CoordinateFrame" and typeof(Self) == "Instance" and Self.Name == "Camera" and isRelatedTo("Weapons", "Camera") and lookVectorOVERRIDE then
        return CFrame.lookAt(Self.CFrame.Position, Self.CFrame.Position + lookVectorOVERRIDE)
    end
    return OldIndex(Self, Key)
end)

-- other hooks

do
    local _function = weaponsRequire.firebullet
    weaponsRequire.firebullet = function(...)
        pcall(function()
            if not Toggles.ProjectileAutoShoot.Value and projectileData[variables.gun.Value.Name] then
                Ticks["ProjectileAimbot"](true)
            end
        end)

        _function(...)
    end
end

do
    local _function = getsenv(weaponsScript)["RotCamera"]
    getsenv(weaponsScript)["RotCamera"] = function(...)
        if not lookVectorOVERRIDE then
            _function(...)
        end
    end
end



-- loops

getgenv().Frames = {}
run.Heartbeat:Connect(function()
    local success, _error = pcall(function()
        for _,_function in Frames do
            _function()
        end
    end)
    if not success then print(_error) end
end)

getgenv().Ticks = {}
task.spawn(function()
    while task.wait(0.1) do
        local success, _error = pcall(function()
            for _,_function in Ticks do
                _function()
            end
        end)
        if not success then print(_error) end
    end
end)

    -- specific loops

    Frames["Ping"] = function()
        getgenv().ping = _stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    end
