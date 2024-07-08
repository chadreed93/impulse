--- Surface functions that aid in minimizing boilerplate but maintaining high performance.
-- @module Surface

impulse.Surface = impulse.Surface or {}
impulse.Surface.Data = impulse.Surface.Data or {}

--- Defines a typeface's properties in handling text shadow.
-- @realm client
-- @string fontFace The font.
-- @int[opt=2] offsetx The offset that the drop shadow will be.
-- @int[opt=2] offsety The offset that the drop shadow will be.
-- @int[opt=255] alpha The alpha of the shadow, recommended to keep at 255.
function impulse.Surface.DefineTypeFace(fontFace, offsetx, offsety, alpha)

	MsgC(impulse.Prefix("Surface"), "Registering typeface: ", Color(255, 150, 0), fontFace,"\n")

	offsetx = offsetx or 2
	offsety = offsety or 2
	alpha = alpha or 255

	impulse.Surface.Data[fontFace] = {
		oX = offsetx,
		oY = offsety,
		fO = alpha
	}

end

--- Determines enumerations that aid in easily scaled UI
-- @realm client
-- @field LowRes
-- @field FullRes
-- @field HighRes
-- @table ScreenScale

impulse.Surface.LowRes = 1
impulse.Surface.FullRes = 2
impulse.Surface.HighRes = 3

--- Gets the current screen scale.
-- @realm client
-- @treturn ScreenScale The current screen scale.
function impulse.Surface.GetScreen()

	local w, h = ScrW(), ScrH()

	if w <= 1440 then
		return impulse.Surface.LowRes
	elseif w <= 2560 then
		return impulse.Surface.FullRes
	else
		return impulse.Surface.HighRes
	end

end

--- Scales between the three values to the screenscale.
-- @realm client
-- @param low
-- @param mid
-- @param high
-- @treturn any The scaled value.
function impulse.Surface.ScreenScale(low, mid, high)
	local t = {low, mid, high}
	return (t[impulse.Surface.GetScreen()])
end

local surface=surface

--- Draws text with a high quality shadow effect.
-- @realm client
-- @string text
-- @string font
-- @int x
-- @int y
-- @color color
-- @int alignX
-- @int alignY
-- @treturn int The text width.
function impulse.Surface.DrawText(text, font, x, y, color, alignX, alignY)

	local typeface = impulse.Surface.Data[font]

	surface.SetFont(font)
	local w, h = surface.GetTextSize(text)

	if alignX == TEXT_ALIGN_RIGHT then
		x = x - w
	elseif alignX == TEXT_ALIGN_CENTER then
		x = x - (w/2)
	end

	if alignY == TEXT_ALIGN_BOTTOM then
		y = y - h
	elseif alignY == TEXT_ALIGN_CENTER then
		y = y - (h/2)
	end

	surface.SetFont(font .. "-Blurred")
	surface.SetTextPos(x + typeface["oX"], y + typeface["oY"])
	surface.SetTextColor(ColorAlpha(color_black, typeface["fO"]))
	surface.DrawText(text)

	surface.SetFont(font)
	surface.SetTextPos(x, y)
	surface.SetTextColor(color)
	surface.DrawText(text)

	return w, h

end

--- Fields for Derma_Query
-- @realm client
-- @field text
-- @func onpress
-- @table QueryButton

--- A better Derma_Query. Unlike your standard Derma_Query, this
-- Can handle as many buttons as you want, see QueryButton table
-- for required fields. 
-- @realm client
-- @string title
-- @string body
-- @tab buttons
function impulse.Surface.Query(title, body, buttons)

	local m_fStartTime = UnPredictedCurTime()
	local m_dMessage = vgui.Create("DPanel", nil, "impulseSurfaceQuery")
	m_dMessage:SetSize(ScrW(), ScrH())
	m_dMessage:MakePopup()

	local m_dMarkupMain = markup.Parse("<font=Impulse-LightUI20><color=255,255,255>" .. body .. "</color></font>", math.max(ScrW() * .3, 400))
	local m_dMarkupBlur = markup.Parse("<font=Impulse-LightUI20-Blurred><color=0,0,0>" .. body .. "</color></font>", math.max(ScrW() * .3, 400))

	m_dMessage.Paint = function(m_dPanel, m_iWidth, m_iHeight)
		Derma_DrawBackgroundBlur(m_dPanel, m_fStartTime)

		impulse.Surface.DrawText(
			title or "impulse",
			"Impulse-LightUI64",
			m_iWidth / 2 - (m_iWidth / 6),
			m_iHeight / 2 - 64,
			color_white,
			TEXT_ALIGN_LEFT,
			TEXT_ALIGN_CENTER
		)

		m_dMarkupBlur:Draw(m_iWidth / 2 - (m_iWidth / 6) + 2, m_iHeight / 2 + 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		m_dMarkupMain:Draw(m_iWidth / 2 - (m_iWidth / 6), m_iHeight / 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	local x = ScrW() / 2 - (ScrW() / 6)

	for _, button in ipairs(buttons) do
		local m_dButton = vgui.Create("DButton", m_dMessage, "m_dButton")
		m_dButton:SetFont("Impulse-LightUI32")
		m_dButton:SetText(button.text)
		m_dButton:SizeToContentsX(32)
		m_dButton:SizeToContentsY(32)
		m_dButton:SetX(x)
		m_dButton:CenterVertical(0.7)
		m_dButton:SetText("") -- we dont draw w/ this

		x = x + 32 + m_dButton:GetWide()

		local cFr = 0
		m_dButton.Paint = function(m_dPanel, m_iWidth, m_iHeight)

			if (m_dPanel:IsHovered()) then
				cFr = math.Approach(cFr, 1, FrameTime() * 8)
			else
				cFr = math.Approach(cFr, 0, FrameTime() * 8)
			end

			surface.SetDrawColor(255, 58, 48)
			surface.DrawOutlinedRect(0, 0, m_iWidth, m_iHeight, 3)
			surface.DrawRect(0, m_iHeight - (cFr * m_iHeight), m_iWidth, m_iHeight )

			impulse.Surface.DrawText(
				button.text,
				"Impulse-LightUI32",
				m_iWidth / 2,
				m_iHeight / 2,
				color_white,
				TEXT_ALIGN_CENTER,
				TEXT_ALIGN_CENTER
			)

		end

		m_dButton.DoClick = function()

			pcall(function() button.onpress(m_dMessage, m_dButton) end)
			m_dMessage:Remove()
		end
	end

	return m_dMessage

end

--- A better Derma_Message. Returned panel can access the close button with PANEL.m_dCloseBtn.
-- @realm client
-- @string title
-- @string body
-- @string closeButtonText
-- @treturn Panel The message panel.
function impulse.Surface.Message(title, body, closeButtonText)

	local m_fStartTime = UnPredictedCurTime()
	local m_dMessage = vgui.Create("DPanel", nil, "impulseSurfaceQuery")
	m_dMessage:SetSize(ScrW(), ScrH())
	m_dMessage:MakePopup()

	local m_dMarkupMain = markup.Parse("<font=Impulse-LightUI20><color=255,255,255>" .. body .. "</color></font>", math.max(ScrW() * .3, 400))
	local m_dMarkupBlur = markup.Parse("<font=Impulse-LightUI20-Blurred><color=0,0,0>" .. body .. "</color></font>", math.max(ScrW() * .3, 400))

	m_dMessage.Paint = function(m_dPanel, m_iWidth, m_iHeight)
		Derma_DrawBackgroundBlur(m_dPanel, m_fStartTime)

		impulse.Surface.DrawText(
			title or "impulse",
			"Impulse-LightUI64",
			m_iWidth / 2 - (m_iWidth / 6),
			m_iHeight / 2 - 64,
			color_white,
			TEXT_ALIGN_LEFT,
			TEXT_ALIGN_CENTER
		)

		m_dMarkupBlur:Draw(m_iWidth / 2 - (m_iWidth / 6) + 2, m_iHeight / 2 + 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		m_dMarkupMain:Draw(m_iWidth / 2 - (m_iWidth / 6), m_iHeight / 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	local m_dCloseBtn = vgui.Create("DButton", m_dMessage, "closeButton")
	m_dCloseBtn:SetFont("Impulse-LightUI32")
	m_dCloseBtn:SetText(closeButtonText or "Close")
	m_dCloseBtn:SizeToContentsX(32)
	m_dCloseBtn:SizeToContentsY(32)
	m_dCloseBtn:CenterHorizontal(0.5)
	m_dCloseBtn:CenterVertical(0.7)
	m_dCloseBtn:SetText("") -- we dont draw w/ this
	local cFr = 0
	m_dCloseBtn.Paint = function(m_dPanel, m_iWidth, m_iHeight)

		if (m_dPanel:IsHovered()) then
			cFr = math.Approach(cFr, 1, FrameTime() * 8)
		else
			cFr = math.Approach(cFr, 0, FrameTime() * 8)
		end

		surface.SetDrawColor(255, 58, 48)
		surface.DrawOutlinedRect(0, 0, m_iWidth, m_iHeight, 3)
		surface.DrawRect(0, m_iHeight - (cFr * m_iHeight), m_iWidth, m_iHeight )

		impulse.Surface.DrawText(
			closeButtonText or "Close",
			"Impulse-LightUI32",
			m_iWidth / 2,
			m_iHeight / 2,
			color_white,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)

	end

	m_dCloseBtn.DoClick = function()
		m_dMessage:Remove()
	end

	m_dMessage.m_dCloseBtn = m_dCloseBtn

	return m_dMessage

end

--- Allows the user to enter a string.
-- @realm client
-- @string title
-- @string body
-- @string placeholder
-- @string submittext
-- @func callback
-- @bool showclosebutton
-- @treturn Panel The message panel.
function impulse.Surface.StringRequest(title, body, placeholder, submittext, callback, showclosebutton)
	local m_fStartTime = UnPredictedCurTime()
	local m_dMessage = vgui.Create("EditablePanel", nil, "impulseSurfaceQuery")
	m_dMessage:SetSize(ScrW(), ScrH())
	

	local m_dMarkupMain = markup.Parse("<font=Impulse-LightUI20><color=255,255,255>" .. body .. "</color></font>", math.max(ScrW() * .3, 400))
	local m_dMarkupBlur = markup.Parse("<font=Impulse-LightUI20-Blurred><color=0,0,0>" .. body .. "</color></font>", math.max(ScrW() * .3, 400))

	m_dMessage.Paint = function(m_dPanel, m_iWidth, m_iHeight)
		Derma_DrawBackgroundBlur(m_dPanel, m_fStartTime)

		impulse.Surface.DrawText(
			title or "impulse",
			"Impulse-LightUI64",
			m_iWidth / 2 - (m_iWidth / 6),
			m_iHeight / 2 - 64,
			color_white,
			TEXT_ALIGN_LEFT,
			TEXT_ALIGN_CENTER
		)

		m_dMarkupBlur:Draw(m_iWidth / 2 - (m_iWidth / 6) + 2, m_iHeight / 2 + 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		m_dMarkupMain:Draw(m_iWidth / 2 - (m_iWidth / 6), m_iHeight / 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	local x = ScrW() / 2 - (ScrW() / 6)

	local m_dTextInput = vgui.Create("DTextEntry", m_dMessage, "textent")
	m_dTextInput:SetFont("Impulse-LightUI32")
	m_dTextInput:SetPlaceholderText(placeholder or "")
	m_dTextInput:SetWide(ScrW() / 3)
	m_dTextInput:SetTall(44)
	m_dTextInput:CenterHorizontal(0.5)
	m_dTextInput:CenterVertical(0.7)

	local m_dEnterBtn = vgui.Create("DButton", m_dMessage, "SUBMIT")
	m_dEnterBtn:SetFont("Impulse-LightUI32")
	m_dEnterBtn:SetText("Submit")
	m_dEnterBtn:SizeToContentsX(32)
	m_dEnterBtn:SizeToContentsY(32)
	m_dEnterBtn:SetX(x)
	m_dEnterBtn:CenterVertical(0.8)
	m_dEnterBtn:SetText("") -- we dont draw w/ this
	local cFr = 0
	m_dEnterBtn.Paint = function(m_dPanel, m_iWidth, m_iHeight)

		if (m_dPanel:IsHovered()) then
			cFr = math.Approach(cFr, 1, FrameTime() * 8)
		else
			cFr = math.Approach(cFr, 0, FrameTime() * 8)
		end

		surface.SetDrawColor(255, 58, 48)
		surface.DrawOutlinedRect(0, 0, m_iWidth, m_iHeight, 3)
		surface.DrawRect(0, m_iHeight - (cFr * m_iHeight), m_iWidth, m_iHeight )

		impulse.Surface.DrawText(
			"Submit",
			"Impulse-LightUI32",
			m_iWidth / 2,
			m_iHeight / 2,
			color_white,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)

	end

	m_dEnterBtn.DoClick = function()
		callback(m_dTextInput:GetValue())
		m_dMessage:Remove()
	end

	x = x + m_dEnterBtn:GetWide() + 16

	local m_dCloseBtn = vgui.Create("DButton", m_dMessage, "closeButton")
	m_dCloseBtn:SetFont("Impulse-LightUI32")
	m_dCloseBtn:SetText("Close")
	m_dCloseBtn:SizeToContentsX(32)
	m_dCloseBtn:SizeToContentsY(32)
	m_dCloseBtn:SetX(x)
	m_dCloseBtn:CenterVertical(0.8)
	m_dCloseBtn:SetText("") -- we dont draw w/ this
	local cFr = 0
	m_dCloseBtn.Paint = function(m_dPanel, m_iWidth, m_iHeight)

		if (m_dPanel:IsHovered()) then
			cFr = math.Approach(cFr, 1, FrameTime() * 8)
		else
			cFr = math.Approach(cFr, 0, FrameTime() * 8)
		end

		surface.SetDrawColor(255, 58, 48)
		surface.DrawOutlinedRect(0, 0, m_iWidth, m_iHeight, 3)
		surface.DrawRect(0, m_iHeight - (cFr * m_iHeight), m_iWidth, m_iHeight )

		impulse.Surface.DrawText(
			"Close",
			"Impulse-LightUI32",
			m_iWidth / 2,
			m_iHeight / 2,
			color_white,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)

	end

	m_dCloseBtn.DoClick = function()
		m_dMessage:Remove()
	end
	m_dMessage:MakePopup()
	return m_dMessage
end


sound.Add({
	name = "impulse.Rollover",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 75,
	pitch = {100, 100},
	sound = "impulse/pano_ui_rollover_01.wav"
})

sound.Add({
	name = "impulse.LongAffirm",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 75,
	pitch = {100, 100},
	sound = "impulse/pano_ui_affirm_lg_01.wav"
})

sound.Add({
	name = "impulse.Submenu",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 75,
	pitch = {100, 100},
	sound = "impulse/pano_ui_sub_menu_01.wav"
})
sound.Add({
	name = "impulse.Close",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 75,
	pitch = {100, 100},
	sound = "impulse/pano_ui_menu_close_01.wav"
})

--- Plays a roll over sound
-- @realm client
function impulse.Surface.Rollover()
	surface.PlaySound("impulse/pano_ui_rollover_01.wav")
end

--- Plays a long affirm sound
-- @realm client
function impulse.Surface.LongAffirm()
	surface.PlaySound("impulse/pano_ui_affirm_lg_01.wav")
end

--- Plays a submenu sound
-- @realm client
function impulse.Surface.Submenu()
	surface.PlaySound("impulse/pano_ui_sub_menu_01.wav")
end

--- Plays a close sound
-- @realm client
function impulse.Surface.Close()
	surface.PlaySound("impulse/pano_ui_menu_close_01.wav")
end


--- Surface functions that aid in minimizing boilerplate but maintaining high performance.
-- @module Surface

impulse.Surface = impulse.Surface or {}
impulse.Surface.Data = impulse.Surface.Data or {}

--- Defines a typeface's properties in handling text shadow.
-- @realm client
-- @string fontFace The font.
-- @int[opt=2] offsetx The offset that the drop shadow will be.
-- @int[opt=2] offsety The offset that the drop shadow will be.
-- @int[opt=255] alpha The alpha of the shadow, recommended to keep at 255.
function impulse.Surface.DefineTypeFace(fontFace, offsetx, offsety, alpha)

	MsgC(impulse.Prefix("Surface"), "Registering typeface: ", Color(255, 150, 0), fontFace,"\n")

	offsetx = offsetx or 2
	offsety = offsety or 2
	alpha = alpha or 255

	impulse.Surface.Data[fontFace] = {
		oX = offsetx,
		oY = offsety,
		fO = alpha
	}

end

--- Determines enumerations that aid in easily scaled UI
-- @realm client
-- @field LowRes
-- @field FullRes
-- @field HighRes
-- @table ScreenScale

impulse.Surface.LowRes = 1
impulse.Surface.FullRes = 2
impulse.Surface.HighRes = 3

--- Gets the current screen scale.
-- @realm client
-- @treturn ScreenScale The current screen scale.
function impulse.Surface.GetScreen()

	local w, h = ScrW(), ScrH()

	if w <= 1440 then
		return impulse.Surface.LowRes
	elseif w <= 2560 then
		return impulse.Surface.FullRes
	else
		return impulse.Surface.HighRes
	end

end

--- Scales between the three values to the screenscale.
-- @realm client
-- @param low
-- @param mid
-- @param high
-- @treturn any The scaled value.
function impulse.Surface.ScreenScale(low, mid, high)
	local t = {low, mid, high}
	return (t[impulse.Surface.GetScreen()])
end

local surface=surface

--- Draws text with a high quality shadow effect.
-- @realm client
-- @string text
-- @string font
-- @int x
-- @int y
-- @color color
-- @int alignX
-- @int alignY
-- @treturn int The text width.
function impulse.Surface.DrawText(text, font, x, y, color, alignX, alignY)

	local typeface = impulse.Surface.Data[font]

	surface.SetFont(font)
	local w, h = surface.GetTextSize(text)

	if alignX == TEXT_ALIGN_RIGHT then
		x = x - w
	elseif alignX == TEXT_ALIGN_CENTER then
		x = x - (w/2)
	end

	if alignY == TEXT_ALIGN_BOTTOM then
		y = y - h
	elseif alignY == TEXT_ALIGN_CENTER then
		y = y - (h/2)
	end

	surface.SetFont(font .. "-Blurred")
	surface.SetTextPos(x + typeface["oX"], y + typeface["oY"])
	surface.SetTextColor(ColorAlpha(color_black, typeface["fO"]))
	surface.DrawText(text)

	surface.SetFont(font)
	surface.SetTextPos(x, y)
	surface.SetTextColor(color)
	surface.DrawText(text)

	return w, h

end

--- Fields for Derma_Query
-- @realm client
-- @field text
-- @func onpress
-- @table QueryButton

--- A better Derma_Query. Unlike your standard Derma_Query, this
-- Can handle as many buttons as you want, see QueryButton table
-- for required fields. 
-- @realm client
-- @string title
-- @string body
-- @tab buttons
function impulse.Surface.Query(title, body, buttons)

	local m_fStartTime = UnPredictedCurTime()
	local m_dMessage = vgui.Create("DPanel", nil, "impulseSurfaceQuery")
	m_dMessage:SetSize(ScrW(), ScrH())
	m_dMessage:MakePopup()

	local m_dMarkupMain = markup.Parse("<font=Impulse-LightUI20><color=255,255,255>" .. body .. "</color></font>", math.max(ScrW() * .3, 400))
	local m_dMarkupBlur = markup.Parse("<font=Impulse-LightUI20-Blurred><color=0,0,0>" .. body .. "</color></font>", math.max(ScrW() * .3, 400))

	m_dMessage.Paint = function(m_dPanel, m_iWidth, m_iHeight)
		Derma_DrawBackgroundBlur(m_dPanel, m_fStartTime)

		impulse.Surface.DrawText(
			title or "impulse",
			"Impulse-LightUI64",
			m_iWidth / 2 - (m_iWidth / 6),
			m_iHeight / 2 - 64,
			color_white,
			TEXT_ALIGN_LEFT,
			TEXT_ALIGN_CENTER
		)

		m_dMarkupBlur:Draw(m_iWidth / 2 - (m_iWidth / 6) + 2, m_iHeight / 2 + 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		m_dMarkupMain:Draw(m_iWidth / 2 - (m_iWidth / 6), m_iHeight / 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	local x = ScrW() / 2 - (ScrW() / 6)

	for _, button in ipairs(buttons) do
		local m_dButton = vgui.Create("DButton", m_dMessage, "m_dButton")
		m_dButton:SetFont("Impulse-LightUI32")
		m_dButton:SetText(button.text)
		m_dButton:SizeToContentsX(32)
		m_dButton:SizeToContentsY(32)
		m_dButton:SetX(x)
		m_dButton:CenterVertical(0.7)
		m_dButton:SetText("") -- we dont draw w/ this

		x = x + 32 + m_dButton:GetWide()

		local cFr = 0
		m_dButton.Paint = function(m_dPanel, m_iWidth, m_iHeight)

			if (m_dPanel:IsHovered()) then
				cFr = math.Approach(cFr, 1, FrameTime() * 8)
			else
				cFr = math.Approach(cFr, 0, FrameTime() * 8)
			end

			surface.SetDrawColor(255, 58, 48)
			surface.DrawOutlinedRect(0, 0, m_iWidth, m_iHeight, 3)
			surface.DrawRect(0, m_iHeight - (cFr * m_iHeight), m_iWidth, m_iHeight )

			impulse.Surface.DrawText(
				button.text,
				"Impulse-LightUI32",
				m_iWidth / 2,
				m_iHeight / 2,
				color_white,
				TEXT_ALIGN_CENTER,
				TEXT_ALIGN_CENTER
			)

		end

		m_dButton.DoClick = function()

			pcall(function() button.onpress(m_dMessage, m_dButton) end)
			m_dMessage:Remove()
		end
	end

	return m_dMessage

end

--- A better Derma_Message. Returned panel can access the close button with PANEL.m_dCloseBtn.
-- @realm client
-- @string title
-- @string body
-- @string closeButtonText
-- @treturn Panel The message panel.
function impulse.Surface.Message(title, body, closeButtonText)

	local m_fStartTime = UnPredictedCurTime()
	local m_dMessage = vgui.Create("DPanel", nil, "impulseSurfaceQuery")
	m_dMessage:SetSize(ScrW(), ScrH())
	m_dMessage:MakePopup()

	local m_dMarkupMain = markup.Parse("<font=Impulse-LightUI20><color=255,255,255>" .. body .. "</color></font>", math.max(ScrW() * .3, 400))
	local m_dMarkupBlur = markup.Parse("<font=Impulse-LightUI20-Blurred><color=0,0,0>" .. body .. "</color></font>", math.max(ScrW() * .3, 400))

	m_dMessage.Paint = function(m_dPanel, m_iWidth, m_iHeight)
		Derma_DrawBackgroundBlur(m_dPanel, m_fStartTime)

		impulse.Surface.DrawText(
			title or "impulse",
			"Impulse-LightUI64",
			m_iWidth / 2 - (m_iWidth / 6),
			m_iHeight / 2 - 64,
			color_white,
			TEXT_ALIGN_LEFT,
			TEXT_ALIGN_CENTER
		)

		m_dMarkupBlur:Draw(m_iWidth / 2 - (m_iWidth / 6) + 2, m_iHeight / 2 + 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		m_dMarkupMain:Draw(m_iWidth / 2 - (m_iWidth / 6), m_iHeight / 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	local m_dCloseBtn = vgui.Create("DButton", m_dMessage, "closeButton")
	m_dCloseBtn:SetFont("Impulse-LightUI32")
	m_dCloseBtn:SetText(closeButtonText or "Close")
	m_dCloseBtn:SizeToContentsX(32)
	m_dCloseBtn:SizeToContentsY(32)
	m_dCloseBtn:CenterHorizontal(0.5)
	m_dCloseBtn:CenterVertical(0.7)
	m_dCloseBtn:SetText("") -- we dont draw w/ this
	local cFr = 0
	m_dCloseBtn.Paint = function(m_dPanel, m_iWidth, m_iHeight)

		if (m_dPanel:IsHovered()) then
			cFr = math.Approach(cFr, 1, FrameTime() * 8)
		else
			cFr = math.Approach(cFr, 0, FrameTime() * 8)
		end

		surface.SetDrawColor(255, 58, 48)
		surface.DrawOutlinedRect(0, 0, m_iWidth, m_iHeight, 3)
		surface.DrawRect(0, m_iHeight - (cFr * m_iHeight), m_iWidth, m_iHeight )

		impulse.Surface.DrawText(
			closeButtonText or "Close",
			"Impulse-LightUI32",
			m_iWidth / 2,
			m_iHeight / 2,
			color_white,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)

	end

	m_dCloseBtn.DoClick = function()
		m_dMessage:Remove()
	end

	m_dMessage.m_dCloseBtn = m_dCloseBtn

	return m_dMessage

end

--- Allows the user to enter a string.
-- @realm client
-- @string title
-- @string body
-- @string placeholder
-- @string submittext
-- @func callback
-- @bool showclosebutton
-- @treturn Panel The message panel.
function impulse.Surface.StringRequest(title, body, placeholder, submittext, callback, showclosebutton)
	local m_fStartTime = UnPredictedCurTime()
	local m_dMessage = vgui.Create("EditablePanel", nil, "impulseSurfaceQuery")
	m_dMessage:SetSize(ScrW(), ScrH())
	

	local m_dMarkupMain = markup.Parse("<font=Impulse-LightUI20><color=255,255,255>" .. body .. "</color></font>", math.max(ScrW() * .3, 400))
	local m_dMarkupBlur = markup.Parse("<font=Impulse-LightUI20-Blurred><color=0,0,0>" .. body .. "</color></font>", math.max(ScrW() * .3, 400))

	m_dMessage.Paint = function(m_dPanel, m_iWidth, m_iHeight)
		Derma_DrawBackgroundBlur(m_dPanel, m_fStartTime)

		impulse.Surface.DrawText(
			title or "impulse",
			"Impulse-LightUI64",
			m_iWidth / 2 - (m_iWidth / 6),
			m_iHeight / 2 - 64,
			color_white,
			TEXT_ALIGN_LEFT,
			TEXT_ALIGN_CENTER
		)

		m_dMarkupBlur:Draw(m_iWidth / 2 - (m_iWidth / 6) + 2, m_iHeight / 2 + 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		m_dMarkupMain:Draw(m_iWidth / 2 - (m_iWidth / 6), m_iHeight / 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	local x = ScrW() / 2 - (ScrW() / 6)

	local m_dTextInput = vgui.Create("DTextEntry", m_dMessage, "textent")
	m_dTextInput:SetFont("Impulse-LightUI32")
	m_dTextInput:SetPlaceholderText(placeholder or "")
	m_dTextInput:SetWide(ScrW() / 3)
	m_dTextInput:SetTall(44)
	m_dTextInput:CenterHorizontal(0.5)
	m_dTextInput:CenterVertical(0.7)

	local m_dEnterBtn = vgui.Create("DButton", m_dMessage, "SUBMIT")
	m_dEnterBtn:SetFont("Impulse-LightUI32")
	m_dEnterBtn:SetText("Submit")
	m_dEnterBtn:SizeToContentsX(32)
	m_dEnterBtn:SizeToContentsY(32)
	m_dEnterBtn:SetX(x)
	m_dEnterBtn:CenterVertical(0.8)
	m_dEnterBtn:SetText("") -- we dont draw w/ this
	local cFr = 0
	m_dEnterBtn.Paint = function(m_dPanel, m_iWidth, m_iHeight)

		if (m_dPanel:IsHovered()) then
			cFr = math.Approach(cFr, 1, FrameTime() * 8)
		else
			cFr = math.Approach(cFr, 0, FrameTime() * 8)
		end

		surface.SetDrawColor(255, 58, 48)
		surface.DrawOutlinedRect(0, 0, m_iWidth, m_iHeight, 3)
		surface.DrawRect(0, m_iHeight - (cFr * m_iHeight), m_iWidth, m_iHeight )

		impulse.Surface.DrawText(
			"Submit",
			"Impulse-LightUI32",
			m_iWidth / 2,
			m_iHeight / 2,
			color_white,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)

	end

	m_dEnterBtn.DoClick = function()
		callback(m_dTextInput:GetValue())
		m_dMessage:Remove()
	end

	x = x + m_dEnterBtn:GetWide() + 16

	local m_dCloseBtn = vgui.Create("DButton", m_dMessage, "closeButton")
	m_dCloseBtn:SetFont("Impulse-LightUI32")
	m_dCloseBtn:SetText("Close")
	m_dCloseBtn:SizeToContentsX(32)
	m_dCloseBtn:SizeToContentsY(32)
	m_dCloseBtn:SetX(x)
	m_dCloseBtn:CenterVertical(0.8)
	m_dCloseBtn:SetText("") -- we dont draw w/ this
	local cFr = 0
	m_dCloseBtn.Paint = function(m_dPanel, m_iWidth, m_iHeight)

		if (m_dPanel:IsHovered()) then
			cFr = math.Approach(cFr, 1, FrameTime() * 8)
		else
			cFr = math.Approach(cFr, 0, FrameTime() * 8)
		end

		surface.SetDrawColor(255, 58, 48)
		surface.DrawOutlinedRect(0, 0, m_iWidth, m_iHeight, 3)
		surface.DrawRect(0, m_iHeight - (cFr * m_iHeight), m_iWidth, m_iHeight )

		impulse.Surface.DrawText(
			"Close",
			"Impulse-LightUI32",
			m_iWidth / 2,
			m_iHeight / 2,
			color_white,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)

	end

	m_dCloseBtn.DoClick = function()
		m_dMessage:Remove()
	end
	m_dMessage:MakePopup()
	return m_dMessage
end


sound.Add({
	name = "impulse.Rollover",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 75,
	pitch = {100, 100},
	sound = "impulse/pano_ui_rollover_01.wav"
})

sound.Add({
	name = "impulse.LongAffirm",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 75,
	pitch = {100, 100},
	sound = "impulse/pano_ui_affirm_lg_01.wav"
})

sound.Add({
	name = "impulse.Submenu",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 75,
	pitch = {100, 100},
	sound = "impulse/pano_ui_sub_menu_01.wav"
})
sound.Add({
	name = "impulse.Close",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 75,
	pitch = {100, 100},
	sound = "impulse/pano_ui_menu_close_01.wav"
})

--- Plays a roll over sound
-- @realm client
function impulse.Surface.Rollover()
	surface.PlaySound("impulse/pano_ui_rollover_01.wav")
end

--- Plays a long affirm sound
-- @realm client
function impulse.Surface.LongAffirm()
	surface.PlaySound("impulse/pano_ui_affirm_lg_01.wav")
end

--- Plays a submenu sound
-- @realm client
function impulse.Surface.Submenu()
	surface.PlaySound("impulse/pano_ui_sub_menu_01.wav")
end

--- Plays a close sound
-- @realm client
function impulse.Surface.Close()
	surface.PlaySound("impulse/pano_ui_menu_close_01.wav")
end
