function default_attributes(::Type{LayoutedAxis})
    Attributes(
        xlabel = "x label",
        ylabel = "y label",
        title = "Title",
        titlefont = "DejaVu Sans",
        titlesize = 30f0,
        titlegap = 10f0,
        titlevisible = true,
        titlealign = :center,
        xlabelcolor = RGBf0(0, 0, 0),
        ylabelcolor = RGBf0(0, 0, 0),
        xlabelsize = 20f0,
        ylabelsize = 20f0,
        xlabelvisible = true,
        ylabelvisible = true,
        xlabelpadding = 5f0,
        ylabelpadding = 5f0,
        xticklabelsize = 20f0,
        yticklabelsize = 20f0,
        xticklabelsvisible = true,
        yticklabelsvisible = true,
        xticklabelspace = 20f0,
        yticklabelspace = 50f0,
        xticklabelpad = 5f0,
        yticklabelpad = 5f0,
        xticklabelrotation = 0f0,
        yticklabelrotation = 0f0,
        xticklabelalign = (:center, :top),
        yticklabelalign = (:right, :center),
        xticksize = 10f0,
        yticksize = 10f0,
        xticksvisible = true,
        yticksvisible = true,
        xtickalign = 0f0,
        ytickalign = 0f0,
        xtickwidth = 1f0,
        ytickwidth = 1f0,
        xtickcolor = RGBf0(0, 0, 0),
        ytickcolor = RGBf0(0, 0, 0),
        xpanlock = false,
        ypanlock = false,
        xzoomlock = false,
        yzoomlock = false,
        spinewidth = 1f0,
        xgridvisible = true,
        ygridvisible = true,
        xgridwidth = 1f0,
        ygridwidth = 1f0,
        xgridcolor = RGBAf0(0, 0, 0, 0.1),
        ygridcolor = RGBAf0(0, 0, 0, 0.1),
        topspinevisible = true,
        rightspinevisible = true,
        leftspinevisible = true,
        bottomspinevisible = true,
        topspinecolor = RGBf0(0, 0, 0),
        leftspinecolor = RGBf0(0, 0, 0),
        rightspinecolor = RGBf0(0, 0, 0),
        bottomspinecolor = RGBf0(0, 0, 0),
        aspect = nothing,
        alignment = (0.5f0, 0.5f0),
        maxsize = (Inf32, Inf32),
        xautolimitmargin = (0.05f0, 0.05f0),
        yautolimitmargin = (0.05f0, 0.05f0),
        xticks = AutoLinearTicks(100f0),
        yticks = AutoLinearTicks(100f0),
    )
end

function default_attributes(::Type{LayoutedColorbar})
    Attributes(
        label = "label",
        title = "Title",
        titlefont = "DejaVu Sans",
        titlesize = 30f0,
        titlegap = 10f0,
        titlevisible = true,
        titlealign = :center,
        labelcolor = RGBf0(0, 0, 0),
        labelsize = 20f0,
        labelvisible = true,
        labelpadding = 5f0,
        ticklabelsize = 20f0,
        ticklabelsvisible = true,
        ticksize = 10f0,
        ticksvisible = true,
        ticklabelpad = 20f0,
        tickalign = 0f0,
        tickwidth = 1f0,
        tickcolor = RGBf0(0, 0, 0),
        spinewidth = 1f0,
        idealtickdistance = 100f0,
        topspinevisible = true,
        rightspinevisible = true,
        leftspinevisible = true,
        bottomspinevisible = true,
        topspinecolor = RGBf0(0, 0, 0),
        leftspinecolor = RGBf0(0, 0, 0),
        rightspinecolor = RGBf0(0, 0, 0),
        bottomspinecolor = RGBf0(0, 0, 0),
        aspect = nothing,
        alignment = (0.5f0, 0.5f0),
        maxsize = (Inf32, Inf32),
    )
end

function default_attributes(::Type{LayoutedText})
    Attributes(
        text = "Text",
        visible = true,
        color = RGBf0(0, 0, 0),
        textsize = 20f0,
        font = "Dejavu Sans",
        valign = :center,
        halign = :center,
        rotation = 0f0,
        padding = (0f0, 0f0, 0f0, 0f0),
    )
end