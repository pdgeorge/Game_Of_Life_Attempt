#Draws Conway's Game of Life

require 'rubygems'
require 'gosu'

# Global constants
WIN_WIDTH = 640
WIN_HEIGHT = 480
CELL_DIM = 10
CELL_BORDER = 1
BACKGROUND = Gosu::Color::WHITE
DEAD_COLOUR = Gosu::Color::WHITE
LIVING_COLOUR = Gosu::Color::BLUE
BORDER_COLOUR = Gosu::Color::BLACK
SEED_MIN = 00 # The higher this number is, the more likely a cell will be alive on game start. For one frame.
RANDOM_LIFE = false # defines if life randomly spawns

class Cell
  attr_accessor :x, :y, :c, :alive, :neighbours

  def initialize (x, y, c, alive)
    @x = x
    @y = y
    @c = c
    @alive = alive
    @neighbours = 0
  end
end

class DemoWindow < Gosu::Window

  def initialize
    #calls initialize from where it was inherited, passing width and height.
    super(WIN_WIDTH, WIN_HEIGHT, false)
    @locs = [60,60] #mouse location
    @x_cells = WIN_WIDTH / CELL_DIM
    @y_cells = WIN_HEIGHT / CELL_DIM
    @array_of_cells = Array.new(@x_cells + 1) { Array.new(@y_cells + 1) }
    @total_cells = @x_cells * @y_cells
    @speed = 0.1
    x = 0
    while x <= @x_cells
      y = 0
      while y <= @y_cells
        temp = rand(@total_cells)
        if(temp < SEED_MIN)
          alive = true
          temp_c = LIVING_COLOUR
        else
          alive = false
          temp_c = DEAD_COLOUR
        end
        @array_of_cells[x][y] = Cell.new(x * CELL_DIM, y * CELL_DIM, temp_c, alive)
        y += 1
      end
      x += 1
    end
  end

  #update happens before draw
  def update
    all_alive_check()
    sleep(@speed)
    if (RANDOM_LIFE and (rand(@total_cells) >= (@total_cells/2)))
      x = rand(@x_cells)
      y = rand(@y_cells)
      @array_of_cells[x][y].alive = true
      @array_of_cells[x][y].c = LIVING_COLOUR
      @array_of_cells[x + 1][y].alive = true
      @array_of_cells[x + 1][y].c = LIVING_COLOUR
      @array_of_cells[x][y + 1].alive = true
      @array_of_cells[x][y + 1].c = LIVING_COLOUR
      @array_of_cells[x + 1][y + 1].alive = true
      @array_of_cells[x + 1][y + 1].c = LIVING_COLOUR
    end
  end

  #all drawing happens in draw
  def draw
    Gosu.draw_rect(0, 0, WIN_WIDTH, WIN_HEIGHT, BACKGROUND, 0, mode=:default)
    x = 0
    while x < @x_cells
      y = 0
      while y < @y_cells
        draw_cell(@array_of_cells[x][y].x, @array_of_cells[x][y].y, @array_of_cells[x][y].c)
        y += 1
      end
      x += 1
    end
  end

  def needs_cursor?
    true
  end

  def button_down(id)
    case id
    when Gosu::MsLeft #create life with a left click
      @locs = [mouse_x, mouse_y]
      finding_x = (mouse_x / CELL_DIM).to_i
      finding_y = (mouse_y / CELL_DIM).to_i
      @array_of_cells[finding_x][finding_y].alive = true
      @array_of_cells[finding_x][finding_y].c = LIVING_COLOUR
      @array_of_cells[finding_x + 1][finding_y].alive = true
      @array_of_cells[finding_x + 1][finding_y].c = LIVING_COLOUR
      @array_of_cells[finding_x][finding_y + 1].alive = true
      @array_of_cells[finding_x][finding_y + 1].c = LIVING_COLOUR
      @array_of_cells[finding_x + 1][finding_y + 1].alive = true
      @array_of_cells[finding_x + 1][finding_y + 1].c = LIVING_COLOUR
      neighbour_check_debug(finding_x, finding_y)
    when Gosu::MsRight #destroy life with a right click
      @locs = [mouse_x, mouse_y]
      finding_x = (mouse_x / CELL_DIM).to_i
      finding_y = (mouse_y / CELL_DIM).to_i
      @array_of_cells[finding_x][finding_y].alive = false
      @array_of_cells[finding_x][finding_y].c = DEAD_COLOUR
      @array_of_cells[finding_x + 1][finding_y].alive = false
      @array_of_cells[finding_x + 1][finding_y].c = DEAD_COLOUR
      @array_of_cells[finding_x][finding_y + 1].alive = false
      @array_of_cells[finding_x][finding_y + 1].c = DEAD_COLOUR
      @array_of_cells[finding_x + 1][finding_y + 1].alive = false
      @array_of_cells[finding_x + 1][finding_y + 1].c = DEAD_COLOUR
    when Gosu::KB_RIGHT
      @speed -= 0.01 if @speed > 0.01
    when Gosu::KB_LEFT
      @speed += 0.01
    end
  end

  def draw_cell(x, y, c)
    Gosu.draw_rect(x, y, CELL_DIM, CELL_DIM, BORDER_COLOUR, 1, mode=:default)
    Gosu.draw_rect(x + CELL_BORDER, y + CELL_BORDER, CELL_DIM - (2 * CELL_BORDER), CELL_DIM - (2 * CELL_BORDER), c, 2, mode=:default)
    Gosu.draw_rect(x + 2*CELL_BORDER, y + 2*CELL_BORDER, CELL_DIM - (4 * CELL_BORDER), CELL_DIM - (4 * CELL_BORDER), Gosu::Color.argb(0.5 * c.alpha, c.red, c.blue, c.green), 3, mode=:default)
  end

  def all_alive_check()
    x = 0
    while x < @x_cells
      y = 0
      while y < @y_cells
        neighbour_check(x, y)
        y += 1
      end
      x += 1
    end
  end

  def neighbour_check(x, y)
    @array_of_cells[x][y].neighbours = 0
    @array_of_cells[x][y].neighbours += 1 if @array_of_cells[x][y + 1].alive == true
    @array_of_cells[x][y].neighbours += 1 if @array_of_cells[x + 1][y].alive == true
    @array_of_cells[x][y].neighbours += 1 if @array_of_cells[x + 1][y + 1].alive == true
    @array_of_cells[x][y].neighbours += 1 if @array_of_cells[x][y - 1].alive == true
    @array_of_cells[x][y].neighbours += 1 if @array_of_cells[x - 1][y].alive == true
    @array_of_cells[x][y].neighbours += 1 if @array_of_cells[x - 1][y - 1].alive == true
    @array_of_cells[x][y].neighbours += 1 if @array_of_cells[x - 1][y + 1].alive == true
    @array_of_cells[x][y].neighbours += 1 if @array_of_cells[x + 1][y - 1].alive == true
    single_alive_check(x, y)
  end

  def neighbour_check_debug(x, y)
    @array_of_cells[x][y].neighbours = 0
    @array_of_cells[x][y].neighbours += 1 if @array_of_cells[x][y + 1].alive == true
    @array_of_cells[x][y].neighbours += 1 if @array_of_cells[x + 1][y].alive == true
    @array_of_cells[x][y].neighbours += 1 if @array_of_cells[x + 1][y + 1].alive == true
    @array_of_cells[x][y].neighbours += 1 if @array_of_cells[x][y - 1].alive == true
    @array_of_cells[x][y].neighbours += 1 if @array_of_cells[x - 1][y].alive == true
    @array_of_cells[x][y].neighbours += 1 if @array_of_cells[x - 1][y - 1].alive == true
    @array_of_cells[x][y].neighbours += 1 if @array_of_cells[x - 1][y + 1].alive == true
    @array_of_cells[x][y].neighbours += 1 if @array_of_cells[x + 1][y - 1].alive == true
    puts(@array_of_cells[x][y].neighbours)
    single_alive_check(x, y)
  end

  def single_alive_check(x, y)
    #cell with less than 2 neighbours dies of loneliness
    if(@array_of_cells[x][y].alive == true and @array_of_cells[x][y].neighbours < 2)
      @array_of_cells[x][y].alive = false
      @array_of_cells[x][y].c = DEAD_COLOUR
      return
    #cell with more than 3 neighbours die of overpopulation
    elsif(@array_of_cells[x][y].alive == true and @array_of_cells[x][y].neighbours > 3)
      @array_of_cells[x][y].alive = false
      @array_of_cells[x][y].c = DEAD_COLOUR
      return
    #dead cell with exactly 3 neighbours comes to life from repopulation
    elsif(@array_of_cells[x][y].alive == false and @array_of_cells[x][y].neighbours == 3)
      @array_of_cells[x][y].alive = true
      @array_of_cells[x][y].c = LIVING_COLOUR
      return
    end
    #living cell with 2 or 3 neighbours not listed as they will simply remain alive
  end
end

#creates new DemoWindow and opens it
DemoWindow.new.show

# Attempted an 'elegant' solution to the neighbour check. It was anything but.
# Left in as a reminder to not attempt this again.
# Since it isn't called, doesn't impact the running of the code, only the size of source file.
def neighbour_check_deleted(x, y)
  i = -1
  if(x == 0 or (i + x) >= @x_cells)
    i = 0
  end
  while i <= 1
    @array_of_cells[x][y].neighbours = 0
    j = -1
    if(y == 0 or ((j + y) >= @y_cells))
      j = 0
    end
    while j <= 1
      if(@array_of_cells[x + i][y + j].alive)
        @array_of_cells[x][y].neighbours += 1
      end
      if(@array_of_cells[x][y].alive)
        @array_of_cells[x][y].neighbours -= 1
      end
      j += 1
    end
    i += 1
    single_alive_check(x, y)
  end
end
