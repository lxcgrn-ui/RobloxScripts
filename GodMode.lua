--[[
    HVXZ God Mode with Toggle UI
    功能：全方位鎖血、右下角滑入提示、左上角發光開關
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local _G = getgenv and getgenv() or _G
_G.GodModeEnabled = true -- 預設啟動

--------------------------------------------------------------------------------
-- 1. 優雅通知系統 (右下角提示)
--------------------------------------------------------------------------------
local function showNotification(message)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HVXZ_Notify"
    screenGui.Parent = Player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 260, 0, 55)
    label.Position = UDim2.new(1, 10, 1, -80)
    label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    label.BorderSizePixel = 0
    label.TextColor3 = Color3.fromRGB(0, 255, 150)
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.Text = "  " .. message
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.TextTransparency = 1
    label.Parent = screenGui

    Instance.new("UICorner", label).CornerRadius = UDim.new(0, 10)

    TweenService:Create(label, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -280, 1, -80),
        BackgroundTransparency = 0.1,
        TextTransparency = 0
    }):Play()

    task.delay(3.5, function()
        local fadeOut = TweenService:Create(label, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 10, 1, -80),
            BackgroundTransparency = 1,
            TextTransparency = 1
        })
        fadeOut:Play()
        fadeOut.Completed:Connect(function() screenGui:Destroy() end)
    end)
end

--------------------------------------------------------------------------------
-- 2. 左上角發光開關 (Toggle UI)
--------------------------------------------------------------------------------
local function createToggle()
    local gui = Instance.new("ScreenGui")
    gui.Name = "HVXZ_ToggleGui"
    gui.Parent = Player:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 45, 0, 45)
    button.Position = UDim2.new(0, 20, 0, 20) -- 左上角位置
    button.BackgroundColor3 = Color3.fromRGB(0, 255, 150) -- 初始綠色
    button.Text = ""
    button.Parent = gui

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 12)
    
    -- 發光效果 (UIStroke)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 3
    stroke.Color = button.BackgroundColor3
    stroke.Transparency = 0.3
    stroke.Parent = button

    local function updateVisuals()
        if _G.GodModeEnabled then
            TweenService:Create(button, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0, 255, 150)}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(0, 255, 150)}):Play()
        else
            TweenService:Create(button, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(255, 50, 50)}):Play()
        end
    end

    button.MouseButton1Click:Connect(function()
        _G.GodModeEnabled = !_G.GodModeEnabled
        updateVisuals()
        
        if _G.GodModeEnabled then
            showNotification("上帝模式：已重新啟動")
        else
            showNotification("上帝模式：已關閉")
        end
    end)
end

--------------------------------------------------------------------------------
-- 3. 上帝模式核心 (Heartbeat Logic)
--------------------------------------------------------------------------------
local function startGodModeLoop()
    RunService.Heartbeat:Connect(function()
        local char = Player.Character
        if char and char:FindFirstChild("Humanoid") and _G.GodModeEnabled then
            local hum = char.Humanoid
            hum.MaxHealth = math.huge
            hum.Health = math.huge
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            
            -- 防虛空
            if char.PrimaryPart and char.PrimaryPart.Position.Y < -450 then
                char:SetPrimaryPartCFrame(CFrame.new(char.PrimaryPart.Position.X, 100, char.PrimaryPart.Position.Z))
            end
        elseif char and char:FindFirstChild("Humanoid") and not _G.GodModeEnabled then
            -- 關閉時恢復正常狀態
            char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            if char.Humanoid.MaxHealth == math.huge then
                char.Humanoid.MaxHealth = 100
                char.Humanoid.Health = 100
            end
        end
    end)
end

-- 禁用重置
task.spawn(function()
    while true do
        pcall(function() StarterGui:SetCore("ResetButtonCallback", false) end)
        task.wait(2)
    end
end)

--------------------------------------------------------------------------------
-- 4. 執行
--------------------------------------------------------------------------------
createToggle()
startGodModeLoop()
showNotification("執行成功：上帝模式已啟動")
