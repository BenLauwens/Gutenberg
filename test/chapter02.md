{data-type="chapter"}
# Real Numbers and Functions

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
	line(x1=Ox, y1=shift_y+height, x2=Ox, y2=shift_y+3, stroke="black", marker_end="url(#arrow)")
	for (nr, n) in enumerate(axis_y)
		line(x1=Ox-3, y1=Oy-scale*n, x2=Ox+3, y2=Oy-scale*n, stroke="black")
		txt = if ys===nothing "$n" else "$(ys[nr])" end
		len = if yl===nothing length(txt) else yl[nr] end
		h = if yh===nothing 1 else xh[nr] end
		latex(txt, x=Ox-font_x*len, y=Oy-scale*n-font_y/2, width=font_x*len, height=font_y*h)
	end
end

function plot_xy(f::Function, xs, xdots, Ox::Integer, Oy::Integer, scale::Integer; color::String="red", dashed::String="", width::Number=1.5)
	points = String[]
	for x in xs
		y = f(x)
		push!(points, "$(Ox+scale*x), $(Oy-scale*y)")
	end
	polyline(points=join(points, " "), fill="none", stroke=color, stroke_width=width, stroke_dasharray = dashed)
	for x in xdots
		y = f(x)
		circle(cx=Ox+scale*x, cy=Oy-scale*y, r=3, fill=color)
	end
end
```

In this chapter, the real numbers are formally defined and some basic real functions are explored. 

## Natural Numbers and Extensions

The axioms of Peano define the *natural numbers*, denoted by ``\mathbb{N}``. 

To close the set of numbers under the subtraction operation, the natural numbers are extended with the negative integers to form the set of *integers*, denoted by ``\mathbb{Z}``. 

To close the set of numbers under the division operation, numbers that can be expressed as an irreducible fraction ``\frac{m}{n}``, where ``m\in \mathbb{Z}`` and ``n\in \mathbb{Z}\setminus \{0, 1\}`` are added to the integers to form the set of *rational numbers*, denoted by ``\mathbb{Q}``.

This definition comes with the understanding that the two rational numbers ``\frac{m}{n}`` and ``\frac{a}{b}`` are equal whenever ``mb=na``.

## Algebraic Properties of Rational Numbers

The set of rational number is more than a set of fractions with integers for numerators and denominators. It also comes with the two binary operations of *addition* and *multiplication*.

!!! axiom "Algebraic properties"
	A set ``𝔽`` together with the binary operations of addition and multiplication form a *field* if ``𝔽`` contains two elements ``0`` and ``1`` with ``0\ne1`` such that ``\forall a,b,c\in 𝔽``:
	1. ``a+b=b+a`` and ``ab=ba`` (*commutativity*)
	2. ``a+\left(b+c\right)=\left(a+b\right)+c=a+b+c`` and ``a\left(bc\right)=\left(ab\right)c=abc`` (*associativity*)
	3. ``a+0=a`` and ``a\cdot1=a`` (*identity*)
	4. There exists ``-a\in 𝔽`` such that ``a+\left(-a\right)=0`` (*opposite*) and for ``a\ne 0`` there exists ``a^{-1}=\frac{1}{a}\in 𝔽`` such that ``a\cdot a^{-1}=1`` (*inverse*)
	5. ``a\left(b+c\right)=ab+bc`` (*distributivity*)

Notice that the rational numbers do satisfy the field axioms.

Following properties can be derived from the algebraic properties.

!!! theorem
	Let ``a,b,c\in \mathbb{Q}``.
	1. ``a+c=b+c\implies a=b``
	2. ``a\cdot 0=0``
	3. ``\left(-a\right)\cdot b=-ab``
	4. ``c\ne 0 \wedge ac=bc \implies a=b``
	6. ``ab=0 \implies a=0 \vee b=0``

!!! example
	Prove the second property.

!!! proof
    Let ``a\in \mathbb{Q}``.

    Since ``0`` is the additive identity, ``0=0+0``. Then ``a\cdot 0=a\cdot\left(0+0\right)``. By the distributive property, ``a\cdot 0=a\cdot 0+a\cdot 0``. By adding ``-a\cdot 0`` to each side of this equality, one gets
    ```math
    0=a\cdot 0-a\cdot 0=\left(a\cdot 0+a\cdot 0\right)-a\cdot 0=a\cdot 0+\left(a\cdot 0-a\cdot 0\right)=a\cdot 0+0=a\cdot 0\,.
    ```
    
    Therefore, ``a\cdot 0 = 0``

!!! exercise
	Prove the other properties.

The associative property allows to write in an unambiguous way ``a+b+c`` and ``abc``. More generally, the sum of ``a_1,a_2,\dots,a_n\in \mathbb{Q}`` is unambiguously defined. To present this sum concisely, we use the *sigma notation*:

```math
\sum_{i=1}^na_i\equiv\begin{cases} 0&\textrm{if }n=0\\
a_1+a_2+\dots+a_n&\textrm{if }n\in \mathbb{N}_0
\end{cases}\,.
```

We call the first case ``n=0`` the *empty sum*.

In a similar way we can define and represent the product of ``a_1,a_2,\dots,a_n\in \mathbb{Q}``:

```math
\prod_{i=1}^na_i\equiv\begin{cases} 1&\textrm{if }n=0\\
a_1\cdot a_2\cdot\dots\cdot a_n&\textrm{if }n\in \mathbb{N}_0
\end{cases}\,.
```

We call the first case ``n=0`` the *empty product*.

If all factors of the product have the same value ``a\in \mathbb{Q}``, we use the *exponential notation*:

```math
\Pi_{i=1}^na\equiv a^n\,.
```

For ``a\in \mathbb{Q}_0``, we can write

```math
\left(\frac{1}{a}\right)^n=\left(a^{-1}\right)^n=a^{-n}=\left(a^n\right)^{-1}=\frac{1}{a^n}
```

and we have the following property

```math
\forall m,n\in\mathbb{Z}:a^{m+n}=a^ma^n\textrm{ and }\left(a^m\right)^n=a^{mn}\,.
```

## Order Properties of Rational Numbers

Rational numbers are not only determined by the operations of addition and multiplication, they are also *ordered* in a way that is compatible with addition and multiplication. 

!!! axiom "Order properties"
	A field ``𝔽`` is an *ordered field* with total order relation ``\le`` if ``\forall a,b,c\in 𝔽:``
	1. ``a\le a`` (*reflectivity*)
	2. ``a\le b \vee b\le a`` (*totality*)
	3. ``a\le b\wedge b\le a\implies a=b`` (*antisymmetry*)
	4. ``a\le b\wedge b\le c\implies a\le c`` (*transitivity*)

	Moreover, addition and multiplication are compatible with the total order relation:
	1. ``a\le b\implies a+c\le b+c``
	2. ``a\le b\wedge 0\le c\implies ac\le bc``

Notice that the rational numbers do satisfy the ordered field axioms.

We say that ``a`` is *positive* if ``0\le a`` and *negative* if ``a\le 0``. The *strict order relation* ``a &lt; b`` means that ``a\le b`` and ``a \ne b``.

Following properties can be derived from the order properties.

!!! theorem
	Let ``a,b,c\in \mathbb{Q}``. 
	1. ``a\le b\implies -b\le -a``
	2. ``a\le b \wedge c\le 0 \implies bc\le ac``
	3. ``0\le a\wedge 0\le b\implies 0 \le ab``
	4. ``0\le a^2``
	5. ``0&lt;1``
	6. ``0&lt;a\implies 0&lt;a^{-1}``
	7. ``0&lt;a&lt;b\implies 0&lt;b^{-1}&lt;a^{-1}``

!!! example
	Prove the fifth property.

!!! proof "by contradiction"
    By the totality property is ``0\le1 \vee 1\le0``. Suppose ``1\le0``.

    By the compatibility of the addition is ``0=1+\left(-1\right)\le0+\left(-1\right)=-1``.

    By the compatibility of the multiplication is ``0=0\cdot\left(-1\right)\le-1\cdot\left(-1\right)=1``.

    Because ``0\ne 1``, ``0\le1`` is in contradiction with ``1\le0``. We supposed wrongly that ``1\le0``. 
    
    Therefore, ``0\le 1`` and ``0\ne 1``, that is, ``0 &lt; 1``.

!!! exercise
	Prove the other properties.

### Decimal Expansions

The rational numbers have a *decimal expansion* that is either:
1. terminating, that is, ending with an infinite string of zeros, eg. ``\frac{3}{4}=0.75000\ldots``, or
2. repeating, that is, ending with a string of digits that repeats over and over, eg. ``\frac{23}{11}=1.090909\ldots=2.\overline{09}``.

!!! example
	Show that ``1.\overline{32}`` and ``.3\overline{405}`` are rational numbers by expressing them as a quotient of two irreducible integers.

	1. Let ``x=1.323232\ldots``. Then ``x-1=0.323232\ldots`` and
	   ```math
	   100x=132.323232\ldots=132+0.323232\ldots= 132+x-1\,.
	   ```
	   Therefore, ``99x=131`` and ``x=\frac{131}{99}``.
	2. Let ``y=0.3405405405\ldots``. Then ``10y=3.405405405\ldots`` and ``10y-3=0.405405405\ldots``. Also,
	   ```math
	   10000y=3405,405405405\ldots=3405+10y-3\,.
	   ```
	   Therefore, ``9990y=3402`` and ``y=\frac{3402}{9990}=\frac{63}{185}``.

## Not all Numbers are Rational

Geometrically, we represent the integers as points on a horizontal line by defining a starting point (the number ``0``) and a unit distance (between two consecutive integers). The unit distance can be further subdivided to represent rational numbers such as ``\frac{1}{n}`` with ``n\in\mathbb{N}_0``. In this way we can uniquely represent each rational number on the *number line*.

Although the rational numbers have a rich structure, there are limitations. Not every point on the number line corresponds to a rational number, eg., we can indicate the number ``\sqrt 2`` using a simple geometric construction, based on the *Pythagorean theorem*, as a single point between the numbers ``1`` and ``2`` but it is not a rational number.

{cell=chap display=false output=false}
```julia
Figure("", "The real line.") do
	Drawing(width=600, height=102) do
		mid = trunc(Int64, 80)
		line(x1=0, y1=mid, x2=600, y2=mid, stroke="black")
		for n in 1:7
			line(x1=80n, y1=mid-5, x2=80n, y2=mid+5, stroke="black")
			txt = string(n-4)
			len = length(txt)
			latex(string(n-4), x=80n-font_x*len/2, y=mid+5, width=font_x*len, height=font_y)
		end
		for (txt, (val, len)) in zip(("\\displaystyle-\\frac{9}{4}", "\\displaystyle-\\frac{3}{2}", "\\displaystyle-\\frac{18}{5}", "\\displaystyle\\frac{7}{3}", "\\textup{e}", "\\textup{π} "), ((-9/4, 2), (-3/2, 2), (-18/5, 3), (7/3, 1), (ℯ, 1), (π, 1)))
			line(x1=320+80val, y1=mid-5, x2=320+80val, y2=mid+5, stroke="black")
			latex(txt, x=320+80val-font_x*len/2, y=mid-if val < 8/3 35 else 25 end, width=font_x*len, height=font_y*if val < 8/3 2 else 1 end)
		end
		line(x1=320, y1=mid, x2=400, y2=mid, stroke="RoyalBlue", stroke_dasharray="3")
		latex("\\color{RoyalBlue}1", x=357, y=mid-20, width="30", height="15")
		line(x1=400, y1=mid, x2=400, y2=mid-80, stroke="RoyalBlue", stroke_dasharray="3")
		latex("\\color{RoyalBlue}1", x=395, y=mid-40, width="30", height="15")
		latex("\\color{RoyalBlue}\\sqrt 2", x=340, y=mid-60, width="30", height="19")
		line(x1=320, y1=mid, x2=400, y2=mid-80, stroke="RoyalBlue")
		path(d="M 400 $(mid-80) A 127 127 0 0 1 $(320+80√2) $mid", fill="none", stroke="RoyalBlue")
		line(x1=320+80√2, y1=mid-5, x2=320+80√2, y2=mid+5, stroke="black")
		latex("\\displaystyle\\sqrt 2", x=312+sqrt(2)*80-5, y=mid+5, width="30", height="19")
	end
end
```

!!! theorem
	``\sqrt 2 \notin \mathbb{Q}``.

!!! proof "by contradiction"
    Suppose ``\sqrt 2\in \mathbb{Q}``.

    Since ``\sqrt 2`` as a rational number can be represented by an irreducible fraction ``\frac{m}{n}``, we have ``\frac{m^2}{n^2}=\left(\sqrt 2\right)^2=2``, that is, ``m^2=2n^2``. Consequently, ``m^2`` is even and so is ``m`` (see previous chapter). Then ``m^2=\left(2k\right)^2=4k^2=2n^2`` or ``n^2=2k^2``, that is, ``n^2`` is even and so is ``n``.

    Both ``m`` and ``n`` are even contradicts that ``\frac{m}{n}`` is an irreducible fraction. We supposed wrongly that ``\sqrt 2\in \mathbb{Q}``.

    Therefore, ``\sqrt 2 \notin \mathbb{Q}``.

!!! exercise
	Prove ``\sqrt 3 \notin \mathbb{Q}``. What goes wrong if you try to prove ``\sqrt 4 \notin \mathbb{Q}``?

	Hint: If a prime number divides the square of an integer, it also divides the integer itself.

## Completeness of the Real Numbers

To express that there are no holes in the *real line*, that is, the line is *complete*, another axiom is needed.

!!! definition
	A number ``u`` of an ordered field ``𝔽`` is said to be an *upper bound* for a nonempty set ``S\subset𝔽`` if ``\forall x\in S: x\le u``.

	The number ``u^\star`` is called the *least upper bound* or *supremum* of ``S`` if ``u^\star`` is an upper bound for ``S`` and ``u^\star \le u`` for every upper bound ``u`` of ``S``. The supremum of ``S`` is denoted ``\sup S``.
	
	Similarly, ``l`` is a *lower bound* for ``S`` if ``\forall x\in S: l\le x``. The number ``l^\star`` is called the *greatest lower bound* or *infimum* of ``S`` if ``l^\star`` is a lower bound for ``S`` and ``l \le l^\star`` for every lower bound ``l`` of ``S``. The infimum of ``S`` is denoted ``\inf S``.

!!! example
	Let ``a&gt;0``. Show that ``\sup aS=a\sup S``.

	1. Since ``\forall x\in S:x\le\sup S``, so ``ax\le a\sup S`` and ``\sup aS\le a\sup S``.
	2. Since ``\forall x\in S:ax\le\sup aS``, so ``x\le \frac{\sup aS}{a}`` and ``a\sup S\le \sup aS``.
	Therefore, ``\sup aS=a\sup S``.

!!! exercise
	Let ``a&gt;0``. Show that ``\inf aS=a\inf S``.

If a set has a maximum (minimum) then this maximum (minimum) is also the supremum (infimum). If this is not the case, the supremum (infimum), not belonging to the set, are the next-best thing. 

!!! axiom "Completeness"
	A nonempty set of real number that has an upper bound must have a least upper bound.

	Equivalently, a nonempty set of real numbers having a lower bound must have a greatest lower bound.

We stress that this is an axiom to be assumed without proof. It cannot be deduced from the algebraic and order properties. These properties are shared by the rational numbers, a set that is not complete.

The completeness axiom has massive consequences. 

!!! lemma
	The set of natural numbers is not bounded above or ``\forall r\in \mathbb{R},\exists n\in \mathbb{N}:r&gt;n``.

!!! proof "by contradiction"
    Suppose that there is an ``r\in \mathbb{R}`` such that ``\forall n\in \mathbb{N}:r&gt;n``.

    Then the set ``\mathbb{N}`` is a nonempty subset of ``\mathbb{R}`` with an upper bound, so by the completeness axiom, ``\mathbb{N}`` has a least upper bound ``M``.

    Then ``M-1&lt;M``, so ``M-1`` is not an upper bound for ``\mathbb{N}``.

    Thus, there is a ``k\in \mathbb{N}`` with the property that ``k &gt; M-1``.

    But then ``k+1`` is also in ``\mathbb{N}``, yet ``k+1&gt;\left(M-1\right)+1=M`` where ``M`` is an upper bound for ``\mathbb{N}``.

    This is a contradiction since no element of a set can be greater than an upper bound for that set.

    Therefore, the assumption that ``r&gt;n`` for every ``n\in \mathbb{N}`` must be false, and for every ``r\in \mathbb{R}`` there must be at least one ``n\in \mathbb{N}`` with ``n&gt;r``.

The Archimedean principle expresses geometrically that any line segment, no matter how long, may be covered by a finite number of line segments of a given positive length, no matter how small. This is a fundamental property of the real line.

!!! theorem "Archimedean Principle"
	``\forall a\in \mathbb{R}^+_0,\forall b\in \mathbb{R},\exists n\in \mathbb{N}:na&gt;b``.

This principle is a direct consequence of the previous lemma, just replace ``r`` by ``\frac{b}{a}``.		

!!! example
	Let ``S=\left\{\frac{1}{2^n}\mid n\in \mathbb{N}\right\}=\left\{1, \frac{1}{2},\frac{1}{4}, \ldots\right\}``. Show that ``\inf S=0``.

	1. ``0`` is a lower bound of ``S``, ``\forall n\in \mathbb{N}: 0&lt;\frac{1}{2^n}`` and
	2. ``\forall \varepsilon\in \mathbb{R}^+_0:0+\varepsilon`` is no lower bound, ``\forall \varepsilon\in \mathbb{R}^+_0,\exists n\in \mathbb{N}:\frac{1}{2^n}\le\frac{1}{n+1}&lt;0+\varepsilon`` (Archimedean principle with ``x=1`` and ``y=\varepsilon``), so ``0`` is the greatest lower bound.
	
## Absolute Values

The concepts that separates the area of mathematics known as analysis (the fundaments of calculus) from other branches such as algebra, set theory, ... is the idea of *distance*. In the real numbers, one can measure distance by using the *absolute value*.

!!! definition
	The absolute value of a real number ``x``, denoted by ``\left|x\right|``, is defined by the formula
	```math
	\left|x\right|=\begin{cases}
	\hphantom{-}x&\textrm{if } x\ge0\\
	-x&\textrm{if }x&lt;0
	\end{cases}
	```

Geometrically, ``\left|x\right|`` represents the (nonnegative) distance from ``x``  to ``0`` on the real line. ``\left|x-y\right|`` represents the (nonnegative) distance between the points ``x`` and ``y`` on the real line, since this distance is the same as that from the point ``x-y`` to ``0``.

The absolute value has the following properties.

!!! theorem
	Let ``a, b\in \mathbb{R}``
	- ``\left|-a\right|=\left|a\right|``
	- ``\left|ab\right|=\left|a\right|\left|b\right|``
	- ``\left|a\pm b\right|\le\left|a\right|+\left|b\right|`` (*triangle inequality*)

!!! proof
    The first two of these properties can be checked by considering the cases where either ``a`` or ``b`` is either positive or negative. The third property follows from the first two.

    Let ``a, b\in \mathbb{R}``.
    
    ```math
    \begin{aligned}
    \left|a\pm b\right|^2&=\left(a\pm b\right)^2=a^2\pm 2ab+b^2\\
    &\le&\left|a\right|^2+2\left|a\right|\left|b\right|+\left|b\right|^2=\left(\left|a\right|+\left|b\right|\right)^2
    \end{aligned}
    ```

    Taking the (positive) square root of both sides, we obtain ``\left|a\pm b\right|\le\left|a\right|+\left|b\right|``.

The notion of an absolute value will be generalized by a *metric* in the setting of a *metric space*<span data-type="footnote">A metric space is an ordered pair ``\left(M, d\right)`` where ``M`` is a set and ``d`` is a metric on ``M``, i.e., a function ``d:M\times M\to \mathbb{R}`` satisfying the following axioms for all points ``x,y,z\in M``:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;•&nbsp;&nbsp;``d\left(x, x\right)=0`` and ``x\ne y\Rightarrow d\left(x, y\right) > 0`` (*positivity*)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;•&nbsp;&nbsp;``d\left(x,y\right)=d\left(y,x\right)`` (*symmetry*)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;•&nbsp;&nbsp;``d\left(x,z\right)\le d\left(x,y\right)+d\left(y,z\right)`` (*triangle inequality*)</span>.

## Intervals

!!! definition
	An *interval* is a subset of the real numbers that contains all real numbers lying between any two numbers of the subset.

The notion of an interval will be generalized by a *connected set* in the setting of a metric space.

!!! example
	The set of real numbers ``x`` such that ``x&gt;6`` is an interval, but the set of real numbers ``y`` such that ``y\ne0`` is not an interval.

If ``a`` and ``b`` are real numbers and ``a&lt;b`` we often refer to
1. the *open interval* from ``a`` to ``b``, denoted ``\left]a,b\right[``, consisting of all real numbers ``x`` satisfying ``a&lt;x&lt;b``
2. the *closed interval* from ``a`` to ``b``, denoted ``\left[a,b\right]``, consisting of all real numbers ``x`` satisfying ``a\le x\le b``
3. the *half-open interval* from ``a`` to ``b``, denoted ``\left[a,b\right[``, consisting of all real numbers ``x`` satisfying ``a\le x&lt;b``
4. the *half-open interval* from ``a`` to ``b``, denoted ``\left]a,b\right]``, consisting of all real numbers ``x`` satisfying ``a&lt;x\le b``

In a figure, hollow dots indicate endpoints of intervals that are not included in the intervals, and solid dots indicate endpoints that are included. The endpoints of an interval are also called *boundary points*.

The already defined intervals are *finite intervals*, that is, each of them has finite length ``b-a``. Intervals can also have infinite length, in which case they are called *infinite intervals*. Note that the whole real line ``\mathbb{R}`` is an interval, denoted by ``\left]-\infty, \infty\right[``. The symbol ``\infty`` ("infinity") does **not** denote a real number.

!!! theorem "Theorem of Nested intervals"
	If ``\forall n\in \mathbb{N}``, we have a closed interval
	```math
	I_n=\left[a_n, b_n\right]=\left\{x\mid x\in \mathbb{R}\wedge a_n\le x\le b_n\right\}
	```
	such that
	```math
	a_n\le a_{n+1}\textrm{ and }b_{n+1}\le b_n\textrm{, so that } \cdots\subset I_n\subset\cdots\subset I_2\subset I_1\subset I_0\,,
	```
	then
	```math
	\bigcap_{n\in \mathbb{N}}I_n\ne\emptyset
	```
	and if, in addition,
	```math
	\inf\left\{b_n-a_n\right\}=0\,,
	```
	then
	```math
	\bigcap_{n\in \mathbb{N}}I_n=\left\{x\right\}\textrm{ where }x=\sup\left\{a_n\right\}=\inf\left\{b_n\right\}\,.
	```

!!! proof

    We split the proof in four parts.

    - We prove first that ``\bigcap_{n\in \mathbb{N}}I_n\ne\emptyset``.
    
      Since the intervals are nested, ``a_m \le b_n`` for all ``m`` and ``n``. This shows that every ``b_n`` is an upper bound for the set ``\left\{a_m\right\}`` and every ``a_m`` is a lower bound for the set ``\left\{b_n\right\}``. Let ``a = \sup\{a_n\}`` and ``b = \inf\{b_n\}``. 
    
      By definition, ``a_n \le a`` for all ``n``, and since ``b_n`` is an upper bound for ``\left\{a_n\right\}``, we have ``a_n\le a\le b_n``, which says that ``a\in I_n`` for every ``n`` and so ``a\in\bigcap_{n\in \mathbb{N}}I_n``. 
        
      Similarly, ``b\in\bigcap_{n\in \mathbb{N}}I_n``.

      Therefore, ``\bigcap_{n\in \mathbb{N}}I_n\ne\emptyset``

    - Secondly, we prove by contradiction that ``a\le b``.

      Suppose ``a&gt;b``. We have ``b&lt;\frac{a+b}{2}&lt;a``. 
        
      Since ``\frac{a+b}{2}&lt;a``, ``\frac{a+b}{2}`` is not a upper bound for ``\left\{a_n\right\}``, so there exists some ``a_k &gt; \frac{a+b}{2}``.

      Similarly, since ``b&lt;\frac{a+b}{2}``, ``\frac{a+b}{2}`` is not a lower bound for ``\left\{b_n\right\}``, so there exists some ``b_l &lt; \frac{a+b}{2}``.

      But then ``b_l &lt; a_k`` which is a contradiction since ``a_m \le b_n`` for all ``m`` and ``n``.

      Therefore, ``a\le b``.

    - Given the condition ``\inf\left\{b_n-a_n\right\}=0``, we prove that ``a=b``.

      Note that ``a_n\le a\le b\le b_n`` implies ``0\le b-a\le b_n-a_n`` for all ``n``, so ``b-a`` is a lower bound for ``\left\{b_n-a_n\right\}`` and ``0\le b-a\le\inf\left\{b_n-a_n\right\}=0``

      Therefore, ``a=b``.

    - Finally, we prove that ``\bigcap_{n\in \mathbb{N}}I_n=\left\{a\right\}``.

      Let ``y\in\bigcap_{n\in \mathbb{N}}I_n``. Then, ``a_n\le y\le b_n`` for all ``n``.

      The first inequality implies that ``y`` is an upper bound for ``a_n``, hence ``a\le y``.

      The second inequality implies that ``y`` is an lower bound for ``b_n``, hence ``y\le b=a``.

      Combining both inequalities ``a\le y\le a``, we have ``y=a``, so ``\bigcap_{n\in \mathbb{N}}I_n \subset \left\{a\right\}``.

      We also have ``\left\{a\right\} \subset \bigcap_{n\in \mathbb{N}}I_n``.

      Therefore, ``\bigcap_{n\in \mathbb{N}}I_n=\left\{a\right\}``.

A direct corollary of the nested intervals theorem is the uncountability of the real numbers.

!!! corollary "The real numbers are not countable"
	There is no surjection ``f:\mathbb{N}\rightarrow\mathbb{R}``.

!!! proof
    Let ``f:\mathbb{N}\rightarrow\mathbb{R}`` be a function.

    For each ``n\in \mathbb{N}``, let ``f\left(n\right)=x_n``

    Choose a closed interval ``I_0=\left[a_0, b_0\right]`` not containing ``x_0``.

    Choose a closed interval ``I_1=\left[a_1, b_1\right]\subset I_0`` not containing ``x_1``.

    Choose a closed interval ``I_2=\left[a_2, b_2\right]\subset I_1\subset I_0`` not containing ``x_2``.

    And so on.

    By the nested intervals theorem, ``\bigcap_{n\in \mathbb{N}}I_n\ne\emptyset``. But no ``x_k`` can be in the intersection since ``x_k \notin I_k``, so there exists some real number ``y\in\bigcap_{n\in \mathbb{N}}I_n`` such that ``y\ne f\left(n\right)`` for any ``n\in \mathbb{N}``.

    Therefore, ``f`` is not a surjection.

The cardinal number of the set of real numbers is called the *continuum*, denoted by ``\# \mathbb{R}=𝔠=ℵ_1=2^{ℵ_0}&gt;ℵ_0``.

## Bisection Method

When we have to find an element in a sorted array, we apply intuitively a *binary search algorithm*, eg. looking up a name in an alphabetically ordered list.

1. We start by inspecting the first and the last name in the list.
2. If the name we are looking for, is not the first or the last name. We check the name that is located half way between the first and the last name.
3. If this is the name we are looking for, we stop.

   If this name is alphabetically after the name we are looking for, we reduce the list from the first name to the name in the center position and go back to the first step.

   If this name is alphabetically before the name we are looking for, we reduce the list from the name in the center position to the last name and go back to the first step.

The same methodology can be used to prove some important theorems in calculus. We call such a procedure, the *bisection method*.

!!! template "Prove by bisection"
	Begin with a closed interval ``I_0=\left[a_0,b_0\right]``.

	STEP 1: Bisect ``I_0`` to obtain two closed intervals ``\left[a_0, \frac{a_0+b_0}{2}\right]`` and ``\left[\frac{a_0+b_0}{2}, b_0\right]``.

	STEP 2: Select one of the two subintervals above, and call it ``I_1=\left[a_1,b_1\right]``.

	Keep repeating this process to obtain a sequence of intervals ``I_0,I_1,I_2,I_3,\ldots``.

The sequence of intervals ``I_0,I_1,I_2,I_3,\ldots`` satisfies both hypotheses of the nested intervals theorem:

1. Since for each ``n`` we have ``a_n&lt;\frac{a_n+b_n}{2}&lt;b_n`` and either ``a_{n+1}=a_n`` or ``b_{n+1}=b_n``. Therefore ``a_n\le a_{n+1}`` and ``b_{n+1}\le b_n`` for all ``n\in \mathbb{N}``, so that ``\cdots\subset I_n\subset\cdots\subset I_2\subset I_1\subset I_0``.
2. We have that ``b_n-a_n=\frac{b_0-a_0}{2^n}``, so

   ```math
   \inf\left\{b_n-a_n\right\}=\inf\left\{\frac{b_0-a_0}{2^n}\right\}=\left(b_0-a_0\right)\inf\left\{\frac{1}{2^n}\right\}=0
   ```

   by previous examples.

Let's prove by the bisection method that there is a rational between any two reals.

We need following lemma.

!!! lemma "Capture theorem"
	Let ``A`` be a nonempty subset of ``\mathbb{R}``. If ``A`` is bounded above, then any open interval containing ``\sup A`` contains an element of ``A``.

	Similarly, if ``A`` is bounded below, than any open interval containing ``\inf A`` contains an element of ``A``.

!!! proof "by contradiction"
    Let ``\left]x,y\right[`` be an open interval such that ``x&lt;\sup A&lt;y``.

    Suppose ``\left]x,y\right[`` doesn't contain an element of ``A``. So ``x`` is an upper bound for ``A`` which is a contradiction since ``x&lt;\sup A``.

    Therefore, ``\left]x,y\right[`` contains an element of ``A``.

!!! exercise
	Prove the second statement.

!!! theorem "The rational numbers are dense in the real numbers"
	Let ``x\in \mathbb{R}`` and ``\varepsilon\in \mathbb{R}^+``. The interval ``\left]x-\delta,x+\delta\right[`` contains a rational number.

!!! proof "by bisection"
    If ``x`` is rational we are done, so let ``x`` be irrational.

    Let ``b_0`` be the smallest integer greater than ``x``, and let ``a_0=b_0-1``.

    Then ``I_0=\left[a_0, b_0\right]`` contains ``x`` and has rational endpoints. It follows that ``x`` is contained in either ``\left]a_0, \frac{a_0+b_0}{2}\right[`` or ``\left]\frac{a_0+b_0}{2}, b_0\right[``. Let ``I_1`` be the closed subinterval containing ``x``.

    Continuing this way, we obtain a sequence of closed intervals ``\cdots\subset I_n\subset\cdots\subset I_2\subset I_1\subset I_0`` satisfying the hypotheses of the nested intervals theorem, where each ``I_n`` contains ``x`` and has rational endpoints.

    By the nested intervals theorem, ``\bigcap_{n\in \mathbb{N}}I_n=\left\{y\right\}`` where ``y=\sup\left\{a_n\right\}=\inf\left\{b_n\right\}``. Since ``x\in I_n`` for all ``n\in \mathbb{N}``, ``y=x``.

    Since ``x=\sup\left\{a_n\right\}``, by the previous lemma, the open interval ``\left]x-\delta,x+\delta\right[`` contains ``a_m\in \mathbb{Q}`` for some ``m\in \mathbb{N}``.

The practical use of this theorem is the possibility to approximate with a given tolerance a real number by a rational number, eg. in computer science *floating point* values are rational approximations of real numbers.

Something stronger than the Capture theorem is actually true: for ``x=\sup\left\{a_n\right\}=\inf\left\{b_n\right\}`` the open interval ``\left]x-\delta,x+\delta\right[`` actually contains an entire interval ``I_N``, for some ``N``. To see this, note that there are tree possibilities when ``a_k\in\left]x-\delta,x+\delta\right[`` and ``b_l\in\left]x-\delta,x+\delta\right[``:
- if ``k=l``, then the open interval contains ``I_k=I_l``;
- if ``k&lt; l``, then the open interval contains ``a_k\le a_{k+1}\le \dots a_l\le b_l``, so the open interval contains ``I_l``;
- if ``k&gt; l``, then the open interval contains ``a_k\le b_k\le \dots \le \dots b_{l+1}\le b_l``, so the open interval contains ``I_k``.

!!! theorem "Heine-Borel Theorem"

	Let ``\left[a,b\right]`` be a closed interval and ``𝒪=\left\{\left]c_i, d_i\right[\mid i\in I\right\}`` be an infinite set of open intervals. If ``\left[a,b\right]\subset\bigcup_{i\in I}\left]c_i, d_i\right[``, then there exists ``n\in \mathbb{N}`` such that ``\left[a,b\right]\subset\bigcup_{k=0}^n\left]c_{i_k}, d_{i_k}\right[``.

!!! proof "by bisection and contradiction"

	Suppose that no finite subset of ``𝒪`` covers ``\left[a,b\right]``.

	Let ``I_0=\left[a,b\right]=\left[a_0,b_0\right]``. 
	
	At least one of the intervals ``\left[a_0,\frac{a_0+b_0}{2}\right]`` or ``\left[\frac{a_0+b_0}{2},b_0\right]`` cannot be covered by a finite subset of ``𝒪``. If both could be covered by finite subsets, their union would cover ``I_0``.

	Let the interval that can't be covered by a finite subset of ``𝒪`` be ``I_1=\left[a_1,b_1\right]``.

	Continuing this way, we obtain a sequence of closed intervals ``\cdots\subset I_n\subset\cdots\subset I_2\subset I_1\subset I_0`` satisfying the hypotheses of the nested intervals theorem, where each ``I_n`` can't be covered by a finite subset of ``𝒪``.

	By the nested intervals theorem, ``\bigcap_{n\in \mathbb{N}}I_n=\left\{x\right\}`` where ``x=\sup\left\{a_n\right\}=\inf\left\{b_n\right\}``.

	Since ``x\in\left[a,b\right]`` and ``\left[a,b\right]`` is covered by the union of ``𝒪``, there exists an open interval ``\left]c_i, d_i\right[`` such that ``x \in \left]c_i, d_i\right[``.

	Since ``\left]c_i, d_i\right[`` is open, there exists an ``\delta &gt;0`` such that ``\left]x-\delta, x+\delta\right[\subset \left]c_i, d_i\right[``.

	Since ``x\in \bigcap_{n\in \mathbb{N}}I_n``, there exists ``N\in \mathbb{N}`` such that ``I_N\subset\left]x-\delta, x+\delta\right[`` by the extension of the Capture theorem.

	This means that for ``n\ge N``, ``I_n \subset \left]c_i, d_i\right[``, contradicting our assumption that no ``I_n`` can be covered by a finite subset of ``𝒪``.

	Therefore, our initial assumption must be false, and there must exist a finite subset of ``𝒪`` that covers ``\left[a,b\right]``.

The Heine-Borel theorem let us replace an infinite set of open intervals with a finite set. Something that will be very useful in the next chapters.

## Functions, Cartesian Plane and Graphs

Remember the definition of a function.

!!! definition
	A function ``f`` from a set ``X`` to a set ``Y``, often written ``f:X\to Y``, is a rule which assigns to each ``x\in X`` a unique element ``f\left(x\right)=y\in Y``.

In this course, we will only consider functions having ``X\subset \mathbb{R}`` and ``Y\subset \mathbb{R}``.

There are several ways to represent a function symbolically:
1. by a formula such as ``y=x^2``;
2. by a formula such as ``f\left(x\right)=x^2``;
3. by a mapping rule such as ``x\mapsto x^2``.

Strictly speaking we should call a function ``f`` and not ``f\left(x\right)`` since the latter denotes the value of the function at the point ``x``.

A function is not properly defined until its domain is specified. For instance the function ``f\left(x\right)=x^2`` defined for all real numbers ``x\ge 0`` is different from the function ``g\left(x\right)=x^2`` defined for all real numbers ``x``. 

When a function ``f`` is defined without specifying its domain, we assume that the domain consists of all real numbers ``x`` for which the value ``f\left(x\right)`` of the function is a real number.

!!! example
	The domain of ``f:x\mapsto\sqrt x`` is the interval ``\left[0,\infty\right[`` since negative numbers do not have a real square root. Note that the *square root function* ``\sqrt x`` always denotes the positive square root of ``x``.

Functions can be represented in the *Cartesian plane*.

!!! definition
	A *Cartesian coordinate system* in a plane is a coordinate system that specifies each point uniquely by a pair of real numbers called coordinates, which are the signed distances to the point from two fixed perpendicular oriented lines, called *coordinate axes* of the system. The point where they meet is called the *origin* denoted by ``O`` and has ``(0, 0)`` as coordinates.

{cell=chap display=false output=false}
```julia
Figure("", "The Cartesian Plane.") do
	Drawing(width=300, height=240) do
		xmid = 150
		ymid = 120
		scale = 30
		axis_xy(300,240,xmid,ymid,scale,(-4,-3,-2,-1,1,2,3,4),(-3,-2,-1,1,2,3))
		a = 2.6
		b = 2.3
		latex("a", x=xmid+scale*a-font_x/2, y=ymid+30-2, width=font_x, height=font_y)
		line(x1=xmid+scale*a,y1=ymid+30,x2=xmid+scale*a,y2=ymid+3, stroke="black", marker_end="url(#arrow)")
		latex("b", x=xmid-30-font_x-1, y=ymid-scale*b-font_y/2-1, width=font_x, height=font_y)
		line(x1=xmid+scale*a,y1=ymid,x2=xmid+scale*a,y2=ymid-scale*b, stroke="black", stroke_dasharray = 2)
		line(x1=xmid-30,y1=ymid-scale*b,x2=xmid-3,y2=ymid-scale*b, stroke="black", marker_end="url(#arrow)")
		line(x1=xmid,y1=ymid-scale*b,x2=xmid+scale*a,y2=ymid-30b, stroke="black", stroke_dasharray = 2)
		circle(cx=xmid+scale*a, cy=ymid-scale*b, r=2, fill="red", stroke="red")
		latex("P(a,b)", x=xmid+scale*a-font_x, y=ymid-scale*b-font_y, width=5*font_x, height=font_y)
	end
end
```

!!! definition
	The *graph of a function* ``f`` consists of those points in the Cartesian plane whose coordinates ``\left(x,y\right)`` are pairs of input-output values for ``f``.

Thus, ``\left(x,y\right)`` lies on the graph of ``f`` provided ``x`` is in the domain of ``f`` and ``y=f\left(x\right)``.

!!! example
	Graph the function ``f\left(x\right)=x^2``.

	Make a table of ``\left(x,y\right)`` pairs that satisfy ``y = x^2``. Now plot the points and join them with a smooth curve.

{cell=chap display=false output=false}
```julia
Figure("", """The graph of <span class="math-tex" data-type="tex">\\(y = x^2\\)</span>""") do
	Drawing(width=255, height=255) do
		xmid = 125
		ymid = 230
		scale = 50
		axis_xy(255,255,xmid,ymid,scale,(-2,-1,1,2),(1,2,3,4))
		plot_xy(x->x^2, -2.1:0.1:2.1, -2:2, xmid, ymid, scale)
	end
end
```

Not every curve you can draw is the graph of a function. A function ``f`` can have only one value ``f\left(x\right)`` for each ``x`` is its domain, so no vertical line can intersect the graph of a function at more than one point.

!!! example
	The circle ``x^2+y^2=1`` cannot be the graph of a function since some vertical lines intersect it twice. It is, however, the union of the graphs of two functions, namely,
	```math
	y=\sqrt{1-x^2}\ \ \ \ \ \textrm{and}\ \ \ \ \ y=-\sqrt{1-x^2}\,,
	```
	which are, respectively, the upper and the lower halves of the given circle.

{cell=chap display=false output=false}
```julia
Figure("", """The circle <span class="math-tex" data-type="tex">\\(x^2+y^2=1\\)</span> is not the graph of a function.""") do
	Drawing(width=255, height=255) do
		xmid = 125
		ymid = 130
		scale = 100
		axis_xy(255,255,xmid,ymid,scale,(-1,1),(-1,1))
		plot_xy(x->sqrt(1-x^2), -1.0:0.01:1.0, (-1, 1), xmid, ymid, scale)
		plot_xy(x->-sqrt(1-x^2), -1.0:0.01:1.0, tuple(), xmid, ymid, scale; dashed="3")
	end
end
```

## Combining Functions

Functions can be combined in a variety of ways to produce new functions.

Like numbers, functions can be added, subtracted, multiplied, and divided (except when the denominator is zero) to produce new functions.

!!! definition
	If ``f`` and ``g`` are functions, then for every ``x`` that belongs to the domains of both ``f`` and ``g`` we define functions ``f+g``, ``f-g``, ``fg``, and ``\frac{f}{g}`` by the formulas:
	```math
	\begin{aligned}
	\left(f+g\right)(x)&=f(x)+g(x)\\
	\left(f-g\right)(x)&=f(x)-g(x)\\
	\left(fg\right)(x)&=f(x)g(x)\\
	\left(\frac{f}{g}\right)(x)&=\frac{f(x)}{g(x)}\,,\textrm{ where } g(x)\ne0\,.
	\end{aligned}
	```

!!! example
	Draw the graphs of ``f\left(x\right)=x^2``, ``g\left(x\right)=x-1`` and their sum ``\left(f+g\right)(x)=x^2+x+1``. Observe that the height of the graph of ``f+g`` at any point ``x`` is the sum of the heights of the graphs of ``f`` and ``g`` at that point.

{cell=chap display=false output=false}
```julia
Figure("", """<span class="math-tex" data-type="tex">\\(\\left(f+g\\right)(x)=f\\left(x\\right)+g\\left(x\\right)\\)</span>.""") do
	Drawing(width=255, height=255) do
		xmid = 125
		ymid = 130
		scale = 50
		range = -2.0:0.1:2.0
		axis_xy(255,255,xmid,ymid,scale,(-2,-1,1,2),(-2,-1,1,2))
		plot_xy(x->x^2, -sqrt(130/50):0.01:sqrt(130/50), (-1, ), xmid, ymid, scale; color="RoyalBlue")
		plot_xy(x->x-1, -125/50+1:0.01:130/50, (-1,), xmid, ymid, scale; color="green")
		D = sqrt(77/5)
		plot_xy(x->x^2+x-1, 0.5(-1-D):0.01:0.5(-1+D), (-1,), xmid, ymid, scale)
		line(x1=xmid+50*(-1),y1=ymid-50*(-2),x2=xmid+50*(-1),y2=ymid-50*1, stroke="black", stroke_dasharray ="2")
	end
end
```

!!! example
	The functions ``f`` and ``g`` are defined by the formulas 
	```math
	y=\sqrt{x}\ \ \ \ \ \textrm{and}\ \ \ \ \ y=\sqrt{1-x}\,.
	```
	Find formulas for the values of ``3f``, ``f+g``, ``f-g``, ``fg``, ``\frac{f}{g}``, and ``\frac{g}{f}`` at ``x``, and specify the domains of each of these functions.

	|Function|Formula|Domain|
	|:------:|:-----:|:----:|
	|``f``|``f\left(x\right)=\sqrt x``|``\left[0,\infty\right[``|
	|``g``|``g\left(x\right)=\sqrt{1-x}``|``\left]\infty,1\right]``|
	|``3f``|``\left(3f\right)\left(x\right)=3\sqrt{x}``|``\left[0,\infty\right[``|
	|``f+g``|``\left(f+g\right)\left(x\right)=\sqrt{x}+\sqrt{1-x}``|``\left[0,1\right]``|
	|``f-g``|``\left(f-g\right)\left(x\right)=\sqrt{x}-\sqrt{1-x}``|``\left[0,1\right]``|
	|``fg``|``\left(fg\right)\left(x\right)=\sqrt{x(1-x)}``|``\left[0,1\right]``|
	|``\frac{f}{g}``|``\left(\frac{f}{g}\right)\left(x\right)=\sqrt{\frac{x}{1-x}}``|``\left[0,1\right[``|
	|``\frac{g}{f}``|``\left(\frac{g}{f}\right)\left(x\right)=\sqrt{\frac{1-x}{x}}``|``\left]0,1\right]``|

There is another method, called *composition*, by which two functions can be combined to form a new function

!!! definition
	If ``f`` and ``g`` are two functions, the *composite function* ``f\circ g`` is defined by
	```math
	(f\circ g)\left(x\right) = f\left(g\left(x\right)\right)\,.
	```
	The domain of ``f\circ g`` consists of those numbers ``x`` in the domain of ``g`` for which ``g\left(x\right)`` is in the domain of ``f``. In particular, if the range of ``g`` is contained in the domain of ``f``, then the domain of ``f\circ g`` is just the domain of ``g``.

In calculating ``\left(f\circ g\right)\left(x\right)=f\left(g\left(x\right)\right)``, we first calculate ``g\left(x\right)`` and then calculate ``f`` of the result.

!!! example
	Given ``f\left(x\right)=\sqrt x`` and ``g\left(x\right)=x+1`` calculate the following composite functions ``\left(f\circ g\right)``, ``\left(g\circ f\right)``, ``\left(f\circ f\right)``, and ``\left(g\circ g\right)``, and specify the domain of each.

	|Function|Formula|Domain|
	|:------:|:-----:|:----:|
	|``f``|``f\left(x\right)=\sqrt x``|``\left[0,\infty\right[``|
	|``g``|``g\left(x\right)=x+1``|``\mathbb{R}``|
	|``f\circ g``|``\left(f\circ g\right)\left(x\right)=\sqrt{x+1}``|``\left[-1,\infty\right[``|
	|``g\circ f``|``\left(f\circ g\right)\left(x\right)=\sqrt{x}+1``|``\left[0,\infty\right[``|
	|``f\circ f``|``\left(f\circ g\right)\left(x\right)=x^\frac{1}{4}``|``\left[0,\infty\right[``|
	|``g\circ g``|``\left(f\circ g\right)\left(x\right)=x+2``|``\mathbb{R}``|

	To see why, for example, the domain of ``f\circ g`` is ``\left[-1,\infty\right[``, observe that ``g\left(x\right)=x+1`` is defined for all real ``x`` but belongs to the domain of ``f`` only if ``x+1\ge 0``, that is, if ``x\ge -1``.

Sometimes it is necessary to define a function by using different formulas on different parts of its domain. One example is the absolute value function
```math
\newcommand{\abs}{\operatorname{abs}}
\abs\left(x\right)=\left|x\right|=\begin{cases}
\hphantom{-}x&\textrm{if }x\ge0\,,\\
-x&\textrm{if }x<0\,.
\end{cases}
```

!!! example
	The *signum function* is defined as follows:
	```math
	\newcommand{\sgn}{\operatorname{sgn}}
	\sgn\left(x\right)=\frac{x}{\left|x\right|}=\begin{cases}
	\hphantom{-}1&\textrm{if }x>0\,,\\
	-1&\textrm{if }x<0\,,\\
	\textrm{undefined}&\textrm{if }x=0\,.
	\end{cases}
	```

{cell=chap display=false output=false}
```julia
Figure("", """The signum function.""") do
	Drawing(width=255, height=155) do
		xmid = 125
		ymid = 80
		scale = 50
		axis_xy(255,155,xmid,ymid,scale,(-2,-1,1,2),(-1,1))
		plot_xy(x->-1, -2:0, tuple(), xmid, ymid, scale)
		plot_xy(x->1, 0:2, tuple(), xmid, ymid, scale)
		circle(cx=xmid,cy=ymid-scale*(-1),r=3,stroke="red",fill="white")
		circle(cx=xmid,cy=ymid-scale*(1),r=3,stroke="red",fill="white")
	end
end
```

Note how we use a hollow dot in the graphs to indicate which endpoints do not lie on various parts of the graph. Similarly, we use a solid dot to indicate which endpoint do lie on various parts of the graph.

## Inverse Functions

Remember a function ``f`` is bijective if ``f\left(x_1\right)\ne f\left(x_2\right)`` whenever ``x_1`` and ``x_2`` belong to the domain of ``f`` and ``x_1\ne x_2``. So, not only a vertical line intersects the graph of the function in one point, also a horizontal line intersects the graph at only one point.

!!! definition
	If ``f`` is a bijective function, then it has an inverse ``f^{-1}``. The value of ``f^{-1}\left(x\right)`` is the unique member ``y`` in the domain of ``f`` for which ``f\left(y\right)=x``. Thus,
	```math
	y=f^{-1}\left(x\right) \iff x=f\left(y\right)\,.
	```

There are several things you should remember about the relation between a function ``f`` and its inverse ``f^{-1}``:
1. The domain of ``f^{-1}`` is the range of ``f``.
2. The range of ``f^{-1}`` is the domain of ``f``.
3. ``\left(f^{-1}\circ f\right)\left(x\right)=f^{-1}(f\left(x\right))=x`` for all ``x`` in the domain of ``f``.
4. ``\left(f\circ f^{-1}\right)\left(x\right)=f\left(f^{-1}\left(x\right)\right)=x`` for all ``x`` in the domain of ``f^{-1}``.
5. ``\left(f^{-1}\right)^{-1}\left(x\right)=f\left(x\right)``  for all ``x`` in the domain of ``f``.
6. The graph of ``f^{-1}`` is the reflection of the graph of ``f`` in the line ``x=y``.

!!! example
	Show that ``g\left(x\right)=\sqrt{2x+1}`` is invertible and find its inverse.

	If ``g(x_1)=g(x_2)`` then ``\sqrt{2x_1+1}=\sqrt{2x_2+1}``. Squaring both sides we get ``2x_1+1=2x_2+1``, which implies ``x_1=x_2``. Thus ``g`` is bijective and invertible.

	Let ``y=g^{-1}\left(x\right)`` then ``x=g\left(y\right)=\sqrt{2y+1}``. It follows that ``x\ge 0`` and ``x^2 = 2y+1``. Therefore, ``y=\frac{x^2-1}{2}`` and
	```math
	g^{-1}\left(x\right)=\frac{x^2-1}{2}\quad\textrm{for }x\ge0\,.
	```

{cell=chap display=false output=false}
```julia
Figure("", """The graphs of <span class="math-tex" data-type="tex">\\(g\\)</span> in red and its inverse in blue.""") do
	Drawing(width=255, height=255) do
		xmid = 50
		ymid = 200
		scale = 50
		axis_xy(255,255,xmid,ymid,scale,(1, 2, 3),(1, 2, 3))
		plot_xy(x->sqrt(2*x+1), -0.5:0.01:4.0, tuple(), xmid, ymid, scale)
		plot_xy(x->0.5(x^2-1), 0:0.01:3.0, tuple(), xmid, ymid, scale; color="RoyalBlue")
		line(x1=xmid-scale,y1=ymid+scale,x2=xmid+4scale,y2=ymid-4scale,stroke="green",stroke_dasharray=3)
	end
end
```

Many important functions are not bijective on their whole domain. It is possible to define an inverse for such a function, but we have to restrict the domain of the function artificially so that the restricted function is bijective.

!!! example
	Consider the function ``f\left(x\right)=x^2``. Unrestricted, its domain is the whole real line and it is not bijective since ``f\left(-a\right)=f\left(a\right)`` for any ``a``. Let us define a new function ``F\left(x\right)`` equal to ``f\left(x\right)`` but having a smaller domain, so that it is bijective:
	```math
	F:\left[0,\infty[\to\right[0,\infty[:x\mapsto x^2\,.
	```
	``F`` is bijective, so it has an inverse ``F^{-1}``. Let ``y=F^{-1}\left(x\right)``, then ``x=F\left(y\right)=y^2`` and ``y\ge 0``. Thus, ``y=\sqrt x``. Hence,
	```math
	F:\left[0,\infty[\to\right[0,\infty[:x\mapsto\sqrt x\,.
	```

{cell=chap display=false output=false}
```julia
Figure("", """The graphs of <span class="math-tex" data-type="tex">\\(F\\)</span> in red and its inverse in blue.""") do
	Drawing(width=250, height=130) do
		xmid = 125
		ymid = 115
		scale = 50
		axis_xy(500,250,xmid,ymid,scale,(-2, -1, 1, 2),(1, 2))
		right = sqrt(230/100)
		plot_xy(x->x^2, 0:0.01:right, tuple(), xmid, ymid, scale)
		plot_xy(x->x^2, -right:0.01:0, tuple(), xmid, ymid, scale, dashed="2")
		plot_xy(x->sqrt(x), 0:0.01:250/100, tuple(), xmid, ymid, scale; color="RoyalBlue")
		line(x1=xmid-10,y1=ymid+10,x2=xmid+115,y2=ymid-ymid,stroke="green",stroke_dasharray=3)
	end
end
```

## Polynomial and Rational Functions

Among the easiest functions to deal with in calculus are *polynomials*.

!!! definition
	A polynomial is a function ``P`` whose value at ``x`` is
	```math
	P\left(x\right)=a_nx^n+a_{n-1}x^{n-1}+\cdots+a_2x^2+a_1x+a_0\,,
	```
	where ``a_n``, ``a_{n-1}``, ``\ldots``, ``a_2``, ``a_1``, and ``a_0`` called the *coefficients* of the polynomial, are constants and, if ``n>0``, then ``a_n\ne0``. The number ``n``, the degree of the highest power of ``x`` in the polynomial, is called the *degree* of the polynomial.

Polynomials play a role in the study of functions somewhat analogous to the role played by integers in the study of numbers.

The following definition is analogous to the definition of a rational number as the quotient of two integers.

!!! definition
	If ``P\left(x\right)`` and ``Q\left(x\right)`` are two polynomials and ``Q\left(x\right)`` is not the zero polynomial the the function
	```math
	R\left(x\right)=\frac{P\left(x\right)}{Q\left(x\right)}
	```
	is called a *rational function*. By the domain convention, the domain of ``R\left(x\right)`` consists of all real numbers ``x`` except those for which ``Q\left(x\right)=0``.

!!! example
	```math
	R\left(x\right)=\frac{2x^3-3x^2+3x+4}{x^2+1}\textrm{ with domain }\mathbb{R}\,.
	```
	```math
	S\left(x\right)=\frac{1}{x^2-4}\textrm{ with domain all real numbers except }\pm 2\,.
	```

If the numerator and the denominator of a rational function have a common factor, that factor can be cancelled out just as with integers. However, the resulting simpler rational function may not have the same domain as the orginal one, so it should be regarded as a different rational function even though it is equal to the orginal one at all points of the original domain.

!!! example
	```math
	\frac{x^2-x}{x^2-1}=\frac{x\left(x-1\right)}{\left(x+1\right)\left(x-1\right)}=\frac{x}{x+1}\ \ \ \textrm{only if }x\ne\pm 1
	```
	even though ``x=1`` is in the domain of ``\frac{x}{x+1}``.

## Trigonometric Functions

Most students first encounter the quantities ``\cos t`` and ``\sin t`` as ratios of sides in a right-angled triangle having ``t`` as one of the acute angles. If the sides of the triangle are labelled "``\textrm{hyp}``" for hypotenuse, "``\textrm{adj}``" for the side adjacant to angle ``t``, and "``\textrm{opp}``" for the side opposite angle ``t``, then
```math
\cos t =\frac{\textrm{adj}}{\textrm{hyp}}\ \ \ \ \ \textrm{and}\ \ \ \ \ \sin t =\frac{\textrm{opp}}{\textrm{hyp}}
```
These ratios depend only on the angle ``t``, not on the particular triangle, since all right-angled triangles having an acute angle ``t`` are similar.

{cell=chap display=false output=false}
```julia
Figure("", """Basic definition of sinus and cosinus.""") do
	Drawing(width=255, height=155) do
		defs() do
			marker(id="arrow", markerWidth="6", markerHeight="6", refX="3", refY="3", orient="auto") do
				path(d="M 0 0 L 6 3 L 0 6 z", fill="black" )
			end
		end
		line(x1=10,y1=130,x2=220,y2=130,stroke="black")
		line(x1=10,y1=130,x2=220,y2=20,stroke="black")
		line(x1=220,y1=130,x2=220,y2=20,stroke="black")
		latex("\\textrm{adj}", x=110-2, y=150-font_y, width=3*font_x, height=font_y)
		latex("\\textrm{hyp}", x=95, y=60-font_y, width=3*font_x, height=font_y)
		latex("\\textrm{opp}", x=230-font_x, y=80-font_y/2-2, width=3*font_x, height=font_y)
		path(d="M 70,130 A 60 60 0 0 0 63,106", stroke="black", fill="none", marker_end="url(#arrow)")
		latex("t", x=82-font_x, y=115-font_y/2-2, width=font_x, height=font_y)
	end
end
```

In calculus we need more general definitions of ``\cos t`` and ``\sin t`` as functions defined for all real numbers ``t``, not just acute angles.

Let ``C`` be the circle with centre at the origin ``O`` and radius ``1``; its equation is ``x^2+y^2=1``. Let ``A`` be the point ``\left(1,0\right)`` on ``C``. For any real number ``t``, let ``P_t`` be the point on ``C`` at distance ``\left|t\right|`` from ``A``, measured along ``C`` in the counterclockwise direction if ``t>0`` and the clockwise direction if ``t<0``. For example, since ``C`` has circumference ``2\textup{π} ``, the point ``P_{\textup{π} /2}`` is one-quarter of the way counterclockwise around ``C`` from ``A``; it is the point ``\left(0,1\right)``.

{cell=chap display=false output=false}
```julia
Figure("", """Definition of cosine and sine.""") do
	Drawing(width=300, height=255) do
		xmid = 130
		ymid = 135
		scale = 100
		axis_xy(270,255,xmid,ymid,scale,(-1,1),(-1,1))
		plot_xy(x->sqrt(1-x^2), -1.0:0.01:1.0, (-1, 0, 1), xmid, ymid, scale, width=1)
		plot_xy(x->sqrt(1-x^2), cos(pi/3):0.01:1.0, tuple(), xmid, ymid, scale; width=2)
		plot_xy(x->-sqrt(1-x^2), -1.0:0.01:1.0, tuple(0), xmid, ymid, scale, width=1)
		plot_xy(x->tan(pi/3)*x, 0:0.1:cos(pi/3), tuple(cos(pi/3)), xmid, ymid, scale; width=2)
		latex("1", x=xmid+scale/5-font_x, y=ymid-scale/2-font_y/2, width=font_x, height=font_y)
		latex("t\\,\\left[\\textrm{arc length}\\right]", x=xmid+scale-font_x, y=ymid-scale/2-font_y/2, width=6font_x, height=font_y)
		path(d="M $(xmid+scale/3),$ymid A $(scale/3) $(scale/3) 0 0 0 $(xmid+cos(pi/3)*scale/3+2),$(ymid-sin(pi/3)*scale/3+5)", stroke="black", fill="none", marker_end="url(#arrow)")
		latex("t\\,\\left[\\textrm{rad}\\right]", x=xmid+scale/3-font_x, y=ymid-scale/6-font_y, width=4font_x, height=font_y)
		latex("A", x=xmid+scale+5, y=ymid-font_y-2, width=font_x, height=font_y)
		latex("P_t=\\left(\\cos t, \\sin t\\right)", x=xmid+scale*cos(pi/3)-5, y=ymid-scale*sin(pi/3)-font_y, width=8*font_x, height=font_y)
		latex("P_\\textup{π} ", x=xmid-scale-2font_x, y=ymid-font_y-2, width=2font_x, height=font_y)
		latex("P_{\\textup{π} /2}", x=xmid+7, y=ymid-scale-font_y/2-10, width=2font_x, height=font_y)
		latex("P_{-\\textup{π} /2}", x=xmid+5, y=ymid+scale, width=3font_x, height=font_y)
	end
end
```

!!! definition
	The *radian measure* of ``\angle AOP_t`` is ``t`` radians.

In calculus it is assumed that all angles are measured in radians unless degrees or other units are stated explicitly. When we talk about the angle ``\frac{\textup{π} }{3}`` we mean ``\frac{\textup{π} }{3}`` radians (which is ``60°``), not ``\frac{\textup{π} }{3}`` degrees.

!!! example
	*Arc length* and *sector area*.

	An arc of a circle of radius ``r`` subtends an angle ``t`` at the centre of the circle. Find the length ``s`` of the arc and the area ``A`` of the sector lying between the arc and the centre of the circle.

	The length ``s`` of the arc is the same fraction of the circumference ``2\textup{π}  r`` of the circle that the angle ``t`` is to a complete revolution ``2\textup{π} `` radians. Thus,
	```math
	s=\frac{t}{2\textup{π} }(2\textup{π}  r)=rt\,.
	```
	Similarly, the area ``A`` of the circular sector is the same fraction of the area ``\textup{π}  r^2`` of the whole circle:
	```math
	A=\frac{t}{2\textup{π} }(\textup{π}  r^2)=\frac{r^2t}{2}\,.
	```

Using the procedure described above, we can find the point ``P_t`` corresponding to any real number ``t``.

!!! definition
	For any real ``t``, the *cosine* of ``t`` denoted by ``\cos t`` and the *sine* of ``t`` denoted by ``\sin t`` are the ``x``- and the ``y``-coordinates of the point ``P_t``.

Because they are defined this way, cosine and sine are often called the *circular functions*. Note that these definitions agree with the ones given earlier for an acute angle.

Many important properties of ``\cos t`` and ``\sin t`` follow from the fact that they are coordinates of the point ``P_t`` on the circle ``C`` with equation ``x^2+y^2=1``.

!!! theorem
	Let ``t\in\mathbb{R}``.
	1. ``-1\le\cos t\le 1`` and ``-1\le\sin t\le 1``
	2. ``\cos^2 t+\sin^2 t=1`` (Pythagorean identity)
	3. ``\cos(t+2\textup{π} )=\cos t`` and ``\sin(t+2\textup{π} )=\sin t`` (periodicity)
	4. ``\cos(-t)=\cos(t)`` and ``\sin(-t)=-\sin t`` (cosine is an *even* function, sine is an *odd* function)
	5. ``\cos\left(\frac{\textup{π} }{2}-t\right)=\sin t`` and ``\sin\left(\frac{\textup{π} }{2}-t\right)=\cos t`` (*complementary angles*, symmetry about ``y=x``)
	6. ``\cos(\textup{π} -t)=-\cos(t)`` and ``\sin(\textup{π} -t)=\sin t`` (*supplementary angles*, symmetry about ``x=0``)

The next table summarizes the most important values of cosine and sine.

|Radians|``0``|``\frac{\textup{π} }{6}``|``\frac{\textup{π} }{4}``|``\frac{\textup{π} }{3}``|``\frac{\textup{π} }{2}``|``\frac{2\textup{π} }{3}``|``\frac{3\textup{π} }{4}``|``\frac{5\textup{π} }{6}``|``\textup{π} ``|
|:------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
|Cosine|``1``|``\frac{\sqrt 3}{2}``|``\frac{\sqrt 2}{2}``|``\frac{1}{2}``|``0``|``-\frac{1}{2}``|``-\frac{\sqrt 2}{2}``|``-\frac{\sqrt 3}{2}``|``-1``|
|Sine|``0``|``\frac{1}{2}``|``\frac{\sqrt 2}{2}``|``\frac{\sqrt 3}{2}``|``1``|``\frac{\sqrt 3}{2}``|``\frac{\sqrt 2}{2}``|``\frac{1}{2}``|``0``|

Observe that the graph of ``\sin x`` is the graph of ``\cos x`` shifted to the right a distance ``\frac{\textup{π} }{2}``.

{cell=chap display=false output=false}
```julia
Figure("", """The graph of the cosine function in red and the sine function in blue.""") do
	Drawing(width=625, height=155) do
		xmid = 300
		ymid = 80
		scale = 50
		axis_xy(625,155,xmid,ymid,scale,(-3pi/2,-pi,-pi/2,pi/2,pi,3pi/2,2pi),(-1,1),xs=("-\\frac{3\\textup{π} }{2}","-\\textup{π} ","-\\frac{\\textup{π} }{2}","\\frac{\\textup{π} }{2}","\\textup{π} ","\\frac{3\\textup{π} }{2}","2\\textup{π} "), xl=(3, 2, 2, 1, 1, 2, 2), xh=(2,1,2,2,1,2,1))
		plot_xy(x->cos(x), -6:0.01:7, tuple(), xmid, ymid, scale)
		plot_xy(x->sin(x), -6:0.01:7, tuple(), xmid, ymid, scale; color="RoyalBlue")
	end
end
```

The following formulas enable us to determine the cosine and sine of a sum or difference of two angles in terms of the cosines and sines of those angles.

!!! theorem
	Let ``s,t\in\mathbb{R}``.
	```math
	\begin{aligned}
	\cos\left(s+t\right)&=\cos s\,\cos t-\sin s\,\sin t\\
	\sin\left(s+t\right)&=\sin s\,\cos t+\cos s\,\sin t\\
	\cos\left(s-t\right)&=\cos s\,\cos t+\sin s\,\sin t\\
	\sin\left(s-t\right)&=\sin s\,\cos t-\cos s\,\sin t\\
	\end{aligned}
	```

!!! proof
	Let ``s,t\in\mathbb{R}`` and consider the points
	```math
	\begin{alignedat}{3}
	P_t&=\left(\cos t,\sin t\right)\ \ \ \ \ &P_{s-t}&=\left(\cos\left(s-t\right),\sin\left(s-t\right)\right)\\
	P_s&=\left(\cos s,\sin s\right)\ \ \ \ \ &A&=\left(1,0\right)\,.
	\end{alignedat}
	```
	The angle ``\angle P_tOP_s=s-t=\angle AOP_{s-t}``, so the distance ``P_sP_t`` is equal to the distance ``P_{s-t}A``. 

	Therefore, ``\left(P_sP_t\right)^2=\left(P_{s-t}A\right)^2``:
	```math
	\left(\cos s-\cos t\right)^2+\left(\sin s-\sin t\right)^2=\left(\cos\left(s-t\right)-1\right)^2+\sin^2\left(s-t\right)\,,
	```
	```math
	\begin{gathered}
	\cos^2s- 2\cos s\,\cos t+\cos^2t+\sin^2s-2\sin s\,\sin t+\sin^2 t\\
	=\cos^2\left(s-t\right)-2\cos\left(s-t\right)+1+\sin^2\left(s-t\right)\,.
	\end{gathered}
	```
	Since ``\cos^2x+\sin^2x=1``, this reduces to ``\cos\left(s-t\right)=\cos s\,\cos t+\sin s\,\sin t``.

!!! exercise
	Prove the other formulas using the even/odd behavior of the cosine and sine functions and the complementary angles relations.

From the addition formulas, we obtain as special cases certain useful formulas called *double-angle formulas*.

!!! corollary
	Let ``t\in\mathbb{R}``.
	1. ``\sin 2t=2\sin t\,\cos t`` and
	2. ``\cos 2t=\cos^2t-\sin^2t=2\cos^2t-1=1-2\sin^2t``.

Solving the last two formulas for ``\cos^2t`` and ``\sin^2t``, we obtain
```math
\cos^2t=\frac{1+\cos2t}{2}\ \ \ \ \ \textrm{and}\ \ \ \ \ \sin^2t=\frac{1-\cos2t}{2}\,,
```
which are sometimes calles the *half-angle formulas*.

There are four other trigonometric functions, each defined in terms of cosine and sine.

!!! definition
	```math
	\tan:\mathbb{R}\setminus\left\{\frac{\mathrm{π}}{2}+k\mathrm{π}\mid k\in \mathbb{Z}\right\}\to \mathbb{R}:x\mapsto\frac{\sin x}{\cos x}\quad\textrm{(tangent)}
	```
	```math
	\cot:\mathbb{R}\setminus\left\{k\mathrm{π}\mid k\in \mathbb{Z}\right\}\to \mathbb{R}:x\mapsto\frac{\cos x}{\sin x}\quad\textrm{(cotangent)}
	```
	```math
	\sec:\mathbb{R}\setminus\left\{\frac{\mathrm{π}}{2}+k\mathrm{π}\mid k\in \mathbb{Z}\right\}\to \mathbb{R}:x\mapsto\frac{1}{\cos x}\quad\textrm{(secans)}
	```
	```math
	\csc:\mathbb{R}\setminus\left\{k\mathrm{π}\mid k\in \mathbb{Z}\right\}\to \mathbb{R}:x\mapsto\frac{1}{\sin x}\quad\textrm{(cosecans)}
	```

{cell=chap display=false output=false}
```julia
Figure("", """The graph of the tangent function in red and the cotangent function in blue.""") do
	Drawing(width=470, height=255) do
		xmid = 240
		ymid = 130
		scale = 50
		axis_xy(470,255,xmid,ymid,scale,(-pi,-pi/2,pi/2,pi),(-2,-1,1,2), xs=("-\\textup{π} ","-\\frac{\\textup{π} }{2}","\\frac{\\textup{π} }{2}","\\textup{π} ","\\frac{3\\textup{π} }{2}"), xl=(2, 2, 1, 1, 2), xh=(1,2,2,1,2))
		top = atan(130/50)
		bottom = -atan(125/50)
		plot_xy(x->sin(x)/cos(x), bottom-pi:0.01:top-pi, tuple(), xmid, ymid, scale)
		line(x1=xmid-scale*pi/2, y1=0, x2=xmid-scale*pi/2, y2=255, stroke="red", stroke_dasharray ="2")
		plot_xy(x->sin(x)/cos(x), bottom:0.01:top, tuple(), xmid, ymid, scale)
		line(x1=xmid+scale*pi/2, y1=0, x2=xmid+scale*pi/2, y2=255, stroke="red", stroke_dasharray ="2")
		plot_xy(x->sin(x)/cos(x), bottom+pi:0.01:top+pi, tuple(), xmid, ymid, scale)
		top = acot(130/50)
		bottom = acot(-125/50)
		plot_xy(x->cos(x)/sin(x), -240/50:0.01:bottom-pi, tuple(), xmid, ymid, scale; color="RoyalBlue")
		line(x1=xmid-scale*pi, y1=0, x2=xmid-scale*pi, y2=255, stroke="RoyalBlue", stroke_dasharray ="2")
		plot_xy(x->cos(x)/sin(x), top-pi:0.01:bottom, tuple(), xmid, ymid, scale; color="RoyalBlue")
		plot_xy(x->cos(x)/sin(x), top:0.01:bottom+pi, tuple(), xmid, ymid, scale; color="RoyalBlue")
		line(x1=xmid+scale*pi, y1=0, x2=xmid+scale*pi, y2=255, stroke="RoyalBlue", stroke_dasharray ="2")
		plot_xy(x->cos(x)/sin(x), top+pi:0.01:230/50, tuple(), xmid, ymid, scale; color="RoyalBlue")
	end
end
```

{cell=chap display=false output=false}
```julia
Figure("", """The graph of the secans function in red and the cosecans function in blue.""") do
	Drawing(width=470, height=260) do
		xmid = 240
		ymid = 130
		scale = 50
		axis_xy(470,260,xmid,ymid,scale,(-pi,-pi/2,pi/2,pi),(-2,-1,1,2),xs=("-\\textup{π} ","-\\frac{\\textup{π} }{2}","\\frac{\\textup{π} }{2}","\\textup{π} ","\\frac{3\\textup{π} }{2}"), xl=(2, 2, 1, 1, 2), xh=(1,2,2,1,2))
		right = acos(50/130)
		left = -right
		plot_xy(x->1/cos(x), left-pi:0.01:right-pi, tuple(), xmid, ymid, scale)
		line(x1=xmid-scale*pi/2, y1=0, x2=xmid-scale*pi/2, y2=260, stroke="red", stroke_dasharray ="2")
		plot_xy(x->1/cos(x), left:0.01:right, tuple(), xmid, ymid, scale)
		line(x1=xmid+scale*pi/2, y1=0, x2=xmid+scale*pi/2, y2=260, stroke="red", stroke_dasharray ="2")
		plot_xy(x->1/cos(x), left+pi:0.01:right+pi, tuple(), xmid, ymid, scale)
		left = asin(50/130)
		right = pi-left
		plot_xy(x->1/sin(x), -240/50:0.01:right-2pi, tuple(), xmid, ymid, scale; color="RoyalBlue")
		line(x1=xmid-scale*pi, y1=0, x2=xmid-scale*pi, y2=260, stroke="RoyalBlue", stroke_dasharray ="2")
		plot_xy(x->1/sin(x), left-pi:0.01:right-pi, tuple(), xmid, ymid, scale; color="RoyalBlue")
		plot_xy(x->1/sin(x), left:0.01:right, tuple(), xmid, ymid, scale; color="RoyalBlue")
		line(x1=xmid+scale*pi, y1=0, x2=xmid+scale*pi, y2=260, stroke="RoyalBlue", stroke_dasharray ="2")
		plot_xy(x->1/sin(x), left+pi:0.01:230/50, tuple(), xmid, ymid, scale; color="RoyalBlue")
	end
end
```

Observe that each of these functions is undefined (and its graph approaches vertical asymptotes) at points where the function in the denominator of its defining fraction has values ``0``.