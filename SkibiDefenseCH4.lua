local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer

-- Whitelist System
local Whitelist = {
    [8642639958] = true,
}

if not Whitelist[Player.UserId] then
    Player:Kick("You are not in Whitelist! You having to pay owner")
    return
end

print("✅ Approve Whitelist succeed!")

-- Teleport Queue Logic
local queue_on_teleport = (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport) or (getgenv and getgenv().queue_on_teleport)
local ScriptToRun = [[
    task.spawn(function()
        if not game:IsLoaded() then game.Loaded:Wait() end
        task.wait(3) 
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/MrTime-Create/SkibiDefenseScript/refs/heads/main/SkibiDefenseCH4.lua"))()
        end)
    end)
]]

if queue_on_teleport then
    queue_on_teleport(ScriptToRun)
end

-----------------------------------------
-- LOBBY LOGIC (PlaceId: 14279693118)
-----------------------------------------
if game.PlaceId == 14279693118 then
    local Events = ReplicatedStorage:WaitForChild("Events", 10)
    local CreateRemote = Events and Events:WaitForChild("createServer", 5)

    if CreateRemote then
        task.wait(15)
        local success = pcall(function() return CreateRemote:InvokeServer("Chapter 4") end)

        if success then
            local PlayerGui = Player:WaitForChild("PlayerGui")
            local startBtn = PlayerGui:WaitForChild("Main"):WaitForChild("Frame"):WaitForChild("Layout")
                :WaitForChild("ServerMenu"):WaitForChild("Alpha"):WaitForChild("Starting"):WaitForChild("TextButton")

            if startBtn then
                local initialText = startBtn.Text
                task.spawn(function()
                    while startBtn and startBtn.Parent and startBtn.Text == initialText do
                        local pos = startBtn.AbsolutePosition
                        local size = startBtn.AbsoluteSize
                        local centerX = pos.X + (size.X / 2)
                        local centerY = pos.Y + (size.Y / 2) + 58 -- Y_OFFSET
                        
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
                        task.wait(0.05)
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
                        task.wait(1)
                    end
                end)
            end
        end
    end
end

-----------------------------------------
-- MATCH LOGIC (PlaceId: 14279724900)
-----------------------------------------
if game.PlaceId == 14279724900 then
    warn("In Match: Starting Optimized AutoPlay...")
    
    local GameData = ReplicatedStorage:WaitForChild("Game")
    local MainEvent = ReplicatedStorage:WaitForChild("Event")
    
    -- Remotes
    local Remotes = {
        Speed = GameData:WaitForChild("Speed"):WaitForChild("Change"),
        Skip = MainEvent:WaitForChild("waveSkip"),
        Ready = ReplicatedStorage:WaitForChild("GAME_START"):WaitForChild("readyButton"),
        Place = MainEvent:WaitForChild("placeTower"),
        Upgrade = MainEvent:WaitForChild("UpgradeTower")
    }

    task.wait(5)
    pcall(function() Remotes.Ready:FireServer(true) end)
    
    -- Folders/Stats
    local TowerData = workspace:WaitForChild("Scripted"):WaitForChild("TowerData")
    local Enemies = workspace:WaitForChild("Scripted"):WaitForChild("Enemies")
    local Money = Player:WaitForChild("leaderstats"):WaitForChild("Money")

    -- UI Elements
    local DataGui = Player.PlayerGui:WaitForChild("Data")
    local WaveLabel = DataGui:WaitForChild("Wave"):WaitForChild("Frame"):WaitForChild("TextLabel")
    local HPLabel = DataGui:WaitForChild("HP"):WaitForChild("Frame"):WaitForChild("TextLabel")

    local TowerConfigs = {
        {Name = "UpgSilver", Price = 0, Pos = CFrame.new(-561.83581542969, -279.76455688477, 19.216766357422)},
        {Name = "Speakerwoman", Price = 700, Pos = CFrame.new(-573.01110839844, -279.76440429688, 16.11022567749)},
        {Name = "DJ", Price = 13500, Pos = CFrame.new(-578.98693847656, -279.76443481445, 3.4188995361328)},
        {Name = "ArmadaSpeakerman", Price = 8000, Pos = CFrame.new(-560.45288085938, -279.76440429688, 22.294364929199)},
        {Name = "ArmadaStrider", Price = 10000000, Pos = CFrame.new(-553.50939941406, -279.76440429688, 19.92643737793)},
        {Name = "UTCP", Price = 14200000, Pos = CFrame.new(-559.98187255859, -279.76440429688, 11.558878898621)}
    }

    local placedTowers = {}

    -- Functions
    local function AutoAction()
        -- 1. Start & Speed
        task.wait(2)
        pcall(function() Remotes.Speed:FireServer(5) end)

        -- 2. Main Loop
        task.spawn(function()
            while task.wait(0.5) do
                -- Auto Skip & Upgrade
                pcall(function() Remotes.Skip:FireServer(true) end)
                
                for _, tower in ipairs(TowerData:GetChildren()) do
                    pcall(function() Remotes.Upgrade:FireServer(tower.Name) end)
                end

                -- Auto Place (ลองวางสูงสุด 3 ครั้ง)
                for i, config in ipairs(TowerConfigs) do
                    if not placedTowers[i] and Money.Value >= config.Price then
                        for attempt = 1, 3 do
                            local success = pcall(function() 
                                Remotes.Place:FireServer(config.Name, config.Pos, false) 
                            end)
                            
                            if success then 
                                placedTowers[i] = true 
                                print(string.format("✅ Placed: %s (Attempt %d)", config.Name, attempt))
                                break 
                            end
                            task.wait(0.2) -- เว้นช่วง 0.2 วินาทีก่อนลองวางซ้ำ
                        end
                    end
                end
            end
        end)

        -- 3. Game Status Check
        task.spawn(function()
            while task.wait(30) do
                -- Check HP
                local hp = tonumber(HPLabel.Text:match("%d+"))
                if hp and hp <= 0 then
                    TeleportService:Teleport(14279693118, Player)
                    break
                end

                -- Check Win (Wave 25+)
                local wave = tonumber(WaveLabel.Text:match("%d+"))
                if wave and wave >= 25 and #Enemies:GetChildren() == 0 then
                    task.wait(5)
                    TeleportService:Teleport(14279693118, Player)
                    break
                end
            end
        end)
    end

    AutoAction()
end
