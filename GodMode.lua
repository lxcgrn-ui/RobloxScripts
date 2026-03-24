--[[ 
    ================================================================================
    HVXZ TEAM - GOD MODE & CUSTOM HUD (FINAL REPAIR)
    ================================================================================
    Developer: ＬＩＡＯ (HVXZ)
    Version: PRO V2.0 (Bug-Fixed & Custom UI)
    Logic: Anti-Void (Velocity Reset), CoreGui Disable, Custom Health Bar.
    ================================================================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- 1. 徹底刪除官方血量條 (CoreGui Health)
local function HideOfficialHealth()
    local success = false
    while not success do
        success = pcall(function()
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
        end)
        task.wait(0.2)
    end
end
task.spawn(HideOfficialHealth)

-- 2. 清理舊版 UI
local function cleanup()
    local oldHud = LocalPlayer.PlayerGui:FindFirstChild("HVXZ_HUD_V2")
    if oldHud then oldHud:Destroy() end
end
cleanup()

-- 3. 建立自訂 HVXZ 血量監控 UI (右上角)
local hud = Instance.new("ScreenGui")
hud.Name = "HVXZ_HUD_V2"
hud.ResetOnSpawn = false
hud.Parent = LocalPlayer:WaitForChild("PlayerGui")

local HUDFrame = Instance.new("Frame", hud)
HUDFrame.Size = UDim2.new(0, 200, 0, 35)
HUDFrame.Position = UDim2.new(1, -210, 0, 45) -- 右上角位置
HUDFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
HUDFrame.BackgroundTransparency = 0.4
local HUDCorner = Instance.new("UICorner", HUDFrame); HUDCorner.CornerRadius = UDim.new(0, 8)
local HUDStroke = Instance.new("UIStroke", HUDFrame); HUDStroke.Color = Color3.fromRGB(0, 255, 255); HUDStroke.Thickness = 1.5

local HealthBarBg = Instance.new("Frame", HUDFrame)
HealthBarBg.Size = UDim2.new(1, -20, 0, 8)
HealthBarBg.Position = UDim2.new(0, 10, 0.6, 0)
HealthBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", HealthBarBg).CornerRadius = UDim.new(1, 0)

local HealthBarFill = Instance.new("Frame", HealthBarBg)
HealthBarFill.Size = UDim2.new(1, 0, 1, 0)
HealthBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 255) -- 預設為青色
Instance.new("UICorner", HealthBarFill).CornerRadius = UDim.new(1, 0)

local HealthText = Instance.new("TextLabel", HUDFrame)
HealthText.Size = UDim2.new(1, -20, 0, 15)
HealthText.Position = UDim2.new(0, 10, 0.1, 0)
HealthText.BackgroundTransparency = 1
HealthText.TextColor3 = Color3.fromRGB(255, 255, 255)
HealthText.TextSize = 12
HealthText.Font = Enum.Font.GothamBold
HealthText.TextXAlignment = Enum.TextXAlignment.Left
HealthText.Text = "HVXZ STATUS: ONLINE"

-- 4. 核心邏輯變量
local GodModeEnabled = true
local LastSafeCFrame = CFrame.new(0, 50, 0)

-- 5. 強化版核心循環
local coreLoop = RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
        local hum = char.Humanoid
        local root = char.HumanoidRootPart

        -- [A] 防死與血量鎖定
        if GodModeEnabled then
            hum.RequiresNeck = false
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            if hum.Health ~= math.huge then
                hum.MaxHealth = math.huge
                hum.Health = math.huge
            end
            
            -- [B] 真正的防虛空 (Anti-Void)
            -- 如果 Y 軸低於 -300，引擎準備刪除你之前，我們強行介入
            if root.Position.Y < -300 then
                -- 核心修復：必須清空所有運動量，否則傳送後會再次慣性掉入虛空
                root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                root.CFrame = LastSafeCFrame + Vector3.new(0, 5, 0)
            elseif hum.FloorMaterial ~= Enum.Material.Air then
                -- 只有踩在地上時才更新安全點，確保不會傳送到半空中
                LastSafeCFrame = root.CFrame
            end
        end

        -- [C] 自訂血量條更新邏輯
        -- 既然是 God Mode，我們要呈現「超越極限」的視覺感
        if hum.Health == math.huge or hum.Health > 999999 then
            HealthText.Text = "HVXZ | HP: INF [GOD]"
            HealthBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 255) -- 青色代表神化
            TweenService:Create(HealthBarFill, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        else
            -- 如果關閉 God Mode，顯示正常比例
            local percent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            HealthText.Text = "HVXZ | HP: " .. math.floor(hum.Health)
            HealthBarFill.BackgroundColor3 = percent < 0.3 and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 255, 255)
            TweenService:Create(HealthBarFill, TweenInfo.new(0.3), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
        end
    end
end)

-- 清理監聽
hud.Destroying:Connect(function()
    coreLoop:Disconnect()
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, true) end)
end)
