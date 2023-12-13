
# Part 1 took me 3:07 AM - 3:32 AM (25 mins)

def parse_input(lines)
    lines.map { |line| line.split(" ").map { Integer(_1) } }
end

def get_derivative_seq(seq)
    deriv_seq = []
    for i in 1...seq.length
        deriv_seq.push(seq[i] - seq[i - 1])
    end
    deriv_seq
end

def predict_value(history)
    # And array of arrays of numbers, each another level of derivative
    changes = [history.dup]
    while true
        changes.push get_derivative_seq(changes.last)
        break if changes.last.all?(0)
    end

    # Add a new predicted value to each row
    changes.last.push 0
    for i in (changes.length - 2).downto(0)
        changes[i].push(changes[i].last + changes[i + 1].last)
    end
    changes.first.last
end

start_time = Time.now

input = IO.readlines("d9_input").map { |line| line.chomp }
histories = parse_input(input)
sum = histories.map { predict_value(_1) }.inject(0) { _1 + _2 }
puts sum

puts
puts format("Took %.1f ms", (Time.now - start_time).to_f * 1000)
