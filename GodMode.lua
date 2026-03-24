--[[ HVXZ TEAM - GOD MODE (PRO EDITION) ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local function cleanup()
    local oldGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("HVXZ_HUB_GOD")
    if oldGui then oldGui:Destroy() end
end
cleanup()

local yOffset = 0
for _, child in pairs(LocalPlayer.PlayerGui:GetChildren()) do
    if string.match(child.Name, "HVXZ_HUB_") then yOffset = yOffset + 200 end
end

local gui = Instance.new("ScreenGui")
gui.Name = "HVXZ_HUB_GOD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Config = { Glass = Color3.fromRGB(15,15,15), Trans = 0.4, Cyan = Color3.fromRGB(0,255,255), Red = Color3.fromRGB(255,50,50), Text = Color3.fromRGB(255,255,255) }
local isEnabled = false

local function makeDraggable(frame)
    local dragToggle, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragToggle then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragToggle = false end
    end)
end

local MainFrame = Instance.new("Frame", gui)
MainFrame.Size = UDim2.new(0, 300, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.4, yOffset)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Config.Glass
MainFrame.BackgroundTransparency = Config.Trans
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)
local MainStroke = Instance.new("UIStroke", MainFrame); MainStroke.Color = Color3.fromRGB(80,80,80)
makeDraggable(MainFrame)

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 40); TitleBar.BackgroundTransparency = 1
local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size = UDim2.new(1, -50, 1, 0); TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1; TitleText.Text = "HVXZ UI - GOD"
TitleText.TextColor3 = Config.Text; TitleText.Font = Enum.Font.GothamBold; TitleText.TextSize = 15; TitleText.TextXAlignment = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(1, -35, 0, 5)
MinBtn.BackgroundTransparency = 0.9; MinBtn.Text = "-"; MinBtn.TextColor3 = Config.Text; MinBtn.Font = Enum.Font.GothamBold; MinBtn.TextSize = 18
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)

local ToggleBg = Instance.new("Frame", MainFrame)
ToggleBg.Size = UDim2.new(1, -30, 0, 45); ToggleBg.Position = UDim2.new(0, 15, 0, 55)
ToggleBg.BackgroundColor3 = Color3.fromRGB(30,30,30); ToggleBg.BackgroundTransparency = Config.Trans
Instance.new("UICorner", ToggleBg).CornerRadius = UDim.new(0, 10)
local TStroke = Instance.new("UIStroke", ToggleBg); TStroke.Color = Config.Red; TStroke.Thickness = 1.5

local ToggleText = Instance.new("TextLabel", ToggleBg)
ToggleText.Size = UDim2.new(1, -70, 1, 0); ToggleText.Position = UDim2.new(0, 15, 0, 0)
ToggleText.BackgroundTransparency = 1; ToggleText.Text = "God Mode (Infinite HP)"; ToggleText.TextColor3 = Config.Text; ToggleText.Font = Enum.Font.GothamSemibold; ToggleText.TextSize = 14; ToggleText.TextXAlignment = Enum.TextXAlignment.Left

local ToggleBtn = Instance.new("TextButton", ToggleBg)
ToggleBtn.Size = UDim2.new(1, 0, 1, 0); ToggleBtn.BackgroundTransparency = 1; ToggleBtn.Text = ""
local Indicator = Instance.new("Frame", ToggleBg)
Indicator.Size = UDim2.new(0, 12, 0, 12); Indicator.Position = UDim2.new(1, -25, 0.5, -6)
Indicator.BackgroundColor3 = Config.Red; Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

ToggleBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    local c = isEnabled and Config.Cyan or Config.Red
    TweenService:Create(TStroke, TweenInfo.new(0.3), {Color = c}):Play()
    TweenService:Create(Indicator, TweenInfo.new(0.3), {BackgroundColor3 = c}):Play()
end)

local MiniBar = Instance.new("Frame", gui)
MiniBar.Size = UDim2.new(0, 200, 0, 40); MiniBar.Position = UDim2.new(0.5, 0, 0.1, yOffset)
MiniBar.AnchorPoint = Vector2.new(0.5, 0); MiniBar.BackgroundColor3 = Config.Glass; MiniBar.BackgroundTransparency = Config.Trans; MiniBar.Visible = false; MiniBar.ClipsDescendants = true
Instance.new("UICorner", MiniBar).CornerRadius = UDim.new(0, 10)
local MiniStroke = Instance.new("UIStroke", MiniBar); MiniStroke.Color = Color3.fromRGB(80,80,80)
makeDraggable(MiniBar)

local MiniText = Instance.new("TextLabel", MiniBar)
MiniText.Size = UDim2.new(1, -80, 1, 0); MiniText.Position = UDim2.new(0, 15, 0, 0)
MiniText.BackgroundTransparency = 1; MiniText.Text = "hvxz team (God)"; MiniText.TextColor3 = Config.Text; MiniText.Font = Enum.Font.GothamBold; MiniText.TextSize = 13; MiniText.TextXAlignment = Enum.TextXAlignment.Left

local ExpandBtn = Instance.new("TextButton", MiniBar)
ExpandBtn.Size = UDim2.new(0, 30, 0, 30); ExpandBtn.Position = UDim2.new(1, -65, 0, 5)
ExpandBtn.BackgroundTransparency = 1; ExpandBtn.Text = "▼"; ExpandBtn.TextColor3 = Config.Cyan; ExpandBtn.Font = Enum.Font.GothamBold; ExpandBtn.TextSize = 14

local CloseBtn = Instance.new("TextButton", MiniBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1; CloseBtn.Text = "X"; CloseBtn.TextColor3 = Config.Red; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 16

local ConfirmBg = Instance.new("Frame", gui)
ConfirmBg.Size = UDim2.new(1, 0, 1, 0); ConfirmBg.BackgroundColor3 = Color3.fromRGB(0,0,0); ConfirmBg.BackgroundTransparency = 1; ConfirmBg.Visible = false
local ConfirmBox = Instance.new("Frame", ConfirmBg)
ConfirmBox.Size = UDim2.new(0, 280, 0, 0); ConfirmBox.Position = UDim2.new(0.5, 0, 0.5, 0); ConfirmBox.AnchorPoint = Vector2.new(0.5, 0.5)
ConfirmBox.BackgroundColor3 = Config.Glass; ConfirmBox.ClipsDescendants = true
Instance.new("UICorner", ConfirmBox).CornerRadius = UDim.new(0, 15); Instance.new("UIStroke", ConfirmBox).Color = Config.Red
local CText = Instance.new("TextLabel", ConfirmBox)
CText.Size = UDim2.new(1, -20, 0, 60); CText.Position = UDim2.new(0, 10, 0, 15); CText.BackgroundTransparency = 1
CText.Text = "Are you sure you want to close?\nFunctions and UI will be disabled."; CText.TextColor3 = Config.Text; CText.Font = Enum.Font.GothamSemibold; CText.TextSize = 13
local YesBtn = Instance.new("TextButton", ConfirmBox)
YesBtn.Size = UDim2.new(0.4, 0, 0, 35); YesBtn.Position = UDim2.new(0.05, 0, 1, -45); YesBtn.BackgroundColor3 = Config.Red; YesBtn.Text = "Close"; YesBtn.TextColor3 = Config.Text; YesBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", YesBtn).CornerRadius = UDim.new(0, 8)
local NoBtn = Instance.new("TextButton", ConfirmBox)
NoBtn.Size = UDim2.new(0.4, 0, 0, 35); NoBtn.Position = UDim2.new(0.55, 0, 1, -45); NoBtn.BackgroundColor3 = Color3.fromRGB(50,50,50); NoBtn.Text = "Cancel"; NoBtn.TextColor3 = Config.Text; NoBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", NoBtn).CornerRadius = UDim.new(0, 8)

-- Animation Logic
TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 300, 0, 120)}):Play()
MinBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 300, 0, 0)}):Play()
    task.wait(0.4); MainFrame.Visible = false; MiniBar.Visible = true
    TweenService:Create(MiniBar, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 200, 0, 40)}):Play()
end)
ExpandBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MiniBar, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 200, 0, 0)}):Play()
    task.wait(0.3); MiniBar.Visible = false; MainFrame.Visible = true
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 300, 0, 120)}):Play()
end)
CloseBtn.MouseButton1Click:Connect(function() 
    ConfirmBg.Visible = true
    TweenService:Create(ConfirmBg, TweenInfo.new(0.3), {BackgroundTransparency = 0.6}):Play()
    TweenService:Create(ConfirmBox, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 280, 0, 140)}):Play()
end)
NoBtn.MouseButton1Click:Connect(function() 
    TweenService:Create(ConfirmBox, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 280, 0, 0)}):Play()
    TweenService:Create(ConfirmBg, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    task.wait(0.3); ConfirmBg.Visible = false
end)

local function fullDestroy()
    TweenService:Create(ConfirmBox, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 280, 0, 0)}):Play()
    TweenService:Create(MiniBar, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
    TweenService:Create(MiniStroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
    task.wait(0.4)
    gui:Destroy()
end
YesBtn.MouseButton1Click:Connect(fullDestroy)

-- Core Logic
local coreLoop = RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        if isEnabled then
            hum.RequiresNeck = false
            hum.MaxHealth = 9e9; hum.Health = 9e9
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            if char.PrimaryPart and char.PrimaryPart.Position.Y < -300 then
                char:SetPrimaryPartCFrame(CFrame.new(char.PrimaryPart.Position.X, 200, char.PrimaryPart.Position.Z))
            end
        else
            hum.RequiresNeck = true
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        end
    end
end)
gui.Destroying:Connect(function() coreLoop:Disconnect() end)
