{data-type="chapter"}
# Transcendental Functions

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

With the exception of the trigonometric functions, all the functions we have encountered so far have been of three main types: polynomials, rational functions (quotients of polynomials), and algebraic functions (fractional powers of rational functions). On an interval in its domain, each of these functions can be constructed from real numbers and a single real variable x by using finitely many arithmetic operations (addition, subtraction, multiplication, and division) and by taking finitely many roots (fractional powers). Functions that cannot be so constructed are called *transcendental functions*. The only examples of these that we have seen so far are the trigonometric functions.

This chapter is devoted to developing other transcendental functions, including *exponential* and *logarithmic functions* and the *inverse trigonometric functions*.

## Exponentials and Logarithms

### Exponentials

An *exponential function* is a function of the form ``f\left(x\right)=a^x``, where the *base* ``a`` is a positive constant and the *exponent* ``x`` is the variable. Do not confuse such functions with power functions such as ``f\left(x\right)=x^a``, where the base is variable and the exponent is constant. The exponential function ``a^x`` can be defined for integer and rational exponents ``x`` as follows:

!!! definition

	If ``a&gt;0``, then
	```math
	\begin{aligned}
	a^0&=1\\
	a^n&=\underbrace{a\cdot a\cdot a\cdot\cdot\cdot a}_{n\textrm{ factors}}\quad\textrm{if }n=1,2,3,\dots\\
	a^{-n}&=\frac{1}{a^n}\quad\textrm{if }n=1,2,3,\dots\\
	a^{\frac{m}{n}}&=\sqrt[n]{a^m}\quad\textrm{if }n=1,2,3,\dots\textrm{ and }m=\pm1,\pm2,\pm3,\dots
	\end{aligned}
	```
	In this definition, ``\sqrt[n]{a}`` is the number ``b&gt;0`` that satisfies ``b^n=a``.

How should we define ``a^x`` if ``x`` is not rational? For example, what does ``2^\uppi`` mean? In order to calculate a derivative of ``a^x``, we will want the function to be defined for all real numbers ``x``, not just rational ones.

{cell=chap display=false output=false}
```julia
Figure("", tex("y=2^x") *  " for rational " * tex("x") * "." ) do
	scale = 50
	Drawing(width=5scale, height=6scale) do
		xmid = 2.5scale
		ymid = 5.5scale
		axis_xy(5scale,6scale,xmid,ymid,scale,(-2,-1,1,2),(1, 2, 3, 4, 5))
		plot_xy(x->2^x, -3:0.01:3, tuple(0), xmid, ymid, scale; width=1, dashed="1, 2")
	end
end
```

In the previous figure we plot points with coordinates ``\left(x,2^x\right)`` for many closely spaced rational values of ``x``. They appear to lie on a smooth curve. The definition of ``a^x`` can be extended to irrational ``x`` in such a way that ``a^x`` becomes a differentiable function of ``x`` on the whole real line. We will do so in the next section. For the moment, if ``x`` is irrational we can regard ``a^x`` as being the limit of values ``a^r`` for rational numbers rapproaching ``x``.

Exponential functions satisfy several identities called *laws of exponents*:

!!! theorem

	If ``a&gt;0`` and ``b&gt;0``, and ``x`` and ``y`` are any real numbers, then
	```math
	\begin{aligned}
	&a^0=1&&a^{x+y}=a^xa^y\\
	&a^{-x}=\frac{1}{a^x}&&a^{x-y}=\frac{a^x}{a^y}\\
	&\left(a^x\right)^y=a^{xy}&&\left(ab\right)^x=a^xb^x
	\end{aligned}
	```

These identities can be proved for rational exponents using the definitions above. They remain true for irrational exponents, but we can’t show that until the next section.

{cell=chap display=false output=false}
```julia
Figure("", "Graphs of some exponential functions" * tex("y=a^x") * "." ) do
	scale = 50
	Drawing(width=5scale, height=6scale) do
		xmid = 2.5scale
		ymid = 5.5scale
		axis_xy(5scale,6scale,xmid,ymid,scale,(-2,-1,1,2),(1, 2, 3, 4, 5))
		plot_xy(x->0.1^x, -3:0.01:3, tuple(), xmid, ymid, scale; width=1, color="cyan")
		latex("a=\\frac{1}{10}", x=xmid-0.78scale, y=-0.02scale, width=3*font_x, height=2font_y, color="cyan")
		plot_xy(x->0.25^x, -3:0.01:3, tuple(), xmid, ymid, scale; width=1, color="RoyalBlue")
		latex("a=\\frac{1}{4}", x=xmid-1.8scale, y=scale, width=3*font_x, height=2font_y, color="RoyalBlue")
		plot_xy(x->0.5^x, -3:0.01:3, tuple(), xmid, ymid, scale; width=1, color="purple")
		latex("a=\\frac{1}{2}", x=xmid-2.5scale, y=2scale, width=3*font_x, height=2font_y, color="purple")
		plot_xy(x->1^x, -3:0.01:3, tuple(), xmid, ymid, scale; width=1, color="olive")
		latex("a=1", x=xmid+1.5scale, y=4.5scale, width=3*font_x, height=1font_y, color="olive")
		plot_xy(x->2^x, -3:0.01:3, tuple(), xmid, ymid, scale; width=1, color="green")
		latex("a=2", x=xmid+1.75scale, y=2scale, width=3*font_x, height=1font_y, color="green")
		plot_xy(x->4^x, -3:0.01:3, tuple(), xmid, ymid, scale; width=1, color="orange")
		latex("a=4", x=xmid+1scale, y=1.3scale, width=3*font_x, height=1font_y, color="orange")
		plot_xy(x->10^x, -3:0.01:3, tuple(), xmid, ymid, scale; width=1, color="red")
		latex("a=10", x=xmid-0.2scale, y=0.2scale, width=4*font_x, height=1font_y, color="red")
	end
end
```

The graphs of some typical exponential functions are shown in the previous figure. They all pass through the point ``\left(0,1\right)`` since ``a^0=1`` for every ``a&gt;0``. Observe that ``a^x&gt;0`` for all ``a&gt;0`` and all real ``x`` and that:

- If ``a&gt;1``, then ``\displaystyle\lim_{x\to -\infty}a^x = 0`` and ``\displaystyle\lim_{x\to \infty}a^x = \infty``.
- If ``0&lt;a&lt;1``, then ``\displaystyle\lim_{x\to -\infty}a^x = \infty`` and ``\displaystyle\lim_{x\to \infty}a^x = 0``.

### Logarithms

The function ``f\left(x\right)=a^x`` is a bijective function provided that ``a&gt;0`` and ``a\ne1``. Therefore, ``f`` has an inverse which we call a *logarithmic function*.

!!! definition

	If ``a&gt;0`` and ``a\ne 1``, the function ``\log_ax``,  called the logarithm of ``x`` to the base ``a``, is the inverse of the bijective function ``a^x``:
	```math
	\forall a&gt;0,a\ne1:x=a^y\implies y=\log_ax\,.
	```

Since ``a^x`` has domain ``\left]-\infty,\infty\right[``, ``\log_a x`` has range ``\left]-\infty,\infty\right[``. Since ``a^x`` has range ``\left]0,\infty\right[``, ``\log_a x`` has domain ``\left]0,\infty\right[``. Since ``a^x`` and ``\log_a x`` are inverse functions, the following cancellation identities hold:
```math
\log_a\left(a^x\right)=x\textrm{ for all real }x\quad\textrm{and}\quad a^{\log_a x}=x\textrm{ for all }x&gt;0\,.
```

{cell=chap display=false output=false}
```julia
Figure("", "Graphs of some logarithmic functions" * tex("y=\\log_a x") * "." ) do
	scale = 50
	Drawing(width=6scale, height=5scale) do
		xmid = 0.5scale
		ymid = 2.5scale
		axis_xy(6scale,5scale,xmid,ymid,scale,(1, 2, 3, 4, 5),(-2,-1,1,2))
		plot_xy(x->log(x)/log(0.1), 0.01:0.01:5.5, tuple(), xmid, ymid, scale; width=1, color="cyan")
		latex("a=\\frac{1}{10}", x=5scale, y=2.75scale, width=4*font_x, height=2font_y, color="cyan")
		plot_xy(x->log(x)/log(0.25), 0.01:0.01:5.5, tuple(), xmid, ymid, scale; width=1, color="RoyalBlue")
		latex("a=\\frac{1}{4}", x=5scale, y=3.25scale, width=4*font_x, height=2font_y, color="RoyalBlue")
		plot_xy(x->log(x)/log(0.5), 0.01:0.01:5.5, tuple(), xmid, ymid, scale; width=1, color="purple")
		latex("a=\\frac{1}{2}", x=5scale, y=4.4scale, width=4*font_x, height=2font_y, color="purple")
		plot_xy(x->log(x)/log(2), 0.01:0.01:5.5, tuple(), xmid, ymid, scale; width=1, color="green")
		latex("a=2", x=5scale, y=0.2scale, width=4*font_x, height=1font_y, color="green")
		plot_xy(x->log(x)/log(4), 0.01:0.01:5.5, tuple(), xmid, ymid, scale; width=1, color="orange")
		latex("a=4", x=5scale, y=1.3scale, width=4*font_x, height=1font_y, color="orange")
		plot_xy(x->log(x)/log(10), 0.01:0.01:5.5, tuple(), xmid, ymid, scale; width=1, color="red")
		latex("a=10", x=5scale, y=1.8scale, width=4*font_x, height=1font_y, color="red")
	end
end
```

The graphs of some typical logarithmic functions are shown in the previous figure. They all pass through the point ``\left(1, 0\right)``. Each graph is the reflection in the line ``y=x`` of the corresponding exponential graph.

From the laws of exponents we can derive the following laws of logarithms:

!!! theorem

	If ``x&gt;0``, ``y&gt;0``, ``a&gt;0``, ``b&gt;0``, ``a\ne 1`` and ``b\ne 1``, then
	```math
	\begin{aligned}
	&\log_a 1=0&&\log_a\left(xy\right)=\log_a x+\log_a y\\
	&\log_a\left(\frac{1}{x}\right)=-\log_a x&&\log_a\left(\frac{x}{y}\right)=\log_a x-\log_a y\\
	&\log_a\left(x^y\right)=ylog_a x&&\log_a x=\frac{\log_b x}{\log_b a}
	\end{aligned}
	```

Corresponding to the asymptotic behaviour of the exponential functions, the logarithmic functions also exhibit asymptotic behaviour. Their graphs are all asymptotic to the ``y``-axis as ``x\to0`` from the right:

- If ``a&gt;1``, then ``\displaystyle\lim_{x\to 0^+}\log_a x = -\infty`` and ``\displaystyle\lim_{x\to \infty}\log_a x = \infty``.
- If ``0&lt;a&lt;1``, then ``\displaystyle\lim_{x\to 0^+}\log_a x = \infty`` and ``\displaystyle\lim_{x\to \infty}\log_a x = -\infty``.

## The Natural Logarithm and the Exponential Function

In this section we are going to define a function ``\ln x``, called the natural logarithm of ``x``, in a way that does not at first seem to have anything to do with the logarithms considered in the previous section. We will show, however, that it has the same properties as those logarithms, and in the end we will see that ``\ln x=\log_\mathcal{e}``, the logarithm of ``x`` to a certain specific base ``\mathcal{e}``. We will show that ``\ln x`` is a bijective function, defined for all positive real numbers. It must therefore have an inverse, ``\mathcal{e}^x``, that we will call the exponential function. Our final goal is to arrive at a definition of the exponential functions ``a^x`` (for any ``a&gt;0``) that is valid for any real number ``x`` instead of just rational numbers, and that is known to be continuous and even differentiable without our having to assume those properties.

### The Natural Logarithm

We do not yet know a function whose derivative is ``x^{-1}=\frac{1}{x}``. We are going to remedy this situation by defining a function ``\ln x`` in such a way that it will have derivative ``\frac{1}{x}``.

To get a hint as to how this can be done, remember the relationship you have seen in high school between definite integral (area) and derivative. The definite integral between 2 points is the signed area between the 2 points bounded by the graph of the function and the ``x``-axis. We will call this the *Fundamental Theorem of Calculus*, which we will explore in the next chapter.

!!! definition

	For ``x&gt;0``, let ``A_x`` be the area of the plane region bounded by the curve ``y=\frac{1}{t}``, the ``t``-axis, and the vertical lines ``t=1`` and ``t=x``. The function ``\ln x`` is defined by
	```math
	\ln x=\begin{cases}
	\hphantom{-}A_x&\textrm{if }x\ge1\,,\\
	-A_x&\textrm{if }0&lt;x&lt;1\,,
	\end{cases}
	```
	as shown in the next figure.

	{cell=chap display=false output=false}
	```julia
	Figure("", "Definition of " * tex("\\ln x") * "." ) do
		scale = 50
		Drawing(width=12scale, height=5.5scale) do
			xmid = 0.5scale
			ymid = 5scale
			x = 0.25
			path = "$(xmid+x*scale), $ymid " * mapreduce(elem->"$(elem[1]), $(elem[2]) ", *, zip(xmid .+ ((x * scale):0.01scale:1scale), ymid .- scale ./ (x:0.01:1))) * "$(xmid+scale), $ymid"
			polygon(points=path, fill="lightblue", stroke="none")
			axis_xy(5.5scale,5.5scale,xmid,ymid,scale,(0.25, 1, ),(1,);symbol_x="t", xs=("x", 1))
			plot_xy(x->1/x, 0.01:0.01:5, tuple(1,), xmid, ymid, scale; width=1)
			latex("A_x", x=xmid+0.35scale, y=ymid-0.75scale, width=2font_x, height=1font_y)
			xmid = 7scale
			x = 4
			path = "$(xmid+scale), $ymid " * mapreduce(elem->"$(elem[1]), $(elem[2]) ", *, zip(xmid .+ (1scale:0.01scale:(x * scale)), ymid .- scale ./ (1:0.01:x))) * "$(xmid+x*scale), $ymid"
			polygon(points=path, fill="lightblue", stroke="none")
			axis_xy(5.5scale,5.5scale,xmid,ymid,scale,(1, 4),(1,);symbol_x="t", shift_x=6.5scale, xs=(1, "x"))
			plot_xy(x->1/x, 0.01:0.01:5, tuple(1,), xmid, ymid, scale; width=1)
			latex("A_x", x=xmid+2.25scale, y=ymid-0.35scale, width=2font_x, height=1font_y)
		end
	end
	```

The definition implies that ``\ln 1=0``, that ``\ln x&gt;0`` if ``x&gt;1``, that ``\ln x&lt;0`` if ``0&lt;x&lt;1``, and that ``\ln`` is a bijective function. We now show that if ``y=\ln x``, then ``y^\prime=\frac{1}{x}``.

!!! theorem

	If ``x&gt;0``, then
	```math
	\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}\ln x=\frac{1}{x}\,.
	```

!!! proof

	For ``x&gt;0`` and ``h&gt;0``, ``\ln\left(x+ h\right)-\ln(x)`` is the area of the plane region bounded by ``y=\frac{1}{t}``, ``y=0``, and the vertical lines ``t=x`` and ``t=x+h``; it is the shaded area in the next figure.

	{cell=chap display=false output=false}
	```julia
	Figure("", "Derivative of " * tex("\\ln x") * "." ) do
		scale = 50
		Drawing(width=5.5scale, height=5.5scale) do
			xmid = 0.5scale
			ymid = 5scale
			x = 0.5
			h = 0.75
			path = "$(xmid+x*scale), $ymid " * mapreduce(elem->"$(elem[1]), $(elem[2]) ", *, zip(xmid .+ (x*scale:0.01scale:(x+h)*scale), ymid .- scale ./ (x:0.01:x+h))) * "$(xmid+(x+h)*scale), $ymid"
			polygon(points=path, fill="lightblue", stroke="none")
			axis_xy(5.5scale,5.5scale,xmid,ymid,scale,(x, x+h), tuple(1/(x+h), 1/x); symbol_x="t", xs=("x", "x+h"), ys=("\\frac{1}{x+h}", "\\frac{1}{x}"), yl=(2, 1), yh=(2, 2))
			plot_xy(x->1/x, 0.01:0.01:5, tuple(x, x+h), xmid, ymid, scale; width=1)
			rect(x=xmid+x*scale, y=ymid-1/x*scale, width=h*scale, height=1/x*scale, fill="none", stroke="deepskyblue")
			rect(x=xmid+x*scale, y=ymid-1/(x+h)*scale, width=h*scale, height=1/(x+h)*scale, fill="none", stroke="deepskyblue")
		end
	end
	```

	Comparing this area with that of two rectangles, we see that
	```math
	\frac{h}{x+h}&lt;\textrm{shaded area}=\ln\left(x+h\right)-\ln x&lt;\frac{h}{x}\,.
	```

	Hence, the Newton quotient for ``\ln x`` satisfies
	```math
	\frac{1}{x+h}&lt;\frac{\ln\left(x+h\right)-\ln x}{h}&lt;\frac{1}{x}\,.
	```

	Letting ``h`` approach ``0`` from the right, we obtain (by the Squeeze Theorem applied to one-sided limits)
	```math
	\lim_{h\to0^+}\frac{\ln\left(x+h\right)-\ln x}{h}=\frac{1}{x}\,.
	```

	A similar argument shows that if ``0&lt;x+h&lt;x``, then
	```math
	\frac{1}{x}&lt;\frac{\ln\left(x+h\right)-\ln x}{h}&lt;\frac{1}{x+h}\,,
	```
	so that
	```math
	\lim_{h\to0^-}\frac{\ln\left(x+h\right)-\ln x}{h}=\frac{1}{x}\,.
	```

	Combining these two one-sided limits we get the desired result:
	```math
	\lim_{h\to0}\frac{\ln\left(x+h\right)-\ln x}{h}=\frac{1}{x}\,.
	```

The two properties ``\displaystyle \frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}\ln x=\frac{1}{x}`` and ``\ln 1=0`` are sufficient to determine the function ``\ln x`` completely. We can deduce from these two properties that ``\ln x`` satisfies the appropriate laws of logarithms:

!!! theorem

	```math
	\begin{aligned}
	&\ln\left(xy\right)=\ln x+\ln y&&\ln\left(\frac{1}{x}\right)=-\ln x\\
	&\ln\left(\frac{x}{y}\right)=\ln x-\ln y&&\ln\left(x^r\right)=r\ln x
	\end{aligned}
	```

	Because we do not want to assume that exponentials are continuous, we should regard the last property for the moment as only valid for exponents ``r`` that are rational numbers.

!!! proof

	We will only prove the first property because the other parts are proved by the same method. If ``y&gt;0`` is a constant, then by the Chain Rule,
	```math
	\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}\left(\ln\left(xy\right)-\ln x\right)=\frac{y}{xy}-\frac{1}{x}=0
	```
	for all ``x&gt;0``. So, ``\ln\left(xy\right)-\ln x=C`` (a constant). Putting ``x=1``, we get ``C=\ln y`` and the first property follows.

The last property shows that ``\ln\left(2^n\right)=n\ln 2\to\infty`` as ``n\to\infty``. Therefore, we also have ``\ln\left(\frac{1}{2}\right)^n=-n\ln 2\to-\infty`` as ``n\to\infty``. Since ``\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}\ln x=\frac{1}{x}&gt;0`` for ``x&gt;0``, it follows that ``\ln x`` is increasing, so we must have
```math
\lim_{x\to\infty}\ln x=\infty\quad\textrm{and}\quad \lim_{x\to-\infty}\ln x=-\infty\,.
```

!!! example

	Show that ``\displaystyle\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}\ln \left|x\right|=\frac{1}{x}`` for any ``x\ne 0``. Hence find ``\int\frac{1}{x}\, \mathrm{d} x``.

	If ``x&gt;0``, then
	```math
	\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}\ln \left|x\right|=\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}\ln x=\frac{1}{x}\,.
	```

	If ``x&lt;0``, then
	```math
	\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}\ln \left|x\right|=\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}\ln \left(-x\right)=\frac{1}{-x}\left(-1\right)=\frac{1}{x}\,.
	```

	Therefore, ``\displaystyle\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}\ln \left|x\right|=\frac{1}{x}``, and on any interval not containing ``x=0``,
	```math
	\int\frac{1}{x}\, \mathrm{d} x=\ln\left|x\right|+C\,.
	```

### The Exponential Function

The function ``\ln x`` is bijective on its domain, the interval ``\left]0,\infty\right[``, so it has an inverse there. For the moment, let us call this inverse ``\exp x``. Thus,
```math
\forall y&gt;0:x=\ln y\implies y=\exp x\,.
```

Since ``\ln 1=0``, we have ``\exp 0=1``. The domain of ``\exp`` is ``\left]-\infty,\infty\right[``, the range of ``\ln``. The range of ``\exp`` is ``\left]0,\infty\right[``, the domain of ``\ln``. We have cancellation identities
```math
\forall x\in \mathbb{R}:\ln\left(\exp x\right)=x\quad\textrm{and}\quad\forall x&gt;0:\exp\left(\ln x\right)=x\,.
```

We can deduce various properties of ``\exp`` from corresponding properties of ``\ln``. Not surprisingly, they are properties we would expect an exponential function to have.

!!! theorem

	```math
	\begin{aligned}
	&\left(\exp x\right)^r=\exp\left(rx\right)&&\exp\left(x+y\right)=\exp x\exp y\\
	&\exp\left(-x\right)=\frac{1}{\exp x}&&\exp\left(x-y\right)=\frac{\exp x}{\exp y}
	\end{aligned}
	```

	For the moment, the first property is asserted only for rational numbers ``r``.

!!! proof

	We prove only the first property, the rest are done similarly.

	If ``u=\left(\exp x\right)^r``, then, ``\ln u=r\ln\left(\exp x\right)=rx``. Therefore, ``u=\exp\left(rx\right)``.

Now we make an important definition!

!!! definition

	Let ``\mathcal{e}=\exp\left(1\right)``.

The number ``\mathcal{e}`` satisfies ``\ln \mathcal{e} = 1``, so the area bounded by the curve ``y=\frac{1}{t}``, the ``t``-axis, and the vertical lines ``t=1`` and ``t=\mathcal{e}`` must be equal to ``1`` square unit.

{cell=chap display=false output=false}
```julia
Figure("", "The definition of " * tex("\\mathcal{e}") * "." ) do
	scale = 50
	Drawing(width=5.5scale, height=5.5scale) do
		xmid = 0.5scale
		ymid = 5scale
		x = 1
		h = ℯ - 1
		path = "$(xmid+x*scale), $ymid " * mapreduce(elem->"$(elem[1]), $(elem[2]) ", *, zip(xmid .+ (x*scale:0.01scale:(x+h)*scale), ymid .- scale ./ (x:0.01:x+h))) * "$(xmid+(x+h)*scale), $ymid"
		polygon(points=path, fill="lightblue", stroke="none")
		axis_xy(5.5scale,5.5scale,xmid,ymid,scale,(x, x+h), tuple(1/(x+h), 1/x); symbol_x="t", xs=("1", "\\mathcal{e}"), ys=("\\frac{1}{\\mathcal{e}}", "1"), yl=(1, 1), yh=(2, 1))
		plot_xy(x->1/x, 0.01:0.01:5, tuple(x, x+h), xmid, ymid, scale; width=1)
		latex("\\textrm{Area}=1", x=xmid+1.25scale, y=ymid-0.35scale, width=4font_x, height=1font_y)
	end
end
```

The number ``\mathcal{e}`` is one of the most important numbers in mathematics. Like ``\uppi``, it is irrational and not a zero of any polynomial with rational coefficients. Its value is between 2 and 3 and begins

```math
\mathcal{e}=2.718281828459045\dots\,.
```

Later on we will learn that
```math
\mathcal{e}=1+\frac{1}{1!}+\frac{1}{2!}+\frac{1}{3!}+\frac{1}{4!}+\cdots\,,
```
a formula from which the value of ``\mathcal{e}`` can be calculated to any desired precision.

The first property of the previous theorem shows that ``\exp r=\exp\left(1r\right)=\left(\exp 1\right)^r=\mathcal{e}^r`` holds for any rational number ``r``. Now here is a crucial observation. We only know what ``\mathcal{e}^r`` means if ``r`` is a rational number (if ``r=\frac{m}{n}``, then ``\mathcal{e}^r=\sqrt[n]{\mathcal{e}^m}``). But ``\exp x`` is defined for all real ``x``, rational or not. Since ``\mathcal{e}^r=\exp r`` when ``r`` is rational, we can use ``\exp x`` as a definition of what ``\mathcal{e}^x`` means for any real number ``x``, and there will be no contradiction if ``x`` happens to be rational.

!!! definition

	Let
	```math
	\mathcal{e}^x=\exp x
	```
	for all real ``x``.

The last theorem can now be restated in terms of ``\mathcal{e}^x``:
```math
\begin{aligned}
&\left(\mathcal{e}^x\right)^y=\mathcal{e}^{xy}&&\mathcal{e}^{x+y}=\mathcal{e}^x\mathcal{e}^y\\
&\mathcal{e}^{-x}=\frac{1}{\mathcal{e}^x}&&\mathcal{e}^{x-y}=\frac{\mathcal{e}^x}{\mathcal{e}^y}
\end{aligned}
```

The graph of ``\mathcal{e}^x`` is the reflection of the graph of its inverse, ``\ln x``, in the line ``y=x``.

{cell=chap display=false output=false}
```julia
Figure("", "The graph of " * tex("\\mathcal{e}^x") * " and " * tex("\\ln x") * "." ) do
	scale = 50
	Drawing(width=5scale, height=5scale) do
		xmid = 2.5scale
		ymid = 2.5scale
		axis_xy(5scale,5scale,xmid,ymid,scale,(1,), tuple(1,))
		plot_xy(x->ℯ^x, -2.5:0.01:2.5, tuple(0,), xmid, ymid, scale; width=1)
		plot_xy(x->log(x), 0.01:0.01:2.5, tuple(1,), xmid, ymid, scale; width=1, color="RoyalBlue")
		plot_xy(x->x, -2.5:0.01:2.5, tuple(), xmid, ymid, scale; width=1, color="black", dashed="3")
	end
end
```

Observe that the ``x``-axis is a horizontal asymptote of the graph of ``y=\mathcal{e}^x`` as ``x\to-\infty``. We have
```math
\lim_{x\to-\infty}\mathcal{e}^x=0\quad\textrm{and}\quad\lim_{x\to\infty}\mathcal{e}^x=\infty\,.
```

Since ``\exp x=\mathcal{e}^x`` actually is an exponential function, its inverse must actually be a logarithm:
```math
\ln x=\log_\mathcal{e}x\,.
```

The derivative of ``y=\mathcal{e}^x`` is calculated by implicit differentiation:
```math
\begin{aligned}
y=\mathcal{e}^x&\implies x=\ln y\\
&\implies 1=\frac{1}{y}\frac{\mathrm{d} y}{\mathrm{d} x}\\
&\implies \frac{\mathrm{d} y}{\mathrm{d} x}=y=\mathcal{e}^x\,.
\end{aligned}
```

Thus, the exponential function has the remarkable property that it is its own derivative and, therefore, also its own antiderivative:
```math
\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}\mathcal{e}^x=\mathcal{e}^x\quad\textrm{and}\quad\int \mathcal{e}^x\, \mathrm{d} x=\mathcal{e}^x+C\,.
```

### General Exponentials and Logarithms

We can use the fact that ``\mathcal{e}^x`` is now defined for all real ``x`` to define the arbitrary exponential ``a^x`` (where ``a&gt;0``) for all real ``x``. If ``r`` is rational, then ``\ln\left(a^r\right)=r\ln a``; therefore, ``a^r=\mathcal{e}^{r\ln a}``. However, ``\mathcal{e}^{x\ln a}`` is defined for all real ``x``, so we can use it as a definition of ``a^x`` with no possibility of contradiction arising if ``x`` is rational.

!!! definition

	Let
	```math
	\forall x\in \mathbb{R},\forall a&gt;0:a^x=\mathcal{e}^{x\ln a}\,.
	```

The laws of exponents for ``a^x`` can now be obtained from those for ``\mathcal{e}^x``, as can the derivative:
```math
\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}a^x=\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}\mathcal{e}^{x\ln a}=\mathcal{e}^{x\ln a}\ln a=a^x\ln a\,.
```

We can also verify the General Power Rule for ``x^a``, where ``a`` is any real number, provided ``x&gt;0``:
```math
\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}x^a=\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}\mathcal{e}^{a\ln x}=\mathcal{e}^{a\ln x}\frac{a}{x}=\frac{ax^a}{x}=ax^{a-1}\,.
```

!!! example

	Find the critical point of ``y=x^x``.

	We can’t differentiate ``x^x`` by treating it as a power (like ``x^a``) because the exponent varies. We can’t treat it as an exponential (like ``a^x``) because the base varies. We can differentiate it if we first write it in terms of the exponential function, ``x^x=\mathcal{e}^{x\ln x}``, and then use the Chain Rule and the Product Rule:
	```math
	\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}x^x=\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}\mathcal{e}^{x\ln x}=\mathcal{e}^{x\ln x}\left(\ln x+x\frac{1}{x}\right)=x^x\left(1+\ln x\right)\,.
	```

	Now ``x^x`` is defined only for ``x&gt;0`` and is itself never ``0``. (Why?) Therefore, the critical point occurs where ``1+\ln x=0``; that is, ``\ln x=-1``, or ``x=\frac{1}{\mathcal{e}}``.

Finally, observe that ``\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}a^x=a^x\ln a`` is negative for all ``x`` if ``0&lt;a&lt;1`` and is positive for all ``x`` if ``a&gt;1``. Thus, ``a^x`` is bijective and has an inverse function, ``\log_a x``, provided ``a&gt;0`` and ``a\ne1``. If ``y=\log_a x``, then ``x=a^y`` and, differentiating implicitly with respect to ``x``, we get
```math
1=a^y\ln a\frac{\mathrm{d} y}{\mathrm{d} x}=x\ln a\frac{\mathrm{d} y}{\mathrm{d} x}\,.
```

Thus, the derivative of ``\log_a x`` is given by
```math
\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}\log_a x=\frac{1}{x\ln a}\,.
```

Since ``\log_a x`` can be expressed in terms of logarithms to any other base, say ``\mathcal{e}``,
```math
\log_a x=\frac{\ln x}{\ln a}\,,
```

we normally use only natural logarithms. Exceptions are found in chemistry, acoustics, and other sciences where “logarithmic scales” are used to measure quantities for which a one-unit increase in the measure corresponds to a tenfold increase in the quantity. Logarithms to base ``10`` are used in defining such scales. In computer science, where powers of ``2`` play a central role, logarithms to base ``2`` are often encountered.

### Logarithmic Differentiation

Suppose we want to differentiate a function of the form
```math
y=\left(f\left(x\right)\right)^{g\left(x\right)}\quad\textrm{for }f\left(x\right)&gt;0\,.
```

Since the variable appears in both the base and the exponent, neither the general power rule, ``\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}x^a=ax^{a-1}``, nor the exponential rule, ``\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}a^x=a^x\ln a`` can be directly applied. One method for finding the derivative of such a function is to express it in the form
```math
y=\mathcal{e}^{g\left(x\right)\ln f\left(x\right)}
```
and then differentiate, using the Product Rule to handle the exponent. This is the method used in previous example.

The derivative in the example can also be obtained by taking natural logarithms of both sides of the equation ``y=x^x`` and differentiating implicitly:
```math
\begin{aligned}
\ln y&=x\ln x\\
\frac{1}{y}\frac{\mathrm{d} y}{\mathrm{d} x}&=\ln x+\frac{x}{x}=1+\ln x\\
\frac{\mathrm{d} y}{\mathrm{d} x}&=y\left(1+\ln x\right)=x^x\left(1+\ln x\right)
\end{aligned}
```

This latter technique is called *logarithmic differentiation*.

Logarithmic differentiation is also useful for finding the derivatives of functions expressed as products and quotients of many factors. Taking logarithms reduces these products and quotients to sums and differences. This usually makes the calculation easier than it would be using the Product and Quotient Rules, especially if the derivative is to be evaluated at a specific point.

!!! example

	Find ``\displaystyle\left.\frac{\mathrm{d} u}{\mathrm{d} x}\right|_{x=1}`` if ``u=\sqrt{\left(x+1\right)\left(x^2+1\right)\left(x^3+1\right)}``.

	```math
	\begin{aligned}
	\ln u&=\frac{1}{2}\left(\ln\left(x+1\right)+\ln\left(x^2+1\right)+\ln\left(x^3+1\right)\right)\\
	\frac{1}{u}\frac{\mathrm{d} u}{\mathrm{d} x}&=\frac{1}{2}\left(\frac{1}{x+1}+\frac{2x}{x^2+1}+\frac{3x^2}{x^3+1}\right)\,.
	\end{aligned}
	```

	At ``x=1`` we have ``u=\sqrt 8=2\sqrt 2``. Hence
	```math
	\left.\frac{\mathrm{d} u}{\mathrm{d} x}\right|_{x=1}=\sqrt 2\left(\frac{1}{2}+1+\frac{3}{2}\right)=3\sqrt 2\,.
	```


## The Inverse Trigonometric Functions

The six trigonometric functions are periodic and, hence, not one-to-one. However, as we did with the function ``x^2``, we can restrict their domains in such a way that the restricted functions are one-to-one and invertible.

### The Inverse Sine (or Arcsine) Function

Let us define a function ``\operatorname{Sin} x`` (note the capital letter) to be ``\sin x``, restricted so that its domain is the interval ``\left[-\frac{\uppi}{2},\frac{\uppi}{2}\right]``:

!!! definition

	```math
	\operatorname{Sin}x=\sin x\quad\textrm{if }-\frac{\uppi}{2}\le x\le\frac{\uppi}{2}\,.
	```

Since its derivative ``\cos x`` is positive on the interval ``\left[-\frac{\uppi}{2},\frac{\uppi}{2}\right]``, the function ``\operatorname{Sin} x`` is
increasing on its domain, so it is a bijective function. It has domain ``\left[-\frac{\uppi}{2},\frac{\uppi}{2}\right]`` and range ``\left[-1,1\right]``.

{cell=chap display=false output=false}
```julia
Figure("", "The graph of " * tex("\\operatorname{Sin}x") * "." ) do
	scale = 50
	Drawing(width=10scale, height=3scale) do
		xmid = 5scale
		ymid = 1.5scale
		axis_xy(10scale,3scale,xmid,ymid,scale,(-pi/2,pi/2), (-1, 1); xs=("-\\frac{\\uppi}{2}", "\\frac{\\uppi}{2}"),xl=(2, 1), xh=(2, 2))
		plot_xy(x->sin(x), -5:0.01:5, tuple(), xmid, ymid, scale; width=1, color="RoyalBlue", dashed="3")
		plot_xy(x->sin(x), -pi/2:0.01:pi/2, (-pi/2, pi/2), xmid, ymid, scale; width=1)
	end
end
```

Being bijective, ``\operatorname{Sin}`` has an inverse function which is denoted ``\operatorname{Arcsin}`` (or, in some books and computer programs, by ``\operatorname{arcsin}``,  ``\operatorname{asin}``, or ``\operatorname{Sin}^{-1}``) and which is called the *inverse sine* or *arcsine function*.

!!! definition

	```math
	\forall y\in\left[-\frac{\uppi}{2},\frac{\uppi}{2}\right]: x=\sin y=\operatorname{Sin}y\implies y = \operatorname{Arcsin} x\,.
	```

{cell=chap display=false output=false}
```julia
Figure("", "The graph of " * tex("\\operatorname{Arcsin}x") * "." ) do
	scale = 50
	Drawing(width=3scale, height=4scale) do
		xmid = 1.5scale
		ymid = 2scale
		axis_xy(3scale,4scale,xmid,ymid,scale,(-1, 1),(-pi/2,pi/2); ys=("-\\frac{\\uppi}{2}", "\\frac{\\uppi}{2}"),yl=(2, 1), yh=(2, 2))
		plot_xy(x->asin(x), -1:0.01:1, tuple(-1, 1), xmid, ymid, scale; width=1)
	end
end
```

The graph of ``\operatorname{Arcsin}`` is the reflection of the graph of ``\operatorname{Sin}`` in the line ``y=x``. The domain of ``\operatorname{Arcsin}`` is ``\left[-1,1\right]``(the range of ``\operatorname{Sin}``), and the range of ``\operatorname{Arcsin}`` is ``\left[-\frac{\uppi}{2},\frac{\uppi}{2}\right]`` (the domain of ``\operatorname{Sin}``).

!!! example

	Simplify the expression ``\tan\left(\operatorname{Arcsin} x\right)``.

	We want the tangent of an angle whose sine is ``x``. Suppose first that ``0\le x&lt;1``. We draw a right triangle with one angle ``\theta``, and label the sides so that ``\theta = \operatorname{Arcsin} x``. The side opposite ``\theta`` is ``x``, and the hypotenuse is ``1``. The remaining side is ``\sqrt{1-x^2}``, and we have

	```math
	\tan\left(\operatorname{Arcsin} x\right)=\tan\theta=\frac{x}{\sqrt{1-x^2}}\,.
	```

	Because both sides of the above equation are odd functions of ``x``, the same result holds for ``0&gt; x&gt;-1``.

Now let us use implicit differentiation to find the derivative of the inverse sine function. If``y=\operatorname{Arcsin}x``, then ``x=\sin y`` and ``-\frac{\uppi}{2}\le y\le\frac{\uppi}{2}``. Differentiating with respect to ``x``, we obtain
```math
1=\cos y\frac{\mathrm{d} y}{\mathrm{d} x}\,.
```
Since ``-\frac{\uppi}{2}\le y\le\frac{\uppi}{2}``, we know that ``\cos y\ge 0``. Therefore,
```math
\cos y=\sqrt{1-\sin^2 y}=1-x^2 \quad\textrm{and}\quad\frac{\mathrm{d} y}{\mathrm{d} x}=\frac{1}{\cos y}=\frac{1}{\sqrt{1-x^2}}\,;
```

Note that the inverse sine function is differentiable only on the open interval ``\left]-1,1\right[``; the slope of its graph approaches infinity as ``x\to -1^+`` or as ``x\to 1^-``.

!!! example

	Let ``f\left(x\right)=\operatorname{Arcsin}\left(\sin x\right)`` for all real numbers ``x``.

	1. Calculate and simplify ``f^\prime\left(x\right)``.

	   Using the Chain Rule and the Pythagorean identity we calculate

	   ```math
	   \begin{aligned}
	   f^\prime\left(x\right)&=\frac{1}{\sqrt{1-\sin^2 x}}\cos x\\
	   &=\frac{\cos x}{\sqrt{cos^2 x}}=\frac{\cos x}{\left|\cos x\right|}=\begin{cases}
       \hphantom{-}1&\textrm{if }\cos x&gt; 0\\
	   -1&\textrm{if }\cos x&lt; 0\,.
	   \end{cases}
	   \end{aligned}
	   ```
	2. Where is ``f`` differentiable? Where is ``f`` continuous?

	   ``f`` is differentiable at all points where ``\cos x\ne0``, that is, everywhere except at odd multiples of ``\frac{\uppi}{2}``.
       Since ``\sin`` is continuous everywhere and has values in ``\left[-1,1\right]``, and since ``\operatorname{Arcsin}`` is continuous on``\left[-1,1\right]``, we have that ``f`` is continuous on the whole real line.

	3. Use the previous results to sketch the graph of ``f``.

       Since ``f`` is continuous, its graph has no breaks. The graph consists of straight line segments of slopes alternating between ``1`` and ``-1`` on intervals between consecutive odd multiples of ``\frac{\uppi}{2}``. Since ``f^\prime\left(x\right)=1`` on the interval ``\left]-1,1\right[``, the graph must be as shown below

	   {cell=chap display=false output=false}
	   ```julia
	   Figure("", "The graph of " * tex("\\operatorname{Arcsin}\\left(\\sin x\\right)") * "." ) do
			scale = 40
			Drawing(width=14scale, height=4scale) do
				xmid = 7scale
				ymid = 2scale
				axis_xy(14scale,4scale,xmid,ymid,scale,(-pi/2,pi/2), (-pi/2,pi/2); xs=("-\\frac{\\uppi}{2}", "\\frac{\\uppi}{2}"),xl=(2, 1), xh=(2, 2), ys=("-\\frac{\\uppi}{2}", "\\frac{\\uppi}{2}"), yl=(2, 1), yh=(2, 2))
				plot_xy(x->asin(sin(x)), -7:0.01:7, (-pi/2, pi/2), xmid, ymid, scale; width=1)
			end
	   end
	   ```

### Other Inverse Trigonometric Functions

The inverse tangent function is defined in a manner similar to the inverse sine. We begin by restricting the tangent function to an interval where it is bijective.

!!! definition

	```math
	\operatorname{Tan}x=\tan x\quad\textrm{if }-\frac{\uppi}{2}\le x\le\frac{\uppi}{2}\,.
	```

The inverse of the function ``\operatorname{Tan}`` is called the inverse tangent function and is denoted ``\operatorname{Arctan}`` (or ``\operatorname{arctan}``,  ``\operatorname{atan}``, or ``\operatorname{Tan}^{-1}``). The domain of ``\operatorname{Arctan}`` is the whole real line (the range of ``\operatorname{Tan}``). Its range is the open interval ``\left]-\frac{\uppi}{2},\frac{\uppi}{2}\right[``.

!!! definition

	```math
	\forall y\in\left]-\frac{\uppi}{2},\frac{\uppi}{2}\right[: x=\tan y=\operatorname{Tan}y\implies y = \operatorname{Arctan} x\,.
	```

The derivative of the inverse tangent function is also found by implicit differentiation: if ``y=\operatorname{Arctan}x``, then ``x=\operatorname{Tan}y`` and
```math
1 = \sec^2y\frac{\mathrm{d} y}{\mathrm{d} x}=\left(1+\tan^2 y\right)\frac{\mathrm{d} y}{\mathrm{d} x}=\left(1+x^2\right)\frac{\mathrm{d} y}{\mathrm{d} x}\,.
```

The function ``\cos x`` is bijective on the interval ``\left[0,\uppi\right]``, so we could define the inverse cosine function, ``\operatorname{Arccos}`` (or ``\operatorname{arccos}``,  ``\operatorname{acos}``, or ``\operatorname{Cos}^{-1}``), so that

```math
\forall y\in\left[0,\uppi\right]:x=\cos y\implies y=\operatorname{Arccos} x\,.
```

However, ``\cos y=\sin\left(\frac{\uppi}{2}-y\right)``, and ``\frac{\uppi}{2}-y`` is in the interval ``\left[-\frac{\uppi}{2},\frac{\uppi}{2}\right]`` when ``y\in\left[0,\uppi\right]``.

!!! definition

	```math
	\operatorname{Arccos}x=\frac{\uppi}{2}-\operatorname{Arcsin}x\quad\textrm{for }-1\le x\le 1
	```

The derivative of ``\operatorname{Arccos}x`` is the negative of that of ``\operatorname{Arcsin}x``.

## Hyperbolic Functions

!!! definition

	For any real ``x`` the hyperbolic cosine, ``\cosh x``, and the hyperbolic sine, ``\sinh x``, are defined by

	```math
	\cosh x=\frac{\mathcal{e}^x+\mathcal{e}^{-x}}{2}\quad\textrm{and}\quad\sinh x=\frac{\mathcal{e}^x-\mathcal{e}^{-x}}{2}\,.
	```

Recall that cosine and sine are called circular functions because, for any ``t``, the point ``\left(\cos t, \sin t\right)`` lies on the circle with equation ``x^2+y^2=1``. Similarly, ``\cosh`` and ``\sinh`` are called hyperbolic functions because the point ``\left(\cosh t, \sinh t\right)`` lies on the rectangular hyperbola with equations ``x^2-y^2=1``,
```math
\cosh^2 t-\sinh^2 t=1\quad \textrm{for any real }t\,.
```

There is no interpretation of ``t`` as an arc length or angle as there was in the circular case; however, the area of the hyperbolic sector bounded by ``y=0``, the hyperbola ``x^2-y^2=1``, and the ray from the origin to ``\left(\cosh t, \sinh t\right)`` is ``\frac{t}{2}`` square units, just as is the area of the circular sector bounded by ``y=0``, the circle ``x^2+y^2=1``, and the ray from the origin to ``\left(\cos t, \sin t\right)``.

{cell=chap display=false output=false}
```julia
Figure("", "The shaded area is " * tex("\\frac{t}{2}") * " square units." ) do
	scale = 40
	Drawing(width=6scale, height=6scale) do
		xmid = 3scale
		ymid = 3scale
		path = "$xmid, $ymid $(xmid+2scale), $ymid " * mapreduce(elem->"$(elem[1]), $(elem[2]) ", *, zip(xmid .+ (1scale:0.01scale:2scale), ymid .- scale.* sqrt.((1:0.01:2).^2 .- 1)))
		polygon(points=path, fill="lightblue", stroke="none")
		axis_xy(6scale,6scale,xmid,ymid,scale,(2,),(sqrt(3),); xs=("\\cosh t", ), xl=(3,), ys=("\\sinh t", ), yl=(3,))
		plot_xy(x->sqrt(x^2-1), -3:0.01:-1, tuple(), xmid, ymid, scale; width=1)
		plot_xy(x->-sqrt(x^2-1), -3:0.01:-1, tuple(), xmid, ymid, scale; width=1)
		plot_xy(x->sqrt(x^2-1), 1:0.01:3, tuple(), xmid, ymid, scale; width=1)
		plot_xy(x->-sqrt(x^2-1), 1:0.01:3, tuple(), xmid, ymid, scale; width=1)
		plot_xy(x->sqrt(3)/2*x, 0:0.01:2, tuple(2), xmid, ymid, scale; width=1, color="RoyalBlue")
	end
end
```

Observe that, similar to the corresponding values of ``\cos x`` and ``\sin x``, we have
```math
\cosh 0 = 1\quad\textrm{and}\quad\sinh 0 = 0\,,
```
and ``\cosh x``, like ``\cos x``, is an even function, and ``\sinh x``, like ``\sin x``, is an odd function:
```math
\cosh\left(-x\right)=\cosh x\quad\textrm{and}\quad\sinh\left(-x\right)=-\sinh x\,.
```

The graph ``y=\cosh x`` is called a *catenary*. A chain hanging by its ends will assume the shape of a catenary.

{cell=chap display=false output=false}
```julia
Figure("", "The graphs of " * tex("\\cosh x") * " (red) and " * tex("\\sinh x") * " (blue)." ) do
	scale = 40
	Drawing(width=6scale, height=6scale) do
		xmid = 3scale
		ymid = 3scale
		axis_xy(6scale,6scale,xmid,ymid,scale,tuple(),tuple(1,))
		plot_xy(x->cosh(x), -3:0.01:3, tuple(), xmid, ymid, scale; width=1)
		plot_xy(x->sinh(x), -3:0.01:3, tuple(2), xmid, ymid, scale; width=1, color="RoyalBlue")
	end
end
```

Many other properties of the hyperbolic functions resemble those of the corresponding circular functions, sometimes with signs changed.

!!! example

	Show that

	```math
	\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}\cosh x=\sinh x\quad\textrm{and}\quad\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}\sinh x=\cosh x
	```

	We have

	```math
	\begin{aligned}
	\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}\cosh x&=\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}\frac{\mathcal{e}^x+\mathcal{e}^{-x}}{2}=\frac{\mathcal{e}^x+\mathcal{e}^{-x}\left(-1\right)}{2}=\sinh x\\
	\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}\sin x&=\frac{\mathrm{d} \hphantom{x}}{\mathrm{d} x}\frac{\mathcal{e}^x-\mathcal{e}^{-x}}{2}=\frac{\mathcal{e}^x-\mathcal{e}^{-x}\left(-1\right)}{2}=\cosh x\,.
	\end{aligned}
	```

The following addition formulas and double-angle formulas can be checked algebraically by using the definition of ``\cosh`` and ``\sinh`` and the laws of exponents:
```math
\begin{aligned}
\cosh\left(x+y\right)&=\cosh x\cosh y+\sinh x\sinh y\,,\\
\sinh\left(x+y\right)&=\sinh x\cosh y+\cosh x\sinh y\,,\\
\cosh\left(2x\right)&=\cosh^2x+\sinh^2x=1+2\sinh^2x=2\cosh^2x-1\,,\\
\cosh\left(2x\right)&=2\sinh x\cosh x\,.
\end{aligned}
```

By analogy with the trigonometric functions, other hyperbolic functions can be defined in terms of ``\cosh`` and ``\sinh``.

!!! definition

	```math
	\tanh x=\frac{\sinh x}{\cosh x}=\frac{\mathcal{e}^x-\mathcal{e}^{-x}}{\mathcal{e}^x+\mathcal{e}^{-x}}=\frac{1-\mathcal{e}^{-2x}}{1+\mathcal{e}^{-2x}}=\frac{\mathcal{e}^{2x}-1}{\mathcal{e}^{2x}+1}\,.
	```

{cell=chap display=false output=false}
```julia
Figure("", "The graphs of " * tex("\\tanh x") * "." ) do
	scale = 40
	Drawing(width=12scale, height=3scale) do
		xmid = 6scale
		ymid = 1.5scale
		axis_xy(12scale,3scale,xmid,ymid,scale,tuple(),tuple(-1, 1))
		plot_xy(x->tanh(x), -6:0.01:6, tuple(), xmid, ymid, scale; width=1)
	end
end
```

The functions ``sinh`` and ``tanh`` are increasing and therefore bijective and invertible on the whole real line. Their inverses are denoted ``\operatorname{arcsinh}`` and ``\operatorname{arctanh}``, respectively.

Since the hyperbolic functions are defined in terms of exponentials, it is not surprising that their inverses can be expressed in terms of logarithms.

!!! example

	Express the functions ``\operatorname{arcsinh}`` and ``\operatorname{arctanh}`` in terms of natural logarithms.

	Let ``y=\operatorname{arcsinh} x``. Then
	```math
	x = \sinh y=\frac{\mathcal{e}^y-\mathcal{e}^{-y}}{2}=\frac{\mathcal{e}^{2y}-1}{2\mathcal{e}^{2y}}\,.
	```
	Therefore,
	```math
	\left(\mathcal{e}^y\right)^2-2x\mathcal{e}^y-1=0\,.
	```
	This is a quadratic equation in ``\mathcal{e}^y``, and it can be solved by the quadratic formula:
	```math
	\mathcal{e}^y=\frac{2x\pm\sqrt{4x^2+4}}{2}=x\pm\sqrt{x^2+1}\,.
	```
	Note that ``\sqrt{x^2+1}&gt;x``. Since ``\mathcal{e}^y`` cannot be negative, we need to use the positive sign:
	```math
	\mathcal{e}^y=x+\sqrt{x^2+1}\,.
	```
	Hence, ``y=\ln\left(x+\sqrt{x^2+1}\right)``, and we have
	```math
	\operatorname{arcsinh} x=\ln\left(x+\sqrt{x^2+1}\right)\,.
	```

	Now let ``y=\operatorname{arctanh} x``. Then
	```math
	x=\tanh y=\frac{\mathcal{e}^y-\mathcal{e}^{-y}}{\mathcal{e}^y+\mathcal{e}^{-y}}=\frac{\mathcal{e}^{2y}-1}{\mathcal{e}^{2y}+1}\quad\textrm{for }-1&lt;x&lt;1
	```
	or
	```math
	\mathcal{e}^{2y}=\frac{1+x}{1-x}.
	```
	Thus,
	```math
	\operatorname{arctanh} x=\frac{1}{2}\ln\left(\frac{1+x}{1-x}\right)\quad\textrm{for }-1&lt;x&lt;1\,.
	```

Since ``\cosh`` is not bijective, its domain must be restricted before an inverse can be defined. Let us define the principal value of ``\cosh`` to be
```math
\forall x\ge0:\operatorname{Cosh} x = \cosh x\,.
```

The inverse, ``\operatorname{Arccosh} x``, is then defined by
```math
\forall y\ge0:x=\cosh y=\operatorname{Cosh}y\implies y=\operatorname{Arccosh} x\,.
```

As we did for ``\operatorname{arcsinh}``, we can obtain the formula
```math
\operatorname{Arccosh} x=\ln\left(x+\sqrt{x^2-1}\right)
```

!!! exercise

	Find the derivatives of the inverse hyperbolic functions.