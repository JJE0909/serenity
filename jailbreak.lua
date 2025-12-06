
local Serenity = {
    Version = "1.0.0",
}


local library = {}
library.flags = {}
library.statusConsole = nil
library.currentTab = nil
local toggled = false
local mouse = game:GetService("Players").LocalPlayer:GetMouse()

local theme = {
    main      = Color3.fromRGB(12, 16, 26),   
    secondary = Color3.fromRGB(18, 24, 38),  

    accent    = Color3.fromRGB(225, 235, 255), 
    accent2   = Color3.fromRGB(36, 99, 210),  
    accent3   = Color3.fromRGB(0, 186, 255),  

    outline   = Color3.fromRGB(30, 40, 70),
    muted     = Color3.fromRGB(140, 150, 175),
}


local function tweenSize(obj, size, delay)
    obj:TweenSize(size, "Out", "Sine", delay, false)
end

local function tweenProps(obj, t, data)
    game:GetService("TweenService"):Create(
        obj,
        TweenInfo.new(t[1], Enum.EasingStyle[t[2]], Enum.EasingDirection[t[3]]),
        data
    ):Play()
    return true
end

local function applyRipple(obj)
    task.spawn(function()
        if obj.ClipsDescendants ~= true then
            obj.ClipsDescendants = true
        end
        local applyRipple = Instance.new("ImageLabel")
        applyRipple.Name = "applyRipple"
        applyRipple.Parent = obj
        applyRipple.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        applyRipple.BackgroundTransparency = 1
        applyRipple.ZIndex = 8
        applyRipple.Image = "rbxassetid://2708891598"
        applyRipple.ImageTransparency = 0.8
        applyRipple.ScaleType = Enum.ScaleType.Fit
        applyRipple.ImageColor3 = Color3.fromRGB(0, 0, 0)
        applyRipple.Position = UDim2.new(
            (mouse.X - applyRipple.AbsolutePosition.X) / obj.AbsoluteSize.X,
            0,
            (mouse.Y - applyRipple.AbsolutePosition.Y) / obj.AbsoluteSize.Y,
            0
        )
        tweenProps(applyRipple, {0.3, "Linear", "InOut"}, {
            Position = UDim2.new(-5.5, 0, -5.5, 0),
            Size = UDim2.new(12, 0, 12, 0),
        })
        task.wait(0.15)
        tweenProps(applyRipple, {0.3, "Linear", "InOut"}, {
            ImageTransparency = 1,
        })
        task.wait(0.3)
        applyRipple:Destroy()
    end)
end

local function getTimestampString()
    local ok, res = pcall(function()
        return os.date("%H:%M:%S")
    end)
    return ok and res or "??:??:??"
end

function library:LogStatus(message)
    message = tostring(message or "")

    print("[Serenity] " .. message)

    local console = self.statusConsole
    if console and console.AddLine then
        console:AddLine(string.format("[%s] %s", getTimestampString(), message))
    end
end

local function updateTabHighlight(section, active)
    if not section then return end
    local btn = section:GetAttribute("TabButton")
    if not btn or not btn:IsA("TextButton") then return end

    local targetBg   = active and theme.accent2 or theme.secondary
    local targetText = active and theme.accent or theme.muted

    tweenProps(btn, {0.15, "Sine", "Out"}, {
        BackgroundColor3 = targetBg,
        TextColor3       = targetText,
    })
end


local changingTab = false
local function switchTabContent(Tab)
    if changingTab then return end
    local New = Tab[1]
    local Old = library.currentTab

    if Old == nil then
        library.currentTab = New
        New.Visible = true
        updateTabHighlight(New, true)
        return
    end

    if New.Visible == true then return end

    changingTab = true
    updateTabHighlight(Old, false)

    tweenSize(Old.Parent, UDim2.new(0, 440, 0, 0), 0.1)
    Old.Visible = false
    task.wait(0.2)

    New.Visible = true
    updateTabHighlight(New, true)

    tweenSize(New.Parent, UDim2.new(0, 440, 0, 318), 0.1)
    library.currentTab = New

    task.wait(0.1)
    changingTab = false
end


local function enableDrag(frame, hold)
    if not hold then
        hold = frame
    end
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function updateDragPosition(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    hold.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

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

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDragPosition(input)
        end
    end)
end

function library:Create(title)
    if game:WaitForChild("CoreGui"):FindFirstChild("Serenity") then
        game:WaitForChild("CoreGui"):FindFirstChild("Serenity"):Destroy()
    end

    local Serenity = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local MainFrameC = Instance.new("UICorner")
    local SideFrame = Instance.new("Frame")
    local SideFrameC = Instance.new("UICorner")
    local TabContainer = Instance.new("ScrollingFrame")
    local TabContainerL = Instance.new("UIListLayout")
    local TabContainerP = Instance.new("UIPadding")
    local TabHolder = Instance.new("Frame")
    local TabHolderC = Instance.new("UICorner")
    local TopFrame = Instance.new("Frame")
    local TopFrameC = Instance.new("UICorner")
    local Title = Instance.new("TextLabel")

    local function destroyMainGui()
        if Serenity then
            Serenity:Destroy()
        end
    end

    _G.SerenityDestroyUI = destroyMainGui

    Serenity.Name = "Serenity"
    Serenity.Parent = game:WaitForChild("CoreGui")

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = Serenity
    MainFrame.BackgroundColor3 = theme.main
    MainFrame.Position = UDim2.new(0.3451, 0, 0.2779, 0)
    MainFrame.Size = UDim2.new(0, 587, 0, 366)
    MainFrame.BorderSizePixel = 0

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = theme.outline
    MainStroke.Thickness = 1
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Parent = MainFrame

    local function toggleMainGui()
        toggled = not toggled
        if not MainFrame.ClipsDescendants then
            MainFrame.ClipsDescendants = true
        end
        if toggled then
            tweenSize(MainFrame, UDim2.new(0, 587, 0, 0), 0.15)
        else
            tweenSize(MainFrame, UDim2.new(0, 587, 0, 366), 0.15)
        end
    end

    _G.SerenityToggleUI = toggleMainGui

    MainFrameC.CornerRadius = UDim.new(0, 8)
    MainFrameC.Name = "MainFrameC"
    MainFrameC.Parent = MainFrame

    SideFrame.Name = "SideFrame"
    SideFrame.Parent = MainFrame
    SideFrame.BackgroundColor3 = theme.secondary
    SideFrame.Position = UDim2.new(0.012, 0, 0.118, 0)
    SideFrame.Size = UDim2.new(0, 130, 0, 318)
    SideFrame.BorderSizePixel = 0

    local SideStroke = Instance.new("UIStroke")
    SideStroke.Color = theme.outline
    SideStroke.Thickness = 1
    SideStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    SideStroke.Parent = SideFrame

    SideFrameC.CornerRadius = UDim.new(0, 6)
    SideFrameC.Name = "SideFrameC"
    SideFrameC.Parent = SideFrame

    TabContainer.Name = "TabContainer"
    TabContainer.Parent = SideFrame
    TabContainer.Active = true
    TabContainer.BackgroundColor3 = theme.secondary
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0.051, 0, 0.022, 0)
    TabContainer.Size = UDim2.new(0, 117, 0, 305)
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.ScrollBarThickness = 3
    TabContainer.ScrollBarImageColor3 = theme.accent3

    TabContainerL.Name = "TabContainerL"
    TabContainerL.Parent = TabContainer
    TabContainerL.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabContainerL.SortOrder = Enum.SortOrder.LayoutOrder
    TabContainerL.Padding = UDim.new(0, 5)

    TabContainerP.Name = "TabContainerP"
    TabContainerP.Parent = TabContainer
    TabContainerP.PaddingTop = UDim.new(0, 5)

    TabHolder.Name = "TabHolder"
    TabHolder.Parent = MainFrame
    TabHolder.BorderSizePixel = 0
    TabHolder.BackgroundColor3 = theme.secondary
    TabHolder.Position = UDim2.new(0.244, 0, 0.118, 0)
    TabHolder.Size = UDim2.new(0, 440, 0, 318)
    TabHolder.ClipsDescendants = true

    local TabStroke = Instance.new("UIStroke")
    TabStroke.Color = theme.outline
    TabStroke.Thickness = 1
    TabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    TabStroke.Parent = TabHolder

    TabHolderC.CornerRadius = UDim.new(0, 6)
    TabHolderC.Name = "TabHolderC"
    TabHolderC.Parent = TabHolder

    TopFrame.Name = "TopFrame"
    TopFrame.Parent = MainFrame
    TopFrame.BackgroundColor3 = theme.secondary
    TopFrame.Position = UDim2.new(0.0123, 0, 0.0191, 0)
    TopFrame.Size = UDim2.new(0, 575, 0, 33)
    TopFrame.BorderSizePixel = 0

    TopFrameC.CornerRadius = UDim.new(0, 6)
    TopFrameC.Name = "TopFrameC"
    TopFrameC.Parent = TopFrame

    local TopGradient = Instance.new("UIGradient")
    TopGradient.Color = ColorSequence.new(
        Color3.fromRGB(20, 60, 130),
        Color3.fromRGB(40, 130, 230)
    )
    TopGradient.Rotation = 0
    TopGradient.Parent = TopFrame


    Title.Name = "Title"
    Title.Parent = TopFrame
    Title.BackgroundTransparency = 1
    Title.BorderSizePixel = 0
    Title.Position = UDim2.new(0.0112, 0, 0, 0)
    Title.Size = UDim2.new(0, 569, 0, 33)
    Title.Font = Enum.Font.GothamMedium
    Title.Text = title
    Title.TextColor3 = theme.accent
    Title.TextSize = 20
    Title.TextXAlignment = Enum.TextXAlignment.Left


    enableDrag(MainFrame, TopFrame)

    TabContainerL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabContainerL.AbsoluteContentSize.Y + 18)
    end)

    local Holder = {}

    function Holder:Tab(name)
        local TabOpen = Instance.new("TextButton")
        local TabOpenC = Instance.new("UICorner")
        local Section = Instance.new("ScrollingFrame")
        local SectionP = Instance.new("UIPadding")
        local SectionC = Instance.new("UICorner")
        local SectionL = Instance.new("UIListLayout")

        TabOpen.Name = "TabOpen"
        TabOpen.Parent = TabContainer
        TabOpen.BackgroundColor3 = theme.secondary
        TabOpen.BackgroundTransparency = 0 
        TabOpen.BorderSizePixel = 0
        TabOpen.Size = UDim2.new(0, 116, 0, 30)
        TabOpen.AutoButtonColor = false
        TabOpen.Font = Enum.Font.GothamMedium
        TabOpen.Text = "       " .. name
        TabOpen.TextColor3 = theme.muted
        TabOpen.TextSize = 14
        TabOpen.TextXAlignment = Enum.TextXAlignment.Left

        TabOpenC.CornerRadius = UDim.new(1, 10)
        TabOpenC.Name = "TabOpenC"
        TabOpenC.Parent = TabOpen


        Section.Name = name
        Section.Parent = TabHolder
        Section.Active = true
        Section.BackgroundColor3 = theme.secondary
        Section.BorderSizePixel = 0
        Section.Position = UDim2.new(0, 0, 0, 0)
        Section.Size = UDim2.new(0, 440, 0, 318)
        Section.Visible = false
        Section.ScrollBarThickness = 0
        Section.ScrollBarImageColor3 = theme.accent
        Section.CanvasSize = UDim2.new(0, 0, 0, 0)

        SectionC.CornerRadius = UDim.new(0, 4)
        SectionC.Name = "SectionC"
        SectionC.Parent = Section

        SectionP.Name = "SectionP"
        SectionP.Parent = Section
        SectionP.PaddingLeft = UDim.new(0, 5)
        SectionP.PaddingTop = UDim.new(0, 5)

        SectionL.Name = "SectionL"
        SectionL.Parent = Section
        SectionL.SortOrder = Enum.SortOrder.LayoutOrder
        SectionL.Padding = UDim.new(0, 5)

        SectionL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Section.CanvasSize = UDim2.new(0, 0, 0, SectionL.AbsoluteContentSize.Y + 18)
        end)

        TabOpen.MouseButton1Click:Connect(function()
            task.spawn(function()
                applyRipple(TabOpen)
            end)
            switchTabContent({Section})
        end)

        if library.currentTab == nil then
            switchTabContent({Section})
        end

        local TabHolderObject = {}

        function TabHolderObject:Section(name)
            local SectionSplit = Instance.new("Frame")
            local SectionC2 = Instance.new("UICorner")
            local SectionName = Instance.new("TextLabel")
            local SectionOpened = Instance.new("ImageLabel")
            local TabL = Instance.new("UIListLayout")
            local UIPadding = Instance.new("UIPadding")

            SectionSplit.Name = "SectionSplit"
            SectionSplit.Parent = Section
            SectionSplit.BackgroundColor3 = Color3.fromRGB(37, 44, 72)
            SectionSplit.BackgroundTransparency = 1
            SectionSplit.BorderSizePixel = 0
            SectionSplit.ClipsDescendants = true
            SectionSplit.Size = UDim2.new(0.981, 0, 0, 44)

            SectionC2.CornerRadius = UDim.new(0, 6)
            SectionC2.Name = "SectionC2"
            SectionC2.Parent = SectionSplit

            SectionName.Name = "SectionName"
            SectionName.Parent = SectionSplit
            SectionName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionName.BackgroundTransparency = 1
            SectionName.Position = UDim2.new(0.183, 0, -1.18, 0)
            SectionName.Size = UDim2.new(0, 401, 0, 36)
            SectionName.Font = Enum.Font.GothamMedium
            SectionName.Text = name
            SectionName.TextColor3 = theme.accent
            SectionName.TextSize = 16
            SectionName.TextXAlignment = Enum.TextXAlignment.Left

            SectionOpened.Name = "SectionOpened"
            SectionOpened.Parent = SectionName
            SectionOpened.BackgroundTransparency = 1
            SectionOpened.BorderSizePixel = 0
            SectionOpened.Position = UDim2.new(0, -33, 0, 5)
            SectionOpened.Size = UDim2.new(0, 26, 0, 26)
            SectionOpened.ImageColor3 = theme.accent

            TabL.Name = "TabL"
            TabL.Parent = SectionSplit
            TabL.SortOrder = Enum.SortOrder.LayoutOrder
            TabL.VerticalAlignment = Enum.VerticalAlignment.Center
            TabL.Padding = UDim.new(0, 3)

            UIPadding.Parent = SectionSplit
            UIPadding.PaddingLeft = UDim.new(0, 0)
            UIPadding.PaddingTop = UDim.new(0, 5)

            Section:SetAttribute("TabButton", TabOpen)

        end

        function TabHolderObject:Button(name, callback)
            local ButtonFrame = Instance.new("Frame")
            local Button = Instance.new("TextButton")
            local ButtonC = Instance.new("UICorner")

            ButtonFrame.Name = "ButtonFrame"
            ButtonFrame.Parent = Section
            ButtonFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ButtonFrame.BackgroundTransparency = 1
            ButtonFrame.BorderSizePixel = 0
            ButtonFrame.Size = UDim2.new(0, 428, 0, 38)

            Button.Name = "Button"
            Button.Parent = ButtonFrame
            Button.BackgroundColor3 = theme.main
            Button.BorderSizePixel = 0
            Button.ClipsDescendants = true
            Button.Size = UDim2.new(0, 428, 0, 38)
            Button.AutoButtonColor = false
            Button.Font = Enum.Font.GothamMedium
            Button.Text = "   " .. name
            Button.TextColor3 = theme.accent
            Button.TextSize = 16
            Button.TextXAlignment = Enum.TextXAlignment.Left

            ButtonC.CornerRadius = UDim.new(0, 6)
            ButtonC.Name = "ButtonC"
            ButtonC.Parent = Button

            Button.MouseButton1Click:Connect(function()
                task.spawn(function()
                    applyRipple(Button)
                end)
                task.spawn(callback)
            end)

            local funcs = {
                updateName = function(_, newName)
                    Button.Text = "   " .. newName
                end,
                currentName = function()
                    return Button.Text
                end,
                Module = ButtonFrame,
            }

            return funcs
        end

        function TabHolderObject:Label(text)
            local LabelFrame = Instance.new("Frame")
            local Label = Instance.new("TextLabel")
            local LabelC = Instance.new("UICorner")

            LabelFrame.Name = "LabelFrame"
            LabelFrame.Parent = Section
            LabelFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            LabelFrame.BackgroundTransparency = 1
            LabelFrame.BorderSizePixel = 0
            LabelFrame.Size = UDim2.new(0, 428, 0, 25)

            Label.Name = "Label"
            Label.Parent = LabelFrame
            Label.BackgroundColor3 = theme.main
            Label.BorderSizePixel = 0
            Label.ClipsDescendants = true
            Label.Size = UDim2.new(0, 428, 0, 25)
            Label.Font = Enum.Font.GothamMedium
            Label.Text = text
            Label.TextColor3 = theme.accent
            Label.TextSize = 16
            Label.TextXAlignment = Enum.TextXAlignment.Center

            LabelC.CornerRadius = UDim.new(0, 6)
            LabelC.Name = "LabelC"
            LabelC.Parent = Label

            local funcs = {
                SetValue = function(_, newText)
                    Label.Text = tostring(newText)
                end,
                Module = LabelFrame,
                GetText = function()
                    return Label.Text
                end,
            }

            return funcs
        end

        function TabHolderObject:Console()
            local ConsoleFrame = Instance.new("Frame")
            local ConsoleTitle = Instance.new("TextLabel")
            local ConsoleContainer = Instance.new("Frame")
            local ConsoleContainerC = Instance.new("UICorner")
            local Console = Instance.new("ScrollingFrame")
            local ConsoleC = Instance.new("UICorner")
            local ConsoleList = Instance.new("UIListLayout")
            local ConsolePad = Instance.new("UIPadding")

            ConsoleFrame.Name = "StatusConsole"
            ConsoleFrame.Parent = Section
            ConsoleFrame.BackgroundTransparency = 1
            ConsoleFrame.BorderSizePixel = 0
            ConsoleFrame.Size = UDim2.new(0, 428, 0, 260)

            ConsoleTitle.Name = "ConsoleTitle"
            ConsoleTitle.Parent = ConsoleFrame
            ConsoleTitle.BackgroundTransparency = 1
            ConsoleTitle.Size = UDim2.new(1, 0, 0, 22)
            ConsoleTitle.Font = Enum.Font.GothamMedium
            ConsoleTitle.Text = "Status Console"
            ConsoleTitle.TextColor3 = theme.accent
            ConsoleTitle.TextSize = 14
            ConsoleTitle.TextXAlignment = Enum.TextXAlignment.Left

            ConsoleContainer.Name = "ConsoleContainer"
            ConsoleContainer.Parent = ConsoleFrame
            ConsoleContainer.BackgroundColor3 = theme.secondary
            ConsoleContainer.BorderSizePixel = 0
            ConsoleContainer.Position = UDim2.new(0, 0, 0, 24)
            ConsoleContainer.Size = UDim2.new(1, 0, 1, -24)

            ConsoleContainerC.CornerRadius = UDim.new(0, 6)
            ConsoleContainerC.Parent = ConsoleContainer

            Console.Name = "Console"
            Console.Parent = ConsoleContainer
            Console.Active = true
            Console.BackgroundColor3 = theme.main
            Console.BorderSizePixel = 0
            Console.Position = UDim2.new(0, 1, 0, 1)
            Console.Size = UDim2.new(1, -2, 1, -2)
            Console.ScrollBarThickness = 4
            Console.ScrollBarImageColor3 = theme.accent3
            Console.CanvasSize = UDim2.new(0, 0, 0, 0)
            Console.ScrollingDirection = Enum.ScrollingDirection.Y
            Console.AutomaticCanvasSize = Enum.AutomaticSize.None

            ConsoleC.CornerRadius = UDim.new(0, 6)
            ConsoleC.Parent = Console

            ConsoleList.Name = "ConsoleList"
            ConsoleList.Parent = Console
            ConsoleList.SortOrder = Enum.SortOrder.LayoutOrder
            ConsoleList.Padding = UDim.new(0, 2)

            ConsolePad.Parent = Console
            ConsolePad.PaddingLeft = UDim.new(0, 6)
            ConsolePad.PaddingTop = UDim.new(0, 6)
            ConsolePad.PaddingRight = UDim.new(0, 6)
            ConsolePad.PaddingBottom = UDim.new(0, 6)

            ConsoleList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Console.CanvasSize = UDim2.new(0, 0, 0, ConsoleList.AbsoluteContentSize.Y + 12)
                Console.CanvasPosition = Vector2.new(
                    0,
                    math.max(0, Console.CanvasSize.Y.Offset - Console.AbsoluteSize.Y)
                )
            end)

            local funcs = {}
            funcs._lines = {}

            function funcs:AddLine(text)
                text = tostring(text)

                local Line = Instance.new("TextLabel")
                Line.BackgroundTransparency = 1
                Line.BorderSizePixel = 0
                Line.Size = UDim2.new(1, 0, 0, 16)
                Line.Font = Enum.Font.Gotham
                Line.Text = text
                Line.TextWrapped = false
                Line.TextXAlignment = Enum.TextXAlignment.Left
                Line.TextYAlignment = Enum.TextYAlignment.Center
                Line.TextSize = 13
                Line.TextColor3 = theme.accent

                Line.Parent = Console
                table.insert(self._lines, Line)

                local maxLines = 150
                if #self._lines > maxLines then
                    self._lines[1]:Destroy()
                    table.remove(self._lines, 1)
                end
            end

            function funcs:Clear()
                for _, line in ipairs(self._lines) do
                    if line and line.Parent then
                        line:Destroy()
                    end
                end
                self._lines = {}
                Console.CanvasPosition = Vector2.new(0, 0)
            end

            return funcs
        end


        function TabHolderObject:Toggle(name, flag, val, callback)
            callback = callback or function() end
            assert(type(name) == "string", "Toggle name must be a string")
            assert(type(flag) == "string", "Toggle flag must be a string")

            if library.flags[flag] == nil then
                library.flags[flag] = val or false
            end

            local ToggleFrame = Instance.new("Frame")
            local ToggleBtn = Instance.new("TextButton")
            local ToggleC = Instance.new("UICorner")
            local ToggleSwitch = Instance.new("Frame")
            local ToggleSwitchC = Instance.new("UICorner")
            local ToggleSwitchBtn = Instance.new("Frame")
            local ToggleSwitchBtnC = Instance.new("UICorner")

            ToggleFrame.Name = "ToggleFrame"
            ToggleFrame.Parent = Section
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleFrame.BackgroundTransparency = 1
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Size = UDim2.new(0, 428, 0, 38)

            ToggleBtn.Name = "Toggle"
            ToggleBtn.Parent = ToggleFrame
            ToggleBtn.BackgroundColor3 = theme.main
            ToggleBtn.BorderSizePixel = 0
            ToggleBtn.ClipsDescendants = true
            ToggleBtn.Size = UDim2.new(0, 428, 0, 38)
            ToggleBtn.AutoButtonColor = false
            ToggleBtn.Font = Enum.Font.GothamMedium
            ToggleBtn.Text = "   " .. name
            ToggleBtn.TextColor3 = theme.accent
            ToggleBtn.TextSize = 16
            ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left

            ToggleC.CornerRadius = UDim.new(0, 6)
            ToggleC.Name = "ToggleC"
            ToggleC.Parent = ToggleBtn

            ToggleSwitch.Name = "ToggleSwitch"
            ToggleSwitch.Parent = ToggleBtn
            ToggleSwitch.BackgroundColor3 = theme.secondary
            ToggleSwitch.BorderSizePixel = 0
            ToggleSwitch.Position = UDim2.new(0.856, 0, 0.145, 0)
            ToggleSwitch.Size = UDim2.new(0, 55, 0, 24)


            ToggleSwitch.BorderSizePixel = 0
            ToggleSwitch.Position = UDim2.new(0.856, 0, 0.145, 0)
            ToggleSwitch.Size = UDim2.new(0, 55, 0, 24)

            ToggleSwitchC.CornerRadius = UDim.new(1, 8)
            ToggleSwitchC.Name = "ToggleSwitchC"
            ToggleSwitchC.Parent = ToggleSwitch

            ToggleSwitchBtn.Name = "ToggleSwitchBtn"
            ToggleSwitchBtn.Parent = ToggleSwitch
            ToggleSwitchBtn.BackgroundColor3 = theme.accent
            ToggleSwitchBtn.BorderSizePixel = 0
            ToggleSwitchBtn.Position = UDim2.new(0, 2, 0, 2)
            ToggleSwitchBtn.Size = UDim2.new(0, 20, 0, 20)

            ToggleSwitchBtnC.CornerRadius = UDim.new(1, 6)
            ToggleSwitchBtnC.Name = "ToggleSwitchBtnC"
            ToggleSwitchBtnC.Parent = ToggleSwitchBtn

            local funcs = {}

            function funcs:SetState(state, force)
                if state == nil then
                    state = not library.flags[flag]
                end

                if not force and library.flags[flag] == state then
                    return
                end

                game.TweenService:Create(
                    ToggleSwitchBtn,
                    TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                    {
                        Position = state
                            and UDim2.new(0, 33, 0, 2)
                            or  UDim2.new(0, 2, 0, 2)
                    }
                ):Play()

                game.TweenService:Create(
                    ToggleSwitch,
                    TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                    {
                        BackgroundColor3 = state and theme.accent3 or theme.secondary
                    }
                ):Play()

                library.flags[flag] = state
                callback(state)
            end

            ToggleBtn.MouseButton1Click:Connect(function()
                task.spawn(function()
                    applyRipple(ToggleBtn)
                end)
                funcs:SetState(nil) 
            end)

            local initial = library.flags[flag]
            if initial == nil then
                initial = val or false
            end
            funcs:SetState(initial, true)

            return funcs
        end


        function TabHolderObject:KeyBind(name, default, callback)
            callback = callback or function() end
            assert(name, "Name Missing")
            assert(default, "Missing Default Key")

            default = (typeof(default) == "string" and Enum.KeyCode[default] or default)

            local banned = {
                Return     = true,
                Space      = true,
                Tab        = true,
                Backquote  = true,
                CapsLock   = true,
                Escape     = true,
                Unknown    = true,
            }

            local shortNames = {
                RightControl = "Right Ctrl",
                LeftControl  = "Left Ctrl",
                LeftShift    = "Left Shift",
                RightShift   = "Right Shift",
                Semicolon    = ";",
                Quote        = '"',
                LeftBracket  = "[",
                RightBracket = "]",
                Equals       = "=",
                Minus        = "-",
                RightAlt     = "Right Alt",
                LeftAlt      = "Left Alt",
            }

            local bindKey = default
            local keyTxt = (default and (shortNames[default.Name] or default.Name) or "None")

            local KeybindFrame = Instance.new("Frame")
            local KeybindBtn = Instance.new("TextButton")
            local KeybindBtnC = Instance.new("UICorner")
            local KeybindValue = Instance.new("TextButton")
            local KeybindValueC = Instance.new("UICorner")
            local KeybindL = Instance.new("UIListLayout")
            local UIPadding = Instance.new("UIPadding")

            KeybindFrame.Name = "KeybindFrame"
            KeybindFrame.Parent = Section
            KeybindFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            KeybindFrame.BackgroundTransparency = 1
            KeybindFrame.BorderSizePixel = 0
            KeybindFrame.Size = UDim2.new(0, 428, 0, 38)

            KeybindBtn.Name = "KeybindBtn"
            KeybindBtn.Parent = KeybindFrame
            KeybindBtn.BackgroundColor3 = theme.main
            KeybindBtn.BorderSizePixel = 0
            KeybindBtn.Size = UDim2.new(0, 428, 0, 38)
            KeybindBtn.AutoButtonColor = false
            KeybindBtn.Font = Enum.Font.GothamMedium
            KeybindBtn.Text = "   " .. name
            KeybindBtn.TextColor3 = theme.accent
            KeybindBtn.TextSize = 16
            KeybindBtn.TextXAlignment = Enum.TextXAlignment.Left

            KeybindBtnC.CornerRadius = UDim.new(0, 6)
            KeybindBtnC.Name = "KeybindBtnC"
            KeybindBtnC.Parent = KeybindBtn

            KeybindValue.Name = "KeybindValue"
            KeybindValue.Parent = KeybindBtn
            KeybindValue.BackgroundColor3 = theme.secondary
            KeybindValue.BorderSizePixel = 0
            KeybindValue.Position = UDim2.new(0.763, 0, 0.289, 0)
            KeybindValue.Size = UDim2.new(0, 40, 0, 28)
            KeybindValue.AutoButtonColor = false
            KeybindValue.Font = Enum.Font.Gotham
            KeybindValue.Text = keyTxt
            KeybindValue.TextColor3 = theme.accent
            KeybindValue.TextSize = 18

            KeybindValueC.CornerRadius = UDim.new(0, 6)
            KeybindValueC.Name = "KeybindValueC"
            KeybindValueC.Parent = KeybindValue

            KeybindL.Name = "KeybindL"
            KeybindL.Parent = KeybindBtn
            KeybindL.HorizontalAlignment = Enum.HorizontalAlignment.Right
            KeybindL.SortOrder = Enum.SortOrder.LayoutOrder
            KeybindL.VerticalAlignment = Enum.VerticalAlignment.Center

            UIPadding.Parent = KeybindBtn
            UIPadding.PaddingRight = UDim.new(0, 6)

            game.UserInputService.InputBegan:Connect(function(inp, gpe)
                if gpe then return end
                if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
                if inp.KeyCode ~= bindKey then return end
                callback(bindKey.Name)
            end)

            KeybindValue.MouseButton1Click:Connect(function()
                KeybindValue.Text = "..."
                task.wait()
                local key = game.UserInputService.InputEnded:Wait()
                local keyName = tostring(key.KeyCode.Name)
                if key.UserInputType ~= Enum.UserInputType.Keyboard then
                    KeybindValue.Text = keyTxt
                    return
                end
                if banned[keyName] then
                    KeybindValue.Text = keyTxt
                    return
                end
                task.wait()
                bindKey = Enum.KeyCode[keyName]
                keyTxt = shortNames[keyName] or keyName
                KeybindValue.Text = keyTxt
            end)

            KeybindValue:GetPropertyChangedSignal("TextBounds"):Connect(function()
                KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 30, 0, 28)
            end)
            KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 30, 0, 28)
        end

        function TabHolderObject:TextBox(name, flag, default, callback)
            callback = callback or function() end
            assert(name, "Name Missing")
            assert(flag, "Flag Missing")
            assert(default, "default Missing")

            library.flags[flag] = default

            local TextboxFrame = Instance.new("Frame")
            local TextboxBack = Instance.new("TextButton")
            local TextboxBackC = Instance.new("UICorner")
            local BoxBG = Instance.new("TextButton")
            local BoxBGC = Instance.new("UICorner")
            local TextBox = Instance.new("TextBox")
            local TextboxBackL = Instance.new("UIListLayout")
            local TextboxBackP = Instance.new("UIPadding")

            TextboxFrame.Name = "TextboxFrame"
            TextboxFrame.Parent = Section
            TextboxFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TextboxFrame.BackgroundTransparency = 1
            TextboxFrame.BorderSizePixel = 0
            TextboxFrame.Size = UDim2.new(0, 428, 0, 38)

            TextboxBack.Name = "TextboxBack"
            TextboxBack.Parent = TextboxFrame
            TextboxBack.BackgroundColor3 = theme.main
            TextboxBack.BorderSizePixel = 0
            TextboxBack.Size = UDim2.new(0, 428, 0, 38)
            TextboxBack.AutoButtonColor = false
            TextboxBack.Font = Enum.Font.GothamMedium
            TextboxBack.Text = "   " .. name
            TextboxBack.TextColor3 = theme.accent
            TextboxBack.TextSize = 16
            TextboxBack.TextXAlignment = Enum.TextXAlignment.Left

            TextboxBackC.CornerRadius = UDim.new(0, 6)
            TextboxBackC.Name = "TextboxBackC"
            TextboxBackC.Parent = TextboxBack

            BoxBG.Name = "BoxBG"
            BoxBG.Parent = TextboxBack
            BoxBG.BackgroundColor3 = theme.secondary
            BoxBG.BorderSizePixel = 0
            BoxBG.Position = UDim2.new(0.763, 0, 0.289, 0)
            BoxBG.Size = UDim2.new(0, 57, 0, 28)
            BoxBG.AutoButtonColor = false
            BoxBG.Font = Enum.Font.Gotham
            BoxBG.Text = ""
            BoxBG.TextColor3 = theme.accent
            BoxBG.TextSize = 14

            BoxBGC.CornerRadius = UDim.new(0, 6)
            BoxBGC.Name = "BoxBGC"
            BoxBGC.Parent = BoxBG

            TextBox.Parent = BoxBG
            TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TextBox.BackgroundTransparency = 1
            TextBox.BorderSizePixel = 0
            TextBox.Size = UDim2.new(1, 0, 1, 0)
            TextBox.Font = Enum.Font.Gotham
            TextBox.Text = default
            TextBox.TextColor3 = theme.accent
            TextBox.TextSize = 18

            TextboxBackL.Name = "TextboxBackL"
            TextboxBackL.Parent = TextboxBack
            TextboxBackL.HorizontalAlignment = Enum.HorizontalAlignment.Right
            TextboxBackL.SortOrder = Enum.SortOrder.LayoutOrder
            TextboxBackL.VerticalAlignment = Enum.VerticalAlignment.Center

            TextboxBackP.Name = "TextboxBackP"
            TextboxBackP.Parent = TextboxBack
            TextboxBackP.PaddingRight = UDim.new(0, 6)

            TextBox.FocusLost:Connect(function()
                if TextBox.Text == "" then
                    TextBox.Text = default
                end
                library.flags[flag] = TextBox.Text
                callback(TextBox.Text)
            end)

            TextBox:GetPropertyChangedSignal("TextBounds"):Connect(function()
                BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 30, 0, 28)
            end)
            BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 30, 0, 28)
        end

        function TabHolderObject:Dropdown(name, flag, options, resettext, callback)
            callback = callback or function() end
            options = options or {}
            assert(name, "Name Missing")
            assert(flag, "Flag Missing")
            library.flags[flag] = nil

            local DropdownFrame = Instance.new("Frame")
            local DropdownTop = Instance.new("TextButton")
            local DropdownTopC = Instance.new("UICorner")
            local DropdownOpen = Instance.new("TextButton")
            local DropdownText = Instance.new("TextBox")
            local DropdownFrameL = Instance.new("UIListLayout")

            DropdownFrame.Name = "DropdownFrame"
            DropdownFrame.Parent = Section
            DropdownFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            DropdownFrame.BackgroundTransparency = 1
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.ClipsDescendants = true
            DropdownFrame.Size = UDim2.new(0, 428, 0, 38)

            DropdownTop.Name = "DropdownTop"
            DropdownTop.Parent = DropdownFrame
            DropdownTop.BackgroundColor3 = theme.main
            DropdownTop.BorderSizePixel = 0
            DropdownTop.Size = UDim2.new(0, 428, 0, 38)
            DropdownTop.AutoButtonColor = false
            DropdownTop.Font = Enum.Font.GothamMedium
            DropdownTop.Text = ""
            DropdownTop.TextColor3 = theme.accent
            DropdownTop.TextSize = 16
            DropdownTop.TextXAlignment = Enum.TextXAlignment.Left

            DropdownTopC.CornerRadius = UDim.new(0, 6)
            DropdownTopC.Name = "DropdownTopC"
            DropdownTopC.Parent = DropdownTop

            DropdownOpen.Name = "DropdownOpen"
            DropdownOpen.Parent = DropdownTop
            DropdownOpen.AnchorPoint = Vector2.new(0, 0.5)
            DropdownOpen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            DropdownOpen.BackgroundTransparency = 1
            DropdownOpen.BorderSizePixel = 0
            DropdownOpen.Position = UDim2.new(0.918, 0, 0.5, 0)
            DropdownOpen.Size = UDim2.new(0, 20, 0, 20)
            DropdownOpen.Font = Enum.Font.Gotham
            DropdownOpen.Text = "+"
            DropdownOpen.TextColor3 = theme.accent3
            DropdownOpen.TextSize = 24
            DropdownOpen.TextWrapped = true

            DropdownText.Name = "DropdownText"
            DropdownText.Parent = DropdownTop
            DropdownText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            DropdownText.BackgroundTransparency = 1
            DropdownText.BorderSizePixel = 0
            DropdownText.Position = UDim2.new(0, 0, 0, 0)
            DropdownText.Size = UDim2.new(0, 184, 0, 38)
            DropdownText.Font = Enum.Font.GothamMedium
            DropdownText.PlaceholderColor3 = Color3.fromRGB(255, 255, 255)
            DropdownText.Text = "   " .. name
            DropdownText.TextColor3 = theme.accent
            DropdownText.TextSize = 16
            DropdownText.TextXAlignment = Enum.TextXAlignment.Left

            DropdownFrameL.Name = "DropdownFrameL"
            DropdownFrameL.Parent = DropdownFrame
            DropdownFrameL.SortOrder = Enum.SortOrder.LayoutOrder
            DropdownFrameL.Padding = UDim.new(0, 4)

            local function showAllDropdownOptions()
                for _, option in ipairs(DropdownFrame:GetChildren()) do
                    if option:IsA("TextButton") and option.Name:match("Option_") then
                        option.Visible = true
                    end
                end
            end

            local function filterDropdownOptions(text)
                for _, option in ipairs(DropdownFrame:GetChildren()) do
                    if option:IsA("TextButton") and option.Name:match("Option_") then
                        if text == "" then
                            option.Visible = true
                        else
                            option.Visible = option.Text:lower():match(text:lower()) ~= nil
                        end
                    end
                end
            end

            local open = false
            local function toggleDropdownList()
                open = not open
                if open then showAllDropdownOptions() end
                DropdownOpen.Text = (open and "-" or "+")
                DropdownFrame.Size = UDim2.new(
                    0,
                    428,
                    0,
                    (open and DropdownFrameL.AbsoluteContentSize.Y + 4 or 38)
                )
            end

            DropdownOpen.MouseButton1Click:Connect(toggleDropdownList)
            DropdownText.Focused:Connect(function()
                if open then return end
                toggleDropdownList()
            end)

            local prefix = "   "

            DropdownText:GetPropertyChangedSignal("Text"):Connect(function()
                if not open then return end

                if not DropdownText.Text:find("^" .. prefix) then
                    DropdownText.Text = prefix .. DropdownText.Text:gsub("^%s*", "")
                    DropdownText.CursorPosition = #DropdownText.Text + 1
                    return
                end

                local searchText = DropdownText.Text:sub(#prefix + 1)
                filterDropdownOptions(searchText)
            end)

            DropdownFrameL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if not open then return end
                DropdownFrame.Size = UDim2.new(
                    0,
                    428,
                    0,
                    (DropdownFrameL.AbsoluteContentSize.Y + 4)
                )
            end)

            local funcs = {}

            function funcs:AddOption(option)
                local Option = Instance.new("TextButton")
                local OptionC = Instance.new("UICorner")

                Option.Name = "Option_" .. option
                Option.Parent = DropdownFrame
                Option.BackgroundColor3 = theme.main
                Option.BorderSizePixel = 0
                Option.Size = UDim2.new(0, 428, 0, 26)
                Option.AutoButtonColor = false
                Option.Font = Enum.Font.Gotham
                Option.Text = option
                Option.TextColor3 = theme.accent
                Option.TextSize = 14

                OptionC.CornerRadius = UDim.new(0, 6)
                OptionC.Name = "OptionC"
                OptionC.Parent = Option

                Option.MouseButton1Click:Connect(function()
                    toggleDropdownList()
                    callback(Option.Text)
                    if not resettext then
                        DropdownText.Text = Option.Text
                    end
                    library.flags[flag] = Option.Text
                end)
            end

            function funcs:SetOptions(opts)
                for _, v in ipairs(DropdownFrame:GetChildren()) do
                    if v.Name:match("Option_") then
                        v:Destroy()
                    end
                end
                for _, v in ipairs(opts) do
                    funcs:AddOption(v)
                end
            end

            funcs:SetOptions(options)

            return funcs
        end

        function TabHolderObject:Slider(name, flag, default, min, max, precise, callback)
            callback = callback or function() end
            min = min or 1
            max = max or 100
            default = default or min
            precise = precise or false
            library.flags[flag] = default
            assert(name, "Name Missing")
            assert(flag, "Flag Missing")

            local SliderFrame = Instance.new("Frame")
            local SliderBack = Instance.new("TextButton")
            local SliderBackC = Instance.new("UICorner")
            local SliderBar = Instance.new("Frame")
            local SliderBarC = Instance.new("UICorner")
            local SliderPart = Instance.new("Frame")
            local SliderPartC = Instance.new("UICorner")
            local SliderValBG = Instance.new("TextButton")
            local SliderValBGC = Instance.new("UICorner")
            local SliderValue = Instance.new("TextBox")
            local MinSlider = Instance.new("TextButton")
            local AddSlider = Instance.new("TextButton")

            SliderFrame.Name = "SliderFrame"
            SliderFrame.Parent = Section
            SliderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SliderFrame.BackgroundTransparency = 1
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Size = UDim2.new(0, 428, 0, 38)

            SliderBack.Name = "SliderBack"
            SliderBack.Parent = SliderFrame
            SliderBack.BackgroundColor3 = theme.main
            SliderBack.BorderSizePixel = 0
            SliderBack.Size = UDim2.new(0, 428, 0, 38)
            SliderBack.AutoButtonColor = false
            SliderBack.Font = Enum.Font.GothamMedium
            SliderBack.Text = "   " .. name
            SliderBack.TextColor3 = theme.accent
            SliderBack.TextSize = 16
            SliderBack.TextXAlignment = Enum.TextXAlignment.Left

            SliderBackC.CornerRadius = UDim.new(0, 6)
            SliderBackC.Name = "SliderBackC"
            SliderBackC.Parent = SliderBack

            SliderBar.Name = "SliderBar"
            SliderBar.Parent = SliderBack
            SliderBar.AnchorPoint = Vector2.new(0, 0.5)
            SliderBar.BackgroundColor3 = theme.secondary
            SliderBar.BorderSizePixel = 0
            SliderBar.Position = UDim2.new(0.369, 40, 0.5, 0)
            SliderBar.Size = UDim2.new(0, 140, 0, 12)

            SliderBarC.CornerRadius = UDim.new(0, 4)
            SliderBarC.Name = "SliderBarC"
            SliderBarC.Parent = SliderBar

            SliderPart.Name = "SliderPart"
            SliderPart.Parent = SliderBar
            SliderPart.BackgroundColor3 = theme.accent3
            SliderPart.BorderSizePixel = 0
            SliderPart.Size = UDim2.new(0, 0, 1, 0)

            SliderPartC.CornerRadius = UDim.new(0, 4)
            SliderPartC.Name = "SliderPartC"
            SliderPartC.Parent = SliderPart

            SliderValBG.Name = "SliderValBG"
            SliderValBG.Parent = SliderBack
            SliderValBG.BackgroundColor3 = theme.secondary
            SliderValBG.BorderSizePixel = 0
            SliderValBG.Position = UDim2.new(0.883, 0, 0.132, 0)
            SliderValBG.Size = UDim2.new(0, 44, 0, 28)
            SliderValBG.AutoButtonColor = false
            SliderValBG.Font = Enum.Font.Gotham
            SliderValBG.Text = ""
            SliderValBG.TextColor3 = theme.accent
            SliderValBG.TextSize = 14

            SliderValBGC.CornerRadius = UDim.new(0, 6)
            SliderValBGC.Name = "SliderValBGC"
            SliderValBGC.Parent = SliderValBG

            SliderValue.Name = "SliderValue"
            SliderValue.Parent = SliderValBG
            SliderValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SliderValue.BackgroundTransparency = 1
            SliderValue.BorderSizePixel = 0
            SliderValue.Size = UDim2.new(1, 0, 1, 0)
            SliderValue.Font = Enum.Font.Gotham
            SliderValue.Text = tostring(default)
            SliderValue.TextColor3 = theme.accent
            SliderValue.TextSize = 18

            MinSlider.Name = "MinSlider"
            MinSlider.Parent = SliderFrame
            MinSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            MinSlider.BackgroundTransparency = 1
            MinSlider.BorderSizePixel = 0
            MinSlider.Position = UDim2.new(0.2967, 40, 0.237, 0)
            MinSlider.Size = UDim2.new(0, 20, 0, 20)
            MinSlider.Font = Enum.Font.Gotham
            MinSlider.Text = "-"
            MinSlider.TextColor3 = theme.accent
            MinSlider.TextSize = 24
            MinSlider.TextWrapped = true

            AddSlider.Name = "AddSlider"
            AddSlider.Parent = SliderFrame
            AddSlider.AnchorPoint = Vector2.new(0, 0.5)
            AddSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            AddSlider.BackgroundTransparency = 1
            AddSlider.BorderSizePixel = 0
            AddSlider.Position = UDim2.new(0.8109, 0, 0.5, 0)
            AddSlider.Size = UDim2.new(0, 20, 0, 20)
            AddSlider.Font = Enum.Font.Gotham
            AddSlider.Text = "+"
            AddSlider.TextColor3 = theme.accent
            AddSlider.TextSize = 24
            AddSlider.TextWrapped = true

            local funcs = {}

            function funcs:SetValue(value)
                local percent = (mouse.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X
                if value then
                    percent = (value - min) / (max - min)
                end
                percent = math.clamp(percent, 0, 1)
                if precise then
                    value = value or tonumber(string.format("%.1f", tostring(min + (max - min) * percent)))
                else
                    value = value or math.floor(min + (max - min) * percent)
                end
                library.flags[flag] = tonumber(value)
                SliderValue.Text = tostring(value)
                SliderPart.Size = UDim2.new(percent, 0, 1, 0)
                callback(tonumber(value))
            end

            function funcs:SetMin(newMin)
                min = newMin or min
            end

            function funcs:SetMax(newMax)
                max = newMax or max
            end

            MinSlider.MouseButton1Click:Connect(function()
                local currentValue = library.flags[flag]
                currentValue = math.clamp(currentValue - 1, min, max)
                funcs:SetValue(currentValue)
            end)

            AddSlider.MouseButton1Click:Connect(function()
                local currentValue = library.flags[flag]
                currentValue = math.clamp(currentValue + 1, min, max)
                funcs:SetValue(currentValue)
            end)

            funcs:SetValue(default)

            local dragging, boxFocused
            local allowed = {
                [""] = true,
                ["-"] = true,
            }

            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    funcs:SetValue()
                    dragging = true
                end
            end)

            game.UserInputService.InputEnded:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            game.UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    funcs:SetValue()
                end
            end)

            SliderValue.Focused:Connect(function()
                boxFocused = true
            end)

            SliderValue.FocusLost:Connect(function()
                boxFocused = false
                if SliderValue.Text == "" then
                    funcs:SetValue(default)
                end
            end)

            SliderValue:GetPropertyChangedSignal("Text"):Connect(function()
                if not boxFocused then return end
                SliderValue.Text = SliderValue.Text:gsub("%D+", "")

                local text = SliderValue.Text
                if not tonumber(text) then
                    SliderValue.Text = SliderValue.Text:gsub("%D+", "")
                elseif not allowed[text] then
                    if tonumber(text) > max then
                        text = max
                        SliderValue.Text = tostring(max)
                    end
                    funcs:SetValue(tonumber(text))
                end
            end)

            return funcs
        end

        return TabHolderObject
    end

    return Holder
end


local keys, network = loadstring(game:HttpGet("https://raw.githubusercontent.com/JJE0909/serenity/refs/heads/main/jailbreak-dumper"))()

local tagUtils = require(game:GetService("ReplicatedStorage").Tag.TagUtils)

local oldIsPointInTag = tagUtils.isPointInTag
tagUtils.isPointInTag = function(point, tag)
    if tag == "NoRagdoll" or tag == "NoFallDamage" or tag == "NoParachute" then
        return true
    end
    return oldIsPointInTag(point, tag)
end

local oldFireServer = getupvalue(network.FireServer, 1)
setupvalue(network.FireServer, 1, function(key, ...)
    if key == keys.Damage then
        return
    end
    return oldFireServer(key, ...)
end)

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local Workspace        = game:GetService("Workspace")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local HttpService      = game:GetService("HttpService")

local TeleportService  = game:GetService("TeleportService")

local CONFIG_FILE              = "Serenity_Jailbreak_Config.json"
local DEFAULT_MIN_BOUNTY       = 0
local LastLoggedTarget         = nil


local LastTargetScan           = { count = 0, maxBounty = 0, time = 0 }
local LastTargetSeenTime       = tick()
local LastHopTime              = 0
local LastHopCheckTime         = 0
local HOP_COOLDOWN             = 30 

local CurrentTarget            = nil
local TargetLinePart           = nil
local TargetLineConnection     = nil


local DEFAULT_NO_CAR_RADIUS    = 400
local DEFAULT_HOP_NO_TARGETS   = 180 
local DEFAULT_HOP_MAX_BOUNTY   = 0 
local DEFAULT_HOP_MIN_PLAYERS  = 0

local LastTargetScan           = { count = 0, maxBounty = 0, time = 0 }
local LastTargetSeenTime       = tick()
local LastHopTime              = 0
local LastHopCheckTime         = 0
local HOP_COOLDOWN             = 30

local CurrentTarget            = nil
local TargetLinePart           = nil
local TargetLineConnection     = nil



local POP_TIRES_STABLE_KEY     = keys.PopTires
local JOIN_TEAM_STABLE_KEY     = keys.JoinTeam
local ARREST_STABLE_KEY        = keys.Arrest
local VEHICLE_ENTRY_STABLE_KEY = keys.EnterCar
local VEHICLE_EXIT_STABLE_KEY  = keys.ExitCar
local VEHICLE_EJECT_STABLE_KEY = keys.Eject
local redeemCode               = keys.RedeemCode

local HOVER_HEIGHT             = 700       
local MIN_HEIGHT_ABOVE_GROUND  = 5
local DROP_OFFSET_STUDS        = 5
local FLY_SPEED_CAR            = 450
local FLY_SPEED_FOOT           = 100
local ROOF_RAYCAST_HEIGHT      = 500
local JAIL_TELEPORT_DIST       = 10000
local TELEPORT_JUMP_THRESHOLD  = 500

local MAX_HORIZONTAL_SPEED     = 1000
local HOVER_ADJUST_SPEED       = 50
local VERTICAL_SNAP_THRESHOLD  = 5

local MAX_VEHICLE_RETRIES      = 5
local MAX_ARREST_RETRIES       = 3
local STUCK_TIMEOUT            = 5
local RETRY_COOLDOWN           = 1

local COVERAGE_CHECK_INTERVAL  = 0.1
local MAX_COVERED_TIME         = 5

local ARREST_CHASE_RANGE       = 20
local ARREST_LOOP_DELAY        = 0.1
local SHOOT_COOLDOWN           = 0.15

local ALLOWED_VEHICLES = {
    Jeep   = true,
    Camaro = true,
}

local SPAWN_PATHS = {
    [Vector3.new(-1189, 19, -1581)] = {
        Vector3.new(-1173, 20, -1581),
        Vector3.new(-1171, 21, -1627),
    },
    [Vector3.new(-1169, 19, -1583)] = {
        Vector3.new(-1173, 19, -1584),
        Vector3.new(-1171, 21, -1627),
    },
    [Vector3.new(-1177, 19, -1579)] = {
        Vector3.new(-1173, 20, -1581),
        Vector3.new(-1171, 21, -1627),
    },
    [Vector3.new(-1165, 19, -1580)] = {
        Vector3.new(-1173, 20, -1581),
        Vector3.new(-1171, 21, -1627),
    },
    [Vector3.new(-1173, 39, -1582)] = {
        Vector3.new(-1159, 40, -1581),
        Vector3.new(-1154, 40, -1566),
        Vector3.new(-1130, 41, -1566),
    },
    [Vector3.new(-1121, 19, -1586)] = {
        Vector3.new(-1173, 20, -1587),
        Vector3.new(-1171, 21, -1627),
    },
    [Vector3.new(-1263, 19, -1549)] = {
        Vector3.new(-1263, 20, -1537),
    },
    [Vector3.new(-1145, 19, -1572)] = {
        Vector3.new(-1173, 20, -1573),
        Vector3.new(-1171, 21, -1627),
    },
    [Vector3.new(764, 20, -3346)] = {
        Vector3.new(763, 21, -3341),
        Vector3.new(780, 21, -3340),
        Vector3.new(782, 21, -3348),
        Vector3.new(807, 22, -3337),
    },
    [Vector3.new(742, 39, 1133)] = {
        Vector3.new(739, 40, 1134),
        Vector3.new(733, 40, 1106),
        Vector3.new(720, 41, 1067),
    },
    [Vector3.new(783, 20, -3351)] = {
        Vector3.new(782, 20, -3348),
        Vector3.new(805, 20, -3338),
    },
}

local SPAWN_PATH_TOLERANCE = 5

local LocalPlayer         = Players.LocalPlayer
local Remote              = nil
local KeyMap              = {}
local AutoArrestEnabled   = false
local CurrentVehicle      = nil
local ActionInProgress    = false
local MainLoopConnection  = nil
local TargetPositionHistory = {}
local ExitedCarRef        = nil

local VehicleRetryCount   = 0
local ArrestRetryCount    = 0
local LastActionTime      = 0
local StuckCheckPosition  = nil

local oldRayCast          = nil
local shootTarget         = nil

local CoverageThread      = nil
local TargetCoveredStartTime = nil
local UnderRoofStartTime   = nil
local SelfCoveredStartTime   = nil
local IsExecutingSpawnPath   = false

local v3new = Vector3.new
local cfNew = CFrame.new
local heartbeat = RunService.Heartbeat
local stepped   = RunService.Stepped


do
    local found = false
    for _, v in getgc(false) do
        if typeof(v) == "function" and islclosure(v) and debug.info(v, "n") == "EventFireServer" then
            local ups = debug.getupvalues(v)
            if #ups >= 3 and typeof(ups[2]) == "Instance" and type(ups[3]) == "table" then
                local rawTable = ups[3]
                if rawTable[redeemCode] then
                    Remote = ups[2]
                    for shortKey, uuid in pairs(rawTable) do
                        if type(shortKey) == "string" and type(uuid) == "string" then
                            KeyMap[shortKey] = uuid
                        end
                    end
                    found = true
                    break
                end
            end
        end
    end
    if not found then
        warn("Debug: KEYS NOT FOUND - SCRIPT WILL LIKELY FAIL")
    end
end

local joinKey = KeyMap[JOIN_TEAM_STABLE_KEY]
if joinKey then
    Remote:FireServer(joinKey, "Police")
end



local function getRootPart()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function getCharacterHumanoid()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
end

local function resetPartVelocity(part)
    if part then
        part.Velocity = Vector3.zero
        part.RotVelocity = Vector3.zero
        if part.AssemblyLinearVelocity then
            part.AssemblyLinearVelocity = Vector3.zero
        end
    end
end

local function readBountyData()
    local bountyDataValue = ReplicatedStorage:FindFirstChild("BountyData")
    if bountyDataValue and bountyDataValue:IsA("StringValue") then
        local success, data = pcall(function()
            return HttpService:JSONDecode(bountyDataValue.Value)
        end)
        if success and data then
            return data
        end
    end
    return {}
end

local function getPlayerBountyAmount(playerName)
    local bountyData = readBountyData()
    for _, entry in ipairs(bountyData) do
        if entry.Name == playerName then
            return entry.Bounty or 0
        end
    end
    return 0
end

local function hasPlayerLeftPrison(player)
    if not player then return true end

    local hasEscapedValue = player:FindFirstChild("HasEscaped")
    if hasEscapedValue then
        if hasEscapedValue:IsA("BoolValue") then
            return hasEscapedValue.Value
        elseif hasEscapedValue:IsA("ValueBase") then
            return hasEscapedValue.Value
        end
    end

    local escapedAttr = player:GetAttribute("HasEscaped")
    if escapedAttr ~= nil then
        return escapedAttr
    end

    return true
end

local function getSafeHeightAboveGround(position)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, CurrentVehicle}

    local ray = Workspace:Raycast(position, Vector3.new(0, -500, 0), raycastParams)
    if ray then
        return math.max(ray.Position.Y + MIN_HEIGHT_ABOVE_GROUND, position.Y)
    end

    return position.Y
end

local function isPositionUnderCover(position, targetPlayer)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local excludeList = {LocalPlayer.Character}

    if targetPlayer and targetPlayer.Character then
        table.insert(excludeList, targetPlayer.Character)
    end

    local vFolder = Workspace:FindFirstChild("Vehicles")
    if vFolder then
        for _, vehicle in ipairs(vFolder:GetChildren()) do
            table.insert(excludeList, vehicle)
        end
    end

    raycastParams.FilterDescendantsInstances = excludeList
    raycastParams.IgnoreWater = true

    local startPosition = position + Vector3.new(0, 5, 0)
    local ray = Workspace:Raycast(startPosition, Vector3.new(0, ROOF_RAYCAST_HEIGHT, 0), raycastParams)
    return ray ~= nil
end

local function isLocalPlayerUnderCover()
    local root = getRootPart()
    if not root then return false end

    local partsToExclude = {LocalPlayer.Character}

    if CurrentVehicle then
        table.insert(partsToExclude, CurrentVehicle)
    end

    if ExitedCarRef then
        table.insert(partsToExclude, ExitedCarRef)
    end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = partsToExclude
    raycastParams.IgnoreWater = true

    local startPosition = root.Position + Vector3.new(0, 2, 0)
    local ray = Workspace:Raycast(startPosition, Vector3.new(0, ROOF_RAYCAST_HEIGHT, 0), raycastParams)

    return ray ~= nil
end

local function setVelocityTowards(targetPos, speed, moverPart)
    if not moverPart or not moverPart.Parent then return end

    local currentPos = moverPart.Position
    local direction = (targetPos - currentPos)
    local dist = direction.Magnitude

    if dist > 1 then
        local unitDir = direction.Unit
        moverPart.AssemblyLinearVelocity = unitDir * speed
    else
        moverPart.AssemblyLinearVelocity = Vector3.zero
    end
end

local function getNearestSpawnPath()
    local root = getRootPart()
    if not root then return nil end

    local myPos = root.Position
    local closestPath = nil
    local closestDist = SPAWN_PATH_TOLERANCE

    for spawnPos, waypoints in pairs(SPAWN_PATHS) do
        local dist = (v3new(myPos.X, spawnPos.Y, myPos.Z) - spawnPos).Magnitude
        if dist < closestDist then
            closestDist = dist
            closestPath = waypoints
        end
    end

    return closestPath
end

local function snapVerticalPosition(targetPos)
    local root = getRootPart()
    local hum  = getCharacterHumanoid()
    if not root or not hum then return end

    local moverPart = CurrentVehicle and CurrentVehicle.PrimaryPart or root
    if not moverPart or not moverPart.Parent then return end

    local currentCFrame = moverPart.CFrame
    local targetY = targetPos.Y

    if math.abs(currentCFrame.Position.Y - targetY) > VERTICAL_SNAP_THRESHOLD then
        local newCFrame = cfNew(currentCFrame.X, targetY, currentCFrame.Z) * currentCFrame.Rotation
        if CurrentVehicle and CurrentVehicle.PrimaryPart and CurrentVehicle.PrimaryPart.Parent and hum.Sit then
            CurrentVehicle:SetPrimaryPartCFrame(newCFrame)
        else
            root.CFrame = newCFrame
        end
        resetPartVelocity(moverPart)
    end
end

local function runSpawnPathWaypoints(waypoints)
    if IsExecutingSpawnPath then return end
    IsExecutingSpawnPath = true

    local root = getRootPart()
    local hum = getCharacterHumanoid()
    if not root or not hum then
        IsExecutingSpawnPath = false
        return
    end

    local noclipConn = stepped:Connect(function()
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)

    for _, waypoint in ipairs(waypoints) do
        local startTime = tick()
        local WAYPOINT_TIMEOUT = 10

        while true do
            root = getRootPart()
            if not root or not root.Parent then break end

            local dist = (root.Position - waypoint).Magnitude
            if dist < 5 then break end
            if (tick() - startTime) > WAYPOINT_TIMEOUT then break end

            local direction = (waypoint - root.Position).Unit
            root.AssemblyLinearVelocity = direction * FLY_SPEED_FOOT

            task.wait()
        end

        root = getRootPart()
        if root then
            resetPartVelocity(root)
        end
    end

    if noclipConn then
        noclipConn:Disconnect()
    end

    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end

    root = getRootPart()
    if root then
        snapVerticalPosition(v3new(root.Position.X, HOVER_HEIGHT, root.Position.Z))
    end

    IsExecutingSpawnPath = false
end

local function resetLocalCharacter()
    local hum = getCharacterHumanoid()
    if hum then
        hum.Health = 0
    end
end

local function canEscapeRoofCover()
    local root = getRootPart()
    if not root then return false end

    local spawnPath = getNearestSpawnPath()
    if spawnPath then
        return true
    end

    local checkDirections = {
        Vector3.new(1, 0, 0),
        Vector3.new(-1, 0, 0),
        Vector3.new(0, 0, 1),
        Vector3.new(0, 0, -1),
        Vector3.new(1, 0, 1).Unit,
        Vector3.new(-1, 0, 1).Unit,
        Vector3.new(1, 0, -1).Unit,
        Vector3.new(-1, 0, -1).Unit,
    }

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, CurrentVehicle}
    raycastParams.IgnoreWater = true

    for _, dir in ipairs(checkDirections) do
        local checkPos = root.Position + (dir * 50)
        local upRay = Workspace:Raycast(
            checkPos + Vector3.new(0, 1, 0),
            Vector3.new(0, ROOF_RAYCAST_HEIGHT, 0),
            raycastParams
        )
        if not upRay then
            return true
        end
    end

    return false
end

local function moveToWorldPosition(targetPos, isCar)
    local root = getRootPart()
    if not root then return end

    if isLocalPlayerUnderCover() then
        local spawnPath = getNearestSpawnPath()
        if spawnPath then
            runSpawnPathWaypoints(spawnPath)
            task.wait(1)
            return
        end
    end

    local moverPart = root
    local speed = isCar and FLY_SPEED_CAR or FLY_SPEED_FOOT

    if isCar and CurrentVehicle and CurrentVehicle.PrimaryPart and CurrentVehicle.PrimaryPart.Parent then
        moverPart = CurrentVehicle.PrimaryPart
    elseif isCar then
        return
    end

    if not moverPart or not moverPart.Parent then return end

    local currentPos = moverPart.Position
    local distXZ = (v3new(currentPos.X, 0, currentPos.Z) - v3new(targetPos.X, 0, targetPos.Z)).Magnitude
    local targetY = HOVER_HEIGHT

    local desiredVelocityX = 0
    local desiredVelocityZ = 0

    if distXZ > 5 then
        local directionXZ = (v3new(targetPos.X, 0, targetPos.Z) - v3new(currentPos.X, 0, currentPos.Z)).Unit
        local horizontalSpeed = math.min(speed, MAX_HORIZONTAL_SPEED)
        desiredVelocityX = directionXZ.X * horizontalSpeed
        desiredVelocityZ = directionXZ.Z * horizontalSpeed
    end

    local yError = targetY - currentPos.Y
    local verticalSpeed = yError * 5 + math.sign(yError) * 10
    local desiredVelocityY = math.clamp(verticalSpeed, -HOVER_ADJUST_SPEED, HOVER_ADJUST_SPEED)

    moverPart.AssemblyLinearVelocity = v3new(desiredVelocityX, desiredVelocityY, desiredVelocityZ)

    if math.abs(yError) > VERTICAL_SNAP_THRESHOLD then
        snapVerticalPosition(v3new(currentPos.X, targetY, currentPos.Z))
    end
end


local FOOT_SPEED        = 100
local FOOT_LERP_ALPHA   = 0.7
local FOOT_MAX_VERTICAL = 120
local FOOT_HOVER_OFFSET = 3

local function stepTowardsOnFoot(targetPos, root)
    if not root or not root.Parent then return end

    local safeY = getSafeHeightAboveGround(targetPos)
    targetPos = Vector3.new(targetPos.X, math.max(targetPos.Y + FOOT_HOVER_OFFSET, safeY + FOOT_HOVER_OFFSET), targetPos.Z)

    local pos  = root.Position
    local diff = targetPos - pos
    local dist = diff.Magnitude

    if dist < 0.5 then
        local v = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(v.X * 0.5, v.Y * 0.5, v.Z * 0.5)
        return
    end

    local horizDiff = Vector3.new(diff.X, 0, diff.Z)
    local horizDist = horizDiff.Magnitude
    if horizDist <= 0 then return end

    local horizDir     = horizDiff.Unit
    local currentVel   = root.AssemblyLinearVelocity
    local currentHoriz = Vector3.new(currentVel.X, 0, currentVel.Z)

    local desiredSpeed = FOOT_SPEED
    if dist < 15 then
        desiredSpeed = FOOT_SPEED * (dist / 15)
    end

    local targetHoriz = horizDir * desiredSpeed
    local newHoriz = currentHoriz:Lerp(targetHoriz, FOOT_LERP_ALPHA)

    local targetYVel = math.clamp(diff.Y * 5, -FOOT_MAX_VERTICAL, FOOT_MAX_VERTICAL)
    root.AssemblyLinearVelocity = Vector3.new(newHoriz.X, targetYVel, newHoriz.Z)
end




local function resetAutoArrestState()
    local root = getRootPart()
    local hum = getCharacterHumanoid()
    if not root or not hum then
        CurrentVehicle = nil
        ActionInProgress = false
        return
    end

    if CurrentVehicle then
        if not CurrentVehicle.PrimaryPart or not CurrentVehicle.Parent then
            CurrentVehicle = nil
            VehicleRetryCount += 1

            if hum.Sit then
                local key = KeyMap[VEHICLE_EXIT_STABLE_KEY]
                if key then Remote:FireServer(key) end
                task.wait(0.05)
            end
            snapVerticalPosition(v3new(root.Position.X, HOVER_HEIGHT, root.Position.Z))
            ActionInProgress = false
            return
        end
    end

    if hum.Sit and not CurrentVehicle then
        local key = KeyMap[VEHICLE_EXIT_STABLE_KEY]
        if key then Remote:FireServer(key) end
        task.wait(0.05)
        snapVerticalPosition(v3new(root.Position.X, HOVER_HEIGHT, root.Position.Z))
        ActionInProgress = false
        return
    end

    if StuckCheckPosition and ActionInProgress then
        local dist = (root.Position - StuckCheckPosition).Magnitude
        if dist < 1 and (tick() - LastActionTime) > STUCK_TIMEOUT then
            ActionInProgress = false
            CurrentVehicle = nil

            if hum.Sit then
                local key = KeyMap[VEHICLE_EXIT_STABLE_KEY]
                if key then Remote:FireServer(key) end
                task.wait(0.05)
            end

            snapVerticalPosition(v3new(root.Position.X, HOVER_HEIGHT, root.Position.Z))
            StuckCheckPosition = nil
            return
        end
    end

    StuckCheckPosition = root.Position
    LastActionTime = tick()
end

local function getClosestVehicleNearPlayer(player)
    if not player or not player.Character then return nil end
    local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
    if not playerRoot then return nil end

    local vFolder = Workspace:FindFirstChild("Vehicles")
    if not vFolder then return nil end

    local closest, dist = nil, 120

    for _, vehicle in ipairs(vFolder:GetChildren()) do
        if vehicle ~= ExitedCarRef then
            local prim = vehicle.PrimaryPart
            if prim and prim.Parent then
                local d = (playerRoot.Position - prim.Position).Magnitude
                if d < dist then
                    closest = vehicle
                    dist = d
                end
            end
        end
    end

    return closest
end

local function getVehicleTargetPart(player)
    if not player or not player.Character then return nil end
    local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
    if not playerRoot then return nil end

    local vFolder = Workspace:FindFirstChild("Vehicles")
    if not vFolder then return nil end

    local closest, dist = nil, 30

    for _, v in ipairs(vFolder:GetChildren()) do
        if v ~= ExitedCarRef then
            local part = v.PrimaryPart
                or (v:FindFirstChild("Body") and v.Body:FindFirstChild("Vehicle"))
                or v:FindFirstChildWhichIsA("BasePart")
            if part then
                local d = (part.Position - playerRoot.Position).Magnitude
                if d < dist then
                    closest = part
                    dist = d
                end
            end
        end
    end

    return closest
end

local function getClosestAllowedVehicle()
    local root = getRootPart()
    local vFolder = Workspace:FindFirstChild("Vehicles")
    if not root or not vFolder then return nil end

    local closest, dist = nil, 99999

    for _, vehicle in ipairs(vFolder:GetChildren()) do
        if ALLOWED_VEHICLES[vehicle.Name] then
            local seat = vehicle:FindFirstChild("Seat")
            local prim = vehicle.PrimaryPart

            if seat and prim and prim.Parent then
                local isAvailable = not vehicle:GetAttribute("Locked") and not vehicle:GetAttribute("VehicleHasDriver")
                if isAvailable then
                    local d = (root.Position - prim.Position).Magnitude
                    if d < dist and prim.CFrame.UpVector.Y > 0.1 and not isPositionUnderCover(prim.Position, nil) then
                        closest = vehicle
                        dist = d
                    end
                end
            end
        end
    end

    return closest
end

local function enterVehicleFlow(vehicle)
    ActionInProgress = true
    library:LogStatus("Moving to vehicle: " .. (vehicle and vehicle.Name or "Unknown"))


    local root = getRootPart()
    local prim = vehicle.PrimaryPart

    if not root or not prim or not prim.Parent then
        ActionInProgress = false
        CurrentVehicle = nil
        VehicleRetryCount += 1
        return false
    end

    if isLocalPlayerUnderCover() then
        local spawnPath = getNearestSpawnPath()
        if spawnPath then
            runSpawnPathWaypoints(spawnPath)
            task.wait(1)
        elseif not canEscapeRoofCover() then
            resetLocalCharacter()
            ActionInProgress = false
            return false
        end
    end

    snapVerticalPosition(v3new(root.Position.X, HOVER_HEIGHT, root.Position.Z))

    local t = tick()
    while (v3new(root.Position.X, 0, root.Position.Z) - v3new(prim.Position.X, 0, prim.Position.Z)).Magnitude > 10
        and (tick() - t) < 10 do

        prim = vehicle.PrimaryPart
        if not prim or not prim.Parent then
            ActionInProgress = false
            CurrentVehicle = nil
            VehicleRetryCount += 1
            return false
        end

        local targetPosXZ = v3new(prim.Position.X, HOVER_HEIGHT, prim.Position.Z)
        moveToWorldPosition(targetPosXZ, false)
        task.wait()
        root = getRootPart()
        if not root then break end
    end

    prim = vehicle.PrimaryPart
    if not prim or not prim.Parent then
        ActionInProgress = false
        CurrentVehicle = nil
        VehicleRetryCount += 1
        return false
    end

    local safeEntryHeight = math.max(prim.Position.Y + DROP_OFFSET_STUDS, getSafeHeightAboveGround(prim.Position))
    snapVerticalPosition(v3new(prim.Position.X, safeEntryHeight, prim.Position.Z))

    local key = KeyMap[VEHICLE_ENTRY_STABLE_KEY]
    if key then
        for _ = 1, 5 do
            if not vehicle.PrimaryPart or not vehicle.PrimaryPart.Parent then
                ActionInProgress = false
                CurrentVehicle = nil
                VehicleRetryCount += 1
                return false
            end
            Remote:FireServer(key, vehicle, vehicle.Seat)
            if getCharacterHumanoid() and getCharacterHumanoid().Sit then break end
            task.wait(0.1)
        end
    end

    task.wait(0.1)

    local hum = getCharacterHumanoid()
    if hum and hum.Sit and vehicle.PrimaryPart and vehicle.PrimaryPart.Parent then
        CurrentVehicle = vehicle
        library:LogStatus("Entered vehicle: " .. tostring(vehicle.Name))

        VehicleRetryCount = 0
        snapVerticalPosition(v3new(vehicle.PrimaryPart.Position.X, HOVER_HEIGHT, vehicle.PrimaryPart.Position.Z))
        ActionInProgress = false
        return true
    else
        CurrentVehicle = nil
        VehicleRetryCount += 1
        root = getRootPart()
        if root then
            snapVerticalPosition(v3new(root.Position.X, HOVER_HEIGHT, root.Position.Z))
        end
        ActionInProgress = false
        return false
    end
end

local function exitVehicleFlow()
    local hum = getCharacterHumanoid()
    if not CurrentVehicle or not hum or not hum.Sit then return end

    local key = KeyMap[VEHICLE_EXIT_STABLE_KEY]
    if key then
        Remote:FireServer(key)
    end
    task.wait()
    ExitedCarRef = CurrentVehicle
    CurrentVehicle = nil
end

local function selectBestTarget()
    local root = getRootPart()
    local now  = tick()

    if not root then
        LastTargetScan.count     = 0
        LastTargetScan.maxBounty = 0
        LastTargetScan.time      = now
        return nil
    end

    local rootPos      = root.Position
    local minBounty    = tonumber(library.flags.MinBounty) or DEFAULT_MIN_BOUNTY
    local priorityMode = library.flags.TargetPriorityMode or "Default"

    local validTargets = {}
    local maxBounty    = 0

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team and (p.Team.Name == "Criminal" or p.Team.Name == "Prisoner") then
            local char  = p.Character
            local tRoot = char and char:FindFirstChild("HumanoidRootPart")
            local tHum  = char and char:FindFirstChild("Humanoid")

            if tRoot and tHum and hasPlayerLeftPrison(p) then
                local currentPos = tRoot.Position

                local lastData    = TargetPositionHistory[p]
                local isTeleport  = false
                local smoothness  = math.huge

                if lastData and lastData.pos then
                    local jumpDistance = (currentPos - lastData.pos).Magnitude
                    if jumpDistance > TELEPORT_JUMP_THRESHOLD then
                        isTeleport = true
                    end

                    local dt = now - (lastData.time or now)
                    if dt > 0 then
                        smoothness = jumpDistance / dt
                    end
                end

                TargetPositionHistory[p] = { pos = currentPos, time = now }

                if not isTeleport then
                    local dist = (rootPos - currentPos).Magnitude
                    if dist <= JAIL_TELEPORT_DIST and not isPositionUnderCover(currentPos, p) then
                        local isAlive = tHum.Health > 0
                        local isSafe  = char:FindFirstChild("ForceField") ~= nil

                        if isAlive and not isSafe then
                            local bounty = getPlayerBountyAmount(p.Name) or 0
                            if bounty >= minBounty then
                                local info = {
                                    player     = p,
                                    distance   = dist,
                                    bounty     = bounty,
                                    isCriminal = (p.Team.Name == "Criminal"),
                                    smoothness = smoothness,
                                }
                                table.insert(validTargets, info)
                                if bounty > maxBounty then
                                    maxBounty = bounty
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    LastTargetScan.count     = #validTargets
    LastTargetScan.maxBounty = maxBounty
    LastTargetScan.time      = now

    if #validTargets == 0 then
        return nil
    end

    local function defaultTargetSort(a, b)
        if a.bounty ~= b.bounty then
            return a.bounty > b.bounty
        end
        if a.isCriminal ~= b.isCriminal then
            return a.isCriminal
        end
        return a.distance < b.distance
    end

    if priorityMode == "Closest" then
        table.sort(validTargets, function(a, b)
            return a.distance < b.distance
        end)
    elseif priorityMode == "Highest Bounty" then
        table.sort(validTargets, function(a, b)
            if a.bounty ~= b.bounty then
                return a.bounty > b.bounty
            end
            return a.distance < b.distance
        end)
    elseif priorityMode == "Smoothest" or priorityMode == "Lowest ping / Smoothest" then
        table.sort(validTargets, function(a, b)
            if a.smoothness ~= b.smoothness then
                return a.smoothness < b.smoothness
            end
            return defaultTargetSort(a, b)
        end)
    else
        table.sort(validTargets, defaultTargetSort)
    end

    return validTargets[1].player
end


local function fireArrestWeapon()
    local gun = require(ReplicatedStorage.Game.ItemSystem.ItemSystem).GetLocalEquipped()
    if gun then
        require(ReplicatedStorage.Game.Item.Gun)._attemptShoot(gun)
    end
end

local function enableSilentAimHooks(targetPart)
    if not oldRayCast then
        oldRayCast = require(ReplicatedStorage.Module.RayCast).RayIgnoreNonCollideWithIgnoreList
    end

    shootTarget = targetPart

    require(ReplicatedStorage.Module.RayCast).RayIgnoreNonCollideWithIgnoreList = function(...)
        local a = {oldRayCast(...)}
        local e = getfenv(2)
        if e and shootTarget and (e.script.Name == "BulletEmitter" or e.script.Name == "Taser") then
            a[1] = shootTarget
            a[2] = shootTarget.Position
        end
        return unpack(a)
    end
end

local function disableSilentAimHooks()
    if oldRayCast then
        require(ReplicatedStorage.Module.RayCast).RayIgnoreNonCollideWithIgnoreList = oldRayCast
    end
    shootTarget = nil
end

local function getVehicleRearPosition(targetVehicle, targetRoot)
    if not targetVehicle or not targetVehicle.PrimaryPart then return nil end
    if not targetRoot then return nil end

    local vehiclePart = targetVehicle.PrimaryPart
    local vehicleCFrame = vehiclePart.CFrame

    local lookVector = vehicleCFrame.LookVector
    local backOffset = -lookVector * 8

    local backPosition = vehiclePart.Position + backOffset
    return backPosition, lookVector
end

local function ramTargetVehicleBody(target)
    if not CurrentVehicle or not CurrentVehicle.PrimaryPart then return false end

    local tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not tRoot then return false end

    local targetVehicle = getClosestVehicleNearPlayer(target)
    if not targetVehicle or not targetVehicle.PrimaryPart then return false end

    local backPos, targetLookVector = getVehicleRearPosition(targetVehicle, tRoot)
    if not backPos then return false end

    local myVehicle = CurrentVehicle
    local myPart = myVehicle.PrimaryPart
    local ramStartTime = tick()
    local RAM_DURATION = 0.5
    local RAM_SPEED = 300

    while (tick() - ramStartTime) < RAM_DURATION do
        if not myVehicle.PrimaryPart or not myVehicle.PrimaryPart.Parent then break end
        if not targetVehicle.PrimaryPart or not targetVehicle.PrimaryPart.Parent then break end

        local tireHealth = targetVehicle:GetAttribute("VehicleTireHealth")
        if tireHealth and tireHealth <= 0 then
            break
        end

        tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if not tRoot then break end

        backPos, targetLookVector = getVehicleRearPosition(targetVehicle, tRoot)
        if not backPos then break end

        myPart = myVehicle.PrimaryPart

        local pushInOffset = targetLookVector * -3
        local targetRamPos = backPos + pushInOffset

        local targetCFrame = CFrame.lookAt(myPart.Position, backPos)
        myVehicle:SetPrimaryPartCFrame(targetCFrame)

        local direction = (targetRamPos - myPart.Position).Unit
        myPart.AssemblyLinearVelocity = direction * RAM_SPEED

        task.wait()
    end

    if myVehicle and myVehicle.PrimaryPart then
        resetPartVelocity(myVehicle.PrimaryPart)
    end

    return true
end

local function getPlayerVehicle(player)
    if not player or not player.Character then return nil end
    local tHum = player.Character:FindFirstChild("Humanoid")
    if tHum and tHum.SeatPart and tHum.SeatPart.Parent then
        return tHum.SeatPart.Parent
    end
    return getClosestVehicleNearPlayer(player)
end

local lastVehicleShotTime = 0

local function stepShootAtVehicle(target)
    if SHOOT_COOLDOWN <= 0 then return end
    if tick() - lastVehicleShotTime < SHOOT_COOLDOWN then return end

    local folder = LocalPlayer:FindFirstChild("Folder")
    if not folder then return end
    local pistol = folder:FindFirstChild("Pistol")
    if not pistol then return end

    local vehicle = getPlayerVehicle(target)
    if not vehicle or not vehicle.PrimaryPart then return end

    local tireHealth = vehicle:GetAttribute("VehicleTireHealth")
    if tireHealth and tireHealth <= 0 then
        return
    end

    if not pistol:GetAttribute("Equipped") then
        pistol.InventoryEquipRemote:FireServer(true)
    end

    enableSilentAimHooks(vehicle.PrimaryPart)

    local ammo = pistol:GetAttribute("AmmoCurrentLocal")
    if ammo and ammo > 0 then
        fireArrestWeapon()
    else
        local reloadRemote = pistol:FindFirstChild("Reload")
        if reloadRemote then
            reloadRemote:FireServer()
        end
    end

    lastVehicleShotTime = tick()
end

local function startCoverCheckLoop()
    if CoverageThread then return end

    CoverageThread = task.spawn(function()
        while AutoArrestEnabled do
            task.wait(COVERAGE_CHECK_INTERVAL)

            if IsExecutingSpawnPath then
                continue
            end

            if not ActionInProgress then
                SelfCoveredStartTime   = nil
                TargetCoveredStartTime = nil
                UnderRoofStartTime     = nil
                continue
            end

            local root = getRootPart()
            local hum  = getCharacterHumanoid()
            if not root or not hum or hum.Health <= 0 then
                SelfCoveredStartTime   = nil
                TargetCoveredStartTime = nil
                UnderRoofStartTime     = nil
                ActionInProgress       = false
                CurrentVehicle         = nil
                ExitedCarRef           = nil
                continue
            end

            local covered = isLocalPlayerUnderCover()

            if covered then
                if not SelfCoveredStartTime then
                    SelfCoveredStartTime = tick()
                end

                local underRoof = (root.Position.Y < (HOVER_HEIGHT - 20))
                if underRoof then
                    if not UnderRoofStartTime then
                        UnderRoofStartTime = tick()
                    end

                    if (tick() - UnderRoofStartTime) >= 5 then
                        warn("[Serenity] Under roof for 5s while action in progress, resetting character.")
                        resetLocalCharacter()
                        SelfCoveredStartTime   = nil
                        TargetCoveredStartTime = nil
                        UnderRoofStartTime     = nil
                        continue
                    end
                else
                    UnderRoofStartTime = nil
                end

                local coveredDuration = tick() - SelfCoveredStartTime
                local spawnPath = getNearestSpawnPath()
                if spawnPath then
                    runSpawnPathWaypoints(spawnPath)
                    task.wait(1)
                    SelfCoveredStartTime = nil
                    UnderRoofStartTime   = nil
                elseif coveredDuration >= MAX_COVERED_TIME then
                    if not canEscapeRoofCover() then
                        resetLocalCharacter()
                        SelfCoveredStartTime   = nil
                        TargetCoveredStartTime = nil
                        UnderRoofStartTime     = nil
                    end
                end
            else
                SelfCoveredStartTime = nil
                UnderRoofStartTime   = nil
            end
        end

        CoverageThread         = nil
        SelfCoveredStartTime   = nil
        TargetCoveredStartTime = nil
        UnderRoofStartTime     = nil
    end)
end



local function stopCoverCheckLoop()
    CoverageThread = nil
    SelfCoveredStartTime = nil
    TargetCoveredStartTime = nil
end





local function sendWebhookLog(eventType, details)
    if not library or not library.flags then return end
    if not library.flags.LogToWebhook then return end

    local url = library.flags.WebhookURL
    if type(url) ~= "string" or url == "" then return end

    local text = ""

    if type(details) == "string" then
        text = details
    elseif type(details) == "table" then
        local parts = {}
        for k, v in pairs(details) do
            table.insert(parts, tostring(k) .. "=" .. tostring(v))
        end
        table.sort(parts)
        text = table.concat(parts, " | ")
    else
        text = tostring(details)
    end

    local body
    local okEncode, encodeErr = pcall(function()
        body = HttpService:JSONEncode({
            content = string.format("[Serenity/%s] %s", tostring(eventType), text),
        })
    end)

    if not okEncode or not body then
        warn("Webhook encode failed:", encodeErr)
        return
    end

    local requestFunc = nil

    if syn and syn.request then
        requestFunc = syn.request
    elseif http and http.request then
        requestFunc = http.request
    elseif http_request then
        requestFunc = http_request
    elseif request then
        requestFunc = request
    end

    local function doHttpExploitRequest()
        if not requestFunc then return false, "no exploit http available" end

        local success, resp = pcall(requestFunc, {
            Url     = url,
            Method  = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body    = body,
        })

        if not success then
            return false, resp
        end

        return true
    end

    local ok, err = doHttpExploitRequest()
    if not ok then
        local s, e = pcall(function()
            HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson)
        end)

        if not s and not tostring(e):find("only be executed by server") then
            warn("Webhook log failed:", e)
        end
    end
end



local function queueScriptForTeleport()
    local code = [[
        task.wait(3)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/JJE0909/serenity/refs/heads/main/jailbreak.lua"))()
    ]]

    local q = queue_on_teleport

    if not q and syn and syn.queue_on_teleport then
        q = syn.queue_on_teleport
    end
    if not q and queueonteleport then
        q = queueonteleport
    end

    if q then
        local ok, err = pcall(q, code)
        if not ok then
            warn("queue_on_teleport failed:", err)
        end
    end
end


local function runSmartServerHop(reason)
    local now = tick()
    library:LogStatus("server hop: " .. tostring(reason))


    if now - LastHopTime < HOP_COOLDOWN then
        return
    end
    LastHopTime = now

    sendWebhookLog("server_hop", {
        reason      = reason,
        maxBounty   = LastTargetScan.maxBounty or 0,
        targetCount = LastTargetScan.count or 0,
        playerCount = #Players:GetPlayers(),
    })

    queueScriptForTeleport()

    pcall(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end

local function shouldServerHop()
    if not library or not library.flags or not library.flags.AutoServerHop then
        return
    end

    local now = tick()
    if now - LastHopCheckTime < 5 then
        return
    end
    LastHopCheckTime = now

    local noTargetsTime      = tonumber(library.flags.HopNoTargetsTime) or DEFAULT_HOP_NO_TARGETS
    local maxBountyThreshold = tonumber(library.flags.HopMaxBounty)     or DEFAULT_HOP_MAX_BOUNTY
    local minPlayers         = tonumber(library.flags.HopMinPlayers)    or DEFAULT_HOP_MIN_PLAYERS

    local reason = nil

    if noTargetsTime > 0 and LastTargetScan.count == 0 and (now - LastTargetSeenTime) > noTargetsTime then
        reason = string.format("no_targets_for_%ds", math.floor(noTargetsTime))
    elseif maxBountyThreshold > 0 and LastTargetScan.count > 0 and LastTargetScan.maxBounty < maxBountyThreshold then
        reason = string.format("max_bounty_%d_below_%d", LastTargetScan.maxBounty, maxBountyThreshold)
    elseif minPlayers > 0 and #Players:GetPlayers() < minPlayers then
        reason = string.format("player_count_%d_below_%d", #Players:GetPlayers(), minPlayers)
    end

    if reason then
        runSmartServerHop(reason)
    end
end


local function destroyTargetVisual()
    if TargetLineConnection then
        TargetLineConnection:Disconnect()
        TargetLineConnection = nil
    end
    if TargetLinePart then
        TargetLinePart:Destroy()
        TargetLinePart = nil
    end
end

local function ensureTargetVisual()
    if not library.flags or not library.flags.ShowTargetLine then
        destroyTargetVisual()
        return
    end

    if not TargetLinePart then
        TargetLinePart = Instance.new("Part")
        TargetLinePart.Name = "SerenityTargetLine"
        TargetLinePart.Anchored = true
        TargetLinePart.CanCollide = false
        TargetLinePart.Material = Enum.Material.Neon
        TargetLinePart.Color = Color3.fromRGB(51, 51, 155)
        TargetLinePart.Size = Vector3.new(0.2, 0.2, 1)
        TargetLinePart.Transparency = 0.2
        TargetLinePart.Parent = Workspace
    end

    if not TargetLineConnection then
        TargetLineConnection = RunService.RenderStepped:Connect(function()
            if not AutoArrestEnabled or not library.flags.ShowTargetLine then
                destroyTargetVisual()
                return
            end

            local root   = getRootPart()
            local target = CurrentTarget
            local tRoot  = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")

            if not root or not tRoot or not TargetLinePart then
                if TargetLinePart then
                    TargetLinePart.Transparency = 1
                end
                return
            end

            TargetLinePart.Transparency = 0.2

            local p1       = root.Position
            local p2       = tRoot.Position
            local middle   = (p1 + p2) / 2
            local distance = (p1 - p2).Magnitude

            TargetLinePart.Size   = Vector3.new(0.2, 0.2, distance)
            TargetLinePart.CFrame = CFrame.new(middle, p2)
        end)
    end
end

local function writeConfig()
    if not writefile then return end

    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, {
        flags = library.flags,
    })
    if not ok then
        warn("[Serenity] Failed to encode config:", encoded)
        return
    end

    local ok2, err = pcall(writefile, CONFIG_FILE, encoded)
    if not ok2 then
        warn("[Serenity] Failed to write config:", err)
    end
end

local function loadConfigFromFile()
    if not readfile or not isfile then return end
    if not isfile(CONFIG_FILE) then return end

    local ok, contents = pcall(readfile, CONFIG_FILE)
    if not ok then
        warn("[Serenity] Failed to read config:", contents)
        return
    end

    local ok2, decoded = pcall(HttpService.JSONDecode, HttpService, contents)
    if not ok2 or type(decoded) ~= "table" or type(decoded.flags) ~= "table" then
        warn("[Serenity] Invalid config format in", CONFIG_FILE)
        return
    end

    for k, v in pairs(decoded.flags) do
        library.flags[k] = v
    end

    if library.flags.ShowTargetLine then
        ensureTargetVisual()
    else
        destroyTargetVisual()
    end
end




local EquippedToolName = nil

local function unequipAllToolsNow()
    local folder = LocalPlayer:FindFirstChild("Folder")
    if not folder then return end

    local function unequipToolByName(toolName)
        local tool = folder:FindFirstChild(toolName)
        if tool then
            local remote = tool:FindFirstChild("InventoryEquipRemote")
            if remote then
                remote:FireServer(false)
            end
        end
    end

    unequipToolByName("Pistol")
    unequipToolByName("Handcuffs")
    EquippedToolName = nil
end

local function equipToolByName(toolName)
    local folder = LocalPlayer:FindFirstChild("Folder")
    if not folder then return nil end

    local tool = folder:FindFirstChild(toolName)
    if not tool then return nil end

    local remote = tool:FindFirstChild("InventoryEquipRemote")
    if not remote then return nil end

    if EquippedToolName == toolName then
        return tool
    end

    if EquippedToolName and EquippedToolName ~= toolName then
        local oldTool = folder:FindFirstChild(EquippedToolName)
        if oldTool then
            local oldRemote = oldTool:FindFirstChild("InventoryEquipRemote")
            if oldRemote then
                oldRemote:FireServer(false)
            end
        end
    end

    remote:FireServer(true)
    task.wait(0.05)

    EquippedToolName = toolName
    return tool
end




local function runArrestSequence(target)
    ActionInProgress = true

    local success = false 
    local targetNameForLog = target and target.Name or "Unknown"
    library:LogStatus("Starting arrest sequence on: " .. targetNameForLog)

    local ok, err = pcall(function()
        if not target then return end

        if ExitedCarRef and not CurrentVehicle and ExitedCarRef.PrimaryPart and ExitedCarRef.PrimaryPart.Parent then
            CurrentVehicle = ExitedCarRef
        end

        local targetName = target.Name
        local root = getRootPart()
        local hum  = getCharacterHumanoid()

        if not root or not hum or hum.Health <= 0 then
            return
        end

        if not hasPlayerLeftPrison(target) then
            return
        end

        if not (hum.Sit and CurrentVehicle and CurrentVehicle.PrimaryPart and CurrentVehicle.PrimaryPart.Parent) then
            return
        end

        local startTime    = tick()
        local chaseTimeout = 40

        local popWithVehicleStart = nil
        local POP_TIMEOUT = 1.5  

        while AutoArrestEnabled and (tick() - startTime) < chaseTimeout do
            hum  = getCharacterHumanoid()
            root = getRootPart()
            if not hum or not root or hum.Health <= 0 then
                return
            end

            local tChar = target.Character
            local tHum  = tChar and tChar:FindFirstChild("Humanoid")
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")

            if not tHum or not tRoot or tHum.Health <= 0 then
                break
            end

            if not hasPlayerLeftPrison(target) then
                success = true
                break
            end

            local vehiclePart = CurrentVehicle and CurrentVehicle.PrimaryPart
            if not vehiclePart or not vehiclePart.Parent then
                break
            end

            if isPositionUnderCover(tRoot.Position, target) then
                break
            end

            local targetPos      = tRoot.Position
            local vehiclePosXZ   = v3new(vehiclePart.Position.X, 0, vehiclePart.Position.Z)
            local targetPosXZ    = v3new(targetPos.X, 0, targetPos.Z)
            local horizontalDist = (vehiclePosXZ - targetPosXZ).Magnitude

            local chaseY         = HOVER_HEIGHT
            local playersVehicle = getPlayerVehicle(target)

            local tireHealth  = playersVehicle and playersVehicle:GetAttribute("VehicleTireHealth") or nil
            local tiresPopped = (tireHealth ~= nil and tireHealth <= 0)

            if playersVehicle and playersVehicle.PrimaryPart then
                if horizontalDist < 80 then
                    local vehPos = playersVehicle.PrimaryPart.Position
                    local safeY  = getSafeHeightAboveGround(vehPos)
                    chaseY       = math.max(vehPos.Y + DROP_OFFSET_STUDS, safeY + 5)

                    if tHum.Sit and not tiresPopped and not popWithVehicleStart then
                        popWithVehicleStart = tick()
                    end
                end
            end

            local chasePos = v3new(targetPos.X, chaseY, targetPos.Z)
            setVelocityTowards(chasePos, FLY_SPEED_CAR, vehiclePart)

            if horizontalDist < 30 and (tiresPopped or not tHum.Sit) then
                resetPartVelocity(vehiclePart)
                break
            end

            if popWithVehicleStart and (tick() - popWithVehicleStart) > POP_TIMEOUT then
                resetPartVelocity(vehiclePart)
                break
            end

            task.wait(0.05)
        end

        if CurrentVehicle and CurrentVehicle.PrimaryPart then
            resetPartVelocity(CurrentVehicle.PrimaryPart)
        end

        if CurrentVehicle then
            ExitedCarRef = CurrentVehicle
        end

        exitVehicleFlow()
        task.wait(0.2)

        root = getRootPart()
        if root then
            resetPartVelocity(root)
        end

        local chaseStart2   = tick()
        local chaseTimeout2 = 15

        while AutoArrestEnabled and (tick() - chaseStart2) < chaseTimeout2 do
            hum  = getCharacterHumanoid()
            root = getRootPart()
            if not hum or not root or hum.Health <= 0 then
                return
            end

            local tChar = target.Character
            local tHum  = tChar and tChar:FindFirstChild("Humanoid")
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")

            if not tHum or not tRoot or tHum.Health <= 0 then
                break
            end

            if not hasPlayerLeftPrison(target) then
                success = true
                break
            end

            local targetPos = tRoot.Position
            local safeY     = getSafeHeightAboveGround(targetPos)
            local chaseY    = math.max(targetPos.Y + 3, safeY + 3)
            local chasePos  = v3new(targetPos.X, chaseY, targetPos.Z)

            stepTowardsOnFoot(chasePos, root)

            local dist   = (root.Position - targetPos).Magnitude
            local seated = tHum.Sit

            if seated then
                local playersVehicle = getPlayerVehicle(target)
                local tireHealth     = playersVehicle and playersVehicle:GetAttribute("VehicleTireHealth") or nil
                local tiresPopped    = (tireHealth ~= nil and tireHealth <= 0)

                if tHum.Sit and playersVehicle and not tiresPopped then
                    local pistol      = equipToolByName("Pistol")
                    local popTiresKey = KeyMap[POP_TIRES_STABLE_KEY]
                    library:LogStatus("Popping tires / ejecting vehicle for: " .. targetNameForLog)

                    if pistol and popTiresKey then
                        Remote:FireServer(popTiresKey, playersVehicle, "Pistol")
                    end
                end

                local ejectKeyUuid = KeyMap[VEHICLE_EJECT_STABLE_KEY]
                if ejectKeyUuid then
                    local veh = getPlayerVehicle(target)
                    if veh then
                        Remote:FireServer(ejectKeyUuid, veh)
                    end
                end
            else
                if dist <= ARREST_CHASE_RANGE then
                    local cuffs         = equipToolByName("Handcuffs")
                    local arrestKeyUuid = KeyMap[ARREST_STABLE_KEY]

                    if cuffs and arrestKeyUuid then
                        Remote:FireServer(arrestKeyUuid, targetName)
                        Remote:FireServer(arrestKeyUuid, targetName)
                        Remote:FireServer(arrestKeyUuid, targetName)
                    end
                end
            end

            task.wait(ARREST_LOOP_DELAY)
        end
    end)

    if not ok then
        warn("runArrestSequence error:", err)
        sendWebhookLog("error", tostring(err))
    end

    disableSilentAimHooks()

    unequipAllToolsNow()

    local root2 = getRootPart()
    if root2 then
        snapVerticalPosition(v3new(root2.Position.X, HOVER_HEIGHT, root2.Position.Z))
    end

    ActionInProgress = false

    if success then
        ArrestRetryCount = 0
    else
        ArrestRetryCount = ArrestRetryCount + 1
    end

    if success and targetNameForLog then
        sendWebhookLog("arrest", {
            target = targetNameForLog,
            bounty = getPlayerBountyAmount(targetNameForLog),
            jobId  = game.JobId,
        })
    end

    return success
end


local function autoArrestMainLoop()
    if not AutoArrestEnabled then return end
    if ActionInProgress or IsExecutingSpawnPath then return end

    local hum  = getCharacterHumanoid()
    local root = getRootPart()

    if not root or not hum or hum.Health <= 0 then
        ActionInProgress       = false
        CurrentVehicle         = nil
        ExitedCarRef           = nil
        VehicleRetryCount      = 0
        ArrestRetryCount       = 0
        StuckCheckPosition     = nil
        TargetPositionHistory  = {}
        SelfCoveredStartTime   = nil
        TargetCoveredStartTime = nil
        CurrentTarget          = nil
        destroyTargetVisual()
        return
    end

    resetAutoArrestState()

    if VehicleRetryCount >= MAX_VEHICLE_RETRIES then
        task.wait(RETRY_COOLDOWN)
        VehicleRetryCount = 0
        return
    end

    if ArrestRetryCount >= MAX_ARREST_RETRIES then
        task.wait(RETRY_COOLDOWN)
        ArrestRetryCount = 0
        return
    end

    local target = selectBestTarget()
    if target then
        LastTargetSeenTime = tick()
    end
    CurrentTarget = target

    if target ~= LastLoggedTarget then
        if target then
            library:LogStatus(string.format(
                "Targeting player: %s (Bounty: %d)",
                target.Name,
                getPlayerBountyAmount(target.Name)
            ))
        else
            library:LogStatus("No valid targets found.")
        end
        LastLoggedTarget = target
    end



    if library.flags.ShowTargetLine and target then
        ensureTargetVisual()
    end

    shouldServerHop()

    local NO_CAR_TARGET_DISTANCE = tonumber(library.flags.NoCarRadius) or DEFAULT_NO_CAR_RADIUS
    local neverUseVehicle        = library.flags.NeverUseVehicle == true

    hum  = getCharacterHumanoid()
    root = getRootPart()
    if not hum or not root or hum.Health <= 0 then return end

    local inVehicle = hum.Sit and CurrentVehicle and CurrentVehicle.PrimaryPart and CurrentVehicle.PrimaryPart.Parent

    if neverUseVehicle and inVehicle then
        exitVehicleFlow()
        inVehicle = false
        hum  = getCharacterHumanoid()
        root = getRootPart()
        if not hum or not root or hum.Health <= 0 then return end
    end

    if not inVehicle then
        if target and target.Character then
            local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if tRoot then
                local dist = (root.Position - tRoot.Position).Magnitude

                if dist <= NO_CAR_TARGET_DISTANCE then
                    runArrestSequence(target)
                    return
                end
            end
        end

        if not neverUseVehicle then
            local veh = getClosestAllowedVehicle()
            if veh then
                local successEnter = enterVehicleFlow(veh)
                if not successEnter then
                    VehicleRetryCount += 1
                    task.wait(RETRY_COOLDOWN)
                end
            else
                local r = getRootPart()
                if r and r.Position.Y < HOVER_HEIGHT then
                    snapVerticalPosition(v3new(r.Position.X, HOVER_HEIGHT, r.Position.Z))
                end
            end
        else
            local r = getRootPart()
            if r and r.Position.Y < HOVER_HEIGHT then
                snapVerticalPosition(v3new(r.Position.X, HOVER_HEIGHT, r.Position.Z))
            end
        end

        return
    end

    if target then
        runArrestSequence(target)
    else
        root = getRootPart()
        if not root then return end

        local prison = v3new(-1140, HOVER_HEIGHT, -1500)
        local bank   = v3new(-10,   HOVER_HEIGHT, 1000)

        local distPrison = (root.Position - prison).Magnitude
        local distBank   = (root.Position - bank).Magnitude

        local dest = (distPrison < distBank) and bank or prison
        moveToWorldPosition(dest, true)
    end
end




local function toggleAutoArrest()
    AutoArrestEnabled = not AutoArrestEnabled
    library:LogStatus("Auto-Arrest " .. (AutoArrestEnabled and "ENABLED" or "DISABLED"))


    if AutoArrestEnabled then
        print("Auto-Arrest ENABLED")

        ActionInProgress      = false
        IsExecutingSpawnPath  = false
        ExitedCarRef          = nil
        CurrentVehicle        = nil
        VehicleRetryCount     = 0
        ArrestRetryCount      = 0
        TargetPositionHistory = {}
        SelfCoveredStartTime  = nil
        TargetCoveredStartTime= nil
        StuckCheckPosition    = nil
        lastVehicleShotTime   = 0
        disableSilentAimHooks()

        if library.flags.ShowTargetLine then
            ensureTargetVisual()
        end


        local root = getRootPart()
        if root then
            resetPartVelocity(root)
        end

        startCoverCheckLoop()

        if isLocalPlayerUnderCover() then
            local spawnPath = getNearestSpawnPath()
            if spawnPath then
                runSpawnPathWaypoints(spawnPath)
                task.wait(1)
            end
        end

        local root2 = getRootPart()
        if root2 and root2.Position.Y < HOVER_HEIGHT then
            snapVerticalPosition(v3new(root2.Position.X, HOVER_HEIGHT, root2.Position.Z))
        end

        if not MainLoopConnection then
            MainLoopConnection = RunService.Heartbeat:Connect(autoArrestMainLoop)
        end
    else
        print("Auto-Arrest DISABLED")

        if MainLoopConnection then
            MainLoopConnection:Disconnect()
            MainLoopConnection = nil
        end

        stopCoverCheckLoop()

        CurrentTarget = nil
        destroyTargetVisual()
        unequipAllToolsNow()


        AutoArrestEnabled     = false
        ActionInProgress      = false
        IsExecutingSpawnPath  = false

        disableSilentAimHooks()
        shootTarget = nil

        local root = getRootPart()
        if root then resetPartVelocity(root) end
        if CurrentVehicle and CurrentVehicle.PrimaryPart then
            resetPartVelocity(CurrentVehicle.PrimaryPart)
        end

        CurrentVehicle        = nil
        ExitedCarRef          = nil
        VehicleRetryCount     = 0
        ArrestRetryCount      = 0
        StuckCheckPosition    = nil
        TargetPositionHistory = {}
        SelfCoveredStartTime  = nil
        TargetCoveredStartTime= nil

        local folder = LocalPlayer:FindFirstChild("Folder")
        if folder then
            local pistol = folder:FindFirstChild("Pistol")
            if pistol and pistol:GetAttribute("Equipped") then
                pistol.InventoryEquipRemote:FireServer(false)
            end
            local cuffs = folder:FindFirstChild("Handcuffs")
            if cuffs then
                cuffs.InventoryEquipRemote:FireServer(false)
            end
        end
    end
end


task.spawn(function()
    while task.wait(1) do
        pcall(function()
            for _, v in getgc(false) do
                if typeof(v) == "function" and islclosure(v) and debug.info(v, "n") == "EventFireServer" then
                    local ups = debug.getupvalues(v)
                    if ups[3] and ups[3]["y62bk0nz"] then
                        ups[3]["y62bk0nz"] = nil
                    end
                end
            end
        end)
    end
end)



local function Boot()
    Serenity.UI     = Serenity.UI     or {}
    Serenity.Config = Serenity.Config or {}

    Serenity.UI.Library   = library
    Serenity.Config.Theme = Serenity.Config.Theme or theme

    pcall(loadConfigFromFile)

    local Lib = library:Create("Serenity | Jailbreak")

    local Tab       = Lib:Tab("Main")
    local StatusTab = Lib:Tab("Status")

    local StatusConsole = StatusTab:Console()
    library.statusConsole = StatusConsole
    library:LogStatus("Status console initialized.")

    local initialToggle = library.flags.Toggle
    if initialToggle == nil then
        initialToggle = true
    end

    Tab:Toggle("Toggle Arrest", "Toggle", initialToggle, function(state)
        toggleAutoArrest()
        writeConfig()
    end)

    local SettingsTab = Lib:Tab("Settings")

    SettingsTab:Slider("Min Bounty", "MinBounty", tonumber(library.flags.MinBounty) or 0, 0, 20000, false, function(val)
        library.flags.MinBounty = val
        writeConfig()
    end)

    SettingsTab:Dropdown(
        "Target Priority",
        "TargetPriorityMode",
        {"Default", "Highest Bounty", "Closest", "Smoothest"},
        false,
        function(mode)
            library.flags.TargetPriorityMode = mode
            writeConfig()
        end
    )

    SettingsTab:Toggle("Auto Server Hop", "AutoServerHop", library.flags.AutoServerHop or false, function(state)
        library.flags.AutoServerHop = state
        writeConfig()
        if state then
            LastTargetSeenTime = tick()
        end
    end)

    SettingsTab:Slider("Hop: No Targets Time (s)", "HopNoTargetsTime", tonumber(library.flags.HopNoTargetsTime) or DEFAULT_HOP_NO_TARGETS, 10, 600, false, function(val)
        library.flags.HopNoTargetsTime = val
        writeConfig()
    end)

    SettingsTab:Slider("Hop: Max Bounty Threshold", "HopMaxBounty", tonumber(library.flags.HopMaxBounty) or DEFAULT_HOP_MAX_BOUNTY, 0, 20000, false, function(val)
        library.flags.HopMaxBounty = val
        writeConfig()
    end)

    SettingsTab:Slider("Hop: Min Player Count", "HopMinPlayers", tonumber(library.flags.HopMinPlayers) or DEFAULT_HOP_MIN_PLAYERS, 0, 30, false, function(val)
        library.flags.HopMinPlayers = val
        writeConfig()
    end)

    SettingsTab:Toggle("Send Logs to Webhook", "LogToWebhook", library.flags.LogToWebhook or false, function(state)
        library.flags.LogToWebhook = state
        writeConfig()
    end)

    SettingsTab:TextBox("Webhook URL", "WebhookURL", library.flags.WebhookURL or "", function(text)
        library.flags.WebhookURL = text
        writeConfig()
    end)

    SettingsTab:Toggle("Show Target Line", "ShowTargetLine", library.flags.ShowTargetLine or false, function(state)
        library.flags.ShowTargetLine = state
        writeConfig()
        if state then
            ensureTargetVisual()
        else
            destroyTargetVisual()
        end
    end)

    SettingsTab:Button("Save Config", function()
        writeConfig()
    end)

    SettingsTab:Button("Load Config", function()
        loadConfigFromFile()
    end)

    SettingsTab:Button("Destroy UI", function()
        if _G.SerenityDestroyUI then
            _G.SerenityDestroyUI()
        end
    end)

    SettingsTab:KeyBind("Toggle UI", "RightShift", function()
        if _G.SerenityToggleUI then
            _G.SerenityToggleUI()
        end
    end)

    Serenity.UI.Instance      = Lib
    Serenity.UI.MainTab       = Tab
    Serenity.UI.StatusTab     = StatusTab
    Serenity.UI.SettingsTab   = SettingsTab
    Serenity.UI.StatusConsole = StatusConsole
end

Boot()

Serenity.Config = Serenity.Config or {}
Serenity.Config.Theme = Serenity.Config.Theme or theme
Serenity.Config.Files = {
    CONFIG_FILE = CONFIG_FILE,
}
Serenity.Config.Targeting = {
    DEFAULT_MIN_BOUNTY      = DEFAULT_MIN_BOUNTY,
    DEFAULT_NO_CAR_RADIUS   = DEFAULT_NO_CAR_RADIUS,
    DEFAULT_HOP_NO_TARGETS  = DEFAULT_HOP_NO_TARGETS,
    DEFAULT_HOP_MAX_BOUNTY  = DEFAULT_HOP_MAX_BOUNTY,
    DEFAULT_HOP_MIN_PLAYERS = DEFAULT_HOP_MIN_PLAYERS,
    HOP_COOLDOWN            = HOP_COOLDOWN,
}
Serenity.Config.Flight = {
    HOVER_HEIGHT            = HOVER_HEIGHT,
    MIN_HEIGHT_ABOVE_GROUND = MIN_HEIGHT_ABOVE_GROUND,
    DROP_OFFSET_STUDS       = DROP_OFFSET_STUDS,
    FLY_SPEED_CAR           = FLY_SPEED_CAR,
    FLY_SPEED_FOOT          = FLY_SPEED_FOOT,
    ROOF_RAYCAST_HEIGHT     = ROOF_RAYCAST_HEIGHT,
    JAIL_TELEPORT_DIST      = JAIL_TELEPORT_DIST,
    TELEPORT_JUMP_THRESHOLD = TELEPORT_JUMP_THRESHOLD,
    MAX_HORIZONTAL_SPEED    = MAX_HORIZONTAL_SPEED,
    HOVER_ADJUST_SPEED      = HOVER_ADJUST_SPEED,
    VERTICAL_SNAP_THRESHOLD = VERTICAL_SNAP_THRESHOLD,
    FOOT_SPEED              = FOOT_SPEED,
    FOOT_LERP_ALPHA         = FOOT_LERP_ALPHA,
    FOOT_MAX_VERTICAL       = FOOT_MAX_VERTICAL,
    FOOT_HOVER_OFFSET       = FOOT_HOVER_OFFSET,
}
Serenity.Config.Retry = {
    MAX_VEHICLE_RETRIES = MAX_VEHICLE_RETRIES,
    MAX_ARREST_RETRIES  = MAX_ARREST_RETRIES,
    STUCK_TIMEOUT       = STUCK_TIMEOUT,
    RETRY_COOLDOWN      = RETRY_COOLDOWN,
}
Serenity.Config.Coverage = {
    COVERAGE_CHECK_INTERVAL = COVERAGE_CHECK_INTERVAL,
    MAX_COVERED_TIME        = MAX_COVERED_TIME,
}
Serenity.Config.Combat = {
    ARREST_CHASE_RANGE = ARREST_CHASE_RANGE,
    ARREST_LOOP_DELAY  = ARREST_LOOP_DELAY,
    SHOOT_COOLDOWN     = SHOOT_COOLDOWN,
}
Serenity.Config.Vehicles = {
    ALLOWED_VEHICLES     = ALLOWED_VEHICLES,
    SPAWN_PATHS          = SPAWN_PATHS,
    SPAWN_PATH_TOLERANCE = SPAWN_PATH_TOLERANCE,
}

Serenity.Services = {
    Players           = Players,
    RunService        = RunService,
    Workspace         = Workspace,
    ReplicatedStorage = ReplicatedStorage,
    HttpService       = HttpService,
    TeleportService   = TeleportService,
}

Serenity.Util = {
    GetHRP                    = getRootPart,
    GetHumanoid               = getCharacterHumanoid,
    KillVelocity              = resetPartVelocity,
    GetBountyData             = readBountyData,
    GetPlayerBounty           = getPlayerBountyAmount,
    HasPlayerEscaped          = hasPlayerLeftPrison,
    GetSafeHeight             = getSafeHeightAboveGround,
    IsCovered                 = isPositionUnderCover,
    AmICovered                = isLocalPlayerUnderCover,
    FlyTowards3D              = setVelocityTowards,
    FindSpawnPath             = getNearestSpawnPath,
    SafeVerticalTeleport      = snapVerticalPosition,
    ExecuteSpawnPath          = runSpawnPathWaypoints,
    KillSelf                  = resetLocalCharacter,
    FlyToLocation             = moveToWorldPosition,
    FlySmoothFoot             = stepTowardsOnFoot,
    CleanupState              = resetAutoArrestState,
    GetClosestVehicleToPlayer = getClosestVehicleNearPlayer,
    GetTargetVehiclePart      = getVehicleTargetPart,
    GetClosestVehicle         = getClosestAllowedVehicle,
    EnsureTargetLine          = ensureTargetVisual,
    DestroyTargetLine         = destroyTargetVisual,
}

Serenity.Network = {
    Remote   = Remote,
    KeyMap   = KeyMap,
    StableKeys = {
        POP_TIRES     = POP_TIRES_STABLE_KEY,
        JOIN_TEAM     = JOIN_TEAM_STABLE_KEY,
        ARREST        = ARREST_STABLE_KEY,
        VEHICLE_ENTRY = VEHICLE_ENTRY_STABLE_KEY,
        VEHICLE_EXIT  = VEHICLE_EXIT_STABLE_KEY,
        VEHICLE_EJECT = VEHICLE_EJECT_STABLE_KEY,
        REDEEM_CODE   = redeemCode,
    },
    LogWebhookEvent        = sendWebhookLog,
    SmartServerHop         = runSmartServerHop,
    QueueScriptOnTeleport  = queueScriptForTeleport,
}

Serenity.AutoArrest = {
    Toggle               = toggleAutoArrest,
    autoArrestMainLoop             = autoArrestMainLoop,
    StartCoverageMonitor = startCoverCheckLoop,
    StopCoverageMonitor  = stopCoverCheckLoop,
}

function Serenity.AutoArrest.Enable()
    if not AutoArrestEnabled then
        toggleAutoArrest()
    end
end

function Serenity.AutoArrest.Disable()
    if AutoArrestEnabled then
        toggleAutoArrest()
    end
end

function Serenity.GetState()
    return {
        AutoArrestEnabled    = AutoArrestEnabled,
        CurrentTarget        = CurrentTarget,
        CurrentVehicle       = CurrentVehicle,
        LastTargetScan       = LastTargetScan,
        LastTargetSeenTime   = LastTargetSeenTime,
        LastHopTime          = LastHopTime,
        LastHopCheckTime     = LastHopCheckTime,
        CoverageThreadActive = CoverageThread ~= nil,
    }
end

function Serenity.toggleMainGui()
    if _G.SerenityToggleUI then
        _G.SerenityToggleUI()
    end
end

function Serenity.destroyMainGui()
    if _G.SerenityDestroyUI then
        _G.SerenityDestroyUI()
    end
end

Serenity.SaveConfig = writeConfig
Serenity.LoadConfig = loadConfigFromFile

return Serenity
