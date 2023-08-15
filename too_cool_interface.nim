{.experimental: "codeReordering".}
import raylib
import too_cool
import grids
import std/[math, random]

type
  CursorMode = enum
    Move, Swap
  Visuals = object
    start_y, start_x, height, width: int
    colors: array[ColorOpt, Color]
    grid_buffer: int  # Space between each sub-board
    square_buffer: int
    field_size: Vector2
    square_size: Vector2
    line_color: Color
    line_width: float32
  Player = object
    field: Field
    vis: Visuals
    mode: CursorMode
  Timer = object
    start: float
    last: float

const
  screenWidth = 800
  screenHeight = 650

proc `+`(a, b: Vector2): Vector2 =
  Vector2(x: a.x + b.x, y: a.y + b.y)

proc initTimer(): Timer =
  result.start = getTime()

proc update(t: var Timer) =
  t.last = getTime()

proc elapsed(t: Timer): float =
  max(round(t.last - t.start, 3), 0)

proc initPlayer(x1, y1, x2, y2: int): Player =
  var visuals = Visuals(start_x: x1, start_y: y1, height: y2 - y1, width: x2 - x1, grid_buffer: 10, square_buffer: 2)
  visuals.colors = [Red, Green, Blue, White]
  visuals.field_size = Vector2(x: (visuals.width - 3 * visuals.grid_buffer).float32 / 2, y: (visuals.height - 3 * visuals.grid_buffer).float32 / 2)
  visuals.square_size = Vector2(x: (visuals.field_size.x.int - 5 * visuals.square_buffer) / 4, y: (visuals.field_size.y.int - 5 * visuals.square_buffer) / 4)
  visuals.line_color = Yellow
  visuals.line_width = 10
  Player(field: initField(), vis: visuals, mode: Move)

proc darken(c: Color, amount: int = 50): Color =
  Color(r: max(c.r - amount.uint8, 0).uint8, g: max(c.g - amount.uint8, 0).uint8, b: max(c.b - amount.uint8, 0).uint8, a: c.a)


proc getSquareCorner(p: Player, y, x: int, c: ColorOpt): Vector2 =
  var cox = p.vis.start_x + p.vis.grid_buffer
  var coy = p.vis.start_y + p.vis.grid_buffer
  case c:
  of Color1:
    discard
  of Color2:
    cox += p.vis.field_size.x.int + p.vis.grid_buffer
  of Color3:
    coy += p.vis.field_size.y.int + p.vis.grid_buffer
  of Color4:
    cox += p.vis.field_size.x.int + p.vis.grid_buffer
    coy += p.vis.field_size.y.int + p.vis.grid_buffer
  
  result.y = float(y * (p.vis.square_buffer + p.vis.square_size.y.int) + p.vis.square_buffer + coy)
  result.x = float(x * (p.vis.square_buffer + p.vis.square_size.x.int) + p.vis.square_buffer + cox)

proc getSquareCorner(p: Player, l: Location): Vector2 =
  getSquareCorner(p, l.y, l.x, l.g)

proc drawFields(p: Player) =
  # Draw field background first
  let r1 = Vector2(x: p.vis.grid_buffer.float32 + p.vis.start_x.float32, y: p.vis.grid_buffer.float32 + p.vis.start_y.float32)
  let r2 = Vector2(x: 2 * p.vis.grid_buffer.float32 + p.vis.field_size.x + p.vis.start_x.float32, y: p.vis.grid_buffer.float32 + p.vis.start_y.float32)
  let r3 = Vector2(x: p.vis.grid_buffer.float32 + p.vis.start_x.float32, y: 2 * p.vis.grid_buffer.float32 + p.vis.field_size.y + p.vis.start_y.float32)
  let r4 = Vector2(x: 2 * p.vis.grid_buffer.float32 + p.vis.field_size.x + p.vis.start_x.float32, y: 2 * p.vis.grid_buffer.float32 + p.vis.field_size.y + p.vis.start_y.float32)
  drawRectangle(r1, p.vis.field_size, p.vis.colors[Color1])
  drawRectangle(r2, p.vis.field_size, p.vis.colors[Color2])
  drawRectangle(r3, p.vis.field_size, p.vis.colors[Color3])
  drawRectangle(r4, p.vis.field_size, p.vis.colors[Color4])

  # Draw each square now
  for y, x in p.field.tl.coordinates:
    var start = getSquareCorner(p, y, x, Color1)
    drawRectangle(start, p.vis.square_size, p.vis.colors[p.field.tl[y, x]])
  for y, x in p.field.tr.coordinates:
    var start = getSquareCorner(p, y, x, Color2)
    drawRectangle(start, p.vis.square_size, p.vis.colors[p.field.tr[y, x]])
  for y, x in p.field.bl.coordinates:
    var start = getSquareCorner(p, y, x, Color3)
    drawRectangle(start, p.vis.square_size, p.vis.colors[p.field.bl[y, x]])
  for y, x in p.field.br.coordinates:
    var start = getSquareCorner(p, y, x, Color4)
    drawRectangle(start, p.vis.square_size, p.vis.colors[p.field.br[y, x]])

proc drawCursor(p: Player) =
  let location = getSquareCorner(p, p.field.cursor_y, p.field.cursor_x, p.field.cursor_grid)
  var color = Yellow
  if p.mode == Swap:
    color = Black
  drawRectangleRoundedLines(Rectangle(x: location.x, y: location.y, width: p.vis.square_size.x, height: p.vis.square_size.y), 0.float32, 4.int32, 5.float32, color)

proc drawPlayer(p: Player) =
  ## We assume we are in a drawing context
  drawRectangle(p.vis.start_x.int32, p.vis.start_y.int32, p.vis.width.int32, p.vis.height.int32, Gray)
  drawFields(p)
  drawCursor(p)
  if p.mode == Swap:
    drawSwapArrows(p)

proc drawSwapArrows(p: Player) =
  let cur = p.field.cursorLocation
  let h = p.field.targetHorizontal
  let v = p.field.targetVertical

  var start = p.getSquareCorner(cur) + Vector2(x: p.vis.square_size.x / 2, y: p.vis.square_size.y / 2)
  var endh = p.getSquareCorner(h) + Vector2(x: p.vis.square_size.x / 2, y: p.vis.square_size.y / 2)
  var endv = p.getSquareCorner(v) + Vector2(x: p.vis.square_size.x / 2, y: p.vis.square_size.y / 2)

  drawLine(start, endh, p.vis.line_width, p.vis.line_color)
  drawLine(start, endv, p.vis.line_width, p.vis.line_color)

proc drawTime(t: Timer, p: Player) =
  drawText(cstring($t.elapsed), int32(p.vis.start_x + p.vis.width + 100), int32(p.vis.start_y + (p.vis.field_size.y / 2).int32), 35.int32, Black)


proc main =
  randomize()

  initWindow(screenWidth, screenHeight, "Too Cool :P")
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  var p = initPlayer(20, 20, 500, 500)
  let goal = initField()
  var t = initTimer()

  while not windowShouldClose(): # Detect window close button or ESC key

    if p.mode == Move:
      if isKeyPressed(Up) or isKeyPressed(W):
        cursorUp(p.field)
      if isKeyPressed(Right) or isKeyPressed(D):
        cursorRight(p.field)
      if isKeyPressed(Down) or isKeyPressed(S):
        cursorDown(p.field)
      if isKeyPressed(Left) or isKeyPressed(A):
        cursorLeft(p.field)
      if isKeyPressed(Space) or isKeyPressed(V):
        p.mode = Swap
    elif p.mode == Swap:
      if isKeyPressed(Space) or isKeyPressed(V):
        p.mode = Move
      if isKeyPressed(Right) or isKeyPressed(Left) or isKeyPressed(D) or isKeyPressed(A):
        let h = p.field.targetHorizontal
        let c = p.field.cursorLocation
        p.field.swap(h, c)
        p.mode = Move
      if isKeyPressed(Up) or isKeyPressed(Down) or isKeyPressed(W) or isKeyPressed(S):
        let h = p.field.targetVertical
        let c = p.field.cursorLocation
        p.field.swap(h, c)
        p.mode = Move
    
    if isKeyPressed(R):
      p.field = initSmartField()
      t = initTimer()
    
    if isKeyPressed(P):
      echo p.field
      echo goal

    beginDrawing()
    clearBackground(RayWhite)
    drawPlayer(p)
    if p.field != goal:
      t.update()
    drawTime(t, p)
    endDrawing()
    
  closeWindow() # Close window and OpenGL context

main()