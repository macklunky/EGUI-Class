local InputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Signal = loadstring(game:HttpGet("https://gist.githubusercontent.com/stravant/b75a322e0919d60dde8a0316d1f09d2f/raw/4961e32d9dd157d83bd7fdeae765650e107f302e/GoodSignal.lua"))()

local function FlipTransparency(num)
	return 1 - num
end


local EButton = {}

EButton.new = function(parent)
	local EButton = {
		_properties = {
			Visible = {
				Value = true
			},
			BackgroundTransparency = {
				Value = 0
			},
			ZIndex = {
				Value = 1
			},
			Size = {
				Value = Vector2.new(100, 100)
			},
			Parent = {
				Value = nil
			},
			BorderTransparency = {
				Value = 0
			},
			BackgroundColor = {
				Value = Color3.fromRGB(255, 255, 255)
			},
			BorderColor = {
				Value = Color3.fromRGB(0, 0, 0)
			},
			BorderSize = {
				Value = 1
			},
			Position = {
				Value = Vector2.new(0, 0)
			},
			ClassName = {
				Value = "EButton"
			},
			Name = {
				Value = "Button"
			}
		},
		_methods = {},
		_events = {},
		_connections = {},
		_children = {},
		_elements = {},
		_rendered = false,
		_absolutePosition = Vector2.new(0, 0),
		_EGUITAG = true,
		_mouseOver = false,
		_destroyed = false
	}

	EButton.FindFirstChild = function(tab, name)
		if not tab then
			error("Expected ':' not '.' calling member function FindFirstChild", 2)
		end
		if not name then
			error("Argument 1 missing or nil", 2)
		end
		if typeof(name) ~= "string" and typeof(name) ~= "number" then
			error("Unable to cast " .. typeof(name) .. " to string", 2)
		end
		name = tostring(name)
		
		if EButton._destroyed == false then
			for index = 1, #EButton._children do
				local child = EButton._children[index]
				if child.Name == name then
					return child
				end
			end
		end
		
		return nil
	end

	EButton.GetChildren = function(tab)
		if not tab then
			error("Expected ':' not '.' calling member function GetChildren", 2)
		end
		if EButton._destroyed == false then
			local children = {}
			for index, child in next, EButton._children do
				children[index] = child
			end
			return children
		end
	end

	EButton.Destroy = function(tab)
		if not tab then
			error("Expected ':' not '.' calling member function Destroy", 2)
		end
		
		if tab.Parent then
			for index = 1, #tab.Parent._children do
				if tab.Parent._children[index] == tab then
					table.remove(tab.Parent._children, index)
				end
			end
		end
		
		--tab.Parent.ChildRemoving:Fire(tab)
		
		tab:_destroy()
	end
	
	EButton._renderUpdate = function()
		if EButton.Parent.ClassName == "EGUI" then
			EButton._absolutePosition = EButton.Position
		else
			EButton._absolutePosition = EButton.Parent._absolutePosition + EButton.Position
		end
		
		EButton._elements.background.Size = EButton.Size
		EButton._elements.background.Position = EButton._absolutePosition
		EButton._elements.background.Color = EButton.BackgroundColor
		EButton._elements.background.Transparency = FlipTransparency(EButton.BackgroundTransparency)
		EButton._elements.background.ZIndex = EButton.ZIndex
		
		EButton._elements.border.Size = EButton.Size + Vector2.new(EButton.BorderSize, EButton.BorderSize)
		EButton._elements.border.Position = EButton._absolutePosition - (Vector2.new(EButton.BorderSize, EButton.BorderSize) / 2)
		EButton._elements.border.Color = EButton.BorderColor
		EButton._elements.border.Transparency = FlipTransparency(EButton.BorderTransparency)
		EButton._elements.border.Thickness = EButton.BorderSize
		EButton._elements.border.ZIndex = EButton.ZIndex
		
		local canRender = false
		if EButton.Parent.ClassName == "EGUI" then
			canRender = EButton.Parent.Enabled
		else
			canRender = EButton.Parent._rendered
		end
		EButton._rendered = canRender and EButton.Visible or false
		EButton._elements.background.Visible = EButton._rendered
		EButton._elements.border.Visible = EButton._rendered
		if EButton._rendered == false then
			EButton._mouseOver = false
		end
		for index, child in next, EButton._children do
			child:_renderUpdate()
		end
	end
	
	EButton._destroy = function(tab)
		for event, signal in next, tab._events do
			signal:DisconnectAll()
		end
		
		for index, element in next, tab._elements do
			element:Remove()
		end
		
		tab._elements = {}
		
		for index, child in next, tab._children do
			child:_destroy()
		end

		tab._children = {}

		tab._destroyed = true
	end
	
	EButton._events.MouseEnter = Signal.new()
	EButton._events.MouseLeave = Signal.new()
	EButton._events.Mouse1Down = Signal.new()
	EButton._events.Mouse1Up = Signal.new()
	EButton._events.Mouse2Down = Signal.new()
	EButton._events.Mouse2Up = Signal.new()
	EButton._events.Mouse3Down = Signal.new()
	EButton._events.Mouse3Up = Signal.new()
	EButton._events.MouseWheelForward = Signal.new()
	EButton._events.MouseWheelBackward = Signal.new()
	
	local background = Drawing.new("Square")
	background.Position = Vector2.new(0, 0)
	background.Size = Vector2.new(200, 50)
	background.Filled = true
	background.Transparency = FlipTransparency(EButton._properties.BackgroundTransparency.Value)
	background.Thickness = 0
	background.Color = Color3.fromRGB(255, 255, 255)
	background.ZIndex = 1
	background.Visible = false
	EButton._elements.background = background

	local border = Drawing.new("Square")
	border.Position = Vector2.new(-0.5, -0.5)
	border.Size = Vector2.new(201, 51)
	border.Filled = false
	border.Transparency = FlipTransparency(EButton._properties.BorderTransparency.Value)
	border.Thickness = 1
	border.Color = Color3.fromRGB(0, 0, 0)
	border.ZIndex = 1
	border.Visible = false
	EButton._elements.border = border
	
	setmetatable(EButton, {
		__index = function(tab, index)
			if typeof(index) ~= "string" and typeof(index) ~= "number" then
				error(index .. " is not a valid member of EButton", 2)
			end
			if tab._events[index] ~= nil then
				return tab._events[index]
			elseif tab._properties[index] ~= nil then
				return tab._properties[index].Value
			elseif tab._methods[index] ~= nil then
				return tab._methods[index]
			elseif tab:FindFirstChild(index) then
				return tab:FindFirstChild(index)
			end
		end,

		__newindex = function(tab, index, value)
			if index == "Parent" and value ~= nil then
				if typeof(value) ~= "table" or typeof(value) == "table" and value._EGUITAG == nil then
					error("Attempt to assign invalid object as Parent", 2)
				end
				tab._properties.Parent.Value = value
				table.insert(value._children, tab)
				--value.ChildAdded:Fire(tab)
			elseif index == "Parent" and value == nil then
				for index = 1, #tab.Parent._children do
					if tab.Parent._children[index] == tab then
						table.remove(tab.Parent._children, index)
					end
				end
			elseif tab._properties[index] then
				tab._properties[index].Value = value
			end
		end,
	})
	
	if parent then
		EButton.Parent = parent
	end
	
	return EButton
end

return EButton
