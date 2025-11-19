-- Fixed UI Library
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Library = {Elements = {}}
Library.__index = Library

-- Safe utility functions
local function SafeCreateDrawing(type, properties)
    local success, drawing = pcall(function()
        local draw = Drawing.new(type)
        for prop, value in pairs(properties) do
            if draw[prop] ~= nil then
                draw[prop] = value
            end
        end
        return draw
    end)
    return success and drawing or nil
end

local function SafeMouseOver(position, size)
    local success, result = pcall(function()
        local mouse = UserInputService:GetMouseLocation()
        return mouse.X >= position.X and mouse.X <= position.X + size.X and
               mouse.Y >= position.Y and mouse.Y <= position.Y + size.Y
    end)
    return success and result or false
end

function Library:CreateWindow(config)
    config = config or {}
    local window = {
        Name = config.Name or "UI",
        Size = config.Size or Vector2.new(500, 400),
        Pages = {},
        IsOpen = false,
        Elements = {}
    }
    
    -- Safe drawing creation
    window.MainFrame = SafeCreateDrawing("Square", {
        Color = Color3.new(0, 0, 0),
        Filled = true,
        Size = window.Size,
        Position = Vector2.new(100, 100),
        Visible = false
    })
    
    if window.MainFrame then
        window.InnerFrame = SafeCreateDrawing("Square", {
            Color = Color3.new(0.1, 0.1, 0.1),
            Filled = true,
            Size = window.Size - Vector2.new(4, 4),
            Position = window.MainFrame.Position + Vector2.new(2, 2),
            Visible = false
        })
        
        window.Title = SafeCreateDrawing("Text", {
            Text = window.Name,
            Color = Color3.new(1, 1, 1),
            Size = 13,
            Position = window.InnerFrame.Position + Vector2.new(10, 8),
            Visible = false
        })
    end
    
    -- Fixed toggle function
    function window:Toggle()
        self.IsOpen = not self.IsOpen
        if self.MainFrame then
            self.MainFrame.Visible = self.IsOpen
            if self.InnerFrame then self.InnerFrame.Visible = self.IsOpen end
            if self.Title then self.Title.Visible = self.IsOpen end
        end
        
        -- Fixed page visibility update - removed the extra page parameter
        for _, page in pairs(self.Pages) do
            if page and type(page.UpdateVisibility) == "function" then
                pcall(function()
                    page:UpdateVisibility(self.IsOpen)
                end)
            end
        end
    end
    
    -- Input handling with error protection
    local inputConnection
    inputConnection = UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == (config.ToggleKey or Enum.KeyCode.RightShift) then
            pcall(function()
                window:Toggle()
            end)
        end
    end)
    
    -- Store connection for cleanup
    window._connections = {inputConnection}
    
    function window:AddPage(name)
        local page = {
            Name = name,
            Sections = {},
            Window = self
        }
        
        function page:UpdateVisibility(visible)
            -- Safe visibility update for page elements
            for _, section in pairs(self.Sections) do
                if section and section.Elements then
                    for _, element in pairs(section.Elements) do
                        if element and element.drawing then
                            pcall(function()
                                element.drawing.Visible = visible
                            end)
                        end
                    end
                end
            end
        end
        
        function page:AddSection(name)
            local section = {
                Name = name,
                Elements = {}
            }
            
            function section:AddLabel(text)
                local label = {
                    Type = "Label",
                    Text = text,
                    drawing = SafeCreateDrawing("Text", {
                        Text = text,
                        Color = Color3.new(1, 1, 1),
                        Size = 12,
                        Position = Vector2.new(20, 50 + (#self.Elements * 25)),
                        Visible = window.IsOpen
                    })
                }
                table.insert(self.Elements, label)
                return label
            end
            
            function section:AddToggle(config)
                config = config or {}
                local toggle = {
                    Type = "Toggle",
                    Name = config.Name or "Toggle",
                    Value = config.Default or false,
                    Callback = config.Callback or function() end
                }
                
                function toggle:Set(value)
                    self.Value = value
                    pcall(self.Callback, value)
                end
                
                function toggle:Get()
                    return self.Value
                end
                
                table.insert(self.Elements, toggle)
                return toggle
            end
            
            function section:AddButton(config)
                config = config or {}
                local button = {
                    Type = "Button",
                    Name = config.Name or "Button",
                    Callback = config.Callback or function() end
                }
                
                table.insert(self.Elements, button)
                return button
            end
            
            function section:AddSlider(config)
                config = config or {}
                local slider = {
                    Type = "Slider",
                    Name = config.Name or "Slider",
                    Value = config.Default or 50,
                    Min = config.Min or 0,
                    Max = config.Max or 100,
                    Callback = config.Callback or function() end
                }
                
                function slider:Set(value)
                    self.Value = math.clamp(value, self.Min, self.Max)
                    pcall(self.Callback, self.Value)
                end
                
                function slider:Get()
                    return self.Value
                end
                
                table.insert(self.Elements, slider)
                return slider
            end
            
            table.insert(self.Sections, section)
            return section
        end
        
        table.insert(self.Pages, page)
        return page
    end
    
    function window:Destroy()
        -- Safe cleanup
        for _, conn in pairs(self._connections or {}) do
            pcall(function() conn:Disconnect() end)
        end
        
        local drawings = {self.MainFrame, self.InnerFrame, self.Title}
        for _, drawing in pairs(drawings) do
            if drawing then
                pcall(function() drawing:Remove() end)
            end
        end
        
        for _, page in pairs(self.Pages) do
            if page and page.Sections then
                for _, section in pairs(page.Sections) do
                    if section and section.Elements then
                        for _, element in pairs(section.Elements) do
                            if element and element.drawing then
                                pcall(function() element.drawing:Remove() end)
                            end
                        end
                    end
                end
            end
        end
    end
    
    table.insert(Library.Elements, window)
    return window
end

-- Safe initialization
function Library:Init()
    print("UI Library initialized safely")
end

return Library
