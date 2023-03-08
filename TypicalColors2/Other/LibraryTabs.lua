local Window = Library:CreateWindow("air pods")
Library:SetWatermark("trinkledink")

local CombatTab = Window:AddTab("Combat")

local HitscanSilentAimBox = CombatTab:AddRightTabbox()
    local HitscanSilentAimTab = HitscanSilentAimBox:AddTab("Hitscan Aimbot")
    HitscanSilentAimTab:AddToggle("HitscanSilentAim", { Text = "Silent Aim" }):AddKeyPicker("HitscanSilentAimKey", { Text = "Silent Aim", Default = "ButtonStart", Mode = "Hold" })
    HitscanSilentAimTab:AddDropdown("HitscanSilentAimTargeting", { Text = "Silent Aim Targeting", Default = "Closest to Cursor", Values = {"Closest to Cursor", "Closest to Character"} })
    --HitscanSilentAimTab:AddDropdown("SilentAimMode", { Text = "Silent Aim Mode", Default = "Camera", Values = {"Camera", "Bullet"} })
    HitscanSilentAimTab:AddSlider("HitscanFieldOfView", { Text = "Field of View", Default = 90, Min = 1, Max = 180, Rounding = 0 })
    HitscanSilentAimTab:AddToggle("WallBang", { Text = "Wall Bang" })
    HitscanSilentAimTab:AddToggle("HitscanAutoShoot", { Text = "Auto Shoot" })
    local HitscanSilentAimSettings = HitscanSilentAimBox:AddTab("Settings")
    HitscanSilentAimSettings:AddToggle("HitscanVisibilityCheck", { Text = "Visibility Check" })
    HitscanSilentAimSettings:AddToggle("HitscanTargetBuildings", { Text = "Target Buildings", Default = true })
    HitscanSilentAimSettings:AddToggle("HitscanTargetInvisibles", { Text = "Target Invisibles" })
    HitscanSilentAimSettings:AddSlider("HeadshotChance", { Text = "Headshot Chance", Default = 100, Min = 0, Max = 100, Rounding = 0, Suffix = "%" })
    HitscanSilentAimSettings:AddSlider("HitscanHitChance", { Text = "Hit Chance", Default = 100, Min = 0, Max = 100, Rounding = 0, Suffix = "%" })

local ProjectileSilentAimBox = CombatTab:AddRightTabbox()
    local ProjectileSilentAimTab = ProjectileSilentAimBox:AddTab("Projectile Aimbot")
    ProjectileSilentAimTab:AddToggle("ProjectileSilentAim", { Text = "Silent Aim" }):AddKeyPicker("ProjectileSilentAimKey", { Text = "Silent Aim", Default = "ButtonStart", Mode = "Hold" })
    ProjectileSilentAimTab:AddDropdown("ProjectileSilentAimTargeting", { Text = "Silent Aim Targeting", Default = "Closest to Cursor", Values = {"Closest to Cursor", "Closest to Character"} })
    ProjectileSilentAimTab:AddToggle("TargetLeadingPosition", { Text = "Target Leading Position" })
    ProjectileSilentAimTab:AddSlider("ProjectileFieldOfView", { Text = "Field of View", Default = 90, Min = 1, Max = 180, Rounding = 0 })
    --ProjectileSilentAimTab:AddToggle("ProjectileAutoShoot", { Text = "Auto Shoot" }) << might implement on fire, redirect if successful
    local ProjectileSilentAimSettings = ProjectileSilentAimBox:AddTab("Settings")
    ProjectileSilentAimSettings:AddSlider("MaximumTravelTime", { Text = "Maximum Travel Time", Default = 1000, Min = 100, Max = 5000, Rounding = 0, Suffix = "ms" })
    ProjectileSilentAimSettings:AddDropdown("ProjectilePositions", { Text = "Projectile Positions", Values = {"Head", "Torso", "Feet"}, Multi = true })
    ProjectileSilentAimSettings:AddDropdown("PrimaryPosition", { Text = "Primary Position", Default = "Feet", Values = {"Head", "Torso", "Feet"} })
    Options.ProjectilePositions:OnChanged(function()
        local empty = true
        for _,_ in next, Options.ProjectilePositions.Value do
            empty = false
        end
        if empty or not Options.ProjectilePositions.Value[Options.PrimaryPosition.Value] then
            Options.ProjectilePositions:SetValue({[Options.PrimaryPosition.Value] = true})
        end
    end)
    Options.ProjectilePositions:SetValue({Head = true, Torso = true, Feet = true})
    Options.PrimaryPosition:OnChanged(function()
        local tbl = Options.ProjectilePositions.Value
        tbl[Options.PrimaryPosition.Value] = true
        Options.ProjectilePositions:SetValue(tbl)
    end)
    ProjectileSilentAimSettings:AddToggle("PlayerPredictionLine", { Text = "Player Prediction Line", Default = true }):AddColorPicker("PlayerPredictionLineColor", { Default = Color3.fromRGB(0, 127, 255) })
    ProjectileSilentAimSettings:AddToggle("ProjectilePredictionLine", { Text = "Projectile Prediction Line", Default = true }):AddColorPicker("ProjectilePredictionLineColor", { Default = Color3.fromRGB(255, 255, 255) })
    ProjectileSilentAimSettings:AddToggle("ProjectileVisibilityCheck", { Text = "Visibility Check" })
    ProjectileSilentAimSettings:AddToggle("ProjectileTargetBuildings", { Text = "Target Buildings", Default = true })
    ProjectileSilentAimSettings:AddToggle("ProjectileTargetInvisibles", { Text = "Target Invisibles" })
    --ProjectileSilentAimSettings:AddSlider("ProjectileHitChance", { Text = "Hit Chance", Default = 100, Min = 0, Max = 100, Rounding = 0, Suffix = "%" }) << might implement confidence
    --ProjectileSilentAimSettings:AddToggle("AutoShootWaits", { Text = "Auto Shoot Waits for Charge" }) << wait for a certain charge



local SettingsTab = Window:AddTab("Settings")
    local function UpdateTheme()
        Library.BackgroundColor = Options.BackgroundColor.Value
        Library.MainColor = Options.MainColor.Value
        Library.AccentColor = Options.AccentColor.Value
        Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor)
        Library.OutlineColor = Options.OutlineColor.Value
        Library.FontColor = Options.FontColor.Value

        Library:UpdateColorsUsingRegistry()
    end
    local Theme = SettingsTab:AddLeftTabbox():AddTab("Theme")
    Theme:AddLabel("Background Color"):AddColorPicker("BackgroundColor", { Default = Library.BackgroundColor })
    Theme:AddLabel("Main Color"):AddColorPicker("MainColor", { Default = Library.MainColor })
    Theme:AddLabel("Accent Color"):AddColorPicker("AccentColor", { Default = Library.AccentColor })
    Theme:AddToggle("Rainbow", { Text = "Rainbow Accent Color" })
    Theme:AddLabel("Outline Color"):AddColorPicker("OutlineColor", { Default = Library.OutlineColor })
    Theme:AddLabel("Font Color"):AddColorPicker("FontColor", { Default = Library.FontColor })
    Theme:AddButton("Default Theme", (function()
        Options.FontColor:SetValueRGB(Color3.fromRGB(255, 255, 255))
        Options.MainColor:SetValueRGB(Color3.fromRGB(28, 28, 28))
        Options.BackgroundColor:SetValueRGB(Color3.fromRGB(20, 20, 20))
        Options.AccentColor:SetValueRGB(Color3.fromRGB(0, 85, 255))
        Options.OutlineColor:SetValueRGB(Color3.fromRGB(50, 50, 50))
        Toggles.Rainbow:SetValue(false)

        UpdateTheme()
    end))
    Theme:AddToggle("Keybinds", { Text = "Show Keybinds Menu", Default = false }):OnChanged(function()
        Library.KeybindFrame.Visible = Toggles.Keybinds.Value
    end)
    Theme:AddToggle("Watermark", { Text = "Show Watermark", Default = false }):OnChanged(function()
        Library:SetWatermarkVisibility(Toggles.Watermark.Value)
    end)
    Options.BackgroundColor:OnChanged(UpdateTheme)
    Options.MainColor:OnChanged(UpdateTheme)
    Options.AccentColor:OnChanged(UpdateTheme)
    Options.OutlineColor:OnChanged(UpdateTheme)
    Options.FontColor:OnChanged(UpdateTheme)
    Toggles.Rainbow:OnChanged(function()
        if not Toggles.Rainbow.Value then
            UpdateTheme()
        end
    end)

local PlayerList = SettingsTab:AddRightTabbox():AddTab("Player List")
    PlayerList:AddDropdown('PlayerListMode', { Text = 'Player selection type', Values = { 'Whitelist', 'Blacklist' }, Default = 1 })
    PlayerList:AddDropdown('PlayerList', { Text = 'Player selection', Values = { 'Loading...' }, Multi = true })
    local refresh = function()
        local playerList = {}
        for _,v in next, players:GetPlayers() do
            if v ~= Player then
                table.insert(playerList, v.Name)
            end
        end
        for i,v in next, Options.PlayerList.Value do -- player selection removal, able to be disabled
            if not players:FindFirstChild(i) then
                Options.PlayerList.Value[i] = nil
            end
        end
        Options.PlayerList.Values = playerList
        Options.PlayerList:SetValues()
    end
    players.PlayerAdded:connect(refresh)
    players.PlayerRemoving:connect(refresh)
    refresh()
