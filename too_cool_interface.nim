import raylib
import too_cool
import grids

type
  Visuals = object
    start_y, start_x, height, width: int
    colors: array[ColorOpt, Color]
    grid_buffer: int  # Space between each sub-board
    square_buffer: int
    field_size: Vector2
    square_size: Vector2
  Player = object
    field: Field
    vis: Visuals

const
  screenWidth = 800
  screenHeight = 650

proc initPlayer(x1, y1, x2, y2: int): Player =
  var visuals = Visuals(start_x: x1, start_y: y1, height: y2 - y1, width: x2 - x1, grid_buffer: 10, square_buffer: 20)
  visuals.colors = [Red, Green, Blue, White]
  visuals.field_size = Vector2(x: (visuals.width - 4 * visuals.grid_buffer).float32 / 2, y: (visuals.height - 4 * visuals.grid_buffer).float32 / 2)
  visuals.square_size = Vector2(x: (visuals.field_size.x.int - 5 * visuals.square_buffer) / 4, y: (visuals.field_size.y.int - 5 * visuals.square_buffer) / 4)
  Player(field: initField(), vis: visuals)

proc getSquareCorner(p: Player, y, x: int, c: ColorOpt): Vector2 =
  var cox: int
  var coy: int
  case c:
  of Color1:
    cox = 0
    coy = 0
  of Color2:
    cox = p.vis.field_size.x.int + 2 * p.vis.grid_buffer
    coy = 0
  of Color3:
    cox = 0
    coy = p.vis.field_size.y.int + 2 * p.vis.grid_buffer
  of Color4:
    cox = p.vis.field_size.x.int + 2 * p.vis.grid_buffer
    coy = p.vis.field_size.y.int + 2 * p.vis.grid_buffer
  
  cox += p.vis.start_x + p.vis.grid_buffer
  coy += p.vis.start_y + p.vis.grid_buffer
  
  result.y = float(y * (p.vis.square_buffer + p.vis.square_size.y.int) + p.vis.square_buffer + coy)
  result.x = float(x * (p.vis.square_buffer + p.vis.square_size.x.int) + 0 * p.vis.square_buffer + cox)


proc drawFields(p: Player) =
  # Draw field background first
  let r1 = Vector2(x: p.vis.grid_buffer.float32 + p.vis.start_x.float32, y: p.vis.grid_buffer.float32 + p.vis.start_y.float32)
  let r2 = Vector2(x: 3 * p.vis.grid_buffer.float32 + p.vis.field_size.x + p.vis.start_x.float32, y: p.vis.grid_buffer.float32 + p.vis.start_y.float32)
  let r3 = Vector2(x: p.vis.grid_buffer.float32 + p.vis.start_x.float32, y: 3 * p.vis.grid_buffer.float32 + p.vis.field_size.y + p.vis.start_y.float32)
  let r4 = Vector2(x: 3 * p.vis.grid_buffer.float32 + p.vis.field_size.x + p.vis.start_x.float32, y: 3 * p.vis.grid_buffer.float32 + p.vis.field_size.y + p.vis.start_y.float32)
  drawRectangle(r1, p.vis.field_size, p.vis.colors[Color1])
  drawRectangle(r2, p.vis.field_size, p.vis.colors[Color2])
  drawRectangle(r3, p.vis.field_size, p.vis.colors[Color3])
  drawRectangle(r4, p.vis.field_size, p.vis.colors[Color4])

  # Draw each square now
  for y, x in p.field.tl.coordinates:
    var start = getSquareCorner(p, y, x, Color1)
    start.x += p.vis.square_buffer.float32
    start.y += p.vis.square_buffer.float32
    drawRectangle(start, p.vis.square_size, p.vis.colors[p.field.tl[y, x]])
  



proc drawPlayer(p: Player) =
  ## We assume we are in a drawing context
  drawRectangle(p.vis.start_x.int32, p.vis.start_y.int32, p.vis.width.int32, p.vis.height.int32, Gray)
  drawFields(p)


proc main =
    
  initWindow(screenWidth, screenHeight, "raylib [core] example - basic window")
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  var p = initPlayer(20, 20, 500, 500)

  while not windowShouldClose(): # Detect window close button or ESC key

    beginDrawing()
    clearBackground(RayWhite)
    drawPlayer(p)
    endDrawing()
    
  closeWindow() # Close window and OpenGL context

main()