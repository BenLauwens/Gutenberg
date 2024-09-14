{data-type="chapter"}
# Differentiation

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

function axis_xy(width::Number, height::Number, Ox::Number, Oy::Number, scale::Number, axis_x, axis_y; xs=nothing, ys=nothing, xl=nothing, yl=nothing, xh=nothing, yh=nothing, shift_x=0, shift_y=0)
	defs() do
		marker(id="arrow", markerWidth="6", markerHeight="6", refX="3", refY="3", orient="auto") do
			path(d="M 0 0 L 6 3 L 0 6 z", fill="black" )
		end
	end
	latex("O", x=Ox-font_x-2, y=Oy, width=font_x, height=font_y)
	latex("x", x=shift_x+width-font_x-2, y=Oy-font_y-2, width=font_x, height=font_y)
	latex("y", x=Ox+2, y=shift_y-2, width=font_x, height=font_y)
	line(x1=shift_x, y1=Oy, x2=shift_x+width-3, y2=Oy, stroke="black", marker_end="url(#arrow)")
	for (nr, n) in enumerate(axis_x)
		line(x1=Ox+scale*n, y1=Oy-3, x2=Ox+scale*n, y2=Oy+3, stroke="black")
		txt = if xs===nothing "$n" else "$(xs[nr])" end
		len = if xl===nothing length(txt) else xl[nr] end
		h = if xh===nothing 1 else xh[nr] end
		latex(txt, x=Ox+scale*n-font_x*len/2, y=Oy, width=font_x*len, height=font_y*h)
	end
	line(x1=Ox, y1=shift_y+height, x2=Ox, y2=shift_y+3, stroke="black", marker_end="url(#arrow)")
	for (nr, n) in enumerate(axis_y)
		line(x1=Ox-3, y1=Oy-scale*n, x2=Ox+3, y2=Oy-scale*n, stroke="black")
		txt = if ys===nothing "$n" else "$(ys[nr])" end
		len = if yl===nothing length(txt) else yl[nr] end
		h = if yh===nothing 1 else xh[nr] end
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

The first of the fundamental problems that are considered in calculus, is the problem of slopes, that is finding the slope of (the tangent line to) a given curve at a given point on the curve. The solution of the problem of slopes is the subject of differential calculus. As we will see, it has many applications in mathematics and other disciplines.

## Tangent Lines and their Slopes

This section deals with the problem of finding a straight line ``L`` that is tangent to a curve ``C`` at a point ``P``. As is often the case in mathematics, the most important step in the solution of such a fundamental problem is making a suitable definition.

For simplicity, and to avoid certain problems best postponed until later, we will not deal with the most general kinds of curves now, but only with those that are the graphs of continuous functions. Let ``C`` be the graph of ``y=f\left(x\right)`` and let ``P`` be the point ``\left(x_0,y_0\right)`` on ``C``, so that ``y_0=f\left(x_0\right)``. We assume that ``P`` is not an endpoint of ``C``. Therefore, ``C`` extends some distance on both sides of ``P``.

What do we mean when we say that the line ``L`` is tangent to ``C`` at ``P``?

A reasonable definition of tangency can be stated in terms of limits. If ``Q`` is a point on ``C`` different from ``P``, then the line through ``P`` and ``Q`` is called a secant line to the curve. This line rotates around ``P`` as ``Q`` moves along the curve. If ``L`` is a line through ``P`` whose slope is the limit of the slopes of these secant lines ``PQ`` as ``Q`` approaches ``P`` along ``C``, then we will say that ``L`` is tangent to ``C`` at ``P``.

{cell=chap display=false output=false}
```julia
Figure("", "Secant lines " * tex("PQ") * " approach tangent line " * tex("L") * " as " * tex("Q") * " approaches " * tex("P") * " along the curve " * tex("C") * "." ) do
    scale = 40
    Drawing(width=6scale, height=5.5scale) do
        xmid = 1scale
        ymid = 5scale
        f = x->-0.5(x-2)^2+3
		x0 = 1.5
		fx0 = f(x0)
		x = 4
		fx = f(x)
        axis_xy(6scale,5.5scale,xmid,ymid,scale,(x0, x),tuple(), xs=("x_0","x_0+h"))
        plot_xy(f, -1:0.01:5.5, (1.5,), xmid, ymid, scale, width=1)
        circle(cx=xmid+x*scale, cy=ymid-fx*scale, r=3, fill="RoyalBlue", stroke="RoyalBlue")
		for y in 0:0.5:2.5
			m = (fx0 - fx - y) / (x0 - x)
			plot_xy(x->m*(x-x0)+fx0, -1:0.01:5.5, tuple(), xmid, ymid, scale, width=0.5, color = "black")
			D = sqrt((2-m)^2+2*(1-fx0+1.5m))
			x1 = 2-m+D
			fx1 = f(x1)
			circle(cx=xmid+scale*x1, cy=ymid-scale*fx1, r=2, fill="RoyalBlue", stroke="RoyalBlue")
		end
		m = -(x0-2)
		plot_xy(x->m*(x-x0)+fx0, -1:0.01:5.5, tuple(), xmid, ymid, scale, width=1, color = "green")
		line(x1=xmid+x0*scale, y1=ymid-fx0*scale, x2=xmid+x0*scale, y2=ymid, stroke="black", stroke_dasharray = "3")
		line(x1=xmid+x*scale, y1=ymid-fx*scale, x2=xmid+x*scale, y2=ymid, stroke="black", stroke_dasharray = "3")
		latex("C", x=xmid+0.5scale, y=ymid-2scale, width=font_x, height=font_y)
		latex("y=f\\left(x\\right)", x=xmid+0.25scale, y=ymid-1.5scale, width=4font_x, height=font_y)
		latex("P", x=xmid+x0*scale-0.5font_x, y=ymid-fx0*scale-1.25font_y, width=font_x, height=font_y)
		latex("Q", x=xmid+x*scale, y=ymid-fx*scale-font_y, width=font_x, height=font_y)
		latex("L", x=xmid+x*scale, y=ymid-4.75scale, width=font_x, height=font_y)
    end
end
```

Since ``C`` is the graph of the function ``y=\left(x\right)``, then vertical lines can meet ``C`` only once. Since ``P=\left(x_0,y_0\right)``, a different point ``Q`` on the graph must have a different ``x``-coordinate, say ``x_0+h``, where ``h\ne0``. Thus ``Q=\left(x_0+h,f\left(x_0+h\right)\right)``, and the slope of the line ``PQ`` is

```math
\frac{f\left(x_0+h\right)-f\left(x\right)}{h}\,.
```

This expression is called the *Newton quotient* or *difference quotient* for ``f`` at ``x_0``. Note that ``h`` can be positive or negative, depending on whether ``Q`` is to the right or left of ``P``.

!!! definition "Nonvertical tangent lines"
	Suppose that the function ``f`` is continuous at ``x = x_0`` and that
	```math
	\lim_{h\to 0} \frac{f\left(x_0+h\right)-f\left(x_0\right)}{h}=m
	```
	exists. Then the straight line having slope ``m`` and passing through the point ``P=\left(x_0,f\left(x_0\right)\right)`` is called the *tangent line* (or simply the *tangent*) to the graph of ``y=f\left(x\right)`` at ``P``. An equation of this tangent is
	```math
	y=m\left(x-x_0\right)+y_0\,,
	```
	where ``y_0=f\left(x_0\right)``.

!!! example
	Find an equation of the tangent line to the curve ``y=x^2`` at the point ``\left(1,1\right)``.

	Here ``f\left(x\right)=x^2``, ``x_0=1``, and ``y_0=f\left(1\right)=1``. The slope of the required tangent is
	```math
	\begin{aligned}
	m = \lim_{h\to 0}\frac{f\left(1+h\right)-f\left(1\right)}{h}&=\lim_{h\to 0}\frac{\left(1+h\right)^2-1}{h}\\
	&=\lim_{h\to 0}\frac{1+2h+h^2-1}{h}\\
	&=\lim_{h\to 0}\frac{2h+h^2}{h}=\lim_{h\to 0}\left(2+h\right)=2\,.
	\end{aligned}
	```
	Accordingly, the equation of the tangent line at ``\left(1,1\right)`` is ``y=2\left(x-1\right)+1``, or ``y=2x-1``.

This definition deals only with tangents that have finite slopes and are, therefore, not vertical. It is also possible for the graph of a function to have a *vertical* tangent line.

!!! example
	Consider the graph of the function ``f\left(x\right)=\sqrt[3]{x}=x^\frac{1}{3}``, which is shown below. 
	
	{cell=chap display=false output=false}
	```julia
	Figure("", "The  " * tex("y") * "-axis is tangent to " * tex("y=x^\\frac{1}{3}") * " at the origin." ) do
		scale = 40
		Drawing(width=4scale, height=3scale) do
			xmid = 2scale
			ymid = 1.5scale
			f = x->cbrt(x)
			axis_xy(4scale,3scale,xmid,ymid,scale,tuple(),tuple())
			plot_xy(f, -2:0.01:2, tuple(), xmid, ymid, scale, width=1)
		end
	end
	```

	The graph is a smooth curve, and it seems evident that the ``y``-axis is tangent to this curve at the origin. Let us try to calculate the limit of the Newton quotient for ``f`` at ``x=0``:

	```math
	\lim_{h\to 0}\frac{f\left(0+h\right)-f\left(0\right)}{h}=\lim_{h\to 0}\frac{h^\frac{1}{3}}{h}=\lim_{h\to 0}\frac{1}{h^\frac{2}{3}}=\infty\,.
	```

	Although the limit does not exist, the slope of the secant line joining the origin to another point ``Q`` on the curve approaches infinity as ``Q`` approaches the origin from either side.

We extend the definition of tangent line to allow for vertical tangents as follows:

!!! definition "Vertical tangents"
	If ``f`` is continuous at ``P=\left(x_0,f\left(x_0\right)\right)``, where ``y_0=f\left(x_0\right)``, and if either
	```math
	\lim_{h\to 0} \frac{f\left(x_0+h\right)-f\left(x_0\right)}{h}=\infty\quad\textrm{or}\quad\lim_{h\to 0} \frac{f\left(x_0+h\right)-f\left(x_0\right)}{h}=-\infty
	```
	then the vertical line ``x=x0`` is tangent to the graph ``y=f\left(x\right)`` at ``P``. If the limit of the Newton quotient fails to exist in any other way than by being ``\infty`` or ``-\infty``, the graph ``y=f\left(x\right)`` has no tangent line at ``P``.

!!! example
	Does the graph of ``y=\left|x\right|`` have a tangent line at ``x=0``?

	The Newton quotient here is
	```math
	\frac{\left|0+h\right|-\left|0\right|}{h}=\frac{\left|h\right|}{h}=\operatorname{sgn}\left(h\right)=\begin{cases}
	\hphantom{-}1\,,&\textrm{if } h&gt;0\\
	-1\,,&\textrm{if } h&lt;0\,.
	\end{cases}
	```

	Since ``\operatorname{sgn}\left(h\right)`` has different right and left limits at ``0`` (namely, ``1`` and ``-1``), the Newton quotient has no limit as ``h\to 0``, so ``y=\left|x\right|`` has no tangent line at ``\left(0,0\right)``.

Curves have tangents only at points where they are smooth.

!!! definition
	The slope of a curve ``C`` at a point ``P`` is the slope of the tangent line to ``C`` at ``P`` if such a tangent line exists. In particular, the slope of the graph of ``y=\left(x\right)`` at the point ``x_0`` is
	```math
	\lim_{h\to 0} \frac{f\left(x_0+h\right)-f\left(x_0\right)}{h}\,.
	```

!!! example
	Find the slope of the curve ``\displaystyle y=\frac{x}{3x+2}`` at the point ``x=-2``.

	If ``x=-2``, then ``y=\frac{1}{2}``, so the required slope is
	```math
	\begin{aligned}
	m &= \lim_{h\to 0}\frac{\frac{-2+h}{3\left(-2+h\right)+2}-\frac{1}{2}}{h}\\
	&= \lim_{h\to 0}\frac{-4+2h-\left(-6+3h+2\right)}{2\left(-6+3h+2\right)h}\\
	&=\lim_{h\to 0}\frac{-h}{2h\left(-4+3h\right)}=\lim_{h\to 0}\frac{-1}{2h\left(-4+3h\right)}=\frac{1}{8}
	\end{aligned}
	```

If a curve ``C`` has a tangent line ``L`` at point ``P``, then the straight line ``N`` through ``P`` perpendicular to ``L`` is called the *normal* to ``C`` at ``P``. If ``L`` is horizontal, then ``N`` is vertical; if ``L`` is vertical, then ``N`` is horizontal. If ``L`` is neither horizontal nor vertical, then the slope of ``N`` is the negative reciprocal of the slope of ``L``; that is,

```math
\textrm{slope of the normal}=\frac{-1}{\textrm{slope of the tangent}}
```

!!! example
	Find equations of the straight lines that are tangent and normal to the curve ``y=\sqrt x`` at the point ``\left(4,2\right)``.

	{cell=chap display=false output=false}
	```julia
	Figure("", "The tangent (blue) and normal (green) to " * tex("y=\\sqrt x") * " at " * tex("\\left(4,2\\right)") * "." ) do
		scale = 40
		Drawing(width=8scale, height=3.5scale) do
			xmid = 0.5scale
			ymid = 3scale
			f = x->sqrt(x)
			axis_xy(8scale,3.5scale,xmid,ymid,scale,(4,),(2,))
			plot_xy(f, 0:0.01:7.5, (4, ), xmid, ymid, scale, width=1)
			plot_xy(x->1+x/4, -0.5:0.01:7.5, tuple(), xmid, ymid, scale, width=1, color="RoyalBlue")
			plot_xy(x->18-4x, -0.5:0.01:7.5, tuple(), xmid, ymid, scale, width=1, color="green")
			line(x1=xmid+4*scale, y1=ymid-2*scale, x2=xmid+4*scale, y2=ymid, stroke="black", stroke_dasharray = "3")
			line(x1=xmid+4*scale, y1=ymid-2*scale, x2=xmid, y2=ymid-2*scale, stroke="black", stroke_dasharray = "3")
		end
	end
	```

	The slope of the tangent at ``\left(4,2\right)`` is

	```math
	\begin{aligned}
	m=\lim_{h\to 0}\frac{\sqrt{4+h}-2}{h}&=\lim_{h\to 0}\frac{\left(\sqrt{4+h}-2\right)\left(\sqrt{4+h}+2\right)}{h\left(\sqrt{4+h}+2\right)}\\
	&=\lim_{h\to 0}\frac{4+h-4}{h\left(\sqrt{4+h}+2\right)}\\
	&=\lim_{h\to 0}\frac{1}{\sqrt{4+h}+2}=\frac{1}{4}
	\end{aligned}
	```

	The tangent line has equations

	```math
	y=\frac{1}{4}\left(x-4\right)+2\quad\textrm{or}\quad x-4y+4=0
	```

	and the normal has slope ``-4`` and, therefore, equation

	```math
	y=-4\left(x-4\right)+2\quad\textrm{or}\quad 4x+y-18=0
	```

## The Derivative

A straight line has the property that its slope is the same at all points. For any other graph, however, the slope may vary from point to point. Thus, the slope of the graph of ``y=f\left(x\right)`` at the point ``x`` is itself a function of ``x``. At any point ``x`` where the graph has a finite slope, we say that ``f`` is *differentiable*, and we call the slope the *derivative* of ``f``: The derivative is therefore the limit of the Newton quotient.

!!! definition
	The derivative of a function ``f`` is another function ``f\prime`` defined by
	```math
	f\prime\left(x\right)=\lim_{h\to 0}\frac{f\left(x+h\right)-f\left(x\right)}{h}
	```
	at all points ``x`` for which the limit exists (i.e., is a finite real number). If ``f\prime`` exists, we say that ``f`` is differentiable at ``x``.

The domain of the derivative ``f\prime`` (read “``f`` prime”) is the set of numbers ``x`` in the domain of ``f`` where the graph of ``f`` has a nonvertical tangent line, and the value ``f\prime\left(x_0\right)`` of ``f\prime`` at such a point ``x_0`` is the slope of the tangent line to ``y=f\left(x\right)`` there. Thus, the equation of the tangent line to ``y=\left(x\right)`` at ``f\left(x_0\right)`` is

```math
y=f\left(x_0\right)+f\prime\left(x_0\right)\left(x-x_0\right)
```

The domain ``f\prime`` may be smaller than the domain of ``f`` because it contains only those points in the domain of ``f`` at which ``f`` is differentiable. Values of ``x`` in the domain of ``f`` where ``f`` is not differentiable and that are not endpoints of the domain of ``f`` are *singular points* of ``f``.

The value of the derivative of ``f`` at a particular point ``x_0`` can be expressed as a limit in either of two ways:

```math
f\prime\left(x_0\right)=\lim_{h\to 0}\frac{f\left(x_0+h\right)-f\left(x_0\right)}{h}=\lim_{x\to x_0}\frac{f\left(x\right)-f\left(x_0\right)}{x-x_0}
```
In the second limit ``x_0+h`` is replaced by ``x``, so that ``h=x-x_0`` and ``h\to 0`` is equivalent to ``x\to x_0``.

The process of calculating the derivative ``f\prime`` of a given function ``f`` is called *differentiation*.

{cell=chap display=false output=false}
```julia
Figure("", "Graphical differentiation." ) do
	scale = 40
	Drawing(width=13scale, height=9scale) do
		xmid = 3scale
		ymid = 2scale
		axis_xy(6scale,4scale,xmid,ymid,scale,(-1,1),(-1,1))
		plot_xy(x->-x-2, -2:0.01:-1, tuple(), xmid, ymid, scale, width=1)
		plot_xy(x->x, -1:0.01:1, tuple(), xmid, ymid, scale, width=1)
		plot_xy(x->-x+2, 1:0.01:2, tuple(), xmid, ymid, scale, width=1)
		xmid = 10scale
		ymid = 2scale
		axis_xy(6scale,4scale,xmid,ymid,scale,(-1,1),(-1,1), shift_x=7scale)
		plot_xy(x->-sin(x), -3:0.01:3, tuple(-1, 1), xmid, ymid, scale, width=1)
		plot_xy(x->-cos(-1)*(x+1)-sin(-1), -2:0.01:0, tuple(), xmid, ymid, scale, width=1, color="RoyalBlue")
		plot_xy(x->-cos(1)*(x-1)-sin(1), 0:0.01:2, tuple(), xmid, ymid, scale, width=1, color="RoyalBlue")
		xmid = 3scale
		ymid = 7scale
		axis_xy(6scale,4scale,xmid,ymid,scale,(-1,1),(-1,1), shift_y=5scale)
		plot_xy(x->-1, -2:0.01:-1, tuple(), xmid, ymid, scale, width=1)
		plot_xy(x->1, -1:0.01:1, tuple(), xmid, ymid, scale, width=1)
		plot_xy(x->-1, 1:0.01:2, tuple(), xmid, ymid, scale, width=1)
		circle(cx=xmid-scale, cy=ymid-scale, fill="white", stroke="red", r=3)
		circle(cx=xmid-scale, cy=ymid+scale, fill="white", stroke="red", r=3)
		circle(cx=xmid+scale, cy=ymid-scale, fill="white", stroke="red", r=3)
		circle(cx=xmid+scale, cy=ymid+scale, fill="white", stroke="red", r=3)
		xmid = 10scale
		ymid = 7scale
		axis_xy(6scale,4scale,xmid,ymid,scale,(-1,1),(-1,1), shift_x=7scale, shift_y=5scale)
		plot_xy(x->-cos(x), -3:0.01:3, tuple(-1, 1), xmid, ymid, scale, width=1)
		line(x1=2scale, y1=0, x2=2scale, y2=9scale, stroke="black", stroke_dasharray = "3")
		line(x1=4scale, y1=0, x2=4scale, y2=9scale, stroke="black", stroke_dasharray = "3")
		line(x1=9scale, y1=0, x2=9scale, y2=9scale, stroke="black", stroke_dasharray = "3")
		line(x1=11scale, y1=0, x2=11scale, y2=9scale, stroke="black", stroke_dasharray = "3")
		line(x1=9scale, y1=7scale+cos(-1)*scale, x2=9scale, y2=7scale, stroke="RoyalBlue")
		line(x1=11scale, y1=7scale+cos(1)*scale, x2=11scale, y2=7scale, stroke="RoyalBlue")
	end
end
```

A function is differentiable on a set ``S`` if it is differentiable at every point ``x`` in ``S``. Typically, the functions we encounter are defined on intervals or unions of intervals. If ``f`` is defined on a closed interval ``\left[a,b\right]``, the definition does not allow for the existence of a derivative at the endpoints ``x=a`` or ``x=b``. (Why?) As we did for continuity, we extend the definition to allow for a right derivative at ``x=a`` and a left derivative at ``x=b``:

```math
f_+^\prime\left(a\right)=\lim_{h\to 0^+}\frac{f\left(a+h\right)-f\left(x\right)}{h}\,,\quad f_-^\prime\left(b\right)=\lim_{h\to 0^-}\frac{f\left(b+h\right)-f\left(x\right)}{h}\,.
```

We now say that ``f`` is differentiable on ``\left[a,b\right]`` if ``f\prime\left(x\right)`` exists for all ``x\in\left[a,b\right]`` and ``f_+^\prime\left(a\right)`` and ``f_-^\prime\left(b\right)`` both exist.

!!! example
	Show that if ``f\left(x\right)=ax+b``, then ``f\prime\left(x\right)=a``.

	The result is apparent from the graph of f, but we will do the calculation using the definition:

	```math
	\begin{aligned}
	f\prime\left(x\right)&=\lim_{h\to 0}\frac{f\left(x+h\right)-f\left(x\right)}{h}\\
	&=\lim_{h\to 0}\frac{a\left(x+h\right)+b-\left(ax+b\right)}{h}\\
	&=\lim_{h\to 0}\frac{ah}{h}=a\,.
	\end{aligned}
	```

An important special case of this example says that the derivative of a constant function is the zero function: If ``g\left(x\right)=c``, a constant, then ``g\prime\left(x\right)=0``.

!!! example
	Use the definition of the derivative to calculate the derivatives of ``f\left(x\right)=x^2``, ``\displaystyle g\left(x\right)=\frac{1}{x}`` and ``k\left(x\right)=\sqrt x``.

	```math
	\begin{aligned}
	f\prime\left(x\right)&=\lim_{h\to 0}\frac{f\left(x+h\right)-f\left(x\right)}{h}\\
	&=\lim_{h\to 0}\frac{\left(x+h\right)^2-x^2}{h}=\lim_{h\to 0}\frac{x^2+2xh+h^2-x^2}{h}\\
	&=\lim_{h\to 0}\frac{2xh+h^2}{h}=\lim_{h\to 0}2x+h=2x\,.
	\end{aligned}
	```

	```math
	\begin{aligned}
	g\prime\left(x\right)&=\lim_{h\to 0}\frac{g\left(x+h\right)-g\left(x\right)}{h}\\
	&=\lim_{h\to 0}\frac{\frac{1}{x+h}-\frac{1}{x}}{h}=\lim_{h\to 0}\frac{\frac{x-\left(x+h\right)}{\left(x+h\right)x}}{h}\\
	&=\lim_{h\to 0}\frac{-h}{h\left(x+h\right)x}=\lim_{h\to 0}-\frac{1}{\left(x+h\right)x}=-\frac{1}{x^2}\,.
	\end{aligned}
	```

	```math
	\begin{aligned}
	k\prime\left(x\right)&=\lim_{h\to 0}\frac{k\left(x+h\right)-k\left(x\right)}{h}\\
	&=\lim_{h\to 0}\frac{\sqrt{x+h}-\sqrt x}{h}=\lim_{h\to 0}\frac{\sqrt{x+h}-\sqrt x}{h}\frac{\sqrt{x+h}+\sqrt x}{\sqrt{x+h}-+\sqrt x}\\
	&=\lim_{h\to 0}\frac{x+h-x}{h\left(\sqrt{x+h}+\sqrt x\right)}=\lim_{h\to 0}\frac{1}{\sqrt{x+h}+\sqrt x}=\frac{1}{2\sqrt x}\,.
	\end{aligned}
	```

The three derivative formulas calculated in this example are special cases of the following *General Power Rule*: If ``f\left(x\right)=x^r``, then ``f\prime\left(x\right)=rx^{r-1}`` for all values of ``r`` and ``x`` for which ``x^{r-1}``makes sense as a real number. Eventually, we will prove all appropriate cases of the General Power Rule. 

!!! example
	Verify that: if ``f\left(x\right)=\left|x\right|``, then ``f\prime\left(x\right)=\frac{x}{\left|x\right|}=\operatorname{sgn}x``.

	We have
	```math
	f\left(x\right)=\begin{cases}
	\hphantom{-}x\,,&\textrm{if }x\ge0\,,\\
	-x\,,\textrm{if }x&lt;0\,.
	\end{cases}
	```

	Thus, from the first example, ``f\prime\left(x\right)=1`` if ``x&gt;0`` and ``f\prime\left(x\right)=-1`` if ``x&lt;0``. Also ``f`` is not differentiable at ``x=0`` (why?), which is a singular point of ``f``. Therefore,
	```math
	f\prime\left(x\right)=\begin{cases}
	\hphantom{-}1\,,&\textrm{if }x\gt0\\
	-1\,,\textrm{if }x&lt;0
	\end{cases}=\frac{x}{\left|x\right|}=\operatorname{sgn}x
	```

Because functions can be written in different ways, it is useful to have more than one notation for derivatives. If ``y=\left(x\right)``, we can use the dependent variable ``y`` to represent the function, and we can denote the derivative of the function with respect to ``x`` in any of the following ways:

```math
\mathsf{D}_x\kern-0.5pt y=y\prime=\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}=\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}f\left(x\right)=f\prime\left(x\right)=\mathsf{D}_x\kern-0.5pt f\left(x\right)=\mathsf{D}\kern-0.5pt f\left(x\right)\,.
```

(In the forms using “``\mathsf{D}_x``,” we can omit the subscript ``x`` if the variable of differentiation is obvious.) Often the most convenient way of referring to the derivative of a function given explicitly as an expression in the variable ``x`` is to write ``\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}`` in front of that expression. The symbol ``\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}`` is a differential operator and should be read “the derivative with respect to ``x`` of ``\dots``”.

The value of the derivative of a function at a particular number ``x_0`` in its domain can also be expressed in several ways:

```math
\left.\mathsf{D}_x\kern-0.5pt y\right|_{x=x_0}=\left.y\prime\right|_{x=x_0}=\left.\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}\right|_{x=x_0}=\left.\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}f\left(x\right)\right|_{x=x_0}=f\prime\left(x_0\right)=\mathsf{D}_x\kern-0.5pt f\left(x_0\right)\,.
```

The symbol ``\left.\vphantom{\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}}\right|_{x=x_0}`` is called an *evaluation symbol*. It signifies that the expression preceding it should be evaluated at ``x=x_0``. Do not confuse ``\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}f\left(x\right)`` and ``\left.\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}f\left(x\right)\right|_{x=x_0}``. The first expression represents a *function*, ``f\prime\left(x\right)``. The second represents a *number* ``f\prime\left(x_0\right)``.

The notation ``\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}`` are called Leibniz notations for the derivative; Newton used notations similar to the prime ``y\prime`` notations we use here.

The Leibniz notation is suggested by the definition of derivative. The Newton quotient ``\frac{f\left(x+h\right)-f\left(x\right)}{h}``, whose limit we take to find the derivative \frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}, can be written in the form ``\frac{\Delta y}{\Delta x}``, where ``\Delta y=f\left(x+h\right)-f\left(x\right)`` is the increment in ``y``, and ``\Delta x=h`` is the corresponding increment in ``x`` as we pass from the point ``\left(x,f\left(x\right)\right)`` to the point ``\left(x+h,f\left(x+h\right)\right)`` on the graph of ``f``. ``\Delta`` is the uppercase Greek letter Delta. Using symbols:

```math
\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}=\lim_{\Delta x\to 0}\frac{\Delta y}{\Delta x}.
```

{cell=chap display=false output=false}
```julia
Figure("", tex(raw"\displaystyle\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}=\lim_{\Delta x\to 0}\frac{\Delta y}{\Delta x}") ) do
    scale = 40
    Drawing(width=6scale, height=5.5scale) do
        xmid = 1scale
        ymid = 5scale
        f = x->-0.5(x-3)^2+4
		x0 = 1.5
		fx0 = f(x0)
		x = 3.5
		fx = f(x)
        axis_xy(6scale,5.5scale,xmid,ymid,scale,(x0, x),tuple(), xs=("x","x+h"))
        plot_xy(f, -1:0.01:5.5, (1.5,), xmid, ymid, scale, width=1)
        circle(cx=xmid+x*scale, cy=ymid-fx*scale, r=3, fill="RoyalBlue", stroke="RoyalBlue")
		m = (fx0-fx)/(x0-x)
		plot_xy(x->m*(x-x0)+fx0, -1:0.01:5.5, tuple(), xmid, ymid, scale, width=1, color = "RoyalBlue")
		m = -(x0-3)
		plot_xy(x->m*(x-x0)+fx0, -1:0.01:5.5, tuple(), xmid, ymid, scale, width=1, color = "green")
		line(x1=xmid+x0*scale, y1=ymid-fx0*scale, x2=xmid+x0*scale, y2=ymid, stroke="black", stroke_dasharray = "3")
		line(x1=xmid+x*scale, y1=ymid-fx*scale, x2=xmid+x*scale, y2=ymid, stroke="black", stroke_dasharray = "3")
		line(x1=xmid+x0*scale, y1=ymid-fx0*scale, x2=xmid+x*scale, y2=ymid-fx0*scale, stroke="black", stroke_dasharray = "3")
		latex("y=f\\left(x\\right)", x=xmid+3.5scale, y=ymid-2.5scale, width=4font_x, height=font_y)
		latex("\\Delta x", x=xmid+2.1scale, y=ymid-2.85scale, width=2font_x, height=font_y)
		latex("\\Delta y", x=xmid+3.5scale, y=ymid-3.5scale, width=2font_x, height=font_y)
    end
end
```

The Newton quotient ``\frac{\Delta y}{\Delta x}`` is actually the quotient of two quantities, ``\Delta y`` and ``\Delta x``. It is not at all clear, however, that the derivative ``\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}``, the limit of ``\frac{\Delta y}{\Delta x}`` as ``\Delta x`` approaches zero, can be regarded as a quotient. If ``y`` is a continuous function of ``x``, then ``\Delta y`` approaches zero when ``\Delta x`` approaches zero, so ``\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}`` appears to be the meaningless quantity ``\frac{0}{0}``. Nevertheless, it is sometimes useful to be able to refer to quantities ``\mathrm d\kern-0.5pt y`` and ``\mathrm d\kern-0.5pt x`` in such a way that their quotient is the derivative ``\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}``. We can justify this by regarding ``\mathrm d\kern-0.5pt x`` as a new independent variable (called the *differential of ``x``*) and defining a new dependent variable ``\mathrm d\kern-0.5pt y`` (the *differential of ``y``*) as a function of ``x`` and ``\mathrm d\kern-0.5pt x`` by

```math
\mathrm{d}\kern-0.5pt y=\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}\mathrm d\kern-0.5pt x=f\prime(x)\,\mathrm d\kern-0.5pt x
```

For example, if ``y=x^2``, we can write ``\mathrm{d}\kern-0.5pt y=2x\,\mathrm{d}\kern-0.5pt x`` to mean the same thing as ``\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}=2x``. Similarly, if ``f\left(x\right)=\frac{1}{x}``, we can write ``\mathrm{d}\kern-0.5pt y=-\frac{1}{x^2}\,\mathrm{d}\kern-0.5pt x`` as the equivalent differential form of the assertion that ``\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}=-\frac{1}{x^2}``. This *differential notation* is useful in applications, and especially for the interpretation and manipulation of integrals. Note that, defined as above, differentials are merely variables that may or may not be small in absolute value.

Is a function ``f`` defined on an interval ``I`` necessarily the derivative of some other function defined on ``I``? The answer is no; some functions are derivatives and some are not. Although a derivative need not be a continuous function, it must, like a continuous function, have the intermediate-value property: on an interval ``\left[a,b\right]``, a derivative ``f\prime\left(x\right)`` takes on every value between ``f\prime\left(a\right)`` and ``f\prime\left(b\right)``. We will prove this in a next section.

If ``g\left(x\right)`` is continuous on an interval ``I``, then ``g\left(x\right)=f\prime\left(x\right)`` for some function ``f`` that is differentiable on ``I`` . We will discuss this fact further in Chapter 6.

## Differentiation Rules

If every derivative had to be calculated directly from the definition of derivative as in the examples of the previou section, calculus would indeed be a painful subject. Fortunately, there is an easier way. We will develop several general differentiation rules that enable us to calculate the derivatives of complicated combinations of functions easily if we already know the derivatives of the elementary functions from which they are constructed.

Before developing these differentiation rules we need to establish one obvious but very important theorem which states, roughly, that the graph of a function cannot possibly have a break at a point where it is smooth.

!!! theorem
	If ``f`` is differentiable at ``x``, then ``f`` is continuous at ``x``.

!!! proof
	Since ``f`` is differentiable at ``x``, we know that
	```math
	\lim_{h\to 0}\frac{f\left(x+h\right)-f\left(x\right)}{h}=f\prime\left(x\right)
	```
	exists. Using the limit rules, we have
	```math
	\lim_{h\to 0}f\left(x+h\right)-f\left(x\right)=\lim_{h\to 0}\frac{f\left(x+h\right)-f\left(x\right)}{h}h=\lim_{h\to 0}\frac{f\left(x+h\right)-f\left(x\right)}{h}\lim_{h\to 0}h=f\prime\left(x\right)0=0\,.
	```
	This is equivalent to ``\lim_{h\to 0}f\left(x+h\right)=f\left(x\right)``, which says that ``f`` is continuous at ``x``.

The derivative of a sum (or difference) of functions is the sum (or difference) of the derivatives of those functions. The derivative of a constant multiple of a function is the same constant multiple of the derivative of the function.

!!! theorem
	If functions ``f`` and ``g`` are differentiable at ``x``, and if ``C`` is a constant, then the functions ``f+g``, ``f-g``, and ``Cf`` are all differentiable at ``x`` and
	```math
	\begin{aligned}
	\left(f+g\right)\prime\left(x\right)&=f\prime\left(x\right)+g\prime\left(x\right)\\
	\left(f-g\right)\prime\left(x\right)&=f\prime\left(x\right)-g\prime\left(x\right)\\
	\left(Cf\right)\prime\left(x\right)&=Cf\prime\left(x\right)\,.
	\end{aligned}
	```

!!! proof
	The proofs of all three assertions are straightforward, using the corresponding limit rules.

	For the sum, we have
	```math
	\begin{aligned}
	\left(f+g\right)\prime\left(x\right)&=\lim_{h\to 0}\frac{\left(f+g\right)\left(x+h\right)-\left(f+g\right)\left(x\right)}{h}\\
	&=\lim_{h\to 0}\frac{\left(f\left(x+h\right)+g\left(x+h\right)\right)-\left(f\left(x\right)+g\left(x\right)\right)}{h}\\
	&=\lim_{h\to 0}\left(\frac{f\left(x+h\right)-f\left(x\right)}{h}+\frac{g\left(x+h\right)-g\left(x\right)}{h}\right)\\
	&=f\prime\left(x\right)+g\prime\left(x\right)\,,
	\end{aligned}
	```
	because the limit of a sum is the sum of the limits. The proof for the difference ``f-g``is similar. 
	
	For the constant multiple, we have
	```math
	\begin{aligned}
	\left(Cf\right)\prime\left(x\right)&=\lim_{h\to 0}\frac{Cf\left(x+h\right)-Cf\left(x\right)}{h}\\
	&=C\lim_{h\to 0}\frac{f\left(x+h\right)-f\left(x\right)}{h}=Cf\prime\left(x\right)\,.
	\end{aligned}
	```

The rule for differentiating sums extends to sums of any finite number of terms

```math
\left(f_1+f_2+\cdots+f_n\right)\prime=f_1^\prime+f_2^\prime+\cdots+f_n^\prime\,.
```

To see this we can use mathematical induction. Theorem 2 shows that the case ``n=2`` is true; this is STEP 1. For STEP 2, we must show that if the formula holds for some integer ``n=h\ge2``, then it must also hold for ``n=k+1``. Therefore, *assume* that

```math
\left(f_1+f_2+\cdots+f_k\right)\prime=f_1^\prime+f_2^\prime+\cdots+f_k^\prime\,.
```

Then we have

```math
\begin{aligned}
\left(f_1+f_2+\cdots+f_k+f_{k+1}\right)\prime&=\left(\underbrace{f_1+f_2+\cdots+f_k}_{\textrm{Let this function be }f}+f_{k+1}\right)\prime\\
&=\left(f+f_{k+1}\right)\prime\\
&=f\prime+f_{k+1}\prime\\
&=f_1^\prime+f_2^\prime+\cdots+f_k^\prime+f_{k+1}\prime\,.
\end{aligned}
```

With both steps verified, we can claim that the formula holds for any ``n&gt2;`` by induction. In particular, therefore, the derivative of any polynomial is the sum of the derivatives of its terms.

The rule for differentiating a product of functions is a little more complicated than that for sums. It is **not** true that the derivative of a product is the product of the derivatives.

!!! theorem
	If functions ``f`` and ``g`` are differentiable at ``x``, then their product ``fg`` is also differentiable at ``x``, and
	```math
	\left(fg\right)\prime\left(x\right)=f\prime\left(x\right)g\left(x\right)+f\left(x\right)g\prime\left(x\right)
	```

!!! proof
	We set up the Newton quotient for ``fg`` and then add ``0`` to the numerator in a way that enables us to involve the Newton quotients for ``f`` and ``g`` separately:
	```math
	\begin{aligned}
	\left(fg\right)\prime\left(x\right)&=\lim_{h\to 0}\frac{\left(fg\right)\left(x+h\right)-\left(fg\right)\left(x\right)}{h}\\
	&=\lim_{h\to 0}\frac{f\left(x+h\right)g\left(x+h\right)-f\left(x\right)g\left(x\right)}{h}\\
	&=\lim_{h\to 0}\frac{f\left(x+h\right)g\left(x+h\right)-f\left(x\right)g\left(x+h\right)+f\left(x\right)g\left(x+h\right)-f\left(x\right)g\left(x\right)}{h}\\
	&=\lim_{h\to 0}\left(\frac{f\left(x+h\right)-f\left(x\right)}{h}g\left(x+h\right)+f\left(x\right)\frac{g\left(x+h\right)-g\left(x\right)}{h}\right)\\
	&=f\prime\left(x\right)g\left(x\right)+f\left(x\right)g\prime\left(x\right)\,,
	\end{aligned}
	```
	To get the last line, we have used the fact that ``f`` and ``g`` are differentiable and the fact that ``g`` is therefore continuous, as well as limit rules.

### Derivatives of Inverse Functions

## Derivatives of Trigonometric Functions

## Higher Order Derivatives

## Implicit Differentiation

## The Mean-Value Theorem

## Indeterminate Forms

## Extreme Values

## Concavity and Inflections

## Sketching the Graph of a Function

## Linear Approximations

## Taylor Polynomials

## Antiderivatives
