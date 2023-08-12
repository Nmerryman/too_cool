import grids

type
    ColorOpt* = enum
        Color1, Color3, Color2, Color4
    Field* = object
        tl_color*, tr_color*, bl_color*, br_color*: ColorOpt
        tl*, tr*, bl*, br*: Grid[ColorOpt]
        cursor_grid*: ColorOpt
        cursor_x*, cursor_y*: int
    Location* = object
        g*: ColorOpt
        x*, y*: int

proc initField*: Field =
    result.tl_color = Color1
    result.tr_color = Color3
    result.bl_color = Color2
    result.br_color = Color4

    result.tl = initGrid(4, 4, Color1)
    result.tl = initGrid(4, 4, Color3)
    result.tl = initGrid(4, 4, Color2)
    result.tl = initGrid(4, 4, Color4)

    result.cursor_grid = Color1
    result.cursor_x = 0
    result.cursor_y = 0

proc cursorRight*(f: var Field) =
    if f.cursor_x < 3:
        f.cursor_x += 1
    else:
        if f.cursor_grid == Color1:
            f.cursor_grid = Color3
            f.cursor_x = 0
        elif f.cursor_grid == Color2:
            f.cursor_grid = Color4
            f.cursor_x = 0

proc cursorDown*(f: var Field) = 
    if f.cursor_y < 3:
        f.cursor_y += 1
    else:
        if f.cursor_grid == Color1:
            f.cursor_grid = Color2
            f.cursor_y = 0
        elif f.cursor_grid == Color3:
            f.cursor_grid = Color4
            f.cursor_y = 0

proc cursorLeft*(f: var Field) = 
    if f.cursor_x > 0:
        f.cursor_x -= 1
    else:
        if f.cursor_grid == Color3:
            f.cursor_grid = Color1
            f.cursor_x = 3
        elif f.cursor_grid == Color4:
            f.cursor_grid = Color2
            f.cursor_x = 3

proc cursorUp*(f: var Field) =
    if f.cursor_y > 0:
        f.cursor_y -= 1
    else:
        if f.cursor_grid == Color2:
            f.cursor_grid = Color1
            f.cursor_y = 3
        elif f.cursor_grid == Color4:
            f.cursor_grid = Color3
            f.cursor_y = 3

proc hovering(f: Field): ColorOpt =
    var grid: Grid[ColorOpt]
    case f.cursor_grid:
    of Color1:
        grid = f.tl
    of Color3:
        grid = f.tr
    of Color2:
        grid = f.bl
    of Color4:
        grid = f.br

    grid.get(f.cursor_y, f.cursor_x)

proc targetHorizontal*(f: Field): Location =
    let cur = f.hovering
    result.y = f.cursor_y
    case f.cursor_grid:
    of Color1:
        let a = f.tr.getRow(f.cursor_y)
        result.g = Color3
        block search:
            for i in 0 ..< a.width:
                if cur != a.get(0, i):
                    result.x = i
                    break search
            result.x = 0
    of Color3:
        let a = f.tl.getRow(f.cursor_y)
        result.g = Color1
        block search:
            for i in countdown(a.width - 1, 0):
                if cur != a.get(0, i):
                    result.x = i
                    break search
            result.x = 3
    of Color2:
        let a = f.br.getRow(f.cursor_y)
        result.g = Color4
        block search:
            for i in 0 ..< a.width:
                if cur != a.get(0, i):
                    result.x = i
                    break search
            result.x = 0
    of Color4:
        let a = f.bl.getRow(f.cursor_y)
        result.g = Color2
        block search:
            for i in countdown(a.width - 1, 0):
                if cur != a.get(0, i):
                    result.x = i
                    break search
            result.x = 3

proc targetVertical*(f: Field): Location =
    let cur = f.hovering
    result.x = f.cursor_x
    case f.cursor_grid:
    of Color1:
        let a = f.bl.getColumn(f.cursor_x)
        result.g = Color2
        block search:
            for i in 0 ..< a.height:
                if cur != a.get(i, 0):
                    result.y = i
                    break search
            result.y = 0
    of Color2:
        let a = f.tl.getColumn(f.cursor_x)
        result.g = Color1
        block search:
            for i in countdown(a.height - 1, 0):
                if cur != a.get(i, 0):
                    result.y = i
                    break search
            result.y = 3
    of Color3:
        let a = f.br.getColumn(f.cursor_y)
        result.g = Color4
        block search:
            for i in 0 ..< a.height:
                if cur != a.get(i, 0):
                    result.y = i
                    break search
            result.y = 0
    of Color4:
        let a = f.tr.getColumn(f.cursor_y)
        result.g = Color3
        block search:
            for i in countdown(a.height - 1, 0):
                if cur != a.get(i, 0):
                    result.y = i
                    break search
            result.y = 3


proc main =
    discard


if isMainModule:
    main()
