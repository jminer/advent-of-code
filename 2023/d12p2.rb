
# Part 1 took me 5:09 PM -

UNFOLD_MULTIPLE = 5

# . = 0 = working and # = 1 = damaged
# `conditions_mask` is the mask of known conditions
Record = Struct.new(:count, :conditions, :conditions_mask, :groups) do
    def slice(new_count, new_groups)
        count_diff = count - new_count
        Record.new(new_count, conditions >> count_diff, conditions_mask >> count_diff, new_groups)
    end
    def unfold
        new_cond = 0
        new_cond_mask = 0
        for i in 0...UNFOLD_MULTIPLE
            # count + 1 because they are to be separated by ?
            new_cond |= conditions << (i * (count + 1))
            new_cond_mask |= conditions_mask << (i * (count + 1))
        end
        # UNFOLD_MULTIPLE + 1 because they are to be separated by ?
        Record.new(count * (UNFOLD_MULTIPLE + 1), new_cond, new_cond_mask, groups * UNFOLD_MULTIPLE)
    end
    def inspect
        cond_str = ""
        for i in 0...count
            if (conditions_mask & (1 << i)) != 0
                cond_str.concat (conditions & (1 << i)) != 0 ? "#" : "."
            else
                cond_str.concat "?"
            end
        end
        "Record count=#{count}, conditions=#{cond_str}, groups=#{groups}"
    end
end

def parse_springs_records(lines)
    lines.map do |line|
        conditions_str, groups_str = line.split(" ")
        conditions = 0
        conditions_mask = 0
        conditions_bytes = conditions_str.bytes
        for i in 0...conditions_bytes.length
            c = conditions_bytes[i]
            if c == "#".ord
                conditions |= (1 << i)
                conditions_mask |= (1 << i)
            elsif c == ".".ord
                conditions_mask |= (1 << i)
            else
                raise "invalid character" if c != "?".ord
            end
        end
        groups = groups_str.split(",").map { Integer(_1) }
        Record.new(conditions_bytes.length, conditions, conditions_mask, groups).unfold
    end
end

# Returns the minimum length necessary to fit the specified groups.
def get_groups_min_size(groups)
    return 0 if groups.length == 0
    groups.inject(0) { _1 + _2 } + groups.length - 1
end

def set_bits(bit_count)
    (1 << bit_count) - 1
end

def bits_equal(a, b, mask)
    (a & mask) == (b & mask)
end

def get_num_combos(record, level = 0)
    if record.groups.length == 0
        if (record.conditions & record.conditions_mask) != 0
            return 0
        else
            return 1
        end
    end
    group = record.groups.first
    rem_groups = record.groups[1..]
    rem_min_size = get_groups_min_size(rem_groups)

    # For example, if `count` is 3, and `group` is 1, there are clearly three positions for the 1 if
    # it's the last group. If the group has to have a space afterward because there are more groups,
    # that reduces the available size.
    avail_size = record.count - rem_min_size - (group - 1)
    avail_size -= 1 if rem_groups.length > 1
    #puts "#{" "*(2*level)}avail_size: #{avail_size}"
    combo_count = 0
    for i in 0...avail_size
        # group + 2 for space before and after group
        
        # Shift all up by one to check for a 0 before the group. This only matters at the beginning,
        # because later calls will have checked before the call.
        is_valid_here = bits_equal(set_bits(group) << i, record.conditions,
            set_bits(group + 1 + i) & record.conditions_mask)
        #puts "#{" "*(2*level)}i=#{i}, #{is_valid_here}, #{record.inspect}"
        next if !is_valid_here
        combo_count += get_num_combos(record.slice(record.count - (i + group + 1), rem_groups), level + 1)
    end
    #puts "#{" "*(2*level)}ret combo_count: #{combo_count}"
    combo_count
end

def generate_combos(count, groups)
    return [0] if groups.length == 0
    combos = []
    group = groups.first
    rem_groups = groups[1..]
    rem_min_size = get_groups_min_size(rem_groups)
    avail_size = count - rem_min_size - (group - 1)

    for i in 0...avail_size
        combo = set_bits(group) << i
        shift = (i + group + 1)
        sub_combos = generate_combos(count - shift, rem_groups)
        combos += sub_combos.map { _1 << shift | set_bits(group) << i }
    end

    combos
end

def filter_combos(combos, record)
    combos.select do |combo|
        bits_equal(combo, record.conditions, record.conditions_mask)
    end
end

def combo_to_s(count, combo)
    s = ""
    for i in 0...count
        s += (combo & 1) == 1 ? "#" : "."
        combo = combo >> 1
    end
    s
end

def test_one(line, expected_combos)
    rec = parse_springs_records([line]).first
    #combos_list = generate_combos(rec.count, rec.groups)
    #combos_list.each { puts combo_to_s(rec.count, _1) }
    combos = get_num_combos(rec)
    passed_str = combos == expected_combos ? "PASSED" : "FAILED❌"
    puts "#{passed_str}: #{combos} == #{expected_combos} combos in #{rec.inspect}"
end

def test_some
    test_one("???.### 1,1,3", 1)
    test_one(".??..??...?##. 1,1,3", 4)
    test_one("?#?#?#?#?#?#?#? 1,3,1,6", 1)
    test_one("????.#...#... 4,1,1", 1)
    test_one("????.######..#####. 1,6,5", 4)
    test_one("?###???????? 3,2,1", 10)

    test_one(".#????.??? 1,2", 4)
    test_one("????????.?#? 1,1,2,2", 20)
    test_one("??.#??.#??. 1,1,1", 4)
end
# test_some

start_time = Time.now

input = IO.readlines("d12_input").map { |line| line.chomp }
records = parse_springs_records(input)
# p records

combos = []
for i in 0...records.length
    combos.push(get_num_combos(records[i]))
    puts "i=#{i}, num_combos: #{combos.last}"
end
# combos = records.map { get_num_combos(_1) }
# combos2 = records.map { filter_combos(generate_combos(_1.count, _1.groups), _1).length }
# for i in 0...records.length
#     puts "#{combos[i]} #{combos2[i]}   #{records[i].inspect}"
# end
# puts combos.inject(0) { _1 + _2 }

puts
puts format("Took %.1f ms", (Time.now - start_time).to_f * 1000)
