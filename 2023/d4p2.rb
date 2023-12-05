
# Part 2 took me 1:26 AM - 2:15 AM

Card = Struct.new(:num, :winning_nums, :have_nums)

def parse_card(line)
    card_parts = line.split ":"
    card_num = Integer(card_parts[0].delete_prefix("Card "))
    winning_nums, have_nums = card_parts[1].split(" | ").map do |nums_list|
        nums_list.split(" ").map { Integer(_1.strip) }
    end
    Card.new(card_num, winning_nums, have_nums)
end

def get_matching_count(card)
    card.winning_nums.intersection(card.have_nums).length
end

CardMatchCount = Struct.new(:card_num, :matching_count, :copy_count)

start_time = Time.now

input = IO.readlines("d4_input").map { |line| line.chomp }
cards = input.map { parse_card _1 }
card_matches = cards.map { |card| CardMatchCount.new(card.num, get_matching_count(card), nil) }
total_card_count = card_matches.length
# Since a card can only copy cards after it, going backwards ensures the copy count has already been
# calculated for any cards it copies.
for i in (card_matches.length - 1).downto(0)
    puts "can't copy that many" if card_matches.length - i < card_matches[i].matching_count
    direct_copies = card_matches[i + 1, card_matches[i].matching_count]
    card_matches[i].copy_count =
        direct_copies.inject(card_matches[i].matching_count) { _1 + _2.copy_count }
    total_card_count += card_matches[i].copy_count
end
puts total_card_count

puts
puts format("Took %.1f ms", (Time.now - start_time).to_f * 1000)
