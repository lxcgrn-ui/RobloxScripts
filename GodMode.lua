local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local oldGui = PlayerGui:FindFirstChild("HVXZ_Main")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "HVXZ_Main"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local isGodMode = true

local function notify(msg)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 200, 0, 40)
    label.Position = UDim2.new(1, 10, 1, -60)
    label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    label.TextColor3 = Color3.fromRGB(0, 255, 150)
    label.Font = Enum.Font.Code
    label.TextSize = 14
    label.Text = " " .. msg
    label.BackgroundTransparency = 1
    label.TextTransparency = 1
    label.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = label

    TweenService:Create(label, TweenInfo.new(0.4), {
        Position = UDim2.new(1, -220, 1, -60),
        BackgroundTransparency = 0.1,
        TextTransparency = 0
    }):Play()

    task.delay(2.5, function()
        local fade = TweenService:Create(label, TweenInfo.new(0.4), {
            Position = UDim2.new(1, 10, 1, -60),
            BackgroundTransparency = 1,
            TextTransparency = 1
        })
        fade:Play()
        fade.Completed:Connect(function() label:Destroy() end)
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
stroke.Transparency = 0.2
stroke.Parent = btn

btn.MouseButton1Click:Connect(function()
    isGodMode = not isGodMode
    if isGodMode then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 255, 150)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(0, 255, 150)}):Play()
        notify("Enabled")
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 50, 50)}):Play()
        notify("Disabled")
    end
end)

local hb
hb = RunService.Heartbeat:Connect(function()
    if not gui.Parent then 
        hb:Disconnect() 
        return 
    end
    
    local char = Player.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        if isGodMode then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            
            if char.PrimaryPart and char.PrimaryPart.Position.Y < -350 then
                char:SetPrimaryPartCFrame(CFrame.new(char.PrimaryPart.Position.X, 150, char.PrimaryPart.Position.Z))
            end
        else
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        end
    end
end)

task.spawn(function()
    while gui.Parent do
        pcall(function() StarterGui:SetCore("ResetButtonCallback", false) end)
        task.wait(2)
    end
end)

notify("Loaded")
