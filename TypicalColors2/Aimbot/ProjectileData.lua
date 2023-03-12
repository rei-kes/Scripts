local chargeTick = variables:WaitForChild("chargetick")

local function lerp(a, b, t)
    return a + (b - a) * t
end



--[[
    Speed           >> speed of projectile in studs per second
    Drop            >> how much the projectile's Y velocity will reduce by every second
    Acceleration    >> amount the speed will increase per second (the only weapon it was for isn't even in the game anymore, so just not even implemented yet)

    Client          >> if a projectile is initiated on the client immediately
    Offset          >> shift of the origin of the projectile relative to the camera

    Hold            >> if a weapon is fired on the mouse button release
    Alt             >> if a weapon's projectile is used with secondary click
]]
local projectileData = { -- some stuff might be wrong, completely forgot where i got the offsets from
    ["Cold Shoulder"] =         {Speed = 218.75, Drop = 25, Alt = true, Offset = CFrame.new(0, -0.375, 0)},
    ["Mad Milk"] =              {Speed = 63.75, Drop = 25, Offset = CFrame.new(0.75, -0.1875, -1.46875)},
    Sandman =                   {Speed = 187.5, Drop = 25, Alt = true, Offset = CFrame.new(0, -0.375, 0)},
    ["Six Point Shuriken"] =    {Speed = 187.5, Drop = 25, Offset = CFrame.new(0.75, -0.1875, -1.46875)},
    ["Wrap Assassin"] =         {Speed = 187.5, Drop = 25, Alt = true, Offset = CFrame.new(0, -0.375, 0)},

    ["Rocket Launcher"] =       {Speed = 68.75, Offset = CFrame.new(0.75, -0.1875, -1.46875)},
    Airstrike =                 {Speed = "func", Offset = CFrame.new(0.75, -0.1875, -1.46875)}, -- (Aerial Bomber)
    ["Cow Mangler 5000"] =      {Speed = 68.75, Offset = CFrame.new(0.75, -0.1875, -1.46875)},
    ["Direct Hit"] =            {Speed = 123.75, Offset = CFrame.new(0.75, -0.1875, -1.46875)},
    ["Double Trouble"] =        {Speed = 68.75, Offset = CFrame.new(0.75, -0.1875, -1.46875)},
    ["G-Bomb"] =                {Speed = 68.75, Offset = CFrame.new(0.75, -0.1875, -1.46875)},
    ["Liberty Launcher"] =      {Speed = 96.25, Offset = CFrame.new(0.75, -0.1875, -1.46875)},
    Maverick =                  {Speed = 82.5, Drop = 25, Offset = CFrame.new(0.75, -0.1875, -1.46875)},
    Original =                  {Speed = 68.75, Offset = CFrame.new(0, -1, -1.46875)},
    ["Personal Death Ray"] =    {Speed = 50, Offset = CFrame.new(0.5, -0.1875, -1.46875)},
    --["Rocket Jumper"] - ignore
    ["Torpedo Tube"] =          {Speed = 68.75, Acceleration = {Amount = 51.2, Max = 123.75}, Offset = CFrame.new(0.75, -0.1875, -1.46875)},
    ["Wrecker's Yard"] =        {Speed = 68.75, Offset = CFrame.new(0.75, -0.1875, -1.46875)},

    Detonator =                 {Speed = 125, Drop = 25, Offset = CFrame.new(0.75, -0.1875, -1.46875)},
    ["Flare Gun"] =             {Speed = 125, Drop = 25, Offset = CFrame.new(0.75, -0.1875, -1.46875)},

    ["Grenade Launcher"] =      {Speed = 76, Drop = 50, Offset = CFrame.new(0.5, -0.375, -1)},
    ["Stickybomb Launcher"] =   {Speed = "func", Drop = 50, Hold = true, Offset = CFrame.new(0.5, -0.375, -1)},
    ["Bikini Bomber"] =         {Speed = 76, Drop = 50, Offset = CFrame.new(0.5, -0.375, -1)},
    ["Irish Guard"] =           {Speed = "func", Drop = 50, Hold = true, Offset = CFrame.new(0.5, -0.375, -1)},
    ["Iron Bomber"] =           {Speed = 76, Drop = 50, Offset = CFrame.new(0.5, -0.375, -1)},
    ["Loch-n-Load"] =           {Speed = 76, Drop = 50, Offset = CFrame.new(0.5, -0.375, -1)},
    ["Loose Cannon"] =          {Speed = 76, Drop = 50, Hold = true, DoubleDonk = true, Offset = CFrame.new(0.5, -0.375, -1)},
    ["Quickiebomb Launcher"] =  {Speed = "func", Drop = 50, Hold = true, Offset = CFrame.new(0.5, -0.375, -1)},
    --["Sticky Jumper"] - ignore
    Ultimatum =                 {Speed = 76, Drop = 50, Offset = CFrame.new(0.5, -0.375, -1)},

    ["Short Circuit"] =         {Speed = 75, Alt = true, Offset = CFrame.new(0.5, -0.1875, -1.46875)},
    --Wrangler =                {Speed = 68.75, Alt = true}, -- only do projectile shit if alt fire

    ["Rescue Ranger"] =         {Speed = 150, Drop = 12.5, Client = true, Offset = CFrame.new(0.5, -0.1875, -1.46875)},
    ["Syringe Crossbow"] =      {Speed = 150, Drop = 12.5, Client = true, Offset = CFrame.new(0.5, -0.1875, -1.46875)}, -- implement auto teammate heal
    ["Milk Pistol"] =           {Speed = 150, Drop = 12.5, Client = true, Offset = CFrame.new(0.5, -0.1875, -1.46875)}, -- (The Dairy Douser)

    Huntsman =                  {Speed = "func", Drop = "func", Client = true, Hold = true, Offset = CFrame.new(0.5, -0.1875, -1.46875)},
    Lemonade =                  {Speed = 63.75, Drop = 25, Offset = CFrame.new(0.75, -0.1875, -1.46875)}
}

 -- variable stats      (note: most if not all are placeholders for future use)

projectileData.Airstrike.Speed = function()
    return player.Character:FindFirstChild("RocketJumped") and 110 or 68.75
end
projectileData["Stickybomb Launcher"].Speed = function(bool)
    if bool and Toggles.AutoShootWaits.Value and (tick() - chargeTick.Value) / 4 < 0.9 then
        return 0
    else
        if Toggles.SpoofWeaponCharge.Value then
            return 115.75
        else
            return lerp(50.3125, 115.75, (tick() - chargeTick.Value) / 4)
        end
    end
end
projectileData["Irish Guard"].Speed = function(bool)
    if bool and Toggles.AutoShootWaits.Value and (tick() - chargeTick.Value) / 4 < 0.9 then
        return 0
    else
        if Toggles.SpoofWeaponCharge.Value then
            return 115.75
        else
            return lerp(50.3125, 115.75, (tick() - chargeTick.Value) / 4)
        end
    end
end
projectileData["Quickiebomb Launcher"].Speed = function(bool)
    if bool and Toggles.AutoShootWaits.Value and (tick() - chargeTick.Value) / 1.2 < 0.9 then
        return 0
    else
        if Toggles.SpoofWeaponCharge.Value then
            return 115.75
        else
            return lerp(50.3125, 115.75, (tick() - chargeTick.Value) / 1.2)
        end
    end
end
projectileData.Huntsman.Speed = function(bool)
    if bool and Toggles.AutoShootWaits.Value and tick() - chargeTick.Value < 1 then
        return 0
    else
        return lerp(113.25, 162.5, tick() - chargeTick.Value)
    end
end
projectileData.Huntsman.Drop = function(bool)
    if bool and Toggles.AutoShootWaits.Value and tick() - chargeTick.Value < 1 then
        return 0
    else
        return lerp(50, 25, tick() - chargeTick.Value)
    end
end

return projectileData
