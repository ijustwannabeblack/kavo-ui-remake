-- Completely Fixed Kavo UI Library
local Kavo = {}

local tween = game:GetService("TweenService")
local input = game:GetService("UserInputService")
local run = game:GetService("RunService")

local Utility = {}

function Utility:TweenObject(obj, properties, duration, ...)
    tween:Create(obj, TweenInfo.new(duration or 0.1, ...), properties):Play()
end

function Kavo:DraggingEnabled(frame, parent)
    parent = parent or frame
    
    local dragging = false
    local dragInput, mousePos, framePos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = parent.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    input.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            parent.Position = UDim2.new(
                framePos.X.Scale, framePos.X.Offset + delta.X,
                framePos.Y.Scale, framePos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Default theme with all required properties
local DEFAULT_THEME = {
    SchemeColor = Color3.fromRGB(74, 99, 135),
    Background = Color3.fromRGB(36, 37, 43),
    Header = Color3.fromRGB(28, 29, 34),
    TextColor = Color3.fromRGB(255, 255, 255),
    ElementColor = Color3.fromRGB(32, 32, 38)
}

-- Theme styles with all required properties
local THEME_STYLES = {
    DarkTheme = {
        SchemeColor = Color3.fromRGB(64, 64, 64),
        Background = Color3.fromRGB(0, 0, 0),
        Header = Color3.fromRGB(0, 0, 0),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(20, 20, 20)
    },
    LightTheme = {
        SchemeColor = Color3.fromRGB(150, 150, 150),
        Background = Color3.fromRGB(255, 255, 255),
        Header = Color3.fromRGB(200, 200, 200),
        TextColor = Color3.fromRGB(0, 0, 0),
        ElementColor = Color3.fromRGB(224, 224, 224)
    },
    BloodTheme = {
        SchemeColor = Color3.fromRGB(227, 27, 27),
        Background = Color3.fromRGB(10, 10, 10),
        Header = Color3.fromRGB(5, 5, 5),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(20, 20, 20)
    },
    GrapeTheme = {
        SchemeColor = Color3.fromRGB(166, 71, 214),
        Background = Color3.fromRGB(64, 50, 71),
        Header = Color3.fromRGB(36, 28, 41),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(74, 58, 84)
    },
    Ocean = {
        SchemeColor = Color3.fromRGB(86, 76, 251),
        Background = Color3.fromRGB(26, 32, 58),
        Header = Color3.fromRGB(38, 45, 71),
        TextColor = Color3.fromRGB(200, 200, 200),
        ElementColor = Color3.fromRGB(38, 45, 71)
    },
    Midnight = {
        SchemeColor = Color3.fromRGB(26, 189, 158),
        Background = Color3.fromRGB(44, 62, 82),
        Header = Color3.fromRGB(57, 81, 105),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(52, 74, 95)
    },
    Sentinel = {
        SchemeColor = Color3.fromRGB(230, 35, 69),
        Background = Color3.fromRGB(32, 32, 32),
        Header = Color3.fromRGB(24, 24, 24),
        TextColor = Color3.fromRGB(119, 209, 138),
        ElementColor = Color3.fromRGB(24, 24, 24)
    },
    Synapse = {
        SchemeColor = Color3.fromRGB(46, 48, 43),
        Background = Color3.fromRGB(13, 15, 12),
        Header = Color3.fromRGB(36, 38, 35),
        TextColor = Color3.fromRGB(152, 99, 53),
        ElementColor = Color3.fromRGB(24, 24, 24)
    },
    Serpent = {
        SchemeColor = Color3.fromRGB(0, 166, 58),
        Background = Color3.fromRGB(31, 41, 43),
        Header = Color3.fromRGB(22, 29, 31),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(22, 29, 31)
    }
}

-- Safe theme getter function
local function GetSafeTheme(themeInput)
    local theme
    
    if type(themeInput) == "string" then
        theme = THEME_STYLES[themeInput] or DEFAULT_THEME
    elseif type(themeInput) == "table" then
        theme = {}
        for key, defaultValue in pairs(DEFAULT_THEME) do
            theme[key] = themeInput[key] or defaultValue
        end
    else
        theme = DEFAULT_THEME
    end
    
    -- Final validation to ensure no nil values
    for key, defaultValue in pairs(DEFAULT_THEME) do
        if theme[key] == nil then
            theme[key] = defaultValue
        end
    end
    
    return theme
end

-- Safe color application function
local function ApplySafeColor(object, property, color)
    if object and object.Parent and color then
        object[property] = color
    end
end

function Kavo.CreateLib(kavName, themeInput)
    kavName = kavName or "Kavo UI"
    
    -- Get safe theme
    local currentTheme = GetSafeTheme(themeInput)
    
    -- Generate unique library name
    local libId = tostring(math.random(1000, 9999))
    local LibName = "KavoLib_" .. libId
    
    -- Clean up existing UI with same name
    for _, gui in pairs(game.CoreGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name == kavName then
            gui:Destroy()
        end
    end
    
    -- Create main UI containers
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = LibName
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game.CoreGui
    
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.BackgroundColor3 = currentTheme.Background
    Main.ClipsDescendants = true
    Main.Position = UDim2.new(0.336, 0, 0.275, 0)
    Main.Size = UDim2.new(0, 525, 0, 318)
    Main.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 4)
    MainCorner.Parent = Main
    
    -- Header
    local MainHeader = Instance.new("Frame")
    MainHeader.Name = "MainHeader"
    MainHeader.BackgroundColor3 = currentTheme.Header
    MainHeader.Size = UDim2.new(0, 525, 0, 29)
    MainHeader.Parent = Main
    
    local headerCover = Instance.new("UICorner")
    headerCover.CornerRadius = UDim.new(0, 4)
    headerCover.Parent = MainHeader
    
    local coverup = Instance.new("Frame")
    coverup.Name = "coverup"
    coverup.BackgroundColor3 = currentTheme.Header
    coverup.BorderSizePixel = 0
    coverup.Position = UDim2.new(0, 0, 0.759, 0)
    coverup.Size = UDim2.new(0, 525, 0, 7)
    coverup.Parent = MainHeader
    
    local title = Instance.new("TextLabel")
    title.Name = "title"
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0.017, 0, 0.345, 0)
    title.Size = UDim2.new(0, 204, 0, 8)
    title.Font = Enum.Font.Gotham
    title.Text = kavName
    title.TextColor3 = currentTheme.TextColor
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = MainHeader
    
    local close = Instance.new("ImageButton")
    close.Name = "close"
    close.BackgroundTransparency = 1
    close.Position = UDim2.new(0.95, 0, 0.138, 0)
    close.Size = UDim2.new(0, 21, 0, 21)
    close.ZIndex = 2
    close.Image = "rbxassetid://3926305904"
    close.ImageRectOffset = Vector2.new(284, 4)
    close.ImageRectSize = Vector2.new(24, 24)
    close.Parent = MainHeader
    
    close.MouseButton1Click:Connect(function()
        Utility:TweenObject(close, {ImageTransparency = 1})
        wait()
        Utility:TweenObject(Main, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(
                0, Main.AbsolutePosition.X + (Main.AbsoluteSize.X / 2),
                0, Main.AbsolutePosition.Y + (Main.AbsoluteSize.Y / 2)
            )
        })
        wait(1)
        ScreenGui:Destroy()
    end)
    
    -- Sidebar
    local MainSide = Instance.new("Frame")
    MainSide.Name = "MainSide"
    MainSide.BackgroundColor3 = currentTheme.Header
    MainSide.Position = UDim2.new(0, 0, 0.091, 0)
    MainSide.Size = UDim2.new(0, 149, 0, 289)
    MainSide.Parent = Main
    
    local sideCorner = Instance.new("UICorner")
    sideCorner.CornerRadius = UDim.new(0, 4)
    sideCorner.Parent = MainSide
    
    local coverup_2 = Instance.new("Frame")
    coverup_2.Name = "coverup"
    coverup_2.BackgroundColor3 = currentTheme.Header
    coverup_2.BorderSizePixel = 0
    coverup_2.Position = UDim2.new(0.95, 0, 0, 0)
    coverup_2.Size = UDim2.new(0, 7, 0, 289)
    coverup_2.Parent = MainSide
    
    -- Tab container
    local tabFrames = Instance.new("Frame")
    tabFrames.Name = "tabFrames"
    tabFrames.BackgroundTransparency = 1
    tabFrames.Position = UDim2.new(0.044, 0, 0, 0)
    tabFrames.Size = UDim2.new(0, 135, 0, 283)
    tabFrames.Parent = MainSide
    
    local tabListing = Instance.new("UIListLayout")
    tabListing.Parent = tabFrames
    
    -- Pages container
    local pages = Instance.new("Frame")
    pages.Name = "pages"
    pages.BackgroundTransparency = 1
    pages.Position = UDim2.new(0.299, 0, 0.123, 0)
    pages.Size = UDim2.new(0, 360, 0, 269)
    pages.Parent = Main
    
    local Pages = Instance.new("Folder")
    Pages.Name = "Pages"
    Pages.Parent = pages
    
    -- Info container
    local infoContainer = Instance.new("Frame")
    infoContainer.Name = "infoContainer"
    infoContainer.BackgroundTransparency = 1
    infoContainer.Position = UDim2.new(0.299, 0, 0.874, 0)
    infoContainer.Size = UDim2.new(0, 368, 0, 33)
    infoContainer.Parent = Main
    
    -- Blur frame
    local blurFrame = Instance.new("Frame")
    blurFrame.Name = "blurFrame"
    blurFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    blurFrame.BackgroundTransparency = 1
    blurFrame.BorderSizePixel = 0
    blurFrame.Position = UDim2.new(-0.022, 0, -0.037, 0)
    blurFrame.Size = UDim2.new(0, 376, 0, 289)
    blurFrame.ZIndex = 999
    blurFrame.Parent = pages
    
    -- Enable dragging
    Kavo:DraggingEnabled(MainHeader, Main)
    
    -- Theme management
    local themeObjects = {
        {Object = Main, Property = "BackgroundColor3"},
        {Object = MainHeader, Property = "BackgroundColor3"},
        {Object = MainSide, Property = "BackgroundColor3"},
        {Object = coverup, Property = "BackgroundColor3"},
        {Object = coverup_2, Property = "BackgroundColor3"}
    }
    
    -- Theme update loop
    coroutine.wrap(function()
        while ScreenGui and ScreenGui.Parent do
            for _, themeObj in pairs(themeObjects) do
                if themeObj.Object and themeObj.Object.Parent then
                    ApplySafeColor(themeObj.Object, themeObj.Property, currentTheme[themeObj.Property:gsub("Color3", "")])
                end
            end
            run.RenderStepped:Wait()
        end
    end)()
    
    -- Public methods
    local publicMethods = {}
    
    function publicMethods:ChangeColor(property, color)
        if currentTheme[property] and color then
            currentTheme[property] = color
        end
    end
    
    function publicMethods:ChangeTheme(newThemeInput)
        currentTheme = GetSafeTheme(newThemeInput)
    end
    
    function publicMethods:ToggleUI()
        if ScreenGui then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end
    
    -- Tab system
    local firstTab = true
    
    function publicMethods:NewTab(tabName)
        tabName = tabName or "Tab"
        
        -- Create tab button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName .. "Tab"
        tabButton.BackgroundColor3 = currentTheme.SchemeColor
        tabButton.Size = UDim2.new(0, 135, 0, 28)
        tabButton.AutoButtonColor = false
        tabButton.Font = Enum.Font.Gotham
        tabButton.Text = tabName
        tabButton.TextColor3 = currentTheme.TextColor
        tabButton.TextSize = 14
        tabButton.BackgroundTransparency = firstTab and 0 or 1
        tabButton.Parent = tabFrames
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 5)
        tabCorner.Parent = tabButton
        
        -- Create page
        local page = Instance.new("ScrollingFrame")
        page.Name = tabName .. "Page"
        page.Active = true
        page.BackgroundColor3 = currentTheme.Background
        page.BorderSizePixel = 0
        page.Size = UDim2.new(1, 0, 1, 0)
        page.ScrollBarThickness = 5
        page.ScrollBarImageColor3 = Color3.fromRGB(
            math.clamp(currentTheme.SchemeColor.R * 255 - 16, 0, 255),
            math.clamp(currentTheme.SchemeColor.G * 255 - 15, 0, 255),
            math.clamp(currentTheme.SchemeColor.B * 255 - 28, 0, 255)
        )
        page.Visible = firstTab
        page.Parent = Pages
        
        local pageLayout = Instance.new("UIListLayout")
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Padding = UDim.new(0, 5)
        pageLayout.Parent = page
        
        -- Update page size function
        local function UpdatePageSize()
            if page and page.Parent then
                local contentSize = pageLayout.AbsoluteContentSize
                Utility:TweenObject(page, {
                    CanvasSize = UDim2.new(0, contentSize.X, 0, contentSize.Y)
                }, 0.15)
            end
        end
        
        UpdatePageSize()
        page.ChildAdded:Connect(UpdatePageSize)
        page.ChildRemoved:Connect(UpdatePageSize)
        
        -- Tab click handler
        tabButton.MouseButton1Click:Connect(function()
            -- Hide all pages
            for _, otherPage in pairs(Pages:GetChildren()) do
                if otherPage:IsA("ScrollingFrame") then
                    otherPage.Visible = false
                end
            end
            
            -- Reset all tab buttons
            for _, otherButton in pairs(tabFrames:GetChildren()) do
                if otherButton:IsA("TextButton") then
                    Utility:TweenObject(otherButton, {BackgroundTransparency = 1}, 0.2)
                end
            end
            
            -- Show this page and tab
            page.Visible = true
            Utility:TweenObject(tabButton, {BackgroundTransparency = 0}, 0.2)
            UpdatePageSize()
        end)
        
        -- Theme updates for tab
        coroutine.wrap(function()
            while tabButton and tabButton.Parent do
                ApplySafeColor(tabButton, "BackgroundColor3", currentTheme.SchemeColor)
                ApplySafeColor(tabButton, "TextColor3", currentTheme.TextColor)
                ApplySafeColor(page, "BackgroundColor3", currentTheme.Background)
                run.RenderStepped:Wait()
            end
        end)()
        
        firstTab = false
        
        -- Return tab interface
        local tabInterface = {}
        
        function tabInterface:NewSection(sectionName, hidden)
            sectionName = sectionName or "Section"
            hidden = hidden or false
            
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Name = "SectionFrame"
            sectionFrame.BackgroundColor3 = currentTheme.Background
            sectionFrame.BorderSizePixel = 0
            sectionFrame.Parent = page
            
            local sectionLayout = Instance.new("UIListLayout")
            sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectionLayout.Padding = UDim.new(0, 5)
            sectionLayout.Parent = sectionFrame
            
            -- Section header
            local sectionHeader = Instance.new("Frame")
            sectionHeader.Name = "SectionHeader"
            sectionHeader.BackgroundColor3 = currentTheme.SchemeColor
            sectionHeader.Size = UDim2.new(0, 352, 0, 33)
            sectionHeader.Visible = not hidden
            sectionHeader.Parent = sectionFrame
            
            local headerCorner = Instance.new("UICorner")
            headerCorner.CornerRadius = UDim.new(0, 4)
            headerCorner.Parent = sectionHeader
            
            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Name = "SectionTitle"
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Position = UDim2.new(0.02, 0, 0, 0)
            sectionTitle.Size = UDim2.new(0.98, 0, 1, 0)
            sectionTitle.Font = Enum.Font.Gotham
            sectionTitle.Text = sectionName
            sectionTitle.TextColor3 = currentTheme.TextColor
            sectionTitle.TextSize = 14
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            sectionTitle.Parent = sectionHeader
            
            -- Section content
            local sectionContent = Instance.new("Frame")
            sectionContent.Name = "SectionContent"
            sectionContent.BackgroundTransparency = 1
            sectionContent.Position = UDim2.new(0, 0, 0.191, 0)
            sectionContent.Parent = sectionFrame
            
            local contentLayout = Instance.new("UIListLayout")
            contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            contentLayout.Padding = UDim.new(0, 3)
            contentLayout.Parent = sectionContent
            
            -- Update section size
            local function UpdateSectionSize()
                if sectionFrame and sectionFrame.Parent then
                    local contentSize = contentLayout.AbsoluteContentSize
                    sectionContent.Size = UDim2.new(1, 0, 0, contentSize.Y)
                    
                    local frameSize = sectionLayout.AbsoluteContentSize
                    sectionFrame.Size = UDim2.new(0, 352, 0, frameSize.Y)
                    
                    UpdatePageSize()
                end
            end
            
            UpdateSectionSize()
            sectionContent.ChildAdded:Connect(UpdateSectionSize)
            sectionContent.ChildRemoved:Connect(UpdateSectionSize)
            
            -- Theme updates for section
            coroutine.wrap(function()
                while sectionFrame and sectionFrame.Parent do
                    ApplySafeColor(sectionFrame, "BackgroundColor3", currentTheme.Background)
                    ApplySafeColor(sectionHeader, "BackgroundColor3", currentTheme.SchemeColor)
                    ApplySafeColor(sectionTitle, "TextColor3", currentTheme.TextColor)
                    run.RenderStepped:Wait()
                end
            end)()
            
            -- Section interface
            local sectionInterface = {}
            
            function sectionInterface:NewButton(buttonName, tooltip, callback)
                buttonName = buttonName or "Button"
                callback = callback or function() end
                
                local button = Instance.new("TextButton")
                button.Name = "Button"
                button.BackgroundColor3 = currentTheme.ElementColor
                button.Size = UDim2.new(0, 352, 0, 33)
                button.AutoButtonColor = false
                button.Font = Enum.Font.SourceSans
                button.Text = ""
                button.TextSize = 14
                button.Parent = sectionContent
                
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 4)
                buttonCorner.Parent = button
                
                local buttonLabel = Instance.new("TextLabel")
                buttonLabel.Name = "ButtonLabel"
                buttonLabel.BackgroundTransparency = 1
                buttonLabel.Position = UDim2.new(0.097, 0, 0.273, 0)
                buttonLabel.Size = UDim2.new(0, 314, 0, 14)
                buttonLabel.Font = Enum.Font.GothamSemibold
                buttonLabel.Text = buttonName
                buttonLabel.TextColor3 = currentTheme.TextColor
                buttonLabel.TextSize = 14
                buttonLabel.TextXAlignment = Enum.TextXAlignment.Left
                buttonLabel.Parent = button
                
                button.MouseButton1Click:Connect(function()
                    pcall(callback)
                end)
                
                UpdateSectionSize()
                
                local buttonInterface = {}
                function buttonInterface:UpdateButton(newText)
                    if buttonLabel then
                        buttonLabel.Text = newText or buttonName
                    end
                end
                
                return buttonInterface
            end
            
            function sectionInterface:NewLabel(labelText)
                labelText = labelText or "Label"
                
                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.BackgroundColor3 = currentTheme.SchemeColor
                label.Size = UDim2.new(0, 352, 0, 33)
                label.Font = Enum.Font.Gotham
                label.Text = "  " .. labelText
                label.TextColor3 = currentTheme.TextColor
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = sectionContent
                
                local labelCorner = Instance.new("UICorner")
                labelCorner.CornerRadius = UDim.new(0, 4)
                labelCorner.Parent = label
                
                UpdateSectionSize()
                
                local labelInterface = {}
                function labelInterface:UpdateLabel(newText)
                    if label then
                        label.Text = "  " .. (newText or labelText)
                    end
                end
                
                return labelInterface
            end
            
            return sectionInterface
        end
        
        return tabInterface
    end
    
    return publicMethods
end

return Kavo