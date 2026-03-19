--[[
    HVXZ God Mode - Stable Version v2.0
    功能：發光開關、優雅提示、全方位鎖血
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- 全域變量控制
getgenv().GodModeActive = true 

---------------------------------------------------
-- 1. 右下角優雅通知 (使用最穩定的 Tween 寫法)
---------------------------------------------------
local function showNotification(msg)
    local sg = Instance.new("ScreenGui")
    sg.Name = "HVXZ_Notify"
    sg.Parent = Player:WaitForChild("PlayerGui")
    sg.ResetOnSpawn = false

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 260, 0, 50)
    label.Position = UDim2.new(1, 10, 1, -80)
    label.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    label.TextColor3 = Color3.fromRGB(0, 255, 150)
    label.Text = "  " .. msg
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.TextTransparency = 1
    label.Parent = sg

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = label

    -- 滑入
    TweenService:Create(label, TweenInfo.new(0.5), {
        Position = UDim2.new(1, -280, 1, -80),
        BackgroundTransparency = 0.2,
        TextTransparency = 0
    }):Play()

    -- 消失
    task.delay(3, function()
        local f = TweenService:Create(label, TweenInfo.new(0.5), {
            Position = UDim2.new(1, 10, 1, -80),
            BackgroundTransparency = 1,
            TextTransparency = 1
        })
        f:Play()
        f.Completed:Connect(function() sg:Destroy() end)
    end)
end

---------------------------------------------------
-- 2. 左上角發光按鈕 (修正可能導致 Error 的 UIStroke)
---------------------------------------------------
local function createToggle()
    -- 刪除舊的 UI 防止重複
    if Player.PlayerGui:FindFirstChild("HVXZ_Control") then
        Player.PlayerGui.HVXZ_Control:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "HVXZ_Control"
    gui.Parent = Player:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 45, 0, 45)
    btn.Position = UDim2.new(0, 25, 0, 25)
    btn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    btn.Text = ""
    btn.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn
    
    -- 安全的發光邊框
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 3
    stroke.Color = Color3.fromRGB(0, 255, 150)
    stroke.Parent = btn

    local function updateUI()
        if getgenv().GodModeActive then
            btn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
            stroke.Color = Color3.fromRGB(0, 255, 150)
        else
            btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            stroke.Color = Color3.fromRGB(255, 50, 50)
        end
    end

    btn.MouseButton1Click:Connect(function()
        getgenv().GodModeActive = not getgenv().GodModeActive
        updateUI()
        showNotification(getgenv().GodModeActive and "上帝模式已啟動" or "上帝模式已關閉")
    end)
end

---------------------------------------------------
-- 3. 上帝模式核心 (穩定循環)
---------------------------------------------------
RunService.Heartbeat:Connect(function()
    local char = Player.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        if getgenv().GodModeActive then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            
            -- 防虛空
            if char.PrimaryPart and char.PrimaryPart.Position.Y < -400 then
                char:SetPrimaryPartCFrame(CFrame.new(char.PrimaryPart.Position.X, 200, char.PrimaryPart.Position.Z))
            end
        else
            -- 關閉時解除鎖定
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        end
    end
end)

-- 執行
createToggle()
showNotification("系統執行成功")
