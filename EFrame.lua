local InputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Signal = loadstring(game:HttpGet("https://gist.githubusercontent.com/stravant/b75a322e0919d60dde8a0316d1f09d2f/raw/4961e32d9dd157d83bd7fdeae765650e107f302e/GoodSignal.lua"))()

local function FlipTransparency(num)
	return 1 - num
end


local EFrame = {}

EFrame.new = function(parent)
	local EFrame = {
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
				Value = "EFrame"
			},
			Name = {
				Value = "Frame"
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

	EFrame.FindFirstChild = function(tab, name)
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
		
		if EFrame._destroyed == false then
			for index = 1, #EFrame._children do
				local child = EFrame._children[index]
				if child.Name == name then
					return child
				end
			end
		end
		
		return nil
	end

	EFrame.GetChildren = function(tab)
		if not tab then
			error("Expected ':' not '.' calling member function GetChildren", 2)
		end
		if EFrame._destroyed == false then
			local children = {}
			for index, child in next, EFrame._children do
				children[index] = child
			end
			return children
		end
	end

	EFrame.Destroy = function(tab)
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
	
	EFrame._renderUpdate = function()
		if EFrame.Parent.ClassName == "EGUI" then
			EFrame._absolutePosition = EFrame.Position
		else
			EFrame._absolutePosition = EFrame.Parent._absolutePosition + EFrame.Position
		end
		
		EFrame._elements.background.Size = EFrame.Size
		EFrame._elements.background.Position = EFrame._absolutePosition
		EFrame._elements.background.Color = EFrame.BackgroundColor
		EFrame._elements.background.Transparency = FlipTransparency(EFrame.BackgroundTransparency)
		EFrame._elements.background.ZIndex = EFrame.ZIndex
		
		EFrame._elements.border.Size = EFrame.Size + Vector2.new(EFrame.BorderSize, EFrame.BorderSize)
		EFrame._elements.border.Position = EFrame._absolutePosition - (Vector2.new(EFrame.BorderSize, EFrame.BorderSize) / 2)
		EFrame._elements.border.Color = EFrame.BorderColor
		EFrame._elements.border.Transparency = FlipTransparency(EFrame.BorderTransparency)
		EFrame._elements.border.Thickness = EFrame.BorderSize
		EFrame._elements.border.ZIndex = EFrame.ZIndex
		
		local canRender = false
		if EFrame.Parent.ClassName == "EGUI" then
			canRender = EFrame.Parent.Enabled
		else
			canRender = EFrame.Parent._rendered
		end
		EFrame._rendered = canRender and EFrame.Visible or false
		EFrame._elements.background.Visible = EFrame._rendered
		EFrame._elements.border.Visible = EFrame._rendered
		if EFrame._rendered == false then
			EFrame._mouseOver = false
		end
		for index, child in next, EFrame._children do
			child:_renderUpdate()
		end
	end
	
	EFrame._destroy = function(tab)
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
	
	EFrame._events.MouseEnter = Signal.new()
	EFrame._events.MouseLeave = Signal.new()
	EFrame._events.Mouse1Down = Signal.new()
	EFrame._events.Mouse1Up = Signal.new()
	EFrame._events.Mouse2Down = Signal.new()
	EFrame._events.Mouse2Up = Signal.new()
	EFrame._events.Mouse3Down = Signal.new()
	EFrame._events.Mouse3Up = Signal.new()
	EFrame._events.MouseWheelForward = Signal.new()
	EFrame._events.MouseWheelBackward = Signal.new()
	
	local background = Drawing.new("Square")
	background.Position = Vector2.new(0, 0)
	background.Size = Vector2.new(100, 100)
	background.Filled = true
	background.Transparency = FlipTransparency(EFrame._properties.BackgroundTransparency.Value)
	background.Thickness = 0
	background.Color = Color3.fromRGB(255, 255, 255)
	background.ZIndex = 1
	background.Visible = false
	EFrame._elements.background = background

	local border = Drawing.new("Square")
	border.Position = Vector2.new(-0.5, -0.5)
	border.Size = Vector2.new(101, 101)
	border.Filled = false
	border.Transparency = FlipTransparency(EFrame._properties.BorderTransparency.Value)
	border.Thickness = 1
	border.Color = Color3.fromRGB(0, 0, 0)
	border.ZIndex = 1
	border.Visible = false
	EFrame._elements.border = border
	
	setmetatable(EFrame, {
		__index = function(tab, index)
			if typeof(index) ~= "string" and typeof(index) ~= "number" then
				error(index .. " is not a valid member of EFrame", 2)
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
		EFrame.Parent = parent
	end
	
	return EFrame
end

return EFrame
