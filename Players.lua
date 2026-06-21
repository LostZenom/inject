if not game:IsLoaded() then game.Loaded:Wait() end

local tweenService     = game:GetService("TweenService")
local players          = game:GetService("Players")
local runService       = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local lp               = players.LocalPlayer
local gui              = lp:WaitForChild("PlayerGui")
local camera           = workspace.CurrentCamera

-- ── Palette ────────────────────────────────────────────────────────────────
local C = {
	PANEL  = Color3.fromRGB( 10,  12,  22),
	STROKE = Color3.fromRGB( 60,  75, 130),
	ACCENT = Color3.fromRGB( 90, 175, 255),
	ACCENT2= Color3.fromRGB(145,  90, 255),
	TEXT   = Color3.fromRGB(225, 235, 255),
	DIM    = Color3.fromRGB(110, 125, 165),
	ACTION = Color3.fromRGB( 65, 140, 240),
	DANGER = Color3.fromRGB(240,  70, 100),
	BG     = Color3.fromRGB(  6,   7,  16),
	DIV    = Color3.fromRGB( 38,  48,  80),
}

local Q = Enum.EasingStyle.Quint
local OUT = Enum.EasingDirection.Out

-- ── Helpers ─────────────────────────────────────────────────────────────────
local function tween(obj, info, goals)
	if obj then tweenService:Create(obj, info, goals):Play() end
end

-- ── Screen GUI ───────────────────────────────────────────────────────────────
local sg = Instance.new("ScreenGui")
sg.Name           = "CLEAN_UI_SLATE"
sg.ResetOnSpawn   = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.IgnoreGuiInset = true
sg.DisplayOrder   = 50
sg.Parent         = (gethui and gethui()) or gui
local screen = sg

-- ── Drag system ───────────────────────────────────────────────────────────────
local dragOwner = nil
local function makePanelDraggable(pnl, bar, onMove)
	local dragging, touchInput = false, nil
	local dragStartM, dragStartPos = Vector2.zero, UDim2.new()
	
	local function pointerPos()
		if touchInput then return Vector2.new(touchInput.Position.X, touchInput.Position.Y) end
		return userInputService:GetMouseLocation()
	end
	
	bar.InputBegan:Connect(function(i)
		if dragging or (dragOwner ~= nil and dragOwner ~= pnl) then return end
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			touchInput = nil ; dragStartM = userInputService:GetMouseLocation()
			dragStartPos = pnl.Position ; dragging = true ; dragOwner = pnl
		elseif i.UserInputType == Enum.UserInputType.Touch then
			touchInput = i ; dragStartM = Vector2.new(i.Position.X, i.Position.Y)
			dragStartPos = pnl.Position ; dragging = true ; dragOwner = pnl
		end
	end)
	
	userInputService.InputEnded:Connect(function(i)
		if i == touchInput or i.UserInputType == Enum.UserInputType.MouseButton1 then
			if dragging then dragging = false ; touchInput = nil ; if dragOwner == pnl then dragOwner = nil end end
		end
	end)
	
	runService.RenderStepped:Connect(function()
		if not dragging then return end
		local d = pointerPos() - dragStartM
		local vp = workspace.CurrentCamera.ViewportSize
		local ps = pnl.AbsoluteSize
		local curPxX = dragStartPos.X.Offset + dragStartPos.X.Scale * vp.X
		local curPxY = dragStartPos.Y.Offset + dragStartPos.Y.Scale * vp.Y
		local anchorOffX = pnl.AnchorPoint.X * ps.X
		local anchorOffY = pnl.AnchorPoint.Y * ps.Y
		local newX = math.clamp(curPxX + d.X, anchorOffX, vp.X - ps.X + anchorOffX)
		local newY = math.clamp(curPxY + d.Y, anchorOffY, vp.Y - ps.Y + anchorOffY)
		pnl.Position = UDim2.new(0, newX, 0, newY)
	end)
end

-- ── Floating Tooltip ────────────────────────────────────────────────────────
local tooltip = Instance.new("TextLabel", screen)
tooltip.Visible = false
tooltip.AutomaticSize = Enum.AutomaticSize.XY
tooltip.BackgroundColor3 = C.BG
tooltip.TextColor3 = C.TEXT
tooltip.Font = Enum.Font.GothamBold
tooltip.TextSize = 12
tooltip.ZIndex = 300
tooltip.TextXAlignment = Enum.TextXAlignment.Center
tooltip.TextYAlignment = Enum.TextYAlignment.Center
Instance.new("UICorner", tooltip).CornerRadius = UDim.new(0, 6)
local tpPad = Instance.new("UIPadding", tooltip)
tpPad.PaddingTop = UDim.new(0, 6) ; tpPad.PaddingBottom = UDim.new(0, 6)
tpPad.PaddingLeft = UDim.new(0, 10) ; tpPad.PaddingRight = UDim.new(0, 10)
Instance.new("UIStroke", tooltip).Color = C.STROKE

local function showTooltip(text)
	tooltip.Text = text
	tooltip.Visible = true
end
local function hideTooltip()
	tooltip.Visible = false
end

userInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement and tooltip.Visible then
		tooltip.Position = UDim2.new(0, input.Position.X + 15, 0, input.Position.Y + 15)
	end
end)

local function bindTooltip(guiObj, text)
	guiObj.MouseEnter:Connect(function() showTooltip(text) end)
	guiObj.MouseLeave:Connect(hideTooltip)
end

-- ── Panel construction ───────────────────────────────────────────────────────
local function makeFloatingPanel(w, h, anchorX, anchorY)
	local pnl = Instance.new("Frame", screen)
	pnl.Size = UDim2.new(0, w, 0, h)
	pnl.AnchorPoint = Vector2.new(anchorX, anchorY)
	pnl.Position = UDim2.new(anchorX, 0, anchorY, 0)
	pnl.BackgroundColor3 = C.PANEL ; pnl.ZIndex = 150 ; pnl.ClipsDescendants = true
	Instance.new("UICorner", pnl).CornerRadius = UDim.new(0, 10)

	local grad = Instance.new("UIGradient", pnl)
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(18, 20, 42)),
		ColorSequenceKeypoint.new(0.6, Color3.fromRGB(10, 12, 26)),
		ColorSequenceKeypoint.new(1,   Color3.fromRGB( 8, 10, 20)),
	})
	grad.Rotation = 130

	local pStroke = Instance.new("UIStroke", pnl)
	pStroke.Color = C.STROKE ; pStroke.Transparency = 0.35 ; pStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	return pnl
end

local function makePanelTitleBar(pnl, title, onClose, onMinimize)
	local bar = Instance.new("Frame", pnl)
	bar.Size = UDim2.new(1, 0, 0, 36) ; bar.BackgroundTransparency = 1 ; bar.ZIndex = 151

	local topLine = Instance.new("Frame", bar)
	topLine.Size = UDim2.new(0.55, 0, 0, 1) ; topLine.AnchorPoint = Vector2.new(0.5, 0)
	topLine.Position = UDim2.new(0.5, 0, 0, 0) ; topLine.BackgroundColor3 = C.ACCENT ; topLine.BorderSizePixel = 0 ; topLine.ZIndex = 152
	local tlGrad = Instance.new("UIGradient", topLine)
	tlGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, 0), NumberSequenceKeypoint.new(0.8, 0), NumberSequenceKeypoint.new(1, 1)})

	local lbl = Instance.new("TextLabel", bar)
	lbl.Text = title ; lbl.Font = Enum.Font.GothamBold ; lbl.TextSize = 12 ; lbl.TextColor3 = C.TEXT
	lbl.Position = UDim2.new(0, 14, 0, 0) ; lbl.Size = UDim2.new(1, -80, 1, 0) ; lbl.BackgroundTransparency = 1 ; lbl.TextXAlignment = Enum.TextXAlignment.Left ; lbl.ZIndex = 152
	local lblGrad = Instance.new("UIGradient", lbl)
	lblGrad.Color = ColorSequence.new(C.ACCENT, C.ACCENT2)

	if onMinimize then
		local minBtn = Instance.new("TextButton", bar)
		minBtn.Text = "–" ; minBtn.Size = UDim2.new(0, 22, 0, 22) ; minBtn.Position = UDim2.new(1, -54, 0.5, -11)
		minBtn.BackgroundTransparency = 1 ; minBtn.ZIndex = 153 ; minBtn.Font = Enum.Font.GothamBold ; minBtn.TextSize = 14 ; minBtn.TextColor3 = C.DIM
		minBtn.MouseButton1Click:Connect(onMinimize)
		minBtn.MouseEnter:Connect(function() tween(minBtn, TweenInfo.new(0.15), {TextColor3 = C.TEXT}) end)
		minBtn.MouseLeave:Connect(function() tween(minBtn, TweenInfo.new(0.18), {TextColor3 = C.DIM}) end)
	end

	local closeBtn = Instance.new("TextButton", bar)
	closeBtn.Text = "" ; closeBtn.Size = UDim2.new(0, 22, 0, 22) ; closeBtn.Position = UDim2.new(1, -28, 0.5, -11)
	closeBtn.BackgroundTransparency = 1 ; closeBtn.ZIndex = 153

	local closeIcon = Instance.new("ImageLabel", closeBtn)
	closeIcon.BackgroundTransparency = 1 ; closeIcon.Size = UDim2.new(0, 10, 0, 10) ; closeIcon.Position = UDim2.new(0.5, 0, 0.5, 0) ; closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	closeIcon.Image = "rbxassetid://82927197777156" ; closeIcon.ImageColor3 = Color3.new(1, 1, 1) ; closeIcon.ImageTransparency = 0.5 ; closeIcon.ZIndex = 154

	closeBtn.MouseButton1Click:Connect(onClose)
	closeBtn.MouseEnter:Connect(function() tween(closeIcon, TweenInfo.new(0.15), {ImageTransparency = 0, ImageColor3 = C.DANGER}) end)
	closeBtn.MouseLeave:Connect(function() tween(closeIcon, TweenInfo.new(0.2), {ImageTransparency = 0.5, ImageColor3 = Color3.new(1,1,1)}) end)

	return bar
end

-- ── Main UI Initialization ────────────────────────────────────────────────────
local PANEL_DEFAULT_W = 340
local PANEL_DEFAULT_H = 420
local TITLE_BAR_H     = 36
local isMinimized     = false

local mainPanel = makeFloatingPanel(PANEL_DEFAULT_W, PANEL_DEFAULT_H, 0.5, 0.35)
local topBar = makePanelTitleBar(mainPanel, "Players", function() sg:Destroy() end, function()
	isMinimized = not isMinimized
	tween(mainPanel, TweenInfo.new(0.3, Q, OUT), {Size = UDim2.new(0, PANEL_DEFAULT_W, 0, isMinimized and TITLE_BAR_H or PANEL_DEFAULT_H)})
end)
makePanelDraggable(mainPanel, topBar)

local contentArea = Instance.new("Frame", mainPanel)
contentArea.Name = "ContentArea" ; contentArea.BackgroundTransparency = 1
contentArea.Position = UDim2.new(0, 0, 0, TITLE_BAR_H) ; contentArea.Size = UDim2.new(1, 0, 1, -TITLE_BAR_H)

-- ── Player Count Pill ────────────────────────────────────────────────────────
local countPill = Instance.new("Frame", contentArea)
countPill.AnchorPoint = Vector2.new(0.5, 0)
countPill.Position = UDim2.new(0.5, 0, 0, 12)
countPill.Size = UDim2.new(0, 0, 0, 26)
countPill.AutomaticSize = Enum.AutomaticSize.X
countPill.BackgroundColor3 = C.TEXT
countPill.BackgroundTransparency = 0.92 -- Sleek transparent background
countPill.BorderSizePixel = 0
Instance.new("UICorner", countPill).CornerRadius = UDim.new(0, 8) -- 8px Pill Radius

local pillLayout = Instance.new("UIListLayout", countPill)
pillLayout.FillDirection = Enum.FillDirection.Horizontal
pillLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
pillLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local pillPad = Instance.new("UIPadding", countPill)
pillPad.PaddingLeft = UDim.new(0, 14)
pillPad.PaddingRight = UDim.new(0, 14)

local countLabel = Instance.new("TextLabel", countPill)
countLabel.AutomaticSize = Enum.AutomaticSize.XY
countLabel.BackgroundTransparency = 1
countLabel.Font = Enum.Font.GothamBold
countLabel.TextSize = 12
countLabel.TextColor3 = C.TEXT
countLabel.Text = "0 / 0"

local function updatePlayerCount()
	countLabel.Text = tostring(#players:GetPlayers()) .. " / " .. tostring(players.MaxPlayers)
end

-- ── Player Panel Logic ───────────────────────────────────────────────────────
local scroll = Instance.new("ScrollingFrame", contentArea)
scroll.Size = UDim2.new(1, -16, 1, -60) -- Adjusted for Pill space
scroll.Position = UDim2.new(0, 8, 0, 48)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 0 -- Hidden scrollbar
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local listLayout = Instance.new("UIListLayout", scroll)
listLayout.SortOrder = Enum.SortOrder.Name
listLayout.Padding = UDim.new(0, 4)

-- State tracking
local spectatingPlayer = nil

-- Using rbxthumb to safely convert provided Decal IDs to Image IDs
local ASSET_EYE = "rbxthumb://type=Asset&id=103350483289008&w=150&h=150"
local ASSET_HIDDEN_EYE = "rbxthumb://type=Asset&id=70930861623459&w=150&h=150"

local function createPlayerCard(player)
	local card = Instance.new("Frame")
	card.Name = player.Name
	card.Size = UDim2.new(1, 0, 0, 56)
	card.BackgroundTransparency = 1 -- Clean, transparent look
	card.BorderSizePixel = 0

	-- Clean Separator Line at the bottom
	local separator = Instance.new("Frame", card)
	separator.Size = UDim2.new(1, -20, 0, 1)
	separator.Position = UDim2.new(0.5, 0, 1, 0)
	separator.AnchorPoint = Vector2.new(0.5, 1)
	separator.BackgroundColor3 = C.TEXT
	separator.BackgroundTransparency = 0.9 -- Extremely subtle
	separator.BorderSizePixel = 0

	-- Player Thumbnail
	local thumb = Instance.new("ImageLabel", card)
	thumb.Size = UDim2.new(0, 36, 0, 36)
	thumb.Position = UDim2.new(0, 10, 0.5, 0)
	thumb.AnchorPoint = Vector2.new(0, 0.5)
	thumb.BackgroundColor3 = C.BG
	thumb.BackgroundTransparency = 0.5
	thumb.Image = "rbxthumb://type=AvatarHeadShot&id="..player.UserId.."&w=150&h=150"
	Instance.new("UICorner", thumb).CornerRadius = UDim.new(0, 8)
	
	-- Display Name
	local dName = Instance.new("TextLabel", card)
	dName.Text = player.DisplayName
	dName.Font = Enum.Font.GothamBold
	dName.TextSize = 14
	dName.TextColor3 = C.TEXT
	dName.BackgroundTransparency = 1
	dName.Position = UDim2.new(0, 56, 0.5, -9)
	dName.Size = UDim2.new(1, -140, 0, 18)
	dName.TextXAlignment = Enum.TextXAlignment.Left
	dName.TextTruncate = Enum.TextTruncate.AtEnd

	-- Username
	local uName = Instance.new("TextLabel", card)
	uName.Text = "@" .. player.Name
	uName.Font = Enum.Font.Gotham
	uName.TextSize = 12
	uName.TextColor3 = C.DIM
	uName.BackgroundTransparency = 1
	uName.Position = UDim2.new(0, 56, 0.5, 7)
	uName.Size = UDim2.new(1, -140, 0, 18)
	uName.TextXAlignment = Enum.TextXAlignment.Left
	uName.TextTruncate = Enum.TextTruncate.AtEnd

	-- Action Buttons Container
	local actions = Instance.new("Frame", card)
	actions.Name = "Actions"
	actions.BackgroundTransparency = 1
	actions.Size = UDim2.new(0, 80, 1, 0)
	actions.Position = UDim2.new(1, -10, 0, 0)
	actions.AnchorPoint = Vector2.new(1, 0)

	local actLayout = Instance.new("UIListLayout", actions)
	actLayout.FillDirection = Enum.FillDirection.Horizontal
	actLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	actLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	actLayout.Padding = UDim.new(0, 6)

	-- Button Generator
	local function makeBtn(name, w)
		local b = Instance.new("TextButton")
		b.Name = name
		b.Size = UDim2.new(0, w, 0, 32)
		b.BackgroundColor3 = C.TEXT
		b.BackgroundTransparency = 0.95 -- Ghost button look
		b.AutoButtonColor = false
		b.Text = ""
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
		b.Parent = actions

		b.MouseEnter:Connect(function() 
			tween(b, TweenInfo.new(0.2), {BackgroundColor3 = C.ACTION, BackgroundTransparency = 0}) 
		end)
		b.MouseLeave:Connect(function() 
			tween(b, TweenInfo.new(0.2), {BackgroundColor3 = C.TEXT, BackgroundTransparency = 0.95}) 
		end)
		return b
	end

	-- 1. Spectate Button
	local btnSpec = makeBtn("Spectate", 32)
	local specIcon = Instance.new("ImageLabel", btnSpec)
	specIcon.Size = UDim2.new(1, -12, 1, -12)
	specIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	specIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	specIcon.BackgroundTransparency = 1
	specIcon.ScaleType = Enum.ScaleType.Fit
	specIcon.Image = (spectatingPlayer == player) and ASSET_HIDDEN_EYE or ASSET_EYE
	bindTooltip(btnSpec, "Spectate")

	btnSpec.MouseButton1Click:Connect(function()
		-- Toggle Off
		if spectatingPlayer == player then
			spectatingPlayer = nil
			specIcon.Image = ASSET_EYE
			camera.CameraSubject = lp.Character and lp.Character:FindFirstChild("Humanoid")
		else
			-- Toggle On
			spectatingPlayer = player
			specIcon.Image = ASSET_HIDDEN_EYE
			local targetHum = player.Character and player.Character:FindFirstChild("Humanoid")
			if targetHum then camera.CameraSubject = targetHum end
			
			-- Reset others visually
			for _, child in ipairs(scroll:GetChildren()) do
				if child:IsA("Frame") and child.Name ~= player.Name then
					local oSpec = child:FindFirstChild("Actions") and child.Actions:FindFirstChild("Spectate")
					if oSpec then oSpec:FindFirstChildWhichIsA("ImageLabel").Image = ASSET_EYE end
				end
			end
		end
	end)

	-- 2. Teleport Button (Glowing White Text)
	local btnTP = makeBtn("TP", 32)
	local tpText = Instance.new("TextLabel", btnTP)
	tpText.Size = UDim2.new(1, 0, 1, 0)
	tpText.BackgroundTransparency = 1
	tpText.Text = "TP"
	tpText.Font = Enum.Font.GothamBold
	tpText.TextSize = 13
	tpText.TextColor3 = Color3.fromRGB(255, 255, 255)
	
	-- Glow Effect on Text
	local glow = Instance.new("UIStroke", tpText)
	glow.Color = Color3.fromRGB(255, 255, 255)
	glow.Transparency = 0.4
	glow.Thickness = 1
	glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	bindTooltip(btnTP, "Teleport to Player")

	btnTP.MouseButton1Click:Connect(function()
		local myChar = lp.Character
		local tChar = player.Character
		if myChar and tChar and myChar:FindFirstChild("HumanoidRootPart") and tChar:FindFirstChild("HumanoidRootPart") then
			myChar.HumanoidRootPart.CFrame = tChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
		end
	end)

	return card
end

-- Refresh logic keeps the list constantly updated
local function refreshPlayerList()
	updatePlayerCount()
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	for _, p in ipairs(players:GetPlayers()) do
		if p ~= lp then
			createPlayerCard(p).Parent = scroll
		end
	end
end

-- Connections
players.PlayerAdded:Connect(refreshPlayerList)
players.PlayerRemoving:Connect(function(p)
	if spectatingPlayer == p then 
		spectatingPlayer = nil 
		camera.CameraSubject = lp.Character and lp.Character:FindFirstChild("Humanoid")
	end
	refreshPlayerList()
end)

-- Initial Load
refreshPlayerList()
