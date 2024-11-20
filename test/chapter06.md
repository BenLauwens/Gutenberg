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

Subdividing a subinterval into two smaller subintervals reduces the error in the approximation by reducing that part of the area under the curve that is not contained in the rectangles. It is reasonable, therefore, to calculate the area of ``R`` by finding the limit of ``S_n`` as ``n`` with the restriction that
the largest of the subinterval widths ``\Delta x_i`` must approach zero:

```math
\textrm{Area of }R=\lim_{\begin{aligned}n&\to\infty\\\max &\Delta x_i\to 0\end{aligned}}S_n\,.
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

Note that if ``f`` is continuous on ``\left[a,b\right]``, then ``m_i`` and ``M_i`` are, in fact, the minimum and maximum values of ``f`` over ``\left[x_{i-1},x_i\right]``by the Extreme-Value Theorem, that is, ``m_i=f\left(l_i\right)`` and ``M_i=\left(u_i\right)``, where ``f\left(l_i\right)\le f\left(x\right)\le f\left(u_i\right)`` for ``x\in \left[x_{i-1},x_i\right]``.

If ``P`` is any partition of ``\left[a,b\right]`` and we create a new partition ``P^\star`` by adding new subdivision points to those of ``P``, thus subdividing the subintervals of ``P`` into smaller ones, then we call ``P^\star`` a *refinement* of ``P``.

!!! theorem

	If ``P^\star`` is a refinement of ``P``, then ``L\left(f,P^\star\right)\ge L\left(f,P\right)`` and ``U\left(f,P^\star\right)\le U\left(f,P\right)``.

!!! proof

	If ``S`` and ``T`` are sets of real numbers, and ``S\subset T``, then any lower bound (or upper bound) of ``T`` is also a lower bound (or upper bound) of ``S``. Hence, the greatest lower bound of ``S`` is at least as large as that of ``T``; and the least upper bound of ``S`` is no greater than that of ``T``.

	Let ``P`` be a given partition of ``\left[a,b\right]`` and form a new partition ``P^\prime`` by adding one subdivision point to those of ``P``, say, the point ``k`` dividing the ``i``th subinterval ``\left[x_{i-1},x_i\right]`` of ``P`` into two subintervals ``\left[x_{i-1},k\right]``and ``\left[x_{i-1},k\right]``. 
	Let ``m_i``, ``m_i^\prime`` and ``m_i^{\prime\prime}`` be the greatest lower bounds of the sets of values of ``f\left(x\right)``  on the intervals ``\left[x_{i-1},x_i\right]``, ``\left[x_{i-1},k\right]``and ``\left[x_{i-1},k\right]``, respectively. Then ``m_i\le m_i^\prime`` and ``m_i\le m_i^{\prime\prime}``. 
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

It can be shown that the *Darboux integral* is equivalent to the better known *Riemann integral*

```math
\int_a^b f\left(x\right)\,\mathrm{d}\kern-0.5pt x=\lim_{\begin{aligned}n&\to\infty\\\max &\Delta x_i\to 0\end{aligned}}\sum_{i=1}^n f\left(x^\prime_i\right)\Delta x_i\,,
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

	Conversely, if ``I_\star= I^\star`` and ``\varepsilon &gt;0`` are given, we can find a partition ``P^\prime`` such that ``L\left(f,P^\prime\right)&gt;I_\star\frac{\varepsilon}{2}``, and another partition ``P^{\prime\prime}`` such that ``U\left(f,P^{\prime\prime}\right)&lt;I^\star+\frac{\varepsilon}{2}``. If ``P`` is a common refinement of ``P^\prime`` and ``P^{\prime\prime}``, then by the first theorem of this section we have that

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

	From the lemma, it follows that at least one of the two subintervals ``\left[a_0,\frac{a_0+b_0}{2}\right]`` and ``\left[\frac{a_0+b_0}{2},b_0\right]`` has the property that for every ``\delta&gt;0`` there exist ``x,y`` in the interval such that ``\left|x-y\right|&lt;\delta`` but ``\left|f\left(x\right)-f\left(y\right)\right|\ge\varepsilon``. Otherwise our assumption would be contradicted.

	Choose a subinterval having this property and call it ``I_1=\left[a_1,b_1\right]``. 
	
	Continuing in this ways, we obtain a sequence of closed intervals satisfying the hypotheses of the Nested Intervals Theorem and having the property that for every ``\delta&gt;0`` there exist ``x,y`` in the interval such that ``\left|x-y\right|&lt;\delta`` but ``\left|f\left(x\right)-f\left(y\right)\right|\ge\varepsilon``.

	By the Nested Intervals Theorem, there exists ``c=\sup\left\{a_n\right\}=\inf\left\{b_n\right\}``.

	Since ``f`` is continuous at ``x_0``, corresponding to the ``\varepsilon`` above, there exists ``\delta_1&gt;0`` such that ``\left|x-x_0\right|&lt\delta_1`` implies ``\left|f\left(x\right)-f\left(x_0\right)\right|&lt;\frac{\varepsilon}{2}``. Similarly, there exists ``\delta_2&gt;0`` such that ``\left|y-x_0\right|&lt\delta_1`` implies ``\left|f\left(y\right)-f\left(x_0\right)\right|&lt;\frac{\varepsilon}{2}``. Let ``\delta_0=\min\left\{\delta_1, \delta_2\right\}``.

	The Capture Theorem states that the interval ``\left]x_0-\frac{\delta_0}{2},x_0+\frac{\delta_0}{2}\right[`` contains ``I_N`` for some ``N\in\mathbb N``.

	Since the length of the interval ``\left]x_0-\frac{\delta_0}{2},x_0+\frac{\delta_0}{2}\right[`` is ``\delta_0``,  we have ``\left|x-y\right|&lt;\delta_0`` for every ``x,y\in\left]x_0-\frac{\delta_0}{2},x_0+\frac{\delta_0}{2}\right[``. By our choice of the ``I_n``, there exists ``x,y\in I_N`` with ``\left|x-y\right|&lt;\delta_0`` but ``\left|f\left(x\right)-f\left(y\right)\right|\ge\varepsilon``.

	Since ``\left|x-x_0\right|&lt\delta_0`` and ``\left|y-x_0\right|&lt\delta_0`` for every ``x,y\in\left]x_0-\frac{\delta_0}{2},x_0+\frac{\delta_0}{2}\right[``, it follows that

	```math
	\begin{aligned}
	\left|f\left(x\right)-f\left(y\right)\right|&=\left|f\left(x\right)-f\left(x_0\right)+f\left(x_0\right)-f\left(y\right)\right|\\
	&\le\left|f\left(x\right)-f\left(x_0\right)\right|+\left|f\left(x_0\right)-f\left(y\right)\right|\\
	&&lt;\frac{\varepsilon}{2}+\frac{\varepsilon}{2}=\varepsilon\,.
	\end{aligned}

	This is impossible. Therefore, ``f`` is uniformly continuous on ``\left[a,b\right]``.
	```

We are now in a position to prove that a continuous function is integrable.

!!! theorem

	If ``f`` is continuous on ``\left[a,b\right]``, then ``f`` is integrable on ``\left[a,b\right]``.

!!! proof

	First note that, since ``f`` is continuous on ``\left[a,b\right]``, it is bounded on ``\left[a,b\right]``.

	Let ``\varepsilon&gt;0``. Since ``f`` is continuous, it is uniformly continuous on ``\left[a,b\right]``, so corresponding to ``\frac{\varepsilon}{b-a}&gt;0`` there exists ``\delta&gt; 0`` such that for all ``x, y\in\left[a,b\right]``, ``\left|x-y\right|&lt;\delta`` implies ``\left|f\left(x\right)-f\left(y\right)\right|&lt;\frac{\varepsilon}{b-a}``.

	Choose a partition ``P=\left\{x_0,x_1,x_2,\dots,x_n\right\}`` for which each subinterval ``\left[x_{i-1},x_i\right]`` has length ``\Delta x_i&lt;\delta``.

	By the Extreme-Value Theorem, the least upper bound, ``M_i``, and the greatest lower bound ``m_i`` of the set of values of ``f\left(x\right)`` on ``\left[x_{i-1},x_i\right]`` satisfy ``M_i-m_i&lt;\frac{\varepsilon}{b-a}``.

	Accordingly,

	```math
	U\left(f,P\right)-L\left(f,P\right)&lt;\frac{\varepsilon}{b-a}\sum_{i=1}^{n\left(P\right)}\Delta x_i=\frac{\varepsilon}{b-a}\left(b-a\right)=\varepsilon\,.
	```

	Thus, ``f`` is integrable on ``\left[a,b\right]``.

## Properties of the Definite Integral

## The Fundamental Theorem of Calculus

## Methods of Integrations

### The Method of Substitution

### Integration by Parts

### Integrals of Rational Functions

### Inverse Substitutions

## Improper Integrals

## Areas of Plane Regions

## Arc Length and Surface Area

