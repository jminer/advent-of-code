
# Part 2 took me 2:42 AM - 2:56 AM (14 mins)

RaceRecords = Struct.new(:time, :distance)

TIME_PREFIX = "Time: "
DISTANCE_PREFIX = "Distance: "

def parse_race_record(lines)
    "invalid input" if !lines[0].start_with?(TIME_PREFIX) || !lines[1].start_with?(DISTANCE_PREFIX)
    lines[0].delete_prefix! TIME_PREFIX
    lines[1].delete_prefix! DISTANCE_PREFIX
    time, distance = lines[0..1].map do |line|
        Integer(line.gsub(" ", ""))
    end
    RaceRecords.new(time, distance)
end

#   h = button-hold time
#   t = travel time
#   raceTime = h + t
#   h * t = newDistance
# Substituting:
#   t = raceTime - h,   h * (raceTime - h) = newDistance
#   raceTime*h - h^2 = newDistance
#   -h^2 + raceTime*h - newDistance = 0
# https://en.wikipedia.org/wiki/Quadratic_formula
# Using quadratic formula, with coefficients a = -1, b = raceTime, c = -newDistance
#   h = (-raceTime +- sqrt(raceTime^2 - 4*(-1)*(-newDistance)) ) / (2 * -1)
#   h = (-raceTime +- sqrt(raceTime^2 - 4*newDistance)) ) / -2

def get_race_button_hold_times(race_record)
    new_distance = race_record.distance + 1.0
    part = Math.sqrt(race_record.time ** 2 - 4.0 * new_distance)
    first = (-race_record.time + part) / -2.0
    second = (-race_record.time - part) / -2.0
    [first.ceil, second.floor]
end

start_time = Time.now


input = IO.readlines("d6_input").map { |line| line.chomp }
race_record = parse_race_record(input)
times = get_race_button_hold_times race_record
#puts "times: #{times[0]} to #{times[1]}"
ways_to_beat = times[1] - times[0] + 1
puts ways_to_beat

# One-liner to brute-force
#(0..46807866).inject(0) { if _2 * (46807866 - _2) > 214117714021024 then _1 + 1 else _1 end }

# One-liner to brute-force using input file
#t, d = race_record.time, race_record.distance
#puts (0..t).inject(0) { if _2 * (t - _2) > d then _1 + 1 else _1 end }

puts
puts format("Took %.1f ms", (Time.now - start_time).to_f * 1000)
