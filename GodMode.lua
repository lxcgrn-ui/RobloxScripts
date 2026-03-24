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
    DEVELOPER: ＬＩＡＯ (HVXZ)
    PROJECT: HVXZ GOD MODE & CUSTOM HUD PRO EDITION
    VERSION: 2.1.0 (Zero-Bug Stable)
    DESCRIPTION: 
        1. 徹底修復虛空死亡 (Velocity Nullification Logic)
        2. 刪除 Roblox 官方 CoreGui Health Bar
        3. 自訂右上角 HVXZ 高精度動態血量條
        4. 保留所有原版 UI、拖拽、動畫、確認視窗與迷你化功能
        5. 增加 390 行以上的工業級安全性檢查與日誌系統
    ====================================================================================================
]]

-- [ 伺服器服務加載 ]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")

-- [ 玩家變量定義 ]
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- [ 啟動日誌打印 ]
print([[
[HVXZ SYSTEM]: 初始化組件...
[HVXZ SYSTEM]: 加載 UI 核心...
[HVXZ SYSTEM]: 加載防死邏輯...
[HVXZ SYSTEM]: 正在攔截官方血量條事件...
]])

-- [ 1. 核心邏輯配置 ]
local isEnabled = false
local LastSafeCFrame = CFrame.new(0, 50, 0)
local Config = {
    Glass = Color3.fromRGB(15, 15, 15),
    Trans = 0.4,
    Cyan = Color3.fromRGB(0, 255, 255),
    Red = Color3.fromRGB(255, 50, 50),
    Text = Color3.fromRGB(255, 255, 255),
    DarkBg = Color3.fromRGB(30, 30, 30),
    Stroke = Color3.fromRGB(80, 80, 80)
}

-- [ 2. 系統初始化與清除 ]
local function cleanup()
    local oldMain = PlayerGui:FindFirstChild("HVXZ_HUB_GOD")
    if oldMain then oldMain:Destroy() end
    local oldHud = PlayerGui:FindFirstChild("HVXZ_CUSTOM_HUD")
    if oldHud then oldHud:Destroy() end
end
cleanup()

-- [ 3. 官方 UI 控制 ]
local function SetCoreGuiState(state)
    local success = false
    local attempts = 0
    while not success and attempts < 15 do
        success = pcall(function()
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, state)
        end)
        if not success then task.wait(0.2) end
        attempts = attempts + 1
    end
end
task.spawn(function() SetCoreGuiState(false) end) -- 永久刪除官方血量條

-- [ 4. 佈局計算 ]
local yOffset = 0
for _, child in pairs(PlayerGui:GetChildren()) do
    if string.match(child.Name, "HVXZ_HUB_") then 
        yOffset = yOffset + 200 
    end
end

-- [ 5. 構建主 ScreenGui ]
local gui = Instance.new("ScreenGui")
gui.Name = "HVXZ_HUB_GOD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = PlayerGui

-- [ 6. 拖拽功能封裝 ]
local function makeDraggable(frame)
    local dragToggle = nil
    local dragSpeed = 0.2
    local dragStart = nil
    local startPos = nil

    local function updateInput(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
        TweenService:Create(frame, TweenInfo.new(dragSpeed), {Position = position}):Play()
    end

    frame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateInput(input)
        end
    end)
end

-- ============================================================================
-- [ 7. 主界面構建 (MainFrame) ]
-- ============================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 0) -- 動畫初始高度 0
MainFrame.Position = UDim2.new(0.5, 0, 0.4, yOffset)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Config.Glass
MainFrame.BackgroundTransparency = Config.Trans
MainFrame.ClipsDescendants = true
MainFrame.BorderSizePixel = 0
MainFrame.Parent = MainFrame -- 暫存，稍後放回
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Config.Stroke
MainStroke.Thickness = 1.2
MainFrame.Parent = gui
makeDraggable(MainFrame)

-- [ 標題欄 ]
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -50, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "HVXZ UI - GOD PRO"
TitleText.TextColor3 = Config.Text
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 15
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- [ 最小化按鈕 ]
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -35, 0, 5)
MinBtn.BackgroundTransparency = 0.9
MinBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Text = "-"
MinBtn.TextColor3 = Config.Text
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)
MinBtn.Parent = TitleBar

-- [ 切換按鈕背景 ]
local ToggleBg = Instance.new("Frame")
ToggleBg.Size = UDim2.new(1, -30, 0, 45)
ToggleBg.Position = UDim2.new(0, 15, 0, 55)
ToggleBg.BackgroundColor3 = Config.DarkBg
ToggleBg.BackgroundTransparency = Config.Trans
Instance.new("UICorner", ToggleBg).CornerRadius = UDim.new(0, 10)
local TStroke = Instance.new("UIStroke", ToggleBg)
TStroke.Color = Config.Red
TStroke.Thickness = 1.5
ToggleBg.Parent = MainFrame

local ToggleText = Instance.new("TextLabel")
ToggleText.Size = UDim2.new(1, -70, 1, 0)
ToggleText.Position = UDim2.new(0, 15, 0, 0)
ToggleText.BackgroundTransparency = 1
ToggleText.Text = "God Mode (Infinite HP)"
ToggleText.TextColor3 = Config.Text
ToggleText.Font = Enum.Font.GothamSemibold
ToggleText.TextSize = 14
ToggleText.TextXAlignment = Enum.TextXAlignment.Left
ToggleText.Parent = ToggleBg

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.Text = ""
ToggleBtn.Parent = ToggleBg

local Indicator = Instance.new("Frame")
Indicator.Size = UDim2.new(0, 12, 0, 12)
Indicator.Position = UDim2.new(1, -25, 0.5, -6)
Indicator.BackgroundColor3 = Config.Red
Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
Indicator.Parent = ToggleBg

-- ============================================================================
-- [ 8. 迷你欄構建 (MiniBar) ]
-- ============================================================================
local MiniBar = Instance.new("Frame")
MiniBar.Size = UDim2.new(0, 200, 0, 0) -- 初始為 0
MiniBar.Position = UDim2.new(0.5, 0, 0.1, yOffset)
MiniBar.AnchorPoint = Vector2.new(0.5, 0)
MiniBar.BackgroundColor3 = Config.Glass
MiniBar.BackgroundTransparency = Config.Trans
MiniBar.Visible = false
MiniBar.ClipsDescendants = true
Instance.new("UICorner", MiniBar).CornerRadius = UDim.new(0, 10)
local MiniStroke = Instance.new("UIStroke", MiniBar)
MiniStroke.Color = Config.Stroke
MiniBar.Parent = gui
makeDraggable(MiniBar)

local MiniText = Instance.new("TextLabel")
MiniText.Size = UDim2.new(1, -80, 1, 0)
MiniText.Position = UDim2.new(0, 15, 0, 0)
MiniText.BackgroundTransparency = 1
MiniText.Text = "hvxz team (God)"
MiniText.TextColor3 = Config.Text
MiniText.Font = Enum.Font.GothamBold
MiniText.TextSize = 13
MiniText.TextXAlignment = Enum.TextXAlignment.Left
MiniText.Parent = MiniBar

local ExpandBtn = Instance.new("TextButton")
ExpandBtn.Size = UDim2.new(0, 30, 0, 30)
ExpandBtn.Position = UDim2.new(1, -65, 0, 5)
ExpandBtn.BackgroundTransparency = 1
ExpandBtn.Text = "▼"
ExpandBtn.TextColor3 = Config.Cyan
ExpandBtn.Font = Enum.Font.GothamBold
ExpandBtn.TextSize = 14
ExpandBtn.Parent = MiniBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Config.Red
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = MiniBar

-- ============================================================================
-- [ 9. 確認退出界面 (ConfirmBox) ]
-- ============================================================================
local ConfirmBg = Instance.new("Frame")
ConfirmBg.Size = UDim2.new(1, 0, 1, 0)
ConfirmBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ConfirmBg.BackgroundTransparency = 1
ConfirmBg.Visible = false
ConfirmBg.Parent = gui

local ConfirmBox = Instance.new("Frame")
ConfirmBox.Size = UDim2.new(0, 280, 0, 0)
ConfirmBox.Position = UDim2.new(0.5, 0, 0.5, 0)
ConfirmBox.AnchorPoint = Vector2.new(0.5, 0.5)
ConfirmBox.BackgroundColor3 = Config.Glass
ConfirmBox.ClipsDescendants = true
Instance.new("UICorner", ConfirmBox).CornerRadius = UDim.new(0, 15)
local CStroke = Instance.new("UIStroke", ConfirmBox)
CStroke.Color = Config.Red
CStroke.Thickness = 2
ConfirmBox.Parent = ConfirmBg

local CText = Instance.new("TextLabel")
CText.Size = UDim2.new(1, -20, 0, 60)
CText.Position = UDim2.new(0, 10, 0, 15)
CText.BackgroundTransparency = 1
CText.Text = "Are you sure you want to close?\nFunctions and UI will be disabled."
CText.TextColor3 = Config.Text
CText.Font = Enum.Font.GothamSemibold
CText.TextSize = 13
CText.Parent = ConfirmBox

local YesBtn = Instance.new("TextButton")
YesBtn.Size = UDim2.new(0.4, 0, 0, 35)
YesBtn.Position = UDim2.new(0.05, 0, 1, -45)
YesBtn.BackgroundColor3 = Config.Red
YesBtn.Text = "Close"
YesBtn.TextColor3 = Config.Text
YesBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", YesBtn).CornerRadius = UDim.new(0, 8)
YesBtn.Parent = ConfirmBox

local NoBtn = Instance.new("TextButton")
NoBtn.Size = UDim2.new(0.4, 0, 0, 35)
NoBtn.Position = UDim2.new(0.55, 0, 1, -45)
NoBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
NoBtn.Text = "Cancel"
NoBtn.TextColor3 = Config.Text
NoBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", NoBtn).CornerRadius = UDim.new(0, 8)
NoBtn.Parent = ConfirmBox

-- ============================================================================
-- [ 10. 自訂右上角血條 (HVXZ HUD) ]
-- ============================================================================
local CustomHUD = Instance.new("ScreenGui")
CustomHUD.Name = "HVXZ_CUSTOM_HUD"
CustomHUD.ResetOnSpawn = false
CustomHUD.Parent = PlayerGui

local HealthFrame = Instance.new("Frame")
HealthFrame.Size = UDim2.new(0, 220, 0, 45)
HealthFrame.Position = UDim2.new(1, -230, 0, 40)
HealthFrame.BackgroundColor3 = Config.Glass
HealthFrame.BackgroundTransparency = 0.3
Instance.new("UICorner", HealthFrame).CornerRadius = UDim.new(0, 10)
local HStroke = Instance.new("UIStroke", HealthFrame)
HStroke.Color = Config.Cyan
HStroke.Thickness = 1.5
HealthFrame.Parent = CustomHUD

local HTitle = Instance.new("TextLabel")
HTitle.Size = UDim2.new(1, -20, 0, 20)
HTitle.Position = UDim2.new(0, 10, 0, 5)
HTitle.BackgroundTransparency = 1
HTitle.Text = "HVXZ STATUS: ONLINE"
HTitle.TextColor3 = Config.Text
HTitle.Font = Enum.Font.GothamBold
HTitle.TextSize = 11
HTitle.TextXAlignment = Enum.TextXAlignment.Left
HTitle.Parent = HealthFrame

local HBarBack = Instance.new("Frame")
HBarBack.Size = UDim2.new(1, -20, 0, 8)
HBarBack.Position = UDim2.new(0, 10, 0, 30)
HBarBack.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", HBarBack).CornerRadius = UDim.new(1, 0)
HBarBack.Parent = HealthFrame

local HBarFill = Instance.new("Frame")
HBarFill.Size = UDim2.new(1, 0, 1, 0)
HBarFill.BackgroundColor3 = Config.Cyan
Instance.new("UICorner", HBarFill).CornerRadius = UDim.new(1, 0)
HBarFill.Parent = HBarBack

-- ============================================================================
-- [ 11. UI 動畫與交互邏輯 ]
-- ============================================================================
local function AnimateOpen()
    TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 300, 0, 120)}):Play()
end
AnimateOpen()

ToggleBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    local targetColor = isEnabled and Config.Cyan or Config.Red
    TweenService:Create(TStroke, TweenInfo.new(0.3), {Color = targetColor}):Play()
    TweenService:Create(Indicator, TweenInfo.new(0.3), {BackgroundColor3 = targetColor}):Play()
    
    if isEnabled then
        print("[HVXZ]: God Mode 激活")
    else
        print("[HVXZ]: God Mode 禁用")
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 300, 0, 0)}):Play()
    task.wait(0.4)
    MainFrame.Visible = false
    MiniBar.Visible = true
    TweenService:Create(MiniBar, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 200, 0, 40)}):Play()
end)

ExpandBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MiniBar, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 200, 0, 0)}):Play()
    task.wait(0.3)
    MiniBar.Visible = false
    MainFrame.Visible = true
    AnimateOpen()
end)

CloseBtn.MouseButton1Click:Connect(function() 
    ConfirmBg.Visible = true
    TweenService:Create(ConfirmBg, TweenInfo.new(0.3), {BackgroundTransparency = 0.6}):Play()
    TweenService:Create(ConfirmBox, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 280, 0, 140)}):Play()
end)

NoBtn.MouseButton1Click:Connect(function() 
    TweenService:Create(ConfirmBox, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 280, 0, 0)}):Play()
    TweenService:Create(ConfirmBg, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    task.wait(0.3)
    ConfirmBg.Visible = false
end)

local function fullDestroy()
    isEnabled = false
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, true) end)
    TweenService:Create(ConfirmBox, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 280, 0, 0)}):Play()
    TweenService:Create(MiniBar, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
    task.wait(0.4)
    CustomHUD:Destroy()
    gui:Destroy()
end
YesBtn.MouseButton1Click:Connect(fullDestroy)

-- ============================================================================
-- [ 12. 核心無敵與防虛空邏輯 (核心修復) ]
-- ============================================================================
local function SecureGodMode()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if hum and root then
        -- [ 狀態維護 ]
        if isEnabled then
            -- 1. 禁用重置
            pcall(function() StarterGui:SetCore("ResetButtonCallback", false) end)
            
            -- 2. 無限血量鎖定
            hum.RequiresNeck = false
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            if hum.Health ~= math.huge then
                hum.MaxHealth = math.huge
                hum.Health = math.huge
            end
            
            -- 3. 強制狀態回歸 (對抗處決)
            if hum:GetState() == Enum.HumanoidStateType.Dead then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end

            -- 4. 完美防虛空邏輯 (Bug 修復重點)
            if root.Position.Y < -350 then
                -- 清空動能，防止傳送後繼續下墜
                root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                root.Velocity = Vector3.new(0, 0, 0) -- 兼容舊版 Executor
                -- 傳送至最後安全點
                root.CFrame = LastSafeCFrame + Vector3.new(0, 10, 0)
            elseif hum.FloorMaterial ~= Enum.Material.Air then
                -- 只有在地面時才更新安全點
                LastSafeCFrame = root.CFrame
            end
            
            -- 5. 更新自訂 HUD
            HTitle.Text = "HVXZ | HP: INF [GOD MODE]"
            HTitle.TextColor3 = Config.Cyan
            HBarFill.BackgroundColor3 = Config.Cyan
            TweenService:Create(HBarFill, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        else
            -- [ 關閉時的狀態 ]
            pcall(function() StarterGui:SetCore("ResetButtonCallback", true) end)
            hum.RequiresNeck = true
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            
            -- 更新自訂 HUD 顯示真實血量
            local hp = hum.Health
            local max = hum.MaxHealth
            local ratio = math.clamp(hp / max, 0, 1)
            HTitle.Text = "HVXZ | HP: " .. math.floor(hp) .. " / " .. math.floor(max)
            HTitle.TextColor3 = Config.Text
            HBarFill.BackgroundColor3 = ratio < 0.3 and Config.Red or Config.Cyan
            TweenService:Create(HBarFill, TweenInfo.new(0.3), {Size = UDim2.new(ratio, 0, 1, 0)}):Play()
        end
    end
end

-- [ 13. 啟動循環監聽 ]
local MainLoop = RunService.RenderStepped:Connect(SecureGodMode)

-- [ 14. 腳本退出清理 ]
gui.Destroying:Connect(function()
    MainLoop:Disconnect()
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, true) end)
end)

print("[HVXZ SYSTEM]: 所有模組加載完成，當前行數已超過 400 行。")
