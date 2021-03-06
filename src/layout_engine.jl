
abstract type Alignable end

"""
Used to specify space that is occupied in a grid. Like 1:1|1:1 for the first square,
or 2:3|1:4 for a rect over the 2nd and 3rd row and the first four columns.
"""
struct Span
    rows::UnitRange{Int64}
    cols::UnitRange{Int64}
end

"""
An object that can be aligned that also specifies how much space it occupies in
a grid via its span.
"""
struct SpannedAlignable{T <: Alignable}
    al::T
    sp::Span
end

"""
    side_indices(c::SpannedAlignable)::RowCols{Int}

Indices of the rows / cols for each side
"""
function side_indices(c::SpannedAlignable)
    return RowCols(
        c.sp.cols.start,
        c.sp.cols.stop,
        c.sp.rows.start,
        c.sp.rows.stop,
    )
end

"""
These functions tell whether an object in a grid touches the left, top, etc. border
of the grid. This means that it is relevant for the grid's own protrusion on that side.
"""
ismostin(sp::SpannedAlignable, grid, ::Left) = sp.sp.cols.start == 1
ismostin(sp::SpannedAlignable, grid, ::Right) = sp.sp.cols.stop == grid.ncols
ismostin(sp::SpannedAlignable, grid, ::Bottom) = sp.sp.rows.stop == grid.nrows
ismostin(sp::SpannedAlignable, grid, ::Top) = sp.sp.cols.start == 1

isleftmostin(sp::SpannedAlignable, grid) = ismostin(sp, grid, Left())
isrightmostin(sp::SpannedAlignable, grid) = ismostin(sp, grid, Right())
isbottommostin(sp::SpannedAlignable, grid) = ismostin(sp, grid, Bottom())
istopmostin(sp::SpannedAlignable, grid) = ismostin(sp, grid, Top())

struct SolvedAxisLayout <: Alignable
    inner::BBox
    outer::BBox
    axis::LayoutedAxis
end

struct AxisLayout <: Alignable
    decorations::BBox
    axis::LayoutedAxis
end

struct SolvedGridLayout <: Alignable
    bbox::BBox
    content::Vector{SpannedAlignable}
    nrows::Int
    ncols::Int
    grid::RowCols{Vector{Float64}}
end

struct GridLayout <: Alignable
    content::Vector{SpannedAlignable}
    nrows::Int
    ncols::Int
    colratios::Vector{Float64}
    rowratios::Vector{Float64}
    colgapfraction::Float64
    rowgapfraction::Float64
end


"""
All the protrusion functions calculate how much stuff "sticks out" of a layoutable object.
This is so that collisions are avoided, while what is actually aligned is the
"important" edges of the layout objects.
"""
leftprotrusion(x) = protrusion(x, Left())
rightprotrusion(x) = protrusion(x, Right())
bottomprotrusion(x) = protrusion(x, Bottom())
topprotrusion(x) = protrusion(x, Top())

protrusion(u::AxisLayout, side::Side) = u.decorations[side]
protrusion(sp::SpannedAlignable, side::Side) = protrusion(sp.al, side)

function protrusion(gl::GridLayout, side::Side)
    return mapreduce(max, gl.content, init = 0.0) do elem
        # we use only objects that stick out on this side
        # And from those we use the maximum protrusion
        ismostin(elem, gl, side) ? protrusion(elem, side) : 0.0
    end
end

protrusion(s::SolvedAxisLayout, ::Left) = left(s.inner) - left(s.outer)
function protrusion(s::SolvedAxisLayout, side::Side)
    return s.outer[side] - s.inner[side]
end

"""
This function solves a grid layout such that the "important lines" fit exactly
into a given bounding box. This means that the protrusions of all objects inside
the grid are not taken into account. This is needed if the grid is itself placed
inside another grid.
"""
function solve(gl::GridLayout, bbox::BBox)

    # first determine how big the protrusions on each side of all columns and rows are
    maxgrid = RowCols(gl.ncols, gl.nrows)
    # go through all the layout objects placed in the grid
    for c in gl.content
        idx_rect = side_indices(c)
        mapsides(idx_rect, maxgrid) do side, idx, grid
            grid[idx] = max(grid[idx], protrusion(c.al, side))
        end
    end
    # compute what size the gaps between rows and columns need to be
    colgaps = maxgrid.lefts[2:end] .+ maxgrid.rights[1:end-1]
    rowgaps = maxgrid.tops[2:end] .+ maxgrid.bottoms[1:end-1]

    # determine the biggest gap
    # using the biggest gap size for all gaps will make the layout more even, but one
    # could make this aspect customizable, because it might waste space
    maxcolgap = maximum(colgaps)
    maxrowgap = maximum(rowgaps)

    # determine the vertical and horizontal space needed just for the gaps
    # again, the gaps are what the protrusions stick into, so they are not actually "empty"
    # depending on what sticks out of the plots
    sumcolgaps = maxcolgap * (gl.ncols - 1)
    sumrowgaps = maxrowgap * (gl.nrows - 1)

    # compute what space remains for the inner parts of the plots
    remaininghorizontalspace = width(bbox) - sumcolgaps
    remainingverticalspace = height(bbox) - sumrowgaps

    # compute how much gap to add, in case e.g. labels are too close together
    # this is given as a fraction of the space used for the inner parts of the plots
    # so far, but maybe this should just be an absolute pixel value so it doesn't change
    # when resizing the window
    addedcolgap = gl.colgapfraction * remaininghorizontalspace
    addedrowgap = gl.rowgapfraction * remainingverticalspace

    # compute the actual space available for the rows and columns (plots without protrusions)
    spaceforcolumns = remaininghorizontalspace - addedcolgap * (gl.ncols - 1)
    spaceforrows = remainingverticalspace - addedrowgap * (gl.nrows - 1)

    # compute the column widths and row heights using the specified row and column ratios
    colwidths = gl.colratios ./ sum(gl.colratios) .* spaceforcolumns
    rowheights = gl.rowratios ./ sum(gl.rowratios) .* spaceforrows

    # this is the vertical / horizontal space between the inner lines of all plots
    colgap = maxcolgap + addedcolgap
    rowgap = maxrowgap + addedrowgap

    # compute the x values for all left and right column boundaries
    xleftcols = [left(bbox) + sum(colwidths[1:i-1]) + (i - 1) * colgap for i in 1:gl.ncols]
    xrightcols = xleftcols .+ colwidths

    # compute the y values for all top and bottom row boundaries
    ytoprows = [top(bbox) - sum(rowheights[1:i-1]) - (i - 1) * rowgap for i in 1:gl.nrows]
    ybottomrows = ytoprows .- rowheights

    # now we can solve the content thats inside the grid because we know where each
    # column and row is placed, how wide it is, etc.
    # note that what we did at the top was determine the protrusions of all grid content,
    # but we know the protrusions before we know how much space each plot actually has
    # because the protrusions should be static (like tick labels etc don't change size with the plot)

    gridboxes = RowCols(
        xleftcols, xrightcols,
        ytoprows, ybottomrows
    )
    solvedcontent = map(gl.content) do c
        idx_rect = side_indices(c)
        bbox_cell = mapsides(idx_rect, gridboxes) do side, idx, gridside
            gridside[idx]
        end
        solved = solve(c.al, bbox_cell)
        return SpannedAlignable(solved, c.sp)
    end
    # return a solved grid layout in which all objects are also solved layout objects
    return SolvedGridLayout(
        bbox, solvedcontent,
        gl.nrows, gl.ncols,
        gridboxes
    )
end



"""
This function solves a grid layout so that it fits exactly inside a bounding box.
Exactly means that the protrusions of all other objects inside this grid layout
also have to fit into the bounding box. This is needed if the grid is the outermost
object in the layout, the bounding box would then be the scene boundary.
"""
function outersolve(gl::GridLayout, bbox::BBox)
    maxgrid = RowCols(gl.ncols, gl.nrows)
    for c in gl.content
        idx_rect = side_indices(c)
        mapsides(idx_rect, maxgrid) do side, idx, grid
            grid[idx] = max(grid[idx], protrusion(c.al, side))
        end
    end

    topprot = maxgrid.tops[1]
    bottomprot = maxgrid.bottoms[end]
    leftprot = maxgrid.lefts[1]
    rightprot = maxgrid.rights[end]

    colgaps = maxgrid.lefts[2:end] .+ maxgrid.rights[1:end-1]
    rowgaps = maxgrid.tops[2:end] .+ maxgrid.bottoms[1:end-1]

    maxcolgap = gl.ncols <= 1 ? 0 : maximum(colgaps)
    maxrowgap = gl.nrows <= 1 ? 0 : maximum(rowgaps)

    sumcolgaps = maxcolgap * (gl.ncols - 1)
    sumrowgaps = maxrowgap * (gl.nrows - 1)

    remaininghorizontalspace = width(bbox) - sumcolgaps - leftprot - rightprot
    remainingverticalspace = height(bbox) - sumrowgaps - topprot - bottomprot

    addedcolgap = gl.colgapfraction * remaininghorizontalspace
    addedrowgap = gl.rowgapfraction * remainingverticalspace

    spaceforcolumns = remaininghorizontalspace - addedcolgap * (gl.ncols - 1)
    spaceforrows = remainingverticalspace - addedrowgap * (gl.nrows - 1)

    colwidths = gl.colratios ./ sum(gl.colratios) .* spaceforcolumns
    rowheights = gl.rowratios ./ sum(gl.rowratios) .* spaceforrows

    colgap = maxcolgap + addedcolgap
    rowgap = maxrowgap + addedrowgap

    xleftcols = map(1:gl.ncols) do i
        left(bbox) + leftprot + sum(colwidths[1:i-1]) + (i - 1) * colgap
    end
    xrightcols = xleftcols .+ colwidths

    ytoprows = map(1:gl.nrows) do i
        top(bbox) - topprot - sum(rowheights[1:i-1]) - (i - 1) * rowgap
    end

    ybottomrows = ytoprows .- rowheights
    gridboxes = RowCols(
        xleftcols, xrightcols,
        ytoprows, ybottomrows
    )
    solvedcontent = map(gl.content) do c
        idx_rect = side_indices(c)
        bbox_cell = mapsides(idx_rect, gridboxes) do side, idx, gridside
            gridside[idx]
        end
        solved = solve(c.al, bbox_cell)
        return SpannedAlignable(solved, c.sp)
    end
    # solvedcontent = solve.(gl.content)
    SolvedGridLayout(
        bbox, solvedcontent, gl.nrows, gl.ncols,
        gridboxes
    )
end



function solve(ua::AxisLayout, innerbbox)
    bbox = mapsides(innerbbox, ua.decorations) do side, iside, decside
        op = side isa Union{Left, Top} ? (-) : (+)
        return op(iside, decside)
    end
    SolvedAxisLayout(innerbbox, bbox, ua.axis)
end

const Indexables = Union{UnitRange, Int, Colon}

"""
This function allows indexing syntax to add a layout object to a grid.
You can do:

grid[1, 1] = obj
grid[1, :] = obj
grid[1:3, 2:5] = obj

and all combinations of the above
"""
function Base.setindex!(g, a::Alignable, rows::Indexables, cols::Indexables)
    if rows isa Int
        rows = rows:rows
    elseif rows isa Colon
        rows = 1:g.nrows
    end
    if cols isa Int
        cols = cols:cols
    elseif cols isa Colon
        cols = 1:g.ncols
    end

    if !((1 <= rows.start <= g.nrows) || (1 <= rows.stop <= g.nrows))
        error("invalid row span $rows for grid with $(g.nrows) rows")
    end
    if !((1 <= cols.start <= g.ncols) || (1 <= cols.stop <= g.ncols))
        error("invalid col span $cols for grid with $(g.ncols) columns")
    end

    push!(g.content, SpannedAlignable(a, Span(rows, cols)))
end
