{data-type="chapter"}
# Limits and Continuity

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

Calculus was created to describe how quantities change:

- *differentiation*, for finding the rate of change of a given function, and
- *integration*, for finding a function having a given rate of change.

Both of these procedure are based on the fundamental concept of *limit* of a function.

In this chapter we will introduce the limit concept and develop some of its properties, including the nice behaviour of some functions that is called *continuity*.

## Average and Instantaneous Velocity

The position of a moving object is a function of time. The average velocity of the object over a time interval is found by dividing the change in the object's position by the length of the time interval.

!!! example
    The average velocity of a falling rock.

    Physical experiments show that if a rock is dropped from rest near the surface of the earth, in the first ``t\,\left[\mathrm{s}\right]`` if will fall a distance

    ```math
    y = \frac{gt^2}{2}\,\left[\mathrm{s}\right]\,,
    ```

    with ``g\approx 9.8`` a constant representing the combined action of the gravition (from mass distribution within earth) and centrifugal forces (from the earth's rotation).

    1. What is the average velocity of the falling rock during the first ``2\,\left[\mathrm{s}\right]`` (time interval ``\left[0,2\right]``)?
    
       ```math
       \frac{\Delta y}{\Delta t}=\frac{g}{2}\frac{t_2^2-t_1^2}{t_2-t_1}=\frac{g}{2}\frac{2^2-0^2}{2-0}=9.8\,\left[\frac{\mathrm{m}}{\mathrm{s}}\right]\,.
       ```

    2. What is the average velocity of the falling rock in the time interval ``\left[1,2\right]``?
    
       ```math
       \frac{\Delta y}{\Delta t}=\frac{g}{2}\frac{t_2^2-t_1^2}{t_2-t_1}=\frac{g}{2}\frac{2^2-1^2}{2-1}=14.7\,\left[\frac{\mathrm{m}}{\mathrm{s}}\right]\,.
       ```

The instantaneous velocity of the object at the instant ``t`` can be estimated by evaluating the average velocity in a small time interval containing ``t``.

!!! example
    How fast is the rock of the previous example falling 
    1. at time ``t=1\,\left[\mathrm{s}\right]``?

       {cell=chap display=false output=false}
       ```julia
        table() do io
            f = (x1, x2)->4.9(x2+x1)
            thead(io, ("Time Interval", "Average Velocity"), align=:center)
            for (x1, x2) in ((1, 1.1), (1, 1.01), (1, 1.001), (1, 1.0001))
                fx = f(x1, x2)
                trow(io, ("\\left[" * string(x1) * "," * string(x2) * "\\right]", string(round(fx, digits=4))), latex=true, align=:center)
            end
        end
       ```

    2. at time ``t=2\,\left[\mathrm{s}\right]``?

       {cell=chap display=false output=false}
       ```julia
        table() do io
            f = (x1, x2)->4.9(x2+x1)
            thead(io, ("Time Interval", "Average Velocity"), align=:center)
            for (x1, x2) in ((2, 2.1), (2, 2.01), (2, 2.001), (2, 2.0001))
                fx = f(x1, x2)
                trow(io, ("\\left[" * string(x1) * "," * string(x2) * "\\right]", string(round(fx, digits=4))), latex=true, align=:center)
            end
        end
       ```

In the second example the average velocity of the falling rock over the time interval ``\left[t,t+h\right]`` is

```math
\frac{\Delta y}{\Delta t}=\frac{g}{2}\frac{\left(t+h\right)^2-t^2}{\left(t+h\right)-t}=\frac{g}{2}\frac{2th+h^2}{h}
```

We examined the values of this average velocity for time intervals whose lengths ``h`` became smaller and smaller. We were finding the *limit of the average velocity as ``h`` tends to zero*. This is expressed symbolically in the form

```math
\lim_{h\to0}\frac{\Delta y}{\Delta t}=\frac{g}{2}\frac{2th+h^2}{h}\,.
```

We can't find the limit of the fraction by just substituting ``h=0`` because that would involve dividing by zero. However, we can calculate the limit by first performing som algebraic simplifications on the expression:

```math
\lim_{h\to0}\frac{\Delta y}{\Delta t}=\frac{g}{2}\left(2t+h\right)\,.
```

The final form no longer involves division by ``h``. It approaches ``gt + \frac{g}{2}0=gt``. In particular, at ``t=1\,\left[\mathrm{s}\right]`` and ``t=2\,\left[\mathrm{s}\right]``, the instantaneous velocities are ``v_1=9.8\,\left[\frac{\mathrm{m}}{\mathrm{s}}\right]`` and ``v_2=19.6\,\left[\frac{\mathrm{m}}{\mathrm{s}}\right]``, respectively.

## The Area of a Circle

All circles are similar geometric figures; they all have the same shape and differ only in size. The ratio of the circumference ``C`` to the diameter ``2r`` has the same value for all circles. The number ``\uppi `` is defined to be this common ratio:

```math
\frac{C}{2r}=\uppi \quad\textrm{or}\quad C=2\uppi r\,.
```

We were taught that the area ``A`` of a circle is this same number ``\uppi `` times the square of the radius:

```math
A=\uppi r^2\,.
```

Can we deduce this area formula from the formula for the circumference?

The answer to this question lies in regarding the circle as a "limit" of regular polygons, which are in turn made up of triangles.

Suppose a regular polygon having ``n`` sides is inscribed in a circle of radius ``r``.

{cell=chap display=false output=false}
```julia
Figure("", """A regular polygon (green) of <span class="math-tex" data-type="tex">\\(n\\)</span> sides inscribed in a red circle. Here <span class="math-tex" data-type="tex">\\(n=9\\)</span>.""") do
	Drawing(width=320, height=302) do
        defs() do
            marker(id="arrow", markerWidth="6", markerHeight="6", refX="3", refY="3", orient="auto") do
                path(d="M 0 0 L 6 3 L 0 6 z", fill="black" )
            end
        end
		r = 150
        xmid = 151
		ymid = 151
		circle(cx=xmid, cy=ymid, r=r, fill="none", stroke="red", stroke_width=1)
        p = [(xmid+r*cos(t), ymid+r*sin(t)) for t in 0:2π/9:2π]
        for n = 1:9
            line(x1=p[n][1], y1=p[n][2], x2=p[n+1][1], y2=p[n+1][2], stroke="green", stroke_width=1)
        end
        line(x1=xmid, y1=xmid, x2=p[1][1], y2=p[1][2], stroke="black", stroke_width=1)
        line(x1=xmid, y1=xmid, x2=p[9][1], y2=p[9][2], stroke="black", stroke_width=1)
        line(x1=xmid, y1=xmid, x2=0.5(p[1][1]+p[9][1]), y2=0.5(p[1][2]+p[9][2]), stroke="black", stroke_width=1, stroke_dasharray="3")
        latex("O", x=xmid-font_x, y=ymid-0.5font_y, width=font_x, height=font_y)
        latex("r", x=xmid+0.5r-0.5font_x, y=ymid, width=font_x, height=font_y)
        latex("A", x=305, y=ymid-0.5font_y, width=font_x, height=font_y)
        latex("B", x=p[9][1]+0.25font_x, y=p[9][2]-0.75font_y, width=font_x, height=font_y)
        latex("M", x=0.5(p[1][1]+p[9][1])-1.5font_x, y=0.5(p[1][2]+p[9][2])-0.75font_y, width=font_x, height=font_y)
        path(d="M 226 151 A 75 75 0 0 0 $(75cos(-π/9)+xmid+1.5), $(75sin(-π/9)+ymid+1.75)", stroke="black", fill="none", marker_end="url(#arrow)")
        latex("\\frac{\\uppi }{n}", x=xmid+80cos(-π/18), y=ymid+80sin(-π/9), width=font_x, height=2*font_y)
    end
end
```

The perimeter ``P_n`` and the area ``A_n`` of the polygon are, respectively, less than the circumference ``C`` and the area ``A`` of the circle, but if ``n`` is large ``P_n`` is close to ``C`` and ``A_n`` is close to ``A``. We could expect ``P_n`` to approach the limit ``C`` and ``A_n`` to approach the limit ``A`` as ``n`` tends to infinity.

Since the total angle around the point ``O`` is ``2\uppi `` radians, ``\angle AOB`` is ``\frac{2\uppi }{n}`` radians. If ``M`` is the midpoint of ``AB``, then ``O`` bisects ``\angle AOB``. We can write the length of ``AB`` and the area of ``\triangle OAB`` in terms of the radius:

```math
\begin{aligned}
\left|AB\right|=&2\left|AM\right|=2r\sin\frac{\uppi}{n}\\
\triangle OAB=&\frac{1}{2}\left|AB\right|\left|OM\right|=r^2\sin\frac{\uppi}{n}\cos\frac{\uppi}{n}
\end{aligned}
```

The perimeter ``P_n`` and area ``A_n`` of the polygon are ``n`` times these expressions:

```math
\begin{aligned}
P_n=&2rn\sin\frac{\uppi}{n}\\
A_n=&r^2n\sin\frac{\uppi}{n}\cos\frac{\uppi}{n}
\end{aligned}
```

Solving the first equation for ``rn\sin\frac{\uppi}{n}=\frac{P_n}{2}`` and substituting into the second equation, we get

```math
A_n = \frac{1}{2}P_nr\cos\frac{\uppi}{n}
```

Now ``\angle AOM=\frac{\uppi}{n}`` approaches ``0`` as ``n`` tends to infinity, so its cosine, ``\cos\frac{\uppi}{n}=\frac{\left|OM\right|}{\left|OA\right|}``, approaches ``1``. Since ``P_n`` approaches ``C=2\uppi r`` as ``n`` tends to infinity, the expression for ``A_n`` approaches ``\frac{1}{2}\left(2\uppi r\right)r\left(1\right)=\uppi r^2``, which must therefore be the area of the circle.

## Limits Defined

In order to speak meaningfully about rate of change, tangent lines, and areas bounded by curves, we have to investigate the process of finding limits. Let us look at some examples.

!!! example
    Describe the behaviour of the function ``f\left(x\right)=\frac{x^2-1}{x-1}`` near ``x=1``.

    Note that ``f(x)`` is defined for all real numbers ``x`` except ``x=1``. (We can't divide by zero.) For any ``x\ne1`` we can simplify the expression for ``f\left(x\right)`` by factoring the numerator and cancelling common factors:

    ```math
    f\left(x\right)=\frac{\left(x-1\right)\left(x+1\right)}{x-1}=x+1\quad\textrm{for }x\ne1\,.
    ```

    The graph of ``f`` is the line ``y=x+1`` with one point removed, namely, the point ``\left(1,2\right)``.

    {cell=chap display=false output=false}
    ```julia
    Figure("", """The graph of """ * tex("""f\\left(x\\right)=\\frac{x^2-1}{x-1}""") * ".") do
        scale = 40
        Drawing(width=7scale, height=6scale) do
            xmid = 2scale
            ymid = 5scale
            axis_xy(7scale,6scale,xmid,ymid,scale,(1,),(2,))
            plot_xy(x->(x^2-1)/(x-1), -2+eps():0.01:5.0-eps(), tuple(), xmid, ymid, scale, width=1)
            circle(cx=3scale, cy=3scale, r=3, fill="hsl(39, 100%, 90%)", stroke="red")
        end
    end
    ```

    This removed point is shown as a *hole* in the graph. Even though ``\left(1\right)`` is not defined, it is clear that we can make the value of ``f\left(x\right)`` *as close as we want* to ``2`` by choosing ``x`` *close enough* to ``1``. Therefore, we say ``f`` approaches the limit ``2`` as ``x`` tends to ``1``. We write this as

    ```math
    \lim_{x\to1}f\left(x\right)=\lim_{x\to1}\frac{x^2-1}{x-1}=2\,.
    ```

!!! example
    What happens to the function ``g\left(x\right)=\left(1+x^2\right)^\frac{1}{x^2}`` as ``x`` approaches zero?

    Note that ``g`` is not defined at ``x=0``. In fact, for the moment it does not appear to be defined for any ``x`` whose square ``x^2`` is not a rational number. Let us ignore for now the problem of deciding what ``g\left(x\right)`` means if ``x^2`` is irrational and consider only rational values of ``x``. There is no obvious way to simplify the expression for ``g\left(x\right)`` as we did in previous example. However, we can use a scientific calculator to obtain approximate values of ``g\left(x\right)`` for some rational values of ``x`` approaching ``0``.

    {cell=chap display=false output=false}
    ```julia
    table() do io
        g = x->(1+x^2)^(1/x^2)
        thead(io, ("x", "g\\left(x\\right)"), latex=true, align=:center)
        for x in (0.1, 0.01, 0.001, 0.0001)
            gx = g(x)
            trow(io, ("\\pm " * string(x), string(round(gx, digits=9))), latex=true)
        end
    end
    ```

    Except the last value in the table, the values of ``g\left(x\right)`` seem to be approaching a certain number, ``2.71828\dots``, as ``x`` tends to ``0``. We will see in Chapter 5 that

    ```math
    \lim_{x\to 0}g\left(x\right)=\lim_{x\to 0}\left(1+x^2\right)^\frac{1}{x^2}=ℯ=2.718281828459045\dots\,.
    ```

The examples and the previous sections suggest the following informal definition of limit.

!!! definition "informal"
    If ``f`` is defined for all ``x`` near ``a``, except possibly at ``a`` itself, and if we can ensure that ``f\left(x\right)`` is as close as we want to ``L`` by taking ``x`` close enough to ``a``, but not equal to ``a``, we say that the function ``f`` approaches the *limit* ``L`` as ``x`` tends to ``a``, and we write
    
    ```math
    \lim_{x\to a}f\left(x\right)=L
    ```

This definition is informal because phrases such as *close as we want* and *close enough* are imprecise; their meaning depends on the context. If we want to prove results about limits a more precise definition is needed. This precise definition is based on the idea of controlling the input ``x`` of a function ``f`` so that the output ``f\left(x\right)`` will lie in a specific interval.

!!! example
    The area of a circular disk of radius ``r\,\left[\mathrm{cm}\right]`` is ``A=\uppi r^2\,\left[\mathrm{cm}^2\right]``. A machinist is required to manufacture a circular metal disk having area ``400\uppi\,\left[\mathrm{cm}^2\right]`` within an error tolerance of ``\pm 5\,\left[\mathrm{cm}^2\right]``. How close to ``20\,\left[\mathrm{cm}\right]`` must the machinist control the radius of the disk to achieve this?

    The machinist wants ``\left|\uppi r^2-400\uppi\right|<5``, that is,

    ```math
    400\uppi-5<\uppi r^2<400\uppi+5
    ```

    or, equivalently,

    ```math
    \begin{aligned}
        \sqrt{400-\frac{5}{\uppi}}<&r<\sqrt{400+\frac{5}{\uppi}}\\
        19.96017<&r<20.03975\,.
    \end{aligned}
    ```

    Thus, the machinist needs ``\left|r-20\right|<0.03975``.

When we say that ``f`` has limit ``L`` as ``x`` tends to ``a``, we are really saying that we can ensure that the error ``\left|f\left(x\right)-L\right|`` will be less than *any* allowed tolerance, no matter how small, by taking ``x`` *close enough* to ``a`` (but not equal to ``a``). It is traditional to use ``\varepsilon``, the Greek letter "epsilon", for the size of the allowable *error* and ``\delta``, the Greek letter "delta" for the difference ``\left|x-a\right|`` that measures how close ``x`` must be to ``a`` to ensure that the error is within that tolerance.

{cell=chap display=false output=false}
```julia
Figure("", "If " * tex("x\\ne a") * " and " * tex("\\left|x-a\\right|&lt;\\delta") * ", then " * tex("\\left|f\\left(x\\right)-L\\right|&lt;\\varepsilon" * ".")) do
    scale = 40
    Drawing(width=6scale, height=4.5scale) do
        xmid = 1scale
        ymid = 4scale
        axis_xy(6scale,4.5scale,xmid,ymid,scale,(2.4,3,3.6),(3,2,1),xs=("a-\\delta","a","a+\\delta"),xl=(3,1,3),ys=("L-\\varepsilon","L","L+\\varepsilon"),yl=(3,1,3))
        line(x1=4scale,y1=4scale,x2=4scale,y2=2scale,stroke_dasharray = "3",stroke="black")
        line(x1=1scale,y1=2scale,x2=4scale,y2=2scale,stroke_dasharray = "3",stroke="black")
        plot_xy(x->0.25(x-3+sqrt(7))^2+0.25, -1:0.01:5, tuple(), xmid, ymid, scale, width=1)
        circle(cx=4scale, cy=2scale, r=3, fill="white", stroke="red")
        rect(x=3.4scale,y=0,width=1.2scale,height=4scale, fill="hsla(189, 100%, 50%, 10%)")
        rect(x=1scale,y=scale,width=4scale,height=2scale, fill="hsla(180, 100%, 25%, 10%)")
        latex("y=f\\left(x\\right)", x=0.8scale, y=3.1scale, width=5font_x, height=font_y,color="red")
    end
end
```

If ``\varepsilon`` is any strict positive number, *no matter how small*, we must be able to ensure that ``\left|f\left(x\right)-L\right|<\varepsilon`` by restricting ``x`` to be *close enough* to (but not equal to) ``a``. How close is close enough? It is sufficient that the distance ``\left|x-a\right|`` from ``x`` to ``a`` be less than a positive number ``\delta`` that depends on ``\varepsilon``.

!!! definition "formal"
    We say that ``f:X\mapsto Y`` approaches the limit ``L`` as ``x`` tends to ``a``, and we write
    
    ```math
    \lim_{x\to a}f\left(x\right)=L
    ````

    if the following condition is satisfied:
    
    ```math
    \forall\varepsilon>0,\exists\delta\left(\varepsilon\right)>0:0<\left|x-a\right|<\delta\implies x\in X \wedge \left|f\left(x\right)-L\right|<\varepsilon\,.
    ```

Note the possible dependency of ``\delta`` on ``\varepsilon`` and the fact that ``x`` belongs to the domain of ``f``.

The formal definition of limit does not tell you how to find the limit of a function, but it does enable you to verify that a suspected limit is correct.

!!! example
    Verify that:

    1. ``\lim_{x\to a}x=a``.

       Let ``\varepsilon>0`` be given. We must find ``\delta>0`` so that

       ```math
       0<\left|x-a\right|<\delta\implies\left|x-a\right|<\varepsilon\,.
       ```

       Clearly, we can take ``\delta=\varepsilon`` and the implication above will be true. This proves that ``\lim_{x\to a}x=a``

    2. ``\lim_{x\to a}c=c`` (``c`` is a constant).

       Let ``\varepsilon>0`` be given. We must find ``\delta>0`` so that

       ```math
       0<\left|x-a\right|<\delta\implies\left|c-c\right|<\varepsilon\,.
       ```

       Since ``c-c=0``, we can use any positive number for ``\delta`` and the implication above will be true. This proves that ``\lim_{x\to a}c=c``.

    3. ``\lim_{x\to 2}x^2=4``.

       Here ``a=2`` and ``L=4``. Let ``\varepsilon>0`` be given. We must find ``\delta>0`` so that

       ```math
       0<\left|x-2\right|<\delta\implies\left|x^2-4\right|<\varepsilon\,.
       ````

       Now,

       ```math
       \left|x^2-4\right|=\left|\left(x+2\right)\left(x-2\right)\right|=\left|x+2\right|\left|x-2\right|\,.
       ```

       We want the expression above to be less than ``\varepsilon``. We can make the factor ``\left|x-2\right|`` as small as we wish by choosing ``\delta`` properly, but we need to control the factor ``\left|x+2\right|`` so that it does not become too large.

       If we first assume ``\delta\le1`` and require that ``\left|x-2\right|<\delta``, then we have

       ```math
       \left|x-2\right|&lt;1 \implies 1&lt;x&lt;3 \implies 3&lt;x+2&lt;5 \implies \left|x+2\right|&lt;5
       ```

       Hence,

       ```math
       \left|f\left(x\right)-4\right|&lt;5\left|x-2\right|\quad\textrm{if}\quad\left|x-2\right|&lt;\delta\le1\,.
       ```

       But ``5\left|x-2\right|&lt;\varepsilon`` if ``\left|x-2\right|&lt;\frac{\varepsilon}{5}``. Therefore, if we take ``\delta=\min\left\lbrace1,\frac{\varepsilon}{5}\right\rbrace``, the *minimum* of the two numbers ``1`` and ``\frac{\varepsilon}{5}``, then

       ```math
       \left|f\left(x-4\right)\right|&lt;5\left|x-2\right|&lt;5\times\frac{\varepsilon}{5}=\varepsilon\quad\textrm{if}\quad\left|x-2\right|&lt;\delta\,.
       ```

       This proves that ``\lim_{x\to 2}x^2=4``.

We do not usually rely on the formal definition of limit to verify specific limits such as those in the last example. Rather, we appeal to general theorems about limits in particular the theorems of the next section.

If a function has a limit at a point, this limit is *unique*.

!!! theorem
    If ``\lim_{x\to a}f\left(x\right)=L`` and ``\lim_{x\to a}f\left(x\right)=M``, then ``L=M``.

!!! proof "by contradiction"
    Suppose ``L\ne M``.

    Let ``\varepsilon = \frac{\left|L-M\right|}{2}&gt;0``. 
    
    Since ``\lim_{x\to a}f\left(x\right)=L``, there exists ``\delta_1 > 0`` such that

    ```math
    0<\left|x-a\right|<\delta_1\implies\left|f\left(x\right)-L\right|<\varepsilon
    ```

    and since ``\lim_{x\to a}f\left(x\right)=M``, there exists ``\delta_2>0`` such that

    ```math
    0<\left|x-a\right|<\delta_2\implies\left|f\left(x\right)-M\right|<\varepsilon\,.
    ```

    Let ``\delta=\min\left\lbrace\delta_1,\delta_2\right\rbrace``. If ``0&lt;\left|x-a\right|&lt;\delta``, then ``\left|x-a\right|&lt;\delta_1``, so ``\left|f\left(x\right)-L\right|&lt;\varepsilon``, and ``\left|x-a\right|&lt;\delta_2``, so ``\left|f\left(x\right)-M\right|&lt;\varepsilon``. Therefore,

    ```math
    \begin{aligned}
    \left|L-M\right|=&\left|L-f\left(x\right)+f\left(x\right)-M\right|\\\le&\left|L-f\left(x\right)\right|+\left|f\left(x\right)-M\right|\\<&2\varepsilon=2\frac{\left|L-M\right|}{2}=\left|L-M\right|
    \end{aligned}
    ```

    by the triangle inequality.

    This is a contradiction, so ``L=M``.

Although a function ``f`` can only have one limit at any particular point, it is, nevertheless, useful to be able to describe the behaviour of functions that approach different numbers a ``x`` tends to ``a`` from one side or the other.

{cell=chap display=false output=false}
```julia
Figure("", tex("\\newcommand{\\sgn}{\\operatorname{sgn}}\\lim_{x\\to0^-}\\sgn x=-1") * " and " * tex("\\lim_{x\\to0^+}\\sgn x=1") * ".") do
	Drawing(width=255, height=155) do
		xmid = 125
		ymid = 80
		scale = 50
		axis_xy(255,155,xmid,ymid,scale,(-2,-1,1,2),(-1,1))
		plot_xy(x->-1, -3:0, tuple(), xmid, ymid, scale)
		plot_xy(x->1, 0:3, tuple(), xmid, ymid, scale)
		circle(cx=xmid,cy=ymid-scale*(-1),r=3,stroke="red",fill="white")
		circle(cx=xmid,cy=ymid-scale*(1),r=3,stroke="red",fill="white")
	end
end
```

!!! definition
    We say that ``f:X\mapsto Y`` has *right limit* ``L`` at ``a``, and we write

    ```math
    \lim_{x\to a^+}f\left(x\right)=L\,,
    ```

    if the following condition is satisfied:

    ```math
    \forall \varepsilon>0,\exists\delta\left(\varepsilon\right)>0:a&lt;x&lt;a+\delta\implies x\in X \wedge \left|f\left(x\right)-L\right|&lt;\varepsilon\,.
    ```

    Similarly, we say that ``f:X\mapsto Y`` has *left limit* ``L`` at ``a``, and we write

    ```math
    \lim_{x\to a^-}f\left(x\right)=L\,,
    ```

    if the following condition is satisfied:

    ```math
    \forall \varepsilon>0,\exists\delta\left(\varepsilon\right)>0:a-\delta&lt;x&lt;a\implies x\in X \wedge \left|f\left(x\right)-L\right|&lt;\varepsilon\,.
    ```

Note again the dependency of ``\delta`` on ``\varepsilon`` and the fact that ``x`` belongs to the domain of ``f``.

!!! example
    Show that ``\lim_{x\to0^+}\sqrt x=0``.

    Let ``\varepsilon>0`` be given. If ``x>0``, then ``\left|\sqrt x-0\right|=\sqrt x``. We can ensure that ``\sqrt x<\varepsilon`` by requiring ``x<\varepsilon^2``. Thus, we can take ``\delta=\varepsilon^2`` and the condition of the definition will be satisfied:

    ```math
    0&lt;x&lt;\delta=\varepsilon^2\implies\left|\sqrt x-0\right|<\varepsilon\,.
    ```

    Therefore, ``\lim_{x\to0^+}\sqrt x=0``.

The existence of different right and left limits of a function at a point excludes the existence of a limit at that point.

!!! theorem
    A function ``f`` has limit ``L`` at ``x=a`` if and only if it has both left and right limits there and these one-sided limits are both equal to ``L``:

    ```math
    \lim_{x\to a}f\left(x\right)=L\iff\lim_{x\to a^-}f\left(x\right)=\lim_{x\to a^+}f\left(x\right)=L\,.
    ```

!!! example
    What one-sided limits does ``g\left(x\right)=\sqrt{1-x^2}`` have at ``x=-1`` and ``x=1``?

    The domain of ``g`` is ``\left[-1,1\right]``, so ``g`` is defined only to the right of ``x=-1`` and only to the left of ``x=1``.

    {cell=chap display=false output=false}
    ```julia
    Figure("", tex("\\sqrt{1-x^2}") * """ has right limit 0 at -1 and left limit 0 at 1.""") do
        Drawing(width=255, height=150) do
            xmid = 125
            ymid = 130
            scale = 100
            axis_xy(255,150,xmid,ymid,scale,(-1,1),(1,))
            plot_xy(x->sqrt(1-x^2), -1.0:0.01:1.0, (-1, 1), xmid, ymid, scale)
        end
    end
    ```

    As can be seen in the figure,

    ```math
    \lim_{x\to-1^+}g\left(x\right)=0\quad\textrm{and}\quad\lim_{x\to1^-}g\left(x\right)=0
    ```

    ``g`` has no left limit or limit at ``x=-1``, no right limit or limit at ``x=1``.

## Rules and Theorems about Limits

The following rules make it easy to calculate limits and one-sided limits of many kinds of functions when we know some elementary limits.

!!! theorem "Limit Rules"
    If ``\lim_{x\to a}f\left(x\right)=L``, ``\lim_{x\to a}g\left(x\right)=M`` and ``k`` is a constant, then

    1. ``\lim_{x\to a}\left(f\left(x\right)+g\left(x\right)\right)=L+M`` (limit of a sum)
    2. ``\lim_{x\to a}\left(f\left(x\right)-g\left(x\right)\right)=L-M`` (limit of a difference)
    3. ``\lim_{x\to a}f\left(x\right)g\left(x\right)=LM`` (limit of a product)
    4. ``\lim_{x\to a}kf\left(x\right)=kL`` (limit of a multiple)
    5. ``\lim_{x\to a}\frac{f\left(x\right)}{g\left(x\right)}=\frac{L}{M}\textrm{ if }M\ne0`` (limit of quotient)
    6. If ``m\in ℤ`` and ``n\in ℕ_0``, then ``\lim_{x\to a}\left(f\left(x\right)\right)^\frac{m}{n}=L^\frac{m}{n}``, provided ``L>0`` if ``n`` is even and ``L\ne0`` if ``m &lt;0``. (limit of a power)
    7. If ``f\left(x\right)\le g\left(x\right)`` on an interval containing ``a`` in its interior, then ``L\le M``. (order is preserved)

Rules 1—6 are also valid for one-sided limits. So is rule 7, under the assumption that ``f\left(x\right)\le\left(x\right)`` on an open interval extending from ``a`` in the appropriate direction.

!!! proof "limit of a sum"
    Let ``\varepsilon > 0`` be given.

    We want to find a strict positive number ``\delta`` such that

    ```math
    0&lt;\left|x-a\right|&lt;\delta\implies\left|\left(f\left(x\right)+g\left(x\right)\right)-\left(L+M\right)\right|&lt;\varepsilon
    ```

    Observe that

    ```math
    \begin{aligned}
    \left|\left(f\left(x\right)+g\left(x\right)\right)-\left(L+M\right)\right|=&\left|\left(f\left(x\right)-L\right)+\left(g\left(x\right)-M\right)\right|\\
    \le&\left|f\left(x\right)-L\right|+\left|g\left(x\right)-M\right|
    \end{aligned}
    ```

    by the triangle inequality.

    Since ``\lim_{x\to a}f\left(x\right)=L`` and ``\frac{\varepsilon}{2}`` is a strict positive number, there exists a number ``\delta_1`` such that

    ```math
    0&lt;\left|x-a\right|&lt;\delta_1\implies\left|f\left(x\right)-L\right|&lt;\frac{\varepsilon}{2}\,.
    ```

    Similarly, since ``\lim_{x\to a}g\left(x\right)=M`` and ``\frac{\varepsilon}{2}`` is a strict positive number, there exists a number ``\delta_2`` such that

    ```math
    0&lt;\left|x-a\right|&lt;\delta_2\implies\left|g\left(x\right)-M\right|&lt;\frac{\varepsilon}{2}\,.
    ```

    Let ``\delta=\min\left\lbrace\delta_1,\delta_2\right\rbrace``. If ``0&lt;\left|x-a\right|&lt;\delta``, then ``\left|x-a\right|&lt;\delta_1``, so ``\left|f\left(x\right)-L\right|&lt;\frac{\varepsilon}{2}``, and ``\left|x-a\right|&lt;\delta_2``, so ``\left|g\left(x\right)-M\right|&lt;\frac{\varepsilon}{2}``. Therefore,

    ```math
    \left|\left(f\left(x\right)+g\left(x\right)\right)-\left(L+M\right)\right|\le\left|f\left(x\right)-L\right|+\left|g\left(x\right)-M\right|&lt;\frac{\varepsilon}{2}+\frac{\varepsilon}{2}=\varepsilon\,.
    ```

    This shows that ``\lim_{x\to a}\left(f\left(x\right)+g\left(x\right)\right)=L+M``.

!!! example
    Find ``\lim_{x\to a}\frac{x^2+x+4}{x^3-2x^2+7}``.

    The expression ``\frac{x^2+x+4}{x^3-2x^2+7}`` is formed by combining the basic functions ``x`` and ``c`` (constant) using addition, subtraction, multiplication, and division. The previous theorem assures us that the limit of such a combination is the same combination of the limits ``a`` and ``c`` of the basic functions, provided the denominator does not have limit zero. Thus,

    ```math
    \lim_{x\to a}\frac{x^2+x+4}{x^3-2x^2+7}=\frac{a^2+a+4}{a^3-2a^2+7}\quad\textrm{provided }a^3-2a^2+7\ne0
    ```

The result of the example can be generalized as a direct corollary.

!!! corollary
    If ``a\in ℝ`` and

    1. ``P\left(x\right)`` is a polynomial, then

       ```math
       \lim_{x\to a}P\left(x\right)=P\left(a\right)
       ```

    2. ``P\left(x\right)`` and ``Q\left(x\right)`` are polynomials and ``Q\left(a\right)\ne 0``, then

       ```math
       \lim_{x\to a}\frac{P\left(x\right)}{Q\left(x\right)}=\frac{P\left(a\right)}{Q\left(a\right)}\,.
       ```

The following theorem will enable us to calculate some very important limits in subsequent chapters. It is called the *squeeze theorem* because it refers to a function ``g`` whose values are squeezed between the values of two other functions that have the same limit ``L`` at a point ``a``. Being trapped between the values of two functions that approach ``L``, the values of ``g`` must also approach ``L``.

{cell=chap display=false output=false}
```julia
Figure("", "The graph of " * tex("g") * " is squeezed between those of " * tex("f") * " and " * tex("h") * ".") do
    scale = 40
    Drawing(width=6scale, height=4.5scale) do
        xmid = 1scale
        ymid = 4scale
        axis_xy(6scale,4.5scale,xmid,ymid,scale,(3,),(2,),xs=("a",),xl=(1,),ys=("L",),yl=(1,))
        line(x1=4scale,y1=4scale,x2=4scale,y2=2scale,stroke_dasharray = "3",stroke="black")
        line(x1=1scale,y1=2scale,x2=4scale,y2=2scale,stroke_dasharray = "3",stroke="black")
        plot_xy(x->2+0.3(x-3)^2, -1:0.01:5, tuple(), xmid, ymid, scale, width=1, color="green")
        plot_xy(x->1+cos(x-3), -1:0.01:5, tuple(), xmid, ymid, scale, width=1, color="RoyalBlue")
        plot_xy(x->2-0.1(x-3)^2, -1:0.01:5, tuple(), xmid, ymid, scale, width=1)
        circle(cx=4scale, cy=2scale, r=3, fill="white", stroke="red")
        latex("y=g\\left(x\\right)", x=scale, y=1.9scale, width=5font_x, height=font_y,color="red")
        latex("y=f\\left(x\\right)", x=scale, y=1.2scale, width=5font_x, height=font_y,color="green")
        latex("y=h\\left(x\\right)", x=scale, y=2.6scale, width=5font_x, height=font_y,color="RoyalBlue")
    end
end
```

!!! theorem
    If ``f\left(x\right)\le g\left(x\right)\le h\left(x\right)`` holds for all ``x`` in some open interval containing ``a``, except possibly at ``x=a``, and

    ```math
    \lim_{x\to a}f\left(x\right)=\lim_{x\to a}h\left(x\right)=L\,,
    ```
    then,

    ```math
    \lim_{x\to a}g\left(x\right)=L\,.
    ```

Similar statements hold for one-sided limits.

!!! proof
    Let ``\varepsilon > 0`` be given.

    We want to find a strict positive number ``\delta`` such that

    ```math
    0&lt;\left|x-a\right|&lt;\delta\implies\left|g\left(x\right)-L\right|&lt;\varepsilon
    ```

    Observe that

    ```math
    \begin{aligned}
    \left|g\left(x\right)-L\right|=&\left|g\left(x\right)-f\left(x\right)+f\left(x\right)-L\right|\\
    \le&\left|g\left(x\right)-f\left(x\right)\right|+\left|f\left(x\right)-L\right|\\
    \le&\left|h\left(x\right)-f\left(x\right)\right|+\left|f\left(x\right)-L\right|=\left|h\left(x\right)-L+L-f\left(x\right)\right|+\left|f\left(x\right)-L\right|\\
    \le&\left|h\left(x\right)-L\right|+\left|L-f\left(x\right)\right|+\left|f\left(x\right)-L\right|
    \end{aligned}\\
    ```

    by the triangle inequality and the squeezing of ``g`` between ``f`` and ``h``.

    Since ``\lim_{x\to a}f\left(x\right)=L`` and ``\frac{\varepsilon}{3}`` is a strict positive number, there exists a number ``\delta_1`` such that

    ```math
    0&lt;\left|x-a\right|&lt;\delta_1\implies\left|f\left(x\right)-L\right|&lt;\frac{\varepsilon}{3}\,.
    ```

    Similarly, since ``\lim_{x\to a}h\left(x\right)=L`` and ``\frac{\varepsilon}{3}`` is a strict positive number, there exists a number ``\delta_2`` such that

    ```math
    0&lt;\left|x-a\right|&lt;\delta_2\implies\left|h\left(x\right)-L\right|&lt;\frac{\varepsilon}{3}\,.
    ```

    Let ``\delta=\min\left\lbrace\delta_1,\delta_2\right\rbrace``. If ``0&lt;\left|x-a\right|&lt;\delta``, then ``\left|x-a\right|&lt;\delta_1``, so ``\left|f\left(x\right)-L\right|&lt;\frac{\varepsilon}{3}``, and ``\left|x-a\right|&lt;\delta_2``, so ``\left|h\left(x\right)-L\right|&lt;\frac{\varepsilon}{3}``. Therefore,

    ```math
    \left|g\left(x\right)-L\right|\le\left|h\left(x\right)-L\right|+\left|L-f\left(x\right)\right|+\left|f\left(x\right)-L\right|&lt;\frac{\varepsilon}{3}+\frac{\varepsilon}{3}+\frac{\varepsilon}{3}=\varepsilon\,.
    ```

    This shows that ``\lim_{x\to a}g\left(x\right)=L``.

!!! example
    Show that if ``\lim_{x\to a}\left|f\left(x\right)\right|=0``, then ``\lim_{x\to a}f\left(x\right)=0``.

    Since ``-\left|f\left(x\right)\right|\le f\left(x\right)\le\left|f\left(x\right)\right|``, and ``-\left|f\left(x\right)\right|`` and ``\left|f\left(x\right)\right|`` both have limit ``0`` as ``x`` tends to ``a``, so does ``f\left(x\right)`` by the squeeze theorem.

## Limits at Infinity and Infinite Limits

We will extend the concept of limit to allow for two situations not covered by the definitions of limit and one-sided limit in the previous section:

1. *limits at infinity*, where ``x`` becomes arbitrarly large, positive or negative;
2. *infinite limits*, which are not real limits at all but provide usefull symbolism for describing the behaviour of functions whose values become arbitrarily large, positive or negative.

!!! example
    How behaves the function

    ```math
    f\left(x\right)=\frac{x}{\sqrt{x^2+1}}
    ```

    whose graph is shown in the next figure and for which some values are given in the following table for values of ``x`` that becomes arbitrarly large, positive and negative?

    {cell=chap display=false output=false}
    ```julia
    table() do io
        g = x->x/sqrt(x^2+1)
        thead(io, ("x", "f\\left(x\\right)=\\frac{x}{\\sqrt{x^2+1}}", "x", "f\\left(x\\right)=\\frac{x}{\\sqrt{x^2+1}}"), latex=true, align=:center)
        for (x1, x2) in ((-1000, 1), (-100, 10), (-10, 100), (1, 1000))
            gx1 = g(x1)
            gx2 = g(x2)
            trow(io, (string(x1), string(round(gx1, digits=9)), string(x2), string(round(gx2, digits=9))), latex=true, align=:center)
        end
    end
    ```

    {cell=chap display=false output=false}
    ```julia
    Figure("", "The graph of " * tex("\\frac{x}{\\sqrt{x^2+1}}") * ".") do
        scale = 40
        Drawing(width=12scale, height=3.5scale) do
            xmid = 6scale
            ymid = 2scale
            axis_xy(12scale,3.5scale,xmid,ymid,scale,tuple(),(1,-1),yl=(1,2))
            line(x1=6scale,y1=scale,x2=12scale,y2=scale,stroke_dasharray = "3",stroke="black")
            line(x1=0,y1=3scale,x2=6scale,y2=3scale,stroke_dasharray = "3",stroke="black")
            plot_xy(x->x/sqrt(x^2+1), -6:0.01:6, tuple(), xmid, ymid, scale, width=1)
        end
    end
    ```

    The values of ``f\left(x\right)`` seem to approach ``1`` as ``x`` takes on larger and larger positive values, and ``-1`` as ``x`` takes on negative values that get larger and larger in absolute value. We express this behaviour by writing
    
    ```math
    \begin{aligned}\lim_{x\to\infty}f\left(x\right)=1\quad & \textrm{“}f\left(x\right)\textrm{ approaches }1\textrm{ as }x\textrm{ approaches infinity.”}\\
    \lim_{x\to-\infty}f\left(x\right)=-1\quad & \textrm{“}f\left(x\right)\textrm{ approaches }-1\textrm{ as }x\textrm{ approaches negative infinity.”}
    \end{aligned}
    ```

    The graph of ``f`` conveys this limiting behaviour by approaching the horizontal lines ``y=1`` as ``x`` moves far to the right and ``y=-1`` as ``x`` moves far to the left. These lines are called *horizontal asymptotes`` of the graph. In general, if a curve approaches a straight line as it recedes very far away from the origin, that line is called an *asymptote* of the curve.

This example suggest the following definition of a limit at infinity.

!!! definition
    We say that ``f:X\mapsto Y`` approaches the limit ``L`` as ``x`` tends to infinity, and we write

    ```math
    \lim_{x\to\infty}f\left(x\right)=L\,,
    ```

    if the following condition is satisfied:

    ```math
    \forall \varepsilon>0,\exists R\left(\varepsilon\right):x&gt;R\implies x\in X \wedge \left|f\left(x\right)-L\right|&lt;\varepsilon\,.
    ```

    Similarly, we say that ``f:X\mapsto Y`` approaches the limit ``L`` as ``x`` tends to negative infinity, and we write

    ```math
    \lim_{x\to-\infty}f\left(x\right)=L\,,
    ```

    if the following condition is satisfied:

    ```math
    \forall \varepsilon>0,\exists R\left(\varepsilon\right):x&lt;R\implies x\in X \wedge \left|f\left(x\right)-L\right|&lt;\varepsilon\,.
    ```

!!! example
    Show that ``\displaystyle\lim_{x\to\infty}\frac{1}{x}=0``.

    Let ``\varepsilon`` be a given positive number. For ``x&gt;0``, we have

    ```math
    \left|\frac{1}{x}-0\right|=\left|\frac{1}{x}\right|=\frac{1}{x}&lt;\varepsilon\quad\textrm{provided}\quad x&gt;\frac{1}{\varepsilon}\,.
    ```

    Therefore, the condition of the definition is satisfied with ``R=\frac{1}{\varepsilon}``. We have shown that ``\lim_{x\to\infty}\frac{1}{x}=0``.

The rules and theorems of previous section have suitable counterparts for limits at infinity.

!!! example
    Evaluate ``\displaystyle\lim_{x\to\infty}f\left(x\right)`` and ``\displaystyle\lim_{x\to-\infty}f\left(x\right)`` for ``\displaystyle f\left(x\right)=\frac{x}{\sqrt{x^2+1}}``.

    Rewrite the expression for ``f\left(x\right)`` as follows:

    ```math
    \newcommand{\sgn}{\operatorname{sgn}}
    \begin{aligned}
    f\left(x\right)=&\frac{x}{\sqrt{x^2+1}}=\frac{x}{\sqrt{x^2\left(1+\frac{1}{x^2}\right)}}\\
    =&\frac{x}{\sqrt{x^2}\sqrt{1+\frac{1}{x^2}}}=\frac{x}{\left|x\right|\sqrt{1+\frac{1}{x^2}}}\\
    =&\frac{\sgn x}{\sqrt{1+\frac{1}{x^2}}}\,.
    \end{aligned}
    ```

    The factor ``\sqrt{1+\frac{1}{x^2}}`` approaches ``1`` as ``x`` approaches ``\infty`` or ``-\infty``, so ``f\left(x\right)`` must have the same limits as ``x\to\pm\infty`` as does ``\newcommand{\sgn}{\operatorname{sgn}}\sgn x``. Therefore,

    ```math
    \lim_{x\to\infty}f\left(x\right)=1\quad\textrm{and}\quad\lim_{x\to-\infty}f\left(x\right)=-1
    ```

The only polynomials that have limits at infinity are constant ones. The situation is more interesting for rational functions. The following examples show how to render such a function in a form where its limits at infinity (if they exist) are apparent. The way to do this is to *divide the numerator and the denominator by the highest power of ``x`` in the denominator.

!!! example
    Evaluate ``\displaystyle\lim_{x\to\infty}\frac{2x^2-x+3}{3x^2+5}``.

    Divide the numerator and the denominator by ``x^2``, the highest power of ``x`` appearing in the denominator:

    ```math
    \lim_{x\to\infty}\frac{2x^2-x+3}{3x^2+5}=\lim_{x\to\infty}\frac{2-\frac{1}{x}+\frac{3}{x^2}}{3+\frac{5}{x^2}}=\frac{2-0+0}{3+0}=\frac{2}{3}\,.
    ```

The technique used in the previous example can also be applied to more general kinds of functions.

!!! example
    Find ``\displaystyle\lim_{x\to\infty}\left(\sqrt{x^2+x}-x\right)``.

    We can rationalize the expression by multiplying the numerator and the denominator (which is ``1``) by the conjugate expression ``\sqrt{x^2+x}+x``.

    ```math
    \begin{aligned}
    \lim_{x\to\infty}\left(\sqrt{x^2+x}-x\right)=&\frac{\left(\sqrt{x^2+x}-x\right)\left(\sqrt{x^2+x}+x\right)}{\left(\sqrt{x^2+x}+x\right)}=\frac{x^2+x-x^2}{\left(\sqrt{x^2\left(1+\frac{1}{x}\right)}+x\right)}\\
    =&\frac{x}{\left(x\sqrt{1+\frac{1}{x}}+x\right)}=\frac{1}{\left(\sqrt{1+\frac{1}{x}}+1\right)}=\frac{1}{2}\,.
    \end{aligned}
    ```

A function whose values grow arbitrarily large can sometimes said to have an infinite limite. Since infinity is not a number, infinite limits are not really limits at all, but they provide a way of describing the behaviour of functions that grow arbitrarily large positive of negative.

!!! example
    Describe the behaviour of the function ``\displaystyle f\left(x\right)=\frac{1}{x^2}`` near ``x=0``.

    {cell=chap display=false output=false}
    ```julia
    Figure("", "The graph of " * tex("\\displaystyle\\frac{1}{x^2}") * ".") do
        scale = 60
        Drawing(width=6scale, height=3.5scale) do
            xmid = 3scale
            ymid = 3scale
            axis_xy(6scale,3.5scale,xmid,ymid,scale,tuple(),tuple())
            plot_xy(x->1/36x^2, -3:0.01:0, tuple(), xmid, ymid, scale, width=1)
            plot_xy(x->1/36x^2, 3:-0.01:0, tuple(), xmid, ymid, scale, width=1)
        end
    end
    ```

    As ``x`` approaches ``0`` from either side, the values of ``f\left(x\right)`` are positive and grow larger and larger, so the limit of ``f\left(x\right)`` as ``x`` approaches ``0`` *does not exist*. it is nevertheless convenient to describe the behaviour of ``f`` near ``0`` by saying that ``f\left(x\right)`` approaches ``\infty`` as ``x`` tends to zero. We write

    ```math
    \lim_{x\to 0}f\left(x\right)=\lim_{x\to 0}\frac{1}{x^2}=\infty\,.
    ```

    Note that in writing this we are *not* saying that ``\lim_{x\to 0}\frac{1}{x^2}`` *exists*. Rather, we are saying that the limit *does not exist because ``\frac{1}{x^2}`` *becomes arbitrarily large near* ``x=0``. Observe how the graph of ``f`` approaches the ``y``-axis as ``x`` tends to ``0``. the ``y``-axis is a **vertical asymptote** of the graph.

!!! definition
    We say that ``f:X\mapsto Y`` approaches infinity as ``x`` tends to ``a`` and write
    
    ```math
    \lim_{x\to a}f\left(x\right)=\infty\,.
    ```
    
    if the following condition is satisfied:

    ```math
    \forall B&gt;0,\exists\delta\left(B\right)&gt;0:0&lt;\left|x-a\right|&lt;\delta\implies x\in X\wedge f\left(x\right)&gt;B\,.
    ```

!!! example
    Verify that ``\displaystyle\lim_{x\to 0}\frac{1}{x^2}=\infty``.

    Let ``B`` be any positive number. We have

    ```math
    \frac{1}{x^2}&gt; B\quad\textrm{provided that}\quad x^2&lt;\frac{1}{B}\,.
    ```

    If ``\delta =\frac{1}{\sqrt{B}}``, then

    ```math
    0&lt;\left|x\right|&lt;\delta\quad\implies\quad x^2&lt;\delta^2=\frac{1}{B}\quad\implies\quad\frac{1}{x^2}&gt;B\,.
    ```

    Therefore, ``\lim_{x\to 0}\frac{1}{x^2}=\infty``.

!!! example

    Describe the behaviour of the function ``f\left(x\right)=\frac{1}{x}`` near ``x=0``.

    {cell=chap display=false output=false}
    ```julia
    Figure("", "The graph of " * tex("\\displaystyle\\frac{1}{x}") * ".") do
        scale = 40
        Drawing(width=8scale, height=8scale) do
            xmid = 4scale
            ymid = 4scale
            axis_xy(8scale,8scale,xmid,ymid,scale,(-1, 1),(-1, 1))
            plot_xy(x->1/x, -4:0.01:0, tuple(), xmid, ymid, scale, width=1)
            plot_xy(x->1/x, 4:-0.01:0, tuple(), xmid, ymid, scale, width=1)
        end
    end
    ```

    As ``x`` approaches ``0`` from the right, the values of ``f\left(x\right)`` become larger and larger positive numbers, and we say that ``f`` has right-hand limit infinity at ``x=0``:

    ```math
    \lim_{x\to0^+}f\left(x\right)=\infty
    ```

    Similarly, the values of ``f\left(x\right)`` become larger and larger negative numbers as ``x`` approaches ``0`` from the left, so ``f`` has left-hand limit ``-\infty`` at ``x=0``:

    ```math
    \lim_{x\to0^-}f\left(x\right)=-\infty
    ```

    These statements do not say that the one-sided limits *exist*; they do not exist because ``\infty`` and ``-\infty`` are not numbers. Since the one-sided limits are not equal even as infinite symbols, all we can say about the two-sided ``\lim_{x\to0}f\left(x\right)`` is that it does not exist.

We can now say a bit more about the limits at infinity and negative infinity of a rational function whose nuberator has higher degree than the denominator. Earlier we said that such a limit *does not exist*. This is true, but we can assign ``\infty`` or ``-\infty`` to such limits, as the following example shows.

!!! example
    Evaluate ``\displaystyle\lim_{x\to\infty}\frac{x^3+1}{x^2+1}``.

    Divide the numerator and the denominator by ``x^2``, the largest power of the denominator:

    ```math
    \lim_{x\to\infty}\frac{x^3+1}{x^2+1}=\lim_{x\to\infty}\frac{x+\frac{1}{x^2}}{1+\frac{1}{x^2}}=\frac{\displaystyle\lim_{x\to\infty}x+\frac{1}{x^2}}{1}=\infty\,.
    ```

A polynomial ``Q\left(x\right)`` of degree ``n&gt;0`` can have at most ``n`` *zeros*; that is, there are at most ``n`` different real numbers ``r`` for which ``Q\left(r\right)=0``. If ``Q\left(r\right)`` is the denominator of a rational function ``\displaystyle R\left(x\right)=\frac{P\left(x\right)}{Q\left(x\right)}``, that function will be defined for all ``x`` except those finitely many zeros of ``Q``. At each of those zeros, ``R\left(x\right)`` may have limits, infinite limits, or one-sided infinite limits. Here are some examples.

!!! example

    1. ``\displaystyle\lim_{x\to 2}\frac{\left(x- 2\right)^2}{x^2-4}=\lim_{x\to 2}\frac{\left(x- 2\right)^2}{\left(x-2\right)\left(x+2\right)}=\lim_{x\to 2}\frac{x-2}{x+2}=0``.

    2. ``\displaystyle\lim_{x\to 2}\frac{x- 2}{x^2-4}=\lim_{x\to 2}\frac{x- 2}{\left(x-2\right)\left(x+2\right)}=\lim_{x\to 2}\frac{1}{x+2}=\frac{1}{4}``.

    3. ``\displaystyle\lim_{x\to 2^+}\frac{x- 3}{x^2-4}=\lim_{x\to 2^+}\frac{x- 3}{\left(x-2\right)\left(x+2\right)}=-\infty``.

    4. ``\displaystyle\lim_{x\to 2^-}\frac{x- 3}{x^2-4}=\lim_{x\to 2^-}\frac{x- 3}{\left(x-2\right)\left(x+2\right)}=\infty``.

    4. ``\displaystyle\lim_{x\to 2}\frac{x- 3}{x^2-4}=\lim_{x\to 2}\frac{x- 3}{\left(x-2\right)\left(x+2\right)}`` does not exist.

    5. ``\displaystyle\lim_{x\to 2}\frac{2-x}{\left(x-2\right)^3}=\lim_{x\to 2}\frac{-\left(x-2\right)}{\left(x-2\right)^3}=\lim_{x\to 2}\frac{1}{\left(x-2\right)^2}=-\infty``.

## Continuity Defined

When a car is driven along a highway, its distance from its starting point depends on time in a *continuous* way, changing by small amounts over short intervals of time. But not all quantities change in this way. When the car is parked in a parking lot where the rate is quoted as "€2,00 per hour or portion," the parking charges remain at €2,00 for the first hour and then suddenly jump to €4,00 as soon as the first hour has passed. The function relating parking charges to parking time will be called *discontinuous* at each hour.

Most functions that we encounter have domains that are intervals, or unions of separate intervals. A point ``P`` in the domain of such a function is called an *interior point* of the domain if it belongs to some open interval contained in the domain. If it is not an interior point, then ``P`` is called an *endpoint* of the domain. For example, the domain of the function ``f\left(x\right)=\sqrt{4-x^2}`` is the closed interval ``\left[-2,2\right]``, which consists of interior points in the interval ``\left]-2,2\right[``, a left endpoint ``-2``, and a right endpoint ``2``. The domain of the function ``g\left(x\right)=\frac{1}{x}`` is the union of open intervals ``\left]-\infty, 0\right[\cup\left]0,\infty\right[`` and consists entirely of interior points. Note that although ``0`` is an endpoint of each of those intervals, it does not belong to the domain of ``g`` and so is not an endpoint of that domain.

!!! definition "Continuity of a function at a point"

    A function ``f``, defined on an open interval containing the point ``c``, an interior point, is said to be continuous at the point ``c`` if

    ```math
    \lim_{x\to c}f\left(x\right)=f\left(c\right)\,;
    ```

    that is,

    ```math
    \forall \varepsilon&gt;0,\exists\delta\left(\varepsilon\right)&gt;0:\left|x-c\right|&lt;\delta\implies\left|f\left(x\right)-f\left(c\right)\right|&lt;\varepsilon\,.
    ```

    If either ``\lim_{x\to c}f\left(x\right)`` fails to exist or it exists but is not equal to ``f\left(c\right)``, then we will say that ``f`` is discontinuous at ``c``.

In graphical terms, ``f`` is continuous at an interior point ``c`` of its domain if its graph has no break in it at the point ``\left(c,f\left(x\right)\right)``; in other words, if you can draw the graph through that point without lifting your pen from the paper.
 
{cell=chap display=false output=false}
```julia
Figure("", tex("f") * " is continuous at " * tex("c") * "; " * tex("\\displaystyle\\lim_{x\\to c}g\\left(x\\right)\\neq g\\left(c\\right)") * "; " * tex("\\displaystyle\\lim_{x\\to c}h\\left(x\\right)") * " does not exist.") do
    scale = 70
    Drawing(width=8.5scale, height=2.5scale) do
        xmid = 0.5scale
        ymid = 2scale
        axis_xy(2.5scale,2.5scale,xmid,ymid,scale,(1,),tuple(),xs=("c",))
        plot_xy(x->0.3x^2+0.1, -0.5:0.01:2, (1,), xmid, ymid, scale, width=1)
        latex("y=f\\left(x\\right)", x=xmid+scale-2font_x, y=0, width=4*font_x, height=font_y)
        xmid = 3.5scale
        axis_xy(2.5scale,2.5scale,xmid,ymid,scale,(1,),tuple(),xs=("c",),shift_x=3scale)
        plot_xy(x->0.3x^2+0.1, -0.5:0.01:2, tuple(), xmid, ymid, scale, width=1)
        latex("y=g\\left(x\\right)", x=xmid+scale-2font_x, y=0, width=4font_x, height=font_y)
        circle(cx=xmid+scale, cy=ymid-scale*0.4, r=3, fill="white", stroke="red")
        circle(cx=xmid+scale, cy=ymid-scale, r=3, fill="red", stroke="red")
        xmid = 6.5scale
        axis_xy(2.5scale,2.5scale,xmid,ymid,scale,(1,),tuple(),xs=("c",),shift_x=6scale)
        plot_xy(x->0.3x^2+0.1, -0.5:0.01:1, tuple(), xmid, ymid, scale, width=1)
        plot_xy(x->-2(x-1.5)^2+1.5, 1:0.01:2, (1,), xmid, ymid, scale, width=1)
        latex("y=h\\left(x\\right)", x=xmid+scale-2font_x, y=0, width=4font_x, height=font_y)
        circle(cx=xmid+scale, cy=ymid-scale*0.4, r=3, fill="white", stroke="red")
    end
end
```

Although a function cannot have a limit at an endpoint of its domain, it can still have a one-sided limit there. We extend the definition of continuity to provide for such situations.

!!! definition
    We say that ``f`` is *right continuous* at ``c`` if ``\displaystyle\lim_{x\to c^+}f\left(x\right)=f\left(x\right)``.

    We say that ``f`` is *left continuous* at ``c`` if ``\displaystyle\lim_{x\to c^-}f\left(x\right)=f\left(x\right)``.

!!! example
    The Heaviside function ``H\left(x\right)`` is continuous at every number ``x`` except ``0``. It is right continuous at ``0`` but is not left continuous or continuous there.

    {cell=chap display=false output=false}
    ```julia
    Figure("", """The Heaviside function""") do
        scale = 50
        Drawing(width=3scale, height=2scale) do
            xmid = 1.5scale
            ymid = 1.5scale
            axis_xy(3scale,2scale,xmid,ymid,scale,tuple(),(1,))
            plot_xy(x->0, -1.5:0.01:0, tuple(), xmid, ymid, scale, width=1)
            plot_xy(x->1, 0:0.01:1.5, tuple(0,), xmid, ymid, scale, width=1)
            circle(cx=xmid, cy=ymid, r=3, fill="white", stroke="red")
        end
    end
    ```

The relationship between continuity and one-sided continuity is summarized in the following theorem.

!!! theorem
    Function ``f`` is continuous at ``c`` if and only if it is both right continuous and left continuous at ``c``.

We have defined the concept of continuity at a point. Of greater importance is the concept of continuity on an interval.

!!! definition "Continuity of a function on an interval"
    A function ``f`` is continuous on an interval if it is continuous at every point of that interval. In the case of an endpoint of a closed interval, ``f`` need only be continuous on one side. Thus, ``f`` is continuous on the interval ``\left[a,b\right]`` if

    ```math
    \lim_{x\to t}f\left(x\right)=f\left(t\right)\,\quad\forall t:a&lt;t&lt;b\,,
    ```

    and

    ```math
    \lim_{x\to a^+}f\left(x\right)=f\left(a\right)\quad\textrm{and}\quad\lim_{x\to b^-}f\left(x\right)=f\left(b\right)\,.
    ```

These concepts are illustrated in following figure.

{cell=chap display=false output=false}
```julia
Figure("", tex("f") * " is continuous on the intervals " * tex("\\left[a,b\\right],\\,\\left]b,c\\right[,\\,\\left[c,d\\right],\\,\\left]d,e\\right]") * ".") do
    scale = 80
    Drawing(width=5.5scale, height=2scale) do
        xmid = 0.5scale
        ymid = 1.5scale
        axis_xy(5.5scale,2scale,xmid,ymid,scale,(0.5, 1.5, 2.5, 3.5, 4.5),tuple(), xs=("a","b","c","d","e"))
        plot_xy(x->-(x-1.25)^2+1, 0.5:0.01:1.5, (0.5, 1.5), xmid, ymid, scale, width=1)
        plot_xy(x->-0.5(x-1.5)^2+1.25, 1.5:0.01:2.5, tuple(), xmid, ymid, scale, width=1)
        circle(cx=xmid+1.5scale, cy=ymid-1.25scale, r=3, fill="white", stroke="red")
        circle(cx=xmid+2.5scale, cy=ymid-0.75scale, r=3, fill="white", stroke="red")
        plot_xy(x->x-2.25, 2.5:0.01:3.5, (2.5, 3.5), xmid, ymid, scale, width=1)
        plot_xy(x->-0.25(x-2.25)+1, 3.5:0.01:4.5, (4.5,), xmid, ymid, scale, width=1)
        circle(cx=xmid+3.5scale, cy=ymid-(-0.25*1.25+1)scale, r=3, fill="white", stroke="red")
    end
end
```

## Continuous Functions

!!! definition "Continuous function"
    We say that ``f`` is a *continuous function* if ``f`` is continuous at every point of its domain.

!!! example
    The function ``f\left(x\right)=\sqrt{x}`` is a continuous function. Its domain is ``\left[0,\infty\right[``. It is continuous at the left endpoint ``0`` because it is right continuous there. Also, ``f`` is continuous at every number ``c&gt;0`` since ``\lim_{x\to c}\sqrt x=\sqrt c``.

!!! example
    The function ``g\left(x\right)=\frac{1}{x}`` is also a continuous function. This may seem wrong to you at first glance because its graph is broken at ``x=0``. However, the number ``0`` is not in the domain of ``g``, so we will prefer to say that ``g`` is undefined rather than discontinuous there.

The following functions are continuous wherever they are defined:
1. all polynomials;
2. all rational functions;
3. all rational powers ``x^\frac{m}{n}=\sqrt[n]{x^m}``;
4. the sine, cosine, tangent, secant, cosecant, and cotangent functions; and
5. the absolute value function ``\left|x\right|``.

Corollary 4 of this chapter assures us that every polynomial is continuous everywhere on the real line, and every rational function is continuous everywhere on its domain (which consists of all real numbers except the finitely many where its denominator is zero). If ``m`` and ``n`` are integers and ``n \neq 0``, the rational power function ``x^\frac{m}{n}`` is defined for all positive numbers ``x``, and also for all negative numbers ``x`` if ``n`` is odd. The domain includes ``0`` if and only if ``\frac{m}{n} \ge 0``.

The following theorems show that if we combine continuous functions in various ways, the results will be continuous.

!!! theorem
    If ``f`` and ``g`` are continuous at the point ``c``, then so are ``f+g``, ``f-g``, ``fg``, and, if ``g\left(c\right)\neq0``, ``\displaystyle\frac{f}{g}``.

!!! proof
    This is just a restatement of various rules for combining limits; for example,
    ```math
    \lim_{x\to c}f\left(x\right)g\left(x\right)=\left(\lim_{x\to c}f\left(x\right)\right)\left(\lim_{x\to c}g\left(x\right)\right)=f\left(c\right)g\left(c\right)\,.
    ```

!!! theorem
    If ``f`` is a continuous function at the point ``L`` and if ``\displaystyle\lim_{x\to c}g\left(x\right)=L``, then we have
    ```math
    \lim_{x\to c}f\left(g\left(x\right)\right)=f\left(L\right)=f\left(\lim_{x\to c}g\left(x\right)\right)\,.
    ```

!!! proof
    Let ``\varepsilon >0`` be given.

    Since ``f`` is continuous at ``L``, there exists ``\kappa&gt;0`` such that ``\left|f\left(g\left(x\right)\right)-f\left(L\right)\right|&lt;\varepsilon`` whenever ``\left|g\left(x\right)-L\right|&lt;\kappa``.

    Since ``\lim_{x\to c}g\left(x\right)=L``, there exists ``\delta>0`` such that if ``0&lt;\left|x-c\right|&lt;\delta``, then ``\left|g\left(x\right)-L\right|&lt;\kappa``.

    Hence, if ``0&lt;\left|x-c\right|&lt;\delta``, then ``\left|f\left(g\left(x\right)\right)-f\left(L\right)\right|&lt;\varepsilon``, and ``\lim_{x\to c}f\left(g\left(x\right)\right)=f\left(L\right)``.

## Continuous Extensions and Removable Discontinuities

As we have seen a rational function may have a limit even at a point where its denominator is zero. If ``f\left(c\right)`` is not defined, but ``\lim_{x\to c}f\left(x\right)=L`` exists, we can define a new function ``F\left(x\right)`` by
```math
    F\left(x\right)=\begin{cases}
    f\left(x\right)&\textrm{if }x\textrm{ is in the domain of }f\\
    L&\textrm{if }x=c\,.
    \end{cases}
```

``F\left(x\right)`` is continuous at ``x=c``. It is called the *continuous extension* of ``f\left(x\right)`` to ``x=c``. For rational functions, continuous extensions are usually found by cancelling common factors.

!!! example
    Show that ``f\left(x\right)=\frac{x^2-x}{x^2-1}`` has a continuous extension to ``x=1``, and find that extension.

    Although ``f\left(1\right)`` is not defined, if ``x\neq 1`` we have
    ```math
    f\left(x\right)=\frac{x^2-x}{x^2-1}=\frac{x\left(x-1\right)}{\left(x+1\right)\left(x-1\right)}=\frac{x}{x+1}\,.
    ```

    The function ``\displaystyle F\left(x\right)=\frac{x}{x+1}`` is equal to ``f\left(x\right)`` for ``x\neq 1`` but is also continuous at ``x=1``, having there the value ``\frac{1}{2}``. The continuous extension of ``f\left(x\right)`` to ``x=1`` is ``F\left(x\right)``. It has the same graph as ``f\left(x\right)`` except with no hole at ``\left(1,\frac{1}{2}\right)``.

If a function ``f`` is undefined or discontinuous at a point ``c`` but can be (re)defined at that single point so that it becomes continuous there, then we say that ``f`` has a removable discontinuity at ``c``. The function ``f`` in the above example has a removable discontinuity at ``x=1``. To remove it, define ``f\left(1\right)=\frac{1}{2}``.

!!! example
    The function ``\displaystyle g\left(x\right)=\begin{cases}x&\textrm{if}\ x\neq2\\1&\textrm{if }x=2\end{cases}`` has a removable discontinuity at ``x=2``. To remove it, redefine ``g\left(2\right)=2``.

## The Intermediate-Value Theorem

Continuous functions that are defined on closed, finite intervals have special properties that make them particularly useful in mathematics and its applications. We will discuss two of these properties here. Although they may appear obvious, these properties are much more subtle than the results about limits stated earlier in this chapter; their proofs require a careful study of the implications of the completeness property of the real numbers and are based on the Nested Intervals theorem.

The first property of a continuous function defined on a closed, finite interval is that the function takes on all real values between any two of its values. This property is called the intermediate-value property.

{cell=chap display=false output=false}
```julia
Figure("", "The continuous function " * tex("f") * " takes on the value " * tex("s") * " at some point " * tex("c") * " between " * tex("a") * " and " * tex("b") * ".") do
    scale = 60
    Drawing(width=5scale, height=4.5scale) do
        xmid = 1scale
        ymid = 4scale
        f = x->sin(4*x-2)+(x-0.5)+0.5
        x = 2.075
        ymin = f(0.5)
        y = f(x)
        ymax = f(3.5)
        axis_xy(4.5scale,4.5scale,xmid,ymid,scale,(0.5, x, 3.5),(ymin,y,ymax), xs=("a","c","b"), ys=("f\\left(a\\right)", "s", "f\\left(b\\right)"), yl=(3, 1.5, 3), shift_x=0.5scale)
        plot_xy(f, 0.5:0.01:3.5, (0.5, 3.5), xmid, ymid, scale, width=1)
        circle(cx=xmid+x*scale, cy=ymid-y*scale, r=3, fill="RoyalBlue", stroke="RoyalBlue")
        line(x1=xmid, y1=ymid-y*scale, x2=xmid+3.5*scale, y2=ymid-y*scale, stroke="RoyalBlue")
        line(x1=xmid+x*scale, y1=ymid, x2=xmid+x*scale, y2=ymid-y*scale, stroke="RoyalBlue")
        line(x1=xmid, y1=ymid-ymin*scale, x2=xmid+0.5*scale, y2=ymid-ymin*scale, stroke="black", stroke_dasharray = "3")
        line(x1=xmid+0.5*scale, y1=ymid, x2=xmid+0.5*scale, y2=ymid-ymin*scale, stroke="black", stroke_dasharray = "3")
        line(x1=xmid, y1=ymid-ymax*scale, x2=xmid+3.5*scale, y2=ymid-ymax*scale, stroke="black", stroke_dasharray = "3")
        line(x1=xmid+3.5*scale, y1=ymid, x2=xmid+3.5*scale, y2=ymid-ymax*scale, stroke="black", stroke_dasharray = "3")
    end
end
```

The figure shows a typical situation. The points ``\left(a, f\left(a\right)\right)`` and ``\left(b, f\left(b\right)\right)`` are on opposite sides of the horizontal line ``y=s``. Being unbroken, the graph ``y=f\left(x\right)`` must cross this line in order to go from one point to the other. In the figure, it crosses the line only once, at ``x=c``. If the line ``y=s`` were somewhat lower or higher, there might have been three crossings and three possible values for ``c``.

We need the following lemma to prove the intermediate-value property.

!!! lemma "Aura theorem"
    Let ``f`` be continuous at ``c``.

    1. If ``f\left(c\right)&gt;0``, then ``f\left(x\right)&gt;0`` for all ``x`` in some open interval containing ``c``.
    2. If ``f\left(c\right)&lt;0``, then ``f\left(x\right)&lt;0`` for all ``x`` in some open interval containing ``c``.

!!! proof
    Let ``f\left(c\right)&gt;0``.

    Then, corresponding to ``\displaystyle\varepsilon = \frac{f\left(c\right)}{2}&gt;0`` there exists a corresponding ``\delta&gt;0`` such that ``\left|x-c\right|&lt;\delta`` implies
    ```math
    \left|f\left(x\right)-f\left(c\right)\right|&lt;\frac{f\left(c\right)}{2} \iff -\frac{f\left(c\right)}{2}&lt;f\left(x\right)-f\left(c\right)&lt;\frac{f\left(c\right)}{2} \iff 0&lt;\frac{f\left(c\right)}{2}&lt;f\left(x\right)&lt;\frac{3f\left(c\right)}{2}\,.
    ```
    Hence, ``f\left(x\right)&gt;0`` for all ``x\in\left]c-\delta,c+\delta\right[``.

!!! exercise
    Prove the second part of the Aura theorem.

We will first prove a special case from which the general case follows easily.

!!! theorem "Bolzano's theorem"
    Let ``f`` be a continuous function defined on ``\left[a,b\right]``. If ``f\left(a\right)&lt;0`` and ``f\left(b\right)&gt;0``, then there exists ``c\in\left]a,b\right[`` such that ``f\left(c\right)=0``.

!!! proof "by contradiction"
    Let ``I_0=\left[a_0, b_0\right]=\left[a,b\right]``. 
    
    If ``\displaystyle f\left(\frac{a_0+b_0}{2}\right)=0``, we are done. Otherwise, ``f`` changes sign on either ``\displaystyle\left[a_0,\frac{a_0+b_0}{2}\right]`` or ``\displaystyle\left[\frac{a_0+b_0}{2},b_0\right]``.

    Let ``I_1=\left[a_1, b_1\right]`` be the subinterval on which ``f`` changes sign and repeat.

    By the Nested Intervals theorem, ``\bigcap_{n\in ℕ}I_n=\left\{c\right\}``, where ``c=\sup\left\{a_n\right\}=\inf\left\{b_n\right\}``.

    Suppose ``f\left(c\right)&gt;0``. By the Aura theorem, ``f`` must be positive on an open interval containing ``c``. Since ``c=\sup\left\{a_n\right\}``, by the Capture theorem this open interval must contain some ``a_m``. But ``f\left(a_m\right)&lt;0`` which is a contradiction.

    Suppose ``f\left(c\right)&lt;0``. By the Aura theorem, ``f`` must be negative on an open interval containing ``c``. Since ``c=\inf\left\{b_n\right\}``, by the Capture theorem this open interval must contain some ``b_m``. But ``f\left(b_m\right)&gt;0`` which is a contradiction.

    Hence, ``f\left(c\right)=0``.

If ``f\left(a\right)&gt;0`` and ``f\left(b\right)&lt;0``, then ``g=-f`` satisfies the hypotheses of Bolzano's theorem and therefore ``g\left(c\right)=-f\left(c\right)=0`` for some ``c\in\left]a,b\right[``, and hence ``f\left(c\right)=0``.

!!! theorem "Intermediate-value theorem"
    If ``f`` is continuous on the interval ``\left[a,b\right]`` and if ``s`` is a number between ``f\left(a\right)`` and ``f\left(b\right)``, then there exists a number ``c\in\left]a,b\right[`` such that ``f\left(c\right)=s``.

!!! proof
    Let ``s`` be a number between ``f\left(a\right)`` and ``f\left(b\right)``.

    The function ``g\left(x\right)=f\left(x\right)-s`` is continuous and satifies the hypotheses of Bolzano's theorem, so there exists some ``c\in\left]a,b\right[`` such that ``g\left(c\right)=f\left(c\right)-s=0``.

    Hence, ``f\left(c\right)=s``.

!!! example
    Show that the equation ``x^3-x-1=0`` has a solution in the interval ``\left[1,2\right]``.

    The function ``f\left(x\right)=x^3-x-1`` is a polynomial and is therefore continuous everywhere.

    Now ``f\left(1\right)=-1`` and ``f\left(2\right)=5``. Since ``0`` lies between ``-1`` and ``5``, the Intermediate-value theorem assures us that there must be a number ``c\in\left[1,2\right]`` such that ``f\left(c\right)=0``.

One method for finding a zero of a function that is continuous and changes sign on an interval involves bisecting the interval many times, each time determining which half of the previous interval must contain the root, because the function has opposite signs at the two ends of that half.

!!! example
    Solve the equation ``x^3-x-1=0`` correct to ``3`` decimal places by successive bisection.

    {cell=chap display=false output=false}
    ```julia
    table() do io
        a = 1
        b = 2
        f = x->x^3-x-1
        thead(io, ("i", "a_i", "B_i", "\\displaystyle\\frac{a_i+b_i}{2}", "\\displaystyle f\\left(\\frac{a_i+b_i}{2}\\right)"), latex=true)
        for i in 0:11
            m = 0.5(a+b)
            fm = f(m)
            trow(io, (string(i), string(a), string(b), string(m), string(round(fm, digits=4))), latex= true, align=(:left, :left, :left, :left, :center))
            if fm < 0
                a = m
            else
                b = m
            end
        end
    end
    ```

    The root is ``1.325`` rounded to ``3`` decimal places.

This method is slow. For example, if the original interval has length ``1``, it will take ``11`` bisections to cut down to an interval of length less than ``0.0005`` (because ``2^{11}&gt;2000=\frac{1}{0.0005}``, and thus to ensure that we have found the root correct to ``3`` decimal places.

In chapter 5, calculus will provide us with much faster methods of solving equations such as the one in the example above. 

## The Extreme-Value Theorem

The second of the properties states that a function ``f`` that is continuous on a closed, finite interval ``\left[a,b\right]`` must have an absolute maximum value and an absolute minimum value. This means that the values of ``f\left(x\right)`` at all points of the interval lie between the values of ``f\left(x\right)`` at two particular points in the interval; the graph of ``f`` has a highest point and a lowest point.

To prove the extreme-value theorem, we will first show that a continuous function on a closed interval is bounded; that is, there exists a constant ``K`` such that ``\left|f\left(x\right)\right|\le K`` if ``a\le x\le b``.

We need the following lemma to prove the boundness property.

!!! lemma
    If ``f`` is continuous at ``a``, then ``f`` is bounded on some open interval containing ``a``.

!!! proof
    Since ``f`` is continuous at ``a``, corresponding to ``\varepsilon =1&gt;0``, there exists ``\delta>0`` such that ``\left|x-a\right|&lt;\delta`` implies ``\left|f\left(x\right)-f\left(a\right)\right|&lt;1``.

    That is, ``x\in\left]a-\delta,a+\delta\right[`` implies ``f\left(a\right)-1&lt;f\left(x\right)&lt;f\left(a\right)+1``, which shows that ``f`` is bounded on the open interval ``\left]a-\delta,a+\delta\right[``.

As we have seen in the proof of the intermediate-value theorem, when our nested intervals ``I_n=\left[a_n,b_n\right]`` arise from the bisection procedure the capture theorem implies that any open interval containing ``c`` (where ``\bigcap_{n\in ℕ}I_n=\left\{c\right\}``) necessarily contains an ``a_k`` and a ``b_l``. Something stronger is actually true: any open interval containing ``c`` actually contains an entire interval ``I_N``, for some ``N``.

To see this, note that there are tree possibilities:
- if ``k=l``, then the open interval contains ``I_k``;
- if ``k&lt; l``, then the open interval contains ``a_k\le a_{k+1}\le \dots a_l\le b_l``, so the open interval contains ``I_l``;
- if  if ``k&gt; l``, then the open interval contains ``a_k\le b_k\le \dots \le \dots b_{l+1}\le b_l``, so the open interval contains ``I_k``.

!!! theorem "Boundness theorem"
    If ``f`` is continous on ``\left[a,b\right]``, then ``f`` is bounded on ``\left[a,b\right]``.

!!! proof "by contradiction"
    Let ``I_0=\left[a_0, b_0\right]=\left[a,b\right]``.

    Suppose ``f`` is continuous on ``\left[a,b\right]`` but not bounded. Then ``f`` is either unbounded on ``\displaystyle \left[a_0,\frac{a_0+b_0}{2}\right]`` or ``\displaystyle \left[\frac{a_0+b_0}{2},b_0\right]`` (since, otherwise, ``f`` would be bounded on their union and hence on all ``I_0``).

    Let ``I_1=\left[a_1, b_1\right]`` be the subinterval on which ``f`` is unbounded and repeat.

    By the Nested Intervals theorem, ``\bigcap_{n\in ℕ}I_n=\left\{c\right\}``, where ``c=\sup\left\{a_n\right\}=\inf\left\{b_n\right\}``.

    Since ``f`` is continuous at ``c``, ``f`` is bounded on some open interval containing ``c``. However, as we have seen, such an open interval contains one of the intervals ``I_N``, which is a contradiction since ``f`` is unbounded on each ``I_n``.

    Hence, ``f`` is bounded on ``\left[a,b\right]``.

Finally, we can prove the Extreme-value theorem.

!!! theorem "Extreme-value theorem"
    A continuous function on ``\left[a,b\right]`` attains both an absolute maximum and an absolute minimum on ``\left[a,b\right]``.

!!! proof "by contradiction"
    We prove ``f`` has a maximum on ``\left[a,b\right]``.

    Since ``f`` is continuous on ``\left[a,b\right]``, by the Boundness theorem ``f`` is bounded on ``\left[a,b\right]``.

    Since ``f`` is bounded, its image set is a nonempty subset of ``ℝ`` which is bounded above, so by the Completeness axiom it has a least upper bound.

    Let ``M=\sup f\left(\left[a,b\right]\right)``. By definition of ``M``, ``f\left(x\right)\le M`` for all ``x\in\left[a,b\right]``.

    Suppose that ``f\left(x\right)&lt; M`` for all ``x\in\left[a,b\right]``.

    Then ``\displaystyle g\left(x\right)=\frac{1}{M-f\left(x\right)}`` is continuous on ``\left[a,b\right]`` and hence bounded on ``\left[a,b\right]`` by the Boundness theorem.

    So, there exists ``K>0`` such that ``\displaystyle\frac{1}{M-f\left(x\right)}\le K`` for all ``x\in\left[a,b\right]``.

    It follows that ``\displaystyle f\left(x\right)\le M-\frac{1}{K}`` for all ``x\in\left[a,b\right]``, which says that ``\displaystyle M-\frac{1}{K}`` is an upper bound for ``f\left(\left[a,b\right]\right)``.

    Since ``K>0``, ``\displaystyle M-\frac{1}{K}&lt; M``. This contradicts the fact that ``M=\sup f\left(\left[a,b\right]\right)``.

    Hence, there must exist ``c\in\left[a,b\right]`` such that ``f\left(c\right)=M``.

To see that ``f`` has a minimum on ``\left[a,b\right]``, just note that ``h=-f`` is continuous on ``\left[a,b\right]`` and therefore has a maximum of ``\left[a,b\right]``.

!!! exercise
    Complete the proof that a continuous function ``f`` on a closed interval ``\left[a,b\right]`` attains its absolute minimum.

The conclusion of the Extreme-value theorem may fail if the function ``f`` is not continuous or if the interval is not closed.

{cell=chap display=false output=false}
```julia
Figure("", """<div style="text-align: justify"><ul><li>""" * tex("\\displaystyle f_1\\left(x\\right)=\\frac{1}{x}") * " is continuous on the open interval " * tex("\\left]0,1\\right[") * ". It is not bounded and has neither a maximum nor a minimum value.</li><li>" * tex("f_2\\left(x\\right)=x") * " is continuous on the open interval " * tex("\\left]0,1\\right[") * ". It is bounded but neither has a maximum nor a minimum value.</li><li>" * tex("\\displaystyle f_3") * " is defined on the closed interval " * tex("\\left[0,1\\right]") * " but is discontinuous at the endpoint " * tex("x=1") * ". It has a minimum value but no maximum value.</li><li>" * tex("\\displaystyle f_4") * " is discontinuous at an interior point of its domain, the closed interval" * tex("\\left[0,1\\right]") * ". It is bounded but has neither maximum nor minimum values.</li></ul></div>") do
    scale = 60
    Drawing(width=10scale, height=2.75scale) do
        xmid = 0.5scale
        ymid = 2.25scale
        axis_xy(2scale,2.75scale,xmid,ymid,scale,(1,),tuple())
        plot_xy(x->1/x, 0.1:0.01:1, tuple(), xmid, ymid, scale, width=1)
        latex("y=f_1\\left(x\\right)", x=xmid+scale-2font_x, y=-5, width=4*font_x, height=font_y+2)
        circle(cx=xmid+scale, cy=ymid-scale, r=3, fill="white", stroke="red")
        xmid = 3scale
        axis_xy(2scale,2.75scale,xmid,ymid,scale,(1,),tuple(),shift_x=2.5scale)
        plot_xy(x->x, 0:0.01:1, tuple(), xmid, ymid, scale, width=1)
        latex("y=f_2\\left(x\\right)", x=xmid+scale-2font_x, y=-5, width=4font_x, height=font_y+2)
        circle(cx=xmid, cy=ymid, r=3, fill="white", stroke="red")
        circle(cx=xmid+scale, cy=ymid-scale, r=3, fill="white", stroke="red")
        xmid = 5.5scale
        axis_xy(2scale,2.75scale,xmid,ymid,scale,(1,),tuple(),shift_x=5scale)
        plot_xy(x->x, 0:0.01:1, (0, ), xmid, ymid, scale, width=1)
        latex("y=f_3\\left(x\\right)", x=xmid+scale-2font_x, y=-5, width=4font_x, height=font_y+2)
        circle(cx=xmid+scale, cy=ymid, r=3, fill="red", stroke="red")
        circle(cx=xmid+scale, cy=ymid-scale, r=3, fill="white", stroke="red")
        xmid = 8scale
        axis_xy(2scale,2.75scale,xmid,ymid,scale,(0.5, 1,),tuple(),shift_x=7.5scale)
        plot_xy(x->1+2x, 0:0.01:0.5, (0,), xmid, ymid, scale, width=1)
        plot_xy(x->2x-1, 0.5:0.01:1, (1,), xmid, ymid, scale, width=1)
        latex("y=f_4\\left(x\\right)", x=xmid+scale-2font_x, y=-5, width=4font_x, height=font_y+2)
        circle(cx=xmid+0.5scale, cy=ymid-2scale, r=3, fill="white", stroke="red")
        circle(cx=xmid+0.5scale, cy=ymid, r=3, fill="white", stroke="red")
        circle(cx=xmid+0.5scale, cy=ymid-scale, r=3, fill="red", stroke="red")
    end
end
```

The Intermediate-value theorem and the Extreme-value theorem are examples of what mathematicians call *existence theorems*. Such theorems assert that something exists without telling you how to find it.

By the Intermediate-value theorem and the Extreme-value theorem, a continuous function defined on a closed interval takes on all values between its minimum value ``m`` and its maximum value ``M`` , so its range is also a closed interval, ``\left[m,M\right]``.

This is the reason why the graph of a function that is continuous on an interval cannot have any breaks. It must be *connected*, a single, unbroken curve with no jumps.
