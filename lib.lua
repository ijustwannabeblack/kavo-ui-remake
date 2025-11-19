-- Splix UI Library
-- Cleaner, optimized version

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Theme
local Theme = {
    Accent = Color3.fromRGB(50, 100, 255),
    LightContrast = Color3.fromRGB(30, 30, 30),
    DarkContrast = Color3.fromRGB(20, 20, 20),
    Outline = Color3.fromRGB(0, 0, 0),
    Inline = Color3.fromRGB(50, 50, 50),
    TextColor = Color3.fromRGB(255, 255, 255),
    TextBorder = Color3.fromRGB(0, 0, 0),
    Font = 2,
    TextSize = 13
}

-- Utility functions
local Utility = {}

function Utility:CreateDrawing(type, properties)
    local drawing = Drawing.new(type)
    for prop, value in pairs(properties) do
        drawing[prop] = value
    end
    return drawing
end

function Utility:MouseOver(position, size)
    local mouse = UserInputService:GetMouseLocation()
    return mouse.X >= position.X and mouse.X <= position.X + size.X and
           mouse.Y >= position.Y and mouse.Y <= position.Y + size.Y
end

function Utility:Lerp(a, b, t)
    return a + (b - a) * t
end

-- UI Library
local Library = {Windows = {}, Elements = {}}

function Library:CreateWindow(config)
    local window = {
        Name = config.Name or "UI",
        Size = config.Size or Vector2.new(500, 600),
        Pages = {},
        IsOpen = false,
        Accent = config.Accent or Theme.Accent
    }
    
    -- Main window frame
    window.MainFrame = Utility:CreateDrawing("Square", {
        Color = Theme.Outline,
        Filled = true,
        Size = window.Size,
        Position = Vector2.new(
            (workspace.CurrentCamera.ViewportSize.X - window.Size.X) / 2,
            (workspace.CurrentCamera.ViewportSize.Y - window.Size.Y) / 2
        ),
        Visible = false
    })
    
    -- Inner frames
    window.InnerFrame = Utility:CreateDrawing("Square", {
        Color = Theme.LightContrast,
        Filled = true,
        Size = window.Size - Vector2.new(4, 4),
        Position = window.MainFrame.Position + Vector2.new(2, 2),
        Visible = false
    })
    
    -- Title
    window.Title = Utility:CreateDrawing("Text", {
        Text = window.Name,
        Color = Theme.TextColor,
        Size = Theme.TextSize,
        Position = window.InnerFrame.Position + Vector2.new(10, 8),
        Visible = false
    })
    
    -- Toggle key
    window.ToggleKey = config.ToggleKey or Enum.KeyCode.RightShift
    
    -- Input handling
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == window.ToggleKey then
            window:Toggle()
        end
    end)
    
    function window:Toggle()
        self.IsOpen = not self.IsOpen
        self.MainFrame.Visible = self.IsOpen
        self.InnerFrame.Visible = self.IsOpen
        self.Title.Visible = self.IsOpen
        
        for _, page in pairs(self.Pages) do
            page:UpdateVisibility(self.IsOpen)
        end
    end
    
    function window:AddPage(name)
        local page = {
            Name = name,
            Sections = {},
            Window = self
        }
        
        -- Page button would go here
        -- Section management would go here
        
        function page:AddSection(name, side)
            local section = {
                Name = name,
                Side = side or "left",
                Elements = {}
            }
            
            function section:AddLabel(text)
                local label = {
                    Type = "Label",
                    Text = text
                }
                table.insert(self.Elements, label)
                return label
            end
            
            function section:AddToggle(config)
                local toggle = {
                    Type = "Toggle",
                    Name = config.Name or "Toggle",
                    Value = config.Default or false,
                    Callback = config.Callback or function() end
                }
                
                function toggle:Set(value)
                    self.Value = value
                    self.Callback(value)
                end
                
                function toggle:Get()
                    return self.Value
                end
                
                table.insert(self.Elements, toggle)
                return toggle
            end
            
            function section:AddSlider(config)
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
                    self.Callback(self.Value)
                end
                
                function slider:Get()
                    return self.Value
                end
                
                table.insert(self.Elements, slider)
                return slider
            end
            
            function section:AddButton(config)
                local button = {
                    Type = "Button",
                    Name = config.Name or "Button",
                    Callback = config.Callback or function() end
                }
                
                table.insert(self.Elements, button)
                return button
            end
            
            function section:AddDropdown(config)
                local dropdown = {
                    Type = "Dropdown",
                    Name = config.Name or "Dropdown",
                    Options = config.Options or {"Option 1", "Option 2"},
                    Value = config.Default or config.Options[1],
                    Callback = config.Callback or function() end
                }
                
                function dropdown:Set(value)
                    if table.find(self.Options, value) then
                        self.Value = value
                        self.Callback(value)
                    end
                end
                
                function dropdown:Get()
                    return self.Value
                end
                
                table.insert(self.Elements, dropdown)
                return dropdown
            end
            
            table.insert(page.Sections, section)
            return section
        end
        
        table.insert(self.Pages, page)
        return page
    end
    
    table.insert(Library.Windows, window)
    return window
end

-- Example usage:
local MyWindow = Library:CreateWindow({
    Name = "Splix UI",
    Size = Vector2.new(500, 400),
    ToggleKey = Enum.KeyCode.Insert
})

local MainPage = MyWindow:AddPage("Main")
local CombatSection = MainPage:AddSection("Combat")

local AimbotToggle = CombatSection:AddToggle({
    Name = "Aimbot",
    Default = true,
    Callback = function(value)
        print("Aimbot:", value)
    end
})

local FOVSlider = CombatSection:AddSlider({
    Name = "Field of View",
    Default = 90,
    Min = 1,
    Max = 360,
    Callback = function(value)
        print("FOV:", value)
    end
})

local VisualsSection = MainPage:AddSection("Visuals", "right")

local ESPToggle = VisualsSection:AddToggle({
    Name = "ESP",
    Default = false,
    Callback = function(value)
        print("ESP:", value)
    end
})

local ThemeDropdown = VisualsSection:AddDropdown({
    Name = "Theme",
    Options = {"Dark", "Light", "Blue", "Red"},
    Default = "Dark",
    Callback = function(value)
        print("Theme:", value)
    end
})

local MiscSection = MainPage:AddSection("Miscellaneous")

local SaveButton = MiscSection:AddButton({
    Name = "Save Config",
    Callback = function()
        print("Config saved!")
    end
})

-- Open the window
MyWindow:Toggle()

return Library
