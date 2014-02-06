# Any live cell with fewer than two live neighbours dies, as if caused by under-population.
# Any live cell with two or three live neighbours lives on to the next generation.
# Any live cell with more than three live neighbours dies, as if by overcrowding.
# Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

require 'highline'
require 'test/unit'

class World
  attr_reader :width, :height
  attr_accessor :grid

  def initialize(width, height)
    @width  = width
    @height = height
    @grid   = Array.new(width) { Array.new(height) { false } }
  end

  def force_alive(x, y)
    self.grid[x][y] = true
  end

  def grid_dup
    duped = []
    grid.each {|r| duped << r.dup}
    duped
  end

  def tick
    duped = grid_dup

    (0...@width).each do |x|
      (0...@height).each do |y|
        n = num_neighbors_alive(x,y)
        if is_cell_alive(x,y)
          if n < 2
            duped[x][y] = false
          elsif n > 3
            duped[x][y] = false
          end
        else
          if n == 3
            duped[x][y] = true
          end
        end
      end
    end

    @grid = duped
    out
  end

  def is_cell_alive(x, y)
    self.grid[x][y]
  end

  def num_neighbors_alive(x,y)
    num = 0

    (-1..1).each do |i|
      (-1..1).each do |j|
        next if i == 0 && j == 0
        next if x+i < 0 || x+i >= @width
        next if y+j < 0 || y+j >= @height

        num += 1 if is_cell_alive(x+i,y+j)
      end
    end

    num
  end

  def out
    system('clear')
    (0...@height).each do |y|
      (0...@width).each do |x|
        print(@grid[x][y] ? 'O ' : '  ')
      end
      puts
    end
  end
end

class WorldTest < Test::Unit::TestCase
  def setup
    @world = World.new(10,10)
  end

  def test_lonely_cell_dies
    @world.force_alive(5, 5)

    assert(@world.is_cell_alive(5,5))

    @world.tick

    refute(@world.is_cell_alive(5,5))
  end

  def test_neighborly_cell_lives
    @world.force_alive(5, 5)
    @world.force_alive(5, 6)
    @world.force_alive(5, 7)
    @world.tick
    assert(@world.is_cell_alive(5,6))
  end

  def test_num_neighbors_alive
    @world.force_alive(5, 5)
    @world.force_alive(5, 6)
    @world.force_alive(5, 7)

    assert(@world.num_neighbors_alive(5,6) == 2)
  end

  def test_for_new_babies
    @world.force_alive(5, 5)
    @world.force_alive(5, 6)
    @world.force_alive(5, 7)
    @world.tick

    assert(@world.is_cell_alive(6,6))
  end

  def test_cells_suffocate
    @world.force_alive(5, 5)
    @world.force_alive(5, 6)
    @world.force_alive(5, 7)
    @world.force_alive(6, 6)
    @world.force_alive(6, 7)
    @world.tick

    refute(@world.is_cell_alive(5,6))
    refute(@world.is_cell_alive(6,6))
  end
end

def generate(world)
  1000.times do
    world.force_alive(rand(world.width), rand(world.height))
  end
end

width, height = HighLine::SystemExtensions.terminal_size
width = width/2
w = World.new(width, height)
generate(w)

while true do
  sleep 0.01
  w.tick
end
