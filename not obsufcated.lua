
-- PEPE HUB with stable TPNearestBase + void trick + key system + integrated boost + improved anti-cheat bypass

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local random = Random.new()
local key = "AISP10MXCH"

-- ✅ Ping monitoring
local ping = 0
local function updatePing()
    local start = tick()
    game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer("")
    RunService.Heartbeat:Connect(function()
        ping = (tick() - start) * 1000 -- Ping in ms
    end)
end
task.spawn(updatePing)

-- ✅ MONITOREO DE MUERTE
local deadSince = nil
local deadTimeout = 6 -- segundos muerto antes de rejoin
task.spawn(function()
    while task.wait(1) do
        local char = player.Character
        if char then
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            if hum then
                if hum.Health <= 0 then
                    if not deadSince then
                        deadSince = tick()
                    elseif (tick() - deadSince) > deadTimeout then
                        -- Rejoin
                        game:GetService("TeleportService"):Teleport(game.PlaceId, player)
                    end
                else
                    deadSince = nil
                end
            end
        end
    end
end)

local function saveKey()
    local ts = tick()
    writefile("pepehubfixedkey.txt", HttpService:JSONEncode({ key = key, time = ts }))
end

local function isKeyValid()
    if isfile("pepehubfixedkey.txt") then
        local data = HttpService:JSONDecode(readfile("pepehubfixedkey.txt"))
        return data.key == key and (tick() - data.time) <= 86400
    end
    return false
end

local hrp = nil
player.CharacterAdded:Connect(function()
    hrp = player.Character:WaitForChild("HumanoidRootPart")
end)
if player.Character then
    hrp = player.Character:WaitForChild("HumanoidRootPart")
end

-- ✅ Anti-cheat bypass function
local function safeTeleport(targetCFrame)
    if not hrp then return end
    local delay = math.clamp(ping / 1000 * 1.2, 0.05, 0.12) -- Ajustado para 80-90 ms
    
    -- Simular movimiento gradual para evitar detección
    local steps = 10 -- Más pasos para mayor suavidad
    local currentPos = hrp.Position
    local targetPos = targetCFrame.Position
    local stepVector = (targetPos - currentPos) / steps
    local velocity = stepVector / (delay / steps) -- Simular velocidad
    
    for i = 1, steps do
        hrp.CFrame = CFrame.new(currentPos + stepVector * i)
        hrp.AssemblyLinearVelocity = velocity -- Simular movimiento natural
        task.wait(delay / steps)
    end
    
    -- Establecer posición final
    hrp.CFrame = targetCFrame
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) -- Resetear velocidad
    
    -- Void trick (una sola vez)
    task.wait(delay)
    hrp.CFrame = CFrame.new(0, -3e40, 0)
    task.wait(delay)
    hrp.CFrame = targetCFrame
    
    -- Anclar posición para contrarrestar anti-cheat
    for i = 1, 5 do
        task.wait(delay)
        hrp.CFrame = targetCFrame
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end

-- ✅ STEAL instantáneo con truco de vacío (ping-adaptado + anti-cheat bypass)
function TweenSteal()
    if not hrp then return end
    local forwardOffset = hrp.CFrame.LookVector * 6
    local targetPos = hrp.Position + forwardOffset
    local targetCF = CFrame.new(targetPos)
    
    safeTeleport(targetCF)
end

-- ✅ BASE MÁS CERCANA con teletransporte + void (ping-adaptado + anti-cheat bypass)
function TPNearestBase()
    if not hrp then return end
    local closestSpawn = nil
    local minDist = math.huge

    for _,v in pairs(workspace.Plots:GetChildren()) do
        if v:FindFirstChild("PlotSign") and v:FindFirstChild("AnimalPodiums") then
            local base = v.PlotSign:FindFirstChild("YourBase")
            if base and not base.Enabled then
                for _, podium in pairs(v.AnimalPodiums:GetChildren()) do
                    if podium:IsA("Model") and podium:FindFirstChild("Base") and podium.Base:FindFirstChild("Spawn") then
                        local spawn = podium.Base.Spawn
                        local dist = (spawn.Position - hrp.Position).Magnitude
                        if dist < minDist and dist <= 100 then
                            minDist = dist
                            closestSpawn = spawn
                        end
                    end
                end
            end
        end
    end

    if not closestSpawn then return end
    local to = closestSpawn.CFrame * CFrame.new(0,2,0)
    
    safeTeleport(to)
end

-- RAINBOW
local function rainbowStroke(stroke)
    coroutine.wrap(function()
        while stroke and stroke.Parent do
            local t = tick()
            stroke.Color = Color3.fromHSV((t % 5) / 5, 1, 1)
            RunService.RenderStepped:Wait()
        end
    end)()
end

local function createMainGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "PepeHubGUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = player:WaitForChild("PlayerGui")

    local function makeButton(name, text, pos, callback)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(0, 100, 0, 100)
        btn.Position = pos
        btn.AnchorPoint = Vector2.new(0.5, 1)
        btn.Text = text
        btn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Arcade
        btn.TextSize = 24
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Parent = gui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 0)
        corner.Parent = btn

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 2
        stroke.Parent = btn
        rainbowStroke(stroke)

        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    -- Integrated Boost GUI
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 100, 0, 50)
    frame.Position = UDim2.new(1, -110, 0.5, -25)
    frame.BackgroundColor3 = Color3.new(0,0,0)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 1, -10)
    textLabel.Position = UDim2.new(0, 5, 0, 5)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.Arcade
    textLabel.Text = "Boost - OFF"
    textLabel.TextColor3 = Color3.new(1,1,1)
    textLabel.TextScaled = true
    textLabel.Parent = frame

    local border = Instance.new("Frame")
    border.Size = UDim2.new(1, 6, 1, 6)
    border.Position = UDim2.new(0, -3, 0, -3)
    border.BackgroundColor3 = Color3.fromHSV(0,1,1)
    border.BorderSizePixel = 0
    border.ZIndex = frame.ZIndex - 1
    border.Parent = frame

    spawn(function()
        local hue = 0
        while frame and frame.Parent do
            hue = (hue + 0.01) % 1
            border.BackgroundColor3 = Color3.fromHSV(hue,1,1)
            wait(0.03)
        end
    end)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1,0,1,0)
    button.Position = UDim2.new(0,0,0,0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = frame

    local boosted = false
    local normalWalkSpeed = player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.WalkSpeed or 16
    local flyUpSpeed = 50
    local flying = false
    local ws = 50

    local function lockWalkSpeed()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            humanoid.WalkSpeed = ws
            humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if humanoid.WalkSpeed ~= ws and boosted then
                    humanoid.WalkSpeed = ws
                end
            end)
        end
    end

    local function onHeartbeat(step)
        if boosted and flying and hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, flyUpSpeed, hrp.AssemblyLinearVelocity.Z)
        end
    end

    button.MouseButton1Click:Connect(function()
        boosted = not boosted
        if boosted then
            lockWalkSpeed()
            textLabel.Text = "Boost - ON"
        else
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = normalWalkSpeed
            end
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
            end
            flying = false
            textLabel.Text = "Boost - OFF"
        end
    end)

    UIS.JumpRequest:Connect(function()
        if boosted then
            flying = true
            task.delay(0.5, function()
                flying = false
            end)
        end
    end)

    RunService.Heartbeat:Connect(onHeartbeat)

    -- Botones principales
    makeButton("BaseButton", "BASE", UDim2.new(0.5, -110, 1, -20), TPNearestBase)
    makeButton("StealButton", "STEAL", UDim2.new(0.5, 110, 1, -20), TweenSteal)

    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.F then
            TPNearestBase()
        elseif input.KeyCode == Enum.KeyCode.G then
            TweenSteal()
        end
    end)
end

local function createKeyPrompt()
    local gui = Instance.new("ScreenGui")
    gui.Name = "PepeHubKeyGUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 180)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "PEPE HUB"
    title.Font = Enum.Font.Arcade
    title.TextSize = 30
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Parent = frame

    local textbox = Instance.new("TextBox")
    textbox.Size = UDim2.new(0.8, 0, 0, 40)
    textbox.Position = UDim2.new(0.1, 0, 0.5, -20)
    textbox.PlaceholderText = "Enter Key"
    textbox.Text = ""
    textbox.TextSize = 18
    textbox.Font = Enum.Font.Arcade
    textbox.TextColor3 = Color3.new(1, 1, 1)
    textbox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    textbox.BorderSizePixel = 0
    textbox.Parent = frame

    local submit = Instance.new("TextButton")
    submit.Size = UDim2.new(0.8, 0, 0, 32)
    submit.Position = UDim2.new(0.1, 0, 1, -42)
    submit.Text = "UNLOCK"
    submit.Font = Enum.Font.Arcade
    submit.TextSize = 20
    submit.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    submit.TextColor3 = Color3.new(1, 1, 1)
    submit.BorderSizePixel = 0
    submit.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Parent = submit
    rainbowStroke(stroke)

    submit.MouseButton1Click:Connect(function()
        if textbox.Text == key then
            saveKey()
            gui:Destroy()
            createMainGUI()
        else
            textbox.Text = "INVALID KEY"
            task.wait(1)
            textbox.Text = ""
        end
    end)

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0.8, 0, 0, 28)
    copyBtn.Position = UDim2.new(0.1, 0, 1, -10)
    copyBtn.Text = "Key link"
    copyBtn.Font = Enum.Font.Arcade
    copyBtn.TextSize = 20
    copyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    copyBtn.TextColor3 = Color3.new(1, 1, 1)
    copyBtn.BorderSizePixel = 0
    copyBtn.Parent = frame

    local stroke2 = Instance.new("UIStroke")
    stroke2.Thickness = 2
    stroke2.Parent = copyBtn
    rainbowStroke(stroke2)

    copyBtn.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/jbvEzhYkf4")
        copyBtn.Text = "Copied to clipboard"
        task.wait(2)
        copyBtn.Text = "Key link"
    end)
end

-- Verificar y cargar la GUI adecuada
if isKeyValid() then
    createMainGUI()
else
    createKeyPrompt()
end