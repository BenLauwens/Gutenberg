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
	line(x1=Ox, y1=height, x2=Ox, y2=shift_y+3, stroke="black", marker_end="url(#arrow)")
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
    scale = 60
    Drawing(width=5.5scale, height=5.5scale) do
        xmid = 0.5scale
        ymid = 5scale
        f = x->-0.5(x-2)^2+3
		x0 = 1.5
		fx0 = f(x0)
		x = 4
		fx = f(x)
        axis_xy(5.5scale,5.5scale,xmid,ymid,scale,(x0, x),tuple(), xs=("x_0","x_0+h"))
        plot_xy(f, -0.5:0.01:5.5, (1.5,), xmid, ymid, scale, width=1)
        circle(cx=xmid+x*scale, cy=ymid-fx*scale, r=3, fill="RoyalBlue", stroke="RoyalBlue")
		for y in 0:0.5:2.5
			m = (fx0 - fx - y) / (x0 - x)
			plot_xy(x->m*(x-x0)+fx0, -0.5:0.01:5.5, tuple(), xmid, ymid, scale, width=0.5, color = "black")
		end
		m = -(x0-2)
		plot_xy(x->m*(x-x0)+fx0, -0.5:0.01:5.5, tuple(), xmid, ymid, scale, width=1)
		line(x1=xmid+x0*scale, y1=ymid-fx0*scale, x2=xmid+x0*scale, y2=ymid, stroke="black", stroke_dasharray = "3")
		line(x1=xmid+x*scale, y1=ymid-fx*scale, x2=xmid+x*scale, y2=ymid, stroke="black", stroke_dasharray = "3")
		latex("C", x=xmid+0.5scale, y=ymid-2scale, width=font_x, height=font_y)
		latex("y=f\\left(x\\right)", x=xmid+0.25scale, y=ymid-1.5scale, width=4font_x, height=font_y)
		latex("P", x=xmid+x0*scale-0.5font_x, y=ymid-fx0*scale-1.25font_y, width=font_x, height=font_y)
		latex("Q", x=xmid+x*scale, y=ymid-fx*scale-font_y, width=font_x, height=font_y)
		latex("L", x=xmid+x*scale, y=ymid-4.5scale, width=font_x, height=font_y)
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
		scale = 60
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

## The Derivative

## Differentiation Rules

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
