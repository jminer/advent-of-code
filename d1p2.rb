
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

def check_digit_at(s, i)
    for num in 0..9
        if s[i..].start_with?(DIGITS[num]) || s[i..].start_with?(WORD_DIGITS[num])
            return num
        end
    end
    nil
end

def cal_value(s)
    for i in 0..(s.length - 1)
        break if first_num = check_digit_at(s, i)
    end
    for i in (s.length - 1).downto(0)
        break if last_num = check_digit_at(s, i)
    end
    first_num * 10 + last_num
end

input = IO.readlines("d1_input").map { |line| line.chomp }
sum = 0
input.each do |line|
    sum += cal_value(line)
end
p sum
