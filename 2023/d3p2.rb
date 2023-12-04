
# Part 2 took me 1:50 AM - 2:34 AM

def is_num_char(s)
    s.ord >= "0".ord && s.ord <= "9".ord
end

# Takes a string and index in that string, and if the index is a number character, gets the whole
# number containing that character. For example `get_num_around("..8745..", 3)` returns "8745"
# because index 3 is "7" and it expands in both directions.
def get_num_around(s, i)
    return nil if !is_num_char(s[i])
    start_index = i
    start_index -= 1 while start_index > 0 && is_num_char(s[start_index - 1])
    end_index = i + 1
    end_index += 1 while end_index < s.length && is_num_char(s[end_index])
    s[start_index...end_index]
end

def get_nums_above_or_below(adjacent_line, star_index)
    nums = []
    # one number above/below
    if is_num_char(adjacent_line[star_index])
        nums.push get_num_around(adjacent_line, star_index)
    else
        # diagonal up-left
        if star_index > 0 && is_num_char(adjacent_line[star_index - 1])
            nums.push get_num_around(adjacent_line, star_index - 1)
        end
        # diagonal up-right
        if star_index < adjacent_line.length - 1 && is_num_char(adjacent_line[star_index + 1])
            nums.push get_num_around(adjacent_line, star_index + 1)
        end
    end
    nums
end

def get_gear_ratio_sum(lines)
    i = 0
    sum = 0
    while i < lines.length
        line = lines[i]
        offset = 0
        while true
            star_index = line.index("*", offset)
            break if !star_index
            offset = star_index + 1

            nums = []
            # check to the left
            if star_index > 0 && is_num_char(line[star_index - 1])
                nums.push get_num_around(line, star_index - 1)
            end
            # check to the right
            if star_index < line.length - 1 && is_num_char(line[star_index + 1])
                nums.push get_num_around(line, star_index + 1)
            end
            if i > 0
                prev_line = lines[i - 1]
                nums += get_nums_above_or_below(prev_line, star_index)
            end
            if i < lines.length - 1
                next_line = lines[i + 1]
                nums += get_nums_above_or_below(next_line, star_index)
            end
            # a gear ratio has to have two
            sum += nums.inject(1) { |ratio, num| ratio * Integer(num) } if nums.length >= 2
        end
        i += 1
    end
    sum
end

input = IO.readlines("d3_input").map { |line| line.chomp }
sum = get_gear_ratio_sum(input)
puts sum
