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

function axis_xy(width::Number, height::Number, Ox::Number, Oy::Number, scale::Number, axis_x, axis_y; xs=nothing, ys=nothing, xl=nothing, yl=nothing, xh=nothing, yh=nothing)
	defs() do
		marker(id="arrow", markerWidth="6", markerHeight="6", refX="3", refY="3", orient="auto") do
			path(d="M 0 0 L 6 3 L 0 6 z", fill="black" )
		end
	end
	latex("O", x=Ox-font_x-2, y=Oy, width=font_x, height=font_y)
	latex("x", x=width-font_x-2, y=Oy-font_y-2, width=font_x, height=font_y)
	latex("y", x=Ox+2, y=0-2, width=font_x, height=font_y)
	line(x1=0, y1=Oy, x2=width-3, y2=Oy, stroke="black", marker_end="url(#arrow)")
	for (nr, n) in enumerate(axis_x)
		line(x1=Ox+scale*n, y1=Oy-3, x2=Ox+scale*n, y2=Oy+3, stroke="black")
		txt = if xs===nothing "$n" else "$(xs[nr])" end
		len = if xl===nothing length(txt) else xl[nr] end
		h = if xh===nothing 1 else xh[nr] end
		latex(txt, x=Ox+scale*n-font_x*len/2, y=Oy, width=font_x*len, height=font_y*h)
	end
	line(x1=Ox, y1=height, x2=Ox, y2=3, stroke="black", marker_end="url(#arrow)")
	for (nr, n) in enumerate(axis_y)
		line(x1=Ox-3, y1=Oy-scale*n, x2=Ox+3, y2=Oy-scale*n, stroke="black")
		txt = if ys===nothing "$n" else "$(ys[nr])" end
		len = if yl===nothing length(txt) else yl[nr] end
		h = if xh===nothing 1 else xh[nr] end
		latex(txt, x=Ox-font_x*len, y=Oy-scale*n-font_y/2, width=font_x*len, height=font_y*h)
	end
end

function plot_xy(f::Function, xs, xdots, Ox::Integer, Oy::Integer, scale::Integer; color::String="red", dashed::String="", width::Number=1)
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

       | Time interval | Average velocity |
       |:-------------:|:----------------:|
       |``\left[1,1.1\right]`` |``10.29`` |
       |``\left[1,1.01\right]`` |``9.849`` |
       |``\left[1,1.001\right]`` |``9.805`` |
       |``\left[1,1.0001\right]`` |``9.801`` |
    2. at time ``t=2\,\left[\mathrm{s}\right]``?

       | Time interval | Average velocity |
       |:-------------:|:----------------:|
       |``\left[2,2.1\right]`` |``20.09`` |
       |``\left[2,2.01\right]`` |``19.65`` |
       |``\left[2,2.001\right]`` |``19.60`` |
       |``\left[2,2.0001\right]`` |``19.60`` |

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

The final form no longer involves divison by ``h``. It approaches ``gt + \frac{g}{2}0=gt``. In particular, at ``t=1\,\left[\mathrm{s}\right]`` and ``t=2\,\left[\mathrm{s}\right]``, the instantaneous velocities are ``v_1=9.8\,\left[\frac{\mathrm{m}}{\mathrm{s}}\right]`` and ``v_2=19.6\,\left[\frac{\mathrm{m}}{\mathrm{s}}\right]``, respectively.

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

The perimeter ``P_n`` and area ``A_n`` of the polygon are ``n``times these expressions:

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

## Limits of Functions

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
    Figure("", """The graph of <span class="math-tex" data-type="tex">\\(\\left(x\\right)=\\frac{x^2-1}{x-1}\\)</span>.""") do
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

    |``x``|``g\left(x\right)``|
    |:---:|:-----------------:|
    |``\pm 0.1``|``2.704813829``|
    |``\pm 0.01``|``2.718145927``|
    |``\pm 0.001``|``2.718280469``|
    |``\pm 0.0001``|``2.718281815``|
    |``\pm 0.00001``|``1.000000000``|

    Except the last value in the table, the values of ``g\left(x\right)`` seem to be approaching a certain number, ``2.71828\dots``, as ``x`` tends to ``0``. We will see in Chapter 5 that

    ```math
    \lim_{x\to 0}g\left(x\right)=\lim_{x\to 0}\left(1+x^2\right)^\frac{1}{x^2}=ℯ=2.718281828459045\dots\,.
    ```

    Observe that the last entry in the table appears to be wrong. It is because the calculator or MATLAB can only represent a finite number of numbers. The calculator was unable to distinguish ``1+\left(0.00001\right)^2=1.0000000001`` from ``1``, and it therefore calculated ``1^{10000000000}=1``. See the course of MATLAB.

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
Figure("", """If <span class="math-tex" data-type="tex">\\(x\\ne a\\)</span> and <span class="math-tex" data-type="tex">\\(\\left|x-a\\right|<\\delta\\)</span>, then <span class="math-tex" data-type="tex">\\(\\left|f\\left(x\\right)-L\\right|<\\varepsilon\\)</span>.""") do
    scale = 40
    Drawing(width=6scale, height=4.5scale) do
        xmid = 1scale
        ymid = 4scale
        axis_xy(6scale,4.5scale,xmid,ymid,scale,(2,3,4),(3,2,1),xs=("a-\\delta","a","a+\\delta"),xl=(3,1,3),ys=("L-\\varepsilon","L","L+\\varepsilon"),yl=(3,1,3))
        line(x1=4scale,y1=4scale,x2=4scale,y2=2scale,stroke_dasharray = "3",stroke="black")
        line(x1=1scale,y1=2scale,x2=4scale,y2=2scale,stroke_dasharray = "3",stroke="black")
        plot_xy(x->0.25(x-3+sqrt(7))^2+0.25, -1:0.01:5, tuple(), xmid, ymid, scale, width=1)
        circle(cx=4scale, cy=2scale, r=3, fill="white", stroke="red")
        rect(x=3scale,y=0,width=2scale,height=4scale, fill="hsla(189, 100%, 50%, 10%)")
        rect(x=scale,y=scale,width=4scale,height=2scale, fill="hsla(180, 100%, 25%, 10%)")
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

    2. ``\lim_{c\to a}x=c`` (``c`` is a constant).

       Let ``\varepsilon>0`` be given. We must find ``\delta>0`` so that

       ```math
       0<\left|x-a\right|<\delta\implies\left|c-c\right|<\varepsilon\,.
       ```

       Since ``c-c=0``, we can use any positive number for ``\delta`` and the implication above will be true. This proves that ``\lim_{c\to a}x=c``.

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
Figure("", """<span class="math-tex" data-type="tex">\\(\\newcommand{\\sgn}{\\operatorname{sgn}}\\lim_{x\\to0^-}\\sgn x=-1\\)</span> and <span class="math-tex" data-type="tex">\\(\\lim_{x\\to0^+}\\sgn x=1\\)</span>.""") do
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
    Figure("", """<span class="math-tex" data-type="tex">\\(\\sqrt{1-x^2}\\)</span> has right limit 0 at -1 and left limit 0 at 1.""") do
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
Figure("", """The graph of <span class="math-tex" data-type="tex">\\(g\\)</span> is squeezed between those of <span class="math-tex" data-type="tex">\\(f\\)</span> and <span class="math-tex" data-type="tex">\\(h\\)</span>.""") do
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

### Limits at Infinity

!!! example
    How behaves the function

    ```math
    f\left(x\right)=\frac{x}{\sqrt{x^2+1}}
    ```

    whose graph is shown in the next figure and for which some values are given in the following table for values of ``x`` that becomes arbitrarly large, positive and negative?

    |``x``|``f\left(x\right)=\frac{x}{\sqrt{x^2+1}}``|``x``|``f\left(x\right)=\frac{x}{\sqrt{x^2+1}}``|
    |:---:|:----------------------------------------:|:---:|:----------------------------------------:|
    |``-1000``|``-0.9999995``|``1``|``0.7071068``|
    |``-100``|``-0.9999500``|``10``|``0.9950372``|
    |``-10``|``-0.9950372``|``100``|``0.9999500``|
    |``-1``|``-0.7071068``|``1000``|``0.9999995``|

    {cell=chap display=false output=false}
    ```julia
    Figure("", """The graph of <span class="math-tex" data-type="tex">\\(\\frac{x}{\\sqrt{x^2+1}}\\)</span>.""") do
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
    Show that ``\lim_{x\to\infty}\frac{1}{x}=0``.

    Let ``\varepsilon`` be a given positive number. For ``x&gt;0``, we have

    ```math
    \left|\frac{1}{x}-0\right|=\left|\frac{1}{x}\right|=\frac{1}{x}&lt;\quad\textrm{provided}\quad x&gt;\frac{1}{\varepsilon}\,.
    ```

    Therefore, the condition of the definition is satisfied with ``R=\frac{1}{\varepsilon}``. We have shown that ``\lim_{x\to\infty}\frac{1}{x}=0``.

The rules and theorems of previous section have suitable counterparts for limits at infinity.

!!! example
    Evaluate ``\lim_{x\to\infty}f\left(x\right)`` and ``\lim_{x\to-\infty}f\left(x\right)`` for ``f\left(x\right)=\frac{x}{\sqrt{x^2+1}}``.

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
    Evaluate ``\lim_{x\to\infty}\frac{2x^2-x+3}{3x^2+5}``.

    Divide the numerator and the denominator by ``x^2``, the highest power of ``x`` appearing in the denominator:

    ```math
    \lim_{x\to\infty}\frac{2x^2-x+3}{3x^2+5}=\lim_{x\to\infty}\frac{2-\frac{1}{x}+\frac{3}{x^2}}{3+\frac{5}{x^2}}=\frac{2-0+0}{3+0}=\frac{2}{3}\,.
    ```

The technique used in the previous example can also be applied to more general kinds of functions.

!!! example
    Find ``\lim_{x\to\infty}\left(\sqrt{x^2+x}-x\right)``.

    We can rationalize the expression by multiplying the numerator and the denominator (which is ``1``) by the conjugate expression ``\sqrt{x^2+x}+x``.

    ```math
    \begin{aligned}
    \lim_{x\to\infty}\left(\sqrt{x^2+x}-x\right)=&\frac{\left(\sqrt{x^2+x}-x\right)\left(\sqrt{x^2+x}+x\right)}{\left(\sqrt{x^2+x}+x\right)}=\frac{x^2+x-x^2}{\left(\sqrt{x^2\left(1+\frac{1}{x}\right)}+x\right)}\\
    =&\frac{x}{\left(x\sqrt{1+\frac{1}{x}}+x\right)}=\frac{1}{\left(\sqrt{1+\frac{1}{x}}+1\right)}=\frac{1}{2}\,.
    \end{aligned}
    ```

### Infinite Limits

A function whose values grow arbitrarily large can sometimes said to have an infinite limite. Since infinity is not a number, infinite limits are not really limits at all, but they provide a way of describing the behaviour of functions that grow arbitrarily large positive of negative.

!!! example
    Describe the behaviour of the function ``f\left(x\right)=\frac{1}{x^2}`` near ``x=0``.

    


## Continuity Defined

## Continuous Functions

## The Intermediate Value Theorem

## The Extreme Value Theorem