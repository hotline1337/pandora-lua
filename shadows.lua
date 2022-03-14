-- menu
local light_shadow_direction_x = ui.add_slider_float("m_envLightShadowDirection_x", -1, 1)
local light_shadow_direction_y = ui.add_slider_float("m_envLightShadowDirection_y", -1, 1)
local light_shadow_direction_z = ui.add_slider_float("m_envLightShadowDirection_z", -1, 1)
local shadow_direction_x = ui.add_slider_float("m_shadowDirection_x", -1, 1)
local shadow_direction_y = ui.add_slider_float("m_shadowDirection_y", -1, 1)
local shadow_direction_z = ui.add_slider_float("m_shadowDirection_z", -1, 1)

-- callbacks
callbacks.register("paint", function()
    if not engine.is_connected() then return end

    local cascade_light = entity_list.get_all("CCascadeLight")[1]
    local m_envLightShadowDirection = entity_list.get_client_entity(cascade_light):get_prop("DT_CascadeLight", "m_envLightShadowDirection")
    local m_shadowDirection = entity_list.get_client_entity(cascade_light):get_prop("DT_CascadeLight", "m_shadowDirection")

    m_envLightShadowDirection:set_vector(vector.new(light_shadow_direction_x:get(), light_shadow_direction_y:get(), light_shadow_direction_z:get()))
    m_shadowDirection:set_vector(vector.new(shadow_direction_x:get(), shadow_direction_y:get(), shadow_direction_z:get()))
end)
