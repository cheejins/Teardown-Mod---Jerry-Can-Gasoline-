#include "scripts/umf.lua"
#include "scripts/utility.lua"

-- Please don't judge this code too heavily. It is a bit of a hack job but it works :)

function init()
    UI_OPTIONS = true
end

function draw()

    local w = UiWidth()
    local h = UiHeight()

    contW = w * 0.9
    contH = h * 0.9
    padH = 10
    padW = 10
    padW2 = padW*2
    padH2 = padH*2

    font_heading = 64
    font_normal = 28

    -- Base container.
    uiDrawBaseContainer()

    -- Title container.
    title_w = 128
    title_h = 128
    uiDrawTitle()

    -- Options container.
    options_w = contW - (padW * 2)
    options_h = contH - title_h - (padH * 3)
    options_tabs = 4
    options_tabH = 72
    options_tabW = (options_w - padW2)/options_tabs
    options_tabNames = {'Tool', 'Gas', 'Performance', 'Info'}
    options_tabSelected = options_tabSelected or options_tabNames[1]
    uiDrawOptions()

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

        ui.container.create(options_tabW - padW, options_tabH, ui.colors.g1, 1)

        if options_tabSelected == text then
            ui.container.create(options_tabW - padW, options_tabH, ui.colors.g3, 1)
        end

        ui.padding.create(options_tabW/2, options_tabH/2)

        UiColor(1,1,1, 1)
        UiFont('bold.ttf', font_normal*1.25)
        UiAlign('center middle')

        local pressed = UiTextButton(text, 100, 100)
        if pressed then
            options_tabSelected = text
        end

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
    local slW = w or 300
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
        UiText(sfn((value/slW) * (max-min) + min, 1) .. ' ' .. (valueText or ''))
    UiPop() end

end



function uiDrawBaseContainer()
    ui.padding.create(UiWidth() * 0.1/2, UiHeight() * 0.1/2)
    ui.container.create(contW, contH, ui.colors.g1, 1)
end

function uiDrawTitle()

    -- Title container
    ui.padding.create(padW, padH)
    ui.container.create(contW - title_w, title_h, ui.colors.g2, 1)


    -- Text: Title
    do UiPush()

        -- Mod Title
        ui.padding.create(padH, padW)
        local textHeight = 64
        UiColor(1,1,1, 1)
        UiFont('bold.ttf', textHeight)
        UiAlign('top left')
        UiText('Jerry Can (Gasoline)')

        -- Mod Subtitle
        ui.padding.create(0, textHeight + padH/2)
        textHeight = 32
        UiFont('bold.ttf', textHeight)
        UiText('By: Cheejins')


    UiPop() end


    -- Button: Play Demo Map
    do UiPush()
    UiPop() end


    -- Button: Exit
    do UiPush()

        ui.padding.create(padW, 0)
        ui.padding.create(contW - title_w, 0)

        local btnW = 128 - (padW*3)
        local btnH = 128

        -- Exit button
        UiColor(1,0,0,1)
        UiRect(btnW, btnH)

        -- X text
        UiColor(1,1,1, 1)
        UiFont('bold.ttf', btnW/1.5)
        UiAlign('middle center')
        ui.padding.create(btnW/2, btnH/2)

        -- Button function
        local exitButton = UiTextButton('X', btnW, btnH)
        if exitButton then
            if UI_GAME then
                -- Function
            elseif UI_OPTIONS then
                Menu()
            end
        end

    UiPop() end

    ui.padding.create(0, title_w)

end

function uiDrawOptions()

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


    -- -- Button: Options reset
    -- do UiPush()
    --     ui.padding.create(contW - padW * 4, ((font_heading - font_normal * 1.5)/2))
    --     UiColor(1,1,1, 1)
    --     UiFont('bold.ttf', font_normal * 1.5)
    --     UiAlign('top right')
    --     UiText('Reset')
    -- UiPop() end


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

            ui.slider.create('Pour Gravity', 'tool.pour.gravity', nil, 0, 10)
            ui.padding.create(0, 64)

            ui.slider.create('Pour Rate (Drops per second)', 'tool.pour.rate', 'RPM', 120, 2400)
            ui.padding.create(0, 64)

            ui.slider.create('Pour Velocity', 'tool.pour.velocity', 'm/s', 0.5, 100)
            ui.padding.create(0, 64)

            ui.slider.create('Pour Spread', 'tool.pour.spread', nil, 0, 10)
            ui.padding.create(0, 64)


        UiPop() end

    end,

    Gas = function()

        do UiPush()

            ui.slider.create('Combustion distance', 'tool.gas.gravity')
            ui.padding.create(0, 64)

            ui.slider.create('Time before igniting', 'tool.gas.preburnTime', 'Seconds', 0, 10)
            ui.padding.create(0, 64)

            ui.slider.create('Destructive Fire', 'tool.gas.destructive')
            ui.padding.create(0, 64)

        UiPop() end

    end,

    Performance = function()
    end,

    Info = function()
    end,

}