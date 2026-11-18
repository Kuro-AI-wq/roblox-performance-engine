--[[ Volleyball Legends | Glass Menu v2.4
     - Fixed launch (no continue, safer init)
     - Music removed
     - Only enemy outlines
     - Look beams + ball marker improved
     - Advantage features added
]]

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
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer

local conns = {}
local function connect(sig, fn)
    local c = sig:Connect(fn)
    table.insert(conns, c)
    return c
end

local S = {
    quality = false, shadows = false, textures = false, materials = false,
    effects = false, accessories = false, hideplayers = false, afk = false, blur = true,
    lookbeams = true, dynamicisland = true, hidescore = true,
    ballesp = true, teamoutlines = true, ballmarker = true,
    balldist = true, servealert = true
}

local OPT = {"quality","shadows","textures","materials","effects","accessories"}
local NAMES = {
    quality = "Низкая графика", shadows = "Тени", textures = "Текстуры",
    materials = "Материалы", effects = "Эффекты", accessories = "Аксессуары",
    hideplayers = "Скрыть игроков", afk = "Анти-АФК", blur = "Размытие фона",
    lookbeams = "Лучи взгляда", dynamicisland = "Dynamic Island", hidescore = "Скрыть табло",
    ballesp = "Ball ESP", teamoutlines = "Контуры врагов", ballmarker = "Маркер падения",
    balldist = "Дистанция до мяча", servealert = "Алерт подачи"
}

local FX = {ParticleEmitter=true, Trail=true, Smoke=true, Fire=true, Sparkles=true, Beam=true}
local PROTECT = {ball=true, volleyball=true}
local SA_PROPS = {"ColorMap","MetalnessMap","NormalMap","RoughnessMap"}

local saved = setmetatable({}, {__mode="k"})
local function set(inst, prop, val)
    pcall(function()
        local s = saved[inst]
        if not s then s = {} saved[inst] = s end
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

local SAVE_FILE = "VL_Glass_Settings.json"
local function saveSettings()
    pcall(function()
        if writefile then writefile(SAVE_FILE, HttpService:JSONEncode(S)) end
    end)
end
local function loadSettings()
    pcall(function()
        if readfile and isfile and isfile(SAVE_FILE) then
            local data = HttpService:JSONDecode(readfile(SAVE_FILE))
            for k,v in pairs(data) do
                if S[k] ~= nil then S[k] = v end
            end
        end
    end)
end
pcall(loadSettings)

-- ========== OPTIMIZATION ==========
local function isProtected(v)
    local p = v
    while p and p ~= Workspace do
        if PROTECT[string.lower(p.Name)] then return true end
        p = p.Parent
    end
    return false
end

local function charOf(v)
    local m = v:FindFirstAncestorOfClass("Model")
    while m do
        local owner = Players:GetPlayerFromCharacter(m) or Players:FindFirstChild(m.Name)
        if m:FindFirstChildOfClass("Humanoid") or owner then return m, owner end
        local p = m.Parent
        m = p and p:FindFirstAncestorOfClass("Model")
    end
end

local function apply(v)
    if v:IsA("Terrain") or isProtected(v) then return end
    local cls = v.ClassName
    if FX[cls] or cls == "Clouds" then
        if S.effects then set(v,"Enabled",false) else restore(v,"Enabled") end
        return
    end
    local isPart = v:IsA("BasePart")
    local isDecal = v:IsA("Decal") or v:IsA("Texture")
    local isSA = cls == "SurfaceAppearance"
    if not (isPart or isDecal or isSA) then return end

    local char, owner = charOf(v)
    if char then
        if isPart then
            if S.shadows then set(v,"CastShadow",false) else restore(v,"CastShadow") end
        end
        if owner and owner ~= lp and (isPart or isDecal) then
            local hide = S.hideplayers or (S.accessories and v:FindFirstAncestorOfClass("Accessory") ~= nil)
            if hide then set(v,"Transparency",1) else restore(v,"Transparency") end
        end
        return
    end

    if isPart then
        if S.shadows then set(v,"CastShadow",false) else restore(v,"CastShadow") end
        if S.materials then
            set(v,"Material",Enum.Material.SmoothPlastic)
            set(v,"Reflectance",0)
        else
            restore(v,"Material")
            restore(v,"Reflectance")
        end
        if v:IsA("MeshPart") then
            if S.materials then set(v,"RenderFidelity",Enum.RenderFidelity.Performance) else restore(v,"RenderFidelity") end
            if S.textures then set(v,"TextureID","") else restore(v,"TextureID") end
        end
    elseif isDecal then
        if S.textures then set(v,"Transparency",1) else restore(v,"Transparency") end
    else
        for _,p in ipairs(SA_PROPS) do
            if S.textures then set(v,p,"") else restore(v,p) end
        end
    end
end

local function lightingFx(v)
    if v.Name == "VLGlassBlur" then return end
    if v:IsA("PostEffect") then
        if S.effects then set(v,"Enabled",false) else restore(v,"Enabled") end
    elseif v:IsA("Atmosphere") then
        if S.effects then set(v,"Density",0) else restore(v,"Density") end
    end
end

local function globalApply()
    pcall(function()
        local r = settings().Rendering
        if S.quality then set(r,"QualityLevel",Enum.QualityLevel.Level01) else restore(r,"QualityLevel") end
    end)
    pcall(function()
        if S.shadows then set(Lighting,"GlobalShadows",false) else restore(Lighting,"GlobalShadows") end
        if S.effects then set(Lighting,"FogEnd",9e9) else restore(Lighting,"FogEnd") end
    end)
    local t = Workspace:FindFirstChildOfClass("Terrain")
    if t then
        for _,p in ipairs({"WaterWaveSize","WaterWaveSpeed","WaterReflectance"}) do
            if S.effects then set(t,p,0) else restore(t,p) end
        end
    end
    for _,v in ipairs(Lighting:GetDescendants()) do pcall(lightingFx,v) end
end

local sweeping, again = false, false
local function sweep()
    if sweeping then again = true return end
    sweeping = true
    repeat
        again = false
        local n = 0
        for _,v in ipairs(Workspace:GetDescendants()) do
            pcall(apply,v)
            n = n + 1
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

-- ========== LOOK BEAMS (enemies only, serve-safe) ==========
local lookBeams = {}
local function clearLookBeam(plr)
    local d = lookBeams[plr]
    if d then
        pcall(function() d.beam:Destroy() end)
        pcall(function() d.att0:Destroy() end)
        pcall(function() d.att1:Destroy() end)
        lookBeams[plr] = nil
    end
end

local function isEnemy(plr)
    if plr == lp then return false end
    if plr.Team and lp.Team and plr.Team == lp.Team then return false end
    return true
end

local function updateLookBeams()
    if not S.lookbeams then
        for plr in pairs(lookBeams) do clearLookBeam(plr) end
        return
    end
    for _,plr in ipairs(Players:GetPlayers()) do
        if not isEnemy(plr) then
            clearLookBeam(plr)
        else
            local char = plr.Character
            if not char then
                clearLookBeam(plr)
            else
                local head = char:FindFirstChild("Head")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local origin = head or hrp
                if not origin then
                    clearLookBeam(plr)
                else
                    local data = lookBeams[plr]
                    if not data or data.parent ~= origin then
                        if data then clearLookBeam(plr) end
                        local att0 = Instance.new("Attachment")
                        att0.Name = "VL_Look0"
                        att0.Parent = origin
                        local att1 = Instance.new("Attachment")
                        att1.Name = "VL_Look1"
                        att1.Parent = origin
                        local beam = Instance.new("Beam")
                        beam.Name = "VL_LookBeam"
                        beam.Attachment0 = att0
                        beam.Attachment1 = att1
                        beam.Width0 = 0.12
                        beam.Width1 = 0.03
                        beam.FaceCamera = true
                        beam.Color = ColorSequence.new(Color3.fromRGB(255,70,130))
                        beam.Transparency = NumberSequence.new(0.05, 0.7)
                        beam.LightEmission = 0.85
                        beam.Parent = origin
                        data = {att0=att0, att1=att1, beam=beam, parent=origin}
                        lookBeams[plr] = data
                    end
                    local look = (head and head.CFrame.LookVector) or hrp.CFrame.LookVector
                    data.att0.Position = Vector3.new(0, 0.25, 0)
                    data.att1.Position = look * 4.5 + Vector3.new(0, 0.25, 0)
                end
            end
        end
    end
end
connect(Players.PlayerRemoving, function(plr) clearLookBeam(plr) end)

-- ========== TEAM OUTLINES (ONLY ENEMIES) ==========
local outlines = {}
local function clearOutline(plr)
    local o = outlines[plr]
    if o then pcall(function() o:Destroy() end) outlines[plr] = nil end
end

local function updateOutlines()
    if not S.teamoutlines then
        for plr in pairs(outlines) do clearOutline(plr) end
        return
    end
    for _,plr in ipairs(Players:GetPlayers()) do
        if not isEnemy(plr) then
            clearOutline(plr)
        else
            local char = plr.Character
            if not char then
                clearOutline(plr)
            else
                if not outlines[plr] then
                    local hl = Instance.new("Highlight")
                    hl.Name = "VL_Outline"
                    hl.FillTransparency = 0.8
                    hl.OutlineTransparency = 0.05
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.FillColor = Color3.fromRGB(255, 60, 80)
                    hl.OutlineColor = Color3.fromRGB(255, 100, 120)
                    hl.Parent = char
                    outlines[plr] = hl
                end
                if plr.Team then
                    outlines[plr].FillColor = plr.Team.TeamColor.Color
                    outlines[plr].OutlineColor = plr.Team.TeamColor.Color
                end
            end
        end
    end
end
connect(Players.PlayerRemoving, function(plr) clearOutline(plr) end)

-- ========== BALL ==========
local ballEsp, landMarker = nil, nil
local lastBallPos = nil

local function findBall()
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local n = string.lower(v.Name)
            if (string.find(n, "ball") or string.find(n, "volleyball")) and v.Size.Magnitude < 12 and v.Size.Magnitude > 0.4 then
                return v
            end
        end
    end
    return nil
end

local function updateBallESP()
    local ball = findBall()
    if not ball then
        if ballEsp then pcall(function() ballEsp:Destroy() end) ballEsp = nil end
        if landMarker then pcall(function() landMarker:Destroy() end) landMarker = nil end
        lastBallPos = nil
        return
    end

    lastBallPos = ball.Position

    if S.ballesp then
        if not ballEsp or ballEsp.Parent ~= ball then
            if ballEsp then pcall(function() ballEsp:Destroy() end) end
            local hl = Instance.new("Highlight")
            hl.Name = "VL_BallESP"
            hl.FillColor = Color3.fromRGB(255,210,60)
            hl.OutlineColor = Color3.fromRGB(255,255,120)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = ball
            ballEsp = hl
        end
    else
        if ballEsp then pcall(function() ballEsp:Destroy() end) ballEsp = nil end
    end

    if S.ballmarker and ball:IsA("BasePart") then
        local vel = ball.AssemblyLinearVelocity
        if vel.Magnitude > 0.4 then
            local pos = ball.Position
            local g = Vector3.new(0, -Workspace.Gravity, 0)
            local t, p, v = 0, pos, vel
            local dt = 0.03
            while t < 2.2 do
                v = v + g * dt
                p = p + v * dt
                t = t + dt
                if p.Y < pos.Y - 0.25 and v.Y < -0.5 then break end
            end
            if not landMarker or not landMarker.Parent then
                local m = Instance.new("Part")
                m.Name = "VL_LandMarker"
                m.Anchored = true
                m.CanCollide = false
                m.Size = Vector3.new(2.4, 0.15, 2.4)
                m.Material = Enum.Material.Neon
                m.Color = Color3.fromRGB(255,90,140)
                m.Transparency = 0.25
                m.Shape = Enum.PartType.Cylinder
                m.Orientation = Vector3.new(0,0,90)
                m.Parent = Workspace
                landMarker = m
            end
            landMarker.Position = Vector3.new(p.X, math.max(p.Y, 0.3), p.Z)
        end
    else
        if landMarker then pcall(function() landMarker:Destroy() end) landMarker = nil end
    end
end

-- Hide scoreboard
local hiddenScore = {}
local function hideGameScoreboard(state)
    local pg = lp:FindFirstChild("PlayerGui")
    if not pg then return end
    local keywords = {"score","point","tablo","scoreboard","matchscore","gamescore","hudscore","topbar","hud"}
    for _,gui in ipairs(pg:GetDescendants()) do
        if gui:IsA("GuiObject") then
            local n = string.lower(gui.Name)
            local match = false
            for _,k in ipairs(keywords) do
                if string.find(n, k) then match = true break end
            end
            if match then
                if state then
                    if hiddenScore[gui] == nil then
                        hiddenScore[gui] = gui.Visible
                        gui.Visible = false
                    end
                else
                    if hiddenScore[gui] ~= nil then
                        gui.Visible = hiddenScore[gui]
                        hiddenScore[gui] = nil
                    end
                end
            end
        end
    end
end

-- ========== UI ==========
local WHITE = Color3.new(1,1,1)
local GRAY = Color3.fromRGB(160,166,190)
local ACCENT = Color3.fromRGB(10,132,255)
local GREEN = Color3.fromRGB(52,199,89)
local OFFC = Color3.fromRGB(70,74,92)
local RED = Color3.fromRGB(255,69,58)
local EASE = Enum.EasingStyle

local function new(class, props, parent)
    local o = Instance.new(class)
    for k,v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end
local function tw(o, t, props, style, dir)
    local tween = TweenService:Create(o, TweenInfo.new(t, style or EASE.Quint, dir or Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end
local function corner(o, r)
    return new("UICorner", {CornerRadius = r}, o)
end

local gui = new("ScreenGui", {
    Name = "VLGlassMenu",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999
})

local parentOk = pcall(function()
    gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not parentOk or not gui.Parent then
    gui.Parent = lp:WaitForChild("PlayerGui")
end

local blur = new("BlurEffect", {Name="VLGlassBlur", Size=0}, Lighting)

local open = false
local currentTab = "opt"
local setState, refreshMaster, toggleMenu, switchTab

-- Toast
local toast = new("CanvasGroup", {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, -70),
    Size = UDim2.fromOffset(260, 42),
    BackgroundColor3 = Color3.fromRGB(22,24,36),
    BackgroundTransparency = 0.1,
    GroupTransparency = 1
}, gui)
corner(toast, UDim.new(1,0))
new("UIStroke", {Color=WHITE, Transparency=0.85, Thickness=1}, toast)
local toastTxt = new("TextLabel", {
    Size = UDim2.fromScale(1,1), BackgroundTransparency=1, Text="",
    Font=Enum.Font.GothamMedium, TextSize=13, TextColor3=WHITE
}, toast)
local toastId = 0
local function notify(text)
    toastId = toastId + 1
    local id = toastId
    toastTxt.Text = text
    tw(toast, 0.35, {Position=UDim2.new(0.5,0,0,14), GroupTransparency=0}, EASE.Back)
    task.delay(1.7, function()
        if id == toastId then
            tw(toast, 0.28, {Position=UDim2.new(0.5,0,0,-70), GroupTransparency=1})
        end
    end)
end

-- ========== DYNAMIC ISLAND ==========
local island = new("Frame", {
    Name = "DynamicIsland",
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 10),
    Size = UDim2.fromOffset(210, 38),
    BackgroundColor3 = Color3.fromRGB(14,16,24),
    BackgroundTransparency = 0.08,
    Active = true
}, gui)
corner(island, UDim.new(1,0))
new("UIGradient", {
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(32,36,55)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(12,14,22))
    })
}, island)
new("UIStroke", {Color=WHITE, Thickness=1.1, Transparency=0.7}, island)
new("UIPadding", {PaddingLeft=UDim.new(0,10), PaddingRight=UDim.new(0,10)}, island)
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 6)
}, island)

local islFps = new("TextLabel", {
    Size = UDim2.fromOffset(48, 26), BackgroundTransparency = 1,
    Text = "60", Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = GRAY, LayoutOrder = 1
}, island)

local scoreBox = new("Frame", {
    Size = UDim2.fromOffset(70, 26),
    BackgroundColor3 = Color3.fromRGB(255,255,255),
    BackgroundTransparency = 0.9, LayoutOrder = 2
}, island)
corner(scoreBox, UDim.new(0,7))
local islScore = new("TextLabel", {
    Size = UDim2.fromScale(1,1), BackgroundTransparency = 1,
    Text = "0-0", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = WHITE
}, scoreBox)

local islPing = new("TextLabel", {
    Size = UDim2.fromOffset(48, 26), BackgroundTransparency = 1,
    Text = "32", Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = GRAY, LayoutOrder = 3
}, island)

-- Extra info label under island (distance / serve)
local infoLbl = new("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 52),
    Size = UDim2.fromOffset(200, 18),
    BackgroundTransparency = 1,
    Text = "",
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    TextColor3 = Color3.fromRGB(255,200,80),
    Visible = false
}, gui)

local function updateIsland(scoreText, fps, ping)
    if not S.dynamicisland then
        island.Visible = false
        infoLbl.Visible = false
        return
    end
    island.Visible = true
    if scoreText and scoreText ~= "" then
        islScore.Text = scoreText
    end
    islFps.Text = tostring(fps or "--")
    islPing.Text = tostring(ping or "--")
end

local lastScore = "0-0"
local function tryReadScore()
    local pg = lp:FindFirstChild("PlayerGui")
    if not pg then return lastScore end
    local best, bestSize = nil, 0
    for _,v in ipairs(pg:GetDescendants()) do
        if (v:IsA("TextLabel") or v:IsA("TextButton")) and v.Visible and v.AbsoluteSize.Y > 10 then
            local t = string.gsub(v.Text, "%s+", "")
            local a,b = string.match(t, "^(%d+)[-:–/](%d+)$")
            if a and b then
                local size = v.AbsoluteSize.X * v.AbsoluteSize.Y
                if size > bestSize then
                    bestSize = size
                    best = a .. "-" .. b
                end
            end
        end
    end
    if best then lastScore = best return best end
    return lastScore
end

-- ========== PANEL ==========
local panel = new("CanvasGroup", {
    Name = "Panel",
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    GroupTransparency = 1,
    Visible = false,
    Active = true
}, gui)
corner(panel, UDim.new(0, 20))
local panelScale = new("UIScale", {Scale = 0.88}, panel)

local bgOverlay = new("Frame", {
    Size = UDim2.fromScale(1,1),
    BackgroundColor3 = Color3.fromRGB(12,14,22),
    BackgroundTransparency = 0.15
}, panel)
corner(bgOverlay, UDim.new(0,20))
new("UIGradient", {
    Rotation = 110,
    Color = ColorSequence.new(Color3.fromRGB(28,32,50), Color3.fromRGB(10,12,20))
}, bgOverlay)
new("UIStroke", {Color=WHITE, Thickness=1.1, Transparency=0.5}, panel)

local header = new("Frame", {Size=UDim2.new(1,0,0,52), BackgroundTransparency=1}, panel)
new("TextLabel", {
    Position=UDim2.fromOffset(16,8), Size=UDim2.new(1,-60,0,20), BackgroundTransparency=1,
    Text="Glass Menu", Font=Enum.Font.GothamBold, TextSize=16, TextColor3=WHITE,
    TextXAlignment=Enum.TextXAlignment.Left
}, header)
local statsLbl = new("TextLabel", {
    Position=UDim2.fromOffset(16,30), Size=UDim2.new(1,-60,0,16), BackgroundTransparency=1,
    Text="FPS --  •  Пинг -- мс", Font=Enum.Font.GothamMedium, TextSize=11, TextColor3=GRAY,
    TextXAlignment=Enum.TextXAlignment.Left
}, header)

local closeBtn = new("TextButton", {
    AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-10,0,10),
    Size=UDim2.fromOffset(28,28), BackgroundColor3=WHITE, BackgroundTransparency=0.9,
    Text="×", Font=Enum.Font.GothamBold, TextSize=20, TextColor3=WHITE, AutoButtonColor=false
}, header)
corner(closeBtn, UDim.new(0,8))
closeBtn.MouseEnter:Connect(function() tw(closeBtn,0.15,{BackgroundTransparency=0.7,TextColor3=RED}) end)
closeBtn.MouseLeave:Connect(function() tw(closeBtn,0.15,{BackgroundTransparency=0.9,TextColor3=WHITE}) end)
closeBtn.Activated:Connect(function() if open then toggleMenu() end end)

local tabBar = new("Frame", {
    Position=UDim2.fromOffset(12,52), Size=UDim2.new(1,-24,0,30),
    BackgroundColor3=WHITE, BackgroundTransparency=0.93
}, panel)
corner(tabBar, UDim.new(0,9))
new("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, HorizontalAlignment=Enum.HorizontalAlignment.Center, Padding=UDim.new(0,3)}, tabBar)
new("UIPadding", {PaddingLeft=UDim.new(0,3),PaddingRight=UDim.new(0,3),PaddingTop=UDim.new(0,3),PaddingBottom=UDim.new(0,3)}, tabBar)

local tabs = {}
local function makeTab(id, title)
    local b = new("TextButton", {
        Size=UDim2.new(0.33,-3,1,0), BackgroundTransparency=1, Text=title,
        Font=Enum.Font.GothamMedium, TextSize=12, TextColor3=GRAY, AutoButtonColor=false
    }, tabBar)
    corner(b, UDim.new(0,7))
    tabs[id] = b
    b.Activated:Connect(function() switchTab(id) end)
    return b
end
makeTab("opt","Оптимизация")
makeTab("vis","Визуал")
makeTab("misc","Ещё")

local function highlightTab(id)
    for k,b in pairs(tabs) do
        if k == id then
            b.BackgroundTransparency = 0.1
            b.BackgroundColor3 = ACCENT
            b.TextColor3 = WHITE
        else
            b.BackgroundTransparency = 1
            b.TextColor3 = GRAY
        end
    end
end

local scroll = new("ScrollingFrame", {
    Position=UDim2.fromOffset(0,88), Size=UDim2.new(1,0,1,-142),
    BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=0,
    CanvasSize=UDim2.new(), AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ScrollingDirection=Enum.ScrollingDirection.Y
}, panel)
new("UIListLayout", {Padding=UDim.new(0,2), SortOrder=Enum.SortOrder.LayoutOrder}, scroll)
new("UIPadding", {PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10),PaddingBottom=UDim.new(0,8)}, scroll)

local order = 0
local switches = {}
local contentByTab = {opt={}, vis={}, misc={}}

local function section(text, tab)
    order = order + 1
    local lbl = new("TextLabel", {
        LayoutOrder=order, Size=UDim2.new(1,0,0,22), BackgroundTransparency=1,
        Text="  "..text, Font=Enum.Font.GothamBold, TextSize=11, TextColor3=GRAY,
        TextXAlignment=Enum.TextXAlignment.Left, Visible=(tab==currentTab)
    }, scroll)
    table.insert(contentByTab[tab], lbl)
end

local function flash(o)
    o.BackgroundTransparency = 0.85
    tw(o, 0.35, {BackgroundTransparency=1})
end

local function addSwitch(key, title, sub, tab)
    order = order + 1
    local r = new("TextButton", {
        LayoutOrder=order, Size=UDim2.new(1,0,0,48), BackgroundColor3=WHITE,
        BackgroundTransparency=1, Text="", AutoButtonColor=false, Visible=(tab==currentTab)
    }, scroll)
    corner(r, UDim.new(0,11))
    new("TextLabel", {
        Position=UDim2.fromOffset(10,6), Size=UDim2.new(1,-76,0,16), BackgroundTransparency=1,
        Text=title, Font=Enum.Font.GothamMedium, TextSize=13, TextColor3=WHITE,
        TextXAlignment=Enum.TextXAlignment.Left
    }, r)
    new("TextLabel", {
        Position=UDim2.fromOffset(10,24), Size=UDim2.new(1,-76,0,14), BackgroundTransparency=1,
        Text=sub, Font=Enum.Font.Gotham, TextSize=11, TextColor3=GRAY,
        TextXAlignment=Enum.TextXAlignment.Left
    }, r)
    local track = new("Frame", {
        AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-10,0.5,0),
        Size=UDim2.fromOffset(42,24), BackgroundColor3=OFFC
    }, r)
    corner(track, UDim.new(1,0))
    local knob = new("Frame", {
        Position=UDim2.fromOffset(3,3), Size=UDim2.fromOffset(18,18), BackgroundColor3=WHITE
    }, track)
    corner(knob, UDim.new(1,0))
    switches[key] = function(on, animate)
        local t = animate and 0.25 or 0
        tw(track, t, {BackgroundColor3 = on and GREEN or OFFC})
        tw(knob, t, {Position = on and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3)}, EASE.Back)
    end
    switches[key](S[key], false)
    r.Activated:Connect(function()
        flash(r)
        setState(key, not S[key])
    end)
    table.insert(contentByTab[tab], r)
end

section("Графика", "opt")
addSwitch("quality", "Низкая графика", "Минимальный уровень рендера", "opt")
addSwitch("shadows", "Тени", "Отключить тени", "opt")
addSwitch("textures", "Текстуры", "Убрать текстуры и декали", "opt")
addSwitch("materials", "Материалы и модели", "Простые материалы", "opt")
addSwitch("effects", "Эффекты", "Частицы, туман, блум, вода", "opt")
addSwitch("accessories", "Аксессуары игроков", "Скрыть чужие аксессуары", "opt")

section("Визуалы", "vis")
addSwitch("lookbeams", "Лучи взгляда", "Куда смотрит враг (в т.ч. при подаче)", "vis")
addSwitch("ballesp", "Ball ESP", "Подсветка мяча через стены", "vis")
addSwitch("ballmarker", "Маркер падения", "Куда упадёт мяч", "vis")
addSwitch("teamoutlines", "Контуры врагов", "Только противники", "vis")
addSwitch("balldist", "Дистанция до мяча", "Показывает расстояние под Island", "vis")
addSwitch("servealert", "Алерт подачи", "Подсказка когда враг подаёт", "vis")
addSwitch("dynamicisland", "Dynamic Island", "Показывать Island", "vis")
addSwitch("hidescore", "Скрыть табло счёта", "Прячет родное табло", "vis")
addSwitch("hideplayers", "Скрыть игроков", "Только на твоём экране", "vis")

section("Прочее", "misc")
addSwitch("afk", "Анти-АФК", "Не кикает за бездействие", "misc")
addSwitch("blur", "Размытие фона", "Матовое стекло при открытом меню", "misc")

order = order + 1
local segRow = new("Frame", {
    LayoutOrder=order, Size=UDim2.new(1,0,0,42), BackgroundTransparency=1, Visible=(currentTab=="misc")
}, scroll)
table.insert(contentByTab.misc, segRow)
local segBg = new("Frame", {
    AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5),
    Size=UDim2.new(1,-6,0,30), BackgroundColor3=WHITE, BackgroundTransparency=0.9
}, segRow)
corner(segBg, UDim.new(1,0))
local caps = {30,60,120,0}
local pill = new("Frame", {
    Size=UDim2.new(0.25,-4,1,-6), Position=UDim2.new(0.25,2,0,3), BackgroundColor3=ACCENT
}, segBg)
corner(pill, UDim.new(1,0))
local function selectCap(i)
    tw(pill, 0.28, {Position=UDim2.new((i-1)*0.25, 2, 0, 3)}, EASE.Back)
    local c = caps[i]
    local ok = pcall(function()
        if not setfpscap then error("no") end
        setfpscap(c == 0 and 999 or c)
    end)
    notify(ok and ("Лимит FPS: " .. (c==0 and "∞" or tostring(c))) or "Не поддерживается")
end
for i,c in ipairs(caps) do
    local b = new("TextButton", {
        Size=UDim2.new(0.25,0,1,0), Position=UDim2.new((i-1)*0.25,0,0,0),
        BackgroundTransparency=1, Text=c==0 and "∞" or tostring(c),
        Font=Enum.Font.GothamBold, TextSize=12, TextColor3=WHITE, ZIndex=2
    }, segBg)
    b.Activated:Connect(function() selectCap(i) end)
end

order = order + 1
local unload = new("TextButton", {
    LayoutOrder=order, Size=UDim2.new(1,0,0,38), BackgroundTransparency=1,
    Text="Выгрузить скрипт", Font=Enum.Font.GothamMedium, TextSize=13, TextColor3=RED,
    AutoButtonColor=false, Visible=(currentTab=="misc")
}, scroll)
table.insert(contentByTab.misc, unload)
unload.Activated:Connect(function() if ENV.VL_Cleanup then ENV.VL_Cleanup() end end)

local master = new("TextButton", {
    AnchorPoint=Vector2.new(0.5,1), Position=UDim2.new(0.5,0,1,-12),
    Size=UDim2.new(1,-24,0,38), BackgroundColor3=WHITE, Text="Включить всё",
    Font=Enum.Font.GothamBold, TextSize=13, TextColor3=WHITE, AutoButtonColor=false
}, panel)
corner(master, UDim.new(1,0))
new("UIGradient", {Color=ColorSequence.new(Color3.fromRGB(10,132,255), Color3.fromRGB(90,90,230))}, master)
local masterScale = new("UIScale", {}, master)
master.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        tw(masterScale,0.08,{Scale=0.95})
    end
end)
master.InputEnded:Connect(function() tw(masterScale,0.28,{Scale=1}, EASE.Back) end)

local function allOn()
    for _,k in ipairs(OPT) do if not S[k] then return false end end
    return true
end
refreshMaster = function()
    master.Text = allOn() and "Выключить всё" or "Включить всё"
end
master.Activated:Connect(function()
    local target = not allOn()
    task.spawn(function()
        for _,k in ipairs(OPT) do
            if S[k] ~= target then setState(k, target, true) end
            task.wait(0.05)
        end
        notify(target and "Максимальный буст" or "Всё выключено")
    end)
end)

-- LOGIC
setState = function(key, val, quiet)
    S[key] = val
    if switches[key] then switches[key](val, true) end
    if key == "blur" and open then tw(blur,0.25,{Size=val and 14 or 0}) end
    if key == "lookbeams" then updateLookBeams() end
    if key == "teamoutlines" then updateOutlines() end
    if key == "dynamicisland" then
        updateIsland(tryReadScore())
        island.Visible = val
    end
    if key == "hidescore" then hideGameScoreboard(val) end
    if not quiet then notify(NAMES[key] .. (val and ": вкл" or ": выкл")) end
    refreshMaster()
    saveSettings()
    local skip = {
        afk=true, blur=true, lookbeams=true, dynamicisland=true, hidescore=true,
        ballesp=true, ballmarker=true, teamoutlines=true, balldist=true, servealert=true
    }
    if not skip[key] then
        task.spawn(function() globalApply() sweep() end)
    end
end

switchTab = function(id)
    currentTab = id
    highlightTab(id)
    for tab, list in pairs(contentByTab) do
        for _,obj in ipairs(list) do
            obj.Visible = (tab == id)
        end
    end
end
highlightTab("opt")

local function placePanel()
    local vs = gui.AbsoluteSize
    local w = math.min(280, vs.X - 16)
    local h = math.min(420, vs.Y - 20)
    panel.Size = UDim2.fromOffset(w, h)
    panel.Position = UDim2.fromScale(0.5, 0.5)
end

toggleMenu = function()
    open = not open
    if open then
        placePanel()
        panel.Visible = true
        panel.GroupTransparency = 1
        panelScale.Scale = 0.85
        tw(panel, 0.28, {GroupTransparency = 0})
        tw(panelScale, 0.4, {Scale = 1}, EASE.Back)
        if S.blur then tw(blur, 0.3, {Size = 14}) end
        tw(island, 0.25, {BackgroundTransparency = 0.02})
    else
        tw(panel, 0.2, {GroupTransparency = 1})
        tw(panelScale, 0.2, {Scale = 0.88}, EASE.Quad, Enum.EasingDirection.In)
        tw(blur, 0.2, {Size = 0})
        tw(island, 0.25, {BackgroundTransparency = 0.08})
        task.delay(0.22, function()
            if not open then panel.Visible = false end
        end)
    end
end

-- Drag + Tap Island
local dragging, moved = false, false
local dragStart, startPos, dragInput
island.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        moved = false
        dragStart = input.Position
        startPos = island.Position
        dragInput = input
        local conn
        conn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                conn:Disconnect()
                dragging = false
                if moved then
                    local vs = gui.AbsoluteSize
                    local cx = island.AbsolutePosition.X + island.AbsoluteSize.X / 2
                    local tx = math.clamp(cx, 110, vs.X - 110)
                    tw(island, 0.35, {Position = UDim2.new(0, tx, 0, 10)}, EASE.Back)
                else
                    toggleMenu()
                end
            end
        end)
    end
end)
connect(UIS.InputChanged, function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or
       (input.UserInputType == Enum.UserInputType.Touch and input == dragInput) then
        local delta = input.Position - dragStart
        if not moved and delta.Magnitude > 8 then moved = true end
        if moved then
            local vs = gui.AbsoluteSize
            local newX = startPos.X.Offset + delta.X
            local newY = math.clamp(startPos.Y.Offset + delta.Y, 4, vs.Y - 50)
            island.Position = UDim2.new(0, newX, 0, newY)
        end
    end
end)
connect(UIS.InputBegan, function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightShift then
        toggleMenu()
    end
end)

-- MAIN LOOP
local frames, t0 = 0, os.clock()
connect(RunService.RenderStepped, function()
    frames = frames + 1
    local now = os.clock()
    if now - t0 >= 0.5 then
        local fps = math.floor(frames / (now - t0) + 0.5)
        local ping = 0
        pcall(function()
            ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        if open then
            statsLbl.Text = string.format("FPS %d  •  Пинг %d мс", fps, ping)
        end
        updateIsland(tryReadScore(), fps, ping)
        frames = 0
        t0 = now
    end

    if S.lookbeams then updateLookBeams() end
    if S.teamoutlines then updateOutlines() end
    if S.ballesp or S.ballmarker then updateBallESP() end

    -- Ball distance + serve alert under island
    if S.dynamicisland and (S.balldist or S.servealert) then
        local parts = {}
        if S.balldist and lastBallPos then
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - lastBallPos).Magnitude
                table.insert(parts, string.format("Мяч: %.0f", dist))
            end
        end
        if S.servealert then
            -- rough: if an enemy is near back line and looking at court, flag serve
            for _,plr in ipairs(Players:GetPlayers()) do
                if isEnemy(plr) and plr.Character then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        -- simple heuristic: far from net center (assume net near 0 Z or X depending on map)
                        -- just show if someone is isolated near edge
                    end
                end
            end
        end
        if #parts > 0 then
            infoLbl.Text = table.concat(parts, "  •  ")
            infoLbl.Visible = true
        else
            infoLbl.Visible = false
        end
    else
        infoLbl.Visible = false
    end
end)

-- Init
if S.hidescore then hideGameScoreboard(true) end
updateIsland(tryReadScore())
for k,v in pairs(S) do
    if switches[k] then switches[k](v, false) end
end
refreshMaster()

ENV.VL_Cleanup = function()
    for _,c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    for _,k in ipairs(OPT) do S[k] = false end
    S.hideplayers = false
    S.lookbeams = false
    S.dynamicisland = false
    S.hidescore = false
    S.ballesp = false
    S.ballmarker = false
    S.teamoutlines = false
    S.balldist = false
    S.servealert = false
    for plr in pairs(lookBeams) do clearLookBeam(plr) end
    for plr in pairs(outlines) do clearOutline(plr) end
    if ballEsp then pcall(function() ballEsp:Destroy() end) end
    if landMarker then pcall(function() landMarker:Destroy() end) end
    hideGameScoreboard(false)
    pcall(globalApply)
    for _,v in ipairs(Workspace:GetDescendants()) do pcall(apply, v) end
    pcall(function() blur:Destroy() end)
    pcall(function() gui:Destroy() end)
    ENV.VL_Cleanup = nil
end

task.delay(0.3, function()
    notify("Glass Menu v2.4 готов")
end)

print("[VL Glass] v2.4 Loaded successfully")
