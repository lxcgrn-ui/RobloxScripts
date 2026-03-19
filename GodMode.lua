local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Remove old UIs
local function cleanup()
    local old = PlayerGui:FindFirstChild("HVXZ_v4")
    if old then old:Destroy() end
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
end
cleanup()

local gui = Instance.new("ScreenGui")
gui.Name = "HVXZ_v4"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local isGodMode = true

---------------------------------------------------
-- 1. Dynamic Notification System
---------------------------------------------------
local function notify(msg, isEnabled)
    local color = isEnabled and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 50, 50)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 220, 0, 45)
    label.Position = UDim2.new(1, 10, 1, -65)
    label.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    label.TextColor3 = color
    label.Font = Enum.Font.Code
    label.TextSize = 15
    label.Text = " " .. msg
    label.BackgroundTransparency = 0.3
    label.Parent = gui

    Instance.new("UICorner", label).CornerRadius = UDim.new(0, 8)
    
    label:TweenPosition(UDim2.new(1, -240, 1, -65), "Out", "Quart", 0.3, true)
    task.delay(2.5, function()
        label:TweenPosition(UDim2.new(1, 10, 1, -65), "In", "Quart", 0.3, true, function()
            label:Destroy()
        end)
    end)
end

---------------------------------------------------
-- 2. Custom Neon Health Bar (Top Middle)
---------------------------------------------------
local barFrame = Instance.new("Frame")
barFrame.Size = UDim2.new(0, 300, 0, 10)
barFrame.Position = UDim2.new(0.5, -150, 0, 40)
barFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
barFrame.BackgroundTransparency = 0.5
barFrame.Parent = gui

Instance.new("UICorner", barFrame).CornerRadius = UDim.new(1, 0)
local barStroke = Instance.new("UIStroke", barFrame)
barStroke.Color = Color3.fromRGB(0, 255, 150)
barStroke.Thickness = 2
barStroke.Transparency = 0.5

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(1, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
barFill.Parent = barFrame

Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

local healthText = Instance.new("TextLabel")
healthText.Size = UDim2.new(0, 100, 0, 20)
healthText.Position = UDim2.new(0.5, -50, 0, -25)
healthText.BackgroundTransparency = 1
healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
healthText.Font = Enum.Font.Code
healthText.TextSize = 14
healthText.Text = "HEALTH: 100%"
healthText.Parent = barFrame

---------------------------------------------------
-- 3. Toggle Button
---------------------------------------------------
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 45, 0, 45)
btn.Position = UDim2.new(0, 25, 0, 25)
btn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
btn.Text = ""
btn.Parent = gui

Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
local btnStroke = Instance.new("UIStroke", btn)
btnStroke.Thickness = 3
btnStroke.Color = Color3.fromRGB(0, 255, 150)

btn.MouseButton1Click:Connect(function()
    isGodMode = not isGodMode
    local themeColor = isGodMode and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 50, 50)
    
    btn.BackgroundColor3 = themeColor
    btnStroke.Color = themeColor
    barFill.BackgroundColor3 = themeColor
    barStroke.Color = themeColor
    
    notify(isGodMode and "GOD MODE: ON" or "GOD MODE: OFF", isGodMode)
end)

---------------------------------------------------
-- 4. Core Logic & HUD Sync
---------------------------------------------------
RunService.Stepped:Connect(function()
    local char = Player.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        if isGodMode then
            hum.RequiresNeck = false
            hum.MaxHealth = 9e9
            hum.Health = 9e9
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            
            -- UI Sync (Locked at 100% Visual)
            barFill.Size = UDim2.new(1, 0, 1, 0)
            healthText.Text = "HEALTH: INF"
            
            if char.PrimaryPart and char.PrimaryPart.Position.Y < -300 then
                char:SetPrimaryPartCFrame(CFrame.new(char.PrimaryPart.Position.X, 200, char.PrimaryPart.Position.Z))
            end
        else
            -- Normal Mode UI Sync
            hum.RequiresNeck = true
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            barFill.Size = UDim2.new(hpPercent, 0, 1, 0)
            healthText.Text = "HEALTH: " .. math.floor(hpPercent * 100) .. "%"
        end
    end
end)

task.spawn(function()
    while gui.Parent do
        pcall(function() StarterGui:SetCore("ResetButtonCallback", false) end)
        task.wait(1)
    end
end)

notify("HVXZ HUD LOADED", true)
