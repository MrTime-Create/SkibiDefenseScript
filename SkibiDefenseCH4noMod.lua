--GameRemotes
local ChangeRemote = game:GetService("ReplicatedStorage"):WaitForChild("Game"):WaitForChild("Speed"):WaitForChild("Change")
local WaveSkipsRemote = game:GetService("ReplicatedStorage"):WaitForChild("Event"):WaitForChild("waveSkip")
local StartGameRemote = game:GetService("ReplicatedStorage"):WaitForChild("GAME_START"):WaitForChild("readyButton")
local ReplayCoreRemote = game:GetService("ReplicatedStorage"):WaitForChild("Event"):WaitForChild("ReplayCore")

local PlaceTowerRemote = game:GetService("ReplicatedStorage"):WaitForChild("Event"):WaitForChild("placeTower")
local UpgradeTowerRemote = game:GetService("ReplicatedStorage"):WaitForChild("Event"):WaitForChild("UpgradeTower")

--Player Data
local Player = game:GetService("Players").LocalPlayer
local Money = Player:WaitForChild("leaderstats"):WaitForChild("Money")

--Game Details
local WaveGui = Player.PlayerGui:WaitForChild("Data"):WaitForChild("Wave"):WaitForChild("Frame"):WaitForChild("TextLabel")

--Game Workspace
local TowerData = game:GetService("Workspace"):WaitForChild("Scripted"):WaitForChild("TowerData")

--Tower Needed
local TowerPrice = {
    [1] = {Name = "UpgSilver", Price = 0},
    [2] = {Name = "Speakerwoman", Price = 700},
    [3] = {Name = "DJ", Price = 13500},
    [4] = {Name = "UTCP", Price = 10200000},
}

local TowerLocation = {
    [1] = {Name = "UpgSilver", CFrame = CFrame.new(-391.57293701171875, -279.7645568847656, 277.38739013671875, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
    [2] = {Name = "Speakerwoman", CFrame = CFrame.new(-392.5389404296875, -279.764404296875, 271.63232421875, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
    [3] = {Name = "DJ", CFrame = CFrame.new(-428.2357482910156, -279.7644348144531, 281.806884765625, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
    [4] = {Name = "UTCP", CFrame = CFrame.new(-336.0376892089844, -279.764404296875, 276.20135498046875, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
}

local placedTowers = {}
local isReplaying = false

local function SetGameSpeed(Value)
    ChangeRemote:FireServer(Value)
end

local function WaveSkipsAuto(Delay)
    task.spawn(function()
        while task.wait(Delay) do
            WaveSkipsRemote:FireServer(true)
        end
    end)
end

local function AutoUpgTower(Delay)
    task.spawn(function()
        while task.wait(Delay) do
            for _, tower in pairs(TowerData:GetChildren()) do
                pcall(function()
                    UpgradeTowerRemote:FireServer(tower.Name) 
                end)
            end
        end
    end)
end

local function AutoPlaceTowersCheck()
    task.spawn(function()
        while task.wait(0.5) do
            if not isReplaying then
                for i = 1, #TowerPrice do
                    if not placedTowers[i] and Money.Value >= TowerPrice[i].Price then
                        PlaceTowerRemote:FireServer(TowerPrice[i].Name, TowerLocation[i].CFrame, false)
                        placedTowers[i] = true
                        print("Placed " .. TowerPrice[i].Name .. "!")
                        
                        task.wait(1)
                    end
                end
            end
        end
    end)
end

local function AutoPlay()
    SetGameSpeed(5)
    WaveSkipsAuto(0.1)
    AutoUpgTower(0.25)
    AutoPlaceTowersCheck() -- เรียกใช้งาน Auto Place

    WaveGui:GetPropertyChangedSignal("Text"):Connect(function()
        local waveNumber = tonumber(string.match(WaveGui.Text, "%d+"))
        
        if waveNumber then
            if waveNumber >= 25 and not isReplaying then
                isReplaying = true
                print("Wave 25 Reached! Preparing to replay...")
                
                task.spawn(function()
                    task.wait(30)
                    pcall(function() ReplayCoreRemote:FireServer() end)
                    
                    task.wait(10)
                    pcall(function() StartGameRemote:FireServer(true) end)
                    
                    table.clear(placedTowers)
                    print("Placed Towers list has been reset!")
                    
                    isReplaying = false
                    print("System Reset! Ready for the next match.")
                    
                    task.wait(5)
                    SetGameSpeed(5)
                end)
            end
        end
    end)
end

AutoPlay()
