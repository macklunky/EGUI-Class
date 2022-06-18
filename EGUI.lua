local InputService = game:GetService("UserInputService")
local Signal = loadstring(game:HttpGet("https://gist.githubusercontent.com/stravant/b75a322e0919d60dde8a0316d1f09d2f/raw/4961e32d9dd157d83bd7fdeae765650e107f302e/GoodSignal.lua"))()

local layers = {}
local drawings = {}

local function FlipTransparency(num)
	return 1 - num
end

local function AddToLayer(drawing)
	local layer = drawing.ZIndex
	
	if not layers[layer] then
		layers[layer] = {}
	end
	
	table.insert(layers[layer], drawing)
end

local function UpdateLayer(drawing, prevLayer)
	for index = 1, #layers[prevLayer] do
		local value = layers[prevLayer][index]
		if value == drawing  then
			table.remove(layers[prevLayer], index)
			break
		end
	end
	
	if not layers[drawing.ZIndex] then
		layers[drawing.ZIndex] = {}
	end
	
	table.insert(layers[drawing.ZIndex], drawing)
end

local function RemoveFromLayer(drawing)
	for index = 1, #layers[drawing.ZIndex] do
		local value = layers[drawing.ZIndex][index]
		if value == drawing then
			table.remove(layers[drawing.ZIndex], index)
			break
		end
	end
end

local function InBounds(pos, boundsPos, boundsSize)
	local X = (pos.X >= boundsPos.X and pos.X <= (boundsPos.X + boundsSize.X))
	local Y = (pos.Y >= boundsPos.Y and pos.Y <= (boundsPos.Y + boundsSize.Y))
	return X and Y
end

local EGUI = {}

EGUI.CreateSquare = function(self, args)
	if not self then
		error("Expected ':' not '.' calling member function CreateSquare", 2)
	end
	
	local drawing = Drawing.new("Square")
	drawing.Size = typeof(args.Size) == "Vector2" and args.Size or Vector2.new(200, 50)
	drawing.Filled = true
	drawing.Thickness = 0
	drawing.Transparency = FlipTransparency(typeof(args.Transparency) == "number" and args.Transparency or 0)
	drawing.Color = typeof(args.Color) == "Color3" and args.Color or Color3.fromRGB(255, 255, 255)
	drawing.Visible = typeof(args.Visible) == "boolean" and args.Visible or false
	drawing.ZIndex = typeof(args.ZIndex) == "number" and args.ZIndex or 0
	drawing.Position = (typeof(args.Position) == "Vector2" and args.Position or Vector2.new()) - (typeof(args.AnchorPoint) == "Vector2" and args.AnchorPoint or Vector2.new(0, 0)) * drawing.Size

	local Square = {
		_properties = {
			Color = drawing.Color,
			Position = args.Position,
			Size = drawing.Size,
			ZIndex = drawing.ZIndex,
			Visible = drawing.Visible,
			CaptureInput = typeof(args.CaptureInput) == "boolean" and args.CaptureInput or false,
			AnchorPoint = typeof(args.AnchorPoint) == "Vector2" and args.AnchorPoint or Vector2.new(0, 0)
		},
		_internal = {
			Drawing = drawing,
			Type = "Square",
			_destroyed = false
		},
		_events = {
			MouseButton1Down = Signal.new(),
			MouseButton1Up = Signal.new(),
			MouseEnter = Signal.new(),
			MouseMoved = Signal.new(),
			MouseLeave = Signal.new(),
			Changed = Signal.new()
		}
	}

	Square.Destroy = function(self)
		if not self then
			error("Expected ':' not '.' calling member function Destroy", 2)
		end

		if self._internal._destroyed then return nil end
		
		RemoveFromLayer(self)
		for index = 1, #drawings do
			local drawing = drawings[index]
			if drawing == self then
				table.remove(drawings, index)
				break
			end
		end
		
		for index, event in next, self._events do
			event:DisconnectAll()
		end
		self._events = {}
		
		self._internal.Drawing:Remove()
		self._internal.Drawing = nil
	end

	setmetatable(Square, {
		__index = function(self, index)
			if self._properties[index] ~= nil then
				return self._properties[index]
			elseif self._events[index] ~= nil and not self._internal._destroyed then
				return self._events[index]
			else
				error(index .. " is not a valid member of Square", 2)
			end
		end,

		__newindex = function(self, index, value)
			if self._internal._destroyed then return nil end

			if index == "Position" then
				if typeof(value) ~= "Vector2" then
					error("Unable to assign property " .. index .. ". Vector2 expected, got "  .. typeof(value), 2)
				end
				self._internal.Drawing.Position = value - (self.Size * self.AnchorPoint)
				local prev = self[index]
				self._properties.Position = value
				self.Changed:Fire(index, prev)
			elseif index == "Size" then
				if typeof(value) ~= "Vector2" then
					error("Unable to assign property " .. index .. ". Vector2 expected, got "  .. typeof(value), 2)
				end
				self._internal.Drawing.Size = value
				self._internal.Drawing.Position = self.Position - (value * self.AnchorPoint)
				local prev = self[index]
				self._properties.Size = value
				self.Changed:Fire(index, prev)
			elseif index == "ZIndex" then
				if typeof(value) ~= "number" then
					error("Unable to assign property " .. index .. ". number expected, got "  .. typeof(value), 2)
				end
				self._internal.Drawing.ZIndex = value
				local prev = self[index]
				self._properties.ZIndex = value
				self.Changed:Fire(index, prev)
			elseif index == "CaptureInput" then
				if typeof(value) ~= "boolean" then
					error("Unable to assign property " .. index .. ". boolean expected, got "  .. typeof(value), 2)
				end
				local prev = self.CaptureInput
				self._properties.CaptureInput = value
				self.Changed:Fire(index, prev)
			elseif index == "Color" then
				if typeof(value) ~= "Color3" then
					error("Unable to assign property " .. index .. ". Color3 expected, got "  .. typeof(value), 2)
				end
				
				self._internal.Drawing.Color = value
				local prev = self[index]
				self._properties.Color = value
				self.Changed:Fire(index, prev)
			elseif index == "Visible" then
				if typeof(value) ~= "boolean" then
					error("Unable to assign property " .. index .. ". boolean expected, got "  .. typeof(value), 2)
				end
				
				self._internal.Drawing.Visible = value
				local prev = self[index]
				self._properties.Visible = value
				self.Changed:Fire(index, prev)
			elseif index == "Transparency" then
				if typeof(value) ~= "number" then
					error("Unable to assign property " .. index .. ". number expected, got "  .. typeof(value), 2)
				end
				self._internal.Transparency = FlipTransparency(math.clamp(value, 0, 1))
				local prev = self[index]
				self._properties.Transparency = math.clamp(value, 0, 1)
				self.Changed:Fire(index, prev)
			elseif index == "AnchorPoint" then
				if typeof(value) ~= "Vector2" then
					error("Unable to assign property " .. index .. ". Vector2 expected, got "  .. typeof(value), 2)
				end
				
				self._internal.Drawing.Position = self.Position - (self.Size * value)
				local prev = self[index]
				self._properties.AnchorPoint = value
				self.Changed:Fire(index, prev)
			elseif self._properties[index] then
				local prev = self[index]
				self._properties[index] = value
				self.Changed:Fire(index, prev)
			else
				error(index .. " is not a valid member of Square", 2)
			end
		end,
	})
	
	AddToLayer(Square)
	
	Square.Changed:Connect(function(property, prev)
		if property == "ZIndex" then
			UpdateLayer(Square, prev)
		end
	end)
	
	table.insert(drawings, Square)
	
	return Square
end

EGUI.CreateText = function(self, args)
	if not self then
		error("Expected ':' not '.' calling member function CreateText", 2)
	end
	
	local drawing = Drawing.new("Text")
	drawing.Size = typeof(args.TextSize) == "number" and args.TextSize or 20
	drawing.Text = typeof(args.Text) == "string" and args.Text or "Label"
	drawing.Color = typeof(args.TextColor) == "Color3" and args.TextColor or Color3.fromRGB(0, 0, 0)
	drawing.Center = false
	drawing.Font = typeof(args.Font) == "number" and args.Font or Drawing.Fonts.Plex
	drawing.Position = (typeof(args.Position) == "Vector2" and args.Position or Vector2.new()) - (typeof(args.AnchorPoint) == "Vector2" and args.AnchorPoint or Vector2.new(0, 0)) * drawing.TextBounds
	drawing.Visible = typeof(args.Visible) == "boolean" and args.Visible or false
	drawing.ZIndex = typeof(args.ZIndex) == "number" and args.ZIndex or 0

	local Text = {
		_properties = {
			Text = drawing.Text,
			TextColor = drawing.Color,
			Position = args.Position,
			TextSize = drawing.Size,
			TextBounds = drawing.TextBounds,
			ZIndex = drawing.ZIndex,
			Visible = drawing.Visible,
			CaptureInput = typeof(args.CaptureInput) == "boolean" and args.CaptureInput or false,
			AnchorPoint = typeof(args.AnchorPoint) == "Vector2" and args.AnchorPoint or Vector2.new(0, 0)
		},
		_internal = {
			Drawing = drawing,
			Type = "Text",
			_destroyed = false
		},
		_events = {
			MouseButton1Down = Signal.new(),
			MouseButton1Up = Signal.new(),
			MouseEnter = Signal.new(),
			MouseMoved = Signal.new(),
			MouseLeave = Signal.new(),
			Changed = Signal.new()
		}
	}

	Text.Destroy = function(self)
		if not self then
			error("Expected ':' not '.' calling member function Destroy", 2)
		end

		if self._internal._destroyed then return nil end
		RemoveFromLayer(self)
		for index = 1, #drawings do
			local drawing = drawings[index]
			if drawing == self then
				table.remove(drawings, index)
				break
			end
		end

		for index, event in next, self._events do
			event:DisconnectAll()
		end
		self._events = {}

		self._internal.Drawing:Remove()
		self._internal.Drawing = nil
	end
	
	setmetatable(Text, {
		__index = function(self, index)
			if self._properties[index] ~= nil then
				return self._properties[index]
			elseif self._events[index] ~= nil and not self._internal._destroyed then
				return self._events[index]
			else
				error(index .. " is not a valid member of Text", 2)
			end
		end,

		__newindex = function(self, index, value)
			if self._internal._destroyed then return nil end

			if index == "Position" then
				if typeof(value) ~= "Vector2" then
					error("Unable to assign property " .. index .. ". Vector2 expected, got "  .. typeof(value), 2)
				end
				self._internal.Drawing.Position = value - (self.TextBounds * self.AnchorPoint)
				local prev = self[index]
				self._properties.Position = value
				self.Changed:Fire(index, prev)
			elseif index == "TextSize" then
				if typeof(value) ~= "number" then
					error("Unable to assign property " .. index .. ". number expected, got "  .. typeof(value), 2)
				end
				self._internal.Drawing.Size = value
				self._internal.Drawing.Position = self.Position - (self._internal.Drawing.TextBounds * self.AnchorPoint)
				local prevSize = self.TextSize
				local prevBounds = self.TextBounds
				self._properties.TextBounds = self._internal.Drawing.TextBounds
				self.Changed:Fire("TextBounds", prevBounds)
				self._properties.Size = value
				self.Changed:Fire(index, prevSize)
			elseif index == "ZIndex" then
				if typeof(value) ~= "number" then
					error("Unable to assign property " .. index .. ". number expected, got "  .. typeof(value), 2)
				end
				self._internal.Drawing.ZIndex = value
				local prev = self[index]
				self._properties.ZIndex = value
				self.Changed:Fire(index, prev)
			elseif index == "CaptureInput" then
				if typeof(value) ~= "boolean" then
					error("Unable to assign property " .. index .. ". boolean expected, got "  .. typeof(value), 2)
				end
				local prev = self[index]
				self._properties.CaptureInput = value
				self.Changed:Fire(index, prev)
			elseif index == "TextColor" then
				if typeof(value) ~= "Color3" then
					error("Unable to assign property " .. index .. ". Color3 expected, got "  .. typeof(value), 2)
				end

				self._internal.Drawing.Color = value
				local prev = self[index]
				self._properties.Color = value
				self.Changed:Fire(index, prev)
			elseif index == "Visible" then
				if typeof(value) ~= "boolean" then
					error("Unable to assign property " .. index .. ". boolean expected, got "  .. typeof(value), 2)
				end

				self._internal.Drawing.Visible = value
				local prev = self[index]
				self._properties.Visible = value
				self.Changed:Fire(index, prev)
			elseif index == "Transparency" then
				if typeof(value) ~= "number" then
					error("Unable to assign property " .. index .. ". number expected, got "  .. typeof(value), 2)
				end
				self._internal.Transparency = FlipTransparency(math.clamp(value, 0, 1))
				local prev = self[index]
				self._properties.Transparency = math.clamp(value, 0, 1)
				self.Changed:Fire(index, prev)
			elseif index == "AnchorPoint" then
				if typeof(value) ~= "Vector2" then
					error("Unable to assign property " .. index .. ". Vector2 expected, got "  .. typeof(value), 2)
				end

				self._internal.Drawing.Position = self.Position - (self.TextBounds * value)
				local prev = self[index]
				self._properties.AnchorPoint = value
				self.Changed:Fire(index, prev)
			elseif index == "Text" then
				if typeof(value) ~= "string" then
					error("Unable to assign property " .. index .. ". string expected, got "  .. typeof(value), 2)
				end
				self._internal.Drawing.Text = value
				self._internal.Drawing.Position = self.Position - (self._internal.Drawing.TextBounds * self.AnchorPoint)
				local prevBounds = self.TextBounds
				local prevText = self.Text
				self._properties.TextBounds = self._internal.Drawing.TextBounds
				self.Changed:Fire("TextBounds", prevBounds)
				self._properties.Text = value
				self.Changed:Fire(index, prevText)
			elseif index == "Font" then
				if typeof(value) ~= "number" then
					error("Unable to assign property " .. index .. ". number expected, got "  .. typeof(value), 2)
				end
				self._internal.Drawing.Font = math.clamp(value, 0, 3)
				self._internal.Drawing.Position = self.Position - (self._internal.Drawing.TextBounds * self.AnchorPoint)
				local prevBounds = self.TextBounds
				local prevFont = self.Font
				self._properties.TextBounds = self._internal.Drawing.TextBounds
				self.Changed:Fire("TextBounds", prevBounds)
				self._properties.Font = math.clamp(value, 0, 3)
				self.Changed:Fire(index, prevFont)
			elseif self._properties[index] then
				local prev = self[index]
				self._properties[index] = value
				self.Changed:Fire(index, prev)
			else
				error(index .. " is not a valid member of Text", 2)
			end
		end,
	})
	
	AddToLayer(Text)

	Text.Changed:Connect(function(property, prev)
		if property == "ZIndex" then
			UpdateLayer(Text, prev)
		end
	end)

	table.insert(drawings, Text)

	return Text
end

InputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local clickPos = Vector2.new(input.Position.X, input.Position.Y + 36)
		
		local topmostDrawings = {}
		local topmostZIndex = -math.huge
		for index, drawing in next, drawings do
			if drawing._internal.Type == "Text" then
				if InBounds(clickPos, drawing._internal.Drawing.Position, drawing.TextBounds) and drawing.Visible and drawing.CaptureInput then
					if drawing.ZIndex == topmostZIndex then
						table.insert(topmostDrawings, drawing)
					elseif drawing.ZIndex > topmostZIndex then
						topmostDrawings = {}
						table.insert(topmostDrawings, drawing)
						topmostZIndex = drawing.ZIndex
					end
				end
			else
				if InBounds(clickPos, drawing._internal.Drawing.Position, drawing.Size) and drawing.Visible and drawing.CaptureInput then
					if drawing.ZIndex == topmostZIndex then
						table.insert(topmostDrawings, drawing)
					elseif drawing.ZIndex > topmostZIndex then
						topmostDrawings = {}
						table.insert(topmostDrawings, drawing)
						topmostZIndex = drawing.ZIndex
					end
				end
			end
		end
		
		if #topmostDrawings > 0 then
			for index = #layers[topmostZIndex], 1, -1 do
				local drawing = layers[topmostZIndex][index]
				local indexFound = table.find(topmostDrawings, drawing)
				if indexFound then
					drawing.MouseButton1Down:Fire(clickPos)
					break
				end
			end
		end
	end
end)

InputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local clickPos = Vector2.new(input.Position.X, input.Position.Y + 36)

		local topmostDrawings = {}
		local topmostZIndex = -math.huge
		for index, drawing in next, drawings do
			if drawing._internal.Type == "Text" then
				if InBounds(clickPos, drawing._internal.Drawing.Position, drawing.TextBounds) and drawing.Visible and drawing.CaptureInput then
					if drawing.ZIndex == topmostZIndex then
						table.insert(topmostDrawings, drawing)
					elseif drawing.ZIndex > topmostZIndex then
						topmostDrawings = {}
						table.insert(topmostDrawings, drawing)
						topmostZIndex = drawing.ZIndex
					end
				end
			else
				if InBounds(clickPos, drawing._internal.Drawing.Position, drawing.Size) and drawing.Visible and drawing.CaptureInput then
					if drawing.ZIndex == topmostZIndex then
						table.insert(topmostDrawings, drawing)
					elseif drawing.ZIndex > topmostZIndex then
						topmostDrawings = {}
						table.insert(topmostDrawings, drawing)
						topmostZIndex = drawing.ZIndex
					end
				end
			end
		end

		if #topmostDrawings > 0 then
			for index = #layers[topmostZIndex], 1, -1 do
				local drawing = layers[topmostZIndex][index]
				local indexFound = table.find(topmostDrawings, drawing)
				if indexFound then
					drawing.MouseButton1Up:Fire(clickPos)
					break
				end
			end
		end
	end
end)

task.spawn(function()
	local drawingsMousedOver = {}
	local lastMousePos = InputService:GetMouseLocation()
	while task.wait() do
		local mousePos = InputService:GetMouseLocation()

		for index = #drawingsMousedOver, 1, -1 do
			local drawing = drawingsMousedOver[index]
			
			if drawing._internal._destroyed then
				table.remove(drawingsMousedOver, index)
				continue
			end
			
			if drawing._internal.Type == "Text" then
				local mousedOver = InBounds(mousePos, drawing._internal.Drawing.Position, drawing.TextBounds)
				if mousedOver and mousePos ~= lastMousePos then
					drawing.MouseMoved:Fire(mousePos)
				elseif not mousedOver then
					drawing.MouseLeave:Fire(mousePos)
					table.remove(drawingsMousedOver, index)
				end
			else
				local mousedOver = InBounds(mousePos, drawing._internal.Drawing.Position, drawing.Size)
				if mousedOver and mousePos ~= lastMousePos then
					drawing.MouseMoved:Fire(mousePos)
				elseif not mousedOver then
					drawing.MouseLeave:Fire(mousePos)
					table.remove(drawingsMousedOver, index)
				end
			end
		end

		for index, drawing in next, drawings do
			if drawing._internal._destroyed then
				continue
			end
			
			if drawing._internal.Type == "Text" then
				local mousedOver = InBounds(mousePos, drawing._internal.Drawing.Position, drawing.TextBounds)
				
				if mousedOver and not table.find(drawingsMousedOver, drawing) then
					drawing.MouseEnter:Fire(mousePos)
					table.insert(drawingsMousedOver, drawing)
				end
			else
				local mousedOver = InBounds(mousePos, drawing._internal.Drawing.Position, drawing.Size)
				
				if mousedOver and not table.find(drawingsMousedOver, drawing) then
					drawing.MouseEnter:Fire(mousePos)
					table.insert(drawingsMousedOver, drawing)
				end
			end
		end
		lastMousePos = mousePos
	end
end)

return EGUI
