local function GenerateWorldgenoverride(location, is_master_world)
    local path = nil
    if is_master_world then
        path = string.format('worldgenoverride_%s_master.json', location)
    else
        path = string.format('worldgenoverride_%s.json', location)
    end
    local out = {
        settings_preset = Levels.GetList(LEVELCATEGORY.SETTINGS, LEVELTYPE.SURVIVAL, location),
        worldgen_preset = Levels.GetList(LEVELCATEGORY.WORLDGEN, LEVELTYPE.SURVIVAL, location),
        settings_preset_CAVE = Levels.GetList(LEVELCATEGORY.SETTINGS, LEVELTYPE.CAVE, location),
        worldgen_preset_CAVE = Levels.GetList(LEVELCATEGORY.WORLDGEN, LEVELTYPE.CAVE, location),
        settings_preset_ADVENTURE = Levels.GetList(LEVELCATEGORY.SETTINGS, LEVELTYPE.ADVENTURE, location),
        worldgen_preset_ADVENTURE = Levels.GetList(LEVELCATEGORY.WORLDGEN, LEVELTYPE.ADVENTURE, location),
        settings_preset_LAVAARENA = Levels.GetList(LEVELCATEGORY.SETTINGS, LEVELTYPE.LAVAARENA, location),
        worldgen_preset_LAVAARENA = Levels.GetList(LEVELCATEGORY.WORLDGEN, LEVELTYPE.LAVAARENA, location),
        settings_preset_QUAGMIRE = Levels.GetList(LEVELCATEGORY.SETTINGS, LEVELTYPE.QUAGMIRE, location),
        worldgen_preset_QUAGMIRE = Levels.GetList(LEVELCATEGORY.WORLDGEN, LEVELTYPE.QUAGMIRE, location),
        settings_preset_TEST = Levels.GetList(LEVELCATEGORY.SETTINGS, LEVELTYPE.TEST, location),
        worldgen_preset_TEST = Levels.GetList(LEVELCATEGORY.WORLDGEN, LEVELTYPE.TEST, location),
        settings_options = Customize.GetWorldSettingsOptions(location, is_master_world),
        worldgen_options = Customize.GetWorldGenOptions(location, is_master_world),
    }
    local file = assert(io.open(path, "w"))
    file:write(json.encode_compliant(out))
    file:close()
end

local function GenerateWorldgenoverride1(location, is_master_world)
    local Customize = require 'map/customize'
    local Levels = require 'map/levels'

    local function makedescstring(desc)
        if desc ~= nil then
            local descstring = '\t\t\t-- '
            if type(desc) == 'function' then
                desc = desc()
            end
            for i, v in ipairs(desc) do
                descstring = descstring .. string.format('"%s"', v.data)
                if i < #desc then
                    descstring = descstring .. ', '
                end
            end
            return descstring
        else
            return nil
        end
    end

    local out = {}
    table.insert(out, string.format('return { -- location=%s, is_master_world=%s', location, tostring(is_master_world)))
    table.insert(out, '\toverride_enabled = true,')

    local presets = '\t\t\t-- '
    for i, level in ipairs(Levels.GetList(LEVELCATEGORY.SETTINGS, LEVELTYPE.SURVIVAL, location)) do
        if i > 1 then
            presets = presets .. ', '
        end
        presets = presets .. '"' .. level.data .. '"'
    end
    table.insert(out,
        string.format('\tsettings_preset = "%s", %s',
            Levels.GetList(LEVELCATEGORY.SETTINGS, LEVELTYPE.SURVIVAL, location)[1].data, presets))

    presets = '\t\t\t-- '
    for i, level in ipairs(Levels.GetList(LEVELCATEGORY.WORLDGEN, LEVELTYPE.SURVIVAL, location)) do
        if i > 1 then
            presets = presets .. ', '
        end
        presets = presets .. '"' .. level.data .. '"'
    end
    table.insert(out,
        string.format('\tworldgen_preset = "%s", %s',
            Levels.GetList(LEVELCATEGORY.WORLDGEN, LEVELTYPE.SURVIVAL, location)[1].data, presets))

    table.insert(out, '\toverrides = {')
    local lastgroup = nil
    table.insert(out, string.format('\t\t--WORLDSETTINGS'))
    for i, item in ipairs(Customize.GetWorldSettingsOptions(location, is_master_world)) do
        if lastgroup ~= item.group then
            if lastgroup ~= nil then
                table.insert(out, '')
            end
            table.insert(out, string.format('\t\t-- %s', string.upper(item.group)))
        end
        lastgroup = item.group

        if item.options ~= nil then
            table.insert(out, string.format('\t\t%s = "%s", %s', item.name, item.default, makedescstring(item.options)))
        else
            table.insert(out, string.format('\t\t%s = "%s",', item.name, item.default))
        end
    end
    lastgroup = nil
    table.insert(out, string.format('\t\t--WORLDGEN'))
    for i, item in ipairs(Customize.GetWorldGenOptions(location, is_master_world)) do
        if lastgroup ~= item.group then
            if lastgroup ~= nil then
                table.insert(out, '')
            end
            table.insert(out, string.format('\t\t-- %s', string.upper(item.group)))
        end
        lastgroup = item.group

        if item.options ~= nil then
            table.insert(out, string.format('\t\t%s = "%s", %s', item.name, item.default, makedescstring(item.options)))
        else
            table.insert(out, string.format('\t\t%s = "%s",', item.name, item.default))
        end
    end
    table.insert(out, '\t},')
    table.insert(out, '}')

    local path = nil
    if is_master_world then
        path = string.format('worldgenoverride_%s_master.lua', location)
    else
        path = string.format('worldgenoverride_%s.lua', location)
    end

    local file = assert(io.open(path, "w"))
    file:write(table.concat(out, '\n'))
    file:close()
end

GenerateWorldgenoverride('forest', true)
GenerateWorldgenoverride('forest', false)
GenerateWorldgenoverride('cave', true)
GenerateWorldgenoverride('cave', false)
Shutdown()
