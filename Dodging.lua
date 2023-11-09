-- Dodging System
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DodgeCooldown = 2 -- Set the dodge cooldown time in seconds

local lastDodgeTime = {} -- To track dodge cooldown for each player

function module.CanDodge(player)
	local currentTime = tick()
	local lastDodge = lastDodgeTime[player]

	if not lastDodge or (currentTime - lastDodge >= DodgeCooldown) then
		return true
	else
		return false
	end
end

function module.Dodge(player, animationIndex, dodgeDirection)
	if not module.CanDodge(player) then
		return
	end

	local DodgeAnimation = ReplicatedStorage:WaitForChild("DodgeAnimation")
	local Animations = DodgeAnimation:WaitForChild("Animations")
	local Character = player.Character
	local Humanoid = Character:WaitForChild("Humanoid")
	local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

	local animator = Humanoid:FindFirstChildOfClass("Animator")

	local animations = Animations:GetChildren()
	local animation = animations[animationIndex]

	if animation and dodgeDirection then
		local dodgeAnimation = animator:LoadAnimation(animation)

		local dodgeVelocity = (dodgeDirection == "Left") and
			HumanoidRootPart.CFrame.RightVector * -1 or
			(dodgeDirection == "Right") and HumanoidRootPart.CFrame.RightVector or
			Vector3.new(0, 0, 0) -- Default to no movement

		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bv.Velocity = dodgeVelocity * Vector3.new(10, 1, 10) -- dodge to the opposite direction of the attack's direction

		dodgeAnimation:Play()
		bv.Parent = HumanoidRootPart

		lastDodgeTime[player] = tick() -- Update the last dodge time

		wait(0.25)
		bv:Destroy()
	end
end
