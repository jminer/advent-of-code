
# Part 2 took me 3:02 AM - 5:05 AM, 7:07 PM -

Position = Struct.new(:x, :y)

module Edges
    WEST = 1
    NORTH = 2
    EAST = 4
    SOUTH = 8
end

CHAR_EDGES = {
    "|".ord => Edges::NORTH | Edges::SOUTH,
    "-".ord => Edges::EAST | Edges::WEST,
    "L".ord => Edges::NORTH | Edges::EAST,
    "J".ord => Edges::NORTH | Edges::WEST,
    "7".ord => Edges::SOUTH | Edges::WEST,
    "F".ord => Edges::SOUTH | Edges::EAST,
}

def opposite_edge(edge)
    if edge == Edges::WEST then Edges::EAST
    elsif edge == Edges::NORTH then Edges::SOUTH
    elsif edge == Edges::EAST then Edges::WEST
    elsif edge == Edges::SOUTH then Edges::NORTH
    end
end

def first_edge(edges_mask)
    if (edges_mask & Edges::WEST) != 0 then Edges::WEST
    elsif (edges_mask & Edges::NORTH) != 0 then Edges::NORTH
    elsif (edges_mask & Edges::SOUTH) != 0 then Edges::SOUTH
    elsif (edges_mask & Edges::EAST) != 0 then Edges::EAST
    end
end

class Map
    attr_accessor :lines, :start_pos
    def initialize(lines)
        @lines = lines
        x = nil
        y = lines.index do |line|
            x = line.index "S"
        end
        @start_pos = Position.new(x, y)
    end

    def getbyte(pos)
        @lines[pos.y].getbyte(pos.x)
    end
    def getbyte_west(pos)
        return nil if pos.x == 0
        @lines[pos.y].getbyte(pos.x - 1)
    end
    def getbyte_east(pos)
        return nil if pos.x == @lines[pos.y].length - 1
        @lines[pos.y].getbyte(pos.x + 1)
    end
    def getbyte_north(pos)
        return nil if pos.y == 0
        @lines[pos.y - 1].getbyte(pos.x)
    end
    def getbyte_south(pos)
        return nil if pos.y == @lines.length - 1
        @lines[pos.y + 1].getbyte(pos.x)
    end
end

class Walker
    def initialize(map)
        @map = map
        @pos = map.start_pos
        @from_edge = nil
    end

    def next
        return nil if @pos == @map.start_pos && @from_edge

        valid_edges = conn_edges(@pos)
        # valid_edges should contain two edges, so reduce it to one
        if @from_edge
            valid_edges &= ~@from_edge
        else
            # For the starting position, from_edge is nil, and we just pick the first edge.
            valid_edges = first_edge(valid_edges)
        end
        # Move the position based on the one edge
        @pos = if valid_edges == Edges::WEST
            Position.new(@pos.x - 1, @pos.y)
        elsif valid_edges == Edges::NORTH
            Position.new(@pos.x, @pos.y - 1)
        elsif valid_edges == Edges::EAST
            Position.new(@pos.x + 1, @pos.y)
        elsif valid_edges == Edges::SOUTH
            Position.new(@pos.x, @pos.y + 1)
        end
        @from_edge = opposite_edge(valid_edges)
        @pos
    end

    private
    # Returns a bitmask of which edges are connected to the specified position, looking at the
    # character at the position and taking into account the edge of the map.
    def conn_edges(pos)
        edges = 0
        c = @map.getbyte(pos)
        if c == "S".ord
            edges |= get_start_edges
        elsif c != ".".ord
            edges |= CHAR_EDGES[c]
        end
        invalid_edges = 0
        invalid_edges |= Edges::WEST if pos.x == 0
        invalid_edges |= Edges::EAST if pos.x == @map.lines[pos.y].length - 1
        invalid_edges |= Edges::NORTH if pos.y == 0
        invalid_edges |= Edges::SOUTH if pos.y == @map.lines.length - 1
        edges &= ~invalid_edges
        edges
    end

    def get_start_edges
        edges = 0
        if ["-".ord, "L".ord, "F".ord].include? @map.getbyte_west(@map.start_pos)
            edges |= Edges::WEST
        end
        if ["|".ord, "7".ord, "F".ord].include? @map.getbyte_north(@map.start_pos)
            edges |= Edges::NORTH
        end
        if ["|".ord, "L".ord, "J".ord].include? @map.getbyte_south(@map.start_pos)
            edges |= Edges::SOUTH
        end
        if ["-".ord, "J".ord, "7".ord].include? @map.getbyte_east(@map.start_pos)
            edges |= Edges::EAST
        end
        edges
    end
end

def walk_path(map)
    walker = Walker.new(map)
    path = [map.start_pos]
    while true
        pos = walker.next
        break if !pos
        path.push pos
    end
    path
end

def get_path_inside_count(map, path)
    # A Hash of row y => array of positions on that row
    path_by_row = Hash.new
    # Skip first item because it's the duplicated start pos. Sort by y so that the hash is ordered
    # nicely only for easier debugging.
    sorted_path = path[1..].sort_by { _1.y }
    for pos in sorted_path
        if path_by_row[pos.y]
            path_by_row[pos.y].push pos
        else
            path_by_row[pos.y] = [pos]
        end
    end
    path_by_row.transform_values! { |pos_arr| pos_arr.sort_by! { _1.x } }

    inside_count = 0
    #p path_by_row
    path_by_row.each do |y, pos_arr|
        # This is basically the even/odd fill rule that 2D graphics use.
        i = 0
        is_inside = false
        inside_start_x = nil
        while i < pos_arr.length
            #puts "x: #{pos_arr[i].x}, inside_start_x: #{inside_start_x}"
            if inside_start_x
                inside_count += pos_arr[i].x - inside_start_x - 1
                inside_start_x = nil
            end
            # Skip ahead so that every loop iteration is a crossing
            is_vert_crossing = false
            if "LF".bytes.include?(map.getbyte(pos_arr[i]))
                horiz_start = map.getbyte(pos_arr[i])
                i += 1 while !"J7".bytes.include?(map.getbyte(pos_arr[i]))
                horiz_end = map.getbyte(pos_arr[i])
                # LJ isn't a vertical crossing, nor is F7. Only FJ or L7 are crossings.
                is_vert_crossing = ["FJ".bytes, "L7".bytes].include?([horiz_start, horiz_end])
            elsif map.getbyte(pos_arr[i]) == "|".ord
                is_vert_crossing = true
            end
            is_inside = !is_inside if is_vert_crossing
            inside_start_x = pos_arr[i].x if is_inside
            i += 1
        end
        #pos_arr.each_slice(2) { inside_count += p _2.x - _1.x - 1 if _2 }
        #puts "y: #{y}  inside: #{inside_count}"
    end
    inside_count
end

start_time = Time.now

input = IO.readlines("d10_input").map { |line| line.chomp }
map = Map.new(input)
path = walk_path(map)
#p path
puts get_path_inside_count(map, path)

puts
puts format("Took %.1f ms", (Time.now - start_time).to_f * 1000)
