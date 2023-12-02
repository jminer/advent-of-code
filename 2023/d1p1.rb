
def cal_value(s)
    i = 0
    start_match = s.match /^[^\d]*(\d)/
    end_match = s.match /(\d)[^\d]*$/
    (start_match[1] + end_match[1]).to_i
end

input = IO.readlines("d1_input").map { |line| line.chomp }
sum = 0
input.each do |line|
    sum += cal_value(line)
end
p sum
