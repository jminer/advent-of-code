
# Part 2 took me 1:48 PM - 2:14 PM (26 mins)

Position = Struct.new(:x, :y)

def get_expansion_mask(rows)
    # True if a galaxy was in the column, and false if empty.
    col_empty_mask = Array.new(rows.first.bytesize, true)
    row_empty_mask = []
    for row in rows
        row_empty_mask.push row.bytes.all?(".".ord)
        for j in 0...row.bytesize
            col_empty_mask[j] = false if row.getbyte(j) == "#".ord
        end
    end
    [col_empty_mask, row_empty_mask]
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

EXPANSION = 1_000_000 - 1

def expand_galaxy_positions(galaxy_positions, col_empty_mask, row_empty_mask)
    col_empty_count = 0
    col_empty_counts = col_empty_mask.map { col_empty_count += _1 ? 1 : 0 }
    galaxy_positions.sort_by! { _1.x }
    offset = 0
    for pos in galaxy_positions
        pos.x += col_empty_counts[pos.x] * EXPANSION
    end

    row_empty_count = 0
    row_empty_counts = row_empty_mask.map { row_empty_count += _1 ? 1 : 0 }
    galaxy_positions.sort_by! { _1.y }
    offset = 0
    for pos in galaxy_positions
        pos.y += row_empty_counts[pos.y] * EXPANSION
    end
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
expansion_masks = get_expansion_mask(input)
galaxy_positions = find_galaxies(input)
expand_galaxy_positions(galaxy_positions, *expansion_masks)
puts get_distances_sum galaxy_positions

puts
puts format("Took %.1f ms", (Time.now - start_time).to_f * 1000)
