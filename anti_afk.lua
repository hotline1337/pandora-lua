local bit = require("bit")

-- callbacks
callbacks.register("post_move", function(cmd)
    if not client.is_alive() then return end

    if cmd.command_number % 2 == 0 then
        cmd.buttons = bit.bor(cmd.buttons, 2^27)
    end
end)
