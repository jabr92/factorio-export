require("json")
 
function getEnergyData(prototype, data)
    if prototype.burner_prototype ~= nil then
        data["burner_effectivity"]=prototype.burner_prototype.effectivity
        data["fuel_categories"]=prototype.burner_prototype.fuel_categories
        data["emissions"]=prototype.burner_prototype.emissions
    elseif prototype.electric_energy_source_prototype ~= nil then
        data["drain"]=prototype.electric_energy_source_prototype.drain*60
        data["emissions"]=prototype.electric_energy_source_prototype.emissions
    end
    return data
end
 
function acquireData(event)
    local playersettings = settings.get_player_settings(game.players[event.player_index])
    if not playersettings["recipelister-output"].value then
        log("beep i'm out") --why did you enable the mod?
        return
    end


    local entries = {
        recipe = {
            "name",
            "localised_name",
            "category",
            "order",
            "group",
            "subgroup",
            "enabled",
            "emissions_multiplier",
            "energy",
			"ingredients",
			"products",
            "main_product"},
        inserter = {
            "name",
			"localised_name",
			"max_energy_usage",
			"inserter_extension_speed",
			"inserter_rotation_speed",
            "map_color",
            "friendly_map_color",
            "enemy_map_color"},
        resource = {
            "name",
			"localised_name",
			"resource_category",
			"mineable_properties",
			"autoplace_specification"},
        item = {
            "name",
			"localised_name",
			"type",
			"order",
			"fuel_value",
			"category",
            "stack_size",
			"tier",
			"module_effects",
			"limitations",
			"fuel_category",
			"fuel_acceleration_multiplier",
			"fuel_top_speed_multiplier",
			"rocket_launch_products",
			"attack_parameters",
			"place_result",
			"burnt_result",
			"equipment_grid",
            "place_as_equipment_result",
            "place_as_tile_result",},
        fluid = {
            "name",
			"localised_name",
			"order",
			"default_temperature",
			"max_temperature",
			"fuel_value",
			"emissions_multiplier"},
        technology = {
            "name",
			"localised_name",
			"effects",
			"research_unit_ingredients",
			"research_unit_count",
			"research_unit_energy",
			"max_level",
			"research_unit_count_formula"},    
        boiler = {
            "name",
			"localised_name",
			"max_energy_usage",
			"target_temperature",
            "map_color",
            "friendly_map_color",
            "enemy_map_color"},
        generator = {
            "name",
			"localised_name",
			"maximum_temperature",
			"effectivity",
			"fluid_usage_per_tick",
            "map_color",
            "friendly_map_color",
            "enemy_map_color"},
        reactor = {
            "name",
			"localised_name",
			"max_energy_usage",
			"neighbour_bonus",
            "map_color",
            "friendly_map_color",
            "enemy_map_color"},
        lab = {
            "name",
			"localised_name",
			"energy_usage",
			"lab_inputs",
			"researching_speed",
            "map_color",
            "friendly_map_color",
            "enemy_map_color"},
        equipment = {
            "name",
            "type",
			"localised_name",
            "shape",
            "energy_production",
            "shield",
            "energy_per_shield",
            "energy_consumption",
            "equipment_categories",
            "attack_parameters",
            "background_color"},
        tile = {
            "name",
            "localised_name",
            "collision_mask_with_flags",
            "layer",
            "autoplace_specification",
            "walking_speed_modifier",
            "vehicle_friction_modifier",
            "emissions_per_second",
            "map_color"}
    }
    entries["assembling-machine"] = {
            "name",
			"localised_name",
			"type",
			"energy_usage",
			"ingredient_count",
			"crafting_speed",
			"crafting_categories",
			"module_inventory_size",
			"allowed_effects",
            "map_color",
            "friendly_map_color",
            "enemy_map_color"}
    entries.furnace = entries["assembling-machine"]
    entries["mining-drill"] = {
            "name",
			"localised_name",
			"energy_usage",
			"mining_speed",
			"resource_categories",
			"allowed_effects",
            "map_color",
            "friendly_map_color",
            "enemy_map_color"}
    entries["transport-belt"] = {
            "name",
			"localised_name",
			"belt_speed",
            "map_color",
            "friendly_map_color",
            "enemy_map_color"}
    entries["solar-panel"] = {
            "name",
			"localised_name",
			"max_energy_production",
            "map_color",
            "friendly_map_color",
            "enemy_map_color"}
    entries["equipment-grid"] = {
            "name",
			"localised_name",
			"equipment_categories",
            "width",
            "height"}
            
    local outdata = {}
    local enabled_types = {}
    local blacklist = {}

    local entities = {
            "assembling-machine",
			"furnace",
			"resource",
			"inserter",
			"transport-belt",
			"mining-drill",
			"boiler",
			"generator",
			"reactor",
			"lab"}
   
    -- read settings
    for k,v in pairs(playersettings) do
        if (string.sub(k,1,20) == "recipelister-enable-") and v.value then
            category = string.sub(k,21)
            enabled_types[category]=v.value
            outdata[category] = {}
        end
    end
    
    -- setup prototypes to read
    local game_prototypes = {} 
    for _,enttype in pairs(entities) do
        if enabled_types[enttype] then
            game_prototypes.entity = game.entity_prototypes
            break
        end
    end
    
    if enabled_types.recipe then
        game_prototypes.recipe = game.recipe_prototypes
    end
    if enabled_types.item then
        game_prototypes.item = game.item_prototypes
    end
    if enabled_types.fluid then
        game_prototypes.fluid = game.fluid_prototypes
    end
    if enabled_types.technology then
        game_prototypes.technology = game.technology_prototypes
    end
    if enabled_types.tile then
        game_prototypes.tile = game.tile_prototypes
    end
    if enabled_types.equipment then
        game_prototypes.equipment = game.equipment_prototypes
    end
    if enabled_types["equipment-grid"]then
        game_prototypes["equipment-grid"] = game.equipment_grid_prototypes
    end
   
    -- read data
    for thetype,prototypes in pairs(game_prototypes) do
        for _,prototype in pairs(prototypes) do
            log(prototype.name)
            local t = thetype
            if thetype == "entity" then
                t = prototype.type
            end
            if enabled_types[t] then
                local data = {}
                for _, entry in pairs(entries[t]) do
                    if entry == "group" or entry == "subgroup" then
                        data[entry]={name = prototype[entry].name, type = prototype[entry].type}
                    elseif entry == "energy_usage" or entry == "belt_speed" or entry == "max_energy_usage" or entry == "max_energy_production" then
                        data[entry]=60*prototype[entry] -- prototype numbers were per tick
                    elseif entry == "burnt_result" or entry == "equipment_grid" or entry == "place_result" or entry == "place_as_equipment_result" or entry == "place_as_tile_result" then
                        if prototype[entry] and prototype[entry].name then
                            data[entry] = prototype[entry].name
                        end
                    elseif entry == "rocket_launch_products" then
                        if prototype[entry] and prototype[entry][1] then
                            data[entry] = prototype[entry]
                        end
                    elseif entry == "fuel_acceleration_multiplier" or entry == "fuel_top_speed_multiplier" then
                        if prototype.fuel_value and prototype.fuel_value ~= 0 then
                            data[entry] = prototype[entry]
                        end
                    -- elseif entry == "map_color" or entry == "friendly_map_color" or entry == "enemy_map_color" and prototype[entry] ~= nil then
                        -- data[entry] = {r = prototype[entry].r,g = prototype[entry].g,b = prototype[entry].b,a = prototype[entry].a}
                    else
                        data[entry]=prototype[entry]
                    end
                end
                if thetype == "entity" then
                    data = getEnergyData(prototype,data)
                    if data then
                        local energyusage = data.energy_usage or data.max_energy_usage or 0
                        local emissions = data.emissions or 0
                        data.pollution = energyusage*emissions*60
                    end
                    if t == "generator" and prototype.fluidbox_prototypes and prototype.fluidbox_prototypes[1] and prototype.fluidbox_prototypes[1].filter then
                        local fluid = prototype.fluidbox_prototypes[1].filter
                        data.max_energy_output = (prototype.maximum_temperature-fluid.default_temperature)*60*prototype.fluid_usage_per_tick*fluid.heat_capacity
                    end
                    if t == "boiler" then
                        local fluidboxes = {}
                        for _, pro in pairs(prototype.fluidbox_prototypes) do
                            local fluidbox = {
                                index = pro.index,
                                production_type = pro.production_type,
                                minimum_temperature = pro.minimum_temperature,
                                maximum_temperature = pro.maximum_temperature
                            }
                            if pro.filter then
                                fluidbox.filter = pro.filter.name
                            end
                            fluidboxes[#fluidboxes+1] = fluidbox
                        end
                        if #fluidboxes > 2 then
                            data.input_fluid = prototype.fluidbox_prototypes[1].filter.name
                            data.output_fluid = prototype.fluidbox_prototypes[2].filter.name
                        end
                    end
                end
                if t == "technology" then
                    data.prerequisites = {}
                    for key, _ in pairs(prototype.prerequisites) do
                        table.insert(data.prerequisites,key)
                    end
                end
                if t == "movement-bonus-equipment" then
                    data["movement_bonus"] = prototype["movement_bonus"]
                end
                if t == "roboport-equipment" then
                    data["logistic_parameters"] = prototype["logistic_parameters"]
                end
                if t == "night-vision-equipment" then
                    data["night_vision_tint"] = prototype["night_vision_tint"]
                end
                outdata[t][prototype.name] = data
            end
        end
    end
    
    -- write section
    local folder = "recipe-lister/"
    local filename = "crafting_data.json"
    game.remove_path(folder)
    if (playersettings["recipelister-split-output"].value) then
        for category,things in pairs(outdata) do
            game.write_file(folder..category..".json",global.json.stringify(things))
        end
    else
        game.write_file(folder..filename,global.json.stringify(outdata))
    end
   
end
 
script.on_event(defines.events.on_player_created, function(event)
    acquireData(event)
    game.players[event.player_index].print{"recipe.hi"}
end)