local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player: Player = Players.LocalPlayer
local screen = player.PlayerGui:WaitForChild("App"):WaitForChild("Container"):WaitForChild("Screen")

local top = screen

local myPlotButton = top:WaitForChild("MyPlot")
local towerButton = top:WaitForChild("TowerButton")
local sellItemsButton = top:WaitForChild("SellItems")
local upgradesButton = top:WaitForChild("Upgrades")

local MYPLOT_ORIGINAL_SIZE = myPlotButton.Size
local HIDDEN_SIZE = UDim2.new(0, 0, 0, 0)
local TOWER_TARGET_SIZE = UDim2.new(0.14, 0, 0.094, 0)
local BASE_PADDING = 5 -- מרווח נוסף סביב הבסיס (studs)

local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local TopButtons = {}

TopButtons.insideBase = false
TopButtons.activeTween = {}

TopButtons.cachedPlot = nil
TopButtons.cachedBaseCF = nil
TopButtons.cachedBaseSize = nil



local function getMyPlot(): Model?
	local plotValue = player:FindFirstChild("Plot")
	if plotValue and plotValue:IsA("ObjectValue") then
		return plotValue.Value
	end
	return nil
end


local function cancelTween(guiObject)
	if TopButtons.activeTween[guiObject] then
		TopButtons.activeTween[guiObject]:Cancel()
		TopButtons.activeTween[guiObject] = nil
	end
end


local function tweenSize(guiObject, targetSize, onComplete)
	cancelTween(guiObject)
	local tween = TweenService:Create(guiObject, TWEEN_INFO, { Size = targetSize })
	TopButtons.activeTween[guiObject] = tween
	if onComplete then
		tween.Completed:Connect(function(state)
			if state == Enum.PlaybackState.Completed then
				onComplete()
			end
		end)
	end
	tween:Play()
	return tween
end


local function teleportTo(targetCFrame: CFrame)
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	character:PivotTo(targetCFrame * CFrame.new(0, 3, 0))
end


local function ensureBaseCache(plot: Model): boolean
	if TopButtons.cachedPlot ~= plot then
		TopButtons.cachedPlot = plot
		TopButtons.cachedBaseCF = nil
		TopButtons.cachedBaseSize = nil
	end

	if TopButtons.cachedBaseCF and TopButtons.cachedBaseSize then
		return true
	end

	local base = plot:FindFirstChild("Base")
	if not base then return false end
	local ground1 = base:FindFirstChild("Ground1", true)
	if not ground1 or not ground1:IsA("BasePart") then
		return false
	end

	TopButtons.cachedBaseCF = ground1.CFrame
	TopButtons.cachedBaseSize = ground1.Size
	return true
end

local function isPointInsideBase(point: Vector3): boolean
	local cf = TopButtons.cachedBaseCF
	local size = TopButtons.cachedBaseSize
	if not cf or not size then
		return false
	end
	local localPoint = cf:PointToObjectSpace(point)
	local halfSize = size / 2
	return math.abs(localPoint.X) <= (halfSize.X + BASE_PADDING)
		and math.abs(localPoint.Z) <= (halfSize.Z + BASE_PADDING)
end


function TopButtons.enterBase()
	if TopButtons.insideBase then return end
	TopButtons.insideBase = true
	tweenSize(myPlotButton, HIDDEN_SIZE, function()
		myPlotButton.Visible = false
	end)
	towerButton.Size = HIDDEN_SIZE
	towerButton.Visible = true
	tweenSize(towerButton, TOWER_TARGET_SIZE)
end


function TopButtons.exitBase()
	if not TopButtons.insideBase then return end
	TopButtons.insideBase = false

	myPlotButton.Visible = true
	myPlotButton.Size = HIDDEN_SIZE
	tweenSize(myPlotButton, MYPLOT_ORIGINAL_SIZE)
	tweenSize(towerButton, HIDDEN_SIZE, function()
		towerButton.Visible = false
		towerButton.Size = TOWER_TARGET_SIZE
	end)
end


function TopButtons.checkBaseBounds()
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local plot = getMyPlot()
	if not plot then return end

	if not ensureBaseCache(plot) then return end

	local inside = isPointInsideBase(hrp.Position)

	if inside and not TopButtons.insideBase then
		TopButtons.enterBase()
	elseif not inside and TopButtons.insideBase then
		TopButtons.exitBase()
	end
end


function TopButtons:init()
	towerButton.Size = TOWER_TARGET_SIZE
	towerButton.Visible = false
	myPlotButton.Visible = true
	myPlotButton.Activated:Connect(function()
		local plot = getMyPlot()
		if not plot then return end

		local func = plot:FindFirstChild("Func")
		if not func then return end

		local spawnPart = func:FindFirstChild("Spawn")
		if not spawnPart then return end

		teleportTo(spawnPart.CFrame)
	end)
	towerButton.Activated:Connect(function()
		local funcFolder = workspace:FindFirstChild("Func")
		if not funcFolder then return end

		local tower = funcFolder:FindFirstChild("Tower")
		if not tower then return end

		local tele = tower:FindFirstChild("Tele")
		if not tele or not tele:IsA("BasePart") then return end

		teleportTo(tele.CFrame)
	end)

	sellItemsButton.Activated:Connect(function()
		local funcFolder = workspace:FindFirstChild("Func")
		if not funcFolder then return end
		local shopBooths = funcFolder:FindFirstChild("ShopBooths")
		if not shopBooths then return end

		local sellShop = shopBooths:FindFirstChild("SellShop")
		if not sellShop then return end

		local shopFunc = sellShop:FindFirstChild("Func")
		if not shopFunc then return end

		local tele = shopFunc:FindFirstChild("Tele")
		if not tele then return end

		teleportTo(tele.CFrame)
	end)

	upgradesButton.Activated:Connect(function()
		local funcFolder = workspace:FindFirstChild("Func")
		if not funcFolder then return end
		local shopBooths = funcFolder:FindFirstChild("ShopBooths")
		if not shopBooths then return end

		local upgrades = shopBooths:FindFirstChild("Upgrades")
		if not upgrades then return end

		local shopFunc = upgrades:FindFirstChild("Func")
		if not shopFunc then return end

		local tele = shopFunc:FindFirstChild("Tele")
		if not tele then return end

		teleportTo(tele.CFrame)
	end)
	RunService.Heartbeat:Connect(function()
		TopButtons.checkBaseBounds()
	end)
end

return TopButtons
