local InputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Signal = loadstring(game:HttpGet("https://gist.githubusercontent.com/stravant/b75a322e0919d60dde8a0316d1f09d2f/raw/4961e32d9dd157d83bd7fdeae765650e107f302e/GoodSignal.lua"))()

local function FlipTransparency(num)
	return 1 - num
end


local EText = {}

EText.new = function(parent)
	local EText = {
		_properties = {
			Visible = {
				Value = true
			},
			TextTransparency = {
				Value = 0
			},
			ZIndex = {
				Value = 1
			},
			TextSize = {
				Value = 14
			},
			Parent = {
				Value = nil
			},
			Font = {
				Value = 0
			},
			TextColor = {
				Value = Color3.fromRGB(0, 0, 0)
			},
			OutlineColor = {
				Value = Color3.fromRGB(255, 255, 255)
			},
			Center = {
				Value = false
			},
			Position = {
				Value = Vector2.new(0, 0)
			},
			ClassName = {
				Value = "EText"
			},
			Name = {
				Value = "Text"
			},
			Text = {
				Value = "Text"
			},
			Outline = {
				Value = false
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

	EText.FindFirstChild = function(tab, name)
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
		
		if EText._destroyed == false then
			for index = 1, #EText._children do
				local child = EText._children[index]
				if child.Name == name then
					return child
				end
			end
		end
		
		return nil
	end

	EText.GetChildren = function(tab)
		if not tab then
			error("Expected ':' not '.' calling member function GetChildren", 2)
		end
		if EText._destroyed == false then
			local children = {}
			for index, child in next, EText._children do
				children[index] = child
			end
			return children
		end
	end

	EText.Destroy = function(tab)
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
	
	EText._renderUpdate = function()
		if EText.Parent.ClassName == "EGUI" then
			EText._absolutePosition = EText.Position
		else
			EText._absolutePosition = EText.Parent._absolutePosition + EText.Position
		end
		
		EText._elements.text.Size = EText.TextSize
		EText._elements.text.Outline = EText.Outline
		EText._elements.text.Center = EText.Center
		EText._elements.text.Text = EText.Text
		EText._elements.text.Font = EText.Font
		EText._elements.text.Position = EText._absolutePosition
		EText._elements.text.Color = EText.TextColor
		EText._elements.text.OutlineColor = EText.OutlineColor
		EText._elements.text.Transparency = FlipTransparency(EText.TextTransparency)
		EText._elements.text.ZIndex = EText.ZIndex
		
		local canRender = false
		if EText.Parent.ClassName == "EGUI" then
			canRender = EText.Parent.Enabled
		else
			canRender = EText.Parent._rendered
		end
		EText._rendered = canRender and EText.Visible or false
		EText._elements.text.Visible = EText._rendered
		if EText._rendered == false then
			EText._mouseOver = false
		end
		for index, child in next, EText._children do
			child:_renderUpdate()
		end
	end
	
	EText._destroy = function(tab)
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
	
	EText._events.MouseEnter = Signal.new()
	EText._events.MouseLeave = Signal.new()
	EText._events.Mouse1Down = Signal.new()
	EText._events.Mouse1Up = Signal.new()
	EText._events.Mouse2Down = Signal.new()
	EText._events.Mouse2Up = Signal.new()
	EText._events.Mouse3Down = Signal.new()
	EText._events.Mouse3Up = Signal.new()
	EText._events.MouseWheelForward = Signal.new()
	EText._events.MouseWheelBackward = Signal.new()
	
	local text = Drawing.new("Text")
	text.Position = Vector2.new(0, 0)
	text.Size = 14
	text.Transparency = FlipTransparency(EText._properties.TextTransparency.Value)
	text.Color = Color3.fromRGB(255, 255, 255)
	text.ZIndex = 1
	text.Visible = false
	text.Font = Drawing.Fonts.UI
	EText._elements.text = text
	
	setmetatable(EText, {
		__index = function(tab, index)
			if typeof(index) ~= "string" and typeof(index) ~= "number" then
				error(index .. " is not a valid member of EText", 2)
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
		EText.Parent = parent
	end
	
	return EText
end

return EText
