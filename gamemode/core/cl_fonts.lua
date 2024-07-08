--- Different fonts for all different styles.
-- @module Fonts

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

-- Font's are still a bit squiffy, they will all be scaled properly soon. Also - please name none specific fonts 'Impulse-Elements<description>'

--- Every single Impulse-Elements font given to you by the framework, all fonts use the Segoe UI family.
-- @realm client
-- @field Impulse-Elements11
-- @field Impulse-Elements13
-- @field Impulse-Elements14
-- @field Impulse-Elements14-Shadow
-- @field Impulse-Elements16
-- @field Impulse-Elements16-Shadow
-- @field Impulse-Elements17
-- @field Impulse-Elements17-Shadow
-- @field Impulse-Elements18
-- @field Impulse-Elements18-Shadow
-- @field Impulse-Elements19
-- @field Impulse-Elements19-Shadow
-- @field Impulse-Elements20-Shadow This is actual 18, but not worth the time to fix.
-- @field Impulse-Elements20A-Shaodw This is actually 20.
-- @field Impulse-Elements22-Shadow
-- @field Impulse-Elements23
-- @field Impulse-Elements23-Shadow
-- @field Impulse-Elements23-Italic
-- @field Impulse-Elements24-Shadow
-- @field Impulse-Elements27
-- @field Impulse-Elements27-Shadow
-- @field Impulse-Elements32
-- @field Impulse-Elements32-Shadow
-- @field Impulse-Elements36
-- @field Impulse-Elements48
-- @field Impulse-Elements72-Shadow
-- @field Impulse-Elements78
-- @table ImpulseElements

surface.CreateFont("impulseHL2RPOverlayBigger", {
    font = "Courier New",
    size = 30,
    weight = 1700,
    antialias = true,
    outline = false
})

surface.CreateFont("Impulse-Elements18", {
    font = "Segoe UI Semilight",
    size = 18,
    weight = 800,
    antialias = true,
    shadow = false,
})

surface.CreateFont("combineTextSmol", {
    font = "Combine 17",
    size = 18,
    weight = 800,
    antialias = true,
    shadow = false,
})

surface.CreateFont("combineTextSmol-Blurred", {
    font = "Combine 17",
    size = 18,
    weight = 800,
    antialias = true,
    shadow = false,
    blursize = 6
})

surface.CreateFont("Impulse-Elements19", {
    font = "Segoe UI Semilight",
    size = 19,
    weight = 1000,
    antialias = true,
    shadow = false,
})

surface.CreateFont("Impulse-Elements16", {
    font = "Segoe UI Semilight",
    size = 16,
    weight = 800,
    antialias = true,
    shadow = false,
})

surface.CreateFont("Impulse-Elements17", {
    font = "Segoe UI Semilight",
    size = 17,
    weight = 800,
    antialias = true,
    shadow = false,
})

surface.CreateFont("Impulse-Elements17-Shadow", {
    font = "Segoe UI Semilight",
    size = 17,
    weight = 800,
    antialias = true,
    shadow = true
})

surface.CreateFont("Impulse-Elements14", {
    font = "Segoe UI Semilight",
    size = 14,
    weight = 800,
    antialias = true,
    shadow = false,
})

surface.CreateFont("Impulse-Elements14-Shadow", {
    font = "Segoe UI Semilight",
    size = 14,
    weight = 800,
    antialias = true,
    shadow = true,
})

surface.CreateFont("Impulse-Elements18-Shadow", {
    font = "Segoe UI Semilight",
    size = 18,
    weight = 900,
    antialias = true,
    shadow = true,
})

surface.CreateFont("Impulse-Elements16-Shadow", {
    font = "Segoe UI Semilight",
    size = 16,
    weight = 900,
    antialias = true,
    shadow = true,
})

surface.CreateFont("Impulse-Elements19-Shadow", {
    font = "Segoe UI Semilight",
    size = 19,
    weight = 900,
    antialias = true,
    shadow = true,
})

surface.CreateFont("Impulse-Elements20-Shadow", { -- dont change this font to actually be 20 its a dumb mistake
    font = "Segoe UI Semilight",
    size = 18,
    weight = 900,
    antialias = true,
    shadow = true,
})

surface.CreateFont("Impulse-Elements20A-Shadow", { -- dont change this font to actually be 20 its a dumb mistake
    font = "Segoe UI Semilight",
    size = 20,
    weight = 900,
    antialias = true,
    shadow = true,
})

surface.CreateFont("Impulse-CharacterInfo", {
    font = "Segoe UI Semilight",
    size = 34,
    weight = 900,
    antialias = true,
    shadow = true,
    outline = true
})

surface.CreateFont("Impulse-CharacterInfo-NO", {
    font = "Segoe UI Semilight",
    size = 34,
    weight = 900,
    antialias = true,
    shadow = true,
    outline = false
})

surface.CreateFont("Impulse-Elements13", {
    font = "Segoe UI Semilight",
    size = 13,
    weight = 800,
    antialias = true,
    shadow = false,
})

surface.CreateFont("Impulse-Elements22-Shadow", {
    font = "Segoe UI Semilight",
    size = 22,
    weight = 700,
    antialias = true,
    shadow = true,
})

surface.CreateFont("Impulse-Elements72-Shadow", {
    font = "Segoe UI Semilight",
    size = 72,
    weight = 700,
    antialias = true,
    shadow = true,
})

surface.CreateFont("Impulse-Elements23", {
    font = "Segoe UI Semilight",
    size = 23,
    weight = 800,
    antialias = true,
    shadow = false,
})

surface.CreateFont("Impulse-Elements23-Shadow", {
    font = "Segoe UI Semilight",
    size = 23,
    weight = 800,
    antialias = true,
    shadow = true,
})

surface.CreateFont("Impulse-Elements23-Italic", {
    font = "Segoe UI Semilight",
    size = 23,
    weight = 800,
    italic = true,
    antialias = true,
    shadow = true,
})

surface.CreateFont("Impulse-Elements24-Shadow", {
    font = "Segoe UI Semilight",
    size = 24,
    weight = 800,
    antialias = true,
    shadow = true,
})

surface.CreateFont("Impulse-Elements27", {
    font = "Segoe UI Semilight",
    size = 27,
    weight = 800,
    antialias = true,
    shadow = true,
})

surface.CreateFont("Impulse-Elements27-Shadow", {
    font = "Segoe UI Semilight",
    size = 27,
    weight = 800,
    antialias = true,
    shadow = true,
})

surface.CreateFont("Impulse-Elements32", {
    font = "Segoe UI Semilight",
    size = 32,
    weight = 800,
    antialias = true,
    shadow = false,
})

surface.CreateFont("Impulse-Elements32-Shadow", {
    font = "Segoe UI Semilight",
    size = 32,
    weight = 800,
    antialias = true,
    shadow = true,
})

surface.CreateFont("Impulse-Elements36", {
    font = "Segoe UI Semilight",
    size = 36,
    weight = 800,
    antialias = true,
    shadow = false,
})

surface.CreateFont("Impulse-Elements48", {
    font = "Segoe UI Semilight",
    size = 48,
    weight = 1000,
    antialias = true,
    shadow = false,
})

surface.CreateFont("Impulse-Elements48-Shadow", {
    font = "Segoe UI Semilight",
    size = 48,
    weight = 1000,
    antialias = true,
    shadow = true,
})

surface.CreateFont("Impulse-Elements49", {
    font = "Segoe UI Semilight",
    size = 49,
    weight = 1000,
    antialias = true,
    shadow = false,
})

surface.CreateFont("Impulse-Elements50", {
    font = "Segoe UI Semilight",
    size = 50,
    weight = 1000,
    antialias = true,
    shadow = false,
})

surface.CreateFont("Impulse-Elements50-Shadow", {
    font = "Segoe UI Semilight",
    size = 50,
    weight = 1000,
    antialias = true,
    shadow = true,
})

surface.CreateFont("Impulse-Elements51", {
    font = "Segoe UI Semilight",
    size = 51,
    weight = 1000,
    antialias = true,
    shadow = false,
})

surface.CreateFont("Impulse-Elements52", {
    font = "Segoe UI Semilight",
    size = 52,
    weight = 1000,
    antialias = true,
    shadow = false,
})

surface.CreateFont("Impulse-Elements52-Shadow", {
    font = "Segoe UI Semilight",
    size = 52,
    weight = 1000,
    antialias = true,
    shadow = true,
})

surface.CreateFont("Impulse-Elements78", {
    font = "Segoe UI Semilight",
    size = 78,
    weight = 1000,
    antialias = true,
    shadow = false,
})

surface.CreateFont("Impulse-Elements108", {
    font = "Segoe UI Semilight",
    size = 108,
    weight = 1000,
    antialias = true,
    shadow = false,
})

surface.CreateFont("Impulse-ChatSmall", {
    font = "Segoe UI Semilight",
    size = (impulse.IsHighRes() and 20 or 16),
    weight = 700,
    antialias = true,
    shadow = true,
})

surface.CreateFont("Impulse-ChatMedium", {
    font = "Segoe UI Semilight",
    size = (impulse.IsHighRes() and 21 or 17),
    weight = 700,
    antialias = true,
    shadow = true,
})

surface.CreateFont("Impulse-ChatRadio", {
    font = "Consolas",
    size = (impulse.IsHighRes() and 24 or 17),
    weight = (impulse.IsHighRes() and 700 or 500),
    antialias = true,
    shadow = true,
})

surface.CreateFont("Impulse-ChatLarge", {
    font = "Segoe UI Semilight",
    size = (impulse.IsHighRes() and 27 or 20),
    weight = (impulse.IsHighRes() and 1100 or 700),
    antialias = true,
    shadow = true,
})

surface.CreateFont("Impulse-UI-SmallFont", {
    font = "Segoe UI Semilight",
    size = math.max(ScreenScale(6), 17),
    extended = true,
    weight = 500
})

surface.CreateFont("Impulse-SpecialFont", {
    font = "Segoe UI Semilight",
    size = 33,
    weight = 3700,
    antialias = true,
    shadow = true
})

surface.CreateFont("Impulse-LightUI128", {
    font = "Segoe UI Light",
    size = 128,
    weight = 100,
    antialias = true,
    blursize = 0
})

surface.CreateFont("Impulse-LightUI128-Blurred", {
    font = "Segoe UI Light",
    size = 128,
    weight = 100,
    antialias = true,
    blursize = 6
})

surface.CreateFont("Impulse-KeyHint", {
    font = "Segoe UI Black",
    size = 32,
    weight = 1000,
    antialias = true,
    blursize = 0
})

impulse.Surface.DefineTypeFace("Impulse-LightUI128", 5, 5, 255)

surface.CreateFont("Impulse-LightUI96", {
    font = "Segoe UI Light",
    size = 96,
    weight = 100,
    antialias = true,
    blursize = 0
})

surface.CreateFont("Impulse-LightUI96-Blurred", {
    font = "Segoe UI Light",
    size = 96,
    weight = 100,
    antialias = true,
    blursize = 3
})

impulse.Surface.DefineTypeFace("Impulse-LightUI96", 4, 4, 255)

surface.CreateFont("Impulse-LightUI64", {
    font = "Segoe UI Light",
    size = 64,
    weight = 100,
    antialias = true,
    blursize = 0
})

surface.CreateFont("Impulse-LightUI64-Blurred", {
    font = "Segoe UI Light",
    size = 64,
    weight = 100,
    antialias = true,
    blursize = 3
})

impulse.Surface.DefineTypeFace("Impulse-LightUI64", 3, 3, 255)

surface.CreateFont("Impulse-LightUI48", {
    font = "Segoe UI Light",
    size = 48,
    weight = 100,
    antialias = true,
    blursize = 0
})

surface.CreateFont("Impulse-LightUI48-Blurred", {
    font = "Segoe UI Light",
    size = 48,
    weight = 100,
    antialias = true,
    blursize = 3
})

impulse.Surface.DefineTypeFace("Impulse-LightUI48", 3, 3, 255)

surface.CreateFont("Impulse-LightUI32", {
    font = "Segoe UI Light",
    size = 32,
    weight = 100,
    antialias = true
})

surface.CreateFont("Impulse-LightUI32-Blurred", {
    font = "Segoe UI Light",
    size = 32,
    weight = 100,
    antialias = true,
    blursize = 2
})

impulse.Surface.DefineTypeFace("Impulse-LightUI32", 3, 3, 255)

surface.CreateFont("Impulse-LightUI24", {
    font = "Segoe UI Light",
    size = 24,
    weight = 100,
    antialias = true
})

surface.CreateFont("Impulse-LightUI18", {
    font = "Segoe UI Light",
    size = 18,
    weight = 100,
    antialias = true
})

surface.CreateFont("Impulse-LightUI20", {
    font = "Segoe UI Light",
    size = 20,
    weight = 100,
    antialias = true
})

surface.CreateFont("Impulse-LightUI20-Blurred", {
    font = "Segoe UI Light",
    size = 20,
    weight = 100,
    antialias = true,
    blursize = 2
})

impulse.Surface.DefineTypeFace("Impulse-LightUI20", 2, 2, 255)

surface.CreateFont("Impulse-LightUI14", {
    font = "Segoe UI Light",
    size = 14,
    weight = 100,
    antialias = true
})

surface.CreateFont("Impulse-LightUI14-Blurred", {
    font = "Segoe UI Light",
    size = 14,
    weight = 100,
    antialias = true,
    blursize = 2
})

surface.CreateFont("Chat", {
    font = "Segoe UI Light",
    size = 26,
    weight = 100,
    antialias = true,
    bold = true
})

surface.CreateFont("smollerHUD", {
    font = "Segoe UI Light",
    size = 25,
    weight = 100,
    antialias = true,
    shadow = false,
    bold = true
})

surface.CreateFont("smollHUD", {
    font = "Segoe UI Light",
    size = 37,
    weight = 100,
    antialias = true,
    shadow = false,
    bold = true
})

surface.CreateFont("HUDshadow", {
    font = "Segoe UI Light",
    size = 40,
    weight = 100,
    antialias = true,
    shadow = true,
    bold = true
})

surface.CreateFont("HUD", {
    font = "Segoe UI Light",
    size = 45,
    weight = 100,
    antialias = true
})

surface.CreateFont("HUD-Blurred", {
    font = "Segoe UI Light",
    size = 45,
    weight = 100,
    antialias = true,
    bold = true
})

surface.CreateFont("medHUD", {
    font = "Segoe UI Light",
    size = 65,
    weight = 200,
    antialias = true
})

surface.CreateFont("BigHUD", {
    font = "Segoe UI Light",
    size = 75,
    weight = 100,
    antialias = true,
    bold = false
})

surface.CreateFont("Code", {
    font = "Segoe UI Light",
    size = 25,
    weight = 200,
    antialias = true,
    bold = true
})

impulse.Surface.DefineTypeFace("Impulse-LightUI14", 2, 2, 255)

hook.Run("PostLoadFonts")
