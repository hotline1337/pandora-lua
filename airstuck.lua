local bit = require("bit")

-- menu
local text = ui.add_label("Airstuck")
local cog = ui.add_cog("Airstuck key", false, true)

-- callbacks
callbacks.register("post_move", function(cmd)
    if not client.is_alive() then return end
    
    if bit.band(cmd.buttons, bit.lshift(1, 0)) ~= 0 or bit.band(cmd.buttons, bit.lshift(1, 11)) ~= 0 then
        return
    end

    if input.key_down(cog:get_key()) then
        cmd.tick_count = 2 ^ 1024
        cmd.command_number = 16777216
    end
end)
