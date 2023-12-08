
# Part 1 took me 1:46 AM - 

RaceRecords = Struct.new(:time, :distance)

TIME_PREFIX = "Time: "
DISTANCE_PREFIX = "Distance: "

def parse_race_records(lines)
    "invalid input" if !lines[0].start_with?(TIME_PREFIX) || !lines[1].start_with?(DISTANCE_PREFIX)
    lines[0].delete_prefix! TIME_PREFIX
    lines[1].delete_prefix! DISTANCE_PREFIX
    times, distances = lines[0..1].map do |line|
        line.split(" ").map { Integer(_1.strip) }
    end
    times.zip(distances).map { |t, d| RaceRecords.new(t, d) }
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
race_records = parse_race_records(input)
ways_to_beat_races = race_records.map do |record|
    times = get_race_button_hold_times record
    #puts "times: #{times[0]} to #{times[1]}"
    times[1] - times[0] + 1
end
puts ways_to_beat_races.inject(1) { _1 * _2 }


puts
puts format("Took %.1f ms", (Time.now - start_time).to_f * 1000)
