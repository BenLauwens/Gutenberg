{data-type = chapter, class = page.reset}
# Smooth Manifolds

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

## Topological Spaces

!!! definition

    A *topological space* is a pair ``\left(M, 𝒯_M\right)`` consisting of a set ``M`` and a family ``𝒯_M`` of subsets of ``M`` such that:

    1. the empty set ``\emptyset`` and ``M`` itself belong to ``𝒯_M``;
    2. the union of any numbers of elements of ``𝒯_M`` is again an element of ``𝒯_M``;
    3. the intersection of any finite number of elements of ``𝒯_M`` is again an element of ``𝒯_M``.

    The family ``𝒯_M`` is said to form a *topology* on ``M`` and its elements are called the *open sets* of ``M``.

Let ``\alpha`` range over a set of indices ``A``, and denote a general element of ``𝒯_M`` by ``U_a``; if ``N`` is a subset of ``M``, the family

```math
𝒯_N=\left\lbrace U_\alpha\cap N\mid\alpha\in A\right\rbrace
```

is a topology on ``N``, called the *induced topology* on ``N``.

A *neighbourhood* of a point (element) ``p`` of ``M`` is a set ``B_p`` containing an open set to which the point ``p`` belongs.

A topological space ``\left(M, 𝒯_M\right)`` is *connected* if it is not possible to write ``M = U\cup V`` with ``U, V \in 𝒯_M`` and ``U\cap V = \emptyset``.

A topological space is *separated* (or Hausdorff) if it is connected and any two distinct points have disjoint neighbourhoods.

A family ``\left\lbrace U_\alpha\mid\alpha\in A\right\rbrace`` of (open) sets of ``M`` forms a (open) covering of ``M`` if

```math
\bigcup_{\alpha\in A} U_\alpha=M
```

A topological space ``M`` is *compact* if it is separated and any open covering of ``M`` contains a finite covering of ``M``.

## Maps

!!! definition

    Given two sets ``U`` and ``V``, a *map*:

    ```math
    \Phi:U\to V
    ```

    associates to each point ``p\in U`` a unique point ``q\in V``:

    ```math
    p\mapsto q=\Phi\left(p\right)\,.
    ```

    the set ``\Phi\left(U\right)=\left\lbrace\Phi\left(U\right): p\in U\right\rbrace`` is the *image* in ``V`` of ``U``.

If for every ``q\in\Phi\left(U\right)`` there is only one point ``p\in U`` such that ``\Phi\left(p\right) = q``, the map ``\Phi`` is said to be *injective*.

If ``\Phi\left(U\right)=V``, the map is said to be *surjective*.

If it is both surjective and injective, then the map is said to be *bijective*.

!!! definition

    If we are given a map ``\Phi:U\to V`` and a map ``\Psi:V\to W``, then the map:

    ```math
    \Psi\circ\Phi:U\to W
    ```

    defined by applying ``\Phi`` and then ``\Psi`` is called the *composition* of ``\Phi`` with ``\Psi``.

If ``\Phi:U\to V`` is injective, then we can define a map ``\Phi^{-1}:V\to U`` which satisfies:

```math
\Phi\circ\Phi^{-1}=I_{\Phi\left(U\right)}\quad\textrm{and}\quad\Phi^{-1}\circ\Phi=I_U
```

where ``I_U`` denotes the identity on ``U``.

!!! definition

    Suppose now that ``\left(M, 𝒯_M\right)`` and ``\left(N, 𝒯_N\right)`` are topological spaces. A map ``\Phi:M\to N`` is said to be *continuous* at a point ``p\in M`` if ``\Phi^{-1}\left(B\right)`` is a neighbourhood of ``p`` for every neighbourhood ``B`` of ``\Phi\left(p\right)\in N``.

A map ``\Phi`` is called *continuous* in ``M`` if it is continuous at every point ``p\in M``: this happens precisely when ``\Phi^{-1}\left(B\right)`` is open for every open ``B\in N``.

If ``\Phi:M\to N`` is bijective, and if ``\Phi`` and ``\Phi^{-1}`` are continuous, then ``\Phi`` is called a *homeomorphism* and ``M`` and ``N`` are called *homeomorphic*.

More generally, if ``\Phi`` is injective and ``\Phi`` and ``\Phi^{-1}`` are continuous with respect to the induced topology on ``\Phi\left(M\right)``, then ``\Phi`` is called a *homeomorphism into* ``N``.

If we are given more than two maps, the composition of maps satisfies the associative property:

```math
\Phi\circ\left(\Psi\circ\Theta\right)=\left(\Phi\circ\Psi\right)\circ\Theta\,.
```

## Charts

!!! definition

    Given a topological space ``\left(M, 𝒯_M\right)`` we define a *chart* of ``M`` to be a pair ``\left(U_\alpha,\phi_\alpha\right)``, with ``U_\alpha`` an element of ``𝒯_M`` and ``\phi_\alpha`` a homeomorphism of ``U_\alpha`` into an open set of ``ℝ^n``, the space of the ``n``-tuples of real numbers ``\left(x^i\right)_{i=1,2,\dots,n}``. The numbers ``x^1, x^2, \dots x^n`` constituting the image of a point ``p\in U_\alpha`` under the map ``\phi_\alpha`` are called the *local coordinates* of ``p``. A family of charts ``𝒜 = \left\lbrace\left(U_\alpha,\phi_\alpha\right)\mid \alpha\in A\right\rbrace`` on ``M`` is said to form an *atlas* on ``M`` if

    ```math
    \bigcup_{\alpha\in A}U_\alpha=M\,.
    ```

Let ``\left(U_\alpha,\phi_\alpha\right)`` and ``\left(U_\beta,\phi_\beta\right)`` be two charts on ``M`` with ``U_\alpha\cap U_\beta\ne\emptyset``. A point ``p\in U_\alpha\cap U_\beta`` can be expressed in terms of its two images in ``ℝ^n`` as:

```math
p=\phi_\alpha^{-1}\left(x\right)=\phi_\beta^{-1}\left(y\right)
```

where we put ``x = \left(x^i\right)_{i=1,2,\dots,n}`` and ``y = \left(y^i\right)_{i=1,2,\dots,n}``. It is easy to show that the composite map:

```math
\phi_\beta\circ\phi_\alpha^{-1}:\phi_\alpha\left(U_\alpha\cap U_\beta\right)\to\phi_\beta\left(U_\alpha\cap U_\beta\right)
```

is a homeomorphism between open sets of ``ℝ^n``. The inverse map is given by

```math
\left(\phi_\beta\circ\phi_\alpha^{-1}\right)^{-1}=\phi_\alpha\circ\phi_\beta^{-1}\,.
```

An atlas on ``M`` is a ``C^r``-atlas if ``\phi_\beta\circ\phi_\alpha^{-1}`` (and its inverse) for any pair ``\left(\alpha,\beta\right)`` is an ``ℝ^n``-valued ``C^r``-function of ``n`` variables (i.e. has a continuous ``r``-th derivative). The composite maps are called coordinate transformations in ``M`` and can be written as

```math
y = \phi_\beta\circ\phi_\alpha^{-1}\left(x\right)
```

and its inverse

```math
x = \phi_\alpha\circ\phi_\beta^{-1}\left(y\right)\,.
```

## Differentiable Manifolds

!!! definition

    A *differentiable manifold* of class ``C^r`` and dimension ``n`` is a Hausdorff topological space with a ``C^r``-atlas. Any point in a ``C^r``-differentiable manifold has a neighbourhood which is also a coordinate neighbourhood of ``M``. Hereafter, a ``C^r``-differentiable manifold will be simply referred to as a (smooth) manifold unless stated otherwise.

A map ``\mathsf f:M\to ℝ`` is said to be a ``C^k``-function at ``p\in M``, if for any chart ``\left(U_\alpha,\phi_\alpha\right)``, there exists a neighbourhood ``B`` of ``p`` such that the composite map

```math
f_\alpha:\phi_\alpha\left(B\right)\subset ℝ^n\to ℝ:f_\alpha\left(x^1,x^2,\dots,x^n\right)=\mathsf f\circ\phi_\alpha^{-1}\left(x\right)
```

is a ``C^k``-differentiable function in ``\phi_\alpha\left(B\right)``.