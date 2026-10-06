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
local HttpService = game:GetService("HttpService")

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

-- Mouse buttons get short names in keybind boxes
local function FormatBind(key)
    if key == nil then return "None" end
    if key == Enum.UserInputType.MouseButton1 then return "MB1" end
    if key == Enum.UserInputType.MouseButton2 then return "MB2" end
    if key == Enum.UserInputType.MouseButton3 then return "MB3" end
    return FormatKey(key)
end

-- File storage (uses writefile/readfile when available, otherwise keeps files in memory)
local HasFileSystem = typeof(writefile) == "function" and typeof(readfile) == "function"
    and typeof(isfile) == "function" and typeof(isfolder) == "function"
    and typeof(makefolder) == "function" and typeof(listfiles) == "function"

local MemoryFiles = {}
local Storage = {}

function Storage.EnsureFolder(path)
    if HasFileSystem and not isfolder(path) then
        makefolder(path)
    end
end

function Storage.Write(path, data)
    if HasFileSystem then
        writefile(path, data)
    else
        MemoryFiles[path] = data
    end
end

function Storage.Read(path)
    if HasFileSystem then
        if isfile(path) then
            return readfile(path)
        end
        return nil
    end
    return MemoryFiles[path]
end

function Storage.Delete(path)
    if HasFileSystem then
        if isfile(path) and typeof(delfile) == "function" then
            delfile(path)
        end
    else
        MemoryFiles[path] = nil
    end
end

function Storage.List(folder, ext)
    local names = {}
    local paths = {}
    if HasFileSystem then
        if isfolder(folder) then
            paths = listfiles(folder)
        end
    else
        for p in pairs(MemoryFiles) do
            table.insert(paths, p)
        end
    end
    local prefix = folder .. "/"
    for _, p in ipairs(paths) do
        p = p:gsub("\\", "/")
        local idx = p:find(prefix, 1, true)
        if idx and p:sub(-#ext) == ext then
            local name = p:sub(idx + #prefix, -#ext - 1)
            if name ~= "" and not name:find("/", 1, true) then
                table.insert(names, name)
            end
        end
    end
    table.sort(names)
    return names
end

-- Window creation
function fatalwtfuilibrary:CreateWindow(opts)
    opts = opts or {}
    local Title = opts.Title or "FATAL.WTF"
    local MenuKey = opts.MenuKey or Enum.KeyCode.RightShift
    local Language = opts.Language or "English"
    local DefaultTheme = opts.Theme or "Default"
    local ScaleVal = opts.Scale or 1
    local LogoAsset = opts.Logo or fatalwtfuilibrary.Icons.Logo

    local ActiveTheme = table.clone(fatalwtfuilibrary.Themes[DefaultTheme] or fatalwtfuilibrary.Themes.Default)

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


    -- TopBar
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(0, 853, 0, 88),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = Window
    })

    MakeDraggable(Window, TopBar)

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

    -- Notification container (bottom right)
    local NotificationContainer = Create("Frame", {
        Name = "Notifications",
        Size = UDim2.new(0, 320, 0, 600),
        Position = UDim2.new(1, -14, 1, -14),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        ZIndex = 100,
        Parent = ScreenGui
    }, {
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        }),
        Create("UIScale", { Name = "Scale", Scale = ScaleVal })
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

    -- Extra window state
    WindowObj.Flags = {}
    WindowObj.Keybinds = {}
    WindowObj.Headers = {}
    WindowObj.ScaleObjects = { UIScale, NotificationContainer.Scale }
    WindowObj.NotificationsEnabled = true
    WindowObj.StrokesEnabled = true
    WindowObj.StripesEnabled = true
    WindowObj.Folder = opts.Folder or (Title:gsub("[^%w_%-]", ""))

    local function RegisterFlag(flag, obj)
        if flag then
            obj.Flag = flag
            WindowObj.Flags[flag] = obj
        end
    end

    -- Converts a screen position into the window's unscaled coordinates
    local function ToWindowSpace(absPos)
        local scale = UIScale.Scale
        if scale <= 0 then scale = 1 end
        return (absPos - Window.AbsolutePosition) / scale
    end

    -- Popups (dropdowns, colorpicker, keybind menu): only one open, closes on outside click
    local ActivePopup = nil
    local LastClosedOwner, LastClosedAt = nil, 0

    local function ClosePopup()
        if ActivePopup then
            local popup = ActivePopup
            ActivePopup = nil
            LastClosedOwner, LastClosedAt = popup.Owner, os.clock()
            if popup.OnClose then
                popup.OnClose()
            end
        end
    end

    local function JustClosed(owner)
        return owner ~= nil and owner == LastClosedOwner and (os.clock() - LastClosedAt) < 0.25
    end

    local function OpenPopup(frame, onClose, owner)
        ClosePopup()
        ActivePopup = { Frame = frame, OnClose = onClose, Owner = owner }
    end

    WindowObj.ClosePopup = ClosePopup

    UserInputService.InputBegan:Connect(function(input)
        if not ActivePopup then return end
        local t = input.UserInputType
        if t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.MouseButton2 and t ~= Enum.UserInputType.Touch then
            return
        end
        local f = ActivePopup.Frame
        local p, s = f.AbsolutePosition, f.AbsoluteSize
        local x, y = input.Position.X, input.Position.Y
        if x < p.X or x > p.X + s.X or y < p.Y or y > p.Y + s.Y then
            ClosePopup()
        end
    end)

    -- Striped gradient header (sections, keybind list)
    local function BuildStripedHeader(parent, height)
        local canvas = Create("CanvasGroup", {
            Name = "Header",
            Size = UDim2.new(1, 0, 0, height),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Parent = parent
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) })
        })
        local stripes = Create("Folder", { Name = "Stripes", Parent = canvas })
        for i = 1, 56 do
            Create("Frame", {
                Name = "Stripe",
                Size = UDim2.new(0, 3, 0, height * 3),
                Position = UDim2.new(0, -height + (i - 1) * 8, 0, -height),
                Rotation = 45,
                BackgroundColor3 = WindowObj.ActiveTheme.StripeColor,
                BorderSizePixel = 0,
                Visible = WindowObj.StripesEnabled,
                Parent = stripes
            })
        end
        local grad = Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, WindowObj.ActiveTheme.Header1),
                ColorSequenceKeypoint.new(0.45, WindowObj.ActiveTheme.Header1),
                ColorSequenceKeypoint.new(1, WindowObj.ActiveTheme.Header2)
            }),
            Parent = canvas
        })
        table.insert(WindowObj.Headers, { Gradient = grad, Stripes = stripes })
        return canvas, grad, stripes
    end

    -- Swaps every themed color in the gui from the old theme to the new one.
    -- Instances with attribute ThemeIgnore = true are skipped, "Text"/"Background" skips just that property.
    local function RemapColors(oldTheme, newTheme)
        local reverse = {}
        for key, col in pairs(oldTheme) do
            if typeof(col) == "Color3" then
                local hex = col:ToHex()
                reverse[hex] = reverse[hex] or {}
                table.insert(reverse[hex], key)
            end
        end

        local function apply(inst, prop)
            local keys = reverse[inst[prop]:ToHex()]
            if not keys then return end
            local attr = "ThemeKey_" .. prop
            local key = keys[1]
            if #keys > 1 then
                local cached = inst:GetAttribute(attr)
                if cached and table.find(keys, cached) then
                    key = cached
                end
            end
            if inst:GetAttribute(attr) ~= key then
                inst:SetAttribute(attr, key)
            end
            local new = newTheme[key]
            if new then
                inst[prop] = new
            end
        end

        for _, inst in ipairs(ScreenGui:GetDescendants()) do
            local ignore = inst:GetAttribute("ThemeIgnore")
            if ignore ~= true then
                if inst:IsA("GuiObject") then
                    if ignore ~= "Background" then
                        apply(inst, "BackgroundColor3")
                    end
                    if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
                        if ignore ~= "Text" then
                            apply(inst, "TextColor3")
                        end
                        if inst:IsA("TextBox") then
                            apply(inst, "PlaceholderColor3")
                        end
                    elseif inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
                        apply(inst, "ImageColor3")
                    end
                    if inst:IsA("ScrollingFrame") then
                        apply(inst, "ScrollBarImageColor3")
                    end
                elseif inst:IsA("UIStroke") then
                    apply(inst, "Color")
                end
            end
        end
    end

    -- Button styling: grey outline that turns accent on hover
    local function SetupButton(Btn, bOpts)
        bOpts = bOpts or {}
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = Btn })
        local stroke = Create("UIStroke", {
            Color = bOpts.Accent and WindowObj.ActiveTheme.Accent or WindowObj.ActiveTheme.Stroke,
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent = Btn
        })

        local obj = { Instance = Btn, Highlighted = bOpts.Accent == true }

        local function RestColor()
            return obj.Highlighted and WindowObj.ActiveTheme.Accent or WindowObj.ActiveTheme.Stroke
        end

        Btn.MouseEnter:Connect(function()
            Tween(stroke, 0.15, { Color = WindowObj.ActiveTheme.Accent })
        end)
        Btn.MouseLeave:Connect(function()
            Tween(stroke, 0.15, { Color = RestColor() })
        end)
        Btn.MouseButton1Click:Connect(function()
            Tween(Btn, 0.08, { BackgroundColor3 = WindowObj.ActiveTheme.Stroke }).Completed:Connect(function()
                Tween(Btn, 0.15, { BackgroundColor3 = WindowObj.ActiveTheme.ElementBg })
            end)
            if bOpts.Callback then
                task.spawn(bOpts.Callback)
            end
        end)

        function obj:SetHighlighted(state)
            obj.Highlighted = state == true
            stroke.Color = RestColor()
        end

        function obj:SetText(text)
            Btn.Text = text
        end

        return obj
    end

    -- Keybind mode menu (right click a keybind): Toggle / Hold / Always
    function WindowObj:OpenKeybindMenu(anchor, currentMode, onSelect)
        local theme = WindowObj.ActiveTheme
        local scale = math.max(UIScale.Scale, 0.01)
        local rel = ToWindowSpace(anchor.AbsolutePosition)
        local anchorW = anchor.AbsoluteSize.X / scale
        local anchorH = anchor.AbsoluteSize.Y / scale
        local menuW = math.max(anchorW, 110)

        local Menu = Create("Frame", {
            Name = "KeybindModeMenu",
            Size = UDim2.new(0, menuW, 0, 104),
            Position = UDim2.new(0, rel.X + anchorW - menuW, 0, rel.Y + anchorH + 4),
            BackgroundColor3 = theme.Background,
            BorderSizePixel = 0,
            ZIndex = 90,
            Parent = OverlayContainer
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
            Create("UIStroke", { Color = theme.Stroke, Thickness = 1 }),
            Create("Frame", {
                Name = "AccentLine",
                Size = UDim2.new(1, 0, 0, 2),
                BackgroundColor3 = theme.Accent,
                BorderSizePixel = 0,
                ZIndex = 2
            }, {
                Create("UIGradient", { Transparency = NumberSequence.new(0, 0.6) })
            })
        })

        local anchorStroke = anchor:FindFirstChildOfClass("UIStroke")
        if anchorStroke then
            anchorStroke.Color = theme.Accent
        end

        for i, mode in ipairs({ "Toggle", "Hold", "Always" }) do
            local selected = mode == currentMode
            local Opt = Create("TextButton", {
                Name = mode,
                Size = UDim2.new(1, -8, 0, 30),
                Position = UDim2.new(0, 4, 0, 6 + (i - 1) * 32),
                BackgroundColor3 = selected and theme.ElementBg or theme.Background,
                AutoButtonColor = false,
                BorderSizePixel = 0,
                Text = "",
                Parent = Menu
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 3) })
            })

            if selected then
                Create("Frame", {
                    Name = "SelectBar",
                    Size = UDim2.new(0, 3, 0, 16),
                    Position = UDim2.new(0, 0, 0.5, -8),
                    BackgroundColor3 = theme.Accent,
                    BorderSizePixel = 0,
                    Parent = Opt
                })
            end

            local OptText = Create("TextLabel", {
                Name = "Text",
                Size = UDim2.new(1, -14, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = selected and theme.Text or theme.TextDim,
                Text = mode,
                Parent = Opt
            })

            Opt.MouseEnter:Connect(function()
                if not selected then OptText.TextColor3 = WindowObj.ActiveTheme.Text end
            end)
            Opt.MouseLeave:Connect(function()
                if not selected then OptText.TextColor3 = WindowObj.ActiveTheme.TextDim end
            end)
            Opt.MouseButton1Click:Connect(function()
                ClosePopup()
                onSelect(mode)
            end)
        end

        OpenPopup(Menu, function()
            if anchorStroke and anchorStroke.Parent then
                anchorStroke.Color = WindowObj.ActiveTheme.Stroke
            end
            Menu:Destroy()
        end, anchor)
    end

    -- Keybind list (shows every bound key, active ones highlighted)
    local KeybindList = Create("Frame", {
        Name = "KeybindList",
        Size = UDim2.new(0, 240, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 14, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = ActiveTheme.SectionBg,
        BorderSizePixel = 0,
        Visible = false,
        Parent = ScreenGui
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
        Create("UIStroke", { Color = ActiveTheme.Stroke, Thickness = 1 })
    })
    local KeybindListScale = Create("UIScale", { Scale = ScaleVal, Parent = KeybindList })
    table.insert(WindowObj.ScaleObjects, KeybindListScale)

    local KeybindListHeader = BuildStripedHeader(KeybindList, 34)
    Create("Frame", {
        Name = "HeaderLine",
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 33),
        BackgroundColor3 = ActiveTheme.Accent,
        BorderSizePixel = 0,
        Parent = KeybindList
    })
    Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -40, 0, 34),
        Position = UDim2.new(0, 11, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = ActiveTheme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "Keybinds",
        Parent = KeybindList
    })
    Create("ImageLabel", {
        Name = "Icon",
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(1, -28, 0, 8),
        BackgroundTransparency = 1,
        Image = fatalwtfuilibrary.Icons.Aimbot,
        ImageColor3 = ActiveTheme.Text,
        Parent = KeybindList
    })
    local KeybindRows = Create("Frame", {
        Name = "List",
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 35),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = KeybindList
    }, {
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
        Create("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 8) })
    })
    MakeDraggable(KeybindList, KeybindListHeader)

    function WindowObj:RefreshKeybindList()
        for _, child in ipairs(KeybindRows:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        local theme = WindowObj.ActiveTheme
        for i, bind in ipairs(WindowObj.Keybinds) do
            if bind.ShowInList and bind.Key then
                local on = bind.Active
                local Row = Create("Frame", {
                    Name = bind.Name,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    LayoutOrder = i,
                    Parent = KeybindRows
                })
                Create("TextLabel", {
                    Name = "Name",
                    Size = UDim2.new(1, -150, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 15,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextColor3 = on and theme.Text or theme.TextDim,
                    Text = bind.Name,
                    Parent = Row
                })
                Create("TextLabel", {
                    Name = "Mode",
                    Size = UDim2.new(0, 60, 1, 0),
                    Position = UDim2.new(1, -134, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    TextColor3 = on and theme.Accent or theme.TextDim,
                    Text = bind.Mode,
                    Parent = Row
                })
                Create("TextLabel", {
                    Name = "Key",
                    Size = UDim2.new(0, 54, 0, 22),
                    Position = UDim2.new(1, -64, 0, 3),
                    BackgroundColor3 = theme.ElementBg,
                    BorderSizePixel = 0,
                    Font = Enum.Font.GothamBold,
                    TextSize = 13,
                    TextColor3 = on and theme.Text or theme.TextDim,
                    Text = FormatBind(bind.Key),
                    Parent = Row
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 3) })
                })
            end
        end
    end

    function WindowObj:SetKeybindListVisible(state)
        KeybindList.Visible = state == true
        WindowObj:RefreshKeybindList()
    end

    -- Keybind engine (Toggle / Hold / Always)
    local function SetBindActive(bind, state)
        if bind.Active == state then return end
        bind.Active = state
        if bind.OnState then
            task.spawn(bind.OnState, state)
        end
        WindowObj:RefreshKeybindList()
    end

    local function MatchesBind(bind, input)
        local key = bind.Key
        if key == nil then return false end
        if key.EnumType == Enum.UserInputType then
            return input.UserInputType == key
        end
        return input.KeyCode == key
    end

    local function CreateBind(parent, props, bOpts)
        local bind = {
            Type = "Keybind",
            Name = bOpts.Name or "Keybind",
            Key = bOpts.Default,
            Value = bOpts.Default,
            Mode = bOpts.Mode or "Toggle",
            Active = false,
            Listening = false,
            ShowInList = bOpts.ShowInList ~= false,
            OnState = bOpts.OnState,
            OnKeyChanged = bOpts.Callback,
            OnModeChanged = bOpts.ModeCallback
        }

        local KeyBtn = Create("TextButton", {
            Name = "KeybindBtn",
            Size = props.Size,
            Position = props.Position or UDim2.new(),
            BackgroundColor3 = WindowObj.ActiveTheme.ElementBg,
            Text = FormatBind(bind.Key),
            Font = Enum.Font.GothamBold,
            TextSize = props.TextSize or 13,
            TextColor3 = WindowObj.ActiveTheme.Text,
            AutoButtonColor = false,
            BorderSizePixel = 0,
            Parent = parent
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
            Create("UIStroke", { Color = WindowObj.ActiveTheme.Stroke, Thickness = 1 })
        })
        bind.Button = KeyBtn

        function bind:SetKey(key, silent)
            bind.Key = key
            bind.Value = key
            KeyBtn.Text = FormatBind(key)
            if not silent and bind.OnKeyChanged then
                task.spawn(bind.OnKeyChanged, key)
            end
            WindowObj:RefreshKeybindList()
        end

        function bind:SetMode(mode)
            bind.Mode = mode
            if mode == "Always" then
                SetBindActive(bind, true)
            elseif mode == "Hold" then
                SetBindActive(bind, false)
            end
            if bind.OnModeChanged then
                task.spawn(bind.OnModeChanged, mode)
            end
            WindowObj:RefreshKeybindList()
        end

        function bind:GetState()
            return bind.Active
        end

        KeyBtn.MouseButton1Click:Connect(function()
            bind.Listening = true
            KeyBtn.Text = "..."
            KeyBtn.TextColor3 = WindowObj.ActiveTheme.Accent
        end)

        KeyBtn.MouseButton2Click:Connect(function()
            if bind.Listening or JustClosed(KeyBtn) then return end
            WindowObj:OpenKeybindMenu(KeyBtn, bind.Mode, function(mode)
                bind:SetMode(mode)
            end)
        end)

        table.insert(WindowObj.Keybinds, bind)
        if bind.Mode == "Always" then
            task.defer(SetBindActive, bind, true)
        end
        return bind
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        for _, bind in ipairs(WindowObj.Keybinds) do
            if bind.Listening then
                local t = input.UserInputType
                if t == Enum.UserInputType.Keyboard then
                    bind.Listening = false
                    bind.Button.TextColor3 = WindowObj.ActiveTheme.Text
                    if input.KeyCode == Enum.KeyCode.Escape then
                        bind.Button.Text = FormatBind(bind.Key)
                    elseif input.KeyCode == Enum.KeyCode.Backspace then
                        bind:SetKey(nil)
                    else
                        bind:SetKey(input.KeyCode)
                    end
                elseif t == Enum.UserInputType.MouseButton2 or t == Enum.UserInputType.MouseButton3 then
                    bind.Listening = false
                    bind.Button.TextColor3 = WindowObj.ActiveTheme.Text
                    bind:SetKey(t)
                end
            elseif not gpe and bind.Mode ~= "Always" and MatchesBind(bind, input) then
                if bind.Mode == "Toggle" then
                    SetBindActive(bind, not bind.Active)
                else
                    SetBindActive(bind, true)
                end
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        for _, bind in ipairs(WindowObj.Keybinds) do
            if bind.Mode == "Hold" and bind.Active and MatchesBind(bind, input) then
                SetBindActive(bind, false)
            end
        end
    end)

    -- Watermark (logo | title | user | fps | ping | time)
    local Watermark = Create("Frame", {
        Name = "Watermark",
        Size = UDim2.new(0, 0, 0, 36),
        AutomaticSize = Enum.AutomaticSize.X,
        Position = UDim2.new(0, 14, 0, 14),
        BackgroundColor3 = ActiveTheme.Background,
        BorderSizePixel = 0,
        Visible = false,
        Parent = ScreenGui
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        Create("UIStroke", { Color = ActiveTheme.Stroke, Thickness = 1 })
    })
    local WatermarkScale = Create("UIScale", { Scale = ScaleVal, Parent = Watermark })
    table.insert(WindowObj.ScaleObjects, WatermarkScale)

    Create("Frame", {
        Name = "AccentLine",
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = ActiveTheme.Accent,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = Watermark
    }, {
        Create("UIGradient", { Transparency = NumberSequence.new(0, 0.6) })
    })

    local WatermarkContent = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Parent = Watermark
    }, {
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        }),
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 12),
            PaddingTop = UDim.new(0, 2)
        })
    })

    Create("ImageLabel", {
        Name = "Logo",
        LayoutOrder = 1,
        Size = UDim2.new(0, 26, 0, 26),
        BackgroundTransparency = 1,
        Image = LogoAsset,
        Parent = WatermarkContent
    })

    local WatermarkParts = {}
    local watermarkOrder = 1
    local function WatermarkText(name, text, color)
        watermarkOrder = watermarkOrder + 1
        local label = Create("TextLabel", {
            Name = name,
            LayoutOrder = watermarkOrder,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextColor3 = color,
            Text = text,
            Parent = WatermarkContent
        })
        WatermarkParts[name] = label
        return label
    end

    WatermarkText("Title", Title, ActiveTheme.Accent)
    WatermarkText("Sep1", "|", ActiveTheme.TextDim)
    WatermarkText("User", LocalPlayer and LocalPlayer.Name or "Player", ActiveTheme.Text)
    WatermarkText("Sep2", "|", ActiveTheme.TextDim)
    WatermarkText("FPS", "0 fps", ActiveTheme.Text)
    WatermarkText("Sep3", "|", ActiveTheme.TextDim)
    WatermarkText("Ping", "0 ms", ActiveTheme.Text)
    WatermarkText("Sep4", "|", ActiveTheme.TextDim)
    WatermarkText("Time", os.date("%H:%M"), ActiveTheme.Text)

    local frameCount, lastStatUpdate = 0, os.clock()
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = os.clock()
        if now - lastStatUpdate >= 0.5 then
            if Watermark.Visible then
                WatermarkParts.FPS.Text = math.floor(frameCount / (now - lastStatUpdate) + 0.5) .. " fps"
                local ok, ping = pcall(function()
                    return LocalPlayer:GetNetworkPing() * 1000
                end)
                WatermarkParts.Ping.Text = (ok and math.floor(ping) or 0) .. " ms"
                WatermarkParts.Time.Text = os.date("%H:%M")
            end
            frameCount, lastStatUpdate = 0, now
        end
    end)

    local WatermarkPositions = {
        ["Top Left"] = { UDim2.new(0, 14, 0, 14), Vector2.new(0, 0) },
        ["Top Right"] = { UDim2.new(1, -14, 0, 14), Vector2.new(1, 0) },
        ["Bottom Left"] = { UDim2.new(0, 14, 1, -14), Vector2.new(0, 1) },
        ["Bottom Right"] = { UDim2.new(1, -14, 1, -14), Vector2.new(1, 1) }
    }

    function WindowObj:SetWatermarkVisible(state)
        Watermark.Visible = state == true
    end

    function WindowObj:SetWatermarkPosition(position)
        local data = WatermarkPositions[position]
        if data then
            Watermark.Position = data[1]
            Watermark.AnchorPoint = data[2]
        end
    end

    function WindowObj:SetWatermarkText(text)
        WatermarkParts.Title.Text = text
    end

    function WindowObj:SetWatermarkColor(color)
        WatermarkParts.Title.TextColor3 = color
        WatermarkParts.Title:SetAttribute("ThemeIgnore", true)
    end

    -- Visual settings
    function WindowObj:SetStrokesEnabled(state)
        WindowObj.StrokesEnabled = state == true
        for _, d in ipairs(ScreenGui:GetDescendants()) do
            if d:IsA("UIStroke") then
                d.Enabled = WindowObj.StrokesEnabled
            end
        end
    end

    function WindowObj:SetStripesEnabled(state)
        WindowObj.StripesEnabled = state == true
        for _, header in ipairs(WindowObj.Headers) do
            for _, stripe in ipairs(header.Stripes:GetChildren()) do
                stripe.Visible = WindowObj.StripesEnabled
            end
        end
    end

    local FontOptions = {
        ["Gotham"] = Enum.Font.GothamBold,
        ["Arial"] = Enum.Font.ArialBold,
        ["Source Sans"] = Enum.Font.SourceSansBold,
        ["Ubuntu"] = Enum.Font.Ubuntu,
        ["Roboto Mono"] = Enum.Font.RobotoMono
    }

    function WindowObj:SetFont(name)
        local font = FontOptions[name]
        if not font then return end
        for _, d in ipairs(ScreenGui:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                d.Font = font
            end
        end
    end

    -- Theme
    function WindowObj:SetTheme(themeNameOrTable)
        local theme = type(themeNameOrTable) == "table" and themeNameOrTable or fatalwtfuilibrary.Themes[themeNameOrTable]
        if not theme then return end
        local newTheme = table.clone(theme)
        local oldTheme = WindowObj.ActiveTheme
        WindowObj.ActiveTheme = newTheme

        RemapColors(oldTheme, newTheme)

        for _, item in ipairs(WindowObj.ThemeObjects) do
            if item.Instance and item.Instance.Parent then
                local col = newTheme[item.Key]
                if col then
                    item.Instance[item.Property] = col
                end
            end
        end

        for _, header in ipairs(WindowObj.Headers) do
            header.Gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, newTheme.Header1),
                ColorSequenceKeypoint.new(0.45, newTheme.Header1),
                ColorSequenceKeypoint.new(1, newTheme.Header2)
            })
            for _, stripe in ipairs(header.Stripes:GetChildren()) do
                stripe.BackgroundColor3 = newTheme.StripeColor
            end
        end

        for _, tab in ipairs(WindowObj.Tabs) do
            if tab == WindowObj.CurrentTab then
                tab.Label.TextColor3 = newTheme.Text
                tab.Icon.ImageColor3 = newTheme.Accent
            else
                tab.Label.TextColor3 = newTheme.TextDim
                tab.Icon.ImageColor3 = newTheme.TextDim
            end
        end
    end

    -- Change a single theme color (used by the theme colorpickers)
    function WindowObj:SetThemeColor(key, color)
        local theme = table.clone(WindowObj.ActiveTheme)
        theme[key] = color
        WindowObj:SetTheme(theme)
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
            ClosePopup()
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
        for _, scaleObj in ipairs(WindowObj.ScaleObjects) do
            scaleObj.Scale = newScale
        end
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

    -- Notifications
    local NotifyOrder = 0
    function WindowObj:Notify(nOpts)
        nOpts = nOpts or {}
        if not WindowObj.NotificationsEnabled then return end
        local nTitle = nOpts.Title or "Notice"
        local nContent = nOpts.Content or ""
        local nDuration = nOpts.Duration or 3
        local theme = WindowObj.ActiveTheme
        NotifyOrder = NotifyOrder + 1

        local textSize = TextService:GetTextSize(nContent, 14, Enum.Font.GothamBold, Vector2.new(254, 1000))
        local height = math.max(70, 44 + textSize.Y + 14)

        local Holder = Create("Frame", {
            Name = "Notification",
            Size = UDim2.new(0, 320, 0, height),
            BackgroundTransparency = 1,
            LayoutOrder = NotifyOrder,
            Parent = NotificationContainer
        })

        local Toast = Create("Frame", {
            Name = "Toast",
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 340, 0, 0),
            BackgroundColor3 = theme.Background,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Parent = Holder
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Create("UIStroke", { Color = theme.Stroke, Thickness = 1 }),
            Create("Frame", {
                Name = "AccentBar",
                Size = UDim2.new(0, 3, 1, 0),
                BackgroundColor3 = theme.Accent,
                BorderSizePixel = 0
            }),
            Create("ImageLabel", {
                Name = "Icon",
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0, 16, 0, 14),
                BackgroundTransparency = 1,
                Image = fatalwtfuilibrary.Icons.Info,
                ImageColor3 = theme.Accent
            }),
            Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -60, 0, 22),
                Position = UDim2.new(0, 46, 0, 12),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextColor3 = theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Text = nTitle
            }),
            Create("TextLabel", {
                Name = "Content",
                Size = UDim2.new(1, -60, 0, textSize.Y),
                Position = UDim2.new(0, 46, 0, 36),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextColor3 = theme.TextDim,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                Text = nContent
            })
        })

        local Track = Create("Frame", {
            Name = "Progress",
            Size = UDim2.new(1, 0, 0, 3),
            Position = UDim2.new(0, 0, 1, -3),
            BackgroundColor3 = theme.ElementBg,
            BorderSizePixel = 0,
            Parent = Toast
        })
        local Fill = Create("Frame", {
            Name = "Fill",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0,
            Parent = Track
        })

        Tween(Toast, 0.3, { Position = UDim2.new(0, 0, 0, 0) })
        Tween(Fill, nDuration, { Size = UDim2.new(0, 0, 1, 0) }, Enum.EasingStyle.Linear)

        task.delay(nDuration, function()
            local tw = Tween(Toast, 0.25, { Position = UDim2.new(0, 340, 0, 0) })
            tw.Completed:Connect(function()
                Holder:Destroy()
            end)
        end)
    end

    -- Tab creation
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

        -- Section creation
        function TabObj:CreateSection(secOpts)
            secOpts = secOpts or {}
            local SecName = secOpts.Name or "Section"
            local Side = secOpts.Side or (#TabObj.Sections % 2 == 0 and "Left" or "Right")
            local TargetCol = (Side:lower() == "right") and RightColumn or LeftColumn

            -- Section Card Frame
            local Card = Create("Frame", {
                Name = SecName,
                Size = UDim2.new(1, -6, 0, secOpts.Height or 410),
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

            -- Section header: diagonal stripes & gradient
            local HeaderCanvas, HeaderGrad, StripesFolder = BuildStripedHeader(Card, 38)

            local HeaderLineSec = Create("Frame", {
                Name = "HeaderLine",
                Size = UDim2.new(1, 0, 0, 2),
                Position = UDim2.new(0, 0, 0, 37),
                BackgroundColor3 = WindowObj.ActiveTheme.Accent,
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

            -- Toggle
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
                    Size = UDim2.new(0, 200, 1, 0),
                    Position = UDim2.new(1, -234, 0, 0),
                    BackgroundTransparency = 1,
                    Parent = Row
                }, {
                    Create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 8)
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
                    if ToggleObj.Bind and ToggleObj.Bind.Active ~= State then
                        ToggleObj.Bind.Active = State
                        WindowObj:RefreshKeybindList()
                    end
                    task.spawn(Callback, State)
                end

                ToggleBtn.MouseButton1Click:Connect(function()
                    ToggleObj:SetValue(not State)
                end)

                -- Colorbox next to the toggle (click to open the colorpicker)
                local colorCount = 0
                function ToggleObj:AddColorpicker(cpOpts)
                    cpOpts = cpOpts or {}
                    colorCount = colorCount + 1
                    local index = colorCount
                    local ColorVal = cpOpts.Default or Color3.fromRGB(255, 255, 255)
                    local Transp = cpOpts.Transparency or 0
                    local cpCallback = cpOpts.Callback or function() end
                    local cpName = cpOpts.Name or (TName .. " Color")

                    local ColorBox = Create("TextButton", {
                        Name = "ColorBox" .. index,
                        Size = UDim2.new(0, 33, 0, 26),
                        BackgroundColor3 = ColorVal,
                        AutoButtonColor = false,
                        Text = "",
                        BorderSizePixel = 0,
                        LayoutOrder = index,
                        Parent = ExtraControls
                    }, {
                        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                        Create("UIStroke", {
                            Color = WindowObj.ActiveTheme.Stroke,
                            Thickness = 1
                        })
                    })
                    ColorBox:SetAttribute("ThemeIgnore", true)

                    local CPObj = {
                        Type = "Colorpicker",
                        Name = cpName,
                        Value = ColorVal,
                        Transparency = Transp
                    }

                    function CPObj:SetValue(newCol, newTransp, silent)
                        ColorVal = newCol
                        Transp = newTransp or Transp
                        CPObj.Value = newCol
                        CPObj.Transparency = Transp
                        ColorBox.BackgroundColor3 = newCol
                        if not silent then
                            task.spawn(cpCallback, newCol, Transp)
                        end
                    end

                    ColorBox.MouseButton1Click:Connect(function()
                        if JustClosed(ColorBox) then return end
                        WindowObj:OpenColorpickerPopup(ColorVal, function(c, t)
                            CPObj:SetValue(c, t)
                        end, {
                            Title = cpName,
                            Anchor = ColorBox,
                            Transparency = Transp
                        })
                    end)

                    RegisterFlag(cpOpts.Flag or (ToggleObj.Flag .. ".Color" .. index), CPObj)
                    return CPObj
                end

                -- Keybind next to the toggle (right click for Toggle / Hold / Always)
                function ToggleObj:AddKeybind(kbOpts)
                    kbOpts = kbOpts or {}
                    local bind = CreateBind(ExtraControls, { Size = UDim2.new(0, 54, 0, 24) }, {
                        Name = kbOpts.Name or TName,
                        Default = kbOpts.Default,
                        Mode = kbOpts.Mode or "Toggle",
                        Callback = kbOpts.Callback,
                        ModeCallback = kbOpts.ModeCallback,
                        ShowInList = kbOpts.ShowInList,
                        OnState = function(active)
                            if ToggleObj.Value ~= active then
                                ToggleObj:SetValue(active)
                            end
                        end
                    })
                    bind.Button.LayoutOrder = 100
                    bind.Active = ToggleObj.Value
                    ToggleObj.Bind = bind
                    RegisterFlag(kbOpts.Flag or (ToggleObj.Flag .. ".Key"), bind)
                    WindowObj:RefreshKeybindList()
                    return bind
                end

                RegisterFlag(tOpts.Flag or (TabName .. "." .. SecName .. "." .. TName), ToggleObj)
                table.insert(SecObj.Elements, ToggleObj)
                return ToggleObj
            end

            -- Slider
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

                RegisterFlag(sOpts.Flag or (TabName .. "." .. SecName .. "." .. SName), SliderObj)
                table.insert(SecObj.Elements, SliderObj)
                return SliderObj
            end

            -- Dropdown
            function SecObj:CreateDropdown(dOpts)
                dOpts = dOpts or {}
                local DName = dOpts.Name or "Dropdown"
                local Options = dOpts.Options or {}
                local Def = dOpts.Default or (Options[1] or "")
                local Callback = dOpts.Callback or function() end

                local Selected = Def
                local isOpen = false
                local DropObj

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
                            if DropObj then DropObj.Value = opt end
                            DropBox.Value.Text = tostring(Selected)
                            ClosePopup()
                            task.spawn(Callback, Selected)
                        end)
                    end
                end

                local function CloseList()
                    isOpen = false
                    DropList.Visible = false
                    ChevL.Rotation = -45
                    ChevR.Rotation = 45
                end

                local function ToggleOpen()
                    if isOpen then
                        ClosePopup()
                        return
                    end
                    if JustClosed(Row) then return end
                    isOpen = true
                    PopulateOptions()
                    local rel = ToWindowSpace(DropBox.AbsolutePosition)
                    local maxH = math.min(#Options * 30 + 4, 150)
                    DropList.Position = UDim2.new(0, rel.X, 0, rel.Y + 36)
                    DropList.Size = UDim2.new(0, 128, 0, maxH)
                    DropList.Visible = true
                    ChevL.Rotation = 45
                    ChevR.Rotation = -45
                    OpenPopup(DropList, CloseList, Row)
                end

                DropBox.MouseButton1Click:Connect(ToggleOpen)
                ArrowBtn.MouseButton1Click:Connect(ToggleOpen)

                DropObj = {
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
                        DropObj.Value = Selected
                        DropBox.Value.Text = tostring(Selected)
                    end
                    PopulateOptions()
                end

                RegisterFlag(dOpts.Flag or (TabName .. "." .. SecName .. "." .. DName), DropObj)
                table.insert(SecObj.Elements, DropObj)
                return DropObj
            end

            -- Button
            local function NewButton(parent, bOpts, size, position)
                local Btn = Create("TextButton", {
                    Name = "Button",
                    Size = size,
                    Position = position or UDim2.new(),
                    BackgroundColor3 = WindowObj.ActiveTheme.ElementBg,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Font = Enum.Font.GothamBold,
                    TextSize = 15,
                    TextColor3 = WindowObj.ActiveTheme.Text,
                    Text = bOpts.Name or "Button",
                    Parent = parent
                })
                return SetupButton(Btn, bOpts)
            end

            function SecObj:CreateButton(bOpts)
                bOpts = bOpts or {}
                local BName = bOpts.Name or "Button"

                local Row = Create("Frame", {
                    Name = BName .. "ButtonRow",
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                })

                local BtnObj = NewButton(Row, bOpts, UDim2.new(1, -4, 0, 32), UDim2.new(0, 2, 0, 2))
                BtnObj.Type = "Button"
                BtnObj.Name = BName
                BtnObj.RowFrame = Row
                BtnObj.SearchableText = BName

                table.insert(SecObj.Elements, BtnObj)
                return BtnObj
            end

            -- Button row (buttons side by side, e.g. Load / Create / Delete)
            function SecObj:CreateButtonRow(buttons)
                buttons = buttons or {}

                local Row = Create("Frame", {
                    Name = "ButtonRow",
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                }, {
                    Create("UIPadding", {
                        PaddingLeft = UDim.new(0, 2),
                        PaddingRight = UDim.new(0, 2)
                    }),
                    Create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 6)
                    })
                })

                local count = math.max(#buttons, 1)
                local gap = math.ceil(6 * (count - 1) / count)
                local objs = {}
                local names = {}
                for i, b in ipairs(buttons) do
                    local obj = NewButton(Row, b, UDim2.new(1 / count, -gap, 0, 32))
                    obj.Instance.Name = (b.Name or "Button") .. "Button"
                    obj.Instance.LayoutOrder = i
                    objs[i] = obj
                    table.insert(names, b.Name or "")
                end

                table.insert(SecObj.Elements, {
                    Type = "ButtonRow",
                    RowFrame = Row,
                    SearchableText = table.concat(names, "")
                })
                return objs
            end

            -- TextBox
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

                function TBObj:GetText()
                    return InputBox.Text
                end

                table.insert(SecObj.Elements, TBObj)
                return TBObj
            end

            -- Colorpicker (row with one or more colorboxes)
            function SecObj:CreateColorpicker(cOpts)
                cOpts = cOpts or {}
                local CName = cOpts.Name or "Colorpicker"

                local Row = Create("Frame", {
                    Name = CName .. "ColorRow",
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                })

                Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -120, 1, 0),
                    Position = UDim2.new(0, 2, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 15,
                    TextColor3 = WindowObj.ActiveTheme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = CName,
                    Parent = Row
                })

                local Swatches = Create("Frame", {
                    Name = "Swatches",
                    Size = UDim2.new(0, 200, 1, 0),
                    Position = UDim2.new(1, -234, 0, 0),
                    BackgroundTransparency = 1,
                    Parent = Row
                }, {
                    Create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 8)
                    })
                })

                local count = 0
                local function AddSwatch(o)
                    count = count + 1
                    local index = count
                    local Col = o.Default or Color3.fromRGB(255, 255, 255)
                    local Transp = o.Transparency or 0
                    local cb = o.Callback or function() end
                    local swatchName = o.Name or CName

                    local Box = Create("TextButton", {
                        Name = "ColorBox" .. index,
                        Size = UDim2.new(0, 33, 0, 26),
                        BackgroundColor3 = Col,
                        AutoButtonColor = false,
                        Text = "",
                        BorderSizePixel = 0,
                        LayoutOrder = index,
                        Parent = Swatches
                    }, {
                        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                        Create("UIStroke", {
                            Color = WindowObj.ActiveTheme.Stroke,
                            Thickness = 1
                        })
                    })
                    Box:SetAttribute("ThemeIgnore", true)

                    local obj = {
                        Type = "Colorpicker",
                        Name = swatchName,
                        Value = Col,
                        Transparency = Transp,
                        RowFrame = Row,
                        SearchableText = CName
                    }

                    function obj:SetValue(c, t, silent)
                        Col = c
                        Transp = t or Transp
                        obj.Value = c
                        obj.Transparency = Transp
                        Box.BackgroundColor3 = c
                        if not silent then
                            task.spawn(cb, c, Transp)
                        end
                    end

                    Box.MouseButton1Click:Connect(function()
                        if JustClosed(Box) then return end
                        WindowObj:OpenColorpickerPopup(Col, function(c, t)
                            obj:SetValue(c, t)
                        end, {
                            Title = swatchName,
                            Anchor = Box,
                            Transparency = Transp
                        })
                    end)

                    local defaultFlag = TabName .. "." .. SecName .. "." .. CName
                    if index > 1 then
                        defaultFlag = defaultFlag .. ".Color" .. index
                    end
                    RegisterFlag(o.Flag or defaultFlag, obj)
                    return obj
                end

                local Primary = AddSwatch(cOpts)

                -- Adds another colorbox to the same row
                function Primary:AddColorpicker(o)
                    return AddSwatch(o or {})
                end

                table.insert(SecObj.Elements, Primary)
                return Primary
            end

            -- Keybind (right click for Toggle / Hold / Always)
            function SecObj:CreateKeybind(kOpts)
                kOpts = kOpts or {}
                local KName = kOpts.Name or "Keybind"

                local Row = Create("Frame", {
                    Name = KName .. "KeybindRow",
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                })

                Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -130, 1, 0),
                    Position = UDim2.new(0, 2, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 15,
                    TextColor3 = WindowObj.ActiveTheme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = KName,
                    Parent = Row
                })

                local bind = CreateBind(Row, {
                    Size = UDim2.new(0, 123, 0, 30),
                    Position = UDim2.new(1, -125, 0, 2),
                    TextSize = 14
                }, {
                    Name = KName,
                    Default = kOpts.Default,
                    Mode = kOpts.Mode,
                    Callback = kOpts.Callback,
                    ModeCallback = kOpts.ModeCallback,
                    OnState = kOpts.OnState,
                    ShowInList = kOpts.ShowInList
                })
                bind.RowFrame = Row
                bind.SearchableText = KName

                RegisterFlag(kOpts.Flag or (TabName .. "." .. SecName .. "." .. KName), bind)
                table.insert(SecObj.Elements, bind)
                WindowObj:RefreshKeybindList()
                return bind
            end

            -- List (configs / items)
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

            -- Label & divider
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

    -- Colorpicker popup (opens next to the colorbox, closes on outside click)
    function WindowObj:OpenColorpickerPopup(initialColor, onColorChanged, cpOpts)
        cpOpts = cpOpts or {}
        local theme = WindowObj.ActiveTheme
        local curH, curS, curV = initialColor:ToHSV()
        local curA = cpOpts.Transparency or 0
        local conns = {}
        local winW, winH = Window.Size.X.Offset, Window.Size.Y.Offset

        local Modal = Create("Frame", {
            Name = "ColorpickerModal",
            Size = UDim2.new(0, 232, 0, 284),
            BackgroundColor3 = theme.Background,
            BorderSizePixel = 0,
            ZIndex = 80,
            Parent = OverlayContainer
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Create("UIStroke", { Color = theme.Stroke, Thickness = 1 })
        })

        local x, y = winW / 2 - 116, winH / 2 - 142
        if cpOpts.Anchor then
            local scale = math.max(UIScale.Scale, 0.01)
            local rel = ToWindowSpace(cpOpts.Anchor.AbsolutePosition)
            local size = cpOpts.Anchor.AbsoluteSize / scale
            x = rel.X + size.X - 232
            y = rel.Y + size.Y + 6
            if y + 284 > winH - 8 then
                y = rel.Y - 290
            end
        end
        Modal.Position = UDim2.new(0, math.clamp(x, 8, winW - 240), 0, math.clamp(y, 8, winH - 292))

        Create("Frame", {
            Name = "AccentLine",
            Size = UDim2.new(1, 0, 0, 2),
            BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0,
            ZIndex = 2,
            Parent = Modal
        }, {
            Create("UIGradient", { Transparency = NumberSequence.new(0, 0.6) })
        })

        Create("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -60, 0, 20),
            Position = UDim2.new(0, 10, 0, 8),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextColor3 = theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Text = cpOpts.Title or "Color",
            Parent = Modal
        })

        local Preview = Create("Frame", {
            Name = "Preview",
            Size = UDim2.new(0, 32, 0, 18),
            Position = UDim2.new(1, -42, 0, 9),
            BackgroundColor3 = initialColor,
            BorderSizePixel = 0,
            Parent = Modal
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
            Create("UIStroke", { Color = theme.Stroke, Thickness = 1 })
        })
        Preview:SetAttribute("ThemeIgnore", true)

        -- Saturation / value square
        local SV = Create("Frame", {
            Name = "SVSquare",
            Size = UDim2.new(0, 180, 0, 180),
            Position = UDim2.new(0, 10, 0, 36),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Parent = Modal
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) })
        })
        SV:SetAttribute("ThemeIgnore", true)

        local SVGradient = Create("UIGradient", {
            Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(curH, 1, 1)),
            Parent = SV
        })

        local Darkness = Create("Frame", {
            Name = "Darkness",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
            Parent = SV
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
            Create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) })
        })
        Darkness:SetAttribute("ThemeIgnore", true)

        local SVCursor = Create("Frame", {
            Name = "Cursor",
            Size = UDim2.new(0, 12, 0, 12),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            ZIndex = 3,
            Parent = SV
        }, {
            Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
            Create("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2 })
        })

        -- Hue bar
        local hueKeys = {}
        for i = 0, 6 do
            table.insert(hueKeys, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV((i / 6) % 1, 1, 1)))
        end

        local HueBar = Create("Frame", {
            Name = "HueBar",
            Size = UDim2.new(0, 24, 0, 180),
            Position = UDim2.new(0, 198, 0, 36),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Parent = Modal
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
            Create("UIGradient", { Rotation = 90, Color = ColorSequence.new(hueKeys) })
        })
        HueBar:SetAttribute("ThemeIgnore", true)

        local HueMarker = Create("Frame", {
            Name = "Marker",
            Size = UDim2.new(1, 6, 0, 4),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            ZIndex = 3,
            Parent = HueBar
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 2) }),
            Create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1 })
        })

        -- Transparency bar
        local AlphaBar = Create("Frame", {
            Name = "AlphaBar",
            Size = UDim2.new(0, 212, 0, 12),
            Position = UDim2.new(0, 10, 0, 226),
            BackgroundColor3 = theme.ElementBg,
            BorderSizePixel = 0,
            Parent = Modal
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) })
        })

        local AlphaFill = Create("Frame", {
            Name = "Fill",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = initialColor,
            BorderSizePixel = 0,
            Parent = AlphaBar
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
            Create("UIGradient", { Transparency = NumberSequence.new(1, 0) })
        })
        AlphaFill:SetAttribute("ThemeIgnore", true)

        local AlphaMarker = Create("Frame", {
            Name = "Marker",
            Size = UDim2.new(0, 4, 1, 6),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            ZIndex = 3,
            Parent = AlphaBar
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 2) }),
            Create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1 })
        })

        -- Hex + RGB inputs
        local function InputBox(name, posX, width)
            return Create("TextBox", {
                Name = name,
                Size = UDim2.new(0, width, 0, 26),
                Position = UDim2.new(0, posX, 0, 248),
                BackgroundColor3 = theme.ElementBg,
                BorderSizePixel = 0,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextColor3 = theme.Text,
                ClearTextOnFocus = false,
                Text = "",
                Parent = Modal
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
                Create("UIStroke", { Color = theme.Stroke, Thickness = 1 })
            })
        end

        local HexBox = InputBox("Hex", 10, 82)
        local RGBBox = InputBox("RGB", 98, 124)

        local function Refresh(fire)
            local c = Color3.fromHSV(curH, curS, curV)
            SVGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(curH, 1, 1))
            SVCursor.Position = UDim2.new(curS, 0, 1 - curV, 0)
            HueMarker.Position = UDim2.new(0.5, 0, curH, 0)
            AlphaFill.BackgroundColor3 = c
            AlphaMarker.Position = UDim2.new(1 - curA, 0, 0.5, 0)
            Preview.BackgroundColor3 = c
            Preview.BackgroundTransparency = curA
            if not HexBox:IsFocused() then
                HexBox.Text = "#" .. c:ToHex():upper()
            end
            if not RGBBox:IsFocused() then
                RGBBox.Text = string.format("%d, %d, %d",
                    math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
            end
            if fire and onColorChanged then
                onColorChanged(c, curA)
            end
        end

        local dragging = nil
        local function UpdateDrag(pos)
            if dragging == "SV" then
                local p, s = SV.AbsolutePosition, SV.AbsoluteSize
                curS = math.clamp((pos.X - p.X) / s.X, 0, 1)
                curV = 1 - math.clamp((pos.Y - p.Y) / s.Y, 0, 1)
            elseif dragging == "Hue" then
                local p, s = HueBar.AbsolutePosition, HueBar.AbsoluteSize
                curH = math.clamp((pos.Y - p.Y) / s.Y, 0, 0.999)
            elseif dragging == "Alpha" then
                local p, s = AlphaBar.AbsolutePosition, AlphaBar.AbsoluteSize
                curA = 1 - math.clamp((pos.X - p.X) / s.X, 0, 1)
            end
            Refresh(true)
        end

        local function BeginDrag(target, mode)
            target.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = mode
                    UpdateDrag(input.Position)
                end
            end)
        end

        BeginDrag(SV, "SV")
        BeginDrag(HueBar, "Hue")
        BeginDrag(AlphaBar, "Alpha")

        table.insert(conns, UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                UpdateDrag(input.Position)
            end
        end))

        table.insert(conns, UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = nil
            end
        end))

        HexBox.FocusLost:Connect(function()
            local ok, col = pcall(Color3.fromHex, (HexBox.Text:gsub("#", "")))
            if ok and col then
                curH, curS, curV = col:ToHSV()
                Refresh(true)
            else
                Refresh(false)
            end
        end)

        RGBBox.FocusLost:Connect(function()
            local nums = {}
            for n in RGBBox.Text:gmatch("%d+") do
                table.insert(nums, math.clamp(tonumber(n), 0, 255))
            end
            if #nums >= 3 then
                curH, curS, curV = Color3.fromRGB(nums[1], nums[2], nums[3]):ToHSV()
                Refresh(true)
            else
                Refresh(false)
            end
        end)

        OpenPopup(Modal, function()
            for _, c in ipairs(conns) do
                c:Disconnect()
            end
            Modal:Destroy()
        end, cpOpts.Anchor)

        Refresh(false)
    end

    -- Config system (saves every element with a flag)
    local function SerializeFlag(obj)
        if obj.Type == "Toggle" or obj.Type == "Slider" or obj.Type == "Dropdown" then
            return obj.Value
        elseif obj.Type == "Colorpicker" then
            return { Color = obj.Value:ToHex(), Transparency = obj.Transparency or 0 }
        elseif obj.Type == "Keybind" then
            local key = obj.Key
            return {
                Key = key and key.Name or "None",
                Mouse = key ~= nil and key.EnumType == Enum.UserInputType,
                Mode = obj.Mode
            }
        end
        return nil
    end

    local function ApplyFlag(obj, value)
        if obj.Type == "Toggle" then
            obj:SetValue(value == true)
        elseif obj.Type == "Slider" then
            if type(value) == "number" then obj:SetValue(value) end
        elseif obj.Type == "Dropdown" then
            obj:Set(value)
        elseif obj.Type == "Colorpicker" and type(value) == "table" then
            obj:SetValue(Color3.fromHex(value.Color), value.Transparency)
        elseif obj.Type == "Keybind" and type(value) == "table" then
            local key = nil
            if value.Key and value.Key ~= "None" then
                key = value.Mouse and Enum.UserInputType[value.Key] or Enum.KeyCode[value.Key]
            end
            obj:SetKey(key)
            if value.Mode then obj:SetMode(value.Mode) end
        end
    end

    local function ConfigFolder()
        return WindowObj.Folder .. "/configs"
    end

    local function ThemeFolder()
        return WindowObj.Folder .. "/themes"
    end

    local function EnsureFolders()
        Storage.EnsureFolder(WindowObj.Folder)
        Storage.EnsureFolder(ConfigFolder())
        Storage.EnsureFolder(ThemeFolder())
    end

    local function CleanName(name)
        name = tostring(name or "")
        name = name:gsub('[\\/:%*%?"<>|]', "")
        name = name:gsub("^%s+", ""):gsub("%s+$", "")
        return name
    end

    function WindowObj:SaveConfig(name)
        name = CleanName(name)
        if name == "" then return false end
        local data = {}
        for flag, obj in pairs(WindowObj.Flags) do
            if flag:sub(1, 2) ~= "__" then
                local value = SerializeFlag(obj)
                if value ~= nil then
                    data[flag] = value
                end
            end
        end
        EnsureFolders()
        Storage.Write(ConfigFolder() .. "/" .. name .. ".json", HttpService:JSONEncode({
            Saved = os.date("%d/%m/%Y"),
            Flags = data
        }))
        return true
    end

    function WindowObj:LoadConfig(name)
        local raw = Storage.Read(ConfigFolder() .. "/" .. CleanName(name) .. ".json")
        if not raw then return false end
        local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)
        if not ok or type(data) ~= "table" or type(data.Flags) ~= "table" then return false end
        for flag, value in pairs(data.Flags) do
            local obj = WindowObj.Flags[flag]
            if obj then
                pcall(ApplyFlag, obj, value)
            end
        end
        return true
    end

    function WindowObj:DeleteConfig(name)
        Storage.Delete(ConfigFolder() .. "/" .. CleanName(name) .. ".json")
    end

    function WindowObj:ListConfigs()
        return Storage.List(ConfigFolder(), ".json")
    end

    function WindowObj:GetConfigDate(name)
        local raw = Storage.Read(ConfigFolder() .. "/" .. CleanName(name) .. ".json")
        if not raw then return "" end
        local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)
        return (ok and type(data) == "table" and data.Saved) or ""
    end

    local function EncodeTheme(theme)
        local out = {}
        for key, value in pairs(theme) do
            if typeof(value) == "Color3" then
                out[key] = value:ToHex()
            end
        end
        return HttpService:JSONEncode(out)
    end

    local function DecodeTheme(raw)
        local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)
        if not ok or type(data) ~= "table" then return nil end
        local theme = table.clone(fatalwtfuilibrary.Themes.Default)
        for key, value in pairs(data) do
            local okColor, col = pcall(Color3.fromHex, value)
            if okColor then
                theme[key] = col
            end
        end
        return theme
    end

    -- Default settings tab: Menu, Configs, Theme, Theme Config
    function WindowObj:CreateSettingsTab(sOpts)
        sOpts = sOpts or {}
        EnsureFolders()

        local function Notify(title, content)
            WindowObj:Notify({ Title = title, Content = content, Duration = 3 })
        end

        local Tab = WindowObj:CreateTab({
            Name = sOpts.Name or "Config",
            Icon = sOpts.Icon or fatalwtfuilibrary.Icons.Config
        })

        -- Menu
        local MenuSec = Tab:CreateSection({ Name = "Menu", Side = "Left" })

        MenuSec:CreateKeybind({
            Name = "Menu Keybind",
            Default = WindowObj.MenuKey,
            ShowInList = false,
            Flag = "__MenuKey",
            Callback = function(key)
                if key then WindowObj:SetMenuKey(key) end
            end
        })

        local WatermarkToggle = MenuSec:CreateToggle({
            Name = "Watermark",
            Default = sOpts.Watermark ~= false,
            Flag = "__Watermark",
            Callback = function(v) WindowObj:SetWatermarkVisible(v) end
        })
        WatermarkToggle:AddColorpicker({
            Name = "Watermark Color",
            Default = WindowObj.ActiveTheme.Accent,
            Flag = "__WatermarkColor",
            Callback = function(c) WindowObj:SetWatermarkColor(c) end
        })

        MenuSec:CreateDropdown({
            Name = "Watermark Position",
            Options = { "Top Left", "Top Right", "Bottom Left", "Bottom Right" },
            Default = "Top Left",
            Flag = "__WatermarkPosition",
            Callback = function(v) WindowObj:SetWatermarkPosition(v) end
        })

        local KeybindListToggle = MenuSec:CreateToggle({
            Name = "Keybind List",
            Default = sOpts.KeybindList == true,
            Flag = "__KeybindList",
            Callback = function(v) WindowObj:SetKeybindListVisible(v) end
        })

        MenuSec:CreateToggle({
            Name = "Notifications",
            Default = true,
            Flag = "__Notifications",
            Callback = function(v) WindowObj.NotificationsEnabled = v end
        })

        MenuSec:CreateSlider({
            Name = "Menu Scale",
            Min = 0.5,
            Max = 1.5,
            Default = ScaleVal,
            Decimals = 2,
            Flag = "__Scale",
            Callback = function(v) WindowObj:SetScale(v) end
        })

        WindowObj:SetWatermarkVisible(WatermarkToggle.Value)
        WindowObj:SetKeybindListVisible(KeybindListToggle.Value)

        -- Configs
        local ConfigSec = Tab:CreateSection({ Name = "Configs", Side = "Right" })
        local ConfigList = ConfigSec:CreateList({ Name = "Configs", Height = 150 })
        local ConfigName = ConfigSec:CreateTextBox({ Name = "Config Name", Placeholder = "Type config name..." })
        local AutoLoadDropdown

        local function RefreshConfigs()
            ConfigList:Clear()
            local names = WindowObj:ListConfigs()
            for _, n in ipairs(names) do
                ConfigList:AddItem({ Id = n, Name = n, Info = WindowObj:GetConfigDate(n) })
            end
            if AutoLoadDropdown then
                AutoLoadDropdown:Refresh(#names > 0 and names or { "None" })
            end
            return names
        end

        ConfigSec:CreateButtonRow({
            {
                Name = "Load",
                Accent = true,
                Callback = function()
                    local sel = ConfigList:GetSelected()
                    if not sel then return Notify("Config", "Select a config first") end
                    if WindowObj:LoadConfig(sel.Name) then
                        Notify("Config Loaded", "Successfully loaded '" .. sel.Name .. "'")
                    else
                        Notify("Config Error", "Could not load '" .. sel.Name .. "'")
                    end
                end
            },
            {
                Name = "Create",
                Callback = function()
                    local name = CleanName(ConfigName:GetText())
                    if name == "" then return Notify("Config", "Type a config name first") end
                    WindowObj:SaveConfig(name)
                    RefreshConfigs()
                    ConfigList:Select(name)
                    Notify("Config Created", "Saved '" .. name .. "'")
                end
            },
            {
                Name = "Delete",
                Callback = function()
                    local sel = ConfigList:GetSelected()
                    if not sel then return Notify("Config", "Select a config first") end
                    WindowObj:DeleteConfig(sel.Name)
                    RefreshConfigs()
                    Notify("Config Deleted", "Deleted '" .. sel.Name .. "'")
                end
            }
        })

        local AutoLoadPath = WindowObj.Folder .. "/autoload.txt"
        local AutoName = Storage.Read(AutoLoadPath)

        local AutoLoadToggle = ConfigSec:CreateToggle({
            Name = "Auto Load",
            Default = AutoName ~= nil and AutoName ~= "",
            Flag = "__AutoLoad",
            Callback = function(v)
                if v then
                    local n = AutoLoadDropdown and AutoLoadDropdown.Value
                    if n and n ~= "None" and n ~= "" then
                        Storage.Write(AutoLoadPath, n)
                    end
                else
                    Storage.Delete(AutoLoadPath)
                end
            end
        })

        AutoLoadDropdown = ConfigSec:CreateDropdown({
            Name = "Auto Load Config",
            Options = { "None" },
            Default = AutoName or "None",
            Flag = "__AutoLoadConfig",
            Callback = function(n)
                if AutoLoadToggle.Value and n ~= "None" then
                    Storage.Write(AutoLoadPath, n)
                end
            end
        })

        RefreshConfigs()

        -- Theme
        local ThemeSec = Tab:CreateSection({ Name = "Theme", Side = "Left" })
        local ThemePickers = {}

        local function ThemePicker(label, key, second)
            local picker = ThemeSec:CreateColorpicker({
                Name = label,
                Default = WindowObj.ActiveTheme[key],
                Flag = "__Theme." .. key,
                Callback = function(c) WindowObj:SetThemeColor(key, c) end
            })
            ThemePickers[key] = picker
            if second then
                ThemePickers[second.Key] = picker:AddColorpicker({
                    Name = second.Name,
                    Default = WindowObj.ActiveTheme[second.Key],
                    Flag = "__Theme." .. second.Key,
                    Callback = function(c) WindowObj:SetThemeColor(second.Key, c) end
                })
            end
        end

        ThemePicker("Accent", "Accent")
        ThemePicker("Background", "Background")
        ThemePicker("Section", "SectionBg")
        ThemePicker("Element", "ElementBg")
        ThemePicker("Header Gradient", "Header1", { Name = "Header Gradient 2", Key = "Header2" })
        ThemePicker("Text", "Text", { Name = "Dim Text", Key = "TextDim" })

        local StrokeToggle = ThemeSec:CreateToggle({
            Name = "UI Stroke",
            Default = true,
            Flag = "__Strokes",
            Callback = function(v) WindowObj:SetStrokesEnabled(v) end
        })
        ThemePickers.Stroke = StrokeToggle:AddColorpicker({
            Name = "UI Stroke",
            Default = WindowObj.ActiveTheme.Stroke,
            Flag = "__Theme.Stroke",
            Callback = function(c) WindowObj:SetThemeColor("Stroke", c) end
        })

        ThemeSec:CreateToggle({
            Name = "Header Stripes",
            Default = true,
            Flag = "__Stripes",
            Callback = function(v) WindowObj:SetStripesEnabled(v) end
        })

        ThemeSec:CreateDropdown({
            Name = "Font",
            Options = { "Gotham", "Arial", "Source Sans", "Ubuntu", "Roboto Mono" },
            Default = "Gotham",
            Flag = "__Font",
            Callback = function(v) WindowObj:SetFont(v) end
        })

        local function SyncThemePickers()
            for key, picker in pairs(ThemePickers) do
                local col = WindowObj.ActiveTheme[key]
                if col then
                    picker:SetValue(col, nil, true)
                end
            end
        end

        -- Theme Config
        local ThemeConfigSec = Tab:CreateSection({ Name = "Theme Config", Side = "Right" })
        local ThemeList = ThemeConfigSec:CreateList({ Name = "Themes", Height = 150 })
        local ThemeName = ThemeConfigSec:CreateTextBox({ Name = "Theme Name", Placeholder = "Type theme name..." })
        local PresetOrder = { "Default", "Ocean", "Blood", "Mint", "Midnight", "Sunset" }

        local function RefreshThemes()
            ThemeList:Clear()
            for _, n in ipairs(PresetOrder) do
                if fatalwtfuilibrary.Themes[n] then
                    ThemeList:AddItem({ Id = n, Name = n, Info = "Preset", Icon = fatalwtfuilibrary.Icons.Visual })
                end
            end
            for _, n in ipairs(Storage.List(ThemeFolder(), ".json")) do
                if not fatalwtfuilibrary.Themes[n] then
                    ThemeList:AddItem({ Id = n, Name = n, Info = "Custom", Icon = fatalwtfuilibrary.Icons.Visual })
                end
            end
        end

        local function ApplyTheme(name)
            local theme = fatalwtfuilibrary.Themes[name]
            if not theme then
                local raw = Storage.Read(ThemeFolder() .. "/" .. name .. ".json")
                if raw then theme = DecodeTheme(raw) end
            end
            if not theme then return false end
            WindowObj:SetTheme(theme)
            SyncThemePickers()
            return true
        end

        ThemeConfigSec:CreateButtonRow({
            {
                Name = "Load",
                Accent = true,
                Callback = function()
                    local sel = ThemeList:GetSelected()
                    if not sel then return Notify("Theme", "Select a theme first") end
                    if ApplyTheme(sel.Name) then
                        Notify("Theme Loaded", "Applied '" .. sel.Name .. "'")
                    end
                end
            },
            {
                Name = "Save",
                Callback = function()
                    local name = CleanName(ThemeName:GetText())
                    if name == "" then return Notify("Theme", "Type a theme name first") end
                    if fatalwtfuilibrary.Themes[name] then return Notify("Theme", "Can't overwrite a preset") end
                    EnsureFolders()
                    Storage.Write(ThemeFolder() .. "/" .. name .. ".json", EncodeTheme(WindowObj.ActiveTheme))
                    RefreshThemes()
                    ThemeList:Select(name)
                    Notify("Theme Saved", "Saved '" .. name .. "'")
                end
            },
            {
                Name = "Delete",
                Callback = function()
                    local sel = ThemeList:GetSelected()
                    if not sel then return Notify("Theme", "Select a theme first") end
                    if fatalwtfuilibrary.Themes[sel.Name] then return Notify("Theme", "Presets can't be deleted") end
                    Storage.Delete(ThemeFolder() .. "/" .. sel.Name .. ".json")
                    RefreshThemes()
                    Notify("Theme Deleted", "Deleted '" .. sel.Name .. "'")
                end
            }
        })

        ThemeConfigSec:CreateButton({
            Name = "Reset To Default",
            Callback = function()
                ApplyTheme("Default")
                ThemeList:Select("Default")
            end
        })

        RefreshThemes()
        ThemeList:Select(fatalwtfuilibrary.Themes[DefaultTheme] and DefaultTheme or "Default")

        -- Auto load the saved config once everything exists
        if AutoLoadToggle.Value and AutoName and AutoName ~= "" then
            task.defer(function()
                if WindowObj:LoadConfig(AutoName) then
                    Notify("Config Loaded", "Auto loaded '" .. AutoName .. "'")
                end
            end)
        end

        return Tab
    end

    -- Players tab: player list, priority (Friend / Neutral / Enemy), spectate, teleport
    function WindowObj:CreatePlayersTab(pOpts)
        pOpts = pOpts or {}

        local function Notify(title, content)
            WindowObj:Notify({ Title = title, Content = content, Duration = 2.5 })
        end

        local PriorityColors = {
            Friend = Color3.fromRGB(70, 210, 120),
            Neutral = Color3.fromRGB(150, 150, 150),
            Enemy = Color3.fromRGB(235, 65, 75)
        }
        WindowObj.PriorityColors = PriorityColors
        WindowObj.Priorities = WindowObj.Priorities or {}

        local Tab = WindowObj:CreateTab({
            Name = pOpts.Name or "Players",
            Icon = pOpts.Icon or fatalwtfuilibrary.Icons.Players
        })

        local ListSec = Tab:CreateSection({ Name = "Player List", Side = "Left", Height = 836 })
        local InfoSec = Tab:CreateSection({ Name = "Player Info", Side = "Right", Height = 406 })
        local ActionSec = Tab:CreateSection({ Name = "Actions", Side = "Right", Height = 416 })

        local theme = WindowObj.ActiveTheme
        local Rows = {}
        local Selected = nil
        local Spectating = nil
        local AutoFriends = false
        local SelectPlayer

        local function Headshot(userId)
            return "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=150&h=150"
        end

        local function GetPriority(plr)
            return WindowObj.Priorities[plr.UserId] or "Neutral"
        end

        function WindowObj:GetPriority(plr)
            return GetPriority(plr)
        end

        local function CreateTag(parent, position)
            local Tag = Create("Frame", {
                Name = "Priority",
                Size = UDim2.new(0, 84, 0, 28),
                Position = position,
                BackgroundColor3 = WindowObj.ActiveTheme.ElementBg,
                BorderSizePixel = 0,
                Parent = parent
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 3) })
            })
            local Bar = Create("Frame", {
                Name = "ColorBar",
                Size = UDim2.new(0, 3, 0, 16),
                Position = UDim2.new(0, 0, 0.5, -8),
                BorderSizePixel = 0,
                Parent = Tag
            })
            local Text = Create("TextLabel", {
                Name = "Text",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                Parent = Tag
            })
            Bar:SetAttribute("ThemeIgnore", true)
            Text:SetAttribute("ThemeIgnore", true)
            return { Frame = Tag, Bar = Bar, Text = Text }
        end

        local function StyleTag(tag, prio)
            local col = PriorityColors[prio]
            tag.Bar.BackgroundColor3 = col
            tag.Text.TextColor3 = col
            tag.Text.Text = prio
        end

        -- Player list
        local CountLabel = Create("TextLabel", {
            Name = "Count",
            Size = UDim2.new(0, 150, 0, 38),
            Position = UDim2.new(1, -186, 0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = theme.Text,
            TextXAlignment = Enum.TextXAlignment.Right,
            Text = "0 Players",
            Parent = ListSec.Card
        })

        local ListRow = Create("Frame", {
            Name = "PlayerListRow",
            Size = UDim2.new(1, 0, 0, 776),
            BackgroundTransparency = 1,
            Parent = ListSec.ContentArea
        })

        local Search = Create("TextBox", {
            Name = "Search",
            Size = UDim2.new(1, -4, 0, 32),
            Position = UDim2.new(0, 2, 0, 2),
            BackgroundColor3 = theme.ElementBg,
            BorderSizePixel = 0,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = theme.Text,
            PlaceholderText = "Search players...",
            PlaceholderColor3 = theme.TextDim,
            Text = "",
            ClearTextOnFocus = false,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = ListRow
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
            Create("UIStroke", { Color = theme.Stroke, Thickness = 1 }),
            Create("UIPadding", { PaddingLeft = UDim.new(0, 34) })
        })
        Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, -24, 0.5, -8),
            BackgroundTransparency = 1,
            Image = fatalwtfuilibrary.Icons.Search,
            ImageColor3 = theme.TextDim,
            Parent = Search
        })

        local Scroll = Create("ScrollingFrame", {
            Name = "List",
            Size = UDim2.new(1, -4, 1, -44),
            Position = UDim2.new(0, 2, 0, 42),
            BackgroundColor3 = theme.Background,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = ListRow
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
            Create("UIStroke", { Color = theme.Stroke, Thickness = 1 }),
            Create("UIListLayout", { SortOrder = Enum.SortOrder.Name, Padding = UDim.new(0, 4) }),
            Create("UIPadding", {
                PaddingTop = UDim.new(0, 3),
                PaddingBottom = UDim.new(0, 3),
                PaddingLeft = UDim.new(0, 3),
                PaddingRight = UDim.new(0, 3)
            })
        })

        local function UpdateCount()
            local n = 0
            for _ in pairs(Rows) do n = n + 1 end
            CountLabel.Text = n .. (n == 1 and " Player" or " Players")
        end

        local function UpdateRowStyle(plr)
            local row = Rows[plr]
            if not row then return end
            local t = WindowObj.ActiveTheme
            local selected = plr == Selected
            row.Frame.BackgroundColor3 = selected and t.ElementBg or t.Background
            row.Bar.Visible = selected
            row.AvatarStroke.Color = selected and t.Accent or t.Stroke
            row.Name.TextColor3 = selected and t.Text or t.TextDim
            StyleTag(row.Tag, GetPriority(plr))
        end

        local function ApplySearch()
            local query = Search.Text:lower()
            for plr, row in pairs(Rows) do
                row.Frame.Visible = query == ""
                    or plr.Name:lower():find(query, 1, true) ~= nil
                    or plr.DisplayName:lower():find(query, 1, true) ~= nil
            end
        end
        Search:GetPropertyChangedSignal("Text"):Connect(ApplySearch)

        -- Player info
        local InfoRow = Create("Frame", {
            Name = "InfoRow",
            Size = UDim2.new(1, 0, 0, 350),
            BackgroundTransparency = 1,
            Parent = InfoSec.ContentArea
        })

        local BigAvatar = Create("ImageLabel", {
            Name = "Avatar",
            Size = UDim2.new(0, 96, 0, 96),
            Position = UDim2.new(0, 2, 0, 4),
            BackgroundColor3 = theme.ElementBg,
            BorderSizePixel = 0,
            Image = "",
            Parent = InfoRow
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Create("UIStroke", { Color = theme.Accent, Thickness = 1 })
        })

        local InfoName = Create("TextLabel", {
            Name = "DisplayName",
            Size = UDim2.new(1, -116, 0, 22),
            Position = UDim2.new(0, 112, 0, 10),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 20,
            TextColor3 = theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Text = "No player selected",
            Parent = InfoRow
        })

        local InfoUser = Create("TextLabel", {
            Name = "Username",
            Size = UDim2.new(1, -116, 0, 18),
            Position = UDim2.new(0, 112, 0, 36),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = theme.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Text = "",
            Parent = InfoRow
        })

        local InfoTag = CreateTag(InfoRow, UDim2.new(0, 112, 0, 62))
        InfoTag.Frame.Visible = false

        local Stats = {}
        local StatNames = { "User ID", "Team", "Health", "Distance", "Account Age" }
        for i, statName in ipairs(StatNames) do
            local rowY = 116 + (i - 1) * 34
            Create("TextLabel", {
                Name = statName:gsub(" ", "") .. "Label",
                Size = UDim2.new(0, 150, 0, 20),
                Position = UDim2.new(0, 2, 0, rowY),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 15,
                TextColor3 = theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = statName,
                Parent = InfoRow
            })
            Stats[statName] = Create("TextLabel", {
                Name = statName:gsub(" ", "") .. "Value",
                Size = UDim2.new(0, 200, 0, 20),
                Position = UDim2.new(1, -202, 0, rowY),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 15,
                TextColor3 = theme.Text,
                TextXAlignment = Enum.TextXAlignment.Right,
                Text = "-",
                Parent = InfoRow
            })
        end

        local HealthTrack = Create("Frame", {
            Name = "HealthBar",
            Size = UDim2.new(0, 200, 0, 3),
            Position = UDim2.new(1, -202, 0, 116 + 2 * 34 + 23),
            BackgroundColor3 = theme.ElementBg,
            BorderSizePixel = 0,
            Parent = InfoRow
        })
        local HealthFill = Create("Frame", {
            Name = "Fill",
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = PriorityColors.Friend,
            BorderSizePixel = 0,
            Parent = HealthTrack
        })
        HealthFill:SetAttribute("ThemeIgnore", true)

        local function RefreshStats()
            local plr = Selected
            if not plr or not plr.Parent then
                for _, label in pairs(Stats) do label.Text = "-" end
                HealthFill.Size = UDim2.new(0, 0, 1, 0)
                return
            end
            Stats["User ID"].Text = tostring(plr.UserId)
            Stats["Team"].Text = plr.Team and plr.Team.Name or "None"
            Stats["Account Age"].Text = plr.AccountAge .. " days"

            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                Stats["Health"].Text = math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)
                HealthFill.Size = UDim2.new(math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1), 0, 1, 0)
            else
                Stats["Health"].Text = "-"
                HealthFill.Size = UDim2.new(0, 0, 1, 0)
            end

            local myChar = LocalPlayer and LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if root and myRoot then
                Stats["Distance"].Text = string.format("%.1f studs", (root.Position - myRoot.Position).Magnitude)
            else
                Stats["Distance"].Text = "-"
            end
        end

        local function RefreshInfo()
            local plr = Selected
            if not plr then
                BigAvatar.Image = ""
                InfoName.Text = "No player selected"
                InfoUser.Text = ""
                InfoTag.Frame.Visible = false
            else
                BigAvatar.Image = Headshot(plr.UserId)
                InfoName.Text = plr.DisplayName
                InfoUser.Text = "@" .. plr.Name
                InfoTag.Frame.Visible = true
                StyleTag(InfoTag, GetPriority(plr))
            end
            RefreshStats()
        end

        -- Actions
        ActionSec:CreateLabel("Priority")
        local PriorityNames = { "Friend", "Neutral", "Enemy" }
        local PriorityButtons

        local function RefreshPriorityButtons()
            local current = Selected and GetPriority(Selected) or nil
            for i, prio in ipairs(PriorityNames) do
                PriorityButtons[i]:SetHighlighted(prio == current)
                PriorityButtons[i].Instance.TextColor3 = PriorityColors[prio]
            end
        end

        local function SetPriority(plr, prio)
            WindowObj.Priorities[plr.UserId] = (prio ~= "Neutral") and prio or nil
            UpdateRowStyle(plr)
            if plr == Selected then
                StyleTag(InfoTag, GetPriority(plr))
                RefreshPriorityButtons()
            end
            if pOpts.OnPriorityChanged then
                task.spawn(pOpts.OnPriorityChanged, plr, prio)
            end
        end

        function WindowObj:SetPriority(plr, prio)
            SetPriority(plr, prio)
        end

        local buttonDefs = {}
        for _, prio in ipairs(PriorityNames) do
            table.insert(buttonDefs, {
                Name = prio,
                Callback = function()
                    if not Selected then return Notify("Players", "Select a player first") end
                    SetPriority(Selected, prio)
                end
            })
        end
        PriorityButtons = ActionSec:CreateButtonRow(buttonDefs)
        for i, prio in ipairs(PriorityNames) do
            PriorityButtons[i].Instance.TextColor3 = PriorityColors[prio]
            PriorityButtons[i].Instance:SetAttribute("ThemeIgnore", "Text")
        end

        local SpectateButton

        local function StopSpectate()
            if not Spectating then return end
            Spectating = nil
            SpectateButton:SetText("Spectate")
            SpectateButton:SetHighlighted(false)
            if pOpts.OnSpectate then
                task.spawn(pOpts.OnSpectate, nil)
            else
                local cam = workspace.CurrentCamera
                local hum = LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if cam and hum then cam.CameraSubject = hum end
            end
        end

        local function StartSpectate(plr)
            Spectating = plr
            SpectateButton:SetText("Stop Spectating")
            SpectateButton:SetHighlighted(true)
            if pOpts.OnSpectate then
                task.spawn(pOpts.OnSpectate, plr)
            else
                local cam = workspace.CurrentCamera
                local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
                if cam and hum then cam.CameraSubject = hum end
            end
        end

        SpectateButton = ActionSec:CreateButton({
            Name = "Spectate",
            Callback = function()
                if Spectating then
                    StopSpectate()
                elseif Selected then
                    StartSpectate(Selected)
                else
                    Notify("Players", "Select a player first")
                end
            end
        })

        ActionSec:CreateButton({
            Name = "Teleport",
            Callback = function()
                if not Selected then return Notify("Players", "Select a player first") end
                if pOpts.OnTeleport then
                    task.spawn(pOpts.OnTeleport, Selected)
                else
                    Notify("Teleport", "No OnTeleport handler was given")
                end
            end
        })

        local function RefreshAllRows()
            for plr in pairs(Rows) do
                UpdateRowStyle(plr)
            end
            if Selected then StyleTag(InfoTag, GetPriority(Selected)) end
            RefreshPriorityButtons()
        end

        for _, prio in ipairs({ "Friend", "Enemy", "Neutral" }) do
            ActionSec:CreateColorpicker({
                Name = prio .. " Color",
                Default = PriorityColors[prio],
                Flag = "Players." .. prio .. "Color",
                Callback = function(c)
                    PriorityColors[prio] = c
                    RefreshAllRows()
                end
            })
        end

        local function CheckFriend(plr)
            task.spawn(function()
                local ok, isFriend = pcall(function()
                    return LocalPlayer:IsFriendsWith(plr.UserId)
                end)
                if ok and isFriend and GetPriority(plr) == "Neutral" then
                    SetPriority(plr, "Friend")
                end
            end)
        end

        ActionSec:CreateToggle({
            Name = "Auto Add Roblox Friends",
            Default = false,
            Flag = "Players.AutoFriends",
            Callback = function(v)
                AutoFriends = v
                if v then
                    for plr in pairs(Rows) do CheckFriend(plr) end
                end
            end
        })

        -- Rows
        function SelectPlayer(plr)
            local previous = Selected
            Selected = plr
            if previous then UpdateRowStyle(previous) end
            if plr then UpdateRowStyle(plr) end
            RefreshInfo()
            RefreshPriorityButtons()
        end

        local function AddRow(plr)
            if Rows[plr] then return end
            if plr == LocalPlayer and pOpts.IncludeLocalPlayer ~= true then return end
            local t = WindowObj.ActiveTheme

            local Frame = Create("TextButton", {
                Name = plr.DisplayName:lower() .. "_" .. plr.UserId,
                Size = UDim2.new(1, -6, 0, 52),
                BackgroundColor3 = t.Background,
                AutoButtonColor = false,
                BorderSizePixel = 0,
                Text = "",
                Parent = Scroll
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 3) })
            })

            local Bar = Create("Frame", {
                Name = "SelectBar",
                Size = UDim2.new(0, 3, 0, 32),
                Position = UDim2.new(0, 0, 0.5, -16),
                BackgroundColor3 = t.Accent,
                BorderSizePixel = 0,
                Visible = false,
                Parent = Frame
            })

            local Avatar = Create("ImageLabel", {
                Name = "Avatar",
                Size = UDim2.new(0, 36, 0, 36),
                Position = UDim2.new(0, 12, 0.5, -18),
                BackgroundColor3 = t.ElementBg,
                BorderSizePixel = 0,
                Image = Headshot(plr.UserId),
                Parent = Frame
            }, {
                Create("UICorner", { CornerRadius = UDim.new(1, 0) })
            })
            local AvatarStroke = Create("UIStroke", { Color = t.Stroke, Thickness = 1, Parent = Avatar })

            local NameLabel = Create("TextLabel", {
                Name = "DisplayName",
                Size = UDim2.new(1, -160, 0, 20),
                Position = UDim2.new(0, 58, 0, 8),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 15,
                TextColor3 = t.TextDim,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Text = plr.DisplayName,
                Parent = Frame
            })

            Create("TextLabel", {
                Name = "Username",
                Size = UDim2.new(1, -160, 0, 16),
                Position = UDim2.new(0, 58, 0, 28),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextColor3 = t.TextDim,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Text = "@" .. plr.Name,
                Parent = Frame
            })

            local Tag = CreateTag(Frame, UDim2.new(1, -94, 0.5, -14))

            Rows[plr] = {
                Frame = Frame,
                Bar = Bar,
                AvatarStroke = AvatarStroke,
                Name = NameLabel,
                Tag = Tag
            }

            Frame.MouseButton1Click:Connect(function()
                SelectPlayer(plr)
            end)

            UpdateRowStyle(plr)
            UpdateCount()
            ApplySearch()
            if AutoFriends then CheckFriend(plr) end
        end

        local function RemoveRow(plr)
            local row = Rows[plr]
            if not row then return end
            row.Frame:Destroy()
            Rows[plr] = nil
            if Spectating == plr then StopSpectate() end
            if Selected == plr then SelectPlayer(nil) end
            UpdateCount()
        end

        for _, plr in ipairs(Players:GetPlayers()) do
            AddRow(plr)
        end
        Players.PlayerAdded:Connect(AddRow)
        Players.PlayerRemoving:Connect(RemoveRow)

        local elapsed = 0
        RunService.Heartbeat:Connect(function(dt)
            elapsed = elapsed + dt
            if elapsed < 0.25 then return end
            elapsed = 0
            if Tab.Page.Visible and Selected then
                RefreshStats()
            end
        end)

        RefreshInfo()
        RefreshPriorityButtons()
        UpdateCount()

        return Tab
    end

    return WindowObj
end

return fatalwtfuilibrary
