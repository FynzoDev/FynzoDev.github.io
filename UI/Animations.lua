local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local animatedTag: string = "animated"

local Animations = {}

function Animations:init()
	for _, obj in CollectionService:GetTagged(animatedTag) do
		if obj:GetAttribute("Animation") == "Spin" then
			Animations.spin(obj)
		elseif obj:GetAttribute("Animation") == "SizeBounce" then
			Animations.sizeBounce(obj)
		elseif obj:GetAttribute("Animation") == "Pendulum" then
			Animations.pendulum(obj)
		end
	end
	
	CollectionService:GetInstanceAddedSignal(animatedTag):Connect(function(obj) 
		if obj:GetAttribute("Animation") == "Spin" then
			Animations.spin(obj)
		elseif obj:GetAttribute("Animation") == "SizeBounce" then
			Animations.sizeBounce(obj)
		elseif obj:GetAttribute("Animation") == "Pendulum" then
			Animations.pendulum(obj)
		end
	end)
end

function Animations.spin(feature)
	local spinTween = TweenService:Create(feature, TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false), {Rotation = 360})
	spinTween:Play()
end

function Animations.sizeBounce(feature: Frame)
	local oldSize = UDim2.fromScale(feature.Size.X.Scale, feature.Size.Y.Scale)
	local newSize = UDim2.fromScale(oldSize.X.Scale * 1.1, oldSize.Y.Scale * 1.1)
	local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true)
	local tween = TweenService:Create(feature, tweenInfo, {Size = newSize})
	tween:Play()
end

function Animations.pendulum(feature: Instance)
	local MAX_ANGLE = 15  
	local SPEED = 5        

	local startTime = os.clock()

	RunService.RenderStepped:Connect(function()
		local t = os.clock() - startTime
		feature.Rotation = math.sin(t * SPEED) * MAX_ANGLE
	end)
end

return Animations
