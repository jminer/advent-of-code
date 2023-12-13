
# Part 2 took me 3:32 AM - 3:41 AM (9 mins)

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
    changes.last.unshift 0
    for i in (changes.length - 2).downto(0)
        changes[i].unshift(changes[i].first - changes[i + 1].first)
    end
    changes.first.first
end

start_time = Time.now

input = IO.readlines("d9_input").map { |line| line.chomp }
histories = parse_input(input)
predictions = histories.map { predict_value(_1) }
#p predictions
sum = predictions.inject(0) { _1 + _2 }
puts sum

puts
puts format("Took %.1f ms", (Time.now - start_time).to_f * 1000)
