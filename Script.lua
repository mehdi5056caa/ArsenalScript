-- [[ NOFACE SCRIPT: ADVANCED ADMIN & UTILITY PANEL ]] --

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

-- Global Configuration State
local SystemConfig = {
    ToggleKey = Enum.KeyCode.P,
    PanelOpen = true,
    
    -- Visuals & ESP
    ESP_Players = false,
    ESP_Color = Color3.fromRGB(255, 30, 60),
    
    -- Combat Mechanics
    TargetAssist = false,
    AimbotFOV = 150, -- FOV Radius Size
    AutoShot = false,
    FireRate = 0.1,
    NoRecoil = false
}

-- Destroy Previous Instantiations
if PlayerGui:FindFirstChild("NoFaceScriptPanel") then
    PlayerGui["NoFaceScriptPanel"]:Destroy()
end

local ESPFolder = Workspace:FindFirstChild("NoFace_ESP_Folder") or Instance.new("Folder")
ESPFolder.Name = "NoFace_ESP_Folder"
ESPFolder.Parent = Workspace

-- Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NoFaceScriptPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Main Container Window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 620, 0, 440)
MainFrame.Position = UDim2.new(0.5, -310, 0.5, -220)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = Color3.fromRGB(255, 30, 60)
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

-- Background Particle Engine (Red Falling Particles Effect)
local ParticleContainer = Instance.new("Frame")
ParticleContainer.Name = "ParticleContainer"
ParticleContainer.Size = UDim2.new(1, 0, 1, 0)
ParticleContainer.BackgroundTransparency = 1
ParticleContainer.ClipsDescendants = true
ParticleContainer.Parent = MainFrame

local particles = {}
for i = 1, 25 do
    local dot = Instance.new("Frame")
    local size = math.random(3, 6)
    dot.Size = UDim2.new(0, size, 0, size)
    dot.Position = UDim2.new(math.random(), 0, math.random(), 0)
    dot.BackgroundColor3 = Color3.fromRGB(255, 40, 70)
    dot.BackgroundTransparency = math.random(2, 6) / 10
    dot.BorderSizePixel = 0
    dot.Parent = ParticleContainer

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot

    table.insert(particles, {
        Frame = dot,
        Speed = math.random(15, 45) / 1000,
        Drift = (math.random() - 0.5) / 2000
    })
end

-- Header Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(8, 8, 11)
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 3
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "NoFace Script"
Title.TextColor3 = Color3.fromRGB(255, 40, 70)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 4
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -36, 0, 6)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.ZIndex = 4
CloseBtn.Parent = TopBar

-- FOV Circle Visualizer
local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.Size = UDim2.new(0, SystemConfig.AimbotFOV * 2, 0, SystemConfig.AimbotFOV * 2)
FOVCircle.Position = UDim2.new(0.5, -SystemConfig.AimbotFOV, 0.5, -SystemConfig.AimbotFOV)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false
FOVCircle.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 1
FOVStroke.Color = Color3.fromRGB(255, 30, 60)
FOVStroke.Transparency = 0.4
FOVStroke.Parent = FOVCircle

-- Content Area
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, -24, 1, -54)
ContentScroll.Position = UDim2.new(0, 12, 0, 48)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 3
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 30, 60)
ContentScroll.ZIndex = 3
ContentScroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 10)
UIList.Parent = ContentScroll

-- UI Helper Functions
local function CreateToggle(titleText, subText, defaultState, callback)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, -6, 0, 52)
    Card.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    Card.BorderSizePixel = 0
    Card.ZIndex = 3
    Card.Parent = ContentScroll

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 6)
    CardCorner.Parent = Card

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Thickness = 1
    CardStroke.Color = Color3.fromRGB(35, 35, 50)
    CardStroke.Parent = Card

    local LabelTitle = Instance.new("TextLabel")
    LabelTitle.Size = UDim2.new(0.7, 0, 0, 18)
    LabelTitle.Position = UDim2.new(0, 12, 0, 8)
    LabelTitle.BackgroundTransparency = 1
    LabelTitle.Text = titleText
    LabelTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
    LabelTitle.Font = Enum.Font.GothamBold
    LabelTitle.TextSize = 12
    LabelTitle.TextXAlignment = Enum.TextXAlignment.Left
    LabelTitle.ZIndex = 4
    LabelTitle.Parent = Card

    local LabelSub = Instance.new("TextLabel")
    LabelSub.Size = UDim2.new(0.7, 0, 0, 14)
    LabelSub.Position = UDim2.new(0, 12, 0, 28)
    LabelSub.BackgroundTransparency = 1
    LabelSub.Text = subText
    LabelSub.TextColor3 = Color3.fromRGB(130, 130, 150)
    LabelSub.Font = Enum.Font.Gotham
    LabelSub.TextSize = 10
    LabelSub.TextXAlignment = Enum.TextXAlignment.Left
    LabelSub.ZIndex = 4
    LabelSub.Parent = Card

    local ToggleSwitch = Instance.new("TextButton")
    ToggleSwitch.Size = UDim2.new(0, 44, 0, 22)
    ToggleSwitch.Position = UDim2.new(1, -54, 0.5, -11)
    ToggleSwitch.BackgroundColor3 = defaultState and Color3.fromRGB(255, 30, 60) or Color3.fromRGB(35, 35, 50)
    ToggleSwitch.Text = ""
    ToggleSwitch.ZIndex = 4
    ToggleSwitch.Parent = Card

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = ToggleSwitch

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = defaultState and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 5
    Knob.Parent = ToggleSwitch

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local state = defaultState
    ToggleSwitch.MouseButton1Click:Connect(function()
        state = not state
        local targetPos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        local targetColor = state and Color3.fromRGB(255, 30, 60) or Color3.fromRGB(35, 35, 50)

        TweenService:Create(Knob, TweenInfo.new(0.12), {Position = targetPos}):Play()
        TweenService:Create(ToggleSwitch, TweenInfo.new(0.12), {BackgroundColor3 = targetColor}):Play()

        callback(state)
    end)
end

local function CreateSlider(titleText, minVal, maxVal, defaultVal, callback)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, -6, 0, 60)
    Card.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    Card.BorderSizePixel = 0
    Card.ZIndex = 3
    Card.Parent = ContentScroll

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 6)
    CardCorner.Parent = Card

    local LabelTitle = Instance.new("TextLabel")
    LabelTitle.Size = UDim2.new(0.6, 0, 0, 18)
    LabelTitle.Position = UDim2.new(0, 12, 0, 8)
    LabelTitle.BackgroundTransparency = 1
    LabelTitle.Text = titleText
    LabelTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
    LabelTitle.Font = Enum.Font.GothamBold
    LabelTitle.TextSize = 12
    LabelTitle.TextXAlignment = Enum.TextXAlignment.Left
    LabelTitle.ZIndex = 4
    LabelTitle.Parent = Card

    local ValLabel = Instance.new("TextLabel")
    ValLabel.Size = UDim2.new(0.3, 0, 0, 18)
    ValLabel.Position = UDim2.new(0.7, -12, 0, 8)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Text = tostring(defaultVal)
    ValLabel.TextColor3 = Color3.fromRGB(255, 40, 70)
    ValLabel.Font = Enum.Font.GothamBold
    ValLabel.TextSize = 12
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValLabel.ZIndex = 4
    ValLabel.Parent = Card

    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -24, 0, 6)
    SliderBar.Position = UDim2.new(0, 12, 0, 38)
    SliderBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    SliderBar.BorderSizePixel = 0
    SliderBar.ZIndex = 4
    SliderBar.Parent = Card

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = SliderBar

    local FillBar = Instance.new("Frame")
    local initPercent = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
    FillBar.Size = UDim2.new(initPercent, 0, 1, 0)
    FillBar.BackgroundColor3 = Color3.fromRGB(255, 30, 60)
    FillBar.BorderSizePixel = 0
    FillBar.ZIndex = 5
    FillBar.Parent = SliderBar

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = FillBar

    local draggingSlider = false
    local function UpdateSlider(input)
        local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        local value = math.floor(minVal + (maxVal - minVal) * pos)
        FillBar.Size = UDim2.new(pos, 0, 1, 0)
        ValLabel.Text = tostring(value)
        callback(value)
    end

    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            UpdateSlider(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)
end

-- Controls Settings
CreateToggle("Aimbot Assist (Head Lock)", "Auto locks camera on target heads within FOV radius", false, function(v)
    SystemConfig.TargetAssist = v
    FOVCircle.Visible = v
end)

CreateSlider("Aimbot FOV Radius", 50, 400, SystemConfig.AimbotFOV, function(v)
    SystemConfig.AimbotFOV = v
    FOVCircle.Size = UDim2.new(0, v * 2, 0, v * 2)
    FOVCircle.Position = UDim2.new(0.5, -v, 0.5, -v)
end)

CreateToggle("Auto Shot (Raycast Trigger)", "Automatically fires when pointing at target character model", false, function(v)
    SystemConfig.AutoShot = v
end)

CreateToggle("ESP Line Tracers (Enemies / Players)", "Draws direct 3D vector tracer lines to target models", false, function(v)
    SystemConfig.ESP_Players = v
    if not v then ESPFolder:ClearAllChildren() end
end)

CreateToggle("No Recoil System", "Smoothly counters camera recoil rotation while firing", false, function(v)
    SystemConfig.NoRecoil = v
end)

-- Window Toggle & Dragging
local function TogglePanel()
    SystemConfig.PanelOpen = not SystemConfig.PanelOpen
    MainFrame.Visible = SystemConfig.PanelOpen
end

CloseBtn.MouseButton1Click:Connect(function()
    SystemConfig.PanelOpen = false
    MainFrame.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == SystemConfig.ToggleKey then
        TogglePanel()
    end
end)

local Dragging, DragStart, StartPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then Dragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
    end
end)

-- ========================================================== --
-- CORE MECHANICS ENGINE (Aimbot, Raycast AutoShot, ESP)
-- ========================================================== --

local lastShot = 0
local lastCameraCFrame = Camera.CFrame

RunService.RenderStepped:Connect(function()
    -- Render Falling Red Particles
    for _, p in ipairs(particles) do
        local currentY = p.Frame.Position.Y.Scale
        local currentX = p.Frame.Position.X.Scale
        if currentY >= 1 then
            p.Frame.Position = UDim2.new(math.random(), 0, 0, 0)
        else
            p.Frame.Position = UDim2.new(currentX + p.Drift, 0, currentY + p.Speed, 0)
        end
    end

    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

    -- 1. ESP LINE TRACERS
    if SystemConfig.ESP_Players and myHrp then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetHrp = player.Character.HumanoidRootPart
                local lineName = "NoFaceLine_" .. player.Name
                
                local line = ESPFolder:FindFirstChild(lineName)
                if not line then
                    line = Instance.new("LineHandleAdornment")
                    line.Name = lineName
                    line.Thickness = 2
                    line.Color3 = SystemConfig.ESP_Color
                    line.AlwaysOnTop = true
                    line.Parent = ESPFolder
                end

                line.Adornee = myHrp
                line.CFrame = CFrame.new(Vector3.new(0, -1, 0), targetHrp.Position - myHrp.Position)
                line.Length = (targetHrp.Position - myHrp.Position).Magnitude
            end
        end
    else
        ESPFolder:ClearAllChildren()
    end

    -- 2. AIMBOT ASSIST
    if SystemConfig.TargetAssist then
        local closestTarget = nil
        local shortestDistance = SystemConfig.AimbotFOV

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local viewportCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - viewportCenter).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closestTarget = head
                    end
                end
            end
        end

        if closestTarget then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestTarget.Position)
        end
    end

    -- 3. AUTO SHOT (RAYCAST DETECTOR)
    if SystemConfig.AutoShot and (tick() - lastShot) >= SystemConfig.FireRate then
        local viewportCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local ray = Camera:ViewportPointToRay(viewportCenter.X, viewportCenter.Y)
        
        local params = RaycastParams.new()
        params.FilterType = RaycastFilterType.Exclude
        if myChar then params.FilterDescendantsInstances = {myChar} end

        local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
        if result and result.Instance then
            local model = result.Instance:FindFirstAncestorOfClass("Model")
            if model and Players:GetPlayerFromCharacter(model) then
                lastShot = tick()
                print("[NoFace AutoShot]: Target Hit Detected -> " .. model.Name)
            end
        end
    end

    -- 4. NO RECOIL
    if SystemConfig.NoRecoil and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position) * lastCameraCFrame.Rotation
    end
    lastCameraCFrame = Camera.CFrame
end)

print("NoFace Script Panel Loaded Successfully! Press 'P' to toggle.")
