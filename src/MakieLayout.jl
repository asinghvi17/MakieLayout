module MakieLayout

using AbstractPlotting
using AbstractPlotting: Rect2D, IRect2D, ispressed, is_mouseinside
using AbstractPlotting.Keyboard
using AbstractPlotting.Mouse
using Observables: onany
using Match
import Animations, Formatting, Observables, DocStringExtensions

include("types.jl")
include("gridlayout.jl")
include("helpers.jl")
include("mousestatemachine.jl")
include("geometry_integration.jl")
include("layout_engine.jl")
include("makie_integration.jl")
include("ticklocators/linear.jl")
include("ticklocators/optimized.jl")
include("defaultattributes.jl")
include("lineaxis.jl")
include("lobjects/laxis.jl")
include("lobjects/lcolorbar.jl")
include("lobjects/ltext.jl")
include("lobjects/lslider.jl")
include("lobjects/lbutton.jl")
include("lobjects/lrect.jl")
include("lobjects/ltoggle.jl")
include("lobjects/llegend.jl")
include("lobjects/lobject.jl")
include("gridapi.jl")

export LAxis
export LSlider
export LButton
export LColorbar
export LText
export LRect
export LToggle
export LLegend
export linkxaxes!, linkyaxes!, linkaxes!
export GridLayout
export ProtrusionLayout
export BBox
export solve
export shrinkbymargin
export applylayout
export Inside, Outside
export Fixed, Auto, Relative, Aspect
export FixedSizeBox
export FixedHeightBox
export width, height, top, bottom, left, right
export with_updates_suspended
export appendcols!, appendrows!, prependcols!, prependrows!, deletecol!, deleterow!, trim!
export gridnest!
export AxisAspect, DataAspect
export autolimits!
export AutoLinearTicks, ManualTicks
export hidexdecorations!, hideydecorations!
export tight_xticklabel_spacing!, tight_yticklabel_spacing!, tight_ticklabel_spacing!, tightlimits!
export colsize!, rowsize!, colgap!, rowgap!
export Left, Right, Top, Bottom, TopLeft, BottomLeft, TopRight, BottomRight
export LegendEntry, LineElement, MarkerElement, PolyElement
export grid!, hbox!, vbox!
export layoutscene

const FPS = Node(30)
const COLOR_ACCENT = Ref(RGBf0(((79, 122, 214) ./ 255)...))
const COLOR_ACCENT_DIMMED = Ref(RGBf0(((174, 192, 230) ./ 255)...))

end # module
