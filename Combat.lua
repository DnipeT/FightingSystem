function module.SwordCombat(count, player, NewChild)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local TweenService = game:GetService("TweenService")
	local UserInputService = game:GetService("UserInputService")

	local rp = ReplicatedStorage:WaitForChild("Combat")
	local selectedAttack = nil
	local isMouseHeld = false

	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if not gameProcessedEvent and input.UserInputType == Enum.UserInputType.MouseButton1 then
			isMouseHeld = true
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isMouseHeld = false
			selectedAttack = nil
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if isMouseHeld and input.UserInputType == Enum.UserInputType.MouseMovement then
			selectedAttack = (input.Delta.x > 0) and "Right" or "Left"
		end
	end)

	local function performAttack(count, player)
		-- Your attack logic here, using the selectedAttack
		if selectedAttack == "Left" then
			-- Perform left attack
			-- Update animation and logic accordingly
		elseif selectedAttack == "Right" then
			-- Perform right attack
			-- Update animation and logic accordingly
		end
	end

	local newHitbox = RAYCAST_HITBOX:Initialize(NewChild.Blade)

	local Animations = script.SwordCombat:WaitForChild("Animations")
	local eAnims = script.SwordCombat:WaitForChild("EnemyAnims")

	local limbs = "Right Arm"

	local Damage = 10
	local BonusDamage = player:WaitForChild("ResetingValue"):WaitForChild("BonusDamage").Value
	local Character = player.Character
	local Humanoid = Character:WaitForChild("Humanoid")
	local Humrp = Character:WaitForChild("HumanoidRootPart")

	local attack = Humanoid:LoadAnimation(Animations:WaitForChild("CommonAttack"))

	local function onHit(Hit)
		if Hit:IsA("BasePart") and not Hit:IsDescendantOf(Character) then
			if not Hit:IsDescendantOf(Character) then
				local enemyHumanoid = Hit.Parent:FindFirstChild("Humanoid")
				local enemyHumrp = Hit.Parent:FindFirstChild("HumanoidRootPart")

				if enemyHumanoid and enemyHumrp then
					local blockValue = Hit.Parent:FindFirstChild("BlockValue")

					if blockValue then
						if blockValue.Value > 0 then
							blockValue.Value = blockValue.Value - 1
						else
							blockValue:Destroy() -- Block breaker
						end
					else
						local react = enemyHumanoid:LoadAnimation(eAnims[1])
						react:Play()

						local hit = Instance.new("BoolValue")
						hit.Parent = Hit.Parent
						hit.Name = "Hit"
						game.Debris:AddItem(hit, 5)

						local damageDealt = Damage + BonusDamage * Damage
						if game:GetService("Players"):GetPlayerFromCharacter(Hit.Parent) then
							local eneplayer = game:GetService("Players"):GetPlayerFromCharacter(Hit.Parent)
							local eneResistance = eneplayer:FindFirstChild("ResetingValue") and eneplayer:FindFirstChild("ResetingValue").Resistance.Value or 0
							damageDealt = damageDealt - eneResistance * Damage
						end
						enemyHumanoid:TakeDamage(damageDealt)

						if count == 4 then
							local goal = {}
							goal.CFrame = CFrame.new((Humrp.CFrame * CFrame.new(0, 0, -10)).p, Humrp.CFrame.p)
							local info = TweenInfo.new(0.7)
							local tween = TweenService:Create(enemyHumrp, info, goal)
							tween:Play() -- Knockback
						end

						wait(0.5)
					end
				end
			end

		end
	end

	newHitbox.OnHit:Connect(onHit)

	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			performAttack(1, game.Players.LocalPlayer)
		end
	end)

end
