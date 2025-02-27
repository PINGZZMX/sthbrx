getgenv().PinguinESP = {
    Color = Color3.fromRGB(255, 255, 255),
    Transparency = 1,
    Thickness = 1,
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
getgenv().squares = {}
getgenv().lines = {}
getgenv().BoxType = "Full Box"
getgenv().BoxesEnabled = false

local function createFullBox(player)
    local square = Drawing.new('Square')
    square.Thickness = getgenv().PinguinESP.Thickness
    square.Color = getgenv().PinguinESP.Color
    square.Filled = false
    square.Transparency = getgenv().PinguinESP.Transparency
    getgenv().squares[player] = square
end

local function createCornerBox(player)
    local lineSet = {}
    for _ = 1, 8 do
        local line = Drawing.new('Line')
        line.Thickness = getgenv().PinguinESP.Thickness
        line.Color = getgenv().PinguinESP.Color
        line.Transparency = getgenv().PinguinESP.Transparency
        table.insert(lineSet, line)
    end
    getgenv().lines[player] = lineSet
end

function updateBoxesForAllPlayers()
    for player, square in pairs(getgenv().squares) do
        square.Visible = false
    end

    for player, lineSet in pairs(getgenv().lines) do
        for _, line in ipairs(lineSet) do
            line.Visible = false
        end
    end

    if getgenv().BoxesEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if getgenv().BoxType == "Full Box" then
                    createFullBox(player)
                else
                    createCornerBox(player)
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if not getgenv().BoxesEnabled then return end

    if getgenv().BoxType == "Full Box" then
        for player, square in pairs(getgenv().squares) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local parts = player.Character:GetChildren()
                local minX, minY = math.huge, math.huge
                local maxX, maxY = -math.huge, -math.huge

                for _, part in ipairs(parts) do
                    if part:IsA("BasePart") then
                        local size = part.Size / 2
                        local cframe = part.CFrame

                        for x = -1, 1, 2 do
                            for y = -1, 1, 2 do
                                for z = -1, 1, 2 do
                                    local worldPoint = cframe.Position + cframe:VectorToWorldSpace(Vector3.new(size.X * x, size.Y * y, size.Z * z))
                                    local screenPoint, onScreen = Camera:WorldToViewportPoint(worldPoint)

                                    if onScreen then
                                        minX = math.min(minX, screenPoint.X)
                                        minY = math.min(minY, screenPoint.Y)
                                        maxX = math.max(maxX, screenPoint.X)
                                        maxY = math.max(maxY, screenPoint.Y)
                                    end
                                end
                            end
                        end
                    end
                end

                if minX < maxX and minY < maxY then
                    square.Position = Vector2.new(minX, minY)
                    square.Size = Vector2.new(maxX - minX, maxY - minY)
                    square.Visible = true
                else
                    square.Visible = false
                end
            else
                square.Visible = false
            end
        end
    else
        for player, lineSet in pairs(getgenv().lines) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                local parts = player.Character:GetChildren()
                local minX, minY = math.huge, math.huge
                local maxX, maxY = -math.huge, -math.huge

                for _, part in ipairs(parts) do
                    if part:IsA("BasePart") then
                        local size = part.Size / 2
                        local cframe = part.CFrame

                        for x = -1, 1, 2 do
                            for y = -1, 1, 2 do
                                for z = -1, 1, 2 do
                                    local worldPoint = cframe.Position + cframe:VectorToWorldSpace(Vector3.new(size.X * x, size.Y * y, size.Z * z))
                                    local screenPoint, onScreen = Camera:WorldToViewportPoint(worldPoint)

                                    if onScreen then
                                        minX = math.min(minX, screenPoint.X)
                                        minY = math.min(minY, screenPoint.Y)
                                        maxX = math.max(maxX, screenPoint.X)
                                        maxY = math.max(maxY, screenPoint.Y);
                                    end
                                end
                            end
                        end

                        local rootScreenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                        if onScreen and minX < maxX and minY < maxY then
                            local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
                            local offset = 20 * (1 - math.clamp(distance / 100, 0, 1))
                            offset = math.clamp(offset, 5, 20)

                            lineSet[1].From = Vector2.new(minX, minY)
                            lineSet[1].To = Vector2.new(minX + offset, minY)

                            lineSet[2].From = Vector2.new(minX, minY)
                            lineSet[2].To = Vector2.new(minX, minY + offset)

                            lineSet[3].From = Vector2.new(maxX, minY)
                            lineSet[3].To = Vector2.new(maxX - offset, minY)

                            lineSet[4].From = Vector2.new(maxX, minY)
                            lineSet[4].To = Vector2.new(maxX, minY + offset)

                            lineSet[5].From = Vector2.new(minX, maxY)
                            lineSet[5].To = Vector2.new(minX + offset, maxY)

                            lineSet[6].From = Vector2.new(minX, maxY)
                            lineSet[6].To = Vector2.new(minX, maxY - offset)

                            lineSet[7].From = Vector2.new(maxX, maxY)
                            lineSet[7].To = Vector2.new(maxX - offset, maxY)

                            lineSet[8].From = Vector2.new(maxX, maxY)
                            lineSet[8].To = Vector2.new(maxX, maxY - offset)

                            for _, line in ipairs(lineSet) do
                                line.Visible = true
                            end
                        else
                            for _, line in ipairs(lineSet) do
                                line.Visible = false
                            end
                        end
                    else
                        for _, line in ipairs(lineSet) do
                            line.Visible = false
                        end
                    end
                end
            end
        end
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if getgenv().BoxesEnabled then
            updateBoxesForAllPlayers()
        end
    end)
end)

updateBoxesForAllPlayers()
