
# Part 1 took me 10:48 PM - 10:59 PM, 1:15 AM - 1:23 AM (19 min)

Card = Struct.new(:num, :winning_nums, :have_nums)

def parse_card(line)
    card_parts = line.split ":"
    card_num = Integer(card_parts[0].delete_prefix("Card "))
    winning_nums, have_nums = card_parts[1].split(" | ").map do |nums_list|
        nums_list.split(" ").map { Integer(_1.strip) }
    end
    Card.new(card_num, winning_nums, have_nums)
end

start_time = Time.now

input = IO.readlines("d4_input").map { |line| line.chomp }
cards = input.map { parse_card _1 }
card_points = cards.map { |card| 1 << (card.winning_nums.intersection(card.have_nums).length - 1) }
p card_points
sum = card_points.inject(0) { _1 + _2 }
puts sum

puts
puts format("Took %.1f ms", (Time.now - start_time).to_f * 1000)
