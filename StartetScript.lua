local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Combat = ReplicatedStorage:WaitForChild("Combat")
local Block = ReplicatedStorage:WaitForChild("Block")

local toolEquipped = nil
local isJumping = false
local isBroken = false
local isActive = false
local debounce = false
local debounceE1 = false
local debounceE2 = false
local count = 0
local countE1 = 0
local countE2 = 0

local currTime, prevTime = 0, 0
local currTimeE1, prevTimeE1 = 0, 0
local currTimeE2, prevTimeE2 = 0, 0
local cd = 0.45

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

Combat.OnClientEvent:Connect(function()
    prevTime = currTime
    wait(cd)
    debounce = false
end)

local function onEquipped(NewChild)
    toolEquipped = true
    if NewChild.Name == "Blade" then
        NewChild.Unequipped:Connect(function()
            toolEquipped = false
            Combat:FireServer("Unidle1")
        end)

        local function attack(attackType, count)
            if debounce == false and toolEquipped == true then
                debounce = true
                currTime = tick()
                local passedTime = currTime - prevTime
                if passedTime < 1 then
                    count = count + 1
                    if count > 4 then
                        count = 1
                    end
                else
                    count = 1
                end
                Combat:FireServer(attackType, count, NewChild)
                prevTime = currTime
                wait(0.6)
                debounce = false
            end
        end

        NewChild.Equipped:Connect(function()
            Combat:FireServer("idle1")
        end)

        UIS.InputBegan:Connect(function(input, IsTyping)
            if NewChild.Parent == character and not IsTyping then
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if isJumping == false then
                        attack("M1", count)
                    else
                        if debounce == false and toolEquipped == true then
                            debounce = true
                            Combat:FireServer("M1Jumping", count)
                            wait(1)
                            debounce = false
                        end
                    end
                elseif input.KeyCode == Enum.KeyCode.Space then
                    isJumping = true
                    wait(0.75)
                    isJumping = false
                elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                    if debounce == false and isBroken == false and isActive == false then
                        isActive = true
                        Combat:FireServer("Block", isActive)
                    end
                elseif input.KeyCode == Enum.KeyCode.E then
                    attack("E", countE2)
                elseif input.KeyCode == Enum.KeyCode.Q then
                    attack("Q", countE1)
                end
            end
        end)

        UIS.InputEnded:Connect(function(input, IsTyping)
            if not IsTyping then
                if input.UserInputType == Enum.UserInputType.MouseButton2 and debounce == false and isBroken == false and isActive == true then
                    isActive = false
                    Combat:FireServer("UnBlock", isActive)
                end
            end
        end)
    end
end

character.ChildAdded:Connect(onEquipped)

character.ChildRemoved:Connect(function(NewChild)
    if NewChild:IsA("Tool") then
        toolEquipped = false
    end
end)

local function CharacterAdded(char)
    char.ChildAdded:Connect(onEquipped)
end

local function PlayerAdded(player)
    player.CharacterAdded:Connect(CharacterAdded)
    local char = player.Character
    if char then
        CharacterAdded(char)
    end
end

Players.PlayerAdded:Connect(PlayerAdded)

for _, player in pairs(Players:GetPlayers()) do
    PlayerAdded(player)
end
