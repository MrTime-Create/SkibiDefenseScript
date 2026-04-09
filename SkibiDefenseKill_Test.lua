local Mobs = game:GetService("Workspace"):WaitForChild("Scripted"):WaitForChild("Enemies")
local Player = game:GetService("Players").LocalPlayer
local WaveGui = Player.PlayerGui:WaitForChild("Data"):WaitForChild("Wave"):WaitForChild("Frame"):WaitForChild("TextLabel")

_G.AutoKill = true

while _G.AutoKill do
    task.wait(0.1) 
    
    if WaveGui and WaveGui.Text == "WAVE 150" then
        _G.AutoKill = false
        break
    end

    for _, enemy in pairs(Mobs:GetChildren()) do
        local currentHealth = enemy:GetAttribute("Health")
        
        if currentHealth and currentHealth > 0 then
            enemy:SetAttribute("Health", 0) 
        end
    end
end
