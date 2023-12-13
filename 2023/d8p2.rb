
# Part 1 took me 11:34 PM - 12:03 AM, 8:46 PM - 9:26 PM (1 hr 9 mins)

Map = Struct.new(:instructions, :nodes, :start_indexes, :end_indexes)
# - `initial_count` is the number of steps from start node to the first end node encountered.
# - `end_counts` is an array of the number of steps to each of the other end nodes encountered (if
#   any).
StepCounts = Struct.new(:initial_count, :end_counts)

def parse_map(lines)
    raise "invalid input" if lines.length < 3
    instructions = lines[0].bytes.map(&{"L".ord => 0, "R".ord => 1}.to_proc)
    raise "second line should be blank" if lines[1].length != 0
    str_indexes = Hash.new
    str_nodes = []
    for i in 2...lines.length
        match = lines[i].match /^([A-Z]{3}) = \(([A-Z]{3}), ([A-Z]{3})\)$/
        str_nodes.push [match[2], match[3]]
        str_indexes[match[1]] = str_nodes.length - 1
    end
    $debug_names = str_indexes.invert
    node_names = str_indexes.keys
    start_indexes = node_names.filter { _1.end_with? "A" }.map(&str_indexes)
    end_indexes = node_names.filter { _1.end_with? "Z" }.map(&str_indexes)
    nodes = str_nodes.map { |node| node.map { str_indexes[_1] } }
    Map.new(instructions, nodes, start_indexes, end_indexes)
end

# Returns the end node index and number of steps it took to reach it.
def get_step_count_to_first_end(map, start_index)
    instr_i = 0
    node_i = start_index
    #puts $debug_names[node_i]
    step_count = 0
    while true
        instr = map.instructions[instr_i]
        node_i = map.nodes[node_i][instr]
        #puts $debug_names[node_i]
        step_count += 1

        instr_i += 1
        instr_i = 0 if instr_i == map.instructions.length

        break if map.end_indexes.include?(node_i)
    end
    [node_i, step_count]
end

def get_step_counts(map, start_index)
    initial_end, initial_count = get_step_count_to_first_end(map, start_index)
    node_i = initial_end
    end_counts = []
    while true
        node_i, step_count = get_step_count_to_first_end(map, node_i)
        end_counts.push step_count
        break if node_i == initial_end
    end

    StepCounts.new(initial_count, end_counts)
end

start_time = Time.now

input = IO.readlines("d8_input").map { |line| line.chomp }
map = parse_map input
#p map
# Find the step count for each starting node.
step_counts = map.start_indexes.map { get_step_counts(map, _1) }
puts step_counts
# Turns out all the end_counts have one number that equals the initial_count. So finding the answer
# is a lot easier, just using lcm.
puts step_counts.inject(1) { _1.lcm(_2.initial_count) }

puts
puts format("Took %.1f ms", (Time.now - start_time).to_f * 1000)
