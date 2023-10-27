Drawing.WaitForRenderer()

local ESP = {
    Objects = {}
}

local Create = function(dictionary, ...)
    local object = {}

    object.Drawing = dictionary.Drawing.new(...)
    for key,value in next, dictionary.Properties do
        object.Drawing[key] = value
    end

    object.AutoProperties = {}
    if dictionary.AutoProperties then
        for key,value in next, dictionary.AutoProperties do
            object.AutoProperties[key] = value
        end
    end

    if dictionary.LifeTime then
        object.LifeTime = {Spawn = tick(), Time = dictionary.LifeTime}
    end

    if dictionary.TiedToInstance then
        object.TiedToInstance = {Object = dictionary.TiedToInstance}
    end

    return object
end

function ESP:UpdateObject(dictionary, ...) -- dictionary: Key, Drawing, Properties, AutoProperties, LifeTime, TiedToInstance
    ESP:Remove(dictionary.Key)

    ESP.Objects[dictionary.Key] = Create(dictionary, ...)
end

function ESP:AddObject(dictionary) -- dictionary same as UpdateObject
    if not ESP.Objects[dictionary.Key] then
        ESP:UpdateObject(dictionary)
    end
end

function ESP:Remove(key)
    if ESP.Objects[key] then
        ESP.Objects[key].Drawing.Visible = false
        ESP.Objects[key] = nil
    end
end

function ESP:Filter(filter)
    for i,_ in next, ESP.Objects do
        if i:find(filter) then
            ESP.Objects[i] = nil
        end
    end
end

function ESP:Clear()
    ESP.Objects = {}
end

local enabled = true
function ESP:Toggle()
    enabled = not enabled
    for _,v in next, ESP.Objects do
        v.Drawing.Visible = enabled
    end

    return enabled
end

game:GetService("RunService").Heartbeat:Connect(function()
    for i,v in next, ESP.Objects do
        if v.TiedToInstance and (not v.TiedToInstance.Object or not v.TiedToInstance.Object:IsDescendantOf(game:GetService("Workspace"))) then
            ESP:Remove(i)
        end
        if v.LifeTime and v.LifeTime.Spawn + v.LifeTime.Time < tick() then
            ESP:Remove(i)
        end

        if ESP.Objects[i] then
            for key,value in next, v.AutoProperties do
                v.Drawing[key] = value()
            end
        end
    end
end)

return ESP