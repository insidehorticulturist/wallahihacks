local dote={cache={}}do do local __modImpl=function()







































local freeThreads= {}
local runCallback=function(
callback, thread, ...)	
callback(...)
	table.insert(freeThreads, thread)
end local yielder=function()	


while true do
		runCallback(coroutine.yield())
	end
end

local Connection = {}
Connection.__index = Connection
local disconnect=function(
self)	
if not self.Connected then
		return
	end
	self.Connected = false

	local next = self._next
	local prev = self._prev

	if next then
		next._prev = prev
	end
	if prev then
		prev._next = next
	end

	local signal = self._signal
	if signal._head == self then
		signal._head = next
	end
end local reconnect=function(

self)	
if self.Connected then
		return
	end
	self.Connected = true

	local signal = self._signal
	local head = signal._head
	if head then
		head._prev = self
	end
	signal._head = self

	self._next = head
	self._prev = false
end

Connection.Disconnect = disconnect
Connection.Reconnect = reconnect

--\\ Signal //--
local Signal = {}
Signal.__index = Signal

-- stylua: ignore
local rbxConnect, rbxDisconnect do
	if task then
		local bindable = Instance.new("BindableEvent")
		rbxConnect = bindable.Event.Connect
		rbxDisconnect = bindable.Event:Connect(function() end).Disconnect
		bindable:Destroy()
	end
end
local connect=function(
self, fn, ...)	
local head = self._head
	local varargs = { ... }
	local cn = setmetatable({
		Connected = true,
		_signal = self,
		_fn = fn,
		_varargs = (#varargs == 0 and{false }or{varargs})[1],
		_next = head,
		_prev = false,
	}, Connection)

	if head then
		head._prev = cn
	end
	self._head = cn

	return cn
end local once=function(

self, fn, ...)	
local cn
	cn = connect(self, function(...)
		disconnect(cn)
		fn(...)
	end, ...)
	return cn
end

local wait = task
and function(self)		
local thread = coroutine.running()
		local cn
		cn = connect(self, function(...)
			disconnect(cn)
			if coroutine.status(thread) == "suspended" then
				task.spawn(thread, ...)
			end
		end)
		return coroutine.yield()
	end
or function(self)		
local thread = coroutine.running()
		local cn
		cn = connect(self, function(...)
			disconnect(cn)
			local passed, message = coroutine.resume(thread, ...)
			if not passed then
				error(message, 0)
			end
		end)
		return coroutine.yield()
	end

local fire = task
and function(self, ...)
		local cn = self._head
		while cn do
			local thread
			if #freeThreads > 0 then
				thread = freeThreads[#freeThreads]
				freeThreads[#freeThreads] = nil
			else
				thread = coroutine.create(yielder)
				coroutine.resume(thread)
			end

			if not cn._varargs then
				task.spawn(thread, cn._fn, thread, ...)
			else
				local args = cn._varargs
				local len = #args
				local count = len
				for _, value in { ... } do
					count =count+ 1
					args[count] = value
				end

				task.spawn(thread, cn._fn, thread, table.unpack(args))

				for i = count, len + 1, -1 do
					args[i] = nil
				end
			end

			cn = cn._next
		end
	end
or function(self, ...)
		local cn = self._head
		while cn do
			local thread
			if #freeThreads > 0 then
				thread = freeThreads[#freeThreads]
				freeThreads[#freeThreads] = nil
			else
				thread = coroutine.create(yielder)
				coroutine.resume(thread)
			end

			if not cn._varargs then
				local passed, message = coroutine.resume(thread, cn._fn, thread, ...)
				if not passed then
					print(string.format("%s\nstacktrace:\n%s", message, debug.traceback()))
				end
			else
				local args = cn._varargs
				local len = #args
				local count = len
				for _, value in { ... } do
					count =count+ 1
					args[count] = value
				end

				local passed, message = coroutine.resume(thread, cn._fn, thread, table.unpack(args))
				if not passed then
					print(string.format("%s\nstacktrace:\n%s", message, debug.traceback()))
				end

				for i = count, len + 1, -1 do
					args[i] = nil
				end
			end

			cn = cn._next
		end
	end
local disconnectAll=function(
self)	
local cn = self._head
	while cn do
		disconnect(cn)
		cn = cn._next
	end
end local destroy=function(

self)	
disconnectAll(self)
	local cn = self.RBXScriptConnection
	if cn then
		rbxDisconnect(cn)
		self.RBXScriptConnection = nil
	end
end
--\\ Constructors

function Signal.new()	
return setmetatable({ _head = false }, Signal)
end

function Signal.wrap(signal)	
local wrapper = setmetatable({ _head = false }, Signal)
	wrapper.RBXScriptConnection = rbxConnect(signal, function(...)
		fire(wrapper, ...)
	end)
	return wrapper
end

--\\ Methods
Signal.Connect = connect
Signal.Once = once
Signal.Wait = wait
Signal.Fire = fire
Signal.DisconnectAll = disconnectAll
Signal.Destroy = destroy

return { new = Signal.new, wrap = Signal.wrap }end function dote.a()local v=dote.cache.a if not v then v={c=__modImpl()}dote.cache.a=v end return v.c end end do local __modImpl=function()-- the EclX look: deep space blacks lit by iridium cyan, with a corona amber for highlights.
-- shared by the hub window and the match stats so both read as one client.
-- also holds the small instance helpers every ui file builds with


local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local theme = {}

theme.colors = {
    background = Color3.fromRGB(7, 9, 14),
    backgroundTop = Color3.fromRGB(12, 17, 28),
    sidebar = Color3.fromRGB(9, 12, 19),
    panel = Color3.fromRGB(12, 17, 27),
    raised = Color3.fromRGB(17, 24, 38),
    hover = Color3.fromRGB(22, 31, 48),
    field = Color3.fromRGB(15, 21, 33),
    stroke = Color3.fromRGB(27, 36, 54),
    strokeBright = Color3.fromRGB(42, 56, 82),
    text = Color3.fromRGB(232, 238, 248),
    textDim = Color3.fromRGB(178, 190, 210),
    muted = Color3.fromRGB(112, 126, 150),
    faint = Color3.fromRGB(64, 76, 98),
    accent = Color3.fromRGB(34, 228, 255),
    accentDeep = Color3.fromRGB(46, 104, 255),
    corona = Color3.fromRGB(255, 184, 77),
    danger = Color3.fromRGB(255, 94, 110),
    success = Color3.fromRGB(80, 224, 140),
    self = Color3.fromRGB(13, 33, 50),
}

theme.fonts = {
    body = Enum.Font.Gotham,
    medium = Enum.Font.GothamMedium,
    bold = Enum.Font.GothamBold,
    black = Enum.Font.GothamBlack,
    mono = Enum.Font.RobotoMono,
}

local colors = theme.colors
local fonts = theme.fonts

-- accent pairs the player can switch between in Settings
theme.presets = {
    { name = "Iridium", accent = Color3.fromRGB(34, 228, 255), deep = Color3.fromRGB(46, 104, 255) },
    { name = "Corona", accent = Color3.fromRGB(255, 196, 92), deep = Color3.fromRGB(255, 92, 58) },
    { name = "Nebula", accent = Color3.fromRGB(196, 140, 255), deep = Color3.fromRGB(92, 96, 240) },
    { name = "Plasma", accent = Color3.fromRGB(255, 96, 176), deep = Color3.fromRGB(136, 80, 255) },
    { name = "Verdant", accent = Color3.fromRGB(88, 232, 150), deep = Color3.fromRGB(16, 156, 186) },
    { name = "Lunar", accent = Color3.fromRGB(232, 238, 248), deep = Color3.fromRGB(120, 132, 156) },
}

-- live theming: what to repaint when the accent or the transparency changes. these hold their instances
-- strongly and drop them when they're destroyed; a weak table won't do, since an instance's lua handle is
-- collected whenever no script references it, even while the instance itself is still on screen
local colorBindings = {} -- instance -> { property = color key }
local accentGradients = {} -- UIGradient -> true
local surfaces = {} -- GuiObject -> how much of the transparency it takes
local listeners = {}
local surfaceTransparency = 0
local forgetOnDestroy=function(
instance, registry)    
instance.Destroying:Connect(function()
        registry[instance] = nil
    end)
end
-- sets instance[property] to a theme color now, and again whenever that color changes

function theme.bind(instance, property, key)
    local properties = colorBindings[instance]
    if not properties then
        properties = {}
        colorBindings[instance] = properties
        forgetOnDestroy(instance, colorBindings)
    end
    properties[property] = key
    instance[property] = colors[key]
    return instance
end

-- a background that fades with the window transparency setting; factor 1 fades fully, panels fade less
-- so they stay readable
function theme.surface(instance, factor)
    if surfaces[instance] == nil then
        forgetOnDestroy(instance, surfaces)
    end
    surfaces[instance] = factor or 1
    instance.BackgroundTransparency = surfaceTransparency * (factor or 1)
    return instance
end

function theme.onChanged(callback)
    table.insert(listeners, callback)
end
local notify=function()    

for _, callback in listeners do
        local ok, err = pcall(callback)
        if not ok then
            warn("[eclx] theme listener error:", err)
        end
    end
end

function theme.setAccent(accent, deep)
    colors.accent = accent
    colors.accentDeep = deep
    local sequence = ColorSequence.new(accent, deep)
    for gradient in accentGradients do
        gradient.Color = sequence
    end
    for instance, properties in colorBindings do
        for property, key in properties do
            instance[property] = colors[key]
        end
    end
    notify()
end

function theme.setTransparency(transparency)
    surfaceTransparency = transparency
    for instance, factor in surfaces do
        instance.BackgroundTransparency = transparency * factor
    end
end

function theme.hex(color)
    return "#" .. color:ToHex()
end

function theme.create(className, properties, children)
    local instance = Instance.new(className)
    for property, value in properties do
        if property ~= "Parent" then
            instance[property] = value
        end
    end
    for _, child in children or {} do
        child.Parent = instance
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

local create = theme.create

function theme.corner(radius)
    return create("UICorner", { CornerRadius = (radius and{(UDim.new(0, radius) )}or{(UDim.new(1, 0) )})[1]})
end

function theme.stroke(color, thickness, transparency)
    return create("UIStroke", {
        Color = color or colors.stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

function theme.padding(left, right, top, bottom)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or left or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or top or 0),
    })
end

-- iridium: cyan into deep blue, the way the game's beams charge
function theme.accentGradient(rotation)
    local gradient = create("UIGradient", {
        Color = ColorSequence.new(colors.accent, colors.accentDeep),
        Rotation = rotation or 0,
    })
    accentGradients[gradient] = true
    forgetOnDestroy(gradient, accentGradients)
    return gradient
end

-- a chevron drawn from two bars, since the fonts don't all have an arrow glyph
function theme.chevron(properties)
    local holder = create("Frame", {
        Size = UDim2.fromOffset(10, 6),
        BackgroundTransparency = 1,
    })
    for _, side in { -1, 1 } do
        local bar = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, side * 2, 0.5, 0),
            Size = UDim2.fromOffset(6, 2),
            Rotation = side * -40,
            BorderSizePixel = 0,
            Parent = holder,
        }, { theme.corner(1) })
        theme.bind(bar, "BackgroundColor3", "accent")
    end
    for property, value in properties do
        holder[property] = value
    end
    return holder
end

function theme.text(properties)
    local label = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = fonts.body,
        TextColor3 = colors.text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    for property, value in properties do
        label[property] = value
    end
    return label
end

function theme.tween(instance, duration, properties, style)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

-- somewhere the game's own scripts can't see: the executor's hidden ui, then CoreGui, then PlayerGui
function theme.guiParent()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then
            return hui
        end
    end
    local ok = pcall(function()
        return game:GetService("CoreGui").Name
    end)
    if ok then
        return game:GetService("CoreGui")
    end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

function theme.headshot(userId)
    return (userId and userId > 0 and{(string.format('rbxthumb://type=AvatarHeadShot&id=%s&w=150&h=150', tostring(userId)))}or{""
})[1]end

-- 950 -> "950", 12450 -> "12.4k", 1250000 -> "1.25m"
function theme.compact(number)
    number = math.round(number)
    if math.abs(number) >= 1e6 then
        return string.format("%.2fm", number / 1e6)
    elseif math.abs(number) >= 1e4 then
        return string.format("%.1fk", number / 1e3)
    end
    return tostring(number)
end

-- 12450 -> "12,450"
function theme.thousands(number)
    local formatted = tostring(math.round(number))
    while true do
        local replaced, count = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        formatted = replaced
        if count == 0 then
            return formatted
        end
    end
end

return theme
end function dote.b()local v=dote.cache.b if not v then v={c=__modImpl()}dote.cache.b=v end return v.c end end do local __modImpl=function()-- EclX client ui. a window with a sidebar of tabs; each tab is two columns of groupboxes or one custom
-- page. it keeps obsidian's shape (Toggles / Options entries with .Value, :SetValue and :OnChanged,
-- groupbox:AddCheckbox(...):AddKeyPicker(...), etc.) so feature modules read settings as they always have.
-- settings are saved as named configs in eclx/configs/<userId>/, one of which can load on start.
-- usage: local window = Library.new({ globals = true }); local tab = window:AddTab("Combat");
--        tab:AddLeftGroupbox("Silent Aim"):AddCheckbox("SilentAim", { Text = "Silent Aim" })


local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local theme = dote.b()

local colors = theme.colors
local fonts = theme.fonts
local create = theme.create
local corner = theme.corner
local stroke = theme.stroke
local text = theme.text
local tween = theme.tween

local LocalPlayer = Players.LocalPlayer

local DEFAULT_SIZE = Vector2.new(980, 620)
local MIN_SIZE = Vector2.new(780, 480)
local SIDEBAR_WIDTH = 190
local HEADER_HEIGHT = 66
local COLUMN_GAP = 16
local PAGE_PADDING = 24
local CONFIG_FOLDER = "eclx/configs"
local HEADER_REFRESH = 0.5
local KEY_MODES = { "Toggle", "Hold", "Press" }
-- buttons ignore clicks this long after the window appears, and DoubleClick ones wait this long for
-- the second click
local CLICK_GRACE = 0.5
local CONFIRM_TIME = 2.5

-- left click only ever fires pickers bound to it on purpose (AllowMouse1); clicking the ui is never a key
local MOUSE_KEYS = {
    [Enum.UserInputType.MouseButton1] = "MB1",
    [Enum.UserInputType.MouseButton2] = "MB2",
    [Enum.UserInputType.MouseButton3] = "MB3",
}

local Library = {}
Library.__index = Library

local Tab = {}
Tab.__index = Tab

local Groupbox = {}
Groupbox.__index = Groupbox
local safeCall=function(
callback, ...)    
local ok, err = pcall(callback, ...)
    if not ok then
        warn("[eclx] callback error:", err)
    end
end local keyName=function(


input)    
if input.UserInputType == Enum.UserInputType.Keyboard then
        return (input.KeyCode ~= Enum.KeyCode.Unknown and{(input.KeyCode.Name )}or{nil
})[1]    end
    return MOUSE_KEYS[input.UserInputType]
end local pointerPosition=function(



input)    
if input and input.UserInputType == Enum.UserInputType.Touch then
        local inset = game:GetService("GuiService"):GetGuiInset()
        return Vector2.new(input.Position.X, input.Position.Y + inset.Y)
    end
    return UserInputService:GetMouseLocation()
end local round=function(

value, decimals)    
local scale = 10 ^ (decimals or 0)
    return math.floor(value * scale + 0.5) / scale
end
-- one setting: a value with change callbacks, registered under its index in Toggles or Options.
-- changeCallback runs whenever the value changes; it defaults to info.Callback, but key pickers pass
-- their own, since their info.Callback is what the key does when pressed, not a reaction to rebinding

local function newValue(window, registry, index, info, value, changeCallback)
    local object = {
        Value = value,
        Default = value,
        Text = info.Text,
        _info = info,
        _changeCallback = (changeCallback == nil and{(info.Callback )}or{changeCallback or nil})[1],
        _callbacks = {},
        _render = nil,
    }

    function object:OnChanged(callback)
        table.insert(self._callbacks, callback)
    end

    function object:_set(newValue)
        self.Value = newValue
        if self._render then
            self._render()
        end
        if self._changeCallback then
            safeCall(self._changeCallback, newValue)
        end
        for _, callback in self._callbacks do
            safeCall(callback, newValue)
        end
    end

    if index then
        registry[index] = object
    end
    return object
end

-- window

function Library.new(options)
    options = options or {}

    local self = setmetatable({
        title = options.title or "EclX",
        tag = options.tag or "CLIENT",
        Toggles = {},
        Options = {},
        tabs = {},
        currentTab = nil,
        visible = false,
        unloaded = false,
        keyPickers = {},
        listening = nil,
        connections = {},
        configEnabled = options.config ~= false and writefile ~= nil,
        configIgnore = options.configIgnore or {},
        visibilityCallbacks = {},
        popup = nil,
        size = DEFAULT_SIZE,
        shownAt = 0,
        -- the player's own scale on top of the fit-to-screen one
        userScale = 1,
    }, Library)

    -- the hub's modules read the global Toggles / Options; a standalone window keeps its own
    if options.globals and getgenv then
        getgenv().Toggles = self.Toggles
        getgenv().Options = self.Options
    end

    self:_build()
    self:_bindInput()

    -- the active tab's number and bar take the accent, so repaint the nav when it changes. only the nav:
    -- reselecting the tab would close the color picker the accent is being dragged in
    theme.onChanged(function()
        if self.currentTab and not self.unloaded then
            self:_paintNav()
        end
    end)

    -- the menu key is a normal key picker, shown in settings
    self.menuKey = self:_newKeyPicker(nil, "MenuKeybind", {
        Text = "Menu key",
        Default = options.menuKey or "Insert",
        Mode = "Press",
        Callback = function()
            self:Toggle()
        end,
    })

    -- the window size the player dragged it to, saved with everything else
    self.sizeValue = newValue(self, self.Options, "UI/Size", {}, { DEFAULT_SIZE.X, DEFAULT_SIZE.Y })
    self.sizeValue.Type = "Hidden"
    function self.sizeValue.SetValue(value, size)
        if typeof(size) == "table" and tonumber(size[1]) and tonumber(size[2]) then
            self:SetSize(Vector2.new(tonumber(size[1]), tonumber(size[2])))
        end
    end

    return self
end

function Library:_maxSize()
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or DEFAULT_SIZE
    return Vector2.new(math.max(MIN_SIZE.X, viewport.X - 24), math.max(MIN_SIZE.Y, viewport.Y - 24))
end

-- scale so the whole window fits on screen, times the player's ui scale
function Library:_fit()
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or self.size
    local fit = math.min(1, (viewport.X - 24) / self.size.X, (viewport.Y - 24) / self.size.Y)
    self.baseScale = math.max(fit * self.userScale, 0.3)
    self.scale.Scale = self.baseScale
end

function Library:SetSize(size, keepScale)
    local maximum = self:_maxSize()
    size = Vector2.new(
        math.clamp(math.round(size.X), MIN_SIZE.X, maximum.X),
        math.clamp(math.round(size.Y), MIN_SIZE.Y, maximum.Y)
    )
    self.size = size
    self.window.Size = UDim2.fromOffset(size.X, size.Y)
    self.sizeValue.Value = { size.X, size.Y }
    if not keepScale then
        self:_fit()
    end
end

function Library:SetUserScale(scale)
    self.userScale = scale
    self:_fit()
end

function Library:_connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(self.connections, connection)
    return connection
end

function Library:_build()
    local gui = create("ScreenGui", {
        Name = "\255",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 60,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = theme.guiParent(),
    })
    self.gui = gui

    local window = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(self.size.X, self.size.Y),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Visible = false,
        Parent = gui,
    }, {
        corner(12),
        create("UIGradient", {
            Color = ColorSequence.new(colors.backgroundTop, colors.background),
            Rotation = 90,
        }),
    })
    theme.surface(window, 1)
    self.window = window

    -- the border catches the light at two corners, like a rim lit by the corona
    local border = stroke(Color3.new(1, 1, 1), 1)
    border.Parent = window
    local borderGradient = create("UIGradient", { Rotation = 35, Parent = border })
local paintBorder=function()        
borderGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, colors.accent),
            ColorSequenceKeypoint.new(0.25, colors.stroke),
            ColorSequenceKeypoint.new(0.75, colors.stroke),
            ColorSequenceKeypoint.new(1, colors.accentDeep),
        })
end    
paintBorder()
    theme.onChanged(paintBorder)

    self.scale = create("UIScale", { Parent = window })
    self:_fit()
    if workspace.CurrentCamera then
        self:_connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function()
            self:_fit()
        end)
    end

    self:_buildSidebar()
    self:_buildContent()
    self:_buildResizeGrip()

    -- popups (dropdowns, color pickers) sit above everything in the window
    self.overlay = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ZIndex = 50,
        Parent = window,
    })

    self:_buildTooltip()
    self:_buildNotifications()
end

function Library:_buildSidebar()
    local sidebar = create("Frame", {
        Size = UDim2.new(0, SIDEBAR_WIDTH, 1, 0),
        BackgroundColor3 = colors.sidebar,
        Parent = self.window,
    }, { corner(12) })
    theme.surface(sidebar, 1)

    -- square off the inner edge and draw the divider
    theme.surface(create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.new(0, 12, 1, 0),
        BackgroundColor3 = colors.sidebar,
        BorderSizePixel = 0,
        Parent = sidebar,
    }), 1)
    create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = colors.stroke,
        BorderSizePixel = 0,
        Parent = sidebar,
    })

    -- the mark: a lit ring with the moon slid across it
    local brand = create("Frame", {
        Size = UDim2.new(1, 0, 0, 74),
        BackgroundTransparency = 1,
        Parent = sidebar,
    })
    local corona = create("Frame", {
        Position = UDim2.fromOffset(20, 22),
        Size = UDim2.fromOffset(30, 30),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = brand,
    }, { corner() })
    self.coronaGradient = theme.accentGradient(45)
    self.coronaGradient.Parent = corona
    -- the moon stays solid even when the window is see-through, or the crescent would vanish
    create("Frame", {
        Position = UDim2.fromOffset(5, 1),
        Size = UDim2.fromOffset(26, 26),
        BackgroundColor3 = colors.sidebar,
        Parent = corona,
    }, { corner() })

    local wordmark = text({
        Position = UDim2.fromOffset(60, 18),
        Size = UDim2.new(1, -70, 0, 24),
        RichText = true,
        Font = fonts.black,
        TextSize = 22,
        Parent = brand,
    })
local paintWordmark=function()        
wordmark.Text = string.format('Ecl<font color="%s">X</font>', tostring(theme.hex(colors.accent)))end    

paintWordmark()
    theme.onChanged(paintWordmark)

    theme.bind(text({
        Position = UDim2.fromOffset(61, 42),
        Size = UDim2.new(1, -70, 0, 12),
        Text = string.format('%s  <font color="%s">// ECLIPSIS</font>', tostring(self.tag), tostring(theme.hex(colors.faint))),
        RichText = true,
        Font = fonts.mono,
        TextSize = 10,
        Parent = brand,
    }), "TextColor3", "accent")
    self:_makeDraggable(brand)

    text({
        Position = UDim2.fromOffset(22, 84),
        Size = UDim2.new(1, -30, 0, 12),
        Text = "MODULES",
        Font = fonts.mono,
        TextSize = 10,
        TextColor3 = colors.faint,
        Parent = sidebar,
    })

    self.nav = create("Frame", {
        Position = UDim2.fromOffset(0, 102),
        Size = UDim2.new(1, 0, 1, -170),
        BackgroundTransparency = 1,
        Parent = sidebar,
    }, {
        theme.padding(10, 10, 0, 0),
        create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
    })

    -- who's playing
    local card = create("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 12, 1, -12),
        Size = UDim2.new(1, -24, 0, 46),
        BackgroundColor3 = colors.panel,
        Parent = sidebar,
    }, { corner(8), stroke() })
    theme.surface(card, 0.7)
    local avatar = create("ImageLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 8, 0.5, 0),
        Size = UDim2.fromOffset(30, 30),
        BackgroundColor3 = colors.raised,
        Image = theme.headshot(LocalPlayer.UserId),
        Parent = card,
    }, { corner() })
    theme.bind(stroke(colors.accent, 1, 0.4), "Color", "accent").Parent = avatar
    text({
        Position = UDim2.fromOffset(46, 8),
        Size = UDim2.new(1, -52, 0, 16),
        Text = LocalPlayer.DisplayName,
        Font = fonts.bold,
        TextSize = 13,
        Parent = card,
    })
    text({
        Position = UDim2.fromOffset(46, 25),
        Size = UDim2.new(1, -52, 0, 12),
        Text = string.format('@%s', tostring(LocalPlayer.Name)),
        Font = fonts.mono,
        TextSize = 10,
        TextColor3 = colors.muted,
        Parent = card,
    })
end

function Library:_buildContent()
    local content = create("Frame", {
        Position = UDim2.fromOffset(SIDEBAR_WIDTH, 0),
        Size = UDim2.new(1, -SIDEBAR_WIDTH, 1, 0),
        BackgroundTransparency = 1,
        Parent = self.window,
    })

    local header = create("Frame", {
        Size = UDim2.new(1, 0, 0, HEADER_HEIGHT),
        BackgroundTransparency = 1,
        Parent = content,
    })
    self:_makeDraggable(header)

    self.pageTitle = text({
        Position = UDim2.fromOffset(24, 15),
        Size = UDim2.new(1, -260, 0, 24),
        Font = fonts.bold,
        TextSize = 20,
        Parent = header,
    })
    self.pageSubtitle = theme.bind(text({
        Position = UDim2.fromOffset(25, 41),
        Size = UDim2.new(1, -260, 0, 12),
        Font = fonts.mono,
        TextSize = 10,
        Parent = header,
    }), "TextColor3", "accent")

    self.telemetry = text({
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -60, 0, 26),
        Size = UDim2.fromOffset(200, 14),
        Font = fonts.mono,
        TextSize = 11,
        TextColor3 = colors.muted,
        TextXAlignment = Enum.TextXAlignment.Right,
        RichText = true,
        Parent = header,
    })

    local close = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -18, 0, 18),
        Size = UDim2.fromOffset(30, 30),
        BackgroundColor3 = colors.panel,
        AutoButtonColor = false,
        Text = "—",
        Font = fonts.bold,
        TextSize = 14,
        TextColor3 = colors.muted,
        Parent = header,
    }, { corner(8), stroke() })
    close.MouseButton1Click:Connect(function()
        self:SetVisible(false)
    end)
    self:_hoverFill(close, colors.panel, colors.hover)

    -- fading accent rule under the header
    local rule = theme.accentGradient(0)
    rule.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(0.4, 0.75),
        NumberSequenceKeypoint.new(1, 1),
    })
    create("Frame", {
        Position = UDim2.fromOffset(PAGE_PADDING, HEADER_HEIGHT - 1),
        Size = UDim2.new(1, -PAGE_PADDING * 2, 0, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = content,
    }, { rule })

    self.body = create("Frame", {
        Position = UDim2.fromOffset(0, HEADER_HEIGHT),
        Size = UDim2.new(1, 0, 1, -HEADER_HEIGHT),
        BackgroundTransparency = 1,
        Parent = content,
    })
end

-- drag the bottom right corner to resize, like obsidian; the size is saved with the settings
function Library:_buildResizeGrip()
    local grip = create("TextButton", {
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -4, 1, -4),
        Size = UDim2.fromOffset(18, 18),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 40,
        Parent = self.window,
    })

    -- three dots on the diagonal
    local dots = {}
    for _, offset in { { 12, 12 }, { 7, 12 }, { 12, 7 }, { 2, 12 }, { 7, 7 }, { 12, 2 } } do
        table.insert(dots, create("Frame", {
            Position = UDim2.fromOffset(offset[1], offset[2]),
            Size = UDim2.fromOffset(2, 2),
            BackgroundColor3 = colors.faint,
            BorderSizePixel = 0,
            ZIndex = 41,
            Parent = grip,
        }))
    end
local paint=function(color)        
for _, dot in dots do
            dot.BackgroundColor3 = color
        end
end    
grip.MouseEnter:Connect(function()
        paint(colors.accent)
    end)
    grip.MouseLeave:Connect(function()
        paint(colors.faint)
    end)

    grip.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        local startMouse = pointerPosition(input)
        local startSize = self.size
        local startPosition = self.window.Position
        local scale = math.max(self.scale.Scale, 0.01)

        self:_closePopup()
        self:_beginDrag(function(position)
            local delta = (position - startMouse) / scale
            self:SetSize(startSize + delta, true)
            -- the window is centered on its position, so shift it by half the growth to keep the top left still
            local grown = (self.size - startSize) * scale / 2
            self.window.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + grown.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + grown.Y
            )
        end)
    end)
end

function Library:_buildTooltip()
    local tooltip = create("Frame", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = colors.panel,
        Visible = false,
        ZIndex = 100,
        Parent = self.gui,
    }, { corner(6), stroke(colors.strokeBright), theme.padding(10, 10, 7, 7) })
    self.tooltipText = text({
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.new(),
        TextSize = 12,
        TextColor3 = colors.textDim,
        TextTruncate = Enum.TextTruncate.None,
        TextWrapped = false,
        RichText = true,
        ZIndex = 101,
        Parent = tooltip,
    })
    self.tooltip = tooltip
end

function Library:_buildNotifications()
    self.notifications = create("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -18, 1, -18),
        Size = UDim2.new(0, 320, 1, -36),
        BackgroundTransparency = 1,
        ZIndex = 90,
        Parent = self.gui,
    }, {
        create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
        }),
    })
end

function Library:_hoverFill(button, normal, hovered)
    button.MouseEnter:Connect(function()
        tween(button, 0.1, { BackgroundColor3 = hovered })
    end)
    button.MouseLeave:Connect(function()
        tween(button, 0.1, { BackgroundColor3 = normal })
    end)
end

function Library:_tooltipOn(guiObject, content)
    if not content then
        return
    end
    guiObject.MouseEnter:Connect(function()
        self:ShowTooltip(content)
    end)
    guiObject.MouseLeave:Connect(function()
        self:HideTooltip()
    end)
end

function Library:ShowTooltip(content)
    self.tooltipText.Text = content
    self.tooltip.Visible = true
end

function Library:HideTooltip()
    self.tooltip.Visible = false
end

function Library:_makeDraggable(handle)
    handle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        self.drag = { start = input.Position, origin = self.window.Position }

        local connection
        connection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                self.drag = nil
                connection:Disconnect()
            end
        end)
    end)
end

-- one slider / color drag at a time, fed by the window's single input connections
function Library:_beginDrag(update)
    self.activeDrag = update
end

function Library:_bindInput()
    self:_connect(UserInputService.InputBegan, function(input)
        if self.unloaded then
            return
        end

        -- clicking anywhere while a key chip waits for a key cancels it, so the next key you press to
        -- walk or build doesn't get bound by accident; pickers that allow left click take it as the key
        if self.listening and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local picker = self.listening
            self.listening = nil
            if picker._info.AllowMouse1 then
                picker:SetValue({ "MB1", picker.Mode })
            else
                picker._render()
            end
            return
        end

        local key = keyName(input)
        if not key then
            return
        end

        -- binding a key: escape / backspace clears it
        if self.listening then
            local picker = self.listening
            self.listening = nil
            if key == "Escape" or key == "Backspace" then
                key = "None"
            end
            picker:SetValue({ key, picker.Mode })
            return
        end

        if UserInputService:GetFocusedTextBox() then
            return
        end

        for _, picker in self.keyPickers do
            if picker.Value == key then
                picker:_press()
            end
        end
    end)

    self:_connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.activeDrag = nil
        end

        local key = keyName(input)
        if not key or self.unloaded then
            return
        end
        for _, picker in self.keyPickers do
            if picker.Value == key then
                picker:_release()
            end
        end
    end)

    self:_connect(UserInputService.InputChanged, function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        if self.activeDrag then
            self.activeDrag(pointerPosition(input))
        elseif self.drag then
            local delta = input.Position - self.drag.start
            local origin = self.drag.origin
            self.window.Position = UDim2.new(
                origin.X.Scale,
                origin.X.Offset + delta.X,
                origin.Y.Scale,
                origin.Y.Offset + delta.Y
            )
        end
    end)

    local frames, elapsed, nextRefresh = 0, 0, 0
    self:_connect(RunService.RenderStepped, function(deltaTime)
        if self.tooltip.Visible then
            local mouse = UserInputService:GetMouseLocation()
            self.tooltip.Position = UDim2.fromOffset(mouse.X + 16, mouse.Y + 14)
        end

        frames =frames+ 1
        elapsed =elapsed+ deltaTime
        if not self.visible then
            return
        end

        self.coronaGradient.Rotation = (self.coronaGradient.Rotation + deltaTime * 40) % 360

        local now = os.clock()
        if now >= nextRefresh then
            nextRefresh = now + HEADER_REFRESH
            local fps = (elapsed > 0 and{(math.round(frames / elapsed) )}or{0
})[1]            frames, elapsed = 0, 0
            local ping = math.round(LocalPlayer:GetNetworkPing() * 1000)
            self.telemetry.Text = string.format([[FPS <font color="%s">%s</font>   PING <font color="%s">%sms</font>]], tostring(theme.hex(colors.text)), tostring(fps), tostring(theme.hex(colors.text)), tostring(ping))        
end
    end)
end

function Library:SetVisible(visible)
    if self.unloaded then
        return
    end
    self.visible = visible
    self.window.Visible = visible
    if visible then
        self.shownAt = os.clock()
    end
    if not visible then
        self:HideTooltip()
        self:_closePopup()
    else
        self.scale.Scale = self.baseScale * 0.97
        tween(self.scale, 0.16, { Scale = self.baseScale })
    end
    for _, callback in self.visibilityCallbacks do
        safeCall(callback, visible)
    end
end

function Library:Toggle()
    self:SetVisible(not self.visible)
end

function Library:OnVisibilityChanged(callback)
    table.insert(self.visibilityCallbacks, callback)
end

function Library:Notify(message, duration, kind)
    if self.unloaded then
        return
    end
    local barColor = (kind == "error" and{(colors.danger )}or{((kind == "warn" and{(colors.corona )}or{(colors.accent
)})[1])})[1]
    local card = create("Frame", {
        Size = UDim2.fromOffset(300, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = colors.panel,
        ZIndex = 90,
        Parent = self.notifications,
    }, { corner(8), theme.padding(16, 12, 10, 10) })
    local cardStroke = stroke(colors.strokeBright)
    cardStroke.Parent = card
    local bar = create("Frame", {
        Position = UDim2.fromOffset(-16, -10),
        Size = UDim2.new(0, 2, 1, 20),
        BackgroundColor3 = barColor,
        BorderSizePixel = 0,
        ZIndex = 91,
        Parent = card,
    })
    local title = text({
        Size = UDim2.new(1, 0, 0, 12),
        Text = self.title .. " // " .. (kind == "error" and"ERROR" or"NOTICE"),
        Font = fonts.mono,
        TextSize = 10,
        TextColor3 = barColor,
        ZIndex = 91,
        Parent = card,
    })
    local body = text({
        Position = UDim2.fromOffset(0, 16),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Text = message,
        TextWrapped = true,
        TextTruncate = Enum.TextTruncate.None,
        TextColor3 = colors.text,
        ZIndex = 91,
        Parent = card,
    })

    task.delay(duration or 4, function()
        local fade = 0.4
        tween(card, fade, { BackgroundTransparency = 1 })
        tween(cardStroke, fade, { Transparency = 1 })
        tween(bar, fade, { BackgroundTransparency = 1 })
        tween(title, fade, { TextTransparency = 1 })
        tween(body, fade, { TextTransparency = 1 })
        task.wait(fade)
        card:Destroy()
    end)
end

function Library:Unload()
    self.unloaded = true
    self.keyPickers = {}
    for _, connection in self.connections do
        connection:Disconnect()
    end
    self.gui:Destroy()
end

-- tabs

function Library:AddTab(name)
    local index = #self.tabs + 1
    local tab = setmetatable({
        window = self,
        name = name,
        index = index,
        selectedCallbacks = {},
    }, Tab)

    local button = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = colors.raised,
        BackgroundTransparency = 1,
        AutoButtonColor = false,
        Text = "",
        LayoutOrder = index,
        Parent = self.nav,
    }, { corner(6) })
    tab.button = button
    tab.bar = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(2, 16),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = button,
    }, { theme.accentGradient(90) })
    tab.number = text({
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(0, 22, 1, 0),
        Text = string.format("%02d", index),
        Font = fonts.mono,
        TextSize = 11,
        TextColor3 = colors.faint,
        Parent = button,
    })
    tab.label = text({
        Position = UDim2.fromOffset(40, 0),
        Size = UDim2.new(1, -44, 1, 0),
        Text = name,
        Font = fonts.medium,
        TextColor3 = colors.muted,
        Parent = button,
    })

    button.MouseEnter:Connect(function()
        if self.currentTab ~= tab then
            tween(button, 0.1, { BackgroundTransparency = 0.6 })
        end
    end)
    button.MouseLeave:Connect(function()
        if self.currentTab ~= tab then
            tween(button, 0.1, { BackgroundTransparency = 1 })
        end
    end)
    button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    table.insert(self.tabs, tab)
    if not self.currentTab then
        self:SelectTab(tab)
    end
    return tab
end

-- a padded scrolling page with two columns; built the first time a groupbox is added
function Tab:_columns()
    if self.left then
        return
    end

    local page = create("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = colors.strokeBright,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = self.window.currentTab == self,
        Parent = self.window.body,
    })
    self.page = page

    -- the columns sit in a container inset by the page padding, so their half widths are halves of the
    -- space they actually have (padding on a scrolling frame doesn't shrink what scale is measured from)
    local container = create("Frame", {
        Position = UDim2.fromOffset(PAGE_PADDING, 18),
        Size = UDim2.new(1, -PAGE_PADDING * 2, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = page,
    }, { theme.padding(0, 0, 0, 24) })
local column=function(
position)        
return create("Frame", {
            Position = position,
            Size = UDim2.new(0.5, -COLUMN_GAP / 2, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = container,
        }, {
            create("UIListLayout", { Padding = UDim.new(0, COLUMN_GAP), SortOrder = Enum.SortOrder.LayoutOrder }),
        })
end    
self.left = column(UDim2.new())
    self.right = column(UDim2.new(0.5, COLUMN_GAP / 2, 0, 0))
end

-- a page the caller fills itself (the match board); builder gets the padded frame
function Tab:AddPage(builder)
    local page = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = self.window.currentTab == self,
        Parent = self.window.body,
    }, { theme.padding(PAGE_PADDING, PAGE_PADDING, 16, 20) })
    self.page = page
    builder(page)
    return page
end

function Tab:OnSelected(callback)
    table.insert(self.selectedCallbacks, callback)
end

function Tab:AddLeftGroupbox(name)
    self:_columns()
    return Groupbox.new(self.window, self.left, name)
end

function Tab:AddRightGroupbox(name)
    self:_columns()
    return Groupbox.new(self.window, self.right, name)
end

-- highlights the current tab's button in the sidebar
function Library:_paintNav()
    for _, other in self.tabs do
        local active = other == self.currentTab
        tween(other.button, 0.12, { BackgroundTransparency = active and 0 or 1 })
        tween(other.bar, 0.12, { BackgroundTransparency = active and 0 or 1 })
        other.label.TextColor3 = (active and{(colors.text )}or{(colors.muted
)})[1]        other.number.TextColor3 = (active and{(colors.accent )}or{(colors.faint
)})[1]    end
end

function Library:SelectTab(tab)
    local previous = self.currentTab
    self.currentTab = tab
    self:_closePopup()

    for _, other in self.tabs do
        local active = other == tab
        if other.page then
            other.page.Visible = active
            -- the new page eases up into place
            if active and previous ~= tab then
                other.page.Position = UDim2.fromOffset(0, 8)
                tween(other.page, 0.18, { Position = UDim2.new() })
            end
        end
    end
    self:_paintNav()

    self.pageTitle.Text = tab.name
    self.pageSubtitle.Text = string.format("// %02d  %s", tab.index, string.upper(tab.name))

    if previous ~= tab then
        if previous then
            for _, callback in previous.selectedCallbacks do
                safeCall(callback, false)
            end
        end
        for _, callback in tab.selectedCallbacks do
            safeCall(callback, true)
        end
    end
end

-- groupboxes

function Groupbox.new(window, column, name)
    local self = setmetatable({ window = window, order = 0 }, Groupbox)

    local frame = create("Frame", {
        Size = UDim2.fromScale(1, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = colors.panel,
        LayoutOrder = #column:GetChildren(),
        Parent = column,
    }, { corner(8), stroke() })
    theme.surface(frame, 0.7)

    create("Frame", {
        Position = UDim2.fromOffset(16, 15),
        Size = UDim2.fromOffset(3, 10),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = frame,
    }, { theme.accentGradient(90) })
    text({
        Position = UDim2.fromOffset(27, 12),
        Size = UDim2.new(1, -40, 0, 16),
        Text = string.upper(name),
        Font = fonts.mono,
        TextSize = 11,
        TextColor3 = colors.textDim,
        Parent = frame,
    })
    create("Frame", {
        Position = UDim2.fromOffset(0, 39),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = colors.stroke,
        BorderSizePixel = 0,
        Parent = frame,
    })

    self.content = create("Frame", {
        Position = UDim2.fromOffset(0, 40),
        Size = UDim2.fromScale(1, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = frame,
    }, {
        theme.padding(16, 16, 12, 16),
        create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
    })

    return self
end

function Groupbox:_next()
    self.order =self.order+ 1
    return self.order
end

-- holder for color swatches / key chips at the right of a row; the row's label makes room for it
function Groupbox:_attachments(row, label, rightInset)
    local holder = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -rightInset, 0.5, 0),
        Size = UDim2.fromScale(0, 1),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Parent = row,
    }, {
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    local window = self.window
    holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        local width = holder.AbsoluteSize.X / math.max(window.scale.Scale, 0.01)
        label.Size = UDim2.new(1, -(rightInset + width + 8), label.Size.Y.Scale, label.Size.Y.Offset)
    end)
    return holder
end

-- adds AddColorPicker / AddKeyPicker to a row object, chaining back to it like obsidian does
function Groupbox:_attachable(object, holder, toggle)
    local groupbox = self
    object._holder = holder
    function object:AddColorPicker(index, info)
        groupbox:_colorPicker(holder, index, info)
        return object
    end
    function object:AddKeyPicker(index, info)
        groupbox.window:_newKeyPicker(holder, index, info, toggle)
        return object
    end
end

function Groupbox:AddCheckbox(index, info)
    info = info or {}
    local window = self.window

    local row = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        AutoButtonColor = false,
        Text = "",
        LayoutOrder = self:_next(),
        Parent = self.content,
    })
    local label = text({
        Size = UDim2.new(1, -44, 1, 0),
        Text = info.Text or index,
        TextColor3 = colors.textDim,
        Parent = row,
    })

    local switch = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(32, 16),
        BackgroundColor3 = colors.field,
        Parent = row,
    }, { corner(), stroke(colors.strokeBright) })
    local fill = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
        Parent = switch,
    }, { corner(), theme.accentGradient(0) })
    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.fromOffset(12, 12),
        BackgroundColor3 = colors.muted,
        Parent = switch,
    }, { corner() })

    local toggle = newValue(window, window.Toggles, index, info, info.Default == true)
    toggle.Type = "Toggle"
    toggle._render = function()
        local on = toggle.Value
        tween(fill, 0.12, { BackgroundTransparency = on and 0 or 1 })
        tween(knob, 0.12, {
            Position = (on and{(UDim2.new(1, -14, 0.5, 0) )}or{(UDim2.new(0, 2, 0.5, 0))})[1],
            BackgroundColor3 = (on and{(Color3.new(1, 1, 1) )}or{(colors.muted)})[1],
        })
        label.TextColor3 = (on and{(colors.text )}or{(colors.textDim
)})[1]    end
    toggle._render()

    function toggle:SetValue(value)
        value = value and true or false
        if value ~= self.Value then
            self:_set(value)
        end
    end

    row.MouseButton1Click:Connect(function()
        toggle:SetValue(not toggle.Value)
    end)
    window:_tooltipOn(row, info.Tooltip)

    self:_attachable(toggle, self:_attachments(row, label, 40), toggle)
    return toggle
end

Groupbox.AddToggle = Groupbox.AddCheckbox

function Groupbox:AddSlider(index, info)
    local window = self.window
    local min, max = info.Min or 0, info.Max or 100
    local decimals = info.Rounding or 0

    local holder = create("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
        LayoutOrder = self:_next(),
        Parent = self.content,
    })
    text({
        Size = UDim2.new(1, -70, 0, 16),
        Text = info.Text or index,
        TextColor3 = colors.textDim,
        Parent = holder,
    })
    local valueLabel = theme.bind(text({
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.fromOffset(70, 16),
        Font = fonts.mono,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = holder,
    }), "TextColor3", "accent")

    -- inset by the knob's radius so the knob never hangs past the groupbox edge
    local track = create("Frame", {
        Position = UDim2.fromOffset(6, 30),
        Size = UDim2.new(1, -12, 0, 4),
        BackgroundColor3 = colors.field,
        Parent = holder,
    }, { corner(2) })
    local fill = create("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = track,
    }, { corner(2), theme.accentGradient(0) })
    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromOffset(12, 12),
        BackgroundColor3 = Color3.new(1, 1, 1),
        ZIndex = 2,
        Parent = track,
    }, { corner() })
    theme.bind(stroke(colors.accent, 2), "Color", "accent").Parent = knob
    local hitbox = create("TextButton", {
        Position = UDim2.fromOffset(0, 20),
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        Text = "",
        Parent = holder,
    })

    local slider = newValue(window, window.Options, index, info, math.clamp(info.Default or min, min, max))
    slider.Type = "Slider"
    slider.Min, slider.Max, slider.Rounding = min, max, decimals
    slider._render = function()
        local alpha = (max > min and{((slider.Value - min) / (max - min) )}or{0
})[1]        fill.Size = UDim2.fromScale(alpha, 1)
        knob.Position = UDim2.fromScale(alpha, 0.5)
        valueLabel.Text = string.format(string.format('%%.%sf', tostring(decimals)), slider.Value) .. (info.Suffix or "")
    end
    slider._render()

    function slider:SetValue(value)
        value = round(math.clamp(tonumber(value) or min, min, max), decimals)
        if value ~= self.Value then
            self:_set(value)
        end
    end
local setFromX=function(
x)        
local alpha = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        slider:SetValue(min + (max - min) * alpha)
end
    
hitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            setFromX(pointerPosition(input).X)
            window:_beginDrag(function(position)
                setFromX(position.X)
            end)
        end
    end)
    window:_tooltipOn(hitbox, info.Tooltip)

    return slider
end

function Groupbox:AddDropdown(index, info)
    local window = self.window
    local multi = info.Multi == true

    local holder = create("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundTransparency = 1,
        LayoutOrder = self:_next(),
        Parent = self.content,
    })
    local labelRow = create("Frame", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Parent = holder,
    })
    local label = text({
        Size = UDim2.fromScale(1, 1),
        Text = info.Text or index,
        TextColor3 = colors.textDim,
        Parent = labelRow,
    })
    local box = create("TextButton", {
        Position = UDim2.fromOffset(0, 22),
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = colors.field,
        AutoButtonColor = false,
        Text = "",
        Parent = holder,
    }, { corner(6) })
    theme.surface(box, 0.5)
    local boxStroke = stroke()
    boxStroke.Parent = box
    box.MouseEnter:Connect(function()
        boxStroke.Color = colors.strokeBright
    end)
    box.MouseLeave:Connect(function()
        boxStroke.Color = colors.stroke
    end)
    local valueText = text({
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -40, 1, 0),
        TextColor3 = colors.text,
        Parent = box,
    })
    theme.chevron({
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Parent = box,
    })

    local values = info.Values or {}
    local default
    if multi then
        default = {}
        for _, value in ((typeof(info.Default) == "table" and{(info.Default )}or{{}})[1]) do
            default[value] = true
        end
    else
        default = info.Default
        if typeof(default) == "number" and values[default] ~= nil and not table.find(values, default) then
            default = values[default]
        end
    end

    local dropdown = newValue(window, window.Options, index, info, default)
    dropdown.Type = "Dropdown"
    dropdown.Multi = multi
    dropdown.Values = values
local display=function(
value)        
if info.FormatDisplayValue then
            local ok, formatted = pcall(info.FormatDisplayValue, value)
            if ok and formatted then
                return tostring(formatted)
            end
        end
        return tostring(value)
end    
dropdown._display = display

    dropdown._render = function()
        local shown
        if multi then
            local names = {}
            for _, value in dropdown.Values do
                if dropdown.Value[value] then
                    table.insert(names, display(value))
                end
            end
            shown = (#names > 0 and{(table.concat(names, ", ") )}or{nil
})[1]        elseif dropdown.Value ~= nil then
            shown = display(dropdown.Value)
        end
        valueText.Text = shown or "None"
        valueText.TextColor3 = (shown and{(colors.text )}or{(colors.muted
)})[1]    end
    dropdown._render()

    function dropdown:SetValue(value)
        if multi then
            local set = {}
            if typeof(value) == "table" then
                for key, selected in value do
                    if typeof(key) == "number" and typeof(selected) ~= "boolean" then
                        set[selected] = true -- a list of names
                    elseif selected then
                        set[key] = true
                    end
                end
            end
            self:_set(set)
        elseif value ~= self.Value then
            self:_set(value)
        end
    end

    function dropdown:SetValues(newValues)
        self.Values = newValues or {}
        self._render()
        if window.popup and window.popup.owner == self then
            window:_closePopup()
        end
    end

    box.MouseButton1Click:Connect(function()
        window:_openDropdown(dropdown, box)
    end)
    window:_tooltipOn(box, info.Tooltip)

    self:_attachable(dropdown, self:_attachments(labelRow, label, 0))
    return dropdown
end

function Groupbox:AddButton(textOrInfo, callback)
    local info = (typeof(textOrInfo) == "table" and{textOrInfo }or{{ Text = textOrInfo, Func = callback }
})[1]    local window = self.window

    local button = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = colors.field,
        AutoButtonColor = false,
        Text = info.Text,
        Font = fonts.medium,
        TextSize = 13,
        TextColor3 = colors.text,
        LayoutOrder = self:_next(),
        Parent = self.content,
    }, { corner(6) })
    theme.surface(button, 0.5)
    local outline = stroke(colors.strokeBright)
    outline.Parent = button

    button.MouseEnter:Connect(function()
        tween(outline, 0.1, { Color = colors.accent })
        tween(button, 0.1, { BackgroundColor3 = colors.raised })
    end)
    button.MouseLeave:Connect(function()
        tween(outline, 0.1, { Color = colors.strokeBright })
        tween(button, 0.1, { BackgroundColor3 = colors.field })
    end)
    -- DoubleClick buttons ask for a second click within CONFIRM_TIME before they run
    local armedUntil = 0
    button.MouseButton1Click:Connect(function()
        -- the click that focuses the game right after the window appears isn't meant for a button
        if os.clock() - window.shownAt < CLICK_GRACE then
            return
        end

        if info.DoubleClick and os.clock() > armedUntil then
            armedUntil = os.clock() + CONFIRM_TIME
            button.Text = "Click again to confirm"
            button.TextColor3 = colors.corona
            task.delay(CONFIRM_TIME, function()
                if os.clock() >= armedUntil then
                    button.Text = info.Text
                    button.TextColor3 = colors.text
                end
            end)
            return
        end
        armedUntil = 0
        button.Text = info.Text
        button.TextColor3 = colors.text

        button.BackgroundColor3 = colors.hover
        tween(button, 0.25, { BackgroundColor3 = colors.raised })
        local func = info.Func or info.Callback
        if func then
            task.spawn(safeCall, func)
        end
    end)
    window:_tooltipOn(button, info.Tooltip)

    return button
end

-- a text field; Finished = true only takes the text when the field loses focus
function Groupbox:AddInput(index, info)
    local window = self.window

    local holder = create("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundTransparency = 1,
        LayoutOrder = self:_next(),
        Parent = self.content,
    })
    text({
        Size = UDim2.new(1, 0, 0, 16),
        Text = info.Text or index,
        TextColor3 = colors.textDim,
        Parent = holder,
    })
    local box = create("TextBox", {
        Position = UDim2.fromOffset(0, 22),
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = colors.field,
        Text = info.Default or "",
        PlaceholderText = info.Placeholder or "",
        PlaceholderColor3 = colors.faint,
        Font = fonts.body,
        TextSize = 13,
        TextColor3 = colors.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = holder,
    }, { corner(6), theme.padding(12, 12, 0, 0) })
    theme.surface(box, 0.5)
    local boxStroke = stroke()
    boxStroke.Parent = box
    box.Focused:Connect(function()
        boxStroke.Color = colors.accent
    end)

    local input = newValue(window, window.Options, index, info, info.Default or "")
    input.Type = "Input"
    input._render = function()
        if box.Text ~= input.Value then
            box.Text = input.Value
        end
    end

    function input:SetValue(value)
        value = tostring(value or "")
        if value ~= self.Value then
            self:_set(value)
        end
    end

    if not info.Finished then
        box:GetPropertyChangedSignal("Text"):Connect(function()
            input:SetValue(box.Text)
        end)
    end
    box.FocusLost:Connect(function()
        boxStroke.Color = colors.stroke
        input:SetValue(box.Text)
    end)
    window:_tooltipOn(box, info.Tooltip)

    return input
end

function Groupbox:AddLabel(content)
    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        LayoutOrder = self:_next(),
        Parent = self.content,
    })
    local label = text({
        Size = UDim2.fromScale(1, 1),
        Text = content or "",
        RichText = true,
        TextColor3 = colors.textDim,
        Parent = row,
    })

    local object = {}
    function object:SetText(newText)
        label.Text = newText
    end
    self:_attachable(object, self:_attachments(row, label, 0))
    return object
end

function Groupbox:AddDivider()
    create("Frame", {
        Size = UDim2.new(1, 0, 0, 9),
        BackgroundTransparency = 1,
        LayoutOrder = self:_next(),
        Parent = self.content,
    }, {
        create("Frame", {
            Position = UDim2.fromOffset(0, 4),
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = colors.stroke,
            BorderSizePixel = 0,
        }),
    })
end

-- color pickers

function Groupbox:_colorPicker(holder, index, info)
    local window = self.window
    local swatch = create("TextButton", {
        Size = UDim2.fromOffset(26, 14),
        BackgroundColor3 = info.Default or Color3.new(1, 1, 1),
        AutoButtonColor = false,
        Text = "",
        LayoutOrder = #holder:GetChildren(),
        Parent = holder,
    }, { corner(4), stroke(colors.strokeBright) })

    local picker = newValue(window, window.Options, index, info, info.Default or Color3.new(1, 1, 1))
    picker.Type = "ColorPicker"
    picker.Title = info.Title or index
    picker.Transparency = info.Transparency or 0
    picker._render = function()
        swatch.BackgroundColor3 = picker.Value
    end

    function picker:SetValueRGB(color, transparency)
        if transparency then
            self.Transparency = transparency
        end
        self:_set(color)
    end
    function picker:SetValue(color)
        if typeof(color) == "Color3" then
            self:_set(color)
        end
    end

    swatch.MouseButton1Click:Connect(function()
        window:_openColorPicker(picker, swatch)
    end)
    window:_tooltipOn(swatch, picker.Title)
    return picker
end

-- key pickers (also used outside groupboxes for the menu key)

function Library:_newKeyPicker(holder, index, info, toggle)
    local window = self
    -- info.Callback is the key's action (run from _press / _release), so a rebind or a config load must
    -- never call it; obsidian's ChangedCallback is the one that hears about a new key
    local picker = newValue(window, window.Options, index, info, info.Default or "None", info.ChangedCallback or false)
    picker.Type = "KeyPicker"
    picker.Mode = info.Mode or "Toggle"
    picker.Toggled = false
    picker.SyncToggleState = info.SyncToggleState == true

    picker._render = function()
        local chip = picker.chip
        if not chip then
            return
        end
        local listening = window.listening == picker
        chip.Text = listening and"..." or string.upper(picker.Value)
        chip.TextColor3 = (listening and{(colors.accent )}or{((picker.Value == "None" and{(colors.faint )}or{(colors.textDim
)})[1])})[1]        picker._chipStroke.Color = (listening and{(colors.accent )}or{(colors.strokeBright
)})[1]    end

    -- { key, mode } like obsidian, or just a key name
    function picker:SetValue(value)
        local key, mode = value, nil
        if typeof(value) == "table" then
            key, mode = value[1], value[2]
        end
        if mode and table.find(KEY_MODES, mode) then
            self.Mode = mode
        end
        self:_set(key or "None")
    end

    function picker:GetState()
        return self.Toggled
    end

    function picker:_press()
        if self.Mode == "Hold" then
            self.Toggled = true
            if toggle and self.SyncToggleState then
                toggle:SetValue(true)
            end
            if info.Callback then
                safeCall(info.Callback, true)
            end
        elseif self.Mode == "Toggle" then
            self.Toggled = not self.Toggled
            if toggle and self.SyncToggleState then
                toggle:SetValue(not toggle.Value)
            end
            if info.Callback then
                safeCall(info.Callback, self.Toggled)
            end
        else
            if info.Callback then
                safeCall(info.Callback)
            end
        end
    end

    function picker:_release()
        if self.Mode == "Hold" and self.Toggled then
            self.Toggled = false
            if toggle and self.SyncToggleState then
                toggle:SetValue(false)
            end
            if info.Callback then
                safeCall(info.Callback, false)
            end
        end
    end

    if holder and not info.NoUI then
        window:_keyChip(holder, picker)
    end

    table.insert(window.keyPickers, picker)
    return picker
end

-- the clickable chip showing a picker's key: click to bind, right click to cycle its mode
function Library:_keyChip(holder, picker)
    local chip = create("TextButton", {
        Size = UDim2.fromOffset(0, 18),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = colors.field,
        AutoButtonColor = false,
        Font = fonts.mono,
        TextSize = 11,
        TextColor3 = colors.textDim,
        LayoutOrder = 100,
        Parent = holder,
    }, { corner(4), theme.padding(7, 7, 0, 0) })
    picker.chip = chip
    picker._chipStroke = stroke(colors.strokeBright)
    picker._chipStroke.Parent = chip
    picker._render()

    local name = picker._info.Text or "Key"
    chip.MouseButton1Click:Connect(function()
        -- start listening a frame later so this click isn't taken as the key
        task.defer(function()
            self.listening = picker
            picker._render()
        end)
    end)
    chip.MouseButton2Click:Connect(function()
        picker.Mode = KEY_MODES[(table.find(KEY_MODES, picker.Mode) or 0) % #KEY_MODES + 1]
        self:ShowTooltip(string.format('%s: <b>%s</b> mode', tostring(name), tostring(picker.Mode)))
    end)
    chip.MouseEnter:Connect(function()
        self:ShowTooltip(string.format('%s  <font color="%s">click to bind \u{b7} esc clears \u{b7} right click: mode (%s)</font>', tostring(name), tostring(theme.hex(colors.muted)), tostring(picker.Mode)))
    end)
    chip.MouseLeave:Connect(function()
        self:HideTooltip()
    end)
    return chip
end

-- popups

function Library:_closePopup()
    if self.popup then
        self.popup.frame:Destroy()
        self.popup.catcher:Destroy()
        self.popup = nil
    end
end

-- frame position for a popup under `anchor`, in the window's unscaled space
function Library:_popupPosition(anchor, width, height)
    local scale = math.max(self.scale.Scale, 0.01)
    local relative = (anchor.AbsolutePosition - self.window.AbsolutePosition) / scale
    local anchorHeight = anchor.AbsoluteSize.Y / scale
    local x = math.clamp(relative.X, 8, self.size.X - width - 8)
    local y = relative.Y + anchorHeight + 4
    if y + height > self.size.Y - 8 then
        y = math.max(8, relative.Y - height - 4)
    end
    return UDim2.fromOffset(x, y)
end

function Library:_openPopup(owner, width, height, anchor)
    self:_closePopup()

    -- clicking anywhere else closes it
    local catcher = create("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 50,
        Parent = self.overlay,
    })
    catcher.MouseButton1Click:Connect(function()
        self:_closePopup()
    end)

    local frame = create("Frame", {
        Position = self:_popupPosition(anchor, width, height),
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = colors.panel,
        ZIndex = 51,
        Parent = self.overlay,
    }, { corner(8), stroke(colors.strokeBright) })

    self.popup = { owner = owner, frame = frame, catcher = catcher }
    return frame
end

function Library:_openDropdown(dropdown, box)
    if self.popup and self.popup.owner == dropdown then
        self:_closePopup()
        return
    end

    local values = dropdown.Values
    local searchable = #values > 8
    local rowHeight = 26
    local listHeight = math.min(#values, 8) * rowHeight + 8
    local width = math.max(box.AbsoluteSize.X / math.max(self.scale.Scale, 0.01), 160)
    local height = listHeight + (searchable and 36 or 0)
    if #values == 0 then
        height = 40
    end

    local frame = self:_openPopup(dropdown, width, height, box)

    local search
    if searchable then
        search = create("TextBox", {
            Position = UDim2.fromOffset(6, 6),
            Size = UDim2.new(1, -12, 0, 26),
            BackgroundColor3 = colors.field,
            PlaceholderText = "search...",
            PlaceholderColor3 = colors.faint,
            Text = "",
            Font = fonts.mono,
            TextSize = 12,
            TextColor3 = colors.text,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
            ZIndex = 52,
            Parent = frame,
        }, { corner(5), theme.padding(8, 8, 0, 0) })
    end

    local list = create("ScrollingFrame", {
        Position = UDim2.fromOffset(4, searchable and 36 or 4),
        Size = UDim2.new(1, -8, 1, -(searchable and 40 or 8)),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = colors.strokeBright,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 52,
        Parent = frame,
    }, {
        create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
    })

    if #values == 0 then
        text({
            Size = UDim2.new(1, 0, 0, 30),
            Text = "nothing to pick yet",
            Font = fonts.mono,
            TextSize = 11,
            TextColor3 = colors.faint,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 53,
            Parent = list,
        })
        return
    end

    local rows = {}
local isSelected=function(value)        
if dropdown.Multi then
            return dropdown.Value[value] == true
        end
        return dropdown.Value == value
end local paint=function(

row, value)        
local selected = isSelected(value)
        row.label.TextColor3 = (selected and{(colors.accent )}or{(colors.textDim
)})[1]        row.mark.BackgroundTransparency = selected and 0 or 1
end
    -- "None" row so a single pick can be cleared
    
local entries = table.clone(values)
    local allowNone = not dropdown.Multi and dropdown._info.AllowNull ~= false

    for order, value in entries do
        local button = create("TextButton", {
            Size = UDim2.new(1, 0, 0, rowHeight),
            BackgroundColor3 = colors.hover,
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Text = "",
            LayoutOrder = order,
            ZIndex = 53,
            Parent = list,
        }, { corner(4) })
        local mark = create("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 8, 0.5, 0),
            Size = UDim2.fromOffset(4, 4),
            BackgroundColor3 = colors.accent,
            BackgroundTransparency = 1,
            ZIndex = 54,
            Parent = button,
        }, { corner() })
        local label = text({
            Position = UDim2.fromOffset(20, 0),
            Size = UDim2.new(1, -24, 1, 0),
            Text = dropdown._display(value),
            ZIndex = 54,
            Parent = button,
        })
        local row = { button = button, label = label, mark = mark, value = value }
        rows[order] = row
        paint(row, value)

        button.MouseEnter:Connect(function()
            button.BackgroundTransparency = 0.4
        end)
        button.MouseLeave:Connect(function()
            button.BackgroundTransparency = 1
        end)
        button.MouseButton1Click:Connect(function()
            if dropdown.Multi then
                local set = table.clone(dropdown.Value)
                set[value] = (set[value] and{nil }or{true
})[1]                dropdown:SetValue(set)
                for _, other in rows do
                    paint(other, other.value)
                end
            else
                if allowNone and dropdown.Value == value then
                    dropdown:SetValue(nil)
                else
                    dropdown:SetValue(value)
                end
                self:_closePopup()
            end
        end)
    end

    if search then
        search:GetPropertyChangedSignal("Text"):Connect(function()
            local query = string.lower(search.Text)
            for _, row in rows do
                row.button.Visible = query == "" or string.find(string.lower(row.label.Text), query, 1, true) ~= nil
            end
        end)
        search:CaptureFocus()
    end
end

local HUE_SEQUENCE = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
    ColorSequenceKeypoint.new(1 / 6, Color3.fromHSV(1 / 6, 1, 1)),
    ColorSequenceKeypoint.new(2 / 6, Color3.fromHSV(2 / 6, 1, 1)),
    ColorSequenceKeypoint.new(3 / 6, Color3.fromHSV(3 / 6, 1, 1)),
    ColorSequenceKeypoint.new(4 / 6, Color3.fromHSV(4 / 6, 1, 1)),
    ColorSequenceKeypoint.new(5 / 6, Color3.fromHSV(5 / 6, 1, 1)),
    ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
})

function Library:_openColorPicker(picker, swatch)
    if self.popup and self.popup.owner == picker then
        self:_closePopup()
        return
    end

    local frame = self:_openPopup(picker, 232, 222, swatch)
    local hue, saturation, brightness = picker.Value:ToHSV()

    text({
        Position = UDim2.fromOffset(12, 8),
        Size = UDim2.new(1, -24, 0, 14),
        Text = string.upper(picker.Title),
        Font = fonts.mono,
        TextSize = 10,
        TextColor3 = colors.muted,
        ZIndex = 52,
        Parent = frame,
    })

    local square = create("TextButton", {
        Position = UDim2.fromOffset(12, 28),
        Size = UDim2.fromOffset(170, 150),
        BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
        AutoButtonColor = false,
        Text = "",
        ZIndex = 52,
        Parent = frame,
    }, { corner(4) })
    create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        ZIndex = 53,
        Parent = square,
    }, {
        corner(4),
        create("UIGradient", { Transparency = NumberSequence.new(0, 1) }),
    })
    create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        ZIndex = 54,
        Parent = square,
    }, {
        corner(4),
        create("UIGradient", { Transparency = NumberSequence.new(1, 0), Rotation = 90 }),
    })
    local cursor = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(10, 10),
        BackgroundTransparency = 1,
        ZIndex = 55,
        Parent = square,
    }, { corner(), stroke(Color3.new(1, 1, 1), 2) })

    local hueBar = create("TextButton", {
        Position = UDim2.fromOffset(194, 28),
        Size = UDim2.fromOffset(14, 150),
        BackgroundColor3 = Color3.new(1, 1, 1),
        AutoButtonColor = false,
        Text = "",
        ZIndex = 52,
        Parent = frame,
    }, { corner(4), create("UIGradient", { Color = HUE_SEQUENCE, Rotation = 90 }) })
    local hueCursor = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, 4, 0, 3),
        BackgroundColor3 = Color3.new(1, 1, 1),
        ZIndex = 53,
        Parent = hueBar,
    }, { corner(1) })

    local hexBox = create("TextBox", {
        Position = UDim2.fromOffset(12, 188),
        Size = UDim2.fromOffset(120, 24),
        BackgroundColor3 = colors.field,
        Font = fonts.mono,
        TextSize = 12,
        TextColor3 = colors.text,
        ClearTextOnFocus = false,
        ZIndex = 52,
        Parent = frame,
    }, { corner(5), stroke() })
    local preview = create("Frame", {
        Position = UDim2.fromOffset(140, 188),
        Size = UDim2.fromOffset(68, 24),
        ZIndex = 52,
        Parent = frame,
    }, { corner(5), stroke(colors.strokeBright) })
local render=function()        

local color = Color3.fromHSV(hue, saturation, brightness)
        square.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        cursor.Position = UDim2.fromScale(saturation, 1 - brightness)
        hueCursor.Position = UDim2.fromScale(0.5, hue)
        preview.BackgroundColor3 = color
        if not hexBox:IsFocused() then
            hexBox.Text = "#" .. color:ToHex()
        end
        return color
end local commit=function()        


picker:SetValueRGB(render())
end    
render()
local dragSquare=function(
position)        -- input positions are Vector3s, so take X / Y rather than subtracting the Vector2 position
        
local origin, size = square.AbsolutePosition, square.AbsoluteSize
        saturation = math.clamp((position.X - origin.X) / size.X, 0, 1)
        brightness = 1 - math.clamp((position.Y - origin.Y) / size.Y, 0, 1)
        commit()
end local dragHue=function(
position)        
hue = math.clamp((position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 0.999)
        commit()
end local dragArea=function(



target, onDrag)        
local hit = create("TextButton", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 60,
            Parent = target,
        })
        hit.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                onDrag(pointerPosition(input))
                self:_beginDrag(onDrag)
            end
        end)
end    
dragArea(square, dragSquare)
    dragArea(hueBar, dragHue)
    hexBox.FocusLost:Connect(function()
        local ok, color = pcall(Color3.fromHex, (string.gsub(hexBox.Text, "#", "")))
        if ok and color then
            hue, saturation, brightness = color:ToHSV()
            commit()
        else
            render()
        end
    end)
end

-- configs: named sets of settings in eclx/configs/<userId>/<name>.json, made and loaded from Settings.
-- nothing saves on its own; one config can be picked to load when the script starts (autoload.txt)

local AUTOLOAD_FILE = "autoload.txt"
local cleanName=function(

name)    
name = string.gsub(tostring(name or ""), "[^%w%s%-_]", "")
    name = string.gsub(name, "^%s+", "")
    name = string.gsub(name, "%s+$", "")
    return name
end local canUseFiles=function()    


return writefile and readfile and isfile and isfolder and makefolder and listfiles
end

function Library:_configFolder()
    return string.format('%s/%s', tostring(CONFIG_FOLDER), tostring(LocalPlayer.UserId))
end

function Library:_configPath(name)
    return string.format('%s/%s.json', tostring(self:_configFolder()), tostring(name))
end

function Library:_ensureConfigFolder()
    for _, folder in { "eclx", CONFIG_FOLDER, self:_configFolder() } do
        if not isfolder(folder) then
            makefolder(folder)
        end
    end

    -- the single file older versions saved to on every change becomes a config named "previous"
    local legacy = string.format('%s/%s.json', tostring(CONFIG_FOLDER), tostring(LocalPlayer.UserId))    
if isfile(legacy) and not isfile(self:_configPath("previous")) then
        writefile(self:_configPath("previous"), readfile(legacy))
        if delfile then
            delfile(legacy)
        end
    end
end

function Library:_serialize()
    local data = { toggles = {}, options = {} }

    for index, toggle in self.Toggles do
        if not (self.configIgnore[index] or toggle._info.NoSave) then
            data.toggles[index] = toggle.Value
        end
    end

    for index, option in self.Options do
        if self.configIgnore[index] or option._info.NoSave then
            continue
        end
        if option.Type == "Slider" or option.Type == "Input" then
            data.options[index] = option.Value
        elseif option.Type == "Dropdown" then
            if option.Multi then
                local list = {}
                for value, selected in option.Value do
                    if selected then
                        table.insert(list, value)
                    end
                end
                data.options[index] = { multi = list }
            else
                data.options[index] = { value = option.Value }
            end
        elseif option.Type == "ColorPicker" then
            data.options[index] = { color = option.Value:ToHex(), transparency = option.Transparency }
        elseif option.Type == "KeyPicker" then
            data.options[index] = { key = option.Value, mode = option.Mode }
        elseif option.Type == "Hidden" then
            data.options[index] = { raw = option.Value }
        end
    end

    return data
end

function Library:_apply(data)
    for index, value in data.toggles or {} do
        local toggle = self.Toggles[index]
        if toggle and not (self.configIgnore[index] or toggle._info.NoSave) then
            toggle:SetValue(value)
        end
    end
    for index, saved in data.options or {} do
        local option = self.Options[index]
        if not option or self.configIgnore[index] or option._info.NoSave then
            continue
        end
        if option.Type == "Slider" or option.Type == "Input" then
            option:SetValue(saved)
        elseif option.Type == "Dropdown" and typeof(saved) == "table" then
            if option.Multi then
                option:SetValue(saved.multi or {})
            else
                option:SetValue(saved.value)
            end
        elseif option.Type == "ColorPicker" and typeof(saved) == "table" then
            local valid, color = pcall(Color3.fromHex, saved.color or "")
            if valid then
                option:SetValueRGB(color, saved.transparency)
            end
        elseif option.Type == "KeyPicker" and typeof(saved) == "table" then
            option:SetValue({ saved.key, saved.mode })
        elseif option.Type == "Hidden" and typeof(saved) == "table" then
            option:SetValue(saved.raw)
        end
    end
end

-- config names, sorted
function Library:ListConfigs()
    if not (self.configEnabled and canUseFiles()) then
        return {}
    end
    local ok, names = pcall(function()
        self:_ensureConfigFolder()
        local list = {}
        for _, path in listfiles(self:_configFolder()) do
            local name = string.match(path, "([^/\\]+)%.json$")
            if name then
                table.insert(list, name)
            end
        end
        table.sort(list, function(a, b)
            return string.lower(a) < string.lower(b)
        end)
        return list
    end)
    return (ok and{names }or{{}
})[1]end

-- returns true, or false and why not
function Library:SaveConfig(name)
    name = cleanName(name)
    if name == "" then
        return false, "give the config a name first"
    end
    if not (self.configEnabled and canUseFiles()) then
        return false, "this executor can't write files"
    end
    local ok, err = pcall(function()
        self:_ensureConfigFolder()
        writefile(self:_configPath(name), HttpService:JSONEncode(self:_serialize()))
    end)
    return ok, err
end

function Library:LoadConfig(name)
    name = cleanName(name)
    if not (self.configEnabled and canUseFiles()) then
        return false, "this executor can't read files"
    end
    if name == "" or not isfile(self:_configPath(name)) then
        return false, string.format('no config called "%s"', tostring(name))    
end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(self:_configPath(name)))
    end)
    if not ok or typeof(data) ~= "table" then
        return false, "that config file is damaged"
    end

    self:_apply(data)
    return true
end

function Library:DeleteConfig(name)
    name = cleanName(name)
    if name == "" or not (canUseFiles() and delfile and isfile(self:_configPath(name))) then
        return false, "pick a config to delete"
    end
    delfile(self:_configPath(name))
    if self:GetAutoload() == name then
        self:SetAutoload(nil)
    end
    return true
end

function Library:GetAutoload()
    if not (self.configEnabled and canUseFiles()) then
        return nil
    end
    local path = string.format('%s/%s', tostring(self:_configFolder()), tostring(AUTOLOAD_FILE))    
local ok, name = pcall(function()
        return (isfile(path) and{(cleanName(readfile(path)) )}or{nil
})[1]    end)
    return (ok and name ~= "" and{name }or{nil
})[1]end

-- nil clears it, so the script starts on defaults
function Library:SetAutoload(name)
    if not (self.configEnabled and canUseFiles()) then
        return false
    end
    self:_ensureConfigFolder()
    local path = string.format('%s/%s', tostring(self:_configFolder()), tostring(AUTOLOAD_FILE))    
if name then
        writefile(path, cleanName(name))
    elseif isfile(path) and delfile then
        delfile(path)
    end
    return true
end

-- loads the autoload config if one is set and still exists; returns its name
function Library:LoadAutoload()
    local name = self:GetAutoload()
    if name and self:LoadConfig(name) then
        return name
    end
    return nil
end

function Library:ResetConfig()
    for _, toggle in self.Toggles do
        if not toggle._info.NoSave then
            toggle:SetValue(toggle.Default)
        end
    end
    for _, option in self.Options do
        if option._info.NoSave then
            continue
        end
        if option.Type == "KeyPicker" then
            option:SetValue({ option.Default, option._info.Mode or "Toggle" })
        elseif option.Type == "ColorPicker" then
            option:SetValueRGB(option.Default)
        elseif option.Type == "Dropdown" and option.Multi then
            option:SetValue(option.Default or {})
        elseif option.Type == "Dropdown" or option.Type == "Slider" or option.Type == "Hidden" or option.Type == "Input" then
            option:SetValue(option.Default)
        end
    end
end

-- the obsidian style config manager in Settings
function Library:_addConfigManager(groupbox)
    local muted = theme.hex(colors.muted)
    local accent = theme.hex(colors.accent)

    local nameInput = groupbox:AddInput("Config/Name", {
        Text = "Config name",
        Placeholder = "e.g. comp, sandbox...",
        NoSave = true,
    })
    groupbox:AddButton({
        Text = "Create config",
        Func = function()
            local name = cleanName(nameInput.Value)
            if name ~= "" and table.find(self:ListConfigs(), name) then
                self:Notify(string.format('"%s" already exists. Pick it below and use Overwrite', tostring(name)), 4, "warn")
                return
            end
            local ok, err = self:SaveConfig(name)
            if ok then
                nameInput:SetValue("")
                self:_refreshConfigs(name)
                self:Notify(string.format('Created config "%s"', tostring(name)))
            else
                self:Notify(string.format("Couldn't create it: %s", tostring(err)), 4, "error")
            end
        end,
    })

    groupbox:AddDivider()

    local list = groupbox:AddDropdown("Config/List", {
        Text = "Configs",
        Values = self:ListConfigs(),
        NoSave = true,
    })
    self.configList = list

    groupbox:AddButton({
        Text = "Load config",
        Func = function()
            local ok, err = self:LoadConfig(list.Value)
            self:Notify((ok and{(string.format('Loaded "%s"', tostring(list.Value)))}or{(string.format("Couldn't load: %s", tostring(err)))})[1], 4, (ok and{nil }or{"error"})[1])
        end,
    })
    groupbox:AddButton({
        Text = "Overwrite config",
        Tooltip = "Saves your current settings into the picked config",
        DoubleClick = true,
        Func = function()
            if not list.Value then
                self:Notify("Pick a config to overwrite", 4, "warn")
                return
            end
            local ok, err = self:SaveConfig(list.Value)
            self:Notify((ok and{(string.format('Saved to "%s"', tostring(list.Value)))}or{(string.format("Couldn't save: %s", tostring(err)))})[1], 4, (ok and{nil }or{"error"})[1])
        end,
    })
    groupbox:AddButton({
        Text = "Delete config",
        DoubleClick = true,
        Func = function()
            local name = list.Value
            local ok, err = self:DeleteConfig(name)
            if ok then
                self:_refreshConfigs()
                self:Notify(string.format('Deleted "%s"', tostring(name)))
            else
                self:Notify(err, 4, "warn")
            end
        end,
    })
    groupbox:AddButton({
        Text = "Refresh list",
        Func = function()
            self:_refreshConfigs(list.Value)
        end,
    })

    groupbox:AddDivider()

    local autoloadLabel = groupbox:AddLabel("")
local showAutoload=function()        
local name = self:GetAutoload()
        autoloadLabel:SetText((name
and{(string.format([[<font color="%s">loads on start:</font> <font color="%s">%s</font>]], tostring(muted), tostring(accent), tostring(name)))}or{(string.format('<font color="%s">loads on start: defaults</font>', tostring(
muted)))})[1])
end    
self.showAutoload = showAutoload
    showAutoload()

    groupbox:AddButton({
        Text = "Set as default",
        Tooltip = "The picked config loads every time the script starts",
        Func = function()
            if not list.Value then
                self:Notify("Pick a config first", 4, "warn")
                return
            end
            self:SetAutoload(list.Value)
            showAutoload()
            self:Notify(string.format('"%s" now loads when the script starts', tostring(list.Value)))
        end,
    })
    groupbox:AddButton({
        Text = "Clear default",
        Tooltip = "Start on default settings",
        Func = function()
            self:SetAutoload(nil)
            showAutoload()
            self:Notify("The script now starts on default settings")
        end,
    })
    groupbox:AddButton({
        Text = "Reset settings to defaults",
        Tooltip = "Doesn't touch your saved configs",
        DoubleClick = true,
        Func = function()
            self:ResetConfig()
            self:Notify("Settings reset to defaults")
        end,
    })
end

-- reloads the config dropdown, keeping `select` picked if it's there
function Library:_refreshConfigs(select)
    if not self.configList then
        return
    end
    local names = self:ListConfigs()
    self.configList:SetValues(names)
    self.configList:SetValue((select and table.find(names, select) and{select }or{nil})[1])
    if self.showAutoload then
        self.showAutoload()
    end
end

-- accent preset, custom accent colors and window transparency
function Library:_addAppearance(groupbox)
    local presetNames, presetsByName = {}, {}
    for _, preset in theme.presets do
        table.insert(presetNames, preset.name)
        presetsByName[preset.name] = preset
    end
    table.insert(presetNames, "Custom")

    local applyingPreset = false
    local accentPicker, deepPicker

    local themeDropdown = groupbox:AddDropdown("UI/Theme", {
        Text = "Theme",
        Values = presetNames,
        Default = theme.presets[1].name,
        AllowNull = false,
        Callback = function(name)
            local preset = presetsByName[name]
            if preset then
                -- show the preset's colors in the pickers without it counting as a custom pick
                applyingPreset = true
                accentPicker:SetValueRGB(preset.accent)
                deepPicker:SetValueRGB(preset.deep)
                applyingPreset = false
                theme.setAccent(preset.accent, preset.deep)
            elseif accentPicker then
                theme.setAccent(accentPicker.Value, deepPicker.Value)
            end
        end,
    })
local onCustomColor=function()        

if applyingPreset or not (accentPicker and deepPicker) then
            return
        end
        -- picking the colors a preset already has keeps that preset selected
        local selected = presetsByName[themeDropdown.Value]
        if selected and selected.accent == accentPicker.Value and selected.deep == deepPicker.Value then
            return
        end
        if themeDropdown.Value ~= "Custom" then
            themeDropdown:SetValue("Custom")
        else
            theme.setAccent(accentPicker.Value, deepPicker.Value)
        end
end
    
local colorsRow = groupbox:AddLabel("Custom colors")
    colorsRow:AddColorPicker("UI/AccentColor", {
        Title = "Accent",
        Default = theme.presets[1].accent,
        Callback = onCustomColor,
    })
    colorsRow:AddColorPicker("UI/AccentDeepColor", {
        Title = "Accent (deep)",
        Default = theme.presets[1].deep,
        Callback = onCustomColor,
    })
    accentPicker = self.Options["UI/AccentColor"]
    deepPicker = self.Options["UI/AccentDeepColor"]

    groupbox:AddSlider("UI/Transparency", {
        Text = "Window transparency",
        Default = 0,
        Min = 0,
        Max = 0.85,
        Rounding = 2,
        Callback = function(value)
            theme.setTransparency(value)
        end,
    })
end

-- the settings tab every window gets at the end: menu key, saving, unload
function Library:AddSettingsTab()
    local tab = self:AddTab("Settings")

    local interface = tab:AddLeftGroupbox("Interface")
    self:_keyChip(interface:AddLabel("Menu key")._holder, self.menuKey)
    interface:AddSlider("UI/Scale", {
        Text = "UI scale",
        Default = 1,
        Min = 0.7,
        Max = 1.3,
        Rounding = 2,
        Suffix = "x",
        Callback = function(value)
            self:SetUserScale(value)
        end,
    })
    interface:AddLabel(string.format([[<font color="%s">drag the bottom right corner to resize</font>]], tostring(theme.hex(colors.muted))))
    interface:AddButton({
        Text = "Reset window size",
        Func = function()
            self:SetSize(DEFAULT_SIZE)
            self.window.Position = UDim2.fromScale(0.5, 0.5)
        end,
    })

    interface:AddButton({
        Text = "Unload EclX",
        DoubleClick = true,
        Tooltip = "Removes the window. Features stay as they are set until you rejoin",
        Func = function()
            self:Notify("Unloaded. Rejoin to load EclX again")
            task.wait(0.1)
            self:Unload()
        end,
    })

    self:_addAppearance(tab:AddLeftGroupbox("Appearance"))

    self:_addConfigManager(tab:AddRightGroupbox("Configs"))

    self.settingsTab = tab
    return tab
end

return Library
end function dote.c()local v=dote.cache.c if not v then v={c=__modImpl()}dote.cache.c=v end return v.c end end do local __modImpl=function()-- by amedote
-- nccam function taken from Infinite Yield FE by Edge
-- https://infyiff.github.io/Download.html


local sc = (debug and debug.setconstant) or setconstant
local gc = (debug and debug.getconstants) or getconstants
if not sc or not getgc or not gc then
	-- executor can't edit constants, hand back a no-op so the keybind doesn't error
	return function() end
end
local pop = game.Players.LocalPlayer.PlayerScripts.PlayerModule.CameraModule.ZoomController.Popper
-- scanning getgc is slow, so find the popper's functions once and reuse them
local popperFunctions
local getPopperFunctions=function()    
if not popperFunctions then
        popperFunctions = {}
        for _, v in pairs(getgc()) do
            if type(v) == 'function' and getfenv(v).script == pop then
                table.insert(popperFunctions, v)
            end
        end
    end
    return popperFunctions
end local Toggle=function()    


for _, v in getPopperFunctions() do
        for i, v1 in pairs(gc(v)) do
            if tonumber(v1) == .25 then
                sc(v, i, 0)
            elseif tonumber(v1) == 0 then
                sc(v, i, .25)
            end
        end
    end
end

return Toggle
end function dote.d()local v=dote.cache.d if not v then v={c=__modImpl()}dote.cache.d=v end return v.c end end do local __modImpl=function()-- every structure the portafab can build, read from the templates in ReplicatedStorage.Server.Structures
-- (the same folder the portafab builds its menu from): names for pickers, iridium cost for the stats.
-- every template carries its price in a Cost attribute


local ReplicatedStorage = game:GetService("ReplicatedStorage")

local catalog
local load=function()    

if catalog then
        return catalog
    end

    catalog = { names = {}, costs = {} }

    local server = ReplicatedStorage:WaitForChild("Server", 10)
    local folder = server and server:WaitForChild("Structures", 10)
    if not folder then
        warn("[eclx] structure templates not found, costs and quick build lists will be empty")
        return catalog
    end

    local function walk(parent)
        for _, child in parent:GetChildren() do
            if child:IsA("Model") then
                if catalog.costs[child.Name] == nil then
                    table.insert(catalog.names, child.Name)
                end
                local cost = child:GetAttribute("Cost")
                catalog.costs[child.Name] = (typeof(cost) == "number" and{cost }or{0
})[1]            elseif child:IsA("Folder") then
                walk(child)
            end
        end
    end
    walk(folder)

    table.sort(catalog.names)
    return catalog
end local getNames=function()    



return load().names
end local costOf=function(


name)    
return load().costs[name] or 0
end

return {
    getNames = getNames,
    costOf = costOf,
}
end function dote.e()local v=dote.cache.e if not v then v={c=__modImpl()}dote.cache.e=v end return v.c end end do local __modImpl=function()-- match stat tracker: counts what every player does over a game, read only from what replicates to us,
-- so other players are tracked the same way we are and nothing gets hooked.
--   structures  every child of workspace.Structures, credited to its Builder attribute
--   iridium     what those structures cost to place, from the structure templates
--   ls / os     a laser strike / orbital shield tool torn down while its owner is alive (firing one does that)
--   arty        an ArtilleryShell part showing up in workspace, credited to whoever sits in the closest
--               manned artillery
--   bores       a bore turning to a new target (or a *target* attribute changing), credited to the closest
--               teammate since you have to be at the bore to aim it
--   kills       a leaderstats kill stat when the game has one; otherwise the killer tag on the humanoid,
--               and failing that an enemy laser strike used in range just before the death
--   deaths      every humanoid death


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local structures = dote.e()

local ORBITAL_TOOLS = {
    ["Laser Strike"] = "ls",
    ["Orbital Shield"] = "os",
}

local STAT_KEYS = { "structures", "iridium", "kills", "deaths", "ls", "os", "arty", "bores" }

-- how long after an orbital tool disappears to check it was really used (not cleared by a death/respawn)
local TOOL_USE_CONFIRM = 0.3

-- a death is put on an enemy laser strike used this recently, within its range (+ slack) of where they stood
local LS_KILL_WINDOW = 4
local LS_RANGE = 125
local LS_KILL_SLACK = 15

-- names games tag a humanoid's killer with, as a child value or an attribute
local KILLER_TAGS = { "creator", "Creator", "Killer", "KilledBy", "LastDamager", "LastAttacker", "LastHit", "Attacker" }

-- leaderstats entries that hold kills, matched lowercase
local KILL_STAT_NAMES = { kills = true, kos = true, ko = true, eliminations = true, elims = true }

-- artillery shots
local ARTY_POLL = 0.1
local SHELL_NAME = "ArtilleryShell" -- every shot drops one of these straight into workspace at the barrel
local SHOT_RANGE = 12 -- studs past the barrel's own size the shell may first appear (seen at ~6 from center)
local OCCUPANT_LINGER = 1 -- a shot right as the gunner hops off still counts for them

-- bore aims
local BORE_POLL = 0.25
local BORE_AIM_ANGLE = math.rad(3)
local BORE_STILL_ANGLE = math.rad(0.5)
local BORE_STILL_TICKS = 2
local BORE_AIM_DEDUPE = 1.5
local BORE_WARMUP = 3 -- a freshly placed / streamed in bore settling isn't an aim
local BORE_CREDIT_RANGE = 60

local Tracker = {}
Tracker.__index = Tracker

-- options.excludeTeams: team names whose players are left out of getRecords (the match viewer drops
-- Spectators); leave it out to list everyone
function Tracker.new(options)
    options = options or {}
    return setmetatable({
        excludeTeams = options.excludeTeams or {},
        -- onEvent callbacks, told about kills, deaths and orbital uses as they happen
        listeners = {},
        startedAt = os.clock(),
        -- bumped on every change so the window only redraws when something happened
        version = 0,
        -- userId (or builder name for players we never saw) -> record
        records = {},
        -- player name -> record, structures name their builder
        byName = {},
        -- recent laser strike uses { at, record, position, team }, oldest first
        lsUses = {},
        -- structures already counted, only used when streaming can hand us the same structure twice
        seenStructures = {},
        watchedTools = setmetatable({}, { __mode = "k" }),
        artys = {},
        anyArtyManned = false,
        bores = {},
        structureFolder = nil,
    }, Tracker)
end
local newRecord=function()    

local record = {
        userId = nil,
        name = "",
        displayName = "",
        teamName = nil,
        teamColor = nil,
        left = false,
        killsFromStat = false,
        -- structure name -> count
        structureTypes = {},
    }
    for _, key in STAT_KEYS do
        record[key] = 0
    end
    return record
end

function Tracker:_changed()
    self.version =self.version+ 1
end

function Tracker:_bump(record, key)
    record[key]=record[key]+ 1
    self:_changed()
end

function Tracker:_record(player)
    local record = self.records[player.UserId]
    if record then
        return record
    end

    -- a builder we only knew by name (left before we started) came back: keep what they had
    record = self.byName[player.Name]
    if record and record.userId == nil then
        self.records[player.Name] = nil
    else
        record = newRecord()
    end

    record.userId = player.UserId
    record.name = player.Name
    record.displayName = player.DisplayName
    self.records[player.UserId] = record
    self.byName[player.Name] = record
    self:_changed()
    return record
end

-- a record for a builder name that isn't in the server (no avatar, shown as left)
function Tracker:_recordForName(name)
    local record = self.byName[name]
    if record then
        return record
    end

    local player = Players:FindFirstChild(name)
    if player and player:IsA("Player") then
        return self:_record(player)
    end

    record = newRecord()
    record.name = name
    record.displayName = name
    record.left = true
    self.records[name] = record
    self.byName[name] = record
    self:_changed()
    return record
end

function Tracker:getRecords()
    local list = {}
    for _, record in self.records do
        if not (record.teamName and self.excludeTeams[record.teamName]) then
            table.insert(list, record)
        end
    end
    return list
end

-- callback(event) for each kill, death and laser strike / orbital shield use:
--   { kind = "kill", killer = record, victim = record, weapon = "Laser Strike" | nil }
--   { kind = "death", victim = record }
--   { kind = "ls" | "os", record = record }
function Tracker:onEvent(callback)
    table.insert(self.listeners, callback)
end

function Tracker:_emit(event)
    for _, callback in self.listeners do
        task.spawn(callback, event)
    end
end

function Tracker:getElapsed()
    return os.clock() - self.startedAt
end
local isAlive=function(
player, character)    
if player.Parent == nil or player.Character ~= character or not character then
        return false
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid ~= nil and humanoid.Health > 0
end local getRootPosition=function(

character)    
local root = character and character:FindFirstChild("HumanoidRootPart")
    return root and root.Position
end
-- players


function Tracker:_watchTool(player, record, tool, stat)
    if self.watchedTools[tool] then
        return
    end
    self.watchedTools[tool] = true

    local holder = tool.Parent

    -- AncestryChanged fires for the tool's ancestors too; only the tool itself losing its parent matters
    tool.AncestryChanged:Connect(function()
        if tool.Parent then
            holder = tool.Parent
            return
        end

        local lastHolder = holder
        local character = player.Character
        local position = getRootPosition(character)
        local usedAt = os.clock()

        task.delay(TOOL_USE_CONFIRM, function()
            -- moved back somewhere, so it was only shuffled around
            if tool.Parent then
                return
            end

            -- deaths and respawns clear tools too: the owner has to still be alive in the same character,
            -- and the tool has to have left the live backpack or that character
            if not isAlive(player, character) then
                return
            end
            if lastHolder:IsA("Backpack") then
                if lastHolder.Parent ~= player then
                    return
                end
            elseif lastHolder ~= character then
                return
            end

            self:_bump(record, stat)
            self:_emit({ kind = stat, record = record })

            if stat == "ls" and position then
                local lsUses = self.lsUses
                table.insert(lsUses, { at = usedAt, record = record, position = position, team = player.Team })
                while lsUses[1] and usedAt - lsUses[1].at > LS_KILL_WINDOW * 2 do
                    table.remove(lsUses, 1)
                end
            end
        end)
    end)
end

function Tracker:_watchToolHolder(player, record, holder)
local onChild=function(child)        
local stat = child:IsA("Tool") and ORBITAL_TOOLS[child.Name]
        if stat then
            self:_watchTool(player, record, child, stat)
        end
end
    
for _, child in holder:GetChildren() do
        onChild(child)
    end
    holder.ChildAdded:Connect(onChild)
end

-- the record a killer tag points at: a player, their character, their name or their user id
function Tracker:_recordFromTag(value)
    if typeof(value) == "Instance" and value:IsA("ObjectValue") then
        value = value.Value
    elseif typeof(value) == "Instance" and value:IsA("ValueBase") then
        value = value.Value
    end

    local valueType = typeof(value)
    if valueType == "Instance" then
        local player = (value:IsA("Player")
and{value
}or{((value:IsA("Model") and{(Players:GetPlayerFromCharacter(value)
)}or{nil
})[1])})[1]        return player and self:_record(player)
    elseif valueType == "string" and value ~= "" then
        return self.byName[value]
    elseif valueType == "number" then
        return self.records[value]
    end

    return nil
end

function Tracker:_findTaggedKiller(humanoid, character)
    for _, tag in KILLER_TAGS do
        local record = self:_recordFromTag(humanoid:FindFirstChild(tag))
            or self:_recordFromTag(humanoid:GetAttribute(tag))
            or self:_recordFromTag(character:GetAttribute(tag))
        if record then
            return record
        end
    end
    return nil
end

-- the most recent enemy laser strike that could have reached where the victim died
function Tracker:_findLsKiller(victim, victimTeam, position, diedAt)
    local lsUses = self.lsUses
    for i = #lsUses, 1, -1 do
        local use = lsUses[i]
        local age = diedAt - use.at
        if
            age >= -0.1
            and age <= LS_KILL_WINDOW
            and use.record ~= victim
            and (use.team == nil or use.team ~= victimTeam)
            and (use.position - position).Magnitude <= LS_RANGE + LS_KILL_SLACK
        then
            return use.record
        end
    end
    return nil
end

function Tracker:_creditKill(killer, victim)
    if killer and killer ~= victim and not killer.killsFromStat then
        self:_bump(killer, "kills")
    end
end

function Tracker:_onDeath(player, record, character, humanoid)
    self:_bump(record, "deaths")

    local killer = self:_findTaggedKiller(humanoid, character)
    if killer then
        self:_creditKill(killer, record)
        self:_emitDeath(killer, record, nil)
        return
    end

    local position = getRootPosition(character)
    if not position then
        self:_emitDeath(nil, record, nil)
        return
    end

    -- the strike that killed them may still be waiting on its use check, so look once that's had time
    local diedAt = os.clock()
    local team = player.Team
    task.delay(TOOL_USE_CONFIRM + 0.1, function()
        local lsKiller = self:_findLsKiller(record, team, position, diedAt)
        self:_creditKill(lsKiller, record)
        self:_emitDeath(lsKiller, record, lsKiller and "Laser Strike")
    end)
end

function Tracker:_emitDeath(killer, victim, weapon)
    if killer and killer ~= victim then
        self:_emit({ kind = "kill", killer = killer, victim = victim, weapon = weapon })
    else
        self:_emit({ kind = "death", victim = victim })
    end
end

function Tracker:_watchCharacter(player, record, character)
    self:_watchToolHolder(player, record, character)

    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 10)
    if not humanoid then
        return
    end

    humanoid.Died:Connect(function()
        self:_onDeath(player, record, character, humanoid)
    end)
end

function Tracker:_watchLeaderstats(record, leaderstats)
local onStat=function(stat)        
if not (stat:IsA("ValueBase") and KILL_STAT_NAMES[string.lower(stat.Name)]) then
            return
        end
local sync=function()            

if typeof(stat.Value) == "number" then
                record.killsFromStat = true
                record.kills = stat.Value
                self:_changed()
            end
end
        
sync()
        stat.Changed:Connect(sync)
end
    
for _, stat in leaderstats:GetChildren() do
        onStat(stat)
    end
    leaderstats.ChildAdded:Connect(onStat)
end

function Tracker:_watchPlayer(player)
    local record = self:_record(player)
    record.left = false
local syncTeam=function()        

local team = player.Team
        record.teamName = team and team.Name
        record.teamColor = team and team.TeamColor.Color
        self:_changed()
end    
syncTeam()
    player:GetPropertyChangedSignal("Team"):Connect(syncTeam)
local onCharacter=function(
character)        
self:_watchCharacter(player, record, character)
end    
if player.Character then
        task.spawn(onCharacter, player.Character)
    end
    player.CharacterAdded:Connect(onCharacter)
local onChild=function(

child)        
if child:IsA("Backpack") then
            self:_watchToolHolder(player, record, child)
        elseif child.Name == "leaderstats" then
            self:_watchLeaderstats(record, child)
        end
end    
for _, child in player:GetChildren() do
        onChild(child)
    end
    player.ChildAdded:Connect(onChild)
end
local structureKey=function(


structure, builder)    
local ok, pivot = pcall(structure.GetPivot, structure)
    if not ok then
        return structure
    end
    local position = pivot.Position
    return string.format('%s|%s|%s|%s|%s', tostring(structure.Name), tostring(builder), tostring(math.round(position.X)), tostring(math.round(position.Y)), tostring(math.round(position.Z)))end


function Tracker:_onStructure(structure)
    local builder = structure:GetAttribute("Builder")
    if typeof(builder) ~= "string" or builder == "" then
        return
    end

    -- with streaming on, a structure leaving and coming back into range is added again; placed structures
    -- don't move, so the same name, builder and spot means it's one we've counted
    if self.dedupeStructures then
        local key = structureKey(structure, builder)
        if self.seenStructures[key] then
            return
        end
        self.seenStructures[key] = true
    end

    local record = self:_recordForName(builder)
    local types = record.structureTypes
    types[structure.Name] = (types[structure.Name] or 0) + 1
    record.iridium =record.iridium+ structures.costOf(structure.Name)
    self:_bump(record, "structures")
end
local findSeat=function(


model)    
for _, descendant in model:GetDescendants() do
        if descendant:IsA("Seat") or descendant:IsA("VehicleSeat") then
            return descendant
        end
    end
    return nil
end local findBarrel=function(

model)    
local tilt = model:FindFirstChild("TiltAssembly")
    return tilt and tilt:FindFirstChild("Barrel")
end

function Tracker:_updateArtys(now)
    local anyManned = false

    for model, entry in self.artys do
        -- seat and barrel can stream in after the model, so look again at most once a second
        if not (entry.seat and entry.seat.Parent and entry.barrel and entry.barrel.Parent) and now >= entry.nextSearch then
            entry.nextSearch = now + 1
            entry.seat = findSeat(model)
            entry.barrel = findBarrel(model)
        end

        local seat = entry.seat
        local occupant = seat and seat.Parent and seat.Occupant
        local player = occupant and Players:GetPlayerFromCharacter(occupant.Parent)
        if player then
            entry.occupant = player
            entry.occupiedAt = now
        end

        if entry.occupant and now - entry.occupiedAt <= OCCUPANT_LINGER then
            anyManned = true
        end
    end

    self.anyArtyManned = anyManned
end

-- a shell is put on the manned artillery whose barrel it spawned closest to
function Tracker:_onShell(shell)
    if not shell.Parent then
        return
    end

    local now = os.clock()
    local position = shell.Position
    local best, bestDistance = nil, math.huge

    for _, entry in self.artys do
        local barrel = entry.barrel
        if entry.occupant and barrel and barrel.Parent and now - entry.occupiedAt <= OCCUPANT_LINGER then
            local distance = (position - barrel.Position).Magnitude
            if distance <= barrel.Size.Magnitude / 2 + SHOT_RANGE and distance < bestDistance then
                best, bestDistance = entry, distance
            end
        end
    end

    if best then
        self:_bump(self:_record(best.occupant), "arty")
    end
end
local firstPart=function(


instance)    
if not instance then
        return nil
    end
    if instance:IsA("BasePart") then
        return instance
    end
    return instance:FindFirstChildWhichIsA("BasePart", true)
end local findBorePart=function(


model)    
local tilt = model:FindFirstChild("TiltAssembly")
    return tilt and (firstPart(tilt:FindFirstChild("FakeBarrel", true)) or firstPart(tilt))
end local rotationBetween=function(

a, b)local
_, angle =(a:Inverse() * b):ToAxisAngle()
    return math.abs(angle)
end
-- whoever aimed it: the closest teammate in range, or the builder when nobody is near

function Tracker:_boreAimer(model)
    local team = model:GetAttribute("Team")
    local ok, pivot = pcall(model.GetPivot, model)

    if ok then
        local best, bestDistance = nil, BORE_CREDIT_RANGE
        for _, player in Players:GetPlayers() do
            if team ~= nil and player.TeamColor ~= team then
                continue
            end

            local position = getRootPosition(player.Character)
            local distance = position and (position - pivot.Position).Magnitude
            if distance and distance < bestDistance then
                best, bestDistance = player, distance
            end
        end

        if best then
            return self:_record(best)
        end
    end

    local builder = model:GetAttribute("Builder")
    return typeof(builder) == "string" and builder ~= "" and self:_recordForName(builder) or nil
end

function Tracker:_onBoreAim(entry, now)
    if now - entry.trackedAt < BORE_WARMUP or now - entry.lastAim < BORE_AIM_DEDUPE then
        return
    end
    entry.lastAim = now

    local record = self:_boreAimer(entry.model)
    if record then
        self:_bump(record, "bores")
    end
end

function Tracker:_trackBore(model)
    local entry = {
        model = model,
        part = nil,
        nextSearch = 0,
        -- rotation the turret last came to rest at, and last poll's
        settled = nil,
        last = nil,
        stillTicks = 0,
        trackedAt = os.clock(),
        lastAim = -math.huge,
    }
    self.bores[model] = entry

    model.AttributeChanged:Connect(function(name)
        if string.find(string.lower(name), "target", 1, true) then
            self:_onBoreAim(entry, os.clock())
        end
    end)
end

function Tracker:_updateBores(now)
    for model, entry in self.bores do
        local part = entry.part
        if not (part and part.Parent) then
            if now < entry.nextSearch then
                continue
            end
            entry.nextSearch = now + 1
            part = findBorePart(model)
            entry.part = part
            entry.settled = nil
            if not part then
                continue
            end
        end

        local rotation = part.CFrame.Rotation
        if not entry.settled or now - entry.trackedAt < BORE_WARMUP then
            entry.settled = rotation
            entry.last = rotation
            continue
        end

        local step = rotationBetween(entry.last, rotation)
        entry.last = rotation

        if step > BORE_STILL_ANGLE then
            entry.stillTicks = 0
            continue
        end

        -- came to rest somewhere new: that's an aim
        entry.stillTicks =entry.stillTicks+ 1
        if entry.stillTicks >= BORE_STILL_TICKS and rotationBetween(entry.settled, rotation) >= BORE_AIM_ANGLE then
            entry.settled = rotation
            self:_onBoreAim(entry, now)
        end
    end
end

function Tracker:start()
    local Structures = workspace:WaitForChild("Structures")
    self.structureFolder = Structures
    self.dedupeStructures = workspace.StreamingEnabled

    for _, player in Players:GetPlayers() do
        self:_watchPlayer(player)
    end
    Players.PlayerAdded:Connect(function(player)
        self:_watchPlayer(player)
    end)
    Players.PlayerRemoving:Connect(function(player)
        local record = self.records[player.UserId]
        if record then
            record.left = true
            self:_changed()
        end
    end)
local onStructureAdded=function(
child)        
self:_onStructure(child)

        if child.Name == "Artillery" then
            self.artys[child] = {
                seat = nil,
                barrel = nil,
                nextSearch = 0,
                occupant = nil,
                occupiedAt = -math.huge,
            }
        elseif child.Name == "Bore" then
            self:_trackBore(child)
        end
end
    
for _, child in Structures:GetChildren() do
        onStructureAdded(child)
    end
    Structures.ChildAdded:Connect(onStructureAdded)
    Structures.ChildRemoved:Connect(function(child)
        self.artys[child] = nil
        self.bores[child] = nil
    end)

    -- deferred so a shell parented before it's moved is in place by the time we look
    workspace.ChildAdded:Connect(function(child)
        if self.anyArtyManned and child.Name == SHELL_NAME and child:IsA("BasePart") then
            task.defer(self._onShell, self, child)
        end
    end)

    local nextArty, nextBore = 0, 0
    RunService.Heartbeat:Connect(function()
        local now = os.clock()
        if now >= nextArty then
            nextArty = now + ARTY_POLL
            self:_updateArtys(now)
        end
        if now >= nextBore then
            nextBore = now + BORE_POLL
            self:_updateBores(now)
        end
    end)
end

Tracker.STAT_KEYS = STAT_KEYS

return Tracker
end function dote.f()local v=dote.cache.f if not v then v={c=__modImpl()}dote.cache.f=v end return v.c end end do local __modImpl=function()-- writes the match stats to eclx/match_<date>_<time>.json in the executor's workspace folder.
-- the "schema" field names the layout so the eclx site can read old and new exports apart


local HttpService = game:GetService("HttpService")

local structures = dote.e()

local FOLDER = "eclx"
local SCHEMA = "eclx.match/2"
local exportMatch=function(

tracker, scoreOf, weights)    
if not (writefile and makefolder and isfolder) then
        return nil, "this executor can't write files"
    end

    local players = {}
    for _, record in tracker:getRecords() do
        local stats = {}
        for _, key in tracker.STAT_KEYS do
            stats[key] = record[key]
        end

        -- per structure type: how many and the iridium they came to
        local built = {}
        for name, count in record.structureTypes do
            built[name] = { count = count, iridium = count * structures.costOf(name) }
        end

        table.insert(players, {
            userId = record.userId,
            name = record.name,
            displayName = record.displayName,
            team = record.teamName,
            teamColor = record.teamColor and string.format('#%s', tostring(record.teamColor:ToHex())),
            left = record.left,
            score = scoreOf(record),
            stats = stats,
            structuresBuilt = built,
        })
    end

    table.sort(players, function(a, b)
        return a.score > b.score
    end)
    for rank, player in players do
        player.rank = rank
    end

    local now = os.time()
    local data = {
        schema = SCHEMA,
        client = "EclX",
        exportedAt = os.date("!%Y-%m-%dT%H:%M:%SZ", now),
        placeId = game.PlaceId,
        jobId = game.JobId,
        trackedSeconds = math.floor(tracker:getElapsed()),
        weights = weights,
        players = players,
    }

    local ok, json = pcall(HttpService.JSONEncode, HttpService, data)
    if not ok then
        return nil, json
    end

    if not isfolder(FOLDER) then
        makefolder(FOLDER)
    end

    local path = string.format('%s/match_%s.json', tostring(FOLDER), tostring(os.date("%Y-%m-%d_%H-%M-%S", now)))    
local written, err = pcall(writefile, path, json)
    if not written then
        return nil, err
    end

    return path
end

return exportMatch
end function dote.g()local v=dote.cache.g if not v then v={c=__modImpl()}dote.cache.g=v end return v.c end end do local __modImpl=function()-- the match board: one row per player with their avatar, what they did over the game and a score that
-- weighs it all, so at the end you can see who carried. click a player for everything they built.
-- it fills a page of an EclX window (the hub's Match tab, or the standalone stats window).
-- usage: StatsBoard.new(tracker, weights, page, window, isShown)


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local theme = dote.b()
local structures = dote.e()
local exportMatch = dote.g()

local colors = theme.colors
local fonts = theme.fonts
local create = theme.create
local corner = theme.corner
local stroke = theme.stroke
local text = theme.text

local LocalPlayer = Players.LocalPlayer

local RANK_COLORS = {
    colors.corona,
    Color3.fromRGB(205, 216, 232),
    Color3.fromRGB(214, 138, 74),
}

local COLUMNS = {
    { key = "structures", label = "Built", tip = "Structures placed" },
    { key = "iridium", label = "Irid", tip = "Iridium spent on structures", compact = true },
    { key = "kills", label = "Kills", tip = "Players killed" },
    { key = "deaths", label = "Deaths", tip = "Times died" },
    { key = "ls", label = "LS", tip = "Laser strikes used" },
    { key = "os", label = "OS", tip = "Orbital shields used" },
    { key = "arty", label = "Arty", tip = "Artillery shots fired" },
    { key = "bores", label = "Bores", tip = "Bores aimed" },
}

local ROW_HEIGHT = 46
local GROUP_HEIGHT = 28
local RANK_WIDTH = 30
local AVATAR_WIDTH = 42
local NAME_X = 8 + RANK_WIDTH + AVATAR_WIDTH
local LIST_TOP = 118
local DETAIL_TOP = 40
local TYPE_ROW_HEIGHT = 36
local REFRESH = 0.5

-- the columns fit themselves to the board's width: stats and score narrow first, then the least
-- telling stats drop out, so the name always keeps MIN_NAME_WIDTH
local MIN_NAME_WIDTH = 120
local STAT_WIDTH = { min = 40, max = 52 }
local SCORE_WIDTH = { min = 92, max = 124 }
local HIDE_ORDER = { "deaths", "os", "ls", "arty", "bores", "structures" }

local StatsBoard = {}
StatsBoard.__index = StatsBoard
local computeLayout=function(

width)    
local visible = {}
    for index in COLUMNS do
        visible[index] = true
    end

    -- room left for stats and score once the rank, avatar and a readable name have theirs
    local spare = width - NAME_X - 8 - MIN_NAME_WIDTH
    local statWidth, scoreWidth
    local hidden = 0

    while true do
        local count = 0
        for _ in visible do
            count =count+ 1
        end

        scoreWidth = SCORE_WIDTH.max
        statWidth = math.clamp((spare - scoreWidth) / math.max(count, 1), STAT_WIDTH.min, STAT_WIDTH.max)
        if count * statWidth + scoreWidth > spare then
            statWidth = STAT_WIDTH.min
            scoreWidth = math.clamp(spare - count * statWidth, SCORE_WIDTH.min, SCORE_WIDTH.max)
        end

        if count * statWidth + scoreWidth <= spare or hidden >= #HIDE_ORDER then
            break
        end

        hidden =hidden+ 1
        for index, column in COLUMNS do
            if column.key == HIDE_ORDER[hidden] then
                visible[index] = nil
            end
        end
    end

    statWidth = math.floor(statWidth)
    scoreWidth = math.floor(scoreWidth)

    -- each visible stat's distance from the right edge
    local offsets, shown = {}, 0
    for index = #COLUMNS, 1, -1 do
        if visible[index] then
            shown =shown+ 1
            offsets[index] = scoreWidth + shown * statWidth
        end
    end

    return {
        statWidth = statWidth,
        scoreWidth = scoreWidth,
        offsets = offsets,
        nameWidth = -(NAME_X + shown * statWidth + scoreWidth + 8),
    }
end local formatStat=function(

column, value)    
return (column.compact and{(theme.compact(value) )}or{(tostring(value)
)})[1]end local formatTime=function(

seconds)    
seconds = math.floor(seconds)
    local hours = math.floor(seconds / 3600
)    local minutes = (math.floor(seconds / 60)) % 60
    if hours > 0 then
        return string.format("%d:%02d:%02d", hours, minutes, seconds % 60)
    end
    return string.format("%02d:%02d", minutes, seconds % 60)
end local button=function(

properties)    
local instance = create("TextButton", {
        BackgroundColor3 = colors.field,
        AutoButtonColor = false,
        Font = fonts.mono,
        TextSize = 11,
        TextColor3 = colors.textDim,
    }, { corner(6) })
    for property, value in properties do
        instance[property] = value
    end
    local outline = stroke(colors.strokeBright)
    outline.Parent = instance
    instance.MouseEnter:Connect(function()
        outline.Color = colors.accent
        instance.TextColor3 = colors.text
    end)
    instance.MouseLeave:Connect(function()
        outline.Color = colors.strokeBright
        instance.TextColor3 = colors.textDim
    end)
    return instance
end
-- weights: the score weights table (changes to it show on the next refresh)
-- isShown: returns whether the page is on screen, so the board only redraws when it's seen

function StatsBoard.new(tracker, weights, page, window, isShown)
    local self = setmetatable({
        tracker = tracker,
        weights = weights,
        page = page,
        window = window,
        isShown = isShown,
        sortKey = "score",
        sortDescending = true,
        groupByTeam = true,
        rows = {},
        groups = {},
        headerButtons = {},
        renderedVersion = -1,
        hoveredRecord = nil,
        detailRecord = nil,
        nextRefresh = 0,
        lastScores = {},
        lastRanks = {},
        lastCount = 0,
    }, StatsBoard)

    self:_build()

    -- sort arrows, tags and bars use the accent
    theme.onChanged(function()
        self:refresh()
    end)

    RunService.RenderStepped:Connect(function()
        if not self.isShown() then
            return
        end
        local now = os.clock()
        if now < self.nextRefresh then
            return
        end
        self.nextRefresh = now + REFRESH

        self:_updateSubtitle()
        if self.tracker.version ~= self.renderedVersion then
            self:_render()
        end
    end)

    return self
end

-- redraw on the next refresh (after the weights change, for one)
function StatsBoard:refresh()
    self.renderedVersion = -1
end

function StatsBoard:scoreOf(record)
    local score = 0
    for key, weight in self.weights do
        score =score+ (record[key] or 0) * weight
    end
    return score
end

function StatsBoard:_build()
    local page = self.page

    -- toolbar: live summary on the left, actions on the right
    self.subtitle = text({
        Size = UDim2.new(1, -260, 0, 28),
        Font = fonts.mono,
        TextSize = 11,
        TextColor3 = colors.muted,
        RichText = true,
        Parent = page,
    })

    local exportButton = button({
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.fromOffset(108, 28),
        Text = "EXPORT JSON",
        Parent = page,
    })
    exportButton.MouseButton1Click:Connect(function()
        self:_export()
    end)

    self.groupButton = button({
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -116, 0, 0),
        Size = UDim2.fromOffset(120, 28),
        Text = "",
        Parent = page,
    })
    self.groupButton.MouseButton1Click:Connect(function()
        self.groupByTeam = not self.groupByTeam
        self:_render()
    end)

    -- team totals: a chip per team and one bar split by each team's share of the points
    self.teamStrip = create("Frame", {
        Position = UDim2.fromOffset(0, 40),
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Parent = page,
    }, {
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
    })
    self.shareBar = create("Frame", {
        Position = UDim2.fromOffset(0, 76),
        Size = UDim2.new(1, 0, 0, 3),
        BackgroundColor3 = colors.field,
        ClipsDescendants = true,
        Parent = page,
    }, {
        corner(2),
        create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder }),
    })

    -- column headers, click to sort
    local columns = create("Frame", {
        Position = UDim2.fromOffset(0, 92),
        Size = UDim2.new(1, -8, 0, 20),
        BackgroundTransparency = 1,
        Parent = page,
    })
local headerButton=function(
key, label, position, size, alignment, tip)        
local headerLabel = create("TextButton", {
            Position = position,
            Size = size,
            BackgroundTransparency = 1,
            Text = label,
            Font = fonts.mono,
            TextSize = 10,
            TextColor3 = colors.muted,
            TextXAlignment = alignment,
            Parent = columns,
        })
        headerLabel.MouseButton1Click:Connect(function()
            if self.sortKey == key then
                self.sortDescending = not self.sortDescending
            else
                self.sortKey = key
                self.sortDescending = key ~= "name"
            end
            self:_render()
        end)
        if tip then
            headerLabel.MouseEnter:Connect(function()
                self.window:ShowTooltip((typeof(tip) == "function" and{(tip() )}or{tip})[1])
            end)
            headerLabel.MouseLeave:Connect(function()
                self.window:HideTooltip()
            end)
        end
        self.headerButtons[key] = { button = headerLabel, label = label }
end
    
headerButton("name", "PLAYER", UDim2.fromOffset(NAME_X, 0), UDim2.new(), Enum.TextXAlignment.Left)
    for _, column in COLUMNS do
        headerButton(
            column.key,
            string.upper(column.label),
            UDim2.new(),
            UDim2.new(),
            Enum.TextXAlignment.Center,
            column.tip
        )
    end
    headerButton(
        "score",
        "SCORE",
        UDim2.new(),
        UDim2.new(),
        Enum.TextXAlignment.Left,
        function()
            return self:_weightsTip()
        end
    )

    self.list = create("ScrollingFrame", {
        Position = UDim2.fromOffset(0, LIST_TOP),
        Size = UDim2.new(1, 0, 1, -LIST_TOP),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = colors.strokeBright,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Parent = page,
    }, {
        create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
    })

    self.empty = text({
        Position = UDim2.fromOffset(0, LIST_TOP),
        Size = UDim2.new(1, 0, 0, 60),
        Text = "NO ACTIVITY YET",
        Font = fonts.mono,
        TextSize = 11,
        TextColor3 = colors.faint,
        TextXAlignment = Enum.TextXAlignment.Center,
        Visible = false,
        Parent = page,
    })

    -- hidden while a player's detail page is open
    self.mainViews = { self.teamStrip, self.shareBar, columns, self.list }

    self:_buildDetail()
local relayout=function()        


local scale = math.max(self.window.scale.Scale, 0.01)
        local width = math.floor(self.list.AbsoluteSize.X / scale) - 8
        if width > 0 and width ~= self.layoutWidth then
            self.layoutWidth = width
            self:_applyLayout(computeLayout(width))
        end
end    
self.layout = computeLayout(700)
    self:_applyLayout(self.layout)
    self.list:GetPropertyChangedSignal("AbsoluteSize"):Connect(relayout)
    task.defer(relayout)
end

function StatsBoard:_layoutRow(row)
    local layout = self.layout
    row.displayName.Size = UDim2.new(1, layout.nameWidth, 0, 17)
    row.username.Size = UDim2.new(1, layout.nameWidth, 0, 13)
    for index, label in row.stats do
        local offset = layout.offsets[index]
        label.Visible = offset ~= nil
        if offset then
            label.Position = UDim2.new(1, -offset, 0, 0)
            label.Size = UDim2.new(0, layout.statWidth, 1, 0)
        end
    end
    row.scoreFrame.Position = UDim2.new(1, -layout.scoreWidth + 8, 0, 0)
    row.scoreFrame.Size = UDim2.new(0, layout.scoreWidth - 16, 1, 0)
end

function StatsBoard:_layoutGroup(group)
    local layout = self.layout
    group.total.Position = UDim2.new(1, -layout.scoreWidth + 8, 0, 4)
    group.total.Size = UDim2.new(0, layout.scoreWidth - 16, 1, -4)
end

function StatsBoard:_applyLayout(layout)
    self.layout = layout

    for index, column in COLUMNS do
        local header = self.headerButtons[column.key].button
        local offset = layout.offsets[index]
        header.Visible = offset ~= nil
        if offset then
            header.Position = UDim2.new(1, -offset, 0, 0)
            header.Size = UDim2.new(0, layout.statWidth, 1, 0)
        end
    end
    local score = self.headerButtons.score.button
    score.Position = UDim2.new(1, -layout.scoreWidth + 8, 0, 0)
    score.Size = UDim2.new(0, layout.scoreWidth - 16, 1, 0)
    self.headerButtons.name.button.Size = UDim2.new(1, layout.nameWidth, 1, 0)

    for _, row in self.rows do
        self:_layoutRow(row)
    end
    for _, group in self.groups do
        self:_layoutGroup(group)
    end
end

function StatsBoard:_weightsTip()
    local parts = {}
    for _, column in COLUMNS do
        local weight = self.weights[column.key] or 0
        if weight ~= 0 then
            table.insert(parts, string.format('%s \u{d7}%s', tostring(column.label), tostring(weight)))
        end
    end
    return "Score = " .. ((#parts > 0 and{(table.concat(parts, " + ") )}or{"0"})[1])
end

function StatsBoard:_updateSubtitle()
    local players, teams, teamCount = 0, {}, 0
    for _, player in Players:GetPlayers() do
        players =players+ 1
        if player.Team and not teams[player.Team] then
            teams[player.Team] = true
            teamCount =teamCount+ 1
        end
    end

    local value = theme.hex(colors.text)
    self.subtitle.Text = string.format('<font color="%s">\u{25cf}</font>  TRACKING <font color="%s">%s</font>', tostring(theme.hex(colors.accent)), tostring(value), tostring(formatTime(self.tracker:getElapsed())))        
.. string.format('   PLAYERS <font color="%s">%s</font>', tostring(value), tostring(players))        
.. ((teamCount > 0 and{(string.format('   TEAMS <font color="%s">%s</font>', tostring(value), tostring(teamCount)))}or{""})[1])
end

function StatsBoard:_tooltipFor(record)
    local muted = theme.hex(colors.muted)
    local lines = { string.format('<b>%s</b>  <font color="%s">@%s</font>', tostring(record.displayName), tostring(muted), tostring(record.name))}

    local kd = (record.deaths > 0 and{(record.kills / record.deaths )}or{(record.kills
)})[1]    table.insert(lines, string.format('K/D %s  \u{b7}  %s iridium', tostring(string.format("%.2f", kd)), tostring(theme.thousands(record.iridium))))

    local types = {}
    for name, count in record.structureTypes do
        table.insert(types, { name = name, count = count })
    end
    table.sort(types, function(a, b)
        return a.count > b.count
    end)
    if #types > 0 then
        table.insert(lines, "")
        for i = 1, math.min(#types, 3) do
            table.insert(lines, string.format('%s  <font color="%s">\u{d7}%s</font>', tostring(types[i].name), tostring(muted), tostring(types[i].count)))
        end
    end
    table.insert(lines, string.format('<font color="%s">click for the full build list</font>', tostring(theme.hex(colors.accent))))

    return table.concat(lines, "\n")
end

-- rows

function StatsBoard:_createRow(record)
    local row = {}

    local frame = create("TextButton", {
        Size = UDim2.new(1, -8, 0, ROW_HEIGHT),
        BackgroundColor3 = colors.panel,
        AutoButtonColor = false,
        Text = "",
        Parent = self.list,
    }, { corner(8) })
    theme.surface(frame, 0.7)
    row.frame = frame
    row.outline = stroke(colors.stroke)
    row.outline.Parent = frame

    row.strip = create("Frame", {
        Position = UDim2.fromOffset(0, 10),
        Size = UDim2.new(0, 2, 1, -20),
        BorderSizePixel = 0,
        Parent = frame,
    })

    row.rank = text({
        Position = UDim2.fromOffset(8, 0),
        Size = UDim2.new(0, RANK_WIDTH, 1, 0),
        Font = fonts.mono,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = frame,
    })

    row.avatar = create("ImageLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 8 + RANK_WIDTH + 2, 0.5, 0),
        Size = UDim2.fromOffset(32, 32),
        BackgroundColor3 = colors.raised,
        Image = theme.headshot(record.userId),
        Parent = frame,
    }, { corner() })
    row.avatarStroke = stroke(colors.strokeBright, 1.5)
    row.avatarStroke.Parent = row.avatar

    row.displayName = text({
        Position = UDim2.fromOffset(NAME_X, 7),
        Font = fonts.bold,
        TextSize = 14,
        Parent = frame,
    })
    row.username = text({
        Position = UDim2.fromOffset(NAME_X, 25),
        Font = fonts.mono,
        TextSize = 10,
        TextColor3 = colors.muted,
        RichText = true,
        Parent = frame,
    })

    row.stats = {}
    for index in COLUMNS do
        row.stats[index] = text({
            Font = fonts.mono,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = frame,
        })
    end

    local score = create("Frame", {
        BackgroundTransparency = 1,
        Parent = frame,
    })
    row.scoreFrame = score
    row.score = text({
        Position = UDim2.fromOffset(0, 8),
        Size = UDim2.new(0.5, 0, 0, 16),
        Font = fonts.mono,
        TextSize = 14,
        TextColor3 = colors.text,
        Parent = score,
    })
    row.share = text({
        Position = UDim2.new(0.5, 0, 0, 10),
        Size = UDim2.new(0.5, 0, 0, 12),
        Font = fonts.mono,
        TextSize = 10,
        TextColor3 = colors.muted,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = score,
    })
    local track = create("Frame", {
        Position = UDim2.fromOffset(0, 30),
        Size = UDim2.new(1, 0, 0, 4),
        BackgroundColor3 = colors.field,
        Parent = score,
    }, { corner(2) })
    row.bar = create("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = track,
    }, { corner(2) })
    row.barGradient = create("UIGradient", { Parent = row.bar })

    frame.MouseEnter:Connect(function()
        self.hoveredRecord = record
        frame.BackgroundColor3 = colors.raised
        row.outline.Color = colors.strokeBright
        self.window:ShowTooltip(self:_tooltipFor(record))
    end)
    frame.MouseLeave:Connect(function()
        if self.hoveredRecord == record then
            self.hoveredRecord = nil
            self.window:HideTooltip()
        end
        frame.BackgroundColor3 = row.background
        row.outline.Color = colors.stroke
    end)
    frame.MouseButton1Click:Connect(function()
        self:_openDetail(record)
    end)

    self.rows[record] = row
    self:_layoutRow(row)
    return row
end

function StatsBoard:_updateRow(row, record, rank, score, maxScore, teamTotal)
    local isSelf = record.userId == LocalPlayer.UserId
    local teamColor = record.teamColor or colors.muted

    row.background = (isSelf and{(colors.self )}or{(colors.panel
)})[1]    if self.hoveredRecord ~= record then
        row.frame.BackgroundColor3 = row.background
    end

    row.strip.BackgroundColor3 = teamColor
    row.avatarStroke.Color = teamColor

    row.rank.Text = string.format("%02d", rank)
    row.rank.TextColor3 = RANK_COLORS[rank] or colors.faint

    row.displayName.Text = record.displayName
    row.displayName.TextColor3 = (record.left and{(colors.muted )}or{(colors.text
)})[1]
    local tags = string.format('@%s', tostring(record.name))    
if isSelf then
        tags =tags.. string.format('  <font color="%s">YOU</font>', tostring(theme.hex(colors.accent)))    
end
    if record.left then
        tags =tags.. string.format('  <font color="%s">LEFT</font>', tostring(theme.hex(colors.danger)))    
end
    row.username.Text = tags

    for index, column in COLUMNS do
        local value = record[column.key]
        local label = row.stats[index]
        label.Text = formatStat(column, value)
        label.TextColor3 = (value == 0 and{(colors.faint )}or{(colors.text
)})[1]    end

    row.score.Text = theme.compact(score)
    row.share.Text = (teamTotal > 0 and{(string.format('%s%%', tostring(math.round(score / teamTotal * 100))))}or{""
})[1]    row.bar.Size = UDim2.fromScale((maxScore > 0 and{(math.clamp(score / maxScore, 0, 1) )}or{0})[1], 1)
    row.barGradient.Color = ColorSequence.new(teamColor, teamColor:Lerp(Color3.new(1, 1, 1), 0.35))
end

function StatsBoard:_groupHeader(teamName)
    local group = self.groups[teamName]
    if group then
        return group
    end

    group = {}
    group.frame = create("Frame", {
        Size = UDim2.new(1, -8, 0, GROUP_HEIGHT),
        BackgroundTransparency = 1,
        Parent = self.list,
    })
    group.dot = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 4, 0.5, 2),
        Size = UDim2.fromOffset(8, 8),
        Parent = group.frame,
    }, { corner(2) })
    group.name = text({
        Position = UDim2.fromOffset(20, 4),
        Size = UDim2.new(0.6, 0, 1, -4),
        Font = fonts.mono,
        TextSize = 11,
        RichText = true,
        Parent = group.frame,
    })
    group.total = text({
        Font = fonts.mono,
        TextSize = 11,
        TextColor3 = colors.muted,
        RichText = true,
        Parent = group.frame,
    })

    self.groups[teamName] = group
    self:_layoutGroup(group)
    return group
end

function StatsBoard:_renderTeams(teamList, allTotal)
    for _, child in self.teamStrip:GetChildren() do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
    for _, child in self.shareBar:GetChildren() do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local muted = theme.hex(colors.muted)
    for order, team in teamList do
        local chip = theme.surface(create("Frame", {
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.fromOffset(0, 26),
            BackgroundColor3 = colors.panel,
            LayoutOrder = order,
            Parent = self.teamStrip,
        }, {
            corner(6),
            stroke(),
            theme.padding(10, 12, 0, 0),
            create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 8),
                VerticalAlignment = Enum.VerticalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        }), 0.7)
        create("Frame", {
            Size = UDim2.fromOffset(8, 8),
            BackgroundColor3 = team.color,
            LayoutOrder = 1,
            Parent = chip,
        }, { corner(2) })
        local share = (allTotal > 0 and{(math.round(team.total / allTotal * 100) )}or{0
})[1]        text({
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.fromScale(0, 1),
            RichText = true,
            Font = fonts.mono,
            TextSize = 11,
            TextTruncate = Enum.TextTruncate.None,
            Text = string.format('%s  <font color="%s">%s</font> <font color="%s">PTS \u{b7} %s%% \u{b7} %s IRID</font>', tostring(string.upper(team.name)), tostring(theme.hex(colors.text)), tostring(theme.compact(team.total)), tostring(muted), tostring(share), tostring(theme.compact(team.iridium))),
            LayoutOrder = 2,
            Parent = chip,
        })

        if allTotal > 0 and team.total > 0 then
            create("Frame", {
                Size = UDim2.fromScale(team.total / allTotal, 1),
                BackgroundColor3 = team.color,
                BorderSizePixel = 0,
                LayoutOrder = order,
                Parent = self.shareBar,
            })
        end
    end
end

function StatsBoard:_render()
    self.renderedVersion = self.tracker.version

    local records = self.tracker:getRecords()
    local scores = {}
    local teams = {}
    local teamList = {}
    local maxScore, allTotal = 0, 0

    for _, record in records do
        local score = self:scoreOf(record)
        scores[record] = score
        maxScore = math.max(maxScore, score)
        allTotal =allTotal+ score

        local teamName = record.teamName or "No team"
        local team = teams[teamName]
        if not team then
            team = { name = teamName, color = record.teamColor or colors.muted, total = 0, iridium = 0, records = {} }
            teams[teamName] = team
            table.insert(teamList, team)
        end
        team.total =team.total+ score
        team.iridium =team.iridium+ record.iridium
        table.insert(team.records, record)
    end

    table.sort(teamList, function(a, b)
        if a.total ~= b.total then
            return a.total > b.total
        end
        return a.name < b.name
    end)

    -- rank is always by score, whatever the list is sorted by
    local byScore = table.clone(records)
    table.sort(byScore, function(a, b)
        if scores[a] ~= scores[b] then
            return scores[a] > scores[b]
        end
        return string.lower(a.displayName) < string.lower(b.displayName)
    end)
    local ranks = {}
    for rank, record in byScore do
        ranks[record] = rank
    end

    local sortKey, descending = self.sortKey, self.sortDescending
local compare=function(a, b)        
local valueA, valueB
        if sortKey == "score" then
            valueA, valueB = scores[a], scores[b]
        elseif sortKey == "name" then
            valueA, valueB = string.lower(a.displayName), string.lower(b.displayName)
        else
            valueA, valueB = a[sortKey], b[sortKey]
        end
        if valueA == valueB then
            return ranks[a] < ranks[b]
        end
        if descending then
            return valueA > valueB
        end
        return valueA < valueB
end
    
local order = 0
    local usedGroups = {}
local place=function(
record, teamTotal)        
local row = self.rows[record] or self:_createRow(record)
        order =order+ 1
        row.frame.LayoutOrder = order
        self:_updateRow(row, record, ranks[record], scores[record], maxScore, teamTotal)
end
    
local muted = theme.hex(colors.muted)
    if self.groupByTeam then
        for _, team in teamList do
            local group = self:_groupHeader(team.name)
            usedGroups[group] = true
            order =order+ 1
            group.frame.LayoutOrder = order
            group.frame.Visible = true
            group.dot.BackgroundColor3 = team.color
            group.name.Text = string.format('%s  <font color="%s">%s</font>', tostring(string.upper(team.name)), tostring(muted), tostring(#team.records))            
group.total.Text = string.format('%s <font color="%s">PTS</font>', tostring(theme.compact(team.total)), tostring(muted))
            
table.sort(team.records, compare)
            for _, record in team.records do
                place(record, team.total)
            end
        end
    else
        local sorted = table.clone(records)
        table.sort(sorted, compare)
        for _, record in sorted do
            place(record, teams[record.teamName or "No team"].total)
        end
    end

    for _, group in self.groups do
        if not usedGroups[group] then
            group.frame.Visible = false
        end
    end

    self.empty.Visible = #records == 0 and not self.detailRecord
    self.groupButton.Text = self.groupByTeam and"GROUPED BY TEAM" or"ALL PLAYERS"
    self:_renderTeams(teamList, allTotal)

    for key, header in self.headerButtons do
        local active = key == sortKey
        header.button.TextColor3 = (active and{(colors.accent )}or{(colors.muted
)})[1]        header.button.Text = (active and{(header.label .. (descending and" v" or" ^") )}or{(header.label
)})[1]    end

    if self.hoveredRecord then
        self.window:ShowTooltip(self:_tooltipFor(self.hoveredRecord))
    end

    self.lastScores = scores
    self.lastRanks = ranks
    self.lastCount = #records
    if self.detailRecord then
        self:_renderDetail()
    end
end

-- detail page: one player's numbers and every structure type they built, in place of the list

function StatsBoard:_buildDetail()
    local panel = create("Frame", {
        Position = UDim2.fromOffset(0, DETAIL_TOP),
        Size = UDim2.new(1, 0, 1, -DETAIL_TOP),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = self.page,
    })
    self.detail = panel

    local back = button({
        Size = UDim2.fromOffset(78, 26),
        Text = "<  BACK",
        Parent = panel,
    })
    back.MouseButton1Click:Connect(function()
        self:_closeDetail()
    end)

    self.detailAvatar = create("ImageLabel", {
        Position = UDim2.fromOffset(0, 40),
        Size = UDim2.fromOffset(60, 60),
        BackgroundColor3 = colors.raised,
        Parent = panel,
    }, { corner() })
    self.detailAvatarStroke = stroke(colors.strokeBright, 2)
    self.detailAvatarStroke.Parent = self.detailAvatar

    self.detailName = text({
        Position = UDim2.fromOffset(74, 46),
        Size = UDim2.new(1, -74 - 220, 0, 26),
        Font = fonts.bold,
        TextSize = 22,
        Parent = panel,
    })
    self.detailSub = text({
        Position = UDim2.fromOffset(75, 76),
        Size = UDim2.new(1, -74 - 220, 0, 14),
        Font = fonts.mono,
        TextSize = 11,
        TextColor3 = colors.muted,
        RichText = true,
        Parent = panel,
    })

    self.detailScore = text({
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 42),
        Size = UDim2.fromOffset(220, 30),
        Font = fonts.mono,
        TextSize = 26,
        TextXAlignment = Enum.TextXAlignment.Right,
        RichText = true,
        Parent = panel,
    })
    self.detailRank = text({
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 76),
        Size = UDim2.fromOffset(220, 14),
        Font = fonts.mono,
        TextSize = 11,
        TextColor3 = colors.muted,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = panel,
    })

    -- one card per stat
    local cards = create("Frame", {
        Position = UDim2.fromOffset(0, 114),
        Size = UDim2.new(1, 0, 0, 54),
        BackgroundTransparency = 1,
        Parent = panel,
    }, {
        create("UIGridLayout", {
            CellSize = UDim2.new(1 / #COLUMNS, -6, 1, 0),
            CellPadding = UDim2.fromOffset(6, 0),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })
    self.detailCards = {}
    for index, column in COLUMNS do
        local card = theme.surface(create("Frame", {
            BackgroundColor3 = colors.panel,
            LayoutOrder = index,
            Parent = cards,
        }, { corner(8), stroke() }), 0.7)
        text({
            Position = UDim2.fromOffset(10, 8),
            Size = UDim2.new(1, -16, 0, 12),
            Text = string.upper(column.label),
            Font = fonts.mono,
            TextSize = 10,
            TextColor3 = colors.muted,
            Parent = card,
        })
        self.detailCards[index] = text({
            Position = UDim2.fromOffset(10, 24),
            Size = UDim2.new(1, -16, 0, 22),
            Font = fonts.mono,
            TextSize = 18,
            Parent = card,
        })
        self.window:_tooltipOn(card, column.tip)
    end

    self.detailBuiltTitle = text({
        Position = UDim2.fromOffset(1, 182),
        Size = UDim2.new(1, 0, 0, 14),
        Font = fonts.mono,
        TextSize = 11,
        RichText = true,
        Parent = panel,
    })

    -- every structure type, two columns, most built first
    self.detailTypes = create("ScrollingFrame", {
        Position = UDim2.fromOffset(0, 204),
        Size = UDim2.new(1, 0, 1, -204),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = colors.strokeBright,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Parent = panel,
    }, {
        create("UIGridLayout", {
            CellSize = UDim2.new(0.5, -8, 0, TYPE_ROW_HEIGHT),
            CellPadding = UDim2.fromOffset(6, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    self.detailEmpty = text({
        Position = UDim2.fromOffset(0, 204),
        Size = UDim2.new(1, 0, 0, 40),
        Text = "NOTHING BUILT YET",
        Font = fonts.mono,
        TextSize = 11,
        TextColor3 = colors.faint,
        TextXAlignment = Enum.TextXAlignment.Center,
        Visible = false,
        Parent = panel,
    })
end

function StatsBoard:_openDetail(record)
    self.detailRecord = record
    self.hoveredRecord = nil
    self.window:HideTooltip()
    for _, view in self.mainViews do
        view.Visible = false
    end
    self.detail.Visible = true
    self.detailTypes.CanvasPosition = Vector2.zero
    self:_render()
end

function StatsBoard:_closeDetail()
    self.detailRecord = nil
    self.detail.Visible = false
    for _, view in self.mainViews do
        view.Visible = true
    end
    self:_render()
end

function StatsBoard:_renderDetail()
    local record = self.detailRecord
    local teamColor = record.teamColor or colors.muted
    local muted = theme.hex(colors.muted)
    local score = self.lastScores[record] or self:scoreOf(record)

    self.detailAvatar.Image = theme.headshot(record.userId)
    self.detailAvatarStroke.Color = teamColor
    self.detailName.Text = record.displayName

    local sub = string.format('@%s  \u{b7}  <font color="%s">%s</font>', tostring(record.name), tostring(theme.hex(teamColor)), tostring(string.upper(record.teamName or "No team")))    
if record.left then
        sub =sub.. string.format('  <font color="%s">\u{b7} LEFT</font>', tostring(theme.hex(colors.danger)))    
end
    self.detailSub.Text = sub

    self.detailScore.Text = string.format('%s<font color="%s" size="12"> PTS</font>', tostring(theme.compact(score)), tostring(muted))    
local rank = self.lastRanks[record]
    self.detailRank.Text = (rank and{(string.format('RANK %s / %s', tostring(string.format("%02d", rank)), tostring(string.format("%02d", self.lastCount))))}or{""
})[1]
    for index, column in COLUMNS do
        local value = record[column.key]
        local card = self.detailCards[index]
        card.Text = (column.compact and{(theme.thousands(value) )}or{(tostring(value)
)})[1]        card.TextColor3 = (value == 0 and{(colors.faint )}or{(colors.text
)})[1]    end

    local types, total = {}, 0
    for name, count in record.structureTypes do
        table.insert(types, { name = name, count = count, iridium = count * structures.costOf(name) })
        total =total+ count
    end
    table.sort(types, function(a, b)
        if a.count ~= b.count then
            return a.count > b.count
        end
        return a.name < b.name
    end)

    self.detailBuiltTitle.Text = string.format('STRUCTURES BUILT  <font color="%s">%s TOTAL \u{b7} %s TYPES \u{b7} %s IRIDIUM</font>', tostring(muted), tostring(total), tostring(#types), tostring(theme.thousands(record.iridium)))    
self.detailEmpty.Visible = #types == 0

    for _, child in self.detailTypes:GetChildren() do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end

    local most = (types[1] and{(types[1].count )}or{1
})[1]    for order, entry in types do
        local cell = create("Frame", {
            BackgroundColor3 = colors.panel,
            LayoutOrder = order,
            ClipsDescendants = true,
            Parent = self.detailTypes,
        }, { corner(8), stroke() })
        -- how it compares to their most built type, behind the text
        create("Frame", {
            Size = UDim2.fromScale(entry.count / most, 1),
            BackgroundColor3 = teamColor,
            BackgroundTransparency = 0.85,
            BorderSizePixel = 0,
            Parent = cell,
        }, { corner(8) })
        text({
            Position = UDim2.fromOffset(12, 0),
            Size = UDim2.new(1, -150, 1, 0),
            Text = entry.name,
            Font = fonts.medium,
            Parent = cell,
        })
        text({
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -62, 0, 0),
            Size = UDim2.new(0, 80, 1, 0),
            Text = string.format('%s irid', tostring(theme.compact(entry.iridium))),
            Font = fonts.mono,
            TextSize = 11,
            TextColor3 = colors.muted,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = cell,
        })
        text({
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -12, 0, 0),
            Size = UDim2.new(0, 46, 1, 0),
            Text = string.format('\u{d7}%s', tostring(entry.count)),
            Font = fonts.mono,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = cell,
        })
    end
end

function StatsBoard:_export()
    local path, err = exportMatch(self.tracker, function(record)
        return self:scoreOf(record)
    end, self.weights)

    if path then
        self.window:Notify(string.format('Match saved to %s', tostring(path)))
    else
        self.window:Notify(string.format('Export failed: %s', tostring(err)), 5, "error")
    end
end

return StatsBoard
end function dote.h()local v=dote.cache.h if not v then v={c=__modImpl()}dote.cache.h=v end return v.c end end do local __modImpl=function()-- what one of each stat is worth in a player's score. iridium is per point spent, so a bore (2000)
-- is worth 40 and a wall (100) is worth 2. the hub lets each player change these in Settings


local DEFAULTS = {
    structures = 0,
    iridium = 0.02,
    kills = 10,
    deaths = 0,
    ls = 6,
    os = 6,
    arty = 2,
    bores = 4,
}
local new=function()    


return table.clone(DEFAULTS)
end

return {
    DEFAULTS = DEFAULTS,
    new = new,
}
end function dote.i()local v=dote.cache.i if not v then v={c=__modImpl()}dote.cache.i=v end return v.c end end do local __modImpl=function()-- who's playing and what they're doing right now: team, health, iridium, the tool in hand, laser strikes /
-- orbital shields carried and suit upgrades. spectators are left out everywhere. the hud, the player tags
-- and the minimap all read from one roster, so each character is only looked through once per sample.
--   positions refresh every frame, everything else SAMPLE times a second


local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

local SPECTATOR_TEAM = "Spectators"
local SAMPLE = 0.2
local BEACON_NAME = "Priority Beacon"

local UPGRADES = {
    { key = "UpgradeHealth", label = "HP" },
    { key = "UpgradeJet", label = "JET" },
    { key = "UpgradeTool", label = "TOOL" },
    { key = "UpgradeCapacity", label = "CAP" },
}

local Roster = {}
Roster.__index = Roster
local isSpectator=function(

player)    
local team = player.Team
    if team then
        return team.Name == SPECTATOR_TEAM
    end
    return player:GetAttribute("IsSpectator") == true
end local getIridiumLevel=function(

character)    
local tank = character:FindFirstChild("IridiumTank")
    local indicator = tank and tank:FindFirstChild("Indicator")
    local meter = indicator and indicator:FindFirstChild("IridiumMeter")
    local mesh = meter and meter:FindFirstChild("Mesh")

    if mesh and mesh:IsA("DataModelMesh") then
        return math.clamp(mesh.Scale.Y, 0, 1)
    end

    return nil
end local countOrbitalsIn=function(

holder, lsCount, osCount)    
if holder then
        for _, child in holder:GetChildren() do
            if child:IsA("Tool") then
                if child.Name == "Laser Strike" then
                    lsCount =lsCount+ 1
                elseif child.Name == "Orbital Shield" then
                    osCount =osCount+ 1
                end
            end
        end
    end
    return lsCount, osCount
end local playingTeams=function()    



local list = {}
    for _, team in Teams:GetTeams() do
        if team.Name ~= SPECTATOR_TEAM then
            table.insert(list, team)
        end
    end
    table.sort(list, function(a, b)
        local indexA, indexB = a:GetAttribute("TeamIndex"), b:GetAttribute("TeamIndex")
        if typeof(indexA) == "number" and typeof(indexB) == "number" and indexA ~= indexB then
            return indexA < indexB
        end
        return a.Name < b.Name
    end)
    return list
end

function Roster.new(tracker)
    return setmetatable({
        tracker = tracker,
        -- player -> info
        byPlayer = {},
        -- infos in display order: team by team, then by name
        list = {},
        -- { team, name, color, players = { info }, beacons, beaconsRequired }
        teams = {},
        -- bumped whenever someone joins, leaves or changes team, so lists know to rebuild
        version = 0,
        nextSample = 0,
    }, Roster)
end

Roster.isSpectator = isSpectator
Roster.UPGRADES = UPGRADES

function Roster:_newInfo(player)
    return {
        player = player,
        userId = player.UserId,
        name = player.Name,
        displayName = player.DisplayName,
        team = nil,
        teamColor = Color3.fromRGB(160, 170, 190),
        character = nil,
        root = nil,
        humanoid = nil,
        alive = false,
        health = 0,
        maxHealth = 100,
        iridium = nil,
        tool = nil,
        ls = 0,
        os = 0,
        upgrades = {},
        position = nil,
        look = nil,
        record = nil,
        number = 0,
    }
end

function Roster:_sample(info)
    local player = info.player
    local character = player.Character
    info.character = character
    info.team = player.Team
    info.teamColor = (player.Team and{(player.TeamColor.Color )}or{(Color3.fromRGB(160, 170, 190)
)})[1]    info.record = self.tracker and self.tracker.records[player.UserId]

    if not character then
        info.root, info.humanoid, info.alive = nil, nil, false
        info.tool, info.iridium = nil, nil
        info.ls, info.os = 0, 0
        return
    end

    if not (info.root and info.root.Parent == character) then
        info.root = character:FindFirstChild("HumanoidRootPart")
    end
    if not (info.humanoid and info.humanoid.Parent == character) then
        info.humanoid = character:FindFirstChildOfClass("Humanoid")
    end

    local humanoid = info.humanoid
    info.health = (humanoid and{(math.max(humanoid.Health, 0) )}or{0
})[1]    info.maxHealth = (humanoid and humanoid.MaxHealth > 0 and{(humanoid.MaxHealth )}or{100
})[1]    info.alive = humanoid ~= nil and humanoid.Health > 0 and info.root ~= nil

    local held = character:FindFirstChildOfClass("Tool")
    info.tool = held and held.Name
    info.iridium = getIridiumLevel(character)
    info.ls, info.os = countOrbitalsIn(character, countOrbitalsIn(player:FindFirstChildOfClass("Backpack"), 0, 0))

    for _, upgrade in UPGRADES do
        local level = character:GetAttribute(upgrade.key)
        info.upgrades[upgrade.key] = (typeof(level) == "number" and{level }or{0
})[1]    end
end

function Roster:_rebuild()
    local teamList = {}
    local teamsByObject = {}
    for _, team in playingTeams() do
        local entry = {
            team = team,
            name = team.Name,
            color = team.TeamColor.Color,
            players = {},
            beacons = 0,
            beaconsRequired = team:GetAttribute("BeaconsRequired"),
        }
        table.insert(teamList, entry)
        teamsByObject[team] = entry
    end

    local list = {}
    for _, info in self.byPlayer do
        local entry = info.team and teamsByObject[info.team]
        if entry then
            table.insert(entry.players, info)
        end
    end

    local number = 0
    for _, entry in teamList do
        table.sort(entry.players, function(a, b)
            return string.lower(a.displayName) < string.lower(b.displayName)
        end)
        for _, info in entry.players do
            number =number+ 1
            info.number = number
            table.insert(list, info)
        end
    end

    -- players without a playing team (joining, between teams) aren't listed
    for _, info in self.byPlayer do
        if not (info.team and teamsByObject[info.team]) then
            info.number = 0
        end
    end

    self.teams = teamList
    self.list = list
    self.version =self.version+ 1
end

function Roster:_countBeacons()
    local structures = workspace:FindFirstChild("Structures")
    if not structures then
        return
    end
    local counts = {}
    for _, structure in structures:GetChildren() do
        if structure.Name == BEACON_NAME then
            local team = structure:GetAttribute("Team")
            local key = (typeof(team) == "BrickColor" and{(team.Name )}or{(tostring(team)
)})[1]            counts[key] = (counts[key] or 0) + 1
        end
    end
    for _, entry in self.teams do
        entry.beacons = counts[entry.team.TeamColor.Name] or 0
        entry.beaconsRequired = entry.team:GetAttribute("BeaconsRequired")
    end
end

-- call every frame
function Roster:update()
    local now = os.clock()
    local membershipChanged = false

    if now >= self.nextSample then
        self.nextSample = now + SAMPLE

        local seen = {}
        for _, player in Players:GetPlayers() do
            if isSpectator(player) then
                continue
            end
            seen[player] = true

            local info = self.byPlayer[player]
            if not info then
                info = self:_newInfo(player)
                self.byPlayer[player] = info
                membershipChanged = true
            end

            local previousTeam = info.team
            self:_sample(info)
            if info.team ~= previousTeam then
                membershipChanged = true
            end
        end

        for player in self.byPlayer do
            if not seen[player] then
                self.byPlayer[player] = nil
                membershipChanged = true
            end
        end

        if membershipChanged or #self.teams ~= #playingTeams() then
            self:_rebuild()
        end
        self:_countBeacons()
    end

    for _, info in self.list do
        local root = info.root
        if root and root.Parent then
            info.position = root.Position
            info.look = root.CFrame.LookVector
        end
    end
end

-- the nth listed player (1 based), wrapping around
function Roster:at(index)
    local count = #self.list
    if count == 0 then
        return nil
    end
    return self.list[(index - 1) % count + 1]
end

function Roster:indexOf(info)
    for index, other in self.list do
        if other == info then
            return index
        end
    end
    return nil
end

return Roster
end function dote.j()local v=dote.cache.j if not v then v={c=__modImpl()}dote.cache.j=v end return v.c end end do local __modImpl=function()-- the viewer's camera. C steps through the follow modes, F flies free:
--   roblox   the normal roblox camera on the watched player: right mouse drag turns, the wheel zooms
--   orbit    a smoothed camera that orbits them, driven here (the game leaves a Scriptable camera alone)
--   chase    the orbit camera, but it swings round behind them as they turn
--   free     flies anywhere: WASD, Q / E down and up, shift faster, ctrl slower, right mouse drag looks,
--            the wheel changes speed
-- noclip stops walls from pulling the camera in (the roblox camera through the same popper patch the hub's
-- noclip camera uses). the game streams the map in around whoever the server has us spectating, so
-- switching players also asks the server to move there; a freecam far from them only sees what's loaded


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local nccam = dote.d()

local FOCUS_HEIGHT = 2.5
local MIN_ZOOM, MAX_ZOOM, DEFAULT_ZOOM = 6, 600, 18
-- how far the roblox camera may zoom out while the viewer runs
local ROBLOX_MAX_ZOOM = 2000
local MIN_PITCH, MAX_PITCH = math.rad(-80), math.rad(70)
local LOOK_SPEED = 0.0045
-- how fast the camera catches up with its target, higher is snappier
local FOLLOW_SHARPNESS = 20
local CHASE_SHARPNESS = 4
-- a target further than this from the camera's focus is cut to, not flown to
local SNAP_DISTANCE = 120
local FREE_SPEEDS = { 10, 20, 40, 70, 110, 170, 260, 400 }
local FREE_DEFAULT_SPEED = 3

local FOLLOW_MODES = { "roblox", "orbit", "chase" }
local MODE_NAMES = {
    roblox = "ROBLOX CAM",
    orbit = "ORBIT CAM",
    chase = "CHASE CAM",
    free = "FREECAM",
}

local LocalPlayer = Players.LocalPlayer

local Camera = {}
Camera.__index = Camera
local damp=function(
sharpness, dt)    
return 1 - math.exp(-sharpness * dt)
end local requestServerTarget=function(


player)    
local shared = ReplicatedStorage:FindFirstChild("Shared")
    local remotes = shared and shared:FindFirstChild("Remotes")
    local remote = remotes and remotes:FindFirstChild("RequestSpectateTarget")
    if remote then
        pcall(remote.FireServer, remote, player)
    end
end

function Camera.new(roster)
    local self = setmetatable({
        roster = roster,
        mode = "roblox",
        -- the follow mode F goes back to
        followMode = "roblox",
        target = nil,
        noclip = false,
        -- orbit / chase
        yaw = 0,
        pitch = math.rad(-15),
        zoom = DEFAULT_ZOOM,
        focus = nil,
        -- freecam
        freeCFrame = nil,
        freeSpeed = FREE_DEFAULT_SPEED,
        looking = false,
        lookDelta = Vector2.zero,
        changedCallbacks = {},
        connections = {},
        rayParams = RaycastParams.new(),
        savedMaxZoom = LocalPlayer.CameraMaxZoomDistance,
    }, Camera)

    self.rayParams.FilterType = Enum.RaycastFilterType.Exclude
    self.rayParams.IgnoreWater = true
    LocalPlayer.CameraMaxZoomDistance = ROBLOX_MAX_ZOOM

    self:_bindInput()
    return self
end

Camera.MODE_NAMES = MODE_NAMES

-- callback(camera) whenever the target or mode changes
function Camera:onChanged(callback)
    table.insert(self.changedCallbacks, callback)
end

function Camera:_changed()
    for _, callback in self.changedCallbacks do
        task.spawn(callback, self)
    end
end

function Camera:setTarget(info)
    if not info then
        return
    end
    local switched = info ~= self.target
    self.target = info
    if self.mode == "free" then
        self.mode = self.followMode
    end
    if switched then
        requestServerTarget(info.player)
        -- face the way they're facing so the cut doesn't spin the view
        if info.look then
            self.yaw = math.atan2(-info.look.X, -info.look.Z)
        end
    end
    self:_changed()
end

-- step through the listed players, direction 1 or -1
function Camera:cycle(direction)
    local roster = self.roster
    local index = self.target and roster:indexOf(self.target)
    local nextInfo = (index and{(roster:at(index + direction) )}or{(roster:at(1)
)})[1]    self:setTarget(nextInfo)
end

function Camera:setMode(mode)
    if mode == self.mode then
        return
    end
    local camera = workspace.CurrentCamera
    if mode == "free" then
        self.freeCFrame = camera.CFrame
    else
        self.followMode = mode
        -- the orbit picks up where the view is now instead of jumping
        local look = camera.CFrame.LookVector
        self.yaw = math.atan2(-look.X, -look.Z)
        self.pitch = math.clamp(math.asin(math.clamp(look.Y, -1, 1)), MIN_PITCH, MAX_PITCH)
        self.focus = nil
    end
    self.mode = mode
    self:_changed()
end

function Camera:toggleFree()
    self:setMode((self.mode == "free" and{(self.followMode )}or{"free"})[1])
end

-- roblox -> orbit -> chase -> roblox
function Camera:cycleFollowMode()
    local index = table.find(FOLLOW_MODES, self.followMode) or 1
    self:setMode(FOLLOW_MODES[index % #FOLLOW_MODES + 1])
end

function Camera:setNoclip(enabled)
    if enabled == self.noclip then
        return
    end
    self.noclip = enabled
    -- nccam flips the popper between its two states
    nccam()
    self:_changed()
end

function Camera:freeSpeedValue()
    return FREE_SPEEDS[self.freeSpeed]
end

function Camera:_bindInput()
local connect=function(signal, callback)        
table.insert(self.connections, signal:Connect(callback))
end
    -- the roblox camera does its own turning and zooming; these drive the others
    
connect(UserInputService.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 and self.mode ~= "roblox" then
            self.looking = true
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
        end
    end)

    connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 and self.looking then
            self.looking = false
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
    end)

    connect(UserInputService.InputChanged, function(input, processed)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if self.looking then
                self.lookDelta =self.lookDelta+ Vector2.new(input.Delta.X, input.Delta.Y)
            end
        elseif input.UserInputType == Enum.UserInputType.MouseWheel and not processed then
            local steps = input.Position.Z
            if self.mode == "free" then
                self.freeSpeed = math.clamp(self.freeSpeed + (steps > 0 and 1 or-1), 1, #FREE_SPEEDS)
                self:_changed()
            elseif self.mode ~= "roblox" then
                self.zoom = math.clamp(self.zoom * (steps > 0 and 0.85 or 1 / 0.85), MIN_ZOOM, MAX_ZOOM)
            end
        end
    end)
end
local keyDown=function(
key)    
return UserInputService:IsKeyDown(key)
end

function Camera:_updateFree(camera, dt, look)
    local cframe = self.freeCFrame or camera.CFrame

    if look.Magnitude > 0 then
        local x, y = cframe:ToEulerAnglesYXZ()
        x = math.clamp(x - look.Y * LOOK_SPEED, MIN_PITCH, MAX_PITCH)
        y =y- look.X * LOOK_SPEED
        cframe = CFrame.new(cframe.Position) * CFrame.fromEulerAnglesYXZ(x, y, 0)
    end

    -- typing in chat or a text box shouldn't fly the camera
    if not UserInputService:GetFocusedTextBox() then
        local move = Vector3.zero
        if keyDown(Enum.KeyCode.W) then
            move =move+ Vector3.new(0, 0, -1)
        end
        if keyDown(Enum.KeyCode.S) then
            move =move+ Vector3.new(0, 0, 1)
        end
        if keyDown(Enum.KeyCode.A) then
            move =move+ Vector3.new(-1, 0, 0)
        end
        if keyDown(Enum.KeyCode.D) then
            move =move+ Vector3.new(1, 0, 0)
        end

        local vertical = 0
        if keyDown(Enum.KeyCode.E) then
            vertical =vertical+ 1
        end
        if keyDown(Enum.KeyCode.Q) then
            vertical =vertical- 1
        end

        local speed = FREE_SPEEDS[self.freeSpeed]
        if keyDown(Enum.KeyCode.LeftShift) then
            speed =speed* 3
        elseif keyDown(Enum.KeyCode.LeftControl) then
            speed =speed/ 4
        end

        if move.Magnitude > 0 then
            move = cframe:VectorToWorldSpace(move.Unit)
        end
        move =move+ Vector3.new(0, vertical, 0)
        cframe =cframe+ move * speed * dt
    end

    self.freeCFrame = cframe
    camera.CFrame = cframe
end

function Camera:_updateOrbit(camera, dt, look)
    local target = self.target
    local position = target and target.position

    if look.Magnitude > 0 then
        self.yaw =self.yaw- look.X * LOOK_SPEED
        self.pitch = math.clamp(self.pitch - look.Y * LOOK_SPEED, MIN_PITCH, MAX_PITCH)
    elseif self.mode == "chase" and target and target.alive and target.look then
        -- swing round behind them, taking the short way
        local behind = math.atan2(-target.look.X, -target.look.Z)
        local difference = (behind - self.yaw + math.pi) % (2 * math.pi) - math.pi
        self.yaw =self.yaw+ difference * damp(CHASE_SHARPNESS, dt)
    end

    -- read the root straight from the character, so the camera moves with this frame's position
    local root = target and target.root
    if root and root.Parent then
        position = root.Position
    end

    if position then
        local goal = position + Vector3.new(0, FOCUS_HEIGHT, 0)
        if not self.focus or (goal - self.focus).Magnitude > SNAP_DISTANCE then
            self.focus = goal
        else
            self.focus = self.focus:Lerp(goal, damp(FOLLOW_SHARPNESS, dt))
        end
    end

    local focus = self.focus
    if not focus then
        return
    end

    local rotation = CFrame.fromEulerAnglesYXZ(self.pitch, self.yaw, 0)
    local offset = rotation:VectorToWorldSpace(Vector3.new(0, 0, self.zoom))
    local distance = self.zoom

    -- pull in in front of walls so the player stays in view, unless noclip is on
    if not self.noclip then
        local ignore = {}
        for _, info in self.roster.list do
            if info.character then
                table.insert(ignore, info.character)
            end
        end
        self.rayParams.FilterDescendantsInstances = ignore
        local hit = workspace:Raycast(focus, offset, self.rayParams)
        if hit then
            distance = math.max((hit.Position - focus).Magnitude - 0.8, 1)
        end
    end

    camera.CFrame = CFrame.new(focus + offset.Unit * distance) * rotation
    camera.Focus = CFrame.new(focus)
end

function Camera:_updateRoblox(camera)
    if camera.CameraType ~= Enum.CameraType.Custom then
        camera.CameraType = Enum.CameraType.Custom
    end
    -- the game points the camera at its own spectate target; keep it on ours
    local humanoid = self.target and self.target.humanoid
    if humanoid and humanoid.Parent and camera.CameraSubject ~= humanoid then
        camera.CameraSubject = humanoid
    end
end

-- call every frame
function Camera:update(dt)
    local camera = workspace.CurrentCamera

    -- the watched player left or became a spectator: move on to someone still playing
    if self.target and not self.roster.byPlayer[self.target.player] then
        self.target = nil
        self:cycle(1)
    elseif not self.target and #self.roster.list > 0 then
        local wanted = LocalPlayer:GetAttribute("SpectateTarget")
        local player = typeof(wanted) == "number" and Players:GetPlayerByUserId(wanted)
        self:setTarget(player and self.roster.byPlayer[player] or self.roster:at(1))
    end

    local look = self.lookDelta
    self.lookDelta = Vector2.zero

    if self.mode == "roblox" then
        self:_updateRoblox(camera)
        return
    end

    if camera.CameraType ~= Enum.CameraType.Scriptable then
        camera.CameraType = Enum.CameraType.Scriptable
    end
    if self.mode == "free" then
        self:_updateFree(camera, dt, look)
    else
        self:_updateOrbit(camera, dt, look)
    end
end

-- hand the camera back to the game (when the viewer is closed)
function Camera:destroy()
    for _, connection in self.connections do
        connection:Disconnect()
    end
    self.connections = {}

    self:setNoclip(false)
    LocalPlayer.CameraMaxZoomDistance = self.savedMaxZoom

    local camera = workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Custom
    if self.looking then
        self.looking = false
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end

return Camera
end function dote.k()local v=dote.cache.k if not v then v={c=__modImpl()}dote.cache.k=v end return v.c end end do local __modImpl=function()-- the viewer's broadcast hud, laid out like a counter strike match:
--   top        the scorebar: each team's kills, players still up, beacons placed and iridium spent
--   left/right a card per player down each side: health, iridium, what they hold, orbitals, K / D.
--              click one (or press its number) to watch them
--   bottom     the watched player up close: health, iridium, upgrades, orbitals and their match stats
--   top right  the feed: kills, deaths, laser strikes and orbital shields as they happen
--   bottom left the controls


local theme = dote.b()
local Roster = dote.j()
local Camera = dote.k()

local colors = theme.colors
local fonts = theme.fonts
local create = theme.create
local corner = theme.corner
local stroke = theme.stroke
local text = theme.text

local REFRESH = 0.1
local CARD_WIDTH = 262
local CARD_HEIGHT = 58
local CARD_HEIGHT_COMPACT = 46
local CARD_GAP = 6
local FEED_MAX = 6
local FEED_LIFETIME = 9

local LS_COLOR = Color3.fromRGB(255, 170, 60)
local OS_COLOR = Color3.fromRGB(80, 170, 255)
local DEAD_TINT = Color3.fromRGB(70, 22, 30)

local CONTROLS = {
    { "LMB / →", "next player" },
    { "←", "previous player" },
    { "1 - 0", "pick a player" },
    { "RMB drag", "turn the camera" },
    { "Wheel", "zoom / fly speed" },
    { "C", "camera: roblox / orbit / chase" },
    { "F", "freecam" },
    { "N", "noclip camera" },
    { "Tab", "match stats" },
    { "M", "bigger map" },
    { "V", "player tags" },
    { "H", "hide the hud" },
}

local Hud = {}
Hud.__index = Hud
local formatTime=function(
seconds)    
seconds = math.floor(seconds)
    local hours = math.floor(seconds / 3600
)    local minutes = (math.floor(seconds / 60)) % 60
    if hours > 0 then
        return string.format("%d:%02d:%02d", hours, minutes, seconds % 60)
    end
    return string.format("%02d:%02d", minutes, seconds % 60)
end local healthColor=function(

ratio)    
return (ratio > 0.5 and{(colors.success )}or{((ratio > 0.25 and{(colors.corona )}or{(colors.danger
)})[1])})[1]end local meter=function(

parent, properties, fillColor)    
local track = create("Frame", {
        BackgroundColor3 = colors.field,
        BorderSizePixel = 0,
        Parent = parent,
    }, { corner(3) })
    for property, value in properties do
        track[property] = value
    end
    local fill = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = fillColor,
        BorderSizePixel = 0,
        Parent = track,
    }, { corner(3) })
    return track, fill
end local chip=function(

parent, label, color, properties)    
local instance = text({
        Size = UDim2.fromOffset(24, 14),
        BackgroundColor3 = color,
        BackgroundTransparency = 0,
        Text = label,
        Font = fonts.bold,
        TextSize = 9,
        TextColor3 = Color3.fromRGB(10, 12, 18),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = Enum.TextTruncate.None,
        Visible = false,
        Parent = parent,
    })
    corner(3).Parent = instance
    for property, value in properties or {} do
        instance[property] = value
    end
    return instance
end local horizontalList=function(

parent, properties, alignment)    
local holder = create("Frame", {
        BackgroundTransparency = 1,
        Parent = parent,
    }, {
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = alignment or Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })
    for property, value in properties do
        holder[property] = value
    end
    return holder
end local teamKills=function(

entry)    
local kills, iridium = 0, 0
    for _, info in entry.players do
        local record = info.record
        if record then
            kills =kills+ record.kills
            iridium =iridium+ record.iridium
        end
    end
    return kills, iridium
end local aliveCount=function(

entry)    
local alive = 0
    for _, info in entry.players do
        if info.alive then
            alive =alive+ 1
        end
    end
    return alive
end

function Hud.new(roster, cameraController, tracker, parent)
    local self = setmetatable({
        roster = roster,
        cameraController = cameraController,
        tracker = tracker,
        parent = parent,
        cards = {},
        renderedVersion = -1,
        nextRefresh = 0,
        feed = {},
    }, Hud)

    self:_buildScorebar()
    self:_buildColumns()
    self:_buildFocus()
    self:_buildFeed()
    self:_buildControls()

    tracker:onEvent(function(event)
        self:_pushFeed(event)
    end)
    cameraController:onChanged(function()
        self.nextRefresh = 0
    end)

    return self
end

-- scorebar

function Hud:_buildTeamSide(bar, sideName)
    local isLeft = sideName == "left"
    local alignment = (isLeft and{(Enum.TextXAlignment.Right )}or{(Enum.TextXAlignment.Left
)})[1]    local holder = create("Frame", {
        AnchorPoint = Vector2.new(isLeft and 1 or 0, 0),
        Position = UDim2.new(0.5, isLeft and-62 or 62, 0, 0),
        Size = UDim2.new(0, 250, 1, 0),
        BackgroundColor3 = colors.panel,
        BackgroundTransparency = 0.1,
        Parent = bar,
    }, { corner(8) })
    local side = {}
    side.holder = holder

    side.glow = create("UIGradient", {
        Rotation = isLeft and 180 or 0,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.35),
            NumberSequenceKeypoint.new(1, 1),
        }),
    })
    side.tint = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BorderSizePixel = 0,
        Parent = holder,
    }, { corner(8), side.glow })

    side.edge = create("Frame", {
        AnchorPoint = Vector2.new(isLeft and 0 or 1, 0),
        Position = UDim2.fromScale(isLeft and 0 or 1, 0),
        Size = UDim2.new(0, 4, 1, 0),
        BorderSizePixel = 0,
        Parent = holder,
    }, { corner(2) })

    side.score = text({
        AnchorPoint = Vector2.new(isLeft and 1 or 0, 0),
        Position = UDim2.new(isLeft and 1 or 0, isLeft and-12 or 12, 0, 4),
        Size = UDim2.fromOffset(60, 40),
        Font = fonts.black,
        TextSize = 34,
        TextXAlignment = alignment,
        TextTruncate = Enum.TextTruncate.None,
        Text = "0",
        Parent = holder,
    })
    side.killsLabel = text({
        AnchorPoint = Vector2.new(isLeft and 1 or 0, 0),
        Position = UDim2.new(isLeft and 1 or 0, isLeft and-12 or 12, 0, 42),
        Size = UDim2.fromOffset(60, 12),
        Font = fonts.mono,
        TextSize = 9,
        TextColor3 = colors.muted,
        TextXAlignment = alignment,
        Text = "KILLS",
        Parent = holder,
    })

    local nameX = isLeft and-80 or 80
    side.name = text({
        AnchorPoint = Vector2.new(isLeft and 1 or 0, 0),
        Position = UDim2.new(isLeft and 1 or 0, nameX, 0, 8),
        Size = UDim2.fromOffset(150, 18),
        Font = fonts.bold,
        TextSize = 16,
        TextXAlignment = alignment,
        Parent = holder,
    })
    side.sub = text({
        AnchorPoint = Vector2.new(isLeft and 1 or 0, 0),
        Position = UDim2.new(isLeft and 1 or 0, nameX, 0, 27),
        Size = UDim2.fromOffset(150, 12),
        Font = fonts.mono,
        TextSize = 10,
        TextColor3 = colors.textDim,
        TextXAlignment = alignment,
        RichText = true,
        Parent = holder,
    })
    -- beacon pips, filled as each one goes down
    side.beacons = horizontalList(holder, {
        AnchorPoint = Vector2.new(isLeft and 1 or 0, 0),
        Position = UDim2.new(isLeft and 1 or 0, nameX, 0, 42),
        Size = UDim2.fromOffset(150, 12),
    }, (isLeft and{(Enum.HorizontalAlignment.Right )}or{(Enum.HorizontalAlignment.Left)})[1])
    side.beaconPips = {}

    return side
end

function Hud:_buildScorebar()
    local bar = create("Frame", {
        Name = "Scorebar",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 10),
        Size = UDim2.fromOffset(624, 60),
        BackgroundTransparency = 1,
        Parent = self.parent,
    })
    self.scorebar = bar

    local center = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, 0),
        Size = UDim2.fromOffset(116, 60),
        BackgroundColor3 = colors.background,
        BackgroundTransparency = 0.05,
        Parent = bar,
    }, { corner(8), stroke(colors.stroke) })

    self.timer = text({
        Position = UDim2.fromOffset(0, 8),
        Size = UDim2.new(1, 0, 0, 24),
        Font = fonts.mono,
        TextSize = 22,
        TextXAlignment = Enum.TextXAlignment.Center,
        Text = "00:00",
        Parent = center,
    })
    local live = horizontalList(center, {
        Position = UDim2.fromOffset(0, 36),
        Size = UDim2.new(1, 0, 0, 14),
    }, Enum.HorizontalAlignment.Center)
    self.liveDot = create("Frame", {
        Size = UDim2.fromOffset(6, 6),
        BackgroundColor3 = colors.danger,
        BorderSizePixel = 0,
        Parent = live,
    }, { corner() })
    text({
        Size = UDim2.fromOffset(78, 14),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = fonts.bold,
        TextSize = 9,
        TextColor3 = colors.textDim,
        Text = "LIVE  VIEWER",
        LayoutOrder = 1,
        Parent = live,
    })

    self.sides = {
        self:_buildTeamSide(bar, "left"),
        self:_buildTeamSide(bar, "right"),
    }

    -- matches with more than two teams list the rest under the bar
    self.extraTeams = text({
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 1, 6),
        Size = UDim2.fromOffset(600, 14),
        Font = fonts.mono,
        TextSize = 10,
        TextColor3 = colors.textDim,
        TextXAlignment = Enum.TextXAlignment.Center,
        RichText = true,
        Parent = bar,
    })
end

function Hud:_updateSide(side, entry)
    side.holder.Visible = entry ~= nil
    if not entry then
        return
    end

    local color = entry.color
    side.tint.BackgroundColor3 = color
    side.edge.BackgroundColor3 = color
    side.name.Text = string.upper(entry.name)
    side.name.TextColor3 = color:Lerp(Color3.new(1, 1, 1), 0.35)

    local kills, iridium = teamKills(entry)
    side.score.Text = tostring(kills)

    local alive = aliveCount(entry)
    side.sub.Text = string.format('<font color="%s">%s</font>/%s UP  \u{b7}  %s IRID', tostring(theme.hex(colors.text)), tostring(alive), tostring(#entry.players), tostring(theme.compact(iridium)))
    
local required = entry.beaconsRequired
    local pips = side.beaconPips
    local wanted = (typeof(required) == "number" and{(math.clamp(required, 0, 10) )}or{0
})[1]    for index = #pips + 1, wanted do
        local holder = create("Frame", {
            Size = UDim2.fromOffset(12, 12),
            BackgroundTransparency = 1,
            LayoutOrder = index,
            Parent = side.beacons,
        })
        pips[index] = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(7, 7),
            Rotation = 45,
            BorderSizePixel = 0,
            Parent = holder,
        }, { corner(1) })
    end
    for index, pip in pips do
        pip.Parent.Visible = index <= wanted
        local placed = index <= entry.beacons
        pip.BackgroundColor3 = (placed and{(color:Lerp(Color3.new(1, 1, 1), 0.2) )}or{(colors.field
)})[1]    end
end

function Hud:_updateScorebar()
    self.timer.Text = formatTime(self.tracker:getElapsed())
    self.liveDot.BackgroundTransparency = os.clock() % 1.6 < 0.8 and 0 or 0.6

    local teams = self.roster.teams
    self:_updateSide(self.sides[1], teams[1])
    self:_updateSide(self.sides[2], teams[2])

    local extra = {}
    for index = 3, #teams do
        local entry = teams[index]
        local kills = teamKills(entry)
        table.insert(
            extra,
string.format('<font color="%s">%s</font> %s KILLS \u{b7} %s/%s UP', tostring(theme.hex(entry.color)), tostring(string.upper(entry.name)), tostring(kills), tostring(aliveCount(entry)), tostring(#entry.players))        
)
    end
    self.extraTeams.Text = table.concat(extra, "     ")
end

-- player cards

function Hud:_buildColumns()
local column=function(side)        
local isLeft = side == "left"
        return create("Frame", {
            Name = isLeft and"LeftTeam" or"RightTeam",
            AnchorPoint = Vector2.new(isLeft and 0 or 1, 0.5),
            Position = UDim2.new(isLeft and 0 or 1, isLeft and 16 or-16, 0.56, 0),
            Size = UDim2.fromOffset(CARD_WIDTH, 400),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = self.parent,
        }, {
            create("UIListLayout", {
                Padding = UDim.new(0, CARD_GAP),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            }),
        })
end    
self.columns = { column("left"), column("right") }
end

function Hud:_createCard(info, parent, compact, mirrored)
    local height = (compact and{CARD_HEIGHT_COMPACT }or{CARD_HEIGHT
})[1]    local card = { info = info, compact = compact }

    local frame = create("TextButton", {
        Size = UDim2.fromOffset(CARD_WIDTH, height),
        BackgroundColor3 = colors.panel,
        BackgroundTransparency = 0.12,
        AutoButtonColor = false,
        Text = "",
        LayoutOrder = info.number,
        Parent = parent,
    }, { corner(8) })
    card.frame = frame
    card.outline = stroke(colors.stroke)
    card.outline.Parent = frame

    card.strip = create("Frame", {
        AnchorPoint = Vector2.new(mirrored and 1 or 0, 0),
        Position = UDim2.new(mirrored and 1 or 0, 0, 0, 8),
        Size = UDim2.new(0, 3, 1, -16),
        BorderSizePixel = 0,
        Parent = frame,
    }, { corner(2) })

    local avatarSize = compact and 32 or 40
    card.avatar = create("ImageLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 12, 0.5, 0),
        Size = UDim2.fromOffset(avatarSize, avatarSize),
        BackgroundColor3 = colors.raised,
        Image = theme.headshot(info.userId),
        Parent = frame,
    }, { corner(6) })
    card.number = text({
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, -3, 1, 3),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = colors.background,
        Font = fonts.mono,
        TextSize = 9,
        TextColor3 = colors.textDim,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = Enum.TextTruncate.None,
        Text = tostring(info.number % 10),
        Parent = card.avatar,
    })
    corner(4).Parent = card.number

    local x = 12 + avatarSize + 10
    local barWidth = CARD_WIDTH - x - 74
    card.name = text({
        Position = UDim2.fromOffset(x, compact and 5 or 7),
        Size = UDim2.fromOffset(barWidth + 14, 16),
        Font = fonts.bold,
        TextSize = 13,
        Text = info.displayName,
        Parent = frame,
    })

    local healthY = compact and 23 or 27
local _, health =meter(frame, {
        Position = UDim2.fromOffset(x, healthY),
        Size = UDim2.fromOffset(barWidth, 5),
    }, colors.success)
    card.health = health
    card.healthText = text({
        Position = UDim2.fromOffset(x + barWidth + 6, healthY - 4),
        Size = UDim2.fromOffset(40, 12),
        Font = fonts.mono,
        TextSize = 10,
        Parent = frame,
    })
    card.iridiumTrack, card.iridium = meter(frame, {
        Position = UDim2.fromOffset(x, healthY + 8),
        Size = UDim2.fromOffset(barWidth, 3),
    }, colors.accent)
    theme.bind(card.iridium, "BackgroundColor3", "accent")

    card.tool = text({
        Position = UDim2.fromOffset(x, healthY + 13),
        Size = UDim2.fromOffset(barWidth + 30, 11),
        Font = fonts.mono,
        TextSize = 9,
        TextColor3 = colors.muted,
        Visible = not compact,
        Parent = frame,
    })

    card.kd = text({
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -10, 0, compact and 5 or 7),
        Size = UDim2.fromOffset(56, 16),
        Font = fonts.mono,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        RichText = true,
        Parent = frame,
    })
    card.chips = horizontalList(frame, {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -10, 0, compact and 24 or 30),
        Size = UDim2.fromOffset(56, 14),
    }, Enum.HorizontalAlignment.Right)
    card.ls = chip(card.chips, "LS", LS_COLOR)
    card.os = chip(card.chips, "OS", OS_COLOR, { LayoutOrder = 1 })

    card.dead = text({
        Position = UDim2.fromOffset(x + barWidth + 6, healthY - 4),
        Size = UDim2.fromOffset(40, 12),
        Font = fonts.bold,
        TextSize = 9,
        TextColor3 = colors.danger,
        Text = "DEAD",
        Visible = false,
        Parent = frame,
    })

    frame.MouseEnter:Connect(function()
        card.hovered = true
        self:_paintCard(card)
    end)
    frame.MouseLeave:Connect(function()
        card.hovered = false
        self:_paintCard(card)
    end)
    frame.MouseButton1Click:Connect(function()
        self.cameraController:setTarget(info)
    end)

    return card
end

function Hud:_paintCard(card)
    local info = card.info
    local controller = self.cameraController
    local watched = controller.mode ~= "free" and controller.target == info

    card.outline.Color = (watched and{(colors.accent )}or{((card.hovered and{(colors.strokeBright )}or{(colors.stroke
)})[1])})[1]    card.outline.Thickness = watched and 1.5 or 1
    card.frame.BackgroundColor3 = (not info.alive and{DEAD_TINT }or{(((watched or card.hovered )and{(colors.raised )}or{(colors.panel
)})[1])})[1]end

function Hud:_rebuildCards()
    for _, card in self.cards do
        card.frame:Destroy()
    end
    self.cards = {}

    for index, entry in self.roster.teams do
        -- teams past the second share the columns, alternating sides
        local columnIndex = (index - 1) % 2 + 1
        local column = self.columns[columnIndex]
        local compact = #entry.players > 6
        for _, info in entry.players do
            self.cards[info] = self:_createCard(info, column, compact, columnIndex == 2)
        end
    end
end

function Hud:_updateCard(card)
    local info = card.info
    local alive = info.alive

    card.strip.BackgroundColor3 = info.teamColor
    card.name.TextColor3 = (alive and{(colors.text )}or{(colors.muted
)})[1]    card.avatar.ImageTransparency = alive and 0 or 0.6
    card.number.Text = tostring(info.number % 10)
    card.frame.LayoutOrder = info.number

    local ratio = (alive and{(math.clamp(info.health / info.maxHealth, 0, 1) )}or{0
})[1]    card.health.Size = UDim2.fromScale(ratio, 1)
    card.health.BackgroundColor3 = healthColor(ratio)
    card.healthText.Visible = alive
    card.healthText.Text = tostring(math.round(info.health))
    card.dead.Visible = not alive

    card.iridiumTrack.Visible = alive and info.iridium ~= nil
    if info.iridium then
        card.iridium.Size = UDim2.fromScale(info.iridium, 1)
    end

    card.tool.Text = (alive and info.tool and{(string.upper(info.tool) )}or{""
})[1]
    local record = info.record
    local kills = record and record.kills or 0
    local deaths = record and record.deaths or 0
    card.kd.Text = string.format('%s<font color="%s"> / </font><font color="%s">%s</font>', tostring(kills), tostring(theme.hex(colors.faint)), tostring(theme.hex(colors.muted)), tostring(deaths))
    
card.ls.Visible = alive and info.ls > 0
    card.ls.Text = (info.ls > 1 and{(string.format('LS%s', tostring(info.ls)))}or{"LS"
})[1]    card.os.Visible = alive and info.os > 0
    card.os.Text = (info.os > 1 and{(string.format('OS%s', tostring(info.os)))}or{"OS"
})[1]
    self:_paintCard(card)
end

-- watched player

function Hud:_buildFocus()
    local panel = create("Frame", {
        Name = "Focus",
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -16),
        Size = UDim2.fromOffset(600, 122),
        BackgroundColor3 = colors.background,
        BackgroundTransparency = 0.08,
        Parent = self.parent,
    }, { corner(10), stroke(colors.stroke) })
    self.focus = { panel = panel }
    local focus = self.focus

    -- camera mode tab sitting on the panel's top edge
    focus.mode = text({
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 0, -6),
        Size = UDim2.fromOffset(0, 18),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = colors.panel,
        Font = fonts.bold,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = Enum.TextTruncate.None,
        RichText = true,
        Parent = panel,
    })
    corner(5).Parent = focus.mode
    theme.padding(10, 10, 0, 0).Parent = focus.mode

    focus.glow = create("Frame", {
        Size = UDim2.new(0, 220, 1, 0),
        BorderSizePixel = 0,
        Parent = panel,
    }, {
        corner(10),
        create("UIGradient", {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.7),
                NumberSequenceKeypoint.new(1, 1),
            }),
        }),
    })

    focus.avatar = create("ImageLabel", {
        Position = UDim2.fromOffset(16, 16),
        Size = UDim2.fromOffset(90, 90),
        BackgroundColor3 = colors.raised,
        Parent = panel,
    }, { corner(10) })
    focus.avatarStroke = stroke(colors.strokeBright, 2)
    focus.avatarStroke.Parent = focus.avatar

    focus.name = text({
        Position = UDim2.fromOffset(122, 14),
        Size = UDim2.fromOffset(230, 22),
        Font = fonts.black,
        TextSize = 20,
        Parent = panel,
    })
    focus.sub = text({
        Position = UDim2.fromOffset(122, 37),
        Size = UDim2.fromOffset(230, 13),
        Font = fonts.mono,
        TextSize = 10,
        TextColor3 = colors.muted,
        RichText = true,
        Parent = panel,
    })
local
_, health =meter(panel, {
        Position = UDim2.fromOffset(122, 58),
        Size = UDim2.fromOffset(170, 8),
    }, colors.success)
    focus.health = health
    focus.healthText = text({
        Position = UDim2.fromOffset(298, 54),
        Size = UDim2.fromOffset(60, 14),
        Font = fonts.mono,
        TextSize = 11,
        Parent = panel,
    })
    focus.iridiumTrack, focus.iridium = meter(panel, {
        Position = UDim2.fromOffset(122, 72),
        Size = UDim2.fromOffset(170, 6),
    }, colors.accent)
    theme.bind(focus.iridium, "BackgroundColor3", "accent")
    focus.iridiumText = text({
        Position = UDim2.fromOffset(298, 68),
        Size = UDim2.fromOffset(60, 14),
        Font = fonts.mono,
        TextSize = 11,
        Parent = panel,
    })
    theme.bind(focus.iridiumText, "TextColor3", "accent")

    -- tool, orbitals and suit upgrades along the bottom
    focus.gear = horizontalList(panel, {
        Position = UDim2.fromOffset(122, 88),
        Size = UDim2.fromOffset(240, 18),
    })
    focus.tool = text({
        Size = UDim2.fromOffset(0, 18),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = fonts.mono,
        TextSize = 10,
        TextColor3 = colors.textDim,
        Parent = focus.gear,
    })
    focus.ls = chip(focus.gear, "LS", LS_COLOR, { LayoutOrder = 1, Size = UDim2.fromOffset(26, 16) })
    focus.os = chip(focus.gear, "OS", OS_COLOR, { LayoutOrder = 2, Size = UDim2.fromOffset(26, 16) })

    focus.upgrades = horizontalList(panel, {
        Position = UDim2.fromOffset(122, 104),
        Size = UDim2.fromOffset(240, 12),
    })
    focus.upgradeLabels = {}
    for index, upgrade in Roster.UPGRADES do
        focus.upgradeLabels[upgrade.key] = text({
            Size = UDim2.fromOffset(0, 12),
            AutomaticSize = Enum.AutomaticSize.X,
            Font = fonts.mono,
            TextSize = 9,
            TextColor3 = colors.muted,
            RichText = true,
            LayoutOrder = index,
            Parent = focus.upgrades,
        })
    end

    -- match stats on the right
    local grid = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.fromOffset(224, 90),
        BackgroundTransparency = 1,
        Parent = panel,
    }, {
        create("UIGridLayout", {
            CellSize = UDim2.fromOffset(53, 42),
            CellPadding = UDim2.fromOffset(4, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })
    focus.stats = {}
    local statList = {
        { key = "kills", label = "KILLS" },
        { key = "deaths", label = "DEATHS" },
        { key = "structures", label = "BUILT" },
        { key = "iridium", label = "IRID", compact = true },
        { key = "ls", label = "LS" },
        { key = "os", label = "OS" },
        { key = "arty", label = "ARTY" },
        { key = "bores", label = "BORES" },
    }
    for index, stat in statList do
        local cell = create("Frame", {
            BackgroundColor3 = colors.panel,
            LayoutOrder = index,
            Parent = grid,
        }, { corner(6) })
        local value = text({
            Position = UDim2.fromOffset(0, 5),
            Size = UDim2.new(1, 0, 0, 20),
            Font = fonts.bold,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = cell,
        })
        text({
            Position = UDim2.fromOffset(0, 26),
            Size = UDim2.new(1, 0, 0, 10),
            Font = fonts.mono,
            TextSize = 8,
            TextColor3 = colors.muted,
            TextXAlignment = Enum.TextXAlignment.Center,
            Text = stat.label,
            Parent = cell,
        })
        focus.stats[stat.key] = { label = value, compact = stat.compact }
    end
    focus.grid = grid

    -- shown instead of the player while the freecam is on
    focus.free = text({
        Position = UDim2.fromOffset(20, 0),
        Size = UDim2.new(1, -40, 1, 0),
        Font = fonts.mono,
        TextSize = 12,
        TextColor3 = colors.textDim,
        TextXAlignment = Enum.TextXAlignment.Center,
        RichText = true,
        TextWrapped = true,
        Visible = false,
        Parent = panel,
    })
    focus.playerViews = { focus.glow, focus.avatar, focus.name, focus.sub, focus.health.Parent, focus.healthText,
        focus.iridiumTrack, focus.iridiumText, focus.gear, focus.upgrades, grid }
end

function Hud:_updateFocus()
    local focus = self.focus
    local controller = self.cameraController
    local free = controller.mode == "free"
    local info = controller.target

    local accent = theme.hex(colors.accent)
    local noclip = (controller.noclip and{(string.format('  <font color="%s">NOCLIP</font>', tostring(theme.hex(colors.corona))))}or{""
})[1]    focus.mode.Text = string.format('<font color="%s">\u{25cf}</font>  %s%s', tostring(accent), tostring(Camera.MODE_NAMES[controller.mode]), tostring(noclip))
    
local showPlayer = not free and info ~= nil
    for _, view in focus.playerViews do
        view.Visible = showPlayer
    end
    focus.free.Visible = not showPlayer

    if not showPlayer then
        local position = workspace.CurrentCamera.CFrame.Position
        local hint = (free
and{(string.format('WASD fly  \u{b7}  Q / E down, up  \u{b7}  Shift fast  \u{b7}  Wheel speed <font color="%s">%s</font>', tostring(accent), tostring(controller:freeSpeedValue())))}or{
"waiting for players"
})[1]        focus.free.Text = string.format('<font color="%s"><b>FREECAM</b></font>\n%s\n<font color="%s">%s, %s, %s  \u{b7}  click a player card or press 1 - 0 to follow</font>', tostring(theme.hex(colors.text)), tostring(hint), tostring(theme.hex(colors.faint)), tostring(math.round(position.X)), tostring(math.round(position.Y)), tostring(math.round(position.Z)))        
return
    end

    local color = info.teamColor
    focus.glow.BackgroundColor3 = color
    focus.avatarStroke.Color = color
    focus.avatar.Image = theme.headshot(info.userId)
    focus.avatar.ImageTransparency = info.alive and 0 or 0.55
    focus.name.Text = info.displayName

    local teamName = (info.team and{(string.upper(info.team.Name) )}or{"NO TEAM"
})[1]    local status = info.alive and"" or string.format('  <font color="%s">DEAD</font>', tostring(theme.hex(colors.danger)))    
focus.sub.Text = string.format('@%s  \u{b7}  <font color="%s">%s</font>%s', tostring(info.name), tostring(theme.hex(color)), tostring(teamName), tostring(status))
    
local ratio = (info.alive and{(math.clamp(info.health / info.maxHealth, 0, 1) )}or{0
})[1]    focus.health.Size = UDim2.fromScale(ratio, 1)
    focus.health.BackgroundColor3 = healthColor(ratio)
    focus.healthText.Text = (info.alive and{(string.format('%s/%s', tostring(math.round(info.health)), tostring(math.round(info.maxHealth))))}or{"—"
})[1]    focus.healthText.TextColor3 = healthColor(ratio)

    local iridium = (info.alive and{(info.iridium )}or{nil
})[1]    focus.iridium.Size = UDim2.fromScale(iridium or 0, 1)
    focus.iridiumText.Text = (iridium and{(string.format('%s%%', tostring(math.floor(iridium * 100))))}or{"—"
})[1]
    focus.tool.Text = (info.alive and info.tool and{(string.upper(info.tool) )}or{"NOTHING HELD"
})[1]    focus.ls.Visible = info.alive and info.ls > 0
    focus.os.Visible = info.alive and info.os > 0

    local dim = theme.hex(colors.faint)
    for _, upgrade in Roster.UPGRADES do
        local level = info.upgrades[upgrade.key] or 0
        focus.upgradeLabels[upgrade.key].Text = string.format('%s <font color="%s">%s</font>  ', tostring(upgrade.label), tostring((level > 0 and{(theme.hex(colors.text) )}or{dim})[1]), tostring(level))    
end

    local record = info.record
    for key, stat in focus.stats do
        local value = record and record[key] or 0
        stat.label.Text = (stat.compact and{(theme.compact(value) )}or{(tostring(value)
)})[1]        stat.label.TextColor3 = (value == 0 and{(colors.faint )}or{(colors.text
)})[1]    end
end

-- feed

function Hud:_buildFeed()
    self.feedList = create("Frame", {
        Name = "Feed",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -16, 0, 64),
        Size = UDim2.fromOffset(360, 200),
        BackgroundTransparency = 1,
        Parent = self.parent,
    }, {
        create("UIListLayout", {
            Padding = UDim.new(0, 4),
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })
    self.feedOrder = 0
end
local isPlaying=function(
record)    
return record ~= nil and record.teamName ~= nil and record.teamName ~= "Spectators"
end local nameOf=function(

record)    
local color = record.teamColor or colors.textDim
    return string.format('<font color="%s"><b>%s</b></font>', tostring(theme.hex(color:Lerp(Color3.new(1, 1, 1), 0.25))), tostring(record.displayName))end


function Hud:_pushFeed(event)
    if self.destroyed then
        return
    end
    local message
    local involved = {}

    if event.kind == "kill" then
        if not (isPlaying(event.killer) and isPlaying(event.victim)) then
            return
        end
        local weapon = (event.weapon == "Laser Strike"
and{(string.format('<font color="%s">[LASER STRIKE]</font>', tostring(theme.hex(LS_COLOR))))}or{(string.format('<font color="%s">[KILL]</font>', tostring(
theme.hex(colors.muted))))})[1]        
message = string.format('%s  %s  %s', tostring(nameOf(event.killer)), tostring(weapon), tostring(nameOf(event.victim)))        
involved = { event.killer, event.victim }
    elseif event.kind == "death" then
        if not isPlaying(event.victim) then
            return
        end
        message = string.format('%s  <font color="%s">died</font>', tostring(nameOf(event.victim)), tostring(theme.hex(colors.muted)))        
involved = { event.victim }
    elseif event.kind == "ls" or event.kind == "os" then
        if not isPlaying(event.record) then
            return
        end
        local label = (event.kind == "ls"
and{(string.format('<font color="%s">LASER STRIKE</font>', tostring(theme.hex(LS_COLOR))))}or{(string.format('<font color="%s">ORBITAL SHIELD</font>', tostring(
theme.hex(OS_COLOR))))})[1]        
message = string.format('%s  <font color="%s">used</font>  %s', tostring(nameOf(event.record)), tostring(theme.hex(colors.faint)), tostring(label))        
involved = { event.record }
    else
        return
    end

    -- the watched player's lines get an outline, the way your own kills do in cs
    local target = self.cameraController.target
    local mine = false
    for _, record in involved do
        if target and record.userId == target.userId then
            mine = true
        end
    end

    self.feedOrder =self.feedOrder- 1
    local entry = text({
        Size = UDim2.fromOffset(0, 24),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = colors.background,
        BackgroundTransparency = 0.2,
        Font = fonts.medium,
        TextSize = 12,
        TextTruncate = Enum.TextTruncate.None,
        RichText = true,
        Text = message,
        LayoutOrder = self.feedOrder,
        Parent = self.feedList,
    })
    corner(6).Parent = entry
    theme.padding(10, 10, 0, 0).Parent = entry
    local outline = stroke((mine and{(colors.accent )}or{(colors.stroke)})[1], mine and 1.5 or 1)
    outline.Parent = entry

    table.insert(self.feed, 1, entry)
    while #self.feed > FEED_MAX do
        table.remove(self.feed):Destroy()
    end

    task.delay(FEED_LIFETIME, function()
        if entry.Parent then
            theme.tween(entry, 0.4, { BackgroundTransparency = 1, TextTransparency = 1 })
            theme.tween(outline, 0.4, { Transparency = 1 })
            task.wait(0.45)
            local index = table.find(self.feed, entry)
            if index then
                table.remove(self.feed, index)
            end
            entry:Destroy()
        end
    end)
end

-- controls

function Hud:_buildControls()
    local panel = create("Frame", {
        Name = "Controls",
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 16, 1, -16),
        Size = UDim2.fromOffset(230, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = colors.background,
        BackgroundTransparency = 0.25,
        Parent = self.parent,
    }, {
        corner(8),
        theme.padding(10, 10, 8, 8),
        create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
    })
    for index, control in CONTROLS do
        local row = create("Frame", {
            Size = UDim2.new(1, 0, 0, 14),
            BackgroundTransparency = 1,
            LayoutOrder = index,
            Parent = panel,
        })
        local key = text({
            Size = UDim2.fromOffset(62, 14),
            Font = fonts.bold,
            TextSize = 9,
            Text = control[1],
            Parent = row,
        })
        theme.bind(key, "TextColor3", "accent")
        text({
            Position = UDim2.fromOffset(66, 0),
            Size = UDim2.new(1, -66, 0, 14),
            Font = fonts.body,
            TextSize = 10,
            TextColor3 = colors.muted,
            Text = control[2],
            Parent = row,
        })
    end
    self.controls = panel
end

-- call every frame, after the roster
function Hud:update()
    local now = os.clock()
    if now < self.nextRefresh then
        return
    end
    self.nextRefresh = now + REFRESH

    if self.roster.version ~= self.renderedVersion then
        self.renderedVersion = self.roster.version
        self:_rebuildCards()
    end

    self:_updateScorebar()
    for _, card in self.cards do
        self:_updateCard(card)
    end
    self:_updateFocus()
end

return Hud
end function dote.l()local v=dote.cache.l if not v then v={c=__modImpl()}dote.cache.l=v end return v.c end end do local __modImpl=function()-- a broadcast-style tag over every player: name in their team color, health and iridium bars, the orbitals
-- they carry and what's in their hands, plus a team colored outline through walls so you can always see
-- where everyone is. players off screen get a marker on the edge pointing their way.


local theme = dote.b()

local colors = theme.colors
local fonts = theme.fonts
local create = theme.create
local corner = theme.corner
local text = theme.text

local TAG_WIDTH = 132
local EDGE_MARGIN = 26
-- tags shrink with distance down to this scale, and fade out past FADE_START
local MIN_SCALE = 0.7
local FADE_START = 450

local LS_COLOR = Color3.fromRGB(255, 170, 60)
local OS_COLOR = Color3.fromRGB(80, 170, 255)

local Tags = {}
Tags.__index = Tags

-- parent: a ScreenGui that ignores the gui inset and isn't scaled, so screen points from the camera land
-- where they should
function Tags.new(roster, cameraController, parent)
    local self = setmetatable({
        roster = roster,
        cameraController = cameraController,
        enabled = true,
        tags = {},
        layer = create("Frame", {
            Name = "Tags",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Parent = parent,
        }),
    }, Tags)
    return self
end
local bar=function(
parent, y, color)    
local track = create("Frame", {
        Position = UDim2.fromOffset(0, y),
        Size = UDim2.new(1, 0, 0, 3),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
        Parent = parent,
    }, { corner(2) })
    local fill = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = track,
    }, { corner(2) })
    return track, fill
end local chip=function(

parent, label, color)    
local instance = text({
        Size = UDim2.fromOffset(22, 13),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.15,
        Text = label,
        Font = fonts.bold,
        TextSize = 9,
        TextColor3 = Color3.fromRGB(10, 12, 18),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = Enum.TextTruncate.None,
        Visible = false,
        Parent = parent,
    })
    corner(3).Parent = instance
    return instance
end

function Tags:_create(info)
    local tag = {}

    tag.frame = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        Size = UDim2.fromOffset(TAG_WIDTH, 44),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = self.layer,
    })
    tag.scale = create("UIScale", { Parent = tag.frame })
    tag.group = create("CanvasGroup", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Parent = tag.frame,
    })

    tag.name = text({
        Size = UDim2.new(1, 0, 0, 15),
        Font = fonts.bold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextStrokeTransparency = 0.55,
        Text = info.displayName,
        Parent = tag.group,
    })
    tag.detail = text({
        Position = UDim2.fromOffset(0, 14),
        Size = UDim2.new(1, 0, 0, 12),
        Font = fonts.mono,
        TextSize = 10,
        TextColor3 = colors.textDim,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextStrokeTransparency = 0.6,
        Parent = tag.group,
    })

    local bars = create("Frame", {
        Position = UDim2.new(0.5, -40, 0, 29),
        Size = UDim2.fromOffset(80, 10),
        BackgroundTransparency = 1,
        Parent = tag.group,
    })
local _, health =bar(bars, 0, colors.success)
    tag.health = health
    tag.iridiumTrack, tag.iridium = bar(bars, 5, colors.accent)

    tag.chips = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0.5, 44, 0, 33),
        Size = UDim2.fromOffset(60, 13),
        BackgroundTransparency = 1,
        Parent = tag.group,
    }, {
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 3),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })
    tag.ls = chip(tag.chips, "LS", LS_COLOR)
    tag.os = chip(tag.chips, "OS", OS_COLOR)

    -- edge marker for players off screen: a team colored dot with their name
    tag.edge = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(12, 12),
        BorderSizePixel = 0,
        Visible = false,
        Parent = self.layer,
    }, { corner() })
    tag.edgeStroke = theme.stroke(Color3.new(0, 0, 0), 1.5, 0.3)
    tag.edgeStroke.Parent = tag.edge
    tag.edgeName = text({
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 1, 2),
        Size = UDim2.fromOffset(120, 12),
        Font = fonts.medium,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextStrokeTransparency = 0.5,
        Text = info.displayName,
        Parent = tag.edge,
    })

    tag.highlight = create("Highlight", {
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
        FillTransparency = 0.88,
        OutlineTransparency = 0.15,
        Enabled = false,
    })

    -- last written values, so instances are only touched when something changed
    tag.last = {}
    return tag
end

function Tags:_destroy(tag)
    tag.frame:Destroy()
    tag.edge:Destroy()
    tag.highlight:Destroy()
end
local set=function(
tag, key, instance, property, value)    
if tag.last[key] ~= value then
        tag.last[key] = value
        instance[property] = value
    end
end

function Tags:_hide(tag)
    set(tag, "visible", tag.frame, "Visible", false)
    set(tag, "edge", tag.edge, "Visible", false)
end

function Tags:_updateTag(tag, info, camera, viewport)
    local character = info.character
    local highlight = tag.highlight

    if not (self.enabled and info.alive and character and info.position) then
        self:_hide(tag)
        if highlight.Enabled then
            highlight.Enabled = false
        end
        return
    end

    -- outline
    if highlight.Parent ~= character then
        highlight.Parent = character
    end
    set(tag, "outline", highlight, "OutlineColor", info.teamColor)
    set(tag, "fill", highlight, "FillColor", info.teamColor)
    if not highlight.Enabled then
        highlight.Enabled = true
    end

    local headPosition = info.position + Vector3.new(0, 3.2, 0)
    local point, onScreen = camera:WorldToViewportPoint(headPosition)
    local distance = (camera.CFrame.Position - info.position).Magnitude

    if onScreen then
        set(tag, "edge", tag.edge, "Visible", false)
        set(tag, "visible", tag.frame, "Visible", true)
        tag.frame.Position = UDim2.fromOffset(math.round(point.X), math.round(point.Y))

        local scale = math.clamp(1.15 - distance / 400, MIN_SCALE, 1)
        set(tag, "scale", tag.scale, "Scale", math.round(scale * 20) / 20)
        local fade = math.clamp((distance - FADE_START) / 400, 0, 0.55)
        set(tag, "fade", tag.group, "GroupTransparency", math.round(fade * 20) / 20)

        set(tag, "nameColor", tag.name, "TextColor3", info.teamColor)

        local detail = string.format('%sm', tostring(math.round(distance)))        
if info.tool then
            detail = string.format('%s  \u{b7}  %s', tostring(string.upper(info.tool)), tostring(detail))        
end
        set(tag, "detail", tag.detail, "Text", detail)

        local healthRatio = math.clamp(info.health / info.maxHealth, 0, 1)
        set(tag, "health", tag.health, "Size", UDim2.fromScale(math.round(healthRatio * 50) / 50, 1))
        set(
            tag,
            "healthColor",
            tag.health,
            "BackgroundColor3",
(healthRatio > 0.5 and{(colors.success )}or{((healthRatio > 0.25 and{(colors.corona )}or{(colors.danger
)})[1])})[1]        )

        set(tag, "hasIridium", tag.iridiumTrack, "Visible", info.iridium ~= nil)
        if info.iridium then
            set(tag, "iridium", tag.iridium, "Size", UDim2.fromScale(math.round(info.iridium * 50) / 50, 1))
        end

        set(tag, "ls", tag.ls, "Visible", info.ls > 0)
        set(tag, "lsText", tag.ls, "Text", (info.ls > 1 and{(string.format('LS%s', tostring(info.ls)))}or{"LS"})[1])
        set(tag, "os", tag.os, "Visible", info.os > 0)
        set(tag, "osText", tag.os, "Text", (info.os > 1 and{(string.format('OS%s', tostring(info.os)))}or{"OS"})[1])
        return
    end

    -- off screen: pin a marker to the edge in their direction. points behind the camera come back mirrored
    set(tag, "visible", tag.frame, "Visible", false)
    local center = viewport / 2
    local direction = Vector2.new(point.X, point.Y) - center
    if point.Z < 0 then
        direction = -direction
    end
    if direction.Magnitude < 1 then
        direction = Vector2.new(0, 1)
    end

    local half = center - Vector2.new(EDGE_MARGIN, EDGE_MARGIN)
    local scale = math.min(half.X / math.max(math.abs(direction.X), 1e-3), half.Y / math.max(math.abs(direction.Y), 1e-3))
    local edgePoint = center + direction * scale

    set(tag, "edge", tag.edge, "Visible", true)
    set(tag, "edgeColor", tag.edge, "BackgroundColor3", info.teamColor)
    set(tag, "edgeNameColor", tag.edgeName, "TextColor3", info.teamColor)
    tag.edge.Position = UDim2.fromOffset(math.round(edgePoint.X), math.round(edgePoint.Y))
end

function Tags:destroy()
    for info, tag in self.tags do
        self:_destroy(tag)
        self.tags[info] = nil
    end
    self.layer:Destroy()
end

function Tags:setEnabled(enabled)
    self.enabled = enabled
end

-- call every frame, after the roster
function Tags:update()
    local camera = workspace.CurrentCamera
    local viewport = camera.ViewportSize
    local tags = self.tags
    local seen = {}

    for _, info in self.roster.list do
        seen[info] = true
        local tag = tags[info]
        if not tag then
            tag = self:_create(info)
            tags[info] = tag
        end
        self:_updateTag(tag, info, camera, viewport)
    end

    for info, tag in tags do
        if not seen[info] then
            self:_destroy(tag)
            tags[info] = nil
        end
    end
end

return Tags
end function dote.m()local v=dote.cache.m if not v then v={c=__modImpl()}dote.cache.m=v end return v.c end end do local __modImpl=function()
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local GetClosestPlayer=function(
fovRadius, teamCheck)    
local mousePos = UserInputService:GetMouseLocation()
    local fovSq = (fovRadius or 300) ^ 2
    local camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer

    local closestPlayer = nil
    local closestDistSq = fovSq

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            continue
        end

        if teamCheck and player.Team == LocalPlayer.Team then
            continue
        end

        local character = player.Character
        if not character then
            continue
        end

        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
        if not (humanoid and humanoid.Health > 0) then
            continue
        end

        local rootPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            continue
        end

        local screenPos, onScreen = camera:WorldToScreenPoint(rootPart.Position)
        if not onScreen then
            continue
        end

        local dx, dy = screenPos.X - mousePos.X, screenPos.Y - mousePos.Y
        local distSq = dx * dx + dy * dy

        if distSq < closestDistSq then
            closestDistSq = distSq
            closestPlayer = player
        end
    end

    if closestPlayer then
        return closestPlayer.Character, math.sqrt(closestDistSq)
    end
    return nil, nil
end local circle=function(

info)    
local drawing = Drawing.new("Circle")
    drawing.Position = info.Position or Vector2.new(150, 150)
    drawing.Radius = info.Radius or 20
    drawing.Filled = false
    drawing.Thickness = info.Thickness or 2

    return drawing
end local label=function(

info)    
local text = Drawing.new("Text")
    text.Text = info.Text or "Hello, World!"
    text.Position = info.Position or Vector2.new(150, 150)
    text.Color = info.Color or Color3.new(0.968627, 0.972549, 0.968627)
    text.Size = 18
    text.Font = Drawing.Fonts.Monospace
    text.Visible = true

    return text
end local line=function(

info)    
local drawing = Drawing.new("Line")
    drawing.Visible = info.Visible or false
    drawing.Transparency = info.Transparency or 1
    drawing.Color = info.Color or Color3.fromRGB(0, 0, 0)

    drawing.Thickness = info.Thickness or 1
    return drawing
end local isAliveModel=function(

character)    
if character and character.IsDescendantOf(character, workspace) and character.PrimaryPart ~= nil then
        return character
    end

    return false
end local ActivateButton=function(

button)	
game:GetService('ReplicatedStorage')
		:WaitForChild('Shared')
		:WaitForChild('Remotes')
		:WaitForChild('ContextButton')
		:FireServer(button)
end local removeValue=function(


list, value)    
for i, v in ipairs(list) do
        if v == value then
            table.remove(list, i)
            return
        end
    end
end local roundRotationTo15Degrees=function(


cf)    
local x, y, z = cf:ToEulerAnglesXYZ()
local roundTo15=function(angle)        
return math.rad(math.round(math.deg(angle) / 15) * 15)
end    
return CFrame.new(cf.Position) * CFrame.Angles(roundTo15(x), roundTo15(y), roundTo15(z))
end local parentToCoreGui=function(



instance)    
if not pcall(function()
        instance.Parent = game:GetService("CoreGui")
    end) then
        instance.Parent = workspace.Terrain
    end
end
-- one shared __namecall hook. every namecall in the game goes through it, so stacking a hook
-- per feature costs fps; handlers are looked up by method name and get (old, self, ...)
-- a method can have several handlers: the newest runs first and its `old` continues down the chain

local namecallHandlers = {}
local oldNamecall
local callOriginal=function(
self, ...)    
return oldNamecall(self, ...)
end local installNamecall=function()    




if oldNamecall then
        return
    end

    oldNamecall = hookmetamethod(
        game,
        "__namecall",
        LPH_JIT_MAX(function(self, ...)
            local entry = namecallHandlers[getnamecallmethod()]

            if entry and not checkcaller() then
                return entry[1](entry[2], self, ...)
            end

            return oldNamecall(self, ...)
        end)
    )
end local hookNamecall=function(



method, handler, toggleNames)    -- a handler that makes its own method calls (a Raycast, a GetAttribute) changes the namecall method,
    -- and passing the call on would then run that method on the original object instead; put it back first
    
local nextHandler = function(self, ...)
        if setnamecallmethod then
            setnamecallmethod(method)
        end
        return callOriginal(self, ...)
    end

    local previous = namecallHandlers[method]
    if previous then
        local previousHandler, previousNext = previous[1], previous[2]
        nextHandler = function(self, ...)
            return previousHandler(previousNext, self, ...)
        end
    end

    namecallHandlers[method] = { handler, nextHandler }

    if not toggleNames then
        installNamecall()
        return
    end

    for _, name in toggleNames do
        local toggle = Toggles[name]
        if toggle.Value then
            installNamecall()
        end
        toggle:OnChanged(function(enabled)
            if enabled then
                installNamecall()
            end
        end)
    end
end local claimHook=function(




feature, target)    
local env = (getgenv and{(getgenv() )}or{_G
})[1]    local registry = env.EclXHooks
    if not registry then
        registry = {}
        env.EclXHooks = registry
    end

    local claimed = registry[feature]
    if not claimed then
        claimed = setmetatable({}, { __mode = "k" })
        registry[feature] = claimed
    end

    if claimed[target] then
        return false
    end
    claimed[target] = true
    return true
end

return {
    claimHook = claimHook,
    GetClosestPlayer = GetClosestPlayer,
    circle = circle,
    label = label,
    line = line,
    isAliveModel = isAliveModel,
    ActivateButton = ActivateButton,
    removeValue = removeValue,
    roundRotationTo15Degrees = roundRotationTo15Degrees,
    hookNamecall = hookNamecall,
    parentToCoreGui = parentToCoreGui,
}
end function dote.n()local v=dote.cache.n if not v then v={c=__modImpl()}dote.cache.n=v end return v.c end end do local __modImpl=function()
return {}end function dote.o()local v=dote.cache.o if not v then v={c=__modImpl()}dote.cache.o=v end return v.c end end do local __modImpl=function()-- by amedote
-- shared helpers for the orbital tools (laser strike / orbital shield): what's equipped,
-- where it will land and whether that's within its use range.
-- assumes the tools aim with GunClient.GetMouseInfo, so the landing point is the mouse hit
-- (or the ls silent aim target when one is locked)


local Players = game:GetService("Players")

local container = dote.o()

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- use range in studs from the HumanoidRootPart (straight-line 3D); firing outside it gives a cooldown
local RANGES = {
    ["Laser Strike"] = 125,
    ["Orbital Shield"] = 250,
}
local getEquippedOrbital=function()    


local character = LocalPlayer.Character
    local tool = character and character:FindFirstChildOfClass("Tool")

    if tool and RANGES[tool.Name] then
        return tool, tool.Name
    end

    return nil, nil
end local getAimPoint=function(


toolName)    
if toolName == "Laser Strike" and container.lsTargetPosition then
        return container.lsTargetPosition
    end

    local hit = Mouse.Hit
    return hit and hit.Position
end local getRootPart=function()    


local character = LocalPlayer.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end local isInRange=function(

toolName, position)    
local range = RANGES[toolName]
    local root = getRootPart()

    if not (range and root and position) then
        return false
    end

    return (position - root.Position).Magnitude <= range
end

return {
    RANGES = RANGES,
    getEquippedOrbital = getEquippedOrbital,
    getAimPoint = getAimPoint,
    getRootPart = getRootPart,
    isInRange = isInRange,
}
end function dote.p()local v=dote.cache.p if not v then v={c=__modImpl()}dote.cache.p=v end return v.c end end do local __modImpl=function()-- laser strike danger range: a ring in their team color around every player holding a laser strike, the
-- size of its use range, so you can see who could strike where. the minimap draws the same ranges


local utility = dote.n()
local orbital = dote.p()

local RING_WIDTH = 1.2
local RING_TRANSPARENCY = 0.35
local LS_RANGE = orbital.RANGES["Laser Strike"]

-- cylinder adornments run along Z, so this lays the ring flat
local Z_TO_VERTICAL = CFrame.Angles(math.rad(90), 0, 0)

local LsRings = {}
LsRings.__index = LsRings

LsRings.RANGE = LS_RANGE

-- true when the player has a laser strike in hand
function LsRings.isThreat(info)
    return info.alive and info.tool == "Laser Strike" and info.position ~= nil
end

function LsRings.new(roster)
    return setmetatable({
        roster = roster,
        enabled = true,
        -- info -> ring adornment
        rings = {},
    }, LsRings)
end
local createRing=function()    

local ring = Instance.new("CylinderHandleAdornment")
    ring.Name = "\255"
    ring.Adornee = workspace.Terrain -- terrain sits at the origin, so CFrames are world space
    ring.Radius = LS_RANGE
    ring.InnerRadius = LS_RANGE - RING_WIDTH
    ring.Height = 0.3
    ring.AlwaysOnTop = false
    ring.Transparency = RING_TRANSPARENCY
    utility.parentToCoreGui(ring)
    return ring
end

function LsRings:setEnabled(enabled)
    self.enabled = enabled
end

-- call every frame, after the roster
function LsRings:update()
    local rings = self.rings
    local active = {}

    if self.enabled then
        for _, info in self.roster.list do
            if LsRings.isThreat(info) then
                active[info] = true
                local ring = rings[info]
                if not ring then
                    ring = createRing()
                    rings[info] = ring
                end
                if ring.Color3 ~= info.teamColor then
                    ring.Color3 = info.teamColor
                end
                ring.CFrame = CFrame.new(info.position) * Z_TO_VERTICAL
            end
        end
    end

    for info, ring in rings do
        if not active[info] then
            ring:Destroy()
            rings[info] = nil
        end
    end
end

function LsRings:destroy()
    self.enabled = false
    self:update()
end

return LsRings
end function dote.q()local v=dote.cache.q if not v then v={c=__modImpl()}dote.cache.q=v end return v.c end end do local __modImpl=function()-- a counter strike style overview of the map in the corner: the map's tiles drawn from above (lighter is
-- higher), a dot per player in their team color with a tick for the way they face, the camera's spot and
-- direction, every team's beacons and spawn points, shields with their health, and the laser strike range
-- of anyone holding one. click a dot to watch that player, M blows it up.
-- everything sits at scale positions, so the map just resizes when it's expanded


local theme = dote.b()
local LsRings = dote.q()

local colors = theme.colors
local fonts = theme.fonts
local create = theme.create
local corner = theme.corner
local stroke = theme.stroke
local text = theme.text

local GRID = 64
local PADDING = 30
local SMALL_SIZE = 230
local LARGE_SIZE = 520
local HEADER = 22
local STRUCTURE_REFRESH = 1
local MAP_FLUSH = 1
local SHIELD_REFRESH = 0.25
-- shields are the Shield models the game puts in workspace.Effects, with Team / Health / MaxHealth
local SHIELD_NAME = "Shield"

-- structures marked on the map, and how
local MARKED = {
    ["Priority Beacon"] = { shape = "diamond", size = 11 },
    ["Spawn Point"] = { shape = "square", size = 6 },
}

local Minimap = {}
Minimap.__index = Minimap

function Minimap.new(roster, cameraController, parent)
    local self = setmetatable({
        roster = roster,
        cameraController = cameraController,
        expanded = false,
        bounds = nil,
        cells = {},
        cellFrames = {},
        heights = { min = math.huge, max = -math.huge },
        dirty = false,
        nextFlush = 0,
        nextStructures = 0,
        dots = {},
        markers = {},
        shields = {},
        lsZones = {},
        nextShields = 0,
        showShields = true,
        showLsRanges = true,
    }, Minimap)

    self:_build(parent)
    task.spawn(self._scanMap, self)
    return self
end

function Minimap:_build(parent)
    self.panel = create("Frame", {
        Name = "Minimap",
        Position = UDim2.fromOffset(16, 16),
        Size = UDim2.fromOffset(SMALL_SIZE, SMALL_SIZE + HEADER),
        BackgroundColor3 = colors.background,
        BackgroundTransparency = 0.15,
        Parent = parent,
    }, { corner(10), stroke(colors.stroke) })

    text({
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -20, 0, HEADER),
        Text = "MAP",
        Font = fonts.bold,
        TextSize = 10,
        TextColor3 = colors.muted,
        Parent = self.panel,
    })
    text({
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -20, 0, HEADER),
        Text = "M",
        Font = fonts.mono,
        TextSize = 10,
        TextColor3 = colors.faint,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = self.panel,
    })

    self.view = create("Frame", {
        Position = UDim2.fromOffset(6, HEADER),
        Size = UDim2.new(1, -12, 1, -HEADER - 6),
        BackgroundColor3 = Color3.fromRGB(5, 7, 11),
        ClipsDescendants = true,
        Parent = self.panel,
    }, { corner(6) })

    self.terrain = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Parent = self.view,
    })
    self.zoneLayer = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Parent = self.view,
    })
    self.markerLayer = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Parent = self.view,
    })
    self.dotLayer = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Parent = self.view,
    })

    -- where the camera is and which way it looks
    self.cameraMark = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(10, 10),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = self.dotLayer,
    })
    local cone = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(2, 14),
        BorderSizePixel = 0,
        BackgroundTransparency = 0.2,
        Parent = self.cameraMark,
    })
    theme.bind(cone, "BackgroundColor3", "accent")
    local eye = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(6, 6),
        BorderSizePixel = 0,
        Parent = self.cameraMark,
    }, { corner() })
    theme.bind(eye, "BackgroundColor3", "accent")

    self.loading = text({
        Size = UDim2.fromScale(1, 1),
        Text = "READING MAP",
        Font = fonts.mono,
        TextSize = 10,
        TextColor3 = colors.faint,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = self.view,
    })
end

function Minimap:toggleExpanded()
    self.expanded = not self.expanded
    local size = (self.expanded and{LARGE_SIZE }or{SMALL_SIZE
})[1]    theme.tween(self.panel, 0.18, { Size = UDim2.fromOffset(size, size + HEADER) })
end

-- map space

function Minimap:_toMap(position)
    local bounds = self.bounds
    if not bounds then
        return nil
    end
    return math.clamp((position.X - bounds.x) / bounds.span, 0, 1), math.clamp((position.Z - bounds.z) / bounds.span, 0, 1)
end
local headingOf=function(

direction)    
return math.deg(math.atan2(direction.X, -direction.Z))
end local footprint=function(



model)    
if model:IsA("BasePart") then
        return model.CFrame, model.Size
    end
    local ok, cframe, size = pcall(model.GetBoundingBox, model)
    if ok then
        return cframe, size
    end
    return nil
end

function Minimap:_markCells(cframe, size)
    local bounds = self.bounds
    local cellSize = bounds.span / GRID
    -- a rotated box covers at most this much ground either way
    local half = math.max(size.X, size.Z) / 2
    local center = cframe.Position
    local top = center.Y + size.Y / 2

    local x0 = math.floor((center.X - half - bounds.x) / cellSize)
    local x1 = math.floor((center.X + half - bounds.x) / cellSize)
    local z0 = math.floor((center.Z - half - bounds.z) / cellSize)
    local z1 = math.floor((center.Z + half - bounds.z) / cellSize)

    for gx = math.max(x0, 0), math.min(x1, GRID - 1) do
        for gz = math.max(z0, 0), math.min(z1, GRID - 1) do
            local key = gz * GRID + gx
            local current = self.cells[key]
            if not current or top > current then
                self.cells[key] = top
                self.dirty = true
            end
        end
    end
    self.heights.min = math.min(self.heights.min, top)
    self.heights.max = math.max(self.heights.max, top)
end

function Minimap:_scanMap()
    local map = workspace:WaitForChild("Map", 30)
    if not map then
        self.loading.Text = "NO MAP FOUND"
        return
    end

    -- the overview covers every tile loaded now, as a square around their middle
    local minX, minZ, maxX, maxZ = math.huge, math.huge, -math.huge, -math.huge
    local footprints = {}
    for index, child in map:GetChildren() do
        local cframe, size = footprint(child)
        if cframe then
            local position = cframe.Position
            local half = math.max(size.X, size.Z) / 2
            minX = math.min(minX, position.X - half)
            maxX = math.max(maxX, position.X + half)
            minZ = math.min(minZ, position.Z - half)
            maxZ = math.max(maxZ, position.Z + half)
            table.insert(footprints, { cframe, size })
        end
        if index % 1000 == 0 then
            task.wait()
        end
    end

    if minX == math.huge then
        self.loading.Text = "NO MAP FOUND"
        return
    end

    local span = math.max(maxX - minX, maxZ - minZ) + PADDING * 2
    self.bounds = {
        x = (minX + maxX) / 2 - span / 2,
        z = (minZ + maxZ) / 2 - span / 2,
        span = span,
    }

    for index, entry in footprints do
        self:_markCells(entry[1], entry[2])
        if index % 1500 == 0 then
            task.wait()
        end
    end
    self.loading.Visible = false
    self:_flushTerrain()

    -- tiles streaming in later fill in their cells
    map.ChildAdded:Connect(function(child)
        local cframe, size = footprint(child)
        if cframe then
            self:_markCells(cframe, size)
        end
    end)
end

function Minimap:_flushTerrain()
    self.dirty = false
    local low, high = self.heights.min, self.heights.max
    local range = math.max(high - low, 1)
    local cellScale = 1 / GRID

    for key, top in self.cells do
        local frame = self.cellFrames[key]
        if not frame then
            frame = create("Frame", {
                Position = UDim2.fromScale((key % GRID) * cellScale, (math.floor(key / GRID)) * cellScale),
                Size = UDim2.fromScale(cellScale, cellScale),
                BorderSizePixel = 0,
                Parent = self.terrain,
            })
            self.cellFrames[key] = frame
        end
        local shade = math.clamp((top - low) / range, 0, 1)
        frame.BackgroundColor3 = colors.panel:Lerp(Color3.fromRGB(70, 88, 118), shade ^ 0.8)
    end
end

-- players

function Minimap:_createDot(info)
    local dot = {}
    dot.frame = create("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(9, 9),
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = self.dotLayer,
    }, { corner() })
    dot.stroke = stroke(Color3.new(0, 0, 0), 1.5, 0.2)
    dot.stroke.Parent = dot.frame

    -- the facing tick turns around the dot's middle
    dot.pivot = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Parent = dot.frame,
    })
    dot.nose = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 0, 1),
        Size = UDim2.fromOffset(2, 5),
        BorderSizePixel = 0,
        Parent = dot.pivot,
    })

    dot.number = text({
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(12, 12),
        Font = fonts.bold,
        TextSize = 8,
        TextColor3 = Color3.fromRGB(8, 10, 16),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = Enum.TextTruncate.None,
        Visible = false,
        Parent = dot.frame,
    })

    dot.frame.MouseButton1Click:Connect(function()
        self.cameraController:setTarget(info)
    end)
    return dot
end

function Minimap:_updateDots()
    local seen = {}
    local controller = self.cameraController

    for _, info in self.roster.list do
        seen[info] = true
        local dot = self.dots[info]
        if not dot then
            dot = self:_createDot(info)
            self.dots[info] = dot
        end

        local u, v
        if info.position then
            u, v = self:_toMap(info.position)
        end
        local visible = u ~= nil and info.alive
        dot.frame.Visible = visible
        if not visible then
            continue
        end

        local watched = controller.mode ~= "free" and controller.target == info
        local size = self.expanded and 13 or(watched and 11 or 9)
        dot.frame.Position = UDim2.fromScale(u, v)
        dot.frame.Size = UDim2.fromOffset(size, size)
        dot.frame.BackgroundColor3 = info.teamColor
        dot.nose.BackgroundColor3 = info.teamColor
        dot.stroke.Color = (watched and{(Color3.new(1, 1, 1) )}or{(Color3.new(0, 0, 0)
)})[1]        dot.stroke.Thickness = watched and 2 or 1.5
        dot.frame.ZIndex = watched and 4 or 2
        if info.look then
            dot.pivot.Rotation = headingOf(info.look)
        end
        dot.number.Visible = self.expanded
        dot.number.Text = tostring(info.number % 10)
    end

    for info, dot in self.dots do
        if not seen[info] then
            dot.frame:Destroy()
            self.dots[info] = nil
        end
    end
end

function Minimap:_updateCamera()
    local camera = workspace.CurrentCamera
    local u, v = self:_toMap(camera.CFrame.Position)
    self.cameraMark.Visible = u ~= nil
    if u then
        self.cameraMark.Position = UDim2.fromScale(u, v)
        local look = camera.CFrame.LookVector
        if Vector2.new(look.X, look.Z).Magnitude > 0.05 then
            self.cameraMark.Rotation = headingOf(look)
        end
    end
end

-- beacons and spawns

function Minimap:_updateStructures()
    local folder = workspace:FindFirstChild("Structures")
    if not folder or not self.bounds then
        return
    end

    local teamColors = {}
    for _, entry in self.roster.teams do
        teamColors[entry.team.TeamColor.Name] = entry.color
    end

    local seen = {}
    for _, structure in folder:GetChildren() do
        local style = MARKED[structure.Name]
        if not style then
            continue
        end
        seen[structure] = true

        local marker = self.markers[structure]
        if not marker then
            local ok, pivot = pcall(structure.GetPivot, structure)
            if not ok then
                continue
            end
            local u, v = self:_toMap(pivot.Position)
            marker = create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(u, v),
                Size = UDim2.fromOffset(style.size, style.size),
                Rotation = style.shape == "diamond" and 45 or 0,
                BorderSizePixel = 0,
                Parent = self.markerLayer,
            }, { corner(style.shape == "diamond" and 2 or 1) })
            stroke(Color3.new(0, 0, 0), 1, 0.3).Parent = marker
            self.markers[structure] = marker
        end

        local team = structure:GetAttribute("Team")
        local key = (typeof(team) == "BrickColor" and{(team.Name )}or{(tostring(team)
)})[1]        marker.BackgroundColor3 = teamColors[key] or colors.muted
    end

    for structure, marker in self.markers do
        if not seen[structure] then
            marker:Destroy()
            self.markers[structure] = nil
        end
    end
end
local healthColor=function(


ratio)    
return (ratio > 0.5 and{(colors.success )}or{((ratio > 0.25 and{(colors.corona )}or{(colors.danger
)})[1])})[1]end

function Minimap:_createZone(filled)
    local zone = {}
    zone.frame = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = filled and 0.8 or 0.93,
        BorderSizePixel = 0,
        Parent = self.zoneLayer,
    }, { corner() })
    zone.stroke = stroke(Color3.new(1, 1, 1), filled and 1.5 or 1, filled and 0.1 or 0.35)
    zone.stroke.Parent = zone.frame
    return zone
end

function Minimap:_placeZone(zone, position, diameter, color)
    local u, v = self:_toMap(position)
    local size = diameter / self.bounds.span
    zone.frame.Position = UDim2.fromScale(u, v)
    zone.frame.Size = UDim2.fromScale(size, size)
    zone.frame.BackgroundColor3 = color
    zone.stroke.Color = color
end

function Minimap:_updateShields()
    local effects = workspace:FindFirstChild("Effects")
    local seen = {}

    if effects and self.showShields then
        local teamColors = {}
        for _, entry in self.roster.teams do
            teamColors[entry.team.TeamColor.Name] = entry.color
        end

        for _, model in effects:GetChildren() do
            if model.Name ~= SHIELD_NAME then
                continue
            end
            local bubble = model:FindFirstChildWhichIsA("BasePart")
            if not bubble then
                continue
            end
            seen[model] = true

            local zone = self.shields[model]
            if not zone then
                zone = self:_createZone(true)
                zone.health = text({
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.new(0.5, 0, 1, 1),
                    Size = UDim2.fromOffset(40, 11),
                    Font = fonts.bold,
                    TextSize = 9,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    TextTruncate = Enum.TextTruncate.None,
                    TextStrokeTransparency = 0.4,
                    Parent = zone.frame,
                })
                self.shields[model] = zone
            end

            local team = model:GetAttribute("Team")
            local key = (typeof(team) == "BrickColor" and{(team.Name )}or{(tostring(team)
)})[1]            self:_placeZone(zone, bubble.Position, bubble.Size.X, teamColors[key] or colors.muted)

            local health, maxHealth = model:GetAttribute("Health"), model:GetAttribute("MaxHealth")
            if typeof(health) == "number" and typeof(maxHealth) == "number" and maxHealth > 0 then
                local ratio = math.clamp(health / maxHealth, 0, 1)
                zone.health.Visible = true
                zone.health.Text = string.format('%s%%', tostring(math.round(ratio * 100)))                
zone.health.TextColor3 = healthColor(ratio)
                zone.health.TextSize = self.expanded and 11 or 9
                -- a weaker shield looks fainter
                zone.frame.BackgroundTransparency = 0.88 - ratio * 0.12
            else
                zone.health.Visible = false
            end
        end
    end

    for model, zone in self.shields do
        if not seen[model] then
            zone.frame:Destroy()
            self.shields[model] = nil
        end
    end
end

function Minimap:_updateLsRanges()
    local seen = {}
    if self.showLsRanges then
        for _, info in self.roster.list do
            if LsRings.isThreat(info) then
                seen[info] = true
                local zone = self.lsZones[info]
                if not zone then
                    zone = self:_createZone(false)
                    self.lsZones[info] = zone
                end
                self:_placeZone(zone, info.position, LsRings.RANGE * 2, info.teamColor)
            end
        end
    end
    for info, zone in self.lsZones do
        if not seen[info] then
            zone.frame:Destroy()
            self.lsZones[info] = nil
        end
    end
end

-- call every frame, after the roster
function Minimap:update()
    local now = os.clock()
    if self.dirty and now >= self.nextFlush then
        self.nextFlush = now + MAP_FLUSH
        self:_flushTerrain()
    end
    if now >= self.nextStructures then
        self.nextStructures = now + STRUCTURE_REFRESH
        self:_updateStructures()
    end
    if self.bounds then
        if now >= self.nextShields then
            self.nextShields = now + SHIELD_REFRESH
            self:_updateShields()
        end
        self:_updateLsRanges()
    end
    self:_updateDots()
    self:_updateCamera()
end

return Minimap
end function dote.r()local v=dote.cache.r if not v then v={c=__modImpl()}dote.cache.r=v end return v.c end end do local __modImpl=function()-- by nqjf and amedote
-- draws a predicted artillery arc from a barrel: neon segments under a highlight, cut where the shell
-- would hit something, with a splash marker at the impact point. used for our own arty and others'
-- usage: local arc = ArcRenderer.new(barrel, ignoreList); arc:setStyle(color, transparency); arc:draw(size); arc:destroy()


local Workspace = game:GetService("Workspace")

local utility = dote.n()

local PROJECTILE_SPEED = 137.23
local TOTAL_DURATION = 5
local RESOLUTION = 30

-- a still barrel skips redrawing, but the landing spot can still change under it
local LANDING_RECHECK = 0.2

local SPLASH_RADIUS = 3
local SPLASH_RING_WIDTH = 0.5
local SPLASH_CORE_RADIUS = 1

local ArcRenderer = {}
ArcRenderer.__index = ArcRenderer
local createSplashAdornment=function(
radius, innerRadius)	
local adornment = Instance.new("CylinderHandleAdornment")
	adornment.Name = "\255"
	adornment.Adornee = workspace.Terrain -- terrain sits at the origin, so CFrames are world space
	adornment.Radius = radius
	adornment.InnerRadius = innerRadius
	adornment.Height = 0.05
	adornment.AlwaysOnTop = true -- the landing spot is often behind terrain, keep it visible
	adornment.ZIndex = 1
	adornment.Visible = false
	utility.parentToCoreGui(adornment)
	return adornment
end
-- ignoreList: instances the shell passes through (the artillery itself, the operator)

function ArcRenderer.new(barrel, ignoreList)
	local self = setmetatable({}, ArcRenderer)

	self.barrel = barrel
	self.parts = {}

	local arcModel = Instance.new("Model")
	arcModel.Name = "\255"
	arcModel.Parent = barrel

	local highlight = Instance.new("Highlight")
	highlight.Name = "ArcHighlight"
	highlight.Adornee = arcModel
	highlight.FillColor = Color3.fromRGB(255, 255, 0)
	highlight.FillTransparency = 0
	highlight.OutlineColor = Color3.new(1, 1, 1)
	highlight.OutlineTransparency = 1
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Parent = arcModel

	self.arcModel = arcModel
	self.highlight = highlight

	for _ = 1, RESOLUTION do
		local part = Instance.new("Part")
		part.Name = "\255"
		part.Anchored = true
		part.CanCollide = false
		-- the arc is purely visual: keep it out of raycasts (mouse, placement), touches and shadows
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Size = Vector3.new(0.1, 0.1, 1)
		part.Material = Enum.Material.Neon

		part.Parent = arcModel
		table.insert(self.parts, part)
	end

	self.splashRing = createSplashAdornment(SPLASH_RADIUS, SPLASH_RADIUS - SPLASH_RING_WIDTH)
	self.splashCore = createSplashAdornment(SPLASH_CORE_RADIUS, 0)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.RespectCanCollide = true
	raycastParams.FilterDescendantsInstances = ignoreList
	self.raycastParams = raycastParams

	-- reused every draw so the arc doesn't allocate new tables
	self.points = {}
	self.movedParts = {}
	self.cframes = {}

	-- last inputs the arc was drawn with, so a still barrel costs nothing
	self.lastCFrame = nil
	self.lastGravity = nil
	self.lastSize = nil
	self.lastDraw = 0
	self.shownSegments = RESOLUTION

	-- last style applied, so color and transparency are only written on change
	self.lastColor = nil
	self.lastTransparency = nil

	return self
end

function ArcRenderer:setStyle(color, transparency)
	if color == self.lastColor and transparency == self.lastTransparency then
		return
	end
	self.lastColor = color
	self.lastTransparency = transparency

	self.highlight.FillColor = color
	self.highlight.FillTransparency = transparency

	for _, part in self.parts do
		part.Color = color
		part.Transparency = transparency
	end

	self.splashRing.Color3 = color
	self.splashRing.Transparency = transparency
	-- the filled center stays softer than the ring so the impact point underneath is still readable
	self.splashCore.Color3 = color
	self.splashCore.Transparency = 0.5 + transparency * 0.5
end

-- segments past the impact point are unparented so they (and the highlight) stop drawing
function ArcRenderer:_showSegments(count)
	if count == self.shownSegments then
		return
	end
	self.shownSegments = count

	for i, part in self.parts do
		local parent = (i <= count and{(self.arcModel )}or{nil
})[1]		if part.Parent ~= parent then
			part.Parent = parent
		end
	end
end

function ArcRenderer:_setSplash(position, normal)
	local ring, core = self.splashRing, self.splashCore

	if not position then
		if ring.Visible then
			ring.Visible = false
			core.Visible = false
		end
		return
	end

	-- cylinder adornments run along Z, so point Z along the surface normal to lay it on the surface
	local up = (math.abs(normal.Y) > 0.99 and{(Vector3.xAxis )}or{(Vector3.yAxis
)})[1]	local origin = position + normal * 0.05
	local cframe = CFrame.lookAt(origin, origin + normal, up)

	ring.CFrame = cframe
	core.CFrame = cframe

	if not ring.Visible then
		ring.Visible = true
		core.Visible = true
	end
end

function ArcRenderer:draw(size)
	local originCFrame = self.barrel.CFrame
	local gravityValue = Workspace.Gravity
	local now = os.clock()

	-- nothing moved since the last draw, the arc is already right
	if
		originCFrame == self.lastCFrame
		and gravityValue == self.lastGravity
		and size == self.lastSize
		and now - self.lastDraw < LANDING_RECHECK
	then
		return
	end
	self.lastCFrame = originCFrame
	self.lastGravity = gravityValue
	self.lastSize = size
	self.lastDraw = now

	local gravity = Vector3.new(0, -gravityValue, 0)
	local startPosition = originCFrame.Position
	local direction = originCFrame.LookVector
	if direction.Magnitude == 0 then
		return
	end
	local velocity = direction.Unit * PROJECTILE_SPEED

	local points = self.points
	for i = 0, RESOLUTION do
		local t = (i / RESOLUTION) * TOTAL_DURATION
		points[i + 1] = startPosition + velocity * t + 0.5 * gravity * t * t
	end

	local movedParts = self.movedParts
	local cframes = self.cframes
	table.clear(movedParts)
	table.clear(cframes)

	local raycastParams = self.raycastParams
	local shown = 0
	local landingPosition, landingNormal

	for i = 1, RESOLUTION do
		local a, b = points[i], points[i + 1]

		-- cut the arc where the shell would hit something
		local hit = Workspace:Raycast(a, b - a, raycastParams)
		if hit then
			b = hit.Position
			landingPosition = hit.Position
			landingNormal = hit.Normal
		end

		local part = self.parts[i]
		local distance = (b - a).Magnitude
		if part and distance > 0.0001 then
			shown = i
			part.Size = Vector3.new(size, size, distance)
			table.insert(movedParts, part)
			table.insert(cframes, CFrame.lookAt((a + b) * 0.5, b))
		end

		if hit then
			break
		end
	end

	-- parent before moving, BulkMoveTo only works on parts in the world
	self:_showSegments(shown)
	self:_setSplash(landingPosition, landingNormal)

	-- one engine call for every segment instead of a CFrame write per part
	Workspace:BulkMoveTo(movedParts, cframes, Enum.BulkMoveMode.FireCFrameChanged)
end

function ArcRenderer:destroy()
	self.arcModel:Destroy()
	self.splashRing:Destroy()
	self.splashCore:Destroy()
end

return ArcRenderer
end function dote.s()local v=dote.cache.s if not v then v={c=__modImpl()}dote.cache.s=v end return v.c end end do local __modImpl=function()-- the arty trajectory for every artillery someone is sitting in, in the color of the team that owns it.
-- the arc stays up for a few seconds after they get off. the drawing is the hub's arcrenderer


local Players = game:GetService("Players")

local ArcRenderer = dote.s()

-- seconds the arc stays after the seat empties
local LINGER = 3
local ARC_SIZE = 0.15
local ARC_TRANSPARENCY = 0

local Arcs = {}
Arcs.__index = Arcs
local findSeat=function(
model)    
for _, descendant in model:GetDescendants() do
        if descendant:IsA("Seat") or descendant:IsA("VehicleSeat") then
            return descendant
        end
    end
    return nil
end local findBarrel=function(

model)    
local tilt = model:FindFirstChild("TiltAssembly")
    return tilt and tilt:FindFirstChild("Barrel")
end local teamColor=function(


model, occupant)    
local team = model:GetAttribute("Team")
    if typeof(team) == "BrickColor" then
        return team.Color
    end
    local player = occupant and Players:GetPlayerFromCharacter(occupant.Parent)
    if player and player.Team then
        return player.TeamColor.Color
    end
    return Color3.fromRGB(200, 200, 200)
end

function Arcs.new()
    local self = setmetatable({
        enabled = true,
        -- artillery model -> { seat, nextSeatSearch, lastOccupied, occupant, renderer }
        artys = {},
        connections = {},
    }, Arcs)

    task.spawn(function()
        local structures = workspace:WaitForChild("Structures")
local track=function(child)            
if child.Name == "Artillery" and not self.artys[child] then
                self.artys[child] = { seat = nil, nextSeatSearch = 0, lastOccupied = nil, renderer = nil }
            end
end        
for _, child in structures:GetChildren() do
            track(child)
        end
        table.insert(self.connections, structures.ChildAdded:Connect(track))
        table.insert(self.connections, structures.ChildRemoved:Connect(function(child)
            local entry = self.artys[child]
            if entry then
                self:_destroyRenderer(entry)
                self.artys[child] = nil
            end
        end))
    end)

    return self
end

function Arcs:_destroyRenderer(entry)
    if entry.renderer then
        entry.renderer:destroy()
        entry.renderer = nil
    end
end

function Arcs:setEnabled(enabled)
    self.enabled = enabled
    if not enabled then
        for _, entry in self.artys do
            self:_destroyRenderer(entry)
        end
    end
end

-- call every frame
function Arcs:update()
    if not self.enabled then
        return
    end

    local now = os.clock()
    for model, entry in self.artys do
        -- the seat can stream in after the model, so look again (at most once a second) until it's found
        local seat = entry.seat
        if not (seat and seat.Parent) and now >= entry.nextSeatSearch then
            seat = findSeat(model)
            entry.seat = seat
            entry.nextSeatSearch = now + 1
        end

        local occupant = seat and seat.Parent and seat.Occupant
        if occupant then
            entry.lastOccupied = now
            entry.occupant = occupant
        end

        local show = entry.lastOccupied ~= nil and now - entry.lastOccupied <= LINGER
        if show and not entry.renderer then
            local barrel = findBarrel(model)
            if barrel then
                local ignore = { model }
                if entry.occupant and entry.occupant.Parent then
                    table.insert(ignore, entry.occupant.Parent)
                end
                entry.renderer = ArcRenderer.new(barrel, ignore)
            end
        elseif not show and entry.renderer then
            self:_destroyRenderer(entry)
        end

        local renderer = entry.renderer
        if renderer then
            renderer:setStyle(teamColor(model, entry.occupant), ARC_TRANSPARENCY)
            renderer:draw(ARC_SIZE)
        end
    end
end

function Arcs:destroy()
    for _, connection in self.connections do
        connection:Disconnect()
    end
    for _, entry in self.artys do
        self:_destroyRenderer(entry)
    end
    self.artys = {}
end

return Arcs
end function dote.t()local v=dote.cache.t if not v then v={c=__modImpl()}dote.cache.t=v end return v.c end end do local __modImpl=function()-- EclX match viewer: what loads instead of the client when you join a match as a spectator. the game's
-- spectate hud is hidden and replaced with a broadcast view: scorebar, a card per player, the watched
-- player's panel, a kill feed, player tags, a minimap with shields and laser strike ranges, every team's
-- arty trajectories and laser strike rings, a roblox / orbit / chase / free camera with noclip, and the
-- match stats board on Tab (its Viewer tab turns each layer on and off). spectators are left out of all of it.
-- sandbox servers get the normal client even when you join spectating, since you can pick a team there.
-- usage: if viewer.shouldView() then viewer.start() end


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Teams = game:GetService("Teams")
local UserInputService = game:GetService("UserInputService")

local Library = dote.c()
local theme = dote.b()
local Tracker = dote.f()
local StatsBoard = dote.h()
local scoreWeights = dote.i()
local Roster = dote.j()
local Camera = dote.k()
local Hud = dote.l()
local Tags = dote.m()
local Minimap = dote.r()
local Arcs = dote.t()
local LsRings = dote.q()

local SPECTATOR_TEAM = "Spectators"
local SANDBOX_TEAM = "Sandbox"
-- how long to wait for the game to hand us a team after joining
local TEAM_WAIT = 15
-- the hud is laid out for a 1080p screen and scaled to fit
local DESIGN_HEIGHT = 1080
local RENDER_NAME = "EclXViewer"

-- the game's own spectate ui, under PlayerGui.RoactTree: the target panel and the player list with its
-- "Spectating" marker
local GAME_UI = { "main", "playerList" }

local NUMBER_KEYS = {
    [Enum.KeyCode.One] = 1,
    [Enum.KeyCode.Two] = 2,
    [Enum.KeyCode.Three] = 3,
    [Enum.KeyCode.Four] = 4,
    [Enum.KeyCode.Five] = 5,
    [Enum.KeyCode.Six] = 6,
    [Enum.KeyCode.Seven] = 7,
    [Enum.KeyCode.Eight] = 8,
    [Enum.KeyCode.Nine] = 9,
    [Enum.KeyCode.Zero] = 10,
}

local LocalPlayer = Players.LocalPlayer

local Viewer = {}
Viewer.__index = Viewer

-- true when we joined a match (not a sandbox) as a spectator
function Viewer.shouldView()
    -- the team is handed out a moment after joining
    local deadline = os.clock() + TEAM_WAIT
    while not LocalPlayer.Team and LocalPlayer:GetAttribute("IsSpectator") == nil and os.clock() < deadline do
        task.wait(0.25)
    end

    if Teams:FindFirstChild(SANDBOX_TEAM) then
        return false
    end
    return Roster.isSpectator(LocalPlayer)
end
local screenGui=function(
name, displayOrder)    
return theme.create("ScreenGui", {
        Name = name,
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = displayOrder,
        Parent = theme.guiParent(),
    })
end

function Viewer.start()
    local self = setmetatable({
        connections = {},
        hiddenUi = {},
        hudVisible = true,
        destroyed = false,
    }, Viewer)

    self.tracker = Tracker.new({ excludeTeams = { [SPECTATOR_TEAM] = true } })
    self.tracker:start()

    self.roster = Roster.new(self.tracker)
    self.roster:update()
    self.camera = Camera.new(self.roster)

    -- tags go straight on the screen; everything else sits in a root scaled to the screen
    self.tagsGui = screenGui("EclXViewerTags", 4)
    self.hudGui = screenGui("EclXViewer", 5)
    self.root = theme.create("Frame", {
        Name = "Root",
        BackgroundTransparency = 1,
        Parent = self.hudGui,
    })
    self.rootScale = theme.create("UIScale", { Parent = self.root })
    self:_fitRoot()
    self:_connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function()
        self:_fitRoot()
    end)

    self.tags = Tags.new(self.roster, self.camera, self.tagsGui)
    self.minimap = Minimap.new(self.roster, self.camera, self.root)
    self.hud = Hud.new(self.roster, self.camera, self.tracker, self.root)
    self.arcs = Arcs.new()
    self.lsRings = LsRings.new(self.roster)

    self:_buildStatsWindow()
    self:_buildSettings()
    self:_hideGameUi()
    self:_bindInput()

    RunService:BindToRenderStep(RENDER_NAME, Enum.RenderPriority.Camera.Value + 1, function(dt)
        self.roster:update()
        self.camera:update(dt)
        self.tags:update()
        self.lsRings:update()
        self.arcs:update()
        self.minimap:update()
        self.hud:update()
    end)

    -- being moved onto a team mid match: the viewer steps aside
    self:_connect(LocalPlayer:GetPropertyChangedSignal("Team"), function()
        if not Roster.isSpectator(LocalPlayer) then
            self:Unload()
            self.window:Notify("You joined a team, so the match viewer closed. Run the script again to load the client")
        end
    end)

    self.window:Notify(string.format([[Match viewer loaded. %s opens the match stats, H hides the hud]], tostring(self.window.menuKey.Value)))
    return self
end

function Viewer:_connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(self.connections, connection)
    return connection
end

-- the root is sized up by 1 / scale so that once scaled it covers the screen exactly
function Viewer:_fitRoot()
    local viewport = workspace.CurrentCamera.ViewportSize
    local scale = math.clamp(viewport.Y / DESIGN_HEIGHT, 0.6, 1.25)
    self.rootScale.Scale = scale
    self.root.Size = UDim2.fromScale(1 / scale, 1 / scale)
end

-- the match board on Tab, in its own EclX window
function Viewer:_buildStatsWindow()
    local window = Library.new({ tag = "VIEWER", menuKey = "Tab", config = false })
    local tab = window:AddTab("Match")
    tab:AddPage(function(page)
        StatsBoard.new(self.tracker, scoreWeights.new(), page, window, function()
            return window.visible
        end)
    end)
    self.window = window
end

-- the Viewer tab: each layer can be turned off. the hotkeys flip the same switches
function Viewer:_buildSettings()
    local window = self.window
    local tab = window:AddTab("Viewer")
    local layers = tab:AddLeftGroupbox("Layers")
    local cameraBox = tab:AddRightGroupbox("Camera")
local checkbox=function(
groupbox, index, text, default, tooltip, apply)        
groupbox:AddCheckbox(index, { Text = text, Default = default, Tooltip = tooltip })
        local toggle = window.Toggles[index]
        toggle:OnChanged(apply)
        apply(toggle.Value)
end
    
checkbox(layers, "Viewer/Tags", "Player tags", true, "Name, health, iridium and orbitals over every player, and team outlines (V)", function(on)
        self.tags:setEnabled(on)
    end)
    checkbox(layers, "Viewer/Arcs", "Arty trajectories", true, "The arc of every manned artillery, in its team's color", function(on)
        self.arcs:setEnabled(on)
    end)
    checkbox(layers, "Viewer/LsRings", "LS danger range", true, "A ring the size of the laser strike's range around anyone holding one", function(on)
        self.lsRings:setEnabled(on)
    end)
    checkbox(layers, "Viewer/MapLs", "LS range on the map", true, nil, function(on)
        self.minimap.showLsRanges = on
    end)
    checkbox(layers, "Viewer/MapShields", "Shields on the map", true, "Every shield to scale, with its health", function(on)
        self.minimap.showShields = on
    end)
    checkbox(layers, "Viewer/Hud", "Hud", true, "(H)", function(on)
        self.hudVisible = on
        self.hudGui.Enabled = on
    end)

    checkbox(cameraBox, "Viewer/Noclip", "Noclip camera", false, "Walls don't pull the camera in (N)", function(on)
        self.camera:setNoclip(on)
    end)
    cameraBox:AddLabel([[<font color="#707e96">C switches roblox / orbit / chase, F freecam</font>]])
end

function Viewer:_flip(index)
    local toggle = self.window.Toggles[index]
    toggle:SetValue(not toggle.Value)
end

-- hides the game's spectate ui, and keeps it hidden when the game shows it again
function Viewer:_hideGameUi()
local hide=function(object)        
if self.hiddenUi[object] or not object:IsA("GuiObject") then
            return
        end
        self.hiddenUi[object] = object.Visible
        object.Visible = false
        self:_connect(object:GetPropertyChangedSignal("Visible"), function()
            if object.Visible and not self.destroyed then
                object.Visible = false
            end
        end)
end
    
task.spawn(function()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        local tree = playerGui:WaitForChild("RoactTree", 30)
        if not tree or self.destroyed then
            return
        end
        for _, name in GAME_UI do
            local object = tree:FindFirstChild(name)
            if object then
                hide(object)
            end
        end
        -- roact can mount them again later
        self:_connect(tree.ChildAdded, function(child)
            if table.find(GAME_UI, child.Name) then
                hide(child)
            end
        end)
    end)
end

function Viewer:_restoreGameUi()
    for object, wasVisible in self.hiddenUi do
        if object.Parent then
            object.Visible = wasVisible
        end
    end
    self.hiddenUi = {}
end

-- in the freecam, a click on a player follows them
function Viewer:_playerUnderMouse()
    local camera = workspace.CurrentCamera
    local mouse = UserInputService:GetMouseLocation()
    local ray = camera:ViewportPointToRay(mouse.X, mouse.Y)

    local best, bestDistance = nil, 40
    for _, info in self.roster.list do
        if info.alive and info.position then
            local point, onScreen = camera:WorldToViewportPoint(info.position)
            if onScreen then
                local distance = (Vector2.new(point.X, point.Y) - mouse).Magnitude
                if distance < bestDistance then
                    best, bestDistance = info, distance
                end
            end
        end
    end
    if best then
        return best
    end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    local characters = {}
    for _, info in self.roster.list do
        if info.character then
            table.insert(characters, info.character)
        end
    end
    params.FilterDescendantsInstances = characters
    local hit = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
    if hit then
        for _, info in self.roster.list do
            if info.character and hit.Instance:IsDescendantOf(info.character) then
                return info
            end
        end
    end
    return nil
end

function Viewer:_bindInput()
    self:_connect(UserInputService.InputBegan, function(input, processed)
        if self.destroyed or UserInputService:GetFocusedTextBox() then
            return
        end

        local camera = self.camera
        local key = input.KeyCode

        -- the game binds some of these keys itself, which marks them processed, so only clicks (which can
        -- land on ui) are checked for it
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if processed then
                return
            end
            if camera.mode == "free" then
                local info = self:_playerUnderMouse()
                if info then
                    camera:setTarget(info)
                end
            else
                camera:cycle(1)
            end
        elseif key == Enum.KeyCode.Right then
            camera:cycle(1)
        elseif key == Enum.KeyCode.Left then
            camera:cycle(-1)
        elseif NUMBER_KEYS[key] then
            local info = self.roster.list[NUMBER_KEYS[key] ]
            if info then
                camera:setTarget(info)
            end
        elseif key == Enum.KeyCode.F then
            camera:toggleFree()
        elseif key == Enum.KeyCode.C then
            camera:cycleFollowMode()
        elseif key == Enum.KeyCode.N then
            self:_flip("Viewer/Noclip")
        elseif key == Enum.KeyCode.M then
            self.minimap:toggleExpanded()
        elseif key == Enum.KeyCode.V then
            self:_flip("Viewer/Tags")
        elseif key == Enum.KeyCode.H then
            self:_flip("Viewer/Hud")
        end
    end)
end

-- running the script again brings the hud back
function Viewer:SetVisible(visible)
    if self.destroyed then
        return
    end
    self.hudVisible = visible
    self.hudGui.Enabled = visible
end

function Viewer:Unload()
    if self.destroyed then
        return
    end
    self.destroyed = true

    RunService:UnbindFromRenderStep(RENDER_NAME)
    for _, connection in self.connections do
        connection:Disconnect()
    end
    self.connections = {}

    self.hud.destroyed = true
    self.camera:destroy()
    self.tags:destroy()
    self.arcs:destroy()
    self.lsRings:destroy()
    self.hudGui:Destroy()
    self.tagsGui:Destroy()
    self.window:SetVisible(false)
    self:_restoreGameUi()

    local env = (getgenv and{(getgenv() )}or{_G
})[1]    if env.EclXViewer == self then
        env.EclXViewer = nil
    end
end

return Viewer
end function dote.u()local v=dote.cache.u if not v then v={c=__modImpl()}dote.cache.u=v end return v.c end end do local __modImpl=function()
local Players = game:GetService("Players")

local artygrav = {}
artygrav.__index = artygrav

function artygrav.new()
	return setmetatable({
		savedGravity = nil,
	}, artygrav)
end

-- puts gravity back to what it was before we changed it
function artygrav:_restore()
	if self.savedGravity then
		workspace.Gravity = self.savedGravity
		self.savedGravity = nil
	end
end

function artygrav:_hookCharacter(character)
	-- dying while seated never fires Seated(false), so clean up on every new character
	self:_restore()

	local humanoid = character:WaitForChild("Humanoid", 10)
	if not humanoid then
		return
	end

	humanoid.Seated:Connect(function(isSeated)
		if isSeated then
			if Toggles.ArtyGravity.Value then
				self.savedGravity = self.savedGravity or workspace.Gravity
				workspace.Gravity = Options.GravitySlider.Value
			end
		else
			self:_restore()
		end
	end)
end

function artygrav:start()
	local Client = Players.LocalPlayer

	Client.CharacterAdded:Connect(function(character)
		self:_hookCharacter(character)
	end)

	if Client.Character then
		self:_hookCharacter(Client.Character)
	end
end

return artygrav
end function dote.v()local v=dote.cache.v if not v then v={c=__modImpl()}dote.cache.v=v end return v.c end end do local __modImpl=function()-- by amedote
-- recolors distributor (iridium) beams. the color goes on the moment a beam appears and is put back
-- whenever the game changes it, so there's no delay and no flicker back to the default


local utility = dote.n()

local main = {}
main.__index = main

function main.new()
	return setmetatable({
		Beams = {}
	}, main)
end

-- cached globals
local Effects = workspace.Effects
local ColorSeqKey = ColorSequenceKeypoint.new
local ColorSeq = ColorSequence.new
local insert = table.insert

local DEFAULT_COLOR = Color3.fromRGB(0, 255, 255)
local createColorSequence=function(
color1, color2)	
return ColorSeq({ ColorSeqKey(0, color1), ColorSeqKey(1, color2) })
end

local DEFAULT_SEQUENCE = createColorSequence(DEFAULT_COLOR, DEFAULT_COLOR)

-- what beams are forced to while the toggle is on, rebuilt only when the options change
local currentSequence = nil
local refreshSequence=function()	

if Toggles.ChangeBeamColors.Value then
		currentSequence = createColorSequence(Options.FirstBeamColor.Value, Options.SecondBeamColor.Value)
	else
		currentSequence = nil
	end
end local applyColor=function(

beam)	
local sequence = currentSequence or DEFAULT_SEQUENCE
	if beam.Color ~= sequence then
		beam.Color = sequence
	end
end local updateAll=function(

beams)	
for i = 1, #beams do
		applyColor(beams[i])
	end
end local isIridiumBeam=function(

v)	
return v:IsA("Beam") and v.Name == "IridiumBeam"
end local watchBeam=function(

beams, beam)	
insert(beams, beam)
	applyColor(beam)

	-- the game sets the beam's color after creating it; put ours straight back
	beam:GetPropertyChangedSignal("Color"):Connect(function()
		if currentSequence and beam.Color ~= currentSequence then
			beam.Color = currentSequence
		end
	end)
end

function main:start()
	local beams = self.Beams

	refreshSequence()

	-- initialize existing beams
	for _, v in Effects:GetChildren() do
		if isIridiumBeam(v) then
			watchBeam(beams, v)
		end
	end

	-- listen for new beams
	Effects.ChildAdded:Connect(function(v)
		if isIridiumBeam(v) then
			watchBeam(beams, v)
		end
	end)

	-- listen for beam removals
	Effects.ChildRemoved:Connect(function(v)
		if isIridiumBeam(v) then
			utility.removeValue(beams, v)
		end
	end)
local handleColorChange=function()		


refreshSequence()
		updateAll(beams)
end
	
Toggles.ChangeBeamColors:OnChanged(handleColorChange)
	Options.FirstBeamColor:OnChanged(handleColorChange)
	Options.SecondBeamColor:OnChanged(handleColorChange)
end

return main
end function dote.w()local v=dote.cache.w if not v then v={c=__modImpl()}dote.cache.w=v end return v.c end end do local __modImpl=function()-- by amedote


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local utility = dote.n()

local ToolProducer = require(
    ReplicatedStorage:WaitForChild("Client")
        :WaitForChild("Loader")
        :WaitForChild("StructureNetworkingController")
        :WaitForChild("Components")
        :WaitForChild("ToolProducer")
)

local main = {}
main.__index = main

function main.new()
    return setmetatable({}, main)
end
local calledFromMouseInfo=function()    



for level = 3, 4 do
        local info = debug.getinfo(level)
        if info and info.name == "getMouseInfo" then
            return true
        end
    end

    return false
end

function main:start()
    -- this is the bs i was talking about in readme that they added, i have no idea what it is lmao nqjf really wanted to commercialize this for some reason
    -- the game raycasts ~1600 times a second, so the toggle is checked before anything else
    utility.hookNamecall("Raycast", function(old, self, ...)
        if not Toggles["PORTAFAB/InfiniteRange"].Value then
            return old(self, ...)
        end

        local character = Players.LocalPlayer.Character
        if
            calledFromMouseInfo()
            and debug.traceback():find("ContextButtons")
            and character
        then
            local result = old(self, ...)

            if result then
                return {
                    Instance = result.Instance,
                    Position = character.HumanoidRootPart.Position,
                }
            end
        end

        return old(self, ...)
    end, { "PORTAFAB/InfiniteRange" })

    utility.hookNamecall("GetAttribute", function(old, self, ...)
        if Toggles.JetPackMods.Value then
            local name = ...

            if name == "MaxThrustTime" then
                return Options.MaxThrustTime.Value
            end

            if name == "CooldownTime" then
                return Options.CooldownTime.Value
            end

            if name == "ThrustPower" then
                return Options.PowerThrust.Value
            end
        end

        return old(self, ...)
    end, { "JetPackMods" })

    Toggles.InstantProduceWeapons:OnChanged(function(bool)
        if bool then
            ToolProducer.SpringPanelConfig = { frequency = 0, dampeningRatio = 2 }
            ToolProducer.AnimationDuration = 0
            ToolProducer.LinearArmConfig = { velocity = 100 }
        else
            ToolProducer.SpringPanelConfig = { frequency = 3, dampeningRatio = 1 }
            ToolProducer.AnimationDuration = 0.25
            ToolProducer.LinearArmConfig = { velocity = 1 }
        end
    end)
end

return main
end function dote.x()local v=dote.cache.x if not v then v={c=__modImpl()}dote.cache.x=v end return v.c end end do local __modImpl=function()-- by nqjf


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local container = dote.o()

local SpawnPointController =
    require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("Loader"):WaitForChild("SpawnPointController"))
local SpawnRequest = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("SpawnRequest")
local UpdateSpawnPads = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("UpdateSpawnPads")

local main = {}
main.__index = main

function main.new()
    return setmetatable({
        currentSpawn = nil,
    }, main)
end

function main:start()
    local this = self
    local oldSelect = SpawnPointController._select

    function SpawnPointController._select(...)
        local index = select(2, ...)

        if index then
            this.currentSpawn = index
        end

        return oldSelect(...)
    end
local requestSpawn=function(

isRespawn)        
if this.currentSpawn == nil then
            local padList = SpawnPointController.padList
            if #padList == 0 then
                return
            end

            local randomSpawn = padList[math.random(1, #padList)]

            if randomSpawn then
                SpawnRequest:InvokeServer(randomSpawn.Index, isRespawn)
            end
            return
        end

        SpawnRequest:InvokeServer(this.currentSpawn, isRespawn)
end
    
container.instantTPCall:Connect(function()
        requestSpawn(false)
    end)

    container.instantRespawnCall:Connect(function()
        requestSpawn(true)
    end)

    Options.SelectedPadList:OnChanged(function(value)
        this.currentSpawn = value
    end)
local setUIList=function(
pads)        
local withIndex = {}

        for _, v in pads do
            local tot = v.TeleportAvailabilityLevel or v.AvailabilityLevel or 0

            if tot >= 1 then
                table.insert(withIndex, v.Index)
            end
        end

        Options.SelectedPadList:SetValues(withIndex)
end
    
UpdateSpawnPads.OnClientEvent:Connect(function(pads)
        setUIList(pads)
    end)

    if Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait() then
        setUIList(SpawnPointController.padList)
    end
end

function main:update()
    container.selectedSpawn = self.currentSpawn
end

return main
end function dote.y()local v=dote.cache.y if not v then v={c=__modImpl()}dote.cache.y=v end return v.c end end do local __modImpl=function()-- by amedote
-- usage: the aim key (left click by default) on a bore starts aiming it, the power key (E) toggles it.
-- aiming starts when the key is let go, so the click that picked the bore is over before the game binds
-- its own target select, and the next click sets the target. shields are looked through


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local StructureUtil =
    require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utilities"):WaitForChild("StructureUtil"))

local ContextButtonRemote =
    ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("ContextButton")

-- how many shields the mouse ray may pass through before giving up
local MAX_SHIELDS = 8

local MOUSE_KEYS = {
    [Enum.UserInputType.MouseButton1] = "MB1",
    [Enum.UserInputType.MouseButton2] = "MB2",
    [Enum.UserInputType.MouseButton3] = "MB3",
}

local main = {}
main.__index = main
local keyName=function(

input)    
if input.UserInputType == Enum.UserInputType.Keyboard then
        return input.KeyCode.Name
    end
    return MOUSE_KEYS[input.UserInputType]
end local isShield=function(



part)    
return CollectionService:HasTag(part, "Shield")
end local selectingTarget=function()    




local info = ContextActionService:GetBoundActionInfo("SelectTarget")
    return info ~= nil and next(info) ~= nil
end local getCurrentBore=function()    


local mouseLocation = UserInputService:GetMouseLocation()
    local camera = workspace.CurrentCamera
    local ray = camera:ScreenPointToRay(mouseLocation.X, mouseLocation.Y)

    local ignore = { camera, CollectionService:GetTagged("ContextHintRaycastIgnore"), Players.LocalPlayer.Character }
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude

    for _ = 1, MAX_SHIELDS do
        params.FilterDescendantsInstances = ignore
        local result = workspace:Raycast(ray.Origin, ray.Direction * 9999, params)
        if not result then
            return nil
        end
        if not isShield(result.Instance) then
            return StructureUtil:getRootModel(result.Instance)
        end
        table.insert(ignore, result.Instance)
    end

    return nil
end local activateButton=function(

button)    
if button then
        button:Fire()
        ContextButtonRemote:FireServer(button)
    end
end local contextButton=function(


bore, name)    
local button = bore:FindFirstChild(name)
    return button and button:FindFirstChild("ContextButton")
end

function main.new()
    return setmetatable({
        -- the bore the aim key went down on, aimed when the key comes back up over it
        pressedBore = nil,
    }, main)
end

function main:start()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or not Toggles.AutoInteractBore.Value then
            return
        end

        local key = keyName(input)
        local aimKey, powerKey = Options["AutoBore/AimKey"].Value, Options["AutoBore/PowerKey"].Value
        if key ~= aimKey and key ~= powerKey then
            return
        end

        -- only our team's bores; enemy ones have the same buttons, but aiming them would leave the game
        -- waiting for a target it'll refuse
        local bore = getCurrentBore()
        if not bore or bore:GetAttribute("Team") ~= Players.LocalPlayer.TeamColor then
            return
        end

        if key == aimKey and contextButton(bore, "TargetButton") and not selectingTarget() then
            self.pressedBore = bore
        elseif key == powerKey then
            activateButton(contextButton(bore, "PowerButton"))
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        local bore = self.pressedBore
        if not bore or keyName(input) ~= Options["AutoBore/AimKey"].Value then
            return
        end
        self.pressedBore = nil

        -- only if it's let go over the same bore, so dragging off cancels
        if Toggles.AutoInteractBore.Value and getCurrentBore() == bore then
            ContextActionService:UnbindAction("SelectTarget")
            activateButton(contextButton(bore, "TargetButton"))
        end
    end)
end
return main
end function dote.z()local v=dote.cache.z if not v then v={c=__modImpl()}dote.cache.z=v end return v.c end end do local __modImpl=function()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StructureUtil =
    require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utilities"):WaitForChild("StructureUtil"))

local utility = dote.n()

local main = {}
main.__index = main

-- model -> hitbox size its flanges were last set to. the portafab asks for the root model of whatever
-- it hovers every frame, so each model's flanges are only walked again when the size changes or a part
-- streams into it
local resized = setmetatable({}, { __mode = "k" })

function main.new()
    return setmetatable({}, main)
end
local resizeFlanges=function(
model, size)    
if resized[model] == size then
        return
    end

    if resized[model] == nil then
        model.DescendantAdded:Connect(function()
            resized[model] = false
        end)
    end
    resized[model] = size

    local flangeSize = Vector3.new(size, 0.5, size)
    for _, descendant in model:GetDescendants() do
        if descendant:IsA("BasePart") and descendant.Name:lower():find("flange") then
            descendant.Size = flangeSize
        end
    end
end

function main:start()
    if not utility.claimHook("pipeextender", StructureUtil) then
        return
    end

    local oldGetRootModel = StructureUtil.getRootModel

    function StructureUtil.getRootModel(...)
        local result = oldGetRootModel(...)

        if result and Toggles["PORTAFAB/ExtendPipeHitbox"].Value and result:IsA("Model") then
            resizeFlanges(result, Options["PORTAFAB/ExtendPipeHitboxSize"].Value)
        end

        return result
    end
end

return main
end function dote.A()local v=dote.cache.A if not v then v={c=__modImpl()}dote.cache.A=v end return v.c end end do local __modImpl=function()-- by nqjf and amedote


local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local container = dote.o()
local utility = dote.n()
local GunClient = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Class"):WaitForChild("GunClient"))

local main = {}
main.__index = main
function main.new()
    return setmetatable({
        circle = nil,
        lastClocked = os.clock(),
    }, main)
end

local inaccuracyMagnitude = 5
local inaccuracySpeed = 2

-- tools that keep their normal targeting
local IGNORED_TOOLS = {
    ["Laser Strike"] = true,
    ["Orbital Shield"] = true,
    ["Cruise Missile"] = true,
    ["Rocket Launcher"] = true,
    ["Laser Drill"] = true,
}
local getRandomBodyPart=function()    

local roll = math.random()
    if roll <= 0.6 then
        return "HumanoidRootPart"
    else
        return "Head"
    end
end

function main:start()
    local oldMouseInfo = GunClient.GetMouseInfo
    local LocalPlayer = Players.LocalPlayer

    function GunClient.GetMouseInfo(...)
        self.lastClocked = os.clock()

        local character = LocalPlayer.Character
        local tool = character and character:FindFirstChildOfClass("Tool")
        local toolName = tool and tool.Name or ""
        if IGNORED_TOOLS[toolName] then
            return oldMouseInfo(...)
        end

        local result = { oldMouseInfo(...) }

        if Toggles.SilentAim.Value then
            local getCharacter =
                utility.GetClosestPlayer(Options["SilentAim/DrawFovValue"].Value, Toggles["SilentAim/TeamCheck"].Value)

            container.lockedOn = getCharacter
            if getCharacter then
                local bodyPart = getCharacter:FindFirstChild(
(Options["SilentAim/BodyParts"].Value == "Random"
and{(getRandomBodyPart()
)}or{(Options["SilentAim/BodyParts"].Value
)})[1]                )

                if bodyPart then
                    local offset = Vector3.new(0, 0, 0)
                    local accuracy = Options["SilentAim/AccuracyValue"].Value
                    if accuracy < 100 then
                        local t = tick() * inaccuracySpeed
                        local fluctuation = math.sin(t) * inaccuracyMagnitude
                        local randomNoise = Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1))
                        offset = (randomNoise + Vector3.new(fluctuation, fluctuation, fluctuation))
                            * ((100 - accuracy) / 100)
                    end

                    result[1] = bodyPart
                    result[2] = bodyPart.Position + offset
                end
            end
        else
            container.lockedOn = nil
        end

        return unpack(result)
    end
end

function main:update()
    if os.clock() - self.lastClocked >= 0.3 then
        container.lockedOn = nil
    end
    if Toggles["SilentAim/DrawFov"].Value then
        if self.circle == nil then
            self.circle = utility.circle({ Radius = Options["SilentAim/DrawFovValue"].Value })
            self.circle.Visible = true
        end

        self.circle.Radius = Options["SilentAim/DrawFovValue"].Value
        self.circle.Color = Options["SilentAim/DrawFovColor"].Value
        self.circle.Position = UserInputService.GetMouseLocation(UserInputService)
    else
        if self.circle ~= nil then
            self.circle.Visible = false
            self.circle:Remove()
        end

        self.circle = nil
    end
end

return main
end function dote.B()local v=dote.cache.B if not v then v={c=__modImpl()}dote.cache.B=v end return v.c end end do local __modImpl=function()-- by nqjf
-- rewritten for 77ware by amedote


local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local container = dote.o()

local damageindicator = {}
damageindicator.__index = damageindicator

function damageindicator.new()
    return setmetatable({}, damageindicator)
end
local applyDamageVisual=function(
character)    
if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        humanoid = character:WaitForChild("Humanoid", 5) 
        if not humanoid then return end
    end

    local lastHealth = humanoid.Health

    humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        local currentHealth = humanoid.Health
        -- skip the silent aim target, its esp already shows the locked-on color
        if currentHealth < lastHealth and Toggles.DamageIndicator.Value and container.lockedOn ~= character then
            local foundHighlight = character:FindFirstChild("xaaaaaa")
            if foundHighlight then
                foundHighlight:Destroy()
            end

            local highlight = Instance.new("Highlight")
            highlight.FillColor = Options.DamageIndicatorColor.Value
            highlight.Parent = character
            highlight.Name = "xaaaaaa"
            highlight.FillTransparency = 0.05

            TweenService:Create(highlight, TweenInfo.new(1), {
                FillTransparency = 1,
                OutlineTransparency = 1,
            }):Play()

            task.delay(1, function()
                if highlight and highlight.Parent then
                    highlight:Destroy()
                end
            end)
        end
        lastHealth = currentHealth
    end)
end local watchPlayer=function(

player)    
player.CharacterAdded:Connect(applyDamageVisual)
end

function damageindicator:start()
    for _, player in Players:GetPlayers() do
        if player.Character then
            applyDamageVisual(player.Character)
        end
        watchPlayer(player)
    end

    Players.PlayerAdded:Connect(watchPlayer)
end

return damageindicator
end function dote.C()local v=dote.cache.C if not v then v={c=__modImpl()}dote.cache.C=v end return v.c end end do local __modImpl=function()-- CIELUV color interpolation by Fractality
-- vendored from https://pastebin.com/raw/wRnsJeid so the script doesn't download and run it on every load
-- usage: local lerp = lerpColor(fromColor, toColor); lerp(0.5) -> Color3


local clamp = math.clamp
local C3 = Color3.new
local black = C3(0, 0, 0)
local RgbToLuv13=function(

c)	
local r, g, b = c.r, c.g, c.b
	-- Apply inverse gamma correction
	r = r < 0.0404482362771076 and r/12.92 or 0.87941546140213*(r + 0.055)^2.4
	g = g < 0.0404482362771076 and g/12.92 or 0.87941546140213*(g + 0.055)^2.4
	b = b < 0.0404482362771076 and b/12.92 or 0.87941546140213*(b + 0.055)^2.4
	-- sRGB->XYZ->CIELUV
	local y = 0.2125862307855956*r + 0.71517030370341085*g + 0.0722004986433362*b
	local z = 3.6590806972265883*r + 11.4426895800574232*g + 4.1149915024264843*b
	local l = y > 0.008856451679035631 and 116*y^(1/3) - 16 or 903.296296296296*y
	if z > 1e-15 then
		local x = 0.9257063972951867*r - 0.8333736323779866*g - 0.09209820666085898*b
		return l, l*x/z, l*(9*y/z - 0.46832)
	else
		return l, -0.19783*l, -0.46832*l
	end
end local lerpColor=function(

c0, c1)	
local l0, u0, v0 = RgbToLuv13(c0)
	local l1, u1, v1 = RgbToLuv13(c1)

	return function(t)
		-- Interpolate
		local l = (1 - t)*l0 + t*l1
		if l < 0.0197955 then
			return black
		end
		local u = ((1 - t)*u0 + t*u1)/l + 0.19783
		local v = ((1 - t)*v0 + t*v1)/l + 0.46832

		-- CIELUV->XYZ
		local y = (l + 16)/116
		y = y > 0.206896551724137931 and y*y*y or 0.12841854934601665*y - 0.01771290335807126
		local x = y*u/v
		local z = y*((3 - 0.75*u)/v - 5)

		-- XYZ->linear sRGB
		local r =  7.2914074*x - 1.5372080*y - 0.4986286*z
		local g = -2.1800940*x + 1.8757561*y + 0.0415175*z
		local b =  0.1253477*x - 0.2040211*y + 1.0569959*z

		-- Adjust for the lowest out-of-bounds component
		if r < 0 and r < g and r < b then
			r, g, b = 0, g - r, b - r
		elseif g < 0 and g < b then
			r, g, b = r - g, 0, b - g
		elseif b < 0 then
			r, g, b = r - b, g - b, 0
		end

		return C3(
			-- Apply gamma correction and clamp the result
			clamp(r < 3.1306684425e-3 and 12.92*r or 1.055*r^(1/2.4) - 0.055, 0, 1),
			clamp(g < 3.1306684425e-3 and 12.92*g or 1.055*g^(1/2.4) - 0.055, 0, 1),
			clamp(b < 3.1306684425e-3 and 12.92*b or 1.055*b^(1/2.4) - 0.055, 0, 1)
		)
	end
end

return lerpColor
end function dote.D()local v=dote.cache.D if not v then v={c=__modImpl()}dote.cache.D=v end return v.c end end do local __modImpl=function()-- by nqjf


local Players = game:GetService("Players")

local container = dote.o()
local utility = dote.n()
local lerpColor = dote.D()

-- health bar colors precomputed per health percent, so the color lerp never runs per frame
local HEALTH_COLORS = {}
do
    local healthBarLerp = lerpColor(Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0))
    for percent = 0, 100 do
        HEALTH_COLORS[percent] = healthBarLerp(percent / 100)
    end
end

-- ui settings, read once per frame in main:update and shared by every entity
local frame = {}

local main = {}
main.__index = main

function main.new()
    return setmetatable({
        entities = {},
    }, main)
end
local DecimalToPercentage=function(
decimalValue)    
decimalValue = math.clamp(decimalValue, 0, 1)
    local percent = decimalValue * 100
    return math.floor(percent)
end local getIridiumLevel=function(

character)    
local tank = character:FindFirstChild("IridiumTank")
    local indicator = tank and tank:FindFirstChild("Indicator")
    local meter = indicator and indicator:FindFirstChild("IridiumMeter")
    local mesh = meter and meter:FindFirstChild("Mesh")

    if mesh and mesh:IsA("DataModelMesh") then
        return mesh.Scale.Y
    end

    return nil
end
-- how often each player's laser strike / orbital shield count is refreshed

local ORBITAL_RECOUNT = 0.25
local countOrbitalsIn=function(
holder, lsCount, osCount)    
if holder then
        for _, child in holder:GetChildren() do
            if child:IsA("Tool") then
                if child.Name == "Laser Strike" then
                    lsCount =lsCount+ 1
                elseif child.Name == "Orbital Shield" then
                    osCount =osCount+ 1
                end
            end
        end
    end
    return lsCount, osCount
end local countOrbitals=function(


player, character)    
local lsCount, osCount = countOrbitalsIn(player:FindFirstChildOfClass("Backpack"), 0, 0)
    return countOrbitalsIn(character, lsCount, osCount)
end

function main:addEsp(player, character)
    character = character or player.Character

    local label = utility.label({})
    label.Center = true

    -- "LS" / "OS" lines under the box, each in its own color. you can only carry one of each, so the
    -- count only shows if that ever changes
    local lsLabel = utility.label({})
    lsLabel.Center = true
    lsLabel.Visible = false
    local osLabel = utility.label({})
    osLabel.Center = true
    osLabel.Visible = false

    local lsCount, osCount, nextRecount = 0, 0, 0
    local lsVisible, osVisible = false, false
    local lastLsText, lastOsText, lastLsColor, lastOsColor

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.4
    highlight.Enabled = false

    local healthBar = utility.line({ Color = Color3.fromRGB(0, 255, 0), Thickness = 1 })
    local Bar = utility.line({ Color = Color3.fromRGB(10, 10, 10), Thickness = 3, Transparency = 0.4 })

    local Box_Lines = {}
    for i = 1, 8 do
        Box_Lines[i] = utility.line({})
    end

    -- cached parts and last written values; drawing and instance writes are only made on change
    local root, hum
    local prevhealth
    local lastText, lastBoxColor, lastLabelColor, lastFillColor
    local labelVisible = true -- utility.label starts visible
    local barVisible = false
    local boxVisible = false
local setLabelVisible=function(
state)        
if labelVisible ~= state then
            labelVisible = state
            label.Visible = state
        end
end local setBarVisible=function(

state)        
if barVisible ~= state then
            barVisible = state
            healthBar.Visible = state
            Bar.Visible = state
        end
end local setBoxVisible=function(

state)        
if boxVisible ~= state then
            boxVisible = state
            for i = 1, 8 do
                Box_Lines[i].Visible = state
            end
        end
end local setHighlightEnabled=function(

state)        
if state and highlight.Parent ~= character then
            highlight.Parent = character
        end
        if highlight.Enabled ~= state then
            highlight.Enabled = state
        end
end local setOrbitalsVisible=function(

showLs, showOs)        
if lsVisible ~= showLs then
            lsVisible = showLs
            lsLabel.Visible = showLs
        end
        if osVisible ~= showOs then
            osVisible = showOs
            osLabel.Visible = showOs
        end
end local hide=function()        


setBoxVisible(false)
        setBarVisible(false)
        setLabelVisible(false)
        setOrbitalsVisible(false, false)
end local pickColor=function(


default)        
if container.lockedOn == character then
            return frame.lockedColor
        end

        return (frame.useTeamColor and{(player.TeamColor.Color )}or{default
})[1]end
    
return {
        update = function()
            local localrootpart = frame.localRoot
            if not localrootpart then
                hide()
                return
            end

            if not (root and root.Parent == character) then
                root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
            end
            if not (hum and hum.Parent == character) then
                hum = character:FindFirstChildOfClass("Humanoid")
            end

            if not (root and hum) then
                hide()
                return
            end

            local rootPosition = root.Position
            local root_pos, onscreen = frame.camera:WorldToViewportPoint(rootPosition)

            if not onscreen then
                hide()
                return
            end

            local dist = (rootPosition - localrootpart.Position).Magnitude
            local espLists = frame.lists

            local ratio = 2500 / root_pos.Z

            local newsize_x = ratio / 2
            local newsize_y = ratio * 1.75 / 2

            local root_x = root_pos.X
            local root_y = root_pos.Y

            label.Position = Vector2.new(root_x, root_y - newsize_y - label.TextBounds.Y)

            local text = (espLists["Name"] and{(character.Name )}or{""
})[1]
            if espLists["Health"] then
                local Hum_Health = hum.Health
                local Hum_MaxHealth = hum.MaxHealth
                local HealthRatio = (Hum_MaxHealth > 0 and{(Hum_Health / Hum_MaxHealth )}or{0
})[1]
                text = string.format('%s%% %s', tostring(math.round(HealthRatio * 100)), tostring(text))
                
local offsetX = math.clamp(math.round(200 / root_pos.Z), 4, 8)

                local Right = root_x + newsize_x
                local Top = root_y - newsize_y
                local Bottom = root_y + newsize_y

                local barPos = Right + offsetX

                Bar.From = Vector2.new(barPos, Top)
                Bar.To = Vector2.new(barPos, Bottom)

                local Length = math.abs((Bottom - 1) - (Top + 1))

                local HealthLength = Length * HealthRatio
                healthBar.From = Vector2.new(barPos, Bottom - 1 - HealthLength)
                healthBar.To = Vector2.new(barPos, Bottom - 1)

                if Hum_Health ~= prevhealth then
                    healthBar.Color = HEALTH_COLORS[math.clamp(math.round(HealthRatio * 100), 0, 100)]
                    prevhealth = Hum_Health
                end

                setBarVisible(true)
            else
                setBarVisible(false)
            end

            if espLists["Iridium"] then
                local iridium = getIridiumLevel(character)
                if iridium then
                    text = string.format(' %s Iridium: %s', tostring(text), tostring(DecimalToPercentage(iridium)))                
end
            end

            if espLists["Distance"] then
                text = string.format('%s (%s)', tostring(text), tostring(math.round(dist)))            
end

            if text ~= lastText then
                lastText = text
                label.Text = text
            end

            if espLists["Box"] then
                local Dir1 = Vector2.new(ratio / 4, 0)
                local Dir2 = Vector2.new(0, ratio / 4)

                local TL = Vector2.new(root_x - newsize_x, root_y - newsize_y)
                local TR = Vector2.new(root_x + newsize_x, root_y - newsize_y)
                local BL = Vector2.new(root_x - newsize_x, root_y + newsize_y)
                local BR = Vector2.new(root_x + newsize_x, root_y + newsize_y)

                Box_Lines[1].From = TL
                Box_Lines[1].To = TL + Dir1

                Box_Lines[2].From = TL
                Box_Lines[2].To = TL + Dir2

                Box_Lines[3].From = TR
                Box_Lines[3].To = TR - Dir1

                Box_Lines[4].From = TR
                Box_Lines[4].To = TR + Dir2

                Box_Lines[5].From = BL
                Box_Lines[5].To = BL + Dir1

                Box_Lines[6].From = BL
                Box_Lines[6].To = BL - Dir2

                Box_Lines[7].From = BR
                Box_Lines[7].To = BR - Dir1

                Box_Lines[8].From = BR
                Box_Lines[8].To = BR - Dir2

                local boxColor = pickColor(frame.boxColor)
                if boxColor ~= lastBoxColor then
                    lastBoxColor = boxColor
                    for i = 1, 8 do
                        Box_Lines[i].Color = boxColor
                    end
                end

                setBoxVisible(true)
            else
                setBoxVisible(false)
            end

            if espLists["Highlight"] then
                local fillColor = pickColor(frame.boxColor)
                if fillColor ~= lastFillColor then
                    lastFillColor = fillColor
                    highlight.FillColor = fillColor
                end

                setHighlightEnabled(true)
            else
                setHighlightEnabled(false)
            end

            local labelColor = pickColor(frame.labelColor)
            if labelColor ~= lastLabelColor then
                lastLabelColor = labelColor
                label.Color = labelColor
            end

            setLabelVisible(true)

            if espLists["Orbitals"] then
                local now = os.clock()
                if now >= nextRecount then
                    nextRecount = now + ORBITAL_RECOUNT
                    lsCount, osCount = countOrbitals(player, character)
                end

                -- stacked under the box: LS first, then OS
                local y = root_y + newsize_y + 2

                if lsCount > 0 then
                    local text = (lsCount > 1 and{(string.format('LS x%s', tostring(lsCount)))}or{"LS"
})[1]                    if text ~= lastLsText then
                        lastLsText = text
                        lsLabel.Text = text
                    end
                    if frame.lsColor ~= lastLsColor then
                        lastLsColor = frame.lsColor
                        lsLabel.Color = frame.lsColor
                    end

                    lsLabel.Position = Vector2.new(root_x, y)
                    y =y+ lsLabel.TextBounds.Y
                end

                if osCount > 0 then
                    local text = (osCount > 1 and{(string.format('OS x%s', tostring(osCount)))}or{"OS"
})[1]                    if text ~= lastOsText then
                        lastOsText = text
                        osLabel.Text = text
                    end
                    if frame.osColor ~= lastOsColor then
                        lastOsColor = frame.osColor
                        osLabel.Color = frame.osColor
                    end

                    osLabel.Position = Vector2.new(root_x, y)
                end

                setOrbitalsVisible(lsCount > 0, osCount > 0)
            else
                setOrbitalsVisible(false, false)
            end
        end,

        destroy = function()
            hide()

            lsLabel:Remove()
            osLabel:Remove()
            label:Remove()
            Bar:Remove()
            healthBar:Remove()

            for i = 1, #Box_Lines do
                Box_Lines[i]:Remove()
            end

            highlight:Destroy()
        end,
    }
end

function main:update()
    local entities = self.entities

    if not Toggles.playersVisual.Value then
        for character, entity in entities do
            entity.destroy()
            entities[character] = nil
        end
        return
    end

    local LocalPlayer = Players.LocalPlayer
    local localCharacter = LocalPlayer.Character

    frame.localRoot = (utility.isAliveModel(localCharacter)
and{localCharacter:FindFirstChild("HumanoidRootPart") or localCharacter.PrimaryPart
}or{nil
})[1]    frame.camera = workspace.CurrentCamera
    frame.lists = Options["playersVisualLists"].Value
    frame.useTeamColor = Toggles["playersVisualUseTeamColor"].Value
    frame.lockedColor = Options["SilentAim/Color"].Value
    frame.boxColor = Options["BoxColor"].Value
    frame.labelColor = Options.LabelColor.Value
    frame.lsColor = Options.EspLsColor.Value
    frame.osColor = Options.EspOsColor.Value

    local teamCheck = Toggles.playersVisualTeamcheck.Value

    for _, player in Players:GetPlayers() do
        if player == LocalPlayer then
            continue
        end

        local character = player.Character
        if not character then
            continue
        end

        local entity = entities[character]

        -- also drops teammates that got an esp before teamcheck was turned on
        if teamCheck and player.Team == LocalPlayer.Team then
            if entity then
                entity.destroy()
                entities[character] = nil
            end
            continue
        end

        if not entity then
            entities[character] = self:addEsp(player, character)
        end
    end

    for character, entity in entities do
        if character:IsDescendantOf(workspace) then
            entity.update()
        else
            entity.destroy()
            entities[character] = nil
        end
    end
end

return main
end function dote.E()local v=dote.cache.E if not v then v={c=__modImpl()}dote.cache.E=v end return v.c end end do local __modImpl=function()-- by nqjf and amedote
-- draws the arc for the artillery we're operating; the drawing itself lives in arcrenderer


local Players = game:GetService("Players")

local ArcRenderer = dote.s()

local ArtilleryArc = {}
ArtilleryArc.__index = ArtilleryArc

function ArtilleryArc.new()
	local self = setmetatable({}, ArtilleryArc)

	self.player = Players.LocalPlayer
	self.barrel = nil
	self.renderer = nil
	self.active = false

	-- the ArtilleryReference value is tracked with events instead of scanning the character every frame
	self.trackedCharacter = nil
	self.referenceValue = nil
	self.characterConnections = {}

	return self
end
local isArtilleryReference=function(
inst)	
return inst.Name == "ArtilleryReference" and inst:IsA("ObjectValue")
end

function ArtilleryArc:_trackCharacter(character)
	for _, connection in self.characterConnections do
		connection:Disconnect()
	end
	table.clear(self.characterConnections)

	self.trackedCharacter = character
	self.referenceValue = nil

	if not character then
		return
	end

	-- prefer a reference that's already set, but keep an empty one since its Value can be filled in later
	for _, inst in character:GetDescendants() do
		if isArtilleryReference(inst) then
			self.referenceValue = inst
			if inst.Value then
				break
			end
		end
	end

	table.insert(self.characterConnections, character.DescendantAdded:Connect(function(inst)
		if isArtilleryReference(inst) then
			self.referenceValue = inst
		end
	end))

	table.insert(self.characterConnections, character.DescendantRemoving:Connect(function(inst)
		if inst == self.referenceValue then
			self.referenceValue = nil
		end
	end))
end

function ArtilleryArc:_findArtilleryReference()
	local plr = self.player
	if not plr then
		return nil
	end

	local character = plr.Character
	if character ~= self.trackedCharacter then
		self:_trackCharacter(character)
	end

	local referenceValue = self.referenceValue
	return referenceValue and referenceValue.Value
end

function ArtilleryArc:_buildArc(foundRef)
	if not foundRef then
		return
	end
	local tilt = foundRef:FindFirstChild("TiltAssembly")
	local barrel = tilt and tilt:FindFirstChild("Barrel")

	if not barrel then
		return
	end

	if self.renderer then
		self:_destroyArc()
	end

	self.barrel = barrel
	-- the arc and the shell ignore the artillery itself and our character
	self.renderer = ArcRenderer.new(barrel, { foundRef, self.player.Character })
	self.active = true
end

function ArtilleryArc:_destroyArc()
	if self.renderer then
		self.renderer:destroy()
	end
	self.renderer = nil
	self.barrel = nil
	self.active = false
end

function ArtilleryArc:update()
	if not Toggles or not Toggles.artyVisual.Value then
		if self.active then
			self:_destroyArc()
		end
		return
	end

	local foundRef = self:_findArtilleryReference()

	if not foundRef then
		if self.active then
			self:_destroyArc()
		end
		return
	end

	if self.active and self.barrel and self.barrel:IsDescendantOf(foundRef) == false then
		self:_destroyArc()
	end
	if not self.active then
		self:_buildArc(foundRef)
	end

	if not self.active then
		return
	end

	self.renderer:setStyle(Options.artyVisualColor.Value, Options.artyVisualTransparency.Value or 0)
	self.renderer:draw(Options.artyVisualSize.Value or 0.1)
end

function ArtilleryArc:destroy()
	self:_destroyArc()
	self:_trackCharacter(nil)
	self.player = nil
end

return ArtilleryArc
end function dote.F()local v=dote.cache.F if not v then v={c=__modImpl()}dote.cache.F=v end return v.c end end do local __modImpl=function()-- by amedote
-- optimized for performance and low GC


local main = {}
main.__index = main

function main.new()
	return setmetatable({}, main)
end

--// Cached services and globals
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceStructure = RS:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("PlaceStructure")
local utility = dote.n()

local newCFrame = CFrame.new
local angles = CFrame.Angles
local rad = math.rad

--// Valid structure types
local validNames = {
	["Arc Turret"] = true, ["Turret"] = true, ["Fabricator"] = true,
	["Automechanic"] = true, ["Boost Pad"] = true, ["Observer"] = true,
	["Spatial Anchor"] = true, ["Spawn Point"] = true, ["Shield Generator"] = true,
	["Point Defense"] = true
}
local computePlacementInfo=function(

capModel, flange)	
local capPrimary = capModel.PrimaryPart or capModel:FindFirstChildWhichIsA("BasePart")
	if not capPrimary then return end

	local heightOffset = (capPrimary.Size.Y * 0.5) - 0.55
	local baseCFrame = flange.CFrame * newCFrame(0.6, heightOffset, 0)
	local snappedCFrame = utility.roundRotationTo15Degrees(baseCFrame)

	local flangeRot = flange.CFrame - flange.CFrame.Position
	local rotatedCFrame = flangeRot
		* angles(0, rad(90), 0)
		* angles(rad(-90), 0, 0)

	rotatedCFrame = newCFrame(snappedCFrame.Position) * rotatedCFrame

	return {
		CFrame = flange.CFrame:ToObjectSpace(rotatedCFrame),
		BasePart = flange
	}
end local placeDistributorCap=function(


turret)	
local pipeFemale = turret:WaitForChild("PipeFemale", 5)
	if not pipeFemale then return end

	local flange = pipeFemale:WaitForChild("FemaleFlange", 5)
	if not flange then return end

	-- only read for its size, so use the template instead of cloning it
	local capModel = RS.Server.Structures.Iridium.Special.Tech:WaitForChild("Distributor Cap", 5)
	if not capModel then return end

	local placementInfo = computePlacementInfo(capModel, flange)
	if not placementInfo then return end

	PlaceStructure:FireServer("Distributor Cap", placementInfo, "FemaleFlange", flange)
end
--// Entry point

function main:start(structure)
	if not (Toggles and Toggles.AutoDCap and Toggles.AutoDCap.Value) then return end

	local name = structure.Name
	if not validNames[name] then return end
	if structure:GetAttribute("Builder") ~= LocalPlayer.Name then return end

	local dropdown = Options.AutoDCapDropdown.Value
	if dropdown and dropdown[name] then
		task.wait(Options.AutoDCapDelay.Value)
		placeDistributorCap(structure)
	end
end

return main
end function dote.G()local v=dote.cache.G if not v then v={c=__modImpl()}dote.cache.G=v end return v.c end end do local __modImpl=function()-- by amedote


local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Util = dote.n()

local nextSize = 1
local StructurePlaced=function(
structure)    
if not Toggles.AutoShield.Value then return end
    if structure.Name ~= "Shield Generator" and structure.Name ~= "Spatial Anchor" then
        return
    end
    if structure:GetAttribute("Team") ~= LocalPlayer.TeamColor then return end
    if structure:GetAttribute("Builder") ~= LocalPlayer.Name then return end

    if structure.Name == "Shield Generator" then
        local MediumButton = structure:WaitForChild("MediumButton"):WaitForChild("ContextButton")
        local SmallButton  = structure:WaitForChild("SmallButton"):WaitForChild("ContextButton")
        local EnableButton = structure:WaitForChild("EnableButton"):WaitForChild("ContextButton")
        local Panel = structure:WaitForChild("Panel"):WaitForChild("SurfaceGui"):WaitForChild("Text")

        if Panel.Text == "Off" then
            Util.ActivateButton(EnableButton)
            if nextSize == 2 then
                Util.ActivateButton(MediumButton)
            elseif nextSize == 3 then
                Util.ActivateButton(SmallButton)
            end

            nextSize = nextSize % 3 + 1
        end
    else
        local EnableButton = structure:WaitForChild("EnableButton"):WaitForChild("ContextButton")
        Util.ActivateButton(EnableButton)
    end
end

return StructurePlaced
end function dote.H()local v=dote.cache.H if not v then v={c=__modImpl()}dote.cache.H=v end return v.c end end do local __modImpl=function()-- by amedote
-- todo: instead of using 252 as heightlimit grab it from the server config
-- todo: fade distance and other customizability options ( they are alr implemented just needs to be fixed in the gui file )

-- the disc is a handle adornment, not a part. adornments aren't BaseParts, so raycasts,
-- Mouse.Target and the game's placement system can't hit them, and nothing is added to workspace


local Players = game:GetService("Players")

local utility = dote.n()

local HEIGHT_LIMIT = 252
local FADE_DISTANCE = 15
local FADE_SPEED = 0.1
local DISC_ROTATION = CFrame.Angles(math.rad(90), 0, 0) -- cylinder adornments run along Z, so lay it flat

local main = {}
main.__index = main

function main.new()
	local self = setmetatable({}, main)
	self.player = Players.LocalPlayer
	self.adornment = nil
	self.hrp = nil
	self.transparency = 1
	self.size = nil
	self.color = nil
	return self
end

function main:start()
	local adornment = Instance.new("CylinderHandleAdornment")
	adornment.Name = "\255"
	adornment.Adornee = workspace.Terrain -- terrain sits at the origin, so CFrame below is world space
	adornment.Height = 0.1
	adornment.AlwaysOnTop = false
	adornment.Transparency = 1
	adornment.Visible = false

	utility.parentToCoreGui(adornment)

	self.adornment = adornment
end

function main:_getRootPart()
	local character = self.player.Character
	if not character then
		return nil
	end

	local hrp = self.hrp
	if not (hrp and hrp.Parent == character) then
		hrp = character:FindFirstChild("HumanoidRootPart")
		self.hrp = hrp
	end

	return hrp
end

function main:_hide()
	self.transparency = 1
	if self.adornment.Visible then
		self.adornment.Visible = false
	end
end

function main:update()
	local adornment = self.adornment
	if not adornment then return end

	if not Toggles.HeightLimitESP.Value then
		self:_hide()
		return
	end

	local hrp = self:_getRootPart()
	if not hrp then
		self:_hide()
		return
	end

	local pos = hrp.Position
	local distance = math.abs(HEIGHT_LIMIT - pos.Y)
	local targetTransparency = (distance < FADE_DISTANCE and{(distance / FADE_DISTANCE )}or{1
})[1]
	local transparency = self.transparency + (targetTransparency - self.transparency) * FADE_SPEED
	self.transparency = transparency

	-- fully faded out, skip the property writes until we get close again
	if targetTransparency == 1 and transparency > 0.99 then
		if adornment.Visible then
			adornment.Visible = false
		end
		return
	end

	local size = Options.HeightlimitSize.Value
	if size and size ~= self.size then
		self.size = size
		adornment.Radius = size / 2
	end

	local color = Options.HeighLimitColor.Value
	if color ~= self.color then
		self.color = color
		adornment.Color3 = color
	end

	adornment.CFrame = CFrame.new(pos.X, HEIGHT_LIMIT, pos.Z) * DISC_ROTATION
	adornment.Transparency = transparency
	adornment.Visible = true
end

return main
end function dote.I()local v=dote.cache.I if not v then v={c=__modImpl()}dote.cache.I=v end return v.c end end do local __modImpl=function()-- by amedote

local main = {}
main.__index = main

function main.new()
    local self = setmetatable({}, main)
    self.beaconspots = {}
    return self
end

function main:start()
    local beaconspots = self.beaconspots
    
    for _, v in workspace.Map:GetChildren() do
        if v.Name == "ControlBlock1" then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Options.BeaconSpotColor.Value
            highlight.Enabled = Toggles.BeaconSpotESP.Value
            highlight.Parent = v
            table.insert(beaconspots, {v, highlight})
        end
    end

    Toggles.BeaconSpotESP:OnChanged(function(value)
        for _, spot in beaconspots do
            spot[2].Enabled = value
        end
    end)

    Options.BeaconSpotColor:OnChanged(function()
        for _, spot in beaconspots do
            spot[2].FillColor = Options.BeaconSpotColor.Value
        end
    end)
end

function main:unload()
    for _, spot in self.beaconspots do
        spot[2]:Destroy()
    end
    table.clear(self.beaconspots)
end

return main
end function dote.J()local v=dote.cache.J if not v then v={c=__modImpl()}dote.cache.J=v end return v.c end end do local __modImpl=function()--core/boreaimbot.luau
--by amedote


local Players = game:GetService('Players')
local Client = Players.LocalPlayer
local Mouse = Client:GetMouse()

local utility = dote.n()

local main = {}
main.__index = main
local findBoreAncestor=function(
instance)	
while instance and instance.Parent do
		if instance.Name == 'Bore' then
			return instance
		end
		instance = instance.Parent
	end
	return nil
end
-- the game's bore target ray respects CanCollide, and blueprints aren't collidable while they're built,
-- so it goes straight through them. this casts at blueprints only, and returns where the mouse meets one
-- when it's in front of what the game hit

local blueprintParams = RaycastParams.new()
blueprintParams.FilterType = Enum.RaycastFilterType.Include
local blueprintUnderMouse=function(
gameTarget)	
local blueprints = workspace:FindFirstChild("Blueprints")
	if not blueprints then
		return nil
	end
	blueprintParams.FilterDescendantsInstances = { blueprints }

	local ray = workspace.CurrentCamera:ScreenPointToRay(Mouse.X, Mouse.Y)
	local hit = workspace:Raycast(ray.Origin, ray.Direction * 2048, blueprintParams)
	if not hit then
		return nil
	end
	if typeof(gameTarget) == "Vector3" and (gameTarget - ray.Origin).Magnitude < (hit.Position - ray.Origin).Magnitude then
		return nil -- something solid is in front of the blueprint
	end
	return hit.Position
end local SetTarget=function(

Bore, Target)	
local setTarget = Bore:FindFirstChild("SetTarget")
	if setTarget then
		setTarget:FireServer(Bore, Target)
	end
end

function main.new()
	return setmetatable({}, main)
end

function main:start()
	-- set while we fire our own SetTarget so the hook lets it straight through
	local inside = false

	utility.hookNamecall("FireServer", function(old, self, ...)
		if inside or self.Name ~= "SetTarget" then
			return old(self, ...)
		end

		if not Toggles.BoreAimbot.Value then
			if Toggles.BoreTargetBlueprints.Value then
				local bore, gameTarget = ...
				local blueprintTarget = blueprintUnderMouse(gameTarget)
				if blueprintTarget then
					return old(self, bore, blueprintTarget)
				end
			end
			return old(self, ...)
		end

		local targetPart = Mouse.Target
		local hitPos = Mouse.Hit and Mouse.Hit.Position
		if not hitPos then
			return old(self, ...)
		end

		local bore = targetPart and findBoreAncestor(targetPart)
		local target = hitPos

		if bore then
			-- never aim at our own team's bores
			if bore:GetAttribute("Team") == Client.TeamColor then
				return
			end

			local tilt = bore:FindFirstChild("TiltAssembly")
			local barrel = tilt and tilt:FindFirstChild("Barrel")
			if barrel then
				target = barrel.Position
			end
		elseif targetPart and Toggles.AimAtCenterOfOtherParts.Value then
			target = targetPart.Position
		end

		inside = true
		local ok, err = pcall(SetTarget, self.Parent, target)
		inside = false

		if not ok then
			warn(err)
		end

		return
	end, { "BoreAimbot", "BoreTargetBlueprints" })
end

return main
end function dote.K()local v=dote.cache.K if not v then v={c=__modImpl()}dote.cache.K=v end return v.c end end do local __modImpl=function()-- by amedote


local utility = dote.n()

local DEFAULT_COLOR = Color3.fromRGB(0, 255, 255)

-- the server charges a bore's beam parts from light to dark blue by rewriting their Color over time.
-- the green channel tells how far along the charge is, so our colors can follow the same charge
local CHARGE_START = Color3.fromRGB(0, 255, 255)
local CHARGE_END = Color3.fromRGB(0, 0, 255)

local STRUCTURES = workspace.Structures
local Client = game:GetService("Players").LocalPlayer

local main = {}
main.__index = main
local chargeOf=function(
color)    
return math.clamp(1 - color.G, 0, 1)
end local quantize=function(


color)    
return Color3.fromRGB(math.round(color.R * 255), math.round(color.G * 255), math.round(color.B * 255))
end
-- beam part -> { charge, written }; weak so parts of removed bores fall out on their own

local beamStates = setmetatable({}, { __mode = "k" })
local applyBeamPart=function(
part, state)    
if not Toggles.BoreBeamColorChange.Value then
        -- hand the part back to the server's colors, once
        if state.written then
            state.written = nil
            part.Color = quantize(CHARGE_START:Lerp(CHARGE_END, state.charge))
        end
        return
    end

    local color = quantize(Options.BoreBeamColor.Value:Lerp(Options.BoreBeamColorCharged.Value, state.charge))
    state.written = color
    if part.Color ~= color then
        part.Color = color
    end
end local watchBeamPart=function(

part)    
if beamStates[part] or not part:IsA("BasePart") then
        return
    end

    local state = { charge = chargeOf(part.Color), written = nil }
    beamStates[part] = state

    part:GetPropertyChangedSignal("Color"):Connect(function()
        -- our own write coming back around
        if part.Color == state.written then
            return
        end

        -- the server moved the charge along: remember how far, then put our color back on top
        state.charge = chargeOf(part.Color)
        applyBeamPart(part, state)
    end)

    applyBeamPart(part, state)
end local applyAllBeamParts=function()    


for part, state in beamStates do
        applyBeamPart(part, state)
    end
end
-- flares: every FakeBarrel in the tilt assembly has a FlareEmitterPart holding a FlareEmitter
-- (ParticleEmitter, ColorSequence) and a Light (single Color3)
-- flare instance -> { original }; original is the game's color, put back when the toggle is off

local flareStates = setmetatable({}, { __mode = "k" })

-- what flares are forced to while the toggle is on, rebuilt only when the options change
local flareSequence = nil
local flareLightColor = nil
local refreshFlareColors=function()    

if Toggles.BoreFlareColors.Value then
        local colorOne = Options.BoreFlareColorOne.Value
        flareSequence = ColorSequence.new(colorOne, Options.BoreFlareColorTwo.Value)
        flareLightColor = colorOne
    else
        flareSequence = nil
        flareLightColor = nil
    end
end local isFlare=function(

instance)    
if instance:IsA("ParticleEmitter") then
        return instance.Name == "FlareEmitter"
    end
    return instance:IsA("Light") and instance.Parent ~= nil and instance.Parent.Name == "FlareEmitterPart"
end local wantedFlareColor=function(

instance)    
return (instance:IsA("ParticleEmitter") and{flareSequence }or{flareLightColor
})[1]end local applyFlare=function(

instance, state)    
local wanted = (flareSequence and{(wantedFlareColor(instance) )}or{(state.original
)})[1]    if instance.Color ~= wanted then
        instance.Color = wanted
    end
end local watchFlare=function(

instance)    
if flareStates[instance] or not isFlare(instance) then
        return
    end

    local state = { original = instance.Color }
    flareStates[instance] = state

    instance:GetPropertyChangedSignal("Color"):Connect(function()
        if not flareSequence then
            -- toggle is off: whatever the game sets is the color to come back to
            state.original = instance.Color
            return
        end

        local wanted = wantedFlareColor(instance)
        if instance.Color ~= wanted then
            -- the game recolored it; remember that for later and put ours back
            state.original = instance.Color
            instance.Color = wanted
        end
    end)

    applyFlare(instance, state)
end local applyAllFlares=function()    


refreshFlareColors()
    for instance, state in flareStates do
        applyFlare(instance, state)
    end
end local watchBoreBeam=function(

bore)    
local tiltAssembly = bore:WaitForChild("TiltAssembly", 5)
    if not tiltAssembly then
        return
    end

    for _, descendant in tiltAssembly:GetDescendants() do
        watchFlare(descendant)
    end
    tiltAssembly.DescendantAdded:Connect(watchFlare)

    local beamParts = tiltAssembly:WaitForChild("BeamParts", 5)
    if not beamParts then
        return
    end

    for _, part in beamParts:GetChildren() do
        watchBeamPart(part)
    end
    beamParts.ChildAdded:Connect(watchBeamPart)
end local applyColor=function(

Bores)    
for _, Bore in ipairs(Bores) do
        local turretCenter = Bore:FindFirstChild("TurretCenter")
        if turretCenter then
            local previewBeam = turretCenter:FindFirstChild("PreviewBeam")
            if previewBeam then
                if Toggles.PreviewBeamColorChange.Value then
                    previewBeam.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Options.PreviewBeamColorOne.Value),
                        ColorSequenceKeypoint.new(1, Options.PreviewBeamColorTwo.Value)
                    })
                else
                    previewBeam.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, DEFAULT_COLOR),
                        ColorSequenceKeypoint.new(1, DEFAULT_COLOR)
                    })
                end
            end
        end

        local material = (Toggles.NeonBores.Value and{(Enum.Material.Neon )}or{(Enum.Material.Plastic
)})[1]        local tiltAssembly = Bore:FindFirstChild("TiltAssembly")
        if tiltAssembly then
            local BeamParts = tiltAssembly:FindFirstChild("BeamParts")
            if BeamParts then
                for _, v in BeamParts:GetChildren() do
                    v.Material = material
                end
            end
        end
    end
end

function main.new()
    return setmetatable({
        Bores = {}
    }, main)
end

function main:start()
    local Bores = self.Bores

    refreshFlareColors()

    -- only bores we placed are tracked, so only their beams get recolored
    for _, Child in ipairs(STRUCTURES:GetChildren()) do
        if Child.Name == "Bore" and Child:GetAttribute("Builder") == Client.Name then
            table.insert(Bores, Child)
            task.spawn(watchBoreBeam, Child)
        end
    end

    STRUCTURES.ChildAdded:Connect(function(Child)
        if Child.Name == "Bore" and Child:GetAttribute("Builder") == Client.Name then
            table.insert(Bores, Child)
            task.spawn(watchBoreBeam, Child)

            task.wait(0.1)
            applyColor({ Child })
        end
    end)

    STRUCTURES.ChildRemoved:Connect(function(Child)
        if Child.Name == "Bore" and Child:GetAttribute("Builder") == Client.Name then
            utility.removeValue(Bores, Child)
        end
    end)

    Toggles.PreviewBeamColorChange:OnChanged(function()
        applyColor(Bores)
    end)

    Toggles.NeonBores:OnChanged(function()
        applyColor(Bores)
    end)

    Options.PreviewBeamColorOne:OnChanged(function()
        if Toggles.PreviewBeamColorChange.Value then
            applyColor(Bores)
        end
    end)
    Options.PreviewBeamColorTwo:OnChanged(function()
        if Toggles.PreviewBeamColorChange.Value then
            applyColor(Bores)
        end
    end)

    Toggles.BoreBeamColorChange:OnChanged(applyAllBeamParts)
    Options.BoreBeamColor:OnChanged(applyAllBeamParts)
    Options.BoreBeamColorCharged:OnChanged(applyAllBeamParts)

    Toggles.BoreFlareColors:OnChanged(applyAllFlares)
    Options.BoreFlareColorOne:OnChanged(applyAllFlares)
    Options.BoreFlareColorTwo:OnChanged(applyAllFlares)
end

return main
end function dote.L()local v=dote.cache.L if not v then v={c=__modImpl()}dote.cache.L=v end return v.c end end do local __modImpl=function()
local utility = dote.n()

local main = {}
main.__index = main
local computePlacementInfo=function(
capModel, flange)    
local capPrimary = capModel:FindFirstChildWhichIsA('BasePart')
    if not capPrimary then
        return
    end
    local heightOffset = capPrimary.Size.Y / 2 - 2.2
    local baseCFrame = flange.CFrame * CFrame.new(-0.8, heightOffset, 0)
    local snappedCFrame = utility.roundRotationTo15Degrees(baseCFrame)
    local flangeRotation = flange.CFrame - flange.CFrame.Position
    local rotatedCFrame = flangeRotation
        * CFrame.Angles(0, math.rad(90), 0)
        * CFrame.Angles(math.rad(90), 0, 0)
    rotatedCFrame = CFrame.new(snappedCFrame.Position) * rotatedCFrame
    return {
        CFrame = flange.CFrame:ToObjectSpace(rotatedCFrame),
        BasePart = flange,
    }
end local PlaceFourWay=function(

item)    
local pipeFemale = item:WaitForChild('PipeFemale', 5)
    if not pipeFemale then
        return
    end
    local flange = pipeFemale:WaitForChild('FemaleFlange', 5)
    if not flange then
        return
    end

    -- only read for its size, so use the template instead of cloning it
    local capModel = game.ReplicatedStorage.Server.Structures.Iridium.Pipes:WaitForChild('Four-Way', 5)
    if not capModel then
        return
    end

    local placementInfo = computePlacementInfo(capModel, flange)
    if not placementInfo then
        return
    end

    game.ReplicatedStorage.Shared.Remotes.PlaceStructure:FireServer(
        'Four-Way',
        placementInfo,
        'FemaleFlange4',
        flange
    )
end

function main.new()
    return setmetatable({}, main)
end

function main:start()
    workspace.Structures.ChildAdded:Connect(function(Child)
        if Toggles.AutoBorePipe.Value then
            if Child.Name == "Bore" and Child:GetAttribute("Builder") == game:GetService("Players").LocalPlayer.Name then
                PlaceFourWay(Child)
            end
        end
    end)
end

return main
end function dote.M()local v=dote.cache.M if not v then v={c=__modImpl()}dote.cache.M=v end return v.c end end do local __modImpl=function()-- by unknown


local Players = game:GetService("Players")

local Client = Players.LocalPlayer
local GetFunctionByNameFromScript=function(
targetScript, functionName)    
local matchingFunctions = {}

    for _, garbageCollectedObject in ipairs(getgc()) do 
        if type(garbageCollectedObject) == "function" and debug.info(garbageCollectedObject, "n") == functionName and getfenv(garbageCollectedObject).script == targetScript then 
            table.insert(matchingFunctions, garbageCollectedObject)
        end 
    end 

    return matchingFunctions
end local MatchCallbackToConnection=function(

Connections, Callback)    
for _, Connection in ipairs(Connections) do 
        if Connection.Function == Callback then 
            return Connection
        end 
    end
end local GetFallDamageScript=function()    


local IsCharacter = Client.Character 

    if not IsCharacter then 
        return 
    end 

    return IsCharacter:FindFirstChild("FallDamageScript")
end local GetFallDamageHandler=function()    


local IsFallDamageScript = GetFallDamageScript()

    if not IsFallDamageScript then 
        return 
    end 

    return  GetFunctionByNameFromScript(IsFallDamageScript, "OnStateChanged")
end local GetLocalHumanoid=function()    


local IsCharacter = Client.Character

    return IsCharacter and IsCharacter:FindFirstChildOfClass("Humanoid")
end

local Player = {}

-- returns true if the fall damage connection was found and updated
function Player.SetFallDamage(IsFallDamage)
    local FallDamageHandler = GetFallDamageHandler()
    local LocalHumanoid = GetLocalHumanoid()

    if not (FallDamageHandler and LocalHumanoid) then
        return false
    end

    local Connections = getconnections(LocalHumanoid.StateChanged)
    local Found = false

    for _, MatchingCallback in ipairs(FallDamageHandler) do 
        local RespectiveConnection = MatchCallbackToConnection(Connections, MatchingCallback)

        if RespectiveConnection then
            Found = true

            if IsFallDamage then 
                RespectiveConnection:Enable()
            else 
                RespectiveConnection:Disable()
            end 
        end
    end 

    return Found
end 

return Player
end function dote.N()local v=dote.cache.N if not v then v={c=__modImpl()}dote.cache.N=v end return v.c end end do local __modImpl=function()-- by amedote
-- chams: draws clones of models in a full-screen ViewportFrame laid over the world, so the actual
-- model (colors, materials) shows through walls. the viewport camera copies the game camera each frame.
-- usage: local chams = Chams.new(fadedNames); chams:setModels(set); chams:update(transparency, fadedTransparency); chams:hide()
-- models named in fadedNames (walls, gates...) are drawn at fadedTransparency so they don't hide what's behind them


local Players = game:GetService("Players")

-- what survives in a clone; scripts, sounds, effects and the like are stripped
local KEEP_CLASSES = { "BasePart", "DataModelMesh", "Decal", "SurfaceAppearance", "Model", "Folder" }
local isKept=function(
instance)    
for _, className in KEEP_CLASSES do
        if instance:IsA(className) then
            return true
        end
    end
    return false
end local parentGui=function(


gui)    
if gethui and pcall(function()
        gui.Parent = gethui()
    end) then
        return
    end

    if pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end) then
        return
    end

    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

local Chams = {}
Chams.__index = Chams

function Chams.new(fadedNames)
    local gui = Instance.new("ScreenGui")
    gui.Name = "\255"
    gui.IgnoreGuiInset = true -- the viewport has to line up with the 3d view exactly
    gui.ResetOnSpawn = false
    gui.DisplayOrder = -1
    gui.Enabled = false

    local viewport = Instance.new("ViewportFrame")
    viewport.Name = "\255"
    viewport.Size = UDim2.fromScale(1, 1)
    viewport.BackgroundTransparency = 1
    viewport.Active = false
    viewport.Ambient = Color3.fromRGB(170, 170, 170)
    viewport.LightColor = Color3.new(1, 1, 1)
    viewport.LightDirection = Vector3.new(-1, -1, -1)

    local camera = Instance.new("Camera")
    camera.Parent = viewport
    viewport.CurrentCamera = camera

    viewport.Parent = gui
    parentGui(gui)

    return setmetatable({
        gui = gui,
        viewport = viewport,
        camera = camera,
        -- model -> clone (false when it can't be cloned); kept while the model exists so
        -- models moving in and out of view don't get recloned
        clones = {},
        shown = {},
        transparency = nil,
        fadedNames = fadedNames or {},
        -- parts of faded clones with their original transparency: { part, original }
        fadedParts = {},
        fadedTransparency = 0,
    }, Chams)
end
local applyFade=function(
entry, fadedTransparency)    -- never make a part more visible than it was (invisible hitboxes stay invisible)
    
entry[1].Transparency = math.max(entry[2], fadedTransparency)
end

function Chams:_getClone(model)
    local clone = self.clones[model]

    if clone == nil then
        clone = model:Clone() -- nil when the model isn't Archivable

        if clone then
            for _, descendant in clone:GetDescendants() do
                if not isKept(descendant) then
                    descendant:Destroy()
                end
            end

            if self.fadedNames[model.Name] then
                for _, descendant in clone:GetDescendants() do
                    if descendant:IsA("BasePart") then
                        local entry = { descendant, descendant.Transparency }
                        applyFade(entry, self.fadedTransparency)
                        table.insert(self.fadedParts, entry)
                    end
                end
            end
        end

        self.clones[model] = clone or false
    end

    return clone or nil
end

-- shows exactly the models in `models` (a set of model = true)
function Chams:setModels(models)
    local shown = self.shown

    for model in shown do
        if not models[model] then
            local clone = self.clones[model]
            if clone then
                clone.Parent = nil
            end
            shown[model] = nil
        end
    end

    for model in models do
        if not shown[model] then
            local clone = self:_getClone(model)
            if clone then
                clone.Parent = self.viewport
            end
            shown[model] = true
        end
    end
end

-- drop a model that left the game
function Chams:forget(model)
    local clone = self.clones[model]
    if clone then
        if self.fadedNames[model.Name] then
            local fadedParts = self.fadedParts
            for i = #fadedParts, 1, -1 do
                if fadedParts[i][1]:IsDescendantOf(clone) then
                    table.remove(fadedParts, i)
                end
            end
        end

        clone:Destroy()
    end

    self.clones[model] = nil
    self.shown[model] = nil
end

function Chams:update(transparency, fadedTransparency)
    local camera = workspace.CurrentCamera
    self.camera.CFrame = camera.CFrame
    self.camera.FieldOfView = camera.FieldOfView

    if transparency ~= self.transparency then
        self.transparency = transparency
        self.viewport.ImageTransparency = transparency
    end

    if fadedTransparency and fadedTransparency ~= self.fadedTransparency then
        self.fadedTransparency = fadedTransparency
        for _, entry in self.fadedParts do
            applyFade(entry, fadedTransparency)
        end
    end

    if not self.gui.Enabled then
        self.gui.Enabled = true
    end
end

function Chams:hide()
    if self.gui.Enabled then
        self.gui.Enabled = false
    end
end

return Chams
end function dote.O()local v=dote.cache.O if not v then v={c=__modImpl()}dote.cache.O=v end return v.c end end do local __modImpl=function()-- by amedote
-- ls silent aim: while held with a laser strike equipped, redirects the strike onto the enemy player
-- or weak enemy structure closest to the mouse inside the fov circle and within ls range.
-- the target is highlighted through walls, and every other structure in the fov gets chams


local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local container = dote.o()
local utility = dote.n()
local orbital = dote.p()
local Chams = dote.O()
local GunClient = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Class"):WaitForChild("GunClient"))

local LocalPlayer = Players.LocalPlayer

-- structures one laser strike can take out
local WEAK_STRUCTURES = {
    ["Refill Station"] = true,
    ["Ladder Block"] = true,
    ["Block"] = true,
    ["Bridge"] = true,
}

-- drawn almost see-through in the chams so they don't hide what's behind them
local FADED_STRUCTURES = {
    ["Gate"] = true,
    ["Wall"] = true,
    ["Bridge"] = true,
}

-- structures further than this from our character never get chams (too many clones gets laggy)
local CHAMS_MAX_DISTANCE = 300

local INDICATOR_COLOR = Color3.fromRGB(255, 0, 0)

local EMPTY = {}

local main = {}
main.__index = main

function main.new()
    return setmetatable({
        weakStructures = {},
        -- every structure -> its position, cached since placed structures don't move
        structurePositions = {},
        -- structures inside the fov this frame (set), reused every frame
        inFov = {},
        indicator = nil,
        highlight = nil,
        chams = nil,
        circle = nil,
    }, main)
end
local isLsEquipped=function()local

_, toolName =orbital.getEquippedOrbital()
    return toolName == "Laser Strike"
end local getStructurePart=function(

structure)    
return structure.PrimaryPart or structure:FindFirstChildWhichIsA("BasePart")
end local screenDistSq=function(


camera, mousePos, position)    
local screenPos, onScreen = camera:WorldToViewportPoint(position)
    if not onScreen then
        return nil
    end

    local dx, dy = screenPos.X - mousePos.X, screenPos.Y - mousePos.Y
    return dx * dx + dy * dy
end

function main:start()
    local Structures = workspace:WaitForChild("Structures")
    local weakStructures = self.weakStructures
    local structurePositions = self.structurePositions

    self.chams = Chams.new(FADED_STRUCTURES)
local track=function(

child)        
if not child:IsA("Model") then
            return
        end

        structurePositions[child] = false -- position is read the first time it's needed
        if WEAK_STRUCTURES[child.Name] then
            table.insert(weakStructures, child)
        end
end
    
for _, child in Structures:GetChildren() do
        track(child)
    end

    Structures.ChildAdded:Connect(track)

    Structures.ChildRemoved:Connect(function(child)
        structurePositions[child] = nil
        self.inFov[child] = nil
        self.chams:forget(child)

        if WEAK_STRUCTURES[child.Name] then
            utility.removeValue(weakStructures, child)
        end
    end)

    local indicator = Instance.new("SphereHandleAdornment")
    indicator.Name = "\255"
    indicator.Adornee = workspace.Terrain -- terrain sits at the origin, so CFrames are world space
    indicator.Radius = 1.5
    indicator.Color3 = INDICATOR_COLOR
    indicator.Transparency = 0.2
    indicator.AlwaysOnTop = true
    indicator.ZIndex = 2
    indicator.Visible = false
    utility.parentToCoreGui(indicator)
    self.indicator = indicator

    -- AlwaysOnTop draws the target's silhouette through walls
    local highlight = Instance.new("Highlight")
    highlight.Name = "\255"
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.OutlineTransparency = 0
    highlight.Enabled = false
    utility.parentToCoreGui(highlight)
    self.highlight = highlight

    -- the laser strike reads its target from GetMouseInfo, swap in the locked target
    local oldMouseInfo = GunClient.GetMouseInfo

    function GunClient.GetMouseInfo(...)
        local targetPart = container.lsTargetPart
        local targetPosition = container.lsTargetPosition

        if not (targetPart and targetPosition and Toggles.LsSilentAim.Value and isLsEquipped()) then
            return oldMouseInfo(...)
        end

        local result = { oldMouseInfo(...) }
        result[1] = targetPart
        result[2] = targetPosition

        return unpack(result)
    end
end

function main:_getStructurePosition(structure)
    local position = self.structurePositions[structure]
    if not position then
        position = structure:GetPivot().Position
        -- a model whose parts haven't streamed in yet has no real position, so only cache once it has some
        if structure.PrimaryPart or structure:FindFirstChildWhichIsA("BasePart", true) then
            self.structurePositions[structure] = position
        end
    end
    return position
end

-- every structure (any team) inside the fov circle and within CHAMS_MAX_DISTANCE, into self.inFov
function main:_collectInFov(camera, mousePos, fovSq)
    local inFov = self.inFov
    table.clear(inFov)

    local root = orbital.getRootPart()
    if not root then
        return
    end
    local rootPosition = root.Position

    for structure in self.structurePositions do
        local position = self:_getStructurePosition(structure)

        -- the distance check is cheaper than projecting to the screen, so it goes first
        if (position - rootPosition).Magnitude <= CHAMS_MAX_DISTANCE then
            local distSq = screenDistSq(camera, mousePos, position)
            if distSq and distSq < fovSq then
                inFov[structure] = true
            end
        end
    end
end

-- closest enemy player or weak enemy structure to the mouse, inside the fov and ls range
function main:_findTarget()
    local camera = workspace.CurrentCamera
    local mousePos = UserInputService:GetMouseLocation()
    local fov = Options["LsSilentAim/FovValue"].Value
    local fovSq = fov * fov

    local bestDistSq = fovSq
    local bestPart, bestPosition, bestModel

    for _, player in Players:GetPlayers() do
        if player == LocalPlayer or player.Team == LocalPlayer.Team then
            continue
        end

        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")

        if humanoid and humanoid.Health > 0 and root then
            local position = root.Position
            local distSq = orbital.isInRange("Laser Strike", position) and screenDistSq(camera, mousePos, position)

            if distSq and distSq < bestDistSq then
                bestDistSq = distSq
                bestPart, bestPosition, bestModel = root, position, character
            end
        end
    end

    local teamColor = LocalPlayer.TeamColor
    for _, structure in self.weakStructures do
        if structure:GetAttribute("Team") == teamColor then
            continue
        end

        local position = self:_getStructurePosition(structure)
        local distSq = orbital.isInRange("Laser Strike", position) and screenDistSq(camera, mousePos, position)

        if distSq and distSq < bestDistSq then
            local part = getStructurePart(structure)
            if part then
                bestDistSq = distSq
                bestPart, bestPosition, bestModel = part, position, structure
            end
        end
    end

    if Toggles["LsSilentAim/Chams"].Value then
        self:_collectInFov(camera, mousePos, fovSq)
    end

    return bestPart, bestPosition, bestModel
end

function main:_updateHighlight(targetModel)
    local highlight = self.highlight

    if not (targetModel and Toggles["LsSilentAim/HighlightTarget"].Value) then
        if highlight.Enabled then
            highlight.Enabled = false
            highlight.Adornee = nil
        end
        return
    end

    if highlight.Adornee ~= targetModel then
        highlight.Adornee = targetModel
    end

    local color = Options["LsSilentAim/HighlightColor"].Value
    local transparency = Options["LsSilentAim/HighlightTransparency"].Value
    if highlight.FillColor ~= color then
        highlight.FillColor = color
        highlight.OutlineColor = color
    end
    if highlight.FillTransparency ~= transparency then
        highlight.FillTransparency = transparency
    end

    if not highlight.Enabled then
        highlight.Enabled = true
    end
end

function main:update()
    local active = Toggles.LsSilentAim.Value and isLsEquipped()

    local targetPart, targetPosition, targetModel
    if active then
        targetPart, targetPosition, targetModel = self:_findTarget()
    end

    container.lsTargetPart = targetPart
    container.lsTargetPosition = targetPosition
    container.lsTargetModel = targetModel

    local indicator = self.indicator
    if indicator then
        if targetPosition then
            indicator.CFrame = CFrame.new(targetPosition)
            if not indicator.Visible then
                indicator.Visible = true
            end
        elseif indicator.Visible then
            indicator.Visible = false
        end
    end

    if self.highlight then
        self:_updateHighlight(targetModel)
    end

    -- chams for the other structures in the fov; the target already has its highlight
    if self.chams then
        if active and Toggles["LsSilentAim/Chams"].Value then
            local inFov = self.inFov
            if targetModel then
                inFov[targetModel] = nil
            end

            self.chams:setModels(inFov)
            self.chams:update(
                Options["LsSilentAim/ChamsTransparency"].Value,
                Options["LsSilentAim/WallTransparency"].Value
            )
        else
            self.chams:setModels(EMPTY)
            self.chams:hide()
        end
    end

    if active and Toggles["LsSilentAim/DrawFov"].Value then
        if self.circle == nil then
            self.circle = utility.circle({})
            self.circle.Visible = true
        end

        self.circle.Radius = Options["LsSilentAim/FovValue"].Value
        self.circle.Color = Options["LsSilentAim/DrawFovColor"].Value
        self.circle.Position = UserInputService:GetMouseLocation()
    elseif self.circle ~= nil then
        self.circle.Visible = false
        self.circle:Remove()
        self.circle = nil
    end
end

return main
end function dote.P()local v=dote.cache.P if not v then v={c=__modImpl()}dote.cache.P=v end return v.c end end do local __modImpl=function()-- by amedote
-- shows where an equipped orbital shield / laser strike will land, red when it's out of range.
-- built from handle adornments so raycasts, Mouse.Hit and the placement system never see them


local utility = dote.n()
local orbital = dote.p()

local OUT_OF_RANGE_COLOR = Color3.fromRGB(255, 0, 0)

local OS_RADIUS = 40 -- a placed orbital shield is 80x80x80

local LS_RADIUS = 2 -- about a default character's width
local LS_BEAM_RADIUS = 0.3
local LS_BEAM_HEIGHT = 500 -- the strike comes in at a random angle in game, this just marks the spot

-- cylinder adornments run along Z, so this stands them up / lays them flat
local Z_TO_VERTICAL = CFrame.Angles(math.rad(90), 0, 0)

local main = {}
main.__index = main

function main.new()
    return setmetatable({
        osSphere = nil,
        lsCircle = nil,
        lsBeam = nil,
        -- last style written per visual, so colors are only set on change
        osStyle = {},
        lsStyle = {},
    }, main)
end
local createAdornment=function(
className, properties)    
local adornment = Instance.new(className)
    adornment.Name = "\255"
    adornment.Adornee = workspace.Terrain -- terrain sits at the origin, so CFrames are world space
    adornment.AlwaysOnTop = false
    adornment.Visible = false

    for property, value in properties do
        adornment[property] = value
    end

    utility.parentToCoreGui(adornment)
    return adornment
end local setVisible=function(

adornment, visible)    
if adornment.Visible ~= visible then
        adornment.Visible = visible
    end
end local applyStyle=function(


style, adornments, color, transparency)    
if style.color == color and style.transparency == transparency then
        return
    end
    style.color = color
    style.transparency = transparency

    for _, adornment in adornments do
        adornment.Color3 = color
        adornment.Transparency = transparency
    end
end

function main:start()
    self.osSphere = createAdornment("SphereHandleAdornment", {
        Radius = OS_RADIUS,
    })

    self.lsCircle = createAdornment("CylinderHandleAdornment", {
        Radius = LS_RADIUS,
        Height = 0.2,
    })

    self.lsBeam = createAdornment("CylinderHandleAdornment", {
        Radius = LS_BEAM_RADIUS,
        Height = LS_BEAM_HEIGHT,
    })

    self.osAdornments = { self.osSphere }
    self.lsAdornments = { self.lsCircle, self.lsBeam }
end

function main:update()
    if not self.osSphere then
        return
    end
local
_, toolName =orbital.getEquippedOrbital()

    local showOs = toolName == "Orbital Shield" and Toggles.OsVisualizer.Value
    local showLs = toolName == "Laser Strike" and Toggles.LsVisualizer.Value

    local position = (showOs or showLs) and orbital.getAimPoint(toolName)

    setVisible(self.osSphere, showOs and position ~= nil)
    setVisible(self.lsCircle, showLs and position ~= nil)
    setVisible(self.lsBeam, showLs and position ~= nil)

    if not position then
        return
    end

    local inRange = orbital.isInRange(toolName, position)

    if showOs then
        applyStyle(
            self.osStyle,
            self.osAdornments,
(inRange and{(Options.OsVisualizerColor.Value )}or{OUT_OF_RANGE_COLOR})[1],
            Options.OsVisualizerTransparency.Value
        )

        self.osSphere.CFrame = CFrame.new(position)
    end

    if showLs then
        applyStyle(
            self.lsStyle,
            self.lsAdornments,
(inRange and{(Options.LsVisualizerColor.Value )}or{OUT_OF_RANGE_COLOR})[1],
            Options.LsVisualizerTransparency.Value
        )

        self.lsCircle.CFrame = CFrame.new(position) * Z_TO_VERTICAL
        self.lsBeam.CFrame = CFrame.new(position + Vector3.new(0, LS_BEAM_HEIGHT / 2, 0)) * Z_TO_VERTICAL
    end
end

return main
end function dote.Q()local v=dote.cache.Q if not v then v={c=__modImpl()}dote.cache.Q=v end return v.c end end do local __modImpl=function()-- by amedote
-- stop orbital error: firing a laser strike / orbital shield outside its use range puts it on
-- cooldown, so block the activation when the landing point is out of range.
-- the range is checked every frame while the tool is held (the same check the visualizers draw);
-- at activation the game is already tearing the tool down, so checking right then isn't reliable


local utility = dote.n()
local orbital = dote.p()

-- how old the last range check may be when the tool fires
local STATE_MAX_AGE = 0.5

local main = {}
main.__index = main

function main.new()
    return setmetatable({
        -- last range check while an orbital was held
        toolName = nil,
        inRange = false,
        distance = nil,
        checkedAt = 0,
    }, main)
end

function main:start()
    local state = self

    -- the tools activate with Tool.Remote:FireServer("PrimaryActivated")
    utility.hookNamecall("FireServer", function(old, self, ...)
        if not Toggles.StopOrbitalError.Value or self.Name ~= "Remote" or (...) ~= "PrimaryActivated" then
            return old(self, ...)
        end

        local tool = self.Parent
        local toolName = tool and tool.Name

        -- only block on a fresh, out-of-range check for this same tool; anything unclear goes through
        if
            orbital.RANGES[toolName]
            and state.toolName == toolName
            and os.clock() - state.checkedAt <= STATE_MAX_AGE
            and not state.inRange
        then
            warn(string.format([[[stop orbital error] blocked %s: target %s studs away, range %s]], tostring(toolName), tostring(state.distance and math.round(state.distance) or "?"), tostring(orbital.RANGES[toolName])))
            return
        end

        return old(self, ...)
    end, { "StopOrbitalError" })
end

function main:update()
local _, toolName =orbital.getEquippedOrbital()
    if not toolName then
        return
    end

    local position = orbital.getAimPoint(toolName)
    local root = orbital.getRootPart()

    self.toolName = toolName
    self.inRange = orbital.isInRange(toolName, position)
    self.distance = position and root and (position - root.Position).Magnitude
    self.checkedAt = os.clock()
end

return main
end function dote.R()local v=dote.cache.R if not v then v={c=__modImpl()}dote.cache.R=v end return v.c end end do local __modImpl=function()-- by amedote
-- trajectories for artillery other players are sitting in, colored by team. the arc stays up for a
-- few seconds after they get off, so you don't lose it the moment they hop out


local Players = game:GetService("Players")

local ArcRenderer = dote.s()

local LocalPlayer = Players.LocalPlayer

-- seconds the arc stays after the seat empties
local LINGER = 3

local main = {}
main.__index = main

function main.new()
    return setmetatable({
        -- artillery model -> { seat, lastOccupied, renderer }
        artys = {},
    }, main)
end
local findSeat=function(
model)    
for _, descendant in model:GetDescendants() do
        if descendant:IsA("Seat") or descendant:IsA("VehicleSeat") then
            return descendant
        end
    end
    return nil
end local findBarrel=function(

model)    
local tilt = model:FindFirstChild("TiltAssembly")
    return tilt and tilt:FindFirstChild("Barrel")
end

function main:_destroyRenderer(entry)
    if entry.renderer then
        entry.renderer:destroy()
        entry.renderer = nil
    end
end

function main:start()
    local Structures = workspace:WaitForChild("Structures")
    local artys = self.artys
local track=function(
child)        
if child.Name == "Artillery" then
            artys[child] = { seat = nil, nextSeatSearch = 0, lastOccupied = nil, renderer = nil }
        end
end
    
for _, child in Structures:GetChildren() do
        track(child)
    end

    Structures.ChildAdded:Connect(track)

    Structures.ChildRemoved:Connect(function(child)
        local entry = artys[child]
        if entry then
            self:_destroyRenderer(entry)
            artys[child] = nil
        end
    end)
end

function main:update()
    local artys = self.artys

    if not Toggles.OtherArtyVisual.Value then
        for _, entry in artys do
            self:_destroyRenderer(entry)
            entry.lastOccupied = nil
        end
        return
    end

    local now = os.clock()
    local character = LocalPlayer.Character
    local myHumanoid = character and character:FindFirstChildOfClass("Humanoid")
    local myTeam = LocalPlayer.TeamColor

    local enemyColor = Options.EnemyArtyColor.Value
    local friendlyColor = Options.FriendlyArtyColor.Value
    local transparency = Options.artyVisualTransparency.Value or 0
    local size = Options.artyVisualSize.Value or 0.1

    for model, entry in artys do
        -- the seat can stream in after the model, so look again (at most once a second) until it's found
        local seat = entry.seat
        if not (seat and seat.Parent) and now >= (entry.nextSeatSearch or 0) then
            seat = findSeat(model)
            entry.seat = seat
            entry.nextSeatSearch = now + 1
        end

        local occupant = seat and seat.Parent and seat.Occupant
        local ours = occupant ~= nil and occupant == myHumanoid

        if occupant and not ours then
            entry.lastOccupied = now
        end

        -- our own arty already has its arc from the artillery module
        local show = not ours and entry.lastOccupied ~= nil and now - entry.lastOccupied <= LINGER

        if show and not entry.renderer then
            local barrel = findBarrel(model)
            if barrel then
                entry.renderer = ArcRenderer.new(barrel, { model })
            end
        elseif not show and entry.renderer then
            self:_destroyRenderer(entry)
        end

        local renderer = entry.renderer
        if renderer then
            local friendly = model:GetAttribute("Team") == myTeam
            renderer:setStyle((friendly and{friendlyColor }or{enemyColor})[1], transparency)
            renderer:draw(size)
        end
    end
end

return main
end function dote.S()local v=dote.cache.S if not v then v={c=__modImpl()}dote.cache.S=v end return v.c end end do local __modImpl=function()-- by amedote
-- ls threat rings: a ring around every enemy holding a laser strike, the size of its use range,
-- so you can see who can hit you and where. their actual aim never reaches other clients


local Players = game:GetService("Players")

local utility = dote.n()
local orbital = dote.p()

local LocalPlayer = Players.LocalPlayer

local RING_WIDTH = 1
local LS_RANGE = orbital.RANGES["Laser Strike"]

-- cylinder adornments run along Z, so this lays the ring flat
local Z_TO_VERTICAL = CFrame.Angles(math.rad(90), 0, 0)

local main = {}
main.__index = main

function main.new()
    return setmetatable({
        -- player -> ring adornment
        rings = {},
        lastColor = nil,
        lastTransparency = nil,
    }, main)
end
local createRing=function(
color, transparency)    
local ring = Instance.new("CylinderHandleAdornment")
    ring.Name = "\255"
    ring.Adornee = workspace.Terrain -- terrain sits at the origin, so CFrames are world space
    ring.Radius = LS_RANGE
    ring.InnerRadius = LS_RANGE - RING_WIDTH
    ring.Height = 0.3
    ring.AlwaysOnTop = false
    ring.Color3 = color
    ring.Transparency = transparency
    utility.parentToCoreGui(ring)
    return ring
end local isHoldingLs=function(

character)    
local tool = character:FindFirstChildOfClass("Tool")
    return tool ~= nil and tool.Name == "Laser Strike"
end

function main:start()
    Players.PlayerRemoving:Connect(function(player)
        local ring = self.rings[player]
        if ring then
            ring:Destroy()
            self.rings[player] = nil
        end
    end)
end

function main:update()
    local rings = self.rings

    if not Toggles.LsThreatRings.Value then
        for player, ring in rings do
            ring:Destroy()
            rings[player] = nil
        end
        return
    end

    local color = Options.LsThreatRingsColor.Value
    local transparency = Options.LsThreatRingsTransparency.Value
    local styleChanged = color ~= self.lastColor or transparency ~= self.lastTransparency
    self.lastColor = color
    self.lastTransparency = transparency

    for _, player in Players:GetPlayers() do
        local root
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
            local character = player.Character
            if character and isHoldingLs(character) then
                root = character:FindFirstChild("HumanoidRootPart")
            end
        end

        local ring = rings[player]

        if root then
            if not ring then
                ring = createRing(color, transparency)
                rings[player] = ring
            elseif styleChanged then
                ring.Color3 = color
                ring.Transparency = transparency
            end

            ring.CFrame = CFrame.new(root.Position) * Z_TO_VERTICAL
        elseif ring then
            ring:Destroy()
            rings[player] = nil
        end
    end
end

return main
end function dote.T()local v=dote.cache.T if not v then v={c=__modImpl()}dote.cache.T=v end return v.c end end do local __modImpl=function()-- the portafab tool: finding it every life, requiring its placement modules and finding the controller
-- object that runs it, for the features that hook or drive placement. sandbox servers also hand out a
-- "Prototyper" built on the same StructurePlacer; its ghost gets hooked too, but it has its own client
-- script with no controller to drive, so quick build / keep placing use the Portafab.
--   tool.StructurePlacer                    enterPlacementMode(name) / confirmPlacement() / abortPlacement()
--   tool.StructurePlacer.Dragger            the ghost: update() each frame, canPlace, placementInfo, model
--   tool.StructurePlacer.Dragger.Snapping   rotation / snapPoint
--   controller (from the tool's LocalScript) bindDragger() + placing = true is what its menu does before
--                                            entering placement mode, so R / E / T work while placing


local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local TOOL_NAME = "Portafab"

-- tools built on StructurePlacer; their placer can stream in after the tool, so wait for it on these
local BUILD_TOOLS = {
    Portafab = true,
    Prototyper = true,
}

-- per tool, weak so a dead life's tool falls out on its own
local modulesByTool = setmetatable({}, { __mode = "k" })
local controllersByTool = setmetatable({}, { __mode = "k" })
local seenTools = setmetatable({}, { __mode = "k" })

local toolCallbacks = {}
local watching = false
local placerOf=function(
tool)    
local placer = tool:FindFirstChild("StructurePlacer")
    if not placer and BUILD_TOOLS[tool.Name] then
        placer = tool:WaitForChild("StructurePlacer", 5)
    end
    return (placer and placer:IsA("ModuleScript") and{placer }or{nil
})[1]end local onToolFound=function(

tool)    
if seenTools[tool] or not tool:IsA("Tool") or not placerOf(tool) then
        return
    end
    seenTools[tool] = true

    -- a tool destroyed mid placement (dying, respawning) leaves its ghost and the Heartbeat moving it
    -- running, with nothing left to cancel them; end the placement when the tool goes
    tool.AncestryChanged:Connect(function()
        if tool.Parent then
            return
        end
        local modules = modulesByTool[tool]
        if modules then
            pcall(modules.placer.abortPlacement, modules.placer)
        end
    end)

    for _, callback in toolCallbacks do
        task.spawn(callback, tool)
    end
end local watch=function(

container)    
for _, child in container:GetChildren() do
        task.spawn(onToolFound, child)
    end
    container.ChildAdded:Connect(function(child)
        onToolFound(child)
    end)
end local startWatching=function()    



if watching then
        return
    end
    watching = true
local onPlayerChild=function(
child)        
if child:IsA("Backpack") then
            watch(child)
        end
end    
for _, child in LocalPlayer:GetChildren() do
        onPlayerChild(child)
    end
    LocalPlayer.ChildAdded:Connect(onPlayerChild)

    if LocalPlayer.Character then
        watch(LocalPlayer.Character)
    end
    LocalPlayer.CharacterAdded:Connect(watch)
end local onTool=function(


callback)    
table.insert(toolCallbacks, callback)
    for tool in seenTools do
        task.spawn(callback, tool)
    end
    startWatching()
end local getTool=function()    



local character = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    for _, container in { character, backpack } do
        local tool = container and container:FindFirstChild(TOOL_NAME)
        if tool and tool:IsA("Tool") then
            return tool
        end
    end
    return nil
end local getModules=function(


tool)    
local modules = modulesByTool[tool]
    if modules then
        return modules
    end

    local placerModule = placerOf(tool)
    local draggerModule = placerModule and placerModule:WaitForChild("Dragger", 5)
    local snappingModule = draggerModule and draggerModule:WaitForChild("Snapping", 5)
    if not snappingModule then
        return nil
    end

    local ok, result = pcall(function()
        return {
            placer = require(placerModule),
            dragger = require(draggerModule),
            snapping = require(snappingModule),
        }
    end)
    if not ok then
        warn("[eclx] couldn't load the portafab modules:", result)
        return nil
    end

    modulesByTool[tool] = result
    return result
end local getController=function(



tool)    
local controller = controllersByTool[tool]
    if controller then
        return controller
    end
    if not getgc then
        return nil
    end

    for _, value in getgc(true) do
        if type(value) == "table" and rawget(value, "tool") == tool and rawget(value, "uiSlots") ~= nil then
            controllersByTool[tool] = value
            return value
        end
    end
    return nil
end local isEquipped=function(

tool)    
return tool.Parent ~= nil and tool.Parent == LocalPlayer.Character
end local equip=function(


tool, timeout)    
local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return false
    end

    humanoid:EquipTool(tool)
    local controller = getController(tool)
    local deadline = os.clock() + (timeout or 2)
    while os.clock() < deadline do
        if isEquipped(tool) and (not controller or controller.constructionMenuShown) then
            task.wait()
            return true
        end
        task.wait()
    end
    return isEquipped(tool)
end local startPlacing=function(




tool, name, rotation)    
if not isEquipped(tool) then
        return false, "portafab isn't out"
    end
    local modules = getModules(tool)
    local controller = getController(tool)
    if not (modules and controller) then
        return false, "portafab not ready"
    end
    if not modules.placer:getStructureModel(name) then
        return false, string.format('no structure called %s', tostring(name))    
end

    controller:bindDragger()
    controller.placing = true
    local ok, err = pcall(modules.placer.enterPlacementMode, modules.placer, name)
    if not ok then
        controller:abortPlacement()
        return false, err
    end
    if rotation then
        modules.snapping.rotation = rotation
    end
    return true
end

return {
    TOOL_NAME = TOOL_NAME,
    onTool = onTool,
    getTool = getTool,
    getModules = getModules,
    getController = getController,
    isEquipped = isEquipped,
    equip = equip,
    startPlacing = startPlacing,
}
end function dote.U()local v=dote.cache.U if not v then v={c=__modImpl()}dote.cache.U=v end return v.c end end do local __modImpl=function()-- place anyway: lets the portafab place a structure where its ghost shows red.
-- the portafab's Dragger works out the placement every frame in Dragger.update and only sets
-- Dragger.canPlace when the spot passes its checks; StructurePlacer:confirmPlacement places nothing
-- unless that flag is set. wrapping update to set it after the game's own check is enough, and the
-- ghost is tinted teal so you can see it will go through. each life's portafab gets its own Dragger


local portafab = dote.U()
local utility = dote.n()

local PLACEABLE_COLOR = BrickColor.new("Teal")

local main = {}
main.__index = main

function main.new()
    return setmetatable({}, main)
end

function main:_wrap(Dragger)
    if typeof(Dragger.update) ~= "function" or not utility.claimHook("placeanyway", Dragger) then
        return
    end

    -- the ghost's parts, collected once per ghost instead of walking the model every frame
    local partsModel, parts = nil, {}

    -- enterPlacementMode reads Dragger.update each time it connects it, so swapping the field is enough
    local oldUpdate = Dragger.update
    Dragger.update = function(...)
        oldUpdate(...)

        -- the model is unparented when the mouse ray hit nothing; placementInfo is stale then, so leave it
        local model = Dragger.model
        if Toggles["PORTAFAB/PlaceAnyway"].Value and model and model.Parent and not Dragger.canPlace then
            Dragger.canPlace = true

            -- pipes are redrawn every frame while placing, so their parts can't be kept
            if model ~= partsModel or model.Name == "Pipe" then
                partsModel = model
                table.clear(parts)
                for _, descendant in model:GetDescendants() do
                    if descendant:IsA("BasePart") then
                        table.insert(parts, descendant)
                    end
                end
            end
            for _, part in parts do
                part.BrickColor = PLACEABLE_COLOR
            end
        end
    end
end

function main:start()
    portafab.onTool(function(tool)
        local modules = portafab.getModules(tool)
        if modules then
            self:_wrap(modules.dragger)
        end
    end)
end

return main
end function dote.V()local v=dote.cache.V if not v then v={c=__modImpl()}dote.cache.V=v end return v.c end end do local __modImpl=function()-- keep placing: after a portafab placement goes through, go straight back to placing the same structure
-- turned the same way, until you cancel with E.
-- quick build: keybinds that start placing a chosen structure, equipping the portafab first if it isn't
-- out. both go through the portafab's own controller (see portafab.startPlacing), so rotate / cancel /
-- snap behave as they do from the menu. slots are fired through container.quickBuildCall


local portafab = dote.U()
local utility = dote.n()
local container = dote.o()

local main = {}
main.__index = main

function main.new()
    return setmetatable({
        -- a slot is being equipped / started; presses meanwhile are dropped so they can't stack up
        busy = false,
    }, main)
end

function main:_hook(tool)
    local modules = portafab.getModules(tool)
    if not modules or not utility.claimHook("buildtools", modules.placer) then
        return
    end
    local placer, snapping = modules.placer, modules.snapping

    -- what's being placed, so keep placing knows what to pick back up
    local current
    local oldEnter = placer.enterPlacementMode
    placer.enterPlacementMode = function(placerSelf, name, ...)
        current = name
        return oldEnter(placerSelf, name, ...)
    end

    local oldConfirm = placer.confirmPlacement
    placer.confirmPlacement = function(placerSelf, ...)
        local name, rotation = current, snapping.rotation
        local placed = oldConfirm(placerSelf, ...)

        if placed and name and Toggles["PORTAFAB/KeepPlacing"].Value then
            -- the controller ends placement right after this returns, so start again once it has
            task.defer(function()
                if portafab.isEquipped(tool) then
                    portafab.startPlacing(tool, name, rotation)
                end
            end)
        end

        return placed
    end

    -- find the controller now rather than on the first placement, when it would cause a hitch
    if Toggles["PORTAFAB/KeepPlacing"].Value or Toggles.QuickBuild.Value then
        portafab.getController(tool)
    end
end

function main:trigger(slot)
    if not Toggles.QuickBuild.Value then
        return
    end

    local name = Options[string.format('QuickBuild/Slot%s', tostring(slot))].Value
    if not name then
        return
    end

    local tool = portafab.getTool()
    if not tool or self.busy then
        return
    end

    self.busy = true
    task.spawn(function()
        local ok, err = pcall(function()
            local ready = portafab.isEquipped(tool)
                or (Toggles["QuickBuild/AutoEquip"].Value and portafab.equip(tool))
            if not ready then
                return
            end
            local started, reason = portafab.startPlacing(tool, name)
            if not started then
                warn("[quick build]", reason)
            end
        end)
        if not ok then
            warn("[quick build]", err)
        end
        self.busy = false
    end)
end

function main:start()
    portafab.onTool(function(tool)
        self:_hook(tool)
    end)

    container.quickBuildCall:Connect(function(slot)
        self:trigger(slot)
    end)
end

return main
end function dote.W()local v=dote.cache.W if not v then v={c=__modImpl()}dote.cache.W=v end return v.c end end do local __modImpl=function()-- fast placement: fixes the hitch the game itself has every time a portafab ghost is made.
-- the game's Dragger.setModel re-tags every SnapPart in the world (each flange and snap point of every
-- structure, ~18k in a built-up match) with RayIgnore, one AddTag call each, though almost all of them
-- already have it. this is the same setModel with that loop reduced to the parts whose tag can differ,
-- found from an index the tag signals keep: the end state is identical, without reading every part.
-- if it ever errors (say the game changes setModel), the game's own version runs instead


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local portafab = dote.U()
local utility = dote.n()

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ModelUtility = require(Shared:WaitForChild("Utilities"):WaitForChild("ModelUtility"))
local SnapStructureList = require(Shared:WaitForChild("Data"):WaitForChild("SnapStructureList"))

local main = {}
main.__index = main

function main.new()
    return setmetatable({}, main)
end

-- a live index of the snap parts and which of them carry RayIgnore, kept by the tag signals, so a new
-- ghost only has to look at the parts whose tag can differ instead of reading all ~18k. holding the parts
-- here also keeps their lua handles alive, so they work as table keys
local snapNames = {} -- snap part -> its name when it was tagged
local snapByName = {} -- name -> { snap part = true }
local ignored = {} -- part -> true while it has RayIgnore
local dirty = {} -- snap parts whose tag may be wrong for the current ghost
local lastWanted = {} -- the WorldSnap names of the last ghost
local indexed = false
local addSnap=function(
part)    
local name = part.Name
    snapNames[part] = name
    snapByName[name] = snapByName[name] or {}
    snapByName[name][part] = true
    dirty[part] = true
end local removeSnap=function(

part)    
local name = snapNames[part]
    if name and snapByName[name] then
        snapByName[name][part] = nil
    end
    snapNames[part] = nil
    dirty[part] = nil
end local buildIndex=function()    


if indexed then
        return
    end
    indexed = true

    for _, part in CollectionService:GetTagged("RayIgnore") do
        ignored[part] = true
    end
    -- everything starts dirty, so the first ghost does one full pass like the game's version
    for _, part in CollectionService:GetTagged("SnapPart") do
        addSnap(part)
    end

    CollectionService:GetInstanceAddedSignal("SnapPart"):Connect(addSnap)
    CollectionService:GetInstanceRemovedSignal("SnapPart"):Connect(removeSnap)
    -- anything else changing the tag on a snap part gets it checked on the next ghost
    CollectionService:GetInstanceAddedSignal("RayIgnore"):Connect(function(part)
        ignored[part] = true
        if snapNames[part] then
            dirty[part] = true
        end
    end)
    CollectionService:GetInstanceRemovedSignal("RayIgnore"):Connect(function(part)
        ignored[part] = nil
        if snapNames[part] then
            dirty[part] = true
        end
    end)
end local retag=function(



wanted)local fix=function(
part)        
local shouldIgnore = not wanted[snapNames[part] ]
        if shouldIgnore ~= (ignored[part] == true) then
            if shouldIgnore then
                CollectionService:AddTag(part, "RayIgnore")
                ignored[part] = true
            else
                CollectionService:RemoveTag(part, "RayIgnore")
                ignored[part] = nil
            end
        end
end
    
for _, names in { lastWanted, wanted } do
        for name in names do
            for part in snapByName[name] or {} do
                fix(part)
            end
        end
    end
    for part in dirty do
        fix(part)
    end
    -- the tag signals for the fixes above may still be queued; they'll mark parts that are already right
    table.clear(dirty)
    lastWanted = wanted
end local setModel=function(


Dragger, model)    
buildIndex()

    if Dragger.model then
        Dragger.model:Destroy()
    end
    Dragger.model = model

    -- snap parts this structure can snap to are hit by the mouse ray; every other one is ignored
    local worldSnap = {}
    local entry = SnapStructureList[model.Name]
    for _, name in entry and entry.WorldSnap or {} do
        worldSnap[name] = true
    end
    retag(worldSnap)

    ModelUtility:recurse(model, function(instance)
        for _, tag in pairs(CollectionService:GetTags(instance)) do
            if tag:sub(1, 7) == "Texture" then
                CollectionService:RemoveTag(instance, tag)
            end
        end

        if not instance:IsA("BasePart") or instance:IsA("Seat") or instance:IsA("VehicleSeat") then
            if not (instance:IsA("Model") or instance:IsA("DataModelMesh") or instance:IsA("NumberValue")) then
                pcall(function()
                    instance:Destroy()
                end)
            end
            return
        end

        instance.Transparency = 1 - (1 - instance.Transparency) * 0.30000000000000004
        instance.CanCollide = false
        instance.Anchored = true
    end)

    Instance.new("Folder", model).Name = "PlacementTag"
    Dragger.canPlace = false
    ModelUtility:setProperties(model, "BrickColor", BrickColor.new("Really red"), "BasePart")
end

function main:_wrap(Dragger)
    if typeof(Dragger.setModel) ~= "function" or not utility.claimHook("fastplacement", Dragger) then
        return
    end

    -- enterPlacementMode and update both call Dragger:setModel, so swapping the field is enough
    local oldSetModel = Dragger.setModel
    Dragger.setModel = function(self, model)
        if Toggles["PORTAFAB/FastPlacement"].Value then
            local ok, err = pcall(setModel, Dragger, model)
            if ok then
                return
            end
            warn("[fast placement] fell back to the game's setModel:", err)
            -- a half done attempt may have set the model already; the game's version starts clean
            if Dragger.model == model then
                Dragger.model = nil
            end
        end

        -- the game's version retags by a WorldSnap list the index doesn't see, so the next fast ghost
        -- checks every part once
        for part in snapNames do
            dirty[part] = true
        end
        return oldSetModel(self, model)
    end
end

function main:start()
    portafab.onTool(function(tool)
        local modules = portafab.getModules(tool)
        if modules then
            self:_wrap(modules.dragger)
        end
    end)
end

return main
end function dote.X()local v=dote.cache.X if not v then v={c=__modImpl()}dote.cache.X=v end return v.c end end do local __modImpl=function()-- gun mods for the hitscan guns (SMG, Pistol...), which all run on GunHitscanClient:
--   no sprint check   IsSprinting (the character's Sprinting attribute) always reads false, so you can
--                     fire while sprinting
--   no iridium usage  HasIridium always passes and ConsumeIridium does nothing. the gun is what tells the
--                     server how much a shot cost ("IridiumConsumed" on the tool's Remote), so skipping
--                     it means nothing is taken


local ReplicatedStorage = game:GetService("ReplicatedStorage")

local utility = dote.n()

local main = {}
main.__index = main

function main.new()
    return setmetatable({}, main)
end

function main:start()
    local GunHitscanClient = require(
        ReplicatedStorage:WaitForChild("Shared")
            :WaitForChild("Class")
            :WaitForChild("GunClient")
            :WaitForChild("GunHitscanClient")
    )
    if not utility.claimHook("gunmods", GunHitscanClient) then
        return
    end

    local oldIsSprinting = GunHitscanClient.IsSprinting
    local oldHasIridium = GunHitscanClient.HasIridium
    local oldConsumeIridium = GunHitscanClient.ConsumeIridium

    function GunHitscanClient.IsSprinting(...)
        if Toggles["GunMods/NoSprintCheck"].Value then
            return false
        end
        return oldIsSprinting(...)
    end

    function GunHitscanClient.HasIridium(...)
        if Toggles["GunMods/NoIridium"].Value then
            return true
        end
        return oldHasIridium(...)
    end

    function GunHitscanClient.ConsumeIridium(...)
        if Toggles["GunMods/NoIridium"].Value then
            return
        end
        return oldConsumeIridium(...)
    end
end

return main
end function dote.Y()local v=dote.cache.Y if not v then v={c=__modImpl()}dote.cache.Y=v end return v.c end end do local __modImpl=function()-- rocket silent aim: the rocket lands where you click instead of falling short.
-- the rocket launcher reports where it's aimed every frame (Remote "TargetingUpdated" with the part, the
-- point and the normal under the mouse, next to "BarrelPositionUpdated"), and the server fires the rocket
-- from the barrel straight at the last point it was told. rockets fly at a steady ROCKET_SPEED and drop
-- slightly (ROCKET_DROP, measured in game), so the point reported is raised by the drop over the flight
-- time, and moved ahead of a moving player so the rocket meets them.
-- while the launcher is out, the indicator marks the spot the rocket will hit, outlines what's there, and
-- shows its health, the distance and the flight time


local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local utility = dote.n()
local theme = dote.b()

local ROCKET_SPEED = 80
local ROCKET_DROP = 8.2
-- each pass refines the flight time with the last aim point; drop and lead are small, so this settles fast
local SOLVE_PASSES = 4
local TOOL_NAME = "Rocket Launcher"
-- a TargetingUpdated older than this means the launcher stopped aiming (put away, dead)
local TARGET_MAX_AGE = 0.5
local MARKER_RADIUS = 1.2
-- where the info card sits from the cursor, out of the way of what you're aiming at
local CARD_OFFSET = Vector2.new(28, -26)

local colors = theme.colors
local fonts = theme.fonts
local create = theme.create
local corner = theme.corner
local text = theme.text

local LocalPlayer = Players.LocalPlayer

local main = {}
main.__index = main

function main.new()
    return setmetatable({
        -- last barrel position the launcher reported, which is where the rocket leaves from
        barrel = nil,
        -- last target the launcher reported: { part, position, at }
        target = nil,
        marker = nil,
        highlight = nil,
        card = nil,
        shownModel = nil,
    }, main)
end
local targetVelocity=function(

part)    
local model = typeof(part) == "Instance" and part:FindFirstAncestorOfClass("Model")
    local humanoid = model and model:FindFirstChildOfClass("Humanoid")
    local root = humanoid and humanoid.RootPart
    return (root and{(root.AssemblyLinearVelocity )}or{(Vector3.zero
)})[1]end local solveAim=function(


origin, target, velocity)    
local aim, flightTime = target, 0
    for _ = 1, SOLVE_PASSES do
        flightTime = (aim - origin).Magnitude / ROCKET_SPEED
        local meet = target + velocity * flightTime
        aim = meet + Vector3.new(0, 0.5 * ROCKET_DROP * flightTime * flightTime, 0)
    end
    return aim, flightTime
end local targetModel=function(


part)    
if typeof(part) ~= "Instance" then
        return nil
    end
    local model = part:FindFirstAncestorOfClass("Model")
    if model and model:FindFirstChildOfClass("Humanoid") then
        return model, "player"
    end
    local structures = workspace:FindFirstChild("Structures")
    local current = part
    while current and current.Parent do
        if current.Parent == structures then
            return current, "structure"
        end
        current = current.Parent
    end
    return nil
end local healthOf=function(


model, kind)    
if kind == "player" then
        local humanoid = model:FindFirstChildOfClass("Humanoid")
        if humanoid then
            return math.max(humanoid.Health, 0), humanoid.MaxHealth
        end
        return nil
    end
    local maxHealth = model:GetAttribute("MaxHealth")
    if typeof(maxHealth) ~= "number" or maxHealth <= 0 then
        return nil
    end
    local health = model:GetAttribute("Health")
    return (typeof(health) == "number" and{(math.max(health, 0) )}or{maxHealth})[1], maxHealth
end local healthColor=function(

ratio)    
return (ratio > 0.5 and{(colors.success )}or{((ratio > 0.25 and{(colors.corona )}or{(colors.danger
)})[1])})[1]end

function main:_buildIndicator()
    local marker = Instance.new("SphereHandleAdornment")
    marker.Name = "\255"
    marker.Adornee = workspace.Terrain -- terrain sits at the origin, so CFrames are world space
    marker.Radius = MARKER_RADIUS
    marker.Transparency = 0.15
    marker.AlwaysOnTop = true
    marker.ZIndex = 2
    marker.Visible = false
    utility.parentToCoreGui(marker)
    self.marker = marker

    -- AlwaysOnTop draws the target's outline through walls
    local highlight = Instance.new("Highlight")
    highlight.Name = "\255"
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.8
    highlight.OutlineTransparency = 0
    highlight.Enabled = false
    utility.parentToCoreGui(highlight)
    self.highlight = highlight

    -- the card sits beside the cursor: what's there, its health, distance and flight time. the gui ignores
    -- the inset so mouse locations line up with it
    local card = create("ScreenGui", {
        Name = "\255",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        DisplayOrder = 10,
        Enabled = false,
        Parent = theme.guiParent(),
    })
    -- a canvas group so the transparency slider fades the whole card at once
    local panel = create("CanvasGroup", {
        Size = UDim2.fromOffset(170, 52),
        BackgroundColor3 = colors.background,
        BackgroundTransparency = 0.2,
        Parent = card,
    }, { corner(6), theme.stroke(colors.strokeBright) })
    self.cardPanel = panel
    self.cardName = text({
        Position = UDim2.fromOffset(8, 4),
        Size = UDim2.new(1, -16, 0, 14),
        Font = fonts.bold,
        TextSize = 12,
        Parent = panel,
    })
    self.cardHealthText = text({
        Position = UDim2.fromOffset(8, 4),
        Size = UDim2.new(1, -16, 0, 14),
        Font = fonts.mono,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = panel,
    })
    local track = create("Frame", {
        Position = UDim2.fromOffset(8, 22),
        Size = UDim2.new(1, -16, 0, 6),
        BackgroundColor3 = colors.field,
        BorderSizePixel = 0,
        Parent = panel,
    }, { corner(3) })
    self.cardTrack = track
    self.cardBar = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = colors.success,
        BorderSizePixel = 0,
        Parent = track,
    }, { corner(3) })
    self.cardInfo = text({
        Position = UDim2.fromOffset(8, 32),
        Size = UDim2.new(1, -16, 0, 14),
        Font = fonts.mono,
        TextSize = 10,
        TextColor3 = colors.muted,
        Parent = panel,
    })
    self.card = card
end

function main:_hideIndicator()
    if self.marker and self.marker.Visible then
        self.marker.Visible = false
        self.highlight.Enabled = false
        self.highlight.Adornee = nil
        self.card.Enabled = false
        self.shownModel = nil
    end
end

function main:start()
    utility.hookNamecall("FireServer", function(old, remote, action, ...)
        if not Toggles.RocketSilentAim.Value or remote.Name ~= "Remote" then
            return old(remote, action, ...)
        end
        local tool = remote.Parent
        if not (tool and tool.Name == TOOL_NAME) then
            return old(remote, action, ...)
        end

        if action == "BarrelPositionUpdated" then
            local position = ...
            if typeof(position) == "Vector3" then
                self.barrel = position
            end
        elseif action == "TargetingUpdated" then
            local part, position, normal = ...
            if typeof(position) == "Vector3" then
                self.target = { part = part, position = position, at = os.clock() }
            end
            if self.barrel and typeof(position) == "Vector3" then
                local velocity = (Toggles["RocketSilentAim/Lead"].Value and{(targetVelocity(part) )}or{(Vector3.zero
)})[1]                local aim = solveAim(self.barrel, position, velocity)
                return old(remote, action, part, aim, normal)
            end
        end

        return old(remote, action, ...)
    end, { "RocketSilentAim" })
end

-- call every frame
function main:update()
    local target = self.target
    local character = LocalPlayer.Character
    local holding = character and character:FindFirstChild(TOOL_NAME)

    if
        not (Toggles.RocketSilentAim.Value and Toggles["RocketSilentAim/Indicator"].Value)
        or not (holding and target and self.barrel)
        or os.clock() - target.at > TARGET_MAX_AGE
    then
        self:_hideIndicator()
        return
    end

    if not self.marker then
        self:_buildIndicator()
    end

    local color = Options["RocketSilentAim/IndicatorColor"].Value
    local velocity = (Toggles["RocketSilentAim/Lead"].Value and{(targetVelocity(target.part) )}or{(Vector3.zero
)})[1]local _, flightTime =solveAim(self.barrel, target.position, velocity)
    -- where the rocket meets the target: ahead of a moving player, on the spot for anything else
    local impact = target.position + velocity * flightTime

    local marker = self.marker
    marker.CFrame = CFrame.new(impact)
    if marker.Color3 ~= color then
        marker.Color3 = color
        self.highlight.OutlineColor = color
        self.highlight.FillColor = color
    end
    local transparency = Options["RocketSilentAim/IndicatorTransparency"].Value
    if transparency ~= self.shownTransparency then
        self.shownTransparency = transparency
        marker.Transparency = transparency
        self.highlight.OutlineTransparency = transparency
        -- the fill stays faint even when the slider is at 0, or it would hide what it's on
        self.highlight.FillTransparency = math.max(transparency, 0.8)
    end
    marker.Visible = true

    local model, kind = targetModel(target.part)
    local highlight = self.highlight
    if model ~= self.shownModel then
        self.shownModel = model
        highlight.Adornee = model
        highlight.Enabled = model ~= nil
    end

    local card = self.card
    local mouse = UserInputService:GetMouseLocation()
    self.cardPanel.Position = UDim2.fromOffset(mouse.X + CARD_OFFSET.X, mouse.Y + CARD_OFFSET.Y)
    self.cardPanel.GroupTransparency = Options["RocketSilentAim/CardTransparency"].Value
    card.Enabled = true

    local distance = (impact - self.barrel).Magnitude
    self.cardInfo.Text = string.format("%d studs  ·  %.1fs", math.round(distance), flightTime)

    local health, maxHealth
    if model then
        health, maxHealth = healthOf(model, kind)
        self.cardName.Text = model.Name
        self.cardName.TextColor3 = (kind == "player" and{color }or{(colors.text
)})[1]    else
        self.cardName.Text = "Ground"
        self.cardName.TextColor3 = colors.muted
    end

    if health and maxHealth and maxHealth > 0 then
        local ratio = math.clamp(health / maxHealth, 0, 1)
        self.cardTrack.Visible = true
        self.cardBar.Size = UDim2.fromScale(ratio, 1)
        self.cardBar.BackgroundColor3 = healthColor(ratio)
        self.cardHealthText.Text = string.format("%d / %d", math.round(health), math.round(maxHealth))
    else
        self.cardTrack.Visible = false
        self.cardHealthText.Text = ""
    end
end

return main
end function dote.Z()local v=dote.cache.Z if not v then v={c=__modImpl()}dote.cache.Z=v end return v.c end end end-- EclX client for Eclipsis


loadstring([[
    function LPH_NO_VIRTUALIZE(f) return f end;
	function LPH_JIT(f) return f end;
	function LPH_JIT_MAX(f) return f end;
	function LPH_NO_UPVALUES(f) return f end;
]])()

local RunService = game:GetService("RunService")

local signal = dote.a()
local Library = dote.c()
local nccam = dote.d()
local structures = dote.e()
local Tracker = dote.f()
local StatsBoard = dote.h()
local scoreWeights = dote.i()

local QUICK_BUILD_SLOTS = 6

local env = (getgenv and{(getgenv() )}or{_G
})[1]
-- joining a match as a spectator loads the match viewer instead of the client
local viewer = dote.u()
if env.EclXViewer then
    env.EclXViewer:SetVisible(true)
    return
end
if not env.EclX and viewer.shouldView() then
    env.EclXViewer = viewer.start()
    return
end

-- running it again just brings the window back; loading the features twice would stack every hook and
-- double the work the game does each frame, so it only ever loads once per server
if env.EclX then
    if not env.EclX.unloaded then
        env.EclX:SetVisible(true)
    else
        warn("[eclx] already loaded in this server. Rejoin to load it again")
    end
    return
end

local window = Library.new({
    globals = true,
    -- spawn pads change every game, so the picked one isn't saved
    configIgnore = { SelectedPadList = true },
})
env.EclX = window

local LocalTab = window:AddTab("Local Player")
local CombatTab = window:AddTab("Combat")
local BuildTab = window:AddTab("Build")
local AutoTab = window:AddTab("Autos")
local VisualTab = window:AddTab("Visuals")
local MatchTab = window:AddTab("Match")

do
    local instantTPCall = signal.new()
    local instantRespawnCall = signal.new()
    local quickBuildCall = signal.new()

    local camera = LocalTab:AddRightGroupbox("Camera")
    camera:AddLabel("Noclip Camera"):AddKeyPicker("NcCam", {
        Text = "Noclip Camera",
        Mode = "Press",
        Callback = function()
            nccam()
        end,
    })

    local JetpackMods = LocalTab:AddLeftGroupbox("Jetpack")
    JetpackMods:AddCheckbox("JetPackMods", { Text = "Enable Jetpack Mods" })
    JetpackMods:AddSlider("MaxThrustTime", { Text = "Set Max Thrust Time", Default = 5, Min = 1, Max = 100 })
    JetpackMods:AddSlider(
        "CooldownTime",
        { Text = "Set Cooldown Time", Default = 0.05, Min = 0.01, Max = 1, Rounding = 2 }
    )
    JetpackMods:AddSlider("PowerThrust", { Text = "Set Power Thrust", Default = 17, Min = 1, Max = 100 })

    local UtilityMods = LocalTab:AddLeftGroupbox("Utility")
    UtilityMods:AddCheckbox("FallDamage", { Text = "No Fall Damage" })
    UtilityMods:AddCheckbox("InstantProduceWeapons", { Text = "Instant Produce Weapons" })
    UtilityMods:AddCheckbox("AutoInteractBore", {
        Text = "Auto Interact Bore",
        Tooltip = "Aim or power any bore you point at from any distance, through shields",
    })
    UtilityMods:AddLabel("Bore aim key"):AddKeyPicker("AutoBore/AimKey", {
        Text = "Bore aim key",
        Default = "MB1",
        Mode = "Press",
        AllowMouse1 = true,
    })
    UtilityMods:AddLabel("Bore power key"):AddKeyPicker("AutoBore/PowerKey", {
        Text = "Bore power key",
        Default = "E",
        Mode = "Press",
        AllowMouse1 = true,
    })
    UtilityMods:AddCheckbox("ArtyGravity", {Text = "Arty Gravity (PRE ECO ONLY)"})
    UtilityMods:AddSlider(
        "GravitySlider",
        { Text = "Set Arty Gravity", Default = 70, Min = 1, Max = 100, Tooltip = "Default: 70" }
    )
    UtilityMods:AddCheckbox("StopOrbitalError", {
        Text = "Stop Orbital Error",
        Tooltip = "Blocks LS/OS use when the target is out of range (LS 125, OS 250 studs), so you don't get the cooldown",
    })

    local SpawnPointMods = LocalTab:AddRightGroupbox("Spawn Point")
    local selectedSpawnLabel = SpawnPointMods:AddLabel("Selected:")
    SpawnPointMods:AddDropdown("SelectedPadList", {
        Text = "Select Spawn",
        Multi = false,
        FormatDisplayValue = function(value)
            return string.format('S%s', tostring(value))        
end,
    })
    -- a stray click (like the one that focuses the game after executing) shouldn't teleport or kill you
    SpawnPointMods:AddButton({
        Text = "Instant Teleport",
        DoubleClick = true,
        Func = function()
            instantTPCall:Fire()
        end,
    })
    SpawnPointMods:AddButton({
        Text = "Instant Respawn",
        DoubleClick = true,
        Func = function()
            instantRespawnCall:Fire()
        end,
    })
    SpawnPointMods:AddLabel("Instant Teleport Keybind"):AddKeyPicker("InstantTPKeybind", {
        Text = "Instant Teleport",
        Mode = "Toggle",
        Callback = function()
            instantTPCall:Fire()
        end,
    })
    SpawnPointMods:AddLabel("Instant Respawn Keybind"):AddKeyPicker("InstantRespawnKeybind", {
        Text = "Instant Respawn",
        Mode = "Toggle",
        Callback = function()
            instantRespawnCall:Fire()
        end,
    })

    local SilentAimSection = CombatTab:AddLeftGroupbox("Silent Aim")
    SilentAimSection:AddCheckbox("SilentAim", { Text = "Silent Aim" }):AddKeyPicker("SilentAimKey", {
        Text = "Silent Aim",
        Mode = "Hold",
        SyncToggleState = true,
    })
    SilentAimSection:AddDropdown(
        "SilentAim/BodyParts",
        { Text = "Select BodyPart", Default = "Head", Values = { "Head", "Random", "HumanoidRootPart" }, Multi = false }
    )
    SilentAimSection:AddCheckbox("SilentAim/TeamCheck", { Text = "Teamcheck" })
    SilentAimSection:AddCheckbox("SilentAim/DrawFov", { Text = "Draw FOV" }):AddColorPicker("SilentAim/DrawFovColor", {
        Default = Color3.fromRGB(255, 255, 255),
        Title = "Draw FOV Color",
        Transparency = 0,
    })
    SilentAimSection:AddSlider("SilentAim/DrawFovValue", { Text = "Set FOV", Default = 425, Min = 1, Max = 1000 })
    SilentAimSection:AddSlider("SilentAim/AccuracyValue", { Text = "Set Accuracy", Default = 100, Min = 1, Max = 100 })
    SilentAimSection:AddLabel("Locked on Color")
        :AddColorPicker("SilentAim/Color", { Default = Color3.fromRGB(255, 0, 0), Title = "locked on color" })

    local LsSilentAimSection = CombatTab:AddLeftGroupbox("LS Silent Aim")
    LsSilentAimSection:AddCheckbox("LsSilentAim", {
        Text = "LS Silent Aim",
        Tooltip = "Laser strikes land on the enemy player or weak structure (Refill Station, Ladder Block, Block, Bridge) closest to your mouse",
    }):AddKeyPicker("LsSilentAimKey", {
        Text = "LS Silent Aim",
        Mode = "Hold",
        SyncToggleState = true,
    })
    LsSilentAimSection:AddCheckbox("LsSilentAim/DrawFov", { Text = "Draw FOV" }):AddColorPicker("LsSilentAim/DrawFovColor", {
        Default = Color3.fromRGB(255, 255, 255),
        Title = "LS FOV Color",
    })
    LsSilentAimSection:AddSlider("LsSilentAim/FovValue", { Text = "Set FOV", Default = 200, Min = 1, Max = 1000 })
    LsSilentAimSection:AddCheckbox("LsSilentAim/HighlightTarget", {
        Text = "Highlight Target",
        Tooltip = "Highlights the selected target through walls",
    }):AddColorPicker("LsSilentAim/HighlightColor", { Default = Color3.fromRGB(255, 0, 0), Title = "LS Target Color" })
    LsSilentAimSection:AddSlider(
        "LsSilentAim/HighlightTransparency",
        { Text = "Highlight Transparency", Default = 0.5, Min = 0, Max = 1, Rounding = 2 }
    )
    LsSilentAimSection:AddCheckbox("LsSilentAim/Chams", {
        Text = "Structure Chams",
        Tooltip = "Shows every structure inside the FOV through walls",
    })
    LsSilentAimSection:AddSlider(
        "LsSilentAim/ChamsTransparency",
        { Text = "Chams Transparency", Default = 0.4, Min = 0, Max = 1, Rounding = 2 }
    )
    LsSilentAimSection:AddSlider(
        "LsSilentAim/WallTransparency",
        { Text = "Gate/Wall/Bridge Transparency", Default = 0.9, Min = 0, Max = 1, Rounding = 2, Tooltip = "How see-through gates, walls and bridges are in the chams" }
    )

    local GunModsSection = CombatTab:AddRightGroupbox("Gun Mods")
    GunModsSection:AddCheckbox("GunMods/NoSprintCheck", {
        Text = "No Sprint Check",
        Tooltip = "Fire guns while sprinting",
    })
    GunModsSection:AddCheckbox("GunMods/NoIridium", {
        Text = "No Iridium Usage",
        Tooltip = "Guns don't use iridium when they fire",
    })

    local RocketAimSection = CombatTab:AddRightGroupbox("Rocket Silent Aim")
    RocketAimSection:AddCheckbox("RocketSilentAim", {
        Text = "Rocket Silent Aim",
        Tooltip = "Rockets land where you click: the aim is raised for the rocket's drop over the distance",
    })
    RocketAimSection:AddCheckbox("RocketSilentAim/Lead", {
        Text = "Lead Moving Players",
        Default = true,
        Tooltip = "When you click a player, aims where they'll be when the rocket gets there",
    })
    RocketAimSection:AddCheckbox("RocketSilentAim/Indicator", {
        Text = "Show Impact Point",
        Default = true,
        Tooltip = "Marks where the rocket will hit and shows what's there: its health, the distance and the flight time",
    }):AddColorPicker("RocketSilentAim/IndicatorColor", {
        Title = "Impact Point Color",
        Default = Color3.fromRGB(255, 120, 40),
    })
    RocketAimSection:AddSlider("RocketSilentAim/IndicatorTransparency", {
        Text = "Marker Transparency",
        Default = 0.15,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Tooltip = "The dot where the rocket will hit and the outline on what's there",
    })
    RocketAimSection:AddSlider("RocketSilentAim/CardTransparency", {
        Text = "Info Card Transparency",
        Default = 0.2,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Tooltip = "The card next to the cursor with the target's health, distance and flight time",
    })

    local BoreAimSection = CombatTab:AddRightGroupbox("Bore Aimbot")
    BoreAimSection:AddCheckbox("BoreAimbot", {Text = "Bore Aimbot", Tooltip = "When you aim a bore at another bore, it will automatically reaim towards the tilt assembly of the bore (top)"})
    BoreAimSection:AddCheckbox("AimAtCenterOfOtherParts", {Text = "Aim at center", Tooltip = "Whether or not aiming a bore will reaim towards the center of a part."})
    BoreAimSection:AddCheckbox("BoreTargetBlueprints", {
        Text = "Target Blueprints",
        Default = true,
        Tooltip = "Lets you set a bore's target on a blueprint; the game's own targeting looks straight through them",
    })

    local PortafabMods = BuildTab:AddLeftGroupbox("Portafab")
    PortafabMods:AddCheckbox("PORTAFAB/InfiniteRange", { Text = "Infinite Context Range" })
    PortafabMods:AddCheckbox("PORTAFAB/PlaceAnyway", {
        Text = "Place Anyway",
        Tooltip = "Lets the portafab place where its ghost shows red (the server may still refuse some spots)",
    })
    PortafabMods:AddCheckbox("PORTAFAB/KeepPlacing", {
        Text = "Keep Placing",
        Tooltip = "Stays in placement mode after placing, turned the same way, so you can keep building. E stops",
    })
    PortafabMods:AddCheckbox("PORTAFAB/FastPlacement", {
        Text = "Fast Placement",
        Default = true,
        Tooltip = "Fixes the game's hitch when you pick a structure: it re-tags every snap point on the map each time (~18k calls in a built-up match). This only touches the few that change",
    })
    PortafabMods:AddDivider()
    PortafabMods:AddCheckbox("PORTAFAB/ExtendPipeHitbox", { Text = "Extend Pipe Hitbox" })
    PortafabMods:AddSlider(
        "PORTAFAB/ExtendPipeHitboxSize",
        { Text = "Set Hitbox Size", Default = 1.9, Min = 1.9, Max = 5, Rounding = 2, Tooltip = "2.5 to 3.5 Is good" }
    )

    local QuickBuild = BuildTab:AddRightGroupbox("Quick Build")
    QuickBuild:AddCheckbox("QuickBuild", {
        Text = "Enable Quick Build",
        Tooltip = "Each slot's key starts placing its structure straight away, no menu",
    })
    QuickBuild:AddCheckbox("QuickBuild/AutoEquip", {
        Text = "Auto Equip Portafab",
        Default = true,
        Tooltip = "Takes the portafab out when a slot's key is pressed while it's put away",
    })
    QuickBuild:AddDivider()
    local structureNames = structures.getNames()
    for slot = 1, QUICK_BUILD_SLOTS do
        QuickBuild:AddDropdown(string.format('QuickBuild/Slot%s', tostring(slot)), {
            Text = string.format('Slot %s', tostring(slot)),
            Values = structureNames,
            Tooltip = "Click the key on the right to bind it",
        }):AddKeyPicker(string.format('QuickBuild/Key%s', tostring(slot)), {
            Text = string.format('Slot %s', tostring(slot)),
            Mode = "Press",
            Callback = function()
                quickBuildCall:Fire(slot)
            end,
        })
    end

    local AutoStuff = AutoTab:AddLeftGroupbox("Auto")
    AutoStuff:AddCheckbox("AutoDCap", {Text = "Auto DCap"})
    AutoStuff:AddSlider("AutoDCapDelay", { Text = "AutoDCapDelay", Default = 0.1, Min = 0, Max = 1, Rounding = 2 })
    AutoStuff:AddDropdown("AutoDCapDropdown", {
        Text = "Select Structures",
        Multi = true,
        Values = {
            "Arc Turret",
            "Turret",
            "Fabricator",
            "Automechanic",
            "Boost Pad",
            "Observer",
            "Spatial Anchor",
            "Spawn Point",
            "Shield Generator",
            "Point Defense",
        }
    })
    AutoStuff:AddCheckbox("AutoShield", {Text = "AutoShield", Tooltip = "Automatically turns on shields and anchors when placed"})
    AutoStuff:AddCheckbox("AutoBorePipe", {Text = "Auto four-way bores"})

    local ArtillerySection = VisualTab:AddLeftGroupbox("Artillery")
    ArtillerySection:AddCheckbox("artyVisual", { Text = "Arty Trajectory Visual" })
    ArtillerySection:AddLabel("Artillery Color"):AddColorPicker("artyVisualColor", {
        Default = Color3.fromRGB(60, 255, 0),
        Title = "Artillery Color",
        Transparency = 0,
    })
    ArtillerySection:AddSlider(
        "artyVisualSize",
        { Text = "Set Arty Size", Default = 0.1, Min = 0.05, Max = 5, Rounding = 2 }
    )
    ArtillerySection:AddSlider(
        "artyVisualTransparency",
        { Text = "Set Arty Transparency", Default = 0, Min = 0, Max = 1, Rounding = 2 }
    )
    local otherArtyToggle = ArtillerySection:AddCheckbox("OtherArtyVisual", {
        Text = "Other Players' Arty",
        Tooltip = "Shows the trajectory of artillery other players are using, for a few seconds after they get off",
    })
    otherArtyToggle:AddColorPicker("EnemyArtyColor", { Title = "Enemy Arty Color", Default = Color3.fromRGB(255, 0, 0) })
    otherArtyToggle:AddColorPicker("FriendlyArtyColor", { Title = "Friendly Arty Color", Default = Color3.fromRGB(0, 170, 255) })

    local PlayerVisualSection = VisualTab:AddRightGroupbox("Players")
    PlayerVisualSection:AddCheckbox("playersVisual", { Text = "Players Visual" })
    PlayerVisualSection:AddDropdown("playersVisualLists", {
        Text = "Select to ESP",
        Default = { "Highlight", "Name", "Health", "Distance", "Box" },
        Values = {
            "Iridium",
            "Highlight",
            "Box",
            "Health",
            "Name",
            "Distance",
            "Tool",
            "Orbitals",
        },
        Multi = true,
    })
    local orbitalColorsLabel = PlayerVisualSection:AddLabel("LS / OS Count Colors")
    orbitalColorsLabel:AddColorPicker("EspLsColor", { Title = "LS Count Color", Default = Color3.fromRGB(255, 170, 0) })
    orbitalColorsLabel:AddColorPicker("EspOsColor", { Title = "OS Count Color", Default = Color3.fromRGB(0, 170, 255) })
    PlayerVisualSection:AddLabel("Label Color")
        :AddColorPicker("LabelColor", { Title = "Label Color", Default = Color3.fromRGB(255, 255, 255) })
    PlayerVisualSection:AddLabel("Box Color")
        :AddColorPicker("BoxColor", { Title = "Box Color", Default = Color3.fromRGB(119, 255, 28) })
    PlayerVisualSection:AddCheckbox("playersVisualUseTeamColor", { Text = "Use Team Color" })
    PlayerVisualSection:AddCheckbox("playersVisualTeamcheck", { Text = "Teamcheck" })

    local UtilityVisualSection = VisualTab:AddLeftGroupbox("Utilities")
    UtilityVisualSection:AddCheckbox("DamageIndicator", { Text = "Damage Indicator" })
        :AddColorPicker(
            "DamageIndicatorColor",
            { Title = "Damage Indicator Color", Default = Color3.fromRGB(255, 0, 0) }
        )
    UtilityVisualSection:AddDivider()
    UtilityVisualSection:AddCheckbox("HeightLimitESP", { Text = "HeightLimit Esp" })
        :AddColorPicker(
            "HeighLimitColor",
            { Title = "Height ESP Color", Default = Color3.fromRGB(255, 0, 0) }
        )
    UtilityVisualSection:AddSlider("HeightlimitSize", { Text = "Height Limit ESP Size", Default = 2, Min = 1, Max = 30 })
    UtilityVisualSection:AddDivider()

    UtilityVisualSection:AddCheckbox("BeaconSpotESP", { Text = "Beacon Spot ESP" })
        :AddColorPicker(
            "BeaconSpotColor",
            { Title = "Beacon ESP Color", Default = Color3.fromRGB(255, 102, 0) }
        )
    UtilityVisualSection:AddDivider()
    local beamColorToggle = UtilityVisualSection:AddCheckbox("ChangeBeamColors", {Text = "Change Distributor Beam Color"})
    beamColorToggle:AddColorPicker(
        "FirstBeamColor",
        { Title = "BeamColorOne", Default = Color3.fromRGB(0, 255, 255) }
    )
    beamColorToggle:AddColorPicker(
        "SecondBeamColor",
        { Title = "BeamColortwo", Default = Color3.fromRGB(0, 255, 255) }
    )

    local BoreVisualsSection = VisualTab:AddRightGroupbox("Bore Visuals")
    BoreVisualsSection:AddCheckbox("NeonBores",{Text = "Neon Bores"})
    local boreBeamToggle = BoreVisualsSection:AddCheckbox("BoreBeamColorChange", {
        Text = "Change Bore Beam Color",
        Tooltip = "Recolors the beam on bores you placed; it still charges from the first color to the second",
    })
    boreBeamToggle:AddColorPicker("BoreBeamColor", {Title = "Bore Beam Color (Uncharged)", Default = Color3.fromRGB(0, 255, 255)})
    boreBeamToggle:AddColorPicker("BoreBeamColorCharged", {Title = "Bore Beam Color (Charged)", Default = Color3.fromRGB(0, 0, 255)})
    local previewBeamToggle = BoreVisualsSection:AddCheckbox("PreviewBeamColorChange",{Text = "Preview Beam Color Change"})
    previewBeamToggle:AddColorPicker(
        "PreviewBeamColorOne",
        { Title = "Previewbeamcolorone", Default = Color3.fromRGB(0, 255, 255)}
    )
    previewBeamToggle:AddColorPicker(
        "PreviewBeamColorTwo",
        { Title = "Previewbeamcolortwo", Default = Color3.fromRGB(0, 255, 255)}
    )
    local boreFlareToggle = BoreVisualsSection:AddCheckbox("BoreFlareColors", {
        Text = "Bore Flare Colors",
        Tooltip = "Recolors the flare particles and light on bores you placed; the light uses the first color",
    })
    boreFlareToggle:AddColorPicker(
        "BoreFlareColorOne",
        { Title = "Bore Flare Color (Start)", Default = Color3.fromRGB(0, 0, 255)}
    )
    boreFlareToggle:AddColorPicker(
        "BoreFlareColorTwo",
        { Title = "Bore Flare Color (End)", Default = Color3.fromRGB(0, 255, 255)}
    )

    local OrbitalVisualsSection = VisualTab:AddRightGroupbox("Orbitals")
    OrbitalVisualsSection:AddCheckbox("OsVisualizer", { Text = "OS Visualizer", Tooltip = "Shows where your orbital shield will land, red when out of range" })
        :AddColorPicker("OsVisualizerColor", { Title = "OS Visualizer Color", Default = Color3.fromRGB(0, 170, 255) })
    OrbitalVisualsSection:AddSlider(
        "OsVisualizerTransparency",
        { Text = "OS Transparency", Default = 0.7, Min = 0, Max = 1, Rounding = 2 }
    )
    OrbitalVisualsSection:AddDivider()
    OrbitalVisualsSection:AddCheckbox("LsVisualizer", { Text = "LS Visualizer", Tooltip = "Shows where your laser strike will land, red when out of range" })
        :AddColorPicker("LsVisualizerColor", { Title = "LS Visualizer Color", Default = Color3.fromRGB(255, 170, 0) })
    OrbitalVisualsSection:AddSlider(
        "LsVisualizerTransparency",
        { Text = "LS Transparency", Default = 0.3, Min = 0, Max = 1, Rounding = 2 }
    )
    OrbitalVisualsSection:AddDivider()
    OrbitalVisualsSection:AddCheckbox("LsThreatRings", { Text = "Enemy LS Range", Tooltip = "Rings the area every enemy holding a laser strike can hit" })
        :AddColorPicker("LsThreatRingsColor", { Title = "Enemy LS Range Color", Default = Color3.fromRGB(255, 60, 60) })
    OrbitalVisualsSection:AddSlider(
        "LsThreatRingsTransparency",
        { Text = "Enemy LS Range Transparency", Default = 0.5, Min = 0, Max = 1, Rounding = 2 }
    )

    -- match stats: the board fills the Match tab, the score weights live in Settings
    local tracker = Tracker.new()
    tracker:start()

    local weights = scoreWeights.new()
    local board
    MatchTab:AddPage(function(page)
        board = StatsBoard.new(tracker, weights, page, window, function()
            return window.visible and window.currentTab == MatchTab
        end)
    end)

    local SettingsTab = window:AddSettingsTab()

    local MatchSettings = SettingsTab:AddLeftGroupbox("Match Stats")
    MatchSettings:AddLabel("Open match stats"):AddKeyPicker("MatchStatsKeybind", {
        Text = "Open match stats",
        Default = "F6",
        Mode = "Press",
        Callback = function()
            if window.visible and window.currentTab == MatchTab then
                window:SetVisible(false)
            else
                window:SelectTab(MatchTab)
                window:SetVisible(true)
            end
        end,
    })

    local WeightSettings = SettingsTab:AddRightGroupbox("Score Weights")
    WeightSettings:AddLabel([[<font color="#707e96">points per stat in a player's score</font>]])
    local weightSliders = {
        { key = "iridium", text = "Iridium spent", max = 0.2, rounding = 3 },
        { key = "structures", text = "Structure placed", max = 5, rounding = 1 },
        { key = "kills", text = "Kill", max = 50, rounding = 0 },
        { key = "deaths", text = "Death", min = -20, max = 0, rounding = 0 },
        { key = "ls", text = "Laser strike", max = 30, rounding = 0 },
        { key = "os", text = "Orbital shield", max = 30, rounding = 0 },
        { key = "arty", text = "Arty shot", max = 10, rounding = 1 },
        { key = "bores", text = "Bore aim", max = 20, rounding = 0 },
    }
    for _, weight in weightSliders do
        WeightSettings:AddSlider(string.format('Score/%s', tostring(weight.key)), {
            Text = weight.text,
            Default = weights[weight.key],
            Min = weight.min or 0,
            Max = weight.max,
            Rounding = weight.rounding,
            Callback = function(value)
                weights[weight.key] = value
                if board then
                    board:refresh()
                end
            end,
        })
    end

    do
        local artygrav = dote.v().new()
        local container = dote.o()
        local beamcolor = dote.w().new()
        local main = dote.x().new()
        local spawnpoint = dote.y().new()
        local bore = dote.z().new()
        local pipeextender = dote.A().new()
        local silentaim = dote.B().new()
        local damageindicator = dote.C().new()
        local visuals = dote.E().new()
        local artillery = dote.F().new()
        local autodcap = dote.G().new()
        local autoshield = dote.H()
        local heightlimit = dote.I().new()
        local beaconspotesp = dote.J().new()
        local boreaimbot = dote.K().new()
        local borecustomize = dote.L().new()
        local autoborepipe = dote.M().new()
        local nofall = dote.N()
        local lssilentaim = dote.P().new()
        local orbitalvisuals = dote.Q().new()
        local stoporbitalerror = dote.R().new()
        local otherarty = dote.S().new()
        local lsthreat = dote.T().new()
        local placeanyway = dote.V().new()
        local buildtools = dote.W().new()
        local fastplacement = dote.X().new()
        local gunmods = dote.Y().new()
        local rocketaim = dote.Z().new()

        for name, value in
            {
                artygrav = artygrav,
                autoborepipe = autoborepipe,
                borecustomize = borecustomize,
                boreaimbot = boreaimbot,
                beamcolor = beamcolor,
                beaconspotesp = beaconspotesp,
                main = main,
                bore = bore,
                artillery = artillery,
                spawnpoint = spawnpoint,
                autodcap = autodcap,
                instantRespawnCall = instantRespawnCall,
                instantTPCall = instantTPCall,
                quickBuildCall = quickBuildCall,
                heightlimit = heightlimit,
                selectedSpawn = "",
                lockedOn = nil,
                tracker = tracker,
            }
        do
            container[name] = value
        end
        artygrav:start()
        autoborepipe:start()
        borecustomize:start()
        boreaimbot:start()
        beamcolor:start()
        beaconspotesp:start()
        heightlimit:start()
        main:start()
        bore:start()
        pipeextender:start()
        spawnpoint:start()
        silentaim:start()
        damageindicator:start()
        lssilentaim:start()
        orbitalvisuals:start()
        stoporbitalerror:start()
        otherarty:start()
        lsthreat:start()
        placeanyway:start()
        buildtools:start()
        fastplacement:start()
        gunmods:start()
        rocketaim:start()

        -- SetText rebuilds the rich text label, so only call it when the spawn changes
        local shownSpawn = {}

        RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
            artillery:update()
            spawnpoint:update()
            visuals:update()
            silentaim:update()
            heightlimit:update()
            -- ls target first, the visualizer draws at it
            lssilentaim:update()
            orbitalvisuals:update()
            stoporbitalerror:update()
            otherarty:update()
            lsthreat:update()
            rocketaim:update()

            if container.selectedSpawn ~= shownSpawn then
                shownSpawn = container.selectedSpawn
                selectedSpawnLabel:SetText(
(shownSpawn
and{(string.format("Selecting <font color='#22e4ff'><b>S%s</b></font>", tostring(shownSpawn)))}or{"<font color='#ff5e6e'><b>NO SPAWN</b></font>"})[1]                

)
            end
        end))
        workspace:WaitForChild("Structures").ChildAdded:Connect(function(child)
            -- both yield, so run them side by side instead of making autoshield wait on autodcap
            task.spawn(autodcap.start, autodcap, child)
            task.spawn(autoshield, child)
        end)

        Toggles.FallDamage:OnChanged(function()
            nofall.SetFallDamage(not Toggles.FallDamage.Value)
        end)

        -- the fall damage script comes back with every character, so turn it off again
        game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
            if not Toggles.FallDamage.Value then
                return
            end

            character:WaitForChild("FallDamageScript", 10)
            for _ = 1, 10 do
                task.wait(0.5)
                if not Toggles.FallDamage.Value or nofall.SetFallDamage(false) then
                    return
                end
            end
        end)
    end
end

-- the config set as default (Settings > Configs) goes on last, so every feature reacts to it like a
-- normal change. with none set, everything starts on defaults
local loadedConfig = window:LoadAutoload()
window:SelectTab(LocalTab)
window:SetVisible(true)
window:Notify(
    ((loadedConfig and{(string.format('Loaded config "%s". ', tostring(loadedConfig)))}or{"Loaded on default settings. "})[1])
        .. string.format('%s hides the window, %s opens match stats', tostring(Options.MenuKeybind.Value), tostring(Options.MatchStatsKeybind.Value))
)
