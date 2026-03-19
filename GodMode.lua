local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local oldGui = PlayerGui:FindFirstChild("HVXZ_Ultra_v3")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "HVXZ_Ultra_v3"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local isGodMode = true

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
    label.BackgroundTransparency = 0.2
    label.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = label

    label:TweenPosition(UDim2.new(1, -240, 1, -65), "Out", "Quart", 0.3, true)

    task.delay(2.5, function()
        label:TweenPosition(UDim2.new(1, 10, 1, -65), "In", "Quart", 0.3, true, function()
            label:Destroy()
        end)
    end)
end

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 45, 0, 45)
btn.Position = UDim2.new(0, 25, 0, 25)
btn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
btn.Text = ""
btn.Parent = gui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = btn

local stroke = Instance.new("UIStroke")
stroke.Thickness = 3
stroke.Color = Color3.fromRGB(0, 255, 150)
stroke.Transparency = 0.1
stroke.Parent = btn

btn.MouseButton1Click:Connect(function()
    isGodMode = not isGodMode
    if isGodMode then
        btn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        stroke.Color = Color3.fromRGB(0, 255, 150)
        notify("GOD: ACTIVE", true)
    else
        btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        stroke.Color = Color3.fromRGB(255, 50, 50)
        notify("GOD: DISABLED", false)
    end
end)

-- Absolute Protection Loop
RunService.Stepped:Connect(function()
    if not gui.Parent then return end
    
    local char = Player.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        if isGodMode then
            -- Bypass death mechanics
            hum.RequiresNeck = false
            hum.MaxHealth = 9e9
            hum.Health = 9e9
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            
            -- Keep parts connected
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanTouch = true
                end
            end

            -- Anti-Void
            if char.PrimaryPart and char.PrimaryPart.Position.Y < -300 then
                char:SetPrimaryPartCFrame(CFrame.new(char.PrimaryPart.Position.X, 200, char.PrimaryPart.Position.Z))
            end
        else
            hum.RequiresNeck = true
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        end
    end
end)

task.spawn(function()
    while gui.Parent do
        pcall(function() StarterGui:SetCore("ResetButtonCallback", false) end)
        task.wait(1)
    end
end)

notify("HVXZ v3 READY", true)
