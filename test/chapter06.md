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

The second fundamental problem addressed by calculus is the problem of areas, that is, the problem of determining the area of a region of the plane bounded by various curves. Like the problem of tangents considered in Chapter 2, many practical problems in various disciplines require the evaluation of areas for their solution, and the solution of the problem of areas necessarily involves the notion of limits. On the surface the problem of areas appears unrelated to the problem of tangents. However, we will see that the two problems are very closely related; one is the inverse of the other. Finding an area is equivalent to finding an antiderivative or, as we prefer to say, finding an integral. The relationship between areas and antiderivatives is called the Fundamental Theorem of Calculus.

## Areas as Limits of Sums

We began the study of derivatives in Chapter 4 by defining what is meant by a tangent line to a curve at a particular point. We would like to begin the study of integrals by defining what is meant by the area of a plane region, but a definition of area is much more difficult to give than a definition of tangency. Let us assume that we know intuitively what area means and list some of its properties.

1. The area of a plane region is a nonnegative real number of square units.
2. The area of a rectangle with width ``w`` and height ``h`` is ``A=wh``.
3. The areas of congruent plane regions are equal.
4. If region ``S`` is contained in region ``R``, then the area of ``S`` is less than or equal to that of ``R``.
5. If region ``R`` is a union of (finitely many) nonoverlapping regions, then the area of ``R`` is the sum of the areas of those regions.

Using these five properties we can calculate the area of any *polygon* (a region bounded by straight line segments). First, we note that properties (2) and (3) show that the area of a parallelogram is the same as that of a rectangle having the same base width and height. Any triangle can be butted against a congruent copy of itself to form a parallelogram, so a triangle has area half the base width times the height. Finally, any polygon can be subdivided into finitely many nonoverlapping triangles so its area is the sum of the areas of those triangles.

We can’t go beyond polygons without taking limits. If a region has a curved boundary, its area can only be approximated by using rectangles or triangles; calculating the exact area requires the evaluation of a limit. We showed how this could be done for a circle in Section 3.1.

We are going to consider how to find the area of a region ``R`` lying under the graph ``y=f\left(x\right)`` of a nonnegative-valued, continuous function ``f``, above the ``x``-axis and between the vertical lines ``x=a`` and ``x=b``, where ``a&lt;b``. To accomplish this, we proceed as follows. Divide the interval ``\left[a,b\right]``into ``n`` subintervals by using division points:

```math
a=x_0&lt;x_1&lt;x_2&lt;x_3&lt;\cdots&lt;x_{n-1}&lt;x_n=b
```

Denote by ``\Delta\kern-0.5pt x_i`` the length of the ``i``th subinterval ``\left[x_{i-1},x_i\right]``:

```math
\Delta\kern-0.5pt x_i=x_i-x_{i-1},\quad\forall i\in\left\{1,2,3,\dots,n\right\}\,.
```

Vertically above each subinterval ``\left[x_{i-1},x_i\right]`` build a rectangle whose base has length ``\Delta\kern-0.5pt x_i`` and whose height is ``f\left(x_i\right)``. The area of this rectangle is ``f\left(x_i\right)\Delta\kern-0.5pt x_i``. Form the sum of these areas:

```math
S_n=\sum_{i=1}^n f\left(x_i\right)\Delta\kern-0.5pt x_i\,.
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

The rectangles are shown shaded in the figure for a decreasing function ``f``. For an increasing function, the tops of the rectangles would lie above the graph of ``f`` rather than below it. Evidently, ``S_n`` is an approximation to the area of the region ``R``, and the approximation gets better as ``n`` increases, provided we choose the points ``a=x_0&lt;x_1&lt;x_2&lt;x_3&lt;\cdots&lt;x_{n-1}&lt;x_n=b`` in such a way that the width ``\Delta\kern-0.5pt x_i`` of the widest rectangle approaches zero.

Subdividing a subinterval into two smaller subintervals reduces the error in the approximation by reducing that part of the area under the curve that is not contained in the rectangles. It is reasonable, therefore, to calculate the area of ``R`` by finding the limit of ``S_n`` as ``n`` with the restriction that
the largest of the subinterval widths ``\Delta\kern-0.5pt x_i`` must approach zero:

```math
\textrm{Area of }R=\lim_{
	\begin{aligned}n&\to\infty\\
\max &\Delta\kern-0.5pt x_i\to 0
\end{aligned}
}S_n\,.
```

## The Definite Integral

We generalize and make more precise the procedure used for finding areas developed in the previous section, and we use it to define the *definite integral* of a function *f* on an interval *I*:

Let a partition ``P`` of ``\left[a,b\right]`` be a finite, ordered set of points ``P=\left\{x_0,x_1,x_2,\dots,x_n\right\}`` , where ``a=x_0&lt;x_1&lt;x_2&lt;x_3&lt;\cdots&lt;x_{n-1}&lt;x_n=b``. Such a partition subdivides ``\left[a,b\right]`` into ``n`` subintervals ``\left[x_{i-1},x_i\right]``, where ``n=n\left(P\right)`` depends on the partition. The length of the ``i``th subinterval ``\left[x_{i-1},x_i\right]`` is ``\Delta\kern-0.5pt x_i=x_i-x_{i-1}``.

Suppose that the function ``f`` is bounded on ``\left[a,b\right]``. Given any partition ``P``, the ``n`` sets ``S_i=\left\{f\left(x\right)\mid x_{i-1}\le x\le x_i\right\}`` have least upper bounds ``M_i`` and greatest lower bounds ``m_i``, so that

```math
m_j\le f\left(x\right)\le M_i\quad\forall x\in\left[x_{i-1},x_i\right]\,.
```

We define *upper* and *lower Riemann sums* for ``f`` corresponding to the partition ``P`` to be

```math
U\left(f,P\right)=\sum_{i=1}^{n\left(P\right)}M_i\Delta\kern-0.5pt x_i\quad\textrm{and}\quad L\left(f,P\right)=\sum_{i=1}^{n\left(P\right)}m_i\Delta\kern-0.5pt x_i\,.
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

Note that if ``f`` is continuous on ``\left[a,b\right]``, then ``m_i`` and ``M_i`` are, in fact, the minimum and maximum values of ``f`` over ``\left[x_{i-1},x_i\right]``by the Extreme-Value Theorem, that is, ``m_i=f\left(l_i\right)`` and ``M_i=\left(u_i\right)``, where ``f\left(l_i\right)\le f\left(x\right)\le f\left(u_i\right)`` for ``x\in \left[x_{i-1},x_i\right]``.

!!! example

	Calculate the lower and upper Riemann sums for the function ``f\left(x\right)=x^2`` on the interval ``\left[0,a\right]``(where ``a &gt; 0``), corresponding to the partition ``P_n`` of ``\left[0,a\right]`` into ``n`` subintervals of equal length.

	Each subinterval of ``P_n`` has length ``\Delta\kern-0.5pt x=\frac{a}{n}``, and the division points are given by ``x_i=\frac{ia}{n}`` for ``i= 0, 1, 2,\dots, n``. Since ``x^2`` is increasing on ``\left[0,a\right]``, its minimum and maximum values over the ``i``th subinterval ``\left[x_{i-1},x_i\right]``occur at ``l_i=x_{i-1}`` and ``u_i=x_i``, respectively. Thus, the lower Riemann sum of ``f`` for ``P_n`` is

	```math
	\begin{aligned}
	L\left(f,P_n\right)&=\sum_{i=1}^nx_{i-1}^2\Delta\kern-0.5pt x=\frac{a^3}{n^3}\sum_{i=1}^n\left(i-1\right)^2\\
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
	U\left(f,P_n\right)&=\sum_{i=1}^nx_i^2\Delta\kern-0.5pt x\\
	&=\frac{a^3}{n^3}\sum_{i=1}^ni^2=\frac{a^3}{n^3}\frac{n\left(n+1\right)\left(2n+1\right)}{6}=\frac{\left(n+1\right)\left(2n+1\right)a^3}{6n^2}\,.
	\end{aligned}
	```

If ``P`` is any partition of ``\left[a,b\right]`` and we create a new partition ``P^\star`` by adding new subdivision points to those of ``P``, thus subdividing the subintervals of ``P`` into smaller ones, then we call ``P^\star`` a *refinement* of ``P``.

!!! theorem

	If ``P^\star`` is a refinement of ``P``, then ``L\left(f,P^\star\right)\ge L\left(f,P\right)`` and ``U\left(f,P^\star\right)\le U\left(f,P\right)``.

!!! proof

	If ``S`` and ``T`` are sets of real numbers, and ``S\subset T``, then any lower bound (or upper bound) of ``T`` is also a lower bound (or upper bound) of ``S``. Hence, the greatest lower bound of ``S`` is at least as large as that of ``T``; and the least upper bound of ``S`` is no greater than that of ``T``.

	Let ``P`` be a given partition of ``\left[a,b\right]`` and form a new partition ``P^\prime`` by adding one subdivision point to those of ``P``, say, the point ``k`` dividing the ``i``th subinterval ``\left[x_{i-1},x_i\right]`` of ``P`` into two subintervals ``\left[x_{i-1},k\right]``and ``\left[x_{i-1},k\right]``. 
	Let ``m_i``, ``m_i^\prime`` and ``m_i^{\prime\prime}`` be the greatest lower bounds of the sets of values of ``f\left(x\right)``  on the intervals ``\left[x_{i-1},x_i\right]``, ``\left[x_{i-1},k\right]``and ``\left[k,x_i\right]``, respectively. Then ``m_i\le m_i^\prime`` and ``m_i\le m_i^{\prime\prime}``. 
	Thus,

	```math
	m_i\left(x_i-x_{i-1}\right)\le m_i^\prime\left(k-x_{i-1}\right)+m_i^{\prime\prime}\left(x_i-k\right)\,,
	```

	so ``L\left(f,P\right)\le L\left(f,P^\prime\right)``.

	If ``P^\star`` is a refinement of ``P``, it can be obtained by adding one point at a time to those of ``P`` and thus ``L\left(f,P\right)\le L\left(f,P^\star\right)``.
	
	We can prove that ``U\left(f,P^\star\right)\le U\left(f,P\right)`` in a similar manner.

!!! theorem

	If ``P`` and ``P^\prime`` are two partitions of ``\left[a,b\right]``, then ``L\left(f,P\right)\le U\left(f,P^\star\right)``.

!!! proof

	Combine the subdivision points of ``P`` and ``P^\prime`` to form a new partition ``P^\star``, which is a refinement of both ``P`` and ``P^\prime``. Then by the previous theorem,

	```math
	L\left(f,P\right)\le L\left(f,P^\star\right)\le U\left(f,P^\star\right)\le U\left(f,P^\prime\right)\,.
	```

	No lower sum can exceed any upper sum.

The last theorem shows that the set of values of ``L\left(f, P\right)`` for fixed ``f`` and various partitions ``P`` of ``\left[a,b\right]`` is a bounded set; any upper sum is an upper bound for this set. By completeness, the set has a least upper bound, which we shall denote ``I_\star``. Thus, ``L\left(f,P\right)\le I_\star`` for any partition ``P``. Similarly, there exists a greatest lower bound ``I^\star`` for the set of values of ``U\left(f, P\right)`` corresponding to different partitions ``P``. 

!!! theorem

	``I_\star\le I^\star``.

!!! proof "by contradiction"

	Let ``S`` and ``T`` be sets of real numbers, such that for any ``x\in S`` and any ``y\in T`` we have ``x\le y``. Because every ``x`` is a lower bound of ``T``,  we have ``x\le\inf T``.

	Suppose ``\sup S &gt; \inf T``. ``\inf T`` cannot be an upper bound of ``S``, so there exists ``x^\prime\in S`` for which ``x^\prime &gt; \inf T``. This is impossible.

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
	\int_a^b f\left(x\right)\,\mathrm{d}\kern-0.5pt x=I_\star=I^\star
	```

	the (*Darboux*) *integral* of ``f`` on ``\left[a,b\right]``\,.

!!! example

	Show that ``f\left(x\right)=x^2`` is integrable over the interval ``\left[0,a\right]`` (where ``a &gt; 0``), and evaluate

	```math
	I=\int_0^a f\left(x\right)\,\mathrm{d}\kern-0.5pt x
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
	\int_0^a f\left(x\right)\,\mathrm{d}\kern-0.5pt x=\int_0^a x^2\,\mathrm{d}\kern-0.5pt x=\frac{a^3}{3}\,.
	```

It can be shown that the *Darboux integral* is equivalent to the better known *Riemann integral*

```math
\int_a^b f\left(x\right)\,\mathrm{d}\kern-0.5pt x=\lim_{\begin{aligned}n&\to\infty\\\max &\Delta\kern-0.5pt x_i\to 0\end{aligned}}\sum_{i=1}^n f\left(x^\prime_i\right)\Delta\kern-0.5pt x_i\,,
```

where ``x^\prime_i`` is an arbitrary point in ``\left[x_{i-1},x_i\right]``. The Darboux integral is easier to use than the more intuitive Riemann integral.

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

To prove that a continuous functions on an interval ``\left[a,b\right]`` is integrable. We are still missing one piece of the puzzle, the notion of *uniformly continuous* functions.

!!! definition

	A function is uniformly continuous on an interval ``I`` if for every ``\varepsilon&gt;0`` there exists a ``\delta>0`` such that, for all ``x,y\in I``, ``\left|x-y\right|&lt;\delta`` implies ``\left|f\left(x\right)-f\left(y\right)\right|&lt;\varepsilon``:

	```math
	\forall\varepsilon&gt;0,\exists\delta&gt;0:\left|x-y\right|&lt;\delta\implies\left|f\left(x\right)-f\left(y\right)\right|&lt;\varepsilon\,.
	```

If a function is continuous on an interval ``I``, the positive number ``\delta`` can depend both on ``\varepsilon`` and the point ``x\in I``. For a function uniformly continuous on an interval ``\left[a,b\right]``, we can always find a positive number ``\delta`` that only depends on ``\varepsilon``.

We will now show that the both notion of continuity of a function are identical for a closed interval ``\left[a,b\right]``. As is the case for all hard theorems, we need a technical lemma.

!!! lemma

	Let ``\left[a,c\right]`` and ``\left[c,b\right]`` be two closed intervals with a common endpoint ``c`` and ``f`` a continuous function on ``\left[a,b\right]``. If the following two statements hold for any ``\varepsilon &gt;0``:
	
	1. there exists ``\delta_1 &gt;0`` such that ``\forall x,y\in\left[a,c\right]:\left|x-y\right|&lt;\delta_1`` implies ``\left|f\left(x\right)-f\left(y\right)\right|&lt;\varepsilon``,
	2. there exists ``\delta_2 &gt;0`` such that ``\forall x,y\in\left[c,b\right]:\left|x-y\right|&lt;\delta_2`` implies ``\left|f\left(x\right)-f\left(y\right)\right|&lt;\varepsilon``,

	then there exists ``\delta&gt;0`` such that ``\forall x,y\in\left[a,b\right]:\left|x-y\right|&lt;\delta`` implies ``\left|f\left(x\right)-f\left(y\right)\right|&lt;\varepsilon``.

!!! proof

	Suppose ``x&lt;c&lt;y``. 
	
	Since ``f`` is continuous at ``c``, there exists ``\delta_3&gt;0`` such that ``\left|x-c\right|&lt;\delta_3`` implies ``\left|f\left(x\right)-f\left(c\right)\right|&lt;\frac{\varepsilon}{2}``. Similarly, there exists ``\delta_4&gt;0`` such that ``\left|y-c\right|&lt;\delta_4`` implies ``\left|f\left(y\right)-f\left(c\right)\right|&lt;\frac{\varepsilon}{2}``.

	Therefore,

	```math
	\begin{aligned}
	\left|f\left(x\right)-f\left(y\right)\right|&=\left|f\left(x\right)-f\left(c\right)+f\left(c\right)-f\left(y\right)\right|\\
	&\le\left|f\left(x\right)-f\left(c\right)\right|+\left|f\left(c\right)-f\left(y\right)\right|\\
	&&lt;\frac{\varepsilon}{2}+\frac{\varepsilon}{2}=\varepsilon\,.
	\end{aligned}
	```

	Let ``\delta=\min\left\{\delta_1, \delta_2, \delta_3, \delta_4\right\}`` and ``\forall x,y \in\left[a,b\right]:\left|x-y\right|&lt;\delta``.

	- If ``x,y\in\left[a,c\right]``, then ``\left|x-y\right|&lt;\delta`` implies ``\left|x-y\right|&lt;\delta_1`` such that ``\left|f\left(x\right)-f\left(y\right)\right|&lt;\varepsilon``.
	- If ``x,y\in\left[c,b\right]``, then ``\left|x-y\right|&lt;\delta`` implies ``\left|x-y\right|&lt;\delta_2`` such that ``\left|f\left(x\right)-f\left(y\right)\right|&lt;\varepsilon``.
	- If ``x&lt;c&lt;y``, then ``\left|x-y\right|&lt;\delta`` implies ``\left|x-c\right|&lt;\delta_3`` and ``\left|y-c\right|&lt;\delta_4`` such that ``\left|f\left(x\right)-f\left(y\right)\right|&lt;\varepsilon``.

	This shows that ``\forall x,y\in\left[a,b\right]:\left|x-y\right|&lt;\delta`` implies ``\left|f\left(x\right)-f\left(y\right)\right|&lt;\varepsilon``.

We can now use the Bisection Method to prove the Uniform Continuity Theorem.

!!! theorem "Uniform Continuity Theorem"

	If ``f`` is continuous on the closed, finite interval ``\left[a,b\right]``, then ``f`` is uniformly continuous on that interval.

!!! proof "by contradiction"

	Suppose ``f`` is continuous on ``I_0=\left[a,b\right]=\left[a_0,b_0\right]`` but not uniformly continuous.

	Then, there exists ``\varepsilon&gt;0`` such that for every ``\delta&gt;0`` there exists ``x,y\in\left[a_0,b_0\right]`` such that ``\left|x-y\right|&lt;\delta`` but ``\left|f\left(x\right)-f\left(y\right)\right|\ge\varepsilon``.

	From the lemma, it follows that at least one of the two subintervals ``\left[a_0,\frac{a_0+b_0}{2}\right]`` and ``\left[\frac{a_0+b_0}{2},b_0\right]`` has the property that for every ``\delta&gt;0`` there exist ``x,y`` in the interval such that ``\left|x-y\right|&lt;\delta`` but ``\left|f\left(x\right)-f\left(y\right)\right|\ge\varepsilon``. Otherwise our assumption would be contradicted by the lemma.

	Choose a subinterval having this property and call it ``I_1=\left[a_1,b_1\right]``. 
	
	Continuing in this ways, we obtain a sequence of closed intervals satisfying the hypotheses of the Nested Intervals Theorem and having the property that for every ``\delta&gt;0`` there exist ``x,y`` in the interval such that ``\left|x-y\right|&lt;\delta`` but ``\left|f\left(x\right)-f\left(y\right)\right|\ge\varepsilon``.

	By the Nested Intervals Theorem, there exists ``c=\sup\left\{a_n\right\}=\inf\left\{b_n\right\}``.

	Since ``f`` is continuous at ``c``, corresponding to the ``\varepsilon`` above, there exists ``\delta_1&gt;0`` such that ``\left|x-c\right|&lt\delta_1`` implies ``\left|f\left(x\right)-f\left(c\right)\right|&lt;\frac{\varepsilon}{2}``. Similarly, there exists ``\delta_2&gt;0`` such that ``\left|y-c\right|&lt\delta_1`` implies ``\left|f\left(y\right)-f\left(c\right)\right|&lt;\frac{\varepsilon}{2}``. Let ``\delta_0=\min\left\{\delta_1, \delta_2\right\}``.

	The Capture Theorem states that the interval ``\left]c-\frac{\delta_0}{2},c+\frac{\delta_0}{2}\right[`` contains ``I_N`` for some ``N\in\mathbb N``.

	Since the length of the interval ``\left]c-\frac{\delta_0}{2},c+\frac{\delta_0}{2}\right[`` is ``\delta_0``,  we have ``\left|x-y\right|&lt;\delta_0`` for every ``x,y\in\left]c-\frac{\delta_0}{2},c+\frac{\delta_0}{2}\right[``. By our choice of the ``I_n``, there exists ``x,y\in I_N`` with ``\left|x-y\right|&lt;\delta_0`` but ``\left|f\left(x\right)-f\left(y\right)\right|\ge\varepsilon``.

	Since ``\left|x-c\right|&lt\delta_0`` and ``\left|y-c\right|&lt\delta_0`` for every ``x,y\in\left]c-\frac{\delta_0}{2},c+\frac{\delta_0}{2}\right[``, it follows that

	```math
	\begin{aligned}
	\left|f\left(x\right)-f\left(y\right)\right|&=\left|f\left(x\right)-f\left(c\right)+f\left(c\right)-f\left(y\right)\right|\\
	&\le\left|f\left(x\right)-f\left(c\right)\right|+\left|f\left(c\right)-f\left(y\right)\right|\\
	&&lt;\frac{\varepsilon}{2}+\frac{\varepsilon}{2}=\varepsilon\,.
	\end{aligned}
	```
	
	This is impossible. Therefore, ``f`` is uniformly continuous on ``\left[a,b\right]``.
	

We are now in a position to prove that a continuous function is integrable.

!!! theorem

	If ``f`` is continuous on ``\left[a,b\right]``, then ``f`` is integrable on ``\left[a,b\right]``.

!!! proof

	First note that, since ``f`` is continuous on ``\left[a,b\right]``, it is bounded on ``\left[a,b\right]``.

	Let ``\varepsilon&gt;0``. Since ``f`` is continuous, it is uniformly continuous on ``\left[a,b\right]``, so corresponding to ``\frac{\varepsilon}{b-a}&gt;0`` there exists ``\delta&gt; 0`` such that for all ``x, y\in\left[a,b\right]``, ``\left|x-y\right|&lt;\delta`` implies ``\left|f\left(x\right)-f\left(y\right)\right|&lt;\frac{\varepsilon}{b-a}``.

	Choose a partition ``P=\left\{x_0,x_1,x_2,\dots,x_n\right\}`` for which each subinterval ``\left[x_{i-1},x_i\right]`` has length ``\Delta\kern-0.5pt x_i&lt;\delta``.

	By the Extreme-Value Theorem, the least upper bound, ``M_i``, and the greatest lower bound ``m_i`` of the set of values of ``f\left(x\right)`` on ``\left[x_{i-1},x_i\right]`` satisfy ``M_i-m_i&lt;\frac{\varepsilon}{b-a}``.

	Accordingly,

	```math
	U\left(f,P\right)-L\left(f,P\right)&lt;\frac{\varepsilon}{b-a}\sum_{i=1}^{n\left(P\right)}\Delta\kern-0.5pt x_i=\frac{\varepsilon}{b-a}\left(b-a\right)=\varepsilon\,.
	```

	Thus, ``f`` is integrable on ``\left[a,b\right]``.

## Properties of the Definite Integral

It is convenient to extend the definition of the definite integral ``\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x`` to allow ``a=b`` and ``a&gt;b`` as well as ``a&lt; b``. The extension still involves partitions ``P`` having ``x_0=a`` and ``x_n=b`` with intermediate points occurring in order between these end points, so that if ``a=b``, then we must have ``\Delta\kern-0.5pt x_i=0`` for every ``i``, and hence the integral is zero. If ``a&gt;b``, we have ``\Delta\kern-0.5pt x_i&lt; 0`` for each ``i``, so the integral will be negative for positive functions ``f`` and vice versa.

### Basic Properties

Some of the most important properties of the definite integral are summarized in the following theorem.

!!! theorem

	Let ``f`` and ``g`` be integrable on an interval containing the points ``a``, ``b``, and ``c``.

	1. ``\displaystyle\int_a^af\left(x\right)\,\mathrm{d}\kern-0.5pt x=0\,.``

	2. ``\displaystyle\int_b^af\left(x\right)\,\mathrm{d}\kern-0.5pt x=\displaystyle\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x\,.``

	3. ``\displaystyle\int_a^b\left(Af\left(x\right)+Bg\left(x\right)\right)\,\mathrm{d}\kern-0.5pt x=A\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x+B\int_a^bg\left(x\right)\,\mathrm{d}\kern-0.5pt x\,.``

	4. ``\displaystyle\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x+\int_b^cf\left(x\right)\,\mathrm{d}\kern-0.5pt x=\int_a^cf\left(x\right)\,\mathrm{d}\kern-0.5pt x\,.``

	5. If ``a\le b`` and ``f\left(x\right)\le g\left(x\right)`` for ``x\in\left[a,b\right]``, then ``\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x\le\int_a^bg\left(x\right)\,\mathrm{d}\kern-0.5pt x\,.``

	6. If ``a\le b``, ``\displaystyle\left|\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x\right|\le\int_a^b\left|f\left(x\right)\right|\,\mathrm{d}\kern-0.5pt x`` (*triangle inequality*).
	
The proofs of parts (1) and (2) are suggested in the first paragraph of this section. The other proofs are more challenging. We will start with the integrability of the sum of two integrable functions

```math
\displaystyle\int_a^b\left(f\left(x\right)+g\left(x\right)\right)\,\mathrm{d}\kern-0.5pt x=\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x+\int_a^bg\left(x\right)\,\mathrm{d}\kern-0.5pt x\,.
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
	\begin{aligned}
	\inf\left\{f\left(x\right)\mid x\in \left[x_{i-1},x_i\right]\right\}+\inf\left\{g\left(x\right)\mid x\in \left[x_{i-1},x_i\right]\right\}&\le\inf\left\{f\left(x\right)+g\left(x\right)\mid x\in\left[x_{i-1},x_i\right]\right\}\textrm{ and}\\
	\sup\left\{f\left(x\right)\mid x\in \left[x_{i-1},x_i\right]\right\}+\sup\left\{g\left(x\right)\mid x\in \left[x_{i-1},x_i\right]\right\}&\ge\sup\left\{f\left(x\right)+g\left(x\right)\mid x\in \left[x_{i-1},x_i\right]\right\}\,.
	\end{aligned}
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
	\int_a^b\left(f\left(x\right)+g\left(x\right)\right)\,\mathrm{d}\kern-0.5pt x&=I^\star\left(f+g\right)\le U\left(f+g,P\right)\le U\left(f,P\right)+ U\left(g,P\right)\\
	&&lt;L\left(f,P\right)+ L\left(g,P\right)+\varepsilon\le I_\star\left(f\right)+I_\star\left(g\right)+\varepsilon=\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x+\int_a^bg\left(x\right)\,\mathrm{d}\kern-0.5pt x+\varepsilon
	\end{aligned}
	```

	and

	```math
	\begin{aligned}
	\int_a^b\left(f\left(x\right)+g\left(x\right)\right)\,\mathrm{d}\kern-0.5pt x&=I_\star\left(f+g\right)\ge L\left(f+g,P\right)\le L\left(f,P\right)+ L\left(g,P\right)\\
	&&gt;U\left(f,P\right)+ U\left(g,P\right)-\varepsilon\ge I^\star\left(f\right)+I^\star\left(g\right)-\varepsilon=\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x+\int_a^bg\left(x\right)\,\mathrm{d}\kern-0.5pt x-\varepsilon
	\end{aligned}
	```

	are true for all ``\varepsilon``, we have

	```math
	\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x+\int_a^bg\left(x\right)\,\mathrm{d}\kern-0.5pt x-\varepsilon=\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x+\int_a^bg\left(x\right)\,\mathrm{d}\kern-0.5pt x\,.
	```

!!! exercise

	Prove the integrability of a constant times an integrable function

	```math
	\displaystyle\int_a^b\left(Af\left(x\right)\right)\,\mathrm{d}\kern-0.5pt x=A\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x\,.
	```

	Hint: consider the cases ``A`` positive and negative.

Now, we will prove the additive dependency of an integral on the interval of integration

```math
\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x+\int_b^cf\left(x\right)\,\mathrm{d}\kern-0.5pt x=\int_a^cf\left(x\right)\,\mathrm{d}\kern-0.5pt x\,.
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
	\int_a^cf\left(x\right)\,\mathrm{d}\kern-0.5pt x&\le U_a^c\left(f, P\right)=U_a^b\left(f,P_1\right)+U_b^c\left(f,P_2\right)\\
	&&lt;L_a^b\left(f,P_1\right)+L_b^c\left(f,P_2\right)+\varepsilon\le\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x+\int_b^cf\left(x\right)\,\mathrm{d}\kern-0.5pt x+\varepsilon
	\end{aligned}
	```

	and 

	```math
	\begin{aligned}
	\int_a^cf\left(x\right)\,\mathrm{d}\kern-0.5pt x&\ge L_a^c\left(f, P\right)=L_a^b\left(f,P_1\right)+L_b^c\left(f,P_2\right)\\
	&&gt;U_a^b\left(f,P_1\right)+U_b^c\left(f,P_2\right)-\varepsilon\le\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x+\int_b^cf\left(x\right)\,\mathrm{d}\kern-0.5pt x-\varepsilon
	\end{aligned}
	```

	are true for all ``\varepsilon``, we have

	```math
	\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x+\int_b^cf\left(x\right)\,\mathrm{d}\kern-0.5pt x=\int_a^cf\left(x\right)\,\mathrm{d}\kern-0.5pt x\,.
	```

!!! exercise

	Prove the integrability of the absolute value of an integrable function.

	Hint: for any interval ``\left[x_{i-1},x_i\right]\in\left[a,b\right]``, we have

	```math
	\sup\left\{\left|f\left(x\right)\right|\mid x\in \left[x_{i-1},x_i\right]\right\}-\inf\left\{\left|f\right|\left(x\right)\mid x\in \left[x_{i-1},x_i\right]\right\}\le\sup\left\{f\left(x\right)\mid x\in \left[x_{i-1},x_i\right]\right\}-\inf\left\{f\left(x\right)\mid x\in \left[x_{i-1},x_i\right]\right\}\,.
	```

### Mean-Value Theorem for Integrals

A simple but very useful result is the Mean-Value Theorem for integrals.

!!! theorem

	If ``f`` is continuous on ``\left[a,b\right]``, then there exists a point ``c\in\left[a,b\right]`` such that

	```math
	\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x=\left(b-a\right)f\left(c\right)\,.
	```

!!! proof

	Let ``f`` be a function continuous on the interval ``\left[a,b\right]``. Then ``f`` assumes a minimum value ``m`` and a maximum value ``M`` on the interval, say at points ``x=l`` and ``x=u``, respectively:

	```math
	\forall x\in \left[a,b\right]: m=f\left(l\right)\le f\left(x\right)\le f\left(u\right)=M\,.
	```

	For the partition ``P`` of ``\left[a,b\right]`` having ``x_0=a`` and ``x_1=b``, we have

	```math
	m\left(b-a\right)=L\left(f,P\right)\le\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x\le U\left(f,P\right)=M\left(b-a\right)\,.
	```

	Therefore,

	```math
	f\left(l\right)=m\le\frac{1}{b-a}\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x\le M=f\left(u\right)\,.
	```

	By the Intermedidate-Value theorem, ``f\left(x\right)`` must take on every value between the two values ``f\left(l\right)`` and ``f\left(u\right)``. Hence, there is a number ``c`` between ``l`` and ``u`` such that

	```math
	f\left(c\right)=\frac{1}{b-a}\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x\,.
	```

The integral ``\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x`` is equal to the area ``\left(b-a\right)f\left(c\right)`` of a rectangle with base width ``b-a`` and height ``f\left(c\right)`` for some ``c\in \left[a,b\right]``.

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
	\bar f = \frac{1}{b-a}\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x\,.
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

Consider the graph ``y=f\left(x\right)`` shown above. Although ``f`` is not continuous at all points in ``\left[a,b\right]``(it is discontinuous at ``c_1`` and ``c_2``), clearly the region lying under the graph and above the ``x``-axis between ``x= a`` and ``x= b`` does have an area. We would like to represent this area as

```math
\int_a^{c_1}f\left(x\right)\,\mathrm{d}\kern-0.5pt x+\int_{c_1}^{c_2}f\left(x\right)\,\mathrm{d}\kern-0.5pt x+\int_{c_2}^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x\,.
```

This is reasonable because there are continuous functions (extensions) on ``\left[a,c_1\right]``, ``\left[c_1,c_2\right]``, and ``\left[c_2,b\right]`` equal to  ``f\left(x\right)`` on the corresponding open intervals, ``\left]a,c_1\right[``, ``\left]c_1,c_2\right[``, and ``\left]c_2,b\right[``.

!!! definition

	Let ``c_0 &lt; c_1 &lt; c_2 &lt; \cdots &lt; c_n`` be a finite set of points on the real line. A function ``f`` defined on ``\left[c_0,c_n\right]`` except possibly at some of the points ``c_i``, is called piecewise continuous on that interval if for each ``i`` there exists a function ``F_i`` continuous on the closed interval ``\left[c_{i-1},c_i\right]`` such that

	```math
	f\left(x\right)=F_i\left(x\right)\quad\textrm{on the \it open interval }\left]c_{i-1},c_i\right[\,.
	```

	In this case, we define the definite integral of ``f`` from ``c_0`` to ``c_n`` to be

	```math
	\int_{c_0}^{c_n}f\left(x\right)\,\mathrm{d}\kern-0.5pt x=\sum_{i=1}^n\int_{c_{i-1}}^{c_i}F_i\left(x\right)\,\mathrm{d}\kern-0.5pt x\,.
	```

!!! example

	Find ``\displaystyle\int_{0.5}^{3.5}f\left(x\right)\,\mathrm{d}\kern-0.5pt x``, where

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
	\int_{0.5}^{3.5}f\left(x\right)\,\mathrm{d}\kern-0.5pt x&=\int_{0.5}^{1.5}\sqrt{1-\left(x-0.5\right)^2}\,\mathrm{d}\kern-0.5pt x+\int_{1.5}^{2.5}2\,\mathrm{d}\kern-0.5pt x+\int_{2.5}^{3.5}\left(x-2.5\right)\,\mathrm{d}\kern-0.5pt x\\
	&=\left(\frac{1}{4}\times\uppi^2\times 1^2\right)+\left(2\times 1\right)+\left(\frac{1}{2}\times1\times 1\right)=\frac{\uppi+10}{4}\,.
	\end{aligned}

## The Fundamental Theorem of Calculus

In this section we demonstrate the relationship between the definite integral defined and the indefinite integral (or general antiderivative). A consequence of this relationship is that we will be able to calculate definite integrals of functions whose antiderivatives we can find.

!!! theorem "Fundamental Theorem of Calculus Part 1"

	If ``g`` is a continuous function on ``\left[a,b\right]`` that is differentiable on ``\left]a,b\right[``, and if ``g^\prime`` is integrable on ``\left[a,b\right]``, then

	```math
	\int_a^b g^\prime\left(x\right)\,\mathrm{d}\kern-0.5pt x=g\left(b\right)-g\left(a\right)\,.
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
	L\left(g^\prime,P\right)\le \int_a^b g^\prime\left(x\right)\,\mathrm{d}\kern-0.5pt x\le U\left(g^\prime,P\right)\,,
	```

	so the Darboux integrability criterion implies

	```math
	\left|\int_a^b g^\prime\left(x\right)\,\mathrm{d}\kern-0.5pt x-\left(g\left(b\right)-g\left(a\right)\right)\right|&lt;\varepsilon\,.
	```

	This is true for all ``\varepsilon``, so

	```math
	\int_a^b g^\prime\left(x\right)\,\mathrm{d}\kern-0.5pt x=g\left(b\right)-g\left(a\right)\,.
	```

To facilitate the evaluation of definite integrals using the Fundamental Theorem of Calculus Part 1, we define the *evaluation symbol*

!!! definition

	``\displaystyle \left.F\left(x\right)\right|_a^b=F\left(b\right)-F\left(a\right)\,.``

Thus,

```math
\int_a^b f\left(x\right)\,\mathrm{d}\kern-0.5pt x=\left.\left(\int f\left(x\right)\,\mathrm{d}\kern-0.5pt x\right)\right|_a^b\,,
```

where ``\displaystyle \int f\left(x\right)\,\mathrm{d}\kern-0.5pt x`` denotes the indefinite integral or general antiderivative of ``f``. When evaluating a definite integral this way, we will omit the constant of integration (``C``) from the indefinite integral because it cancels out in the subtraction:

```math
\left.\left(F\left(x\right)+C\right)\right|_a^b=F\left(b\right)+C-\left(F\left(a\right)+C\right)=F\left(b\right)-F\left(a\right)=\left.F\left(x\right)\right|_a^b\,.
```
	
!!! example

	Evaluate ``\displaystyle \int_0^a x^2\,\mathrm{d}\kern-0.5pt x``.

	``\displaystyle \int_0^a x^2\,\mathrm{d}\kern-0.5pt x=\left.\frac{1}{3}x^3\right|_0^a=\frac{1}{3}a^3-\frac{1}{3}0^3=\frac{a^3}{3}`` because ``\displaystyle \frac{\mathrm{d}\kern-0.5pt \hphantom{x}}{\mathrm{d}\kern-0.5pt x}\frac{x^3}{3}=x^2``.

!!! theorem "Fundamental Theorem of Calculus Part 2"

	Let ``f`` be an integrable function on ``\left[a,b\right]``. For ``x\in\left[a,b\right]``, let

	```math
	F\left(x\right)=\int_a^xf\left(t\right)\,\mathrm{d}\kern-0.5pt t\,.
	```

	Then ``F`` is continuous on ``\left[a,b\right]``. If ``f`` is continuous at ``x_0\in\left]a,b\right[``, then ``F`` is differentiable at ``x_0`` and

	```math
	F^\prime\left(x_0\right)=f\left(x_0\right)\,.
	```

!!! proof

	``f`` is an integrable function, so ``f`` is bounded on ``\left[a,b\right]`` and there exists ``B\ge 0`` such that ``\left|f\left(x\right)\right|\le B`` for ``x\in\left[a,b\right]``.

	Let ``\varepsilon &gt;0``. If ``\left|x-y\right|&lt;\frac{\epsilon}{B}`` for ``a\le x&lt; y\le b``, then

	```math
	\left|F\left(y\right)-F\left(x\right)\right|=\left|\int_y^xf\left(t\right)\,\mathrm{d}\kern-0.5pt t\right|\le \int_y^x\left|f\left(t\right)\right|\,\mathrm{d}\kern-0.5pt t\le\int_y^xB,\mathrm{d}\kern-0.5pt t=B\left(y-x\right)&lt;\varepsilon\,.
	```

	This shows that ``F`` is (uniformly) continuous on ``\left[a,b\right]``.

	Suppose ``f`` is continuous at ``x_0\in\left]a,b\right[``. We have

	```math
	\frac{F\left(x\right)-F\left(x_0\right)}{x-x_0}=\frac{1}{x-x_0}\int_{x_0}^xf\left(t\right)\,\mathrm{d}\kern-0.5pt t
	```

	for ``x\ne x_0`` and

	```math
	f\left(x_0\right)=\frac{1}{x-x_0}\int_{x_0}^xf\left(x_0\right)\,\mathrm{d}\kern-0.5pt t\,.
	```

	Therefore,

	```math
	\frac{F\left(x\right)-F\left(x_0\right)}{x-x_0}-f\left(x_0\right)=\frac{1}{x-x_0}\int_{x_0}^x\left(f\left(t\right)-f\left(x_0\right)\right)\,\mathrm{d}\kern-0.5pt t\,.
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

	Find the derivative of ``\displaystyle F\left(x\right)=\int_{x^2}^{x^3}ℯ^{-t^2}\,\mathrm{d}\kern-0.5pt t``.

	```math
	\begin{aligned}
	F\left(x\right)&=\int_{0}^{x^3}ℯ^{-t^2}\,\mathrm{d}\kern-0.5pt t-\int_{0}^{x^2}ℯ^{-t^2}\,\mathrm{d}\kern-0.5pt t\\
	F^\prime\left(x\right)&=ℯ^{-\left(x^3\right)^2}\left(3x^2\right)-ℯ^{-\left(x^2\right)^2}\left(2x\right)\\
	&=3x^2ℯ^{-x^6}-2xℯ^{-x^4}\,.
	\end{aligned}
	```

We can build the Chain Rule into the Fundamental Theorem of Calculus part 2

```math
\frac{\mathrm{d}\kern-0.5pt \hphantom{x}}{\mathrm{d}\kern-0.5pt x}\int^{g\left(x\right)}_{h\left(x\right)}f\left(t\right)\,\mathrm{d}\kern-0.5pt t=f\left(g\left(x\right)\right)g^\prime\left(x\right)-f\left(h\left(x\right)\right)h^\prime\left(x\right)\,.
```

You should remember both conclusions of the Fundamental Theorem; they are both useful. Part 1 concerns the integral of a derivative; it tells you how to evaluate a definite integral if you can find an antiderivative of the integrand. Part 2 concerns the derivative of an integral; it tells you how to differentiate a definite integral with respect to its upper limit.

## Methods of Integrations

As we have seen, the evaluation of definite integrals is most easily carried out if we can antidifferentiate the integrand. In this section we develop some techniques of integration, that is, methods for finding antiderivatives of functions. Although the techniques we develop can be used for a large class of functions, they will not work for all functions we might want to integrate.

Let us begin by assembling a table of some known indefinite integrals. These results have all emerged during our development of differentiation formulas for elementary functions. You should *memorize* them.

```math
\begin{align}
&\int \mathrm{d}\kern-0.5pt x=\int 1\,\mathrm{d}\kern-0.5pt x=x+C&&\int x\,\mathrm{d}\kern-0.5pt x=\frac{x^2}{2}+C\\
&\int x^2\,\mathrm{d}\kern-0.5pt x=\frac{x^3}{3}+C&&\int\frac{1}{x^2}\, \mathrm{d}\kern-0.5pt x=\frac{1}{x}+C\\
&\int \sqrt x\,\mathrm{d}\kern-0.5pt x=\frac{2}{3}x^{\frac{3}{2}}+C&&\int \frac{1}{\sqrt x}\,\mathrm{d}\kern-0.5pt x=2\sqrt x+C\\
&\int x^r\, \mathrm{d}\kern-0.5pt x=\frac{x^{r+1}}{r+1}+C\quad\left(r\ne1\right)&&\int\frac{1}{x}\, \mathrm{d}\kern-0.5pt x=\ln\left|x\right|+C\\
&\int \sin ax\,\mathrm{d}\kern-0.5pt x=-\frac{1}{a}\cos ax+C&&\int\cos ax\, \mathrm{d}\kern-0.5pt x=\frac{1}{a}\sin ax+C\\
&\int \sec^2 ax\,\mathrm{d}\kern-0.5pt x=\frac{1}{a}\tan ax+C&&\int\csc^2 ax\, \mathrm{d}\kern-0.5pt x=-\frac{1}{a}\cot ax+C\\
&\int \frac{1}{\sqrt{a^2-x^2}}\,\mathrm{d}\kern-0.5pt x=\operatorname{Arcsin}\frac{x}{a}+C\quad\left(a&gt;0\right)&&\int \frac{1}{a^2+x^2}\,\mathrm{d}\kern-0.5pt x=\frac{1}{a}\operatorname{Arctan}\frac{x}{a}+C\\
&\int ℯ^{ax}\,\mathrm{d}\kern-0.5pt x=\frac{1}{a}ℯ^{ax}+C&&\int b^{ax}\,\mathrm{d}\kern-0.5pt x=\frac{1}{a\ln b}b^{ax}+C\\
&\int \sinh ax\,\mathrm{d}\kern-0.5pt x=\frac{1}{a}\cosh ax+C&&\int\cosh ax\, \mathrm{d}\kern-0.5pt x=\frac{1}{a}\sinh ax+C
\end{align}
```

The linearity formula

```math
\int_a^b\left(Af\left(x\right)+Bg\left(x\right)\right)\,\mathrm{d}\kern-0.5pt x=A\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x+B\int_a^bg\left(x\right)\,\mathrm{d}\kern-0.5pt x
```

makes it possible to integrate sums and constant multiples of functions.

### The Method of Substitution

When an integral cannot be evaluated by inspection, awe require one or more special techniques. The most important of these techniques is the method of substitution, the integral version of the Chain Rule. If we rewrite the Chain Rule,

```math
\frac{\mathrm{d}\kern-0.5pt \hphantom{x}}{\mathrm{d}\kern-0.5pt x}f\left(g\left(x\right)\right)=f^\prime\left(g\left(x\right)\right)g^\prime\left(x\right)\,,
```

in integral form, we obtain

```math
\int f^\prime\left(g\left(x\right)\right)g^\prime\left(x\right)\,\mathrm{d}\kern-0.5pt x=f\left(g\left(x\right)\right)+C\,.
```

Observe that the following formalism would produce this latter formula even if we did not already know it was true. Let ``u=g\left(x\right)``. Then ``\frac{\mathrm{d}\kern-0.5pt u}{\mathrm{d}\kern-0.5pt x}=g^\prime\left(x\right)``, or in differential form, ``\mathrm d\kern-0.5pt u=g^\prime\left(x\right)\mathrm d\kern-0.5pt x``. Thus,

```math
\int f^\prime\left(g\left(x\right)\right)g^\prime\left(x\right)\,\mathrm{d}\kern-0.5pt x=\int f^\prime\left(u\right)\,\mathrm{d}\kern-0.5pt u=f\left(u\right)+C=f\left(g\left(x\right)\right)+C\,.
```

!!! example

	Find the indefinite integral ``\displaystyle \int \frac{\sin\left(3\ln x\right)}{x}\,\mathrm{d}\kern-0.5pt x``.

	Let ``u=3\ln x``. Then ``\mathrm{d}\kern-0.5pt u=\frac{3}{x}\,\mathrm{d}\kern-0.5pt x`` and

	```math
	\int \frac{\sin\left(3\ln x\right)}{x}\,\mathrm{d}\kern-0.5pt x=\frac{1}{3}\int \sin u\,\mathrm{d}\kern-0.5pt u=-\frac{1}{3}\cos u+C=-\frac{1}{3}\cos\left(3\ln x\right)+C\,.
	```

!!! theorem

	Suppose that ``g`` is a differentiable function on ``\left[a,b\right]`` that satisfies ``g\left(a\right)=A`` and ``g\left(b\right)=B``. Also suppose that ``f`` is continuous on the range of ``g``. Then

	```math
	\int_a^b f^\prime\left(g\left(x\right)\right)g^\prime\left(x\right)\,\mathrm{d}\kern-0.5pt x=\int_A^B f^\prime\left(u\right)\,\mathrm{d}\kern-0.5pt u\,.
	```

!!! proof

	Let ``F`` be an antiderivative of ``f``, ``F^\prime\left(u\right)=f\left(u\right)``. Then

	```math
	\frac{\mathrm{d}\kern-0.5pt \hphantom{x}}{\mathrm{d}\kern-0.5pt x}F\left(g\left(x\right)\right)=F^\prime\left(g\left(x\right)\right)g^\prime\left(x\right)=f\left(g\left(x\right)\right)g^\prime\left(x\right)\,.
	```

	Thus,

	```math
	\begin{aligned}
	\int_a^bf\left(g\left(x\right)\right)g^\prime\left(x\right)\,\mathrm{d}\kern-0.5pt x&=\left.F\left(g\left(x\right)\right)\right|_a^b=F\left(g\left(b\right)\right)-F\left(g\left(a\right)\right)\\
	&=F\left(B\right)-F\left(A\right)=\left.F\left(u\right)\right|_A^B=\int_A^B f^\prime\left(u\right)\,\mathrm{d}\kern-0.5pt u\,.
	\end{aligned}
	```

!!! example

	Evaluate the integral ``\displaystyle I=\int_0^8\frac{\cos\sqrt{x+1}}{\sqrt{x+1}}\,\mathrm{d}\kern-0.5pt x``.

	Let ``u=\sqrt{x+1}``. Then ``\mathrm{d}\kern-0.5pt u=\frac{1}{2\sqrt{x+1}}\,\mathrm{d}\kern-0.5pt x``. If ``x=0``, then ``u=1``; if ``x=8``, then ``u=3``. Thus,

	```math
	I=2\int_1^3\cos u\,\mathrm{d}\kern-0.5pt u=\left.2\sin u\right|_1^3=2\sin 3-2\sin 1\,.
	```

The method of substitution is often useful for evaluating trigonometric integrals. We begin by listing the integrals of the four trigonometric functions whose integrals we have not yet seen. They arise often in applications and should be memorized.

```math
\begin{aligned}
\int \tan x\,\mathrm{d}\kern-0.5pt x&=\ln\left|\sec x\right|+C\\
\int \cot x\,\mathrm{d}\kern-0.5pt x&=\ln\left|\sin x\right|+C
\end{aligned}
```

All of these can, of course, be checked by differentiating the right-hand sides. 

### Integration by Parts

### Integrals of Rational Functions

### Inverse Substitutions

## Improper Integrals

## Areas of Plane Regions

## Arc Length and Surface Area

