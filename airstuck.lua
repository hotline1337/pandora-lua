local bit = require("bit")

callbacks.register("post_move", function(cmd)
    if not client.is_alive() then return end
    
    if bit.band(cmd.buttons, bit.lshift(1, 0)) ~= 0 or bit.band(cmd.buttons, bit.lshift(1, 11)) ~= 0 then
        return
    end

    if input.key_down(0x58) then
        cmd.tick_count = 2 ^ 1024
        cmd.command_number = 16777216
    end
end)
