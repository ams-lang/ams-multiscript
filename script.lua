-- SMS Multi-Script - Version Ultra Simple qui fonctionne
print("🚀 Chargement du script SMS...")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Variables
local basePosition = nil
local baseMarked = false
local espEnabled = false
local noCollisionEnabled = false
local espConnections = {}

print("✅ Joueur chargé:", player.Name)

-- Fonction pour créer l'ESP
local function toggleESP()
    espEnabled = not espEnabled
    
    if espEnabled then
        print("👁️ ESP activé")
        
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                
                local gui = Instance.new("BillboardGui")
                gui.Name = "ESP_" .. otherPlayer.Name
                gui.Adornee = otherPlayer.Character.HumanoidRootPart
                gui.Size = UDim2.new(0, 200, 0, 100)
                gui.StudsOffset = Vector3.new(0, 3, 0)
                gui.AlwaysOnTop = true
                gui.Parent = otherPlayer.Character.HumanoidRootPart
                
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 1, 0)
                frame.BackgroundColor3 = Color3.new(1, 0, 0)
                frame.BackgroundTransparency = 0.5
                frame.BorderSizePixel = 2
                frame.BorderColor3 = Color3.new(0, 1, 0)
                frame.Parent = gui
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = otherPlayer.Name
                nameLabel.TextColor3 = Color3.new(1, 1, 1)
                nameLabel.TextScaled = true
                nameLabel.Font = Enum.Font.SourceSansBold
                nameLabel.Parent = frame
                
                local distanceLabel = Instance.new("TextLabel")
                distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
                distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
                distanceLabel.BackgroundTransparency = 1
                distanceLabel.Text = "0m"
                distanceLabel.TextColor3 = Color3.new(1, 1, 0)
                distanceLabel.TextScaled = true
                distanceLabel.Font = Enum.Font.SourceSans
                distanceLabel.Parent = frame
                
                -- Mettre à jour la distance
                local connection = RunService.Heartbeat:Connect(function()
                    if otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = (player.Character.HumanoidRootPart.Position - otherPlayer.Character.HumanoidRootPart.Position).Magnitude
                        distanceLabel.Text = math.floor(distance) .. "m"
                    end
                end)
                
                espConnections[otherPlayer.Name] = {gui, connection}
            end
        end
    else
        print("👁️ ESP désactivé")
        for playerName, data in pairs(espConnections) do
            if data[1] then data[1]:Destroy() end
            if data[2] then data[2]:Disconnect() end
        end
        espConnections = {}
    end
end

-- Fonction No Collision
local function toggleNoCollision()
    noCollisionEnabled = not noCollisionEnabled
    
    if noCollisionEnabled then
        print("👻 No Collision activé")
        
        local function setNoCollision()
            if player.Character then
                for _, part in pairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = false
                    end
                end
            end
        end
        
        setNoCollision()
        
        -- Maintenir no collision
        RunService.Heartbeat:Connect(function()
            if noCollisionEnabled then
                setNoCollision()
            end
        end)
    else
        print("👻 No Collision désactivé")
        if player.Character then
            for _, part in pairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Fonction marquer base
local function markBase()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        basePosition = player.Character.HumanoidRootPart.Position
        baseMarked = true
        
        -- Créer marqueur
        local marker = Instance.new("Part")
        marker.Name = "BaseMarker"
        marker.Shape = Enum.PartType.Cylinder
        marker.Material = Enum.Material.Neon
        marker.BrickColor = BrickColor.new("Bright green")
        marker.Size = Vector3.new(0.5, 8, 8)
        marker.Anchored = true
        marker.CanCollide = false
        marker.Position = basePosition + Vector3.new(0, -2, 0)
        marker.Rotation = Vector3.new(0, 0, 90)
        marker.Parent = workspace
        
        print("🏠 Base marquée à:", basePosition)
    end
end

-- Fonction téléporter
local function teleportToBase()
    if baseMarked and basePosition and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(basePosition + Vector3.new(0, 5, 0))
        
        local explosion = Instance.new("Explosion")
        explosion.Position = player.Character.HumanoidRootPart.Position
        explosion.BlastRadius = 0
        explosion.BlastPressure = 0
        explosion.Parent = workspace
        
        print("🚀 Téléporté vers la base!")
    else
        print("❌ Aucune base marquée!")
    end
end

-- Créer l'interface
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SMS_Script"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 350)
    frame.Position = UDim2.new(0.5, -150, 0.5, -175)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.new(0, 0.7, 1)
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "🚀 SMS SCRIPT"
    title.TextColor3 = Color3.new(0, 0.8, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    -- Bouton marquer base
    local markBtn = Instance.new("TextButton")
    markBtn.Size = UDim2.new(0.9, 0, 0, 40)
    markBtn.Position = UDim2.new(0.05, 0, 0, 50)
    markBtn.BackgroundColor3 = Color3.new(0, 0.7, 0)
    markBtn.Text = "MARQUER BASE"
    markBtn.TextColor3 = Color3.new(1, 1, 1)
    markBtn.TextScaled = true
    markBtn.Font = Enum.Font.SourceSans
    markBtn.Parent = frame
    markBtn.MouseButton1Click:Connect(markBase)
    
    -- Bouton téléporter
    local tpBtn = Instance.new("TextButton")
    tpBtn.Size = UDim2.new(0.9, 0, 0, 40)
    tpBtn.Position = UDim2.new(0.05, 0, 0, 100)
    tpBtn.BackgroundColor3 = Color3.new(0, 0.5, 1)
    tpBtn.Text = "TÉLÉPORTER"
    tpBtn.TextColor3 = Color3.new(1, 1, 1)
    tpBtn.TextScaled = true
    tpBtn.Font = Enum.Font.SourceSans
    tpBtn.Parent = frame
    tpBtn.MouseButton1Click:Connect(teleportToBase)
    
    -- Bouton ESP
    local espBtn = Instance.new("TextButton")
    espBtn.Size = UDim2.new(0.9, 0, 0, 40)
    espBtn.Position = UDim2.new(0.05, 0, 0, 150)
    espBtn.BackgroundColor3 = Color3.new(0.7, 0, 0)
    espBtn.Text = "ESP: OFF"
    espBtn.TextColor3 = Color3.new(1, 1, 1)
    espBtn.TextScaled = true
    espBtn.Font = Enum.Font.SourceSans
    espBtn.Parent = frame
    espBtn.MouseButton1Click:Connect(function()
        toggleESP()
        espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
        espBtn.BackgroundColor3 = espEnabled and Color3.new(0, 0.7, 0) or Color3.new(0.7, 0, 0)
    end)
    
    -- Bouton No Collision
    local ncBtn = Instance.new("TextButton")
    ncBtn.Size = UDim2.new(0.9, 0, 0, 40)
    ncBtn.Position = UDim2.new(0.05, 0, 0, 200)
    ncBtn.BackgroundColor3 = Color3.new(0.7, 0, 0)
    ncBtn.Text = "NO COLLISION: OFF"
    ncBtn.TextColor3 = Color3.new(1, 1, 1)
    ncBtn.TextScaled = true
    ncBtn.Font = Enum.Font.SourceSans
    ncBtn.Parent = frame
    ncBtn.MouseButton1Click:Connect(function()
        toggleNoCollision()
        ncBtn.Text = noCollisionEnabled and "NO COLLISION: ON" or "NO COLLISION: OFF"
        ncBtn.BackgroundColor3 = noCollisionEnabled and Color3.new(0, 0.7, 0) or Color3.new(0.7, 0, 0)
    end)
    
    -- Bouton fermer
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.9, 0, 0, 30)
    closeBtn.Position = UDim2.new(0.05, 0, 0, 250)
    closeBtn.BackgroundColor3 = Color3.new(1, 0, 0)
    closeBtn.Text = "FERMER"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.SourceSans
    closeBtn.Parent = frame
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    print("✅ Interface créée!")
end

-- Gérer les respawns
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

-- Lancer le script
wait(1)
createGUI()
print("🔥 SMS Script chargé avec succès!")
print("✅ Interface disponible - Toutes les fonctions prêtes!")
