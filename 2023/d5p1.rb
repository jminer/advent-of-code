
# Part 1 took me 10:28 PM - 11:20 PM (-13 talking to Matt) (39 min)

IdMap = Struct.new(:src_start_id, :dest_start_id, :range_length)

class CategoryMap
    attr_accessor :src_cat, :dest_cat, :id_maps
    def initialize(src_cat, dest_cat, id_maps)
        self.src_cat = src_cat
        self.dest_cat = dest_cat
        self.id_maps = id_maps
        self.id_maps.sort_by! { _1.src_start_id }
    end

    def convert(id)
        for map in id_maps
            if id >= map.src_start_id && id < map.src_start_id + map.range_length
                return id - map.src_start_id + map.dest_start_id
            end
        end
        id
    end
end

def parse_input(lines)
    # Add a blank line so that it can rely on it to stop the parsing
    lines.push "" if lines[-1].length != 0
    raise "invalid input" if !lines[0].start_with?("seeds: ")
    line_enum = lines.to_enum
    seed_ids = line_enum.next.delete_prefix("seeds: ").split(" ").map { Integer(_1) }

    maps = []
    begin
        while true
            line_enum.next while line_enum.peek.length == 0
            cat_match = line_enum.next.match /^(\w+)-to-(\w+) map:$/
            src_cat = cat_match[1]
            dest_cat = cat_match[2]

            id_maps = []
            while line_enum.peek.length != 0
                id_map_nums = line_enum.next.split(" ").map { Integer(_1) }
                id_maps.push IdMap.new(id_map_nums[1], id_map_nums[0], id_map_nums[2])
            end
            line_enum.next

            maps.push CategoryMap.new(src_cat, dest_cat, id_maps)
        end
    rescue
    end

    [seed_ids, maps]
end

start_time = Time.now

input = IO.readlines("d5_input").map { |line| line.chomp }
seed_ids, maps = parse_input(input)
# The maps are in the right order in the input file, so ignore the source and dest names.
location_ids = seed_ids.map { |seed_id| maps.inject(seed_id) { |id, map| map.convert(id) }}
#puts location_ids
#puts

puts location_ids.min

puts
puts format("Took %.1f ms", (Time.now - start_time).to_f * 1000)
