--[[
    fatalwtfuilibrary
    High performance, modular UI library replicating the fatal.wtf / VisualMenu aesthetic.
    Features:
      - Pixel-perfect reproduction of VisualMenu (diagonal canvas stripes, custom toggles, chevron dropdowns)
      - Dynamic Theme engine (Default, Ocean, Blood, Mint, Midnight, Sunset) with live reactivity
      - Tab switching, Search filtering, Keybind toggling, Smooth drag (PC & Touch)
      - Controls: Toggles (with nested Colorpickers & Keybinds), Sliders, Dropdowns, Colorpickers, Keybinds, TextBoxes, Buttons, Lists
      - Built-in Toast Notification system
--]]

local fatalwtfuilibrary = {}
fatalwtfuilibrary.__index = fatalwtfuilibrary

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer

-- Themes
fatalwtfuilibrary.Themes = {
    Default = {
        Accent = Color3.fromRGB(235, 60, 140),
        Header1 = Color3.fromRGB(150, 25, 85),
        Header2 = Color3.fromRGB(30, 26, 28),
        Background = Color3.fromRGB(10, 10, 10),
        SectionBg = Color3.fromRGB(18, 18, 18),
        ElementBg = Color3.fromRGB(26, 26, 26),
        Stroke = Color3.fromRGB(38, 38, 38),
        Text = Color3.fromRGB(240, 240, 240),
        TextDim = Color3.fromRGB(130, 130, 130),
        StripeColor = Color3.fromRGB(170, 170, 170),
        SliderStripe = Color3.fromRGB(32, 32, 32),
    },
    Ocean = {
        Accent = Color3.fromRGB(0, 195, 255),
        Header1 = Color3.fromRGB(0, 100, 180),
        Header2 = Color3.fromRGB(15, 25, 45),
        Background = Color3.fromRGB(10, 12, 16),
        SectionBg = Color3.fromRGB(16, 20, 26),
        ElementBg = Color3.fromRGB(24, 30, 38),
        Stroke = Color3.fromRGB(35, 45, 58),
        Text = Color3.fromRGB(240, 245, 255),
        TextDim = Color3.fromRGB(120, 135, 155),
        StripeColor = Color3.fromRGB(140, 180, 220),
        SliderStripe = Color3.fromRGB(28, 36, 48),
    },
    Blood = {
        Accent = Color3.fromRGB(245, 45, 60),
        Header1 = Color3.fromRGB(160, 20, 30),
        Header2 = Color3.fromRGB(35, 12, 16),
        Background = Color3.fromRGB(12, 10, 10),
        SectionBg = Color3.fromRGB(20, 16, 16),
        ElementBg = Color3.fromRGB(28, 22, 22),
        Stroke = Color3.fromRGB(48, 32, 32),
        Text = Color3.fromRGB(245, 240, 240),
        TextDim = Color3.fromRGB(145, 120, 120),
        StripeColor = Color3.fromRGB(190, 140, 140),
        SliderStripe = Color3.fromRGB(36, 26, 26),
    },
    Mint = {
        Accent = Color3.fromRGB(45, 225, 145),
        Header1 = Color3.fromRGB(20, 135, 80),
        Header2 = Color3.fromRGB(14, 32, 24),
        Background = Color3.fromRGB(10, 12, 11),
        SectionBg = Color3.fromRGB(16, 20, 18),
        ElementBg = Color3.fromRGB(24, 30, 27),
        Stroke = Color3.fromRGB(32, 48, 38),
        Text = Color3.fromRGB(240, 250, 245),
        TextDim = Color3.fromRGB(125, 145, 135),
        StripeColor = Color3.fromRGB(150, 210, 180),
        SliderStripe = Color3.fromRGB(26, 38, 32),
    },
    Midnight = {
        Accent = Color3.fromRGB(165, 95, 255),
        Header1 = Color3.fromRGB(100, 40, 180),
        Header2 = Color3.fromRGB(28, 16, 46),
        Background = Color3.fromRGB(11, 10, 14),
        SectionBg = Color3.fromRGB(18, 16, 24),
        ElementBg = Color3.fromRGB(27, 24, 36),
        Stroke = Color3.fromRGB(45, 36, 58),
        Text = Color3.fromRGB(245, 240, 255),
        TextDim = Color3.fromRGB(135, 125, 155),
        StripeColor = Color3.fromRGB(180, 150, 225),
        SliderStripe = Color3.fromRGB(35, 30, 48),
    },
    Sunset = {
        Accent = Color3.fromRGB(255, 135, 45),
        Header1 = Color3.fromRGB(185, 55, 65),
        Header2 = Color3.fromRGB(42, 20, 26),
        Background = Color3.fromRGB(12, 10, 10),
        SectionBg = Color3.fromRGB(22, 18, 16),
        ElementBg = Color3.fromRGB(32, 25, 22),
        Stroke = Color3.fromRGB(50, 36, 30),
        Text = Color3.fromRGB(255, 245, 240),
        TextDim = Color3.fromRGB(150, 130, 120),
        StripeColor = Color3.fromRGB(215, 165, 140),
        SliderStripe = Color3.fromRGB(40, 30, 26),
    }
}

-- Icons Asset Registry
fatalwtfuilibrary.Icons = {
    Logo = "rbxassetid://123865964093715",
    Search = "rbxassetid://135740014908175",
    Aimbot = "rbxassetid://76535961115022",
    Visual = "rbxassetid://120042457174817",
    Misc = "rbxassetid://107381670745078",
    Players = "rbxassetid://133980729758572",
    Config = "rbxassetid://138852765629919",
    Globe = "rbxassetid://135874277454346",
    Info = "rbxassetid://99396201903267",
}

-- Helper functions
local function Create(className, properties, children)
    local inst = Instance.new(className)
    if properties then
        for prop, val in pairs(properties) do
            inst[prop] = val
        end
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = inst
        end
    end
    return inst
end

local function Tween(instance, duration, properties, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.2,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function MakeDraggable(guiObject, handle)
    handle = handle or guiObject
    local dragging = false
    local dragStart = nil
    local startPos = nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function FormatKey(keyCode)
    if not keyCode then return "None" end
    local str = tostring(keyCode.Name)
    str = str:gsub("Keypad", "Num ")
    str = str:gsub("Right", "R")
    str = str:gsub("Left", "L")
    return str
end

-- =====================================================================
-- WINDOW CREATION
-- =====================================================================
function fatalwtfuilibrary:CreateWindow(opts)
    opts = opts or {}
    local Title = opts.Title or "FATAL.WTF"
    local MenuKey = opts.MenuKey or Enum.KeyCode.RightShift
    local Language = opts.Language or "English"
    local DefaultTheme = opts.Theme or "Default"
    local ScaleVal = opts.Scale or 1
    local LogoAsset = opts.Logo or fatalwtfuilibrary.Icons.Logo

    local ActiveTheme = fatalwtfuilibrary.Themes[DefaultTheme] or fatalwtfuilibrary.Themes.Default

    -- ScreenGui Parent target
    local TargetParent = opts.Parent
    if not TargetParent then
        local success, coreGui = pcall(function() return CoreGui end)
        if success and coreGui then
            local successParent, _ = pcall(function()
                local test = Instance.new("Folder", coreGui)
                test:Destroy()
            end)
            if successParent then
                TargetParent = coreGui
            end
        end
    end
    if not TargetParent then
        if LocalPlayer then
            TargetParent = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 2)
        end
        if not TargetParent then
            TargetParent = game:GetService("StarterGui")
        end
    end

    local ScreenGui = Create("ScreenGui", {
        Name = "fatalwtfuilibrary_" .. Title:gsub("%s+", "_"),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 100,
        Parent = TargetParent
    })

    local UIScale = Create("UIScale", {
        Scale = ScaleVal,
        Parent = nil
    })

    local Window = Create("Frame", {
        Name = "Window",
        Size = UDim2.new(0, 853, 0, 994),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = ActiveTheme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        Parent = ScreenGui
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Create("UIStroke", {
            Name = "WindowStroke",
            Thickness = 1,
            Color = ActiveTheme.Stroke,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }),
        UIScale
    })

    MakeDraggable(Window, nil)

    -- TopBar
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(0, 853, 0, 88),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = Window
    })

    -- Logo
    local LogoFrame = Create("Frame", {
        Name = "Logo",
        Size = UDim2.new(0, 56, 0, 56),
        Position = UDim2.new(0, 22, 0, 20),
        BackgroundTransparency = 1,
        Parent = TopBar
    }, {
        Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Image = LogoAsset
        })
    })

    -- Divider
    local Divider = Create("Frame", {
        Name = "Divider",
        Size = UDim2.new(0, 2, 0, 68),
        Position = UDim2.new(0, 96, 0, 12),
        BackgroundColor3 = ActiveTheme.Stroke,
        BorderSizePixel = 0,
        Parent = TopBar
    })

    -- Search Bar Container
    local SearchContainer = Create("Frame", {
        Name = "SearchContainer",
        Size = UDim2.new(0, 150, 0, 26),
        Position = UDim2.new(0, 110, 0, 36),
        BackgroundTransparency = 1,
        Parent = TopBar
    })

    local SearchIcon = Create("ImageLabel", {
        Name = "SearchIcon",
        Size = UDim2.new(0, 21, 0, 21),
        Position = UDim2.new(0, 2, 0, 2),
        BackgroundTransparency = 1,
        Image = fatalwtfuilibrary.Icons.Search,
        ImageColor3 = ActiveTheme.TextDim,
        Parent = SearchContainer
    })

    local SearchBox = Create("TextBox", {
        Name = "SearchBox",
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 28, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = ActiveTheme.Text,
        PlaceholderText = "Search...",
        PlaceholderColor3 = ActiveTheme.TextDim,
        Text = "",
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = SearchContainer
    })

    -- Tabs Container
    local TabsContainer = Create("Frame", {
        Name = "Tabs",
        Size = UDim2.new(1, -280, 0, 88),
        Position = UDim2.new(0, 270, 0, 0),
        BackgroundTransparency = 1,
        Parent = TopBar
    })

    local TabsListLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 18),
        Parent = TabsContainer
    })

    -- Header Line under TopBar
    local HeaderLine = Create("Frame", {
        Name = "HeaderLine",
        Size = UDim2.new(0, 837, 0, 2),
        Position = UDim2.new(0, 8, 0, 88),
        BackgroundColor3 = ActiveTheme.Stroke,
        BorderSizePixel = 0,
        Parent = Window
    })

    -- Bottom Bar: Globe, Language, MenuKey
    local GlobeIcon = Create("Frame", {
        Name = "GlobeIcon",
        Size = UDim2.new(0, 21, 0, 21),
        Position = UDim2.new(0, 12, 0, 965),
        BackgroundTransparency = 1,
        Parent = Window
    }, {
        Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Image = fatalwtfuilibrary.Icons.Globe,
            ImageColor3 = ActiveTheme.TextDim
        })
    })

    local LanguageLabel = Create("TextLabel", {
        Name = "Language",
        Size = UDim2.new(0, 150, 0, 20),
        Position = UDim2.new(0, 40, 0, 965),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = ActiveTheme.Text,
        Text = Language,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Window
    })

    local MenuKeyLabel = Create("TextLabel", {
        Name = "MenuKey",
        Size = UDim2.new(0, 200, 0, 20),
        Position = UDim2.new(0, 636, 0, 965),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = ActiveTheme.TextDim,
        Text = "Menu: " .. FormatKey(MenuKey),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = Window
    })

    -- Pages Container
    local PagesContainer = Create("Frame", {
        Name = "PagesContainer",
        Size = UDim2.new(0, 853, 0, 860),
        Position = UDim2.new(0, 0, 0, 96),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = Window
    })

    -- Floating Overlay Container for popups (Dropdowns, Colorpickers)
    local OverlayContainer = Create("Frame", {
        Name = "OverlayContainer",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 50,
        Parent = Window
    })

    -- Notification Container
    local NotificationContainer = Create("Frame", {
        Name = "Notifications",
        Size = UDim2.new(0, 320, 1, -40),
        Position = UDim2.new(1, -330, 0, 20),
        BackgroundTransparency = 1,
        ZIndex = 100,
        Parent = ScreenGui
    }, {
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 10)
        })
    })

    -- Window Object
    local WindowObj = {
        ScreenGui = ScreenGui,
        Window = Window,
        UIScale = UIScale,
        TopBar = TopBar,
        TabsContainer = TabsContainer,
        PagesContainer = PagesContainer,
        OverlayContainer = OverlayContainer,
        NotificationContainer = NotificationContainer,
        ActiveTheme = ActiveTheme,
        Tabs = {},
        CurrentTab = nil,
        MenuKey = MenuKey,
        Visible = true,
        ThemeObjects = {}
    }

    -- Register Theme elements
    local function RegisterTheme(instance, prop, themeKey)
        table.insert(WindowObj.ThemeObjects, {
            Instance = instance,
            Property = prop,
            Key = themeKey
        })
    end

    RegisterTheme(Window, "BackgroundColor3", "Background")
    RegisterTheme(Window.WindowStroke, "Color", "Stroke")
    RegisterTheme(Divider, "BackgroundColor3", "Stroke")
    RegisterTheme(HeaderLine, "BackgroundColor3", "Stroke")
    RegisterTheme(LanguageLabel, "TextColor3", "Text")
    RegisterTheme(MenuKeyLabel, "TextColor3", "TextDim")
    RegisterTheme(GlobeIcon.Icon, "ImageColor3", "TextDim")
    RegisterTheme(SearchIcon, "ImageColor3", "TextDim")
    RegisterTheme(SearchBox, "TextColor3", "Text")
    RegisterTheme(SearchBox, "PlaceholderColor3", "TextDim")

    -- SetTheme Method
    function WindowObj:SetTheme(themeNameOrTable)
        local theme = type(themeNameOrTable) == "table" and themeNameOrTable or fatalwtfuilibrary.Themes[themeNameOrTable]
        if not theme then return end
        WindowObj.ActiveTheme = theme

        for _, item in ipairs(WindowObj.ThemeObjects) do
            if item.Instance and item.Instance.Parent then
                local col = theme[item.Key]
                if col then
                    item.Instance[item.Property] = col
                end
            end
        end

        -- Update header gradients in all sections
        for _, tab in ipairs(WindowObj.Tabs) do
            for _, sec in ipairs(tab.Sections) do
                if sec.HeaderGradient then
                    sec.HeaderGradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, theme.Header1),
                        ColorSequenceKeypoint.new(0.45, theme.Header1),
                        ColorSequenceKeypoint.new(1, theme.Header2)
                    })
                end
                if sec.StripesFolder then
                    for _, st in ipairs(sec.StripesFolder:GetChildren()) do
                        st.BackgroundColor3 = theme.StripeColor
                    end
                end
            end
            if tab == WindowObj.CurrentTab then
                tab.Label.TextColor3 = theme.Text
                tab.Icon.ImageColor3 = theme.Accent
            else
                tab.Label.TextColor3 = theme.TextDim
                tab.Icon.ImageColor3 = theme.TextDim
            end
        end
    end

    -- Toggle Window Visibility
    function WindowObj:Toggle(state)
        if state == nil then
            WindowObj.Visible = not WindowObj.Visible
        else
            WindowObj.Visible = state
        end

        if WindowObj.Visible then
            Window.Visible = true
            Tween(Window, 0.25, {
                Position = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundTransparency = 0
            })
            Tween(UIScale, 0.25, { Scale = ScaleVal })
        else
            local tw = Tween(UIScale, 0.2, { Scale = ScaleVal * 0.95 })
            Tween(Window, 0.2, {
                BackgroundTransparency = 1
            })
            tw.Completed:Connect(function()
                if not WindowObj.Visible then
                    Window.Visible = false
                end
            end)
        end
    end

    -- Keybind listener to open/close menu
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == WindowObj.MenuKey then
            WindowObj:Toggle()
        end
    end)

    function WindowObj:SetMenuKey(newKey)
        WindowObj.MenuKey = newKey
        MenuKeyLabel.Text = "Menu: " .. FormatKey(newKey)
    end

    function WindowObj:SetScale(newScale)
        ScaleVal = newScale
        UIScale.Scale = newScale
    end

    -- Search filtering
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower():gsub("%s+", "")
        for _, tab in ipairs(WindowObj.Tabs) do
            for _, section in ipairs(tab.Sections) do
                for _, element in ipairs(section.Elements) do
                    if element.SearchableText and element.RowFrame then
                        if query == "" or element.SearchableText:lower():find(query, 1, true) then
                            element.RowFrame.Visible = true
                        else
                            element.RowFrame.Visible = false
                        end
                    end
                end
            end
        end
    end)

    -- Toast Notifications
    function WindowObj:Notify(nOpts)
        nOpts = nOpts or {}
        local nTitle = nOpts.Title or "Notice"
        local nContent = nOpts.Content or ""
        local nDuration = nOpts.Duration or 3

        local Toast = Create("Frame", {
            Name = "Toast",
            Size = UDim2.new(0, 300, 0, 68),
            BackgroundColor3 = WindowObj.ActiveTheme.SectionBg,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Parent = NotificationContainer
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 5) }),
            Create("UIStroke", {
                Color = WindowObj.ActiveTheme.Accent,
                Thickness = 1
            }),
            Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 12, 0, 8),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextColor3 = WindowObj.ActiveTheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = nTitle
            }),
            Create("TextLabel", {
                Name = "Content",
                Size = UDim2.new(1, -24, 0, 30),
                Position = UDim2.new(0, 12, 0, 28),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                TextColor3 = WindowObj.ActiveTheme.TextDim,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = nContent
            })
        })

        local ProgressBar = Create("Frame", {
            Name = "Progress",
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = WindowObj.ActiveTheme.Accent,
            BorderSizePixel = 0,
            Parent = Toast
        })

        Toast.Position = UDim2.new(1, 50, 0, 0)
        Tween(Toast, 0.25, { Position = UDim2.new(0, 0, 0, 0) })
        Tween(ProgressBar, nDuration, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)

        task.delay(nDuration, function()
            local tw = Tween(Toast, 0.25, { Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1 })
            tw.Completed:Connect(function()
                Toast:Destroy()
            end)
        end)
    end

    -- =================================================================
    -- TAB CREATION
    -- =================================================================
    function WindowObj:CreateTab(tabOpts)
        tabOpts = tabOpts or {}
        local TabName = tabOpts.Name or "Tab"
        local TabIcon = tabOpts.Icon or fatalwtfuilibrary.Icons[TabName] or fatalwtfuilibrary.Icons.Visual

        local TabBtn = Create("TextButton", {
            Name = TabName .. "Tab",
            Size = UDim2.new(0, 0, 0, 36),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = "",
            Parent = TabsContainer
        })

        local TabIconImg = Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 23, 0, 23),
            Position = UDim2.new(0, 0, 0.5, -11),
            BackgroundTransparency = 1,
            Image = TabIcon,
            ImageColor3 = WindowObj.ActiveTheme.TextDim,
            Parent = TabBtn
        })

        local TabText = Create("TextLabel", {
            Name = "Text",
            Size = UDim2.new(0, 0, 0, 20),
            Position = UDim2.new(0, 30, 0.5, -10),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBlack,
            TextSize = 16,
            TextColor3 = WindowObj.ActiveTheme.TextDim,
            Text = TabName,
            Parent = TabBtn
        })

        -- Page Frame (2 Columns: Left & Right, matching 408x406 cards or dynamic height)
        local PageFrame = Create("Frame", {
            Name = TabName .. "Page",
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = PagesContainer
        })

        local LeftColumn = Create("ScrollingFrame", {
            Name = "LeftColumn",
            Size = UDim2.new(0, 412, 1, -10),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = WindowObj.ActiveTheme.Stroke,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = PageFrame
        }, {
            Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                Padding = UDim.new(0, 14),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
        })

        local RightColumn = Create("ScrollingFrame", {
            Name = "RightColumn",
            Size = UDim2.new(0, 412, 1, -10),
            Position = UDim2.new(0, 431, 0, 10),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = WindowObj.ActiveTheme.Stroke,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = PageFrame
        }, {
            Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                Padding = UDim.new(0, 14),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
        })

        local TabObj = {
            Name = TabName,
            Button = TabBtn,
            Icon = TabIconImg,
            Label = TabText,
            Page = PageFrame,
            LeftCol = LeftColumn,
            RightCol = RightColumn,
            Sections = {},
            Window = WindowObj
        }

        function TabObj:Select()
            for _, t in ipairs(WindowObj.Tabs) do
                t.Page.Visible = false
                Tween(t.Label, 0.15, { TextColor3 = WindowObj.ActiveTheme.TextDim })
                Tween(t.Icon, 0.15, { ImageColor3 = WindowObj.ActiveTheme.TextDim })
            end
            WindowObj.CurrentTab = TabObj
            TabObj.Page.Visible = true
            Tween(TabObj.Label, 0.15, { TextColor3 = WindowObj.ActiveTheme.Text })
            Tween(TabObj.Icon, 0.15, { ImageColor3 = WindowObj.ActiveTheme.Accent })
        end

        TabBtn.MouseButton1Click:Connect(function()
            TabObj:Select()
        end)

        table.insert(WindowObj.Tabs, TabObj)
        if #WindowObj.Tabs == 1 then
            TabObj:Select()
        end

        -- =============================================================
        -- SECTION CREATION
        -- =============================================================
        function TabObj:CreateSection(secOpts)
            secOpts = secOpts or {}
            local SecName = secOpts.Name or "Section"
            local Side = secOpts.Side or (#TabObj.Sections % 2 == 0 and "Left" or "Right")
            local TargetCol = (Side:lower() == "right") and RightColumn or LeftColumn

            -- Section Card Frame
            local Card = Create("Frame", {
                Name = SecName,
                Size = UDim2.new(1, -6, 0, 410),
                AutomaticSize = Enum.AutomaticSize.None,
                BackgroundColor3 = WindowObj.ActiveTheme.SectionBg,
                BorderSizePixel = 0,
                Parent = TargetCol
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                Create("UIStroke", {
                    Color = WindowObj.ActiveTheme.Stroke,
                    Thickness = 1
                })
            })

            RegisterTheme(Card, "BackgroundColor3", "SectionBg")

            -- Section Header: CanvasGroup with diagonal stripes & gradient
            local HeaderCanvas = Create("CanvasGroup", {
                Name = "Header",
                Size = UDim2.new(1, 0, 0, 38),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Parent = Card
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) })
            })

            -- Diagonal stripes folder
            local StripesFolder = Create("Folder", { Name = "Stripes", Parent = HeaderCanvas })
            for i = 1, 56 do
                Create("Frame", {
                    Name = "Stripe",
                    Size = UDim2.new(0, 3, 0, 114),
                    Position = UDim2.new(0, -38 + (i - 1) * 8, 0, -38),
                    Rotation = 45,
                    BackgroundColor3 = WindowObj.ActiveTheme.StripeColor,
                    BorderSizePixel = 0,
                    Parent = StripesFolder
                })
            end

            local HeaderGrad = Create("UIGradient", {
                Rotation = 0,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, WindowObj.ActiveTheme.Header1),
                    ColorSequenceKeypoint.new(0.45, WindowObj.ActiveTheme.Header1),
                    ColorSequenceKeypoint.new(1, WindowObj.ActiveTheme.Header2)
                }),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 0)
                }),
                Parent = HeaderCanvas
            })

            local HeaderLineSec = Create("Frame", {
                Name = "HeaderLine",
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 0, 38),
                BackgroundColor3 = WindowObj.ActiveTheme.Stroke,
                BorderSizePixel = 0,
                Parent = Card
            })

            local SecTitle = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -40, 0, 38),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextColor3 = WindowObj.ActiveTheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = SecName,
                Parent = Card
            })

            local InfoIcon = Create("ImageLabel", {
                Name = "InfoIcon",
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(1, -26, 0, 11),
                BackgroundTransparency = 1,
                Image = fatalwtfuilibrary.Icons.Info,
                ImageColor3 = WindowObj.ActiveTheme.TextDim,
                Parent = Card
            })

            -- Content Scrolling Container for Section Elements
            local ContentArea = Create("ScrollingFrame", {
                Name = "Content",
                Size = UDim2.new(1, 0, 1, -42),
                Position = UDim2.new(0, 0, 0, 42),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = WindowObj.ActiveTheme.Stroke,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                Parent = Card
            }, {
                Create("UIPadding", {
                    PaddingTop = UDim.new(0, 6),
                    PaddingBottom = UDim.new(0, 10),
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10)
                }),
                Create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Vertical,
                    Padding = UDim.new(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
            })

            local SecObj = {
                Name = SecName,
                Card = Card,
                ContentArea = ContentArea,
                HeaderGradient = HeaderGrad,
                StripesFolder = StripesFolder,
                Elements = {},
                Tab = TabObj,
                Window = WindowObj
            }

            table.insert(TabObj.Sections, SecObj)

            -- =========================================================
            -- TOGGLE
            -- =========================================================
            function SecObj:CreateToggle(tOpts)
                tOpts = tOpts or {}
                local TName = tOpts.Name or "Toggle"
                local State = tOpts.Default == true
                local Callback = tOpts.Callback or function() end

                local Row = Create("Frame", {
                    Name = TName .. "Row",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                })

                local Label = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -120, 1, 0),
                    Position = UDim2.new(0, 2, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 15,
                    TextColor3 = WindowObj.ActiveTheme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = TName,
                    Parent = Row
                })

                local ToggleBtn = Create("TextButton", {
                    Name = "Toggle",
                    Size = UDim2.new(0, 26, 0, 26),
                    Position = UDim2.new(1, -28, 0, 2),
                    BackgroundColor3 = State and WindowObj.ActiveTheme.Accent or WindowObj.ActiveTheme.ElementBg,
                    BorderSizePixel = 0,
                    Text = "",
                    Parent = Row
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    Create("UIStroke", {
                        Color = WindowObj.ActiveTheme.Stroke,
                        Thickness = 1
                    })
                })

                -- Checkmark lines
                local CheckShort = Create("Frame", {
                    Name = "CheckShort",
                    Size = UDim2.new(0, 3, 0, 8),
                    Position = UDim2.new(0, 7, 0, 11),
                    Rotation = -45,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Visible = State,
                    Parent = ToggleBtn
                })

                local CheckLong = Create("Frame", {
                    Name = "CheckLong",
                    Size = UDim2.new(0, 3, 0, 13),
                    Position = UDim2.new(0, 13, 0, 6),
                    Rotation = 40,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Visible = State,
                    Parent = ToggleBtn
                })

                local ExtraControls = Create("Frame", {
                    Name = "Extras",
                    Size = UDim2.new(0, 90, 1, 0),
                    Position = UDim2.new(1, -124, 0, 0),
                    BackgroundTransparency = 1,
                    Parent = Row
                }, {
                    Create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        Padding = UDim.new(0, 6)
                    })
                })

                local ToggleObj = {
                    Type = "Toggle",
                    Name = TName,
                    Value = State,
                    RowFrame = Row,
                    SearchableText = TName,
                    ExtrasContainer = ExtraControls
                }

                function ToggleObj:SetValue(val)
                    State = val == true
                    ToggleObj.Value = State
                    CheckShort.Visible = State
                    CheckLong.Visible = State
                    Tween(ToggleBtn, 0.15, {
                        BackgroundColor3 = State and WindowObj.ActiveTheme.Accent or WindowObj.ActiveTheme.ElementBg
                    })
                    task.spawn(Callback, State)
                end

                ToggleBtn.MouseButton1Click:Connect(function()
                    ToggleObj:SetValue(not State)
                end)

                -- Nested Colorpicker attached to Toggle
                function ToggleObj:AddColorpicker(cpOpts)
                    cpOpts = cpOpts or {}
                    local ColorVal = cpOpts.Default or Color3.fromRGB(255, 255, 255)
                    local cpCallback = cpOpts.Callback or function() end

                    local ColorBox = Create("TextButton", {
                        Name = "ColorPickerPreview",
                        Size = UDim2.new(0, 32, 0, 24),
                        BackgroundColor3 = ColorVal,
                        Text = "",
                        BorderSizePixel = 0,
                        Parent = ExtraControls
                    }, {
                        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                        Create("UIStroke", {
                            Color = WindowObj.ActiveTheme.Stroke,
                            Thickness = 1
                        })
                    })

                    local CPObj = {
                        Value = ColorVal
                    }

                    function CPObj:SetValue(newCol)
                        ColorVal = newCol
                        CPObj.Value = newCol
                        ColorBox.BackgroundColor3 = newCol
                        task.spawn(cpCallback, newCol)
                    end

                    ColorBox.MouseButton1Click:Connect(function()
                        WindowObj:OpenColorpickerPopup(ColorVal, function(c)
                            CPObj:SetValue(c)
                        end)
                    end)

                    return CPObj
                end

                -- Nested Keybind attached to Toggle
                function ToggleObj:AddKeybind(kbOpts)
                    kbOpts = kbOpts or {}
                    local KeyVal = kbOpts.Default or Enum.KeyCode.E
                    local kbCallback = kbOpts.Callback or function() end
                    local listening = false

                    local KeyBtn = Create("TextButton", {
                        Name = "KeybindBtn",
                        Size = UDim2.new(0, 50, 0, 24),
                        BackgroundColor3 = WindowObj.ActiveTheme.ElementBg,
                        Text = FormatKey(KeyVal),
                        Font = Enum.Font.GothamBold,
                        TextSize = 13,
                        TextColor3 = WindowObj.ActiveTheme.Text,
                        BorderSizePixel = 0,
                        Parent = ExtraControls
                    }, {
                        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                        Create("UIStroke", {
                            Color = WindowObj.ActiveTheme.Stroke,
                            Thickness = 1
                        })
                    })

                    KeyBtn.MouseButton1Click:Connect(function()
                        listening = true
                        KeyBtn.Text = "..."
                        KeyBtn.TextColor3 = WindowObj.ActiveTheme.Accent
                    end)

                    UserInputService.InputBegan:Connect(function(input, gpe)
                        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                            listening = false
                            KeyVal = input.KeyCode
                            KeyBtn.Text = FormatKey(KeyVal)
                            KeyBtn.TextColor3 = WindowObj.ActiveTheme.Text
                            task.spawn(kbCallback, KeyVal)
                        end
                    end)

                    return {
                        SetKey = function(_, k)
                            KeyVal = k
                            KeyBtn.Text = FormatKey(KeyVal)
                        end
                    }
                end

                table.insert(SecObj.Elements, ToggleObj)
                return ToggleObj
            end

            -- =========================================================
            -- SLIDER
            -- =========================================================
            function SecObj:CreateSlider(sOpts)
                sOpts = sOpts or {}
                local SName = sOpts.Name or "Slider"
                local Min = sOpts.Min or 0
                local Max = sOpts.Max or 100
                local Def = math.clamp(sOpts.Default or Min, Min, Max)
                local Decimals = sOpts.Decimals or 0
                local Unit = sOpts.Unit or ""
                local Callback = sOpts.Callback or function() end

                local CurrentVal = Def

                local Row = Create("Frame", {
                    Name = SName .. "SliderRow",
                    Size = UDim2.new(1, 0, 0, 44),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                })

                local Label = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -70, 0, 20),
                    Position = UDim2.new(0, 2, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 15,
                    TextColor3 = WindowObj.ActiveTheme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = SName,
                    Parent = Row
                })

                local ValueLabel = Create("TextLabel", {
                    Name = "Value",
                    Size = UDim2.new(0, 65, 0, 20),
                    Position = UDim2.new(1, -67, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    TextColor3 = WindowObj.ActiveTheme.TextDim,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Text = string.format("%." .. Decimals .. "f", CurrentVal) .. Unit,
                    Parent = Row
                })

                -- Slider Track (CanvasGroup with diagonal stripes)
                local Track = Create("CanvasGroup", {
                    Name = "SliderTrack",
                    Size = UDim2.new(1, -4, 0, 14),
                    Position = UDim2.new(0, 2, 0, 24),
                    BackgroundColor3 = WindowObj.ActiveTheme.ElementBg,
                    BorderSizePixel = 0,
                    Parent = Row
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 3) })
                })

                -- Diagonal stripes in slider track
                for i = 1, 75 do
                    Create("Frame", {
                        Name = "Stripe",
                        Size = UDim2.new(0, 2, 0, 42),
                        Position = UDim2.new(0, -14 + (i - 1) * 5, 0, -14),
                        Rotation = 45,
                        BackgroundColor3 = WindowObj.ActiveTheme.SliderStripe,
                        BorderSizePixel = 0,
                        Parent = Track
                    })
                end

                local initAlpha = (CurrentVal - Min) / (Max - Min)
                local Fill = Create("Frame", {
                    Name = "Fill",
                    Size = UDim2.new(initAlpha, 0, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundColor3 = WindowObj.ActiveTheme.Accent,
                    BorderSizePixel = 0,
                    Parent = Track
                })

                local SliderObj = {
                    Type = "Slider",
                    Name = SName,
                    Value = CurrentVal,
                    RowFrame = Row,
                    SearchableText = SName
                }

                local function UpdateFromInput(input)
                    local trackAbs = Track.AbsolutePosition
                    local trackSize = Track.AbsoluteSize
                    local x = math.clamp(input.Position.X - trackAbs.X, 0, trackSize.X)
                    local alpha = x / trackSize.X
                    local rawVal = Min + (Max - Min) * alpha
                    local mult = 10 ^ Decimals
                    local stepped = math.round(rawVal * mult) / mult

                    CurrentVal = stepped
                    SliderObj.Value = CurrentVal
                    Fill.Size = UDim2.new(alpha, 0, 1, 0)
                    ValueLabel.Text = string.format("%." .. Decimals .. "f", CurrentVal) .. Unit
                    task.spawn(Callback, CurrentVal)
                end

                local dragging = false
                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        UpdateFromInput(input)
                    end
                end)

                Track.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateFromInput(input)
                    end
                end)

                function SliderObj:SetValue(val)
                    CurrentVal = math.clamp(val, Min, Max)
                    SliderObj.Value = CurrentVal
                    local alpha = (CurrentVal - Min) / (Max - Min)
                    Fill.Size = UDim2.new(alpha, 0, 1, 0)
                    ValueLabel.Text = string.format("%." .. Decimals .. "f", CurrentVal) .. Unit
                    task.spawn(Callback, CurrentVal)
                end

                table.insert(SecObj.Elements, SliderObj)
                return SliderObj
            end

            -- =========================================================
            -- DROPDOWN
            -- =========================================================
            function SecObj:CreateDropdown(dOpts)
                dOpts = dOpts or {}
                local DName = dOpts.Name or "Dropdown"
                local Options = dOpts.Options or {}
                local Def = dOpts.Default or (Options[1] or "")
                local Callback = dOpts.Callback or function() end

                local Selected = Def
                local isOpen = false

                local Row = Create("Frame", {
                    Name = DName .. "DropdownRow",
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                })

                local Label = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -140, 1, 0),
                    Position = UDim2.new(0, 2, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 15,
                    TextColor3 = WindowObj.ActiveTheme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = DName,
                    Parent = Row
                })

                -- Dropdown Box
                local DropBox = Create("TextButton", {
                    Name = "Box",
                    Size = UDim2.new(0, 92, 0, 32),
                    Position = UDim2.new(1, -132, 0, 2),
                    BackgroundColor3 = WindowObj.ActiveTheme.ElementBg,
                    Text = "",
                    BorderSizePixel = 0,
                    Parent = Row
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
                    Create("UIStroke", {
                        Color = WindowObj.ActiveTheme.Stroke,
                        Thickness = 1
                    }),
                    Create("TextLabel", {
                        Name = "Value",
                        Size = UDim2.new(1, -10, 1, 0),
                        Position = UDim2.new(0, 5, 0, 0),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextSize = 14,
                        TextColor3 = WindowObj.ActiveTheme.Text,
                        Text = tostring(Selected),
                        TextTruncate = Enum.TextTruncate.AtEnd
                    })
                })

                -- Dropdown Arrow with procedural chevrons
                local ArrowBtn = Create("TextButton", {
                    Name = "Arrow",
                    Size = UDim2.new(0, 34, 0, 32),
                    Position = UDim2.new(1, -36, 0, 2),
                    BackgroundColor3 = WindowObj.ActiveTheme.ElementBg,
                    Text = "",
                    BorderSizePixel = 0,
                    Parent = Row
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
                    Create("UIStroke", {
                        Color = WindowObj.ActiveTheme.Stroke,
                        Thickness = 1
                    })
                })

                local ChevL = Create("Frame", {
                    Name = "ChevL",
                    Size = UDim2.new(0, 2, 0, 8),
                    Position = UDim2.new(0, 13, 0, 13),
                    Rotation = -45,
                    BackgroundColor3 = WindowObj.ActiveTheme.TextDim,
                    BorderSizePixel = 0,
                    Parent = ArrowBtn
                })

                local ChevR = Create("Frame", {
                    Name = "ChevR",
                    Size = UDim2.new(0, 2, 0, 8),
                    Position = UDim2.new(0, 18, 0, 13),
                    Rotation = 45,
                    BackgroundColor3 = WindowObj.ActiveTheme.TextDim,
                    BorderSizePixel = 0,
                    Parent = ArrowBtn
                })

                -- Floating popup menu
                local DropList = Create("ScrollingFrame", {
                    Name = "FloatingOptions",
                    Size = UDim2.new(0, 128, 0, 0),
                    BackgroundColor3 = WindowObj.ActiveTheme.SectionBg,
                    BorderSizePixel = 0,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = WindowObj.ActiveTheme.Stroke,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    Visible = false,
                    ZIndex = 60,
                    Parent = OverlayContainer
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    Create("UIStroke", {
                        Color = WindowObj.ActiveTheme.Stroke,
                        Thickness = 1
                    }),
                    Create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Vertical,
                        Padding = UDim.new(0, 2)
                    })
                })

                local function PopulateOptions()
                    for _, ch in ipairs(DropList:GetChildren()) do
                        if ch:IsA("TextButton") then ch:Destroy() end
                    end
                    for _, opt in ipairs(Options) do
                        local OptBtn = Create("TextButton", {
                            Name = "Opt_" .. tostring(opt),
                            Size = UDim2.new(1, 0, 0, 28),
                            BackgroundColor3 = (opt == Selected) and WindowObj.ActiveTheme.ElementBg or Color3.fromRGB(0, 0, 0),
                            BackgroundTransparency = (opt == Selected) and 0 or 1,
                            BorderSizePixel = 0,
                            Font = Enum.Font.GothamBold,
                            TextSize = 13,
                            TextColor3 = (opt == Selected) and WindowObj.ActiveTheme.Accent or WindowObj.ActiveTheme.Text,
                            Text = tostring(opt),
                            ZIndex = 61,
                            Parent = DropList
                        })

                        OptBtn.MouseButton1Click:Connect(function()
                            Selected = opt
                            DropBox.Value.Text = tostring(Selected)
                            isOpen = false
                            DropList.Visible = false
                            ChevL.Rotation = -45
                            ChevR.Rotation = 45
                            task.spawn(Callback, Selected)
                            PopulateOptions()
                        end)
                    end
                end

                local function ToggleOpen()
                    isOpen = not isOpen
                    if isOpen then
                        PopulateOptions()
                        local boxAbs = DropBox.AbsolutePosition
                        local winAbs = Window.AbsolutePosition
                        local relX = boxAbs.X - winAbs.X
                        local relY = boxAbs.Y - winAbs.Y + 36

                        local maxH = math.min(#Options * 30 + 4, 150)
                        DropList.Position = UDim2.new(0, relX, 0, relY)
                        DropList.Size = UDim2.new(0, 128, 0, maxH)
                        DropList.Visible = true

                        ChevL.Rotation = 45
                        ChevR.Rotation = -45
                    else
                        DropList.Visible = false
                        ChevL.Rotation = -45
                        ChevR.Rotation = 45
                    end
                end

                DropBox.MouseButton1Click:Connect(ToggleOpen)
                ArrowBtn.MouseButton1Click:Connect(ToggleOpen)

                local DropObj = {
                    Type = "Dropdown",
                    Name = DName,
                    Value = Selected,
                    RowFrame = Row,
                    SearchableText = DName
                }

                function DropObj:Set(val)
                    Selected = val
                    DropObj.Value = val
                    DropBox.Value.Text = tostring(val)
                    task.spawn(Callback, val)
                end

                function DropObj:Refresh(newOpts)
                    Options = newOpts or {}
                    if not table.find(Options, Selected) then
                        Selected = Options[1] or ""
                        DropBox.Value.Text = tostring(Selected)
                    end
                    PopulateOptions()
                end

                table.insert(SecObj.Elements, DropObj)
                return DropObj
            end

            -- =========================================================
            -- BUTTON
            -- =========================================================
            function SecObj:CreateButton(bOpts)
                bOpts = bOpts or {}
                local BName = bOpts.Name or "Button"
                local Callback = bOpts.Callback or function() end

                local Row = Create("Frame", {
                    Name = BName .. "ButtonRow",
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                })

                local Btn = Create("TextButton", {
                    Name = "Button",
                    Size = UDim2.new(1, -4, 0, 32),
                    Position = UDim2.new(0, 2, 0, 2),
                    BackgroundColor3 = WindowObj.ActiveTheme.ElementBg,
                    BorderSizePixel = 0,
                    Font = Enum.Font.GothamBold,
                    TextSize = 15,
                    TextColor3 = WindowObj.ActiveTheme.Text,
                    Text = BName,
                    Parent = Row
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
                    Create("UIStroke", {
                        Color = WindowObj.ActiveTheme.Accent,
                        Thickness = 1
                    })
                })

                Btn.MouseEnter:Connect(function()
                    Tween(Btn, 0.15, { BackgroundColor3 = WindowObj.ActiveTheme.Stroke })
                end)
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, 0.15, { BackgroundColor3 = WindowObj.ActiveTheme.ElementBg })
                end)
                Btn.MouseButton1Click:Connect(function()
                    Tween(Btn, 0.08, { BackgroundColor3 = WindowObj.ActiveTheme.Accent }).Completed:Connect(function()
                        Tween(Btn, 0.15, { BackgroundColor3 = WindowObj.ActiveTheme.ElementBg })
                    end)
                    task.spawn(Callback)
                end)

                local BtnObj = {
                    Type = "Button",
                    Name = BName,
                    RowFrame = Row,
                    SearchableText = BName
                }

                table.insert(SecObj.Elements, BtnObj)
                return BtnObj
            end

            -- =========================================================
            -- TEXTBOX
            -- =========================================================
            function SecObj:CreateTextBox(tbOpts)
                tbOpts = tbOpts or {}
                local TBName = tbOpts.Name or "TextBox"
                local Placeholder = tbOpts.Placeholder or "Enter text..."
                local Def = tbOpts.Default or ""
                local ClearOnFocus = tbOpts.ClearTextOnFocus == true
                local Callback = tbOpts.Callback or function() end

                local Row = Create("Frame", {
                    Name = TBName .. "TextBoxRow",
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                })

                local InputBox = Create("TextBox", {
                    Name = "Input",
                    Size = UDim2.new(1, -4, 0, 32),
                    Position = UDim2.new(0, 2, 0, 2),
                    BackgroundColor3 = WindowObj.ActiveTheme.ElementBg,
                    BorderSizePixel = 0,
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    TextColor3 = WindowObj.ActiveTheme.Text,
                    PlaceholderColor3 = WindowObj.ActiveTheme.TextDim,
                    PlaceholderText = Placeholder,
                    Text = Def,
                    ClearTextOnFocus = ClearOnFocus,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Row
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
                    Create("UIStroke", {
                        Color = WindowObj.ActiveTheme.Stroke,
                        Thickness = 1
                    }),
                    Create("UIPadding", {
                        PaddingLeft = UDim.new(0, 10),
                        PaddingRight = UDim.new(0, 10)
                    })
                })

                InputBox.FocusLost:Connect(function(enterPressed)
                    task.spawn(Callback, InputBox.Text, enterPressed)
                end)

                local TBObj = {
                    Type = "TextBox",
                    Name = TBName,
                    RowFrame = Row,
                    SearchableText = TBName
                }

                function TBObj:SetText(t)
                    InputBox.Text = t
                    task.spawn(Callback, t, false)
                end

                table.insert(SecObj.Elements, TBObj)
                return TBObj
            end

            -- =========================================================
            -- COLORPICKER (STANDALONE)
            -- =========================================================
            function SecObj:CreateColorpicker(cOpts)
                cOpts = cOpts or {}
                local CName = cOpts.Name or "Colorpicker"
                local DefColor = cOpts.Default or Color3.fromRGB(255, 255, 255)
                local Callback = cOpts.Callback or function() end

                local CurrentCol = DefColor

                local Row = Create("Frame", {
                    Name = CName .. "ColorRow",
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                })

                local Label = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -50, 1, 0),
                    Position = UDim2.new(0, 2, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 15,
                    TextColor3 = WindowObj.ActiveTheme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = CName,
                    Parent = Row
                })

                local ColorBox = Create("TextButton", {
                    Name = "ColorBox",
                    Size = UDim2.new(0, 38, 0, 26),
                    Position = UDim2.new(1, -40, 0, 3),
                    BackgroundColor3 = CurrentCol,
                    Text = "",
                    BorderSizePixel = 0,
                    Parent = Row
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    Create("UIStroke", {
                        Color = WindowObj.ActiveTheme.Stroke,
                        Thickness = 1
                    })
                })

                local CPObj = {
                    Type = "Colorpicker",
                    Name = CName,
                    Value = CurrentCol,
                    RowFrame = Row,
                    SearchableText = CName
                }

                function CPObj:SetValue(col)
                    CurrentCol = col
                    CPObj.Value = col
                    ColorBox.BackgroundColor3 = col
                    task.spawn(Callback, col)
                end

                ColorBox.MouseButton1Click:Connect(function()
                    WindowObj:OpenColorpickerPopup(CurrentCol, function(c)
                        CPObj:SetValue(c)
                    end)
                end)

                table.insert(SecObj.Elements, CPObj)
                return CPObj
            end

            -- =========================================================
            -- KEYBIND (STANDALONE)
            -- =========================================================
            function SecObj:CreateKeybind(kOpts)
                kOpts = kOpts or {}
                local KName = kOpts.Name or "Keybind"
                local DefKey = kOpts.Default or Enum.KeyCode.RightShift
                local Callback = kOpts.Callback or function() end

                local CurrentKey = DefKey
                local listening = false

                local Row = Create("Frame", {
                    Name = KName .. "KeybindRow",
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                })

                local Label = Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -120, 1, 0),
                    Position = UDim2.new(0, 2, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 15,
                    TextColor3 = WindowObj.ActiveTheme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = KName,
                    Parent = Row
                })

                local KeyBtn = Create("TextButton", {
                    Name = "KeyBtn",
                    Size = UDim2.new(0, 100, 0, 28),
                    Position = UDim2.new(1, -102, 0, 3),
                    BackgroundColor3 = WindowObj.ActiveTheme.ElementBg,
                    Text = FormatKey(CurrentKey),
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    TextColor3 = WindowObj.ActiveTheme.Text,
                    BorderSizePixel = 0,
                    Parent = Row
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
                    Create("UIStroke", {
                        Color = WindowObj.ActiveTheme.Stroke,
                        Thickness = 1
                    })
                })

                KeyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    KeyBtn.Text = "..."
                    KeyBtn.TextColor3 = WindowObj.ActiveTheme.Accent
                end)

                UserInputService.InputBegan:Connect(function(input, gpe)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        CurrentKey = input.KeyCode
                        KeyBtn.Text = FormatKey(CurrentKey)
                        KeyBtn.TextColor3 = WindowObj.ActiveTheme.Text
                        task.spawn(Callback, CurrentKey)
                    end
                end)

                local KeybindObj = {
                    Type = "Keybind",
                    Name = KName,
                    Value = CurrentKey,
                    RowFrame = Row,
                    SearchableText = KName
                }

                function KeybindObj:SetKey(k)
                    CurrentKey = k
                    KeybindObj.Value = k
                    KeyBtn.Text = FormatKey(k)
                    task.spawn(Callback, k)
                end

                table.insert(SecObj.Elements, KeybindObj)
                return KeybindObj
            end

            -- =========================================================
            -- LIST (CONFIG/ITEM LIST)
            -- =========================================================
            function SecObj:CreateList(lOpts)
                lOpts = lOpts or {}
                local LName = lOpts.Name or "List"
                local ListHeight = lOpts.Height or 160
                local Callback = lOpts.Callback or function() end

                local Row = Create("Frame", {
                    Name = LName .. "ListRow",
                    Size = UDim2.new(1, 0, 0, ListHeight + 8),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                })

                local ListFrame = Create("ScrollingFrame", {
                    Name = "ListFrame",
                    Size = UDim2.new(1, -4, 0, ListHeight),
                    Position = UDim2.new(0, 2, 0, 4),
                    BackgroundColor3 = WindowObj.ActiveTheme.Background,
                    BorderSizePixel = 0,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = WindowObj.ActiveTheme.Stroke,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    Parent = Row
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
                    Create("UIStroke", {
                        Color = WindowObj.ActiveTheme.Stroke,
                        Thickness = 1
                    }),
                    Create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Vertical,
                        Padding = UDim.new(0, 3)
                    })
                })

                local Items = {}
                local SelectedId = nil

                local ListObj = {
                    Type = "List",
                    Name = LName,
                    RowFrame = Row,
                    SearchableText = LName
                }

                function ListObj:AddItem(itemData)
                    local id = itemData.Id or itemData.Name
                    local name = itemData.Name or "item"
                    local info = itemData.Info or ""
                    local iconAsset = itemData.Icon or fatalwtfuilibrary.Icons.Config

                    local ItemFrame = Create("Frame", {
                        Name = "Item_" .. id,
                        Size = UDim2.new(1, -6, 0, 30),
                        BackgroundColor3 = (SelectedId == id) and WindowObj.ActiveTheme.ElementBg or WindowObj.ActiveTheme.Background,
                        BorderSizePixel = 0,
                        Parent = ListFrame
                    }, {
                        Create("UICorner", { CornerRadius = UDim.new(0, 3) })
                    })

                    local SelectBar = Create("Frame", {
                        Name = "SelectBar",
                        Size = UDim2.new(0, 3, 0, 20),
                        Position = UDim2.new(0, 0, 0, 5),
                        BackgroundColor3 = WindowObj.ActiveTheme.Accent,
                        BorderSizePixel = 0,
                        Visible = (SelectedId == id),
                        Parent = ItemFrame
                    })

                    local IconImg = Create("ImageLabel", {
                        Name = "Icon",
                        Size = UDim2.new(0, 15, 0, 15),
                        Position = UDim2.new(0, 10, 0, 7),
                        BackgroundTransparency = 1,
                        Image = iconAsset,
                        ImageColor3 = (SelectedId == id) and WindowObj.ActiveTheme.Accent or WindowObj.ActiveTheme.TextDim,
                        Parent = ItemFrame
                    })

                    local NameLabel = Create("TextLabel", {
                        Name = "Name",
                        Size = UDim2.new(1, -140, 0, 20),
                        Position = UDim2.new(0, 32, 0, 5),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextSize = 14,
                        TextColor3 = (SelectedId == id) and WindowObj.ActiveTheme.Text or WindowObj.ActiveTheme.TextDim,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = name,
                        Parent = ItemFrame
                    })

                    local InfoLabel = Create("TextLabel", {
                        Name = "Info",
                        Size = UDim2.new(0, 100, 0, 20),
                        Position = UDim2.new(1, -106, 0, 5),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextSize = 12,
                        TextColor3 = WindowObj.ActiveTheme.TextDim,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Text = info,
                        Parent = ItemFrame
                    })

                    local ClickBtn = Create("TextButton", {
                        Name = "ClickHitbox",
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text = "",
                        Parent = ItemFrame
                    })

                    ClickBtn.MouseButton1Click:Connect(function()
                        ListObj:Select(id)
                    end)

                    Items[id] = {
                        Frame = ItemFrame,
                        SelectBar = SelectBar,
                        Icon = IconImg,
                        NameLabel = NameLabel,
                        Data = itemData
                    }
                end

                function ListObj:Select(id)
                    SelectedId = id
                    for itId, it in pairs(Items) do
                        local isSel = (itId == id)
                        it.Frame.BackgroundColor3 = isSel and WindowObj.ActiveTheme.ElementBg or WindowObj.ActiveTheme.Background
                        it.SelectBar.Visible = isSel
                        it.Icon.ImageColor3 = isSel and WindowObj.ActiveTheme.Accent or WindowObj.ActiveTheme.TextDim
                        it.NameLabel.TextColor3 = isSel and WindowObj.ActiveTheme.Text or WindowObj.ActiveTheme.TextDim
                    end
                    if Items[id] then
                        task.spawn(Callback, Items[id].Data)
                    end
                end

                function ListObj:RemoveItem(id)
                    if Items[id] then
                        Items[id].Frame:Destroy()
                        Items[id] = nil
                        if SelectedId == id then SelectedId = nil end
                    end
                end

                function ListObj:Clear()
                    for _, it in pairs(Items) do
                        it.Frame:Destroy()
                    end
                    Items = {}
                    SelectedId = nil
                end

                function ListObj:GetSelected()
                    return SelectedId and Items[SelectedId] and Items[SelectedId].Data or nil
                end

                table.insert(SecObj.Elements, ListObj)
                return ListObj
            end

            -- =========================================================
            -- LABEL & DIVIDER
            -- =========================================================
            function SecObj:CreateLabel(txt)
                local Row = Create("Frame", {
                    Name = "LabelRow",
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                })
                local L = Create("TextLabel", {
                    Name = "Text",
                    Size = UDim2.new(1, -4, 1, 0),
                    Position = UDim2.new(0, 2, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 14,
                    TextColor3 = WindowObj.ActiveTheme.TextDim,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = tostring(txt),
                    Parent = Row
                })
                return {
                    SetText = function(_, t) L.Text = tostring(t) end
                }
            end

            function SecObj:CreateDivider()
                local Row = Create("Frame", {
                    Name = "DividerRow",
                    Size = UDim2.new(1, 0, 0, 8),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                })
                Create("Frame", {
                    Name = "Line",
                    Size = UDim2.new(1, -4, 0, 1),
                    Position = UDim2.new(0, 2, 0, 4),
                    BackgroundColor3 = WindowObj.ActiveTheme.Stroke,
                    BorderSizePixel = 0,
                    Parent = Row
                }, {
                    Create("UIGradient", {
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.8),
                            NumberSequenceKeypoint.new(0.5, 0),
                            NumberSequenceKeypoint.new(1, 0.8)
                        })
                    })
                })
            end

            return SecObj
        end

        return TabObj
    end

    -- =================================================================
    -- INTERACTIVE COLORPICKER MODAL
    -- =================================================================
    function WindowObj:OpenColorpickerPopup(initialColor, onColorChanged)
        local curH, curS, curV = Color3.toHSV(initialColor)
        local isModalOpen = true

        local Modal = Create("Frame", {
            Name = "ColorpickerModal",
            Size = UDim2.new(0, 240, 0, 220),
            Position = UDim2.new(0.5, -120, 0.5, -110),
            BackgroundColor3 = WindowObj.ActiveTheme.SectionBg,
            BorderSizePixel = 0,
            ZIndex = 80,
            Parent = OverlayContainer
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 5) }),
            Create("UIStroke", { Color = WindowObj.ActiveTheme.Stroke, Thickness = 1 }),
            Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -40, 0, 24),
                Position = UDim2.new(0, 10, 0, 4),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextColor3 = WindowObj.ActiveTheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "Colorpicker",
                ZIndex = 81
            })
        })

        local CloseBtn = Create("TextButton", {
            Name = "Close",
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(1, -26, 0, 6),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = WindowObj.ActiveTheme.TextDim,
            Text = "X",
            ZIndex = 81,
            Parent = Modal
        })

        -- Saturation/Value 2D Area
        local SVBox = Create("ImageLabel", {
            Name = "SVBox",
            Size = UDim2.new(0, 180, 0, 130),
            Position = UDim2.new(0, 10, 0, 32),
            BackgroundColor3 = Color3.fromHSV(curH, 1, 1),
            BorderSizePixel = 0,
            Image = "rbxassetid://4155801252",
            ZIndex = 81,
            Parent = Modal
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) })
        })

        local SVCursor = Create("Frame", {
            Name = "Cursor",
            Size = UDim2.new(0, 8, 0, 8),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(curS, 0, 1 - curV, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            ZIndex = 82,
            Parent = SVBox
        }, {
            Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
            Create("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Thickness = 1 })
        })

        -- Hue Slider (Vertical)
        local HueBar = Create("Frame", {
            Name = "HueBar",
            Size = UDim2.new(0, 26, 0, 130),
            Position = UDim2.new(0, 200, 0, 32),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            ZIndex = 81,
            Parent = Modal
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
            Create("UIGradient", {
                Rotation = 90,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                })
            })
        })

        local HueCursor = Create("Frame", {
            Name = "HueCursor",
            Size = UDim2.new(1, 4, 0, 4),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, curH, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            ZIndex = 82,
            Parent = HueBar
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 2) }),
            Create("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Thickness = 1 })
        })

        -- Preview & Hex input
        local PreviewBox = Create("Frame", {
            Name = "Preview",
            Size = UDim2.new(0, 36, 0, 28),
            Position = UDim2.new(0, 10, 0, 172),
            BackgroundColor3 = initialColor,
            BorderSizePixel = 0,
            ZIndex = 81,
            Parent = Modal
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
            Create("UIStroke", { Color = WindowObj.ActiveTheme.Stroke, Thickness = 1 })
        })

        local HexBox = Create("TextBox", {
            Name = "Hex",
            Size = UDim2.new(0, 80, 0, 28),
            Position = UDim2.new(0, 56, 0, 172),
            BackgroundColor3 = WindowObj.ActiveTheme.ElementBg,
            BorderSizePixel = 0,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = WindowObj.ActiveTheme.Text,
            Text = "#" .. initialColor:ToHex(),
            ZIndex = 81,
            Parent = Modal
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
            Create("UIStroke", { Color = WindowObj.ActiveTheme.Stroke, Thickness = 1 })
        })

        local function UpdateColor()
            local c = Color3.fromHSV(curH, curS, curV)
            SVBox.BackgroundColor3 = Color3.fromHSV(curH, 1, 1)
            PreviewBox.BackgroundColor3 = c
            HexBox.Text = "#" .. c:ToHex()
            if onColorChanged then onColorChanged(c) end
        end

        -- Drag SV
        local draggingSV = false
        SVBox.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSV = true
                local abs = SVBox.AbsolutePosition
                local sz = SVBox.AbsoluteSize
                curS = math.clamp((input.Position.X - abs.X) / sz.X, 0, 1)
                curV = 1 - math.clamp((input.Position.Y - abs.Y) / sz.Y, 0, 1)
                SVCursor.Position = UDim2.new(curS, 0, 1 - curV, 0)
                UpdateColor()
            end
        end)

        -- Drag Hue
        local draggingHue = false
        HueBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingHue = true
                local abs = HueBar.AbsolutePosition
                local sz = HueBar.AbsoluteSize
                curH = math.clamp((input.Position.Y - abs.Y) / sz.Y, 0, 1)
                HueCursor.Position = UDim2.new(0.5, 0, curH, 0)
                UpdateColor()
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSV = false
                draggingHue = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if draggingSV and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local abs = SVBox.AbsolutePosition
                local sz = SVBox.AbsoluteSize
                curS = math.clamp((input.Position.X - abs.X) / sz.X, 0, 1)
                curV = 1 - math.clamp((input.Position.Y - abs.Y) / sz.Y, 0, 1)
                SVCursor.Position = UDim2.new(curS, 0, 1 - curV, 0)
                UpdateColor()
            elseif draggingHue and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local abs = HueBar.AbsolutePosition
                local sz = HueBar.AbsoluteSize
                curH = math.clamp((input.Position.Y - abs.Y) / sz.Y, 0, 1)
                HueCursor.Position = UDim2.new(0.5, 0, curH, 0)
                UpdateColor()
            end
        end)

        HexBox.FocusLost:Connect(function()
            local hexClean = HexBox.Text:gsub("#", "")
            local sHex, col = pcall(function() return Color3.fromHex(hexClean) end)
            if sHex and col then
                curH, curS, curV = Color3.toHSV(col)
                SVCursor.Position = UDim2.new(curS, 0, 1 - curV, 0)
                HueCursor.Position = UDim2.new(0.5, 0, curH, 0)
                UpdateColor()
            else
                HexBox.Text = "#" .. Color3.fromHSV(curH, curS, curV):ToHex()
            end
        end)

        CloseBtn.MouseButton1Click:Connect(function()
            Modal:Destroy()
        end)
    end

    return WindowObj
end

return fatalwtfuilibrary
