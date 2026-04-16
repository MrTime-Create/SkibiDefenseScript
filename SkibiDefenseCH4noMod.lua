
local Player = game:GetService("Players").LocalPlayer

--game:GetService("RbxAnalyticsService"):GetClientId()

local Whitelist = {
    [8642639958] = true,
}

if not Whitelist[Player.UserId] then
    Player:Kick("You are not in Whitelist!")
    return
end

print("✅ Approve Whitelist succeed! Start working...")
local queue_on_teleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport) or (getgenv and getgenv().queue_on_teleport)

local ScriptToRun = [[
    task.spawn(function()
        repeat task.wait() until game:IsLoaded()
        task.wait(3) 

        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/MrTime-Create/SkibiDefenseScript/refs/heads/main/SkibiDefenseCH4noMod.lua"))()
        end)

        if not success then
            warn("Queue on Teleport failed: " .. tostring(err))
        end
    end)
]]

if queue_on_teleport then
    queue_on_teleport(ScriptToRun)
else
    warn("Your executor does not support queue_on_teleport!")
end

if game.PlaceId == 14279693118 then
    task.wait(10)

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Events = ReplicatedStorage:WaitForChild("Events")
    local CreateRemote = Events:WaitForChild("createServer")

    local success, err = pcall(function()
        CreateRemote:InvokeServer("Chapter 4")
    end)

    if success then
        task.wait(5)
        
        local playerGui = Player:WaitForChild("PlayerGui")
        local button = playerGui:WaitForChild("Main")
            :WaitForChild("Frame")
            :WaitForChild("Layout")
            :WaitForChild("ServerMenu")
            :WaitForChild("Alpha")
            :WaitForChild("Starting")
            :WaitForChild("TextButton")
            
        if button then
            local vim = game:GetService("VirtualInputManager")
            local initialText = button.Text
            local Y_OFFSET = 58 
            
            task.spawn(function()
                while button and button.Parent and button.Text == initialText do
                    local centerX = button.AbsolutePosition.X + (button.AbsoluteSize.X / 2)
                    local centerY = button.AbsolutePosition.Y + (button.AbsoluteSize.Y / 2) + Y_OFFSET
                    
                    vim:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
                    task.wait(0.05)
                    vim:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
                    
                    task.wait(1.5)
                end
            end)
        end
    end
end

if game.PlaceId == 14279724900 then
    print("In Match: Starting AutoPlay...")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TeleportService = game:GetService("TeleportService")
    
    local ChangeRemote = ReplicatedStorage:WaitForChild("Game"):WaitForChild("Speed"):WaitForChild("Change")
    local WaveSkipsRemote = ReplicatedStorage:WaitForChild("Event"):WaitForChild("waveSkip")
    local StartGameRemote = ReplicatedStorage:WaitForChild("GAME_START"):WaitForChild("readyButton")
    
    local PlaceTowerRemote = ReplicatedStorage:WaitForChild("Event"):WaitForChild("placeTower")
    local UpgradeTowerRemote = ReplicatedStorage:WaitForChild("Event"):WaitForChild("UpgradeTower")

    local WaveGui = Player.PlayerGui:WaitForChild("Data"):WaitForChild("Wave"):WaitForChild("Frame"):WaitForChild("TextLabel")
    local BaseHPGui = Player.PlayerGui:WaitForChild("Data"):WaitForChild("HP"):WaitForChild("Frame"):WaitForChild("TextLabel")
    
    task.wait(5)
    pcall(function() StartGameRemote:FireServer(true) end)
    
    local TowerData = game:GetService("Workspace"):WaitForChild("Scripted"):WaitForChild("TowerData")
    local EnemiesData = game:GetService("Workspace"):WaitForChild("Scripted"):WaitForChild("Enemies")
    local Money = Player:WaitForChild("leaderstats"):WaitForChild("Money")

    local TowerPrice = {
        [1] = {Name = "UpgSilver", Price = 0},
        [2] = {Name = "Speakerwoman", Price = 700},
        [3] = {Name = "DJ", Price = 13500},
        [4] = {Name = "UTCP", Price = 10200000},
        [5] = {Name = "ArmadaSpeakerman", Price = 8000},
        [6] = {Name = "ArmadaStrider", Price = 5000000}
    }

    local TowerLocation = {
        [1] = {Name = "UpgSilver", CFrame = CFrame.new(-391.57293701171875, -279.7645568847656, 277.38739013671875, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
        [2] = {Name = "Speakerwoman", CFrame = CFrame.new(-392.5389404296875, -279.764404296875, 271.63232421875, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
        [3] = {Name = "DJ", CFrame = CFrame.new(-428.2357482910156, -279.7644348144531, 281.806884765625, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
        [4] = {Name = "UTCP", CFrame = CFrame.new(-336.0376892089844, -279.764404296875, 276.20135498046875, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
        [5] = {Name = "ArmadaSpeakerman", CFrame = CFrame.new(-395.541748046875, -279.764404296875, 275.82574462890625, 1, 0, 0, 0, 1, 0, 0, 0, 1)}
        [6] = {Name = "ArmadaStrider", CFrame = CFame.new(-400, -279.764404296875, 280, 1, 0, 0, 0, 1, 0, 0, 0, 1)}
    }

    local placedTowers = {}

    local function SetGameSpeed(Value)
        pcall(function() ChangeRemote:FireServer(Value) end)
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
                            task.wait(0.5)
                        end
                    end
                end
            end
        end)
    end

    local function CheckBaseHP()
        task.spawn(function()
            while task.wait(1) do
                if BaseHPGui then
                    local hpString = string.match(BaseHPGui.Text, "%d+") 
                    if hpString then
                        local currentHP = tonumber(hpString)
                        if currentHP <= 0 then
                            print("Base HP is 0! Teleporting back to Lobby...")
                            TeleportService:Teleport(14279693118, Player)
                            break
                        end
                    end
                end
            end
        end)
    end

    local function CheckEnemiesOnWave25()
        task.spawn(function()
            while task.wait(30) do
                local waveNumber = tonumber(string.match(WaveGui.Text, "%d+"))
                if waveNumber and waveNumber >= 25 and #EnemiesData:GetChildren() == 0 then
                    print("Match Finished (Wave 25+)! Preparing to return to lobby...")
                    task.wait(2)
                    table.clear(placedTowers)
                    TeleportService:Teleport(14279693118, Player)
                    break
                end
            end
        end)
    end

    local function AutoPlay()
        task.wait(5)
        SetGameSpeed(5)
        WaveSkipsAuto(0.1)
        AutoUpgTower(0.1)
        AutoPlaceTowersCheck()
        CheckBaseHP()
        CheckEnemiesOnWave25() 
    end

    AutoPlay()
end
