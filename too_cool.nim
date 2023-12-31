import grids
import std/[random]

type
    ColorOpt* = enum
        Color1, Color2, Color3, Color4
    Field* = object
        tl_color*, tr_color*, bl_color*, br_color*: ColorOpt
        tl*, tr*, bl*, br*: Grid[ColorOpt]
        cursor_grid*: ColorOpt
        cursor_x*, cursor_y*: int
    Location* = object
        g*: ColorOpt
        x*, y*: int

proc `[]`(f: Field, l: Location): ColorOpt =
    case l.g:
    of Color1:
        f.tl[l.y, l.x]
    of Color2:
        f.tr[l.y, l.x]
    of Color3:
        f.bl[l.y, l.x]
    of Color4:
        f.br[l.y, l.x]

proc `[]`*(f: var Field, c: ColorOpt): var Grid =
    case c:
    of Color1:
        f.tl
    of Color2:
        f.tr
    of Color3:
        f.bl
    of Color4:
        f.br

proc `[]=`(f: var Field, l: Location, c: ColorOpt) =
    case l.g:
    of Color1:
        f.tl[l.y, l.x] = c
    of Color2:
        f.tr[l.y, l.x] = c
    of Color3:
        f.bl[l.y, l.x] = c
    of Color4:
        f.br[l.y, l.x] = c

proc `==`*(a, b: Field): bool =
    a.tl == b.tl and a.tl_color == b.tl_color and a.tr == b.tr and a.tr_color == b.tr_color and
     a.bl == b.bl and a.bl_color == b.bl_color and a.br == b.br and a.br_color == b.br_color

proc swap*(f: var Field, a, b: Location) =
    var temp_a = f[a]
    var temp_b = f[b]

    f[b] = temp_a
    f[a] = temp_b

proc initField*: Field =
    result.tl_color = Color1
    result.tr_color = Color2
    result.bl_color = Color3
    result.br_color = Color4

    result.tl = initGrid(4, 4, Color1)
    result.tr = initGrid(4, 4, Color2)
    result.bl = initGrid(4, 4, Color3)
    result.br = initGrid(4, 4, Color4)

    result.cursor_grid = Color1
    result.cursor_x = 0
    result.cursor_y = 0

proc initRandomField*: Field =
    result = initField()

    var remaining: array[ColorOpt, int] = [16, 16, 16, 16]

    for y, x in result.tl.coordinates:
        var choice = rand(ColorOpt)
        while remaining[choice] == 0:
            choice = rand(ColorOpt)
        result.tl[y, x] = choice
        remaining[choice] -= 1

    for y, x in result.tr.coordinates:
        var choice = rand(ColorOpt)
        while remaining[choice] == 0:
            choice = rand(ColorOpt)
        result.tr[y, x] = choice
        remaining[choice] -= 1

    for y, x in result.bl.coordinates:
        var choice = rand(ColorOpt)
        while remaining[choice] == 0:
            choice = rand(ColorOpt)
        result.bl[y, x] = choice
        remaining[choice] -= 1

    for y, x in result.br.coordinates:
        var choice = rand(ColorOpt)
        while remaining[choice] == 0:
            choice = rand(ColorOpt)
        result.br[y, x] = choice
        remaining[choice] -= 1

proc initSmartField*: Field =
    result = initField()

    var collection: seq[Location] = @[]

    for y, x in result.tl.coordinates:
        for g in ColorOpt:
            collection.add(Location(g: g, x: x, y: y))

    for y, x in result.tl.coordinates:
        var curl = Location(g: Color1, x: x, y: y)
        var cur = result[curl]
        if cur != Color1:
            continue
        var choice = sample(collection)
        while choice.g == Color1 or result[choice] == Color1:
            choice = sample(collection)
        result.swap(curl, choice)

    for y, x in result.tr.coordinates:
        var curl = Location(g: Color2, x: x, y: y)
        var cur = result[curl]
        if cur != Color2:
            continue
        var choice = sample(collection)
        while choice.g == Color2 or result[choice] == Color2:
            choice = sample(collection)
        result.swap(curl, choice)

    for y, x in result.bl.coordinates:
        var curl = Location(g: Color3, x: x, y: y)
        var cur = result[curl]
        if cur != Color3:
            continue
        var choice = sample(collection)
        while choice.g == Color3 or result[choice] == Color3:
            choice = sample(collection)
        result.swap(curl, choice)

    for y, x in result.br.coordinates:
        var curl = Location(g: Color4, x: x, y: y)
        var cur = result[curl]
        if cur != Color4:
            continue
        var choice = sample(collection)
        while choice.g == Color4 or result[choice] == Color4:
            choice = sample(collection)
        result.swap(curl, choice)

proc cursorRight*(f: var Field) =
    if f.cursor_x < 3:
        f.cursor_x += 1
    else:
        if f.cursor_grid == Color1:
            f.cursor_grid = Color2
            f.cursor_x = 0
        elif f.cursor_grid == Color3:
            f.cursor_grid = Color4
            f.cursor_x = 0

proc cursorDown*(f: var Field) = 
    if f.cursor_y < 3:
        f.cursor_y += 1
    else:
        if f.cursor_grid == Color1:
            f.cursor_grid = Color3
            f.cursor_y = 0
        elif f.cursor_grid == Color2:
            f.cursor_grid = Color4
            f.cursor_y = 0

proc cursorLeft*(f: var Field) = 
    if f.cursor_x > 0:
        f.cursor_x -= 1
    else:
        if f.cursor_grid == Color2:
            f.cursor_grid = Color1
            f.cursor_x = 3
        elif f.cursor_grid == Color4:
            f.cursor_grid = Color3
            f.cursor_x = 3

proc cursorUp*(f: var Field) =
    if f.cursor_y > 0:
        f.cursor_y -= 1
    else:
        if f.cursor_grid == Color3:
            f.cursor_grid = Color1
            f.cursor_y = 3
        elif f.cursor_grid == Color4:
            f.cursor_grid = Color2
            f.cursor_y = 3

proc hovering(f: Field): ColorOpt =
    var grid: Grid[ColorOpt]
    case f.cursor_grid:
    of Color1:
        grid = f.tl
    of Color2:
        grid = f.tr
    of Color3:
        grid = f.bl
    of Color4:
        grid = f.br

    grid[f.cursor_y, f.cursor_x]

proc cursorLocation*(f: Field): Location =
    Location(g: f.cursor_grid, y: f.cursor_y, x: f.cursor_x)

proc targetHorizontal*(f: Field): Location =
    let cur = f.hovering
    result.y = f.cursor_y
    case f.cursor_grid:
    of Color1:
        let a = f.tr.getRow(f.cursor_y)
        result.g = Color2
        block search:
            for i in 0 ..< a.width:
                if cur != a[0, i]:
                    result.x = i
                    break search
            result.x = 0
    of Color3:
        let a = f.br.getRow(f.cursor_y)
        result.g = Color4
        block search:
            for i in 0 ..< a.width:
                if cur != a[0, i]:
                    result.x = i
                    break search
            result.x = 3
    of Color2:
        let a = f.tl.getRow(f.cursor_y)
        result.g =  Color1  
        block search:
            for i in countdown(a.width - 1, 0):
                if cur != a[0, i]:
                    result.x = i
                    break search
            result.x = 0
    of Color4:
        let a = f.bl.getRow(f.cursor_y)
        result.g = Color3
        block search:
            for i in countdown(a.width - 1, 0):
                if cur != a[0, i]:
                    result.x = i
                    break search
            result.x = 3

proc targetVertical*(f: Field): Location =
    let cur = f.hovering
    result.x = f.cursor_x
    case f.cursor_grid:
    of Color1:
        let a = f.bl.getColumn(f.cursor_x)
        result.g = Color3
        block search:
            for i in 0 ..< a.height:
                if cur != a[i, 0]:
                    result.y = i
                    break search
            result.y = 0
    of Color2:
        let a = f.br.getColumn(f.cursor_x)
        result.g = Color4
        block search:
            for i in 0 ..< a.height:
                if cur != a[i, 0]:
                    result.y = i
                    break search
            result.y = 3
    of Color3:
        let a = f.tl.getColumn(f.cursor_x)
        result.g = Color1
        block search:
            for i in countdown(a.height - 1, 0):
                if cur != a[i, 0]:
                    result.y = i
                    break search
            result.y = 0
    of Color4:
        let a = f.tr.getColumn(f.cursor_x)
        result.g = Color2
        block search:
            for i in countdown(a.height - 1, 0):
                if cur != a[i, 0]:
                    result.y = i
                    break search
            result.y = 3

proc main =
    var temp = initRandomField()
    echo temp

if isMainModule:
    main()
