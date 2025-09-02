+++
title = "Exams Real Calculus"
output = "exams.html"
+++

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 1

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

Prove using the formal definition of the limit of a function that ``\displaystyle \lim_{x\to 1} \frac{1}{x - 1}`` does not exist.

## Do some calculations!

Prove

```math
1^3+2^3+\cdots+n^3=\left(1+2+\cdots+n\right)^2\,.
```

{class = pagebreak}
## Explain the proof!

If ``f\left(u\right)`` is differentiable at ``u=g\left(x\right)``, and ``g\left(x\right)`` is differentiable at ``x``, then the composite function ``f\circ g\left(x\right)=f\left(g\left(x\right)\right)`` is differentiable at ``x``, and

```math
\left(f\circ g\right)^\prime=f\prime\left(g\left(x\right)\right)g\prime\left(x\right)
```

!!! proof
	Suppose that ``f`` is differentiable at the point ``u=g\left(x\right)`` and that ``g`` is differentiable at ``x``.

	Let the function ``E\left(k\right)`` be defined by
	```math
	E\left(k\right)=\begin{cases}
	0&\textrm{if }k=0\,.\\
	\frac{f\left(u+k\right)-f\left(u\right)}{k}-f\prime\left(u\right)&\textrm{if }k\ne0\,.
	\end{cases}
	```

	By the definition of derivative
	```math
	\lim_{k\to 0}E\left(k\right)=f\prime\left(u\right)-f\prime\left(u\right)=0=E\left(0\right)\,,
	```
	so ``E\left(k\right)`` is continuous at ``k=0``. Also, whether ``k=0`` or not, we have
	```math
	f\left(u+k\right)-f\left(u\right)=\left(f\prime\left(u\right)+E\left(k\right)\right)k\,.
	```
	Now put ``u=g\left(x\right)`` and ``k=g\left(x+h\right)-g\left(x\right)``, so that ``u+k=g\left(x+h\right)``, and obtain
	```math
	f\left(g\left(x+h\right)\right)-f\left(g\left(x\right)\right)=\left(f\prime\left(g\left(x\right)\right)+E\left(k\right)\right)\left(g\left(x+h\right)-g\left(x\right)\right)\,.
	```
	Since ``g`` is differentiable at ``x``,
	```math
	\lim_{h\to 0}\frac{g\left(x+h\right)-g\left(x\right)}{h}=g\prime\left(x\right)\,.
	```
	Also, ``g`` is continuous at ``x``, so 
	```math
	\lim_{h\to 0}k=\lim_{h\to 0}\left(g\left(x+h\right)-g\left(x\right)\right)=0\,.
	```
	Since ``E`` is continuous at ``0``, 
	```math
	\lim_{h\to 0}E\left(k\right)=\lim_{k\to 0}E\left(k\right)=E\left(0\right)=0\,.
	```
	Hence,
	```math
	\begin{aligned}
	\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}f\left(g\left(x\right)\right)&=\lim_{h\to 0}\frac{f\left(g\left(x\right)\right)-f\left(g\left(x+h\right)\right)}{h}\\
	&= \left(f\prime\left(g\left(x\right)\right)+E\left(k\right)\right)\frac{g\left(x+h\right)-g\left(x\right)}{h}\\
	&=\left(f\prime\left(g\left(x\right)\right)+0\right)g\prime\left(x\right)=f\prime\left(g\left(x\right)\right)g\prime\left(x\right)\,,
	\end{aligned}
	```
	which was to be proved.

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 2

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

Prove that if ``f`` is continuous at ``a``, then for any ``\varepsilon &gt; 0`` there is a ``\delta &gt;0`` so that whenever ``\left|x - a\right| &lt;\delta`` and ``\left|y - a\right| &lt;\delta``, we have ``\left|f\left(x\right) - f\left(y\right)\right| &lt;\varepsilon``.

## Do some calculations!

Prove that ``\sqrt 3`` is irrational. Hint: use the fact that every integer is of the form ``3n``, ``3n+1`` or ``3n+2``. Why doesn't this proof work for ``\sqrt 4``.

{class = pagebreak}
## Explain the proof!

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

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 3

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

Suppose that ``f`` satisfies ``f\left(x + y\right) = f\left(x\right) + f\left(y\right)``, and that ``f`` is continuous at ``0``. Prove that ``f`` is continuous at ``a`` for all ``a``.

## Do some calculations!

Prove or give a counterexample for each of the following assertions:

1. ``f\circ\left(g+h\right)=f\circ g+f\circ h\,.``

2. ``\left(g+h\right)\circ f=g\circ f+h\circ f\,.``

3. ``\displaystyle\frac{1}{f\circ g}=\frac{1}{f}\circ g\,.``

4. ``\displaystyle\frac{1}{f\circ g}=f\circ \frac{1}{g}\,.``

{class = pagebreak}
## Explain the proof!

If ``P`` and ``P^\prime`` are two partitions of ``\left[a,b\right]``, then ``L\left(f,P\right)\le U\left(f,P^\star\right)``.

!!! proof

	Combine the subdivision points of ``P`` and ``P^\prime`` to form a new partition ``P^\star``, which is a refinement of both ``P`` and ``P^\prime``. Then,

	```math
	L\left(f,P\right)\le L\left(f,P^\star\right)\le U\left(f,P^\star\right)\le U\left(f,P^\prime\right)\,.
	```

	No lower sum can exceed any upper sum.

``I_\star\le I^\star``.

!!! proof "by contradiction"

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


{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 4

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

Suppose that ``f`` is a continuous function on ``\left[0, 1\right]`` and that ``f\left(x\right)`` is in ``\left[0, 1\right]`` for each ``x`` (draw a picture). Prove that ``f\left(x\right) = x`` for some number ``x``.

## Do some calculations!

Describe the graph of ``g`` in terms of the graph of ``f`` if

1. ``g\left(x\right)=f\left(x\right)+c\,.``

2. ``g\left(x\right)=f\left(x+c\right)\,.``

3. ``g\left(x\right)=cf\left(x\right)\,.``

4. ``g\left(x\right)=f\left(cx\right)\,.``

5. ``\displaystyle g\left(x\right)=f\left(\frac{1}{x}\right)\,.``

{class = pagebreak}
## Explain the proof!

The bounded function ``f`` is integrable on ``\left[a,b\right]`` if and only if for every positive number ``\varepsilon`` there exists a partition ``P`` of ``\left[a,b\right]`` such that ``U\left(f,P\right)-L\left(f,P\right)&lt;\varepsilon``.

!!! proof

	Suppose that for every ``\varepsilon &gt;0`` there exists a partition ``P`` of ``\left[a,b\right]`` such that ``U\left(f,P\right)-L\left(f,P\right)&lt;\varepsilon``, then

	```math
	I^\star\le U\left(f,P\right)&lt;L\left(f, P\right)+\varepsilon\le I_\star +\varepsilon
	```

	Since ``I^\star&lt; I_\star +\varepsilon`` must hold for every ``\varepsilon &gt;0``, it follows that ``I^\star\le I_\star``. Since we already know that ``I_\star\le I^\star``, we have ``I_\star= I^\star`` and ``f`` is integrable on ``\left[a,b\right]``.

	Conversely, if ``I_\star= I^\star`` and ``\varepsilon &gt;0`` are given, we can find a partition ``P^\prime`` such that ``L\left(f,P^\prime\right)&gt;I_\star-\frac{\varepsilon}{2}``, and another partition ``P^{\prime\prime}`` such that ``U\left(f,P^{\prime\prime}\right)&lt;I^\star+\frac{\varepsilon}{2}``. If ``P`` is a common refinement of ``P^\prime`` and ``P^{\prime\prime}``, then we have that

	```math
	U\left(f,P\right)-L\left(f, P\right)\le U\left(f,P^{\prime\prime}\right)-L\left(f, P^\prime\right)&lt;\frac{\varepsilon}{2}+\frac{\varepsilon}{2}=\varepsilon\,,
	```

	as required.

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 5

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

Suppose that ``f`` is differentiable at ``x``. Prove that

```math
f^\prime\left(x\right)=\lim_{h\to 0}\frac{f\left(x+h\right)-f\left(x-h\right)}{2h}\,.
```

Hint: Remember an old algebraic trick — a number is not changed if the same quantity is added to and then subtracted from it.

## Do some calculations!

Describe the graph of ``g`` in terms of the graph of ``f`` if

1. ``g\left(x\right)=f\left(\left|x\right|\right)\,.``

2. ``g\left(x\right)=\left|f\left(x\right)\right|\,.``

3. ``g\left(x\right)=\max\left(f\left(x\right),0\right)\,.``

4. ``g\left(x\right)=\min\left(f\left(x\right),0\right)\,.``

5. ``g\left(x\right)=\max\left(f\left(x\right),1\right)\,.``

{class = pagebreak}
## Explain the proof!

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

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 6

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

1. Suppose that ``f\left(a\right) = g\left(a\right) = h\left(a\right)``, that ``f\left(x\right)\le g\left(x\right)\le h\left(x\right)`` for all ``x``, and that ``f^\prime\left(a\right) = h^\prime\left(a\right)``. Prove that ``g`` is differentiable at ``a``, and that ``f^\prime\left(a\right) = g^\prime\left(a\right) = h^\prime\left(a\right)``. (Begin with the definition of ``g^\prime\left(a\right)``.)

2. Show that the conclusion does not follow if we omit the hypothesis ``f\left(a\right) = g\left(a\right) = h\left(a\right)``.

## Do some calculations!

Determine the limit ``L`` for the given ``a``, and prove that it is the limit by showing how to find a ``\delta`` such that ``\left|f\left(x\right) - L\right| &lt; \varepsilon`` for all ``x`` satisfying ``0 &lt; \left|x-a\right| &lt; \delta``.

1. ``f\left(x\right)=x^2+5x-2,\,a=2\,.``

2. ``f\left(x\right)=\sqrt{\left|x\right|},\,a=0\,.``

{class = pagebreak}
## Explain the proof!

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

	By the Intermediate-Value theorem, ``f\left(x\right)`` must take on every value between the two values ``f\left(l\right)`` and ``f\left(u\right)``. Hence, there is a number ``c`` between ``l`` and ``u`` such that

	```math
	f\left(c\right)=\frac{1}{b-a}\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x\,.
	```

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 7

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

1. Prove that if ``f`` is differentiable at ``a``, then ``\left|f\right|`` is also differentiable at ``a``, provided that ``f\left(a\right) \ne 0``.

2. Give a counterexample if ``f\left(a\right) = 0``

## Do some calculations!

Determine the limit ``L`` for the given ``a``, and prove that it is the limit by showing how to find a ``\delta`` such that ``\left|f\left(x\right) - L\right| &lt; \varepsilon`` for all ``x`` satisfying ``0 &lt; \left|x-a\right| &lt; \delta``.

1. ``\displaystyle f\left(x\right)=\frac{100}{x}\,a=1\,.``

2. ``f\left(x\right)=\sqrt{x},\,a=1\,.``

{class = pagebreak}
## Explain the proof!

!!! theorem "Heine-Borel Theorem"

	Let ``\left[a,b\right]`` be a closed interval and ``𝒪=\left\{\left]c_i, d_i\right[\mid i\in I\right\}`` be an infinite set of open intervals. If ``\left[a,b\right]\subset\bigcup_{i\in I}\left]c_i, d_i\right[``, then there exists ``n\in \mathbb{N}`` such that ``\left[a,b\right]\subset\bigcup_{k=0}^n\left]c_{i_k}, d_{i_k}\right[``.

This theorem is used in the proof of the following theorem.

If ``f`` is continous on ``\left[a,b\right]``, then ``f`` is bounded on ``\left[a,b\right]``.

!!! proof

    For each ``x \in \left[a, b\right]``, since ``f`` is continuous at ``x``, there exists an open interval ``I_x=\left]x-\delta_x, x+\delta_x\right[`` such that for all ``y \in I_x \cap \left[a, b\right]`` we have ``\left|f\left(y\right) - f\left(x\right)\right| &lt; 1``.

    The set of all such open intervals ``I_x`` forms an open cover of ``\left[a,b\right]``.

    By the Heine-Borel theorem there exists a finite subcover such that ``\left[a,b\right]\subset\bigcup_{i=0}^nI_{x_i}``.

    For any point ``y \in \left[a, b\right]``, ``y`` must be in at least one of the intervals ``I_{x_i}=\left]x_i-\delta_{x_i}, x_i+\delta_{x_i}\right[``. Let's say ``y\in\left]x_j-\delta_{x_j}, x_j+\delta_{x_j}\right[``.

    By the property of the open interval ``\left]x_j-\delta_{x_j}, x_j+\delta_{x_j}\right[``, we know that ``\left|f\left(y\right) - f\left(x_j\right)\right| &lt; 1``, i.e. ``f\left(y\right) &lt; f\left(x_j\right) + 1`` and ``f\left(y\right) &gt; f\left(x_j\right) - 1``.

    Let ``M = \max\left\{f\left(x_i\right) |0\le i\le n\right\}+ 1`` and ``m = \min\left\{f\left(x_i\right) |0\le i\le n\right\}- 1``.

    We can conclude that for all ``y \in \left[a, b\right]`` we have ``m &lt; f\left(y\right) &lt; M``.

    Therefore, ``f`` is bounded on ``\left[a,b\right]``, with ``m`` as a lower bound and ``M`` as an upper bound.

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 8

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

Prove the following (which we often use implicitly): If ``f`` is increasing on ``\left]a, b\right[`` and continuous at ``a`` and ``b``, then ``f`` is increasing on ``\left[a,b\right]``. In particular, if ``f`` is continuous on ``\left[a, b\right]`` and ``f^\prime &gt; 0`` on ``\left]a, b\right[``, then ``f`` is increasing on ``\left[a, b\right]``.

## Do some calculations!

Give examples to show that the following definitions of ``\lim_{x\to a} f(x) = L`` are not correct.

1. ``\forall\delta&gt; 0,\exists\varepsilon&gt;0:0&lt;\left|x-a\right|&lt;\delta\implies\left|f\left(x\right)-L\right|&lt;\varepsilon\,.``

2. ``\forall\varepsilon&gt; 0,\exists\delta&gt;0:\left|f\left(x\right)-L\right|&lt;\varepsilon\implies0&lt;\left|x-a\right|&lt;\delta\,.``

{class = pagebreak}
## Explain the proof!

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

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 9

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

Suppose that ``f`` is a continuous and differentiable function on ``\left[0, 1\right]`` and that ``f\left(x\right)`` is in ``\left[0, 1\right]`` for each ``x`` (draw a picture). Show that there is exactly one number ``x`` in ``\left[0, 1\right]`` such that ``f\left(x\right) = x``.

## Do some calculations!

Prove that there is some number ``x`` such that ``\sin x=x-1``.

{class = pagebreak}
## Explain the proof!

Let ``f`` be integrable on an interval containing the points ``a``, ``b``, and ``c``. Then

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
	&&gt;U_a^b\left(f,P_1\right)+U_b^c\left(f,P_2\right)-\varepsilon\ge\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x+\int_b^cf\left(x\right)\,\mathrm{d}\kern-0.5pt x-\varepsilon
	\end{aligned}
	```

	are true for all ``\varepsilon``, we have

	```math
	\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x+\int_b^cf\left(x\right)\,\mathrm{d}\kern-0.5pt x=\int_a^cf\left(x\right)\,\mathrm{d}\kern-0.5pt x\,.
	```

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 10

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

Prove that if ``f`` and ``g`` are continuous on ``\left[a, b\right]`` and differentiable on ``\left]a,b\right[`` and ``g^\prime\left(x\right) \ne 0`` for ``x`` in ``\left]a,b\right[``, then there is some ``x`` in ``\left]a,b\right[`` with

```math
\frac{f^\prime\left(x\right)}{g^\prime\left(x\right)}=\frac{f\left(x\right)-f\left(a\right)}{g\left(b\right)-g\left(x\right)}\,.
```

Hint: Multiply out first, to see what this really says.

## Do some calculations!

1. If ``g=f^2``, find a formula for ``g^\prime`` (involving ``f^\prime``).

2. If ``g=\left(f^\prime\right)^2``, find a formula for ``g^\prime`` (involving ``f^{\prime\prime}``).

{class = pagebreak}
## Explain the proof!

A continuous function on ``\left[a,b\right]`` attains both an absolute maximum and an absolute minimum on ``\left[a,b\right]``.

!!! proof "by contradiction"
    We prove ``f`` has a maximum on ``\left[a,b\right]``.

    Since ``f`` is continuous on ``\left[a,b\right]``, by the Boundness theorem ``f`` is bounded on ``\left[a,b\right]``.

    Since ``f`` is bounded, its image set is a nonempty subset of ``\mathbb{R}`` which is bounded above, so by the Completeness axiom it has a least upper bound.

    Let ``M=\sup f\left(\left[a,b\right]\right)``. By definition of ``M``, ``f\left(x\right)\le M`` for all ``x\in\left[a,b\right]``.

    Suppose that ``f\left(x\right)&lt; M`` for all ``x\in\left[a,b\right]``.

    Then ``\displaystyle g\left(x\right)=\frac{1}{M-f\left(x\right)}`` is continuous on ``\left[a,b\right]`` and hence bounded on ``\left[a,b\right]`` by the Boundness theorem.

    So, there exists ``K>0`` such that ``\displaystyle\frac{1}{M-f\left(x\right)}\le K`` for all ``x\in\left[a,b\right]``.

    It follows that ``\displaystyle f\left(x\right)\le M-\frac{1}{K}`` for all ``x\in\left[a,b\right]``, which says that ``\displaystyle M-\frac{1}{K}`` is an upper bound for ``f\left(\left[a,b\right]\right)``.

    Since ``K>0``, ``\displaystyle M-\frac{1}{K}&lt; M``. This contradicts the fact that ``M=\sup f\left(\left[a,b\right]\right)``.

    Hence, there must exist ``c\in\left[a,b\right]`` such that ``f\left(c\right)=M``.

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 11

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

Prove that if ``f^\prime\left(x\right)\ge M`` for all ``x`` in ``\left[a,b\right]``, then ``f\left(b\right) \ge f\left(a\right) + M\left(b—a\right)``.

## Do some calculations!

If ``f`` is three times differentiable and ``f^\prime\left(x\right) \ne 0``, the *Schwarzian derivative* of ``f`` at ``x`` is defined to be

```math
\mathcal Df\left(x\right)=\frac{f^{\prime\prime\prime\left(x\right)}}{f^\prime\left(x\right)}-\frac{3}{2}\left(\frac{f^{\prime\prime}\left(x\right)}{f^\prime\left(x\right)}\right)^2\,.
```

Show that

```math
\mathcal D\left(f\circ g\right)=\left(\mathcal D f\circ g\right)\left(g^\prime\right)^2+\mathcal Dg\,.
```

{class = pagebreak}
## Explain the proof!

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

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 12

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

If ``f`` is continuous and bijective on an interval, then ``f^{-1}`` is also continuous.

## Do some calculations!

Suppose that ``f\left(x\right) = xg\left(x\right)`` for some function ``g`` which is continuous at ``0``.
Prove that ``f`` is differentiable at ``0``, and find ``f^\prime\left(0\right)`` in terms of ``g``.

{class = pagebreak}
## Explain the proof!

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

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 13

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

Prove that if ``f`` is increasing, then so is ``f^{-1}``.

## Do some calculations!

If ``a_1&lt;a_2&lt;\cdots&lt;a_n``, find the minimum values of ``\displaystyle f\left(x\right)=\sum_{i=1}^n\left(x-a_i\right)^2``.

{class = pagebreak}
## Explain the proof!

Let ``x\in \mathbb{R}`` and ``\varepsilon\in \mathbb{R}^+``. The interval ``\left]x-\varepsilon,x+\varepsilon\right[`` contains a rational number.

!!! proof "by bisection"
    If ``x`` is rational we are done, so let ``x`` be irrational.

    Let ``b_0`` be the smallest integer greater than ``x``, and let ``a_0=b_0-1``.

    Then ``I_0=\left[a_0, b_0\right]`` contains ``x`` and has rational endpoints. It follows that ``x`` is contained in either ``\left]a_0, \frac{a_0+b_0}{2}\right[`` or ``\left]\frac{a_0+b_0}{2}, b_0\right[``. Let ``I_1`` be the closed subinterval containing ``x``.

    Continuing this way, we obtain a sequence of closed intervals ``\cdots\subset I_n\subset\cdots\subset I_2\subset I_1\subset I_0`` satisfying the hypotheses of the nested intervals theorem, where each ``I_n`` contains ``x`` and has rational endpoints.

    By the nested intervals theorem, ``\bigcap_{n\in \mathbb{N}}I_n=\left\{y\right\}`` where ``y=\sup\left\{a_n\right\}=\inf\left\{b_n\right\}``. Since ``x\in I_n`` for all ``n\in \mathbb{N}``, ``y=x``.

    Since ``x=\sup\left\{a_n\right\}``, by the previous lemma, the open interval ``\left]x-\varepsilon,x+\varepsilon\right[`` contains ``a_m\in \mathbb{Q}`` for some ``m\in \mathbb{N}``.

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 14

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

Suppose that ``x = u\left(\right)``, ``y = v\left(t\right)`` is a parametric representation of a curve, and that ``u`` is bijective on some interval.

1. Show that on this interval the curve lies along the graph of ``f = v\circ u^{-1}``.

2. If ``u`` is differentiable on this interval and ``u^\prime\left(t\right)\ne 0``, show that at the point ``x=u\left(t\right)`` we have

   ```math
   f^\prime\left(x\right)=\frac{v^\prime\left(t\right)}{u^\prime\left(t\right)}\,.
   ```

3. Prove also

   ```math
   f^{\prime\prime}\left(x\right)=\frac{u^\prime\left(t\right)v^{\prime\prime}\left(t\right)-v^\prime\left(t\right)u^{\prime\prime}\left(t\right)}{\left(u^\prime\left(t\right)\right)^3}\,.
   ```

## Do some calculations!

Prove that the polynomial function ``f_m\left(x\right) = x^3 - 3x + m`` never has two roots in ``\left[0, 1\right]``, no matter what ``m`` may be. 

{class = pagebreak}
## Explain the proof!

If ``f`` is continuous on the closed, finite interval ``\left[a,b\right]``, then ``f`` is uniformly continuous on that interval.

!!! proof "by contradiction"

	Suppose ``f`` is continuous on ``I_0=\left[a,b\right]=\left[a_0,b_0\right]`` but not uniformly continuous.

	Then, there exists ``\varepsilon&gt;0`` such that for every ``\delta&gt;0`` there exists ``x,y\in\left[a_0,b_0\right]`` such that ``\left|x-y\right|&lt;\delta`` but ``\left|f\left(x\right)-f\left(y\right)\right|\ge\varepsilon``.

	It follows from the lemma that, corresponding to this ``\varepsilon``, it must be true for at least one of the two subintervals ``\left[a_0,\frac{a_0+b_0}{2}\right]`` and ``\left[\frac{a_0+b_0}{2},b_0\right]`` that for every ``\delta&gt;0`` there exist ``x,y`` in the interval such that ``\left|x-y\right|&lt;\delta`` but ``\left|f\left(x\right)-f\left(y\right)\right|\ge\varepsilon``.

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

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 15

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

Prove that

```math
\int_{ca}^{cb}f\left(t\right)\,\mathrm d\kern-0.5pt t=c\int_a^bf\left(ct\right)\,\mathrm d\kern-0.5pt t\,.
```

## Do some calculations!

1. What is wrong with the following use of l'Hôpital's Rule:

   ```math
   \lim_{x\to 1}\frac{x^3+x-2}{x^2-3x+2}=\lim_{x\to 1}\frac{3x^2+1}{2x-3}=\lim_{x\to 1}\frac{6x}{2}=3
   ```

   What is the actual limit?

2. Find the following limits:

   ``\displaystyle \lim_{x\to 0}\frac{x}{\tan x}\,.``

   ``\displaystyle \lim_{x\to 0}\frac{\cos^2 x -1}{x^2}\,.``

{class = pagebreak}
## Explain the proof!

If ``f`` is continous on ``\left[a,b\right]``, then ``f`` is bounded on ``\left[a,b\right]``.

!!! proof "by contradiction"
    Let ``I_0=\left[a_0, b_0\right]=\left[a,b\right]``.

    Suppose ``f`` is continuous on ``\left[a,b\right]`` but not bounded. Then ``f`` is either unbounded on ``\displaystyle \left[a_0,\frac{a_0+b_0}{2}\right]`` or ``\displaystyle \left[\frac{a_0+b_0}{2},b_0\right]`` (since, otherwise, ``f`` would be bounded on their union and hence on all ``I_0``).

    Let ``I_1=\left[a_1, b_1\right]`` be the subinterval on which ``f`` is unbounded and repeat.

    By the Nested Intervals theorem, ``\bigcap_{n\in \mathbb{N}}I_n=\left\{c\right\}``, where ``c=\sup\left\{a_n\right\}=\inf\left\{b_n\right\}``.

    Since ``f`` is continuous at ``c``, ``f`` is bounded on some open interval containing ``c``. However, as we have seen, such an open interval contains one of the intervals ``I_N``, which is a contradiction since ``f`` is unbounded on each ``I_n``.

    Hence, ``f`` is bounded on ``\left[a,b\right]``.

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 16

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

Suppose that ``f`` is nondecreasing on ``\left[a, b\right]``. Notice that ``f`` is automatically bounded on ``\left[a, b\right]``, because ``f\left(a\right) \le f\left(x\right) \le f\left(b\right)`` for ``x`` in ``\left[a, b\right]``.

1. If ``P = \left(t_0, t_1, \dots, t_n\right)`` is a partition of ``\left[a, b\right]``, what is ``L\left(f, P\right)`` and ``U\left(f, P\right)``?

2. Suppose that ``t_i - t_{i-1} = \delta`` for each ``i``. Prove that ``U\left(f, P\right) - L\left(f, P\right) = \delta\left(f\left(b\right) - f\left(a\right)\right)``.

3. Prove that ``f`` is integrable.

## Do some calculations!

Find a formula for ``\left(f^{-1}\right)^{\prime\prime}\left(x\right)``.

{class = pagebreak}
## Explain the proof!

A continuous function on ``\left[a,b\right]`` attains both an absolute maximum and an absolute minimum on ``\left[a,b\right]``.

!!! proof "by contradiction"
    We prove ``f`` has a maximum on ``\left[a,b\right]``.

    Since ``f`` is continuous on ``\left[a,b\right]``, by the Boundness theorem ``f`` is bounded on ``\left[a,b\right]``.

    Since ``f`` is bounded, its image set is a nonempty subset of ``\mathbb{R}`` which is bounded above, so by the Completeness axiom it has a least upper bound.

    Let ``M=\sup f\left(\left[a,b\right]\right)``. By definition of ``M``, ``f\left(x\right)\le M`` for all ``x\in\left[a,b\right]``.

    Suppose that ``f\left(x\right)&lt; M`` for all ``x\in\left[a,b\right]``.

    Then ``\displaystyle g\left(x\right)=\frac{1}{M-f\left(x\right)}`` is continuous on ``\left[a,b\right]`` and hence bounded on ``\left[a,b\right]`` by the Boundness theorem.

    So, there exists ``K>0`` such that ``\displaystyle\frac{1}{M-f\left(x\right)}\le K`` for all ``x\in\left[a,b\right]``.

    It follows that ``\displaystyle f\left(x\right)\le M-\frac{1}{K}`` for all ``x\in\left[a,b\right]``, which says that ``\displaystyle M-\frac{1}{K}`` is an upper bound for ``f\left(\left[a,b\right]\right)``.

    Since ``K>0``, ``\displaystyle M-\frac{1}{K}&lt; M``. This contradicts the fact that ``M=\sup f\left(\left[a,b\right]\right)``.

    Hence, there must exist ``c\in\left[a,b\right]`` such that ``f\left(c\right)=M``.

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 17

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

Suppose that ``f`` is continuous on ``\left[a, b\right]`` and that ``g`` is integrable and nonnegative on ``\left[a, b\right]``. Prove that

```math
\int_a^bf\left(x\right)g\left(x\right)\,\mathrm d\kern-0.5pt x=f\left(c\right)\int_a^bg\left(x\right)\,\mathrm d\kern-0.5pt x
```

for some ``c`` in ``\left[a, b\right]``.

## Do some calculations!

Suppose ``h`` is a function such that ``h^\prime\left(x\right) = \sin\left(sin\left(x + 1\right)\right)`` and ``h\left(0\right) = 3``. Find

1. ``\left(h^{-1}\right)^\prime\left(3\right)\,.``

2. ``\left(\beta^{-1}\right)^\prime\left(3\right)``, where ``\beta\left(x\right)=h\left(x+1\right)\,.``

{class = pagebreak}
## Explain the proof!

!!! theorem "Heine-Borel Theorem"

	Let ``\left[a,b\right]`` be a closed interval and ``𝒪=\left\{\left]c_i, d_i\right[\mid i\in I\right\}`` be an infinite set of open intervals. If ``\left[a,b\right]\subset\bigcup_{i\in I}\left]c_i, d_i\right[``, then there exists ``n\in \mathbb{N}`` such that ``\left[a,b\right]\subset\bigcup_{k=0}^n\left]c_{i_k}, d_{i_k}\right[``.

This theorem is used in the proof of the following theorem.

If ``f`` is continuous on ``\left[a,b\right]``, then ``f`` is integrable on ``\left[a,b\right]``.

!!! proof

	Let ``\varepsilon&gt;0``.

	For each ``x \in \left[a, b\right]``, since ``f`` is continuous at ``x``, there exists an open interval ``I_x=\left]x-\delta_x, x+\delta_x\right[`` such that for all ``y \in I_x \cap \left[a, b\right]`` we have ``\left|f\left(y\right) - f\left(x\right)\right| &lt; \frac{\varepsilon}{2\left(b-a\right)}``.

	The set of all such open intervals ``I_x`` forms an open cover of ``\left[a,b\right]``.

    By the Heine-Borel theorem there exists a finite subcover such that ``\left[a,b\right]\subset\bigcup_{i=0}^nI_{x_i}``.

	Now, create a partition ``P`` of ``\left[a,b\right]`` using the endpoints of these intervals that lie within ``\left[a,b\right]``. Specifically, our partition points will be: ``a = y_0 &lt; y_1 &lt; y_2 &lt; \dots &lt; y_m = b``.

	Consider any subinterval ``\left[y_{j-1},y_j\right]`` in this partition. 

	Since the function is continuous on all closed subintervals of ``\left[a,b\right]``, we have by the Extreme-value theorem ``M_j = \max\left\{f\left(y\right)\mid y \in \left[y_{j-1},y_j\right]\right\}`` and ``m_j = \min\left\{f\left(y\right)\mid y \in \left[y_{j-1},y_j\right]\right\}``.

	Since this subinterval is entirely contained within at least one of our original open intervals ``I_{x_i}``, we have 

	```math
	M_j-m_j = \left(M_j-x_i\right) + \left(x_i-m_j\right) &lt; \frac{\varepsilon}{2\left(b-a\right)} + \frac{\varepsilon}{2\left(b-a\right)}=\frac{\varepsilon}{\left(b-a\right)}\,.
	```

	Calculate the difference between the upper and lower Riemann sums for this partition:

	```math
	U\left(f, P\right)-L\left(f, P\right)=\sum_{j=1}^m\left(M_j-m_j\right)\left(x_j-x_{j-1}\right)&lt;\frac{\varepsilon}{\left(b-a\right)}\sum_{j=1}^m\left(x_j-x_{j-1}\right)=\varepsilon\,.
	```

	By the Darboux's Integrability condition, ``f`` is integrable on ``\left[a,b\right]``.

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 18

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

Suppose that ``f`` is integrable on ``\left[a, b\right]``. Prove that there is a number ``x`` in ``\left]a, b\right[`` such that

```math
\int_a^xf\left(t\right)\,\mathrm d\kern-0.5pt t=\int_x^bf\left(t\right)\,\mathrm d\kern-0.5pt t\,.
```

## Do some calculations!

Prove that ``\displaystyle \int_0^bx^3\,\mathrm d\kern-0.5pt x=\frac{b^4}{4}``, by considering partitions into ``n`` equal subintervals, using the formula ``\displaystyle \sum_{i=1}^ni^3= \left(\sum_{i=1}^ni\right)^2``.

{class = pagebreak}
## Explain the proof!

If ``f\left(x\right)\le g\left(x\right)\le h\left(x\right)`` holds for all ``x`` in some open interval containing ``a``, except possibly at ``x=a``, and

```math
\lim_{x\to a}f\left(x\right)=\lim_{x\to a}h\left(x\right)=L\,,
```
then,

```math
\lim_{x\to a}g\left(x\right)=L\,.
```

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

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 19

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

Prove that if ``h`` is continuous, ``f`` and ``g`` are differentiable, and

```math
F\left(x\right)=\int_{f\left(x\right)}^{g\left(x\right)}h\left(t\right)\,\mathrm d\kern-0.5pt t\,,
```

then ``F^\prime\left(x\right)=h\left(g\left(x\right)\right)g^\prime\left(x\right)-h\left(f\left(x\right)\right)f^\prime\left(x\right)``.

## Do some calculations!

Find ``\left(f^{-1}\right)^\prime\left(0\right)`` if

1. ``\displaystyle f\left(x\right) = \int_0^x\left(1+\sin\left(\sin t\right)\right)\,\mathrm d\kern-0.5pt t\,.``

2. ``\displaystyle f\left(x\right) = \int_0^x\cos\left(\cos t\right)\,\mathrm d\kern-0.5pt t\,.``

{class = pagebreak}
## Explain the proof!

If ``f`` is defined on an open interval ``\left]a,b\right[`` and achieves a maximum (or minimum) value at the point ``c`` in ``\left]a,b\right[``, and if ``f\prime\left(c\right)`` exists, then ``f\prime\left(c\right)=0``. (Values of ``x`` where ``f\prime\left(x\right)=0`` are called *critical points* of the function ``f``.)

!!! proof

	Suppose that ``f`` has a maximum value at ``c``. Then ``f\left(x\right)-f\left(c\right)\le0`` whenever ``x`` is in ``\left]a,b\right[``.

	If ``c&lt;x&lt;b``, then
	```math
	\frac{f\left(x\right)-f\left(c\right)}{x-c}\le0\,,\quad\textrm{so }f^\prime\left(c\right)=\lim_{x\to c^+}\frac{f\left(x\right)-f\left(c\right)}{x-c}\le0\,.
	```
	If ``a&lt;x&lt;c``, then
	```math
	\frac{f\left(x\right)-f\left(c\right)}{x-c}\ge0\,,\quad\textrm{so }f^\prime\left(c\right)=\lim_{x\to c^-}\frac{f\left(x\right)-f\left(c\right)}{x-c}\ge0\,.
	```
	Thus ``f^\prime\left(c\right)``. The proof for a minimum value at ``c`` is similar.

Suppose that the function ``g`` is continuous on the closed, finite interval ``\left[a,b\right]``and that it is differentiable on the open interval ``\left]a,b\right[``. If ``g\left(a\right)=g\left(b\right)``, then there exists a point ``c`` in the open interval ``\left]a,b\right[`` such that ``g\prime\left(c\right)=0``.

!!! proof

	If ``g\left(x\right)=g\left(a\right)`` for every ``x`` in ``\left[a,b\right]``, then ``g`` is a constant function, so ``g\prime\left(c\right)=0`` for every ``c`` in ``\left]a,b\right[``. Therefore, suppose there exists ``x`` in ``\left]a,b\right[`` such that ``g\left(x\right)\ne g\left(a\right)``.

	Let us assume that ``g\left(x\right)&gt; g\left(a\right)``. (If ``g\left(x\right)&lt; g\left(a\right)``, the proof is similar.)

	By the Extreme-Value Theorem, being continuous on ``\left[a,b\right]``, ``g`` must have a maximum value at some point ``c`` in ``\left[a,b\right]``.

	Since ``g\left(c\right)\ge g\left(x\right)&gt; g\left(a\right)=g\left(b\right)``, ``c`` cannot be either ``a`` or ``b``. Therefore, ``c`` is in the open interval ``\left]a,b\right[``, so ``g`` is differentiable at ``c``.

	By the previous theorem, ``c`` must be a critical point of ``g``: ``g\prime\left(c\right)=0``.

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 20

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

Prove the integrability of the absolute value of an integrable function.

Hint: for any interval ``\left[x_{i-1},x_i\right]\in\left[a,b\right]``, we have

```math
\sup\left\{\left|f\left(x\right)\right|\mid x\in \left[x_{i-1},x_i\right]\right\}-\inf\left\{\left|f\left(x\right)\right|\mid x\in \left[x_{i-1},x_i\right]\right\}\le\sup\left\{f\left(x\right)\mid x\in \left[x_{i-1},x_i\right]\right\}-\inf\left\{f\left(x\right)\mid x\in \left[x_{i-1},x_i\right]\right\}\,.
```

## Do some calculations!

Find ``F^\prime\left(x\right)`` if ``\displaystyle F\left(x\right)=\int_0^xxf\left(t\right)\,\mathrm d\kern-0.5pt t``. (The answer is not ``xf\left(x\right)``.)

{class = pagebreak}
## Explain the proof!

Suppose the functions ``f`` and ``g`` are differentiable on the interval ``\left]a,b\right[``, and ``g^\prime\left(x\right)\ne0`` there. Suppose also that

1. ``\displaystyle\lim_{x\to a^+} f\left(x\right)=lim_{x\to a^+} g\left(x\right)=0`` and
2. ``\displaystyle\lim_{x\to a^+}\frac{f^\prime\left(x\right)}{g^\prime\left(x\right)}=L`` where ``L`` is finite or ``\infty`` or ``-\infty``.

Then
```math
lim_{x\to a^+}\frac{f\left(x\right)}{g\left(x\right)}=L\,.
```

!!! proof

    Define
	
    ```math
	F\left(x\right)=\begin{cases}
		f\left(x\right)&\textrm{if }a&lt;x&ltb;\\
		0&\textrm{if }x=a
	\end{cases}\quad\textrm{and}\quad
	G\left(x\right)=\begin{cases}
		g\left(x\right)&\textrm{if }a&lt;x&ltb;\\
		0&\textrm{if }x=a
	\end{cases}\,.
	```

	Then, ``F`` and ``G`` are continuous on the interval ``\left[a,x\right]``and differentiable on the interval ``\left]a,x\right[`` for every ``x\in \left]a,b\right[``. 
	
	By the Generalized Mean-Value Theorem there exists a number ``c \in \left]a,x\right[`` such that
	```math
	\frac{f\left(x\right)}{g\left(x\right)}=\frac{F\left(x\right)}{G\left(x\right)}=\frac{F\left(x\right)-F\left(a\right)}{G\left(x\right)-G\left(a\right)}=\frac{F^\prime\left(c\right)}{G^\prime\left(c\right)}=\frac{f^\prime\left(c\right)}{g^\prime\left(c\right)}
	```

	Since ``a&lt;c&lt;x``, if ``x\to a^+``, then necessarily ``c\to a^+``, so we have
	```math
	\lim_{x\to a^+}\frac{f\left(x\right)}{g\left(x\right)}=\lim_{c\to a^+}\frac{f^\prime\left(c\right)}{g^\prime\left(c\right)}=L\,.
	```

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 21

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

If ``f`` is continuous at ``a``, then ``f`` is bounded on some open interval containing ``a``.

## Do some calculations!

If ``f`` is continuous on ``\left[0, 1\right]``, compute ``\displaystyle \lim_{x\to0^+}x\int_x^1\frac{f\left(t\right)}{t}\,\mathrm d\kern-0.5pt t``.

{class = pagebreak}
## Explain the proof!

If the ``\left(n+1\right)``st-order derivative, ``f^{\left(n+1\right)}\left(t\right)``, exists for all ``t`` in an interval containing ``a`` and ``x``, and if ``P_n\left(x\right)`` is the ``n``th order Taylor polynomial for ``f`` about ``a``, then the error ``E_n\left(x\right)=f\left(x\right)-p_n\left(x\right)`` is given by

```math
E_n\left(x\right)=\frac{f^{\left(n+1\right)}\left(s\right)}{\left(n+1\right)!}\left(x-a\right)^{n+1}\,,
```

where ``s`` is some number between ``a`` and ``x``. The resulting formula

```math
f\left(x\right)=\sum_{i=0}^n\frac{f^{\left(i\right)}\left(a\right)}{i!}\left(x-a\right)^i+\frac{f^{\left(n+1\right)}\left(s\right)}{\left(n+1\right)!}\left(x-a\right)^{n+1}\,,
```

is called Taylor's formula with Lagrange remainder.

!!! proof "by induction"

	Observe that the case ``n=0`` of Taylor's formula, namely,
	```math
	f\left(x\right)=P_0\left(x\right)+E_0\left(x\right)=f\left(a\right)+f^\prime\left(x\right)\left(x-a\right)\,.
	```
	is just the Mean-Value Theorem
	```math
	\frac{f\left(x\right)-f\left(a\right)}{x-a}=f^\prime\left(s\right)
	```
	for some ``s`` between ``a`` and ``x``.

	Suppose that we have proved the case ``n=k-1``, where ``k\ge 1``. Thus, we are assuming that if ``f`` is any function whose ``k``th derivative exists on an interval containing ``a`` and ``x``, then
	```math
	E_{k-1}\left(x\right)=\frac{f^{\left(k\right)}\left(s\right)}{k!}\left(x-a\right)^k\,,
	```
	where ``s`` os some number between ``a`` and ``x``.

	Let us conisder the next higher case: ``n=k``. We assume ``x&gt;a`` (the case ``x&lt;a`` is similar) and apply the generalized Mean-Value Theorem to the functions ``E_k\left(t\right)`` and ``\left(t-a\right)^{k+1}`` on ``\left[a,x\right]``. Since ``E_k\left(a\right)=0``, we obtain a number ``u\in\left]a,x\right[`` such that
	```math
	\frac{E_k\left(x\right)}{\left(x-a\right)^{k+1}}=\frac{E_k\left(x\right)-E_k\left(a\right)}{\left(x-a\right)^{k+1}-\left(a-a\right)^{k+1}}=\frac{E_k^\prime\left(u\right)}{\left(k+1\right)\left(u-a\right)^{k}}\,.
	```

	Now,
	```math
	\begin{aligned}
	E_k^\prime\left(u\right)&=\left.\frac{\mathrm{d}\kern-0.1pt\hphantom{t}}{\mathrm{d}\kern-0.1pt t}\left(f\left(t\right)-f\left(a\right)-f^\prime\left(a\right)\left(t-a\right)-\frac{f^{\prime\prime}\left(a\right)}{2}\left(t-a\right)^2-\cdots-\frac{f^{\left(k\right)}\left(a\right)}{k!}\left(t-a\right)^k\right)\right|_{t=u}\\
	&=f^\prime\left(t\right)-f^\prime\left(a\right)-f^{\prime\prime}\left(a\right)\left(u-a\right)-\cdots-\frac{f^{\left(k\right)}\left(a\right)}{\left(k-1\right)!}\left(u-a\right)^{k-1}\,.
	\end{aligned}
	```
	
	This last expression is just ``E_{k-1}\left(u\right)`` for the function ``f^\prime`` instead of ``f``. By the induction assumption it is equal to
	```math
	\frac{\left(f^\prime\right)^{\left(k\right)}\left(s\right)}{k!}\left(u-a\right)^k=\frac{f^{\left(k+1\right)}\left(s\right)}{k!}\left(u-a\right)^k
	```
	for some ``s`` between ``a`` and ``u``. Therefore,
	```math
	E_k\left(x\right)=\frac{f^{\left(k+1\right)}\left(s\right)}{\left(k+1\right)!}\left(x-a\right)^{k+1}\,.
	```

	We have shown that the case ``n=k`` of Taylor’s Theorem is true if the case ``n=k-1`` is true, and the inductive proof is complete.

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 22

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

If ``f^\prime\left(x_0\right)=0`` and ``f^{\prime\prime}\left(x\right) &gt;0``, then ``f`` has a local minimum value at ``x_0``.

## Do some calculations!

Prove that

```math
\operatorname{Arcsin}\alpha+\operatorname{Arcsin}\beta=\operatorname{Arcsin}\left(\alpha\sqrt{1-\beta^2}+\beta\sqrt{1-\alpha^2}\right)\,,
```

indicating any restrictions on ``\alpha`` and ``\beta``.

{class = pagebreak}
## Explain the proof!

Let ``f`` be integrable on an interval containing the points ``a``, ``b``, and ``c``. Then

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
	&&gt;U_a^b\left(f,P_1\right)+U_b^c\left(f,P_2\right)-\varepsilon\ge\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x+\int_b^cf\left(x\right)\,\mathrm{d}\kern-0.5pt x-\varepsilon
	\end{aligned}
	```

	are true for all ``\varepsilon``, we have

	```math
	\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x+\int_b^cf\left(x\right)\,\mathrm{d}\kern-0.5pt x=\int_a^cf\left(x\right)\,\mathrm{d}\kern-0.5pt x\,.
	```

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 23

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

Suppose that ``g`` is a differentiable function on ``\left[a,b\right]`` that satisfies ``g\left(a\right)=A`` and ``g\left(b\right)=B``. Also suppose that ``f`` is continuous on the range of ``g``. Then

```math
\int_a^b f^\prime\left(g\left(x\right)\right)g^\prime\left(x\right)\,\mathrm{d}\kern-0.5pt x=\int_A^B f^\prime\left(u\right)\,\mathrm{d}\kern-0.5pt u\,.
```

## Do some calculations!

If ``f`` is integrable on ``\left[-\uppi,\uppi\right]``, show that the minimum value of

```math
\int_{-\uppi}^\uppi\left(f\left(x\right)-a\cos nx\right)^2\,\mathrm d\kern-0.5pt x
```

occurs when

```math
a=\frac{1}{\uppi}\int_{-\uppi}^\uppi f\left(x\right)\cos nx\,\mathrm d\kern-0.5pt x
```

(Bring ``a`` outside the integral sign, obtaining a quadratic expression in ``a``.)

{class = pagebreak}
## Explain the proof!

!!! theorem "Heine-Borel Theorem"

	Let ``\left[a,b\right]`` be a closed interval and ``𝒪=\left\{\left]c_i, d_i\right[\mid i\in I\right\}`` be an infinite set of open intervals. If ``\left[a,b\right]\subset\bigcup_{i\in I}\left]c_i, d_i\right[``, then there exists ``n\in \mathbb{N}`` such that ``\left[a,b\right]\subset\bigcup_{k=0}^n\left]c_{i_k}, d_{i_k}\right[``.

This theorem is used in the proof of the following theorem.

If ``f`` is continuous on ``\left[a,b\right]``, then ``f`` is integrable on ``\left[a,b\right]``.

!!! proof

	Let ``\varepsilon&gt;0``.

	For each ``x \in \left[a, b\right]``, since ``f`` is continuous at ``x``, there exists an open interval ``I_x=\left]x-\delta_x, x+\delta_x\right[`` such that for all ``y \in I_x \cap \left[a, b\right]`` we have ``\left|f\left(y\right) - f\left(x\right)\right| &lt; \frac{\varepsilon}{2\left(b-a\right)}``.

	The set of all such open intervals ``I_x`` forms an open cover of ``\left[a,b\right]``.

    By the Heine-Borel theorem there exists a finite subcover such that ``\left[a,b\right]\subset\bigcup_{i=0}^nI_{x_i}``.

	Now, create a partition ``P`` of ``\left[a,b\right]`` using the endpoints of these intervals that lie within ``\left[a,b\right]``. Specifically, our partition points will be: ``a = y_0 &lt; y_1 &lt; y_2 &lt; \dots &lt; y_m = b``.

	Consider any subinterval ``\left[y_{j-1},y_j\right]`` in this partition. 

	Since the function is continuous on all closed subintervals of ``\left[a,b\right]``, we have by the Extreme-value theorem ``M_j = \max\left\{f\left(y\right)\mid y \in \left[y_{j-1},y_j\right]\right\}`` and ``m_j = \min\left\{f\left(y\right)\mid y \in \left[y_{j-1},y_j\right]\right\}``.

	Since this subinterval is entirely contained within at least one of our original open intervals ``I_{x_i}``, we have 

	```math
	M_j-m_j = \left(M_j-x_i\right) + \left(x_i-m_j\right) &lt; \frac{\varepsilon}{2\left(b-a\right)} + \frac{\varepsilon}{2\left(b-a\right)}=\frac{\varepsilon}{\left(b-a\right)}\,.
	```

	Calculate the difference between the upper and lower Riemann sums for this partition:

	```math
	U\left(f, P\right)-L\left(f, P\right)=\sum_{j=1}^m\left(M_j-m_j\right)\left(x_j-x_{j-1}\right)&lt;\frac{\varepsilon}{\left(b-a\right)}\sum_{j=1}^m\left(x_j-x_{j-1}\right)=\varepsilon\,.
	```

	By the Darboux's Integrability condition, ``f`` is integrable on ``\left[a,b\right]``.

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 24

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

The arc length ``s`` of the curve ``y=f\left(x\right)`` from ``x=a`` to ``x=b`` is given by

```math
s = \int_a^b\sqrt{1+\left(f^\prime\left(x\right)\right)^2}\,\mathrm{d}\kern-0.5pt x=\int_a^b\sqrt{1+\left(\frac{\mathrm d\kern-0.5pt y}{\mathrm d\kern-0.5pt x}\right)^2}\,\mathrm{d}\kern-0.5pt x\,.
```

## Do some calculations!

Use logarithmic differentiation to find ``f^\prime\left(x\right)`` for each of the following.

1. ``\displaystyle f\left(x\right)=\left(1+x\right)\left(1+\textup{e}^{x^2}\right)\,.``

2. ``\displaystyle f\left(x\right)=\left(\sin x\right)^{\cos x}+\left(\cos x\right)^{\sin x}\,.``

{class = pagebreak}
## Explain the proof!

Let ``f`` and ``g`` be integrable on an interval containing the points ``a`` and ``b``. Then

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
	\int_a^b\left(f\left(x\right)+g\left(x\right)\right)\,\mathrm{d}\kern-0.5pt x&=I_\star\left(f+g\right)\ge L\left(f+g,P\right)\ge L\left(f,P\right)+ L\left(g,P\right)\\
	&&gt;U\left(f,P\right)+ U\left(g,P\right)-\varepsilon\ge I^\star\left(f\right)+I^\star\left(g\right)-\varepsilon=\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x+\int_a^bg\left(x\right)\,\mathrm{d}\kern-0.5pt x-\varepsilon
	\end{aligned}
	```

	are true for all ``\varepsilon``, we have

	```math
	\int_a^b\left(f\left(x\right)+g\left(x\right)\right)\,\mathrm{d}\kern-0.5pt x=\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x+\int_a^bg\left(x\right)\,\mathrm{d}\kern-0.5pt x\,.
	```

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 25

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

Prove the integrability of a constant times an integrable function

```math
\displaystyle\int_a^b\left(Af\left(x\right)\right)\,\mathrm{d}\kern-0.5pt x=A\int_a^bf\left(x\right)\,\mathrm{d}\kern-0.5pt x\,.
```

Hint: consider the cases ``A`` positive and negative.

## Do some calculations!

Find the following limits by l'Hôpital's Rule.

1. ``\displaystyle \lim_{x\to 0}\left(1-x\right)^\frac{1}{x}\,.``

2. ``\displaystyle \lim_{x\to \frac{\uppi}{4}}\left(\tan x\right)^{\tan 2x}\,.``

3. ``\displaystyle \lim_{x\to 0}\left(\cos x\right)^\frac{1}{x^2}\,.``

{class = pagebreak}
## Explain the proof!

Suppose the functions ``f`` and ``g`` are differentiable on the interval ``\left]a,b\right[``, and ``g^\prime\left(x\right)\ne0`` there. Suppose also that

1. ``\displaystyle\lim_{x\to a^+} f\left(x\right)=lim_{x\to a^+} g\left(x\right)=0`` and
2. ``\displaystyle\lim_{x\to a^+}\frac{f^\prime\left(x\right)}{g^\prime\left(x\right)}=L`` where ``L`` is finite or ``\infty`` or ``-\infty``.

Then
```math
lim_{x\to a^+}\frac{f\left(x\right)}{g\left(x\right)}=L\,.
```

!!! proof

    Define
	
    ```math
	F\left(x\right)=\begin{cases}
		f\left(x\right)&\textrm{if }a&lt;x&ltb;\\
		0&\textrm{if }x=a
	\end{cases}\quad\textrm{and}\quad
	G\left(x\right)=\begin{cases}
		g\left(x\right)&\textrm{if }a&lt;x&ltb;\\
		0&\textrm{if }x=a
	\end{cases}\,.
	```

	Then, ``F`` and ``G`` are continuous on the interval ``\left[a,x\right]``and differentiable on the interval ``\left]a,x\right[`` for every ``x\in \left]a,b\right[``. 
	
	By the Generalized Mean-Value Theorem there exists a number ``c \in \left]a,x\right[`` such that
	```math
	\frac{f\left(x\right)}{g\left(x\right)}=\frac{F\left(x\right)}{G\left(x\right)}=\frac{F\left(x\right)-F\left(a\right)}{G\left(x\right)-G\left(a\right)}=\frac{F^\prime\left(c\right)}{G^\prime\left(c\right)}=\frac{f^\prime\left(c\right)}{g^\prime\left(c\right)}
	```

	Since ``a&lt;c&lt;x``, if ``x\to a^+``, then necessarily ``c\to a^+``, so we have
	```math
	\lim_{x\to a^+}\frac{f\left(x\right)}{g\left(x\right)}=\lim_{c\to a^+}\frac{f^\prime\left(c\right)}{g^\prime\left(c\right)}=L\,.
	```

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 26

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

If ``f`` is a continuous function at the point ``L`` and if ``\displaystyle\lim_{x\to c}g\left(x\right)=L``, then we have

```math
\lim_{x\to c}f\left(g\left(x\right)\right)=f\left(L\right)=f\left(\lim_{x\to c}g\left(x\right)\right)\,.
```

## Do some calculations!

Find all continuous functions ``f`` satisfying

```math
\int_0^{x^2}f\left(x\right)\,\mathrm d\kern-0.5pt x=1-\textup{e}^{2x^2}\,.
```

{class = pagebreak}
## Explain the proof!

If ``f\left(u\right)`` is differentiable at ``u=g\left(x\right)``, and ``g\left(x\right)`` is differentiable at ``x``, then the composite function ``f\circ g\left(x\right)=f\left(g\left(x\right)\right)`` is differentiable at ``x``, and

```math
\left(f\circ g\right)^\prime=f\prime\left(g\left(x\right)\right)g\prime\left(x\right)
```

!!! proof
	Suppose that ``f`` is differentiable at the point ``u=g\left(x\right)`` and that ``g`` is differentiable at ``x``.

	Let the function ``E\left(k\right)`` be defined by
	```math
	E\left(k\right)=\begin{cases}
	0&\textrm{if }k=0\,.\\
	\frac{f\left(u+k\right)-f\left(u\right)}{k}-f\prime\left(u\right)&\textrm{if }k\ne0\,.
	\end{cases}
	```

	By the definition of derivative
	```math
	\lim_{k\to 0}E\left(k\right)=f\prime\left(u\right)-f\prime\left(u\right)=0=E\left(0\right)\,,
	```
	so ``E\left(k\right)`` is continuous at ``k=0``. Also, whether ``k=0`` or not, we have
	```math
	f\left(u+k\right)-f\left(u\right)=\left(f\prime\left(u\right)+E\left(k\right)\right)k\,.
	```
	Now put ``u=g\left(x\right)`` and ``k=g\left(x+h\right)-g\left(x\right)``, so that ``u+k=g\left(x+h\right)``, and obtain
	```math
	f\left(g\left(x+h\right)\right)-f\left(g\left(x\right)\right)=\left(f\prime\left(g\left(x\right)\right)+E\left(k\right)\right)\left(g\left(x+h\right)-g\left(x\right)\right)\,.
	```
	Since ``g`` is differentiable at ``x``,
	```math
	\lim_{h\to 0}\frac{g\left(x+h\right)-g\left(x\right)}{h}=g\prime\left(x\right)\,.
	```
	Also, ``g`` is continuous at ``x``, so 
	```math
	\lim_{h\to 0}k=\lim_{h\to 0}\left(g\left(x+h\right)-g\left(x\right)\right)=0\,.
	```
	Since ``E`` is continuous at ``0``, 
	```math
	\lim_{h\to 0}E\left(k\right)=\lim_{k\to 0}E\left(k\right)=E\left(0\right)=0\,.
	```
	Hence,
	```math
	\begin{aligned}
	\frac{\mathrm{d}\hphantom{\kern-0.5pt y}}{\mathrm{d}\kern-0.5pt x}f\left(g\left(x\right)\right)&=\lim_{h\to 0}\frac{f\left(g\left(x\right)\right)-f\left(g\left(x+h\right)\right)}{h}\\
	&= \left(f\prime\left(g\left(x\right)\right)+E\left(k\right)\right)\frac{g\left(x+h\right)-g\left(x\right)}{h}\\
	&=\left(f\prime\left(g\left(x\right)\right)+0\right)g\prime\left(x\right)=f\prime\left(g\left(x\right)\right)g\prime\left(x\right)\,,
	\end{aligned}
	```
	which was to be proved.

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 27

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

If ``\lim_{x\to a}f\left(x\right)=L`` and ``k`` is a constant, then ``\lim_{x\to a}kf\left(x\right)=kL``.

## Do some calculations!

Find all continuous functions ``f`` satisfying

```math
\int_0^xf\left(t\right)\frac{t}{1+t^2}\,\mathrm d\kern-0.5pt t=\left(f\left(x\right)\right)^2\,.
```

{class = pagebreak}
## Explain the proof!

Let ``f`` be a continuous function defined on ``\left[a,b\right]``. If ``f\left(a\right)&lt;0`` and ``f\left(b\right)&gt;0``, then there exists ``c\in\left]a,b\right[`` such that ``f\left(c\right)=0``.

!!! proof "by contradiction"
    Let ``I_0=\left[a_0, b_0\right]=\left[a,b\right]``. 
    
    If ``\displaystyle f\left(\frac{a_0+b_0}{2}\right)=0``, we are done. Otherwise, ``f`` changes sign on either ``\displaystyle\left[a_0,\frac{a_0+b_0}{2}\right]`` or ``\displaystyle\left[\frac{a_0+b_0}{2},b_0\right]``.

    Let ``I_1=\left[a_1, b_1\right]`` be the subinterval on which ``f`` changes sign and repeat.

    By the Nested Intervals theorem, ``\bigcap_{n\in \mathbb{N}}I_n=\left\{c\right\}``, where ``c=\sup\left\{a_n\right\}=\inf\left\{b_n\right\}``.

    Suppose ``f\left(c\right)&gt;0``. By the Aura theorem, ``f`` must be positive on an open interval containing ``c``. Since ``c=\sup\left\{a_n\right\}``, by the Capture theorem this open interval must contain some ``a_m``. But ``f\left(a_m\right)&lt;0`` which is a contradiction.

    Suppose ``f\left(c\right)&lt;0``. By the Aura theorem, ``f`` must be negative on an open interval containing ``c``. Since ``c=\inf\left\{b_n\right\}``, by the Capture theorem this open interval must contain some ``b_m``. But ``f\left(b_m\right)&gt;0`` which is a contradiction.

    Hence, ``f\left(c\right)=0``.

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 28

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

Let ``A`` be a nonempty subset of ``\mathbb{R}``. If ``A`` is bounded below, than any open interval containing ``\inf A`` contains an element of ``A``.

## Do some calculations!

Suppose that ``f^{\prime\prime}`` is continuous and that

```math
\int_0^\uppi\left(f\left(x\right)+f^{\prime\prime}\left(x\right)\right)\sin x\,\mathrm d\kern-0.5pt x=2\,.
```

Given that ``f\left(\uppi\right) = 1``, compute ``f\left(0\right)``.

{class = pagebreak}
## Explain the proof!

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

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 29

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

Let ``a&gt;0`` and ``S`` a set of real numbers. Show that ``\inf aS=a\inf S``.

## Do some calculations!

1. Prove that

   ```math
   \int_a^bf\left(x\right)\,\mathrm d\kern-0.5pt x=\int_a^bf\left(a+b-x\right)\,\mathrm d\kern-0.5pt x
   ```

2. The graph of ``f(x) = 1/x``, ``x \ge 1`` is revolved around the horizontal axis.

   (a) Find the volume of the enclosed "infinite trumpet."
   (b) Show that the surface area is infinite.
   
   Suppose that we fill up the trumpet with the finite amount of paint found in part (a). It would seem that we have thereby coated the infinite inside surface area with only a finite amount of paint. How is this possible?

{class = pagebreak}
## Explain the proof!

!!! theorem "Heine-Borel Theorem"

	Let ``\left[a,b\right]`` be a closed interval and ``𝒪=\left\{\left]c_i, d_i\right[\mid i\in I\right\}`` be an infinite set of open intervals. If ``\left[a,b\right]\subset\bigcup_{i\in I}\left]c_i, d_i\right[``, then there exists ``n\in \mathbb{N}`` such that ``\left[a,b\right]\subset\bigcup_{k=0}^n\left]c_{i_k}, d_{i_k}\right[``.

This theorem is used in the proof of the following theorem.

If ``f`` is continous on ``\left[a,b\right]``, then ``f`` is bounded on ``\left[a,b\right]``.

!!! proof

    For each ``x \in \left[a, b\right]``, since ``f`` is continuous at ``x``, there exists an open interval ``I_x=\left]x-\delta_x, x+\delta_x\right[`` such that for all ``y \in I_x \cap \left[a, b\right]`` we have ``\left|f\left(y\right) - f\left(x\right)\right| &lt; 1``.

    The set of all such open intervals ``I_x`` forms an open cover of ``\left[a,b\right]``.

    By the Heine-Borel theorem there exists a finite subcover such that ``\left[a,b\right]\subset\bigcup_{i=0}^nI_{x_i}``.

    For any point ``y \in \left[a, b\right]``, ``y`` must be in at least one of the intervals ``I_{x_i}=\left]x_i-\delta_{x_i}, x_i+\delta_{x_i}\right[``. Let's say ``y\in\left]x_j-\delta_{x_j}, x_j+\delta_{x_j}\right[``.

    By the property of the open interval ``\left]x_j-\delta_{x_j}, x_j+\delta_{x_j}\right[``, we know that ``\left|f\left(y\right) - f\left(x_j\right)\right| &lt; 1``, i.e. ``f\left(y\right) &lt; f\left(x_j\right) + 1`` and ``f\left(y\right) &gt; f\left(x_j\right) - 1``.

    Let ``M = \max\left\{f\left(x_i\right) |0\le i\le n\right\}+ 1`` and ``m = \min\left\{f\left(x_i\right) |0\le i\le n\right\}- 1``.

    We can conclude that for all ``y \in \left[a, b\right]`` we have ``m &lt; f\left(y\right) &lt; M``.

    Therefore, ``f`` is bounded on ``\left[a,b\right]``, with ``m`` as a lower bound and ``M`` as an upper bound.

{data-type = unnumbered, class = page.reset}
# Exam: ES111 Calculus – Series 30

Promotion: ………………………………………………………………………………………

First Name: ………………………………………………………………………………………

Last Name: ………………………………………………………………………………………

## Create a proof!

If ``\lim_{x\to a}f\left(x\right)=L`` and ``\lim_{x\to a}f\left(x\right)=M``, then ``L=M``.

## Do some calculations!

Let

```math
f\left(x\right) = \begin{cases}
\frac{\textup{e}^x-1}{x}\,,&x\ne 0\\
1\,,&x=0\,.
\end{cases}
```

1. Find the Taylor polynomial of degree ``n`` for ``f`` at ``0``, compute ``f^{\left(k\right)}\left(0\right)``, and give an estimate for the remainder term ``E_n\left(x\right)``.

2. Compute ``\displaystyle\int_0^1f\left(x\right)\,\mathrm d\kern-0.5pt x``, with an error of less than ``10^{-4}``.

## Explain the proof!

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
