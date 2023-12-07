
# Part 2 took me 11:32 PM - 11:36 PM, 9:33 PM - 10:41 PM, 12:27 AM - 1:46 AM (2 hr 31 min)

SeedRange = Struct.new(:start_id, :length)
IdMap = Struct.new(:src_start_id, :dest_start_id, :range_length) do
    def src_range_end
        src_start_id + range_length
    end
    def dest_range_end
        dest_start_id + range_length
    end

    def convert(id)
        # comment out for speed
        raise "outside range" if id < src_start_id || id > src_range_end
        return id - src_start_id + dest_start_id
    end

    # Splits this map in two so that the first part (this map) will have a length of `new_length`. A
    # new map is returned for the latter part.
    def split_off(new_length)
        raise "invalid length #{new_length}" if new_length == 0 || new_length == range_length

        new_map = IdMap.new(src_start_id + new_length, dest_start_id + new_length,
            range_length - new_length)
        self.range_length = new_length
        new_map
    end
end

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
                return map.convert(id)
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
    seed_nums = line_enum.next.delete_prefix("seeds: ").split(" ").map { Integer(_1) }
    seed_ranges = seed_nums.each_slice(2).map { SeedRange.new(_1[0], _1[1]) }

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

    [seed_ranges, maps]
end

# Splits the seed id map at `map_index` if the `at_id` is not at the beginning or end of it.
def maybe_split_seed_id_map(seed_id_maps, map_index, at_id)
    #puts "maybe_split  seed_id_maps_len: #{seed_id_maps.length}, map_index: #{map_index}, at_id: #{at_id}"
    seed_id_map = seed_id_maps[map_index]
    if at_id > seed_id_map.dest_start_id &&
    at_id < seed_id_map.dest_range_end
        #puts "    splitting"
        split_off_map = seed_id_map.split_off(at_id - seed_id_map.dest_start_id)
        seed_id_maps.insert(map_index + 1, split_off_map)
    end
end

# seed_id_maps should be sorted by `dest_start_id`
def apply_cat_map(seed_id_maps, cat_map)
    # I have to convert all the ids for a category at once. Otherwise, the second IdMap in the
    # category will try translating IDs that were already translated and break them.
    #p seed_id_maps

    split_ids = cat_map.id_maps.map { _1.src_start_id }
    split_ids += cat_map.id_maps.map { _1.src_range_end }
    split_ids.uniq!  # I could instead do this myself faster if it's sorted
    split_ids.sort!
    #p split_ids

    i = 0  # seed_id_maps
    j = 0  # split_ids
    j += 1 while j < split_ids.length && split_ids[j] < seed_id_maps[0].dest_start_id
    while i < seed_id_maps.length
        break if j == split_ids.length
        while j < split_ids.length && split_ids[j] < seed_id_maps[i].dest_range_end
            maybe_split_seed_id_map(seed_id_maps, i, split_ids[j])
            j += 1
        end
        i += 1
    end

    for seed_id_map in seed_id_maps
        seed_id_map.dest_start_id = cat_map.convert(seed_id_map.dest_start_id)
    end

    # Now that dest_start_id was remapped, the modified objects need to be moved.
    seed_id_maps.sort_by! { _1.dest_start_id }
end

start_time = Time.now

input = IO.readlines("d5_input").map { |line| line.chomp }
seed_ranges, cat_maps = parse_input(input)
# Start off with an identity map for each seed range.
seed_id_maps = seed_ranges.map { IdMap.new(_1.start_id, _1.start_id, _1.length) }
seed_id_maps.sort_by! { _1.dest_start_id }
# Then build a direct seed id to location id map in place of going through 7 layers of maps.
cat_maps.each { apply_cat_map(seed_id_maps, _1) }
#p seed_id_maps

# Since it's sorted by `dest_start_id`` and the dest is location, then the first `dest_start_id` is
# the smallest location id.
puts
puts seed_id_maps[0].dest_start_id

puts
puts format("Took %.1f ms", (Time.now - start_time).to_f * 1000)
