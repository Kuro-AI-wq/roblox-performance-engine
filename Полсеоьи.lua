--[[
	GAKURAN // AUTO-PARRY  v1.1
	====================================
	Экзекутор : Delta (мобильный / ПК)
	Игра      : Gakuran (Roblox)
	Режимы    : Авто-пари (тап F) · Автоблок (холд F) · Реактивный тап
	            · Даш от M2 (Q)
	GUI       : широкое меню + прокрутка, включённые функции — зелёные

	Что нового в 1.1:
	  + Реактивный тап (fallback, если анимация не распознана)
	  + Счётчик ХИТ (сколько раз по тебе прилетело)
	  + Кнопка ТЕСТ F (проверка, что экзекутор шлёт клавиши)
	  + Ключевые слова атак можно дописывать в JSON на устройстве
	  + Прокрутка меню пальцем + увеличенные кнопки под тач
	  + Включённые тумблеры — зелёные
]]

local ok, err = pcall(function()

	local Players   = game:GetService("Players")
	local UIS       = game:GetService("UserInputService")
	local VIM       = game:GetService("VirtualInputManager")
	local HttpService = game:GetService("HttpService")
	local LP = Players.LocalPlayer

	-- повторный запуск = замена старого меню
	local env = getgenv and getgenv() or _G
	if env.GakuranAP_Running ~= nil then
		env.GakuranAP_Running = false
		task.wait(0.25)
		pcall(function()
			if env.GakuranAP_GUI then env.GakuranAP_GUI:Destroy() end
		end)
		task.wait(0.1)
	end
	env.GakuranAP_Running = true

	local holding = false
	local holdUntil = 0
	local parryBusy = false
	local dashBusy = false
	local lastTapAt = 0
	local lastReactiveAt = 0
	local lastDashAt = 0
	local npcScanAt = 0
	local enemyCache = {}
	local stats = { parry = 0, block = 0, dash = 0, hit = 0 }
	local lastHealth = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") and LP.Character:FindFirstChildOfClass("Humanoid").Health or 100
	local flashText, flashColor, flashUntil = "", Color3.fromRGB(245,245,245), 0

	-- ===== НАСТРОЙКИ =====
	local CFG = {
		autoParry   = true,    -- тап F в окно пари
		autoBlock   = true,    -- холд F, пока враг атакует
		autoDash    = false,   -- тап Q от M2 (если авто-пари выкл)
		reactive    = true,    -- запасной тап F, если анимация не распознана
		usePlayers  = true,
		useNPCs     = true,
		facingCheck = true,
		smartDetect = true,
		debugLog    = false,
		parryTiming = 0.65,    -- точка срабатывания пари (0.40..0.90)
		range       = 12,
		cooldown    = 0.28,    -- кулдаун тапа пари
		reactiveCooldown = 0.45, -- кулдаун реактивного тапа
		holdBlock   = 0.25,
		extraKeywords = {},    -- свои слова: ["jab","cross"] — дописывай в JSON
	}

	local function loadCfg()
		local ok2, data = pcall(function()
			if not isfile then return nil end
			if not isfile("GakuranAP_Settings.json") then return nil end
			return HttpService:JSONDecode(readfile("GakuranAP_Settings.json"))
		end)
		if ok2 and type(data) == "table" then
			for k, v in pairs(data) do
				if CFG[k] ~= nil then CFG[k] = v end
			end
		end
	end
	local function saveCfg()
		pcall(function()
			if writefile then
				writefile("GakuranAP_Settings.json", HttpService:JSONEncode(CFG))
			end
		end)
	end
	loadCfg()

	-- ===== СИМУЛЯЦИЯ КЛАВИШ =====
	local function toNum(code)
		return typeof(code) == "EnumItem" and code.Value or code
	end
	local function sendKey(code, down)
		if type(keypress) == "function" then
			local okk = pcall(function()
				if down then keypress(toNum(code)) else keyrelease(toNum(code)) end
			end)
			if okk then return end
		end
		pcall(function()
			VIM:SendKeyEvent(down, code, false, game)
		end)
	end
	local function tapKey(code)
		sendKey(code, false)
		task.wait(0.025)
		sendKey(code, true)
		task.wait(0.05)
		sendKey(code, false)
	end

	-- ===== ПОИСК АТАК =====
	local ATTACK_KW = {
		"attack","atk","swing","slash","punch","kick","strike","combo",
		"light","heavy","m1","m2","jab","cross","hook","uppercut",
		"roundhouse","blitz","gatling","fury","strong","power","rush",
		"barrage","smash","thrust","spin","elbow","knee","headbutt",
		"clinch","grab","throw","kick",
	}
	local HEAVY_KW = { "heavy","m2","strong","power","special","fury","smash","overhead" }
	local IGNORE_KW = {
		"idle","run","walk","jump","dodge","block","parry","stun","ragdoll",
		"emote","dash","death","fall","swim","climb","sit","tool","hold",
		"carry","pickup","drop","laugh","wave","taunt","cheer","clap","stand",
		"land","shiftlock","camera","greet",
	}

	local function kwMatch(name, list)
		for _, w in ipairs(list) do
			if name:find(w, 1, true) then return true end
		end
		return false
	end
	local function kwMatchExtra(name)
		for _, w in ipairs(CFG.extraKeywords or {}) do
			if type(w) == "string" and name:find(w:lower(), 1, true) then return true end
		end
		return false
	end

	local function findAttackTrack(hum)
		if not hum then return nil end
		for _, tr in ipairs(hum:GetPlayingAnimationTracks()) do
			if tr.IsPlaying and tr.Speed > 0.1 then
				local n = (tr.Name or ""):lower()
				if kwMatch(n, ATTACK_KW) or kwMatchExtra(n) then
					return tr, n
				end
			end
		end
		if CFG.smartDetect then
			for _, tr in ipairs(hum:GetPlayingAnimationTracks()) do
				if tr.IsPlaying and tr.Speed > 0.1 then
					local n = (tr.Name or ""):lower()
					if not kwMatch(n, IGNORE_KW) then return tr, n end
				end
			end
		end
		return nil
	end

	-- враг "занят" (любая не-движенческая анимация) — для реактивного тапа
	local function enemyBusy(hum)
		if not hum then return false end
		for _, tr in ipairs(hum:GetPlayingAnimationTracks()) do
			if tr.IsPlaying and tr.Speed > 0.1 then
				local n = (tr.Name or ""):lower()
				if not kwMatch(n, IGNORE_KW) then return true end
			end
		end
		return false
	end

	local function trackProgress(tr)
		local len = tr.Length
		if not len or len <= 0 then return 0 end
		return tr.TimePosition / len
	end

	-- ===== КЭШ ВРАГОВ =====
	local function addEnemy(char)
		if not char or enemyCache[char] then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then return end
		local isPlayer = Players:GetPlayerFromCharacter(char) ~= nil
		if isPlayer and not CFG.usePlayers then return end
		if not isPlayer and not CFG.useNPCs then return end
		enemyCache[char] = { hum = hum, active = nil, tapped = false }
	end

	Players.PlayerAdded:Connect(function(p)
		if p == LP then return end
		p.CharacterAdded:Connect(function(c) addEnemy(c) end)
		if p.Character then addEnemy(p.Character) end
	end)
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP then
			p.CharacterAdded:Connect(function(c) addEnemy(c) end)
			if p.Character then addEnemy(p.Character) end
		end
	end

	local function scanNPCs()
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("Humanoid") and v.Parent and v.Parent ~= LP.Character then
				if not Players:GetPlayerFromCharacter(v.Parent) then
					addEnemy(v.Parent)
				end
			end
		end
	end

	local function evalEnemy(char, data, myRoot)
		local root = char:FindFirstChild("HumanoidRootPart")
		local hum = data.hum
		if not root or not hum or hum.Health <= 0 then return nil end
		local dist = (root.Position - myRoot.Position).Magnitude
		if dist > CFG.range then return nil end

		local tr, trName = findAttackTrack(hum)
		if not tr then
			data.active, data.tapped = nil, false
			return nil
		end
		if CFG.debugLog and tr ~= data.active then
			print(string.format("[GakuranAP] атака: %s (%.1f стд)", trName, dist))
		end
		if tr ~= data.active then data.active, data.tapped = tr, false end

		local prog = trackProgress(tr)
		local inWindow = prog >= CFG.parryTiming - 0.08 and prog <= CFG.parryTiming + 0.08
		local facing = true
		if CFG.facingCheck then
			local dirToMe = (myRoot.Position - root.Position).Unit
			facing = root.CFrame.LookVector:Dot(dirToMe) > 0.15
		end
		return {
			data = data,
			isHeavy = kwMatch((trName or ""):lower(), HEAVY_KW),
			inWindow = inWindow,
			facing = facing,
			dist = dist,
		}
	end

	local function flash(txt, col)
		flashText = txt
		flashColor = col or Color3.fromRGB(245, 245, 245)
		flashUntil = tick() + 0.18
	end

	-- ===== ОСНОВНОЙ ЦИКЛ =====
	task.spawn(function()
		while env.GakuranAP_Running do
			task.wait(1 / 30)

			local myChar = LP.Character
			local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
			local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
			if not (myRoot and myHum and myHum.Health > 0) then
				if holding then sendKey(Enum.KeyCode.F, false) holding = false end
				continue
			end
			if myHum:GetState() == Enum.HumanoidStateType.Ragdoll
				or myHum:GetState() == Enum.HumanoidStateType.Sitting then
				if holding then sendKey(Enum.KeyCode.F, false) holding = false end
				continue
			end

			for char in pairs(enemyCache) do
				if char.Parent == nil then enemyCache[char] = nil end
			end
			if CFG.useNPCs and tick() > npcScanAt then
				npcScanAt = tick() + 3
				scanNPCs()
			end

			local threat = nil
			for char, data in pairs(enemyCache) do
				local t = evalEnemy(char, data, myRoot)
				if t and t.inWindow and t.facing then threat = t break end
			end

			-- АВТО-ПАРИ
			if threat and CFG.autoParry and not parryBusy
				and not threat.data.tapped and tick() - lastTapAt >= CFG.cooldown then
				threat.data.tapped = true
				parryBusy = true
				task.spawn(function()
					tapKey(Enum.KeyCode.F)
					parryBusy = false
					lastTapAt = tick()
					stats.parry = stats.parry + 1
					flash("ПАРИ!", Color3.fromRGB(80, 235, 130))
				end)
			end

			-- РЕАКТИВНЫЙ ТАП (fallback, если анимация не распознана)
			if not threat and CFG.reactive and CFG.autoParry
				and not parryBusy and tick() - lastReactiveAt >= CFG.reactiveCooldown then
				local anyBusy = false
				for char, data in pairs(enemyCache) do
					local root = char:FindFirstChild("HumanoidRootPart")
					if root and (root.Position - myRoot.Position).Magnitude <= CFG.range then
						local facing = true
						if CFG.facingCheck then
							local dirToMe = (myRoot.Position - root.Position).Unit
							facing = root.CFrame.LookVector:Dot(dirToMe) > 0.15
						end
						if facing and enemyBusy(data.hum) then
							anyBusy = true
							break
						end
					end
				end
				if anyBusy then
					lastReactiveAt = tick()
					parryBusy = true
					task.spawn(function()
						tapKey(Enum.KeyCode.F)
						parryBusy = false
						lastTapAt = tick()
						stats.parry = stats.parry + 1
						flash("ПАРИ!", Color3.fromRGB(80, 235, 130))
					end)
				end
			end

			-- АВТО-ДАШ от M2 (тяжёлый удар блоком не гасится)
			if threat and threat.isHeavy and CFG.autoDash and not CFG.autoParry
				and not dashBusy and tick() - lastDashAt >= 1.0 then
				dashBusy = true
				task.spawn(function()
					tapKey(Enum.KeyCode.Q)
					dashBusy = false
					lastDashAt = tick()
					stats.dash = stats.dash + 1
					flash("ДАШ!")
				end)
			end

			-- АВТО-БЛОК
			local anyAttack = false
			for char, data in pairs(enemyCache) do
				if evalEnemy(char, data, myRoot) then anyAttack = true break end
			end
			if CFG.autoBlock and anyAttack then
				if not holding then
					sendKey(Enum.KeyCode.F, true)
					holding = true
					stats.block = stats.block + 1
					flash("БЛОК")
				end
				holdUntil = tick() + CFG.holdBlock
			elseif holding and tick() >= holdUntil then
				send
