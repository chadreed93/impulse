impulse.DefineSetting("hud_type", {name="HUD style", category="HUD", type="dropdown", options={"Complexity", "impulse", "None"}, default="Complexity"})
--
impulse.DefineSetting("crosshair_style", {name="Crosshair style", category="HUD", type="dropdown", options={"Complexity", "impulse", "None"}, default="Complexity"})

impulse.DefineSetting("hud_iconcolours", {name="Icon Colors", category="HUD", type="dropdown", options={"Enabled", "Disabled"}, default="Disabled"})

impulse.DefineSetting("perf_blur", {name="Blur", category="Misc", type="dropdown", options={"Enabled", "Disabled"}, default="Disabled"})

impulse.DefineSetting("hud_wepselecttype", {name="Scroll Wheel Preference", category="HUD", type="dropdown", options={"Helix", "HL2"}, default="Helix"})


impulse.hudEnabled = impulse.hudEnabled or true



surface.CreateFont("HUD", {
	font = "Swansea",
	size = 45,
	weight = 100,
	antialias = true
})

surface.CreateFont("Impulse-LightUI64", {
	font = "Swansea",
	size = 64,
	weight = 100,
	antialias = true,
	blursize = 0
})

surface.CreateFont("Impulse-LightUI64-Blurred", {
	font = "Swansea",
	size = 64,
	weight = 100,
	antialias = true,
	blursize = 3
})


local hidden = {}
hidden["CHudHealth"] = true
hidden["CHudBattery"] = true
hidden["CHudAmmo"] = true
hidden["CHudSecondaryAmmo"] = true
hidden["CHudCrosshair"] = true
hidden["CHudHistoryResource"] = true
hidden["CHudDeathNotice"] = true
hidden["CHudDamageIndicator"] = true

function GM:HUDShouldDraw(element)
	if (hidden[element]) then
		return false
	end

	return true
end

local blur = Material("pp/blurscreen")
local cheapBlur = Color(0,0,0,205)
local function BlurRect(x, y, w, h)
if not impulse.GetSetting("perf_blur") then
		draw.RoundedBox(0,x,y,w,h, cheapBlur)
		surface.SetDrawColor(0,0,0)
		surface.DrawOutlinedRect(x,y,w,h)
	else
		local X, Y = 0,0

		surface.SetDrawColor(color_white)
		surface.SetMaterial(blur)

		for i = 1, 2 do
			blur:SetFloat("$blur", (i / 10) * 20)
			blur:Recompute()

			render.UpdateScreenEffectTexture()

			render.SetScissorRect(x, y, x+w, y+h, true)
			surface.DrawTexturedRect(X * -1, Y * -1, ScrW(), ScrH())
			render.SetScissorRect(0, 0, 0, 0, false)
		end
	end
end

local vignette = Material("impulse/vignette.png")
local vig_alpha_normal = Color(10,10,10,190)
local lasthealth
local time = 0
local zoneLbl
local gradient = Material("vgui/gradient-l")
local watermark = Material("impulse/impulse-logo-white.png")
local watermarkCol = Color(255,255,255,120)
local fde = 0
local hudBlackGrad = Color(40,40,40,180)
local hudBlack = Color(20,20,20,140)
local darkCol = Color(30, 30, 30, 190)
local whiteCol = Color(255, 255, 255, 255)
local iconsWhiteCol = Color(255, 255, 255, 220)
local bleedFlashCol = Color(230, 0, 0, 220)
local painCol = Color(255,10,10,80)
local crosshairGap = 5
local crosshairLength = crosshairGap + 5
local healthIcon = Material("impulse/icons/heart-128.png")
local healthCol = Color(210, 0, 0, 255)
local armourIcon = Material("impulse/icons/shield-128.png")
local armourCol = Color(205, 25, 0, 255)
local hungerIcon = Material("impulse/icons/bread-128.png")
local hungerCol = Color(205, 133, 63, 255)
local moneyIcon = Material("impulse/icons/banknotes-128.png")
local moneyCol = Color(133, 227, 91, 255)
local timeIcon = Material("impulse/icons/clock-128.png")
local xpIcon = Material("impulse/icons/star-128.png")
local warningIcon = Material("impulse/icons/warning-128.png")
local infoIcon = Material("impulse/icons/info-128.png")
local announcementIcon = Material("impulse/icons/megaphone-128.png")
local exitIcon = Material("impulse/icons/exit-128.png")
local bleedingIcon = Material("impulse/icons/droplet-256.png")
local selectedhud = impulse.GetSetting("hud_type")
local selectedxhair = impulse.GetSetting("crosshair_style")

if selectedhud != "Landis" then
	
local lastModel = ""
local lastSkin = ""
local lastTeam = 99
local lastBodygroups = {}
local iconLoaded = false

local painFt
local painFde = 1

local bleedFlash = false
local hotPink = Color(148, 0, 211)
local colorselect = Color(255, 10, 5, 255)
local colorselect2 = Color(155, 10, 25, 49)
local colormat = Color(225, 0, 0, 255)

local ammoToIcon = {
	[1] = Material("cn-hl2rp/icons/ammo-rifle-512.png"),
	[4] = Material("cn-hl2rp/icons/ammo-smg-512.png"),
	[7] = Material("cn-hl2rp/icons/ammo-shotgun-512.png"),
	[3] = Material("cn-hl2rp/icons/ammo-pistol-512.png")
}

--| DO NOT DELETE MY SHIT lol, it broke the ammo counter
--| Pro tip: if you don't know what it does, LEAVE IT ALONE
local oldReserve = 0

ICROSSHAIR_CROSS = 1
ICROSSHAIR_DOT = 2
ICROSSHAIR_CIRCLE = 3

--| DO NOT put declarations like "ICROSSHAIR_CROSS = 1" inside the GM:HudPaint() hook.
--  They will be called EVERY FRAME, which could be up to 140 times a SECOND. That's why we have
--  so many variables up here, so that we don't create a new one hundreds of times a second.
--  Also, if you're using a Material("") inside your HudPaint(), declare it OUTSIDE the hook
--  because it's relatively expensive to call and probably only needs to be defined once.
--| Same goes with Color().

--| PLEASE keep proper indentation in mind. Make it readable for those who come to fix your stuff.

local unitOfCone = 940.98999023438


local function DrawCrosshair(x, y)
	if selectedxhair == "Complexity" then
	local wep = LocalPlayer():GetActiveWeapon()

	if not IsValid(wep) then
		return
	end

	local spread = x--{x = 0, y = 0}
	local negativespread = x--{x = 0, y = 0}

	if wep.IsPlutonic then
		wep:CalculateSpread()
		
		spread = (wep.LastSpread / wep.Primary.Cone) * (unitOfCone * wep.Primary.Cone)
	end

	local crosshairType = wep.CrosshairType or ICROSSHAIR_CROSS


	if crosshairType == ICROSSHAIR_CROSS then
		local y0 = y -spread
		local y1 = y + spread
		local x0 = x + spread
		local x1 = x - spread
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawLine(x1 - 5, y, x1 - 10, y)
		surface.DrawLine(x0 + 5, y, x0 + 10, y)
		surface.DrawLine(x, y0 - 10, x, y0 - 5)
		surface.DrawLine(x, y1 + 5, x, y1 + 10)
		surface.DrawRect(x , y, 1, 1)
	elseif crosshairType == ICROSSHAIR_DOT then
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawRect(x - 1, y - 1, 2, 2)
	elseif crosshairType == ICROSSHAIR_CIRCLE then
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawCircle(x, y, 5, 255, 255, 255, 255)
	end
elseif selectedxhair == "impulse" then 
	surface.SetDrawColor(color_white)
	surface.DrawLine(x - crosshairLength, y, x - crosshairGap, y)
	surface.DrawLine(x + crosshairLength, y, x + crosshairGap, y)
	surface.DrawLine(x, y - crosshairLength, x, y - crosshairGap)
	surface.DrawLine(x, y + crosshairLength, x, y + crosshairGap)
elseif selectedxhair == "None" then -- ok
end
end

local deathEndingFade
local deathEnding
function GM:HUDPaint()
	local health = LocalPlayer():Health()
	local lp = LocalPlayer()
	local lpTeam = lp:Team()
	local scrW, scrH = ScrW(), ScrH()
	local hudWidth, hudHeight = 300, 178
	local seeColIcons = impulse.GetSetting("hud_iconcolours")
	local aboveHUDUsed = false
	local deathSoundPlayed
	local selectedhud = impulse.GetSetting("hud_type")

	local x, y
	local curWep = lp:GetActiveWeapon()

	if not curWep or not curWep.ShouldDrawCrosshair or (curWep.ShouldDrawCrosshair and curWep.ShouldDrawCrosshair(curWep) != false) then
		if impulse.GetSetting("view_thirdperson") == true then
			local p = LocalPlayer():GetEyeTrace().HitPos:ToScreen()
			x, y = p.x, p.y
		else
			x, y = scrW/2, scrH/2
		end

		if curWep.IsPlutonic then
			local sway_x = ScreenScale(curWep.VMDeltaX * 2)
			x = x + sway_x

			local sway_y = ScreenScale(curWep.VMDeltaY * 2)
			y = y + sway_y
		end

		DrawCrosshair(x, y)
	end
	if selectedhud == "impulse" then
		if SERVER_DOWN and CRASHSCREEN_ALLOW then
			if not IsValid(CRASH_SCREEN) then
				CRASH_SCREEN = vgui.Create("impulseCrashScreen")
			end
		elseif IsValid(CRASH_SCREEN) and not CRASH_SCREEN.fadin then
			CRASH_SCREEN.fadin = true
			CRASH_SCREEN:AlphaTo(0, 1.2, nil, function()
				if IsValid(CRASH_SCREEN) then
					CRASH_SCREEN:Remove()
				end
			end)
		end

		if not lp:Alive() and not SCENES_PLAYING then
			local ft = FrameTime()

			if not deathRegistered then
				local deathSound = hook.Run("GetDeathSound") or "impulse/death.mp3"
				surface.PlaySound(deathSound)

				deathWait = CurTime() + impulse.Config.RespawnTime
				if lp:IsDonator() then
					deathWait = CurTime() + impulse.Config.RespawnTimeDonator
				end

				deathRegistered = true
				deathEnding = true
			end

			fde = math.Clamp(fde + ft * .2, 0, 1)
			painFde = 0.7

			surface.SetDrawColor(0, 0, 0, math.ceil(fde * 255))
			surface.DrawRect(-1, -1, ScrW() +2, ScrH() +2)

			local textCol = Color(255, 255, 255, math.ceil(fde * 255))

			draw.SimpleText("You have died", "Impulse-Elements32", scrW / 2, scrH / 2, textCol, TEXT_ALIGN_CENTER)

			local wait = math.ceil(deathWait - CurTime())

			if wait > 0 then
				draw.SimpleText("You will respawn in "..wait.." "..(wait == 1 and "second" or "seconds")..".", "Impulse-Elements23", scrW/2, (scrH/2)+30, textCol, TEXT_ALIGN_CENTER)
				draw.SimpleText("WARNING: NLR applies, you may not return to this area until 5 minutes after your death.", "Impulse-Elements18", scrW/2, (scrH/2)+70, textCol, TEXT_ALIGN_CENTER)

				draw.SimpleText("If you feel you were unfairly killed, submit a report (F3) for assistance.", "Impulse-Elements16", scrW/2, scrH-20, textCol, TEXT_ALIGN_CENTER)
			end

			if IsValid(PlayerIcon) then
				PlayerIcon:Remove()
			end
			
			return
		else
			if FORCE_FADESPAWN or deathEnding then
				deathEnding = true
				FORCE_FADESPAWN = nil 

				local ft = FrameTime()
				deathEndingFade = math.Clamp((deathEndingFade or 0) + ft * .15, 0, 1)

				local val = 255 - math.ceil(deathEndingFade * 255)

				if deathEndingFade != 1 then
					surface.SetDrawColor(0, 0, 0, val)
					surface.DrawRect(0, 0, ScrW(), ScrH())
				else
					deathEnding = false
					deathEndingFade = 0
				end
			end

			fde = 0

			if deathRegistered then
				deathRegistered = false
			end

			LocalPlayer().Ragdoll = nil
		end

		if impulse.hudEnabled == false or (impulse.CinematicIntro and LocalPlayer():Alive()) or (IsValid(impulse.MainMenu) and impulse.MainMenu:IsVisible()) or hook.Run("ShouldDrawHUDBox") == false then
			if IsValid(PlayerIcon) then
				PlayerIcon:Remove()
			end
			return
		end

		if health < 45 then
			healthstate = Color(255,0,0,240)
		elseif health < 70 then
			healthstate = Color(255,0,0,190)
		else
			healthstate = nil
		end

		-- Draw any HUD stuff under this comment

		if lasthealth and health < lasthealth then
			painFde = 0
		end

		painFt = FrameTime() * 2
		painFde = math.Clamp(painFde + painFt, 0, 0.7)

		--surface.SetDrawColor(ColorAlpha(painCol, 255 * (0.7 - painFde)))
		--surface.DrawRect(0, 0, scrW, scrH)

		-- HUD

		y = scrH-hudHeight-8-10
		BlurRect(10, y, hudWidth, hudHeight)
		surface.SetDrawColor(darkCol)
		surface.DrawRect(10, y, hudWidth, hudHeight)
		surface.SetMaterial(gradient)
		surface.DrawTexturedRect(10, y, hudWidth, hudHeight)

		surface.SetFont("Impulse-Elements23")
		surface.SetTextColor(color_white)
		surface.SetDrawColor(color_white)
		surface.SetTextPos(30, y+10)
		surface.DrawText(LocalPlayer():Name())

		surface.SetTextColor(team.GetColor(lpTeam))
		surface.SetTextPos(30, y+30)
		surface.DrawText(team.GetName(lpTeam))

		local yAdd = 0

		surface.SetTextColor(color_white)
		surface.SetFont("Impulse-Elements19")

		surface.SetTextPos(136, y+64+yAdd)
		surface.DrawText("Health: "..LocalPlayer():Health())
		if seeColIcons == true then surface.SetDrawColor(healthCol) end
		surface.SetMaterial(healthIcon)
		surface.DrawTexturedRect(110, y+66+yAdd, 18, 16)

		surface.SetTextPos(136, y+86+yAdd)
		surface.DrawText("Hunger: "..LocalPlayer():GetSyncVar(SYNC_HUNGER, 100))
		if seeColIcons == true then surface.SetDrawColor(hungerCol) end
		surface.SetMaterial(hungerIcon)
		surface.DrawTexturedRect(110, y+87+yAdd, 18, 18)

		surface.SetTextPos(136, y+108+yAdd)
		surface.DrawText("Money: "..impulse.Config.CurrencyPrefix..LocalPlayer():GetSyncVar(SYNC_MONEY, 0))
		if seeColIcons == true then surface.SetDrawColor(moneyCol) end
		surface.SetMaterial(moneyIcon)
		surface.DrawTexturedRect(110, y+107+yAdd, 18, 18)

		surface.SetDrawColor(color_white)

		if lp:GetSyncVar(SYNC_ARRESTED, false) == true and impulse_JailTimeEnd and impulse_JailTimeEnd > CurTime() then
			local timeLeft = math.ceil(impulse_JailTimeEnd - CurTime())

			surface.SetMaterial(exitIcon)
			surface.DrawTexturedRect(10, y-30, 18, 18)
			draw.DrawText("Sentence remaining: "..string.FormattedTime(timeLeft, "%02i:%02i"), "Impulse-Elements19", 35, y-30, color_white, TEXT_ALIGN_LEFT)
			aboveHUDUsed = true
		end

		draw.DrawText(lp:GetSyncVar(SYNC_XP, 0).."XP", "Impulse-Elements19", 55, y+150+(yAdd-8), color_white, TEXT_ALIGN_LEFT)
		surface.SetMaterial(xpIcon)
		surface.DrawTexturedRect(30, y+150+(yAdd-8), 18, 18)

		local iconsX = 315
		local bleedIconCol

		surface.SetDrawColor(color_white)


		local weapon = LocalPlayer():GetActiveWeapon()
		if IsValid(weapon) then
			if weapon:GetMaxClip1() != -1 then
				surface.SetDrawColor(darkCol)
				surface.DrawRect(scrW-70, scrH-45, 70, 30)
				surface.SetTextPos(scrW-60, scrH-40)
				surface.DrawText(weapon:Clip1().."/"..LocalPlayer():GetAmmoCount(weapon:GetPrimaryAmmoType()))
			elseif weapon:GetClass() == "weapon_physgun" or weapon:GetClass() == "gmod_tool" then
				draw.DrawText("Don't have this weapon out in RP.\nYou may be punished for this.", "Impulse-Elements16", 35, y-35, color_white, TEXT_ALIGN_LEFT)
				surface.SetMaterial(warningIcon)
				surface.DrawTexturedRect(10, y-32, 18, 18)
				aboveHUDUsed = true

				surface.SetDrawColor(darkCol)
				surface.DrawRect(scrW-140, scrH-55, 140, 30)

				surface.SetFont("Impulse-Elements18-Shadow")
				surface.SetTextPos(scrW-130, scrH-50)
				surface.DrawText("Props: "..LocalPlayer():GetSyncVar(SYNC_PROPCOUNT, 0).."/"..((LocalPlayer():IsDonator() and impulse.Config.PropLimitDonator) or impulse.Config.PropLimit))
			end
		end

		if not aboveHUDUsed then
			if impulse.ShowZone then
				if IsValid(zoneLbl) then
					zoneLbl:Remove()	
				end

				zoneLbl = vgui.Create("impulseZoneLabel")
				zoneLbl:SetPos(5, scrH / 2)
				zoneLbl.Zone = lp:GetZoneName()

				impulse.ShowZone = false
			end
		elseif zoneLbl and IsValid(zoneLbl) then
			zoneLbl:Remove()
		end

		if not IsValid(PlayerIcon) and impulse.hudEnabled == true then
			PlayerIcon = vgui.Create("impulseSpawnIcon")
			PlayerIcon:SetPos(30, y+60)
			PlayerIcon:SetSize(64, 64)
			PlayerIcon:SetModel(LocalPlayer():GetModel(), LocalPlayer():GetSkin())

			timer.Simple(0, function()
				if not IsValid(PlayerIcon) then
					return
				end

				local ent = PlayerIcon.Entity

				if IsValid(ent) then
					for v,k in pairs(LocalPlayer():GetBodyGroups()) do
						ent:SetBodygroup(k.id, LocalPlayer():GetBodygroup(k.id))
					end
				end
			end)
		end
		
		local bodygroupChange = false

		if (nextBodygroupChangeCheck or 0) < CurTime() and IsValid(PlayerIcon) then
			local curBodygroups = lp:GetBodyGroups()
			local ent = PlayerIcon.Entity

			for v,k in pairs(lastBodygroups) do
				if not curBodygroups[v] or ent:GetBodygroup(k.id) != LocalPlayer():GetBodygroup(curBodygroups[v].id) then
					bodygroupChange = true
					break
				end
			end

			nextBodygroupChangeCheck = CurTime() + 0.5
		end

		if (lp:GetModel() != lastModel) or (lp:GetSkin() != lastSkin) or bodygroupChange == true or (iconLoaded == false and input.IsKeyDown(KEY_W)) and IsValid(PlayerIcon) then -- input is super hacking fix for SpawnIcon issue
			PlayerIcon:SetModel(lp:GetModel(), lp:GetSkin())
			lastModel = lp:GetModel()
			lastSkin = lp:GetSkin()
			lastTeam = lp:Team()
			lastBodygroups = lp:GetBodyGroups()

			iconLoaded = true
			bodygroupChange = false

			timer.Simple(0, function()
				if not IsValid(PlayerIcon) then
					return
				end

				local ent = PlayerIcon.Entity

				if IsValid(ent) then
					for v,k in pairs(LocalPlayer():GetBodyGroups()) do
						ent:SetBodygroup(k.id, LocalPlayer():GetBodygroup(k.id))
					end
				end
			end)
		end
	elseif selectedhud == "Complexity" then
		local lp = LocalPlayer()
		local health = lp:Health()
		local lpTeam = lp:Team()
		local scrW, scrH = ScrW(), scrH
		local hudWidth, hudHeight = 300, 178
		local seeColIcons = impulse.GetSetting("hud_iconcolours")
		local aboveHUDUsed = false
		local deathSoundPlayed

		if SERVER_DOWN and CRASHSCREEN_ALLOW then
			if not IsValid(CRASH_SCREEN) then
				CRASH_SCREEN = vgui.Create("impulseCrashScreen")
			end
		elseif IsValid(CRASH_SCREEN) and not CRASH_SCREEN.fadin then
			CRASH_SCREEN.fadin = true
			CRASH_SCREEN:AlphaTo(0, 1.2, nil, function()
				if IsValid(CRASH_SCREEN) then
					CRASH_SCREEN:Remove()
				end
			end)
		end

		if not lp:Alive() then
			local ft = FrameTime()

			if not deathRegistered then
				local deathSound = hook.Run("GetDeathSound") or "impulse/death.mp3"
				surface.PlaySound(deathSound)

				deathWait = CurTime() + impulse.Config.RespawnTime
				if lp:IsDonator() then
					deathWait = CurTime() + impulse.Config.RespawnTimeDonator
				end

				deathRegistered = true
			end

			fde = math.Clamp(fde + ft * .2, 0, 1)
			painFde = 0.7

			surface.SetDrawColor(0, 0, 0, math.ceil(fde * 255))
			surface.DrawRect(-1, -1, ScrW() +2, ScrH() +2)

			local textCol = Color(255, 255, 255, math.ceil(fde * 255))

			draw.SimpleText("You have died", "Impulse-LightUI32", scrW / 2, scrH / 2, textCol, TEXT_ALIGN_CENTER)

			local wait = math.ceil(deathWait - CurTime())

			if wait > 0 then
				draw.SimpleText("You will respawn in "..wait.." seconds.", "Impulse-LightUI24", scrW/2, (scrH/2)+30, textCol, TEXT_ALIGN_CENTER)
				draw.SimpleText("WARNING: NLR applies, you may not return to this area until 5 minutes after your death.", "Impulse-LightUI18", scrW/2, (scrH/2)+70, textCol, TEXT_ALIGN_CENTER)

				draw.SimpleText("If you feel you were unfairly killed, submit a report (F3) for assistance.", "Impulse-LightUI18", scrW/2, scrH-20, textCol, TEXT_ALIGN_CENTER)
			end

			if IsValid(PlayerIcon) then
				PlayerIcon:Remove()
			end
			
			return
		else
			fde = 0

			if deathRegistered then
				deathRegistered = false
			end

			LocalPlayer().Ragdoll = nil
		end

		if impulse.hudEnabled == false or (impulse.CinematicIntro and LocalPlayer():Alive()) or (IsValid(impulse.MainMenu) and impulse.MainMenu:IsVisible()) or hook.Run("ShouldDrawHUDBox") == false then
			if IsValid(PlayerIcon) then
				PlayerIcon:Remove()
			end
			return
		end

		if health < 45 then
			healthstate = Color(255,0,0,240)
		elseif health < 70 then
			healthstate = Color(255,0,0,190)
		else
			healthstate = nil
		end

		-- Draw any HUD stuff under this comment

		--Crosshair
		local x, y
		local curWep = lp:GetActiveWeapon()
		// <D64 {▪‿▪}>
		y = scrH-hudHeight-8-10

		-- Bottom Lines
		
		surface.SetDrawColor(colorselect )
		surface.SetMaterial(Material("vgui/gradient-l"))
		surface.DrawTexturedRect(0, (scrH - 43) - 60, 450, 2)

		surface.SetDrawColor(colorselect )
		surface.SetMaterial(Material("vgui/gradient-l"))
		surface.DrawTexturedRect(0, (scrH - 44) + 10, 450, 2)


		-- Gradients
		surface.SetDrawColor(colorselect2)
		surface.SetMaterial(Material("vgui/gradient-l"))
		surface.DrawTexturedRect(0, (scrH - 46) - 57, 450, 70)
		--surface.DrawTexturedRect(260, (scrH - 48) - 57, 136, 60)

		-- Icons
		surface.SetDrawColor( Color(255,255,255,255)  )
		surface.SetMaterial(Material("icons/player_factions/faction_health.png", "mips smooth"))
		surface.DrawTexturedRect(52 + 0, (scrH - 46) - 60, 70, 70)

		surface.SetMaterial(Material("icons/player_factions/faction_utensils.png", "mips smooth"))
		surface.DrawTexturedRect(240 + 0, (scrH - 46) - 60, 70, 70)

		-- Text
		surface.SetFont("Impulse-LightUI64")
		surface.SetTextColor(color_white)
		surface.SetTextPos(134, (scrH - 86) - 18)
		surface.DrawText(lp:Health())

		surface.SetTextPos(322, (scrH - 86) - 18)
		surface.DrawText(lp:GetSyncVar(SYNC_HUNGER, 100))

		surface.SetDrawColor(color_white)

		if lp:GetSyncVar(SYNC_ARRESTED, false) == true and impulse_JailTimeEnd and impulse_JailTimeEnd > CurTime() then
			local timeLeft = math.ceil(impulse_JailTimeEnd - CurTime())

			surface.SetMaterial(exitIcon)
			surface.DrawTexturedRect(10, y-30, 18, 18)
			draw.DrawText("Sentence remaining: "..string.FormattedTime(timeLeft, "%02i:%02i"), "Impulse-LightUI18", 35, y-30, color_white, TEXT_ALIGN_LEFT)
			aboveHUDUsed = true
		end

		local iconsX = 315
		local bleedIconCol

		surface.SetDrawColor(color_white)


		local weapon = lp:GetActiveWeapon()
		if IsValid(weapon) then
			if weapon:GetMaxClip1() != -1 then
				local scrw = ScrW()
				local clip = weapon:Clip1()
				

				local reserveSmooth = lp:GetAmmoCount(weapon:GetPrimaryAmmoType())
				oldReserve = reserveSmooth

				-- Ammo
				local scrw = ScrW()

				surface.SetDrawColor( colorselect2 )
				surface.SetMaterial(Material("vgui/gradient-r"))
				surface.DrawTexturedRect(scrW - 400, (scrH - 46) - 57, 450, 70)

				surface.SetDrawColor(colorselect )
				surface.SetMaterial(Material("vgui/gradient-r"))
				surface.DrawTexturedRect(scrw - 400, (scrH - 44) - 60, 450, 2)
		
				surface.SetDrawColor(colorselect )
				surface.SetMaterial(Material("vgui/gradient-r"))
				surface.DrawTexturedRect(scrw - 400, (scrH - 44) + 10, 450, 2)

				surface.SetFont("medHUD")
				surface.SetDrawColor( color_white )
				surface.SetTextPos((scrW - 328) + 32, (scrH - 86) - 18)
				surface.DrawText(clip.."  |")

				surface.SetFont("Impulse-LightUI64")
				surface.SetTextPos((scrW - 108) - 100, (scrH - 86) - 18)
				surface.DrawText(reserveSmooth)

				surface.SetDrawColor( Color(255,255,255,255) )
				surface.SetMaterial(ammoToIcon[weapon:GetPrimaryAmmoType()] or Material("cn-hl2rp/icons/ammo-rifle-512.png"))
				surface.DrawTexturedRect(scrW - 106, scrH - 94, 48, 48)
				
			elseif weapon:GetClass() == "weapon_physgun" or weapon:GetClass() == "gmod_tool" then
				--draw.DrawText("Don't have this weapon out in RP.\nYou may be punished for this.", "Impulse-Elements18", scrW - 60, scrH - 136, color_white, TEXT_ALIGN_RIGHT)
				--surface.SetMaterial(warningIcon)
				--surface.DrawTexturedRect(10, y-32, 24, 24)
				aboveHUDUsed = true
				local scrw = ScrW()

				surface.SetDrawColor( colorselect2 )
				surface.SetMaterial(Material("vgui/gradient-r"))
				surface.DrawTexturedRect(scrW - 400, (scrH - 46) - 57, 450, 70)

				surface.SetDrawColor(colorselect )
				surface.SetMaterial(Material("vgui/gradient-r"))
				surface.DrawTexturedRect(scrw - 400, (scrH - 43) - 60, 450, 2)
		
				surface.SetDrawColor(colorselect )
				surface.SetMaterial(Material("vgui/gradient-r"))
				surface.DrawTexturedRect(scrw - 400, (scrH - 46) + 10, 450, 2)

				surface.SetFont("medHUD")
				surface.SetTextPos((scrW - 359) + 32, (scrH - 90) - 18)
				surface.DrawText("Props: ")

				surface.SetFont("medHUD")
				surface.SetTextPos((scrW - 108) - 84, (scrH - 96) - 8)
				surface.DrawText(LocalPlayer():GetSyncVar(SYNC_PROPCOUNT, 0))
			end
		end

		if not aboveHUDUsed then
			if impulse.ShowZone then
				if IsValid(zoneLbl) then
					zoneLbl:Remove()	
				end

				zoneLbl = vgui.Create("impulseZoneLabel")
				zoneLbl:SetPos(5, scrH / 2)
				zoneLbl.Zone = lp:GetZoneName()

				impulse.ShowZone = false
			end
		elseif zoneLbl and IsValid(zoneLbl) then
			zoneLbl:Remove()
		end

		local isPreview = GetConVar("impulse_ispreview"):GetBool()

		if isPreview then
			-- watermark
			surface.SetMaterial(Material("cn-hl2rp/icons/betalogo.png"))
			surface.DrawTexturedRect( 26, y - 70, 400, 225 )
		end

		if impulse_DevHud and (lp:IsSuperAdmin() or lp:IsDeveloper()) then
			local trace = {}
			trace.start = lp:EyePos()
			trace.endpos = trace.start + lp:GetAimVector() * 3000
			trace.filter = lp

			local traceData = util.TraceLine(trace)
			local traceEnt = traceData.Entity

			if traceEnt and traceEnt != NULL then
				surface.SetTextPos((scrW / 2) + 30, (scrH / 2) - 100)
				surface.DrawText(tostring(traceEnt))

				surface.SetTextPos((scrW / 2) + 30, (scrH / 2) - 80)
				surface.DrawText(traceEnt:GetModel().."     "..traceData.HitTexture or "")

				local syncData = impulse.Sync.Data[traceEnt:EntIndex()]
				local netData
				local y = (scrH / 2) - 40

				if syncData then
					for v,k in pairs(syncData) do
						if type(k) == "table" then
							k = table.ToString(k)
						end

						surface.SetTextPos((scrW / 2) + 30, y)
						surface.DrawText("syncvalue: "..v.." ; "..tostring(k))
						y = y + 20
					end
				end

				if IsValid(traceEnt) and traceEnt.GetNetworkVars then
					netData = traceEnt:GetNetworkVars()
				end

				if netData then
					for v,k in pairs(netData) do
						surface.SetTextPos((scrW / 2) + 30, y)
						surface.DrawText("netvalue: "..v.." ; "..tostring(k))
						y = y + 20
					end
				end
			end

			surface.SetTextPos(400, scrH / 1.5)
			surface.DrawText(tostring(lp:GetPos()))
			surface.SetTextPos(400, (scrH / 1.5) + 20)
			surface.DrawText(tostring(lp:GetAngles()))
			surface.SetTextPos(400, (scrH / 1.5) + 40)
			surface.DrawText(lp:GetVelocity():Length2D())
		end

		lasthealth = health
	elseif selectedhud == "None" then
		local lp = LocalPlayer()
		local health = lp:Health()
		local lpTeam = lp:Team()
		local scrW, scrH = ScrW(), scrH
		local hudWidth, hudHeight = 300, 178
		local seeColIcons = impulse.GetSetting("hud_iconcolours")
		local aboveHUDUsed = false
		local deathSoundPlayed

		if SERVER_DOWN and CRASHSCREEN_ALLOW then
			if not IsValid(CRASH_SCREEN) then
				CRASH_SCREEN = vgui.Create("impulseCrashScreen")
			end
		elseif IsValid(CRASH_SCREEN) and not CRASH_SCREEN.fadin then
			CRASH_SCREEN.fadin = true
			CRASH_SCREEN:AlphaTo(0, 1.2, nil, function()
				if IsValid(CRASH_SCREEN) then
					CRASH_SCREEN:Remove()
				end
			end)
		end

		if not lp:Alive() then
			local ft = FrameTime()

			if not deathRegistered then
				local deathSound = hook.Run("GetDeathSound") or "impulse/death.mp3"
				surface.PlaySound(deathSound)

				deathWait = CurTime() + impulse.Config.RespawnTime
				if lp:IsDonator() then
					deathWait = CurTime() + impulse.Config.RespawnTimeDonator
				end

				deathRegistered = true
			end

			fde = math.Clamp(fde + ft * .2, 0, 1)
			painFde = 0.7

			surface.SetDrawColor(0, 0, 0, math.ceil(fde * 255))
			surface.DrawRect(-1, -1, ScrW() +2, ScrH() +2)

			local textCol = Color(255, 255, 255, math.ceil(fde * 255))

			draw.SimpleText("You have died", "Impulse-LightUI32", scrW / 2, scrH / 2, textCol, TEXT_ALIGN_CENTER)

			local wait = math.ceil(deathWait - CurTime())

			if wait > 0 then
				draw.SimpleText("You will respawn in "..wait.." seconds.", "Impulse-LightUI24", scrW/2, (scrH/2)+30, textCol, TEXT_ALIGN_CENTER)
				draw.SimpleText("WARNING: NLR applies, you may not return to this area until 5 minutes after your death.", "Impulse-LightUI18", scrW/2, (scrH/2)+70, textCol, TEXT_ALIGN_CENTER)

				draw.SimpleText("If you feel you were unfairly killed, submit a report (F3) for assistance.", "Impulse-LightUI18", scrW/2, scrH-20, textCol, TEXT_ALIGN_CENTER)
			end

			if IsValid(PlayerIcon) then
				PlayerIcon:Remove()
			end
			
			return
		else
			fde = 0

			if deathRegistered then
				deathRegistered = false
			end

			LocalPlayer().Ragdoll = nil
		end

		if impulse.hudEnabled == false or (impulse.CinematicIntro and LocalPlayer():Alive()) or (IsValid(impulse.MainMenu) and impulse.MainMenu:IsVisible()) or hook.Run("ShouldDrawHUDBox") == false then
			if IsValid(PlayerIcon) then
				PlayerIcon:Remove()
			end
			return
		end

		--print("No HUD elements to show.")
	end
end


local nextOverheadCheck = 0
local lastEnt
local trace = {}
local approach = math.Approach
local letterboxFde = 0
local textFde = 0
local holdTime
overheadEntCache = {}
-- overhead info is HEAVILY based off nutscript. I'm not taking credit for it. but it saves clients like 70 fps so its worth it




local function DrawOverheadInfo(target, alpha)
	local pos = target:EyePos()

	pos.z = pos.z + 5

	local lp = LocalPlayer()

	local ang = (pos - lp:EyePos()):GetNormalized():Angle()

	--
	ang:RotateAroundAxis(ang:Up(), -106)
	ang:RotateAroundAxis(ang:Forward(), 90)

	ang[1] = 0
	ang[3] = 90

	pos = pos + ang:Forward() * (target.OffsetHorizontal3D2D or 8)

	cam.Start3D2D(pos, ang, 0.1)
	cam.IgnoreZ(true)

	local myGroup = LocalPlayer():GetSyncVar(SYNC_GROUP_NAME, nil)
	local group = target:GetSyncVar(SYNC_GROUP_NAME, nil)
	local rank = target:GetSyncVar(SYNC_GROUP_RANK, nil)
	local col = ColorAlpha(team.GetColor(target:Team()), alpha)
	local shadow = ColorAlpha(color_black, alpha)

	if myGroup and not LocalPlayer():IsCP() and not target:IsCP() and group and rank and group == myGroup then
		--draw.DrawText(group.." - "..rank, "Impulse-Elements16-Shadow", 0, -24, ColorAlpha(hotPink, alpha), 0)
		draw.DrawText(group.." - "..rank, "Impulse-LightUI20-Blurred", 2, -48, ColorAlpha(color_black, alpha), 0)
		draw.DrawText(group.." - "..rank, "Impulse-LightUI20",0, -50, ColorAlpha(hotPink, alpha), 0)
	end

	draw.DrawText(LocalPlayer():KnownNameOf(target), "Impulse-LightUI64-Blurred", 3, 3, shadow, 0)
	draw.DrawText(LocalPlayer():KnownNameOf(target), "Impulse-LightUI64", 0, 0, col, 0)

	local drawHealthInfoY = 15
	if target:GetSyncVar(SYNC_TYPING, false) then
		if target:IsCP() then
			tx = "<:: Typing ::>" .. string.rep(".", ((CurTime() * 4) % 3))
		else
			tx = "Typing" .. string.rep(".", ((CurTime() * 4) % 3))
		end
		
		draw.DrawText(tx, "Impulse-LightUI20-Blurred", 2, 52, ColorAlpha(color_black, alpha), 0)
		draw.DrawText(tx, "Impulse-LightUI20",0, 50, ColorAlpha(color_white, alpha), 0)
		drawHealthInfoY = 30
	elseif target:GetSyncVar(SYNC_ARRESTED, false) and LocalPlayer():CanArrest(target) then
		draw.DrawText("(F2 to unrestrain | E to drag)", "Impulse-Elements16-Shadow", 0, 32, ColorAlpha(color_white, alpha), 1)
		drawHealthInfoY = 30
	else
		local desc = target:GetDescription()

		if desc:len() > 64 then
			desc = string.sub(desc, 0, 48) .. "..."
		end
		draw.DrawText(desc, "Impulse-LightUI20-Blurred", 2, 52, ColorAlpha(color_black, alpha), 0)
		draw.DrawText(desc, "Impulse-LightUI20",0, 50, ColorAlpha(color_white, alpha), 0)
		drawHealthInfoY = 30
	end
	cam.IgnoreZ(false)
	cam.End3D2D()
end

local function DrawDoorInfo(target, alpha)
	local pos = target.LocalToWorld(target, target:OBBCenter()):ToScreen()
	local doorOwners = target:GetSyncVar(SYNC_DOOR_OWNERS, nil) 
	local doorName = target:GetSyncVar(SYNC_DOOR_NAME, nil) 
	local doorGroup =  target:GetSyncVar(SYNC_DOOR_GROUP, nil)
	local doorBuyable = target:GetSyncVar(SYNC_DOOR_BUYABLE, nil)
	local col = ColorAlpha(colorselect, alpha)

	if doorName then
		local ownedBy = ""
		if doorOwners then
			if #doorOwners > 1 then
				ownedBy = "Owners:"
			else
				ownedBy = "Owner:"
			end

			for v,k in pairs(doorOwners) do
				local owner = Entity(k)

				if IsValid(owner) and owner:IsPlayer() then
					ownedBy = ownedBy.."\n"..owner:Name()
				end
			end
		end

		draw.DrawText(doorName.."\n"..ownedBy, "Impulse-Elements18-Shadow", pos.x, pos.y, col, 1)
	elseif doorGroup then
		draw.DrawText(impulse.Config.DoorGroups[doorGroup], "Impulse-Elements18-Shadow", pos.x, pos.y, col, 1)
	elseif doorOwners then
		local ownedBy
		if #doorOwners > 1 then
			ownedBy = "Owners:"
		else
			ownedBy = "Owner:"
		end

		for v,k in pairs(doorOwners) do
			local owner = Entity(k)

			if IsValid(owner) and owner:IsPlayer() then
				ownedBy = ownedBy.."\n"..owner:Name()
			end
		end
		draw.DrawText(ownedBy, "Impulse-Elements18-Shadow", pos.x, pos.y, col, 1)
	end

	if LocalPlayer():CanBuyDoor(doorOwners, doorBuyable) then
		draw.DrawText("Ownable door (F2)", "Impulse-Elements18-Shadow", pos.x, pos.y, col, 1)
	end
end


local function DrawEntInfo(target, alpha)
	local pos = target.LocalToWorld(target, target:OBBCenter()) + Vector(0, 0, target:OBBMaxs()[3]/2 + (target.OffsetVertical3D2D or 24))
	local scrW = ScrW()
	local scrH = ScrH()
	local hudName = target.HUDName
	local hudDesc = target.HUDDesc
	local hudCol = target.HUDColour or impulse.Config.InteractColour

	local lp = LocalPlayer()

	local ang = (pos - lp:EyePos()):GetNormalized():Angle()

	--
	ang:RotateAroundAxis(ang:Up(), -106)
	ang:RotateAroundAxis(ang:Forward(), 90)

	ang[1] = 0
	ang[3] = 90

	pos = pos + ang:Forward() * (target.OffsetHorizontal3D2D or 8)

	cam.Start3D2D(pos, ang, 0.1)
		cam.IgnoreZ(true)
			draw.DrawText(hudName, "Impulse-LightUI64-Blurred", 4, 4, ColorAlpha(color_black, alpha), 0)
			draw.DrawText(hudName, "Impulse-LightUI64", 0, 0, ColorAlpha(hudCol, alpha), 0)
			if hudDesc then
				draw.DrawText(hudDesc, "Impulse-LightUI32-Blurred", 2, 66, ColorAlpha(color_black, alpha), 0)
				draw.DrawText(hudDesc, "Impulse-LightUI32",0, 64, ColorAlpha(color_white, alpha), 0)
			end
		cam.IgnoreZ(false)
	cam.End3D2D()
end

local function DrawButtonInfo(target, alpha)	
	local pos = target.LocalToWorld(target, target:OBBCenter()):ToScreen()
	local scrW = ScrW()
	local scrH = ScrH()
	local buttonId = impulse_ActiveButtons[target:EntIndex()]
	local hudCol = colorselect2
	local buttonData = impulse.Config.Buttons[buttonId]

	if not buttonData then
		return
	end

	if not buttonData.desc then
		return
	end

	draw.DrawText(buttonData.desc, HIGH_RES("Impulse-Elements18-Shadow", "Impulse-Elements20A-Shadow"), pos.x, pos.y + 20, ColorAlpha(hudCol, alpha), 1)
end



function GM:HUDPaintBackground()

	if impulse.GetSetting("hud_vignette") == true then
		surface.SetMaterial(vignette)
		surface.SetDrawColor(vig_alpha_normal)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	end

	if impulse.hudEnabled == false then
		return
	end

	local lp = LocalPlayer()
	local realTime = RealTime()
	local frameTime = FrameTime()

	if nextOverheadCheck < realTime then
		nextOverheadCheck = realTime + 0.5
		
		trace.start = lp.GetShootPos(lp)
		trace.endpos = trace.start + lp.GetAimVector(lp) * 300
		trace.filter = lp
		trace.mins = Vector(-4, -4, -4)
		trace.maxs = Vector(4, 4, 4)
		trace.mask = MASK_SHOT_HULL

		lastEnt = util.TraceHull(trace).Entity

		if IsValid(lastEnt) then
			overheadEntCache[lastEnt] = true
		end
	end

	for entTarg, shouldDraw in pairs(overheadEntCache) do
		if IsValid(entTarg) then
			local goal = shouldDraw and 255 or 0
			local alpha = approach(entTarg.overheadAlpha or 0, goal, frameTime * 1000)

			if lastEnt != entTarg then
				overheadEntCache[entTarg] = false
			end

			if alpha > 0 then
				if not entTarg:GetNoDraw() then
					if entTarg:IsPlayer() then
						DrawOverheadInfo(entTarg, alpha)
					elseif entTarg.HUDName then
						DrawEntInfo(entTarg, alpha)
						surface.SetMaterial(Material("mrp/key_cap_icon_dark.png"))
						surface.SetDrawColor(255,255,255,255)
						surface.DrawTexturedRect(900, 953, 45, 45)
						draw.DrawText("Press    E    to use this.", "HUD", 960, 950, Color(255,255,255), 1)
					elseif entTarg:IsDoor() then
						DrawDoorInfo(entTarg, alpha)
						surface.SetMaterial(Material("mrp/key_cap_icon_dark.png"))
						surface.SetDrawColor(255,255,255,255)
						surface.DrawTexturedRect(815, 953, 45, 45)
						draw.DrawText("Press    E    to open or close doors.", "HUD", 960, 950, Color(255,255,255), 1)
					elseif impulse_ActiveButtons[entTarg.EntIndex(entTarg)] then
						DrawButtonInfo(entTarg, alpha)
					end
				end
			end

			entTarg.overheadAlpha = alpha

			if alpha == 0 and goal == 0 then
				overheadEntCache[entTarg] = nil
			end
		else
			overheadEntCache[entTarg] = nil
		end
	end
	
	if impulse.CinematicIntro and lp:Alive() then
		local ft = FrameTime()
		local maxTall =  ScrH() * .12

		if holdTime and holdTime + 6 < CurTime() then
			letterboxFde = math.Clamp(letterboxFde - ft * .5, 0, 1)
			textFde = math.Clamp(textFde - ft * .3, 0, 1)

			if letterboxFde == 0 then
				impulse.CinematicIntro = false
			end
		elseif holdTime and holdTime + 4 < CurTime() then
			textFde = math.Clamp(textFde - ft * .3, 0, 1)
		else
			letterboxFde = math.Clamp(letterboxFde + ft * .5, 0, 1)

			if letterboxFde == 1 then
				textFde = math.Clamp(textFde + ft * .1, 0, 1)
				holdTime = holdTime or CurTime()
			end
		end

		surface.SetDrawColor(color_black)
		surface.DrawRect(0, 0, ScrW(), (maxTall * letterboxFde))
		surface.DrawRect(0, (ScrH() - (maxTall * letterboxFde)) + 1, ScrW(), maxTall)

		draw.DrawText(impulse.CinematicTitle, "Impulse-Elements36", ScrW() - 150, ScrH() * .905, ColorAlpha(color_white, (255 * textFde)), TEXT_ALIGN_RIGHT)
	else
		letterboxFde = 0
		textFde = 0
		holdTime = nil
	end
end


hook.Add("PostDrawTranslucentRenderables", "DrawEntInfo", function(bDrawingDepth,bDrawingSkybox)
	if bDrawingDepth or bDrawingSkybox then
		return
	end
	local lp = LocalPlayer()
	local realTime = RealTime()
	local frameTime = FrameTime()

	for entTarg, shouldDraw in pairs(overheadEntCache) do
		if IsValid(entTarg) then
			local alpha =entTarg.overheadAlpha

			if lastEnt != entTarg then
				overheadEntCache[entTarg] = false
			end

			if alpha and alpha > 0 then
				if not entTarg:GetNoDraw() then
					if entTarg:IsPlayer() then
						DrawOverheadInfo(entTarg, alpha)
					elseif entTarg.HUDName then
						DrawEntInfo(entTarg, alpha)
					elseif entTarg:IsDoor() then
						--DrawDoorInfo(entTarg, alpha)
					elseif impulse_ActiveButtons and impulse_ActiveButtons[entTarg.EntIndex(entTarg)] then
						DrawButtonInfo(entTarg, alpha)
					end
				end
			end
		else
			overheadEntCache[entTarg] = nil
		end
	end
end)

concommand.Add("impulse_cameratoggle", function()
	impulse.hudEnabled = (!impulse.hudEnabled)

	if not IsValid(impulse.chatBox.frame) then
		return
	end

	if impulse.hudEnabled then
		impulse.chatBox.frame:Show()
	else
		impulse.chatBox.frame:Hide()
	end
end)
else
	-- COPYRIGHT:
-- This file is part of Landis Games. 
-- Landis Games is not public software, you may not redistribute it
-- and/or modify it without the express permission of Landis Games.
-- Any modification to the framework done, given proper permission
-- must remain in the guidelines of the license. If you have any
-- questions, please contact us at support@landis-community.com
-- Thank you for your cooperation.
-- 
-- Copyright (c) 2021-2023 Landis Games, All Rights Reserved.

impulse.hudEnabled = impulse.hudEnabled or true

local hidden = {}
hidden["CHudHealth"] = true
hidden["CHudBattery"] = true
hidden["CHudAmmo"] = true
hidden["CHudSecondaryAmmo"] = true
hidden["CHudCrosshair"] = true
hidden["CHudHistoryResource"] = true
hidden["CHudDeathNotice"] = true
hidden["CHudDamageIndicator"] = true
hidden["CHudWeaponSelection"] = true
hidden["CHUDQuickInfo"] = true
hidden["CHUDAutoAim"] = true
function GM:HUDShouldDraw(element)
	if (hidden[element]) then
		return false
	end

	return true
end

local blur = Material("pp/blurscreen")
local cheapBlur = Color(0,0,0,205)
local function BlurRect(x, y, w, h)
	impulse.BlurRect(x, y, w, h)
end

local vignette = Material("impulse/vignette.png", "mips smooth")
local vig_alpha_normal = Color(10,10,10,255)
local lasthealth
local time = 0
local zoneLbl
local gradient = Material("vgui/gradient-l")
local watermark = Material("impulse/impulse-logo-white.png")
local watermarkCol = Color(255,255,255,120)
local fde = 0
local hudBlackGrad = Color(40,40,40,180)
local hudBlack = Color(20,20,20,140)
local darkCol = Color(30, 30, 30, 190)
local whiteCol = Color(255, 255, 255, 255)
local iconsWhiteCol = Color(255, 255, 255, 220)
local bleedFlashCol = Color(230, 0, 0, 220)
local painCol = Color(255,10,10,80)
local crosshairGap = 5
local crosshairLength = crosshairGap + 16
local healthIcon = Material("impulse/icons/heart-128.png", "mips smooth")
local healthCol = Color(210, 0, 0, 255)
local armourIcon = Material("impulse/icons/shield-128.png")
local armourCol = Color(205, 190, 0, 255)
local hungerIcon = Material("impulse/icons/bread-128.png", "mips smooth")
local hungerCol = Color(205, 133, 63, 255)
local moneyIcon = Material("impulse/icons/banknotes-128.png")
local moneyCol = Color(133, 227, 91, 255)
local timeIcon = Material("impulse/icons/clock-128.png")
local xpIcon = Material("impulse/icons/star-128.png")
local warningIcon = Material("impulse/icons/warning-128.png")
local infoIcon = Material("impulse/icons/info-128.png")
local announcementIcon = Material("impulse/icons/megaphone-128.png")
local exitIcon = Material("impulse/icons/exit-128.png")
local bleedingIcon = Material("impulse/icons/droplet-256.png")

local lastModel = ""
local lastSkin = ""
local lastTeam = 99
local lastBodygroups = {}
local iconLoaded = false

local painFt
local painFde = 1

local bleedFlash = false
local hotPink = Color(148, 0, 211)

local wpnRow = 0
local wpnCol = 0
local wpnOpen = false
local wpnLastInput = CurTime()

local wpnColUsable = Color(33,78,102,210)
local wpnColUsable2 = Color(35,83,122,220)
local wpnColSell = Color(24,64,84,200)
local wpnColSell2 = Color(30,66,90,220)
local wpnColEmpty = Color(24,46,48,60)
local wpnColEmpty2 = Color(27,50,54,60)
local wpnGradient = Material("vgui/gradient-l")

local wpnSlots = {
	"Tools",
	"Essential",
	"Primary",
	"Secondary",
	"Utilities",
	"Misc."
}

local function DrawWeaponSelect()

	if (wpnLastInput + 5 < CurTime()) or not wpnOpen then
		wpnRow = 0
		wpnCol = 0
		return
	end

	local weps = {}

	for i = 1, 6 do
		weps[i] = {}
	end

	for _, wep in ipairs(LocalPlayer():GetWeapons()) do
		table.insert(weps[wep.Slot and wep.Slot + 1 or 1], wep)
	end

	surface.SetMaterial(wpnGradient)

	local x = (ScrW() / 2) - 498

	for slot, wpns in pairs(weps) do
		BlurRect(x, 0, 166, 60)
		surface.SetDrawColor(#wpns != 0 and wpnColUsable2 or wpnColEmpty2)
		surface.DrawRect(x, 0, 166, 60)
		surface.SetMaterial(wpnGradient)
		surface.SetDrawColor(#wpns != 0 and wpnColUsable or wpnColEmpty)
		surface.DrawTexturedRect(x, 0, 166, 60)
		
		impulse.Surface.DrawText(
			wpnSlots[slot],
			"Impulse-LightUI32",
			x + 83,
			30,
			color_white,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)

		if wpnRow == slot then

			for y, wep in ipairs(wpns) do
				BlurRect(x, y * 60, 166, 60)
				surface.SetDrawColor(wpnCol == y and wpnColSell2 or wpnColEmpty2)
				surface.DrawRect(x, y * 60, 166, 60)
				surface.SetMaterial(wpnGradient)
				surface.SetDrawColor(wpnCol == y and wpnColSell or wpnColEmpty)
				surface.DrawTexturedRect(x, y * 60, 166, 60)
			
				impulse.Surface.DrawText(
					wep:GetPrintName(),
					"Impulse-LightUI20",
					x + 83,
					y * 60 + 30,
					color_white,
					TEXT_ALIGN_CENTER,
					TEXT_ALIGN_CENTER
				)
			end
		end

		x = x + 166
	end

end

local lastWeaponSwitch = 0

hook.Add("StartCommand", "PreventAutoAttack", function(ply, ucmd)
	if ply:InVehicle() then return end

	if ucmd:KeyDown(IN_ATTACK) and lastWeaponSwitch + 0.5 > CurTime() then
		ucmd:SetButtons(bit.band(ucmd:GetButtons(), bit.bnot(IN_ATTACK)))
	end
end)

-- Reason for this:
-- When running hooks, Garry's Mod does not order the hooks in any particular way, but guarantees that the GAMEMODE and GM defined hooks get run LAST.
-- Since this is a fix to WireMod E2 selectors, this will allow it to only be run if it is not override by Wiremod's UI tools :3
-- Justin B
function GM:PlayerBindPress(ply, bind, pressed)
	if not pressed then return end

	local isInvShifting = false 
	local shiftBy = 1

	if not bind:StartWith("slot") then 
		if bind == "+attack" then
			if wpnOpen and not (wpnLastInput + 5 < CurTime()) then
				local weps = {}

				for _, wep in ipairs(LocalPlayer():GetWeapons()) do
					weps[wep.Slot and wep.Slot + 1 or 1] = weps[wep.Slot and wep.Slot + 1 or 1] or {}
					table.insert(weps[wep.Slot and wep.Slot + 1 or 1], wep)
				end

				local swp = (weps[wpnRow] or {})[wpnCol]

				if not IsValid(swp) then return end

				lastWeaponSwitch = CurTime()
				input.SelectWeapon(swp)
				wpnOpen = false
				wpnLastInput = 0
				surface.PlaySound("impulse/pano_ui_menu_close_01.wav")
				return
			end
		elseif bind == "invprev" then
			if input.IsMouseDown(MOUSE_LEFT) then return end
			isInvShifting = true 
			shiftBy = -1
		elseif bind == "invnext" then
			if input.IsMouseDown(MOUSE_LEFT) then return end
			isInvShifting = true 
			shiftBy = 1
		end
		if not isInvShifting then return end
	end

	local i = isInvShifting and (wpnRow != 0 and wpnRow or (LocalPlayer():GetActiveWeapon().Slot or 1) + 1) or tonumber(bind:sub(5))

	wpnOpen = true 
	wpnLastInput = CurTime()

	if ( wpnRow != i ) then
				
		wpnRow = i
		wpnCol = 1
		surface.PlaySound("impulse/pano_ui_sub_menu_01.wav")

	else

		local weps = {}
		for i = 1, 6 do
			weps[i] = {}
		end
		for _, wep in ipairs(LocalPlayer():GetWeapons()) do
			table.insert(weps[wep.Slot and wep.Slot + 1 or 1], wep)
		end


		if ((wpnCol + shiftBy) > #weps[wpnRow] or ((wpnCol + shiftBy) <= 0)) then
			if (isInvShifting) then
				wpnRow = wpnRow + shiftBy
				if (wpnRow < 0) then
					wpnRow = 6
					wpnCol = 1
				elseif (wpnRow > 6) then
					wpnRow = 1
					wpnCol = 1
				end

				if shiftBy > 0 then
					wpnCol = 1
				else
					wpnCol = #weps[(wpnRow <= 0) and 6 or wpnRow]
				end
				
			else
				wpnCol = 1
			end
		else
			if (isInvShifting) then
				wpnCol = wpnCol + shiftBy
			else
				wpnCol = wpnCol + 1
			end
		end
		surface.PlaySound("impulse/pano_ui_rollover_01.wav")

	end
end

--- A physical player in the server
-- @classmod Player

--- Get's a text version of the players health amount.
-- @realm client
-- @treturn string The players health described in text.
-- @treturn color The color to draw in.
function meta:GetKnownHealth()
	local h = self.Health(self)
	if h < 10 then
		return "(Extremely Injured)", Color(255, 0, 0)
	elseif h < 25 then
		return "(Heavily Injured)", Color(255, 50, 0)
	elseif h < 40 then
		return "(Injured)", Color(255, 100, 0)
	elseif h < 60 then
		return "(Hurt)", Color(255, 150, 0)
	elseif h < 80 then
		if self:Bleeding() then
			return "(Cut)", Color(255, 175, 0)
		else
			return "(Bruised)", Color(255, 175, 0)
		end
	end
	if self:Bleeding() then
		return "(Cut)", Color(255,0,0)
	end 
end

local function DrawOverheadInfo(target, alpha)
	local pos = target:EyePos()

	pos.z = pos.z + 5

	local lp = LocalPlayer()

	local ang = (pos - lp:EyePos()):GetNormalized():Angle()

	--
	ang:RotateAroundAxis(ang:Up(), -106)
	ang:RotateAroundAxis(ang:Forward(), 90)

	ang[1] = 0
	ang[3] = 90

	pos = pos + ang:Forward() * (target.OffsetHorizontal3D2D or 8)

	cam.Start3D2D(pos, ang, 0.1)
	cam.IgnoreZ(true)

	local myGroup = LocalPlayer():GetSyncVar(SYNC_GROUP_NAME, nil)
	local group = target:GetSyncVar(SYNC_GROUP_NAME, nil)
	local rank = target:GetSyncVar(SYNC_GROUP_RANK, nil)
	local col = ColorAlpha(team.GetColor(target:Team()), alpha)
	local shadow = ColorAlpha(color_black, alpha)

	if myGroup and not LocalPlayer():IsCP() and not target:IsCP() and group and rank and group == myGroup then
		--draw.DrawText(group.." - "..rank, "Impulse-Elements16-Shadow", 0, -24, ColorAlpha(hotPink, alpha), 0)
		draw.DrawText(group.." - "..rank, "Impulse-LightUI20-Blurred", 2, -48, ColorAlpha(color_black, alpha), 0)
		draw.DrawText(group.." - "..rank, "Impulse-LightUI20",0, -50, ColorAlpha(hotPink, alpha), 0)
	end

	draw.DrawText(target:KnownName(), "Impulse-LightUI64-Blurred", 3, 3, shadow, 0)
	draw.DrawText(target:KnownName(), "Impulse-LightUI64", 0, 0, col, 0)

	local drawHealthInfoY = 15
	if target:GetSyncVar(SYNC_TYPING, false) then
		local tx = "Typing" .. string.rep(".", ((CurTime() * 4) % 3))
		draw.DrawText(tx, "Impulse-LightUI20-Blurred", 2, 52, ColorAlpha(color_black, alpha), 0)
		draw.DrawText(tx, "Impulse-LightUI20",0, 50, ColorAlpha(color_white, alpha), 0)
		drawHealthInfoY = 30
	elseif target:GetSyncVar(SYNC_ARRESTED, false) and LocalPlayer():CanArrest(target) then
		draw.DrawText("(F2 to unrestrain | E to drag)", "Impulse-Elements16-Shadow", 0, 32, ColorAlpha(color_white, alpha), 1)
		drawHealthInfoY = 30
	else
		local desc = target:GetDescription()

		if desc:len() > 64 then
			desc = string.sub(desc, 0, 48) .. "..."
		end
		draw.DrawText(desc, "Impulse-LightUI20-Blurred", 2, 52, ColorAlpha(color_black, alpha), 0)
		draw.DrawText(desc, "Impulse-LightUI20",0, 50, ColorAlpha(color_white, alpha), 0)
		drawHealthInfoY = 30
	end

	local bleeding = target:GetSyncVar(SYNC_BLEEDING, false)
	if bleeding or (target:Health() < 80) then
		local text, color = target:GetKnownHealth()
		if bleeding then
			color = Color(255, 0, 0)
			text = text .. " (Bleeding)"
		end
		draw.DrawText(text, "Impulse-Elements16-Shadow", pos.x, pos.y + drawHealthInfoY, ColorAlpha(color, alpha), 1)
	end

	cam.IgnoreZ(false)
	cam.End3D2D()
end

local function DrawDoorInfo(target, alpha)
	local pos = target.LocalToWorld(target, target:OBBCenter()):ToScreen()
	local doorOwners = target:GetSyncVar(SYNC_DOOR_OWNERS, nil) 
	local doorName = target:GetSyncVar(SYNC_DOOR_NAME, nil) 
	local doorGroup =  target:GetSyncVar(SYNC_DOOR_GROUP, nil)
	local doorBuyable = target:GetSyncVar(SYNC_DOOR_BUYABLE, nil)
	local col = ColorAlpha(impulse.Config.MainColour, alpha)
	local mcol = ColorAlpha(color_white, alpha)

	if doorName then
		impulse.Surface.DrawText(
			doorName,
			"Impulse-LightUI20",
			pos.x,
			pos.y,
			col,
			1
		)
		--draw.DrawText(doorName, "Impulse-Elements18-Shadow", pos.x, pos.y, col, 1)
		if doorOwners then
			local ownedBy
			if #doorOwners > 1 then
				ownedBy = "Owners:"
			else
				ownedBy = "Owner:"
			end

			for v,k in pairs(doorOwners) do
				local owner = Entity(k)

				if IsValid(owner) and owner:IsPlayer() then
					if (owner == LocalPlayer()) then
						
					end
					ownedBy = ownedBy.."\n"..owner:Name()
				end
			end
			impulse.Surface.DrawText(
				ownedBy,
				"Impulse-LightUI20",
				pos.x,
				pos.y + 20,
				col,
				1
			)
		end
	elseif doorGroup then
		impulse.Surface.DrawText(
			impulse.Config.DoorGroups[doorGroup],
			"Impulse-LightUI20",
			pos.x,
			pos.y,
			col,
			1
		)
	elseif doorOwners then
		local ownedBy
		if #doorOwners > 1 then
			ownedBy = "Owners:"
		else
			ownedBy = "Owner:"
		end

		for v,k in pairs(doorOwners) do
			local owner = Entity(k)

			if IsValid(owner) and owner:IsPlayer() then
				ownedBy = ownedBy.."\n"..owner:Name()
			end
		end
		impulse.Surface.DrawText(
			ownedBy,
			"Impulse-LightUI20",
			pos.x,
			pos.y,
			col,
			1
		)
	end

	local __dw, _ = impulse.Surface.DrawText(
		"Open",
		"Impulse-LightUI32",
		ScrW() / 2,
		ScrH() - 96,
		mcol,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_BOTTOM
	)
	local __dw = surface.GetTextSize("Open")
	impulse.DrawKey((ScrW() / 2) - __dw - 24, ScrH() - 96 - 36, "E", false, alpha)

	if LocalPlayer():CanBuyDoor(doorOwners, doorBuyable) then
		impulse.Surface.DrawText(
			"Ownable door (F2)",
			"Impulse-LightUI20",
			pos.x,
			pos.y,
			col,
			1
		)
	end
end

local function DrawEntInfo(target, alpha)
	local pos = target.LocalToWorld(target, target:OBBCenter()) + Vector(0, 0, target:OBBMaxs()[3]/2 + (target.OffsetVertical3D2D or 24))
	local scrW = ScrW()
	local scrH = ScrH()
	local hudName = target.HUDName
	local hudDesc = target.HUDDesc
	local hudCol = target.HUDColour or impulse.Config.InteractColour

	local lp = LocalPlayer()

	local ang = (pos - lp:EyePos()):GetNormalized():Angle()

	--
	ang:RotateAroundAxis(ang:Up(), -106)
	ang:RotateAroundAxis(ang:Forward(), 90)

	ang[1] = 0
	ang[3] = 90

	pos = pos + ang:Forward() * (target.OffsetHorizontal3D2D or 8)

	cam.Start3D2D(pos, ang, 0.1)
		cam.IgnoreZ(true)
			draw.DrawText(hudName, "Impulse-LightUI64-Blurred", 4, 4, ColorAlpha(color_black, alpha), 0)
			draw.DrawText(hudName, "Impulse-LightUI64", 0, 0, ColorAlpha(hudCol, alpha), 0)
			if hudDesc then
				draw.DrawText(hudDesc, "Impulse-LightUI32-Blurred", 2, 66, ColorAlpha(color_black, alpha), 0)
				draw.DrawText(hudDesc, "Impulse-LightUI32",0, 64, ColorAlpha(color_white, alpha), 0)
			end
		cam.IgnoreZ(false)
	cam.End3D2D()
end

local function DrawButtonInfo(target, alpha)	
	local angles = target.GetAngles(target)
	local pos = target.LocalToWorld(target, target:OBBCenter()) 
	local scrW = ScrW()
	local scrH = ScrH()
	local buttonId = impulse_ActiveButtons[target:EntIndex()]
	local hudCol = impulse.Config.InteractColour
	local buttonData = impulse.Config.Buttons[buttonId]

	if not buttonData then
		return
	end

	if not buttonData.desc then
		return
	end

	local lp = LocalPlayer()

	local ang = (pos - lp:EyePos()):GetNormalized():Angle()

	ang:RotateAroundAxis(ang:Up(), -106)
	ang:RotateAroundAxis(ang:Forward(), 90)

	ang[1] = 0
	ang[3] = 90

	pos = pos + ang.Forward(ang) * 8

	cam.Start3D2D(pos, ang, 0.1)
		cam.IgnoreZ(true)

			draw.SimpleText(buttonData.desc, "Impulse-LightUI64",2, 2, ColorAlpha(color_black, alpha), 0, TEXT_ALIGN_CENTER)

			draw.SimpleText(buttonData.desc, "Impulse-LightUI64",0, 0, ColorAlpha(hudCol, alpha), 0, TEXT_ALIGN_CENTER)

		cam.IgnoreZ(false)
	cam.End3D2D()
end

ICROSSHAIR_CROSS = 1
ICROSSHAIR_DOT = 2
ICROSSHAIR_CIRCLE = 3

local unitOfCone = 940.98999023438

local function DrawCrosshair(x, y)

	local wep = LocalPlayer():GetActiveWeapon()

	if not IsValid(wep) then
		return
	end

	local spread = x--{x = 0, y = 0}
	local negativespread = x--{x = 0, y = 0}

	if wep.IsPlutonic then
		wep:CalculateSpread()
		
		spread = (wep.LastSpread / wep.Primary.Cone) * (unitOfCone * wep.Primary.Cone)
	end

	local crosshairType = wep.CrosshairType or ICROSSHAIR_CROSS


	if crosshairType == ICROSSHAIR_CROSS then
		local y0 = y -spread
		local y1 = y + spread
		local x0 = x + spread
		local x1 = x - spread
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawLine(x1 - 5, y, x1 - 10, y)
		surface.DrawLine(x0 + 5, y, x0 + 10, y)
		surface.DrawLine(x, y0 - 10, x, y0 - 5)
		surface.DrawLine(x, y1 + 5, x, y1 + 10)
		surface.DrawRect(x , y, 1, 1)
	elseif crosshairType == ICROSSHAIR_DOT then
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawRect(x - 1, y - 1, 2, 2)
	elseif crosshairType == ICROSSHAIR_CIRCLE then
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawCircle(x, y, 5, 255, 255, 255, 255)
	end


end

local gladient = Material("vgui/gradient-l")

local gradient = Material("vgui/gradient-r")

local heartIcon = Material("landis/horizons/heartgrad.png")
local hungerIcon = Material("landis/horizons/breadgrad.png")

local pqmap = {
	["Low"] = 1,
	["Medium"] = 2,
	["High"] = 3
}

local flr, interp = math.floor, Lerp

local function DrawHUD()

	local qualityLevel = pqmap[impulse.GetSetting("render_quality", "High")]

	local scrW, scrH = ScrW(), ScrH()
	local colIcons = impulse.GetSetting("hud_iconcolors", false)

	surface.SetMaterial(gladient)
	surface.SetDrawColor(24,46,48,60)
	surface.DrawTexturedRect(0, scrH - 100, 540, 100)

	surface.SetDrawColor(255, 255, 255, 120)
	surface.DrawTexturedRect(0, scrH - 102, 540, 2)

	-- HEART ICON START

	-- BACKGROUND
	local healthFraction = LocalPlayer():Health() / 100

	-- Medium+ has a percent shaded health icon.
	if qualityLevel >= 2 then
		

		render.SetScissorRect(80, scrH - 76, 128, (scrH - 28) + (48 * (1 - healthFraction)), true)

		surface.SetMaterial(heartIcon)
		surface.SetDrawColor(100, 100, 100, 255)
		surface.DrawTexturedRect(80, scrH - 76, 48, 48)

		render.SetScissorRect(80, (scrH - 28) - (48 * (healthFraction)), 128, scrH - 28, true)
	end

	surface.SetMaterial(heartIcon)
	if colIcons then
		surface.SetDrawColor(255, 59, 48, 255)
	else
		surface.SetDrawColor(255, 255, 255, 255)
	end
	surface.DrawTexturedRect(80, scrH - 76, 48, 48)

	if qualityLevel >= 3 then

		-- HIGH QUALITY, FILTER SHADED BAR FOR FRACTION OF THE SHADE TO BE VISIBLE, PREVENTING PIXEL JUMPING!
		local heightFX = 48 * healthFraction
		local fxY = flr((scrH - 28) + (heightFX))
		--print(fxY)
		local interPixelDistanceShade = ((heightFX) % 1)

		if colIcons then
			local r, g, b = interp(interPixelDistanceShade, 100, 255), interp(interPixelDistanceShade, 100, 59), interp(interPixelDistanceShade, 100, 48)
			surface.SetDrawColor(r, g, b, 255)
		else
			local r, g, b = interp(interPixelDistanceShade, 100, 255), interp(interPixelDistanceShade, 100, 255), interp(interPixelDistanceShade, 100, 255)
			surface.SetDrawColor(0, g, 0, 255)
		end

		render.SetScissorRect(80,(scrH - 76) + (fxY - 1), 128,(scrH - 76) + (fxY), true)

		surface.SetMaterial(heartIcon)
		surface.DrawTexturedRect(80, scrH - 76, 48, 48)

		render.SetScissorRect(0, 0, 0, 0, false)
		
	elseif qualityLevel >= 2 then
		render.SetScissorRect(0, 0, 0, 0, false)
	end

	-- HEART ICON END

	local health = LocalPlayer():Health()
	surface.SetFont("Impulse-LightUI64")
	
	
	local textW, textH = surface.GetTextSize(health)
	surface.SetTextPos(146, scrH - 50 - (textH/2))

	surface.SetFont("Impulse-LightUI64-Blurred")
	surface.SetTextColor(0, 0, 0, 255)
	surface.DrawText(health, false)

	surface.SetTextPos(144, scrH - 52 - (textH/2))

	surface.SetFont("Impulse-LightUI64")
	surface.SetTextColor(255, 255, 255, 255)
	surface.DrawText(health, false)

	surface.SetFont("Impulse-LightUI32")
	local tw2, th2 = surface.GetTextSize("| 100")

	surface.SetTextPos(162 + textW, scrH - 50 - (th2/2))
	surface.SetTextColor(0, 0, 0, 255)
	surface.SetFont("Impulse-LightUI32-Blurred")
	surface.DrawText("| 100")

	surface.SetTextPos(160 + textW, scrH - 52 - (th2/2))
	surface.SetTextColor(140, 140, 140, 255)
	surface.SetFont("Impulse-LightUI32")
	surface.DrawText("| 100")

	local hunger = LocalPlayer():GetSyncVar(SYNC_HUNGER, 100)

	local hungerFraction = hunger / 100

	render.SetScissorRect(300, scrH - 76, 348, (scrH - 76) + (48 * (1 - hungerFraction)), true)

	surface.SetMaterial(hungerIcon)
	surface.SetDrawColor(100, 100, 100, 255)
	surface.DrawTexturedRect(300, scrH - 76, 48, 48)

	render.SetScissorRect(0, 0, 0, 0, false)
	render.SetScissorRect(300, (scrH - 28) - (48 * (hungerFraction)), 348, scrH - 28, true)

	surface.SetMaterial(hungerIcon)
	if colIcons then
		surface.SetDrawColor(255, 159, 10, 255)
	else
		surface.SetDrawColor(255, 255, 255, 255)
	end
	surface.DrawTexturedRect(300, scrH - 76, 48, 48)

	render.SetScissorRect(0, 0, 0, 0, false)
	
	surface.SetFont("Impulse-LightUI64")

	surface.SetTextColor(255, 255, 255, 255)
	
	local textW2, textH2 = surface.GetTextSize(hunger)
	surface.SetTextPos(366, scrH - 50 - (textH2/2))
	surface.SetTextColor(0, 0, 0, 255)
	surface.SetFont("Impulse-LightUI64-Blurred")
	surface.DrawText(hunger)

	surface.SetTextPos(364, scrH - 52 - (textH2/2))
	surface.SetTextColor(255, 255, 255, 255)
	surface.SetFont("Impulse-LightUI64")
	surface.DrawText(hunger)

	surface.SetFont("Impulse-LightUI32")
	local tw3, th3 = surface.GetTextSize("| 100")

	surface.SetTextColor(0, 0, 0, 255)
	surface.SetTextPos(382 + textW2, scrH - 50 - (th3/2))
	surface.SetFont("Impulse-LightUI32-Blurred")
	surface.DrawText("| 100")

	surface.SetTextColor(140, 140, 140, 255)
	surface.SetTextPos(380 + textW2, scrH - 52 - (th3/2))
	surface.SetFont("Impulse-LightUI32")
	surface.DrawText("| 100")

	local lp = LocalPlayer()

	if lp:GetSyncVar(SYNC_ARRESTED, false) == true and impulse_JailTimeEnd and impulse_JailTimeEnd > CurTime() then
		local timeLeft = math.ceil(impulse_JailTimeEnd - CurTime())
		local t = "Sentence remaining: "..string.FormattedTime(timeLeft, "%02i:%02i")

		surface.SetFont("Impulse-LightUI32")
		local _w, _h = surface.GetTextSize(t)

		surface.SetTextColor(0, 0, 0, 255)
		surface.SetTextPos(scrW/2 - (_w/2) + 2, scrH-38)
		surface.SetFont("Impulse-LightUI32-Blurred")
		surface.DrawText(t)

		surface.SetTextColor(255, 255, 255, 255)
		surface.SetTextPos(scrW/2 - (_w/2), scrH-40)
		surface.SetFont("Impulse-LightUI32")
		surface.DrawText(t)

		surface.SetMaterial(exitIcon)
		surface.DrawTexturedRect(scrW/2 - (_w/2) - 34, scrH-38, 32, 32)
		
		--draw.DrawText(t, "Impulse-Elements19", scrW/, scrH-30, color_white, TEXT_ALIGN_LEFT)
		aboveHUDUsed = true
	end

	local bIsBleeding = lp:Bleeding()
	local bHasBrokenLegs = lp:HasBrokenLegs()

	if (bIsBleeding) then

		surface.SetFont("Impulse-LightUI32")
		surface.SetTextColor(255, 59, 48, 255)
		
		local _w, _h = surface.GetTextSize("BLEEDING")

		surface.SetDrawColor(255, 59, 48, 255)
		surface.SetMaterial(bleedingIcon)
		surface.DrawTexturedRect(scrW * 0.5 - (_w/2) - 18, scrH - (_h/2) - 40, 32, 32)

		surface.SetTextPos(scrW * 0.5 - (_w/2) + 18, scrH - (_h/2) - 40)
		surface.DrawText("BLEEDING")

	end

	-- WEAPON SHIT

	local wep = LocalPlayer():GetActiveWeapon()

	if not IsValid(wep) then
		return
	end
	
	local wc = wep:GetClass()

	if wc == "weapon_physgun" or wc == "gmod_tool" then
		surface.SetMaterial(gradient)
		surface.SetDrawColor(24,46,48,60)
		surface.DrawTexturedRect(scrW-540, scrH - 100, 540, 100)

		surface.SetDrawColor(255, 255, 255, 120)
		surface.DrawTexturedRect(scrW-540, scrH - 102, 540, 2)

		surface.SetFont("Impulse-LightUI64")

		surface.SetTextColor(255, 255, 255, 255)
		local tx = LocalPlayer():GetSyncVar(SYNC_PROPCOUNT,0) .. " Props"
		local tw5, th5 = surface.GetTextSize(tx)

		surface.SetTextPos(scrW-80-tw5, scrH-52-(th5/2))
		surface.DrawText(tx)

		surface.SetMaterial(warningIcon)
		surface.SetDrawColor(255, 0, 0)
		local warnY =  scrH / 2 + scrH / 4
		surface.DrawTexturedRect(scrW / 2 - 32, warnY - 32, 64, 64)

		impulse.Surface.DrawText(
			"Warning",
			"Impulse-LightUI48",
			scrW / 2,
			warnY + 38,
			Color(255, 0, 0),
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_TOP
		)

		impulse.Surface.DrawText(
			"This tool may not be used to speak out-of-character",
			"Impulse-LightUI20",
			scrW / 2,
			warnY + 80,
			Color(255, 255, 255),
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_TOP
		)
		impulse.Surface.DrawText(
			"This tool must be put away in any in-game scenario.",
			"Impulse-LightUI20",
			scrW / 2,
			warnY + 100,
			Color(255, 255, 255),
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_TOP
		)
		 
	end

	local clip = wep:Clip1()

	if clip == -1 or wep.IsMelee then
		return
	end

	surface.SetMaterial(gradient)
	surface.SetDrawColor(24,46,48,60)
	surface.DrawTexturedRect(scrW-540, scrH - 100, 540, 100)

	surface.SetDrawColor(255, 255, 255, 120)
	surface.DrawTexturedRect(scrW-540, scrH - 102, 540, 2)

	local maxclip = wep:GetMaxClip1()
	local reserve = wep.Ammo1 and wep:Ammo1() or 0 -- Weird edge case where some things don't have an Ammo1 func?

	surface.SetFont("Impulse-LightUI64")
	surface.SetTextColor(255, 255, 255, 255)
	
	local textW3, textH3 = impulse.Surface.DrawText(
		clip,
		"Impulse-LightUI64",
		scrW-360,
		scrH - 52,
		color_white,
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_CENTER
	)

	surface.SetFont("Impulse-LightUI32")
	surface.SetTextColor(140, 140, 140, 255)

	local maxclipt = "| " .. maxclip .. " MAX"

	impulse.Surface.DrawText(
		maxclipt,
		"Impulse-LightUI32",
		scrW-344+textW3,
		scrH - 52,
		Color(140, 140, 140),
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_CENTER
	)

	local tw5, th5 = surface.GetTextSize(reserve)

	impulse.Surface.DrawText(
		reserve,
		"Impulse-LightUI32",
		scrW - 40,
		scrH - 52,
		Color(140, 140, 140),
		TEXT_ALIGN_RIGHT,
		TEXT_ALIGN_CENTER
	)

	impulse.Surface.DrawText(
		"RESERVE",
		"Impulse-LightUI20",
		scrW - 40 - (tw5/2),
		scrH - 40,
		Color(140, 140, 140),
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_TOP
	)

end

local deathEndingFade
local deathEnding
local deathRegistered
local deathWait
-- Potential Micro-optimization: Replace all realtime math calculations with cached values (updated on a hook for screen size changes to prevent everything breaking.) - sophie
function GM:HUDPaint()
	local health = LocalPlayer():Health()
	local lp = LocalPlayer()
	local lpTeam = lp:Team()
	local scrW, scrH = ScrW(), ScrH()
	local hudWidth, hudHeight = 300, 178
	local seeColIcons = impulse.GetSetting("hud_iconcolors")
	local aboveHUDUsed = false
	local deathSoundPlayed

	if SERVER_DOWN and CRASHSCREEN_ALLOW then
		if not IsValid(CRASH_SCREEN) then
			CRASH_SCREEN = vgui.Create("impulseCrashScreen")
		end
	elseif IsValid(CRASH_SCREEN) and not CRASH_SCREEN.fadin then
		CRASH_SCREEN.fadin = true
		CRASH_SCREEN:AlphaTo(0, 1.2, nil, function()
			if IsValid(CRASH_SCREEN) then
				CRASH_SCREEN:Remove()
			end
		end)
	end

	if not lp:Alive() and not SCENES_PLAYING then
		local ft = FrameTime()

		if not deathRegistered then
			local deathSound = hook.Run("GetDeathSound") or "horizons_fx/deathstinger.wav"
			surface.PlaySound(deathSound)

			deathWait = CurTime() + impulse.Config.RespawnTime
			if lp:IsDonator() then
				deathWait = CurTime() + impulse.Config.RespawnTimeDonator
			end

			deathRegistered = true
			deathEnding = true
		end

		fde = math.Clamp(fde + ft * 1, 0, 10)

		if fde < 1 then
			return
		end
		local fder = math.Clamp(fde - 1, 0, 1)
		local fder2 = math.Clamp(fde - 1.5, 0, 6) / 6
		painFde = 0.7

		surface.SetDrawColor(0, 0, 0, math.ceil(fder2 * 255))
		surface.DrawRect(-1, -1, ScrW() +2, ScrH() +2)

		local textCol = Color(255, 255, 255, math.ceil(fder * 255))
		local shadCol = Color(0, 0, 0, math.ceil(fder * 255))
		local redCol = Color(255, 59, 48, math.ceil(fder * 255))

		DrawMotionBlur(0.1, 200 - math.ceil(fder + fder2 * 10), 0)
		DrawSharpen(fder + fder2 * 5, 1)
		DrawToyTown(fder + fder2 * 10, ScrH())

		impulse.Surface.DrawText(
			"YOU DIED",
			"Impulse-LightUI128",
			scrW / 2,
			scrH / 2,
			redCol,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_BOTTOM
		)

		local wait = math.ceil(deathWait - CurTime())

		if wait > 0 then

			impulse.Surface.DrawText(
				"You will respawn in "..wait.." "..(wait == 1 and "second" or "seconds")..".",
				"Impulse-LightUI32",
				scrW/2,
				(scrH/2)+6,
				textCol,
				TEXT_ALIGN_CENTER,
				TEXT_ALIGN_CENTER
			)

			impulse.Surface.DrawText(
				"WARNING",
				"Impulse-LightUI32",
				scrW/2,
				(scrH/2)+100,
				redCol,
				TEXT_ALIGN_CENTER,
				TEXT_ALIGN_BOTTOM
			)
			
			impulse.Surface.DrawText(
				"NLR applies, you may not return to this area until 5 minutes after your death.",
				"Impulse-LightUI20",
				scrW/2,
				(scrH/2)+100,
				textCol,
				TEXT_ALIGN_CENTER,
				TEXT_ALIGN_TOP
			)
			
			impulse.Surface.DrawText(
				"If you feel you were unfairly killed, submit a report (F3) for assistance.",
				"Impulse-LightUI20",
				scrW/2,
				scrH-32,
				textCol,
				TEXT_ALIGN_CENTER,
				TEXT_ALIGN_BOTTOM
			)
		end

		if IsValid(PlayerIcon) then
			PlayerIcon:Remove()
		end
		
		return
	else
		if FORCE_FADESPAWN or deathEnding then
			deathEnding = true
			FORCE_FADESPAWN = nil 

			local ft = FrameTime()
			deathEndingFade = math.Clamp((deathEndingFade or 0) + ft * .15, 0, 1)

			local val = 255 - math.ceil(deathEndingFade * 255)

			if deathEndingFade != 1 then
				surface.SetDrawColor(0, 0, 0, val)
				surface.DrawRect(0, 0, ScrW(), ScrH())
			else
				deathEnding = false
				deathEndingFade = 0
			end
		end

		fde = 0

		if deathRegistered then
			deathRegistered = false
		end

		LocalPlayer().Ragdoll = nil
	end

	if impulse.hudEnabled == false or (impulse.CinematicIntro and LocalPlayer():Alive()) or (IsValid(impulse.MainMenu) and impulse.MainMenu:IsVisible()) or hook.Run("ShouldDrawHUDBox") == false then
		if IsValid(PlayerIcon) then
			PlayerIcon:Remove()
		end
		return
	end

	-- Draw any HUD stuff under this comment

	if lasthealth and health < lasthealth then
		painFde = 0
	end

	painFt = FrameTime() * 2
	painFde = math.Clamp(painFde + painFt, 0, 0.7)

	surface.SetDrawColor(ColorAlpha(painCol, 255 * (0.7 - painFde)))
	surface.DrawRect(0, 0, scrW, scrH)

	--Crosshair
	local x, y
	local curWep = lp:GetActiveWeapon()

	if not curWep or not curWep.ShouldDrawCrosshair or (curWep.ShouldDrawCrosshair and curWep.ShouldDrawCrosshair(curWep) != false) then
		if impulse.GetSetting("view_thirdperson") == true then
			local p = LocalPlayer():GetEyeTrace().HitPos:ToScreen()
			x, y = p.x, p.y
		else
			x, y = scrW/2, scrH/2
		end

		if curWep.IsPlutonic then
			local sway_x = ScreenScale(curWep.VMDeltaX * 2)
			x = x + sway_x

			local sway_y = ScreenScale(curWep.VMDeltaY * 2)
			y = y + sway_y
		end

		DrawCrosshair(x, y)
	end

	-- HUD

	y = scrH-hudHeight-8-10
	DrawHUD()
	DrawWeaponSelect()

	local iconsX = 315
	local bleedIconCol

	surface.SetDrawColor(color_white)

	if not aboveHUDUsed then
		if impulse.ShowZone then
			if IsValid(zoneLbl) then
				zoneLbl:Remove()	
			end

			zoneLbl = vgui.Create("impulseZoneLabel")
			zoneLbl:SetPos(80, scrH * 0.37)

			local time = GetGlobalFloat("dnc_time", 0);

			zoneLbl.Zone = lp:GetZoneName()

			impulse.ShowZone = false
		end
	elseif zoneLbl and IsValid(zoneLbl) then
		zoneLbl:Remove()
	end
	
	local bodygroupChange = false

	if (nextBodygroupChangeCheck or 0) < CurTime() and IsValid(PlayerIcon) then
		local curBodygroups = lp:GetBodyGroups()
		local ent = PlayerIcon.Entity

		for v,k in pairs(lastBodygroups) do
			if not curBodygroups[v] or ent:GetBodygroup(k.id) != LocalPlayer():GetBodygroup(curBodygroups[v].id) then
				bodygroupChange = true
				break
			end
		end

		nextBodygroupChangeCheck = CurTime() + 0.5
	end

	local isPreview = GetConVar("impulse_ispreview"):GetBool()

	if isPreview then
		-- watermark
		surface.SetDrawColor(watermarkCol)
		surface.SetMaterial(watermark)
		surface.DrawTexturedRect(32, scrH - 202, 112, 30)

		surface.SetTextPos(34, scrH - 170)
		surface.SetTextColor(0, 0, 0, 255)
		surface.SetFont("Impulse-LightUI20-Blurred")
		surface.DrawText("PREVIEW BUILD - "..impulse.Version.." - "..LocalPlayer():SteamID64().. " - ".. os.date("%H:%M:%S - %m/%d/%Y", os.time()))
		surface.SetTextPos(34, scrH - 150)
		surface.DrawText("SCHEMA: "..SCHEMA_NAME.." VERSION: "..impulse.Config.SchemaVersion or "?")

		surface.SetTextPos(32, scrH - 172)
		surface.SetTextColor(watermarkCol)
		surface.SetFont("Impulse-LightUI20")
		surface.DrawText("PREVIEW BUILD - "..impulse.Version.." - "..LocalPlayer():SteamID64().. " - ".. os.date("%H:%M:%S - %m/%d/%Y", os.time()))
		surface.SetTextPos(32, scrH - 152)
		surface.DrawText("SCHEMA: "..SCHEMA_NAME.." VERSION: "..impulse.Config.SchemaVersion or "?")
	end

	-- dev hud

	if impulse_DevHud and (lp:IsSuperAdmin() or lp:IsDeveloper()) then
		local trace = {}
		trace.start = lp:EyePos()
		trace.endpos = trace.start + lp:GetAimVector() * 3000
		trace.filter = lp

		local traceData = util.TraceLine(trace)
		local traceEnt = traceData.Entity

		if traceEnt and traceEnt != NULL then
			surface.SetTextPos((scrW / 2) + 30, (scrH / 2) - 100)
			surface.DrawText(tostring(traceEnt))

			surface.SetTextPos((scrW / 2) + 30, (scrH / 2) - 80)
			surface.DrawText(traceEnt:GetModel().."     "..traceData.HitTexture or "")

			local syncData = impulse.Sync.Data[traceEnt:EntIndex()]
			local netData
			local y = (scrH / 2) - 40

			if syncData then
				for v,k in pairs(syncData) do
					if type(k) == "table" then
						k = table.ToString(k)
					end

					surface.SetTextPos((scrW / 2) + 30, y)
					surface.DrawText("syncvalue: "..v.." ; "..tostring(k))
					y = y + 20
				end
			end

			if IsValid(traceEnt) and traceEnt.GetNetworkVars then
				netData = traceEnt:GetNetworkVars()
			end

			if netData then
				for v,k in pairs(netData) do
					surface.SetTextPos((scrW / 2) + 30, y)
					surface.DrawText("netvalue: "..v.." ; "..tostring(k))
					y = y + 20
				end
			end
		end

		surface.SetTextPos(400, scrH / 1.5)
		surface.DrawText(tostring(lp:GetPos()))
		surface.SetTextPos(400, (scrH / 1.5) + 20)
		surface.DrawText(tostring(lp:GetAngles()))
		surface.SetTextPos(400, (scrH / 1.5) + 40)
		surface.DrawText(lp:GetVelocity():Length2D())
		local PS14 = render.SupportsPixelShaders_1_4()
		local PS20 = render.SupportsPixelShaders_2_0()
		local VS20 = render.SupportsVertexShaders_2_0()
		surface.SetTextPos(400, (scrH / 1.5) + 60)
		surface.DrawText("PS14: "..tostring(PS14).." PS20: "..tostring(PS20).." VS20: "..tostring(VS20))
	
	end

	lasthealth = health
end

local nextOverheadCheck = 0
local lastEnt
local trace = {}
local approach = math.Approach
local letterboxFde = 0
local textFde = 0
local holdTime
overheadEntCache = {}
-- overhead info is HEAVILY based off nutscript. I'm not taking credit for it. but it saves clients like 70 fps so its worth it
function GM:HUDPaintBackground()

	if impulse.GetSetting("hud_vignette") == true then
		surface.SetMaterial(vignette)
		surface.SetDrawColor(vig_alpha_normal)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	end

	if impulse.hudEnabled == false then
		return
	end

	local lp = LocalPlayer()
	local realTime = RealTime()
	local frameTime = FrameTime()

	if nextOverheadCheck < realTime then
		nextOverheadCheck = realTime + 0.5
		
		trace.start = lp.GetShootPos(lp)
		trace.endpos = trace.start + lp.GetAimVector(lp) * 300
		trace.filter = lp
		trace.mins = Vector(-4, -4, -4)
		trace.maxs = Vector(4, 4, 4)
		trace.mask = MASK_SHOT_HULL

		lastEnt = util.TraceHull(trace).Entity

		if IsValid(lastEnt) then
			overheadEntCache[lastEnt] = true
		end
	end

	for entTarg, shouldDraw in pairs(overheadEntCache) do
		if IsValid(entTarg) then

			local goal = shouldDraw and 255 or 0
			local alpha = approach(entTarg.overheadAlpha or 0, goal, frameTime * 1000)

			if lastEnt != entTarg then
				overheadEntCache[entTarg] = false
			end

			if alpha > 0 then
				if not entTarg:GetNoDraw() then
					if entTarg:IsPlayer() then
						if impulse.GetSetting("hud_hints", false) then
							if entTarg.HoverHint then
								if not entTarg.PixVisHandle then
									entTarg.PixVisHandle = util.GetPixelVisibleHandle()
								end

								local visible = util.PixelVisible(entTarg:GetPos(), 128, entTarg.PixVisHandle)
								alpha = alpha * visible
								
								if entTarg.HoverText then
									local __dw, _ = impulse.Surface.DrawText(
										entTarg.HoverText,
										"Impulse-LightUI32",
										ScrW() / 2,
										ScrH() - 96,
										ColorAlpha(color_white, alpha),
										TEXT_ALIGN_CENTER,
										TEXT_ALIGN_BOTTOM
									)
									local __dw = surface.GetTextSize(entTarg.HoverText)
									impulse.DrawKey((ScrW() / 2) - (__dw / 2) - 50, ScrH() - 96 - 36, entTarg.HoverKey, false, alpha)
								end
							end
						end
					elseif entTarg:IsDoor() then
						DrawDoorInfo(entTarg, alpha)
					end
				end
			end

			entTarg.overheadAlpha = alpha

			if alpha == 0 and goal == 0 then
				overheadEntCache[entTarg] = nil
			end
		else
			overheadEntCache[entTarg] = nil
		end
	end
	
	if impulse.CinematicIntro and lp:Alive() then
		local ft = FrameTime()
		local maxTall =  ScrH() * .12

		if holdTime and holdTime + 6 < CurTime() then
			letterboxFde = math.Clamp(letterboxFde - ft * .5, 0, 1)
			textFde = math.Clamp(textFde - ft * .3, 0, 1)

			if letterboxFde == 0 then
				impulse.CinematicIntro = false
			end
		elseif holdTime and holdTime + 4 < CurTime() then
			textFde = math.Clamp(textFde - ft * .3, 0, 1)
		else
			letterboxFde = math.Clamp(letterboxFde + ft * .5, 0, 1)

			if letterboxFde == 1 then
				textFde = math.Clamp(textFde + ft * .1, 0, 1)
				holdTime = holdTime or CurTime()
			end
		end

		surface.SetDrawColor(color_black)
		surface.DrawRect(0, 0, ScrW(), (maxTall * letterboxFde))
		surface.DrawRect(0, (ScrH() - (maxTall * letterboxFde)) + 1, ScrW(), maxTall)

		draw.DrawText(impulse.CinematicTitle, "Impulse-Elements36", ScrW() - 150, ScrH() * .905, ColorAlpha(color_white, (255 * textFde)), TEXT_ALIGN_RIGHT)
	else
		letterboxFde = 0
		textFde = 0
		holdTime = nil
	end
end

hook.Add("PostDrawTranslucentRenderables", "DrawEntInfo", function(bDrawingDepth,bDrawingSkybox)
	if bDrawingDepth or bDrawingSkybox then
		return
	end
	local lp = LocalPlayer()
	local realTime = RealTime()
	local frameTime = FrameTime()

	for entTarg, shouldDraw in pairs(overheadEntCache) do
		if IsValid(entTarg) then
			local alpha =entTarg.overheadAlpha

			if lastEnt != entTarg then
				overheadEntCache[entTarg] = false
			end

			if alpha > 0 then
				if not entTarg:GetNoDraw() then
					if entTarg:IsPlayer() then
						DrawOverheadInfo(entTarg, alpha)
					elseif entTarg.HUDName then
						DrawEntInfo(entTarg, alpha)
					elseif entTarg:IsDoor() then
						--DrawDoorInfo(entTarg, alpha)
					elseif impulse_ActiveButtons and impulse_ActiveButtons[entTarg.EntIndex(entTarg)] then
						DrawButtonInfo(entTarg, alpha)
					end
				end
			end
		else
			overheadEntCache[entTarg] = nil
		end
	end
end)

concommand.Add("impulse_cameratoggle", function()
	impulse.hudEnabled = (!impulse.hudEnabled)

	if not IsValid(impulse.chatBox.frame) then
		return
	end

	if impulse.hudEnabled then
		impulse.chatBox.frame:Show()
	else
		impulse.chatBox.frame:Hide()
	end
end)
end
