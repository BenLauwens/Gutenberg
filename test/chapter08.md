{data-type="chapter"}
# Sequences, Infinite Series and Power Series

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

An infinite series is a sum that involves infinitely many terms. Since addition is carried out on two numbers at a time, the evaluation of the sum of an infinite series necessarily involves finding a limit.

## Sequences and Convergence

By a *sequence* (or an infinite sequence) we mean an ordered list having a first element but no last element. For our purposes, the elements (called *terms*) of a sequence will always be real numbers, although much of our discussion could be applied to complex numbers as well. Examples of sequences are:

```math
\begin{aligned}
\left(a_n\right)=&\left(0, 1, 2, 3, 4, 5, 6, 7\dots \right)\\
\left(b_n\right)=&\left(1, -\frac{1}{2}, \frac{1}{4}, -\frac{1}{8}, \frac{1}{16}, -\frac{1}{32}, \frac{1}{64},\dots \right)\\
\left(c_n\right)=&\left(0, 1, 1, 2, 3, 5, 8, 13, \dots \right)
\end{aligned}
```

The terms of a sequence are usually listed in parentheses as shown. The ellipsis points ``\dots`` should be read “and so on.”

An infinite sequence is a special kind of function, one whose domain is a set of integers extending from some starting integer to infinity. The starting integer is usually ``0`` or ``1``, so the domain is the set of positive integers. The sequence ``\left(a_0, a_1, a_2, a_3, \dots\right)`` is the function ``f`` that takes the value ``f\left(n\right)=a_n`` an at each positive integer ``n``. A sequence can be specified in three ways:

1. We can list the first few terms followed by ``\dots`` if the pattern is obvious.
2. We can provide a formula for the general term ``a_n`` as a function of ``n``.
3. We can provide a formula for calculating the term an as a function of earlier terms ``a_1,a_2,\dots,a_{n-1}`` and specify enough of the beginning terms so the process of computing higher terms can begin.

In each case it must be possible to determine any term of the sequence, although it may be necessary to calculate all the preceding terms first.

!!! example

	```math
	\begin{aligned}
	a_n &= n\\
	b_n &= \left(-\frac{1}{2}\right)^n\\
	c_n &= c_{n-2} + c_{n-1}\textrm{ with }c_0 = 0\textrm{ and }c_1=1\,.
	\end{aligned}
	```

In the last example we say the sequence ``c_n`` is defined *recursively* or *inductively*; each term must be calculated from previousones rather than directly as a function of ``n``. 

We now introduce terminology used to describe various properties of sequences.

!!! definition

	- The sequence ``\left(a_n\right)`` is *bounded below* by ``L``, and ``L`` is a *lower bound* for ``\left(a_n\right)``, if ``a_n\ge L`` for every ``n\in\mathbb N``. The sequence is *bounded above* by ``M`` and ``M`` is an upper bound, if ``a_n\le M`` for every ``n\in\mathbb N``.

	  The sequence ``\left(a_n\right)`` is *bounded* if it is both bounded above and bounded below. In this case there is a constant ``K`` such that ``\left|a_n\right|\le K`` for every ``n\in\mathbb N``.
	  
	- The sequence ``\left(a_n\right)`` is *positive* if it is bounded below by zero, that is, if ``a_n\ge 0`` for every ``n\in\mathbb N``; it is *negative* if ``a_n\le 0 `` for every ``n\in\mathbb N``.

	- The sequence ``\left(a_n\right)`` is *increasing* if ``a_{n+1}\ge a_n`` for every ``n\in\mathbb N``; it is *decreasing* if ``a_{n+1}\le a_n`` for every ``n\in\mathbb N``. The sequence is said to be *monotonic* if it is either increasing or decreasing.

	- The sequence ``\left(a_n\right)`` is *alternating* if ``a_na_{n+1}&lt;0`` for every ``n\in\mathbb N``, that is, if any two consecutive terms have opposite signs. Note that this definition requires ``a_n\ne0`` for every ``n\in\mathbb N``.

When you want to show that a sequence is increasing, you can try to show that the inequality ``a_{n+1}-a_n \ge 0`` holds for every ``n\in\mathbb N``. Alternatively, if  ``a_n=f\left(n\right)`` for a differentiable function ``f\left(x\right)`` you can show that ``f`` is a nondecreasing function on ``\left[0,\infty\right[`` by showing that ``f^\prime\left(x\right)\ge0`` there. Similar approaches are useful for showing that a sequence is decreasing.

The adverb *ultimately* is used to describe any termwise property of a sequence that the terms have from some point on, but not necessarily at the beginning of the sequence.

Central to the study of sequences is the notion of convergence. The concept of the limit of a sequence is a special case of the concept of the limit of a function ``f\left(x\right)`` as ``x\to\infty``.

!!! definition

	We say that sequence ``\left(a_n\right)`` converges to the limit ``L``, and we write ``\lim_{n\to\infty} a_n= L``, if for every positive real number ``\varepsilon`` there exists an integer ``N`` (which may depend on ``\varepsilon``) such that if ``n\ge N``, then ``\left|a_n-L\right|\le\varepsilon``.

!!! example

	Show that ``\lim_{n\to\infty} \frac{c}{n^p}= 0`` or any real number ``c`` and any ``p&gt;0``.

	Let ``\varepsilon&gt;0``be given. Then

	```math
	\left|\frac{c}{n^p}\right|&lt;\varepsilon\quad\textrm{if}\quad n^p\&gt;\frac{\left|c\right|}{\varepsilon}\,,
	```

	that is, if ``n\ge N``, the least integer greater than ``\left(\frac{\left|c\right|}{\varepsilon}\right)^\frac{1}{p}``.

	Therefore, ``\lim_{n\to\infty} \frac{c}{n^p}= 0``.

Every sequence ``\left(a_n\right)`` must either *converge* to a finite limit ``L`` or *diverge*. That is, either ``\lim_{n\to\infty} a_n= L`` exists (is a real number) or ``\lim_{n\to\infty} a_n`` does not exist. If ``\lim_{n\to\infty} a_n=\infty``, we can say that the sequence diverges to ``\infty``; if ``\lim_{n\to\infty} a_n=-\infty``, we can say that it diverges to ``-\infty``. If ``\lim_{n\to\infty} a_n= L`` simply does not exist (but is not ``\infty`` or ``-\infty``), we can only say that the sequence diverges.

The limit of a sequence is equivalent to the limit of a function as its argument approaches infinity:

If ``\displaystyle\lim_{x\to\infty}f\left(x\right)=L`` and ``a_n=f\left(n\right)``, then ``\displaystyle\lim_{n\to\infty}a_n=L``.

Because of this, the standard rules for limits of functions also hold for limits of sequences, with the appropriate changes of notation.

!!! theorem

	If ``\left(a_n\right)`` and ``\left(b_n\right)`` converge, then

	- ``\displaystyle \lim_{n\to\infty}\left(a_n\pm b_n\right)=\lim_{n\to\infty}a_n\pm\lim_{n\to\infty}b_n\,,``

	- ``\displaystyle \lim_{n\to\infty}ca_n=c\lim_{n\to\infty}a_n\,,``

	- ``\displaystyle \lim_{n\to\infty}a_nb_n=\left(\lim_{n\to\infty}a_n\right)\left(\lim_{n\to\infty}b_n\right)\,,``

	- ``\displaystyle \lim_{n\to\infty}\frac{a_n}{b_n}=\frac{\displaystyle\lim_{n\to\infty}a_n}{\displaystyle\lim_{n\to\infty}b_n}\quad\textrm{assuming }\lim_{n\to\infty}b_n\ne 0\,.``

	If ``a_n\le b_n`` ultimately, then ``\displaystyle \lim_{n\to\infty}a_n\le \lim_{n\to\infty}b_n``.

	If ``a_n\le c_n\le b_n`` ultimately, and ``\displaystyle \lim_{n\to\infty}a_n=L=\lim_{n\to\infty}b_n``, then ``\displaystyle \lim_{n\to\infty}c_n=L``.

The limits of many explicitly defined sequences can be evaluated using these properties in a manner similar to the methods used for limits of the form ``\lim_{x\to\infty}f\left(x\right)``.

!!! example

	Calculate the limits of the sequences

	```math
	1.\ \left(\frac{2n^2-n-1}{5n^2+n-3}\right)\quad 2.\ \left(\frac{\cos n}{n}\right)\quad 3.\ \sqrt{n^2+2n}-n\,.
	```

	1. ``\displaystyle \lim_{n\to\infty}\frac{2n^2-n-1}{5n^2+n-3}=\lim_{n\to\infty}\frac{2-\frac{1}{n}-\frac{1}{n^2}}{5+\frac{1}{n}-\frac{3}{n^2}}=\frac{2}{5}\,.``

	2. Since ``\left|\cos n\right|\le 1`` for ``n\in\mathbb N``, we have

	   ```math
	   -\frac{1}{n}\le\frac{\cos n}{n}\le\frac{1}{n}\quad\textrm{for }n\ge 1\,.
	   ```

	   Now, ``\lim_{n\to\infty}-\frac{1}{n}=0=\lim_{n\to\infty}\frac{1}{n}``. Therefore, ``\lim_{n\to\infty}-\frac{\cos n}{n}=0``.

	3. 
	
	   ```math
	   \begin{aligned}
	   \lim_{n\to\infty}\left(\sqrt{n^2+2n}-n\right)&=\lim_{n\to\infty}\frac{\left(\sqrt{n^2+2n}-n\right)\left(\sqrt{n^2+2n}+n\right)}{\sqrt{n^2+2n}+n}\\
	   &=\lim_{n\to\infty}\frac{2n}{\sqrt{n^2+2n}+n}=\lim_{n\to\infty}\frac{2}{\sqrt{1+\frac{2}{n}}+1}=1\,.
	   \end{aligned}
	   ```

!!! theorem

	If ``\left(a_n\right)`` converges, then ``\left(a_n\right)`` is bounded.

!!! proof

	Let ``\lim_{n\to\infty}a_n=L``.

	For ``\varepsilon = 1``there exists a number ``N`` such that if ``n&gt; N``, then ``\left|a_n-L\right|&lt1``; therefore ``\left|a_n\right|&lt;1+\left| L\right|`` for such ``n``.

	If ``K`` denotes the largest of the numbers ``\left|a_0\right|,\left|a_1\right|, \dots, \left|a_N\right|``, and ``1+\left| L\right|``, then ``\left|a_n\right|\le K`` for every ``n\in\mathbb N``. 
	
	Hence, ``\left(a_n\right)`` is bounded.

The converse of this theorem is false; the sequence ``\left(\left(-1\right)^n\right)`` is bounded but does not converge.

The *completeness property* of the real number system can be reformulated in terms of sequences to read as follows:

!!! theorem

	If the sequence ``\left(a_n\right)`` is bounded above and is (ultimately) increasing, then it converges. The same conclusion holds if a``\left(a_n\right)`` is bounded below and is (ultimately) decreasing.

!!! example

	Let ``\left(a_n\right)`` be defined recursively by

	```math
	a_n=\begin{cases}
	1&\textrm{if }n=0\\
	\sqrt{6+a_{n-1}}&\textrm{if }n\ge 1\,.
	\end{cases}
	```

	Show that ``\lim_{n\to\infty}a_n`` exists and find its value.

	Observe that ``a_1=\sqrt 7\&gt;a_0``. If ``a_{k+1}&gt;a_k``, then we have ``a_{k+2}=\sqrt{6+a_{k+1}}&gt;\sqrt{6+a_k}=_{k+1}``, so ``\left(a_n\right)`` is increasing, by induction.

	Observe also that ``a_0=1&lt;3``. If ``a_k&lt;3``, then ``a_{k+1}=\sqrt{6+a_k}&lt;\sqrt{6+3}=3``, si ``a_n&lt; 3`` for every ``n`` by induction.

	Since ``\left(a_n\right)`` is increasing and bounded above, ``\lim_{n\to\infty}a_n=a`` exists, by completeness.

	Since ``\sqrt{6+x}`` is a continuous function of ``x``, we have

	```math
	a=\lim_{n\to\infty}a_{n+1}=\lim_{n\to\infty}\sqrt{6+a_{n}}=\sqrt{6+\lim_{n\to\infty}a_n}=\sqrt{6+a}\,.
	```

	Thus, ``a^2=6+a``, or ``a^2-a-6=0``, or ``\left(a-3\right)\left(a+2\right)=0``. This quadratic has roots ``a=3`` and ``a=-2``. Since ``a_n\ge 1`` for every ``n``, we must have ``a\ge1``. Therefore, ``a=3`` and ``\lim_{n\to\infty}a_n=3``.

## Infinite Series

### Definitions

An *infinite series*, usually just called a *series*, is a formal sum of infinitely many terms; for instance, ``a_0+a_1+a_2+a_3+\cdots`` is a series formed by adding the terms of the sequence ``\left(a_n\right)``. This series is also denoted ``\sum_{n=0}^\infty a_n``:

```math
\sum_{n=0}^\infty a_n=a_0+a_1+a_2+a_3+\cdots
```

The interpretation we place on the infinite sum is that of adding from left to right, as suggested by the grouping

```math
\cdots\left(\left(\left(\left(a_0+a_1\right)+a_2\right)+a_3\right)+a_4\right)+\cdots\,.
```

We accomplish this by defining a new sequence ``\left(s_n\right)``, called the *sequence of partial sums* of the series ``\sum_{n=0}^\infty a_n``, so that ``s_n`` is the sum of the first ``n`` terms of the series:

```math
s_n=\sum_{i=0}^na_i\,.
```

We then define the sum of the infinite series to be the limit of this sequence of partial sums.

!!! definition

	We say that the series ``\sum_{n=0}^\infty a_n`` converges to the sum ``s``, and we write

	```math
	\sum_{n=0}^\infty a_n=s\,,
	```

	if ``\lim_{n\to\infty}s_n=s``, where ``s_n`` is the ``n``th partial sum of ``\sum_{n=0}^\infty a_n``.

Thus, a series converges if and only if the sequence of its partial sums converges. Similarly, a series is said to diverge to infinity, diverge to negative infinity, or simply diverge if its sequence of partial sums does so.

### Geometric Series

!!! definition

	A series of the form ``\sum_{n=0}^\infty ar^n=a+ar+ar^2+ar^3+\cdots``, whose ``n``th term is ``a_n=ar^n``, is called a *geometric series*. The number ``a`` is the first term. The number ``r`` is called the common ratio of the series, since it is the value of the ratio of the ``\left(n+1\right)``th term to the ``n``th term for any ``n\in\mathbb N``:

	```math
	\frac{a_{n+1}}{a_n}=\frac{ar^{n+1}}{ar^n}=r\,.
	```

The ``n``th partial sum ``s_n`` of a geometric series is calculated as follows:

```math
\begin{aligned}
s_n&=a+ar+ar^2+ar^3+\cdots+ar^n\\
rs_n&=\hphantom{a+}ar+ar^2+ar^3+\cdots+ar^n+ar^{n+1}
\end{aligned}
```

The second equation is obtained by multiplying the first by ``r``. Subtracting these two equations (note the cancellations), we get ``\left(1-r\right)s_n=a-ar^{n+1}``. If ``r\ne1``, we can divide by ``1-r`` and get a formula for ``s_n``.

!!! theorem

	The ``n``th partial sum of a geometric series ``\sum_{n=0}^\infty ar^n`` is

	```math
	s_n=\sum_{i=0}^n ar^i=\begin{cases}
	\left(n+1\right)a&\textrm{if }r=1\,,\\
	\displaystyle\frac{a\left(1-r^{n+1}\right)}{1-r}&\textrm{if }r\ne1\,.
	\end{cases}
	```

The convergence of the geometric series can be summarized as follows

```math
\sum_{n=0}^\infty ar^n=\begin{cases}
0&\textrm{if }a=0\,,\\
\displaystyle\frac{a}{1-r}&\textrm{if }\left|r\right|&lt;1\,.
\end{cases}
```

In all other cases the geometric series diverges.

The representation of the function ``\frac{1}{1-x}`` as the sum of a geometric series,

```math
\frac{1}{1-x}=\sum_{n=0}^\infty x^n=1+x+x^2+x^3+\cdots\quad\textrm{for }-1&lt;x&lt;1\,,
```

will be important in our discussion of power series later in this chapter.

### Theorems

!!! theorem

	If ``\sum_{n=0}^\infty a_n`` converges, then ``\lim_{n\to\infty}a_n=0``. Therefore, if ``\lim_{n\to\infty}a_n`` does not exist or exists but is not zero, then the series ``\sum_{n=0}^\infty a_n`` diverges.

!!! proof

	If ``s_n=a_0+a_1+a_2+\cdots+a_n``, then ``s_n-s_{n-1}=a_n``. 
	
	If ``\sum_{n=0}^\infty a_n`` converges, then ``\lim_{n\to\infty}s_n=s`` exists, and ``\lim_{n\to\infty}s_{n-1}=s``.

	Hence, ``\lim_{n\to\infty}a_n=s-s=0``.

This theorem is very important for the understanding of infinite series. Students often err either in forgeting that a series cannot converge if its terms do not approach zero or in confusing this result with its converse, which is false.

When considering whether a given series converges, the first question you should ask yourself is: “Does the ``n``th term approach ``0`` as ``n`` approaches ``\infty``?” If the answer is no, then the series does not converge. If the answer is yes, then the series *may or may not* converge.

The following theorem asserts that it is only the ultimate behaviour of an that deterines whether ``\sum_{n=0}^\infty a_n`` converges.

!!! theorem

	``\sum_{n=0}^\infty a_n`` converges if and only if ``\sum_{n=N}^\infty a_n`` converges for any integer ``N\ge 0``.

!!! exercise

	Prove this theorem.

!!! theorem

	If ``\left(a_n\right)`` is ultimately positive, then the series ``\sum_{n=0}^\infty a_n`` converges if its partial sums are bounded above.

!!! exercise

	Prove this theorem.	

### Convergence Tests

The integral test provides a means for determining whether an ultimately positive series converges or diverges by comparing it with an improper integral that behaves similarly.

!!! theorem "Integral Test"

	Suppose that ``a_n=f\left(n\right)``, where ``f`` is positive, continuous, and nonincreasing on an interval ``\left[N,\infty\right[`` for some positive integer ``N``. Then

	```math
	\sum_{n=0}^\infty a_n\quad\textrm{and}\quad\int_N^\infty f\left(t\right)\,\mathrm{d}\kern-0.5pt t
	```

	either both converge or both diverge to infinity.

!!! example

	Show that

	```math
	\sum_{n=0}^\infty \left(n+1\right)^{-p}=\sum_{n=1}^\infty n^{-p}
	```

	converges if ``p&gt;1``.

	By the integral test

	```math
	\int_1^\infty t^{-p}\,\mathrm{d}\kern-0.5pt t=\lim_{x\to\infty}\left(-px^{-p-1}\right)-\left(-p1^{-p-1}\right)=p\quad\textrm{if }p&gt;1
	```

	the series converges for ``p&gt;1``.

!!! theorem "Comparison Test"

	Let ``a_n=f\left(n\right)`` and ``n_n=f\left(n\right)`` be sequences for which there exists a positive constant ``K`` such that, ultimately, ``0\le a_n\le Kb_n``. If the series ``\sum_{n=0}^\infty b_n`` converges, then so does the series ``\sum_{n=0}^\infty a_n``.

!!! theorem "Ratio Test"

	Suppose that ``a_n &gt; 0`` (ultimately) and that

	```math
	\rho = \lim_{n\to\infty}\frac{a_{n+1}}{a_n}
	```

	exists and ``0\le\rho&lt;1``, then ``\sum_{n=0}^\infty a_n`` converges.


### Absolute Convergence

!!! definition

	The series ``\sum_{n=0}^\infty a_n`` is said to be *absolutely convergent* if ``\sum_{n=0}^\infty \left|a_n\right|`` converges.

The series

```math
s=\sum_{n=0}^\infty\frac{\left(-1\right)^n}{\left(n+1\right)^2}=1-\frac{1}{4}+\frac{1}{9}-\frac{1}{16}+\cdots
```

converges absolutely since

```math
S=\sum_{n=0}^\infty\left|\frac{\left(-1\right)^n}{\left(n+1\right)^2}\right|=1+\frac{1}{4}+\frac{1}{9}+\frac{1}{16}+\cdots
```

converges. It seems reasonable that the first series must converge, and its sum ``s`` should satisfy ``-S\le s\le S``. 

In general, the cancellation that occurs because some terms are negative and others positive makes it easier for a series to converge than if all the terms are of one sign. We verify this insight in the following theorem.

!!! theorem

	If a series converges absolutely, then it converges.

## Power Series