------------------------------------------------------------------------------------------------
-- Please don't judge this code too heavily. It is a bit of a hack job but it works :)
------------------------------------------------------------------------------------------------


function uiDrawOptions()

    local w = UiWidth()
    local h = UiHeight()

    contW = w * 0.9
    contH = h * 0.9
    padH = 10
    padW = 10
    padW2 = padW * 2
    padH2 = padH * 2

    font_heading = 64
    font_normal = 28

    -- Base container.
    uiDrawBaseContainer()

    -- Title container.
    title_w = 128
    title_h = 128
    uiDrawTitleContainer()

    -- Options container.
    options_w = contW - (padW * 2)
    options_h = contH - title_h - (padH * 3)
    options_tabs = 4
    options_tabH = 72
    options_tabW = (options_w - padW2)/options_tabs
    options_tabNames = {'Tool', 'Gas', 'Performance', 'Info'}
    options_tabSelected = options_tabSelected or options_tabNames[1]
    uiDrawOptionsContainer()

end

function uiDrawBaseContainer()
    ui.padding.create(UiWidth() * 0.1/2, UiHeight() * 0.1/2)
    ui.container.create(contW, contH, ui.colors.g1, 1)
end

function uiDrawTitleContainer()

    -- Title container
    ui.padding.create(padW, padH)
    ui.container.create(contW - title_w, title_h, ui.colors.g2, 1)


    -- Text: Title
    do UiPush()

        -- Mod Preview Image
        local imgW = title_w - padW2
        local imgH = title_h - padH2
        ui.padding.create(padW, padH)
        UiImageBox('img/preview.jpg', imgW, imgH, 1,1, 1,1,1,1)

        -- Mod Title
        ui.padding.create(padW + imgW, 0)
        local textHeight = 64
        UiColor(1,1,1, 1)
        UiFont('bold.ttf', textHeight)
        UiAlign('top left')
        UiText('Gas Can')

        -- Mod Subtitle
        ui.padding.create(0, textHeight + padH/2)
        textHeight = 32
        UiFont('bold.ttf', textHeight)
        UiText('By: Cheejins')


    UiPop() end


    -- Button: Play Demo Map
    do UiPush()

        ui.padding.create(contW - title_w - padW , padH)

        local a = 1

        if UI_OPTIONS then
            a = oscillate(2)
        end

        UiColor(0,1,0, a)
        UiAlign('top right')
        UiFont('bold.ttf', 64)

        UiButtonImageBox('ui/common/box-outline-6.png', 10,10, 0,1,0, a)
        if UiTextButton('Play Demo Map', 440,70) then
            StartLevel("", "MOD/demoMap/main.xml")
        end

    UiPop() end


    -- Button: Exit
    do UiPush()

        ui.padding.create(padW, 0)
        ui.padding.create(contW - title_w, 0)

        local btnW = 128 - (padW*3)
        local btnH = 128

        UiAlign('left top')

        -- Exit button
        UiColor(1,0,0,1)
        UiRect(btnW, btnH)

        UiButtonImageBox('ui/common/box-outline-6.png', 1,1, 0,0,0, a)
        if UiBlankButton(btnW, btnH) then
            if UI_GAME then
                UI_GAME = false
            elseif UI_OPTIONS then
                Menu()
            end
        end

        -- X text
        UiColor(1,1,1, 1)
        ui.padding.create(btnW/2, btnH/2)
        UiFont('bold.ttf', btnW/1.5)
        UiAlign('middle center')
        UiText('X')


    UiPop() end

    ui.padding.create(0, title_w)

end

function uiDrawOptionsContainer()

    -- Options container
    ui.padding.create(0, padH)
    ui.container.create(options_w, options_h, ui.colors.g2, 1)

    -- Text: Options
    ui.padding.create(padW, padH)
    do UiPush()
        UiColor(1,1,1, 1)
        UiFont('bold.ttf', font_heading)
        UiAlign('top left')
        UiText('Options')
    UiPop() end


    do UiPush()

        ui.padding.create(800, 40)

        local a = oscillate(5)

        UiColor(1,0.5,0.5, a)
        UiFont('bold.ttf', 64)
        UiAlign('center middle')
        UiTextShadow(1,0,0,1, 0.3,0.3)
        UiText('<< This mod is not finished yet >>')

    UiPop() end


    -- Button: Options reset
    do UiPush()
        ui.padding.create(contW - padW * 4, ((font_heading - font_normal * 1.5)/2))
        UiColor(1,1,1, 1)
        UiFont('bold.ttf', font_normal * 1.5)
        UiAlign('top right')

        local resetButton = UiTextButton('Reset')
        if resetButton then
            modReset()
            beep()
        end

    UiPop() end


    -- Options tabs
    ui.padding.create(0, padH2 + font_heading)
    do UiPush()

        ui.tabView.tab.create("Tool")

        ui.padding.create(options_tabW + (padW/(options_tabs-1)), 0)
        ui.tabView.tab.create("Gas")

        ui.padding.create(options_tabW + (padW/(options_tabs-1)), 0)
        ui.tabView.tab.create("Performance")

        ui.padding.create(options_tabW + (padW/(options_tabs-1)), 0)
        ui.tabView.tab.create("Info")

    UiPop() end


    -- Options tab content container
    local tabContentH = contH - title_h - options_tabH - options_tabH - padH * 6.5
    ui.padding.create(0, options_tabH)
    ui.container.create(contW - padW*4, tabContentH, ui.colors.g3, 1)


    -- Tab content
    ui.padding.create(padW, padH2)
    ui.container.create(contW - padW*6, tabContentH - padH*3, ui.colors.g1, 1)
    ui.padding.create(padW2*2, padH2*2)
    do UiPush()

        if options_tabSelected == 'Tool' then

            options_tabs_render.Tool()

        elseif options_tabSelected == 'Gas' then

            options_tabs_render.Gas()

        elseif options_tabSelected == 'Performance' then

            options_tabs_render.Performance()

        elseif options_tabSelected == 'Info' then

            options_tabs_render.Info()

        end

    UiPop() end

end

options_tabs_render = {

    Tool = function()

        do UiPush()

            ui.padding.create(500, 20)

            ui.slider.create('Pour Gravity', 'tool.pour.gravity', nil, 0, 0.1)
            ui.padding.create(0, 64)

            ui.slider.create('Pour RPM (Drops per second)', 'tool.pour.rate', 'RPM', 120, 2400)
            ui.padding.create(0, 64)

            ui.slider.create('Pour Velocity', 'tool.pour.velocity', 'm/s', 0.01, 0.5)
            ui.padding.create(0, 64)

            ui.slider.create('Pour Spread', 'tool.pour.spread', nil, 0, 20)
            ui.padding.create(0, 64)

            ui.checkBox.create('Debug Mode', 'tool.debugMode')
            ui.padding.create(0, 64)

        UiPop() end

    end,

    Gas = function()

        do UiPush()

            ui.padding.create(500, 20)

            ui.slider.create('Minimum Ignition Distance', 'tool.gas.ignitionDistance', 'Meters', 1, 3)
            ui.padding.create(0, 64)

            ui.slider.create('Ignition Delay', 'tool.gas.preburnTime', 'Seconds', 0, 3)
            ui.padding.create(0, 64)

            ui.slider.create('Burn Duration', 'tool.gas.burnTime', 'Seconds', 0, 60)
            ui.padding.create(0, 64)

            ui.slider.create('Burn Thickness', 'tool.gas.burnThickness', 'Meters', 0, 4)
            ui.padding.create(0, 64)

            ui.checkBox.create('Gas-covered vehicles become explosive', 'tool.gas.explosiveVehicles')
            ui.padding.create(0, 64)

        UiPop() end

    end,

    Performance = function()

        UiColor(1,1,1, 1)
        UiFont('bold.ttf', 32)
        UiAlign('left middle')
        UiText('(Performance options coming soon)')

    end,

    Info = function()

        UiColor(1,1,1, 1)
        UiFont('bold.ttf', 32)
        UiAlign('left middle')
        UiText('(Info section coming soon)')
        ui.padding.create(0, 50)

        ui.padding.create(0, 50)
        UiText('CONTROLS')
        ui.padding.create(0, 50)
        UiText('- r = remove all gas drops')
        ui.padding.create(0, 50)
        UiText('- left click = pour gas.')
        ui.padding.create(0, 50)
        UiText('- right click = spawn fire at your crosshair..')
        ui.padding.create(0, 50)


        ui.padding.create(0, 50)
        UiText('QUICK NOTES')
        ui.padding.create(0, 50)
        UiText('- Gas only ignites near existing fires.')
        ui.padding.create(0, 50)
        UiText('- Gas will not ignite on non-flammable materials like metal or concrete (yet)')
        ui.padding.create(0, 50)
        UiText('- The Gas Can options are already tuned. Changing them too much can mess up the functionality of the gas.')

    end,

}



--- Draw options shorcut key hint above tool name.
function uiDrawToolNameOptionsHint(addHeight)

    UiPush()

        UiTranslate(UiCenter(), UiHeight() - (addHeight or 60))

        UiAlign("center middle")
        UiFont("bold.ttf", 32)
        UiTextShadow(0,0,0, 1, 0.3, 0.5)
        UiColor(1,1,1, 1)

        UiText('Press "o" for options.')

    UiPop()

end

--- Manage when to open and close the options menu.
function uiManageGameOptions()

    if tool.tool.active() then

        if InputPressed('o') then UI_GAME = not UI_GAME end

        if UI_GAME then
            UiMakeInteractive()
            uiDrawOptions()
        end

    end

end



ui = {}

ui.colors = {
    white = Vec(1,1,1),
    g3 = Vec(0.5,0.5,0.5),
    g2 = Vec(0.35,0.35,0.35),
    g1 = Vec(0.2,0.2,0.2),
    black = Vec(0,0,0),
}



ui.container = {}

function ui.container.create(w, h, c, a)
    if not c then c = Vec(0.5,0.5,0.5) end
    UiColor(c[1], c[2], c[3], a or 0.5)
    UiRect(w, h)
end



ui.padding = {}

function ui.padding.create(w, h)
    UiTranslate(w or 10, h or 10)
end



ui.tabView = {}

ui.tabView.tab = {}

function ui.tabView.tab.create(text)

    do UiPush()

        UiAlign('top left')

        ui.container.create(options_tabW - padW, options_tabH, ui.colors.g1, 1)

        if options_tabSelected == text then
            ui.container.create(options_tabW - padW, options_tabH, ui.colors.g3, 1)
        end

        UiButtonImageBox('ui/common/box-outline-6.png', 1,1, 0,0,0, a)
        if UiBlankButton(options_tabW, options_tabH) then
            if options_tabSelected ~= text then
                PlaySound(LoadSound('clickdown.ogg'), GetCameraTransform().pos, 1)
            end
            options_tabSelected = text
        end

        ui.padding.create(options_tabW/2, options_tabH/2)

        UiColor(1,1,1, 1)
        UiFont('bold.ttf', font_normal*1.25)
        UiAlign('center middle')
        UiText(text)

    UiPop() end

end



ui.slider = {}

function ui.slider.create(title, registryPath, valueText, min, max, w, h, fontSize, axis)

    local value = GetFloat('savegame.mod.' .. registryPath)

    min = min or 0
    max = max or 300

    UiAlign('left middle')

    -- Text header
    UiColor(1,1,1, 1)
    UiFont('regular.ttf', fontSize or font_normal)
    UiText(title)
    ui.padding.create(0, fontSize or font_normal)

    -- Slider BG
    UiColor(0.4,0.4,0.4, 1)
    local slW = w or 500
    UiRect(slW, h or 10)

    -- Convert to slider scale.
    value = ((value-min) / (max-min)) * slW

    -- Slider dot
    UiColor(1,1,1, 1)
    UiAlign('center middle')
    value, done = UiSlider("ui/common/dot.png", "x", value, 0, slW)
    if done then
        local val = (value/slW) * (max-min) + min -- Convert to true scale.
        SetFloat('savegame.mod.' .. registryPath, val)
    end

    -- Slider value
    do UiPush()
        UiAlign('left middle')
        ui.padding.create(slW + 20, 0)
        local decimals = ternary((value/slW) * (max-min) + min < 100, 3, 1)
        UiText(sfn((value/slW) * (max-min) + min, decimals) .. ' ' .. (valueText or ''))
    UiPop() end

end


ui.checkBox = {}

function ui.checkBox.create(title, registryPath)

    local value = GetBool('savegame.mod.' .. registryPath)

    UiAlign('left middle')

    -- Text header
    UiColor(1,1,1, 1)
    UiFont('regular.ttf', fontSize or font_normal)
    UiText(title)
    ui.padding.create(0, fontSize or font_normal)

    -- Toggle BG
    UiAlign('left top')
    UiColor(0.4,0.4,0.4, 1)
    local tglW = w or 150
    local tglH = h or 50
    UiRect(tglW, h or tglH)

    -- Render toggle
    do UiPush()

        local toggleText = 'ON'

        if value then
            ui.padding.create(tglW/2, 0)
            UiColor(0,0.8,0, 1)
        else
            toggleText = 'OFF'
            UiColor(0.8,0,0, 1)
        end

        UiRect(tglW/2, tglH)

        do UiPush()
            ui.padding.create(tglW/4, tglH/2)
            UiColor(1,1,1, 1)
            UiFont('bold.ttf', font_normal)
            UiAlign('center middle')
            UiText(toggleText)
        UiPop() end

    UiPop() end

    UiButtonImageBox('ui/common/box-outline-6.png', 10,10, 0,0,0, a)
    if UiBlankButton(tglW, tglH) then
        SetBool('savegame.mod.' .. registryPath, not value)
        PlaySound(LoadSound('clickdown.ogg'), GetCameraTransform().pos, 1)
    end

end