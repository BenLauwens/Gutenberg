{data-type="chapter"}
# Integration

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

The second fundamental problem addressed by calculus is the problem of areas, that is, the problem of determining the area of a region of the plane bounded by various curves. Like the problem of tangents considered in Chapter 2, many practical problems in various disciplines require the evaluation of areas for their solution, and the solution of the problem of areas necessarily involves the notion of limits. On the surface the problem of areas appears unrelated to the problem of tangents. However, we will see that the two problems are very closely related; one is the inverse of the other. Finding an area is equivalent to finding an antiderivative or, as we prefer to say, finding an integral. The relationship between areas and antiderivatives is called the Fundamental theorem of Calculus.

## Areas as Limits of Sums

We began the study of derivatives in Chapter 4 by defining what is meant by a tangent line to a curve at a particular point. We would like to begin the study of integrals by defining what is meant by the area of a plane region, but a definition of area is much more difficult to give than a definition of tangency. Let us assume that we know intuitively what area means and list some of its properties.

1. The area of a plane region is a nonnegative real number of square units.
2. The area of a rectangle with width ``w`` and height ``h`` is ``A=wh``.
3. The areas of congruent plane regions are equal.
4. If region ``S`` is contained in region ``R``, then the area of ``S`` is less than or equal to that of ``R``.
5. If region ``R`` is a union of (finitely many) nonoverlapping regions, then the area of ``R`` is the sum of the areas of those regions.

Using these five properties we can calculate the area of any *polygon* (a region bounded by straight line segments). First, we note that properties (2) and (3) show that the area of a parallelogram is the same as that of a rectangle having the same base width and height. Any triangle can be butted against a congruent copy of itself to form a parallelogram, so a triangle has area half the base width times the height. Finally, any polygon can be subdivided into finitely many nonoverlapping triangles so its area is the sum of the areas of those triangles.

We can’t go beyond polygons without taking limits. If a region has a curved boundary, its area can only be approximated by using rectangles or triangles; calculating the exact area requires the evaluation of a limit. We showed how this could be done for a circle in Section 3.1.

We are going to consider how to find the area of a region ``R`` lying under the graph ``y=f\left(x\right)`` of a nonnegative-valued, continuous function ``f``, above the ``x``-axis and between the vertical lines ``x=a`` and ``x=b``, where ``a&lt;b``. To accomplish this, we proceed as follows. Divide the interval ``\left[a,b\right]`` into ``n`` subintervals by using division points:

```math
a=x_0&lt;x_1&lt;x_2&lt;x_3&lt;\cdots&lt;x_{n-1}&lt;x_n=b
```

Denote by ``\Delta x_i`` the length of the ``i``th subinterval ``\left[x_{i-1},x_i\right]``:

```math
\Delta x_i=x_i-x_{i-1},\quad\forall i\in\left\{1,2,3,\dots,n\right\}\,.
```

Vertically above each subinterval ``\left[x_{i-1},x_i\right]`` build a rectangle whose base has length ``\Delta x_i`` and whose height is ``f\left(x_i\right)``. The area of this rectangle is ``f\left(x_i\right)\Delta x_i``. Form the sum of these areas:

```math
S_n=\sum_{i=1}^n f\left(x_i\right)\Delta x_i\,.
```

{cell=chap display=false output=false}
```julia
Figure("", "Approximating the area under the graph of a decreasing function using rectangles." ) do
	scale = 30
	Drawing(width=12scale, height=5.5scale) do
		xmid = scale
		ymid = 4.5scale
		x = (1, 2.0, 2.8, 4.1, 5, 6.2, 7, 7.9, 9.1, 10)
		f = x->3*(1/x + 0.25)
		axis_xy(12scale,5scale,xmid,ymid,scale,x,tuple();xs=("x_0", "x_1", "x_2", "x_3", "", "x_{i-1}", "x_i", "", "x_{n-1}", "x_n"))
		for i in 2:length(x)
			polygon(points="$(xmid+scale*x[i-1]), $(ymid-scale*0) $(xmid+scale*x[i-1]), $(ymid-scale*f(x[i])) $(xmid+scale*x[i]), $(ymid-scale*f(x[i])) $(xmid+scale*x[i]), $(ymid-scale*0)", fill="lightblue", stroke="RoyalBlue")
		end
		plot_xy(f, 0.01:0.01:11, tuple(), xmid, ymid, scale; width=1)
	end
end
```

The rectangles are shown shaded in the figure for a decreasing function ``f``. For an increasing function, the tops of the rectangles would lie above the graph of ``f`` rather than below it. Evidently, ``S_n`` is an approximation to the area of the region ``R``, and the approximation gets better as ``n`` increases, provided we choose the points ``a=x_0&lt;x_1&lt;x_2&lt;x_3&lt;\cdots&lt;x_{n-1}&lt;x_n=b`` in such a way that the width ``\Delta x_i`` of the widest rectangle approaches zero.

Subdividing a subinterval into two smaller subintervals reduces the error in the approximation by reducing that part of the area under the curve that is not contained in the rectangles. It is reasonable, therefore, to calculate the area of ``R`` by finding the limit of ``S_n`` as ``n`` with the restriction that the largest of the subinterval widths ``\Delta x_i`` must approach zero:

```math
\textrm{Area of }R=\lim_{
	\begin{aligned}n&\to\infty\\
\max &\Delta x_i\to 0
\end{aligned}
}S_n\,.
```

## The Definite Integral

We generalize and make more precise the procedure used for finding areas developed in the previous section, and we use it to define the *definite integral* of a function *f* on an interval *I*:

Let a partition ``P`` of ``\left[a,b\right]`` be a finite, ordered set of points ``P=\left\{x_0,x_1,x_2,\dots,x_n\right\}`` , where ``a=x_0&lt;x_1&lt;x_2&lt;x_3&lt;\cdots&lt;x_{n-1}&lt;x_n=b``. Such a partition subdivides ``\left[a,b\right]`` into ``n`` subintervals ``\left[x_{i-1},x_i\right]``, where ``n=n\left(P\right)`` depends on the partition. The length of the ``i``th subinterval ``\left[x_{i-1},x_i\right]`` is ``\Delta x_i=x_i-x_{i-1}``.

Suppose that the function ``f`` is bounded on ``\left[a,b\right]``. Given any partition ``P``, the ``n`` sets ``S_i=\left\{f\left(x\right)\mid x_{i-1}\le x\le x_i\right\}`` have least upper bounds ``M_i`` and greatest lower bounds ``m_i``, so that

```math
m_j\le f\left(x\right)\le M_i\quad\forall x\in\left[x_{i-1},x_i\right]\,.
```

We define *upper* and *lower Riemann sums* for ``f`` corresponding to the partition ``P`` to be

```math
U\left(f,P\right)=\sum_{i=1}^{n\left(P\right)}M_i\Delta x_i\quad\textrm{and}\quad L\left(f,P\right)=\sum_{i=1}^{n\left(P\right)}m_i\Delta x_i\,.
```

{cell=chap display=false output=false}
```julia
Figure("", "Upper and lower sums corresponding to the partition " * tex("P=\\left\\{x_0,x_1,x_2,x_3\\right\\}") * " ." ) do
	scale = 40
	Drawing(width=12scale, height=4.5scale) do
		xmid = 0.5scale
		ymid = 4scale
		x = (1, 2.25, 3, 4.5)
		f1 = x->x
		f2 = x->(x-4)^2+1.5
		yh = (0, f1(2.25), f2(2.5), f2(3))
		yl = (0, f1(1), f1(2.25), f2(4))
		for i in 2:length(x)
			polygon(points="$(xmid+scale*x[i-1]), $(ymid-scale*0) $(xmid+scale*x[i-1]), $(ymid-scale*yh[i]) $(xmid+scale*x[i]), $(ymid-scale*yh[i]) $(xmid+scale*x[i]), $(ymid-scale*0)", fill="lightgreen", stroke="green")
		end
		axis_xy(5.5scale,5.5scale,xmid,ymid,scale,x,tuple(); xs=("x_0", "x_1", "x_2", "x_3"))
		plot_xy(f1, 1:0.01:2.5, tuple(1), xmid, ymid, scale; width=1)
		plot_xy(f2, 2.5:0.01:4.5, tuple(4.5), xmid, ymid, scale; width=1)
		circle(cx=xmid+scale*2.5, cy=ymid-scale*f1(2.5), r=3, fill="white", stroke="red")
		circle(cx=xmid+scale*2.5, cy=ymid-scale*(f1(2.5)+f2(2.5))/2, r=3, fill="red", stroke="red")
		circle(cx=xmid+scale*2.5, cy=ymid-scale*f2(2.5), r=3, fill="white", stroke="red")
		xmid = 7scale
		for i in 2:length(x)
			polygon(points="$(xmid+scale*x[i-1]), $(ymid-scale*0) $(xmid+scale*x[i-1]), $(ymid-scale*yl[i]) $(xmid+scale*x[i]), $(ymid-scale*yl[i]) $(xmid+scale*x[i]), $(ymid-scale*0)", fill="lightblue", stroke="RoyalBlue")
		end
		axis_xy(5.5scale,5.5scale,xmid,ymid,scale,x,tuple(); shift_x=6.5scale, xs=("x_0", "x_1", "x_2", "x_3"))
		plot_xy(f1, 1:0.01:2.5, tuple(1), xmid, ymid, scale; width=1)
		plot_xy(f2, 2.5:0.01:4.5, tuple(4.5), xmid, ymid, scale; width=1)
		circle(cx=xmid+scale*2.5, cy=ymid-scale*f1(2.5), r=3, fill="white", stroke="red")
		circle(cx=xmid+scale*2.5, cy=ymid-scale*(f1(2.5)+f2(2.5))/2, r=3, fill="red", stroke="red")
		circle(cx=xmid+scale*2.5, cy=ymid-scale*f2(2.5), r=3, fill="white", stroke="red")
	end
end
```

Note that if ``f`` is continuous on ``\left[a,b\right]``, then ``m_i`` and ``M_i`` are, in fact, the minimum and maximum values of ``f`` over ``\left[x_{i-1},x_i\right]`` by the Extreme-Value theorem, that is, ``m_i=f\left(l_i\right)`` and ``M_i=\left(u_i\right)``, where ``f\left(l_i\right)\le f\left(x\right)\le f\left(u_i\right)`` for ``x\in \left[x_{i-1},x_i\right]``.

!!! example

	Calculate the lower and upper Riemann sums for the function ``f\left(x\right)=x^2`` on the interval ``\left[0,a\right]`` (where ``a &gt; 0``), corresponding to the partition ``P_n`` of ``\left[0,a\right]`` into ``n`` subintervals of equal length.

	Each subinterval of ``P_n`` has length ``\Delta x=\frac{a}{n}``, and the division points are given by ``x_i=\frac{ia}{n}`` for ``i= 0, 1, 2,\dots, n``. Since ``x^2`` is increasing on ``\left[0,a\right]``, its minimum and maximum values over the ``i``th subinterval ``\left[x_{i-1},x_i\right]`` occur at ``l_i=x_{i-1}`` and ``u_i=x_i``, respectively. Thus, the lower Riemann sum of ``f`` for ``P_n`` is

	```math
	\begin{aligned}
	L\left(f,P_n\right)&=\sum_{i=1}^nx_{i-1}^2\Delta x=\frac{a^3}{n^3}\sum_{i=1}^n\left(i-1\right)^2\\
	&=\frac{a^3}{n^3}\sum_{j=0}^{n-1}j^2=\frac{a^3}{n^3}\frac{\left(n-1\right)n\left(2\left(n-1\right)+1\right)}{6}=\frac{\left(n-1\right)\left(2n-1\right)a^3}{6n^2}
	\end{aligned}
	```

	where we have used

	```math
	\sum_{i=1}^ni^2=\frac{n\left(n+1\right)\left(2n+1\right)}{6}
	```

	to evaluate the sum of squares. Similarly, the upper Riemann sum is

	```math
	\begin{aligned}
	U\left(f,P_n\right)&=\sum_{i=1}^nx_i^2\Delta x\\
	&=\frac{a^3}{n^3}\sum_{i=1}^ni^2=\frac{a^3}{n^3}\frac{n\left(n+1\right)\left(2n+1\right)}{6}=\frac{\left(n+1\right)\left(2n+1\right)a^3}{6n^2}\,.
	\end{aligned}
	```

If ``P`` is any partition of ``\left[a,b\right]`` and we create a new partition ``P^\diamond`` by adding new subdivision points to those of ``P``, thus subdividing the subintervals of ``P`` into smaller ones, then we call ``P^\diamond`` a *refinement* of ``P``.

!!! theorem

	If ``P^\diamond`` is a refinement of ``P``, then ``L\left(f,P^\diamond\right)\ge L\left(f,P\right)`` and ``U\left(f,P^\diamond\right)\le U\left(f,P\right)``.

If ``S`` and ``T`` are sets of real numbers, and ``S\subset T``, then any lower bound (or upper bound) of ``T`` is also a lower bound (or upper bound) of ``S``. Hence, the greatest lower bound of ``S`` is at least as large as that of ``T``; and the least upper bound of ``S`` is no greater than that of ``T``.

!!! proof

	Let ``P`` be a given partition of ``\left[a,b\right]`` and form a new partition ``P^\prime`` by adding one subdivision point to those of ``P``, say, the point ``k`` dividing the ``i``th subinterval ``\left[x_{i-1},x_i\right]`` of ``P`` into two subintervals ``\left[x_{i-1},k\right]`` and ``\left[x_{i-1},k\right]``.

	Let ``m_i``, ``m_i^\prime`` and ``m_i^{\prime\prime}`` be the greatest lower bounds of the sets of values of ``f\left(x\right)``  on the intervals ``\left[x_{i-1},x_i\right]``, ``\left[x_{i-1},k\right]`` and ``\left[k,x_i\right]``, respectively. Then ``m_i\le m_i^\prime`` and ``m_i\le m_i^{\prime\prime}``.

	Thus,

	```math
	m_i\left(x_i-x_{i-1}\right)\le m_i^\prime\left(k-x_{i-1}\right)+m_i^{\prime\prime}\left(x_i-k\right)\,,
	```

	so ``L\left(f,P\right)\le L\left(f,P^\prime\right)``.

	If ``P^\diamond`` is a refinement of ``P``, it can be obtained by adding one point at a time to those of ``P`` and thus ``L\left(f,P\right)\le L\left(f,P^\diamond\right)``.
	
	We can prove that ``U\left(f,P^\diamond\right)\le U\left(f,P\right)`` in a similar manner.

!!! theorem

	If ``P`` and ``P^\prime`` are two partitions of ``\left[a,b\right]``, then ``L\left(f,P\right)\le U\left(f,P^\prime\right)``.

!!! proof

	Combine the subdivision points of ``P`` and ``P^\prime`` to form a new partition ``P^\diamond``, which is a refinement of both ``P`` and ``P^\prime``. Then by the previous theorem,

	```math
	L\left(f,P\right)\le L\left(f,P^\diamond\right)\le U\left(f,P^\diamond\right)\le U\left(f,P^\prime\right)\,.
	```

	No lower sum can exceed any upper sum.

The last theorem shows that the set of values of ``L\left(f, P\right)`` for fixed ``f`` and various partitions ``P`` of ``\left[a,b\right]`` is a bounded set; any upper sum is an upper bound for this set. By completeness, the set has a least upper bound, which we shall denote ``I_\star``. Thus, ``L\left(f,P\right)\le I_\star`` for any partition ``P``. Similarly, there exists a greatest lower bound ``I^\star`` for the set of values of ``U\left(f, P\right)`` corresponding to different partitions ``P``. 

!!! theorem

	``I_\star\le I^\star``.

!!! proof

	Let ``S`` and ``T`` be sets of real numbers, such that for any ``x\in S`` and any ``y\in T`` we have ``x\le y``. 
	
	Because every ``x`` is a lower bound of ``T``,  we have ``x\le\inf T``.

	Because ``\inf T`` is an upper bound of ``S``, we have ``\sup S\le\inf T``.

	Therefore,
	
	```math
	x\le \sup S\le \inf T \le y\,.
	```

	Applying this result to the set of values of ``L\left(f, P\right)`` and ``U\left(f, P\right)`` for fixed ``f`` and various partitions ``P``, we find using the previous theorem

	```math
	\sup L\left(f, P\right)=I_\star\le I^\star=\inf U\left(f, P\right)\,.
	```

!!! definition

	If ``f`` is bounded on ``\left[a,b\right]`` and ``I_\star=I^\star``, then we say that ``f`` is *Darboux integrable*, or simply integrable on ``\left[a,b\right]``, and denote by

	```math
	\int_a^b f\left(x\right)\,\mathrm{d} x=I_\star=I^\star
	```

	the (*Darboux*) *integral* of ``f`` on ``\left[a,b\right]\,.``

The definite integral of ``f\left(x\right)`` over ``\left[a,b\right]`` is a number; it is not a function of ``x``. It depends on the numbers ``a`` and ``b`` and on the particular function ``f``, but not on the variable ``x`` (which is a *dummy variable* like the variable ``i`` in the sum ``\sum_{i=1}^nf\left(i\right)``). Replacing ``x`` with another variable does not change the value of the integral:

```math
\int_a^b f\left(x\right)\,\mathrm{d} x=\int_a^b f\left(t\right)\,\mathrm{d} t\,.
```

The various parts of the symbol ``\int_a^b f\left(x\right)\,\mathrm{d} x`` have their own names:

- ``\int`` is called the *integral sign*; it resembles the letter ``S`` since it represents the limit of a sum.

- ``a`` and ``b`` are called the *limits of integration*; ``a`` is the *lower limit*, ``b`` is the *upper limit*.

- The function ``f`` is the *integrand*; ``x`` is the *variable of integration*.

- ``\mathrm{d} x`` is the *differential of ``x``*. It replaces ``x`` in the Riemann sums. If an integrand depends on more than one variable, the differential tells you which one is the variable of integration.

!!! example

	Show that ``f\left(x\right)=x^2`` is integrable over the interval ``\left[0,a\right]`` (where ``a &gt; 0``), and evaluate

	```math
	I=\int_0^a f\left(x\right)\,\mathrm{d} x
	```

	We evaluate the limits as ``n\to\infty`` of the lower and upper sums of ``f`` over ``\left[0,a\right]`` obtained in the previous example.

	```math
	\begin{aligned}
	\lim_{n\to\infty}L\left(f,P_n\right)&=\lim_{n\to\infty}\frac{\left(n-1\right)\left(2n-1\right)a^3}{6n^2}=\frac{a^3}{3}\,,\\
	\lim_{n\to\infty}U\left(f,P_n\right)&=\lim_{n\to\infty}\frac{\left(n+1\right)\left(2n+1\right)a^3}{6n^2}=\frac{a^3}{3}\,.
	\end{aligned}
	```

	Since ``L\left(f,P_n\right)\le I\le U\left(f,P_n\right)``, we must have ``I=\frac{a^3}{3}``. Thus, ``f\left(x\right)=x^2`` is integrable over ``\left[0,a\right]``, and

	```math
	\int_0^a f\left(x\right)\,\mathrm{d} x=\int_0^a x^2\,\mathrm{d} x=\frac{a^3}{3}\,.
	```

Let ``P=\left\{x_0,x_1,x_2,\dots,x_n\right\}``, where ``a=x_0&lt;x_1&lt;x_2&lt;\dots&lt;x_n=b``, be a partition of ``\left[a,b\right]``. In each subinterval ``\left[x_{i-1},x_i\right]`` of ``P`` pick a point ``c_i`` (called a *tag*). Let ``c=\left(c_1,c_2,\dots,c_n\right)`` denote the list of these tags. The sum

```math
\begin{aligned}
R\left(f,P,c\right)&=\sum_{i=1}^nf\left(c_i\right)\Delta x\\
&=f\left(c_1\right)\Delta x_1+f\left(c_2\right)\Delta x_2+\cdots+f\left(c_n\right)\Delta x_n
\end{aligned}
```

is called the *Riemann sum* of ``f`` on ``\left[a,b\right]`` corresponding to partition ``P`` and tags ``c``.

For any choice of the tags ``c``, the Riemann sum ``F\left(f,P,c\right)`` satisfies

```math
L\left(f,P\right)\le R\left(f,P,c\right)\le U\left(f,P\right)
```

Therefore, if ``f`` is integrable on ``\left[a,b\right]``, then its integral is the limit of such Riemann sums, where the limit is taken as the number ``n\left(P\right)`` of subintervals of ``P`` increases to infinity in such a way that the lengths of all the subintervals approach zero. That is,

```math
\int_a^b f\left(x\right)\,\mathrm{d} x=\lim_{\begin{aligned}n&\to\infty\\\max &\Delta x_i\to 0\end{aligned}}\sum_{i=1}^n f\left(c_i\right)\Delta x_i\,,
```

where ``c_i`` is an arbitrary point in ``\left[x_{i-1},x_i\right]``. The Darboux integral is easier to use than the more intuitive *Riemann integral* but many applications of integration depend on recognizing that a limit of Riemann sums is a definite integral.

The following theorem provides a convenient test for determining whether a given bounded function is integrable.

!!! theorem "Darboux's Integrability Condition"

	The bounded function ``f`` is integrable on ``\left[a,b\right]`` if and only if for every positive number ``\varepsilon`` there exists a partition ``P`` of ``\left[a,b\right]`` such that ``U\left(f,P\right)-L\left(f,P\right)&lt;\varepsilon``.

!!! proof

	Suppose that for every ``\varepsilon &gt;0`` there exists a partition ``P`` of ``\left[a,b\right]`` such that ``U\left(f,P\right)-L\left(f,P\right)&lt;\varepsilon``, then

	```math
	I^\star\le U\left(f,P\right)&lt;L\left(f, P\right)+\varepsilon\le I_\star +\varepsilon
	```

	Since ``I^\star&lt; I_\star +\varepsilon`` must hold for every ``\varepsilon &gt;0``, it follows that ``I^\star\le I_\star``. Since we already know that ``I_\star\le I^\star``, we have ``I_\star= I^\star`` and ``f`` is integrable on ``\left[a,b\right]``.

	Conversely, if ``I_\star= I^\star`` and ``\varepsilon &gt;0`` are given, we can find a partition ``P^\prime`` such that ``L\left(f,P^\prime\right)&gt;I_\star-\frac{\varepsilon}{2}``, and another partition ``P^{\prime\prime}`` such that ``U\left(f,P^{\prime\prime}\right)&lt;I^\star+\frac{\varepsilon}{2}``. If ``P`` is a common refinement of ``P^\prime`` and ``P^{\prime\prime}``, then by the first theorem of this section we have that

	```math
	U\left(f,P\right)-L\left(f, P\right)\le U\left(f,P^{\prime\prime}\right)-L\left(f, P^\prime\right)&lt;\frac{\varepsilon}{2}+\frac{\varepsilon}{2}=\varepsilon\,,
	```

	as required.

We are now in a position to prove that a continuous function is integrable.

!!! theorem

	If ``f`` is continuous on ``\left[a,b\right]``, then ``f`` is integrable on ``\left[a,b\right]``.

!!! proof

	Let ``\varepsilon&gt;0``.

	For each ``x \in \left[a, b\right]``, since ``f`` is continuous at ``x``, there exists an open interval ``I_x=\left]x-\delta_x, x+\delta_x\right[`` such that for all ``y \in I_x \cap \left[a, b\right]`` we have ``\left|f\left(y\right) - f\left(x\right)\right| &lt; \frac{\varepsilon}{2\left(b-a\right)}``.

	The set of all such open intervals ``I_x`` forms an open cover of ``\left[a,b\right]``.

    By the Heine-Borel theorem there exists a finite subcover such that ``\left[a,b\right]\subset\bigcup_{i=0}^nI_{x_i}``.

	Now, create a partition ``P`` of ``\left[a,b\right]`` using the endpoints of these intervals that lie within ``\left[a,b\right]``. Specifically, our partition points will be: ``a = y_0 &lt; y_1 &lt; y_2 &lt; \dots &lt; y_m = b``.

	Consider any subinterval ``\left[y_{j-1},y_j\right]`` in this partition. 

	Since the function is continuous on all closed subintervals of ``\left[a,b\right]``, we have by the Extreme-Value theorem 
	
	```math
	M_j = \max\left\{f\left(y\right)\mid y \in \left[y_{j-1},y_j\right]\right\}\quad\textrm{and}\quad m_j = \min\left\{f\left(y\right)\mid y \in \left[y_{j-1},y_j\right]\right\}\,.
	```

	Since this subinterval is entirely contained within at least one of our original open intervals ``I_{x_i}``, we have 

	```math
	M_j-m_j = \left(M_j-f\left(x_i\right)\right) + \left(f\left(x_i\right)-m_j\right) &lt; \frac{\varepsilon}{2\left(b-a\right)} + \frac{\varepsilon}{2\left(b-a\right)}=\frac{\varepsilon}{\left(b-a\right)}\,.
	```

	Calculate the difference between the upper and lower Riemann sums for this partition:

	```math
	U\left(f, P\right)-L\left(f, P\right)=\sum_{j=1}^m\left(M_j-m_j\right)\left(x_j-x_{j-1}\right)&lt;\frac{\varepsilon}{\left(b-a\right)}\sum_{j=1}^m\left(x_j-x_{j-1}\right)=\varepsilon\,.
	```

	By the Darboux's Integrability condition, ``f`` is integrable on ``\left[a,b\right]``.

## Properties of the Definite Integral

It is convenient to extend the definition of the definite integral ``\int_a^bf\left(x\right)\,\mathrm{d} x`` to allow ``a=b`` and ``a&gt;b`` as well as ``a&lt; b``. The extension still involves partitions ``P`` having ``x_0=a`` and ``x_n=b`` with intermediate points occurring in order between these end points, so that if ``a=b``, then we must have ``\Delta x_i=0`` for every ``i``, and hence the integral is zero. If ``a&gt;b``, we have ``\Delta x_i&lt; 0`` for each ``i``, so the integral will be negative for positive functions ``f`` and vice versa.

### Basic Properties

Some of the most important properties of the definite integral are summarized in the following theorem.

!!! theorem

	Let ``f`` and ``g`` be integrable on an interval containing the points ``a``, ``b``, and ``c``.

	1. ``\displaystyle\int_a^af\left(x\right)\,\mathrm{d} x=0\,.``

	2. ``\displaystyle\int_b^af\left(x\right)\,\mathrm{d} x=-\displaystyle\int_a^bf\left(x\right)\,\mathrm{d} x\,.``

	3. ``\displaystyle\int_a^b\left(Af\left(x\right)+Bg\left(x\right)\right)\,\mathrm{d} x=A\int_a^bf\left(x\right)\,\mathrm{d} x+B\int_a^bg\left(x\right)\,\mathrm{d} x\,.``

	4. ``\displaystyle\int_a^bf\left(x\right)\,\mathrm{d} x+\int_b^cf\left(x\right)\,\mathrm{d} x=\int_a^cf\left(x\right)\,\mathrm{d} x\,.``

	5. If ``a\le b`` and ``f\left(x\right)\le g\left(x\right)`` for ``x\in\left[a,b\right]``, then ``\int_a^bf\left(x\right)\,\mathrm{d} x\le\int_a^bg\left(x\right)\,\mathrm{d} x\,.``

	6. If ``a\le b``, ``\displaystyle\left|\int_a^bf\left(x\right)\,\mathrm{d} x\right|\le\int_a^b\left|f\left(x\right)\right|\,\mathrm{d} x`` (*triangle inequality*).
	
The proofs of parts (1) and (2) are suggested in the first paragraph of this section. The other proofs are more challenging. We will start with the integrability of the sum of two integrable functions

```math
\displaystyle\int_a^b\left(f\left(x\right)+g\left(x\right)\right)\,\mathrm{d} x=\int_a^bf\left(x\right)\,\mathrm{d} x+\int_a^bg\left(x\right)\,\mathrm{d} x\,.
```

!!! proof

	Let ``\varepsilon > 0``. 
	
	By the Darboux condition of integrability, there are partitions ``P_1`` and ``P_2`` of ``\left[a,b\right]`` such that

	```math
	U\left(f,P_1\right)-L\left(f,P_1\right)&lt;\frac{\varepsilon}{2}\quad\textrm{and}\quad U\left(g,P_2\right)-L\left(g,P_2\right)&lt;\frac{\varepsilon}{2}\,.
	```

	If ``P=P_1\cup P_2``, then

	```math
	U\left(f,P\right)-L\left(f,P\right)&lt;\frac{\varepsilon}{2}\quad\textrm{and}\quad U\left(g,P\right)-L\left(g,P\right)&lt;\frac{\varepsilon}{2}\,.
	```

	For any interval ``\left[x_{i-1},x_i\right]\in\left[a,b\right]``, we have

	```math
	\inf\left\{f\left(x\right)\mid x\in \left[x_{i-1},x_i\right]\right\}+\inf\left\{g\left(x\right)\mid x\in \left[x_{i-1},x_i\right]\right\}\le\inf\left\{f\left(x\right)+g\left(x\right)\mid x\in\left[x_{i-1},x_i\right]\right\}
	```

	and

	```math
	\sup\left\{f\left(x\right)\mid x\in \left[x_{i-1},x_i\right]\right\}+\sup\left\{g\left(x\right)\mid x\in \left[x_{i-1},x_i\right]\right\}\ge\sup\left\{f\left(x\right)+g\left(x\right)\mid x\in \left[x_{i-1},x_i\right]\right\}\,.
	```

	It follows that

	```math
	L\left(f,P\right)+ L\left(g,P\right)\le L\left(f+g,P\right)\quad\textrm{and}\quad U\left(f,P\right)+ U\left(g,P\right)\ge U\left(f+g,P\right)\,.
	```

	Therefore, 

	```math
	U\left(f+g,P\right)-L\left(f+g,P\right)\le U\left(f,P\right)-L\left(f,P\right)+ U\left(g,P\right)-L\left(g,P\right)&lt;\varepsilon
	```

	This shows that ``f+g`` is integrable on ``\left[a,b\right]``.

	Since

	```math
	\begin{aligned}
	\int_a^b\left(f\left(x\right)+g\left(x\right)\right)\,\mathrm{d} x&=I^\star\left(f+g\right)\le U\left(f+g,P\right)\le U\left(f,P\right)+ U\left(g,P\right)\\
	&&lt;L\left(f,P\right)+ L\left(g,P\right)+\varepsilon\\
	&\le I_\star\left(f\right)+I_\star\left(g\right)+\varepsilon=\int_a^bf\left(x\right)\,\mathrm{d} x+\int_a^bg\left(x\right)\,\mathrm{d} x+\varepsilon
	\end{aligned}
	```

	and

	```math
	\begin{aligned}
	\int_a^b\left(f\left(x\right)+g\left(x\right)\right)\,\mathrm{d} x&=I_\star\left(f+g\right)\ge L\left(f+g,P\right)\ge L\left(f,P\right)+ L\left(g,P\right)\\
	&&gt;U\left(f,P\right)+ U\left(g,P\right)-\varepsilon\\
	&\ge I^\star\left(f\right)+I^\star\left(g\right)-\varepsilon=\int_a^bf\left(x\right)\,\mathrm{d} x+\int_a^bg\left(x\right)\,\mathrm{d} x-\varepsilon
	\end{aligned}
	```

	are true for all ``\varepsilon``, we have

	```math
	\int_a^b\left(f\left(x\right)+g\left(x\right)\right)\,\mathrm{d} x=\int_a^bf\left(x\right)\,\mathrm{d} x+\int_a^bg\left(x\right)\,\mathrm{d} x\,.
	```

!!! exercise

	Prove the integrability of a constant times an integrable function

	```math
	\displaystyle\int_a^b\left(Af\left(x\right)\right)\,\mathrm{d} x=A\int_a^bf\left(x\right)\,\mathrm{d} x\,.
	```

	Hint: consider the cases ``A`` positive and negative.

Now, we will prove the additive dependency of an integral on the interval of integration

```math
\int_a^bf\left(x\right)\,\mathrm{d} x+\int_b^cf\left(x\right)\,\mathrm{d} x=\int_a^cf\left(x\right)\,\mathrm{d} x\,.
```

!!! proof

	Since ``f`` is bounded on both ``\left[a,b\right]`` and ``\left[b,c\right]``, ``f`` is bounded on ``\left[a,c\right]``. In this proof we will decorate lower and upper sums so that it will be clear which intervals we are dealing with.

	Let ``\varepsilon&gt;0``.

	There exists partitions ``P_1`` of ``\left[a,b\right]`` and ``P_2`` of ``\left[b,c\right]`` such that

	```math
	U_a^b\left(f,P_1\right)-L_a^b\left(f,P_1\right)&lt;\frac{\varepsilon}{2}\quad\textrm{and}\quad U_b^c\left(f,P_2\right)-L_b^c\left(f,P_2\right)&lt;\frac{\varepsilon}{2}\,.
	```

	The set ``P=P_1\cup P_2`` is a partition of ``\left[a,c\right]``, and

	```math
	U_a^c\left(f,P\right)=U_a^b\left(f,P_1\right)+U_b^c\left(f,P_2\right)\quad\textrm{and}\quad L_a^c\left(f,P\right)=L_a^b\left(f,P_1\right)+L_b^c\left(f,P_2\right)\,.
	```

	It follows that

	```math
	U_a^c\left(f,P\right)-L_a^c\left(f,P\right)&lt;\varepsilon\,,
	```

	so ``f`` is integrable on ``\left[a,c\right]``.

	Since

	```math
	\begin{aligned}
	\int_a^cf\left(x\right)\,\mathrm{d} x&\le U_a^c\left(f, P\right)=U_a^b\left(f,P_1\right)+U_b^c\left(f,P_2\right)\\
	&&lt;L_a^b\left(f,P_1\right)+L_b^c\left(f,P_2\right)+\varepsilon\le\int_a^bf\left(x\right)\,\mathrm{d} x+\int_b^cf\left(x\right)\,\mathrm{d} x+\varepsilon
	\end{aligned}
	```

	and 

	```math
	\begin{aligned}
	\int_a^cf\left(x\right)\,\mathrm{d} x&\ge L_a^c\left(f, P\right)=L_a^b\left(f,P_1\right)+L_b^c\left(f,P_2\right)\\
	&&gt;U_a^b\left(f,P_1\right)+U_b^c\left(f,P_2\right)-\varepsilon\ge\int_a^bf\left(x\right)\,\mathrm{d} x+\int_b^cf\left(x\right)\,\mathrm{d} x-\varepsilon
	\end{aligned}
	```

	are true for all ``\varepsilon``, we have

	```math
	\int_a^bf\left(x\right)\,\mathrm{d} x+\int_b^cf\left(x\right)\,\mathrm{d} x=\int_a^cf\left(x\right)\,\mathrm{d} x\,.
	```

!!! exercise

	Prove the integrability of the absolute value of an integrable function.

	Hint: for any interval ``\left[x_{i-1},x_i\right]\in\left[a,b\right]``, we have

	```math
	\begin{gathered}
	\sup\left\{\left|f\left(x\right)\right|\mid x\in \left[x_{i-1},x_i\right]\right\}-\inf\left\{\left|f\left(x\right)\right|\mid x\in \left[x_{i-1},x_i\right]\right\}\\
	\le\sup\left\{f\left(x\right)\mid x\in \left[x_{i-1},x_i\right]\right\}-\inf\left\{f\left(x\right)\mid x\in \left[x_{i-1},x_i\right]\right\}\,.
	\end{gathered}
	```

### Mean-Value Theorem for Integrals

A simple but very useful result is the Mean-Value theorem for integrals.

!!! theorem

	If ``f`` is continuous on ``\left[a,b\right]``, then there exists a point ``c\in\left[a,b\right]`` such that

	```math
	\int_a^bf\left(x\right)\,\mathrm{d} x=\left(b-a\right)f\left(c\right)\,.
	```

!!! proof

	Let ``f`` be a function continuous on the interval ``\left[a,b\right]``. Then ``f`` assumes a minimum value ``m`` and a maximum value ``M`` on the interval, say at points ``x=l`` and ``x=u``, respectively:

	```math
	\forall x\in \left[a,b\right]: m=f\left(l\right)\le f\left(x\right)\le f\left(u\right)=M\,.
	```

	For the partition ``P`` of ``\left[a,b\right]`` having ``x_0=a`` and ``x_1=b``, we have

	```math
	m\left(b-a\right)=L\left(f,P\right)\le\int_a^bf\left(x\right)\,\mathrm{d} x\le U\left(f,P\right)=M\left(b-a\right)\,.
	```

	Therefore,

	```math
	f\left(l\right)=m\le\frac{1}{b-a}\int_a^bf\left(x\right)\,\mathrm{d} x\le M=f\left(u\right)\,.
	```

	By the Intermediate-Value theorem, ``f\left(x\right)`` must take on every value between the two values ``f\left(l\right)`` and ``f\left(u\right)``. Hence, there is a number ``c`` between ``l`` and ``u`` such that

	```math
	f\left(c\right)=\frac{1}{b-a}\int_a^bf\left(x\right)\,\mathrm{d} x\,.
	```

The integral ``\int_a^bf\left(x\right)\,\mathrm{d} x`` is equal to the area ``\left(b-a\right)f\left(c\right)`` of a rectangle with base width ``b-a`` and height ``f\left(c\right)`` for some ``c\in \left[a,b\right]``.

{cell=chap display=false output=false}
```julia
Figure("", "Half of the area between " * tex("y=f\\left(x\\right)") * " and the horizontal line " * tex("y=f\\left(c\\right)") * " lies above the line, and the other half lies below the line.") do
	scale = 40
	Drawing(width=7.5scale, height=5scale) do
		xmid = 1scale
		ymid = 4.5scale
		a = 1.0
		b = 6.0
		f = x->1.5*(sin(x-3.75)+1.5)
		F = x->1.5*(-cos(x-3.75)+1.5*x)
		fc = (F(b) - F(a)) / (b-a)
		c = asin(fc/1.5 - 1.5)+3.75
		l = 3.75 - pi/2
		fl = f(l)
		u = 3.75 + pi/2
		fu = f(u)
		axis_xy(7.5scale,5scale,xmid,ymid,scale,(a, l, c, u, b),(fl, fc, fu);xs=("a", "l", "c", "u", "b"), ys=("f\\left(l\\right)", "f\\left(c\\right)", "f\\left(u\\right)"), yl=(2.5, 2.5, 2.5))
		path = "$(xmid+a*scale), $(ymid-fc*scale) " * mapreduce(elem->"$(elem[1]), $(elem[2]) ", *, zip(xmid .+ scale*(a:0.01:c), ymid .- scale * f.(a:0.01:c))) 
		polygon(points=path, fill="lightblue", stroke="none")
		path = mapreduce(elem->"$(elem[1]), $(elem[2]) ", *, zip(xmid .+ scale*(c:0.01:b), ymid .- scale * f.(c:0.01:b))) * "$(xmid+b*scale), $(ymid-fc*scale) " 
		polygon(points=path, fill="lightgreen", stroke="none")
		plot_xy(f, a:0.01:b, tuple(), xmid, ymid, scale; width=1)
		plot_xy(x->fc, 0.0:0.01:6.5, tuple(), xmid, ymid, scale; width=1)
	end
end
```

Observe in the figure that the area below the curve ``y=f\left(x\right)`` and above the line ``y=f\left(c\right)`` is equal to the area above ``y=f\left(x\right)`` and below ``y=f\left(c\right)``. In this sense, ``f\left(c\right)`` is the *average value* of the function ``f\left(x\right)`` on the interval ``\left[a,b\right]``.

!!! definition

	If ``f`` is integrable on ``\left[a,b\right]``, then the *average value* or *mean value* of ``f`` on ``\left[a,b\right]``, denoted by ``\bar f``, is

	```math
	\bar f = \frac{1}{b-a}\int_a^bf\left(x\right)\,\mathrm{d} x\,.
	```

### Piecewise Continuous Functions

The definition of integrability and the definite integral given above can be extended to a wider class than just continuous functions. One simple but very important extension is to the class of *piecewise continuous functions*.

{cell=chap display=false output=false}
```julia
Figure("", "A piecewise continuous function.") do
	scale = 50
	Drawing(width=4.5scale, height=3scale) do
		xmid = 0.5scale
		ymid = 2.5scale
		a = 0.5
		c1 = 1.5
		c2 = 2.5
		b = 3.5
		f1 = x->sqrt(1-(x-0.5)^2)
		f2 = x->2
		f3 = x->(x-0.5)-2
		axis_xy(4.5scale,5scale,xmid,ymid,scale,(a, c1, c2, b),(1, 2);xs=("a", "c_1", "c_2", "b"))
		path = "$(xmid+a*scale), $(ymid) " * mapreduce(elem->"$(elem[1]), $(elem[2]) ", *, zip(xmid .+ scale*(a:0.01:c1), ymid .- scale * f1.(a:0.01:c1))) * mapreduce(elem->"$(elem[1]), $(elem[2]) ", *, zip(xmid .+ scale*(c1:0.01:c2), ymid .- scale * f2.(c1:0.01:c2))) * mapreduce(elem->"$(elem[1]), $(elem[2]) ", *, zip(xmid .+ scale*(c2:0.01:b), ymid .- scale * f3.(c2:0.01:b))) * "$(xmid+b*scale), $(ymid) "
		polygon(points=path, fill="lightblue", stroke="none")
		plot_xy(f1, a:0.01:c1, tuple(a, c1), xmid, ymid, scale; width=1)
		plot_xy(f2, c1:0.01:c2, tuple(c2), xmid, ymid, scale; width=1)
		plot_xy(f3, c2:0.01:b, tuple(b), xmid, ymid, scale; width=1)
		circle(cx=xmid+scale*c1, cy=ymid-scale*f2(c1), r=3, fill="white", stroke="red")
		circle(cx=xmid+scale*c2, cy=ymid-scale*f3(c2), r=3, fill="white", stroke="red")
	end
end
```

Consider the graph ``y=f\left(x\right)`` shown above. Although ``f`` is not continuous at all points in ``\left[a,b\right]`` (it is discontinuous at ``c_1`` and ``c_2``), clearly the region lying under the graph and above the ``x``-axis between ``x= a`` and ``x= b`` does have an area. We would like to represent this area as

```math
\int_a^{c_1}f\left(x\right)\,\mathrm{d} x+\int_{c_1}^{c_2}f\left(x\right)\,\mathrm{d} x+\int_{c_2}^bf\left(x\right)\,\mathrm{d} x\,.
```

This is reasonable because there are continuous functions (extensions) on ``\left[a,c_1\right]``, ``\left[c_1,c_2\right]``, and ``\left[c_2,b\right]`` equal to  ``f\left(x\right)`` on the corresponding open intervals, ``\left]a,c_1\right[``, ``\left]c_1,c_2\right[``, and ``\left]c_2,b\right[``.

!!! definition

	Let ``c_0 &lt; c_1 &lt; c_2 &lt; \cdots &lt; c_n`` be a finite set of points on the real line. A function ``f`` defined on ``\left[c_0,c_n\right]`` except possibly at some of the points ``c_i``, is called piecewise continuous on that interval if for each ``i`` there exists a function ``F_i`` continuous on the closed interval ``\left[c_{i-1},c_i\right]`` such that

	```math
	f\left(x\right)=F_i\left(x\right)\quad\textrm{on the open interval }\left]c_{i-1},c_i\right[\,.
	```

	In this case, we define the definite integral of ``f`` from ``c_0`` to ``c_n`` to be

	```math
	\int_{c_0}^{c_n}f\left(x\right)\,\mathrm{d} x=\sum_{i=1}^n\int_{c_{i-1}}^{c_i}F_i\left(x\right)\,\mathrm{d} x\,.
	```

!!! example

	Find ``\displaystyle\int_{0.5}^{3.5}f\left(x\right)\,\mathrm{d} x``, where

	```math
	f\left(x\right)=\begin{cases}
	\sqrt{1-\left(x-0.5\right)^2}&\textrm{if } 0.5\le x\le 1.5\\
	2&\textrm{if } 1.5&lt; x\le 2.5\\
	x-2.5&\textrm{if } 2.5&lt; x\le 3.5\,.
	\end{cases}
	```

	The value of the integral is the sum of the shaded areas in the figure

	```math
	\begin{aligned}
	\int_{0.5}^{3.5}f\left(x\right)\,\mathrm{d} x&=\int_{0.5}^{1.5}\sqrt{1-\left(x-0.5\right)^2}\,\mathrm{d} x+\int_{1.5}^{2.5}2\,\mathrm{d} x+\int_{2.5}^{3.5}\left(x-2.5\right)\,\mathrm{d} x\\
	&=\left(\frac{1}{4}\times\uppi^2\times 1^2\right)+\left(2\times 1\right)+\left(\frac{1}{2}\times1\times 1\right)=\frac{\uppi+10}{4}\,.
	\end{aligned}

## The Fundamental Theorem of Calculus

In this section we demonstrate the relationship between the definite integral defined and the indefinite integral (or general antiderivative). A consequence of this relationship is that we will be able to calculate definite integrals of functions whose antiderivatives we can find.

!!! theorem "Fundamental theorem of Calculus Part 1"

	If ``g`` is a continuous function on ``\left[a,b\right]`` that is differentiable on ``\left]a,b\right[``, and if ``g^\prime`` is integrable on ``\left[a,b\right]``, then

	```math
	\int_a^b g^\prime\left(x\right)\,\mathrm{d} x=g\left(b\right)-g\left(a\right)\,.
	```

!!! proof

	Let ``\varepsilon &gt;0``. There exist a partition ``P`` of ``\left[a,b\right]`` such that

	```math
	U\left(g^\prime,P\right)-L\left(g^\prime,P\right)&lt; \varepsilon\,.
	```

	We apply the Mean-Value theorem to ``g`` on each interval ``\left[x_{i-1},x_i\right]``, to obtain ``t_i\in \left[x_{i-1},x_i\right]`` for which

	```math
	\left(x_i-x_{i-1}\right)g^\prime\left(t_i\right)=g\left(x_i\right)-g\left(x_{i-1}\right)\,.
	```

	Hence,

	```math
	g\left(b\right)-g\left(a\right)=\sum_{i=1}^n\left(g\left(x_i\right)-g\left(x_{i-1}\right)\right)=\sum_{i=1}^ng^\prime\left(t_i\right)\left(x_i-x_{i-1}\right)\,.
	```

	Since ``\inf\left\{g^\prime\left(x\right)\mid x\in\left[x_{i-1},x_i\right] \right\}\le g^\prime\left(t_i\right)\le\sup\left\{g^\prime\left(x\right)\mid x\in\left[x_{i-1},x_i\right] \right\}``, we have

	```math
	L\left(g^\prime,P\right)\le g\left(b\right)-g\left(a\right)\le U\left(g^\prime,P\right)\,.
	```

	We also have that

	```math
	L\left(g^\prime,P\right)\le \int_a^b g^\prime\left(x\right)\,\mathrm{d} x\le U\left(g^\prime,P\right)\,,
	```

	so the Darboux integrability criterion implies

	```math
	\left|\int_a^b g^\prime\left(x\right)\,\mathrm{d} x-\left(g\left(b\right)-g\left(a\right)\right)\right|&lt;\varepsilon\,.
	```

	This is true for all ``\varepsilon``, so

	```math
	\int_a^b g^\prime\left(x\right)\,\mathrm{d} x=g\left(b\right)-g\left(a\right)\,.
	```

To facilitate the evaluation of definite integrals using the Fundamental theorem of Calculus Part 1, we define the *evaluation symbol*

!!! definition

	``\displaystyle \left.F\left(x\right)\right|_a^b=F\left(b\right)-F\left(a\right)\,.``

Thus,

```math
\int_a^b f\left(x\right)\,\mathrm{d} x=\left.\left(\int f\left(x\right)\,\mathrm{d} x\right)\right|_a^b\,,
```

where ``\displaystyle \int f\left(x\right)\,\mathrm{d} x`` denotes the indefinite integral or general antiderivative of ``f``. When evaluating a definite integral this way, we will omit the constant of integration (``C``) from the indefinite integral because it cancels out in the subtraction:

```math
\left.\left(F\left(x\right)+C\right)\right|_a^b=F\left(b\right)+C-\left(F\left(a\right)+C\right)=F\left(b\right)-F\left(a\right)=\left.F\left(x\right)\right|_a^b\,.
```
	
!!! example

	Evaluate ``\displaystyle \int_0^a x^2\,\mathrm{d} x``.

	``\displaystyle \int_0^a x^2\,\mathrm{d} x=\left.\frac{1}{3}x^3\right|_0^a=\frac{1}{3}a^3-\frac{1}{3}0^3=\frac{a^3}{3}`` because ``\displaystyle \frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}\frac{x^3}{3}=x^2``.

!!! theorem "Fundamental theorem of Calculus Part 2"

	Let ``f`` be an integrable function on ``\left[a,b\right]``. For ``x\in\left[a,b\right]``, let

	```math
	F\left(x\right)=\int_a^xf\left(t\right)\,\mathrm{d} t\,.
	```

	Then ``F`` is continuous on ``\left[a,b\right]``. If ``f`` is continuous at ``x_0\in\left]a,b\right[``, then ``F`` is differentiable at ``x_0`` and

	```math
	F^\prime\left(x_0\right)=f\left(x_0\right)\,.
	```

!!! proof

	``f`` is an integrable function, so ``f`` is bounded on ``\left[a,b\right]`` and there exists ``B\ge 0`` such that ``\left|f\left(x\right)\right|\le B`` for ``x\in\left[a,b\right]``.

	Let ``\varepsilon &gt;0``. If ``\left|x-y\right|&lt;\frac{\varepsilon}{B}`` for ``a\le x&lt; y\le b``, then

	```math
	\left|F\left(y\right)-F\left(x\right)\right|=\left|\int_y^xf\left(t\right)\,\mathrm{d} t\right|\le \int_y^x\left|f\left(t\right)\right|\,\mathrm{d} t\le\int_y^xB,\mathrm{d} t=B\left(y-x\right)&lt;\varepsilon\,.
	```

	This shows that ``F`` is (uniformly) continuous on ``\left[a,b\right]``.

	Suppose ``f`` is continuous at ``x_0\in\left]a,b\right[``. We have

	```math
	\frac{F\left(x\right)-F\left(x_0\right)}{x-x_0}=\frac{1}{x-x_0}\int_{x_0}^xf\left(t\right)\,\mathrm{d} t
	```

	for ``x\ne x_0`` and

	```math
	f\left(x_0\right)=\frac{1}{x-x_0}\int_{x_0}^xf\left(x_0\right)\,\mathrm{d} t\,.
	```

	Therefore,

	```math
	\frac{F\left(x\right)-F\left(x_0\right)}{x-x_0}-f\left(x_0\right)=\frac{1}{x-x_0}\int_{x_0}^x\left(f\left(t\right)-f\left(x_0\right)\right)\,\mathrm{d} t\,.
	```

	Let ``\varepsilon &gt;0``. Since ``f`` is continuous at ``x_0``, there exists ``\delta&gt;0`` such that for ``t\in\left]a,b\right[``
	
	```math
	\left|t-x_0\right|&lt;\delta\implies \left|f\left(t\right)-f\left(x_0\right)\right|&lt;\varepsilon\,.
	```

	Thus for ``x\in\left]a,b\right[`` satisfying ``\left|x-x_0\right|&lt;\delta`` we have

	```math
	\left|\frac{F\left(x\right)-F\left(x_0\right)}{x-x_0}-f\left(x_0\right)\right|\le\varepsilon\,.
	```

	This shows that

	```math
	\lim_{x\to x_0}\frac{F\left(x\right)-F\left(x_0\right)}{x-x_0}=f\left(x_0\right)\,.
	```

	In other words, ``F^\prime\left(x_0\right)=f\left(x_0\right)``.

!!! example

	Find the derivative of ``\displaystyle F\left(x\right)=\int_{x^2}^{x^3}\mathcal{e}^{-t^2}\,\mathrm{d} t``.

	```math
	\begin{aligned}
	F\left(x\right)&=\int_{0}^{x^3}\mathcal{e}^{-t^2}\,\mathrm{d} t-\int_{0}^{x^2}\mathcal{e}^{-t^2}\,\mathrm{d} t\\
	F^\prime\left(x\right)&=\mathcal{e}^{-\left(x^3\right)^2}\left(3x^2\right)-\mathcal{e}^{-\left(x^2\right)^2}\left(2x\right)\\
	&=3x^2\mathcal{e}^{-x^6}-2x\mathcal{e}^{-x^4}\,.
	\end{aligned}
	```

We can build the Chain Rule into the Fundamental theorem of Calculus part 2

```math
\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}\int^{g\left(x\right)}_{h\left(x\right)}f\left(t\right)\,\mathrm{d} t=f\left(g\left(x\right)\right)g^\prime\left(x\right)-f\left(h\left(x\right)\right)h^\prime\left(x\right)\,.
```

You should remember both conclusions of the Fundamental theorem; they are both useful. Part 1 concerns the integral of a derivative; it tells you how to evaluate a definite integral if you can find an antiderivative of the integrand. Part 2 concerns the derivative of an integral; it tells you how to differentiate a definite integral with respect to its upper limit.

## Methods of Integrations

As we have seen, the evaluation of definite integrals is most easily carried out if we can antidifferentiate the integrand. In this section we develop some techniques of integration, that is, methods for finding antiderivatives of functions. Although the techniques we develop can be used for a large class of functions, they will not work for all functions we might want to integrate.

Let us begin by assembling a table of some known indefinite integrals. These results have all emerged during our development of differentiation formulas for elementary functions. You should *memorize* them.

```math
\begin{aligned}
&\int \mathrm{d} x=\int 1\,\mathrm{d} x=x+C&&\int x\,\mathrm{d} x=\frac{x^2}{2}+C\\
&\int x^2\,\mathrm{d} x=\frac{x^3}{3}+C&&\int\frac{1}{x^2}\, \mathrm{d} x=\frac{1}{x}+C\\
&\int \sqrt x\,\mathrm{d} x=\frac{2}{3}x^{\frac{3}{2}}+C&&\int \frac{1}{\sqrt x}\,\mathrm{d} x=2\sqrt x+C\\
&\int x^r\, \mathrm{d} x=\frac{x^{r+1}}{r+1}+C\quad\left(r\ne1\right)&&\int\frac{1}{x}\, \mathrm{d} x=\ln\left|x\right|+C\\
&\int \sin ax\,\mathrm{d} x=-\frac{1}{a}\cos ax+C&&\int\cos ax\, \mathrm{d} x=\frac{1}{a}\sin ax+C\\
&\int \sec^2 ax\,\mathrm{d} x=\frac{1}{a}\tan ax+C&&\int\csc^2 ax\, \mathrm{d} x=-\frac{1}{a}\cot ax+C\\
&\int \frac{1}{\sqrt{a^2-x^2}}\,\mathrm{d} x=\operatorname{Arcsin}\frac{x}{a}+C\quad\left(a&gt;0\right)&&\int \frac{1}{a^2+x^2}\,\mathrm{d} x=\frac{1}{a}\operatorname{Arctan}\frac{x}{a}+C\\
&\int \mathcal{e}^{ax}\,\mathrm{d} x=\frac{1}{a}\mathcal{e}^{ax}+C&&\int b^{ax}\,\mathrm{d} x=\frac{1}{a\ln b}b^{ax}+C\\
&\int \sinh ax\,\mathrm{d} x=\frac{1}{a}\cosh ax+C&&\int\cosh ax\, \mathrm{d} x=\frac{1}{a}\sinh ax+C
\end{aligned}
```

The linearity formula

```math
\int_a^b\left(Af\left(x\right)+Bg\left(x\right)\right)\,\mathrm{d} x=A\int_a^bf\left(x\right)\,\mathrm{d} x+B\int_a^bg\left(x\right)\,\mathrm{d} x
```

makes it possible to integrate sums and constant multiples of functions.

### The Method of Substitution

When an integral cannot be evaluated by inspection, awe require one or more special techniques. The most important of these techniques is the method of substitution, the integral version of the Chain Rule. If we rewrite the Chain Rule,

```math
\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}f\left(g\left(x\right)\right)=f^\prime\left(g\left(x\right)\right)g^\prime\left(x\right)\,,
```

in integral form, we obtain

```math
\int f^\prime\left(g\left(x\right)\right)g^\prime\left(x\right)\,\mathrm{d} x=f\left(g\left(x\right)\right)+C\,.
```

Observe that the following formalism would produce this latter formula even if we did not already know it was true. Let ``u=g\left(x\right)``. Then ``\frac{\mathrm{d} u}{\mathrm{d} x}=g^\prime\left(x\right)``, or in differential form, ``\mathrm d u=g^\prime\left(x\right)\mathrm d x``. Thus,

```math
\int f^\prime\left(g\left(x\right)\right)g^\prime\left(x\right)\,\mathrm{d} x=\int f^\prime\left(u\right)\,\mathrm{d} u=f\left(u\right)+C=f\left(g\left(x\right)\right)+C\,.
```

!!! example

	Find the indefinite integral ``\displaystyle \int \frac{\sin\left(3\ln x\right)}{x}\,\mathrm{d} x``.

	Let ``u=3\ln x``. Then ``\mathrm{d} u=\frac{3}{x}\,\mathrm{d} x`` and

	```math
	\int \frac{\sin\left(3\ln x\right)}{x}\,\mathrm{d} x=\frac{1}{3}\int \sin u\,\mathrm{d} u=-\frac{1}{3}\cos u+C=-\frac{1}{3}\cos\left(3\ln x\right)+C\,.
	```

!!! theorem

	Suppose that ``g`` is a differentiable function on ``\left[a,b\right]`` that satisfies ``g\left(a\right)=A`` and ``g\left(b\right)=B``. Also suppose that ``f`` is continuous on the range of ``g``. Then

	```math
	\int_a^b f^\prime\left(g\left(x\right)\right)g^\prime\left(x\right)\,\mathrm{d} x=\int_A^B f^\prime\left(u\right)\,\mathrm{d} u\,.
	```

!!! proof

	Let ``F`` be an antiderivative of ``f``, ``F^\prime\left(u\right)=f\left(u\right)``. Then

	```math
	\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}F\left(g\left(x\right)\right)=F^\prime\left(g\left(x\right)\right)g^\prime\left(x\right)=f\left(g\left(x\right)\right)g^\prime\left(x\right)\,.
	```

	Thus,

	```math
	\begin{aligned}
	\int_a^bf\left(g\left(x\right)\right)g^\prime\left(x\right)\,\mathrm{d} x&=\left.F\left(g\left(x\right)\right)\right|_a^b=F\left(g\left(b\right)\right)-F\left(g\left(a\right)\right)\\
	&=F\left(B\right)-F\left(A\right)=\left.F\left(u\right)\right|_A^B=\int_A^B f^\prime\left(u\right)\,\mathrm{d} u\,.
	\end{aligned}
	```

!!! example

	Evaluate the integral ``\displaystyle I=\int_0^8\frac{\cos\sqrt{x+1}}{\sqrt{x+1}}\,\mathrm{d} x``.

	Let ``u=\sqrt{x+1}``. Then ``\mathrm{d} u=\frac{1}{2\sqrt{x+1}}\,\mathrm{d} x``. If ``x=0``, then ``u=1``; if ``x=8``, then ``u=3``. Thus,

	```math
	I=2\int_1^3\cos u\,\mathrm{d} u=\left.2\sin u\right|_1^3=2\sin 3-2\sin 1\,.
	```

The method of substitution is often useful for evaluating trigonometric integrals. We begin by listing the integrals of the four trigonometric functions whose integrals we have not yet seen. They arise often in applications and should be memorized.

```math
\begin{aligned}
\int \tan x\,\mathrm{d} x&=\ln\left|\sec x\right|+C\\
\int \cot x\,\mathrm{d} x&=\ln\left|\sin x\right|+C
\end{aligned}
```

All of these can, of course, be checked by differentiating the right-hand sides. They can be evaluated directly by rewriting``\tan x`` or ``\\cot x`` in terms of ``\sin x`` and ``\cos x`` and using an appropriate substitution. For example,

```math
\begin{aligned}
\int \tan x\,\mathrm{d} x&=\int \frac{\sin x}{\cos x}\,\mathrm{d} x\quad\textrm{Let }u=\cos x\textrm{, then }\mathrm{d} u=-\sin x\,\mathrm{d} x\\
&=-\int\frac{1}{u}\,\mathrm{d} u=-\ln\left|u\right|+C\\
&=-\ln\left|\cos x\right|+C=\ln\left|\frac{1}{\cos x}\right|+C=\ln\left|\sec x\right|+C
\end{aligned}
```

We now consider integrals of the form

```math
\int \sin^m x\cos^n x\,\mathrm{d} x\,.
```

If either ``m`` or ``n`` is an odd, positive integer, the integral can be done easily by substitution. If, say, ``n=2k+1`` where ``k`` is an integer, then we can use the identity ``\sin^2 x + \cos^2 x = 1`` to rewrite the integral in the form

```math
\int \sin^m x\left(1-\sin^2 x\right)^k\cos x\,\mathrm{d} x\,,
```

which can be integrated using the substitution ``u=\sin x``. Similarly, ``u=\cos x`` can be used if ``m`` is an odd integer.

If the powers of ``\sin x`` and ``\cos x`` are both even, then we can make use of the double-angle formulas

```math
\cos^2 x=\frac{1}{2}\left(1+\cos 2x\right)\quad\textrm{and}\quad \sin^2=\frac{1}{2}\left(1-\cos 2x\right)\,.
```

!!! example

	Evaluate ``\displaystyle\int \sin^4 x\,\mathrm{d} x``.

	```math
	\begin{aligned}
	\int \sin^4 x\,\mathrm{d} x&=\frac{1}{4}\int \left(1-\cos 2x\right)^2\,\mathrm{d} x\\
	&=\frac{1}{4}\int \left(1-2\cos 2x+\cos^2 2x\right)\,\mathrm{d} x\\
	&=\frac{x}{4}-\frac{1}{4}\sin 2x+\frac{1}{8}\int \left(1+\cos 4x\right)\,\mathrm{d} x\\
	&=\frac{x}{4}-\frac{1}{4}\sin 2x+\frac{x}{8}+\frac{1}{32}\sin 4x+C\\
	&=\frac{3}{8}x-\frac{1}{4}\sin 2x+\frac{1}{32}\sin 4x+C
	\end{aligned}
	```

### Integration by Parts

Our next general method for antidifferentiation is called *integration by parts*. Just as the method of substitution can be regarded as inverse to the Chain Rule for differentiation, so the method for integration by parts is inverse to the Product Rule for differentiation.

Suppose that ``U\left(x\right)`` and ``V\left(x\right)`` are two differentiable functions. According to the Product Rule,

```math
\frac{\mathrm d \hphantom{x}}{\mathrm{d} x}\left(U\left(x\right)V\left(x\right)\right)=U\left(x\right)\frac{\mathrm{d} V}{\mathrm{d} x}\left(x\right)+V\left(x\right)\frac{\mathrm{d} U}{\mathrm{d} x}\left(x\right)\,.
```

Integrating both sides of this equation and transposing terms, we obtain

```math
\int U\left(x\right)\frac{\mathrm{d} V}{\mathrm{d} x}\left(x\right)\,\mathrm{d} x=U\left(x\right)V\left(x\right)-\int V\left(x\right)\frac{\mathrm{d} U}{\mathrm{d} x}\left(x\right)\,\mathrm{d} x\,.
```

The above formula serves as a pattern for carrying out integration by parts. We break up the given integrand into a product of two pieces, ``U`` and ``V^\prime``, where ``V^\prime`` is readily integrated and where ``\int VU^\prime\,\mathrm{d} x`` is usually (but not always) a simpler integral than ``\int UV^\prime\,\mathrm{d} x``. The technique is called integration by parts because it replaces one integral with the sum of an integrated term and another integral that remains to be evaluated. That is, it accomplishes only part of the original integration.

!!! example

	Evaluate ``\displaystyle \int x\mathcal{e}^x\,\mathrm{d} x``.

	```math
	\begin{aligned}
	\int x\mathcal{e}^x\,\mathrm{d} x&\quad\textrm{Let }U=x,\mathrm{d} V=\mathcal{e}^x\,\mathrm{d} x\textrm{, then }\mathrm{d} U=\mathrm{d} x,V=\mathcal{e}^x\\
	&=\,x\mathcal{e}^x-\int \mathcal{e}^x\,\mathrm{d} x=x\mathcal{e}^x-\mathcal{e}^x+C\,.
	\end{aligned}
	```

Note the form in which the integration by parts is carried out. We indicate at the side what choices we are making for ``U`` and ``\mathrm{d} V`` and then calculate ``\mathrm{d} U`` and ``V`` from these. However, we do not actually substitute ``U`` and ``V`` into the integral; instead, we use the formula ``\int U\,\mathrm{d} V=UV-\int V\,\mathrm{d} U`` as a pattern or mnemonic device to replace the given integral by the equivalent partially integrated form on the second line.

In general, do not include a constant of integration with ``V`` or on the right-hand side until the last integral has been evaluated because that constant would cancel out in the next step.

The following are two useful rules of thumb for choosing ``U`` and ``\mathrm{d} V``:

1. If the integrand involves a polynomial multiplied by an exponential, a sine or a cosine, or some other readily integrable function, try ``U`` equals the polynomial and ``\mathrm{d} V`` equals the rest.

2. If the integrand involves a logarithm, an inverse trigonometric function, or some other function that is not readily integrable but whose derivative is readily calculated, try that function for ``U`` and let ``\mathrm{d} V`` equal the rest.

Of course, these “rules” come with no guarantee.

The following example illustrates a frequently occurring and very useful phenomenon. It may happen after one or two integrations by parts, with the possible application of some known identity, that the original integral reappears on the right-hand side. Unless its coefficient there is ``1``, we have an equation that can be solved for that integral.

!!! example

	Evaluate ``\displaystyle \int \mathcal{e}^{ax}\cos bx\,\mathrm{d} x``.

	```math
	\begin{aligned}
	\int \mathcal{e}^{ax}\cos bx\,\mathrm{d} x&\quad\textrm{Let }U=\mathcal{e}^{ax},\mathrm{d} V=\cos bx\,\mathrm{d} x\textrm{, then }\mathrm{d} U=a\mathcal{e}^{ax}\,\mathrm{d} x,V=\frac{1}{b}\sin bx\\
	&=\,\frac{1}{b}\mathcal{e}^{ax}\sin bx-\frac{a}{b}\int \mathcal{e}^{ax}\sin bx\,\mathrm{d} x\\
	&\quad\textrm{Let }U=\mathcal{e}^{ax},\mathrm{d} V=\sin bx\,\mathrm{d} x\textrm{, then }\mathrm{d} U=a\mathcal{e}^{ax}\,\mathrm{d} x,V=-\frac{1}{b}\cos bx\\
	&=\,\frac{1}{b}\mathcal{e}^{ax}\sin bx-\frac{a}{b}\left(-\frac{1}{b}\mathcal{e}^{ax}\cos bx+\frac{a}{b}\int \mathcal{e}^{ax}\cos bx\,\mathrm{d} x\right)\\
	&=\,\frac{1}{b}\mathcal{e}^{ax}\sin bx+\frac{a}{b^2}\mathcal{e}^{ax}\cos bx-\frac{a^2}{b^2}\int \mathcal{e}^{ax}\cos bx\,\mathrm{d} x\,.
	\end{aligned}
	```

	Thus,

	```math
	\left(1+\frac{a^2}{b^2}\right)\int \mathcal{e}^{ax}\cos bx\,\mathrm{d} x=\frac{1}{b}\mathcal{e}^{ax}\sin bx+\frac{a}{b^2}\mathcal{e}^{ax}\cos bx+C_1
	```

	and

	```math
	\int \mathcal{e}^{ax}\cos bx\,\mathrm{d} x=\frac{b\mathcal{e}^{ax}\sin bx+a\mathcal{e}^{ax}\cos bx}{a^2+b^2}+C\,.
	```

Observe that after the first integration by parts we had an integral that was different from, but no simpler than, the original integral. At this point we might have become discouraged and given up on this method. However, perseverance proved worthwhile; a second integration by parts returned the original integral in an equation that could be solved for the integral.

### Integrals of Rational Functions

A complicated fraction can be written as a sum of simpler fractions. This is called the *method of partial fractions*.

!!! theorem

	Let ``P`` and ``Q`` be polynomials with real coefficients, and suppose that the degree of ``P`` is less than the degree of ``Q``. Then

	1. ``Q\left(x\right)`` can be factored into the product of a constant ``K``, real linear factors of the form ``\left(x-a_i\right)``, and real quadratic factors of the form ``x^2+b_i x+c_i`` having no real roots. The linear and quadratic factors may be repeated:

	   ```math
	   Q\left(x\right)=K\left(x-a_1\right)^{m_1}\left(x-a_2\right)^{m_2}\cdots\left(x-a_j\right)^{m_j}\left(x^2+b_1x+c_1\right)^{n_1}\cdots\left(x^2+b_kx+c_k\right)^{n_k}\,.
	   ```

	   The degree of ``Q`` is ``m_1+m_2+\cdots+m_j+2n_1+2n_2+\cdots+2n_k``.

	2. The rational function ``\displaystyle\frac{P\left(x\right)}{Q\left(x\right)}`` can be expressed as a sum of partial fractions as follows:

	   1. corresponding to each factor ``\left(x-a\right)^m`` of ``Q\left(x\right)`` the decomposition contains a sum of fractions of the form

		  ```math
		  \frac{A_1}{x-a}+\frac{A_2}{\left(x-a\right)^2}+\cdots+\frac{A_m}{\left(x-a\right)^m}\,;
		  ```

	   2. corresponding to each factor ``\left(x^2+bx+c\right)^m`` of ``Q\left(x\right)`` the decomposition contains a sum of fractions of the form

	   	  ```math
		  \frac{B_1x+C_1}{x^2+bx+c^2}+\frac{B_2x+C_2}{\left(x^2+bx+c^2\right)^2}+\cdots+\frac{B_nx+C_n}{\left(x^2+bx+c^2\right)^n}\,.
		  ```

	   The constants ``A_1, A_2,\dots,A_m,B_1,B_2,\dots,B_n,C_1,C_2,\dots,C_n`` can be determined by adding up the fractions in the decomposition and equating the coefficients of like powers of ``x`` in the numerator of the sum with those in ``P\left(x\right)``.

We do not attempt to give any formal proof of this assertion here; such a proof belongs in an algebra course.

Note that part (1) does not tell us how to find the factors of ``Q\left(x\right)``; it tells us only what form they have. We must know the factors of ``Q`` before we can make use of partial fractions to integrate the rational function ``\frac{P\left(x\right)}{Q\left(x\right)}``.

!!! example

	Evaluate ``\displaystyle \int\frac{x^2+2}{4x^5+4x^3+x}\,\mathrm{d} x``.

	The denominator factors to ``x\left(2x^2+1\right)^2``, so the appropriate partial fraction decomposition is

	```math
	\begin{aligned}
	\frac{x^2 +2}{x\left(2x^2+1\right)^2}&=\frac{A}{x}+\frac{Bx+C}{2x^2+1}+\frac{Dx+E}{\left(2x^2+1\right)^2}\\
	&=\frac{A\left(4x^4+4x^2+1\right)+B\left(2x^4+x^2\right)+C\left(2x^3+x\right)+Dx^2+Ex}{x\left(2x^2+1\right)^2}\,.
	\end{aligned}
	```

	Thus

	```math
	\begin{aligned}
	4A + 2B \hphantom{+ 2C + D + E} = 0&\quad\left(\textrm{coefficient of }x^4\right)\\
	\hphantom{4A + 2B +} 2C \hphantom{+ D + E} = 0&\quad\left(\textrm{coefficient of }x^3\right)\\
	4A + 2B \hphantom{ + 2C }+ D \hphantom{+ E} = 0&\quad\left(\textrm{coefficient of }x^2\right)\\
	\hphantom{4A + 2B + 2}C \hphantom{+ D} + E = 0&\quad\left(\textrm{coefficient of }x^1\right)\\
	\hphantom{4}A \hphantom{+ 2B + 2C + D + E} = 0&\quad\left(\textrm{coefficient of }x^0\right)\,.
	\end{aligned}
	```

	Solving these equations, we get ``A=2``, ``B=-4``, ``C=0``, ``D=-3``, and ``E=0``.

	```math
	\begin{aligned}
	\int\frac{x^2+2}{4x^5+4x^3+x}\,\mathrm{d} x&=\,2\int\frac{1}{x}\,\mathrm{d} x-4\int\frac{x}{2x^2+1}\,\mathrm{d} x-3\int\frac{x}{\left(2x^2+1\right)^2}\\
	&\quad\textrm{Let }u=2x^2+1\,\mathrm{d} x\textrm{, then }\mathrm{d} u=4x\,\mathrm{d} x\\
	&=\,2\ln\left|x\right|-\int\frac{1}{u}\,\mathrm{d} u-\frac{3}{4}\int\frac{1}{u ^2}\,\mathrm{d} u\\
	&=\,2\ln\left|x\right|-\ln\left|u\right|=\frac{3}{4}\frac{1}{u}+C\\
	&=\,\ln\left(\frac{x^2}{2x^2+1}\right)+\frac{3}{4}\frac{1}{2x^2+1}+C\,.
	\end{aligned}
	```

### Inverse Substitutions

The substitutions considered in the beginning of this section were direct substitutions in the sense that we simplified an integrand by replacing an expression appearing in it with a single variable. In this section we consider the reverse approach: we replace the variable of integration with a function of a new variable. Such substitutions, called *inverse substitutions*, would appear on the surface to make the integral more complicated.

As we will see, however, sometimes such substitutions can actually simplify an integrand, transforming the integral into one that can be evaluated by inspection or to which other techniques can readily be applied. In any event, inverse substitutions can often be used to convert integrands to rational functions.

(1) Integrals involving ``\sqrt{a^2-x^2}`` (where ``a&gt;0``) can frequently be reduced to a simpler form by means of the substitution ``x=a\sin\theta``.

Observe that ``\sqrt{a^2-x^2}`` makes sense only if ``-a\le x\le a``, which corresponds to ``-\frac{\uppi}{2}\le\theta\le\frac{\uppi}{2}``. Since ``\cos\theta\ge0`` for such ``\theta``, we have

```math
\sqrt{a^2-x^2}=\sqrt{a^2\left(1-\sin^2 \theta\right)}=\sqrt{a^2\cos^2\theta}=a\cos\theta\,.
```

!!! example

	Evaluate ``\displaystyle\int\frac{1}{\left(5-x^2\right)^\frac{3}{2}}\,\mathrm{d} x``.

	```math
	\begin{aligned}
	\int\frac{1}{\left(5-x^2\right)^\frac{3}{2}}\,\mathrm{d} x&\quad\textrm{Let }x=\sqrt 5\sin\theta\textrm{, then }\mathrm{d} x=\sqrt 5\cos\theta\,\mathrm{d} \theta\\
	&=\,\int\frac{\sqrt 5\cos\theta}{\left(\sqrt 5\cos\theta\right)^3}\,\mathrm{d} \theta\\
	&=\,\frac{1}{5}\int\sec^2\theta\,\mathrm{d} \theta=\frac{1}{5}\tan\theta+C=\frac{1}{5}\frac{x}{\sqrt{5-x^2}}+C\,.
	\end{aligned}
	```

(2) Integrals involving ``\sqrt{a^2+x^2}`` or ``\frac{1}{x^2+x^2}`` (where ``a&gt;0``) can frequently be reduced to a simpler form by means of the substitution ``x=a\tan\theta``.

Since ``x`` can take any real value, we have ``-\frac{\uppi}{2}&lt;\theta&lt;\frac{\uppi}{2}``, so ``\sec\theta&gt;0`` and

```math
\sqrt{a^2+x^2}=a\sqrt{1+\tan^2\theta}=a\sec\theta\,.
```

!!! example

	Evaluate ``\displaystyle \int\frac{1}{\sqrt{4+x^2}}\,\mathrm{d} x``.

	```math
	\begin{aligned}
	\int\frac{1}{\sqrt{4+x^2}}\,\mathrm{d} x&\quad\textrm{Let }x=2\tan\theta\textrm{, then }\mathrm{d} x=2\sec^2\theta\,\mathrm{d} \theta\\
	&=\,\int\frac{2\sec^2\theta}{2\sec\theta}\,\mathrm{d} \theta=\int\sec\theta\,\mathrm{d} \theta\\
	&=\,\int\frac{\sec\theta\left(\sec\theta+\tan\theta\right)}{\sec\theta+\tan\theta}\,\mathrm{d} \theta\\
	&\quad\textrm{Let }u=\sec\theta+\tan\theta\textrm{, then }\mathrm{d} u=\sec\theta\left(\sec\theta+\tan\theta\right)\,\mathrm{d} \theta\\
	&=\,\int\frac{1}{u}\,\mathrm{d} u=\ln\left|u\right|+C\\
	&=\,\ln\left|\sec\theta+\tan\theta\right|+C=\ln\left|\frac{\sqrt{4+x^2}}{2}+\frac{x}{2}\right|+C\,.
	\end{aligned}
	```

(3) Integrals involving ``\sqrt{x^2-a^2}`` (where ``a&gt;0``) can frequently be reduced to a simpler form by means of the substitution ``x=a\sec\theta``.
   
We must be more careful with this substitution. Although

```math
\sqrt{x^2-a^2}=a\sqrt{\sec^2\theta-1}=a\sqrt{\tan^2\theta}=a\left|\tan\theta\right|\,,
```

we cannot always drop the absolute value from the tangent.

!!! example
	
	Evaluate ``\displaystyle \int\frac{1}{\sqrt{x^2-a^2}}\,\mathrm{d} x``.
	
	Assume ``x\ge a``.
	
	```math
	\begin{aligned}
	\int\frac{1}{\sqrt{x^2-a^2}}\,\mathrm{d} x&\quad\textrm{Let }x=a\sec\theta\textrm{, then }\mathrm{d} x=a\sec\theta\tan\theta\,\mathrm{d} \theta\\
	&=\,\int\sec\theta\,\mathrm{d} x=\ln\left|\sec\theta+\tan\theta\right| + C\\
	&=\,\ln\left|\frac{x}{a}+\frac{\sqrt{x^2-a^2}}{a}\right| + C\,.
	\end{aligned}
	```

(4) As an alternative to the inverse secant substitution ``x=a\sec\theta`` to simplify integrals involving ``\sqrt{x^2-a^2}`` (where ``x\ge a&gt;0``), we can use the inverse hyperbolic cosine substitution ``x=\operatorname{Arccosh} u``. Since ``\cosh^2 u-1=\sinh^2 u``, this substitution produces ``\sqrt{x^2-a^2}= a\operatorname{arcsinh} u``. To express ``u`` in terms of ``x``, we need the result of the previous chapter,

```math
\operatorname{Arccosh x}=\ln\left(x+\sqrt{x^2-1}\right)\,,\quad x\ge1\,.
```

!!! example

	Evaluate ``\displaystyle \int\frac{1}{\sqrt{x^2-a^2}}\,\mathrm{d} x``.

	Assume ``x\ge a``.

	```math
	\begin{aligned}
	\int\frac{1}{\sqrt{x^2-a^2}}\,\mathrm{d} x&\quad\textrm{Let }x=a\cosh u\textrm{, then }\mathrm{d} x=a\sinh u\,\mathrm{d} u\\
	&=\,\int\frac{a\sinh u}{a\sinh u}\,\mathrm{d} u=u + C\\
	&=\,\operatorname{Arccosh}\frac{x}{a}+C=\ln\left|\frac{x}{a}+\frac{\sqrt{x^2-a^2}}{a}\right| + C\,.
	\end{aligned}
	```

(5) Similarly, the inverse hyperbolic substitution ``x=\operatorname{arcsinh} u`` can be used instead of the inverse tangent substitution ``x=a\tan\theta`` to simplify integrals involving ``\sqrt{a^2+x^2}`` or ``\frac{1}{x^2+x^2}``. In this case we have ``\mathrm{d} x = a\cosh u\,\mathrm{d} u`` and ``x^2+a^2=a^2\cosh^2 u``, and we may need the result

```math
\operatorname{arcsinh}x=\ln\left(x+\sqrt{x^2+1}\right)
```

valid for all ``x`` and proved in the previous chapter.

(6) There is a certain special substitution that can transform an integral whose integrand is a rational function of ``\sin\theta`` and ``\cos\theta`` (i.e., a quotient of polynomials in ``\sin\theta`` and ``\cos\theta``) into a rational function of ``x``. The substitution is ``x=\tan\frac{\theta}{2}``.

Observe that

```math
\cos^2\frac{\theta}{2}=\frac{1}{\sec^2\frac{\theta}{2}}=\frac{1}{1+\tan^2\frac{\theta}{2}}=\frac{1}{1+x^2}\,,
```

so

```math
\begin{aligned}
\cos\theta&=2\cos^2\frac{\theta}{2}-1=\frac{2}{1+x^2}-1=\frac{1-x^2}{1+x^2}\\
\sin\theta&=2\sin\frac{\theta}{2}\cos\frac{\theta}{2}=2\tan\frac{\theta}{2}\cos^2\frac{\theta}{2}=\frac{2x}{1+x^2}\,.
\end{aligned}
```

Also, ``\mathrm{d} x=\frac{1}{2}\sec^2\frac{\theta}{2}\,\mathrm{d} \theta``, so

```math
\mathrm{d} \theta=2\cos^2\frac{\theta}{2}\,\mathrm{d} x=\frac{2}{1+x^2}\,\mathrm{d} x\,.
```

## Improper Integrals

Up to this point, we have considered definite integrals of the form

```math
I=\int_a^b f\left(x\right)\,\mathrm{d} x\,,
```

where the integrand ``f`` is continuous on the closed, finite interval ``\left[a,b\right]``. Since such a function is necessarily bounded, the integral I is necessarily a finite number; for positive f it corresponds to the area of a bounded region of the plane, a region contained inside some disk of finite radius with centre at the origin. Such integrals are also called *proper integrals*. 

We are now going to generalize the definite integral to allow for two possibilities excluded in the situation described above:

1. We may have ``a=-\infty`` or ``b=\infty`` or both.

2. ``f`` may be unbounded as ``x`` approaches ``a`` or ``b`` or both.

Integrals satisfying (1) are called *improper integrals of type I*; integrals satisfying (2) are called *improper integrals of type II*. Either type of improper integral corresponds (for positive ``f``) to the area of a region in the plane that “extends to infinity” in some direction and therefore is unbounded. As we will see, such integrals may or may not have finite values.

### Improper Integrals of Type I

!!! definition

	If ``f`` is continuous on ``\left[a,\infty\right[``, we define the improper integral of ``f`` over ``\left[a,\infty\right[`` as a limit of proper integrals:

	```math
	\int_a^\infty f\left(x\right)\,\mathrm{d} x=\lim_{R\to\infty}\int_a^R f\left(x\right)\,\mathrm{d} x\,.
	```

	Similarly, if ``f`` is continuous on ``\left]-\infty, b\right]``, then we define

	```math
	\int_{-\infty}^b f\left(x\right)\,\mathrm{d} x=\lim_{R\to-\infty}\int_R^b f\left(x\right)\,\mathrm{d} x\,.
	```

	In either case, if the limit exists (is a finite number), we say that the improper integral converges; if the limit does not exist, we say that the improper integral diverges. If the limit is ``\infty`` (or ``-\infty``), we say the improper integral diverges to infinity (or diverges to negative infinity).

The integral ``\int_{-\infty}^\infty f\left(x\right)\,\mathrm{d} x`` is, for ``f`` continuous on the real line, improper of type I at both endpoints. We break it into two separate integrals:

```math
\int_{-\infty}^\infty f\left(x\right)\,\mathrm{d} x=\int_{-\infty}^0 f\left(x\right)\,\mathrm{d} x+\int_0^\infty f\left(x\right)\,\mathrm{d} x\,.
```

The integral on the left converges if and only if both integrals on the right converge.

!!! example

	Evaluate ``\displaystyle\int_{-\infty}^\infty \frac{1}{1+x^2}\,\mathrm{d} x``.

	By the even symmetry of the integrand, we have

	```math
	\begin{aligned}
	\int_{-\infty}^\infty \frac{1}{1+x^2}\,\mathrm{d} x&=\int_{-\infty}^0 \frac{1}{1+x^2}\,\mathrm{d} x+\int_0^\infty \frac{1}{1+x^2}\,\mathrm{d} x\\
	&=2\lim_{R\to\infty}\int_0^R \frac{1}{1+x^2}\,\mathrm{d} x\\
	&=2\lim_{R\to\infty}\operatorname{Arctan}R=2\frac{\uppi}{2}=\uppi\,.
	\end{aligned}
	```

### Improper Integrals of Type II

!!! definition

	If ``f`` is continuous on the interval ``\left]a,b\right]`` and is possibly unbounded near ``a``, we define the improper integral

	```math
	\int_a^b f\left(x\right)\,\mathrm{d} x=\lim_{c\to a^+}\int_c^b f\left(x\right)\,\mathrm{d} x\,.
	```

	Similarly, if ``f`` is continuous on ``\left[a,b\right[`` and is possibly unbounded near ``b``, we define

	```math
	\int_a^b f\left(x\right)\,\mathrm{d} x=\lim_{c\to b^-}\int_a^c f\left(x\right)\,\mathrm{d} x\,.
	```

	These improper integrals may converge, diverge, diverge to infinity, or diverge to negative infinity.

While improper integrals of type I are always easily recognized because of the infinite limits of integration, improper integrals of type II can be somewhat harder to spot. You should be alert for singularities of integrands and especially points where they have vertical asymptotes. It may be necessary to break an improper integral into several improper integrals if it is improper at both endpoints or at points inside the interval of integration.

!!! example

	Find the area of the region ``S`` lying under ``y=\frac{1}{\sqrt x}``, above the ``x``-axis, between ``x=0`` and ``x=1``.

	The area ``A`` is given by

	```math
	A=\int_0^1\frac{1}{\sqrt x}\,\mathrm{d} x\,,
	```

	which is an improper integral of type II since the integrand is unbounded near ``x=0``. The region ``S`` has a “spike” extending to infinity along the ``y``-axis, a vertical asymptote of the integrand.
	
	We express such integrals as limits of proper integrals:

	```math
	A = \lim_{c\to 0^+}\int_c^1x^{-\frac{1}{2}}\,\mathrm{d} x=\lim_{c\to 0^+}\left.2x^{\frac{1}{2}}\right|_c^1=\lim_{c\to 0^+}\left(2-2\sqrt c\right)=2\,.
	```

	This integral converges, and ``S`` has a finite area of ``2`` square units.

## Areas of Plane Regions

In this section we review and extend the use of definite integrals to represent plane areas. Recall that the integral  ``\int_a^b f\left(x\right)\,\mathrm{d} x`` measures the area between the graph of ``f`` and the ``x``-axis from ``x=a`` to ``x=b``, but treats as negative any part of this area that lies below the ``x``-axis. (We are assuming that ``a&lt;b``.) In order to express the total area bounded by ``y=f\left(x\right)``, ``y=0``, ``x=a``, and ``x=b``, counting all of the area positively, we should integrate the absolute value of ``f``.

There is no “rule” for integrating ``\int_a^b \left|f\left(x\right)\right|\,\mathrm{d} x`` one must break the integral into a sum
of integrals over intervals where ``f\left(x\right)&gt; 0``.

!!! example

	The area bounded by ``y=\cos x``, ``y=0``, ``x=0``, and ``x=\frac{3\uppi}{2}`` is

	```math
	\begin{aligned}
	A&=\int_0^\frac{3\uppi}{2}\left|\cos x\right|\,\mathrm{d} x\\
	&=\int_0^\frac{\uppi}{2}\cos x\,\mathrm{d} x-\int_\frac{\uppi}{2}^\frac{3\uppi}{2}\cos x\,\mathrm{d} x\\
	&=\left.\sin x\right|_0^\frac{\uppi}{2}-\left.\sin x\right|_\frac{\uppi}{2}^\frac{3\uppi}{2}\\
	&=\left(1-0\right)-\left(-1-1\right)=3\,\textrm{square units.}
	\end{aligned}
	```

### Areas Between Two Curves

Suppose that a plane region ``R`` is bounded by the graphs of two continuous functions, ``y=f\left(x\right)`` and ``y=g\left(x\right)``, and the vertical straight lines ``x=a`` and ``x=b``, as shown in the figure. 

Assume that ``a&lt;b`` and that ``f\left(x\right)\le g\left(x\right)`` on ``\left[a,b\right]``, so the graph of ``f`` lies below that of ``g``. If ``f\left(x\right)\ge 0`` on ``\left[a,b\right]`` then the area ``A`` of ``R`` is the area above the ``x``-axis and under the graph of ``g`` minus the area above the ``x``-axis and under the graph of ``f``:

```math
A=\int_a^b g\left(x\right)\,\mathrm{d} x-\int_a^b f\left(x\right)\,\mathrm{d} x=\int_a^b \left(g\left(x\right)-f\left(x\right)\right)\,\mathrm{d} x\,.
```

It is useful to regard this formula as expressing ``A`` as the “sum” (i.e., the integral) of infinitely many *area elements*

```math
\mathrm{d} A = \left(g\left(x\right)-f\left(x\right)\right)\,\mathrm{d} x\,,
```

corresponding to values of ``x`` between ``a`` and ``b``. Each such area element is the area of an infinitely thin vertical rectangle of width ``\mathrm{d} x`` and height ``g\left(x\right)-f\left(x\right)`` located at position ``x``. Even if ``f`` and ``g`` can take on negative values on ``\left[a,b\right]``, this interpretation and the resulting area formula

```math
A=\int_a^b \left(g\left(x\right)-f\left(x\right)\right)\,\mathrm{d} x\,.
```

remain valid, provided that ``f\left(x\right)\le g\left(x\right)`` on ``\left[a,b\right]`` so that all the area elements ``\mathrm{d} A`` have positive area. Using integrals to represent a quantity as a *sum of differential elements* is a very helpful approach. Of course, what we are really doing is identifying the integral as a limit of a suitable Riemann sum.

More generally, if the restriction ``f\left(x\right)\le g\left(x\right)``  is removed, then the vertical rectangle of width ``\mathrm{d} x`` at position ``x`` extending between the graphs of ``f`` and ``g`` has height ``\left|f\left(x\right)-g\left(x\right)\right|`` and hence area

```math
\mathrm{d} A = \left|f\left(x\right)-g\left(x\right)\right|\,\mathrm{d} x\,.
```

Hence, the total area lying between the graphs ``y=f\left(x\right)`` and ``y=g\left(x\right)`` between the vertical lines ``x=a`` and ``x=b&gt;a`` is given by

```math
A = \int_a^b \left|f\left(x\right)-g\left(x\right)\right|\,\mathrm{d} x\,.
```

In order to evaluate this integral, we have to determine the intervals on which  ``f\left(x\right)&gt; g\left(x\right)`` or ``f\left(x\right)&lt; g\left(x\right)``, and break the integral into a sum of integrals over each of these intervals.

!!! example

	Find the total area ``A`` lying between ``y=\sin x`` and ``y=\cos x`` from ``x=0`` to ``x=2\uppi``.

	Between ``0`` and ``2\uppi`` the graphs of sine and cosine cross at ``x=\frac{\uppi}{4}`` and ``x=\frac{5\uppi}{4}``. The required area is

	```math
	\begin{aligned}
	A &= \int_0^\frac{\pi}{4}\left(\cos x-\sin x\right)\,\mathrm{d} x+\int_\frac{\uppi}{4}^\frac{5\pi}{4}\left(\sin x-\cos x\right)\,\mathrm{d} x+\int_\frac{5\pi}{4}^{2\uppi}\left(\cos x-\sin x\right)\,\mathrm{d} x\\
	&=\left.\left(\sin x+\cos x\right)\right|_0^\frac{\uppi}{4}-\left.\left(\cos x+\sin x\right)\right|_\frac{\uppi}{4}^\frac{5\pi}{4}+\left.\left(\sin x+\cos x\right)\right|_\frac{5\uppi}{4}^{2\uppi}\\
	&=\left(\sqrt 2-1\right)+\left(\sqrt 2+\sqrt 2\right)+\left(1+\sqrt 2\right)=4\sqrt 2\,\textrm{square units.}
	\end{aligned}
	```

## Volumes by Slicing—Solids of Revolution

In this section we show how volumes of certain three-dimensional regions (or solids) can be expressed as definite integrals and thereby determined. We will not attempt to give a definition of *volume* but will rely on our intuition and experience with solid objects to provide enough insight for us to specify the volumes of certain simple solids. For example, if the base of a rectangular box is a rectangle of length ``l`` and width ``w`` and therefore area ``A=lw``, and if the box has height ``h``, then its volume is ``V=Ah=lwh``.

A rectangular box is a special case of a solid called a *cylinder*. Such a solid has a flat base occupying a region Rin a plane, and consists of all points on parallel straight line segments having one end in Rand the other end in a (necessarily congruent) region in a second plane parallel to the plane of the base. Either of these regions can be called the base of the cylinder. The cylindrical wall is the surface consisting of the parallel line segments joining corresponding points on the boundaries of the two bases. A cylinder having a polygonal base (i.e., one bounded by straight lines) is usually called a *prism*. The height of any cylinder or prism is the perpendicular distance between the parallel planes containing the two bases. If this height is ``h`` units and the area of a base is ``A`` square units, then the volume of the cylinder or prism is ``V=Ah`` cubic units.

### Volumes by Slicing

Knowing the volume of a cylinder enables us to determine the volumes of some more general solids. We can divide solids into thin “slices” by parallel planes. (Think of a loaf of sliced bread.) Each slice is approximately a cylinder of very small “height”; the height is the thickness of the slice. If we know the cross-sectional area of each slice, we can determine its volume and sum these volumes to find the volume of the solid.

!!! definition

	The volume ``V`` of a solid between ``x=a`` and ``x=b`` having cross-sectional area ``A\left(x\right)`` at position ``x`` is

	```math
	V = \int_a^b A\left(x\right)\,\mathrm{d} x\,.
	```

### Solids of Revolution

Many common solids have circular cross-sections in planes perpendicular to some axis. Such solids are called solids of revolution because they can be generated by rotating a plane region about an axis in that plane so that it sweeps out the solid.

!!! theorem

	If the region ``R`` bounded by ``y=f\left(x\right)``, ``y=0``, ``x=a``, and ``x=b`` is rotated about the ``x``-axis, then the cross-section of the solid generated in the plane perpendicular to the ``x``-axis at ``x`` is a circular disk of radius ``\left|f\left(x\right)\right|``. The area of this cross-section is ``A\left(x\right)=\uppi\left(f\left(x\right)\right)^2``, so the volume of the solid of revolution is

	```math
	V=\uppi\int_a^b\left(f\left(x\right)\right)^2\,\mathrm{d} x\,.
	```

!!! example

	Find the volume of the right-circular cone of base radius ``r`` and height ``h`` that is generated by rotating the triangle with vertices ``\left(0,0\right)``, ``\left(h,0\right)``, and ``\left(h,r\right)`` about the ``x``-axis.

	The line from ``\left(0,0\right)`` to ``\left(h,r\right)`` has equation ``y=\frac{r}{h}x``. Thus the volume of the cone is

	```math
	V=\uppi\int_0^h\left(\frac{r}{h}x\right)^2\,\mathrm{d} x=\left.\uppi\left(\frac{r}{h}\right)^2\frac{x^3}{3}\right|_0^h=\frac{1}{3}\uppi r^2h\ \textrm{cubic units.}
	```

!!! theorem

	The volume of the solid obtained by rotating the plane region ``0\le y\le f\left(x\right)``, ``0\le a&lt;x&lt;b`` about the ``y``-axis is

	```math
	V=2\uppi\int_a^bxf\left(x\right)\,\mathrm{d} x\,.
	```

!!! example

	Find the volume of a bowl obtained by revolving the parabolic arc ``y=x^2``, ``0\le x\le1`` about the ``y``-axis.

	The interior of the bowl corresponds to revolving the region given by ``x^2 \le y\le 1``, ``0\le x\le 1`` about the ``y``-axis. The area element at position ``x`` has height ``1-x^2`` and generates a cylindrical shell of volume ``\mathrm{d} V=2\uppi x\left(1-x^2\right)\,\mathrm{d} x``. Thus, the volume of the bowl is

	```math
	V=2\uppi\int_0^1 x\left(1-x^2\right)\,\mathrm{d} x=\left.2\uppi\left(\frac{x^2}{2}-\frac{x^4}{4}\right)\right|_0^1=\frac{\uppi}{2}\ \textrm{cubic units.}
	```

We have described two methods for determining the volume of a solid of revolution, slicing and cylindrical shells. The choice of method for a particular solid is usually dictated by the form of the equations defining the region being rotated and by the axis of rotation.

## Arc Length and Surface Area

In this section we consider how integrals can be used to find the lengths of curves and the areas of the surfaces of solids of revolution.

### Arc Length

If ``A`` and ``B`` are two points in the plane, let ``\left|AB\right|`` denote the distance between ``A`` and ``B``, that is, the length of the straight line segment ``AB``.

Given a curve ``𝒞`` joining the two points ``A`` and ``B``, we would like to define what is meant by the length of the curve ``𝒞`` from ``A`` to ``B``. Suppose we choose points ``A=P_0``, ``P_1``, ``P_2``, ``\dots``, ``P_{n-1}``, and ``P_n=B`` in order along the curve. The polygonal line ``P_0P_1P_2\dots P_{n-1}P_n`` constructed by joining adjacent pairs of these points with straight line segments forms a polygonal approximation to ``𝒞``, having length

```math
L_n=\left|P_0P_1\right|+\left|P_1P_2\right|+\cdots+\left|P_{n-1}P_n\right|=\sum_{i=1}^n\left|P_{i-1}P_i\right|\,.
```

!!! definition

	The *arc length* of the curve ``𝒞`` from ``A`` to ``B`` is the smallest real number ``s`` such that the length ``L_n`` of every polygonal approximation to ``𝒞`` satisfies ``L_n\le s``.

A curve with a finite arc length is said to be *rectifiable*. Its arc length ``s`` is the limit of the lengths ``L_n`` of polygonal approximations as ``n\to \infty`` in such a way that the maximum segment length ``\left|P_{i-1}P_i\right|\to 0``.

### The Arc Length of the Graph of a Function

Let ``f`` be a function defined on a closed, finite interval ``\left[a,b\right]`` and having a continuous derivative ``f^\prime`` there. If ``𝒞`` is the graph of ``f``, that is, the graph of the equation ``y=f\left(x\right)``, then any partition of ``\left[a,b\right]`` provides a polygonal approximation to ``𝒞``. For the partition

```math
\left\{a=x_0&lt;x_1&lt;x_2&lt;\cdots&lt;x_n=b\right\}
```

let ``P_i`` be the point ``\left(x_i,f\left(x_i\right)\right)``, ``\left(0\le i\le n\right)``. The length of the polygonal line ``P_0P_1P_2\dots P_{n-1}P_n`` is

```math
\begin{aligned}
L_n=\sum_{i=1}^n\left|P_{i-1}P_i\right|&=\sum_{i=1}^n\sqrt{\left(x_i-x_{i-1}\right)^2+\left(f\left(x_i\right)-f\left(x_{i-1}\right)\right)^2}\\
&=\sum_{i=1}^n\sqrt{1+\left(\frac{f\left(x_i\right)-f\left(x_{i-1}\right)}{x_i-x_{i-1}}\right)^2}\Delta x_i\,,
\end{aligned}
```

where ``\Delta x_i=x_i-x_{i-1}``. By the Mean-Value theorem there exists a number ``c_i`` in the interval ``\left[x_{i-1},x_i\right]`` such that

```math
\frac{f\left(x_i\right)-f\left(x_{i-1}\right)}{x_i-x_{i-1}}=f^\prime\left(c_i\right)\,,
```

so we have

```math
L_n=\sum_{i=1}^n\sqrt{1+\left(f^\prime\left(c_i\right)\right)^2}\,.
```

Thus, ``L_n`` is a Riemann sum for ``\int_a^b\sqrt{1+\left(f^\prime\left(x\right)\right)^2}\,\mathrm{d} x``. Being the limit of such Riemann sums as ``n\to\infty`` in such a way that ``\max\Delta x_i \to 0``, that integral is the length of the curve ``C``.

!!! theorem

	The arc length ``s`` of the curve ``y=f\left(x\right)`` from ``x=a`` to ``x=b`` is given by

	```math
	s = \int_a^b\sqrt{1+\left(f^\prime\left(x\right)\right)^2}\,\mathrm{d} x=\int_a^b\sqrt{1+\left(\frac{\mathrm d y}{\mathrm d x}\right)^2}\,\mathrm{d} x\,.
	```

!!! example

	Find the length of the curve ``y=x^\frac{2}{3}`` from ``x=1`` to ``x=8``.

	Since ``\frac{\mathrm d y}{\mathrm d x}=\frac{2}{3}x^{-\frac{1}{3}}`` is continuous between ``x=1`` and ``x=8``, the length of the curve is given by

	```math
	\begin{aligned}
	s&=\int_1^8\sqrt{1+\frac{4}{9}x^{-\frac{2}{3}}}\,\mathrm{d} x=\int_1^8\sqrt{\frac{9x^\frac{2}{3}+4}{9x^\frac{2}{3}}}\,\mathrm{d} x\\
	&=\int_1^8\frac{\sqrt{9x^\frac{2}{3}+4}}{3x^\frac{1}{3}}\,\mathrm{d} x\\
	&\quad\textrm{Let }u=9x^\frac{2}{3}+4,\mathrm{d} u=6x^{-\frac{2}{3}}\,\mathrm{d} x\\
	&=\frac{1}{18}\int_{13}^{40}u^\frac{1}{2}\,\mathrm{d} u=\left.\frac{1}{27}u^\frac{3}{2}\right|_{13}^{40}=\frac{40\sqrt{40}-13\sqrt{13}}{27}\ \textrm{units.}
	\end{aligned}
	```

### Areas of Surfaces of Revolution

When a plane curve is rotated (in three dimensions) about a line in the plane of the curve, it sweeps out a surface of revolution. For instance, a sphere of radius ``a`` is generated by rotating a semicircle of radius ``a`` about the diameter of that semicircle.

The area of a surface of revolution can be found by integrating an area element ``\mathrm{d} S`` constructed by rotating the arc length element ``\mathrm{d} s`` of the curve about the given line. If the radius of rotation of the element ``\mathrm{d} s`` is ``r``, then it generates, on rotation, a circular band of width ``\mathrm{d} s`` and length (circumference) ``2\uppi r``. The area of this band is, therefore,

```math
\mathrm{d} S=2\uppi r\,\mathrm{d} s\,.
```

The areas of surfaces of revolution around various lines can be obtained by integrating ``\mathrm{d} S`` with appropriate choices of ``r``. Here are some important special cases.

!!! theorem

	If ``f^\prime\left(x\right)`` is continuous on ``\left[a,b\right]`` and the curve ``y=f\left(x\right)`` is rotated about the ``x``-axis, the area of the surface of revolution so generated is

	```math
	S=2\uppi\int_a^b\left|y\right|\,\mathrm{d} s=2\uppi\int_a^b\left|f\left(x\right)\right|\sqrt{1+\left(f^\prime\left(x\right)\right)^2}\,\mathrm{d} x\,.
	```

	If the rotation is about the ``y``-axis, the surface area is

	```math
	S=2\uppi\int_a^b\left|x\right|\,\mathrm{d} s=2\uppi\int_a^b\left|x\right|\sqrt{1+\left(f^\prime\left(x\right)\right)^2}\,\mathrm{d} x\,.
	```

!!! example

	Find the surface area of a parabolic reflector whose shape is obtained by rotating the parabolic arc ``y=x^2``, ``\left(0 \le x \le 1\right)``, about the ``y``-axis.

	The arc length element for the parabola ``y=x^2`` is ``\mathrm{d} s=\sqrt{1+4x^2}\,\mathrm{d} x``, so the required surface area is

	```math
	\begin{aligned}
	S&=2\uppi\int_0^1x\sqrt{1+4x^2}\,\mathrm{d} x\\
	&\quad\textrm{Let }u=1+4x^2,\mathrm{d} u=8x\,\mathrm{d} x\\
	&=\frac{\uppi}{4}\int_1^5u^\frac{1}{2}\,\mathrm{d} u\\
	&=\left.\frac{\uppi}{6}u^\frac{3}{2}\right|_{1}^{5}=\frac{\uppi}{6}\left(5\sqrt 5-1\right)\ \textrm{square units.}
	\end{aligned}
	```
