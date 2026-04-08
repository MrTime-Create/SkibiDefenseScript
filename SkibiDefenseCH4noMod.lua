if not game:IsLoaded() then
    game.Loaded:Wait()
end
task.wait(2)

local Player = game:GetService("Players").LocalPlayer

local queue_on_teleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport) or getgenv().queue_on_teleport

local ScriptToRun = [[
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MrTime-Create/SkibiDefenseScript/refs/heads/main/SkibiDefenseCH4noMod.lua"))()
]]

if queue_on_teleport then
    queue_on_teleport(ScriptToRun)
end

if game.PlaceId == 14279693118 then
    print("At Lobby: Creating Server...")
    local CreateRemote = game:GetService("ReplicatedStorage"):WaitForChild("Events", 10):WaitForChild("createServer")
    local StartRemote = game:GetService("ReplicatedStorage"):WaitForChild("Events", 10):WaitForChild("start")
    
    if CreateRemote and StartRemote then
        CreateRemote:InvokeServer("Chapter 4")
        task.wait(1)
        StartRemote:FireServer()
    end
    
    return 
end

if game.PlaceId == 14279724900 then
    print("In Match: Starting AutoPlay...")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local ChangeRemote = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Speed"):WaitForChild("Change")
    local WaveSkipsRemote = ReplicatedStorage:WaitForChild("Event"):WaitForChild("waveSkip")
    local StartGameRemote = ReplicatedStorage:WaitForChild("GAME_START"):WaitForChild("readyButton")
    local ReplayCoreRemote = ReplicatedStorage:WaitForChild("Event"):WaitForChild("ReplayCore")

    local PlaceTowerRemote = ReplicatedStorage:WaitForChild("Event"):WaitForChild("placeTower")
    local UpgradeTowerRemote = ReplicatedStorage:WaitForChild("Event"):WaitForChild("UpgradeTower")
    
    local TeleportService = game:GetService("TeleportService")

    local WaveGui = Player.PlayerGui:WaitForChild("Data"):WaitForChild("Wave"):WaitForChild("Frame"):WaitForChild("TextLabel")
    local BaseHPGui = Player.PlayerGui:WaitForChild("Data"):WaitForChild("HP"):WaitForChild("Frame"):WaitForChild("TextLabel")
    local TowerData = game:GetService("Workspace"):WaitForChild("Scripted"):WaitForChild("TowerData")

    task.wait(3)
    StartGameRemote:FireServer(true)

    local Money = Player:WaitForChild("leaderstats"):WaitForChild("Money")

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

    local function SetGameSpeed(Value)
        ChangeRemote:FireServer(Value)
    end

    local function WaveSkipsAuto(Delay)
        task.spawn(function()
            while task.wait(Delay) do
                pcall(function() WaveSkipsRemote:FireServer(true) end)
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
                if Money then
                    for i = 1, #TowerPrice do
                        if not placedTowers[i] and Money.Value >= TowerPrice[i].Price then
                            pcall(function()
                                PlaceTowerRemote:FireServer(TowerPrice[i].Name, TowerLocation[i].CFrame, false)
                                placedTowers[i] = true
                                print("Placed " .. TowerPrice[i].Name .. "!")
                            end)
                            task.wait(1)
                        end
                    end
                end
            end
        end)
    end

    local function CheckBaseHP()
    task.spawn(function()
        while task.wait(0.2) do
            if BaseHPGui then
                local hpString = string.match(BaseHPGui.Text, "%d+") 
                
                if hpString then
                    local currentHP = tonumber(hpString)
                    if currentHP <= 0 then
                        print("Base HP is 0! Teleporting back to Lobby...")
                        
                        if queue_on_teleport then
                            queue_on_teleport(ScriptToRun)
                        end
                        
                        TeleportService:Teleport(14279693118, Player)
                        
                        break
                    end
                end
            end
        end
    end)
end

    local function AutoPlay()
        task.wait(2)
        SetGameSpeed(5)
        WaveSkipsAuto(0.1)
        AutoUpgTower(0.25)
        AutoPlaceTowersCheck()
        CheckBaseHP()

        if WaveGui then
            local waveConnection
            
            waveConnection = WaveGui:GetPropertyChangedSignal("Text"):Connect(function()
                local waveNumber = tonumber(string.match(WaveGui.Text, "%d+"))
                
                if waveNumber and waveNumber >= 25 then
                    if waveConnection then 
                        waveConnection:Disconnect() 
                    end
                    
                    print("Wave 25 Reached! Preparing to replay...")
                    
                    task.spawn(function()
                        table.clear(placedTowers)
                        print("Placed Towers list has been reset!")
                        
                        print("System Reset! Ready for the next match.")
                        
                        task.wait(5)
                        print("Teleport back to lobby...")
                        TeleportService:Teleport(14279693118, Player)
                        if queue_on_teleport then
                            queue_on_teleport(ScriptToRun)
                        end
                    end)
                end
            end)
        end
    end

    AutoPlay()
end
