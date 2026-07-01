local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local CollectionService = game:GetService("CollectionService")

local Animations = require(script.Parent.Animations)

local player: Player = Players.LocalPlayer

local app: ScreenGui = player.PlayerGui:WaitForChild("App")

local Buttons = {}

function Buttons:init()
	for _, button: ImageButton | TextButton in app:GetDescendants() do
		if not button:IsA("ImageButton") and not button:IsA("TextButton") then
			continue
		end

		self:addAnims(button)
	end

	for _, button: ImageButton | TextButton in CollectionService:GetTagged("Button") do
		if not button:IsA("ImageButton") and not button:IsA("TextButton") then
			continue
		end

		self:addAnims(button)
	end

	CollectionService:GetInstanceAddedSignal("Button"):Connect(function(obj: Instance)
		if not obj:IsA("ImageButton") and not obj:IsA("TextButton") then
			return
		end

		self:addAnims(obj)
	end)

	for _, obj in app:GetDescendants() do
		if obj:IsA("GuiObject") then
			local info = obj:FindFirstChild("Info")
			if info and info:IsA("GuiObject") then
				self:setupInfoHover(obj, info)
			end
		end
	end

	app.DescendantAdded:Connect(function(obj: Instance)
		if obj:IsA("GuiObject") then
			local info = obj:FindFirstChild("Info")
			if info and info:IsA("GuiObject") then
				self:setupInfoHover(obj, info)
			end
		end
	end)
end

function Buttons:setupInfoHover(obj: GuiObject, info: GuiObject)
	info.Visible = false

	obj.MouseEnter:Connect(function()
		info.Visible = true
	end)

	obj.MouseLeave:Connect(function()
		info.Visible = false
	end)
end

function Buttons:addAnims(button: ImageButton | TextButton)
	local originalSize = button.Size
	local hoverSize = UDim2.fromScale(
		originalSize.X.Scale * 1.05,
		originalSize.Y.Scale * 1.05
	)
	local pressedSize = UDim2.fromScale(
		originalSize.X.Scale * 0.95,
		originalSize.Y.Scale * 0.95
	)

	button.MouseEnter:Connect(function()
		SoundService:PlayLocalSound(SoundService.UI.Hover)
		button:TweenSize(
			hoverSize,
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Back,
			0.1,
			true
		)
	end)

	button.MouseLeave:Connect(function()
		button:TweenSize(
			originalSize,
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Back,
			0.1,
			true
		)
	end)

	button.MouseButton1Down:Connect(function()
		button:TweenSize(
			pressedSize,
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Back,
			0.1,
			true
		)
	end)

	button.MouseButton1Up:Connect(function()
		SoundService:PlayLocalSound(SoundService.UI.Click)
		button:TweenSize(
			hoverSize,
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Back,
			0.1,
			true
		)
	end)
end

return Buttons
