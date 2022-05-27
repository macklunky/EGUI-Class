local InputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Signal = loadstring(game:HttpGet("https://gist.githubusercontent.com/stravant/b75a322e0919d60dde8a0316d1f09d2f/raw/4961e32d9dd157d83bd7fdeae765650e107f302e/GoodSignal.lua"))()

local function FlipTransparency(num)
	return 1 - num
end

local EGUI = {}

EGUI.new = function()
	local EGUI = {
		_properties = {
			Enabled = {
				Value = true
			},
			ClassName = {
				Value = "EGUI"
			}
		},
		_methods = {},
		_events = {},
		_connections = {},
		_children = {},
		_EGUITAG = true,
		_destroyed = false
	}

	EGUI.FindFirstChild = function(tab, name)
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
		
		if EGUI._destroyed == false then
			for index = 1, #EGUI._children do
				local child = EGUI._children[index]
				if child.Name == name then
					return child
				end
			end
		end
		
		return nil
	end

	EGUI.GetChildren = function(tab, name)
		if not tab then
			error("Expected ':' not '.' calling member function GetChildren", 2)
		end
		if EGUI._destroyed == false then--rawget(EGUI, "_destroyed") == false then
			local children = {}
			for index, child in next, EGUI._children do
				children[index] = child
			end
			return children
		end
	end

	EGUI.Destroy = function(tab)
		if not tab then
			error("Expected ':' not '.' calling member function Destroy", 2)
		end
		
		for event, signal in next, tab._events do
			signal:DisconnectAll()
		end
		
		for index, child in next, tab._children do
			child:_destroy()
		end

		tab._children = {}

		tab._destroyed = true
	end

	setmetatable(EGUI, {
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
			if typeof(index) ~= "string" and typeof(index) ~= "number" then
				error(index .. " is not a valid member of EFrame", 2)
			end
			if tab._properties[index] then
				tab._properties[index].Value = value
			else
				error(index .. " is not a valid member of EFrame", 2)
			end
		end,
	})

	task.spawn(function()
		local lastMousePosition = InputService:GetMouseLocation()
		while EGUI._destroyed == false do--rawget(EGUI, "_destroyed") == false do
			--update gui mouseenter mouseleave mousemove events
			for index, child in next, EGUI._children do
				if child._destroyed == false then
					child:_renderUpdate()
				end
			end
			local newMousePosition = InputService:GetMouseLocation()
			if newMousePosition ~= lastMousePosition then
				
				
				--do stuff
				--update gui rendering
				
				
				lastMousePosition = newMousePosition
			end
			RunService.RenderStepped:Wait()
		end
	end)

	local changedConnection
	changedConnection = InputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			--update gui scroll events with input.Position
		end
	end)

	local beganConnection
	beganConnection = InputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			--update mouse1down events with input.Position
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			--update mouse2down events with input.Position
		elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
			--update mouse3down events with input.Position
		end
	end)

	local endedConnection
	endedConnection = InputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			--update mouse1up events with input.Position
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			--update mouse2up events with input.Position
		elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
			--update mouse3up events with input.Position
		end
	end)
	
	return EGUI
end

return EGUI
