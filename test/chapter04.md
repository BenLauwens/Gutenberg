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
		marker(id="arrow", markerWidth="6", markerHeight="6", refX="3", refY="3", orient="auto-start-reverse") do
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

### Vertical Tangent Lines

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
	then the vertical line ``x=x_0`` is tangent to the graph ``y=f\left(x\right)`` at ``P``. If the limit of the Newton quotient fails to exist in any other way than by being ``\infty`` or ``-\infty``, the graph ``y=f\left(x\right)`` has no tangent line at ``P``.

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

### Normals

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

A straight line has the property that its slope is the same at all points. For any other graph, however, the slope may vary from point to point. Thus, the slope of the graph of ``y=f\left(x\right)`` at the point ``x`` is itself a function of ``x``. At any point ``x`` where the graph has a finite slope, we say that ``f`` is *differentiable*, and we call the slope the *derivative* of ``f``. The derivative is therefore the limit of the Newton quotient.

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
	&=\lim_{h\to 0}\frac{\sqrt{x+h}-\sqrt x}{h}=\lim_{h\to 0}\frac{\sqrt{x+h}-\sqrt x}{h}\frac{\sqrt{x+h}+\sqrt x}{\sqrt{x+h}+\sqrt x}\\
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

### Notation

Because functions can be written in different ways, it is useful to have more than one notation for derivatives. If ``y=f\left(x\right)``, we can use the dependent variable ``y`` to represent the function, and we can denote the derivative of the function with respect to ``x`` in any of the following ways:

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

The Leibniz notation is suggested by the definition of derivative. The Newton quotient ``\frac{f\left(x+h\right)-f\left(x\right)}{h}``, whose limit we take to find the derivative ``\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}``, can be written in the form ``\frac{\Delta\kern-0.5pt y}{\Delta\kern-0.5pt x}``, where ``\Delta\kern-0.5pt y=f\left(x+h\right)-f\left(x\right)`` is the increment in ``y``, and ``\Delta\kern-0.5pt x=h`` is the corresponding increment in ``x`` as we pass from the point ``\left(x,f\left(x\right)\right)`` to the point ``\left(x+h,f\left(x+h\right)\right)`` on the graph of ``f``. ``\Delta`` is the uppercase Greek letter Delta. Using symbols:

```math
\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}=\lim_{\Delta\kern-0.5pt x\to 0}\frac{\Delta\kern-0.5pt y}{\Delta\kern-0.5pt x}.
```

{cell=chap display=false output=false}
```julia
Figure("", tex(raw"\displaystyle\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}=\lim_{\Delta\kern-0.5pt x\to 0}\frac{\Delta\kern-0.5pt y}{\Delta\kern-0.5pt x}") ) do
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
		latex("\\Delta\\kern-0.5pt x", x=xmid+2.1scale, y=ymid-2.85scale, width=2font_x, height=font_y)
		latex("\\Delta\\kern-0.5pt y", x=xmid+3.5scale, y=ymid-3.5scale, width=2font_x, height=font_y)
    end
end
```

The Newton quotient ``\frac{\Delta\kern-0.5pt y}{\Delta\kern-0.5pt x}`` is actually the quotient of two quantities, ``\Delta\kern-0.5pt y`` and ``\Delta\kern-0.5pt x``. It is not at all clear, however, that the derivative ``\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}``, the limit of ``\frac{\Delta\kern-0.5pt y}{\Delta\kern-0.5pt x}`` as ``\Delta\kern-0.5pt x`` approaches zero, can be regarded as a quotient. If ``y`` is a continuous function of ``x``, then ``\Delta\kern-0.5pt y`` approaches zero when ``\Delta\kern-0.5pt x`` approaches zero, so ``\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}`` appears to be the meaningless quantity ``\frac{0}{0}``. Nevertheless, it is sometimes useful to be able to refer to quantities ``\mathrm d\kern-0.5pt y`` and ``\mathrm d\kern-0.5pt x`` in such a way that their quotient is the derivative ``\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}``. We can justify this by regarding ``\mathrm d\kern-0.5pt x`` as a new independent variable (called the *differential of ``x``*) and defining a new dependent variable ``\mathrm d\kern-0.5pt y`` (the *differential of ``y``*) as a function of ``x`` and ``\mathrm d\kern-0.5pt x`` by

```math
\mathrm{d}\kern-0.5pt y=\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}\mathrm d\kern-0.5pt x=f\prime(x)\,\mathrm d\kern-0.5pt x
```

For example, if ``y=x^2``, we can write ``\mathrm{d}\kern-0.5pt y=2x\,\mathrm{d}\kern-0.5pt x`` to mean the same thing as ``\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}=2x``. Similarly, if ``f\left(x\right)=\frac{1}{x}``, we can write ``\mathrm{d}\kern-0.5pt y=-\frac{1}{x^2}\,\mathrm{d}\kern-0.5pt x`` as the equivalent differential form of the assertion that ``\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}=-\frac{1}{x^2}``. This *differential notation* is useful in applications, and especially for the interpretation and manipulation of integrals. Note that, defined as above, differentials are merely variables that may or may not be small in absolute value.

### Approximation by Differentials

If one quantity, say ``y``, is a function of another quantity ``x``, that is,
```math
y=f\left(x\right)\,,
```
we sometimes want to know how a change in the value of ``x`` by an amount ``\Delta\kern-0.5pt x`` will affect the value of ``y``. The exact change ``\Delta\kern-0.5pt y`` in ``y`` is given by
```math
\Delta\kern-0.5pt y=f\left(x+\Delta\kern-0.5pt x\right)-f\left(x\right)\,,
```
but if the change ``\Delta\kern-0.5pt x`` is small, then we can get a good approximation to ``\Delta\kern-0.5pt y`` by using the fact that ``\displaystyle\frac{\Delta\kern-0.5pt y}{\Delta\kern-0.5pt x}`` is approximately the derivative ``\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}``. Thus,
```math
\Delta\kern-0.5pt y=\frac{\Delta\kern-0.5pt y}{\Delta\kern-0.5pt x}\Delta\kern-0.5pt x\approx\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}\Delta\kern-0.5pt x=f\prime\left(x\right)\Delta\kern-0.5pt x\,.
```
It is often convenient to represent this approximation in terms of differentials; if we denote the change in ``x`` by ``\mathrm{d}\kern-0.5pt x`` instead of ``\Delta\kern-0.5pt x``, then the change ``\Delta\kern-0.5pt y`` in ``y`` is approximated by the differential ``\mathrm{d}\kern-0.5pt y``, that is
```math
\Delta\kern-0.5pt y\approx\mathrm{d}\kern-0.5pt y=f\prime\left(x\right)\,\mathrm{d}\kern-0.5pt x\,.
```

{cell=chap display=false output=false}
```julia
Figure("", tex(raw"\mathrm{d}\kern-0.5pt y") * ", the change in height to the tangent line, approximates " * tex(raw"\Delta\kern-0.5pt y") * ", the change in height to the graph of f" ) do
    scale = 40
    Drawing(width=6scale, height=3.5scale) do
        xmid = 1scale
        ymid = 3scale
        f = x->0.1(x+0.5)^2+0.5
		x0 = 2
		fx0 = f(x0)
		x = 3.5
		fx = f(x)
        axis_xy(6scale,3.5scale,xmid,ymid,scale,(x0, x),tuple(), xs=("x","x+\\mathrm{d}\\kern-0.5pt y"))
        plot_xy(f, -1:0.01:5, (2, 3.5), xmid, ymid, scale, width=1)
		m = 0.2(x0+0.5)
		plot_xy(x->m*(x-x0)+fx0, -1:0.01:5, tuple(), xmid, ymid, scale, width=1, color = "RoyalBlue")
		line(x1=xmid+x0*scale, y1=ymid-fx0*scale, x2=xmid+x0*scale, y2=ymid, stroke="black", stroke_dasharray = "3")
		line(x1=xmid+x*scale, y1=ymid-fx*scale, x2=xmid+x*scale, y2=ymid, stroke="black", stroke_dasharray = "3")
		line(x1=xmid+x0*scale, y1=ymid-fx0*scale, x2=xmid+5*scale, y2=ymid-fx0*scale, stroke="black", stroke_dasharray = "3")
		line(x1=xmid+x*scale, y1=ymid-fx*scale, x2=xmid+5*scale, y2=ymid-fx*scale, stroke="black", stroke_dasharray = "3")
		line(x1=xmid+x*scale, y1=ymid-(m*(x-x0)+fx0)*scale, x2=xmid+5*scale, y2=ymid-(m*(x-x0)+fx0)*scale, stroke="black", stroke_dasharray = "3")
		latex("y=f\\left(x\\right)", x=xmid+2.5scale, y=ymid-3scale, width=4font_x, height=font_y)
		line(x1=xmid+x0*scale+3, y1=ymid-scale, x2=xmid+x*scale-3, y2=ymid-scale, marker_end="url(#arrow)", marker_start="url(#arrow)", stroke="black")
		latex("\\Delta\\kern-0.5pt x=\\mathrm{d}\\kern-0.5pt x", x=xmid+1.85scale, y=ymid-1scale, width=5font_x, height=font_y)
		line(x1=xmid+3.6scale, y1=ymid-(m*(x-x0)+fx0)*scale+3, x2=xmid+3.6scale, y2=ymid-fx0*scale-3, marker_end="url(#arrow)", marker_start="url(#arrow)", stroke="black")
		latex("\\mathrm{d}\\kern-0.5pt y", x=xmid+3.5scale, y=ymid-1.7scale, width=2font_x, height=font_y)
		line(x1=xmid+4.25scale, y1=ymid-fx*scale+3, x2=xmid+4.25scale, y2=ymid-fx0*scale-3, marker_end="url(#arrow)", marker_start="url(#arrow)", stroke="black")
		latex("\\Delta\\kern-0.5pt y", x=xmid+4.25scale, y=ymid-1.7scale, width=2font_x, height=font_y)
    end
end
```

### Some Questions

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

### Sums and Constant Multiples

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
	because the limit of a sum is the sum of the limits. The proof for the difference ``f-g`` is similar. 
	
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

To see this we can use mathematical induction. theorem 2 shows that the case ``n=2`` is true; this is STEP 1. For STEP 2, we must show that if the formula holds for some integer ``n=h\ge2``, then it must also hold for ``n=k+1``. Therefore, *assume* that

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

### Product Rule

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

!!! example
	Use mathematical induction to verify the formula ``\displaystyle \frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}x^n=nx^{n-1}`` for all positive integers ``n``.

	For ``n=1`` the formula says that ``\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}x^1=1x^0``, so the formula is true in this case. We must show that if the formula is true for ``n=k\ge1``, then it is also true for ``n=k+1``. Therefore, assume that
	```math
	\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}x^k=kx^{k-1}
	```
	Using the Product Rule we calculate
	```math
	\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}x^{k+1}=\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}\left(x^kx\right)=kx^{k-1}x+x^k 1=\left(k+1\right)x^k=\left(k+1\right)x^{\left(k+1\right)-1}
	```
	Thus, the formula is true for ``n=k+1`` also. The formula is true for all integers ``n\ge1`` by induction.

The Product Rule can be extended to products of any number of factors; for instance,

```math
\begin{aligned}
\left(fgh\right)^\prime\left(x\right)&=f^\prime\left(x\right)\left(gh\right)\left(x\right)+f\left(x\right)\left(gh\right)^\prime\left(x\right)\\
&=f^\prime\left(x\right)g\left(x\right)h\left(x\right)+f^\prime\left(x\right)g\prime\left(x\right)h\left(x\right)+f^\prime\left(x\right)g\left(x\right)h\prime\left(x\right)\,.
\end{aligned}
```

In general, the derivative of a product of ``n`` functions will have n terms; each term will be the same product but with one of the factors replaced by its derivative:
```math
\left(f_1f_2f_3\dots f_n\right)^\prime=f_1^\prime f_2f_3\dots f_n+f_1f_2^\prime f_3\dots f_n+f_1f_2f_3^\prime\dots f_n+\cdots+f_1f_2f_3\dots f_n^\prime\,.
```

!!! exercise
	Prove this formula by mathematical induction.

### Reciprocal Rule

!!! theorem
	If ``f`` is differentiable at ``x`` and ``f\left(x\right)\ne0``, then ``\displaystyle\frac{1}{f}`` is differentiable at ``x``, and
	```math
	\left(\frac{1}{f}\right)^\prime\left(x\right)=\frac{-f\prime\left(x\right)}{\left(f\left(x\right)\right)^2}\,.
	```

!!! proof
	Using the definition of the derivative, we calculate
	```math
	\begin{aligned}
	\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}\frac{1}{f\left(x\right)}&=\lim_{h\to 0}\frac{\displaystyle\frac{1}{f\left(x+h\right)}-\frac{1}{f\left(x\right)}}{h}\\
	&=\lim_{h\to 0}\frac{f\left(x\right)-f\left(x+h\right)}{hf\left(x+h\right)f\left(x\right)}\\
	&=\lim_{h\to 0}\left(\frac{-1}{f\left(x+h\right)f\left(x\right)}\right)\left(\frac{f\left(x+h\right)-f\left(x\right)}{h}\right)\\
	&=\frac{-1}{\left(f\left(x\right)\right)^2}f\prime\left(x\right)
	\end{aligned}
	```
	Again we have to use the continuity of ``f`` and the limit rules.

!!! example
	Confirm the General Power Rule for negative integers:
	```math
	\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}x^{-n}=-nx^{-n-1}\,.
	```
	Since we have already proved the rule for positive integers, we have
	```math
	\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}x^{-n}=\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}\frac{1}{x^n}=\frac{-nx^{n-1}}{{\left(x^n\right)^2}}=-nx^{-n-1}\,.
	```

### Quotient Rule

The Product Rule and the Reciprocal Rule can be combined to provide a rule for differentiating a quotient of two functions. Observe that
```math
\begin{aligned}
\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}\left(\frac{f\left(x\right)}{g\left(x\right)}\right)=\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}\left(f\left(x\right)\frac{1}{g\left(x\right)}\right)&=f\prime\left(x\right)\frac{1}{g\left(x\right)}+f\left(x\right)\left(-\frac{g\prime\left(x\right)}{\left(g\left(x\right)\right)^2}\right)\\
&= \frac{g\left(x\right)f\prime\left(x\right)-f\left(x\right)g^\prime\left(x\right)}{\left(g\left(x\right)\right)^2}\,.
\end{aligned}
```

Thus, we have proved the following Quotient Rule.

!!! theorem
	If ``f`` and ``g`` are differentiable at ``x``, and if ``g\left(x\right)\ne0``, then the quotient ``\displaystyle\frac{f}{g}`` is differentiable at ``x`` and
	```math
	\left(\frac{f}{g}\right)^\prime=\frac{g\left(x\right)f\prime\left(x\right)-f\left(x\right)g^\prime\left(x\right)}{\left(g\left(x\right)\right)^2}\,.
	```

### Chain Rule

Although we can differentiate ``\sqrt x`` and ``x^2+1``, we cannot yet differentiate ``\sqrt{x^2+1}``. To do this, we need a rule that tells us how to differentiate composites of functions whose derivatives we already know. This rule is known as the Chain Rule and is the most often used of all the differentiation rules.

!!! theorem
	If ``f\left(u\right)`` is differentiable at ``u=g\left(x\right)``, and ``g\left(x\right)`` is differentiable at ``x``, then the composite function ``f\circ g\left(x\right)=f\left(g\left(x\right)\right)`` is differentiable at ``x``, and
	```math
	\left(f\circ g\right)^\prime=f\prime\left(g\left(x\right)\right)g\prime\left(x\right)
	```

In terms of Leibniz notation, if ``y=f\left(u\right)`` where ``u=g\left(x\right)``, then ``y=f\left(g\left(x\right)\right)`` and:

- at ``u``, ``y`` is changing ``\displaystyle \frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt u}`` times as fast as ``u`` is changing;
- at ``x``, ``u`` is changing ``\displaystyle \frac{\mathrm{d}\kern-0.5pt u}{\mathrm{d}\kern-0.5pt x}`` times as fast as ``x`` is changing.

Therefore, at ``x``, ``y=f\left(u\right)=f\left(g\left(x\right)\right)`` is changing ``\displaystyle \frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt u}\frac{\mathrm{d}\kern-0.5pt u}{\mathrm{d}\kern-0.5pt x}`` times as fast as ``x`` is changing. That is,

```math
\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}=\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt u}\frac{\mathrm{d}\kern-0.5pt u}{\mathrm{d}\kern-0.5pt x}\,,\quad\textrm{where }\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt u}\textrm{ is evaluated at }u=g\left(x\right)\,.
```

It appears as though the symbol ``\mathrm{d}\kern-0.5pt u`` cancels from the numerator and denominator, but this is not meaningful because ``\displaystyle \frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt u}`` was not defined as the quotient of two quantities, but rather as a single quantity, the derivative of ``y`` with respect to ``u``.

We would like to prove this theorem by writing
```math
\frac{\Delta\kern-0.5pt y}{\Delta\kern-0.5pt x}=\frac{\Delta\kern-0.5pt y}{\Delta u}\frac{\Delta u}{\Delta\kern-0.5pt x}
```
and taking the limit as ``\Delta\kern-0.5pt x \to 0``. Such a proof is valid for most composite functions but not all. The next demonstration is valid in all cases.

!!! proof
	Suppose that ``f`` is differentiable at the point ``u=g\left(x\right)`` and that ``g`` is differentiable at ``x``.

	Let the function ``E\left(k\right)`` be defined by
	```math
	E\left(k\right)=\begin{cases}
	0&\textrm{if }k=0\,.\\
	\frac{f\left(u+k\right)-f\left(u\right)}{k}-f\prime\left(u\right)&\textrm{if }k\ne0\,.
	\end{cases}
	```

	By the definition of derivative
	```math
	\lim_{k\to 0}E\left(k\right)=f\prime\left(u\right)-f\prime\left(u\right)=0=E\left(0\right)\,,
	```
	so ``E\left(k\right)`` is continuous at ``k=0``. Also, whether ``k=0`` or not, we have
	```math
	f\left(u+k\right)-f\left(u\right)=\left(f\prime\left(u\right)+E\left(k\right)\right)k\,.
	```
	Now put ``u=g\left(x\right)`` and ``k=g\left(x+h\right)-g\left(x\right)``, so that ``u+k=g\left(x+h\right)``, and obtain
	```math
	f\left(g\left(x+h\right)\right)-f\left(g\left(x\right)\right)=\left(f\prime\left(g\left(x\right)\right)+E\left(k\right)\right)\left(g\left(x+h\right)-g\left(x\right)\right)\,.
	```
	Since ``g`` is differentiable at ``x``,
	```math
	\lim_{h\to 0}\frac{g\left(x+h\right)-g\left(x\right)}{h}=g\prime\left(x\right)\,.
	```
	Also, ``g`` is continuous at ``x``, so 
	```math
	\lim_{h\to 0}k=\lim_{h\to 0}\left(g\left(x+h\right)-g\left(x\right)\right)=0\,.
	```
	Since ``E`` is continuous at ``0``, 
	```math
	\lim_{h\to 0}E\left(k\right)=\lim_{k\to 0}E\left(k\right)=E\left(0\right)=0\,.
	```
	Hence,
	```math
	\begin{aligned}
	\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}f\left(g\left(x\right)\right)&=\lim_{h\to 0}\frac{f\left(g\left(x\right)\right)-f\left(g\left(x+h\right)\right)}{h}\\
	&=\lim_{h\to 0}\left(f\prime\left(g\left(x\right)\right)+E\left(k\right)\right)\frac{g\left(x+h\right)-g\left(x\right)}{h}\\
	&=\left(f\prime\left(g\left(x\right)\right)+0\right)g\prime\left(x\right)=f\prime\left(g\left(x\right)\right)g\prime\left(x\right)\,,
	\end{aligned}
	```
	which was to be proved.

!!! example
	Find the derivative of ``y=\sqrt{x^2+1}``.

	Here ``y=f\left(g\left(x\right)\right)``, where ``f\left(u\right)=\sqrt u`` and ``g\left(x\right)=x^2+1``. Since the derivatives of ``f`` and ``g`` are
	```math
	f\prime\left(u\right)=\frac{1}{2\sqrt u}\quad\textrm{and}\quad g\prime\left(x\right)=2x\,,
	```
	the Chain Rules gives
	```math
	\begin{aligned}
	\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}&=\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}f\left(g\left(x\right)\right)=f\prime\left(g\left(x\right)\right)g\prime\left(x\right)\\
	&=\frac{1}{2\sqrt{g\left(x\right)}}g\prime\left(x\right)=\frac{1}{2\sqrt{x^2+1}}2x=\frac{x}{\sqrt{x^2+1}}\,.
	\end{aligned}
	```

## Derivatives of Trigonometric Functions

In this section we will calculate the derivatives of the six trigonometric functions. We only have to work hard for one of them, sine; the others then follow from known identities and the differentiation rules

First, we have to establish some trigonometric limits that we will need to calculate the derivative of sine. It is assumed throughout that the arguments of the trigonometric functions are measured in radians.

!!! theorem
	The functions ``\sin\theta`` and ``\cos\theta`` are continuous at every value of ``\theta``. In particular, at ``\theta=0`` we have:
	```math
	\lim_{\theta\to 0}\sin\theta=\sin 0=0\quad\textrm{and}\quad\lim_{\theta\to 0}\cos\theta=\cos 0=1
	```

This result seems obvious from the graphs of sine and cosine, but we will still prove it.

!!! proof
	Let ``A``, ``P`` and ``Q`` be the points as shown in the figure.
	{cell=chap display=false output=false}
	```julia
	Figure("", """Continuity of cosine and sine.""") do
		Drawing(width=228, height=190) do
			defs() do
				marker(id="arrowblue", markerWidth="6", markerHeight="6", refX="3", refY="3", orient="auto") do
					path(d="M 0 0 L 6 3 L 0 6 z", fill="RoyalBlue" )
				end
			end
			scale = 75
			xmid = 1.25scale
			ymid = 1.25scale
			axis_xy(2.5scale,2.5scale,xmid,ymid,scale,(-1,1),(-1,1))
			plot_xy(x->sqrt(1-x^2), -1.0:0.01:1.0, (-1, 0, 1), xmid, ymid, scale, width=1)
			plot_xy(x->-sqrt(1-x^2), -1.0:0.01:1.0, tuple(0), xmid, ymid, scale, width=1)
			plot_xy(x->tan(pi/3)*x, 0:0.1:cos(pi/3), tuple(cos(pi/3)), xmid, ymid, scale; color="RoyalBlue")
			latex("\\theta", x=xmid+2/3*scale-font_x, y=ymid-scale/2-font_y/2, width=6font_x, height=font_y, color="red")
			path(d="M $(xmid+scale/3),$ymid A $(scale/3) $(scale/3) 0 0 0 $(xmid+cos(pi/3)*scale/3+2),$(ymid-sin(pi/3)*scale/3+5)", stroke="RoyalBlue", fill="none", marker_end="url(#arrowblue)")
			latex("\\theta", x=xmid+scale/5-font_x, y=ymid-scale/10-font_y, width=4font_x, height=font_y, color="RoyalBlue")
			latex("A", x=xmid+scale+2, y=ymid, width=font_x, height=font_y)
			latex("Q", x=xmid+cos(pi/3)*scale-7, y=ymid, width=font_x, height=font_y)
			latex("P=\\left(\\cos \\theta, \\sin \\theta\\right)", x=xmid+scale*cos(pi/3)-5, y=ymid-scale*sin(pi/3)-font_y, width=8*font_x, height=font_y)
			line(x1=xmid+cos(pi/3)*scale, y1=ymid, x2=xmid+cos(pi/3)*scale, y2=ymid-sin(pi/3)*scale, stroke="RoyalBlue")
			line(x1=xmid+scale, y1=ymid, x2=xmid+cos(pi/3)*scale, y2=ymid-sin(pi/3)*scale, stroke="RoyalBlue")
		end
	end
	```
	Since the length of chord ``AP`` is less than the length of arc ``AP``, we have
	```math
	\sin^2\theta+\left(1-\cos\theta\right)^2&lt;\theta^2\,.
	```
	Squaring yields positive values and the square root is an increasing function, so
	```math
	0\le\left|\sin\theta\right|&lt;\left|\theta\right|\quad\textrm{and}\quad 0\le\left|1-\cos\theta\right|&lt;\left|\theta\right|\,.
	```
	Using the squeeze theorem, we find
	```math
	0\le\lim_{\theta\to 0}\left|\sin\theta\right|&lt;\lim_{\theta\to 0}\left|\theta\right|=0\quad\textrm{and}\quad 0\le\lim_{\theta\to 0}\left|1-\cos\theta\right|&lt;\lim_{\theta\to 0}\left|\theta\right|=0\,.
	```
	Thus,
	```math
	\lim_{\theta\to 0}\sin\theta = 0=\sin0\quad\textrm{and}\quad\lim_{\theta\to 0}\cos\theta = 1=\cos0
	```
	and sine and cosine are continuous at ``\theta=0``.

	To prove the continuity at another point, we use the addition formulas and the rules to evaluate limits:
	```math
	\lim_{\theta\to \theta_0}\sin\theta=\lim_{\phi\to0}\sin(\theta_0+\phi)=\sin\theta_0\lim_{\phi\to0}\cos\phi+\cos\theta_0\lim_{\phi\to0}\sin\phi=\sin\theta_0
	```
	and
	```math
	\lim_{\theta\to \theta_0}\cos\theta=\lim_{\phi\to0}\cos(\theta_0+\phi)=\cos\theta_0\lim_{\phi\to0}\cos\phi-\sin\theta_0\lim_{\phi\to0}\sin\phi=\cos\theta_0\,.
	```

The graph of the function ``\displaystyle\frac{\sin\theta}{\theta}`` is shown in the next figure. Although it is not defined at ``\theta=0``, this function appears to have limit ``1`` as ``\theta`` approaches ``0``.

{cell=chap display=false output=false}
```julia
Figure("", tex(raw"\displaystyle\lim_{\theta\to 0}\frac{\sin\theta}{\theta}=1") ) do
	scale = 40
	Drawing(width=14scale, height=2.2scale) do
		xmid = 7scale
		ymid = 1.5scale
		f = x->sin(x)/x
		axis_xy(14scale,2scale,xmid,ymid,scale,(-2pi,-pi,-pi/2,pi/2,pi,2pi),(1,),xs=("-2\\textup{π}", "-\\textup{π} ","-\\frac{\\textup{π} }{2}","\\frac{\\textup{π} }{2}","\\textup{π} ","2\\textup{π}"), xl=(3, 2, 2, 1, 1, 2), xh=(1,1,2,2,1,1))
		plot_xy(f, -7:0.01:-0.01, tuple(), xmid, ymid, scale, width=1)
		plot_xy(f, 0.01:0.01:7, tuple(), xmid, ymid, scale, width=1)
		circle(cx=xmid, cy=ymid-scale, fill="white", stroke="red", r=3)
	end
end
```

!!! theorem
	``\displaystyle\lim_{\theta\to 0}\frac{\sin\theta}{\theta}=1\,.``

!!! proof
	Let ``0&lt;\theta&lt;\frac{\pi}{2}``, and represent ``\theta`` as shown in the figure.
	{cell=chap display=false output=false}
	```julia
	Figure("", "Area " * tex("\\triangle OAP&lt; ") * "Area sector " * tex("OAP&lt; ") * " Area " * tex("\\triangle OAT")) do
		Drawing(width=228, height=225) do
			defs() do
				marker(id="arrowblue", markerWidth="6", markerHeight="6", refX="3", refY="3", orient="auto") do
					path(d="M 0 0 L 6 3 L 0 6 z", fill="RoyalBlue" )
				end
			end
			scale = 75
			xmid = 1.25scale
			ymid = 1.8scale
			axis_xy(2.5scale,3scale,xmid,ymid,scale,(-1,1),(-1,1))
			plot_xy(x->sqrt(1-x^2), -1.0:0.01:1.0, (-1, 0, 1), xmid, ymid, scale, width=1)
			plot_xy(x->-sqrt(1-x^2), -1.0:0.01:1.0, tuple(0), xmid, ymid, scale, width=1)
			plot_xy(x->tan(pi/3)*x, 0:0.1:1, tuple(cos(pi/3), 1), xmid, ymid, scale; color="RoyalBlue")
			latex("\\theta", x=xmid+1/2*scale-font_x, y=ymid-2/3*scale-font_y/2, width=6font_x, height=font_y, color="red")
			path(d="M $(xmid+scale/3),$ymid A $(scale/3) $(scale/3) 0 0 0 $(xmid+cos(pi/3)*scale/3+2),$(ymid-sin(pi/3)*scale/3+5)", stroke="RoyalBlue", fill="none", marker_end="url(#arrowblue)")
			latex("\\theta", x=xmid+scale/5-font_x, y=ymid-scale/10-font_y, width=4font_x, height=font_y, color="RoyalBlue")
			latex("A", x=xmid+scale+2, y=ymid, width=font_x, height=font_y)
			latex("T", x=xmid+scale+2, y=ymid-tan(pi/3)*scale-font_y/2, width=font_x, height=font_y)
			latex("P=\\left(\\cos \\theta, \\sin \\theta\\right)", x=xmid+scale*cos(pi/3)-5, y=ymid-scale*sin(pi/3)-font_y/2, width=8*font_x, height=font_y)
			line(x1=xmid+scale, y1=ymid, x2=xmid+scale, y2=ymid-tan(pi/3)*scale, stroke="RoyalBlue")
			line(x1=xmid+scale, y1=ymid, x2=xmid+cos(pi/3)*scale, y2=ymid-sin(pi/3)*scale, stroke="RoyalBlue")
		end
	end
	```
	Points ``A\left(1,0\right)`` and ``P\left(\cos\theta,\sin\theta\right)`` lie on the unit circle ``x^2+y^2=1``. The area of the circular sector ``OAP`` lies between the areas of triangles ``\triangle OAP`` and ``\triangle OAT``:
	```math
	\textrm{Area }\triangle OAP&lt;\textrm{Area sector } OAP&lt;\textrm{Area }\triangle OAT\,.
	```
	As shown in Chapter 2, the area of a circular sector having central angle ``\theta`` and radius ``1`` is ``\frac{\theta}{2}``. The area of a triangle is ``\frac{1}{2}\times\textrm{base}\times\textrm{height}``, so
	```math
	\textrm{Area }\triangle OAP=\frac{1}{2}\left(1\right)\sin\theta=\frac{\sin\theta}{2}\quad\textrm{and}\quad
	\textrm{Area }\triangle OAT=\frac{1}{2}\left(1\right)\tan\theta=\frac{\tan\theta}{2}\,.\\
	```
	Thus
	```math
	\frac{\sin\theta}{2}&lt;\frac{\theta}{2}&lt;\frac{\sin\theta}{2\cos\theta}\quad\textrm{or}\quad1&lt;\frac{\theta}{\sin\theta}&lt;\frac{1}{\cos\theta}\,.
	```
	Now take the reciprocals, thereby reversing the inequalities:
	```math
	1&gt;\frac{\sin\theta}{\theta}&gt;\cos\theta\,.
	```
	Since ``\lim_{\theta\to 0^+}\cos\theta=1``, the squeeze theorem gives ``\displaystyle\lim_{\theta\to 0^+}\frac{\sin\theta}{\theta}=1``.
	Finally, note that ``\sin\theta`` and ``\theta`` are odd functions. Therefore, ``f\left(\theta\right)=\frac{\sin\theta}{\theta}`` is an even function: ``f\left(\theta\right)=f\left(-\theta\right)``. This symmetry implies that the left limit at ``0`` must have the same value as the right limit:
	```math
	\lim_{\theta\to 0^-}\frac{\sin\theta}{\theta}=1=\lim_{\theta\to 0^+}\frac{\sin\theta}{\theta}\,,
	```
	so ``\displaystyle\lim_{\theta\to 0}\frac{\sin\theta}{\theta}=1``.

This theorem can be combined with limit rules and known trigonometric identities to yield other trigonometric limits.

!!! example
	``\displaystyle\textrm{Show that }\lim_{h\to 0}\frac{\cos h-1}{h}=0\,.``

	Using the half-angle formula ``\cos h=1-2\sin^2\frac{h}{2}``, we calculate
	```math
	\begin{aligned}
	\lim_{h\to 0}\frac{\cos h-1}{h}\,&=\lim_{h\to 0}\frac{-2\sin^2\frac{h}{2}}{h}\quad\textrm{let }\theta=\frac{h}{2}\,,\\
	&=-\lim_{\theta\to 0}\frac{\sin\theta}{\theta}\sin\theta=-\left(1\right)\left(0\right)=0\,.
	\end{aligned}
	```

To calculate the derivative of ``\sin x``, we need the addition formula for sine
```math
\sin\left(x+h\right)=\sin x\cos h+\cos x\sin h
```

!!! theorem
	``\displaystyle\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}\sin x=\cos x\,.``

!!! proof
	We use the definition of derivative, the addition formula for sine, the rules for combining limits, and the previous theorem:
	```math
	\begin{aligned}
	\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}\sin x&=\lim_{h\to 0}\frac{\sin\left(x+h\right)-\sin x}{h}\\
	&=\lim_{h\to 0}\frac{\sin x\cos h+\cos x\sin h-\sin x}{h}\\
	&=\lim_{h\to 0}\frac{\sin x\left(\cos h-1\right)+\cos x\sin h}{h}\\
	&=\lim_{h\to 0}\sin x\lim_{h\to 0}\frac{\cos h-1}{h}+\lim_{h\to 0}\cos x\lim_{h\to 0}\frac{\sin h}{h}\\
	&=\left(\sin x\right)\left(0\right)+\left(\cos x\right)\left(1\right)=\cos x\,.
	\end{aligned}
	```

!!! theorem
	``\displaystyle\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}\cos x=-\sin x\,.``

!!! proof
	We make use of the complementary angle identities, and the Chain rule:
	```math
	\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}\cos x=\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}\sin\left(\frac{\textup{π}}{2}-x\right)=\left(-1\right)\cos\left(\frac{\textup{π}}{2}-x\right)=-\sin x\,.
	```

Because ``\sin x`` and ``\cos x`` are differentiable everywhere, the functions
```math
\tan x=\frac{\sin x}{\cos x}\,,\quad\cot x=\frac{\cos x}{\sin x}\,,\quad\sec x=\frac{1}{\cos x}\,,\quad\csc x=\frac{1}{\sin x}
```
are differentiable at every value of ``x`` at which they are defined (i.e., where their denominators are not zero). Their derivatives can be calculated by the Quotient and Reciprocal Rules and are as follows:
```math
\begin{aligned}
\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}\tan(x)=\sec^2 x\,,\quad&\quad\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}\cot x=-\csc^2 x\,,\\
\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}\sec(x)=\sec x\tan x\,,\quad&\quad\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}\csc x=-\csc x\cot x\,.
\end{aligned}
```

!!! example
	Verify the formula for ``\tan x``.

	```math
	\begin{aligned}
	\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}\tan(x)&=\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}\left(\frac{\sin x}{\cos x}\right)=\frac{\cos x\displaystyle\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}\sin(x)-\sin x\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}\cos(x)}{\cos^2 x}\\
	&=\frac{\cos x\cos(x)-\sin x\left(-\sin x\right)}{\cos^2 x}=\frac{\cos^2 x+\sin^2 x}{\cos^2 x}\\
	&=\frac{1}{\cos^2 x}=\sec^2 x\,.
	\end{aligned}
	```

!!! exercise
	Verify the other formulas.

## Higher Order Derivatives

If the derivative ``y\prime=f\prime\left(x\right)`` of a function ``y=f\left(x\right)`` is itself differentiable at ``x``, we can calculate its derivative, which we call the second derivative of ``f`` and denote by ``y\prime\prime=f\prime\prime\left(x\right)``. As is the case for first derivatives, second derivatives can be denoted by various notations depending on the context. Some of the more common ones are
```math
y\prime\prime=f\prime\prime\left(x\right)=\frac{\mathrm{d}^2\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x^2}=\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}f\left(x\right)=\frac{\mathrm{d}^2\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x^2}f\left(x\right)=\mathsf{D}_x^2y=\mathsf{D}_x^2f\left(x\right)\,.
```

Similarly, you can consider third-, fourth-, and in general ``n``th-order derivatives. The prime notation is inconvenient for derivatives of high order, so we denote the order by a superscript in parentheses (to distinguish it from an exponent): the ``n``th derivative of ``y=f\left(x\right)`` is
```math
y^{(n)}=f^{(n)}\left(x\right)=\frac{\mathrm{d}^n\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x^n}=\frac{\mathrm{d}^n\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x^n}f\left(x\right)=\mathsf{D}_x^ny=\mathsf{D}_x^nf\left(x\right)\,,
```
and it is defined to be the derivative of the ``\left(n-1\right)``st derivative. For ``n=1,2,3`` primes are still normally used: ``f^{\left(3\right)}=f\prime\prime\prime``. It is convenient to denote ``f^{\left(0\right)}=f``, that is, to regard a function as its own zeroth-order derivative.

!!! example
	The *velocity* of a moving object is the (instantaneous) rate of change of the position of the object with respect to time; if the object moves along the ``x``-axis and is at position ``x=f\left(t\right)`` at time ``t``, then its velocity at that time is
	```math
	v=\frac{\mathrm{d}\kern-0.5pt x}{\mathrm{d}\kern-0pt t}=f\prime\left(t\right)\,.
	```
	Similarly, the *acceleration* of the object is the rate of change of the velocity. Thus, the acceleration is the second derivative of the position:
	```math
	a=\frac{\mathrm{d}^2\kern-0.5pt x}{\mathrm{d}\kern-0pt t^2}=f\prime\prime\left(t\right)\,.
	```

!!! example
	If ``y=x^3``, then ``y\prime=3x^2``, ``y\prime\prime=6x``, ``y\prime\prime\prime=6``, ``y^{\left(4\right)}=0``, and all higher derivatives are zero.

In general, if ``f\left(x\right)=x^n`` (where ``n`` is a positive integer), then
```math
\begin{aligned}
f^{\left(k\right)}&=n\left(n-1\right)\left(n-2\right)\cdots\left(n-\left(k-1\right)\right)x^{n-k}\\
&=\begin{cases}
\frac{n!}{\left(n-k\right)!}x^{n-k}&\textrm{if }0\le k\le n\\
0&\textrm{if }k&gt;n\,,
\end{cases}
\end{aligned}
```
where ``n!`` is called the *factorial* and is recursively defined by:
```math
n!=\begin{cases}
1&\textrm{if }n=0\\
n\left(n-1\right)!&\textrm{if }n&gt;0\,.
\end{cases}
```

It follows that if ``P`` is a polynomial of degree ``n``,
```math
P\left(x\right)=a_nx^n+a_{n-1}x^{n-1}+\cdots+a_1x+a_0\,,
```
where ``a_n, a_{n-1}, \dots, a_1, a_0`` are constants, then ``P^{\left(k\right)}\left(x\right)=0`` for ``k&gt;n``. For ``k\le n``, ``P^{\left(k\right)}`` is a polynomial of degree ``n-k``; in particular, ``P^{\left(n\right)}\left(x\right)=n!a_n``, a constant function.

## Implicit Differentiation

We know how to find the slope of a curve that is the graph of a function ``y=f\left(x\right)`` by calculating the derivative of ``f``. But not all curves are the graphs of such functions. To be the graph of a function ``f\left(x\right)``, the curve must not intersect any vertical lines at more than one point.

Curves are generally the graphs of equations in two variables. Such equations can be written in the form
```math
F\left(x,y\right)=0\,,
```
where ``F\left(x,y\right)`` denotes an expression involving the two variables ``x`` and ``y``. For example, a circle with centre at the origin and radius ``5`` has equation
```math
x^2+y^2=25
```
so ``F\left(x,y\right)=x^2+y^2-25`` for that circle.

Sometimes we can solve an equation ``F\left(x,y\right)=0`` for ``y`` and so find explicit formulas for one or more functions ``y=f\left(x\right)`` defined by the equation. Usually, however, we are not able to solve the equation. However, we can still regard it as defining yas one or more functions of ``x`` implicitly, even it we cannot solve for these functions explicitly. Moreover, we still find the derivative ``\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}`` of these implicit solutions by a technique called *implicit differentiation*. The idea is to differentiate the given equation with respect to ``x``, regarding ``y`` as a function of ``x`` having derivative ``\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}``, or ``y^\prime``.

!!! example

	Find ``\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}`` if ``y^2=x``.

	The equation ``y^2=x`` defines two differentiable functions of ``x``; in this case we know them explicitly. They are ``y_1=\sqrt x`` and ``y_2=-\sqrt x``, having derivatives defined for ``x&gt;0`` by
	```math
	\frac{\mathrm{d}\kern-0.5pt y_1}{\mathrm{d}\kern-0.5pt x}=\frac{1}{2\sqrt x}\quad\textrm{and}\quad\frac{\mathrm{d}\kern-0.5pt y_2}{\mathrm{d}\kern-0.5pt x}=-\frac{1}{2\sqrt x}\,.
	```

	However, we can find the slope of the curve ``y^2=x`` at any point ``\left(x,y\right)`` satisfying that equation without first solving the equation for ``y``. To find ``\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}``, we simply differentiate both sides of the equation ``y^2=x`` with respect to ``x``, treating ``y`` as a differentiable function of ``x`` and using the Chain Rule to differentiate ``y^2``:
	```math
	\begin{aligned}
	\frac{\mathrm{d}\kern-0.5pt \hphantom{x}}{\mathrm{d}\kern-0.5pt x}\left(y^2\right)&=\frac{\mathrm{d}\kern-0.5pt \hphantom{x}}{\mathrm{d}\kern-0.5pt x}\left(x\right)\\
	2y\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}&=1\\
	\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}&=\frac{1}{2y}\,.
	\end{aligned}
	```

	Observe that this agrees with the derivatives we calculated above for both of the explicit solutions ``y_1=\sqrt x`` and ``y_2=-\sqrt x``:
	```math
	\frac{\mathrm{d}\kern-0.5pt y_1}{\mathrm{d}\kern-0.5pt x}=\frac{1}{2y_1}=\frac{1}{2\sqrt x}\quad\textrm{and}\quad\frac{\mathrm{d}\kern-0.5pt y_2}{\mathrm{d}\kern-0.5pt x}=\frac{1}{2y_2}=-\frac{1}{2\sqrt x}\,.
	```

!!! example

	Find ``y^{\prime\prime}`` if ``xy+y^2=2x``.

	Twice differentiate both sides of the given equation with respect to ``x``:
	```math
	\begin{aligned}
	y+xy^\prime+2yy^\prime&=2\\
	y^\prime+y^\prime+xy^{\prime\prime}+2\left(y\prime\right)^2+2yy^{\prime\prime}&=0\,.
	\end{aligned}
	```

	Now solve these equations for ``y^\prime`` and ``y^{\prime\prime}``.
	```math
	\begin{aligned}
	y^\prime&=\frac{2-y}{x+2y}\\
	y^{\prime\prime}&=-\frac{2y^\prime+2\left(y^\prime\right)^2}{x+2y}=-\frac{8}{\left(x+2y\right)^3}\,.
	\end{aligned}
	```

Until now, we have only proven the General Power Rule
```math
\frac{\mathrm{d}\kern-0.5pt \hphantom{x}}{\mathrm{d}\kern-0.5pt x}x^r=rx^{r-1}
```
for integer exponents ``r`` and a few special rational exponents such as ``r=\frac{1}{2}``. Using implicit differentiation, we can give the proof for any rational exponent ``r=\frac{m}{n}``, where ``m`` and ``n`` are integers, and ``n\ne0``.

If ``y=x^\frac{m}{n}``, then ``y^n=x^m``. Differentiating implicitly with respect to ``x``, we obtain
```math
ny^{n-1}\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}=mx^{m-1}\,,
```
so
```math
\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}=\frac{m}{n}x^{m-1}y^{1-n}=\frac{m}{n}x^{m-1}\left(x^\frac{m}{n}\right)^{1-n}=\frac{m}{n}x^{m-1+\frac{m}{n}-m}=\frac{m}{n}x^{\frac{m}{n}-1}\,.
```

## Derivatives of Inverse Functions

Suppose that the function ``f`` is differentiable on an interval ``\left]a,b\right[`` and that either ``f\prime\left(x\right)&gt;0`` for ``a&lt;x&lt;b``, so that ``f`` is increasing on ``\left]a,b\right[``, or ``f\prime\left(x\right)&lt;0`` for ``a&lt;x&lt;b``, so that ``f`` is decreasing on ``\left]a,b\right[``. In either case ``f`` is bijective on ``\left]a,b\right[`` and has an inverse, ``f^{-1}`` there. Differentiating the cancellation identity
```math
f\left(f^{-1}\left(x\right)\right)=x
````
with respect to ``x``, using the chain rule, we obtain
```math
f\prime\left(f^{-1}\left(x\right)\right)\frac{\mathrm d\hphantom{x}}{\mathrm dx}f^{-1}\left(x\right)=\frac{\mathrm d\hphantom{x}}{\mathrm dx}x=1\,.
```
Thus,
```math
\frac{\mathrm d\hphantom{x}}{\mathrm dx}f^{-1}\left(x\right)=\frac{1}{f\prime\left(f^{-1}\left(x\right)\right)}\,.
```
In Leibniz notation, if ``y=f^{-1}\left(x\right)``, we have
```math
\left.\frac{\mathrm dy}{\mathrm dx}\right|_x=\frac{1}{\left.\frac{\mathrm dx}{\mathrm dy}\right|_{y=f^{-1}\left(x\right)}}\,.
```
The slope of the graph of ``f^{-1}`` at ``\left(x,y\right)`` is the reciprocal of the slope of the graph of ``f`` at ``\left(y,x\right)``.

{cell=chap display=false output=false}
```julia
Figure("", "Tangents to the graphs of " * tex("f") * " and " * tex("f^{-1}") * ".") do
	scale = 40
	Drawing(width=6scale, height=6scale) do
		xmid = 1scale
		ymid = 5scale
		f = x->0.4(x+1)^2-0.1
		f_prime = x->0.8(x+1)
		x_0 = 1.5
		y_0 = f(x_0)
		m = f_prime(x_0)
		f_inv = y->sqrt((y+0.1)/0.4)-1
		m_prime = 1/f_prime(x_0)
		axis_xy(6scale,6scale,xmid,ymid,scale,tuple(),tuple())
		plot_xy(f, -1:0.01:5, tuple(x_0), xmid, ymid, scale, width=1, color="RoyalBlue")
		plot_xy(f_inv, -0.1:0.01:5, tuple(y_0), xmid, ymid, scale, width=1)
		line(x1=0, y1=6scale, x2=6scale, y2=0, stroke="green", stroke_dasharray = "3")
		line(x1=x_0*scale+xmid, y1=ymid-y_0*scale, x2=y_0*scale+xmid, y2=ymid-x_0*scale, stroke="green", stroke_dasharray = "3")
		x_i = (x_0-y_0-m_prime*y_0+m*x_0)/(m-m_prime)
		plot_xy(x->m*(x-x_0)+y_0, x_i:0.01:4, tuple(), xmid, ymid, scale, width=1, color="RoyalBlue")
		plot_xy(x->m_prime*(x-y_0)+x_0, x_i:0.01:5, tuple(), xmid, ymid, scale, width=1)
		latex("y=f\\left(x\\right)", x=xmid+scale, y=ymid-5scale, width=4font_x, height=font_y, color="RoyalBlue")
		latex("x=f^{-1}\\left(y\\right)", x=xmid+3.25scale, y=ymid-2scale, width=5font_x, height=font_y, color="red")
		latex("\\left(x,y\\right)", x=xmid+0.5scale, y=ymid-3scale, width=3font_x, height=font_y)
		latex("\\left(y,x\\right)", x=xmid+2.5scale, y=ymid-1.5scale, width=3font_x, height=font_y)
	end
end
```

!!! example

	Show that ``f\left(x\right)=x^3+x`` is bijective on the whole real line, and, nothing that ``f\left(2\right)=10``, find ``\left(f^{-1}\right)^\prime\left(10\right)``.

	Since ``f\prime\left(x\right)=3x^2+1&gt;0`` for all real numbers ``x``, ``f`` is increasing and therefore bijective and invertible. If ``y=f^{-1}\left(x\right)``, then
	```math
	\begin{aligned}
	x=f\left(y\right)=y^3+y &\implies 1=(3y^2+1)y\prime\\
	&\implies y\prime=\frac{1}{3y^2+1}\,.
	\end{aligned}
	```
	Now ``x=f\left(2\right)=10`` implies ``y=f^{-1}\left(10\right)=2``. Thus,
	```math
	\left(f^{-1}\right)^\prime\left(10\right)=\left.\frac{1}{3y^2+1}\right|_{y=2}=\frac{1}{13}\,.
	```

## The Mean-Value Theorem

If you set out in a car at 1:00 p.m. and arrive in a town 150 km away from your starting point at 3:00 p.m., then you have travelled at an average speed of ``\frac{150}{2}=75`` km/h. Although you may not have travelled at constant speed, you must have been going 75 km/h at at least one instant during your journey, for if your speed was always less than 75 km/h you would have gone less than 150 km in 2 h, and if your speed was always more than 75 km/h, you would have gone more than 150 km in 2 h. In order to get from a value less than 75 km/h to a value greater than 75 km/h, your speed, which is a continuous function of time, must pass through the value 75 km/h at some intermediate time.

The conclusion that the average speed over a time interval must be equal to the instantaneous speed at some time in that interval is an instance of an important mathematical principle. In geometric terms it says that if ``A`` and ``B`` are two points on a smooth curve, then there is at least one point ``C`` on the curve between ``A`` and ``B`` where the tangent line is parallel to the chord line ``AB``.

{cell=chap display=false output=false}
```julia
Figure("", "There is a point " * tex("C") * " on the curve where the tangent (green) is parallel to the chord " * tex("AB") * " (blue).") do
    scale = 40
    Drawing(width=6scale, height=5.5scale) do
        xmid = 1scale
        ymid = 5scale
        f = x->-0.5(x-2)^2+4
		c = 1.5
		fc = f(c)
		a = -0.5
		fa = f(a)
		b= 3.5
		fb=f(b)
        axis_xy(6scale,5.5scale,xmid,ymid,scale,(a,b,c),tuple(), xs=("a","b","c"))
        plot_xy(f, -1:0.01:5.5, (a, b, c), xmid, ymid, scale, width=1)
		m = -(c-2)
		plot_xy(x->m*(x-c)+fc, -1:0.01:5.5, tuple(), xmid, ymid, scale, width=1, color = "green")
		plot_xy(x->m*(x-a)+fa, a:0.01:b, tuple(), xmid, ymid, scale, width=1, color = "RoyalBlue")
		line(x1=xmid+a*scale, y1=ymid-fa*scale, x2=xmid+a*scale, y2=ymid, stroke="black", stroke_dasharray = "3")
		line(x1=xmid+b*scale, y1=ymid-fb*scale, x2=xmid+b*scale, y2=ymid, stroke="black", stroke_dasharray = "3")
		line(x1=xmid+c*scale, y1=ymid-fc*scale, x2=xmid+c*scale, y2=ymid, stroke="black", stroke_dasharray = "3")
		latex("y=f\\left(x\\right)", x=xmid+3scale, y=ymid-4scale, width=4font_x, height=font_y)
		latex("A", x=xmid+a*scale-0.6font_x, y=ymid-fa*scale-1.25font_y, width=font_x, height=font_y)
		latex("B", x=xmid+b*scale-0.5font_x, y=ymid-fb*scale-1.25font_y, width=font_x, height=font_y)
		latex("C", x=xmid+c*scale-0.5font_x, y=ymid-fc*scale-1.25font_y, width=font_x, height=font_y)
    end
end
```

This principle is stated more precisely in the following theorem.

!!! theorem "The Mean-Value theorem"
	Suppose that the function ``f`` is continuous on the closed, finite interval ``\left[a,b\right]`` and that it is differentiable on the open interval ``\left]a,b\right[``. Then there exists a point ``c`` in the open interval ``\left]a,b\right[`` such that
	```math
	\frac{f\left(b\right)-f\left(a\right)}{b-a}=f\prime\left(c\right)\,.
	```

This says that the slope of the chord line joining the points ``\left(a,f\left(a\right)\right)`` and ``\left(b,f\left(b\right)\right)`` is equal to the slope of the tangent line to the curve ``f=f\left(x\right)`` at the point ``\left(c,f\left(c\right)\right)``, so the two lines are parallel.

We can make several observations:

1. The hypotheses of the Mean-Value theorem are all necessary for the conclusion; if ``f`` fails to be continuous at even one point of ``\left[a,b\right]`` or fails to be differentiable at even one point of ``\left]a,b\right[``, then there may be no point where the tangent line is parallel to the secant line ``AB``.
2. The Mean-Value theorem gives no indication of how many points ``C`` there may be on the curve between ``A`` and ``B`` where the tangent is parallel to ``AB``. If the curve is itself the straight line ``A``B, then every point on the line between ``A`` and ``B`` has the required property. In general, there may be more than one point; the Mean-Value theorem asserts only that there must be at least one.
3. The Mean-Value theorem gives us no information on how to find the point ``c``, which it says must exist. For some simple functions it is possible to calculate ``c`` (see the following example), but doing so is usually of no practical value. As we shall see, the importance of the Mean-Value theorem lies in its use as a theoretical tool. It belongs to a class of theorems called existence theorems

The Mean-Value theorem is one of those deep results that is based on the completeness of the real number system via the fact that a continuous function on a closed, finite interval takes on a maximum and minimum value (Extreme-Value theorem). Before giving the proof, we establish two preliminary results.

!!! theorem
	If ``f`` is defined on an open interval ``\left]a,b\right[`` and achieves a maximum (or minimum) value at the point ``c`` in ``\left]a,b\right[``, and if ``f\prime\left(c\right)`` exists, then ``f\prime\left(c\right)=0``. (Values of ``x`` where ``f\prime\left(x\right)=0`` are called *critical points* of the function ``f``.)

!!! proof

	Suppose that ``f`` has a maximum value at ``c``. Then ``f\left(x\right)-f\left(c\right)\le0`` whenever ``x`` is in ``\left]a,b\right[``.

	If ``c&lt;x&lt;b``, then
	```math
	\frac{f\left(x\right)-f\left(c\right)}{x-c}\le0\,,\quad\textrm{so }f^\prime\left(c\right)=\lim_{x\to c^+}\frac{f\left(x\right)-f\left(c\right)}{x-c}\le0\,.
	```
	If ``a&lt;x&lt;c``, then
	```math
	\frac{f\left(x\right)-f\left(c\right)}{x-c}\ge0\,,\quad\textrm{so }f^\prime\left(c\right)=\lim_{x\to c^-}\frac{f\left(x\right)-f\left(c\right)}{x-c}\ge0\,.
	```
	Thus ``f^\prime\left(c\right)``. The proof for a minimum value at ``c`` is similar.

!!! theorem "Rolle's theorem"

	Suppose that the function ``g`` is continuous on the closed, finite interval ``\left[a,b\right]`` and that it is differentiable on the open interval ``\left]a,b\right[``. If ``g\left(a\right)=g\left(b\right)``, then there exists a point ``c`` in the open interval ``\left]a,b\right[`` such that ``g\prime\left(c\right)=0``.

!!! proof

	If ``g\left(x\right)=g\left(a\right)`` for every ``x`` in ``\left[a,b\right]``, then ``g`` is a constant function, so ``g\prime\left(c\right)=0`` for every ``c`` in ``\left]a,b\right[``. Therefore, suppose there exists ``x`` in ``\left]a,b\right[`` such that ``g\left(x\right)\ne g\left(a\right)``.

	Let us assume that ``g\left(x\right)&gt; g\left(a\right)``. (If ``g\left(x\right)&lt; g\left(a\right)``, the proof is similar.)

	By the Extreme-Value theorem, being continuous on ``\left[a,b\right]``, ``g`` must have a maximum value at some point ``c`` in ``\left[a,b\right]``.

	Since ``g\left(c\right)\ge g\left(x\right)&gt; g\left(a\right)=g\left(b\right)``, ``c`` cannot be either ``a`` or ``b``. Therefore, ``c`` is in the open interval ``\left]a,b\right[``, so ``g`` is differentiable at ``c``.

	By the previous theorem, ``c`` must be a critical point of ``g``: ``g\prime\left(c\right)=0``.

Rolle’s theorem is a special case of the Mean-Value theorem in which the chord line has slope 0, so the corresponding parallel tangent line must also have slope 0. We can deduce the Mean-Value theorem from this special case.

!!! proof "of the Mean-Value theorem"
	
	Suppose ``f`` satisfies the conditions of the Mean-Value theorem. 
	
	Let
	```math
	g\left(x\right) = f\left(x\right)-\left(f\left(a\right)+\frac{f\left(b\right)-f\left(a\right)}{b-a}\left(x-a\right)\right)\,.
	```

	The function ``g`` is also continuous on ``\left[a,b\right]`` and differentiable on ``\left]a,b\right[`` because ``f`` has these properties. 
	
	In addition, ``g\left(a\right)=g\left(b\right)=0``. By Rolle’s theorem, there is some point ``c`` in ``\left]a,b\right[`` such that ``g\prime\left(c\right)=0``. 
	
	Since
	```math
	g\prime\left(x\right) = f\prime\left(x\right)-\frac{f\left(b\right)-f\left(a\right)}{b-a}\,,
	```
	it follows that
	```math
	f\prime\left(c\right)=\frac{f\left(b\right)-f\left(a\right)}{b-a}\,.
	```

Many of the applications we will make of the Mean-Value theorem will actually use the following generalized version of it.

!!! theorem "The Generalized Mean-Value theorem"
	
	If functions ``f`` and ``g`` are both continuous on ``\left[a,b\right]`` and differentiable on ``\left]a,b\right[``, and if ``g\prime\left(x\right)\ne 0`` for every ``x\in\left]a,b\right[``, then there exists a number ``c \in \left]a,b\right[`` such that
	```math
	\frac{f\left(b\right)-f\left(a\right)}{g\left(b\right)-g\left(a\right)}=\frac{f\prime\left(c\right)}{g\prime\left(c\right)}\,.
	```

!!! proof
	
	Note that ``g\left(b\right)\ne g\left(a\right)`` otherwise, there would be some number in ``\left]a,b\right[`` where ``g\prime\left(x\right)= 0``. Hence, neither denominator above can be zero. Apply the Mean-Value theorem to
	```math
	h\left(x\right)=\left(f\left(b\right)-f\left(a\right)\right)\left(g\left(x\right)-g\left(a\right)\right)-\left(g\left(b\right)-g\left(a\right)\right)\left(f\left(x\right)-f\left(a\right)\right)\,.
	```
	Since ``h\left(a\right)=h\left(b\right)=0``, there exists ``c\in \left]a,b\right[`` such that ``h\prime\left(c\right)=0``. Thus,
	```math
	\left(f\left(b\right)-f\left(a\right)\right)g\prime\left(c\right)-\left(g\left(b\right)-g\left(a\right)\right)f\prime\left(c\right)=0\,,
	```
	and the result follows on division by the ``g`` factors.

## Indeterminate Forms

We showed that
```math
\lim_{x\to 0}\frac{\sin x}{x}=1
```

We could not readily see this by substituting ``x=0`` into the function ``\frac{\sin x}{x}`` because both ``\sin x`` and ``x`` are zero at ``x=0``. We call ``\frac{\sin x}{x}`` an indeterminate form of type ``\left[\frac{0}{0}\right]`` at ``x=0``. The limit of such an indeterminate form can be any number. There are other types of indeterminate forms:
```math
\left[\frac{\infty}{\infty}\right]\,,\quad\left[0\cdot\infty\right]\,,\quad\left[\infty-\infty\right]\,,\quad\left[0^0\right]\,,\quad\left[\infty^0\right]\,,\quad\left[1^\infty\right]\,.
```

Indeterminate forms of type ``\left[\frac{0}{0}\right]`` are the most common. You can evaluate many indeterminate forms of type ``\left[\frac{0}{0}\right]`` with simple algebra, typically by cancelling common factors. We will now develop another method called l’Hôpital’s Rules for evaluating limits of indeterminate forms of the types ``\left[\frac{0}{0}\right]`` and ``\left[\frac{\infty}{\infty}\right]``. The other types of indeterminate forms can usually be reduced to one of these two by algebraic manipulation and the taking of logarithms.

!!! theorem "The first l'Hôpital Rule"

	Suppose the functions ``f`` and ``g`` are differentiable on the interval ``\left]a,b\right[``, and ``g^\prime\left(x\right)\ne0`` there. Suppose also that
	1. ``\displaystyle\lim_{x\to a^+} f\left(x\right)=lim_{x\to a^+} g\left(x\right)=0`` and
	2. ``\displaystyle\lim_{x\to a^+}\frac{f^\prime\left(x\right)}{g^\prime\left(x\right)}=L`` where ``L`` is finite or ``\infty`` or ``-\infty``.

	Then
	```math
	lim_{x\to a^+}\frac{f\left(x\right)}{g\left(x\right)}=L\,.
	```

	Similar results hold if every occurrence of ``\lim_{x\to a^+}`` is replaced by ``\lim_{x\to b^-}`` or even ``\lim_{x\to c}`` where ``a&lt;c&lt;b``. The cases ``a=-\infty`` and ``b=\infty`` are also allowed.

!!! proof

	We prove the case involving ``\lim_{x\to a^+}`` for finite ``a``. 
	
	Define
	```math
	F\left(x\right)=\begin{cases}
		f\left(x\right)&\textrm{if }a&lt;x&ltb;\\
		0&\textrm{if }x=a
	\end{cases}\quad\textrm{and}\quad
	G\left(x\right)=\begin{cases}
		g\left(x\right)&\textrm{if }a&lt;x&ltb;\\
		0&\textrm{if }x=a
	\end{cases}\,.
	```

	Then, ``F`` and ``G`` are continuous on the interval ``\left[a,x\right]`` and differentiable on the interval ``\left]a,x\right[`` for every ``x\in \left]a,b\right[``. 
	
	By the Generalized Mean-Value theorem there exists a number ``c \in \left]a,x\right[`` such that
	```math
	\frac{f\left(x\right)}{g\left(x\right)}=\frac{F\left(x\right)}{G\left(x\right)}=\frac{F\left(x\right)-F\left(a\right)}{G\left(x\right)-G\left(a\right)}=\frac{F^\prime\left(c\right)}{G^\prime\left(c\right)}=\frac{f^\prime\left(c\right)}{g^\prime\left(c\right)}
	```

	Since ``a&lt;c&lt;x``, if ``x\to a^+``, then necessarily ``c\to a^+``, so we have
	```math
	\lim_{x\to a^+}\frac{f\left(x\right)}{g\left(x\right)}=\lim_{c\to a^+}\frac{f^\prime\left(c\right)}{g^\prime\left(c\right)}=L\,.
	```

	The case involving ``\lim_{x\to b^-}`` for finite ``b`` is proved similarly. The cases where ``a=-\infty`` or ``b=\infty`` follow from the cases already considered via the change of variable ``x=\frac{1}{t}``.

!!! example

	Evaluate ``\displaystyle \lim_{x\to \frac{\pi}{2}^-}\frac{2x-π}{\cos^2x}``.

	```math
	\lim_{x\to \frac{\pi}{2}^-}\frac{2x-π}{\cos^2x}=\lim_{x\to \frac{\pi}{2}^-}\frac{2}{-2\sin x\cos x}=-\infty\,.
	```

	Evaluate ``\displaystyle \lim_{x\to 0^+}\left(\frac{1}{x}-\frac{1}{\sin x}\right)``.

	```math
	\lim_{x\to 0^+}\left(\frac{1}{x}-\frac{1}{\sin x}\right)=\lim_{x\to 0^+}\frac{\sin x-x}{x\sin x}=\lim_{x\to 0^+}\frac{\cos x-1}{\sin x+x\cos x}=\lim_{x\to 0^+}\frac{-\sin x}{2\cos x-x\sin x}=\frac{-0}{2}=0\,.
	```

!!! theorem "The second l'Hôpital Rule"

	Suppose the functions ``f`` and ``g`` are differentiable on the interval ``\left]a,b\right[``, and ``g^\prime\left(x\right)\ne0`` there. Suppose also that
	1. ``\displaystyle\lim_{x\to a^+} g\left(x\right)=\pm\infty`` and
	2. ``\displaystyle\lim_{x\to a^+}\frac{f^\prime\left(x\right)}{g^\prime\left(x\right)}=L`` where ``L`` is finite or ``\infty`` or ``-\infty``.

	Then
	```math
	\lim_{x\to a^+}\frac{f\left(x\right)}{g\left(x\right)}=L\,.
	```

	Again, similar results hold if every occurrence of ``\lim_{x\to a^+}`` is replaced by ``\lim_{x\to b^-}`` or even ``\lim_{x\to c}`` where ``a&lt;c&lt;b``. The cases ``a=-\infty`` and ``b=\infty`` are also allowed.

Do not try to use l’Hôpital’s Rules to evaluate limits that are not indeterminate of type ``\left[\frac{0}{0}\right]`` or ``\left[\frac{\infty}{\infty}\right]``; such attempts will almost always lead to false conclusions.

## Increasing and Decreasing Functions

Intervals on which the graph of a function ``f`` has positive or negative slope provide useful information about the behaviour of ``f``. The Mean-Value theorem enables us to determine such intervals by considering the sign of the derivative ``f\prime``.

!!! definition
	
	Suppose that the function ``f`` is defined on an interval ``I`` and that ``x_1`` and ``x_2`` are two points of ``I``.
	- If ``f\left(x_2\right)&gt;f\left(x_1\right)`` whenever ``x_2&gt;x_1``, we say ``f`` is *increasing* on ``I``.
	- If ``f\left(x_2\right)&lt;f\left(x_1\right)`` whenever ``x_2&lt;x_1``, we say ``f`` is *decreasing* on ``I``.
	- If ``f\left(x_2\right)\ge f\left(x_1\right)`` whenever ``x_2&gt;x_1``, we say ``f`` is *nondecreasing* on ``I``.
	- If ``f\left(x_2\right)\le f\left(x_1\right)`` whenever ``x_2&gt;x_1``, we say ``f`` is *nonincreasing* on ``I``.

Note the distinction between increasing and nondecreasing. If a function is increasing (or decreasing) on an interval, it must take different values at different points. (Such a function is called *bijective*.) A nondecreasing function (or a nonincreasing function) may be constant on a subinterval of its domain, and may therefore not be bijective. An increasing function is nondecreasing, but a nondecreasing function is not necessarily increasing.

!!! theorem
	
	Let ``J`` be an open interval, and let ``I`` be an interval consisting of all the points in ``J`` and possibly one or both of the endpoints of ``J``: Suppose that ``f`` is continuous on ``I`` and differentiable on ``J``.
	- If ``f\prime\left(x\right)&gt;0`` for all ``x\in J``, then ``f`` is increasing on ``I``.
	- If ``f\prime\left(x\right)&lt;0`` for all ``x\in J``, then ``f`` is decreasing on ``I``.
	- If ``f\prime\left(x\right)\ge 0`` for all ``x\in J``, then ``f`` is nondecreasing on ``I``.
	- If ``f\prime\left(x\right)\le 0`` for all ``x\in J``, then ``f`` is nonincreasing on ``I``.

!!! proof
	
	Let ``x_1`` and ``x_2`` be points in ``I`` with ``x_2&gt;x_1``.
	
	By the Mean-Value theorem there exists a point ``c \in \left]x_1,x_2\right[`` (and therefore in ``J``) such that
	```math
	\frac{f\left(x_2\right)-f\left(x_1\right)}{x_2-x_1}=f\prime\left(c\right)\,;
	```
	hence, ``f\left(x_2\right)-f\left(x_1\right)=\left(x_2-x_1\right)f\prime\left(c\right)``. Since ``x_2-x_1&gt;0``, the difference ``\left.f\left(x_2\right)-f\left(x_1\right)\right.`` has the same sign as ``f\prime\left(c\right)`` and may be zero if ``f\prime\left(c\right)`` is zero. Thus, all four conclusions follow from the corresponding parts of the previous definition.

!!! example
	On what intervals is the function ``f\left(x\right)=x^3-12x+1`` increasing? On what intervals is it decreasing?

	We have ``f\prime\left(x\right)=3x^2-12=3\left(x-2\right)\left(x+2\right)``. Observe that ``f\prime\left(x\right)&gt;0`` if ``x&lt;-2`` or ``x&gt;2`` and ``f\prime\left(x\right)&lt;0`` if ``-2&lt;x&lt;2``. Therefore, ``f`` is increasing on the intervals ``\left]-\infty,-2\right[`` and ``\left]2, \infty\right[`` and is decreasing on the interval ``\left]-2,2\right[``.

If a function is constant on an interval, then its derivative is zero on that interval. The Mean-Value theorem provides a converse of this fact.

!!! theorem

	If ``f`` is continuous on an interval ``I``, and ``f\prime\left(x\right)=0`` every interior point of ``I`` (i.e., at interior point of I that is not an endpoint of ``I``), then ``f\left(x\right)=C``, a constant, on ``I``.

!!! proof

	Pick a point ``x_0`` in ``I`` and let ``C=f\left(x_0\right)``.

	If ``x`` is any other point of ``I``, then the Mean-Value theorem says that there exists a point ``c`` between ``x_0`` and ``x`` such that
	```math
	\frac{f\left(x\right)-f\left(x_0\right)}{x-x_0}=f\prime\left(x\right)\,.
	```
	The point ``c`` must belong to ``I`` because an interval contains all points between any two of its points, and ``c`` cannot be an endpoint of ``I`` since ``c\ne x_0`` and ``c\ne x``. 
	Since ``f\prime\left(c\right)=0`` for all such points ``c``, we have ``f\left(x\right)-f\left(x_0\right)=0`` for all ``x\in I``, and ``f\left(x\right)=f\left(x_0\right)=C`` as claimed.

## Extreme Values

The first derivative of a function is a source of much useful information about the behaviour of the function.

### Maximum and Minimum Values

Recall that a function has a maximum value at ``x0`` if ``f\left(x\right)\le f\left(x_0\right)`` for all ``x`` in the domain of ``f``. The maximum value is ``f\left(x_0\right)``. To be more precise, we should call such a maximum value an *absolute* or *global* maximum because it is the largest value that ``f`` attains anywhere on its entire domain.

!!! definition

	Function ``f`` has an *absolute maximum value* ``f\left(x_0\right)`` at the point ``x_0`` in its domain if ``f\left(x\right)\le f\left(x_0\right)`` holds for every ``x`` in the domain of ``f``.

	Similarly, ``f`` has an *absolute minimum value* ``f\left(x_1\right)`` at the point ``x_1`` in its domain if ``f\left(x\right)\ge f\left(x_1\right)`` holds for every ``x`` in the domain of ``f``.

Maximum and minimum values of a function are collectively referred to as *extreme values*. The following theorem is a restatement (and slight generalization) of the Extreme-Value theorem. It will prove very useful in some circumstances when we want to find extreme values.

!!! theorem

	If the domain of the function ``f`` is a closed, finite interval or a union of finitely many such intervals, and if ``f`` is continuous on that domain, then ``f`` must have an absolute maximum value and an absolute minimum value.

In addition to these extreme values, ``f`` can have several other “local” maximum and minimum values corresponding to points on the graph that are higher or lower than neighbouring points. The absolute maximum is the highest of the local maxima; the absolute minimum is the lowest of the local minima.

!!! definition

	Function ``f`` has a *local maximum value* ``f\left(x_0\right)`` at the point ``x_0`` in its domain provided there exists a number ``h &gt; 0`` such that ``f\left(x\right)\le f\left(x_0\right)`` whenever ``x`` is in the domain of ``f`` and ``\left|x-x_0\right|&lt;h``.

	Similarly, ``f`` has a *local minimum value* ``f\left(x_1\right)`` at the point ``x_1`` in its domain provided there exists a number ``h &gt; 0`` such that ``f\left(x\right)\ge f\left(x_1\right)`` whenever ``x`` is in the domain of ``f`` and ``\left|x-x_1\right|&lt;h``.

### Critical Points, Singular Points, and Endpoints

A function ``f`` can have local extreme values only at points ``x`` of three special types:

1. critical points of ``f`` (points ``x`` in the domain of ``f`` where ``f\prime\left(x\right)=0``),
2. singular points of ``f`` (points ``x`` in the domain of ``f`` where ``f\prime\left(x\right)`` is not defined), and
3. endpoints of the domain of ``f`` (points ``x`` in the domain of ``f`` that do not belong to any open interval contained in the domain of ``f``).

!!! theorem

	If the function ``f`` is defined on an interval ``I`` and has a local maximum (or local minimum) value at point ``x=x_0`` in ``I``, then ``x_0`` must be either a critical point of ``f``; a singular point of ``f``; or an endpoint of ``I``.

!!! proof

	Suppose that ``f`` has a local maximum value at ``x_0`` and that ``x_0`` is neither an endpoint of the domain of ``f`` nor a singular point of ``f``. 
	
	Then for some ``h&gt;0``, ``f\left(x\right)`` is defined on the open interval ``\left]x_0-h,x_0+h\right[`` and has an absolute maximum (for that interval) at ``x_0``. Also, ``f\prime\left(x_0\right)`` exists. By the first preliminary result of the Mean-value theorem, ``f\prime\left(x_0\right)=0``. 
	
	The proof for the case where ``f`` has a local minimum value at ``x_0`` is similar.

Although a function cannot have extreme values anywhere other than at endpoints, critical points, and singular points, it need not have extreme values at such points.

### Finding Absolute Extreme Values

If a function ``f`` is defined on a closed interval or a union of finitely many closed intervals, the Extreme-value theorem assures us that ``f`` must have an absolute maximum value and an absolute minimum value. The last theorem tells us how to find them. We need only check the values of ``f`` at any critical points, singular points, and endpoints.

!!! example

	Find the maximum and the minimum values of the function ``g\left(x\right)=x^2-3x^2-9x+2`` on the interval ``\left[-2, 2\right]``.

	Since ``g`` is a polynomial, it can have no singular points. For critical points, we calculate
	```math
	g\prime\left(x\right)=3x^2-6x-9=3\left(x^2-2x-3\right)=3\left(x+1\right)\left(x-3\right)=0
	```
	if ``x=-1`` or ``x=3``.

	However, ``x=3`` is not in the domain of ``g``, so we can ignore it. We need to consider only the values of ``g`` at the critical point ``x=-1`` and at the endpoints ``x=-2`` and ``x=2``:
	```math
	g\left(-2\right)=0\,\quad g\left(-1\right)=7\,\quad g\left(2\right)=-20\,.
	```

	The maximum value of ``g`` on ``\left[-2, 2\right]`` is ``7``, at the critical point ``x=-1``, and the minimum value is ``-20``, at the endpoint ``x=2``. 

!!! example

	Find the maximum and the minimum values of the function ``h\left(x\right)=2x^\frac{2}{3}-2x`` on the interval ``\left[-1, 1\right]``.

	The derivative of ``h`` is
	```math
	h\prime\left(x\right) = 3\left(\frac{2}{3}\right)x^{-\frac{1}{3}}-2=2\left(x^{-\frac{1}{3}}-1\right)
	```

	Note that ``x^{-\frac{1}{3}}`` is not defined at the point ``x=0`` in the domain of ``h``, so ``x=0`` is a singular point of ``h``. Also, ``h`` has a critical point where ``x^{-\frac{1}{3}}=1``, that is, at ``x=1``, which also happens to be an endpoint of the domain of ``h``. We must therefore examine the values of ``h`` at the points ``x=0`` and ``x=1``, as well as at the other endpoint ``x=-1``. We have
	```math
	h\left(-1\right)=5\,,\quad h\left(0\right)=0\,,\quad h\left(1\right)=1\,.
	```

	The function ``h`` has maximum value ``5`` at the endpoint point ``x=-1`` and minimum value ``0`` at the singular point ``x=0``.

### The First Derivative Test

Most functions you will encounter in elementary calculus have nonzero derivatives everywhere on their domains except possibly at a finite number of critical points, singular points, and endpoints of their domains. On intervals between these points the derivative exists and is not zero, so the function is either increasing or decreasing there. If ``f`` is continuous and increases to the left of ``x_0`` and decreases to the right, then it must have a local maximum value at ``x_0``. The following theorem collects several results of this type together.

!!! theorem "The First Derivative Test"

	PART I. Testing interior critical points and singular points.

	Suppose that ``f`` is continuous at ``x_0``, and ``x_0`` is not an endpoint of the domain of ``f``:

	- If there exists an open interval ``\left]a,b\right[`` containing ``x_0`` such that ``f\prime\left(x_0\right)&gt;0`` on ``\left]a,x_0\right[`` and ``f\prime\left(x_0\right)&lt;0`` on ``\left]x_0,b\right[``, then ``f`` has a local maximum value at ``x_0``.

	- If there exists an open interval ``\left]a,b\right[`` containing ``x_0`` such that ``f\prime\left(x_0\right)&lt;0`` on ``\left]a,x_0\right[`` and ``f\prime\left(x_0\right)&gt;0`` on ``\left]x_0,b\right[``, then ``f`` has a local minimum value at ``x_0``.

	PART II. Testing endpoints of the domain.

	Suppose ``a`` is a left endpoint of the domain of ``f`` and ``f`` is right continuous at ``a``.

	- If ``f\prime\left(x_0\right)&gt;0`` on some interval ``\left]a,b\right[``, then ``f`` has a local minimum value at ``a``.

	- If ``f\prime\left(x_0\right)&lt;`` on some interval ``\left]a,b\right[``, then ``f`` has a local maximum value at ``a``.

	Suppose ``b`` is a right endpoint of the domain of ``f`` and ``f`` is left continuous at ``b``.

	- If ``f\prime\left(x_0\right)&gt;`` on some interval ``\left]a,b\right[``, then ``f`` has a local maximum value at ``b``.

	- If ``f\prime\left(x_0\right)&lt;0`` on some interval ``\left]a,b\right[``, then ``f`` has a local mainimum value at ``b``.

If ``f\prime`` is positive (or negative) on both sides of a critical or singular point, then ``f`` has neither a maximum nor a minimum value at that point.

### Functions Not Defined on Closed, Finite Intervals

If the function ``f`` is not defined on a closed, finite interval, then the extended Extreme-value theorem cannot be used to guarantee the existence of maximum and minimum values for ``f``. Of course, ``f`` may still have such extreme values. In many applied situations we will want to find extreme values of functions defined on infinite and/or open intervals. 

!!! theorem

	If ``f`` is continuous on the open interval ``\left]a,b\right[``, and if
	```math
	\lim_{x\to a^+}f\left(x\right)=L\quad\textrm{and}\quad\lim_{x\to b^-}f\left(x\right)=M\,,
	```
	then the following conclusions hold:
	- If ``f\left(u\right)&gt;L`` and ``f\left(u\right)&gt;M`` for some ``u\in\left]a,b\right[``, then ``f`` has an absolute maximum value on ``\left]a,b\right[``.
	- If ``f\left(u\right)&lt;L`` and ``f\left(u\right)&lt;M`` for some ``u\in\left]a,b\right[``, then ``f`` has an absolute minimum value on ``\left]a,b\right[``.

	In this theorem ``a`` may be ``-\infty``, in which case ``\lim_{x\to a^+}`` should be replaced with ``\lim_{x\to -\infty}``, and ``b`` may be ``\infty``, in which case ``\lim_{x\to b^-}`` should be replaced with ``\lim_{x\to \infty}``.
	
	Also, either or both of ``L`` and ``M`` may be either ``\infty`` or ``-\infty``.

## Convexity/Concavity and Inflections

Like the first derivative, the second derivative of a function also provides useful information about the behaviour of the function and the shape of its graph: it determines whether the graph is *bending upward* (i.e., has increasing slope) or *bending downward* (i.e., has decreasing slope) as we move along the graph toward the right.

!!! definition

	We say that the function ``f`` is convex on an open interval ``I`` if it is differentiable there and the derivative ``f^\prime`` is an increasing function on ``I``. Similarly, ``f`` is concave ``I`` if ``f^\prime`` exists and is decreasing on ``I``.

The terms “convex” and “concave are used to describe the graph of the function as well as the function itself.

Note that convexity/concavity is defined only for differentiable functions, and even for those, only on intervals on which their derivatives are not constant. According to the above definition, a function is neither concave up nor concave down on an interval where its graph is a straight line segment. We say the function has no convexity/concavity on such an interval. We also say a function has opposite convexity/concavity on two intervals if it is convex on one interval and concave the other.


!!! definition

	We say that the point ``\left(x_0,f\left(x_0\right)\right)`` is an *inflection point* of the curve ``y=f\left(x\right)`` (or that the function ``f`` has an inflection point at ``x_0``) if the following two conditions are satisfied:

	1. the graph of ``y=f\left(x\right)`` has a tangent line at ``x=x_0``, and
	2. the convexity/concavity of ``f`` is opposite on opposite sides of ``x_0``.

Note that 1. implies that either ``f`` is differentiable at ``x_0`` or its graph has a vertical tangent line there, and 2. implies that the graph crosses its tangent line at ``x_0``. An inflection point of a function ``f`` is a point on the graph of a function, rather than a point in its domain like a critical point or a singular point. A function may or may not have an inflection point at a critical point or singular point. In general, a point ``P`` is an inflection point (or simply an inflection) of a curve ``C`` (which is not necessarily the graph of a function) if ``C`` has a tangent at ``P`` and arcs of ``C`` extending in opposite directions from ``P`` are on opposite sides of that tangent line.

If a function ``f`` has a second derivative ``f^{\prime\prime}``, the sign of that second derivative tells us whether the first derivative ``f^\prime`` is increasing or decreasing and hence determines the concavity of ``f``.

!!! theorem

	1. If ``f^{\prime\prime}\left(x\right) &gt; 0`` on interval ``I``, then ``f`` is convex on ``I``.
	2. If ``f^{\prime\prime}\left(x\right) &lt;0`` on interval ``I``, then ``f`` is concave on ``I``.
	3. if ``f`` has an inflection point at ``x_0`` and ``f^{\prime\prime}\left(x_0\right)`` exists, then ``f^{\prime\prime}\left(x_0\right)=0``.

!!! proof

	Part 1. and 2. follow from applying theorem 52 to the derivative ``f^\prime``.

	If ``f`` has an inflection point at ``x_0`` and ``f^{\prime\prime}\left(x_0\right)`` exists, then ``f`` must be differentiable in an open interval containing ``x_0``. Since ``f^\prime`` is increasing on one side of ``x_0`` and decreasing on the other side, it must have a local maximum or minimum at ``x_0``. By theorem 46, ``f^{\prime\prime}\left(x_0\right)=0``.

This theorem tells us that to find (the ``x``-coordinates of) inflection points of a twice differentiable function ``f``, we need only look at points where ``f^{\prime\prime}\left(x\right)=0``. However, not every such point has to be an inflection point. For example, ``f\left(x\right)=x^4``, does not have an inflection point at ``x=0``.

A function ``f`` will have a local maximum (or minimum) value at a critical point if its graph is concave down (or up) in an interval containing that point. In fact, we can often use the value of the second derivative at the critical point to determine whether the function has a local maximum or a local minimum value there.

!!! theorem "The Second Derivative Test"

	1. If ``f^\prime\left(x_0\right)=0`` and ``f^{\prime\prime}\left(x\right) &lt;0``, then ``f`` has a local maximum value at ``x_0``.
	2. If ``f^\prime\left(x_0\right)=0`` and ``f^{\prime\prime}\left(x\right) &gt;0``, then ``f`` has a local minimum value at ``x_0``.
	3. If ``f^\prime\left(x_0\right)=0`` and ``f^{\prime\prime}\left(x\right)=0``, no conclusion can be drawn; ``f`` may have a local maximum at ``x_0`` or a local minimum, or it may have an inflection point instead.

!!! proof

	Suppose that ``f^\prime\left(x_0\right)=0`` and ``f^{\prime\prime}\left(x\right) &lt;0``.

	Since
	```math
	\lim_{h\to 0}\frac{f^\prime\left(x_0+h\right)}{h}=\lim_{h\to 0}\frac{f^\prime\left(x_0+h\right)-f^\prime\left(x_0\right)}{h}=f^{\prime\prime}\left(x_0\right)&lt0\,,
	```
	it follows that ``f^\prime\left(x_0+h\right) &lt; 0`` for all sufficiently small positive ``h``, and ``f^\prime\left(x_0+h\right) &gt; 0`` for all sufficiently small negative ``h``. By the first derivative test, ``f`` must have a local maximum value at ``x_0``. The proof of the local minimum case is similar.

## Taylor Polynomials

### Linear Approximations

Many problems in applied mathematics are too difficult to be solved exactly—that is why we resort to using computers, even though in many cases they may only give approximate answers. However, not all approximation is done with machines. Linear approximation can be a very effective way to estimate values or test the plausibility of numbers given by a computer.

The tangent to the graph ``y=f\left(x\right)`` at ``x=a`` describes the behaviour of that graph near the point ``P=\left(a,f\left(a\right)\right)`` better than any other straight line through ``P``, because it goes through ``P`` in the same direction as the curve ``y=f\left(x\right)``. We exploit this fact by using the height to the tangent line to calculate approximate values of ``f\left(x\right)`` for values of ``x`` near ``a``. The tangent line has equation ``y=f\left(a\right)+f^\prime\left(a\right)\left(x-a\right)``. We call the right side of this equation the *linearization* of ``f`` about ``a``.

!!! definition

	The linearization of the function ``f`` about ``a`` is the function ``L`` defined by
	```math
	L\left(x\right)=f\left(a\right)+f^\prime\left(a\right)\left(x-a\right)\,.
	```

	We say that ``f\left(x\right)\approx L\left(x\right)=f\left(a\right)+f^\prime\left(a\right)\left(x-a\right)`` provides *linear approximations* for values of *f* near *a*.

We have already made use of linearization in a previous section, where it was disguised as the formula
```math
\Delta\kern-0.5pt y = \frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}\Delta\kern-0.5pt y
```
and used to approximate a small change ``\Delta\kern-0.5pt y=f\left(a+\Delta\kern-0.5pt x\right)-f\left(a\right)`` in the values of function ``f`` corresponding to the small change in the argument of the function from ``a`` to ``a+\Delta\kern-0.5pt x``. This is just the linear approximation
```math
f\left(a+\Delta\kern-0.5pt x\right)\approx L\left(x\right)=f\left(a\right)+f^\prime\left(a\right)\left(x-a\right)\,.
```

In any approximation, the *error* is defined by
```math
\textrm{error}=\textrm{true value}-\textrm{approximate value}\,.
```

If the linearization of ``f`` about ``a`` is used to approximate ``f\left(x\right)`` near ``x=a``, then the error ``E\left(x\right)`` in this approximation is
```math
E\left(x\right)=f\left(x\right)-L\left(x\right)=f\left(x\right)-f\left(a\right)-f^\prime\left(a\right)\left(x-a\right)\,.
```

It is the vertical distance at ``x`` between the graph of ``f`` and the tangent line to that graph at ``x=a``. Observe that if ``x`` is “near” ``a``, then ``E\left(x\right)`` is small compared to the horizontal distance between ``x`` and ``a``.

The following theorem gives us a way to estimate this error if we know bounds for the second derivative of ``f``:

!!! theorem

	If ``f^{\prime\prime}\left(t\right)`` exists for all ``t`` in an interval containing ``a`` and ``x``, then there exists some point ``s`` between ``a`` and ``x`` such that the error ``E\left(x\right)=f\left(x\right)-L\left(x\right)`` in the linear approximation ``f\left(x\right)\approx L\left(x\right)=f\left(a\right)+f^\prime\left(a\right)\left(x-a\right)`` satisfies
	```math
	E\left(x\right)=\frac{f^{\prime\prime}\left(s\right)}{2}\left(x-a\right)^2\,.
	```

!!! proof

	Let us assume that ``x&gt;a``. (The proof for ``x&lt;a`` is similar.)

	Since
	```math
	E\left(t\right)=f\left(t\right)-f\left(a\right)-f^\prime\left(a\right)\left(t-a\right)\,,
	```
	we have ``E^\prime\left(t\right)=f^\prime\left(t\right)-f^\prime\left(a\right)``. We apply the Generalized Mean-Value theorem to the two functions ``E\left(t\right)`` and ``\left(t-a\right)^2`` on ``\left[a,x\right]``. Noting that ``E\left(a\right)=0``, we obtain a number ``u\in\left]a,x\right[`` such that
	```math
	\frac{E\left(x\right)}{\left(x-a\right)^2}=\frac{E\left(x\right)-E\left(a\right)}{\left(x-a\right)^2-\left(a-a\right)^2}=\frac{E^\prime\left(u\right)}{2\left(u-a\right)}=\frac{f^\prime\left(u\right)-f^\prime\left(a\right)}{2\left(u-a\right)}=\frac{1}{2}f^{\prime\prime}\left(s\right)
	```
	for some ``s\in\left]a,u\right[``; the latter expression is a consequence of applying the Mean-Value theorem again, this time to ``f^\prime`` on ``\left[a,u\right]``. 
	
	Thus,
	```math
	E\left(x\right)=\frac{f^{\prime\prime}\left(s\right)}{2}\left(x-a\right)^2\,.
	```
	as claimed.

!!! example

	Use the linearization for ``\sqrt x`` about ``x=25`` to find an approximate value for ``\sqrt{26}`` and estimate the size of the error. Use these to give a small interval that you can be sure contains ``\sqrt{26}``.

	If ``f\left(x\right)=\sqrt x``, then ``f^\prime\left(x\right)=\frac{1}{2\sqrt x}``. Since we now that ``f\left(25\right)=5`` and ``f^\prime\left(25\right)=\frac{1}{10}``, the linearization of ``f\left(x\right)`` about ``x=25`` is
	```math
	L\left(x\right)=5+\frac{1}{10}\left(x-25\right)
	```

	Putting ``x=26``, we get
	```math
	\sqrt{26}=f\left(26\right)\approx L\left(26\right)=5+\frac{1}{10}\left(26-25\right)=5.1\,.
	```

	We have also ``f^{\prime\prime}\left(x\right)=-\frac{1}{4}x^{-\frac{3}{2}}``. For ``25&lt;x&lt;26``, ``f^{\prime\prime}\left(x\right)&lt;0``, so ``\sqrt{26}=f\left(26\right)&lt;L\left(26\right)=5.1``. Also, ``\left|f^{\prime\prime}\left(x\right)\right|&lt;\frac{1}{4}\frac{1}{125}=\frac{1}{500}`` and
	```math
	\left|E\left(26\right)\right|&lt;\frac{1}{2}\frac{1}{500}\left(26-25\right)^2=\frac{1}{1000}=0.001\,.
	```
	
	Therefore, ``f\left(26\right)&gt;L\left(26\right)-0.001=5.099``, and ``\sqrt{26}`` is in the interval ``\left]5.099, 5.1\right[``.

### Higher Order Approximations

The linearization of a function ``f\left(x\right)`` about ``x=a``, namely, the linear function
```math
P_1\left(x\right)=L\left(x\right)=f\left(a\right)+f^\prime\left(a\right)\left(x-a\right)\,,
```
describes the behaviour of ``f`` near ``a`` better than any other polynomial of degree ``1`` because both ``P_1`` and ``f`` have the same value and the same derivative at ``a``:
```math
P_1\left(a\right)=f\left(a\right)\quad\textrm{and}\quad P_1^\prime\left(a\right)=f^\prime\left(a\right)\,.
```

We can obtain even better approximations to ``f\left(x\right)`` by using quadratic or higherdegree polynomials and matching more derivatives at ``x=a``. For example, if ``f`` is twice differentiable near ``a``, then the polynomial
```math
P_2\left(x\right)=L\left(x\right)=f\left(a\right)+f^\prime\left(a\right)\left(x-a\right)+\frac{f^{\prime\prime}\left(a\right)}{2}\left(x-a\right)^2\,,
```
satisfies ``P_2\left(a\right)=f\left(a\right)``, ``P_2^\prime\left(a\right)=f^\prime\left(a\right)`` and ``P_2^{\prime\prime}\left(a\right)=f^{\prime\prime}\left(a\right)`` and describes the behaviour of ``f`` near ``a`` better than any other polynomial of degree at most ``2``.

In general, if ``f^{\left(n\right)}(x)`` exists in an open interval containing ``x=a``, then the polynomial
```math
P_n\left(x\right)=L\left(x\right)=\sum_{i=0}^n\frac{f^{\left(i\right)}\left(a\right)}{i!}\left(x-a\right)^i\,,
```
matches ``f`` and its first ``n`` derivatives at ``x=a``, and so describes ``f\left(x\right)`` near ``x=a`` better than any other polynomial of degree at most ``n``. ``P_n`` is called the ``n``th-order *Taylor polynomial* for ``f`` about ``a``. Taylor polynomials about ``0`` are usually called *Maclaurin polynomials*.

!!! example

	Find the Taylor polynomials ``P_1\left(x\right)``, ``P_2\left(x\right)`` and ``P_3\left(x\right)`` for ``f\left(x\right)=\sqrt x`` about ``x=25``.

	We have
	```math
	f^\prime\left(x\right)=\frac{1}{2}x^{-\frac{1}{2}}\,,\quad f^{\prime\prime}\left(x\right)=-\frac{1}{4}x^{-\frac{3}{2}}\,,\quad f^{\left(3\right)}\left(x\right)=\frac{3}{8}x^{-\frac{5}{2}}\,.
	```

	Thus,
	```math
	\begin{aligned}
	P_1\left(x\right)&=f\left(25\right)+f^\prime\left(25\right)\left(x-25\right)\\
	&=5+\frac{1}{10}\left(x-25\right)\\
	P_2\left(x\right)&=f\left(25\right)+f^\prime\left(25\right)\left(x-25\right)+\frac{f^{\prime\prime}\left(25\right)}{2}\left(x-25\right)^2\\
	&=5+\frac{1}{10}\left(x-25\right)-\frac{1}{1000}\left(x-25\right)^2\\
	P_2\left(x\right)&=f\left(25\right)+f^\prime\left(25\right)\left(x-25\right)+\frac{f^{\prime\prime}\left(25\right)}{2}\left(x-25\right)^2+\frac{f^{\left(3\right)}\left(25\right)}{3!}\left(x-25\right)^3\\
	&=5+\frac{1}{10}\left(x-25\right)-\frac{1}{1000}\left(x-25\right)^2+\frac{1}{50000}\left(x-25\right)^3
	\end{aligned}
	```

	{cell=chap display=false output=false}
	```julia
	Figure("", "Taylor polynomials (blue, green, gray) for " * tex("f\\left(x\\right)=\\sqrt x") *  " (red)." ) do
		scale = 10
		Drawing(width=52scale, height=9scale) do
			xmid = 2scale
			ymid = 7.5scale
			axis_xy(52scale,9scale,xmid,ymid,scale,(5, 10, 15, 20, 25, 30, 35, 40, 45),(2, 4, 6))
			plot_xy(x->sqrt(x), 0:0.01:50, tuple(), xmid, ymid, scale, width=1)
			plot_xy(x->5+0.1*(x-25), 0:0.01:50, tuple(), xmid, ymid, scale, width=1, color="RoyalBlue")
			plot_xy(x->5+0.1*(x-25)-0.001*(x-25)^2, 0:0.01:50, tuple(), xmid, ymid, scale, width=1, color="green")
			plot_xy(x->5+0.1*(x-25)-0.001*(x-25)^2+2e-5*(x-25)^3, 0:0.01:50, tuple(), xmid, ymid, scale, width=1, color="gray")
		end
	end
	```

!!! theorem "Taylor's theorem"

	If the ``\left(n+1\right)``st-order derivative, ``f^{\left(n+1\right)}\left(t\right)``, exists for all ``t`` in an interval containing ``a`` and ``x``, and if ``P_n\left(x\right)`` is the ``n``th order Taylor polynomial for ``f`` about ``a``, then the error ``E_n\left(x\right)=f\left(x\right)-p_n\left(x\right)`` is given by
	```math
	E_n\left(x\right)=\frac{f^{\left(n+1\right)}\left(s\right)}{\left(n+1\right)!}\left(x-a\right)^{n+1}\,,
	```
	where ``s`` is some number between ``a`` and ``x``. The resulting formula
	```math
	f\left(x\right)=\sum_{i=0}^n\frac{f^{\left(i\right)}\left(a\right)}{i!}\left(x-a\right)^i+\frac{f^{\left(n+1\right)}\left(s\right)}{\left(n+1\right)!}\left(x-a\right)^{n+1}\,,
	```
	is called Taylor's formula with Lagrange remainder.

!!! proof "by induction"

	Observe that the case ``n=0`` of Taylor's formula, namely,
	```math
	f\left(x\right)=P_0\left(x\right)+E_0\left(x\right)=f\left(a\right)+f^\prime\left(x\right)\left(x-a\right)\,.
	```
	is just the Mean-Value theorem
	```math
	\frac{f\left(x\right)-f\left(a\right)}{x-a}=f^\prime\left(s\right)
	```
	for some ``s`` between ``a`` and ``x``.

	Suppose that we have proved the case ``n=k-1``, where ``k\ge 1``. Thus, we are assuming that if ``f`` is any function whose ``k``th derivative exists on an interval containing ``a`` and ``x``, then
	```math
	E_{k-1}\left(x\right)=\frac{f^{\left(k\right)}\left(s\right)}{k!}\left(x-a\right)^k\,,
	```
	where ``s`` is some number between ``a`` and ``x``.

	Let us consider the next higher case: ``n=k``. We assume ``x&gt;a`` (the case ``x&lt;a`` is similar) and apply the generalized Mean-Value theorem to the functions ``E_k\left(t\right)`` and ``\left(t-a\right)^{k+1}`` on ``\left[a,x\right]``. Since ``E_k\left(a\right)=0``, we obtain a number ``u\in\left]a,x\right[`` such that
	```math
	\frac{E_k\left(x\right)}{\left(x-a\right)^{k+1}}=\frac{E_k\left(x\right)-E_k\left(a\right)}{\left(x-a\right)^{k+1}-\left(a-a\right)^{k+1}}=\frac{E_k^\prime\left(u\right)}{\left(k+1\right)\left(u-a\right)^{k}}\,.
	```

	Now,
	```math
	\begin{aligned}
	E_k^\prime\left(u\right)&=\left.\frac{\mathrm{d}\kern-0.1pt\hphantom{t}}{\mathrm{d}\kern-0.1pt t}\left(f\left(t\right)-f\left(a\right)-f^\prime\left(a\right)\left(t-a\right)-\frac{f^{\prime\prime}\left(a\right)}{2}\left(t-a\right)^2-\cdots-\frac{f^{\left(k\right)}\left(a\right)}{k!}\left(t-a\right)^k\right)\right|_{t=u}\\
	&=f^\prime\left(t\right)-f^\prime\left(a\right)-f^{\prime\prime}\left(a\right)\left(u-a\right)-\cdots-\frac{f^{\left(k\right)}\left(a\right)}{\left(k-1\right)!}\left(u-a\right)^{k-1}\,.
	\end{aligned}
	```
	
	This last expression is just ``E_{k-1}\left(u\right)`` for the function ``f^\prime`` instead of ``f``. By the induction assumption it is equal to
	```math
	\frac{\left(f^\prime\right)^{\left(k\right)}\left(s\right)}{k!}\left(u-a\right)^k=\frac{f^{\left(k+1\right)}\left(s\right)}{k!}\left(u-a\right)^k
	```
	for some ``s`` between ``a`` and ``u``. Therefore,
	```math
	E_k\left(x\right)=\frac{f^{\left(k+1\right)}\left(s\right)}{\left(k+1\right)!}\left(x-a\right)^{k+1}\,.
	```

	We have shown that the case ``n=k`` of Taylor’s theorem is true if the case ``n=k-1`` is true, and the inductive proof is complete.

## Antiderivatives

Throughout this chapter we have been concerned with the problem of finding the derivative ``f^\prime`` of a given function ``f``. The reverse problem—given the derivative ``f^\prime``, find ``f``—is also interesting and important. It is the problem studied in integral calculus and is generally more difficult to solve than the problem of finding a derivative. We will take a preliminary look at this problem in this section and will return to it in more detail in Chapter 6.

We begin by defining an *antiderivative* of a function ``f`` to be a function ``F`` whose derivative is ``f``: It is appropriate to require that ``F^\prime\left(x\right)=f\left(x\right)`` on an interval.

!!! definition

	An antiderivative of a function ``f`` on an interval ``I`` is another function ``F`` satisfying
	```math
	F^\prime\left(x\right)=f\left(x\right)
	```
	for ``x\in I``.

Antiderivatives are not unique; since a constant has derivative zero, you can always add any constant to an antiderivative ``F`` of a function ``f`` on an interval and get another antiderivative of ``f`` on that interval. More importantly, all antiderivatives of ``f`` on an interval can be obtained by adding constants to any particular one. If ``F`` and ``G`` are both antiderivatives of ``f`` on an interval ``I``, then
```math
\frac{\mathrm{d}\kern-0.5pt \hphantom{x}}{\mathrm{d}\kern-0.5pt x}\left(G\left(x\right)-F\left(x\right)\right)=f\left(x\right)-f\left(x\right)=0
```
on ``I``, so ``G\left(x\right)-F\left(x\right)=C`` (a constant) on I. Thus, ``G\left(x\right)=F\left(x\right)+C`` on ``I``.

Note that this conclusion is not valid over a set that is not an interval. For example, the derivative of
```math
\operatorname{sgn}\left(x\right)=\begin{cases}
	\hphantom{-}1\,,&\textrm{if } x&gt;0\\
	-1\,,&\textrm{if } x&lt;0\,.
	\end{cases}
```
is ``0`` for all ``x\ne0``, but ``\operatorname{sgn}\left(x\right)`` is not constant for all ``x\ne 0``.

The general antiderivative of a function  ``f\left(x\right)`` on an interval ``I`` is ``F\left(x\right)+C``, where ``F\left(x\right)`` is any particular antiderivative of ``f\left(x\right)`` on ``I`` and ``C`` is a constant. This general antiderivative is called the *indefinite integral* of ``f\left(x\right)`` on ``I`` and is denoted ``\int f\left(x\right)\,\mathrm d\kern-0.5pt x``.

!!! definition

	The indefinite integral of ``f\left(x\right)`` on interval ``I`` is
	```math
	\int f\left(x\right)\,\mathrm d\kern-0.5pt x=F\left(x\right)+C
	```
	on ``I``, provided ``F^\prime\left(x\right)=f\left(x\right)`` for all ``x\in I``.

The symbol ``\int`` is called an *integral sign*. It is shaped like an elongated “S” for reasons that will only become apparent when we study the definite integral in Chapter 6. Just as you regard ``\frac{\mathrm{d}\kern-0.5pt y}{\mathrm{d}\kern-0.5pt x}`` as a single symbol representing the derivative of ``y`` with respect to ``x``, so you should regard ``\int f\left(x\right)\,\mathrm d\kern-0.5pt x`` as a single symbol representing the indefinite integral (general antiderivative) of ``f`` with respect to ``x``. The constant ``C`` is called a *constant of integration*.

Finding antiderivatives is generally more difficult than finding derivatives; many functions do not have antiderivatives that can be expressed as combinations of finitely many elementary functions. However, every formula for a derivative can be rephrased as a formula for an antiderivative. For instance,
```math
\frac{\mathrm{d}\kern-0.5pt \hphantom{x}}{\mathrm{d}\kern-0.5pt x}\sin x=\cos x\,;\quad\textrm{therefore,}\quad\int\cos x\,\mathrm d\kern-0.5pt x=\sin x+C\,.
```

We will develop several techniques for finding antiderivatives in later chapters. Until then, we must content ourselves with being able to write a few simple antiderivatives based on the known derivatives of elementary functions:
```math
\begin{align}
&\int \mathrm{d}\kern-0.5pt x=\int 1\,\mathrm{d}\kern-0.5pt x=x+C&&\int x\,\mathrm{d}\kern-0.5pt x=\frac{x^2}{2}+C\\
&\int x^2\,\mathrm{d}\kern-0.5pt x=\frac{x^3}{3}+C&&\int\frac{1}{x^2}\, \mathrm{d}\kern-0.5pt x=\frac{1}{x}+C\\
&\int \frac{1}{\sqrt x}\,\mathrm{d}\kern-0.5pt x=2\sqrt x+C&&\int x^r\, \mathrm{d}\kern-0.5pt x=\frac{x^{r+1}}{r+1}+C\quad\left(r\ne1\right)\\
&\int \sin x\,\mathrm{d}\kern-0.5pt x=-\cos x+C&&\int\cos x\, \mathrm{d}\kern-0.5pt x=\sin x+C\\
&\int \sec^2 x\,\mathrm{d}\kern-0.5pt x=\tan x+C&&\int\csc^2 x\, \mathrm{d}\kern-0.5pt x=-\cot x+C
\end{align}
```

For the moment, ``r`` must be rational, but this restriction will be removed in the next chapter.

The rule for differentiating sums and constant multiples of functions translates into a similar rule for antiderivatives

The graphs of the different antiderivatives of the same function on the same interval are vertically displaced versions of the same curve. In general, only one of these curves will pass through any given point, so we can obtain a unique antiderivative of a given function on an interval by requiring the antiderivative to take a prescribed value at a particular point ``x``.

!!! example

	Find the function ``f\left(x\right)`` whose derivative is ``f^\prime\left(x\right)=6x^2-1`` for all real ``x`` and for which ``f\left(2\right)=10``.

	Since ``f^\prime\left(x\right)=6x^2-1``, we have
	```math
	f\left(x\right)=\int\left(6x^2-1\right)\,\mathrm{d}\kern-0.5pt x=2x^3-x+C
	```
	for some constant ``C``. Since ``f\left(2\right)=10``, we have
	```math
	10=f\left(2\right)=16-2+C\,.
	```

	Thus, ``C=-4`` and ``f\left(x\right)=2x^3-x-4``.
