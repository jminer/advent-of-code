
Game = Struct.new(:num, :sets)
CubeExample = Struct.new(:count, :color)

def parse_game(line)
    match = line.match /Game (\d+): (.*)/
    game_num = match[1].to_i
    set_strings = match[2].split "; "
    sets = set_strings.map do |set|
        set.split(", ").map do |cube|
            cube_match = cube.match /(\d+) (\w+)/
            CubeExample.new(Integer(cube_match[1]), cube_match[2])
        end
    end
    Game.new(game_num, sets)
end 

def is_set_possible(set)
    for example in set
        return false if example.color == "red" && example.count > 12
        return false if example.color == "green" && example.count > 13
        return false if example.color == "blue" && example.count > 14
    end
    true
end

input = IO.readlines("d2_input").map { |line| line.chomp }
games = input.map { |line| parse_game line }
possible_games = games.select do |game|
    game.sets.all? { |set| is_set_possible set }
end
sum = possible_games.inject(0) {|acc, g| acc + g.num}
puts sum
