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

proc get(f: Field, l: Location): ColorOpt =
    case l.g:
    of Color1:
        f.tl[l.y, l.x]
    of Color2:
        f.tr[l.y, l.x]
    of Color3:
        f.bl[l.y, l.x]
    of Color4:
        f.br[l.y, l.x]

proc `[]`(f: var Field, c: ColorOpt): var Grid =
    case c:
    of Color1:
        f.tl
    of Color2:
        f.tr
    of Color3:
        f.bl
    of Color4:
        f.br

proc place(f: var Field, l: Location, c: ColorOpt) =
    case l.g:
    of Color1:
        f.tl[l.y, l.x] = c
    of Color2:
        f.tr[l.y, l.x] = c
    of Color3:
        f.bl[l.y, l.x] = c
    of Color4:
        f.br[l.y, l.x] = c
        

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
        let a = f.tl.getRow(f.cursor_y)
        result.g = Color4
        block search:
            for i in countdown(a.width - 1, 0):
                if cur != a[0, i]:
                    result.x = i
                    break search
            result.x = 3
    of Color2:
        let a = f.br.getRow(f.cursor_y)
        result.g = Color1
        block search:
            for i in 0 ..< a.width:
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
        result.g = Color2
        block search:
            for i in 0 ..< a.height:
                if cur != a[i, 0]:
                    result.y = i
                    break search
            result.y = 0
    of Color2:
        let a = f.tl.getColumn(f.cursor_x)
        result.g = Color1
        block search:
            for i in countdown(a.height - 1, 0):
                if cur != a[i, 0]:
                    result.y = i
                    break search
            result.y = 3
    of Color3:
        let a = f.br.getColumn(f.cursor_y)
        result.g = Color4
        block search:
            for i in 0 ..< a.height:
                if cur != a[i, 0]:
                    result.y = i
                    break search
            result.y = 0
    of Color4:
        let a = f.tr.getColumn(f.cursor_y)
        result.g = Color3
        block search:
            for i in countdown(a.height - 1, 0):
                if cur != a[i, 0]:
                    result.y = i
                    break search
            result.y = 3

proc swap(f: var Field, a, b: Location) =
    var temp_a = f.get(a)
    var temp_b = f.get(b)

    f.place(b, temp_a)
    f.place(a, temp_b)


proc main =
    discard


if isMainModule:
    main()
