
# Part 1 took me 7:37 PM - 8:30 PM, 11:14 PM - 11:21 PM (60 mins)

Position = Struct.new(:x, :y)

def expand_image(rows)
    # True if a galaxy was in the column, and false if empty.
    col_mask = Array.new(rows.first.bytesize, false)
    for i in (rows.length - 1).downto(0)
        rows.insert(i + 1, rows[i].dup) if rows[i].bytes.all? ".".ord
        for j in 0...rows[i].bytesize
            col_mask[j] |= rows[i].getbyte(j) == "#".ord
        end
    end
    for i in (col_mask.length - 1).downto(0)
        if !col_mask[i]
            for row in rows
                row.insert(i, ".")
            end
        end
    end
    rows
end

def find_galaxies(image_rows)
    galaxy_positions = []
    for y in 0...image_rows.length
        x = -1
        while (x = image_rows[y].index("#", x + 1))
            galaxy_positions.push Position.new(x, y)
        end
    end
    galaxy_positions
end

def get_distances_sum(galaxy_positions)
    galaxy_positions.sort_by! { _1.y }
    y_sum = 0
    y_increment = 0
    for i in 1...galaxy_positions.length
        delta = galaxy_positions[i].y - galaxy_positions[i - 1].y
        y_increment += i * delta
        y_sum += y_increment
    end
    #puts "y_sum: #{y_sum}"

    galaxy_positions.sort_by! { _1.x }
    x_sum = 0
    x_increment = 0
    for i in 1...galaxy_positions.length
        delta = galaxy_positions[i].x - galaxy_positions[i - 1].x
        x_increment += i * delta
        x_sum += x_increment
    end
    #puts "x_sum: #{x_sum}"

    y_sum + x_sum
end

start_time = Time.now

input = IO.readlines("d11_input").map { |line| line.chomp }
expanded_image = expand_image(input)
galaxy_positions = find_galaxies(input)
puts get_distances_sum galaxy_positions

puts
puts format("Took %.1f ms", (Time.now - start_time).to_f * 1000)
