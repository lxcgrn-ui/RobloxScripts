--[=[
    Advanced Universal God Mode & Notification System
    功能：全方位鎖血、防虛空、禁用重置、優雅 UI 提示
]=]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

--------------------------------------------------------------------------------
-- 1. 優雅通知系統 (Notification System)
--------------------------------------------------------------------------------
local function showNotification(message)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NotifyGui"
    screenGui.Parent = Player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 250, 0, 50)
    label.Position = UDim2.new(1, 0, 1, -70) -- 初始位置在螢幕右下角外側
    label.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    label.BorderSizePixel = 0
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 18
    label.Font = Enum.Font.GothamMedium
    label.Text = message
    label.BackgroundTransparency = 1
    label.TextTransparency = 1
    label.Parent = screenGui

    -- 圓角效果
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = label

    -- 進入動畫
    local fadeIn = TweenService:Create(label, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -270, 1, -70),
        BackgroundTransparency = 0.2,
        TextTransparency = 0
    })

    -- 退出動畫
    local fadeOut = TweenService:Create(label, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Position = UDim2.new(1, 0, 1, -70),
        BackgroundTransparency = 1,
        TextTransparency = 1
    })

    fadeIn:Play()
    task.wait(3) -- 顯示 3 秒
    fadeOut:Play()
    fadeOut.Completed:Connect(function()
        screenGui:Destroy()
    end)
end

--------------------------------------------------------------------------------
-- 2. 上帝模式核心邏輯 (God Mode Core)
--------------------------------------------------------------------------------
local function enableGodMode(char)
    local humanoid = char:WaitForChild("Humanoid")

    -- 禁用死亡狀態：防止血量歸零時觸發死亡動畫
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    
    -- 禁用關節斷裂（例如防止頭部掉落導致死亡）
    char:WaitForChild("HumanoidRootPart")
    if char:FindFirstChild("Head") then
        char.Head.CanCollide = true -- 防止頭部掉進地板
    end

    -- 每一幀強制更新狀態
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not char or not char.Parent then
            connection:Disconnect()
            return
        end
        
        -- 鎖定生命值
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge

        -- 防虛空 (Anti-Void)：如果掉出地圖邊界，自動傳送回高度 50 的位置
        if char.PrimaryPart and char.PrimaryPart.Position.Y < -400 then
            char:SetPrimaryPartCFrame(CFrame.new(char.PrimaryPart.Position.X, 50, char.PrimaryPart.Position.Z))
        end
    end)
end

-- 禁用玩家菜單中的 "Reset Character" 按鈕
local function disableReset()
    local success
    repeat
        success = pcall(function()
            StarterGui:SetCore("ResetButtonCallback", false)
        end)
        task.wait(0.5)
    until success
end

--------------------------------------------------------------------------------
-- 3. 執行與初始化
--------------------------------------------------------------------------------

-- 初始化當前角色
enableGodMode(Character)
disableReset()
showNotification("系統執行成功：上帝模式已啟動")

-- 當角色重生時自動重新加載
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    enableGodMode(newChar)
    disableReset()
end)
