{data-type = chapter}
# Test

This is a *test*, see [most important section](#most_important_section)! Nice layout ...
but does it work?

## Section 1

Happy **Julia** printing!

This is a *formula*:
{#einstein}
```math
\begin{aligned}
    E&=&mc^2\\
    c^2&=&a^2+b^2
\end{aligned}
```

and another
```math
E=mc^2
```

And some ``E=mc^2`` in a text.

{#most_important_section}
## Section 2

Another paragraph with a variable `a`.

!!! theorem "Archimedes"
    This is a 'theorem' with some nice features.
    This is is!

And not a "*lemma*".

!!! proof
    This is a proof.
    - First
    and some comments
    - Secondly
    - Finally
    
    With a nice conclusion!

```julia
function say_hello(name::String)
    println("Hello, ", name)
end
```
Test!

{cell=chap display=false}
```julia
using NativeSVG

function say_hello(name::String)
    println("Hello, ", name)
    Drawing() do
        g(stroke_linecap="butt", stroke_miterlimit="4", stroke_width="3.0703125") do
            circle(cx="20", cy="20", r="16", stroke="#cb3c33", fill="#d5635c")
            circle(cx="40", cy="56", r="16", stroke="#389826", fill="#60ad51")
            circle(cx="60", cy="20", r="16", stroke="#9558b2", fill="#aa79c1")
        end
    end
end

say_hello("Ben")
```

{cell=chap}
```julia
(1, 2, 3, 4)
```

{cell=chap}
```julia
Drawing() do
    latex("E=mc^2", x="20", y="20", width="60", height="20")
end
```

## Another Section

1. A list
   1. With a sublist
   2. Next item
2. Another main item
   And some text!
3. And another item
4. A small modification

!!! theorem
    &nbsp;
    - First statement
    - Second statement

Let ``x\in\R`` and ``y\in\mathcal R``.
