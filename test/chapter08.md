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
\left(a_n\right)=&\left(0, 1, 2, 3, 4, 5, 6, 7, \dots \right)\\
\left(b_n\right)=&\left(1, -\frac{1}{2}, \frac{1}{4}, -\frac{1}{8}, \frac{1}{16}, -\frac{1}{32}, \frac{1}{64},\dots \right)\\
\left(c_n\right)=&\left(0, 1, 1, 2, 3, 5, 8, 13, \dots \right)
\end{aligned}
```

The terms of a sequence are usually listed in parentheses as shown. The ellipsis points ``\dots`` should be read “and so on.”

An infinite sequence is a special kind of function, one whose domain is a set of integers extending from some starting integer to infinity. The starting integer is usually ``0`` or ``1``, so the domain is the set of positive integers. The sequence ``\left(a_0, a_1, a_2, a_3, \dots\right)`` is the function ``f`` that takes the value ``f\left(n\right)=a_n`` an at each positive integer ``n``. A sequence can be specified in three ways:

1. We can list the first few terms followed by ``\dots`` if the pattern is obvious.
2. We can provide a formula for the general term ``a_n`` as a function of ``n``.
3. We can provide a formula for calculating the term ``a_n`` as a function of earlier terms ``a_1,a_2,\dots,a_{n-1}`` and specify enough of the beginning terms so the process of computing higher terms can begin.

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

	- The sequence ``\left(a_n\right)`` is *bounded below* by ``L``, and ``L`` is a *lower bound* for ``\left(a_n\right)``, if ``a_n\ge L`` for every ``\left.n\in\mathbb{N}\right.``. The sequence is *bounded above* by ``M`` and ``M`` is an upper bound, if ``a_n\le M`` for every ``n\in\mathbb{N}``.

	  The sequence ``\left(a_n\right)`` is *bounded* if it is both bounded above and bounded below. In this case there is a constant ``K`` such that ``\left|a_n\right|\le K`` for every ``n\in\mathbb{N}``.
	  
	- The sequence ``\left(a_n\right)`` is *positive* if it is bounded below by zero, that is, if ``a_n\ge 0`` for every ``n\in\mathbb{N}``; it is *negative* if ``a_n\le 0 `` for every ``n\in\mathbb{N}``.

	- The sequence ``\left(a_n\right)`` is *increasing* if ``a_{n+1}\ge a_n`` for every ``n\in\mathbb{N}``; it is *decreasing* if ``a_{n+1}\le a_n`` for every ``n\in\mathbb{N}``. The sequence is said to be *monotonic* if it is either increasing or decreasing.

	- The sequence ``\left(a_n\right)`` is *alternating* if ``a_na_{n+1}&lt;0`` for every ``n\in\mathbb{N}``, that is, if any two consecutive terms have opposite signs. Note that this definition requires ``a_n\ne0`` for every ``n\in\mathbb{N}``.

When you want to show that a sequence is increasing, you can try to show that the inequality ``a_{n+1}-a_n \ge 0`` holds for every ``n\in\mathbb{N}``. Alternatively, if  ``a_n=f\left(n\right)`` for a differentiable function ``f\left(x\right)`` you can show that ``f`` is a nondecreasing function on ``\left[0,\infty\right[`` by showing that ``f^\prime\left(x\right)\ge0`` there. Similar approaches are useful for showing that a sequence is decreasing.

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

	2. Since ``\left|\cos n\right|\le 1`` for ``n\in\mathbb{N}``, we have

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

	For ``\varepsilon = 1`` there exists a number ``N`` such that if ``n&gt; N``, then ``\left|a_n-L\right|&lt1``; therefore ``\left|a_n\right|&lt;1+\left| L\right|`` for such ``n``.

	If ``K`` denotes the largest of the numbers ``\left|a_0\right|,\left|a_1\right|, \dots, \left|a_N\right|``, and ``1+\left| L\right|``, then ``\left|a_n\right|\le K`` for every ``n\in \mathbb{N}``. 
	
	Hence, ``\left(a_n\right)`` is bounded.

The converse of this theorem is false; the sequence ``\left(\left(-1\right)^n\right)`` is bounded but does not converge.

The *completeness property* of the real number system can be reformulated in terms of sequences to read as follows:

!!! theorem

	If the sequence ``\left(a_n\right)`` is bounded above and is (ultimately) increasing, then it converges. The same conclusion holds if ``\left(a_n\right)`` is bounded below and is (ultimately) decreasing.

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

	A series of the form ``\sum_{n=0}^\infty ar^n=a+ar+ar^2+ar^3+\cdots``, whose ``n``th term is ``a_n=ar^n``, is called a *geometric series*. The number ``a`` is the first term. The number ``r`` is called the common ratio of the series, since it is the value of the ratio of the ``\left(n+1\right)``th term to the ``n``th term for any ``n\in \mathbb{N}``:

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

The following theorem asserts that it is only the ultimate behaviour of ``a_n`` that determines whether ``\sum_{n=0}^\infty a_n`` converges.

!!! theorem

	``\sum_{n=0}^\infty a_n`` converges if and only if ``\sum_{n=N}^\infty a_n`` converges for any integer ``N\ge 0``.

!!! exercise

	Prove this theorem.

!!! theorem

	If ``\left(a_n\right)`` is ultimately positive, then the series ``\sum_{n=0}^\infty a_n`` converges if its partial sums are bounded above.

!!! exercise

	Prove this theorem.

!!! theorem

	If ``\sum_{n=0}^\infty a_n`` and ``\sum_{n=0}^\infty b_n`` converge to ``A`` and ``B``, respectively, then

	1. ``\sum_{n=0}^\infty ca_n`` converges to ``cA`` (where ``c`` is a constant);

	2. ``\sum_{n=0}^\infty\left(a_n\pm b_n\right)`` converges to ``A\pm B``;

	3. if ``a_n \le b_n`` for all ``n\in \mathbb{N}``, then ``A\le B``.

!!! exercise

	Prove this theorem.

### Convergence Tests for Positive Sequences

The integral test provides a means for determining whether an ultimately positive series converges or diverges by comparing it with an improper integral that behaves similarly.

!!! theorem "Integral Test"

	Suppose that ``a_n=f\left(n\right)``, where ``f`` is positive, continuous, and nonincreasing on an interval ``\left[N,\infty\right[`` for some positive integer ``N``. If

	```math
	\int_N^\infty f\left(t\right)\,\mathrm{d} t
	```

	converges, then
	
	```math
	\sum_{n=0}^\infty a_n
	```

	converges also.

!!! proof

	Let ``s_n=a_0+a_1+a_2+\cdots+a_n``.

	If ``n&gt;N``, we have

	```math
	\begin{aligned}
	s_n&=s_N+a_{N+1}+a_{N+2}+\cdots+a_n\\
	&=s_N+f\left(N+1\right)+f\left(N+2\right)+\cdots+f\left(n\right)\\
	&\le s_N+\int_N^\infty f\left(t\right)\,\mathrm d t\,.
	\end{aligned}
	```

	If the improper integral ``\int_N^\infty f\left(t\right)\,\mathrm{d} t`` converges, then the sequence ``\left(s_n\right)`` is bounded above and ``\sum_{n=0}^\infty a_n`` converges.

!!! example

	Show that

	```math
	\sum_{n=0}^\infty \left(n+1\right)^{-p}=\sum_{n=1}^\infty n^{-p}
	```

	converges if ``p&gt;1``.

	By the integral test

	```math
	\int_1^\infty t^{-p}\,\mathrm{d} t=\lim_{x\to\infty}\left(-px^{-p-1}\right)-\left(-p1^{-p-1}\right)=p\quad\textrm{if }p&gt;1
	```

	the series converges for ``p&gt;1``.

!!! theorem "Comparison Test"

	Let ``a_n=f\left(n\right)`` and ``n_n=f\left(n\right)`` be sequences for which there exists a positive constant ``K`` such that, ultimately, ``0\le a_n\le Kb_n``. If the series ``\sum_{n=0}^\infty b_n`` converges, then so does the series ``\sum_{n=0}^\infty a_n``.

!!! proof

	Since a series converges if and only if its tail converges, we can assume, without loss of generality, that the condition ``0\le a_n\le Kb_n`` holds for all ``n\ge0``.
	
	Let ``s_n=a_0+a_1+a_2+\cdots+a_n`` and ``S_n=b_0+b_1+b_2+\cdots+b_n``. Then ``s_n\le KS_n``.
	
	If ``\sum b_n`` converges, then ``\left(S_n\right)`` is convergent and hence is bounded. 
	
	Hence ``\left(s_n\right)`` is bounded above and ``\sum a_n`` converges.

!!! theorem "Limit Comparison Test"

	Let ``\left(a_n\right)`` and ``\left(b_n\right)`` are positive sequences and that

	```math
	\lim_{n\to\infty}\frac{a_n}{b_n}=L\,,
	```

	where ``L`` is a nonnegative finite number.

	If ``\sum b_n`` converges, then ``\sum a_n`` also converges.

!!! proof

	Let ``L`` a nonnegative finite number, we have ``b_n&gt;0`` and

	```math
	0\le \frac{a_n}{b_n}\le L+1\,,
	```

	so ``0\le a_n\le \left(L+1\right)b_n``.

	Hence ``\sum a_n`` converges if ``\sum b_n`` converges by the previous theorem.



!!! theorem "Ratio Test"

	Suppose that ``a_n &gt; 0`` (ultimately) and that

	```math
	\rho = \lim_{n\to\infty}\frac{a_{n+1}}{a_n}
	```

	exists and ``0\le\rho&lt;1``, then ``\sum_{n=0}^\infty a_n`` converges.


!!! proof

	Let ``\rho &lt; 1``. Pick a number ``r`` such that ``\rho&lt; r&lt;1``.

	Since we are given that ``\lim_{n\to\infty}\frac{a_{n+1}}{a_n}=\rho``, we have ``\frac{a_{n+1}}{a_n}\le r`` for ``n`` sufficiently large; that is, ``a_{n+1}\le ra_n`` for ``n\le N``. In particular,

	```math
	\begin{aligned}
	a_{N+1}&\le ra_N\\
	a_{N+2}&\le ra_{N+1}\le r^2a_N\\
	a_{N+3}&\le ra_{N+2}\le r^3a_N\\
	&\vdots\\
	a_{N+k}&\le r^ka_N\quad\textrm{for }k\in \mathbb{N}\,.
	\end{aligned}
	```

	Hence, ``\sum_{n=N}^\infty a_n`` converges by comparison with the convergent geometric series ``\sum_{k=0}^\infty r^k``. 
	
	It follows that ``\sum_{n=0}^\infty a_n=\sum_{n=0}^{N-1} a_n+\sum_{n=N}^\infty a_n`` must also converge.

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

!!! proof

	Let ``\sum a_n`` be absolutely convergent, and let ``b_n=a_n +\left|a_n\right|`` for each ``n``.

	Since ``-\left|a_n\right|\le a_n\le \left|a_n\right|``, we have ``0\le b_n \le 2\left|a_n\right|`` for each ``n``. 
	
	Thus, ``\sum b_n`` converges by the comparison test.

	Therefore, ``\sum a_n=\sum b_n -\sum \left|a_n\right|`` also converges.

## Power Series

!!! definition

	A series of the form

	```math
	\sum_{n=0}^\infty a_n\left(x-c\right)^n=a_0+a_1\left(x-c\right)+a_2\left(x-c\right)^2+a_3\left(x-c\right)^3+\cdots
	```

	is called a *power series in powers of ``x-c``* or a *power series about ``c``*. The constants ``a_0,a_1,a_2,a_3,\dots`` are called the *coefficients* of the power series.

Since the terms of a power series are functions of a variable ``x``, the series may or may not converge for each value of ``x``. For those values of ``x`` for which the series does converge, the sum defines a function of ``x``. For example, if ``-1&lt;x&lt;1``, then

```math
1+x+x^2+x^3+\cdots = \frac{1}{1-x}\,.
```

The geometric series on the left side is a power series *representation* of the function ``\frac{1}{1-x}`` in powers of ``x`` (or about ``0``). Note that the representation is valid only in the open interval ``\left]-1, 1\right[`` even though ``\frac{1}{1-x}`` is defined for all real ``x`` except ``x=1``. For ``x=-1`` and for ``\left|x\right|&gt; 1`` the series does not converge, so it cannot represent ``\frac{1}{1-x}`` at these points.

The point ``c`` is the *centre of convergence* of the power series ``\sum_{n=0}^\infty a_n\left(x-c\right)^n``. The series certainly converges (to ``a_0``) at ``x=c``. (All the terms except possibly the first are ``0``.) The next theorem shows that if the series converges anywhere else, then it converges on an interval (possibly infinite) centred at ``x=c``, and it converges absolutely everywhere on that interval except possibly at one or both of the endpoints if the interval is finite. The geometric series

```math
1+x+x^2+x^3+\cdots 
```

is an example of this behaviour. It has centre of convergence ``c=0``, and converges only on the interval ``\left]-1, 1\right[``, centred at ``0``. The convergence is absolute at every point of the interval.

!!! theorem

	For any power series ``\sum_{n=0}^\infty a_n\left(x-c\right)^n`` one of the following alternatives must hold:

	1. the series may converge only at ``x=c``,

	2. the series may converge at every real number ``x``, or

	3. there may exist a positive real number ``R`` such that the series converges at every ``x`` satisfying ``\left|x-c\right|&lt;R`` and diverges at every ``x`` satisfying ``\left|x-c\right|&gt;R``. In this case the series may or may not converge at either of the two endpoints ``x=c-R`` and ``x=c+R``.

	In each of these cases the convergence is absolute except possibly at the endpoints ``x=c-R`` and ``x=c+R``.

!!! proof

	Suppose, therefore, that ``\sum_{n=0}^\infty a_n\left(x_0-c\right)^n`` converges. 
	
	Then ``\lim_{n\to\infty} a_n\left(x_0-c\right)^n=0``, so ``\left|a_n\left(x_0-c\right)^n\right|\le K`` for all ``n``, where ``K`` is some constant.

	If ``r=\frac{\left|x-c\right|}{\left|x_0-c\right|}&lt;1``, then

	```math
	\sum_{n=0}^\infty \left|a_n\left(x-c\right)^n\right|=\sum_{n=0}^\infty \left|a_n\left(x_0-c\right)^n\right|\left|\frac{\left|x-c\right|}{\left|x_0-c\right|}\right|^n\le K \sum_{n=0}^\infty r^n=\frac{K}{1-r}&lt;\infty\,.
	```

	Thus, ``\sum_{n=0}^\infty a_n\left(x-c\right)^n`` converges absolutely.

The set of values ``x`` for which the power series ``\sum_{n=0}^\infty a_n\left(x-c\right)^n`` converges is an interval centred at ``x=c``. We call this interval the *interval of convergence* of the power series. It must have one of the following forms:

1. the isolated point ``x=c`` (a degenerate closed interval ``\left[c,c\right]``),

2. the entire real line ``\left]-\infty,\infty\right[``,

3. a finite interval centred at ``c``:

   ```math
   \left[c-R,c+R\right]\,,\quad\textrm{or}\quad\left[c-R,c+R\right[\,,\quad\textrm{or}\quad\left]c-R,c+R\right]\,,\quad\textrm{or}\quad\left]c-R,c+R\right[\,.
   ```

The number ``R`` is called the *radius of convergence* of the power series. In the first case we say the radius of convergence is ``R=0``; in the second case it is ``R=\infty``.

The radius of convergence, ``R``, can often be found by using the ratio test on the power series. If

```math
\rho =\lim_{n\to\infty}\left|\frac{a_{n+1}\left(x-c\right)^{n+1}}{a_n\left(x-c\right)^n}\right|=\left(\lim_{n\to\infty}\left|\frac{a_{n+1}}{a_n}\right|\right)\left|x-c\right|
```

exists, then the series ``\sum_{n=0}^\infty a_n\left(x-c\right)^n`` converges absolutely where ``\rho&lt;1``, that is, where

```math
\left|x-c\right|&lt; R=\frac{1}{\lim_{n\to\infty}\left|\frac{a_{n+1}}{a_n}\right|}\,.
```

The series diverges if ``\left|x-c\right|&gt; R``.

!!! example

	Determine the centre, radius, and interval of convergence of

	```math
	\sum_{n=0}^\infty\frac{\left(2x+5\right)^n}{\left(n^2+1\right)3^n}\,.
	```

	The series can be rewritten

	```math
	\sum_{n=0}^\infty\left(\frac{2}{3}\right)^n\frac{1}{n^2+1}\left(x+\frac{5}{2}\right)^n\,.
	```

	The centre of convergence is ``x=-\frac{5}{2}``. The radius of convergence, ``R``, is given by

	```math
	\frac{1}{R}=\rho=\lim_{n\to\infty}\left|\frac{\left(\frac{2}{3}\right)^{n+1}\frac{1}{\left(n+1\right)^2+1}}{\left(\frac{2}{3}\right)^n\frac{1}{n^2+1}}\right|=\lim_{n\to\infty}\frac{2}{3}\frac{n^2+1}{\left(n+1\right)^2+1}=\frac{2}{3}\,.
	```

	Thus, ``R=\frac{3}{2}``. The series converges absolutely on ``\left]-\frac{5}{2}-\frac{3}{2}, -\frac{5}{2}+\frac{3}{2}\right[=\left]-4, -1\right[``, and it diverges on ``\left]-\infty, -4\right[`` and ``\left]-1, \infty\right[``. At ``x=-1`` the series is ``\sum_{n=0}^\infty\frac{1}{n^2+1}``; at ``x=-4`` the series is ``\sum_{n=0}^\infty\left(-1\right)^n\frac{1}{n^2+1}``. Both series converge (absolutely). The interval of convergence of the given power series is therefore ``\left[-4,-1\right]``.


### Algebraic Operations on Power Series

To simplify the following discussion, we will consider only power series with centre of convergence ``0``, that is, series of the form

```math
\sum_{n=0}^\infty a_nx^n=a_0+a_1x+a_2x^2+a_3x^3+\cdots
```

Any properties we demonstrate for such series extend automatically to power series of the form ``\sum_{n=0}^\infty a_n\left(y-c\right)^n`` via the change of variable ``x=y-c``.

First, we observe that series having the same centre of convergence can be added or subtracted on whatever interval is common to their intervals of convergence. The following theorem is a simple consequence of the algebraic properties of series

!!! theorem

	Let ``\sum_{n=0}^\infty a_nx^n`` and ``\sum_{n=0}^\infty b_nx^n`` be two power series with radii of convergence ``R_a`` and ``R_b``, respectively, and let ``c`` be a constant. Then

	1. ``\sum_{n=0}^\infty \left(ca\right)_nx^n`` has radius of convergence ``R_a``, and

	   ```math
	   \sum_{n=0}^\infty \left(ca\right)_nx^n=c\sum_{n=0}^\infty a_nx^n
	   ```

	   wherever the series on the right converges.

	2. ``\sum_{n=0}^\infty \left(a_n+b_n\right)x^n`` has radius of convergence ``R`` at least as large as the smaller of ``R_a`` and ``R_b``, and

	   ```math
	   \sum_{n=0}^\infty \left(a_n+b_n\right)x^n=\sum_{n=0}^\infty a_nx^n+\sum_{n=0}^\infty b_nx^n
	   ```

	   wherever both series on the right converge.

The situation regarding multiplication and division of power series is more complicated. We will mention only the results and will not attempt any proofs of our assertions.

Long multiplication of the form

```math
\left(a_0+a_1x+a_2x^2+a_3x^3+\cdots\right)\left(b_0+b_1x+b_2x^2+b_3x^3+\cdots\right)
```

leads us to conjecture the formula

```math
\left(\sum_{n=0}^\infty a_nx^n\right)\left(\sum_{n=0}^\infty b_nx^n\right)=\sum_{n=0}^\infty c_nx^n
```

where

```math
c_n=a_0b_n+a_1b_{n-1}+\cdots+a_nb_0=\sum_{i=0}^na_ib_{n-i}\,.
```

The series ``\sum_{n=0}^\infty c_nx^n`` is called the *Cauchy product* of the series ``\sum_{n=0}^\infty a_nx^n`` and ``\sum_{n=0}^\infty b_nx^n``. Like the sum, the Cauchy product also has radius of convergence at least equal to the lesser of those of the factor series.

!!! example

	Since

	```math
	\frac{1}{1-x}=1+x+x^2+x^3+\cdots=\sum_{n=0}^\infty x^n
	```

	holds for ``x\in\left]-1, 1\right[``, we can determine a power series representation for ``\frac{1}{\left(1-x\right)^2}`` by taking the Cauchy product of this series with itself. Since ``a_n=b_n=1`` for ``n\in\mathbb{N}``, we have

	```math
	c_n=\sum_{i=0}^n1=n+1
	```

	and

	```math
	\frac{1}{\left(1-x\right)^2}=1+2x+3x^3+4x^3+\cdots=\sum_{n=0}^\infty\left(n+1\right)x^n\,,
	```

	which must also hold for ``x\in\left]-1, 1\right[``.

### Differentiation and Integration of Power Series

If a power series has a positive radius of convergence, it can be differentiated or integrated term by term. The resulting series will converge to the appropriate derivative or integral of the sum of the original series everywhere except possibly at the endpoints of the interval of convergence of the original series. This very important fact ensures that, for purposes of calculation, power series behave just like polynomials, the easiest functions to differentiate and integrate. We formalize the differentiation and integration properties of power series in the following theorem.

!!! theorem

	If the series ``\sum_{n=0}^\infty a_nx^n`` converges to the sum ``f\left(x\right)`` on an interval ``\left]-R, R\right[`` where ``R&gt;0``, that is,

	```math
	f\left(x\right)=\sum_{n=0}^\infty a_nx^n=a_0+a_1x+a_2x^2+a_3x^3+\cdots\,,\quad x\in\left]-R, R\right[\,,
	```

	then ``f`` is differentiable on ``\left]-R, R\right[`` and

	```math
	f^\prime\left(x\right)=\sum_{n=1}^\infty na_nx^n=a_1x+2a_2x^2+3a_3x^3+\cdots\,,\quad x\in\left]-R, R\right[\,.
	```

	Also, ``f`` is integrable over any closed subinterval of ``\left]-R, R\right[`` and if ``\left|x\right|&lt;R``, then

	```math
	\int_0^x f\left(t\right)\,\mathrm{d} t=\sum_{n=0}^\infty \frac{a_n}{n+1}x^{n+1}=a_0x+\frac{a_1}{2}x^2+\frac{a_2}{3}x^3+\frac{a_3}{4}x^4+\cdots\,.
	```

Together, these results imply that the termwise differentiated or integrated series have the same radius of convergence as the given series. In fact, as the following examples illustrate, the interval of convergence of the differentiated series is the same as that of the original series except for the possible loss of one or both endpoints if the original series converges at endpoints of its interval of convergence. Similarly, the integrated series will converge everywhere on the interval of convergence of the original series and possibly at one or both endpoints of that interval, even if the original series does not converge at the endpoints.

!!! example

	Find power series representations for the functions

	```math
	\frac{1}{\left(1-x\right)^2}\quad\textrm{and}\quad\ln\left(1+x\right)
	```

	by starting with the geometric series

	```math
	\frac{1}{1-x}=1+x+x^2+x^3+\cdots=\sum_{n=0}^\infty x^n
	```

	Differentiate the geometric series term by term to obtain

	```math
	\frac{1}{\left(1-x\right)^2}=1+2x+3x^3+4x^3+\cdots=\sum_{n=0}^\infty\left(n+1\right)x^n\,,\quad x\in\left]-R, R\right[\,.
	```

	Substitute ``-t`` in place of ``x`` in the original geometric series:

	```math
	\frac{1}{1+t}=1-t+t^2-t^3+\cdots=\sum_{n=0}^\infty \left(-1\right)^nx^n\,,\quad x\in\left]-R, R\right[\,.
	```

	Integrate from ``0`` to ``x``, where ``\left|x\right|&lt;1``, to get

	```math
	\begin{aligned}
	\ln\left(1+x\right)&=\int_0^x\frac{1}{1+t}\,\,\mathrm{d} t=\sum_{n=0}^\infty \left(-1\right)^n\int_0^xt^n\,\,\mathrm{d} t\\
	&=\sum_{n=0}^\infty \left(-1\right)^n\frac{x^{n+1}}{n+1}=x-\frac{x^2}{2}+\frac{x^3}{3}-\frac{x^4}{4}+\cdots\,,\quad x\in\left]-R, R\right[\,.
	\end{aligned}
	```

Being differentiable on ``\left]-R, R\right[``, where ``R`` is the radius of convergence, the sum ``f\left(x\right)`` of a power series is necessarily continuous on that open interval. If the series happens to converge at either or both of the endpoints ``-R`` and ``R``, then ``f`` is also continuous (on one side) up to these endpoints. This result is stated formally in the following theorem. We will not prove it here.

!!! theorem "Abel's Theorem"

	The sum of a power series is a continuous function everywhere on the interval of convergence of the series.

!!! example

	The series in the last example converges (conditionally) at the endpoint ``x=1`` as well as on the interval ``\left]-1,1\right[``. Since ``\ln\left(1+x\right)`` is continuous at ``x=1``, Abel's Theorem assures us that the series must converge to that function at ``x=1`` also.

	In particular, therefore, the alternating harmonic series converges to ``\ln 2``:

	```math
	\ln 2 = 1-\frac{1}{2}+\frac{1}{3}-\frac{1}{4}+\frac{1}{5}-\cdots=\sum_{n=0}^\infty \left(-1\right)^n\frac{1}{n+1}\,.
	```

	This would not, however, be a very useful formula for calculating the value of ln 2. (Why not?)


## Taylor and Maclaurin Series

If a power series ``\sum_{n=0}^\infty a_n\left(x-c\right)^n`` has a positive radius of convergence ``R``, then the sum of the series defines a function ``f\left(x\right)`` on the interval ``\left]c-R,c+R\right[``. We say that the power series is a *representation* of ``f\left(x\right)`` on that interval. What relationship exists between the function ``f\left(x\right)`` and the coefficients ``a_0, a_1, a_2,\dots`` of the power series?

!!! theorem

	If the series ``\sum_{n=0}^\infty a_n\left(x-c\right)^n`` converges to ``f\left(x\right)`` for ``x\in\left]c-R,c+R\right[``, where ``R&gt;0``, then

	```math
	a_n=\frac{f^{\left(n\right)}\left(c\right)}{n!}\quad\textrm{for }n\in \mathbb{N}\,.
	```

!!! proof

	This proof requires that we differentiate the series for ``f\left(x\right)`` term by term several times justified by a previous theorem:

	```math
	\begin{aligned}
	f^\prime\left(x\right)&=\sum_{n=1}^\infty na_n\left(x-c\right)^{n-1}=a_1+2a_2\left(x-c\right)+3a_3\left(x-c\right)^2+\cdots\\
	f^{\prime\prime}\left(x\right)&=\sum_{n=2}^\infty n\left(n-1\right)a_n\left(x-c\right)^{n-2}=2a_2+6a_3\left(x-c\right)+\cdots\\
	&\vdots\\
	f^{\left(i\right)}\left(x\right)&=\sum_{n=i}^\infty n\left(n-1\right)\left(n-2\right)\cdots\left(n-i+1\right)a_n\left(x-c\right)^{n-i}\\
	&=i!a_i+\frac{\left(i+1\right)!}{1!}a_{i+1}\left(x-c\right)+\frac{\left(i+2\right)!}{2!}a_{i+2}\left(x-c\right)^2+\cdots\,.
	\end{aligned}
	```

	Each series converges for ``x\in\left]c-R,c+R\right[``. Setting ``x=c``, we obtain ``f^{\left(i\right)}\left(c\right)=i!a_i``, which proves the theorem.

This theorem shows that a function ``f\left(x\right)`` that has a power series representation with centre at ``c`` and positive radius of convergence must have derivatives of all orders in an interval around ``x=c``, and it can have only one representation as a power series in powers of ``x-c``.

!!! definition

	If ``f\left(x\right)`` has derivatives of all orders at ``x=c``, then the series
	```math
	\sum_{n=0}^\infty \frac{f^{\left(n\right)}\left(x\right)}{n!}\left(x-c\right)^n=f\left(c\right)+f^\prime\left(c\right)\left(x-c\right)+\frac{f^{\prime\prime}\left(c\right)}{2!}\left(x-c\right)^2+\frac{f^{\left(3\right)}\left(c\right)}{3!}\left(x-c\right)^3+\cdots
	```

	is called the *Taylor series of ``f`` about ``c``*. If ``c=0``, the term *Maclaurin series* is usually used in place of Taylor series.

The Taylor series is a power series as defined in the previous section. This implies that ``c`` must be the centre of any interval on which such a series converges, but the definition of Taylor series makes no requirement that the series should converge anywhere except at the point ``x=c``.

!!! definition

	A function ``f`` is analytic at ``c`` if ``f`` has a Taylor series at ``c`` and that series converges to ``f\left(x\right)`` in an open interval containing ``c``. If ``f`` is analytic at each point of an open interval, then we say it is analytic on that interval.

Most, but not all, of the elementary functions encountered in calculus are analytic wherever they have derivatives of all orders. On the other hand, whenever a power series in powers of ``x=c`` converges for all ``x`` in an open interval containing ``c``, then its sum ``f\left(x\right)`` is analytic at ``c``, and the given series is the Taylor series of ``f`` about ``c``.

!!! example

	Find the Taylor series for ``\mathcal{e}^x`` about ``x=c``. Where does the series converge to ``\mathcal{e}^x``? Where is ``\mathcal{e}^x`` analytic? What is the Maclaurin series for ``\mathcal{e}^x``?

	Since all the derivatives of ``f\left(x\right)=\mathcal{e}^x`` are ``\mathcal{e}^x``, we have ``f^{\left(n\right)}\left(c\right)=\mathcal{e}^c`` for ``n\in\mathbb{N}``. Thus, the taylorseries for ``\mathcal{e}^x`` about ``x=c`` is

	```math
	\sum_{n=0}^\infty \frac{\mathcal{e}^c}{n!}\left(x-c\right)^n\,.
	```

	The radius of convergence ``R`` of this series is given by

	```math
	\frac{1}{R}=\lim_{n\to\infty}\left|\frac{\frac{\mathcal{e}^c}{\left(n+1\right)!}}{\frac{\mathcal{e}^c}{n!}}\right|=\lim_{n\to\infty}\frac{n!}{\left(n+1\right)!}=\lim_{n\to\infty}\frac{1}{n+1}=0\,.
	```

	Thus, the radius of convergence is ``R=\infty`` and the series converges for all ``x``.

	Suppose the sum is ``g\left(x\right)``:

	```math
	g\left(x\right)=\mathcal{e}^c+\mathcal{e}^c\left(x-c\right)+\frac{\mathcal{e}^c}{2!}\left(x-c\right)^2+\frac{\mathcal{e}^c}{3!}\left(x-c\right)^3+\cdots\,.
	```

	By the differentiation theorem of series, we have

	```math
	\begin{aligned}
	g^\prime\left(x\right)&=0+\mathcal{e}^c+\frac{\mathcal{e}^c}{2!}2\left(x-c\right)+\frac{\mathcal{e}^c}{3!}3\left(x-c\right)^2+\cdots\,.\\
	&=\mathcal{e}^c+\mathcal{e}^c\left(x-c\right)+\frac{\mathcal{e}^c}{2!}\left(x-c\right)^2+\frac{\mathcal{e}^c}{3!}\left(x-c\right)^3+\cdots=g\left(x\right)\,.
	\end{aligned}
	```

	Also, ``g\left(c\right)=\mathcal{e}^c+0+0+\cdots=\mathcal{e}^c``. Since ``g\left(x\right)`` satisfies the differential equation ``g^\prime\left(x\right)=g\left(x\right)``, we have ``g\left(x\right)=C\mathcal{e}^x``.  Substituting ``x=c`` gives ``\mathcal{e}^c=g\left(c\right)=C\mathcal{e}^c``, so ``C=1``. Thus, the Taylor series for ``\mathcal{e}^x`` in powers of ``x-c`` converges to ``\mathcal{e}^x`` for every real number ``x``:
	
	```math
	\mathcal{e}^x=\sum_{n=0}^\infty \frac{\mathcal{e}^c}{n!}\left(x-c\right)^n\,.
	```

	In particular, ``\mathcal{e}^x`` is analytic on the whole real line. Setting ``c=0`` we obtain the Maclaurin series for ``\mathcal{e}^x``:

	```math
	\mathcal{e}^x=\sum_{n=0}^\infty \frac{x^n}{n!}=1+x+\frac{x^2}{2!}+\frac{x^3}{3!}+\cdots\,.
	```
