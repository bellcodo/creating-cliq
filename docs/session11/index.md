# Session 11
> Snake tail on the grid

[Last Sessions Code](https://raw.githubusercontent.com/bellcodo/creating-cliq/a43094176fdf92e505e486bade3a2c1cc3854297/src/session11/splix.io)

## Outline
1. Construct a square object which can draw itself.
	1. Create `Square` stub.
	2. Put squares into the grid instead of `tuples`.
	3. Implement a `draw_me` function based on `Square` data.
2. Push squares into a snake tail.
	1. Print squares that are in snake body.
	2. Push squares when updating movement.

#### Construct a square object which can draw itself.

###### Square class stub

```python
class Square:
	def __init__(self, x, y, size=GLOBAL_DEFAULT_SQUARE_SIZE):
		self.x = x
		self.y = y
		self.size = size
		
	def draw_me(self, canvas):
		pass
```

> The square should store its `(x,y)` coordinate and size. It should know how to convert the topleft point into a square on the canvas. If we take a minute and compose `SquareGrid` with a list of `Square`'s we can then use the `Square` class for the snake tail as well.


##### Put squares into the grid instead of `tuples`.

> Here is the `init_grid` function from the `SquareGrid` class

```python
    def init_grid(self, width, height):
        num_rows = self.NUM_ROWS
        num_cols = self.NUM_COLS
        grid_elements = []
        
        for x in range(num_rows):
            for y in range(num_cols):
                grid_elements.append((x+BASE_SHIFT_X,y+BASE_SHIFT_Y))
        return grid_elements
```

> The `tuple` that is saved in the `grid_elements` list is the data that we want to save in a our new `Square` class. Update the append step to create a square passing in the `(x,y)`.

```python
    def init_grid(self, width, height):
        num_rows = self.NUM_ROWS
        num_cols = self.NUM_COLS
        grid_elements = []
        
        for x in range(num_rows):
            for y in range(num_cols):
                grid_elements.append(Square(x+BASE_SHIFT_X,y+BASE_SHIFT_Y))
        return grid_elements
```

> Take a look at the current `draw_me` of the `SquareGrid`.

```python
    def draw_me(self, canvas):
        size = self.SQUARE_PIXEL_SIZE
        for pos in self.grid_elements:
            x = pos[0] * size
            y = pos[1] * size
            canvas.draw_polygon(
                rect_coords(size, size, (x,y)),
                1, 'Green', 'Orange'
            )
```

> Notice that it is doing two things. 

1. looping over `body_segments`. 
2. Printing `squares`. 

> We want to push the printing responsibility to the `Square` object so the grid can focus on just looping over the list of `grid_elements`.

> *Delegate* the drawing of the squares to the `Square` class. In order to delegate loop over the `grid_elements` and run `draw_me` on the square.

```python
    def draw_me(self, canvas):
        for square in self.grid_elements:
           square.draw_me(canvas)
```
>  Simplicity is beauty.

* Diff of code [here](https://github.com/bellcodo/creating-cliq/commit/6923b736677ae3af6d8d755548d10c9eef831cf1#diff-31e8a04db2a0c99989f04d22bc79622a)

##### Implement a `draw_me` function based on `Square` data.

>Now we need to update the `Square` class to handle the drawing based on the data available. 

```python
class Square:
	def __init__(self, x, y, size=GLOBAL_DEFAULT_SQUARE_SIZE):
		self.x = x
		self.y = y
		self.size = size
		
	def draw_me(self, canvas):
		pass
```

> To draw a square you need to call `rect_coords` and pass the `size` in for both the `length` and `width`. Its important to note that the `Square` class expects `(x,y)` positions to be in terms of grid positions instead of pixels. Because of this we need to scale the `(x,y)` by the size as well. 

```python
class Square:
    def __init__(self, x, y, size=GLOBAL_DEFAULT_SQUARE_SIZE):
        self.x = x
        self.y = y
        self.size = size
        
    def draw_me(self, canvas):
        size = self.size
        (x,y) = self.x*size, self.y*size
        canvas.draw_polygon(rect_coords(size, size, (x,y)),
                    1, 'Green', 'Orange'
        )
```

### Push squares into a snake tail.

#####  Print squares that are in snake body.
> Each time through the print loop we want the snake `body_segments` to get printed. This means where the snake head is getting printed
we need to update and add printing for the `body`.

```python
    def draw_me(self, canvas):
        self.draw_circle(canvas, self.circle_shape.center_point)
        self.body.draw_me(canvas)
```

> Body doesn't have a `draw_me` function so add it. Note the body is just a list of `Square`s so you should be able to write a simple for loop that calls `draw_me` on each of the squares.

```python
    def draw_me(self, canvas):
        for sqr in self.body_segments:
            sqr.draw_me(canvas)
```

> Lets put a few `Square`s into the body during *initialization* so we can verify all the printing is *wired up* correctly.

> You're `Body` class should look like this

```python
class Body:

    def __init__(self):
        self.body_segments = [Square(0,0), Square(2,2), Square(1,1)]

    def append(self, segment):
        self.body_segments.append(segment)

    def list_segments(self):
        return list(self.body_segments)
    
    def draw_me(self, canvas):
        for sqr in self.body_segments:
            sqr.draw_me(canvas)
```

### Might look like this: diag-snake
![diag-snake](https://drive.google.com/uc?export=download&id=0B3SFnARVIcGLMnU2a0lKd2tlWFk)

##### Push squares when updating movement.
> Great! The snake body prints if there are `squares` in the body. Remove the squares from the *initialization* and lets push squares whenever we update the movement.

> Here is the `update_direction` method today. Once we get the old `pt` we need to put it in the body. One tricky part is getting the `body_segments` to print on the screen. The problem is that `pt` is based on the pixels of the `circle_shape`, but the `Square` object needs to know where on the *grid* to put the square. To fix this we need to divide both the `x` and `y` by the global size `IN_SQUARES`.

```python
    def update_direction(self, shift_point):
        sqr_shift_point = map(lambda pt: pt*IN_SQUARES, shift_point)
        pt = self.circle_shape.center_point
        self.body.append(Square(pt[0]/IN_SQUARES, pt[1]/IN_SQUARES))	
        new_point = (
            pt[0] + sqr_shift_point[0], 
            pt[1] + sqr_shift_point[1], 
        )
        self.circle_shape.center_point = new_point
```

> Take a look! You should be getting squares rendering each time you move.

### Might look like this: offset snake
![offset snake](https://drive.google.com/uc?export=download&id=0B3SFnARVIcGLOVIyZVVoeUdyWGM)

