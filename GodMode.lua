--[[
    HVXZ God Mode - Final Clean Version (No Chinese Characters)
    Features: Glowing Toggle, Elegant UI, Universal God Mode
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- Global toggle state
getgenv().GodModeActive = true 

---------------------------------------------------
-- 1. Notification System
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

    -- Slide In Animation
    TweenService:Create(label, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -280, 1, -80),
        BackgroundTransparency = 0.2,
        TextTransparency = 0
    }):Play()

    -- Auto Fade Out
    task.delay(3, function()
        local f = TweenService:Create(label, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 10, 1, -80),
            BackgroundTransparency = 1,
            TextTransparency = 1
        })
        f:Play()
        f.Completed:Connect(function() sg:Destroy() end)
    end)
end

---------------------------------------------------
-- 2. Glowing Toggle UI
---------------------------------------------------
local function createToggle()
    local old = Player.PlayerGui:FindFirstChild("HVXZ_Control")
    if old then old:Destroy() end

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
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 3
    stroke.Color = Color3.fromRGB(0, 255, 150)
    stroke.Transparency = 0.2
    stroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        getgenv().GodModeActive = not getgenv().GodModeActive
        if getgenv().GodModeActive then
            btn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
            stroke.Color = Color3.fromRGB(0, 255, 150)
            showNotification("God Mode: Enabled")
        else
            btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            stroke.Color = Color3.fromRGB(255, 50, 50)
            showNotification("God Mode: Disabled")
        end
    end)
end

---------------------------------------------------
-- 3. Core Logic
---------------------------------------------------
RunService.Heartbeat:Connect(function()
    local char = Player.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        if getgenv().GodModeActive then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            
            -- Anti-Void Protection
            if char.PrimaryPart and char.PrimaryPart.Position.Y < -400 then
                char:SetPrimaryPartCFrame(CFrame.new(char.PrimaryPart.Position.X, 200, char.PrimaryPart.Position.Z))
            end
        else
            -- Reset Dead State
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        end
    end
end)

-- Disable Reset Button
task.spawn(function()
    while true do
        pcall(function() StarterGui:SetCore("ResetButtonCallback", false) end)
        task.wait(2)
    end
end)

---------------------------------------------------
-- 4. Execution
---------------------------------------------------
createToggle()
showNotification("System: Loaded Successfully")
