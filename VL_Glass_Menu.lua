--[[ Volleyball Legends | Glass Menu (client-only)
     Тап по кнопке с фото - открыть/закрыть меню.
     Зажми и тяни - переместить кнопку (прилипает к краю).
     На ПК меню открывается ещё и по RightShift. ]]

local CONFIG = {
    ICON_ASSET = nil, -- необязательно: свой "rbxassetid://123456", фото уже встроено
}
local ICON_B64 = "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"

if not game:IsLoaded() then game.Loaded:Wait() end
local ENV = (getgenv and getgenv()) or _G
if ENV.VL_Cleanup then pcall(ENV.VL_Cleanup) end

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local lp = Players.LocalPlayer

local conns = {}
local function connect(sig, fn)
    local c = sig:Connect(fn)
    conns[#conns + 1] = c
    return c
end

-- ===================== СОСТОЯНИЕ =====================
local S = { quality = false, shadows = false, textures = false, materials = false,
    effects = false, accessories = false, hideplayers = false, afk = false, blur = true }
local OPT = { "quality", "shadows", "textures", "materials", "effects", "accessories" }
local NAMES = { quality = "Низкая графика", shadows = "Тени", textures = "Текстуры",
    materials = "Материалы", effects = "Эффекты", accessories = "Аксессуары",
    hideplayers = "Скрыть игроков", afk = "Анти-АФК", blur = "Размытие фона" }

local FX = { ParticleEmitter = true, Trail = true, Smoke = true, Fire = true, Sparkles = true, Beam = true }
local PROTECT = { ball = true, volleyball = true } -- эти имена не трогаем
local SA_PROPS = { "ColorMap", "MetalnessMap", "NormalMap", "RoughnessMap" }

-- запоминаем оригиналы, чтобы всё можно было вернуть обратно
local saved = setmetatable({}, { __mode = "k" })
local function set(inst, prop, val)
    pcall(function()
        local s = saved[inst]
        if not s then s = {}; saved[inst] = s end
        if s[prop] == nil then s[prop] = inst[prop] end
        inst[prop] = val
    end)
end
local function restore(inst, prop)
    local s = saved[inst]
    if s and s[prop] ~= nil then
        local v = s[prop]
        s[prop] = nil
        pcall(function() inst[prop] = v end)
    end
end

-- ===================== ОПТИМИЗАЦИЯ =====================
local function isProtected(v)
    local p = v
    while p and p ~= Workspace do
        if PROTECT[p.Name:lower()] then return true end
        p = p.Parent
    end
    return false
end

local function charOf(v)
    local m = v:FindFirstAncestorOfClass("Model")
    while m do
        local owner = Players:GetPlayerFromCharacter(m) or Players:FindFirstChild(m.Name)
        if m:FindFirstChildOfClass("Humanoid") or owner then
            return m, owner
        end
        local p = m.Parent
        m = p and p:FindFirstAncestorOfClass("Model")
    end
end

local function apply(v)
    if v:IsA("Terrain") or isProtected(v) then return end
    local cls = v.ClassName
    if FX[cls] or cls == "Clouds" then
        if S.effects then set(v, "Enabled", false) else restore(v, "Enabled") end
        return
    end
    local isPart = v:IsA("BasePart")
    local isDecal = v:IsA("Decal") or v:IsA("Texture")
    local isSA = cls == "SurfaceAppearance"
    if not (isPart or isDecal or isSA) then return end

    local char, owner = charOf(v)
    if char then -- персонажей не ломаем: только тени и видимость чужих
        if isPart then
            if S.shadows then set(v, "CastShadow", false) else restore(v, "CastShadow") end
        end
        if owner and owner ~= lp and (isPart or isDecal) then
            local hide = S.hideplayers or (S.accessories and v:FindFirstAncestorOfClass("Accessory") ~= nil)
            if hide then set(v, "Transparency", 1) else restore(v, "Transparency") end
        end
        return
    end

    if isPart then
        if S.shadows then set(v, "CastShadow", false) else restore(v, "CastShadow") end
        if S.materials then
            set(v, "Material", Enum.Material.SmoothPlastic)
            set(v, "Reflectance", 0)
        else
            restore(v, "Material")
            restore(v, "Reflectance")
        end
        if v:IsA("MeshPart") then
            if S.materials then set(v, "RenderFidelity", Enum.RenderFidelity.Performance) else restore(v, "RenderFidelity") end
            if S.textures then set(v, "TextureID", "") else restore(v, "TextureID") end
        end
    elseif isDecal then
        if S.textures then set(v, "Transparency", 1) else restore(v, "Transparency") end
    else
        for _, p in ipairs(SA_PROPS) do
            if S.textures then set(v, p, "") else restore(v, p) end
        end
    end
end

local function lightingFx(v)
    if v.Name == "VLGlassBlur" then return end
    if v:IsA("PostEffect") then
        if S.effects then set(v, "Enabled", false) else restore(v, "Enabled") end
    elseif v:IsA("Atmosphere") then
        if S.effects then set(v, "Density", 0) else restore(v, "Density") end
    end
end

local function globalApply()
    pcall(function()
        local r = settings().Rendering
        if S.quality then set(r, "QualityLevel", Enum.QualityLevel.Level01) else restore(r, "QualityLevel") end
    end)
    pcall(function()
        if S.shadows then set(Lighting, "GlobalShadows", false) else restore(Lighting, "GlobalShadows") end
        if S.effects then set(Lighting, "FogEnd", 9e9) else restore(Lighting, "FogEnd") end
    end)
    local t = Workspace:FindFirstChildOfClass("Terrain")
    if t then
        for _, p in ipairs({ "WaterWaveSize", "WaterWaveSpeed", "WaterReflectance" }) do
            if S.effects then set(t, p, 0) else restore(t, p) end
        end
    end
    for _, v in ipairs(Lighting:GetDescendants()) do pcall(lightingFx, v) end
end

local sweeping, again = false, false
local function sweep() -- проход по карте пачками, чтобы не фризило
    if sweeping then again = true return end
    sweeping = true
    repeat
        again = false
        local n = 0
        for _, v in ipairs(Workspace:GetDescendants()) do
            pcall(apply, v)
            n += 1
            if n % 250 == 0 then task.wait() end
            if again then break end
        end
    until not again
    sweeping = false
end

local function active()
    return S.shadows or S.textures or S.materials or S.effects or S.accessories or S.hideplayers
end

connect(Workspace.DescendantAdded, function(v)
    if active() then task.defer(pcall, apply, v) end
end)
connect(Lighting.DescendantAdded, function(v) task.defer(pcall, lightingFx, v) end)

connect(lp.Idled, function()
    if S.afk then
        pcall(function()
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end
end)

-- ===================== ИКОНКА (фото) =====================
local function b64decode(s)
    local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local map = {}
    for i = 1, #alphabet do map[alphabet:byte(i)] = i - 1 end
    local clean = (s:gsub("[^%w%+/]", ""))
    local out = {}
    for i = 1, #clean, 4 do
        local a, b, c, d = clean:byte(i, i + 3)
        local n = map[a] * 262144 + map[b] * 4096 + (c and map[c] or 0) * 64 + (d and map[d] or 0)
        out[#out + 1] = string.char(math.floor(n / 65536) % 256)
        if c then out[#out + 1] = string.char(math.floor(n / 256) % 256) end
        if d then out[#out + 1] = string.char(n % 256) end
    end
    return table.concat(out)
end

local iconAsset = CONFIG.ICON_ASSET
if not iconAsset then
    pcall(function()
        local getAsset = getcustomasset or getsynasset
        if writefile and getAsset then
            writefile("vl_glass_icon.jpg", b64decode(ICON_B64))
            iconAsset = getAsset("vl_glass_icon.jpg")
        end
    end)
end

-- ===================== ИНТЕРФЕЙС =====================
local WHITE = Color3.new(1, 1, 1)
local GRAY = Color3.fromRGB(150, 156, 185)
local ACCENT = Color3.fromRGB(10, 132, 255)
local GREEN = Color3.fromRGB(52, 199, 89)
local OFFC = Color3.fromRGB(88, 92, 112)
local RED = Color3.fromRGB(255, 69, 58)
local EASE = Enum.EasingStyle

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end
local function tw(o, t, props, style, dir)
    local tween = TweenService:Create(o, TweenInfo.new(t, style or EASE.Quint, dir or Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end
local function corner(o, r) return new("UICorner", { CornerRadius = r }, o) end

local gui = new("ScreenGui", { Name = "VLGlassMenu", ResetOnSpawn = false, IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999 })
local okParent = pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not okParent or not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end

local blur = new("BlurEffect", { Name = "VLGlassBlur", Size = 0 }, Lighting)

local open = false
local master
local setState, refreshMaster, toggleMenu, snap, placePanel

-- уведомление сверху (как баннер на iPhone)
local toast = new("CanvasGroup", { AnchorPoint = Vector2.new(.5, 0), Position = UDim2.new(.5, 0, 0, -60),
    Size = UDim2.fromOffset(260, 44), BackgroundColor3 = Color3.fromRGB(28, 30, 44),
    BackgroundTransparency = .08, GroupTransparency = 1 }, gui)
corner(toast, UDim.new(1, 0))
new("UIStroke", { Color = WHITE, Transparency = .82, Thickness = 1 }, toast)
local toastTxt = new("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "",
    Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = WHITE }, toast)
local toastId = 0
local function notify(text)
    toastId += 1
    local id = toastId
    toastTxt.Text = text
    tw(toast, .4, { Position = UDim2.new(.5, 0, 0, 16), GroupTransparency = 0 }, EASE.Back)
    task.delay(1.8, function()
        if id == toastId then
            tw(toast, .3, { Position = UDim2.new(.5, 0, 0, -60), GroupTransparency = 1 })
        end
    end)
end

-- кнопка с фото
local btn = new("ImageButton", { Name = "Toggle", Size = UDim2.fromOffset(58, 58), Position = UDim2.fromOffset(14, 110),
    BackgroundColor3 = Color3.fromRGB(40, 44, 64), AutoButtonColor = false,
    Image = iconAsset or "", ScaleType = Enum.ScaleType.Crop }, gui)
corner(btn, UDim.new(1, 0))
local btnStroke = new("UIStroke", { Color = WHITE, Thickness = 2.5, Transparency = .2 }, btn)
local btnScale = new("UIScale", {}, btn)
if not iconAsset then
    new("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "VL",
        Font = Enum.Font.GothamBlack, TextSize = 20, TextColor3 = WHITE }, btn)
end

-- стеклянная панель
local panel = new("CanvasGroup", { Name = "Panel", AnchorPoint = Vector2.new(.5, .5), BackgroundTransparency = 1,
    GroupTransparency = 1, Visible = false, Active = true }, gui)
corner(panel, UDim.new(0, 26))
local panelScale = new("UIScale", { Scale = .85 }, panel)
local bg = new("Frame", { Position = UDim2.fromOffset(2, 2), Size = UDim2.new(1, -4, 1, -4),
    BackgroundColor3 = WHITE, BackgroundTransparency = .2 }, panel)
corner(bg, UDim.new(0, 24))
new("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(78, 84, 118), Color3.fromRGB(22, 24, 38)) }, bg)
local edge = new("UIStroke", { Color = WHITE, Thickness = 1.2, Transparency = 0 }, bg)
new("UIGradient", { Rotation = 45, Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, .3), NumberSequenceKeypoint.new(.5, .88), NumberSequenceKeypoint.new(1, .55) }) }, edge)

local header = new("Frame", { Size = UDim2.new(1, 0, 0, 62), BackgroundTransparency = 1 }, panel)
new("TextLabel", { Position = UDim2.fromOffset(20, 10), Size = UDim2.new(1, -40, 0, 24), BackgroundTransparency = 1,
    Text = "Volleyball Legends", Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = WHITE,
    TextXAlignment = Enum.TextXAlignment.Left }, header)
local stats = new("TextLabel", { Position = UDim2.fromOffset(20, 34), Size = UDim2.new(1, -40, 0, 16),
    BackgroundTransparency = 1, Text = "FPS --  •  Пинг -- мс", Font = Enum.Font.GothamMedium, TextSize = 12,
    TextColor3 = GRAY, TextXAlignment = Enum.TextXAlignment.Left }, header)
new("Frame", { Position = UDim2.fromOffset(16, 61), Size = UDim2.new(1, -32, 0, 1),
    BackgroundColor3 = WHITE, BackgroundTransparency = .9, BorderSizePixel = 0 }, panel)

local scroll = new("ScrollingFrame", { Position = UDim2.fromOffset(0, 64), Size = UDim2.new(1, 0, 1, -128),
    BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y }, panel)
new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, scroll)
new("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 8) }, scroll)

local order = 0
local switches = {}

local function section(text)
    order += 1
    new("TextLabel", { LayoutOrder = order, Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Text = "  " .. text,
        Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = GRAY, TextXAlignment = Enum.TextXAlignment.Left }, scroll)
end

local function flash(o)
    o.BackgroundTransparency = .86
    tw(o, .45, { BackgroundTransparency = 1 })
end

local function addSwitch(key, title, sub)
    order += 1
    local r = new("TextButton", { LayoutOrder = order, Size = UDim2.new(1, 0, 0, 54), BackgroundColor3 = WHITE,
        BackgroundTransparency = 1, Text = "", AutoButtonColor = false }, scroll)
    corner(r, UDim.new(0, 14))
    new("TextLabel", { Position = UDim2.fromOffset(10, 9), Size = UDim2.new(1, -86, 0, 18), BackgroundTransparency = 1,
        Text = title, Font = Enum.Font.GothamMedium, TextSize = 15, TextColor3 = WHITE,
        TextXAlignment = Enum.TextXAlignment.Left }, r)
    new("TextLabel", { Position = UDim2.fromOffset(10, 28), Size = UDim2.new(1, -86, 0, 16), BackgroundTransparency = 1,
        Text = sub, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = GRAY,
        TextXAlignment = Enum.TextXAlignment.Left }, r)
    local track = new("Frame", { AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -10, .5, 0),
        Size = UDim2.fromOffset(50, 30), BackgroundColor3 = OFFC }, r)
    corner(track, UDim.new(1, 0))
    local knob = new("Frame", { Position = UDim2.fromOffset(3, 3), Size = UDim2.fromOffset(24, 24), BackgroundColor3 = WHITE }, track)
    corner(knob, UDim.new(1, 0))
    switches[key] = function(on, animate)
        local t = animate and .3 or 0
        tw(track, t, { BackgroundColor3 = on and GREEN or OFFC })
        tw(knob, t, { Position = on and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3) }, EASE.Back)
    end
    switches[key](S[key], false)
    r.Activated:Connect(function()
        flash(r)
        setState(key, not S[key])
    end)
end

section("Оптимизация")
addSwitch("quality", "Низкая графика", "Минимальный уровень рендера")
addSwitch("shadows", "Тени", "Отключить тени")
addSwitch("textures", "Текстуры", "Убрать текстуры и декали на карте")
addSwitch("materials", "Материалы и модели", "Простые материалы, меньше деталей")
addSwitch("effects", "Эффекты", "Частицы, туман, блум, вода")
addSwitch("accessories", "Аксессуары игроков", "Скрыть чужие аксессуары")
section("Дополнительно")
addSwitch("hideplayers", "Скрыть игроков", "Только на твоём экране")
addSwitch("afk", "Анти-АФК", "Не кикает за бездействие")
addSwitch("blur", "Размытие фона", "Матовое стекло при открытом меню")
section("Лимит FPS")

-- сегментированный переключатель лимита FPS
order += 1
local segRow = new("Frame", { LayoutOrder = order, Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1 }, scroll)
local segBg = new("Frame", { AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
    Size = UDim2.new(1, -12, 0, 36), BackgroundColor3 = WHITE, BackgroundTransparency = .88 }, segRow)
corner(segBg, UDim.new(1, 0))
local caps = { 30, 60, 120, 0 }
local pill = new("Frame", { Size = UDim2.new(.25, -4, 1, -6), Position = UDim2.new(.25, 2, 0, 3),
    BackgroundColor3 = ACCENT }, segBg)
corner(pill, UDim.new(1, 0))
local function selectCap(i)
    tw(pill, .35, { Position = UDim2.new((i - 1) * .25, 2, 0, 3) }, EASE.Back)
    local c = caps[i]
    local ok = pcall(function()
        if not setfpscap then error("no setfpscap") end
        setfpscap(c == 0 and 999 or c)
    end)
    notify(ok and ("Лимит FPS: " .. (c == 0 and "без лимита" or c)) or "Лимит FPS не поддерживается")
end
for i, c in ipairs(caps) do
    local b = new("TextButton", { Size = UDim2.new(.25, 0, 1, 0), Position = UDim2.new((i - 1) * .25, 0, 0, 0),
        BackgroundTransparency = 1, Text = c == 0 and "∞" or tostring(c), Font = Enum.Font.GothamBold,
        TextSize = 14, TextColor3 = WHITE, ZIndex = 2 }, segBg)
    b.Activated:Connect(function() selectCap(i) end)
end

order += 1
local unload = new("TextButton", { LayoutOrder = order, Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1,
    Text = "Выгрузить скрипт", Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = RED, AutoButtonColor = false }, scroll)
unload.Activated:Connect(function() if ENV.VL_Cleanup then ENV.VL_Cleanup() end end)

-- главная кнопка
master = new("TextButton", { AnchorPoint = Vector2.new(.5, 1), Position = UDim2.new(.5, 0, 1, -14),
    Size = UDim2.new(1, -32, 0, 46), BackgroundColor3 = WHITE, Text = "Включить всё", Font = Enum.Font.GothamBold,
    TextSize = 15, TextColor3 = WHITE, AutoButtonColor = false }, panel)
corner(master, UDim.new(1, 0))
new("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(10, 132, 255), Color3.fromRGB(94, 92, 230)) }, master)
local masterScale = new("UIScale", {}, master)
master.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        tw(masterScale, .1, { Scale = .95 })
    end
end)
master.InputEnded:Connect(function() tw(masterScale, .35, { Scale = 1 }, EASE.Back) end)

local function allOn()
    for _, k in ipairs(OPT) do if not S[k] then return false end end
    return true
end
refreshMaster = function()
    if master then master.Text = allOn() and "Выключить всё" or "Включить всё" end
end

master.Activated:Connect(function()
    local target = not allOn()
    task.spawn(function()
        for _, k in ipairs(OPT) do
            if S[k] ~= target then setState(k, target, true) end
            task.wait(.08)
        end
        notify(target and "Максимальный буст включён" or "Всё выключено")
    end)
end)

-- ===================== ЛОГИКА МЕНЮ =====================
setState = function(key, val, quiet)
    S[key] = val
    if switches[key] then switches[key](val, true) end
    if key == "blur" and open then tw(blur, .3, { Size = val and 18 or 0 }) end
    if not quiet then notify(NAMES[key] .. (val and ": вкл" or ": выкл")) end
    if val then
        btnStroke.Color = GREEN
        tw(btnStroke, .7, { Color = open and ACCENT or WHITE })
    end
    refreshMaster()
    if key ~= "afk" and key ~= "blur" then
        task.spawn(function()
            globalApply()
            sweep()
        end)
    end
end

placePanel = function()
    local vs = gui.AbsoluteSize
    local w, h = math.min(300, vs.X - 20), math.min(410, vs.Y - 24)
    local bp, bs = btn.AbsolutePosition, btn.AbsoluteSize
    local x
    if bp.X + bs.X / 2 < vs.X / 2 then x = bp.X + bs.X + 10 else x = bp.X - w - 10 end
    x = math.clamp(x, 10, vs.X - w - 10)
    local y = math.clamp(bp.Y + bs.Y / 2 - h / 2, 12, vs.Y - h - 12)
    panel.Size = UDim2.fromOffset(w, h)
    panel.Position = UDim2.fromOffset(x + w / 2, y + h / 2)
end

toggleMenu = function()
    open = not open
    tw(btnStroke, .3, { Color = open and ACCENT or WHITE })
    if open then
        placePanel()
        panel.Visible = true
        panel.GroupTransparency = 1
        panelScale.Scale = .82
        tw(panel, .3, { GroupTransparency = 0 })
        tw(panelScale, .45, { Scale = 1 }, EASE.Back)
        if S.blur then tw(blur, .4, { Size = 18 }) end
    else
        tw(panel, .22, { GroupTransparency = 1 })
        tw(panelScale, .22, { Scale = .88 }, EASE.Quad, Enum.EasingDirection.In)
        tw(blur, .25, { Size = 0 })
        task.delay(.24, function() if not open then panel.Visible = false end end)
    end
end

snap = function()
    local vs = gui.AbsoluteSize
    local cx = btn.AbsolutePosition.X + btn.AbsoluteSize.X / 2
    local tx = cx < vs.X / 2 and 10 or vs.X - 68
    tw(btn, .4, { Position = UDim2.fromOffset(tx, btn.Position.Y.Offset) }, EASE.Back)
end

btn:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
    if open then placePanel() end
end)

-- перетаскивание кнопки (тап = открыть/закрыть)
local dragging, moved, dragStart, startPos, dragInput = false, false, nil, nil, nil
btn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging, moved = true, false
        dragStart, startPos, dragInput = i.Position, btn.Position, i
        tw(btnScale, .12, { Scale = .9 })
        local c
        c = i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then
                c:Disconnect()
                dragging = false
                tw(btnScale, .35, { Scale = 1 }, EASE.Back)
                if moved then snap() else toggleMenu() end
            end
        end)
    end
end)
connect(UIS.InputChanged, function(i)
    if not dragging then return end
    if i.UserInputType == Enum.UserInputType.MouseMovement
        or (i.UserInputType == Enum.UserInputType.Touch and i == dragInput) then
        local d = i.Position - dragStart
        if not moved and d.Magnitude > 8 then moved = true end
        if moved then
            local vs = gui.AbsoluteSize
            btn.Position = UDim2.fromOffset(
                math.clamp(startPos.X.Offset + d.X, 6, vs.X - 64),
                math.clamp(startPos.Y.Offset + d.Y, 6, vs.Y - 64))
        end
    end
end)
connect(UIS.InputBegan, function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.RightShift then toggleMenu() end
end)

-- FPS и пинг в шапке
local frames, t0 = 0, os.clock()
connect(RunService.RenderStepped, function()
    frames += 1
    local now = os.clock()
    if now - t0 >= .5 then
        if open then
            local ping = 0
            pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            stats.Text = ("FPS %d  •  Пинг %d мс"):format(math.floor(frames / (now - t0) + .5), ping)
        end
        frames, t0 = 0, now
    end
end)

-- выгрузка: возвращает всё как было
ENV.VL_Cleanup = function()
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    for _, k in ipairs(OPT) do S[k] = false end
    S.hideplayers = false
    pcall(globalApply)
    for _, v in ipairs(Workspace:GetDescendants()) do pcall(apply, v) end
    pcall(function() blur:Destroy() end)
    pcall(function() gui:Destroy() end)
    ENV.VL_Cleanup = nil
end

task.delay(.3, function() notify("Меню загружено") end)
