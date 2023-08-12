import std/[sequtils, algorithm]
# TODO consider if I should return a grid object instead of seq[T] for rows
# TODO make copy or use of var consistent
# TODO make sure dimensions and default is being transfered properly
# TODO reorganize procs to something more sensible
# FIXME make x or y first arg across int/slice consistent
# TODO make consider whether I should use .. or ..< and make sure conversions are consistent between layers
# TODO change everything to use .. and always use y, x

type Grid*[T] = object      ## Origin is the top left
    width*, height*: int
    data*: seq[T]
    default*: T

proc initGrid*[T](height, width: int, default: T = default(T)): Grid[T] =
    result.data = @[]
    result.width = width
    result.height = height
    result.default = default
    for _ in 0 ..< (width * height):
        result.data.add(default)

proc initGrid*[T](size: openArray[int], default: T = default(T)): Grid[T] =
    if size.len != 2:
        raise newException(RangeDefect, "Too many grid dimensions")
    Grid(size[0], size[1], default)

proc rebuildGrid*(grid: var Grid, y, x: int) =
    if x * y <= grid.data.len:
        grid.data.setLen(x * y)
    else:
        for a in 0 ..< x * y - grid.data.len:
            grid.data.add(grid.default)
    grid.height = y
    grid.width = x

proc getRow*[T](grid: Grid[T], y: int): Grid[T] =
    if y < 0 or y >= grid.height:
        return repeat(default(T), grid.width).toGrid.reshape(grid.width, 1)  # new from default
    grid.subGrid(y, y, 0, grid.width - 1)

proc getColumn*[T](grid: Grid[T], x: int): Grid[T] =
    if x < 0 or x >= grid.width:
        return repeat(default(T), grid.height).toGrid  # new from default
    grid.subGrid(0, grid.height - 1, x, x)

proc repl*(grid: Grid): string =
    var text: string = "\n"
    for a in 0 ..< grid.height:
        for b in 0 ..< grid.width:
            text.add($grid.get(b, a) & ", ")
        text.add("\n")
    text

proc `[]`*[T](grid: Grid[T], y, x: int): T =
    if x < 0 or y < 0 or x >= grid.width or y >= grid.height:
        return default(T)
    grid.data[x + y * grid.width]

proc `[]`*[T](grid: Grid[T], ySlice, xSlice: Slice[int]): Grid[T] =
    grid.subGrid(ySlice, xSlice)

proc `[]=`*[T](grid: var Grid[T], y, x: int, val: T) =
    # One of the only procs to not return anything
    # TODO consider changing that
    if x < 0 or y < 0 or x >= grid.width or y >= grid.height:
        raise newException(FieldDefect, "Invalid coodinates")
    grid.data[x + y * grid.width] = val

proc `[]=`*[T](grid: var Grid[T], ySlice, xSlice: Slice[int], val: Grid[T]) =
    if ySlice.b - ySlice.a != val.height - 1 or xSlice.b - xSlice.a != val.width - 1:
        echo "\nerror"
        echo grid
        echo val
        echo ySlice, " ", xSlice
        raise newException(FieldDefect, "Invalid sizing")
    for y in 0 ..< val.height:
        for x in 0 ..< val.width:
            grid[y + ySlice.a, x + xSlice.a] = val[y, x]

proc `[]=`*[T](grid: var Grid[T], ySlice, xSlice: Slice[int], val: T) =
    for y in ySlice.a .. ySlice.b:
        for x in xSlice.a .. xSlice.b:
            grid[y, x] = val

proc `==`*[T](grid: Grid[T], val: T): bool =
    if grid.data.len == 1:
        result = grid.data[0] == val

iterator items*[T](grid: Grid[T]): T =
    for a in 0 ..< grid.width * grid.height:
        yield grid.data[a]

iterator rows*[T](grid: Grid[T]): Grid[T] =
    for y in 0 ..< grid.height:
        yield grid.getRow(y)

iterator columns*[T](grid: Grid[T]): Grid[T] =
    for x in 0 ..< grid.width:
        yield grid.getColumn(x)

iterator coordinates*[T](grid: Grid[T]): tuple[y, x: int] =
    for a in 0 ..< grid.height:
        for b in 0 ..< grid.width:
            yield (a, b)
    
proc copyShape(grid: Grid): Grid =
    result.height = grid.height
    result.width = grid.width

proc subGrid*[T](grid: Grid[T], y0, y1, x0, x1: int): Grid[T] =
    ## Get a grid from inside a grid assuming ..
    ## We arent doing any checks to make sure the subGrid is valid
    if y0 < 0 or y1 >= grid.height or x0 < 0 or x1 >= grid.width:
        # echo grid
        # echo y0, " ", y1, " ", x0, " ", x1
        raise newException(FieldDefect, "Invalid coordinates")
    result.default = grid.default
    for y in y0 .. y1:
        for x in x0 .. x1:
            result.data.add(grid[y, x])
    result.height = y1 - y0 + 1
    result.width = x1 - x0 + 1

proc subGrid*[T](grid: Grid[T], ySlice, xSlice: Slice[int]): Grid[T] =
    ## with slices we assume `..`
    subGrid(grid, ySlice.a, ySlice.b, xSlice.a, xSlice.b)


proc reshape*(grid: Grid, y, x: int): Grid =
    # TODO Consider makeing this var instead of copy
    if grid.height * grid.width != x * y:
        raise newException(Defect, "Invalid reshape")
    result.height = y
    result.width = x
    result.data = grid.data
    result.default = grid.default

proc toGrid*[T](data: openArray[T]): Grid[T] =
    ## takes a seq/array and turns it to a height x 1 grid
    result.data = data.toSeq
    result.height = data.len()
    result.width = 1

proc copy*[T](grid: Grid[T]): Grid[T] =
    ## Uses `=` to make a copy
    result = grid

proc rotatecw*[T](grid: Grid[T]): Grid[T] =
    # TODO consider removing this for more optomized code
    var shape: seq[Grid[T]] = @[]
    for a in grid.rows:
        shape.add(a)
    let temp = grid.copy()
    
    result = grid.copy()
    swap(result.height, result.width)
    for a in 0 ..< temp.width:
        var col = temp.getColumn(a)
        col.height = 1
        col.width = result.width
        col.data.reverse()
        # echo col
        result[a .. a, 0 .. result.width - 1] = col
    # echo "r", result
            
proc rotatecw*(grid: Grid, count: int): Grid =
    var thing = grid
    for _ in 0 ..< count:
        thing = thing.rotatecw
    thing

proc mapItem*[T, S](grid: Grid[T], mapped: proc (arg: T): S): Grid[S] =
    result.height = grid.height
    result.width = grid.width
    for a in grid.items:
        result.data.add(mapped(a))

proc mapRow*[T, S](grid: Grid[T], mapped: proc (arg: T): S): Grid[S] =
    result = grid.copyShape
    for a in grid.rows:
        result.data.append(mapped(a))


# Basic testing
# var thing = [1, 1, 0, 0, 1, 0, 0, 0, 0].toGrid.reshape(3, 3)
# echo thing.repl
# # echo thing.getRow(0)
# thing = thing.rotatecw(2)
# echo thing.repl