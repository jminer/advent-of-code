
# Part 1 took me 7:34 PM - 8:24 PM (50 mins)

module HandTypes
    FIVE_OF_A_KIND = 7
    FOUR_OF_A_KIND = 6
    FULL_HOUSE = 5
    THREE_OF_A_KIND = 4
    TWO_PAIR = 3
    ONE_PAIR = 2
    HIGH_CARD = 1
end

CARD_BYTE_STRENGTHS = %w(A K Q T 9 8 7 6 5 4 3 2 J).map { _1.ord }.reverse.each_with_index.to_h

class Hand
    attr_accessor :cards, :bid, :hand_type
    def initialize(cards, bid)
        @cards = cards
        @bid = bid
        init_hand_type
    end

    def <=>(other)
        type_cmp = hand_type <=> other.hand_type
        return type_cmp if type_cmp != 0
        for i in 0...cards.length
            card_cmp = CARD_BYTE_STRENGTHS[cards.getbyte(i)] <=>
                CARD_BYTE_STRENGTHS[other.cards.getbyte(i)]
            return card_cmp if card_cmp != 0
        end
        0
    end

    private

    def init_hand_type
        card_bytes = @cards.bytes
        card_bytes.sort!

        non_joker_card_bytes = card_bytes.dup
        non_joker_card_bytes.delete("J".ord)
        runs = []
        dup_counter = 1
        for i in 1...non_joker_card_bytes.length
            if non_joker_card_bytes[i] == non_joker_card_bytes[i - 1]
                dup_counter += 1
            else
                runs.push dup_counter
                dup_counter = 1
            end
        end
        runs.push dup_counter
        #p runs

        # Add the number of jokers to whatever the most common card is as that will increase the
        # strength of the hand the most.
        runs.sort! { _2 <=> _1}
        runs[0] += card_bytes.count("J".ord)

        if runs[0] == 5
            @hand_type = HandTypes::FIVE_OF_A_KIND
        elsif runs.include?(4)
            @hand_type = HandTypes::FOUR_OF_A_KIND
        elsif runs.include?(3)
            @hand_type = runs.include?(2) ? HandTypes::FULL_HOUSE : HandTypes::THREE_OF_A_KIND
        elsif runs.count(2) == 2
            @hand_type = HandTypes::TWO_PAIR
        elsif runs.count(2) == 1
            @hand_type = HandTypes::ONE_PAIR
        else
            @hand_type = HandTypes::HIGH_CARD
        end
        #p hand_type
    end
end

def parse_hand(line)
    cards, bid_str = line.split(" ")
    bid = Integer(bid_str)
    Hand.new(cards, bid)
end


start_time = Time.now

input = IO.readlines("d7_input").map { |line| line.chomp }
hands = input.map { parse_hand _1 }
hands.sort!
puts hands.each_with_index.inject(0) { |sum, (hand, i)| sum + hand.bid * (i + 1) }

puts
puts format("Took %.1f ms", (Time.now - start_time).to_f * 1000)
