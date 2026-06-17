local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")


local lp = Players.LocalPlayer
local gui = lp:WaitForChild("PlayerGui")


local old = gui:FindFirstChild("Rikusu_Badge")
if old then old:Destroy() end


local C = {
    PANEL  = Color3.fromRGB(10, 12, 22),
    CARD   = Color3.fromRGB(16, 20, 40),
    STROKE = Color3.fromRGB(60, 75, 130),
    ACCENT = Color3.fromRGB(90, 175, 255),
    ACCENT2= Color3.fromRGB(145, 90, 255),
    TEXT   = Color3.fromRGB(225, 235, 255),
    SUB    = Color3.fromRGB(155, 170, 215),
    ON     = Color3.fromRGB(50, 210, 120),
    ASH1   = Color3.fromRGB(185, 190, 200),
    ASH2   = Color3.fromRGB(48, 92, 222),
    ASH3   = Color3.fromRGB(255, 28, 28),
    BTN    = Color3.fromRGB(22, 30, 58),
    BTN_HV = Color3.fromRGB(35, 48, 90),
}


local function tw(obj, ti, goals)
    if obj and obj.Parent then
        TweenService:Create(obj, ti, goals):Play()
    end
end


local E = Enum.EasingStyle
local D = Enum.EasingDirection


local TI = {
    SlideIn  = TweenInfo.new(0.55, E.Quint, D.Out),
    SlideOut = TweenInfo.new(0.40, E.Quint, D.In),
    Fade     = TweenInfo.new(0.28, E.Sine,  D.Out),
    Reveal   = TweenInfo.new(0.30, E.Quint, D.Out),
    Pulse    = TweenInfo.new(1.75, E.Sine,  D.InOut, -1, true),
    Border   = TweenInfo.new(2.8,  E.Sine,  D.InOut, -1, true),
    Hover    = TweenInfo.new(0.15, E.Sine,  D.Out),
}


local sg = Instance.new("ScreenGui")
sg.Name = "Rikusu_Badge"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
    sg.DisplayOrder = 999
end)
sg.Parent = (rawget(_G, "gethui") and gethui()) or gui


local function vp()
    local cam = workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(1920, 1080)
end


local BW, BH = 340, 98
local PAD_R, PAD_B = 20, 20
local THUMB_X, THUMB_Y, THUMB_S = 12, 12, 56
local TEXT_X = THUMB_X + THUMB_S + 12
local RIGHT_PAD = 12


local function restPos()
    local v = vp()
    return UDim2.new(0, v.X - BW - PAD_R, 0, v.Y - BH - PAD_B)
end
local function offRight()
    local v = vp()
    return UDim2.new(0, v.X + BW + 60, 0, v.Y - BH - PAD_B)
end
local function offDown()
    local v = vp()
    return UDim2.new(0, v.X - BW - PAD_R, 0, v.Y + BH + 40)
end


local card = Instance.new("Frame")
card.Name = "Badge"
card.Size = UDim2.new(0, BW, 0, BH)
card.Position = offRight()
card.BackgroundColor3 = C.PANEL
card.BackgroundTransparency = 0.08
card.BorderSizePixel = 0
card.ClipsDescendants = true
card.ZIndex = 10
card.Parent = sg
Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)


local borderStroke = Instance.new("UIStroke")
borderStroke.Color = C.STROKE
borderStroke.Thickness = 1
borderStroke.Transparency = 0.38
borderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
borderStroke.Parent = card


local thumbFrame = Instance.new("Frame")
thumbFrame.Size = UDim2.new(0, THUMB_S, 0, THUMB_S)
thumbFrame.Position = UDim2.new(0, THUMB_X, 0, THUMB_Y)
thumbFrame.BackgroundColor3 = C.CARD
thumbFrame.BackgroundTransparency = 0.15
thumbFrame.BorderSizePixel = 0
thumbFrame.ZIndex = 19
thumbFrame.Parent = card
Instance.new("UICorner", thumbFrame).CornerRadius = UDim.new(0, 8)


local thumbStroke = Instance.new("UIStroke")
thumbStroke.Color = C.STROKE
thumbStroke.Thickness = 1
thumbStroke.Transparency = 0.45
thumbStroke.Parent = thumbFrame


local thumbImg = Instance.new("ImageLabel")
thumbImg.Size = UDim2.new(1, 0, 1, 0)
thumbImg.BackgroundTransparency = 1
thumbImg.Image = "https://www.roblox.com/asset-thumbnail/image?assetId=" .. tostring(game.PlaceId) .. "&width=150&height=150&format=png"
thumbImg.ScaleType = Enum.ScaleType.Crop
thumbImg.ImageTransparency = 1
thumbImg.ZIndex = 20
thumbImg.Parent = thumbFrame
Instance.new("UICorner", thumbImg).CornerRadius = UDim.new(0, 8)


local icon = Instance.new("TextLabel")
icon.Size = UDim2.new(0, 20, 0, 22)
icon.Position = UDim2.new(0, TEXT_X, 0, 13)
icon.BackgroundTransparency = 1
icon.Text = "リクス"
icon.Font = Enum.Font.GothamBold
icon.TextSize = 15
icon.TextColor3 = C.ACCENT
icon.TextTransparency = 1
icon.ZIndex = 20
icon.Parent = card


local USER_SIZE = 25


local userFrame = Instance.new("Frame")
userFrame.Size = UDim2.new(0, USER_SIZE, 0, 82)
userFrame.Position = UDim2.new(1, -USER_SIZE - 30, 0, 8)
userFrame.BackgroundTransparency = 1
userFrame.ZIndex = 20
userFrame.Parent = card


local avatarHolder = Instance.new("Frame")
avatarHolder.Size = UDim2.new(0, USER_SIZE, 0, USER_SIZE)
avatarHolder.BackgroundColor3 = C.CARD
avatarHolder.BackgroundTransparency = 0.1
avatarHolder.BorderSizePixel = 0
avatarHolder.ZIndex = 20
avatarHolder.Parent = userFrame
Instance.new("UICorner", avatarHolder).CornerRadius = UDim.new(0, 10)

local avatar = Instance.new("ImageLabel")
avatar.Size = UDim2.new(1, 0, 1, 0)
avatar.BackgroundTransparency = 1
avatar.ScaleType = Enum.ScaleType.Crop
avatar.ImageTransparency = 1
avatar.ZIndex = 21
avatar.Parent = avatarHolder
Instance.new("UICorner", avatar).CornerRadius = UDim.new(0, 10)


-- FIXED: GetUserThumbnailAsync is synchronous, wrap in pcall directly
local success, thumbUrl = pcall(function()
    return Players:GetUserThumbnailAsync(
        lp.UserId,
        Enum.ThumbnailType.HeadShot,
        Enum.ThumbnailSize.Size420x420
    )
end)

if success and thumbUrl then
    avatar.Image = thumbUrl
else
    -- Fallback to default avatar if thumbnail fails
    avatar.Image = "https://tr.rbxcdn.com/c18d9c4944d4955d825e0d6f86a96e37/420/420/Avatar/Png"
end


local displayLbl = Instance.new("TextLabel")
displayLbl.Size = UDim2.new(0, 100, 0, 14)
displayLbl.Position = UDim2.new(0.5, -50, 0, USER_SIZE + 2)
displayLbl.BackgroundTransparency = 1
displayLbl.Text = lp.DisplayName
displayLbl.Font = Enum.Font.GothamBold
displayLbl.TextSize = 10
displayLbl.TextColor3 = C.ACCENT
displayLbl.TextTransparency = 1
displayLbl.TextXAlignment = Enum.TextXAlignment.Center
displayLbl.ZIndex = 21
displayLbl.Parent = userFrame


local usernameLbl = Instance.new("TextLabel")
usernameLbl.Size = UDim2.new(0, 100, 0, 12)
usernameLbl.Position = UDim2.new(0.5, -50, 0, USER_SIZE + 15)
usernameLbl.BackgroundTransparency = 1
usernameLbl.Text = "@" .. lp.Name
usernameLbl.Font = Enum.Font.GothamMedium
usernameLbl.TextSize = 9
usernameLbl.TextColor3 = C.SUB
usernameLbl.TextTransparency = 1
usernameLbl.TextXAlignment = Enum.TextXAlignment.Center
usernameLbl.ZIndex = 21
usernameLbl.Parent = userFrame


local subLbl = Instance.new("TextLabel")
subLbl.Size = UDim2.new(1, -TEXT_X - RIGHT_PAD, 0, 16)
subLbl.Position = UDim2.new(0, TEXT_X, 0, 38)
subLbl.BackgroundTransparency = 1
subLbl.Text = "INJECTED — Enjoy"
subLbl.Font = Enum.Font.GothamSemibold
subLbl.TextSize = 11
subLbl.TextColor3 = C.SUB
subLbl.TextTransparency = 1
subLbl.TextXAlignment = Enum.TextXAlignment.Left
subLbl.ZIndex = 20
subLbl.Parent = card


local onlineY = 67


local dotHalo = Instance.new("Frame")
dotHalo.Size = UDim2.new(0, 14, 0, 14)
dotHalo.Position = UDim2.new(0, TEXT_X, 0, onlineY - 1)
dotHalo.BackgroundColor3 = C.ON
dotHalo.BackgroundTransparency = 0.72
dotHalo.BorderSizePixel = 0
dotHalo.ZIndex = 19
dotHalo.Parent = card
Instance.new("UICorner", dotHalo).CornerRadius = UDim.new(1, 0)


local dotCore = Instance.new("Frame")
dotCore.Size = UDim2.new(0, 7, 0, 7)
dotCore.Position = UDim2.new(0, TEXT_X + 3.5, 0, onlineY + 3.5)
dotCore.BackgroundColor3 = C.ON
dotCore.BackgroundTransparency = 0
dotCore.BorderSizePixel = 0
dotCore.ZIndex = 20
dotCore.Parent = card
Instance.new("UICorner", dotCore).CornerRadius = UDim.new(1, 0)


local onlineLbl = Instance.new("TextLabel")
onlineLbl.Size = UDim2.new(0, 50, 0, 14)
onlineLbl.Position = UDim2.new(0, TEXT_X + 18, 0, onlineY)
onlineLbl.BackgroundTransparency = 1
onlineLbl.Text = "Ready To Execute"
onlineLbl.Font = Enum.Font.GothamSemibold
onlineLbl.TextSize = 10
onlineLbl.TextColor3 = C.ON
onlineLbl.TextTransparency = 1
onlineLbl.TextXAlignment = Enum.TextXAlignment.Left
onlineLbl.ZIndex = 20
onlineLbl.Parent = card


local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0, 100, 0, 22)
copyBtn.Position = UDim2.new(1, -95 - RIGHT_PAD, 0, onlineY - 2)
copyBtn.BackgroundColor3 = C.BTN
copyBtn.BackgroundTransparency = 0.05
copyBtn.BorderSizePixel = 0
copyBtn.Text = "Copy"
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 10
copyBtn.TextColor3 = C.ACCENT
copyBtn.TextTransparency = 1
copyBtn.ZIndex = 22
copyBtn.AutoButtonColor = false
copyBtn.Parent = card
Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)


local copyStroke = Instance.new("UIStroke")
copyStroke.Color = C.ACCENT
copyStroke.Thickness = 1
copyStroke.Transparency = 0.55
copyStroke.Parent = copyBtn


local feedbackLbl = Instance.new("TextLabel")
feedbackLbl.Size = UDim2.new(1, 0, 1, 0)
feedbackLbl.BackgroundTransparency = 1
feedbackLbl.Text = "✓  Copied!"
feedbackLbl.Font = Enum.Font.GothamBold
feedbackLbl.TextSize = 10
feedbackLbl.TextColor3 = C.ON
feedbackLbl.TextTransparency = 1
feedbackLbl.Visible = false
feedbackLbl.ZIndex = 23
feedbackLbl.Parent = copyBtn


local copyDebounce = false
copyBtn.MouseButton1Click:Connect(function()
    if copyDebounce then return end
    copyDebounce = true
    local scriptText = string.format(
        'game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game.Players.LocalPlayer)',
        game.PlaceId, game.JobId
    )
    pcall(setclipboard, scriptText)
    copyBtn.Text = ""
    feedbackLbl.Visible = true
    tw(feedbackLbl, TI.Reveal, { TextTransparency = 0 })
    tw(copyBtn, TI.Reveal, { BackgroundColor3 = Color3.fromRGB(18, 48, 32) })
    copyStroke.Color = C.ON
    task.wait(1.6)
    tw(feedbackLbl, TI.Fade, { TextTransparency = 1 })
    task.wait(0.28)
    feedbackLbl.Visible = false
    copyBtn.Text = "Copy"
    tw(copyBtn, TI.Reveal, { BackgroundColor3 = C.BTN, TextTransparency = 0 })
    copyStroke.Color = C.ACCENT
    copyDebounce = false
end)


copyBtn.MouseEnter:Connect(function()
    if not copyDebounce then tw(copyBtn, TI.Hover, { BackgroundColor3 = C.BTN_HV }) end
end)
copyBtn.MouseLeave:Connect(function()
    if not copyDebounce then tw(copyBtn, TI.Hover, { BackgroundColor3 = C.BTN }) end
end)


local ashParticles = {}
for i = 1, 20 do
    local p = Instance.new("Frame")
    p.AnchorPoint = Vector2.new(0.5, 0.5)
    p.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
    p.BackgroundColor3 = C.ASH2
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ZIndex = 12
    p.Parent = card
    Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
    ashParticles[i] = {
        obj = p,
        startX = math.random(8, 92) / 100,
        startY = math.random(30, 90) / 100,
        drift = math.random(-14, 14) / 100,
        rise = math.random(18, 30) / 100,
        speed = math.random(12, 22) / 10,
        phase = math.random() * math.pi * 2,
        delay = math.random() * 1.8,
    }
end


local water = Instance.new("Frame")
water.Size = UDim2.new(1, 0, 0.32, 0)
water.Position = UDim2.new(0, 0, 0.68, 0)
water.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
water.BackgroundTransparency = 0.78
water.BorderSizePixel = 0
water.ZIndex = 11
water.Parent = card


local waterGrad = Instance.new("UIGradient")
waterGrad.Rotation = 90
waterGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 42, 70)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 12, 22)),
})
waterGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.80),
    NumberSequenceKeypoint.new(1, 0.55),
})
waterGrad.Parent = water


local reflection = Instance.new("Frame")
reflection.Size = UDim2.new(1, 0, 0.32, 0)
reflection.Position = UDim2.new(0, 0, 0.68, 1)
reflection.BackgroundColor3 = Color3.fromRGB(60, 70, 95)
reflection.BackgroundTransparency = 0.93
reflection.BorderSizePixel = 0
reflection.ZIndex = 11
reflection.Parent = card
Instance.new("UICorner", reflection).CornerRadius = UDim.new(0, 14)


local refGrad = Instance.new("UIGradient")
refGrad.Rotation = 90
refGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 130, 170)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 24, 34)),
})
refGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.92),
    NumberSequenceKeypoint.new(1, 1),
})
refGrad.Parent = reflection


local conns = {}


local function startAmbient()
    local t0 = tick()
    conns[#conns + 1] = RunService.Heartbeat:Connect(function()
        local t = tick() - t0
        for _, a in ipairs(ashParticles) do
            local p = a.obj
            local life = ((t + a.delay) % 3.2) / 3.2
            local rise = math.sin(life * math.pi)
            local x = a.startX + math.sin(t * a.speed + a.phase) * 0.015 + a.drift * life
            local y = a.startY - a.rise * life
            local fade
            if life < 0.12 then
                fade = 1 - (life / 0.12)
            elseif life > 0.82 then
                fade = (life - 0.82) / 0.18
            else
                fade = 0.08
            end
            local tint = 1 - rise * 0.35
            p.Position = UDim2.new(x, 0, y, 0)
            p.BackgroundColor3 = Color3.new(
                math.clamp(C.ASH1.R * tint + C.ASH3.R * (1 - tint), 0, 1),
                math.clamp(C.ASH1.G * tint + C.ASH3.G * (1 - tint), 0, 1),
                math.clamp(C.ASH1.B * tint + C.ASH3.B * (1 - tint), 0, 1)
            )
            p.BackgroundTransparency = math.clamp(fade + 0.06, 0, 1)
        end
        water.BackgroundTransparency = 0.78 + math.sin(t * 1.8) * 0.03
        reflection.BackgroundTransparency = 0.94 + math.sin(t * 2.1) * 0.015
        refGrad.Rotation = 90 + math.sin(t * 0.7) * 2
    end)


    tw(borderStroke, TI.Border, { Transparency = 0.72 })
    tw(dotHalo, TI.Pulse, {
        BackgroundTransparency = 0.88,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, TEXT_X - 1, 0, onlineY - 2),
    })
end


local function stopAmbient()
    for _, c in ipairs(conns) do
        c:Disconnect()
    end
    table.clear(conns)
end


task.spawn(function()
    task.wait(0.15)
    card.Position = offRight()
    tw(card, TI.SlideIn, { Position = restPos() })
    task.wait(0.26)


    tw(thumbImg, TI.Reveal, { ImageTransparency = 0 })
    tw(icon, TI.Reveal, { TextTransparency = 0 })
    tw(displayLbl, TI.Reveal, { TextTransparency = 0 })
    tw(avatar, TI.Reveal, { ImageTransparency = 0 })
    task.wait(0.08)
    tw(usernameLbl, TI.Reveal, { TextTransparency = 0 })
    tw(onlineLbl, TI.Reveal, { TextTransparency = 0 })
    tw(copyBtn, TI.Reveal, { TextTransparency = 0 })


    startAmbient()
    task.wait(6)
    stopAmbient()


    local FO = TI.Fade
    local fadeTargets = { displayLbl, usernameLbl, icon, onlineLbl, copyBtn, thumbImg, dotCore, dotHalo, avatar }
    for _, obj in ipairs(fadeTargets) do
        local prop = (obj:IsA("TextLabel") or obj:IsA("TextButton")) and "TextTransparency"
            or (obj == thumbImg or obj == avatar) and "ImageTransparency"
            or "BackgroundTransparency"
        tw(obj, FO, { [prop] = 1 })
    end
    tw(borderStroke, FO, { Transparency = 1 })
    tw(water, FO, { BackgroundTransparency = 1 })
    tw(reflection, FO, { BackgroundTransparency = 1 })


    for _, a in ipairs(ashParticles) do
        tw(a.obj, FO, { BackgroundTransparency = 1 })
    end


    task.wait(0.10)
    tw(card, TI.SlideOut, { Position = offDown() })
    task.wait(0.45)


    pcall(function()
        sg:Destroy()
    end)
end)
