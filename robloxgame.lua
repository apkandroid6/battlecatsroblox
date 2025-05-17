-- WELCOME
---
Explorer: line 8
Scripts: line 29
description: line 139
---

Workplace
    EnemyBase
        Attribute
        
ServerScripts
    MoneyManager
    BattleScript
    
attribute script
script.Parent:SetAttribute("Health", 100)

ReplicatedStorage
    UnitSpawn (remote event)
    Models (folder v)
        CatUnit
    
StarterGui
    screengui
        spawnbutton (text button)


---
SCRIPTS


unit spawn scriot
-- ServerScriptService > BattleScript

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpawnEvent = ReplicatedStorage:WaitForChild("SpawnUnit")
local UnitModel = ReplicatedStorage:WaitForChild("Models"):WaitForChild("CatUnit")
local EnemyBase = workspace:WaitForChild("EnemyBase")

-- Health setup
if not EnemyBase:GetAttribute("Health") then
	EnemyBase:SetAttribute("Health", 100)
end

-- Table of all active units
local ActiveUnits = {}

-- Handle spawning a unit
SpawnEvent.OnServerEvent:Connect(function(player)
	local money = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("₩머니")

	if not money or money.Value < 25 then
		print(player.Name .. " doesn't have enough ₩머니.")
		return
	end

	money.Value -= 25

	local unit = UnitModel:Clone()
	unit.Parent = workspace
	unit:SetPrimaryPartCFrame(CFrame.new(-50, 5, 0))

	table.insert(ActiveUnits, unit)
end)

-- Central loop to move all units
task.spawn(function()
	while true do
		task.wait(0.2)

		for i = #ActiveUnits, 1, -1 do
			local unit = ActiveUnits[i]

			if unit and unit.Parent and unit.PrimaryPart then
				local distance = (unit.PrimaryPart.Position - EnemyBase.Position).Magnitude

				if distance < 5 then
					local hp = EnemyBase:GetAttribute("Health") or 0
					hp -= 10
					EnemyBase:SetAttribute("Health", hp)
					print("Enemy base hit! HP:", hp)

					unit:Destroy()
					table.remove(ActiveUnits, i)
				else
					unit:SetPrimaryPartCFrame(unit.PrimaryPart.CFrame * CFrame.new(0.5, 0, 0))
				end
			else
				table.remove(ActiveUnits, i)
			end
		end
	end
end)

-- Base death handling
EnemyBase:GetAttributeChangedSignal("Health"):Connect(function()
	local hp = EnemyBase:GetAttribute("Health")
	if hp <= 0 then
		print("Enemy base destroyed!")
		EnemyBase:Destroy()
	end
end)

Moneymanager script
-- ServerScriptService > MoneyManager

game.Players.PlayerAdded:Connect(function(player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player

	local won = Instance.new("IntValue")
	won.Name = "₩머니" -- Hangul for "money"
	won.Value = 0
	won.Parent = stats

	-- Give 25 won every 1 second
	task.spawn(function()
		while player and player.Parent do
			wait(0.1)
			won.Value = won.Value + 1
		end
	end)
end)

spawnbutton script

-- LocalScript inside SpawnButton
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local spawnEvent = ReplicatedStorage:WaitForChild("SpawnUnit")

script.Parent.MouseButton1Click:Connect(function()
	spawnEvent:FireServer()
end)



---
description
bad battlr cats remake