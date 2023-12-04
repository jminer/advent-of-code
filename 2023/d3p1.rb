
# Part 1 took me 2:39 - 3:12 PM

def is_string_periods(s)
    s.each_byte { return false if _1 != ".".ord }
    true
end

def get_sum(lines)
    i = 0
    sum = 0
    while i < lines.length
        line = lines[i]
        offset = 0
        while true
            match = line.match(/(\d+)/, offset)
            break if !match
            offset = match.end(0)
            
            is_part_number = false
            is_part_number |= match.begin(0) > 0 && line[match.begin(0) - 1] != "."
            is_part_number |= match.end(0) < line.length && line[match.end(0)] != "."
            range_start = match.begin(0) > 0 ? match.begin(0) - 1 : 0
            range_end = match.end(0) < line.length ? match.end(0) + 1 : line.length
            if i > 0
                prev_line = lines[i - 1]
                is_part_number |= !is_string_periods(prev_line[range_start...range_end])
            end
            if i < lines.length - 1
                next_line = lines[i + 1]
                is_part_number |= !is_string_periods(next_line[range_start...range_end])
            end
            #puts "found " + match[0] + " " + is_part_number.to_s
            sum += match[0].to_i if is_part_number
        end
        i += 1
    end
    sum
end

input = IO.readlines("d3_input").map { |line| line.chomp }
sum = get_sum(input)
puts sum
