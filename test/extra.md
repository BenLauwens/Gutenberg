We need the following lemma to prove the boundedness property.

!!! lemma

    If ``f`` is continuous at ``a``, then ``f`` is bounded on some open interval containing ``a``.

!!! proof

    Since ``f`` is continuous at ``a``, corresponding to ``\varepsilon =1&gt;0``, there exists ``\delta>0`` such that ``\left|x-a\right|&lt;\delta`` implies ``\left|f\left(x\right)-f\left(a\right)\right|&lt;1``.

    That is, ``x\in\left]a-\delta,a+\delta\right[`` implies ``f\left(a\right)-1&lt;f\left(x\right)&lt;f\left(a\right)+1``, which shows that ``f`` is bounded on the open interval ``\left]a-\delta,a+\delta\right[``.

!!! theorem "Boundedness theorem"

    If ``f`` is continous on ``\left[a,b\right]``, then ``f`` is bounded on ``\left[a,b\right]``.

!!! proof "by contradiction"

    Let ``I_0=\left[a_0, b_0\right]=\left[a,b\right]``.

    Suppose ``f`` is continuous on ``\left[a,b\right]`` but not bounded. Then ``f`` is either unbounded on ``\displaystyle \left[a_0,\frac{a_0+b_0}{2}\right]`` or ``\displaystyle \left[\frac{a_0+b_0}{2},b_0\right]`` (since, otherwise, ``f`` would be bounded on their union and hence on all ``I_0``).

    Let ``I_1=\left[a_1, b_1\right]`` be the subinterval on which ``f`` is unbounded and repeat.

    By the Nested Intervals theorem, ``\bigcap_{n\in \mathbb{N}}I_n=\left\{c\right\}``, where ``c=\sup\left\{a_n\right\}=\inf\left\{b_n\right\}``.

    Since ``f`` is continuous at ``c``, ``f`` is bounded on some open interval containing ``c``. However, as we have seen by the extension of the Capture theorem, such an open interval contains one of the intervals ``I_N``, which is a contradiction since ``f`` is unbounded on each ``I_n``.

    Hence, ``f`` is bounded on ``\left[a,b\right]``.


We are still missing one piece of the puzzle, the notion of *uniformly continuous* functions.

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
