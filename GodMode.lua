--[[ 
    ====================================================================================================
    ||                                                                                                ||
    ||   ██╗  ██╗ ██╗   ██╗ ██╗  ██╗ ███████╗   ████████╗ ███████╗  █████╗  ███╗   ███╗               ||
    ||   ██║  ██║ ██║   ██║ ╚██╗██╔╝ ╚══███╔╝   ╚══██╔══╝ ██╔════╝ ██╔══██╗ ████╗ ████║               ||
    ||   ███████║ ██║   ██║  ╚███╔╝    ███╔╝       ██║    █████╗   ███████║ ██╔████╔██║               ||
    ||   ██╔══██║ ╚██╗ ██╔╝  ██╔██╗   ███╔╝        ██║    ██╔══╝   ██╔══██║ ██║╚██╔╝██║               ||
    ||   ██║  ██║  ╚████╔╝  ██╔╝ ██╗ ███████╗      ██║    ███████╗ ██║  ██║ ██║ ╚═╝ ██║               ||
    ||   ╚═╝  ╚═╝   ╚═══╝   ╚═╝  ╚═╝ ╚══════╝      ╚═╝    ╚══════╝ ╚═╝  ╚═╝ ╚═╝     ╚═╝               ||
    ||                                                                                                ||
    ====================================================================================================
    DEVELOPER: LIAO (HVXZ TEAM)
    PROJECT: HVXZ GOD MODE & CUSTOM HUD PRO EDITION
    VERSION: 2.2.0 (Stable / Zero-Bug / English Edition)
    
    [LOGIC SUMMARY]:
    1. REPAIRED: Anti-Void logic with instant velocity neutralization to prevent momentum death.
    2. REPAIRED: State-Lock mechanism to override 'Dead' state immediately within 1/60 second.
    3. UI: Removed Roblox Default Health Bar and replaced it with HVXZ High-Precision HUD.
    4. INTERFACE: Fully English GUI with draggable frames, animations, and confirmation prompts.
    5. STABILITY: Multi-threaded checks for Character respawning and CoreGui availability.
    ====================================================================================================
]]

-- [ SERVICE INITIALIZATION ]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Debris = game:GetService("Debris")

-- [ LOCAL PLAYER DEFINITIONS ]
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- [ CONFIGURATION & COLORS ]
local isEnabled = false
local LastSafeCFrame = CFrame.new(0, 50, 0)
local UI_Config = {
    Glass = Color3.fromRGB(15, 15, 15),
    Transparency = 0.4,
    Cyan = Color3.fromRGB(0, 255, 255),
    Red = Color3.fromRGB(255, 50, 50),
    White = Color3.fromRGB(255, 255, 255),
    Background = Color3.fromRGB(30, 30, 30),
    Border = Color3.fromRGB(80, 80, 80)
}

-- [ CLEANUP PREVIOUS INSTANCES ]
local function DestroyPreviousUI()
    local existingMain = PlayerGui:FindFirstChild("HVXZ_HUB_GOD")
    if existingMain then existingMain:Destroy() end
    local existingHud = PlayerGui:FindFirstChild("HVXZ_CUSTOM_HUD")
    if existingHud then existingHud:Destroy() end
end
DestroyPreviousUI()

-- [ CORE GUI MODIFICATION ]
-- Function to permanently disable the Roblox default health bar
local function DisableDefaultHealthBar()
    local success = false
    local retryCount = 0
    while not success and retryCount < 20 do
        success = pcall(function()
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
        end)
        if not success then task.wait(0.2) end
        retryCount = retryCount + 1
    end
end
task.spawn(DisableDefaultHealthBar)

-- [ UI OFFSET CALCULATION ]
local yOffsetAdjustment = 0
for _, child in pairs(PlayerGui:GetChildren()) do
    if string.match(child.Name, "HVXZ_HUB_") then 
        yOffsetAdjustment = yOffsetAdjustment + 220 
    end
end

-- [ MASTER SCREEN GUI ]
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "HVXZ_HUB_GOD"
MainGui.ResetOnSpawn = false
MainGui.IgnoreGuiInset = true
MainGui.DisplayOrder = 1000
MainGui.Parent = PlayerGui

-- [ DRAGGABLE FUNCTIONALITY ]
local function EnableDragging(targetFrame)
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        local newPosition = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
        TweenService:Create(targetFrame, TweenInfo.new(0.15), {Position = newPosition}):Play()
    end

    targetFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    targetFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- ============================================================================
-- [ GUI CONSTRUCTION: MAIN PANEL ]
-- ============================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 0) -- Animation start size
MainFrame.Position = UDim2.new(0.5, 0, 0.4, yOffsetAdjustment)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = UI_Config.Glass
MainFrame.BackgroundTransparency = UI_Config.Transparency
MainFrame.ClipsDescendants = true
MainFrame.BorderSizePixel = 0
MainFrame.Parent = MainGui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 15)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = UI_Config.Border
MainStroke.Thickness = 1.2
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

EnableDragging(MainFrame)

-- [ TITLE BAR SECTION ]
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "HVXZ UI - GOD PRO"
TitleLabel.TextColor3 = UI_Config.White
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- [ MINIMIZE BUTTON ]
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -35, 0, 5)
MinimizeBtn.BackgroundTransparency = 0.9
MinimizeBtn.BackgroundColor3 = UI_Config.White
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = UI_Config.White
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 8)
MinimizeBtn.Parent = TitleBar

-- [ FUNCTION TOGGLE AREA ]
local ToggleContainer = Instance.new("Frame")
ToggleContainer.Size = UDim2.new(1, -30, 0, 45)
ToggleContainer.Position = UDim2.new(0, 15, 0, 55)
ToggleContainer.BackgroundColor3 = UI_Config.Background
ToggleContainer.BackgroundTransparency = UI_Config.Transparency
Instance.new("UICorner", ToggleContainer).CornerRadius = UDim.new(0, 10)
local ToggleStroke = Instance.new("UIStroke", ToggleContainer)
ToggleStroke.Color = UI_Config.Red
ToggleStroke.Thickness = 1.5
ToggleContainer.Parent = MainFrame

local ToggleLabel = Instance.new("TextLabel")
ToggleLabel.Size = UDim2.new(1, -70, 1, 0)
ToggleLabel.Position = UDim2.new(0, 15, 0, 0)
ToggleLabel.BackgroundTransparency = 1
ToggleLabel.Text = "God Mode (Infinite HP)"
ToggleLabel.TextColor3 = UI_Config.White
ToggleLabel.Font = Enum.Font.GothamSemibold
ToggleLabel.TextSize = 14
ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
ToggleLabel.Parent = ToggleContainer

local ActionBtn = Instance.new("TextButton")
ActionBtn.Size = UDim2.new(1, 0, 1, 0)
ActionBtn.BackgroundTransparency = 1
ActionBtn.Text = ""
ActionBtn.Parent = ToggleContainer

local StatusIndicator = Instance.new("Frame")
StatusIndicator.Size = UDim2.new(0, 12, 0, 12)
StatusIndicator.Position = UDim2.new(1, -25, 0.5, -6)
StatusIndicator.BackgroundColor3 = UI_Config.Red
Instance.new("UICorner", StatusIndicator).CornerRadius = UDim.new(1, 0)
StatusIndicator.Parent = ToggleContainer

-- ============================================================================
-- [ GUI CONSTRUCTION: MINIMIZED BAR ]
-- ============================================================================
local MinimizedBar = Instance.new("Frame")
MinimizedBar.Name = "MinimizedBar"
MinimizedBar.Size = UDim2.new(0, 200, 0, 40)
MinimizedBar.Position = UDim2.new(0.5, 0, 0.1, yOffsetAdjustment)
MinimizedBar.AnchorPoint = Vector2.new(0.5, 0)
MinimizedBar.BackgroundColor3 = UI_Config.Glass
MinimizedBar.BackgroundTransparency = UI_Config.Transparency
MinimizedBar.Visible = false
MinimizedBar.ClipsDescendants = true
Instance.new("UICorner", MinimizedBar).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", MinimizedBar).Color = UI_Config.Border
MinimizedBar.Parent = MainGui
EnableDragging(MinimizedBar)

local MiniTitle = Instance.new("TextLabel")
MiniTitle.Size = UDim2.new(1, -80, 1, 0)
MiniTitle.Position = UDim2.new(0, 15, 0, 0)
MiniTitle.BackgroundTransparency = 1
MiniTitle.Text = "HVXZ PRO (GOD)"
MiniTitle.TextColor3 = UI_Config.White
MiniTitle.Font = Enum.Font.GothamBold
MiniTitle.TextSize = 13
MiniTitle.TextXAlignment = Enum.TextXAlignment.Left
MiniTitle.Parent = MinimizedBar

local MaximizeBtn = Instance.new("TextButton")
MaximizeBtn.Size = UDim2.new(0, 30, 0, 30)
MaximizeBtn.Position = UDim2.new(1, -65, 0, 5)
MaximizeBtn.BackgroundTransparency = 1
MaximizeBtn.Text = "▼"
MaximizeBtn.TextColor3 = UI_Config.Cyan
MaximizeBtn.Font = Enum.Font.GothamBold
MaximizeBtn.TextSize = 14
MaximizeBtn.Parent = MinimizedBar

local TerminateBtn = Instance.new("TextButton")
TerminateBtn.Size = UDim2.new(0, 30, 0, 30)
TerminateBtn.Position = UDim2.new(1, -35, 0, 5)
TerminateBtn.BackgroundTransparency = 1
TerminateBtn.Text = "X"
TerminateBtn.TextColor3 = UI_Config.Red
TerminateBtn.Font = Enum.Font.GothamBold
TerminateBtn.TextSize = 16
TerminateBtn.Parent = MinimizedBar

-- ============================================================================
-- [ GUI CONSTRUCTION: CONFIRMATION SYSTEM ]
-- ============================================================================
local Overlay = Instance.new("Frame")
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Overlay.BackgroundTransparency = 1
Overlay.Visible = false
Overlay.Parent = MainGui

local ConfirmPanel = Instance.new("Frame")
ConfirmPanel.Size = UDim2.new(0, 280, 0, 0)
ConfirmPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
ConfirmPanel.AnchorPoint = Vector2.new(0.5, 0.5)
ConfirmPanel.BackgroundColor3 = UI_Config.Glass
ConfirmPanel.ClipsDescendants = true
Instance.new("UICorner", ConfirmPanel).CornerRadius = UDim.new(0, 15)
Instance.new("UIStroke", ConfirmPanel).Color = UI_Config.Red
ConfirmPanel.Parent = Overlay

local PromptText = Instance.new("TextLabel")
PromptText.Size = UDim2.new(1, -20, 0, 60)
PromptText.Position = UDim2.new(0, 10, 0, 15)
PromptText.BackgroundTransparency = 1
PromptText.Text = "Exit HVXZ System?\nAll god-mode features will be lost."
PromptText.TextColor3 = UI_Config.White
PromptText.Font = Enum.Font.GothamSemibold
PromptText.TextSize = 13
PromptText.Parent = ConfirmPanel

local ConfirmExit = Instance.new("TextButton")
ConfirmExit.Size = UDim2.new(0.4, 0, 0, 35)
ConfirmExit.Position = UDim2.new(0.05, 0, 1, -45)
ConfirmExit.BackgroundColor3 = UI_Config.Red
ConfirmExit.Text = "Terminate"
ConfirmExit.TextColor3 = UI_Config.White
ConfirmExit.Font = Enum.Font.GothamBold
Instance.new("UICorner", ConfirmExit).CornerRadius = UDim.new(0, 8)
ConfirmExit.Parent = ConfirmPanel

local CancelExit = Instance.new("TextButton")
CancelExit.Size = UDim2.new(0.4, 0, 0, 35)
CancelExit.Position = UDim2.new(0.55, 0, 1, -45)
CancelExit.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
CancelExit.Text = "Cancel"
CancelExit.TextColor3 = UI_Config.White
CancelExit.Font = Enum.Font.GothamBold
Instance.new("UICorner", CancelExit).CornerRadius = UDim.new(0, 8)
CancelExit.Parent = ConfirmPanel

-- ============================================================================
-- [ GUI CONSTRUCTION: CUSTOM HUD (TOP-RIGHT) ]
-- ============================================================================
local CustomHUD = Instance.new("ScreenGui")
CustomHUD.Name = "HVXZ_CUSTOM_HUD"
CustomHUD.ResetOnSpawn = false
CustomHUD.Parent = PlayerGui

local HealthContainer = Instance.new("Frame")
HealthContainer.Size = UDim2.new(0, 220, 0, 45)
HealthContainer.Position = UDim2.new(1, -230, 0, 40)
HealthContainer.BackgroundColor3 = UI_Config.Glass
HealthContainer.BackgroundTransparency = 0.3
Instance.new("UICorner", HealthContainer).CornerRadius = UDim.new(0, 10)
local HealthStroke = Instance.new("UIStroke", HealthContainer)
HealthStroke.Color = UI_Config.Cyan
HealthStroke.Thickness = 1.5
HealthContainer.Parent = CustomHUD

local HUDTitle = Instance.new("TextLabel")
HUDTitle.Size = UDim2.new(1, -20, 0, 20)
HUDTitle.Position = UDim2.new(0, 10, 0, 5)
HUDTitle.BackgroundTransparency = 1
HUDTitle.Text = "HVXZ STATUS: MONITORING"
HUDTitle.TextColor3 = UI_Config.White
HUDTitle.Font = Enum.Font.GothamBold
HUDTitle.TextSize = 11
HUDTitle.TextXAlignment = Enum.TextXAlignment.Left
HUDTitle.Parent = HealthContainer

local ProgressBarBg = Instance.new("Frame")
ProgressBarBg.Size = UDim2.new(1, -20, 0, 8)
ProgressBarBg.Position = UDim2.new(0, 10, 0, 30)
ProgressBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", ProgressBarBg).CornerRadius = UDim.new(1, 0)
ProgressBarBg.Parent = HealthContainer

local ProgressBarFill = Instance.new("Frame")
ProgressBarFill.Size = UDim2.new(1, 0, 1, 0)
ProgressBarFill.BackgroundColor3 = UI_Config.Cyan
Instance.new("UICorner", ProgressBarFill).CornerRadius = UDim.new(1, 0)
ProgressBarFill.Parent = ProgressBarBg

-- ============================================================================
-- [ UI INTERACTION LOGIC & ANIMATIONS ]
-- ============================================================================
local function PlayIntroAnimation()
    TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 300, 0, 120)}):Play()
end
PlayIntroAnimation()

ActionBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    local color = isEnabled and UI_Config.Cyan or UI_Config.Red
    TweenService:Create(ToggleStroke, TweenInfo.new(0.3), {Color = color}):Play()
    TweenService:Create(StatusIndicator, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play()
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 300, 0, 0)}):Play()
    task.wait(0.4)
    MainFrame.Visible = false
    MinimizedBar.Visible = true
    TweenService:Create(MinimizedBar, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 200, 0, 40)}):Play()
end)

MaximizeBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MinimizedBar, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 200, 0, 0)}):Play()
    task.wait(0.3)
    MinimizedBar.Visible = false
    MainFrame.Visible = true
    PlayIntroAnimation()
end)

TerminateBtn.MouseButton1Click:Connect(function() 
    Overlay.Visible = true
    TweenService:Create(Overlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.6}):Play()
    TweenService:Create(ConfirmPanel, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 280, 0, 140)}):Play()
end)

CancelExit.MouseButton1Click:Connect(function() 
    TweenService:Create(ConfirmPanel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 280, 0, 0)}):Play()
    TweenService:Create(Overlay, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    task.wait(0.3)
    Overlay.Visible = false
end)

local function TerminateScript()
    isEnabled = false
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, true) end)
    TweenService:Create(ConfirmPanel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 280, 0, 0)}):Play()
    TweenService:Create(MinimizedBar, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
    task.wait(0.4)
    CustomHUD:Destroy()
    MainGui:Destroy()
end
ConfirmExit.MouseButton1Click:Connect(TerminateScript)

-- ============================================================================
-- [ CORE PROTECTION & ANTI-VOID ENGINE ]
-- ============================================================================
local function ExecuteGodLogic()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if humanoid and rootPart then
        if isEnabled then
            -- [ 1. BYPASS RESET CHARACTER ]
            pcall(function() StarterGui:SetCore("ResetButtonCallback", false) end)
            
            -- [ 2. INFINITE HEALTH LOCK ]
            humanoid.RequiresNeck = false
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            if humanoid.Health ~= math.huge then
                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge
            end
            
            -- [ 3. ANTI-EXECUTION STATE FIX ]
            if humanoid:GetState() == Enum.HumanoidStateType.Dead then
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end

            -- [ 4. ADVANCED ANTI-VOID SYSTEM ]
            if rootPart.Position.Y < -350 then
                -- CRITICAL BUG FIX: Neutralize all forces before teleportation
                rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                rootPart.Velocity = Vector3.new(0, 0, 0) 
                -- Relocate to the last recorded safe position
                rootPart.CFrame = LastSafeCFrame + Vector3.new(0, 10, 0)
            elseif humanoid.FloorMaterial ~= Enum.Material.Air then
                -- Track safe CFrame only when the player is on solid ground
                LastSafeCFrame = rootPart.CFrame
            end
            
            -- [ 5. CUSTOM HUD UPDATE: GOD MODE ]
            HUDTitle.Text = "HVXZ | STATUS: GOD [INF HP]"
            HUDTitle.TextColor3 = UI_Config.Cyan
            ProgressBarFill.BackgroundColor3 = UI_Config.Cyan
            TweenService:Create(ProgressBarFill, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        else
            -- [ NORMAL STATE RESTORATION ]
            pcall(function() StarterGui:SetCore("ResetButtonCallback", true) end)
            humanoid.RequiresNeck = true
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            
            -- Display real health metrics on Custom HUD
            local currentHP = humanoid.Health
            local maximumHP = humanoid.MaxHealth
            local healthRatio = math.clamp(currentHP / maximumHP, 0, 1)
            HUDTitle.Text = "HVXZ | HP: " .. math.floor(currentHP) .. " / " .. math.floor(maximumHP)
            HUDTitle.TextColor3 = UI_Config.White
            ProgressBarFill.BackgroundColor3 = healthRatio < 0.3 and UI_Config.Red or UI_Config.Cyan
            TweenService:Create(ProgressBarFill, TweenInfo.new(0.3), {Size = UDim2.new(healthRatio, 0, 1, 0)}):Play()
        end
    end
end

-- [ MASTER THREAD START ]
local GodThread = RunService.RenderStepped:Connect(ExecuteGodLogic)

-- [ POST-EXECUTION CLEANUP ]
MainGui.Destroying:Connect(function()
    GodThread:Disconnect()
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, true) end)
end)
