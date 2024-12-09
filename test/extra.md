Heine Borel Theorem 

Given:
A closed interval [a, b]
An infinite set of open intervals {(αi, βi)} where i is in some index set I
[a, b] is covered by the union of all (αi, βi)
We'll prove this by contradiction. Assume that no finite subset of {(αi, βi)} covers [a, b].
Let's start the bisection process:
Define c = (a + b) / 2, the midpoint of [a, b]
At least one of the intervals [a, c] or [c, b] cannot be covered by a finite subset of {(αi, βi)} (If both could be covered by finite subsets, their union would cover [a, b])
Let's call the interval that can't be covered by a finite subset [a1, b1]
We repeat this process:
c1 = (a1 + b1) / 2
Either [a1, c1] or [c1, b1] can't be covered by a finite subset
We call this new interval [a2, b2]
Continuing this process indefinitely, we get a sequence of nested intervals:
[a, b] ⊃ [a1, b1] ⊃ [a2, b2] ⊃ ...
This sequence has the following properties:
Each interval [an, bn] cannot be covered by a finite subset of {(αi, βi)}
The length of each interval is half of its predecessor: bn - an = (b - a) / 2^n
By the Nested Interval Theorem, there exists a point x that belongs to all these intervals.
Since x ∈ [a, b] and [a, b] is covered by the union of {(αi, βi)}, there must exist an open interval (αk, βk) such that x ∈ (αk, βk).
Since (αk, βk) is open, there exists an ε > 0 such that (x - ε, x + ε) ⊂ (αk, βk).
However, as the intervals [an, bn] get arbitrarily small (their length approaches 0 as n increases), there must be some N such that for all n ≥ N, [an, bn] ⊂ (x - ε, x + ε).
This means that for n ≥ N, [an, bn] ⊂ (αk, βk), contradicting our assumption that no [an, bn] can be covered by a finite subset of {(αi, βi)}.
Therefore, our initial assumption must be false, and there must exist a finite subset of {(αi, βi)} that covers [a, b].
This proof uses the bisection method and the Nested Interval Theorem to arrive at a contradiction, demonstrating the result without directly invoking the compactness of [a, b].

Boundedness Theorem

Let f be a continuous function on the closed interval [a, b]. We want to show that f is bounded on [a, b].
Proof:
For each x ∈ [a, b], since f is continuous at x, there exists an open interval (αx, βx) containing x such that for all y ∈ (αx, βx) ∩ [a, b]:
|f(y) - f(x)| < 1
The collection of all such open intervals {(αx, βx)} forms an open cover of [a, b].
By the property we proved earlier (using the bisection method), there exists a finite subcover of [a, b]. Let's call these intervals (α1, β1), (α2, β2), ..., (αn, βn).
For each i = 1, 2, ..., n, choose a point xi ∈ (αi, βi) ∩ [a, b]. These points exist because each (αi, βi) contains at least one point from [a, b] in our finite subcover.
Now, for any point y ∈ [a, b], y must be in at least one of the intervals (αi, βi) in our finite subcover. Let's say y ∈ (αj, βj).
By the property of the open interval (αj, βj), we know that:
|f(y) - f(xj)| < 1
This means that:
f(y) < f(xj) + 1
f(y) > f(xj) - 1
Let M = max{f(x1), f(x2), ..., f(xn)} + 1
Let m = min{f(x1), f(x2), ..., f(xn)} - 1
From steps 6 and 7, we can conclude that for all y ∈ [a, b]:
m < f(y) < M
Therefore, f is bounded on [a, b], with m as a lower bound and M as an upper bound.
This proof uses the finite subcover property that we derived earlier without invoking uniform continuity. The key idea is that the continuity of f at each point allows us to control the variation of f in small neighborhoods, and the finite subcover property allows us to extend this local control to the entire interval [a, b] using only finitely many such neighborhoods.

Integrability of a continuous function on a closed interval

Let f be a continuous function on the closed interval [a, b]. We want to show that f is integrable on [a, b].
For any ε > 0, we will construct a partition of [a, b] such that the difference between the upper and lower Riemann sums is less than ε.
Since f is continuous on [a, b], for each x ∈ [a, b], there exists an open interval (αx, βx) containing x such that for all y ∈ (αx, βx) ∩ [a, b], we have:
|f(y) - f(x)| < ε / (2(b-a))
The collection of all such open intervals {(αx, βx)} forms an open cover of [a, b].
By the property we just proved, there exists a finite subcover of [a, b]. Let's call these intervals (α1, β1), (α2, β2), ..., (αn, βn).
Now, let's create a partition P of [a, b] using the endpoints of these intervals that lie within [a, b]. Specifically, our partition points will be:
a = x0 < x1 < x2 < ... < xm = b
where {x1, x2, ..., xm-1} is the sorted set of all αi and βi that lie in (a, b).
Consider any subinterval [xi-1, xi] in this partition. This subinterval is entirely contained within at least one of our original open intervals (αj, βj).
For this subinterval [xi-1, xi], let:
Mi = sup{f(x) : x ∈ [xi-1, xi]}
mi = inf{f(x) : x ∈ [xi-1, xi]}
Since [xi-1, xi] is contained in (αj, βj), for any x, y ∈ [xi-1, xi], we have:
|f(x) - f(y)| < ε / (2(b-a))
This means that Mi - mi < ε / (2(b-a))
Now, let's look at the difference between the upper and lower Riemann sums for this partition:
U(P, f) - L(P, f) = Σ(Mi - mi)(xi - xi-1)
               < Σ(ε / (2(b-a)))(xi - xi-1)
               = (ε / (2(b-a))) Σ(xi - xi-1)
               = (ε / (2(b-a))) (b - a)
               = ε / 2
               < ε
Since we've constructed a partition P for which U(P, f) - L(P, f) < ε for any ε > 0, f satisfies the definition of Riemann integrability.