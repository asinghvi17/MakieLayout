function LayoutedButton(scene::Scene; kwargs...)

    attrs = merge!(Attributes(kwargs), default_attributes(LayoutedButton))

    @extract attrs (padding, textsize, label, font, alignment, cornerradius,
        cornersegments, strokewidth, strokecolor, buttoncolor, autoshrink,
        labelcolor, labelcolor_hover, labelcolor_active,
        buttoncolor_active, buttoncolor_hover, clicks)

    decorations = Dict{Symbol, Any}()

    widthattr = attrs.width
    heightattr = attrs.height

    heightnode = Node{Union{Nothing, Float32}}(heightattr[])
    widthnode = Node{Union{Nothing, Float32}}(widthattr[])

    bboxnode = Node(BBox(0, 100, 0, 100))

    textpos = Node(Point2f0(0, 0))

    subarea = lift(bboxnode) do bbox
        IRect2D(bbox)
    end
    subscene = Scene(scene, subarea, camera=campixel!)

    lcolor = Node{Any}(labelcolor[])
    labeltext = text!(subscene, label, position = textpos, textsize = textsize, font = font,
        color = lcolor, align = (:center, :center))[end]

    onany(label, textsize, font, padding, heightattr, widthattr, autoshrink) do label,
            textsize, font, padding, heightattr, widthattr, autoshrink

        textbb = FRect2D(boundingbox(labeltext))

        # widthnode[] = width(textbb) + padding[1] + padding[2]

        newheight = if isnothing(heightattr)
            # self-calculate text height
            if autoshrink[2]
                height(textbb) + padding[3] + padding[4]
            else
                nothing
            end
        else
            # use provided height
            heightattr
        end
        if newheight != heightnode[]
            heightnode[] = newheight
        end

        newwidth = if isnothing(widthattr)
            if autoshrink[1]
                width(textbb) + padding[1] + padding[2]
            else
                nothing
            end
        else
            widthattr
        end
        if newwidth != widthnode[]
            widthnode[] = newwidth
        end
    end

    label[] = label[]

    buttonrect = lift(subarea, heightnode, widthnode, alignment) do bbox, h, w, al

        bw = width(bbox)
        bh = height(bbox)

        w = isnothing(w) ? bw : w
        h = isnothing(h) ? bh : h

        rw = bw - w
        rh = bh - h

        xshift = if al[1] == :left
            0
        elseif al[1] == :center
            0.5rw
        elseif al[1] == :right
            rw
        end

        yshift = if al[2] == :bottom
            0
        elseif al[2] == :center
            0.5rh
        elseif al[2] == :top
            rh
        end

        l = xshift
        b = yshift
        r = l + w
        t = b + h
        BBox(l, r, b, t)
    end

    on(buttonrect) do rect
        textpos[] = Point2f0(left(rect) + 0.5f0 * width(rect), bottom(rect) + 0.5f0 * height(rect))
    end

    roundedrectpoints = lift(buttonrect, cornerradius, cornersegments) do rect,
            cr, csegs

        cr = min(width(rect) / 2, height(rect) / 2, cr)

        # inner corners
        ictl = topleft(rect) .+ Point2(cr, -cr)
        ictr = topright(rect) .+ Point2(-cr, -cr)
        icbl = bottomleft(rect) .+ Point2(cr, cr)
        icbr = bottomright(rect) .+ Point2(-cr, cr)

        cstr = anglepoint.(Ref(ictr), LinRange(0, pi/2, csegs), cr)
        cstl = anglepoint.(Ref(ictl), LinRange(pi/2, pi, csegs), cr)
        csbl = anglepoint.(Ref(icbl), LinRange(pi, 3pi/2, csegs), cr)
        csbr = anglepoint.(Ref(icbr), LinRange(3pi/2, 2pi, csegs), cr)

        arr = [cstr; cstl; csbl; csbr]
    end

    bcolor = Node{Any}(buttoncolor[])
    button = poly!(subscene, roundedrectpoints, strokewidth = strokewidth, strokecolor = strokecolor,
        color = bcolor)[end]
    decorations[:button] = button
    # put button in front so the text doesn't block the mouse
    reverse!(subscene.plots)

    mousestate = addmousestate!(subscene, button)

    onmouseover(mousestate) do state
        bcolor[] = buttoncolor_hover[]
        lcolor[] = labelcolor_hover[]
    end

    onmouseout(mousestate) do state
        bcolor[] = buttoncolor[]
        lcolor[] = labelcolor[]
    end

    onmousedown(mousestate) do state
        bcolor[] = buttoncolor_active[]
        lcolor[] = labelcolor_active[]
    end

    onmouseclick(mousestate) do state
        clicks[] = clicks[] + 1
    end

    LayoutedButton(scene, bboxnode, widthnode, heightnode, attrs, decorations)
end

function anglepoint(center::Point2, angle::Real, radius::Real)
    Ref(center) .+ Ref(Point2(cos(angle), sin(angle))) .* radius
end

function align_to_bbox!(lb::LayoutedButton, bbox)
    lb.bboxnode[] = bbox
end

widthnode(lb::LayoutedButton) = lb.width
heightnode(lb::LayoutedButton) = lb.height

defaultlayout(lb::LayoutedButton) = ProtrusionLayout(lb)

function Base.getproperty(lb::LayoutedButton, s::Symbol)
    if s in fieldnames(LayoutedButton)
        getfield(lb, s)
    else
        lb.attributes[s]
    end
end
function Base.propertynames(lb::LayoutedButton)
    vcat(fieldnames(LayoutedButton, keys(lb.attributes))
end
