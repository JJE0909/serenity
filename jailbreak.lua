local library = {}
library.flags = {}
library.currentTab = nil
local toggled = false
local mouse = game.Players.LocalPlayer:GetMouse()

local theme = {
	main = Color3.fromRGB(37, 37, 37),
	secondary = Color3.fromRGB(42, 42, 42),
	accent = Color3.fromRGB(255, 255, 255),
	accent2 = Color3.fromRGB(57, 57, 57),
    accent3 = Color3.fromRGB(51, 51, 155)
}

function Tween(obj,size,delay)
	obj:TweenSize(size,"Out","Sine",delay,false)
end

function Tween2(obj, t, data)
	game:GetService("TweenService"):Create(obj, TweenInfo.new(t[1], Enum.EasingStyle[t[2]], Enum.EasingDirection[t[3]]), data):Play()
	return true
end

function Ripple(obj)
	spawn(function()
		if obj.ClipsDescendants ~= true then
			obj.ClipsDescendants = true
		end
		local Ripple = Instance.new("ImageLabel")
		Ripple.Name = "Ripple"
		Ripple.Parent = obj
		Ripple.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		Ripple.BackgroundTransparency = 1.000
		Ripple.ZIndex = 8
		Ripple.Image = "rbxassetid://2708891598"
		Ripple.ImageTransparency = 0.800
		Ripple.ScaleType = Enum.ScaleType.Fit
		Ripple.ImageColor3 = Color3.fromRGB(0,0,0)
		Ripple.Position = UDim2.new((mouse.X - Ripple.AbsolutePosition.X) / obj.AbsoluteSize.X, 0, (mouse.Y - Ripple.AbsolutePosition.Y) / obj.AbsoluteSize.Y, 0)
		Tween2(Ripple, {.3, 'Linear', 'InOut'}, {Position = UDim2.new(-5.5, 0, -5.5, 0), Size = UDim2.new(12, 0, 12, 0)})
		wait(0.15)
		Tween2(Ripple, {.3, 'Linear', 'InOut'}, {ImageTransparency = 1})
		wait(.3)
		Ripple:Destroy()
	end)
end

local changeingTab = false
function SwitchTab(Tab)
	if changeingTab == true then return end
	local Old = library.currentTab
	if Old == nil then
		library.currentTab = Tab[1]
		Tab[1].Visible = true
		return
	end
	if Tab[1].Visible == true then return end
	changeingTab = true
	Tween(Old.Parent,UDim2.new(0, 440,0, 0),.1)
	Old.Visible = false
	wait(0.2)
	Tab[1].Visible = true
	Tween(Tab[1].Parent,UDim2.new(0, 440,0, 318),.1)
	library.currentTab = Tab[1]
	wait(.1)
	changeingTab = false
end

function drag(frame, hold) 
	if not hold then
		hold = frame
	end
	local dragging
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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
			update(input)
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
	local TabOpen = Instance.new("TextButton")
	local TabContainerL = Instance.new("UIListLayout")
	local TabContainerP = Instance.new("UIPadding")
	local TabHolder = Instance.new("Frame")
	local TabHolderC = Instance.new("UICorner")
	local TopFrame = Instance.new("Frame")
	local SideFrameC_2 = Instance.new("UICorner")
	local Title = Instance.new("TextLabel")
	
  function DestroyUI()
      if Serenity then
          Serenity:Destroy()
      end
  end

	Serenity.Name = "Serenity"
	Serenity.Parent = game:WaitForChild("CoreGui")

	MainFrame.Name = "MainFrame"
	MainFrame.Parent = Serenity
	MainFrame.BackgroundColor3 = theme.main
	MainFrame.Position = UDim2.new(0.345118761, 0, 0.277912617, 0)
	MainFrame.Size = UDim2.new(0, 587, 0, 366)
	MainFrame.BorderSizePixel = 0
	
	function ToggleUI()
        toggled = not toggled
        if not MainFrame.ClipsDescendants then
            MainFrame.ClipsDescendants = true
        end
        if toggled then
            Tween(MainFrame,UDim2.new(0, 587,0, 0),0.15)
            else
            Tween(MainFrame,UDim2.new(0,587,0,366),0.15)
        end
	end

	MainFrameC.CornerRadius = UDim.new(0, 6)
	MainFrameC.Name = "MainFrameC"
	MainFrameC.Parent = MainFrame

	SideFrame.Name = "SideFrame"
	SideFrame.Parent = MainFrame
	SideFrame.BackgroundColor3 = theme.secondary
	SideFrame.Position = UDim2.new(0.0120000103, 0, 0.117999971, 0)
	SideFrame.Size = UDim2.new(0, 130, 0, 318)

	SideFrameC.CornerRadius = UDim.new(0, 4)
	SideFrameC.Name = "SideFrameC"
	SideFrameC.Parent = SideFrame

	TabContainer.Name = "TabContainer"
	TabContainer.Parent = SideFrame
	TabContainer.Active = true
	TabContainer.BackgroundColor3 = theme.secondary
	TabContainer.BackgroundTransparency = 1.000
	TabContainer.BorderSizePixel = 0
	TabContainer.Position = UDim2.new(0.0510812625, 0, 0.0220125783, 0)
	TabContainer.Size = UDim2.new(0, 117, 0, 305)
	TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	TabContainer.ScrollBarThickness = 0

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
	TabHolder.Position = UDim2.new(0.244000047, 0, 0.117999971, 0)
	TabHolder.Size = UDim2.new(0, 440, 0, 318)
	TabHolder.ClipsDescendants = true

	TabHolderC.CornerRadius = UDim.new(0, 4)
	TabHolderC.Name = "TabHolderC"
	TabHolderC.Parent = TabHolder

	TopFrame.Name = "TopFrame"
	TopFrame.Parent = MainFrame
	TopFrame.BackgroundColor3 = theme.secondary
	TopFrame.Position = UDim2.new(0.0123288939, 0, 0.0191256832, 0)
	TopFrame.Size = UDim2.new(0, 575, 0, 33)

	SideFrameC_2.CornerRadius = UDim.new(0, 4)
	SideFrameC_2.Name = "SideFrameC"
	SideFrameC_2.Parent = TopFrame

	Title.Name = "Title"
	Title.Parent = TopFrame
	Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Title.BackgroundTransparency = 1.000
	Title.BorderSizePixel = 0
	Title.Position = UDim2.new(0.0112130605, 0, 0, 0)
	Title.Size = UDim2.new(0, 569, 0, 33)
	Title.Font = Enum.Font.GothamMedium
	Title.Text = title
	Title.TextColor3 = theme.accent
	Title.TextSize = 20.000
	Title.TextXAlignment = Enum.TextXAlignment.Left

	drag(MainFrame, TopFrame)

	TabContainerL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabContainerL.AbsoluteContentSize.Y + 18)
	end)

	local Holder = {}

	function Holder:Tab(name)
		local TabOpen = Instance.new("TextButton")
		local TabOpenC = Instance.new("UICorner")
		local Section = Instance.new("ScrollingFrame")
		local SectionP = Instance.new("UIPadding")
		local TabHolderC = Instance.new("UICorner")
		local SectionL = Instance.new("UIListLayout")

		TabOpen.Name = "TabOpen"
		TabOpen.Parent = TabContainer
		TabOpen.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
		TabOpen.BackgroundTransparency = 1.000
		TabOpen.BorderSizePixel = 0
		TabOpen.Position = UDim2.new(0, 0, 0, 0)
		TabOpen.Size = UDim2.new(0, 116, 0, 30)
		TabOpen.AutoButtonColor = false
		TabOpen.Font = Enum.Font.GothamMedium
		TabOpen.Text = ("       %s"):format(name)
		TabOpen.TextColor3 = theme.accent
		TabOpen.TextSize = 14.000
		TabOpen.TextXAlignment = Enum.TextXAlignment.Left

		TabOpenC.CornerRadius = UDim.new(1, 10)
		TabOpenC.Name = "TabOpenC"
		TabOpenC.Parent = TabOpen

		Section.Name = name
		Section.Parent = TabHolder
		Section.Active = true
		Section.BackgroundColor3 = theme.secondary
		Section.BorderSizePixel = 0
		Section.Position = UDim2.new(0, 0, -0.00149685144, 0)
		Section.Size = UDim2.new(0, 440, 0, 318)
		Section.Visible = false
		Section.ScrollBarThickness = 0
		Section.ScrollBarImageColor3 = theme.accent
		Section.CanvasSize = UDim2.new(0,0,0,0)

		TabHolderC.CornerRadius = UDim.new(0, 4)
		TabHolderC.Name = "TabHolderC"
		TabHolderC.Parent = Section

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

		local IsTabOpen = false
		TabOpen.MouseButton1Click:Connect(function()
			spawn(function()
				Ripple(TabOpen)
			end)
			SwitchTab({Section})
		end)
		if library.currentTab == nil then SwitchTab({Section}) end
		
		local TabHolder = {}
		
		function TabHolder:Section(name)
            local SectionSplit = Instance.new("Frame")
            local SectionC = Instance.new("UICorner")
            local SectionName = Instance.new("TextLabel")
            local SectionOpened = Instance.new("ImageLabel")
            local TabL = Instance.new("UIListLayout")
            local UIPadding = Instance.new("UIPadding")
            
            SectionSplit.Name = "SectionSplit"
            SectionSplit.Parent = Section
            SectionSplit.BackgroundColor3 = Color3.fromRGB(37, 44, 72)
            SectionSplit.BackgroundTransparency = 1.000
            SectionSplit.BorderSizePixel = 0
            SectionSplit.ClipsDescendants = true
            SectionSplit.Size = UDim2.new(0.981000066, 0, -0.025559105, 44)
            
            SectionC.CornerRadius = UDim.new(0, 6)
            SectionC.Name = "SectionC"
            SectionC.Parent = SectionSplit
            
            SectionName.Name = "SectionName"
            SectionName.Parent = SectionSplit
            SectionName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionName.BackgroundTransparency = 1.000
            SectionName.Position = UDim2.new(0.18319124, 0, -1.18047225, 0)
            SectionName.Size = UDim2.new(0, 401, 0, 36)
            SectionName.Font = Enum.Font.GothamMedium
            SectionName.Text = name
            SectionName.TextColor3 = theme.accent
            SectionName.TextSize = 16.000
            SectionName.TextXAlignment = Enum.TextXAlignment.Left
            
            SectionOpened.Name = "SectionOpened"
            SectionOpened.Parent = SectionName
            SectionOpened.BackgroundTransparency = 1.000
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
            
		end
        
        function TabHolder:Button(name,callback)
            local ButtonFrame = Instance.new("Frame")
            local Button = Instance.new("TextButton")
            local ButtonC = Instance.new("UICorner")
            
            ButtonFrame.Name = "ButtonFrame"
            ButtonFrame.Parent = Section
            ButtonFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ButtonFrame.BackgroundTransparency = 1.000
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
            Button.Text = "   "..name
            Button.TextColor3 = theme.accent
            Button.TextSize = 16.000
            Button.TextXAlignment = Enum.TextXAlignment.Left
            
            ButtonC.CornerRadius = UDim.new(0, 6)
            ButtonC.Name = "ButtonC"
            ButtonC.Parent = Button
            
            Button.MouseButton1Click:Connect(function()
            spawn(function()
                Ripple(Button)
            end)
                spawn(callback)
            end)
            
            local funcs = {
                updateName = function(newName)
                    Button.Text = "   " .. newName
                end,
                currentName = function()
                    return Button.Text
                end,
                Module = ButtonFrame
            }
            
            return funcs
        end
                
        function TabHolder:Label(text)
            local LabelFrame = Instance.new("Frame")
            local Label = Instance.new("TextLabel")
            local LabelC = Instance.new("UICorner")
            
            LabelFrame.Name = "LabelFrame"
            LabelFrame.Parent = Section
            LabelFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            LabelFrame.BackgroundTransparency = 1.000
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
            Label.TextSize = 16.000
            Label.TextXAlignment = Enum.TextXAlignment.Center
            
            LabelC.CornerRadius = UDim.new(0, 6)
            LabelC.Name = "LabelC"
            LabelC.Parent = Label

            local funcs = {
                SetValue = function(self, newText)
                    Label.Text = tostring(newText)
                end,
                Module = LabelFrame,
                GetText = function()
                    return Label.Text
                end
            }

            return funcs
        end

        
        function TabHolder:Toggle(name,flag,val,callback)
            local callback = callback or function() end
            local val = val or false
            assert(name,"Name Missing")
            assert(flag,"Flag Missing")
            library.flags[flag] = val
            
            local ToggleFrame = Instance.new("Frame")
            local ToggleBtn = Instance.new("TextButton")
            local ToggleBtnC = Instance.new("UICorner")
            local ToggleDisable = Instance.new("Frame")
            local ToggleSwitch = Instance.new("Frame")
            local ToggleSwitchC = Instance.new("UICorner")
            local ToggleDisableC = Instance.new("UICorner")
            
            ToggleFrame.Name = "ToggleFrame"
            ToggleFrame.Parent = Section
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleFrame.BackgroundTransparency = 1.000
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Size = UDim2.new(0, 428, 0, 38)
            
            ToggleBtn.Name = "ToggleBtn"
            ToggleBtn.Parent = ToggleFrame
            ToggleBtn.BackgroundColor3 = theme.main
            ToggleBtn.BorderSizePixel = 0
            ToggleBtn.Size = UDim2.new(0, 428, 0, 38)
            ToggleBtn.AutoButtonColor = false
            ToggleBtn.Font = Enum.Font.GothamMedium
            ToggleBtn.Text = "   "..name
            ToggleBtn.TextColor3 = theme.accent
            ToggleBtn.TextSize = 16.000
            ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
            
            ToggleBtnC.CornerRadius = UDim.new(0, 6)
            ToggleBtnC.Name = "ToggleBtnC"
            ToggleBtnC.Parent = ToggleBtn
            
            ToggleDisable.Name = "ToggleDisable"
            ToggleDisable.Parent = ToggleBtn
            ToggleDisable.BackgroundColor3 = theme.secondary
            ToggleDisable.BorderSizePixel = 0
            ToggleDisable.Position = UDim2.new(0.901869178, 0, 0.208881587, 0)
            ToggleDisable.Size = UDim2.new(0, 36, 0, 22)
            
            ToggleSwitch.Name = "ToggleSwitch"
            ToggleSwitch.Parent = ToggleDisable
            ToggleSwitch.BackgroundColor3 = theme.accent
            ToggleSwitch.Size = UDim2.new(0, 24, 0, 22)
            
            ToggleSwitchC.CornerRadius = UDim.new(0, 6)
            ToggleSwitchC.Name = "ToggleSwitchC"
            ToggleSwitchC.Parent = ToggleSwitch
            
            ToggleDisableC.CornerRadius = UDim.new(0, 6)
            ToggleDisableC.Name = "ToggleDisableC"
            ToggleDisableC.Parent = ToggleDisable
            
            local funcs = {
            SetState = function(self, state)
                if state == nil then state = not library.flags[flag] end
                if library.flags[flag] == state then return end
                game.TweenService:Create(ToggleSwitch, TweenInfo.new(0.2), {Position = UDim2.new(0, (state and ToggleSwitch.Size.X.Offset / 2 or 0), 0, 0), BackgroundColor3 = (state and theme.accent3 or theme.accent)}):Play()
                library.flags[flag] = state
                callback(state)
            end,
          Module = ToggleFrame
        }
        
        if val == true then
            funcs:SetState(flag,true)
        end
        
        ToggleBtn.MouseButton1Click:Connect(function()
            funcs:SetState()
        end)
        return funcs
    end
        
        function TabHolder:KeyBind(name,default,callback)
            callback = callback or function() end
            assert(name,"Name Missing")
            assert(default,"Missing Default Key")
            
            local default = (typeof(default) == "string" and Enum.KeyCode[default] or default)
            local banned = {
              Return = true;
              Space = true;
              Tab = true;
              Backquote = true;
              CapsLock = true;
              Escape = true;
              Unknown = true;
            }
            local shortNames = {
              RightControl = 'Right Ctrl',
              LeftControl = 'Left Ctrl',
              LeftShift = 'Left Shift',
              RightShift = 'Right Shift',
              Semicolon = ";",
              Quote = '"',
              LeftBracket = '[',
              RightBracket = ']',
              Equals = '=',
              Minus = '-',
              RightAlt = 'Right Alt',
              LeftAlt = 'Left Alt'
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
            KeybindFrame.BackgroundTransparency = 1.000
            KeybindFrame.BorderSizePixel = 0
            KeybindFrame.Size = UDim2.new(0, 428, 0, 38)
            
            KeybindBtn.Name = "KeybindBtn"
            KeybindBtn.Parent = KeybindFrame
            KeybindBtn.BackgroundColor3 = theme.main
            KeybindBtn.BorderSizePixel = 0
            KeybindBtn.Size = UDim2.new(0, 428, 0, 38)
            KeybindBtn.AutoButtonColor = false
            KeybindBtn.Font = Enum.Font.GothamMedium
            KeybindBtn.Text = "   "..name
            KeybindBtn.TextColor3 = theme.accent
            KeybindBtn.TextSize = 16.000
            KeybindBtn.TextXAlignment = Enum.TextXAlignment.Left
            
            KeybindBtnC.CornerRadius = UDim.new(0, 6)
            KeybindBtnC.Name = "KeybindBtnC"
            KeybindBtnC.Parent = KeybindBtn
            
            KeybindValue.Name = "KeybindValue"
            KeybindValue.Parent = KeybindBtn
            KeybindValue.BackgroundColor3 = theme.secondary
            KeybindValue.BorderSizePixel = 0
            KeybindValue.Position = UDim2.new(0.763033211, 0, 0.289473683, 0)
            KeybindValue.Size = UDim2.new(0, 40, 0, 28)
            KeybindValue.AutoButtonColor = false
            KeybindValue.Font = Enum.Font.Gotham
            KeybindValue.Text = keyTxt
            KeybindValue.TextColor3 = theme.accent
            KeybindValue.TextSize = 18.000
            
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
              wait()
              local key, uwu = game.UserInputService.InputEnded:Wait()
              local keyName = tostring(key.KeyCode.Name)
              if key.UserInputType ~= Enum.UserInputType.Keyboard then
                KeybindValue.Text = keyTxt
                return
              end
              if banned[keyName] then
                KeybindValue.Text = keyTxt
                return
              end
              wait()
              bindKey = Enum.KeyCode[keyName]
              KeybindValue.Text = shortNames[keyName] or keyName
            end)
            
            KeybindValue:GetPropertyChangedSignal("TextBounds"):Connect(function()
              KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 30, 0, 28)
            end)
            KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 30, 0, 28)
        end
        
        function TabHolder:TextBox(name,flag,default,callback)
            local callback = callback or function() end
            assert(name,"Name Missing")
            assert(flag,"Flag Missing")
            assert(default,"default Missing")
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
            TextboxFrame.BackgroundTransparency = 1.000
            TextboxFrame.BorderSizePixel = 0
            TextboxFrame.Size = UDim2.new(0, 428, 0, 38)
            
            TextboxBack.Name = "TextboxBack"
            TextboxBack.Parent = TextboxFrame
            TextboxBack.BackgroundColor3 = theme.main
            TextboxBack.BorderSizePixel = 0
            TextboxBack.Size = UDim2.new(0, 428, 0, 38)
            TextboxBack.AutoButtonColor = false
            TextboxBack.Font = Enum.Font.GothamMedium
            TextboxBack.Text = "   "..name
            TextboxBack.TextColor3 = theme.accent
            TextboxBack.TextSize = 16.000
            TextboxBack.TextXAlignment = Enum.TextXAlignment.Left
            
            TextboxBackC.CornerRadius = UDim.new(0, 6)
            TextboxBackC.Name = "TextboxBackC"
            TextboxBackC.Parent = TextboxBack
            
            BoxBG.Name = "BoxBG"
            BoxBG.Parent = TextboxBack
            BoxBG.BackgroundColor3 = theme.secondary
            BoxBG.BorderSizePixel = 0
            BoxBG.Position = UDim2.new(0.763033211, 0, 0.289473683, 0)
            BoxBG.Size = UDim2.new(0, 57, 0, 28)
            BoxBG.AutoButtonColor = false
            BoxBG.Font = Enum.Font.Gotham
            BoxBG.Text = ""
            BoxBG.TextColor3 = theme.accent
            BoxBG.TextSize = 14.000
            
            BoxBGC.CornerRadius = UDim.new(0, 6)
            BoxBGC.Name = "BoxBGC"
            BoxBGC.Parent = BoxBG
            
            TextBox.Parent = BoxBG
            TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TextBox.BackgroundTransparency = 1.000
            TextBox.BorderSizePixel = 0
            TextBox.Size = UDim2.new(1, 0, 1, 0)
            TextBox.Font = Enum.Font.Gotham
            TextBox.Text = default
            TextBox.TextColor3 = theme.accent
            TextBox.TextSize = 18.000
            
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
        
        function TabHolder:Dropdown(name,flag,options,resettext,callback)
            local callback = callback or function() end
            local options = options or {}
            assert(name,"Name Missing")
            assert(flag,"Flag Missing")
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
            DropdownFrame.BackgroundTransparency = 1.000
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
            DropdownTop.TextSize = 16.000
            DropdownTop.TextXAlignment = Enum.TextXAlignment.Left
            
            DropdownTopC.CornerRadius = UDim.new(0, 6)
            DropdownTopC.Name = "DropdownTopC"
            DropdownTopC.Parent = DropdownTop
            
            DropdownOpen.Name = "DropdownOpen"
            DropdownOpen.Parent = DropdownTop
            DropdownOpen.AnchorPoint = Vector2.new(0, 0.5)
            DropdownOpen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            DropdownOpen.BackgroundTransparency = 1.000
            DropdownOpen.BorderSizePixel = 0
            DropdownOpen.Position = UDim2.new(0.918383181, 0, 0.5, 0)
            DropdownOpen.Size = UDim2.new(0, 20, 0, 20)
            DropdownOpen.Font = Enum.Font.Gotham
            DropdownOpen.Text = "+"
            DropdownOpen.TextColor3 = theme.accent3
            DropdownOpen.TextSize = 24.000
            DropdownOpen.TextWrapped = true
            
            DropdownText.Name = "DropdownText"
            DropdownText.Parent = DropdownTop
            DropdownText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            DropdownText.BackgroundTransparency = 1.000
            DropdownText.BorderSizePixel = 0
            DropdownText.Position = UDim2.new(0, 0, 0, 0)
            DropdownText.Size = UDim2.new(0, 184, 0, 38)
            DropdownText.Font = Enum.Font.GothamMedium
            DropdownText.PlaceholderColor3 = Color3.fromRGB(255, 255, 255)
            DropdownText.Text = "   "..name
            DropdownText.TextColor3 = theme.accent
            DropdownText.TextSize = 16.000
            DropdownText.TextXAlignment = Enum.TextXAlignment.Left
            
            DropdownFrameL.Name = "DropdownFrameL"
            DropdownFrameL.Parent = DropdownFrame
            DropdownFrameL.SortOrder = Enum.SortOrder.LayoutOrder
            DropdownFrameL.Padding = UDim.new(0, 4)
            
            local setAllVisible = function()
              local options = DropdownFrame:GetChildren() 
              for i=1, #options do
                local option = options[i]
                if option:IsA("TextButton") and option.Name:match("Option_") then
                  option.Visible = true
                end
              end
            end
            
            local searchDropdown = function(text)
              local options = DropdownFrame:GetChildren()
              for i=1, #options do
                local option = options[i]
                if text == "" then
                  setAllVisible()
                else
                  if option:IsA("TextButton") and option.Name:match("Option_") then
                    if option.Text:lower():match(text:lower()) then
                      option.Visible = true
                    else
                      option.Visible = false
                    end
                  end
                end
              end
            end
            
            local open = false
            local ToggleDropVis = function()
                open = not open
                if open then setAllVisible() end
                DropdownOpen.Text = (open and "-" or "+")
                DropdownFrame.Size = UDim2.new(0, 428, 0, (open and DropdownFrameL.AbsoluteContentSize.Y + 4 or 38))
            end
            
            DropdownOpen.MouseButton1Click:Connect(ToggleDropVis)
                DropdownText.Focused:Connect(function()
                if open then return end
                ToggleDropVis()
            end)
        
            local prefix = "   "

            DropdownText:GetPropertyChangedSignal("Text"):Connect(function()
                if not open then return end

                if not DropdownText.Text:find("^"..prefix) then
                    DropdownText.Text = prefix .. DropdownText.Text:gsub("^%s*", "")
                    DropdownText.CursorPosition = #DropdownText.Text + 1
                    return
                end

                local searchText = DropdownText.Text:sub(#prefix + 1) 
                searchDropdown(searchText)
            end)

                
            DropdownFrameL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
              if not open then return end
              DropdownFrame.Size = UDim2.new(0, 428, 0, (DropdownFrameL.AbsoluteContentSize.Y + 4))
            end)
            
            local funcs = {}
            
             funcs.AddOption = function(self,option)
                local Option = Instance.new("TextButton")
                local OptionC = Instance.new("UICorner")
                
                Option.Name = "Option_"..option
                Option.Parent = DropdownFrame
                Option.BackgroundColor3 = theme.main
                Option.BorderSizePixel = 0
                Option.Position = UDim2.new(0, 0, 0.328125, 0)
                Option.Size = UDim2.new(0, 428, 0, 26)
                Option.AutoButtonColor = false
                Option.Font = Enum.Font.Gotham
                Option.Text = option
                Option.TextColor3 = theme.accent
                Option.TextSize = 14.000
                
                OptionC.CornerRadius = UDim.new(0, 6)
                OptionC.Name = "OptionC"
                OptionC.Parent = Option
                
                Option.MouseButton1Click:Connect(function()
                    ToggleDropVis()
                    callback(Option.Text)
                    if not resettext then
                        DropdownText.Text = Option.Text
                    end
                    library.flags[flag] = Option.Text
                end)
            end
                
                funcs.SetOptions = function(self, options)
                  for _, v in next, DropdownFrame:GetChildren() do
                    if v.Name:match("Option_") then
                      v:Destroy()
                    end
                  end
                  for _,v in next, options do
                    funcs:AddOption(v)
                  end
                end
        
            funcs:SetOptions(options)
            
            return funcs
        end
        
        function TabHolder:Slider(name,flag,default,min,max,precise,callback)
            local callback = callback or function() end
            local min = min or 1
            local max = max or 100
            local default = default or min
            local precise = precise or false
            library.flags[flag] = default
            assert(name,"Name Missing")
            assert(flag,"Flag Missing")
            
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
            SliderFrame.BackgroundTransparency = 1.000
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Size = UDim2.new(0, 428, 0, 38)
            
            SliderBack.Name = "SliderBack"
            SliderBack.Parent = SliderFrame
            SliderBack.BackgroundColor3 = theme.main
            SliderBack.BorderSizePixel = 0
            SliderBack.Size = UDim2.new(0, 428, 0, 38)
            SliderBack.AutoButtonColor = false
            SliderBack.Font = Enum.Font.GothamMedium
            SliderBack.Text = "   "..name
            SliderBack.TextColor3 = theme.accent
            SliderBack.TextSize = 16.000
            SliderBack.TextXAlignment = Enum.TextXAlignment.Left
            
            SliderBackC.CornerRadius = UDim.new(0, 6)
            SliderBackC.Name = "SliderBackC"
            SliderBackC.Parent = SliderBack
            
            SliderBar.Name = "SliderBar"
            SliderBar.Parent = SliderBack
            SliderBar.AnchorPoint = Vector2.new(0, 0.5)
            SliderBar.BackgroundColor3 = theme.secondary
            SliderBar.BorderSizePixel = 0
            SliderBar.Position = UDim2.new(0.369000018, 40, 0.5, 0)
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
            SliderValBG.Position = UDim2.new(0.883177578, 0, 0.131578952, 0)
            SliderValBG.Size = UDim2.new(0, 44, 0, 28)
            SliderValBG.AutoButtonColor = false
            SliderValBG.Font = Enum.Font.Gotham
            SliderValBG.Text = ""
            SliderValBG.TextColor3 = theme.accent
            SliderValBG.TextSize = 14.000
            
            SliderValBGC.CornerRadius = UDim.new(0, 6)
            SliderValBGC.Name = "SliderValBGC"
            SliderValBGC.Parent = SliderValBG
            
            SliderValue.Name = "SliderValue"
            SliderValue.Parent = SliderValBG
            SliderValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SliderValue.BackgroundTransparency = 1.000
            SliderValue.BorderSizePixel = 0
            SliderValue.Size = UDim2.new(1, 0, 1, 0)
            SliderValue.Font = Enum.Font.Gotham
            SliderValue.Text = "16"
            SliderValue.TextColor3 = theme.accent
            SliderValue.TextSize = 18.000
            
            MinSlider.Name = "MinSlider"
            MinSlider.Parent = SliderFrame
            MinSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            MinSlider.BackgroundTransparency = 1.000
            MinSlider.BorderSizePixel = 0
            MinSlider.Position = UDim2.new(0.296728969, 40, 0.236842096, 0)
            MinSlider.Size = UDim2.new(0, 20, 0, 20)
            MinSlider.Font = Enum.Font.Gotham
            MinSlider.Text = "-"
            MinSlider.TextColor3 = theme.accent
            MinSlider.TextSize = 24.000
            MinSlider.TextWrapped = true
            
            AddSlider.Name = "AddSlider"
            AddSlider.Parent = SliderFrame
            AddSlider.AnchorPoint = Vector2.new(0, 0.5)
            AddSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            AddSlider.BackgroundTransparency = 1.000
            AddSlider.BorderSizePixel = 0
            AddSlider.Position = UDim2.new(0.810906529, 0, 0.5, 0)
            AddSlider.Size = UDim2.new(0, 20, 0, 20)
            AddSlider.Font = Enum.Font.Gotham
            AddSlider.Text = "+"
            AddSlider.TextColor3 = theme.accent
            AddSlider.TextSize = 24.000
            AddSlider.TextWrapped = true
            
            local funcs = {
                SetValue = function(self, value)
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
            end,
            
            SetMin = function(self, newMin)
                min = newMin or min
            end,
            
            SetMax = function(self, newMax)
                max = newMax or max
            end,
            }

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

            local dragging, boxFocused, allowed = false, false, {
              [""] = true,
              ["-"] = true
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
                SliderValue.Text = SliderValue.Text:gsub('%D+', '')
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
		return TabHolder
	end
	return Holder
end










local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local ARREST_STABLE_KEY = "n90a2oyr"        
local VEHICLE_ENTRY_STABLE_KEY = "eol2ojbr"  
local VEHICLE_EXIT_STABLE_KEY = "ofu0irqi"   
local VEHICLE_EJECT_STABLE_KEY = "frxkxciw"  

local HOVER_HEIGHT = 700
local MIN_HEIGHT_ABOVE_GROUND = 30
local DROP_OFFSET_STUDS = 10
local FLY_SPEED_CAR = 500
local FLY_SPEED_FOOT = 100      
local ROOF_RAYCAST_HEIGHT = 150    
local JAIL_TELEPORT_DIST = 10000  
local TELEPORT_JUMP_THRESHOLD = 500 

local MAX_HORIZONTAL_SPEED = 1000    
local HOVER_ADJUST_SPEED = 50        
local VERTICAL_SNAP_THRESHOLD = 5    

local MAX_VEHICLE_RETRIES = 5
local MAX_ARREST_RETRIES = 3
local STUCK_TIMEOUT = 5           
local RETRY_COOLDOWN = 1          

local COVERAGE_CHECK_INTERVAL = 0.1
local MAX_COVERED_TIME = 5 

local ALLOWED_VEHICLES = {
    ["Jeep"] = true,
    ["Camaro"] = true,
}

local SPAWN_PATHS = {
    [Vector3.new(765, 22, -3345)] = {
        Vector3.new(764, 22, -3341),
        Vector3.new(777, 22, -3336),
        Vector3.new(782, 23, -3348),
        Vector3.new(810, 25, -3336),
    },

    [Vector3.new(742, 40, 1132)] = {
        Vector3.new(738, 40, 1134),
        Vector3.new(728, 40, 1109),
        Vector3.new(734, 42, 1106),
        Vector3.new(715, 44, 1058),
    },

    [Vector3.new(-1187, 20, -1581)] = {
        Vector3.new(-1174, 21, -1581),
        Vector3.new(-1173, 23, -1620),
    },

    [Vector3.new(-1143, 20, -1572)] = {
        Vector3.new(-1174, 21, -1581),
        Vector3.new(-1173, 23, -1620),
    },

    [Vector3.new(-1123, 20, -1589)] = {
        Vector3.new(-1127, 20, -1585),
        Vector3.new(-1173, 21, -1584),
        Vector3.new(-1173, 23, -1620),
    },

    [Vector3.new(-1175, 19, -1583)] = {
        Vector3.new(-1173, 21, -1584),
        Vector3.new(-1173, 23, -1620),
    },

    [Vector3.new(-1164, 19, -1580)] = {
        Vector3.new(-1173, 21, -1584),
        Vector3.new(-1173, 23, -1620),
    },

    [Vector3.new(-1176, 40, -1582)] = {
        Vector3.new(-1159, 40, -1581),
        Vector3.new(-1160, 41, -1566),
        Vector3.new(-1122, 43, -1566),
    },
}

local SPAWN_PATH_TOLERANCE = 15 

local LocalPlayer = Players.LocalPlayer
local Remote = nil
local KeyMap = {}
local AutoArrestEnabled = false
local CurrentVehicle = nil
local ActionInProgress = false
local MainLoopConnection = nil
local NoclipConnection = nil
local TargetPositionHistory = {}
local ExitedCarRef = nil

local VehicleRetryCount = 0
local ArrestRetryCount = 0
local LastActionTime = 0
local StuckCheckPosition = nil

local oldRayCast = nil
local shootTarget = nil

local CoverageCheckConnection = nil
local TargetCoveredStartTime = nil
local SelfCoveredStartTime = nil
local IsExecutingSpawnPath = false

local v3new = Vector3.new
local cfNew = CFrame.new
local heartbeat = RunService.Heartbeat
local stepped = RunService.Stepped

do
    local found = false
    for _, v in getgc(false) do
        if typeof(v) == "function" and islclosure(v) and debug.info(v, "n") == "EventFireServer" then
            local ups = debug.getupvalues(v)
            if #ups >= 3 and typeof(ups[2]) == "Instance" and type(ups[3]) == "table" then
                local rawTable = ups[3]
                if rawTable[ARREST_STABLE_KEY] then
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
    if not found then warn("Debug: KEYS NOT FOUND - SCRIPT WILL LIKELY FAIL") end
end

local function getHRP() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") end
local function getHumanoid() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") end

local function killVelocity(part)
    if part then
        part.Velocity = Vector3.zero
        part.RotVelocity = Vector3.zero
        if part.AssemblyLinearVelocity then
            part.AssemblyLinearVelocity = Vector3.zero
        end
    end
end

local function getBountyData()
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

local function getPlayerBounty(playerName)
    local bountyData = getBountyData()
    for _, entry in ipairs(bountyData) do
        if entry.Name == playerName then
            return entry.Bounty or 0
        end
    end
    return 0
end

local function hasPlayerEscaped(player)
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

local function getSafeHeight(position)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, CurrentVehicle}
    
    local ray = Workspace:Raycast(position, Vector3.new(0, -500, 0), raycastParams)
    
    if ray then
        return math.max(ray.Position.Y + MIN_HEIGHT_ABOVE_GROUND, position.Y)
    end
    
    return position.Y
end

local function isCovered(position, targetPlayer)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local excludeList = {LocalPlayer.Character}
    
    if targetPlayer and targetPlayer.Character then
        table.insert(excludeList, targetPlayer.Character)
    end

    raycastParams.FilterDescendantsInstances = excludeList
    raycastParams.IgnoreWater = true
    
    local startPosition = position + Vector3.new(0, 5, 0)
    local ray = Workspace:Raycast(startPosition, Vector3.new(0, ROOF_RAYCAST_HEIGHT, 0), raycastParams)

    return ray ~= nil
end

local function amICovered()
    local root = getHRP()
    if not root then return false end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, CurrentVehicle}
    raycastParams.IgnoreWater = true
    
    local startPosition = root.Position + Vector3.new(0, 5, 0)
    local ray = Workspace:Raycast(startPosition, Vector3.new(0, ROOF_RAYCAST_HEIGHT, 0), raycastParams)
    
    return ray ~= nil
end


local function flyTowards3D(targetPos, speed, moverPart)
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

local function findSpawnPath()
    local root = getHRP()
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

local function safeVerticalTeleport(targetPos)
    local root = getHRP()
    local hum = getHumanoid()
    if not root or not hum then return end
    
    if amICovered() then
        local spawnPath = findSpawnPath()
        if spawnPath then
            executeSpawnPath(spawnPath)
            task.wait(1)
            return
        end
    end
    
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
        killVelocity(moverPart)
    end
end



local function executeSpawnPath(waypoints)
    if IsExecutingSpawnPath then return end
    IsExecutingSpawnPath = true
    
    local root = getHRP()
    local hum = getHumanoid()
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
    
    for i, waypoint in ipairs(waypoints) do
        local startTime = tick()
        local WAYPOINT_TIMEOUT = 10
        
        while true do
            root = getHRP()
            if not root or not root.Parent then break end
            
            local dist = (root.Position - waypoint).Magnitude
            if dist < 5 then break end
            if (tick() - startTime) > WAYPOINT_TIMEOUT then break end
            
            local direction = (waypoint - root.Position).Unit
            root.AssemblyLinearVelocity = direction * FLY_SPEED_FOOT
            
            task.wait()
        end
        
        root = getHRP()
        if root then
            killVelocity(root)
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
    
    root = getHRP()
    if root then
        safeVerticalTeleport(v3new(root.Position.X, HOVER_HEIGHT, root.Position.Z))
    end
    
    IsExecutingSpawnPath = false
end

local function killSelf()
    local hum = getHumanoid()
    if hum then
        hum.Health = 0
    end
end

local function canEscapeCover()
    local root = getHRP()
    if not root then return false end
    
    local spawnPath = findSpawnPath()
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
        local upRay = Workspace:Raycast(checkPos + Vector3.new(0, 1, 0), Vector3.new(0, ROOF_RAYCAST_HEIGHT, 0), raycastParams)
        if not upRay then
            return true
        end
    end
    
    return false
end



local function flyToLocation(targetPos, isCar)
    local root = getHRP()
    if not root then return end
    
    if amICovered() then
        local spawnPath = findSpawnPath()
        if spawnPath then
            executeSpawnPath(spawnPath)
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
        safeVerticalTeleport(v3new(currentPos.X, targetY, currentPos.Z))
    end
end

local function cleanupState()
    local root = getHRP()
    local hum = getHumanoid()
    if not root or not hum then
        CurrentVehicle = nil
        ActionInProgress = false
        return
    end

    if CurrentVehicle then
        if not CurrentVehicle.PrimaryPart or not CurrentVehicle.Parent then
            CurrentVehicle = nil
            VehicleRetryCount = VehicleRetryCount + 1
            
            if hum.Sit then
                local key = KeyMap[VEHICLE_EXIT_STABLE_KEY]
                if key then Remote:FireServer(key) end
                task.wait(0.1)
            end
            safeVerticalTeleport(v3new(root.Position.X, HOVER_HEIGHT, root.Position.Z))
            ActionInProgress = false
            return
        end
    end

    if hum.Sit and not CurrentVehicle then
        local key = KeyMap[VEHICLE_EXIT_STABLE_KEY]
        if key then Remote:FireServer(key) end
        task.wait(0.1)
        safeVerticalTeleport(v3new(root.Position.X, HOVER_HEIGHT, root.Position.Z))
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
                task.wait(0.1)
            end
            
            safeVerticalTeleport(v3new(root.Position.X, HOVER_HEIGHT, root.Position.Z))
            StuckCheckPosition = nil
            return
        end
    end
    
    StuckCheckPosition = root.Position
    LastActionTime = tick()
end

local function getClosestVehicleToPlayer(player)
    if not player or not player.Character then return nil end
    local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
    if not playerRoot then return nil end
    
    local vFolder = Workspace:FindFirstChild("Vehicles")
    if not vFolder then return nil end
    
    local closest, dist = nil, 20
    
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

local function getTargetVehiclePart(player)
    if not player or not player.Character then return nil end
    local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
    if not playerRoot then return nil end
    
    local vFolder = Workspace:FindFirstChild("Vehicles")
    if not vFolder then return nil end
    
    local closest, dist = nil, 30
    
    for _, v in ipairs(vFolder:GetChildren()) do
        if v ~= ExitedCarRef then
            local part = v.PrimaryPart or (v:FindFirstChild("Body") and v.Body:FindFirstChild("Vehicle")) or v:FindFirstChildWhichIsA("BasePart")
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

local function getClosestVehicle()
    local root = getHRP()
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
                    if d < dist and prim.CFrame.UpVector.Y > 0.1 and not isCovered(prim.Position, nil) then
                        closest = vehicle
                        dist = d
                    end
                end
            end
        end
    end
    
    return closest
end

local function enterVehicleRoutine(vehicle)
    ActionInProgress = true
    local root = getHRP()
    local prim = vehicle.PrimaryPart
    
    if not root or not prim or not prim.Parent then
        ActionInProgress = false
        return false
    end
    
    if amICovered() then
        local spawnPath = findSpawnPath()
        if spawnPath then
            executeSpawnPath(spawnPath)
            task.wait(1)
        elseif not canEscapeCover() then
            killSelf()
            ActionInProgress = false
            return false
        end
    end

    safeVerticalTeleport(v3new(root.Position.X, HOVER_HEIGHT, root.Position.Z))

    local targetPosXZ = v3new(prim.Position.X, HOVER_HEIGHT, prim.Position.Z)
    local t = tick()
    while (v3new(root.Position.X, 0, root.Position.Z) - v3new(prim.Position.X, 0, prim.Position.Z)).Magnitude > 10 and (tick() - t) < 10 do
        if not prim or not prim.Parent then
            ActionInProgress = false
            return false
        end
        flyToLocation(targetPosXZ, false)
        task.wait()
    end
    
    if not prim or not prim.Parent then
        ActionInProgress = false
        return false
    end
    
    local safeEntryHeight = math.max(prim.Position.Y + DROP_OFFSET_STUDS, getSafeHeight(prim.Position))
    safeVerticalTeleport(v3new(prim.Position.X, safeEntryHeight, prim.Position.Z))
    
    local key = KeyMap[VEHICLE_ENTRY_STABLE_KEY]
    if key then
        for i = 1, 5 do
            Remote:FireServer(key, vehicle, vehicle.Seat)
            if getHumanoid() and getHumanoid().Sit then break end
            task.wait(0.15)
        end
    end
    
    task.wait(0.2)
    
    local hum = getHumanoid()
    if hum and hum.Sit then
        CurrentVehicle = vehicle
        VehicleRetryCount = 0
        safeVerticalTeleport(v3new(prim.Position.X, HOVER_HEIGHT, prim.Position.Z))
        ActionInProgress = false
        return true
    else
        CurrentVehicle = nil
        safeVerticalTeleport(v3new(root.Position.X, HOVER_HEIGHT, root.Position.Z))
        ActionInProgress = false
        return false
    end
end

local function exitVehicleRoutine()
    local hum = getHumanoid()
    if not CurrentVehicle or not hum or not hum.Sit then return end
    
    local key = KeyMap[VEHICLE_EXIT_STABLE_KEY]
    if key then
        Remote:FireServer(key)
    end
    task.wait(0.05)
    ExitedCarRef = CurrentVehicle
    CurrentVehicle = nil
end

local function getBestTarget()
    local root = getHRP()
    if not root then return nil end
    
    local validTargets = {}
    local rootPos = root.Position
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team and (p.Team.Name == "Criminal" or p.Team.Name == "Prisoner") then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
                local tRoot = p.Character.HumanoidRootPart
                local tHum = p.Character.Humanoid
                local currentPos = tRoot.Position
                
                if not hasPlayerEscaped(p) then continue end
                
                local isTeleporting = false
                local lastPos = TargetPositionHistory[p]
                
                if lastPos then
                    local jumpDistance = (currentPos - lastPos).Magnitude
                    if jumpDistance > TELEPORT_JUMP_THRESHOLD then
                        isTeleporting = true
                    end
                end
                
                TargetPositionHistory[p] = currentPos
                
                if not isTeleporting then
                    local dist = (rootPos - currentPos).Magnitude
                    
                    if dist <= JAIL_TELEPORT_DIST then
                        if not isCovered(currentPos, p) then
                            local isAlive = tHum.Health > 0
                            local isSafe = p.Character:FindFirstChild("ForceField") ~= nil
                            
                            if isAlive and not isSafe then
                                local bounty = getPlayerBounty(p.Name)
                                
                                table.insert(validTargets, {
                                    player = p,
                                    distance = dist,
                                    bounty = bounty,
                                    isCriminal = p.Team.Name == "Criminal"
                                })
                            end
                        end
                    end
                end
            end
        end
    end

    table.sort(validTargets, function(a, b)
        if a.bounty ~= b.bounty then return a.bounty > b.bounty end
        if a.isCriminal ~= b.isCriminal then return a.isCriminal end
        return a.distance < b.distance
    end)
    
    if #validTargets > 0 then
        local best = validTargets[1]
        return best.player
    end
    
    return nil
end

local function shoot()
    local gun = require(ReplicatedStorage.Game.ItemSystem.ItemSystem).GetLocalEquipped()
    if gun then
        require(ReplicatedStorage.Game.Item.Gun)._attemptShoot(gun)
    end
end

local function setupSilentAim(targetPart)
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

local function resetSilentAim()
    if oldRayCast then
        require(ReplicatedStorage.Module.RayCast).RayIgnoreNonCollideWithIgnoreList = oldRayCast
    end
    shootTarget = nil
end

local function shootTargetVehicle(target)
    local folder = LocalPlayer:FindFirstChild("Folder")
    if not folder then return end
    
    local pistol = folder:FindFirstChild("Pistol")
    if not pistol then 
        return 
    end
    
    local vehiclePart = getTargetVehiclePart(target)
    if not vehiclePart then
        return
    end
    
    pistol.InventoryEquipRemote:FireServer(true)
    task.wait(0.2)
    
    local reloadRemote = pistol:FindFirstChild("Reload")
    if reloadRemote and reloadRemote:IsA("RemoteEvent") then
        reloadRemote:FireServer()
        task.wait(0.5)
    end
    
    setupSilentAim(vehiclePart)
    
    for i = 1, 15 do
        shoot()
        task.wait(0.2)
    end
    
    if reloadRemote and reloadRemote:IsA("RemoteEvent") then
        reloadRemote:FireServer()
        task.wait(0.5)
    end
    
    resetSilentAim()
    
    pistol.InventoryEquipRemote:FireServer(false)
    task.wait(0.1)
end

local function arrestSequence(target)
    ActionInProgress = true
    ExitedCarRef = nil
    local targetName = target.Name
    local root = getHRP()
    local hum = getHumanoid()

    local tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not tRoot then
        ActionInProgress = false
        return false
    end
    
    local tStart = tick()
    local ejectKey = KeyMap[VEHICLE_EJECT_STABLE_KEY]
    local arrestKey = KeyMap[ARREST_STABLE_KEY]
    local folder = LocalPlayer:FindFirstChild("Folder")

    if amICovered() then
        local spawnPath = findSpawnPath()
        if spawnPath then
            executeSpawnPath(spawnPath)
            task.wait(1)
        elseif not canEscapeCover() then
            killSelf()
            ActionInProgress = false
            return false
        end
    end

    if CurrentVehicle and CurrentVehicle.PrimaryPart then
        safeVerticalTeleport(v3new(CurrentVehicle.PrimaryPart.Position.X, HOVER_HEIGHT, CurrentVehicle.PrimaryPart.Position.Z))
    end
    task.wait(0.1)

    local lastCoverageCheck = tick()
    
    while hum and hum.Sit and CurrentVehicle and CurrentVehicle.PrimaryPart do
        tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if not tRoot or not tRoot.Parent then break end
        if not hasPlayerEscaped(target) then break end
        
        if (tick() - lastCoverageCheck) >= COVERAGE_CHECK_INTERVAL then
            lastCoverageCheck = tick()
            if isCovered(tRoot.Position, target) then
                break
            end
        end
        
        local currentTargetPos = tRoot.Position
        local prim = CurrentVehicle.PrimaryPart
        root = getHRP()
        if not root or not prim or not prim.Parent then break end
        
        local aboveTarget = v3new(currentTargetPos.X, HOVER_HEIGHT, currentTargetPos.Z)
        flyTowards3D(aboveTarget, FLY_SPEED_CAR, prim)
        
        local horizontalDist = (v3new(prim.Position.X, 0, prim.Position.Z) - v3new(currentTargetPos.X, 0, currentTargetPos.Z)).Magnitude
        
        if horizontalDist < 15 then
            killVelocity(prim)
            break
        end
        
        if (tick() - tStart) > 30 then break end
        task.wait()
    end

    tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if tRoot and isCovered(tRoot.Position, target) then
        ActionInProgress = false
        return false
    end

    while hum and hum.Sit and CurrentVehicle and CurrentVehicle.PrimaryPart do
        tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if not tRoot or not tRoot.Parent then break end
        if not hasPlayerEscaped(target) then break end
        
        if (tick() - lastCoverageCheck) >= COVERAGE_CHECK_INTERVAL then
            lastCoverageCheck = tick()
            if isCovered(tRoot.Position, target) then
                break
            end
        end
        
        local currentTargetPos = tRoot.Position
        local prim = CurrentVehicle.PrimaryPart
        root = getHRP()
        if not root or not prim or not prim.Parent then break end
        
        local targetHeight = currentTargetPos.Y + DROP_OFFSET_STUDS
        local goalPos = v3new(currentTargetPos.X, targetHeight, currentTargetPos.Z)
        
        flyTowards3D(goalPos, FLY_SPEED_CAR, prim)
        
        local horizontalDist = (v3new(prim.Position.X, 0, prim.Position.Z) - v3new(currentTargetPos.X, 0, currentTargetPos.Z)).Magnitude
        local verticalDist = math.abs(prim.Position.Y - targetHeight)
        
        if horizontalDist < 15 and verticalDist < 15 then
            killVelocity(prim)
            break
        end
        
        if (tick() - tStart) > 40 then break end
        task.wait()
    end

    if CurrentVehicle and CurrentVehicle.PrimaryPart then
        killVelocity(CurrentVehicle.PrimaryPart)
    end
    exitVehicleRoutine()
    task.wait(0.2)

    shootTargetVehicle(target)

    local targetVehicle = getClosestVehicleToPlayer(target)
    if targetVehicle and ejectKey then
        for i = 1, 5 do
            if folder and folder:FindFirstChild("Handcuffs") then
                folder.Handcuffs.InventoryEquipRemote:FireServer(true)
            end
            Remote:FireServer(ejectKey, targetVehicle)
            task.wait(0.1)
        end
    end
    task.wait(0.2)
    
    if folder and folder:FindFirstChild("Handcuffs") then
        folder.Handcuffs.InventoryEquipRemote:FireServer(true)
        task.wait(0.1)
    end
    
    local chaseStartTime = tick()
    local CHASE_TIMEOUT = 10
    local success = false
    safeVerticalTeleport(v3new(root.Position.X, root.Position.Y + MIN_HEIGHT_ABOVE_GROUND, root.Position.Z))
    
    while true do
        tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if not tRoot or not tRoot.Parent then break end
        if not hasPlayerEscaped(target) then
            success = true
            break
        end
        if (tick() - chaseStartTime) > CHASE_TIMEOUT then break end
        
        if (tick() - lastCoverageCheck) >= COVERAGE_CHECK_INTERVAL then
            lastCoverageCheck = tick()
            if isCovered(tRoot.Position, target) then
                break
            end
        end
        
        local tPos = tRoot.Position
        root = getHRP()
        if not root then break end
        
        local dist = (root.Position - tPos).Magnitude
        
        local chaseTarget = v3new(tPos.X, tPos.Y + 3, tPos.Z)
        flyTowards3D(chaseTarget, FLY_SPEED_FOOT, root)
        
        if dist < 25 and arrestKey then
            if folder and folder:FindFirstChild("Handcuffs") then
                folder.Handcuffs.InventoryEquipRemote:FireServer(true)
            end
            Remote:FireServer(arrestKey, targetName)
            Remote:FireServer(arrestKey, targetName)
            Remote:FireServer(arrestKey, targetName)
        end
        
        local currentTargetVehicle = getClosestVehicleToPlayer(target)
        if currentTargetVehicle and ejectKey then
            Remote:FireServer(ejectKey, currentTargetVehicle)
        end
        
        task.wait()
    end
    
    killVelocity(getHRP())
    if folder and folder:FindFirstChild("Handcuffs") then
        folder.Handcuffs.InventoryEquipRemote:FireServer(false)
    end
    
    if success then
        ArrestRetryCount = 0
    else
        ArrestRetryCount = ArrestRetryCount + 1
    end
    
    root = getHRP()
    if root then
        if amICovered() then
            local spawnPath = findSpawnPath()
            if spawnPath then
                executeSpawnPath(spawnPath)
                task.wait(1)
            elseif not canEscapeCover() then
                killSelf()
                ActionInProgress = false
                return success
            end
        end
        safeVerticalTeleport(v3new(root.Position.X, HOVER_HEIGHT, root.Position.Z))
    end
    
    ExitedCarRef = nil
    ActionInProgress = false
    return success
end

local function startCoverageMonitor()
    if CoverageCheckConnection then return end
    
    CoverageCheckConnection = task.spawn(function()
        while AutoArrestEnabled do
            task.wait(COVERAGE_CHECK_INTERVAL)
            
            if IsExecutingSpawnPath then continue end
            
            local root = getHRP()
            local hum = getHumanoid()
            if not root or not hum or hum.Health <= 0 then continue end
            
            if amICovered() then
                if not SelfCoveredStartTime then
                    SelfCoveredStartTime = tick()
                end
                
                local coveredDuration = tick() - SelfCoveredStartTime
                
                local spawnPath = findSpawnPath()
                if spawnPath then
                    executeSpawnPath(spawnPath)
                    task.wait(1)
                    SelfCoveredStartTime = nil
                elseif coveredDuration >= MAX_COVERED_TIME then
                    if not canEscapeCover() then
                        killSelf()
                        SelfCoveredStartTime = nil
                    end
                end
            else
                SelfCoveredStartTime = nil
            end
        end
    end)
end

local function stopCoverageMonitor()
    CoverageCheckConnection = nil
    SelfCoveredStartTime = nil
    TargetCoveredStartTime = nil
end

local function MainLoop()
    if ActionInProgress then return end
    if IsExecutingSpawnPath then return end
    
    local hum = getHumanoid()
    local root = getHRP()
    
    if not root or not hum or hum.Health <= 0 then return end
    
    cleanupState()
    
    if amICovered() then
        local spawnPath = findSpawnPath()
        if spawnPath then
            executeSpawnPath(spawnPath)
            task.wait(1)
            return
        elseif not canEscapeCover() then
            killSelf()
            return
        end
    end
    
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
    
    if not hum.Sit and not CurrentVehicle then
        local veh = getClosestVehicle()
        if veh then
            local success = enterVehicleRoutine(veh)
            if not success then
                VehicleRetryCount = VehicleRetryCount + 1
                task.wait(RETRY_COOLDOWN)
            end
        else
            if root.Position.Y < HOVER_HEIGHT then
                safeVerticalTeleport(v3new(root.Position.X, HOVER_HEIGHT, root.Position.Z))
            end
        end
        return
    end
    
    if hum.Sit or CurrentVehicle then
        local target = getBestTarget()
        if target then
            local success = arrestSequence(target)
            if not success then
                ArrestRetryCount = ArrestRetryCount + 1
                task.wait(0.1)
            end
        else
            local prison = v3new(-1140, HOVER_HEIGHT, -1500)
            local bank = v3new(-10, HOVER_HEIGHT, 1000)
            
            root = getHRP()
            if root then
                local distPrison = (root.Position - prison).Magnitude
                local distBank = (root.Position - bank).Magnitude
                
                if distPrison < distBank then
                    flyToLocation(bank, true)
                else
                    flyToLocation(prison, true)
                end
            end
        end
    end
end


local function ToggleAutoArrest()
    AutoArrestEnabled = not AutoArrestEnabled
    
    if AutoArrestEnabled then
        print("Auto-Arrest ENABLED")
        
        startCoverageMonitor()
        
        if amICovered() then
            local spawnPath = findSpawnPath()
            if spawnPath then
                executeSpawnPath(spawnPath)
                task.wait(1)
            end
        end
        
        local root = getHRP()
        if root and root.Position.Y < HOVER_HEIGHT and not amICovered() then
            safeVerticalTeleport(v3new(root.Position.X, HOVER_HEIGHT, root.Position.Z))
        end
        
        if not MainLoopConnection then
            MainLoopConnection = heartbeat:Connect(MainLoop)
        end
    else
        print("Auto-Arrest DISABLED")
        
        stopCoverageMonitor()
        
        if MainLoopConnection then
            MainLoopConnection:Disconnect()
            MainLoopConnection = nil
        end
        
        resetSilentAim()
        
        ActionInProgress = false
        CurrentVehicle = nil
        ExitedCarRef = nil
        VehicleRetryCount = 0
        ArrestRetryCount = 0
        StuckCheckPosition = nil
        IsExecutingSpawnPath = false
    end
end

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            for _, v in getgc(false) do
                if typeof(v)=="function" and islclosure(v) and debug.info(v,"n")=="EventFireServer" then
                    local ups = debug.getupvalues(v)
                    if ups[3] and ups[3]["y62bk0nz"] then ups[3]["y62bk0nz"] = nil end
                end
            end
        end)
    end
end)

local Lib = library:Create("Serenity | Jailbreak")
local Tab = Lib:Tab("Main")

Tab:Toggle("Toggle Auto Arrest","Toggle",false,function(Value)
    ToggleAutoArrest()
end)













local SettingsTab = Lib:Tab("Settings")

SettingsTab:Button("Destroy UI",function()
    DestroyUI()
end)

SettingsTab:KeyBind("Toggle UI","RightShift",function(Value)
    ToggleUI()
end)



















--[[
local Tab = Lib:Tab("Player")
local Tab2 = Lib:Tab("Enviroment")

Tab:Section("Section")

Tab:Button("Button",function()
    print("Button Pressed")
end)

Tab:Label("Label")

Tab:Toggle("Toggle","Toggle",true,function(Value)
    print(Value)
end)

Tab:KeyBind("Keybind","P",function(Value)
    print(Value)
end)

Tab:TextBox("TextBox","TextBox","Text Here",function(Value)
    print(Value)
end)

Tab:Dropdown("Dropdown","Dropdown",{"Synapse","ScriptWare","Shitnel","Krnl","Pedohurt"},true,function(Value)
    print(Value)
end)

Tab:Slider("Slider","Slider",1,1,50,false,function(Value)
    print(Value)
end)

Tab:Section("Section2")

Tab:Button("Destroy UI",function()
    DestroyUI()
end)

Tab:KeyBind("Toggle UI","RightShift",function(Value)
    ToggleUI()
end)









--]]
