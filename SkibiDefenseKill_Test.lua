local Mobs = game:GetService("Workspace"):WaitForChild("Scripted"):WaitForChild("Enemies")
local Player = game:GetService("Players").LocalPlayer
local WaveGui = Player.PlayerGui:WaitForChild("Data"):WaitForChild("Wave"):WaitForChild("Frame"):WaitForChild("TextLabel")

_G.AutoKill = true

while _G.AutoKill do
    -- 1. CRITICAL: Added a wait to prevent the game from freezing/crashing
    task.wait(0.1) 
    
    -- 2. Moved the Wave check INSIDE the loop so it constantly checks
    if WaveGui and WaveGui.Text == "WAVE 150" then
        _G.AutoKill = false
        break -- Exits the loop
    end

    for _, enemy in pairs(Mobs:GetChildren()) do
        -- 3. Corrected attribute syntax
        local currentHealth = enemy:GetAttribute("Health")
        
        -- Make sure the enemy has the attribute and is still alive
        if currentHealth and currentHealth > 0 then
            -- 4. Correctly set the attribute to 0 to "kill" it
            enemy:SetAttribute("Health", 0) 
            
            -- Note: If the game uses standard Humanoids instead of attributes, use this instead:
            -- local hum = enemy:FindFirstChildOfClass("Humanoid")
            -- if hum then hum.Health = 0 end
        end
    end
end