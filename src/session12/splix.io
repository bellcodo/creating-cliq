import simplegui, time, random

WINDOW_WIDTH = 500
WINDOW_HEIGHT = WINDOW_WIDTH
GLOBAL_DEFAULT_SQUARE_SIZE = 25
IN_SQUARES = GLOBAL_DEFAULT_SQUARE_SIZE
GLOBAL_CIRCLE_RADIUS = GLOBAL_DEFAULT_SQUARE_SIZE / 2
GLOBAL_NUM_ROWS = 10
GLOBAL_NUM_COLS = GLOBAL_NUM_ROWS

GLOBAL_SQUARES_ACROSS = WINDOW_WIDTH / GLOBAL_DEFAULT_SQUARE_SIZE
BASE_SHIFT_X = (GLOBAL_SQUARES_ACROSS - GLOBAL_NUM_ROWS) /2
BASE_SHIFT_Y = BASE_SHIFT_X

DEFAULT_SQUARE_DRAW_ATTRIBUTES = {
    "line_width": 1,
    "line_color": 'Green',
    "fill_color": 'Orange'
}

# For color: http://www.codeskulptor.org/docs.html#Colors
DEFUALT_SNAKE_DRAW_ATTRIBUTES = {
    "line_width": 2,
    "line_color": "Aqua",
    "fill_color": "Pink"
}

def rect_coords (length, height, startpos = (0, 0)) :
    x = startpos[0]
    y = startpos[1]
    return [
        (x, y),
        (x, y + height),
        (x + length, y + height),
        (x + length, y)  
    ]

class Square:
    SHAPE_ATTRIBUTES = DEFAULT_SQUARE_DRAW_ATTRIBUTES
    SIZE = GLOBAL_DEFAULT_SQUARE_SIZE
    
    def __init__(self, top_left_pt, size=SIZE, shape_attributes=SHAPE_ATTRIBUTES):
        self.top_left_point = top_left_pt
        self.shape_attributes = shape_attributes
        self.size = size
        
    def draw_me(self, canvas):
        size = self.size
        (x,y) = self.top_left_point
        (x,y) = x*size, y*size
        canvas.draw_polygon(rect_coords(size, size, (x,y)),
                    self.shape_attributes["line_width"], self.shape_attributes["line_color"], self.shape_attributes["fill_color"]
        )
                            
class SquareGrid:
    
    SQUARE_PIXEL_SIZE = GLOBAL_DEFAULT_SQUARE_SIZE
    NUM_ROWS = GLOBAL_NUM_ROWS
    NUM_COLS = GLOBAL_NUM_COLS
    
    def __init__(self):
        self.grid_elements = self.init_grid()

    def init_grid(self):
        num_rows = self.NUM_ROWS
        num_cols = self.NUM_COLS
        grid_elements = []
        size = self.SQUARE_PIXEL_SIZE
        for x in range(num_rows):
            for y in range(num_cols):
                top_left_pt = [
                    (x+BASE_SHIFT_X), (y+BASE_SHIFT_Y)
                ]
                grid_elements.append(Square(top_left_pt))
        return grid_elements

    def draw_me(self, canvas):
        for pos in self.grid_elements:
            pos.draw_me(canvas)

class Character:
    
    class Circle:
        RADIUS = GLOBAL_CIRCLE_RADIUS
        SHAPE_ATTRIBUTES = DEFUALT_SNAKE_DRAW_ATTRIBUTES

        def __init__(self, x, y, radius=RADIUS, shape_attributes=SHAPE_ATTRIBUTES):
            self.radius = radius
            self.center_point = (x,y)
            self.shape_attributes = shape_attributes
            
        def draw_me(self, canvas):
            canvas.draw_circle(
                    self.center_point,
                    self.radius,
                    self.shape_attributes["line_width"],
                    self.shape_attributes["fill_color"],
                    self.shape_attributes["fill_color"]   
                )
            
    class Body:

        def __init__(self, shape_attributes):
            self.body_segments = [Square([3,3])]
            self.shape_attributes = shape_attributes

        def append(self, segment):
            self.body_segments.append(segment)

        def list_segments(self):
            return list(self.body_segments)
        
        def draw_me(self, canvas):
            for sqr in self.body_segments:
                sqr.draw_me(canvas)
    
    key_map = {
        "left": 37,
        "up"  : 38,
        "right":39,
        "down": 40
    }

    move_dist = 5
    vel = [move_dist, 0]

    def __init__ (self, shape_attributes):
        self.shape_attributes = shape_attributes      
        self.circle_shape = self.initialize_head(shape_attributes)
        self.body = self.Body(shape_attributes)

    def initialize_head(self, shape_attributes):
        START_POINT_X = IN_SQUARES*(BASE_SHIFT_X + .5)
        START_POINT_Y = IN_SQUARES*(BASE_SHIFT_Y + .5)
        
        start_in_middle_of_base = (GLOBAL_NUM_COLS / 2) - 1
        x = START_POINT_X + start_in_middle_of_base*IN_SQUARES
        y = START_POINT_Y
        
        return self.Circle(x,y)
        
    def draw_me(self, canvas):
        self.circle_shape.draw_me(canvas)
        self.body.draw_me(canvas)
   
    def update_direction(self, shift_point):
        sqr_shift_point = map(lambda pt: pt*IN_SQUARES, shift_point)
        pt = self.circle_shape.center_point
        new_point = (
            pt[0] + sqr_shift_point[0], 
            pt[1] + sqr_shift_point[1], 
        )
        self.circle_shape.center_point = new_point
        
    def move_right(self):
        self.update_direction((1,0))

    def move_left(self):
        self.update_direction((-1,0))

    def move_up(self):
        self.update_direction((0,-1))
    
    def move_down(self):
        self.update_direction((0,1))
    
    def move (self, key):
        if key in Character.key_map.values():
            if key == Character.key_map["right"]:
                self.move_right()
                
            if key == Character.key_map["left"]:
                self.move_left()
                
            if key == Character.key_map["up"]:
                self.move_up()
                
            if key == Character.key_map["down"]:
                self.move_down()
                
snake = Character(DEFUALT_SNAKE_DRAW_ATTRIBUTES)            
grid = SquareGrid()                


ticker = 0
def draw(canvas):
  
    box1 = rect_coords(WINDOW_WIDTH, WINDOW_HEIGHT, startpos = (0, 0))
    canvas.draw_polygon(box1, 20, "Aqua") #draw rectangle

#    print time.time().
    global ticker 
    ticker += 1
    if ticker == 3:
        #snake.save_me()    
        ticker = 0
    grid.draw_me(canvas)    # draw grid
    snake.draw_me(canvas)    # draw circle


    return


# add functions and handler to frame
#===================================================
frame = simplegui.create_frame("Home", WINDOW_WIDTH, WINDOW_HEIGHT)
frame.set_canvas_background("Silver")

frame.set_draw_handler(draw)
frame.set_keydown_handler(snake.move) #for move circle******

frame.start()
