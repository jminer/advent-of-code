
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

def get_game_min_cube_counts(game)
    cube_counts = Hash.new(0)
    for set in game.sets
        for example in set
            prev = cube_counts[example.color]
            if prev < example.count
                cube_counts[example.color] = example.count
            end
        end
    end
    cube_counts
end

def get_game_power(game)
    get_game_min_cube_counts(game).values.inject(1) { |acc, count| acc * count}
end

input = IO.readlines("d2_input").map { |line| line.chomp }
games = input.map { |line| parse_game line }
sum = games.inject(0) { |sum, game| sum + get_game_power(game) }
puts sum
