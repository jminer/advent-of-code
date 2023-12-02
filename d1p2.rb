
DIGITS = %w(
    0
    1
    2
    3
    4
    5
    6
    7
    8
    9
)
WORD_DIGITS = %w(
    zero
    one
    two
    three
    four
    five
    six
    seven
    eight
    nine
)

def cal_value(s)
    first_index = s.length
    first_num = nil
    last_index = -1
    last_num = nil
    for i in 0..s.length
        for num in 0..9
            matches = s[i..].start_with?(DIGITS[num]) || s[i..].start_with?(WORD_DIGITS[num])
            if matches && i < first_index
                first_index = i
                first_num = num
            end
            if matches && i > last_index
                last_index = i
                last_num = num
            end
        end
    end
    first_num * 10 + last_num
end

input = IO.readlines("d1_input").map { |line| line.chomp }
sum = 0
input.each do |line|
    sum += cal_value(line)
end
p sum
