
# Part 1 took me 8:33 PM - 9:22 PM, 11:24 - 11:28 PM (53 mins)

Map = Struct.new(:instructions, :nodes, :start_index, :end_index)

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
    start_index = str_indexes["AAA"]
    end_index = str_indexes["ZZZ"]
    nodes = str_nodes.map { |node| node.map { str_indexes[_1] } }
    Map.new(instructions, nodes, start_index, end_index)
end

def follow_instructions(map)
    instr_i = 0
    node_i = map.start_index
    step_count = 0
    while node_i != map.end_index
        instr = map.instructions[instr_i]
        node_i = map.nodes[node_i][instr]
        step_count += 1

        instr_i += 1
        instr_i = 0 if instr_i == map.instructions.length
    end
    step_count
end

start_time = Time.now

input = IO.readlines("d8_input").map { |line| line.chomp }
map = parse_map input
#p map
step_count = follow_instructions map
puts step_count

puts
puts format("Took %.1f ms", (Time.now - start_time).to_f * 1000)
