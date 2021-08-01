
local function onCommand(event)
     game.players[event.player_index].print("I ran")
end

commands.add_command("export", nil, onCommand)
