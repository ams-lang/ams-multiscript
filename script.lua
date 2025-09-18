-- SMS Multi-Script for Roblox
-- Compatible with all executors and "steal a brairot"
-- Created by SMS Team

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Variables globales
local basePosition = nil
local baseMarked = false
local espEnabled = false
local noCollisionEnabled = false
local espObjects = {}
local connections = {}
local gui = nil

-- Protection anti-détection
local function protectScript()
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
        end
        if gethui then
            gui.Parent = gethui()
        end
    end)
end

-- Fonction ESP optimisée
local function createESP(targetPlayer)
    if targetPlayer == player or not targetPlayer.Character then return end
    
    local character = targetPlayer.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local billboardGui = Instance.new("BillboardGui")
    local frame = Instance.new("Frame")
    local nameLabel = Instance.new("TextLabel")
    local distanceLabel = Instance.new("TextLabel")
    local healthLabel = Instance.new("TextLabel")
    
    billboardGui.Name = "SMS_ESP_" .. targetPlayer.Name
    billboardGui.Adornee = humanoidRootPart
    billboardGui.Size = UDim2.new(0, 200, 0, 120)
    billboardGui.StudsOffset = Vector3.new(0, 4, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = humanoidRootPart
    
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 0.3
    frame.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 255, 150)
    frame.Parent = billboardGui
    
    nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "👤 " .. targetPlayer.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.Parent = frame
    
    distanceLabel.Size = UDim2.new(1, 0, 0.3, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.4, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "📏 0m"
    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    distanceLabel.TextScaled = true
    distanceLabel.Font = Enum.Font.SourceSans
    distanceLabel.Parent = frame
    
    healthLabel.Size = UDim2.new(1, 0, 0.3, 0)
    healthLabel.Position = UDim2.new(0, 0, 0.7, 0)
    healthLabel.BackgroundTransparency = 1
    healthLabel.Text = "❤️ 100%"
    healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    healthLabel.TextScaled = true
    healthLabel.Font = Enum.Font.SourceSans
    healthLabel.Parent = frame
    
    local connection = RunService.Heartbeat:Connect(function()
        if humanoidRootPart and humanoidRootPart.Parent and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
            distanceLabel.Text = "📏 " .. math.floor(distance) .. "m"
            
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                healthLabel.Text = "❤️ " .. healthPercent .. "%"
                healthLabel.TextColor3 = healthPercent > 50 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            end
        else
            connection:Disconnect()
        end
    end)
    
    espObjects[targetPlayer] = {billboardGui, connection}
end

local function removeESP(targetPlayer)
    if espObjects[targetPlayer] then
        pcall(function()
            espObjects[targetPlayer][1]:Destroy()
            espObjects[targetPlayer][2]:Disconnect()
        end)
        espObjects[targetPlayer] = nil
    end
end

local function toggleESP()
    espEnabled = not espEnabled
    
    if espEnabled then
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer.Character then
                createESP(targetPlayer)
            end
        end
        
        connections.playerAdded = Players.PlayerAdded:Connect(function(targetPlayer)
            targetPlayer.CharacterAdded:Connect(function()
                wait(1)
                if espEnabled then
                    createESP(targetPlayer)
                end
            end)
        end)
        
        connections.characterAdded = {}
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            connections.characterAdded[targetPlayer] = targetPlayer.CharacterAdded:Connect(function()
                wait(1)
                if espEnabled then
                    createESP(targetPlayer)
                end
            end)
        end
    else
        for targetPlayer, _ in pairs(espObjects) do
            removeESP(targetPlayer)
        end
        
        if connections.playerAdded then
            connections.playerAdded:Disconnect()
        end
        
        for _, connection in pairs(connections.characterAdded or {}) do
            connection:Disconnect()
        end
        connections.characterAdded = {}
    end
end

local function toggleNoCollision()
    noCollisionEnabled = not noCollisionEnabled
    
    if noCollisionEnabled then
        local function setNoCollision(character)
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = false
                end
            end
        end
        
        if player.Character then
            setNoCollision(player.Character)
        end
        
        connections.noCollisionRespawn = player.CharacterAdded:Connect(function(character)
            wait(0.1)
            if noCollisionEnabled then
                setNoCollision(character)
            end
        end)
        
        connections.noCollisionMaintain = RunService.Heartbeat:Connect(function()
            if noCollisionEnabled and player.Character then
                for _, part in pairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if player.Character then
            for _, part in pairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
        
        if connections.noCollisionRespawn then
            connections.noCollisionRespawn:Disconnect()
        end
        
        if connections.noCollisionMaintain then
            connections.noCollisionMaintain:Disconnect()
        end
    end
end

local function markBase()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    basePosition = character.HumanoidRootPart.Position
    baseMarked = true
    
    -- Créer marqueur visuel
    local part = Instance.new("Part")
    part.Name = "SMS_BaseMarker"
    part.Shape = Enum.PartType.Cylinder
    part.Material = Enum.Material.ForceField
    part.BrickColor = BrickColor.new("Bright green")
    part.Size = Vector3.new(1, 10, 10)
    part.Anchored = true
    part.CanCollide = false
    part.Position = basePosition + Vector3.new(0, -3, 0)
    part.Rotation = Vector3.new(0, 0, 90)
    part.Parent = workspace
    
    -- Animation du marqueur
    local rotationTween = TweenService:Create(
        part,
        TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
        {Rotation = Vector3.new(0, 360, 90)}
    )
    rotationTween:Play()
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "📍 BASE MARQUÉE";
        Text = "Position sauvegardée !";
        Duration = 3;
    })
end

local function teleportToBase()
    if not baseMarked or not basePosition then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "❌ ERREUR";
            Text = "Aucune base marquée !";
            Duration = 3;
        })
        return
    end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    character.HumanoidRootPart.CFrame = CFrame.new(basePosition + Vector3.new(0, 5, 0))
    
    -- Effet de téléportation
    local effect = Instance.new("Explosion")
    effect.Position = character.HumanoidRootPart.Position
    effect.BlastRadius = 0
    effect.BlastPressure = 0
    effect.Visible = true
    effect.Parent = workspace
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "✅ TÉLÉPORTÉ";
        Text = "Retour à la base !";
        Duration = 2;
    })
end

-- Interface GUI moderne et stylée
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    gui = screenGui
    
    screenGui.Name = "SMS_MultiScript_GUI"
    screenGui.ResetOnSpawn = false
    
    -- Protection
    protectScript()
    screenGui.Parent = player.PlayerGui
    
    local mainFrame = Instance.new("Frame")
    local corner = Instance.new("UICorner")
    local gradient = Instance.new("UIGradient")
    
    mainFrame.Size = UDim2.new(0, 380, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -190, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame
    
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(45, 45, 65)),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(25, 25, 35))
    }
    gradient.Rotation = 45
    gradient.Parent = mainFrame
    
    -- Titre avec style
    local titleFrame = Instance.new("Frame")
    local titleCorner = Instance.new("UICorner")
    local titleLabel = Instance.new("TextLabel")
    
    titleFrame.Size = UDim2.new(1, 0, 0, 60)
    titleFrame.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
    titleFrame.BorderSizePixel = 0
    titleFrame.Parent = mainFrame
    
    titleCorner.CornerRadius = UDim.new(0, 15)
    titleCorner.Parent = titleFrame
    
    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🚀 SMS MULTI-SCRIPT v2.0"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = titleFrame
    
    -- Bouton fermer stylé
    local closeButton = Instance.new("TextButton")
    local closeCorner = Instance.new("UICorner")
    
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -50, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.BorderSizePixel = 0
    closeButton.Parent = titleFrame
    
    closeCorner.CornerRadius = UDim.new(0, 10)
    closeCorner.Parent = closeButton
    
    -- Fonction pour créer des sections
    local function createSection(title, emoji, yPos, buttons)
        local section = Instance.new("Frame")
        local sectionCorner = Instance.new("UICorner")
        local sectionTitle = Instance.new("TextLabel")
        
        section.Size = UDim2.new(1, -20, 0, 100)
        section.Position = UDim2.new(0, 10, 0, yPos)
        section.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        section.BorderSizePixel = 0
        section.Parent = mainFrame
        
        sectionCorner.CornerRadius = UDim.new(0, 10)
        sectionCorner.Parent = section
        
        sectionTitle.Size = UDim2.new(1, 0, 0, 30)
        sectionTitle.BackgroundTransparency = 1
        sectionTitle.Text = emoji .. " " .. title
        sectionTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
        sectionTitle.TextScaled = true
        sectionTitle.Font = Enum.Font.GothamSemibold
        sectionTitle.Parent = section
        
        for i, button in ipairs(buttons) do
            local btn = Instance.new("TextButton")
            local btnCorner = Instance.new("UICorner")
            
            btn.Size = UDim2.new(button.width or 0.48, 0, 0, 35)
            btn.Position = UDim2.new(button.x or ((i-1) * 0.51), 5, 0, 40)
            btn.BackgroundColor3 = button.color or Color3.fromRGB(70, 130, 255)
            btn.Text = button.text
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextScaled = true
            btn.Font = Enum.Font.Gotham
            btn.BorderSizePixel = 0
            btn.Parent = section
            
            btnCorner.CornerRadius = UDim.new(0, 8)
            btnCorner.Parent = btn
            
            btn.MouseButton1Click:Connect(button.callback)
            
            -- Animation hover
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 160, 255)}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = button.color or Color3.fromRGB(70, 130, 255)}):Play()
            end)
        end
        
        return section
    end
    
    -- Section Base
    local espToggleBtn, ncToggleBtn
    
    createSection("TÉLÉPORTATION BASE", "🏠", 80, {
        {text = "MARQUER BASE", callback = markBase, color = Color3.fromRGB(50, 200, 50)},
        {text = "TÉLÉPORTER", callback = teleportToBase, color = Color3.fromRGB(50, 150, 255)}
    })
    
    -- Section ESP
    local espSection = createSection("ESP WALLHACK", "👁️", 200, {
        {text = "ESP: OFF", callback = function()
            toggleESP()
            espToggleBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
            espToggleBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        end, color = Color3.fromRGB(200, 50, 50), width = 0.96, x = 0.02}
    })
    espToggleBtn = espSection:FindFirstChild("TextButton")
    
    -- Section No Collision
    local ncSection = createSection("NO COLLISION", "👻", 320, {
        {text = "NO COLLISION: OFF", callback = function()
            toggleNoCollision()
            ncToggleBtn.Text = noCollisionEnabled and "NO COLLISION: ON" or "NO COLLISION: OFF"
            ncToggleBtn.BackgroundColor3 = noCollisionEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        end, color = Color3.fromRGB(200, 50, 50), width = 0.96, x = 0.02}
    })
    ncToggleBtn = ncSection:FindFirstChild("TextButton")
    
    -- Bouton minimize
    local minimizeButton = Instance.new("TextButton")
    local minCorner = Instance.new("UICorner")
    
    minimizeButton.Size = UDim2.new(0, 100, 0, 35)
    minimizeButton.Position = UDim2.new(0, 10, 1, -45)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
    minimizeButton.Text = "MINIMISER"
    minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeButton.TextScaled = true
    minimizeButton.Font = Enum.Font.Gotham
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Parent = screenGui
    minimizeButton.Visible = false
    
    minCorner.CornerRadius = UDim.new(0, 8)
    minCorner.Parent = minimizeButton
    
    closeButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        minimizeButton.Visible = true
    end)
    
    minimizeButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        minimizeButton.Visible = false
    end)
    
    -- Notification de chargement
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "✅ SMS MULTI-SCRIPT";
        Text = "Script chargé avec succès !";
        Duration = 5;
    })
end

-- Gestion des respawns
player.CharacterAdded:Connect(function(character)
    wait(1)
    if noCollisionEnabled then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = false
            end
        end
    end
end)

-- Initialisation
wait(2)
createGUI()

print("=== SMS MULTI-SCRIPT LOADED ===")
print("Script créé par SMS Team")
print("Compatible avec tous les executors")
print("===============================")
