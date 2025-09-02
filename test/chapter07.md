{data-type="chapter"}
# Parametric and Polar Curves

{cell=chap display=false output=false result=false}
```julia
using NativeSVG

struct Figure
	draw::Function
	id::String
	title::String
end

function Base.show(io::IO, ::MIME"text/html", fig::Figure)
    write(io, "<figure>\n")
	show(io, fig.draw())
	write(io, "<figcaption>", fig.title, "</figcaption>")
	write(io, "</figure>\n")
end

const font_y = 18
const font_x = 14

function axis_xy(width::Number, height::Number, Ox::Number, Oy::Number, scale::Number, axis_x, axis_y; xs=nothing, ys=nothing, xl=nothing, yl=nothing, xh=nothing, yh=nothing, shift_x=0, shift_y=0, symbol_x="x")
	defs() do
		marker(id="arrow", markerWidth="6", markerHeight="6", refX="3", refY="3", orient="auto") do
			path(d="M 0 0 L 6 3 L 0 6 z", fill="black" )
		end
	end
	latex("O", x=Ox-font_x-2, y=Oy, width=font_x, height=font_y)
	latex(symbol_x, x=shift_x+width-font_x-2, y=Oy-font_y-2, width=font_x, height=font_y)
	latex("y", x=Ox+2, y=shift_y-2, width=font_x, height=font_y)
	line(x1=shift_x, y1=Oy, x2=shift_x+width-3, y2=Oy, stroke="black", marker_end="url(#arrow)")
	for (nr, n) in enumerate(axis_x)
		line(x1=Ox+scale*n, y1=Oy-3, x2=Ox+scale*n, y2=Oy+3, stroke="black")
		txt = if xs===nothing "$n" else "$(xs[nr])" end
		len = if xl===nothing length(txt) else xl[nr] end
		h = if xh===nothing 1 else xh[nr] end
		latex(txt, x=Ox+scale*n-font_x*len/2, y=Oy, width=font_x*len, height=font_y*h)
	end
	line(x1=Ox, y1=height, x2=Ox, y2=shift_y+3, stroke="black", marker_end="url(#arrow)")
	for (nr, n) in enumerate(axis_y)
		line(x1=Ox-3, y1=Oy-scale*n, x2=Ox+3, y2=Oy-scale*n, stroke="black")
		txt = if ys===nothing "$n" else "$(ys[nr])" end
		len = if yl===nothing length(txt) else yl[nr] end
		h = if yh===nothing 1 else yh[nr] end
		latex(txt, x=Ox-font_x*len, y=Oy-scale*n-font_y/2, width=font_x*len, height=font_y*h)
	end
end

function plot_xy(f::Function, xs, xdots, Ox::Number, Oy::Number, scale::Number; color::String="red", dashed::String="", width::Number=1)
	points = String[]
	for x in xs
		y = f(x)
		push!(points, "$(Ox+scale*x), $(Oy-scale*y)")
	end
	polyline(points=join(points, " "), fill="none", stroke=color, stroke_width=width, stroke_dasharray = dashed)
	for x in xdots
		y = f(x)
		circle(cx=Ox+scale*x, cy=Oy-scale*y, r=3, fill=color, stroke=color)
	end
end

function curve_xy(f::Function, g::Function, ts, tdots, Ox::Number, Oy::Number, scale::Number; color::String="red", dashed::String="", width::Number=1, arrow::Bool=true)
	defs() do
		marker(id="arrowc", markerWidth="6", markerHeight="6", refX="3", refY="3", orient="auto") do
			path(d="M 0 0 L 6 3 L 0 6 z", fill=color, stroke=color)
		end
	end
	points = String[]
	for t in ts
		x = f(t)
		y = g(t)
		push!(points, "$(Ox+scale*x), $(Oy-scale*y)")
	end
	if arrow
		polyline(points=join(points, " "), fill="none", stroke=color, stroke_width=width, stroke_dasharray = dashed, marker_end="url(#arrowc)")
	else
		polyline(points=join(points, " "), fill="none", stroke=color, stroke_width=width, stroke_dasharray = dashed)
	end
	for t in tdots
		x = f(t)
		y = g(t)
		circle(cx=Ox+scale*x, cy=Oy-scale*y, r=3, fill=color, stroke=color)
	end
end

function table(f::Function)
    io = IOBuffer()
    write(io, "<table>\n")
    f(io)
    write(io, "</table>\n")
    String(take!(io))
end

function thead(io::IOBuffer, header; latex::Bool=false, align=:left)
    write(io, "<thead>")
    for (nr, element) in enumerate(header)
        style = if align isa Symbol
            string(align)
        else
            string(align[nr])
        end
        write(io, """<th style="text-align: $style">""")
        if latex
            write(io, tex(element))
        else
            write(io, element)
        end
        write(io, "</th>")
    end
    write(io, "</thead>\n")
end

function trow(io::IOBuffer, row; latex::Bool=false, align=:left)
    write(io, "<tr>")
    for (nr, element) in enumerate(row)
        style = if align isa Symbol
            string(align)
        else
            string(align[nr])
        end
        write(io, """<td style="text-align: $style">""")
        if latex
            write(io, tex(element))
        else
            write(io, element)
        end
        write(io, "</td>")
    end
    write(io, "</tr>\n")
end

function tex(str::String)
    """<span class="math-tex" data-type="tex">\\(""" * str * """\\)</span>"""
end
```

Until now, most curves we have encountered have been graphs of functions, and they provided useful visual information about the behaviour of the functions. In this chapter we begin to look at plane curves as interesting objects in their own right.

## Parametric Curves

Suppose that an object moves around in the ``xy``-plane so that the coordinates of its position at any time ``t`` are continuous functions of the variable ``t``:

```math
x=f\left(t\right)\quad\textrm{and}\quad y = g\left(t\right)\,.
```

The path followed by the object is a curve ``𝒞`` in the plane that is specified by the two equations above. We call these equations *parametric equations* of ``𝒞``. A curve specified by a particular pair of parametric equations is called a *parametric curve*.

!!! definition

	A *parametric curve* ``𝒞`` in the plane consists of an ordered pair ``\left(f, g\right)`` of continuous functions each defined on the same interval ``I``. The equations

	```math
	x=f\left(t\right)\quad\textrm{and}\quad y = g\left(t\right)\quad\textrm{for }t\in I\,,
	```

	are called *parametric equations* of the curve ``𝒞``. The independent variable ``t`` is called the *parameter*.

Note that the parametric curve ``𝒞`` was not defined as a set of points in the plane, but rather as the ordered pair of functions whose range is that set of points. Different pairs of functions can give the same set of points in the plane, but we may still want to regard them as different parametric curves.

We will usually denote the parameter by ``t``; in many applications the parameter represents time, but this need not always be the case. 

A parametric curve has a direction (indicated, say, by arrowheads), namely, the direction corresponding to increasing values of the parameter ``t``.

!!! example

	Sketch and identify the parametric curve

	```math
	x=t^2-1\quad\textrm{and}\quad y=t+1\,,\quad t\in \mathbb{R}\,.
	```

	We could construct a table of values of ``x`` and ``y`` for various values of ``t``, thus getting the coordinates of a number of points on a curve. However, for this example it is easier to *eliminate* the parameter from the pair of parametric equations, thus producing a single equation in ``x`` and ``y`` whose graph is the desired curve:

	```math
	t=y - 1\,,\quad x=t^2-1=\left(y-1\right)^2-1=y^2-2y\,.
	```

	All points on the curve lie on the parabola ``x=y^2-2y``. Since ``y\to\pm\infty`` as ``t\to\pm\infty``, the parametric curve is the whole parabola.

	{cell=chap display=false output=false}
	```julia
	Figure("", "The parabola defined parameterically by " * tex("x=t^2-1, y=t+1, t\\in \\mathbb{R}\\,.") ) do
		scale = 40
		Drawing(width=11scale, height=7scale) do
			xmid = 2scale
			ymid = 4.5scale
			axis_xy(11scale,7scale,xmid,ymid,scale,tuple(),tuple())
			curve_xy(t->t^2-1, t->t+1, -4:0.01:3, (-2, -1, 0, 1, 2), xmid, ymid, scale)
			latex("t=-2", x=xmid+3scale, y=ymid+0.5scale, width=3font_x, height=font_y)
			latex("t=-1", x=xmid+0.25scale, y=ymid-0.5scale, width=3font_x, height=font_y)
			latex("t=0", x=xmid-2.15scale, y=ymid-1.2scale, width=3font_x, height=font_y)
			latex("t=1", x=xmid+0.15scale, y=ymid-2scale, width=3font_x, height=font_y)
			latex("t=-2", x=xmid+3scale, y=ymid-3scale, width=3font_x, height=font_y)
		end
	end
	```

Although the curve in this example is more easily identified when the parameter is eliminated, there is a loss of information in going to the nonparametric form. Specifically, we lose the sense of the curve as the path of a moving point and hence also the direction of the curve.

!!! example

	Sketch the parametric curve

	```math
	x=t^3-3t\quad\textrm{and}\quad y=t^2\,,\quad -2\le t\le 2\,.
	```

	We could eliminate the parameter and obtain

	```math
	x^2=t^2\left(t^2-3\right)^2=y\left(y-2\right)^2\,,
	```

	but this doesn’t help much since we do not recognize this curve from its Cartesian equation. Instead, let us calculate the coordinates of some points:

	{cell=chap display=false output=false}
	```julia
	Figure("", "A self-intersecting parametric curve.") do
		scale = 50
		Drawing(width=6scale, height=5scale) do
			xmid = 3scale
			ymid = 4.5scale
			axis_xy(6scale,5scale,xmid,ymid,scale,tuple(),tuple())
			curve_xy(t->t^3-3t, t->t^2, -2:0.01:2, (-2, -1, 0, 1, sqrt(3)), xmid, ymid, scale)
			latex("t=-2", x=xmid-3scale, y=ymid-4.15scale, width=3font_x, height=font_y)
			latex("t=-1", x=xmid+2.15scale, y=ymid-1.15scale, width=3font_x, height=font_y)
			latex("t=0", x=xmid+0.05scale, y=ymid+0.05scale, width=3font_x, height=font_y)
			latex("t=1", x=xmid-2.85scale, y=ymid-1.15scale, width=3font_x, height=font_y)
			latex("t=\\pm\\sqrt 3", x=xmid+0.1scale, y=ymid-3.15scale, width=4font_x, height=font_y)
		end
	end
	```

	Note that the curve is symmetric about the ``y``-axis because ``x`` is an odd function of ``t`` and ``y`` is an even function of ``t``.

	The curve intersects itself on the ``y``-axis. To find this selfintersection, set ``x=0``:

	```math
	0=x=t^3-3t=t\left(t-\sqrt 3\right)\left(t+\sqrt 3\right)\,.
	```

	For ``t=0`` the curve is at ``\left(0,0\right)``, but for ``t=\pm\sqrt 3`` the curve is at ``\left(0,3\right)``. The selfintersection occurs because the curve passes through the same point for two different values of the parameter.

	According to the defintion, a parametric curve always involves a particular set of parametric equations; it is not just a set of points in the plane. When we are interested in considering a curve solely as a set of points (a geometric object), we need not be concerned with any particular pair of parametric equations representing that curve. In this case we call the curve simply a *plane curve*.

!!! definition

	A plane curve is a set of points ``\left(x,y\right)`` in the plane such that ``x=f\left(t\right)`` and ``y=g\left(t\right)`` for some ``t`` in an interval ``I``, where ``f`` and ``g`` are continuous functions defined on ``I``. Any such interval ``I`` and function pair ``\left(f, g\right)`` that generate the points of ``𝒞`` is called a *parametrization* of ``𝒞``.

Since a plane curve does not involve any specific parametrization, it has no specific direction.

!!! example

	If ``f`` is a continuous function on an interval ``I``, then the graph of ``f`` is a plane curve. One obvious parametrization of this curve is

	```math
	x=t\quad\textrm{and}\quad y=f\left(t\right)\,,\quad t\in I\,.
	```

## Smooth Parametric Curves and Their Slopes

We say that a plane curve is *smooth* if it has a tangent line at each point ``P`` and this tangent turns in a continuous way as ``P`` moves along the curve.

If the curve ``𝒞`` is the graph of function ``f``; then ``𝒞`` is certainly smooth on any interval where the derivative ``f^\prime\left(x\right)`` exists and is a continuous function of ``x``. It may also be smooth on intervals containing isolated singular points; for example, the curve ``y=x^⅓`` is smooth everywhere even though ``\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}`` does not exist at ``x=0``.

For parametric curves ``x=f\left(t\right), y = g\left(t\right)`` the situation is more complicated. Even if ``f`` and ``g`` have continuous derivatives everywhere, such curves may fail to be smooth at certain points, specifically points where ``f^\prime\left(t\right)=g^\prime\left(t\right)=0``.

!!! example

	Consider the parametric curve

	```math
	x=f\left(t\right)=t^2\quad\textrm{and}\quad y = g\left(t\right)=t^3\,.
	```

	Eliminating ``t`` leads to the Cartesian equation ``y^2=x^3`` or ``x=y^\frac{2}{3}``, which is not smooth at the origin even though ``f^\prime\left(t\right)=2t`` and ``g^\prime\left(t\right)=3t^2`` are continuous for all ``t``.

	{cell=chap display=false output=false}
	```julia
	Figure("", "A self-intersecting parametric curve.") do
		scale = 100
		Drawing(width=1.75scale, height=2.5scale) do
			xmid = 0.5scale
			ymid = 1.25scale
			axis_xy(1.75scale,2.5scale,xmid,ymid,scale,tuple(),tuple())
			curve_xy(t->t^2, t->t^3, -1.5:0.01:1.05, (-1, 0, 1), xmid, ymid, scale)
			latex("t=-1", x=xmid+0.5scale, y=ymid+0.925scale, width=3font_x, height=font_y)
			latex("t=0", x=xmid-0.45scale, y=ymid-0.2scale, width=3font_x, height=font_y)
			latex("t=1", x=xmid+0.55scale, y=ymid-1.075scale, width=3font_x, height=font_y)
		end
	end
	```

	Observe that both ``f^\prime`` and ``g^\prime`` vanish at ``t=0``. If we regard the parametric equations as specifying the position at time ``t`` of a moving point ``P``, then the horizontal velocity is ``f^\prime\left(t\right)`` and the vertical velocity is ``g^\prime\left(t\right)``. Both velocities are ``0`` at ``t=0``, so ``P`` has come to a stop at that instant. When it starts moving again, it need not move in the direction it was going before it stopped.

The following theorem confirms that a parametric curve is smooth at points where the derivatives of its coordinate functions are continuous and not both zero.

!!! theorem

	Let ``𝒞`` be the parametric curve 
	
	```math
	x=f\left(t\right)\quad\textrm{and}\quad y = g\left(t\right)\quad\textrm{for }t\in I\,,
	```
	
	where ``f^\prime\left(t\right)`` and ``g^\prime\left(t\right)`` are continuous on the interval ``I``. If ``f^\prime\left(t\right)\ne 0`` on ``I``, then ``𝒞`` is smooth and has at each ``t`` a tangent line with slope

	```math
	\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}=\frac{g^\prime\left(t\right)}{f^\prime\left(t\right)}\,.
	```

!!! proof

	``f^\prime\left(t\right)\ne 0`` on ``I``, then ``f`` is either increasing or decreasing on ``I`` and so is bijective and invertible. So,

	```math
	y = g\left(t\right)=g\left(f^{-1}\left(x\right)\right)
	```

	with slope

	```math
	\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}=g^\prime\left(f^{-1}\left(x\right)\right)\frac{\mathrm{d}\kern-0.5pt \hphantom{x}}{\mathrm{d}\kern-0.5pt x}f^{-1}\left(x\right)=\frac{g^\prime\left(f^{-1}\left(x\right)\right)}{f^\prime\left(f^{-1}\left(x\right)\right)}=\frac{g^\prime\left(t\right)}{f^\prime\left(t\right)}\,.
	```

	This slope is a continuous function of ``t``, so the tangent to ``𝒞`` turns continuously for ``t`` in ``I``.

If ``f^\prime`` and ``g^\prime`` are continuous, and both vanish at some point ``t_0``, then the curve ``𝒞`` *may or may not* be smooth around ``t_0``.

The concavity of a parametric curve can be determined using the second derivatives of the parametric equations. The procedure is just to calculate the second derivative of ``y`` with respect to ``x`` using the Chain Rule:

```math
\begin{aligned}
\frac{\mathrm{d}^2\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x^2}=\frac{\mathrm{d}\kern-0.5pt \hphantom{x}}{\mathrm{d}\kern-0.5pt x}\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}&=\frac{\mathrm{d}\kern-0.5pt \hphantom{x}}{\mathrm{d}\kern-0.5pt x}\frac{g^\prime\left(f^{-1}\left(x\right)\right)}{f^\prime\left(f^{-1}\left(x\right)\right)}\\
&=\frac{f^\prime\left(f^{-1}\left(x\right)\right)g^{\prime\prime}\left(f^{-1}\left(x\right)\right)-g^\prime\left(f^{-1}\left(x\right)\right)f^{\prime\prime}\left(f^{-1}\left(x\right)\right)}{\left(f^\prime\left(f^{-1}\left(x\right)\right)\right)^2}\frac{1}{f^\prime\left(f^{-1}\left(x\right)\right)}\\
&=\frac{f^\prime\left(f^{-1}\left(x\right)\right)g^{\prime\prime}\left(f^{-1}\left(x\right)\right)-g^\prime\left(f^{-1}\left(x\right)\right)f^{\prime\prime}\left(f^{-1}\left(x\right)\right)}{\left(f^\prime\left(f^{-1}\left(x\right)\right)\right)^3}\\
&=\frac{f^\prime\left(t\right)g^{\prime\prime}\left(t\right)-g^\prime\left(t\right)f^{\prime\prime}\left(t\right)}{\left(f^\prime\left(t\right)\right)^3}\,.
\end{aligned}
```

## Arc Lengths and Areas for Parametric Curves

Let ``𝒞`` be a smooth parametric curve with equations

```math
x=f\left(t\right)\quad\textrm{and}\quad y = g\left(t\right)\quad\textrm{for }a\le t\le b\,.
```

We assume that ``f^\prime\left(t\right)`` and ``g^\prime\left(t\right)`` are continuous on the interval ``\left[a, b\right]`` and are never both zero. From the differential triangle with legs ``\mathrm{d}\kern-0.5pt x`` and ``\mathrm{d}\kern-0.5pt y`` and hypotenuse ``\mathrm{d}\kern-0.5pt s``, we obtain ``\left(\mathrm{d}\kern-0.5pt s\right)^2=\left(\mathrm{d}\kern-0.5pt x\right)^2+\left(\mathrm{d}\kern-0.5pt y\right)^2``, so we have

```math
\mathrm{d}\kern-0.5pt s=\frac{\mathrm{d}\kern-0.5pt s}{\mathrm{d}\kern-0.5pt t}\mathrm{d}\kern-0.5pt t=\sqrt{\left(\frac{\mathrm{d}\kern-0.5pt s}{\mathrm{d}\kern-0.5pt t}\right)^2}\mathrm{d}\kern-0.5pt t=\sqrt{\left(\frac{\mathrm{d}\kern-0.5pt x}{\mathrm{d}\kern-0.5pt t}\right)^2+\left(\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt t}\right)^2}\mathrm{d}\kern-0.5pt t\,.
```

The length of the curve ``𝒞`` is given by

```math
s=\int_{t=a}^{t=b}\mathrm{d}\kern-0.5pt s=\int_a^b\sqrt{\left(\frac{\mathrm{d}\kern-0.5pt x}{\mathrm{d}\kern-0.5pt t}\right)^2+\left(\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt t}\right)^2}\mathrm{d}\kern-0.5pt t\,.
```

!!! example

	Find the length of the parametric curve

	```math
	x=\mathcal{e}^t\cos t\quad\textrm{and}\quad y=\mathcal{e}^t\sin t\,,\quad t\in \left[0, 2\right]\,.
	```

	We have

	```math
	\frac{\mathrm{d}\kern-0.5pt x}{\mathrm{d}\kern-0.5pt t}=\mathcal{e}^t\left(\cos t-\sin t\right)\quad\textrm{and}\quad\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt t}=\mathcal{e}^t\left(\sin t+\cos t\right)\,.
	```

	Squaring these formulas, adding and simplifying, we get

	```math
	\left(\frac{\mathrm{d}\kern-0.5pt s}{\mathrm{d}\kern-0.5pt t}\right)^2=\mathcal{e}^{2t}\left(\cos t-\sin t\right)^2+\mathcal{e}^{2t}\left(\sin t+\cos t\right)^2=2\mathcal{e}^{2t}\,.
	```

	The length of the curve is, therefore,

	```math
	s=\int_0^2\sqrt{2\mathcal{e}^{2t}}\,\mathrm{d}\kern-0.5pt t=\sqrt 2\int_0^2\mathcal{e}^t\,\mathrm{d}\kern-0.5pt t=\sqrt 2\left(\mathcal{e}^2-1\right)\ \textrm{units.}
	```

Parametric curves can be rotated around various axes to generate surfaces of revolution. The areas of these surfaces can be found by the same procedure used for graphs of functions, with the appropriate version of ``\mathrm{d}\kern-0.5pt s``. If the curve

```math
x=f\left(t\right)\quad\textrm{and}\quad y = g\left(t\right)\quad\textrm{for }a\le t\le b
```

is rotated about the ``x``-axis, the area ``S`` of the surface so generated is given by

```math
S=2\uppi\int_{t=a}^{t=b}\left|y\right|\mathrm{d}\kern-0.5pt s=2\uppi\int_a^b\left|g\left(t\right)\right|\sqrt{\left(f^\prime\left(t\right)\right)^2+\left(g^\prime\left(t\right)\right)^2} \,\mathrm{d}\kern-0.5pt t\,.
```

If the rotation is about the ``y``-axis, then the area is

```math
S=2\uppi\int_{t=a}^{t=b}\left|x\right|\mathrm{d}\kern-0.5pt s=2\uppi\int_a^b\left|f\left(t\right)\right|\sqrt{\left(f^\prime\left(t\right)\right)^2+\left(g^\prime\left(t\right)\right)^2} \,\mathrm{d}\kern-0.5pt t\,.
```

!!! example

	Find the area of the surface of revolution obtained by rotating the astroid curve 
	
	```math
	x=a\cos^3 t\quad\textrm{and}\quad y=a\sin^3 t\,,\quad\textrm{where }a&gt;0\,
	```

	about the ``x``-axis.

	{cell=chap display=false output=false}
	```julia
	Figure("", "An astroid.") do
		scale = 100
		Drawing(width=2.5scale, height=2.5scale) do
			xmid = 1.25scale
			ymid = 1.25scale
			axis_xy(2.5scale,2.5scale,xmid,ymid,scale,tuple(-1, 1),tuple(-1, 1); xs=("-a", "a"), ys=("-a", "a"))
			curve_xy(t->cos(t)^3, t->sin(t)^3, 0:0.01:2pi, tuple(), xmid, ymid, scale; arrow=false)
		end
	end
	```

	The curve is symmetric about both coordinate axes. The entire surface will be generated by rotating the upper half of the curve; in fact, we need only rotate the first quadrant part and multiply by ``2``. The first quadrant part of the curve corresponds to ``0\le t\le\frac{\uppi}{2}``. We have

	```math
	\frac{\mathrm{d}\kern-0.5pt x}{\mathrm{d}\kern-0.5pt t}=-3a\cos^2 t\sin t\quad\textrm{and}\quad\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt t}=3a\sin^2 t\cos t\,.
	```

	Accordingly, the arc length element is

	```math
	\mathrm{d}\kern-0.5pt s=3a\cos t\sin t\mathrm{d}\kern-0.5pt t\,.
	```

	Therefore, the required surface area is

	```math
	S = 2 \times 2\uppi\int_0^\frac{\uppi}{2}a\sin^3 t\,3a\cos t\sin t\mathrm{d}\kern-0.5pt t=\frac{12}{5}\uppi a\ \textrm{square units.}
	```

Consider the parametric curve ``𝒞`` with equations

```math
x=f\left(t\right)\quad\textrm{and}\quad y = g\left(t\right)\quad\textrm{for }a\le t\le b\,,
```

where ``f`` is differentiable and ``g`` is continuous on ``\left[a,b\right]``. For the moment, let us also assume that ``f^\prime\left(t\right)\ge 0`` and ``g\left(t\right)\ge 0`` on ``\left[a,b\right]``, so ``𝒞`` has no points below the ``x``-axis and is traversed from left to right as ``t`` increases from ``a`` to ``b``.

The region under ``C`` and above the ``x``-axis has area element given by

```math
\mathrm{d}\kern-0.5pt A = y\,\mathrm{d}\kern-0.5pt x=g\left(t\right)f^\prime\left(t\right)\,\mathrm{d}\kern-0.5pt t\,,
```

so its area is

```math
A=\int_a^b g\left(t\right)f^\prime\left(t\right)\,\mathrm{d}\kern-0.5pt t\,.
```

Similar arguments can be given for three other cases:

- if ``f^\prime\left(t\right)\ge 0`` and ``g\left(t\right)\le 0`` on ``\left[a,b\right]``, then ``\displaystyle A=-\int_a^b g\left(t\right)f^\prime\left(t\right)\,\mathrm{d}\kern-0.5pt t``,

- if ``f^\prime\left(t\right)\le 0`` and ``g\left(t\right)\ge 0`` on ``\left[a,b\right]``, then ``\displaystyle A=-\int_a^b g\left(t\right)f^\prime\left(t\right)\,\mathrm{d}\kern-0.5pt t``,

- if ``f^\prime\left(t\right)\le 0`` and ``g\left(t\right)\le 0`` on ``\left[a,b\right]``, then ``\displaystyle A=\int_a^b g\left(t\right)f^\prime\left(t\right)\,\mathrm{d}\kern-0.5pt t``,

where ``A``  is the (positive) area bounded by ``𝒞``, the ``x``-axis, and the vertical lines ``x=f\left(a\right)`` and ``x=f\left(b\right)``. Combining these results we can see that

```math
\int_a^b g\left(t\right)f^\prime\left(t\right)\,\mathrm{d}\kern-0.5pt t=A_1-A_2\,,
```

where ``A_1`` is the area lying vertically between ``𝒞`` and that part of the ``x``-axis consisting of points ``x=f\left(t\right)`` such that ``g\left(t\right)f^\prime\left(t\right)\ge 0``, and ``A_2`` is a similar area corresponding to points where ``g\left(t\right)f^\prime\left(t\right)&lt; 0``. This formula is valid for arbitrary continuous ``g`` and differentiable ``f``. In particular, if ``𝒞`` is a non–self-intersecting closed curve, then the area of the region bounded by ``𝒞`` is given by

```math
A=\begin{cases}
\hphantom{-}\int_a^b g\left(t\right)f^\prime\left(t\right)\,\mathrm{d}\kern-0.5pt t&\textrm{if }𝒞\textrm{ is traversed clockwise as }t\textrm{ increases,}\\
-\int_a^b g\left(t\right)f^\prime\left(t\right)\,\mathrm{d}\kern-0.5pt t&\textrm{if }𝒞\textrm{ is traversed counterclockwise.}
\end{cases}
```

!!! example

	Find the area bounded by the ellipse

	```math
	x=a\cos s\quad\textrm{and}\quad y=b\sin s\quad\textrm{for } 0\le s\le 2\uppi\,,\quad\textrm{where }a&gt;0, b&gt;0\,.
	```

	This ellipse is traversed counterclockwise. The area enclosed is

	```math
	\begin{aligned}
	A&=-\int_0^{2\uppi}b\sin s\left(-a\sin s\right)\,\mathrm{d}\kern-0.5pt s=\frac{ab}{2}\int_0^{2\uppi}\left(1-\cos 2s\right)\,\mathrm{d}\kern-0.5pt s\\
	&=\left.\frac{ab}{2}s\right|_0^{2\uppi}-\left.\frac{ab}{4}\sin 2s\right|_0^{2\uppi}=\uppi ab\ \textrm{square units.}
	\end{aligned}
	```

## Polar Coordinates and Polar Curves

The *polar coordinate system* is an alternative to the rectangular (Cartesian) coordinate system for describing the location of points in a plane. Sometimes it is more important to know how far, and in what direction, a point is from the origin than it is to know its Cartesian coordinates. In the polar coordinate system there is an origin (or *pole*), ``O``, and a *polar axis*, a ray (i.e., a half-line) extending from ``O`` horizontally to the right.

The position of any point ``P`` in the plane is then determined by its polar coordinates ``\left(r,\theta\right)_P``, where

1. ``r`` is the distance from ``O`` to ``P``, and

2. ``\theta`` is the angle that the ray ``OP`` makes with the polar axis (counterclockwise angles being considered positive).

The polar axis coincides with the positive ``x``-axis.

{cell=chap display=false output=false}
```julia
Figure("", "Polar coordinates.") do
	scale = 30
	Drawing(width=10scale, height=10scale) do
		xmid = 5scale
		ymid = 5scale
		for i in (1, 2, 3, 4, 5, 7, 8, 9, 10, 11)
			line(x1=xmid+4scale*cos(pi/12*i), y1=ymid-4scale*sin(pi/12*i), x2=xmid-4scale*cos(pi/12*i), y2=ymid+4scale*sin(pi/12*i), stroke="black", stroke_width=0.5)
		end
		for i in (1, 2, 3, 4)
			circle(cx=xmid, cy=ymid, r=i*scale, stroke="black", fill="none", stroke_width=0.5)
		end
		latex("\\frac{\\uppi}{12}", x=xmid+4scale*cos(pi/12)+5, y=ymid-4scale*sin(pi/12)-10, width=font_x, height=2font_y)
		latex("\\frac{\\uppi}{6}", x=xmid+4scale*cos(pi/6)+4, y=ymid-4scale*sin(pi/6)-12, width=font_x, height=2font_y)
		latex("\\frac{\\uppi}{4}", x=xmid+4scale*cos(pi/4)+2, y=ymid-4scale*sin(pi/4)-14, width=font_x, height=2font_y)
		latex("\\frac{\\uppi}{3}", x=xmid+4scale*cos(pi/3), y=ymid-4scale*sin(pi/3)-18, width=font_x, height=2font_y)
		latex("\\frac{5\\uppi}{12}", x=xmid+4scale*cos(5pi/12)-2, y=ymid-4scale*sin(5pi/12)-22, width=font_x, height=2font_y)
		axis_xy(10scale,10scale,xmid,ymid,scale,tuple(1, 2, 3, 4),tuple(); xs=("\\quad 1", "\\quad 2", "\\quad 3", "\\quad 4"))
		circle(cx=xmid+3scale*cos(pi/6), cy=ymid-3scale*sin(pi/6), r=3, stroke="red", fill="red")
		latex("\\left(3,\\frac{\\uppi}{6}\\right)_P", x=xmid+3scale*cos(pi/6)-20, y=ymid-3scale*sin(pi/6)-25, width=3font_x, height=2font_y)
	end
end
```

Unlike rectangular coordinates, the polar coordinates of a point are not unique. The polar coordinates ``\left(r,\theta_1\right)_P`` and ``\left(r,\theta_2\right)_P`` represent the same point provided ``\theta_1`` and ``\theta_2`` differ by an integer multiple of ``2\uppi``. For instance, the polar coordinates

```math
\left(3,\frac{\uppi}{6}\right)_P=\left(3,\frac{13\uppi}{6}\right)_P=\left(3,\frac{-11\uppi}{6}\right)_P=\left(-3,\frac{7\uppi}{6}\right)_P=\left(-3,\frac{-5\uppi}{6}\right)_P
```

all represent the same point with Cartesian coordinates ``\left(\frac{3\sqrt 3}{2}, \frac{3}{2}\right)``. In addition, the origin ``O`` has polar coordinates ``\left(0,\theta\right)_P`` for any value of ``\theta``. (If we go zero distance from ``O``, it doesn’t matter in what direction we go.)

If we want to consider both rectangular and polar coordinate systems in the same plane, and we choose the positive ``x``-axis as the polar axis, then the relationships between the rectangular coordinates of a point and its polar coordinates are

```math
\begin{cases}
x = r\cos\theta\\
y = r\sin\theta
\end{cases}
\quad\textrm{or}\quad
\begin{cases}
r^2 = x^2+y^2\\
\tan\theta = \frac{y}{x}
\end{cases}
```

A single equation in ``x`` and ``y`` generally represents a curve in the plane with respect to the Cartesian coordinate system. Similarly, a single equation in ``r`` and ``\theta`` generally represents a curve with respect to the polar coordinate system. The conversion formulas above can be used to convert one representation of a curve into the other.

!!! example

	Find the Cartesian equation of the curve represented by the polar equation ``r=2a\cos\theta``; hence, identify the curve.

	The polar equation can be transformed to Cartesian coordinates if we first multiply it by ``r``:

	```math
	\begin{aligned}
	r^2&=2ar\cos\theta\\
	x^2+y^2&=2ax\\
	\left(x-a\right)^2+y^2&=a^2
	\end{aligned}
	```

	The given polar equation ``r=2a\cos\theta`` thus represents a circle with centre ``\left(a, 0\right)`` and radius ``a``.

The graph of an equation of the form ``r=f\left(\theta\right)`` is called the polar graph of the function ``f``. Some polar graphs can be recognized easily if the polar equation is transformed to rectangular form. For others, this transformation does not help; the rectangular equation may be too complicated to be recognizable. In these cases one must resort to constructing a table of values and plotting points.

!!! example

	Sketch the polar curve ``r=a\left(1-\cos\theta\right)``, where ``a&gt;0``.

	Transformation to rectangular coordinates is not much help here; the resulting equation is ``\left(x^2+y^2+ax\right)^2=a^2\left(x^2+y^2\right)`` (verify this), which we do not recognize. Therefore, we will make a plot.

	{cell=chap display=false output=false}
	```julia
	Figure("", "A cardioid.") do
		scale = 20
		Drawing(width=12scale, height=12scale) do
			xmid = 6scale
			ymid = 6scale
			for i in (1, 2, 3, 4, 5, 7, 8, 9, 10, 11)
				line(x1=xmid+5scale*cos(pi/12*i), y1=ymid-5scale*sin(pi/12*i), x2=xmid-5scale*cos(pi/12*i), y2=ymid+5scale*sin(pi/12*i), stroke="black", stroke_width=0.5)
			end
			for i in (1, 2, 3, 4, 5)
				circle(cx=xmid, cy=ymid, r=i*scale, stroke="black", fill="none", stroke_width=0.5)
			end
			axis_xy(12scale,12scale,xmid,ymid,scale,tuple(2),tuple(); xs=tuple("\\ \\ a"))
			r = theta -> 2*(1-cos(theta))
			curve_xy(theta->r(theta)*cos(theta), theta->r(theta)*sin(theta), 0:0.01:2pi, tuple(), xmid, ymid, scale; arrow=false)
		end
	end
	```

	Because it is shaped like a heart, this curve is called a cardioid.

## Slopes, Areas, and Arc Lengths for Polar Curves

!!! theorem

	At any point ``P`` other than the origin on the polar curve ``r=f\left(\theta\right)``, the angle ``\psi`` between the radial line from the origin to ``P`` and the tangent to the curve is given by

	```math
	\tan\psi=\frac{f\left(\theta\right)}{f^\prime\left(\theta\right)}\,.
	```

	In particular, ``\psi=\frac{\uppi}{2}`` if ``f^\prime\left(\theta\right)=0``. If ``f\left(\theta_0\right)=0`` and the curve has a tangent line at ``\theta_0``, then that tangent line has equation ``\theta=\theta_0``.

!!! proof

	The curve ``𝒞`` with equations

	```math
	x=g\left(\theta\right)=r\left(\theta\right)\cos\theta\quad\textrm{and}\quad y = h\left(\theta\right)=r\left(\theta\right)\sin\theta\quad\textrm{having parameter }\theta\,,
	```

	has a tangent with slope

	```math
	\begin{aligned}
	\tan\phi&=\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}=\frac{h^\prime\left(\theta\right)}{g^\prime\left(\theta\right)}=\frac{r^\prime\left(\theta\right)\sin\theta+r\left(\theta\right)\cos\theta}{r^\prime\left(\theta\right)\cos\theta-r\left(\theta\right)\sin\theta}\\
	&=\frac{r^\prime\left(\theta\right)\tan\theta+r\left(\theta\right)}{r^\prime\left(\theta\right)-r\tan\theta}=\frac{\tan\theta+\frac{r\left(\theta\right)}{r^\prime\left(\theta\right)}}{1-\frac{r\left(\theta\right)}{r^\prime\left(\theta\right)}\tan\theta}\,.
	\end{aligned}
	```

	{cell=chap display=false output=false}
	```julia
	Figure("", tex("\\psi+\\theta=\\phi+\\uppi\\,.")) do
		scale = 50
		Drawing(width=2.5scale, height=2.5scale) do
			defs() do
				marker(id="arrow", markerWidth="6", markerHeight="6", refX="3", refY="3", orient="auto") do
					path(d="M 0 0 L 6 3 L 0 6 z", fill="black" )
				end
			end
			xmid = 0.5scale
			ymid = 2scale
			axis_xy(2.5scale,2.5scale,xmid,ymid,scale,tuple(),tuple())
			f = x->0.25(x+0.5)^2+0.75
			ff = x->0.5(x+0.5)
			x0 = 0.75
			r = 0.3
			m1 = ff(x0)
			m2 = f(x0)/x0
			plot_xy(f, -0.5:0.01:2, tuple(x0), xmid, ymid, scale; width=1)
			plot_xy(x->f(x0)+(x-x0)*m1, -0.5:0.01:2, tuple(), xmid, ymid, scale; width=1, color="RoyalBlue")
			plot_xy(x->x*m2, -0.5:0.01:2, tuple(), xmid, ymid, scale; width=1, color="green")
			plot_xy(x->f(x0), x0:0.01:2, tuple(), xmid, ymid, scale; width=0.5, color="black")
			x1 = x0+1.5r
			x1tris = x0+3r
			x2 = x0+r*cos(atan(m2))
			x2bis = x0+1.5r*cos(atan(m2))
			x3 = x0-r*cos(atan(m1))
			x3tris = x0+3r*cos(atan(m1))
			path(d="M $(x2*scale+xmid), $(ymid-(x2/x0*f(x0))*scale) A $(r*scale) $(r*scale) 0 0 0 $(x3*scale+xmid-1), $(ymid-2-(f(x0)+(x3-x0)*ff(x0))*scale)", stroke="black", fill="none", marker_end="url(#arrow)")
			path(d="M $(x1*scale+xmid), $(ymid-f(x0)*scale) A $(1.5r*scale) $(1.5r*scale) 0 0 0 $(x2bis*scale+xmid+2), $(ymid-(x2bis/x0*f(x0))*scale+1)", stroke="black", fill="none", marker_end="url(#arrow)")
			path(d="M $(x1tris*scale+xmid), $(ymid-f(x0)*scale) A $(3r*scale) $(3r*scale) 0 0 0 $(x3tris*scale+xmid+1), $(ymid-(f(x0)+(x3tris-x0)*ff(x0))*scale+3)", stroke="black", fill="none", marker_end="url(#arrow)")
			latex("\\psi", x=xmid+scale*0.4, y=ymid-scale*1.75, width=font_x, height=font_y)
			latex("\\theta", x=xmid+scale*1.2, y=ymid-scale*1.5, width=font_x, height=font_y)
			latex("\\phi", x=xmid+scale*1.7, y=ymid-scale*1.6, width=font_x, height=font_y)
		end
	end
	```

	The figure shows the relation between ``\theta``, ``\psi`` and ``\phi``, the angle between the tangent to the curve at ``P`` and the ``x``-axis

	```math
	\psi+\theta=\phi+\uppi\,,
	```

	so,

	```math
	\begin{aligned}
	\tan\left(\psi+\theta\right)&=\tan\left(\phi+\uppi\right)=\tan\left(\phi\right)\\
	\frac{\tan\psi+\tan\theta}{1-\tan\psi\tan\theta}&=\frac{\frac{r\left(\theta\right)}{r^\prime\left(\theta\right)}+\tan\theta}{1-\frac{r\left(\theta\right)}{r^\prime\left(\theta\right)}\tan\theta}\,.
	\end{aligned}
	```

	Therefore,

	```math
	\tan\psi=\frac{r\left(\theta\right)}{r^\prime\left(\theta\right)}\,.
	```

The basic area problem in polar coordinates is that of finding the area ``A`` of the region ``R`` bounded by the polar graph ``r=f\left(\theta\right)`` and the two rays ``\theta=\alpha`` and ``\theta=\beta``. We assume that ``\beta&gt;\alpha`` and that ``f`` is continuous for ``\alpha\le\theta\le\beta``.

A suitable area element in this case is a sector of angular width ``\mathrm{d}\kern-0.5pt \theta``. For infinitesimal ``\mathrm{d}\kern-0.5pt \theta`` this is just a sector of a circle of radius ``r=f\left(\theta\right)``:

```math
\mathrm{d}\kern-0.5pt A=r^2\uppi\frac{1}{2\uppi}\,\mathrm{d}\kern-0.5pt\theta=\frac{1}{2}r^2\,\mathrm{d}\kern-0.5pt\theta=\frac{1}{2}\left(f\left(\theta\right)\right)^2\,\mathrm{d}\kern-0.5pt\theta\,.
```

!!! theorem

	The region bounded by ``r=f\left(\theta\right)`` and two rays ``\theta=\alpha`` and ``\theta=\beta``, ``\beta&gt;\alpha``, has area

	```math
	A=\frac{1}{2}\int_\alpha^\beta\left(f\left(\theta\right)\right)^2\,\mathrm{d}\kern-0.5pt\theta\,.
	```

!!! example

	Find the area of the region that lies inside the circle ``r=\sqrt2\sin\theta`` and inside the *lemniscate* ``r^2=\sin2\theta``.

	{cell=chap display=false output=false}
	```julia
	Figure("", "The area between two polar curves.") do
		scale = 60
		Drawing(width=2.5scale, height=3scale) do
			xmid = 1scale
			ymid = 2scale
			axis_xy(2.5scale,3scale,xmid,ymid,scale,tuple(),tuple())
			r1 = theta -> sqrt(2)*sin(theta)
			r2 = theta -> sqrt(sin(2theta))
			path = mapreduce(elem->"$(elem[1]), $(elem[2]) ", *, zip(xmid .+ scale*(r1.(0:0.01:pi/4).*cos.(0:0.01:pi/4)), ymid .- scale * r1.(0:0.01:pi/4).*sin.(0:0.01:pi/4))) * mapreduce(elem->"$(elem[1]), $(elem[2]) ", *, zip(xmid .+ scale*(r2.(pi/4:0.01:pi/2).*cos.(pi/4:0.01:pi/2)), ymid .- scale * r2.(pi/4:0.01:pi/2).*sin.(pi/4:0.01:pi/2)))
			polygon(points=path, fill="lightblue", stroke="none")
			curve_xy(theta->r1(theta)*cos(theta), theta->r1(theta)*sin(theta), 0:0.01:pi, tuple(), xmid, ymid, scale; arrow=false)
			curve_xy(theta->r2(theta)*cos(theta), theta->r2(theta)*sin(theta), 0:0.01:pi/2, tuple(), xmid, ymid, scale; arrow=false, color="green")
			curve_xy(theta->r2(theta)*cos(theta), theta->r2(theta)*sin(theta), pi+0.01:0.01:3pi/2, tuple(), xmid, ymid, scale; arrow=false, color="green")
			plot_xy(x->x, 0:0.01:1, tuple(), xmid, ymid, scale; color="black", dashed="1")
			latex("\\frac{\\uppi}{4}", x=xmid+1scale, y=ymid-1.25scale, width=font_x, height=2font_y)
		end
	end
	```

	The region is shaded in the figure. Besides intersecting at the origin, the curves intersect at the first quadrant point satisfying

	```math
	2\sin^2\theta=\sin2\theta=2\sin\theta\cos\theta\,.
	```

	Thus, ``\sin\theta=\cos\theta`` and ``\theta=\frac{\uppi}{4}``. The required area is

	```math
	\begin{aligned}
	A&=\frac{1}{2}\int_0^\frac{\uppi}{4}2\sin^2\theta\,\mathrm{d}\kern-0.5pt \theta+\frac{1}{2}\int_\frac{\uppi}{4}^\frac{\uppi}{2}2\sin2\theta\,\mathrm{d}\kern-0.5pt \theta\\
	&=\int_0^\frac{\uppi}{4}\frac{1-\cos2\theta}{2}\,\mathrm{d}\kern-0.5pt \theta-\left.\frac{1}{4}\cos2\theta\right|_\frac{\uppi}{4}^\frac{\uppi}{2}\\
	&= \frac{\uppi}{8}-\left.\frac{1}{4}\sin2\theta\right|_0^\frac{\uppi}{4}+\frac{1}{4}=\frac{\uppi}{8}-\frac{1}{4}+\frac{1}{4}=\frac{\uppi}{8}\ \textrm{square units.}
	\end{aligned}
	```

The arc length element for the polar curve ``r=f\left(\theta\right)`` can be derived from that for a parametric curve.

The curve ``𝒞`` with equations

```math
x=g\left(\theta\right)=r\left(\theta\right)\cos\theta\quad\textrm{and}\quad y = h\left(\theta\right)=r\left(\theta\right)\sin\theta\quad\textrm{having parameter }\theta\,,
```

has differential arc length element

```math
\begin{aligned}
\mathrm{d}\kern-0.5pt s&=\sqrt{\left(\mathrm{d}\kern-0.5pt x\right)^2+\left(\mathrm{d}\kern-0.5pt y\right)^2}=\sqrt{\left(g^\prime\left(\theta\right)\mathrm{d}\kern-0.5pt \theta\right)^2+\left(h^\prime\left(\theta\right)\mathrm{d}\kern-0.5pt \theta\right)^2}\\
&=\sqrt{\left(r^\prime\left(\theta\right)\cos\theta-r\left(\theta\right)\sin\theta\right)^2+\left(r^\prime\left(\theta\right)\sin\theta+r\left(\theta\right)\cos\theta\right)^2}\,\mathrm{d}\kern-0.5pt \theta\\
&=\sqrt{\left(r^\prime\left(\theta\right)\right)^2+\left(r\left(\theta\right)\right)^2}\,\mathrm{d}\kern-0.5pt \theta\,.
\end{aligned}
```

The length of the curve ``𝒞`` for ``\theta`` between ``\alpha`` and ``\beta`` is then given by

```math
s = \int_\alpha^\beta \sqrt{\left(r^\prime\left(\theta\right)\right)^2+\left(r\left(\theta\right)\right)^2}\,\mathrm{d}\kern-0.5pt \theta\,.
```

!!! example

	Find the total length of the cardioid ``r=a\left(1+\cos\theta\right)``.

	{cell=chap display=false output=false}
	```julia
	Figure("", "Another cardioid.") do
		scale = 20
		Drawing(width=12scale, height=12scale) do
			xmid = 6scale
			ymid = 6scale
			for i in (1, 2, 3, 4, 5, 7, 8, 9, 10, 11)
				line(x1=xmid+5scale*cos(pi/12*i), y1=ymid-5scale*sin(pi/12*i), x2=xmid-5scale*cos(pi/12*i), y2=ymid+5scale*sin(pi/12*i), stroke="black", stroke_width=0.5)
			end
			for i in (1, 2, 3, 4, 5)
				circle(cx=xmid, cy=ymid, r=i*scale, stroke="black", fill="none", stroke_width=0.5)
			end
			axis_xy(12scale,12scale,xmid,ymid,scale,tuple(2, 4),tuple(); xs=tuple("\\ \\ a", "\\quad 2a"))
			r = theta -> 2*(1+cos(theta))
			curve_xy(theta->r(theta)*cos(theta), theta->r(theta)*sin(theta), 0:0.01:2pi, tuple(), xmid, ymid, scale; arrow=false)
		end
	end
	```

	The total length is twice the length from ``\theta=0`` to ``\theta=\uppi``. See figure.

	Since ``r^\prime\left(\theta\right)=-a\sin\theta``, the arc length is

	```math
	\begin{aligned}
	s&=2\int_0^\uppi\sqrt{a^2\sin^2\theta+a^2\left(1+\cos\theta\right)}\,\mathrm{d}\kern-0.5pt \theta\\
	&=2\int_0^\uppi\sqrt{2a^2+a^2\cos\theta}\,\mathrm{d}\kern-0.5pt \theta\quad\textrm{but }1+\cos\theta=2\cos^2\left(\frac{\theta}{2}\right)\\
	&= 2\sqrt 2a\int_0^\uppi\sqrt{2\cos^2\left(\frac{\theta}{2}\right)}\,\mathrm{d}\kern-0.5pt \theta\\
	&= 4a\int_0^\uppi\cos\left(\frac{\theta}{2}\right)\,\mathrm{d}\kern-0.5pt \theta=\left.8a\sin\left(\frac{\theta}{2}\right)\right|_0^\uppi=8a\ \textrm{units.}
	\end{aligned}
	```
