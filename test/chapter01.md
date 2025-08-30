{data-type = chapter, class = page.reset}
# Preliminaries

This chapter introduces mathematical logic as a tool for rigorously proving statements. An elementary introduction to set theory and functions is also included.

## Propositions

!!! definition
	A *proposition* is a declarative sentence which is true ``T`` or false ``F,`` but not both.

Many propositions are *composite*, that is, composed of *subpropositions* and various *connectives* discussed subsequently. Such composite propositions are called *compound propositions*. A proposition is said to be *primitive* if it cannot be broken down into simpler propositions.

!!! example
	Some primitive propositions:
	* Brussels is in Belgium: ``T``
	* ``2+2=3``: ``F``
	* ``x=2`` is a solution of ``x^2=4``: ``T``

The fundamental property of a compound proposition is that its truth value is completely determined by the truth values of its subpropositions together with the way in which they are connected to form the compound proposition.

## Connectives

Any two propositions ``𝒫`` and ``𝒬`` can be combined by the word "and" to form a compound proposition called the *conjunction* of ``𝒫`` and ``𝒬``, denoted ``𝒫\wedge 𝒬`` and read "``𝒫`` and ``𝒬``". If ``𝒫`` and ``𝒬`` are true, then ``𝒫\wedge 𝒬`` is true; otherwise ``𝒫\wedge 𝒬`` is false. The truth value of ``𝒫\wedge 𝒬`` may be defined equivalently by the following truth table:

| ``𝒫`` | ``𝒬`` | ``𝒫\wedge 𝒬``  |
| :-: | :-: | :-: |
| ``T`` | ``T`` | ``T``  |
| ``T`` | ``F`` | ``F``  |
| ``F`` | ``T`` | ``F``  |
| ``F`` | ``F`` | ``F``  |

!!! example
	Some conjunctions:
	* Brussels is the capital of Belgium and the home town of the Royal Military Academy: ``T``
	* ``2+2=3`` and ``x=2`` is a solution of ``x^2=4``: ``F``

Any two propositions ``𝒫`` and ``𝒬`` can be combined by the word "or" to form a compound proposition called the *disjunction* of ``𝒫`` and ``𝒬``, denoted ``𝒫\vee 𝒬`` and read "``𝒫`` or ``𝒬``". If ``𝒫`` and ``𝒬`` are false, then ``𝒫\vee 𝒬`` is false; otherwise ``𝒫\vee 𝒬`` is true. The truth value of ``𝒫\vee 𝒬`` may be defined equivalently by the following truth table:

| ``𝒫`` | ``𝒬`` | ``𝒫\vee 𝒬``  |
| :-: | :-: | :-: |
| ``T`` | ``T`` | ``T``  |
| ``T`` | ``F`` | ``T``  |
| ``F`` | ``T`` | ``T``  |
| ``F`` | ``F`` | ``F``  |

!!! example
	Some disjunctions:
	* Belgium is the capital of Brussels or Brussels is the biggest city in Europe: ``F``
	* ``2+2=3`` or ``x=2`` is a solution of ``x^2=4``: ``T``

Any proposition ``𝒫`` can be preceded by the word "not" to form a new proposition called the *negation* of ``𝒫``, denoted ``\lnot 𝒫`` and read "not ``𝒫``". If ``𝒫`` is true, then ``\lnot 𝒫`` is false; and if If ``𝒫`` is false, then ``\lnot 𝒫`` is true. The truth value of ``\lnot 𝒫`` may be defined equivalently by the following truth table: 

| ``𝒫`` | ``\lnot 𝒫``  |
| :-: | :-: |
| ``T`` | ``F``  |
| ``F`` | ``T``  |

!!! example
	Some negations:
	* Belgium is not the capital of Brussels: ``T``
	* ``x=2`` is not a solution of ``x^2=4``: ``F``

A proposition containing only ``T`` in the last column of its truth table is called a *tautology* denoted ``\top``, eg.

| ``𝒫`` | ``\lnot 𝒫`` | ``𝒫\vee \lnot 𝒫``  |
| :-: | :-: | :-: |
| ``T`` | ``F`` | ``T``  |
| ``F`` | ``T`` | ``T``  |

!!! example
	A person is a combattant or a non-combattant. (*Law of Armed Conflicts*)

A proposition containing only ``F`` in the last column of its truth table is called a *contradiction* denoted ``\bot``, eg.

| ``𝒫`` | ``\lnot 𝒫`` | ``𝒫\wedge \lnot 𝒫``  |
| :-: | :-: | :-: |
| ``T`` | ``F`` | ``F``  |
| ``F`` | ``T`` | ``F``  |

!!! example
	The cat is dead and alive. (*Quantum Mechanics*)

## Logical Equivalence

The propositions ``𝒫`` and ``𝒬`` are said to be *logically equivalent*, denoted by ``𝒫\equiv 𝒬`` if they have identical truth tables.

!!! example
	Show that ``\lnot \left(𝒫\wedge 𝒬\right)\equiv \lnot 𝒫\vee \lnot 𝒬``.

    Column 4 and 7 of the following truth table are identical, so the propositions are logically equivalent.

    | ``𝒫`` | ``𝒬`` |  | ``𝒫\wedge 𝒬`` | ``\lnot \left(𝒫\wedge 𝒬\right)`` |  | ``\lnot 𝒫`` | ``\lnot 𝒬`` | ``\lnot 𝒫\vee \lnot 𝒬``  |
    | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
    | ``T`` | ``T`` |  | ``T`` | ``F`` |  | ``F`` | ``F`` | ``F``  |
    | ``T`` | ``F`` |  | ``F`` | ``T`` |  | ``F`` | ``T`` | ``T``  |
    | ``F`` | ``T`` |  | ``F`` | ``T`` |  | ``T`` | ``F`` | ``T``  |
    | ``F`` | ``F`` |  | ``F`` | ``T`` |  | ``T`` | ``T`` | ``T``  |

The basic rules, called laws, governing propositions are stated in the following theorem.

!!! theorem
	Let ``𝒫``, ``𝒬`` and ``ℛ`` be propositions.
	1.  ``𝒫\vee 𝒫\equiv 𝒫`` and ``𝒫\wedge 𝒫\equiv 𝒫`` (*idempotent laws*)
	2. ``𝒫\vee 𝒬\equiv 𝒬\vee 𝒫`` and ``𝒫\wedge 𝒬\equiv 𝒬\wedge 𝒫`` (*commutative laws*)
	3. ``𝒫\vee \left(𝒬\vee ℛ\right)\equiv \left(𝒫\vee 𝒬\right)\vee ℛ\equiv 𝒫\vee 𝒬\vee ℛ`` and 
       ``𝒫\wedge \left(𝒬\wedge ℛ\right)\equiv \left(𝒫\wedge 𝒬\right)\wedge ℛ\equiv 𝒫\wedge 𝒬\wedge ℛ`` (*associative laws*)
	4. ``𝒫\wedge \left(𝒬\vee ℛ\right)\equiv \left(𝒫\wedge 𝒬\right)\vee \left(𝒫\wedge ℛ\right)`` and 
       ``𝒫\vee \left(𝒬\wedge ℛ\right)\equiv \left(𝒫\vee 𝒬\right)\wedge \left(𝒫\vee ℛ\right)`` (*distributive laws*)
	5. ``𝒫\vee \bot \equiv 𝒫`` and ``𝒫\wedge \bot \equiv \bot`` (*identity laws*)
	6. ``𝒫\vee \top \equiv \top`` and ``𝒫\wedge \top \equiv 𝒫`` (*identity laws*)
	7. ``𝒫\vee \lnot 𝒫\equiv \top`` and ``𝒫\wedge \lnot 𝒫\equiv \bot`` (*complement laws*)
	8. ``\lnot \top \equiv \bot`` and ``\lnot \bot \equiv \top`` (*complement laws*)
	9. ``\lnot \left(\lnot 𝒫\right)\equiv 𝒫`` (*involution law*)
	10. ``\lnot \left(𝒫\vee 𝒬\right)\equiv \lnot 𝒫\wedge \lnot 𝒬`` and ``\lnot \left(𝒫\wedge 𝒬\right)\equiv \lnot 𝒫\vee \lnot 𝒬`` (*De Morgan's laws*)

!!! exercise
	Use a truth table to show the logical equivalence of the other propositions.

## Conditional Propositions

Many statements are of the form "If ``𝒫`` then ``𝒬``". Such statements are called *conditional propositions*, and are denoted by ``𝒫\implies 𝒬``. The conditional ``𝒫\implies 𝒬`` is frequently read "``𝒫`` implies ``𝒬``", or "``𝒫`` only if ``𝒬``".

!!! example
	If I have exercised then I am hungry.

Another common statement is of the form "``𝒫`` if and only if ``𝒬``". Such statements are called *biconditional propositions*, and are denoted by ``𝒫\iff 𝒬``.

!!! example
	I am hungry if and only if I have skipped a meal.

Their truth values are defined by following truth tables:

| ``𝒫`` | ``𝒬`` |  | ``\left.𝒫\implies 𝒬\right.`` |  | ``\left.\lnot 𝒫\right.`` | ``\left.\lnot 𝒫\vee 𝒬\right.`` |  | ``\left.𝒫\iff 𝒬\right.`` |  | ``\left.𝒬\implies 𝒫\right.`` | ``\left(𝒫\implies 𝒬\right)\wedge \left(𝒬\implies 𝒫\right)``  |
| :-: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: |
| ``T`` | ``T`` |  | ``T`` |  | ``F`` | ``T`` |  | ``T`` |  | ``T`` | ``T``  |
| ``T`` | ``F`` |  | ``F`` |  | ``F`` | ``F`` |  | ``F`` |  | ``T`` | ``F``  |
| ``F`` | ``T`` |  | ``T`` |  | ``T`` | ``T`` |  | ``F`` |  | ``F`` | ``F``  |
| ``F`` | ``F`` |  | ``T`` |  | ``T`` | ``T`` |  | ``T`` |  | ``T`` | ``T``  |

Observe that:
* The conditional ``𝒫\implies 𝒬`` is false only when the first part ``𝒫`` is true and the second part ``𝒬`` is false. Accordingly, when ``𝒫`` is false, the conditonal ``𝒫\implies 𝒬`` is true regardless of the truth value of ``𝒬``.
* ``𝒫\implies 𝒬`` is logically equivalent to ``\lnot 𝒫\vee 𝒬``.
* The biconditional ``𝒫\iff 𝒬`` is true whenever ``𝒫`` and ``𝒬`` have the same truth values and false otherwise.
* ``𝒫\iff 𝒬`` is logically equivalent to ``\left(𝒫\implies 𝒬\right)\wedge \left(𝒬\implies 𝒫\right)``. ``𝒬\implies 𝒫`` is called the *converse* of ``𝒫\implies 𝒬``.

## Sets

!!! definition
	A *set* is a collection of objects called *elements* of the set. 
	
In general, we denote a set by a capital letter and an element by a lower case letter. If an element ``a`` belongs to a set ``S`` we write ``a\in S``. If ``a`` does not belong to ``S`` we write ``a\not\in S``.

A set can be described by listing its elements in braces separated by commas, eg. ``\lbrace a,e,i,o,u\rbrace``, or by describing some property held by all elements, eg. ``\lbrace x\mid x\;\textrm{ is a vowel}\rbrace``.

If each element of a set ``A`` belongs to a set ``B`` we call ``A`` a *subset* of ``B``, written ``A\subset B``. If ``A\subset B`` and ``B\subset A`` we call ``A`` and ``B`` *equal* and write ``A=B``.

Often we restrict our discussion to subsets of a particular set called the *universe* or the *universal set* denoted by ``\Omega``, eg. the set of the letters of the roman alphabet.

It is useful to consider a set having no elements at all. This is called the *empty set* and is denoted by ``\emptyset``. It is a subset on any set.

A universe ``\Omega`` can be represented geometrically by the set of points inside a rectangle. In such case subsets of ``\Omega`` such as ``A`` and ``B`` are represented by sets of points inside ellipses. Such diagrams, called *Venn diagrams*, often serve to provide geometric intuition regarding possible relationships between sets.

!!! theorem
	If ``A\subset B`` and ``B\subset C``, then ``A\subset C``.

!!! proof

    *SET THE CONTEXT:* Let ``A``, ``B`` and ``C`` be sets for which ``A\subset B`` and ``B\subset C``.
    
    *ASSERT THE HYPOTHESIS:* Suppose ``x\in A``.
    
    *LIST IMPLICATIONS:*
    
    1. Since ``x\in A``, it is true that ``x\in B`` by the definition of subset.
    2. Since ``x\in B``, it is true that ``x\in C`` by the definition of subset.
    
    *STATE THE CONCLUSION:* Therefore, by the definition of subset, ``A\subset C``.

## Set Operations

The set of all elements which belong to ``A`` or ``B`` is called the *union* of ``A`` and ``B`` and is denoted by ``A\cup B``.

The set of all elements which belong to ``A`` and ``B`` is called the *intersection* of ``A`` and ``B`` and is denoted by ``A\cap B``. Two sets ``A`` and ``B`` such that ``A\cap B=\emptyset`` are called *disjoint sets*.

The set consisting of all elements of ``A`` which do not belong to ``B`` is called the *difference* of ``A`` and ``B`` denoted by ``A\setminus B``.

The set consisting of all elements of ``\Omega`` which do not belong to ``A`` is called the *complement* of ``A`` denoted by ``A^c =\Omega \setminus A``.

!!! theorem
	Let ``A``, ``B`` and ``C`` be sets.

	1. ``A\cup A=A`` and ``A\cap A=A`` (*idempotent laws*)
	2. ``A\cup B=B\cup A`` and ``A\cap B=B\cap A`` (*commutative laws*)
	3. ``A\cup \left(B\cup C\right)=\left(A\cup B\right)\cup C=A\cup B\cup C`` and
       ``A\cap \left(B\cap C\right)=\left(A\cap B\right)\cap C=A\cap B\cap C`` (*associative laws*)
	4. ``A\cap \left(B\cup C\right)=\left(A\cap B\right)\cup \left(A\cap C\right)`` and 
       ``A\cup \left(B\cap C\right)=\left(A\cup B\right)\cap \left(A\cup C\right)`` (*distributive laws*)
	5. ``A\cup \emptyset =A`` and ``A\cap \emptyset =\emptyset`` (*identity laws*)
	6. ``A\cup \Omega =\Omega`` and ``A\cap \Omega =A`` (*identity laws*)
	7. ``A\cup A^c =\Omega`` and ``A\cap A^c =\emptyset`` (*complement laws*)
	8. ``\Omega^c =\emptyset`` and ``\emptyset^c =\Omega`` (*complement laws*)
	9. ``\left(A^c \right)^c =A`` (*involution law*)
	10. ``\left(A\cup B\right)^c =A^c \cap B^c`` and ``\left(A\cap B\right)^c =A^c \cup B^c`` (*De Morgan's laws*)
	11. ``A\setminus B=A\cap B^c``
	12. If ``A\subset B``, then ``B^c \subset A^c``
	13. ``A=\left(A\cap B\right)\cup \left(A\cap B^c \right)``

!!! example
	Proof the first law of De Morgan.

!!! proof

    *SET THE CONTEXT:* Let ``A`` and ``B`` be any two sets.

    *PART 1:* ``\left(A\cup B\right)^c \subset A^c \cap B^c`` 

    *ASSERT THE HYPOTHESIS:* Suppose ``x\in \left(A\cup B\right)^c``.
    
    *LIST IMPLICATIONS:*
    
    1.  By the definition of set complement, ``x\not\in A\cup B``.
    2. If ``x\in A`` or ``x\in B``, then ``x\in A\cup B`` which is false.
    3. Thus, ``x\not\in A`` and ``x\not\in B``, so by the definition of set complement ``x\in A^c`` and ``x\in B^c``.
    4. By the definition of set intersection ``x\in A^c \cap B^c``.
    
    *CONCLUSION PART 1:* Hence, from the definition of subset, it follows that ``\left(A\cup B\right)^c \subset A^c \cap B^c``.
    
    *PART 2:* ``A^c \cap B^c \subset \left(A\cup B\right)^c`` 
    
    *ASSERT THE HYPOTHESIS:* Suppose ``x\in A^c \cap B^c``.
    
    *LIST IMPLICATIONS:*
    
    1. By the definition of set intersection, ``x\in A^c`` and ``x\in B^c``.
    2. Thus by the definition of set complement, ``x\not\in A`` and ``x\not\in B``.
    3. If ``x\in A\cup B``, then by the definition of the union, it would follow that ``x\in A`` or ``x\in B`` which is false.
    4. Thus, ``x\not\in A\cup B``, and by definition of set complement ``x\in \left(A\cup B\right)^c``.
    
    *CONCLUSION PART 2:* Hence, from the definition of subset, it follows that ``A^c \cap B^c \subset \left(A\cup B\right)^c``.
    
    *STATE THE CONCLUSION:* Therefore, because ``\left(A\cup B\right)^c`` and ``A^c \cap B^c`` are subsets of each other, by the definition of set equality ``\left(A\cup B\right)^c =A^c \cap B^c``.

!!! exercise

	Proof the other theorems.

## Cartesian Product

The set of all *ordered pairs* of elements ``\left(x,y\right)`` where ``x\in A`` and ``y\in B`` is called the *Cartesian product* or *product set* of ``A`` and ``B`` and is denoted by ``A\times B``. In general, ``A\times B\not= B\times A``.

The notion of Cartesian product can be generalized to ordered tuples of element ``\left(x,y,z,\ldots\right)``.

## Functions

!!! definition
	A function ``f`` from a set ``X`` to a set ``Y``, often written ``f:X\to Y``, is a rule which assigns to each ``x\in X`` a unique element ``y\in Y``. 

The element ``y`` is called the *image* of ``x`` under ``f`` and is denoted by ``f\left(x\right)``. If ``A\subset X``, then ``f\left(A\right)`` is the set of all elements ``f\left(x\right)`` where ``x\in A`` and is called the *image* of ``A`` under ``f``. Symbols ``x`` and ``y`` are called *variables*.

A function ``f:X\to Y`` can also be defined as a subset of the Cartesian product ``X\times Y`` such that if ``\left(x_1,y_1 \right)`` and ``\left(x_2,y_2 \right)`` are in this subset and ``x_1 =x_2``, then ``y_1 =y_2``.

The set ``X`` is called the *domain* of ``f`` and ``f\left(X\right)`` is called the *range* of ``f``. If ``Y=f\left(X\right)`` we say that ``f`` is from ``X`` onto ``Y`` and refer to ``f`` as a *surjective* function.

If an element ``a\in A\subset X`` maps into an element ``b\in B\subset Y``, then ``a`` is called the *inverse image* of ``b`` under ``f`` and is denoted by ``f^{-1} \left(b\right)``. The set of all ``x\in X`` for which ``f\left(x\right)\in B`` is called the *inverse image* of ``B`` under ``f`` and is denoted by ``f^{-1} \left(B\right)``.

If ``f\left(a_1 \right)=f\left(a_2 \right)`` only when ``a_1 =a_2``, we say that ``f`` is an *injective* function.

If a function ``f:X\to Y`` is both surjective and injective, we say there is a one to one correspondence between ``X`` and ``Y`` and call ``f`` a *bijective* function. Given any element ``y\in Y``, there will be only one element ``f^{-1} \left(y\right)`` in ``X``. In such case ``f^{-1}`` will define a function from ``Y`` to ``X`` called the *inverse function*.

## Cardinal Numbers

Two sets ``A`` and ``B`` are called *equivalent* and we write ``A\sim B`` if there exists a one to one correspondence between ``A`` and ``B``.

!!! theorem
	If ``A\sim B`` and ``B\sim C``, then ``A\sim C``.

To determine the number of elements belonging to a set, we need a definition for counting.

!!! axiom "Peano"

	Following axioms define the natural numbers.

	1. ``0`` is a natural number.
	2. Every natural number has a successor which is also a natural number.
	3. ``0`` is not the successor of any natural number.
	4. If the successor of ``x`` equals the successor of ``y``, then ``x`` equals ``y``.
	5. If a statement is true for ``0``, and if the truth of that statement for a natural number implies its truth for the successor of that natural number, then the statement is true for every natural number. (*Axiom of induction*)

The set of natural number is denoted by ``ℕ``.

A set which is equivalent to the set ``\lbrace 0,1,2,3,\ldots,n\rbrace`` for some ``n\in ℕ`` is called *finite*; otherwise it is called *infinite*.

An infinite set which is equivalent to the set of natural numbers is called *denumerable*; otherwise it is called *non-denumerable*.

!!! definition
    The *cardinal number* of the set ``\lbrace 1,2,3,\ldots,n\rbrace`` as well as any set equivalent to it is defined to be ``n``. The cardinal number of any denumerable set is defined as ``\aleph_0``, *aleph null*. The cardinal number of the empty set ``\emptyset`` is defined as ``0``.

The cardinal number of a set ``S`` is denoted by ``\#S``.

## Quantifiers

Let ``A`` be a given set. A *propositional function* defined on ``A`` is a function ``𝒫:A\to \lbrace T,F\rbrace`` which has the property that ``𝒫\left(a\right)`` is true or false for each ``a\in A``. That is, ``𝒫\left(x\right)`` becomes a proposition (with a truth value) whenever any element ``a\in A`` is substituted for the variable ``x.`` The set ``T_{𝒫}`` of all elements of ``a\in A`` for which ``𝒫\left(a\right)`` is true is called the *truth set* of ``𝒫\left(x\right)``.

!!! example

	Find the truth set ``T_{𝒫}`` of each propositional function ``𝒫\left(x\right)`` defined on ``ℕ``.
	
	* Let ``𝒫\left(x\right)`` be "``x+2&gt;7``". Then ``T_{𝒫} =\lbrace x\mid x\in ℕ,x+2&gt;7\rbrace =\lbrace 6,7,8,\ldots\rbrace``. 
	* Let ``𝒫\left(x\right)`` be "``x+5 < 3``". Then ``T_{𝒫} =\lbrace x\mid x\in ℕ,x+5 < 3\rbrace =\emptyset``. In other words, ``𝒫\left(x\right)`` is false for any natural number. 
	* Let ``𝒫\left(x\right)`` be "``x+5&gt;1``". Then ``T_{𝒫} =\lbrace x\mid x\in ℕ,x+5&gt;1\rbrace =ℕ``. Thus ``𝒫\left(x\right)`` is true for every natural number. 

Let ``𝒫\left(x\right)`` be a propositional function defined on a set ``A``. Consider the expression "``\forall x\in A:𝒫\left(x\right)``" which reads "For every ``x`` in ``A``, ``𝒫\left(x\right)`` is a true statement". The symbol ``\forall`` which reads "for all" or "for every" is called the *universal quantifier*. The proposition ``\forall x\in A:𝒫\left(x\right)`` expresses that the truth set of ``𝒫\left(x\right)`` is the entire set ``A``, or symbolically, ``T_{𝒫} =\lbrace x\mid x\in A,𝒫\left(x\right)\rbrace =A``.

!!! example

	Some propositions using the universal quantifier:

	* The proposition ``\forall n\in ℕ:n+4&gt;3`` is true since ``\lbrace n\mid n\in ℕ,n+4&gt;3\rbrace =ℕ``. 
	* The proposition ``\forall n\in ℕ:n+2&gt;8`` is false since ``\lbrace n\mid n\in ℕ,n+2&gt;8\rbrace =\lbrace 7,8,9,\ldots\rbrace``. 
	* The symbol ``\forall`` can be used to define the intersection of an indexed collection ``\lbrace A_i\mid i\in I\rbrace`` of sets ``A_i`` as follows: ``\bigcap_{i\in I} A_i =\lbrace x\mid\forall i\in I:x\in A_i \rbrace``. 

Let ``𝒫\left(x\right)`` be a propositional function defined on a set ``A``. Consider the expression "``\exists x\in A:𝒫\left(x\right)``" which reads "There exists an ``x`` in ``A`` such that ``𝒫\left(x\right)`` is a true statement". The symbol ``\exists`` which reads "there exists" or "for some" or "for at least one" is called the *existential quantifier*. The proposition ``\exists x\in A:𝒫\left(x\right)`` expresses that the truth set of ``𝒫\left(x\right)`` is not the emptyset, or symbolically, ``T_{𝒫} =\lbrace x\mid x\in A,𝒫\left(x\right)\rbrace \not= \emptyset``.

!!! example

	Some propositions using the existential quantifier:

	* The proposition ``\exists n\in ℕ:n+4 < 7`` is true since ``\lbrace n\mid n\in ℕ,n+4 < 7\rbrace =\lbrace 0,1,2\rbrace \not= \emptyset``. 
	* The proposition ``\exists n\in ℕ:n+6 < 4`` is false since ``\lbrace n\mid n\in ℕ,n+6 < 4\rbrace =\emptyset``. 
	* The symbol ``\exists`` can be used to define the intersection of an indexed collection ``\lbrace A_i\mid i\in I\rbrace`` of sets ``A_i`` as follows: ``\bigcup_{i\in I} A_i =\lbrace x\mid\exists i\in I:x\in A_i \rbrace``. 

Consider the proposition: "All officers are engineers". Its negation is either of the following equivalent statements:

* "It is not the case that all officers are engineers". 
* "There exists at least one officer who is not an engineer". 

Symbolically, using ``M`` to denote the set of officers, the above can be written as

```math
\lnot \left(\forall x\in M:x\;\textrm{is}\;\textrm{an}\;\textrm{engineer}\;\right)\equiv \exists x\in M:x\;\textrm{is}\;\textrm{not}\;\textrm{an}\;\textrm{engineer}\,,
```

or, when ``𝒫\left(x\right)`` denotes "``x`` is an engineer",

```math
\lnot \left(\forall x\in M:𝒫\left(x\right)\right)\equiv \exists x\in M:\lnot 𝒫\left(x\right)\,.
```

The above is true for any proposition ``𝒫\left(x\right)``.

!!! theorem "De Morgan 1"

	``\lnot \left(\forall x\in A:𝒫\left(x\right)\right)\equiv \exists x\in A:\lnot 𝒫\left(x\right)``.

In other words, the following two statements are equivalent:

* It is not true that, for all ``a\in A``, ``𝒫\left(a\right)`` is true. 
* There exists an ``a\in A`` such that ``𝒫\left(a\right)`` is false. 

There is an analogous theorem for the negation of a proposition which contains the existential quantifier.

!!! theorem "De Morgan 2"

	``\lnot \left(\exists x\in A:𝒫\left(x\right)\right)\equiv \forall x\in A:\lnot 𝒫\left(x\right)``.

That is, the following two statements are equivalent:

* It is not true that, for some ``a\in A``, ``𝒫\left(a\right)`` is true. 
* For all ``a\in A``, ``𝒫\left(a\right)`` is false. 

Previously, ``\lnot`` was used as an operation on propositions, here ``\lnot`` is used as an operation on propositional functions. The operations ``\vee`` and ``\wedge`` can also be applied to propositional functions.

1. The truth set of ``\lnot 𝒫\left(x\right)`` is the complement of ``T_{𝒫}``, that is ``T_{𝒫}^c``.
2. The truth set of ``𝒫\left(x\right)\vee 𝒬\left(x\right)`` is the union of ``T_{𝒫}`` and ``T_{𝒬}``, that is ``T_{𝒫} \cup T_{𝒬}``.
3. The truth set of ``𝒫\left(x\right)\wedge 𝒬\left(x\right)`` is the intersection of ``T_{𝒫}`` and ``T_{𝒬}``, that is ``T_{𝒫} \cap T_{𝒬}``.

A propositional function of 2 variables defined over a product set ``A=A_1 \times A_2`` is a function ``A_1 \times A_2 \to \lbrace T,F\rbrace :𝒫\left(x_1,x_2 \right)`` which has the property that ``𝒫\left(a_1,a_2 \right)`` is true or false for any pair ``\left(a_1,a_2 \right)`` in ``A``.

A propositional function can be generalized over a product set of more than 2 sets. A propositional function preceded by a quantifier for each variable denotes a proposition and has a truth value.

!!! example

	Let ``B=\lbrace 1,2,3,\ldots,9\rbrace`` and let ``𝒫\left(x,y\right)`` denotes "``x+y=10``". Then ``𝒫\left(x,y\right)`` is a propositional function on ``A=B\times B``.

	1.  The following is a proposition since there is a quantifier for each variable: ``\forall x\in B,\exists y\in B:𝒫\left(x,y\right)`` that is, "For every ``x`` in ``B``, there exists a ``y`` in ``B`` such that ``x+y=10``". This statement is true.
	2. The following is also a proposition: ``\exists y\in B,\forall x\in B:𝒫\left(x,y\right)`` that is, "There exists a ``y`` in ``B`` such that, for every ``x`` in ``B``, we have ``x+y=10``". No such ``y`` exists; hence the statement is false.

Observe that the only difference between both examples is the order of the quantifiers. Thus a different ordering of the quantifiers may yield a different statement!

!!! theorem

	For any propositional function ``𝒫\left(x,y\right)`` :
	
	1. ``\forall x\in A,\forall y\in B:𝒫\left(x,y\right)~\iff ~\forall y\in B,\forall x\in A:𝒫\left(x,y\right)``.
	2. ``\exists x\in A,\exists y\in B:𝒫\left(x,y\right)~\iff ~\exists y\in B,\exists x\in A:𝒫\left(x,y\right)``.
	3. ``\exists x\in A,\forall y\in B:𝒫\left(x,y\right)~\implies ~\forall y\in B,\exists x\in A:𝒫\left(x,y\right)``.
	4. ``\forall x\in A,\exists y\in B:𝒫\left(x,y\right)~\mathrel{\rlap{\implies}\ \,/\quad}~\exists y\in B,\forall x\in A:𝒫\left(x,y\right)``.

Quantified statements with more than one variable may be negated by successively applying the theorems of De Morgan. Thus each ``\forall`` is changed to ``\exists``, and each ``\exists`` is changed to ``\forall`` as the negation symbol ``\lnot`` passes through the statement from left to right.

!!! example

	Some examples of the negation of quantified statement with more than one variable:

	* ``\lnot \left(\forall x\in A,\exists y\in B,\exists z\in C:𝒫\left(x,y,z\right)\right)\equiv \exists x\in A,\lnot \left(\exists y\in B,\exists z\in C:𝒫\left(x,y,z\right)\right)\equiv`` ``\exists x\in A,\forall y\in B,\lnot \left(\exists z\in C:𝒫\left(x,y,z\right)\right)\equiv \exists x\in A,\forall y\in B,\forall z\in C:\lnot 𝒫\left(x\right)``. 
	* Consider the proposition: "Every student has at least one course where the lecturer is an officer". Its negation is the statement: "There is a student such that all his courses have a lecturer which is not an officer". 

## Proofs

Many proofs can be written by following a simple *template* that suggests guidelines to follow when writing the proof.

### Direct Proof

To prove ``𝒫\implies 𝒬``, we can proceed by looking at the truth table. The table shows that if ``𝒫`` is false, the statement ``𝒫\implies 𝒬`` is automatically true. This means that if we are concerned with showing ``𝒫\implies 𝒬`` is true, we don’t have to worry about the situations where ``𝒫`` is false  because the statement ``𝒫\implies 𝒬`` will be automatically true in those cases. But we must be very careful about the situations where ``𝒫`` is true. We must show that the condition of ``𝒫`` being true forces ``𝒬`` to be true also.

!!! template "direct proof"

	*SET THE CONTEXT*

	*ASSERT THE HYPOTHESIS*

	*LIST IMPLICATIONS*

	*STATE THE CONCLUSION*

!!! example

	Prove the proposition "The sum of any two odd natural numbers is even".

!!! proof

    *SET THE CONTEXT:* Let ``m`` and ``n`` be two natural numbers.

    *ASSERT THE HYPOTHESIS:* Suppose ``m`` and ``n`` are odd.

    *LIST IMPLICATIONS:*

    1. From the definition of odd natural numbers, there is a natural number ``k_1`` such that ``m=2k_1 +1`` and a natural number ``k_2`` such that ``n=2k_2 +1``.
    2. Then ``m+n=\left(2k_1 +1\right)+\left(2k_2 +1\right)=2\left(k_1 +k_2 +1\right)``.
    3. Since ``k_1`` and ``k_2`` are natural numbers, so is ``k_1 +k_2 +1``.
    4. Thus, the sum ``m+n`` is equal to twice a natural number, so by the definition of even natural numbers, ``m+n`` is even.

    *STATE THE CONCLUSION*: Therefore, the sum of any two odd natural number is always even.        


In proving a statement is true, we sometimes have to examine multiple cases before showing the statement is true in all possible scenarios.

!!! template "direct proof with multiple cases"

	*SET THE CONTEXT*

	*CASE 1: ASSERT THE HYPOTHESIS*

	*CASE 1: LIST IMPLICATIONS*

	*CASE 1: STATE THE CONCLUSION*

	*CASE 2: ASSERT THE HYPOTHESIS*

	*CASE 2: LIST IMPLICATIONS*

	*CASE 2: STATE THE CONCLUSION*

	*...*

	*STATE THE GENERAL CONCLUSION*

!!! example

	Prove the proposition "If ``n\in ℕ``, then ``1+\left(-1\right)^n \left(2n-1\right)`` is a multiple of ``4``".

!!! proof

    Let ``n`` be a natural number.

    *CASE 1:* Suppose ``n`` is even. Then ``n=2k`` for some ``k\in ℕ``, and ``\left(-1\right)^n =1``. Thus ``1+\left(-1\right)^n \left(2n-1\right)=1+\left(1\right)\left(2\cdot 2k-1\right)=4k``, which is a multiple of ``4``.

    *CASE 2:* Suppose ``n`` is odd. Then ``n=2k+1`` for some ``k\in ℕ``, and ``\left(-1\right)^n =-1``. Thus ``1+\left(-1\right)^n \left(2n-1\right)=1-\left(2\left(2k+1\right)-1\right)=-4k``, which is a multiple of ``4``. 

    These cases show that ``1+\left(-1\right)^n \left(2n-1\right)`` is always a multiple of ``4``.             

### Proof by Contraposition

Sometimes a direct proof of ``𝒫\implies 𝒬`` is very hard. The proposition ``\lnot 𝒬\implies \lnot 𝒫`` is logically equivalent to ``𝒫\implies 𝒬``. This is called the *contraposition* of the initial proposition.

!!! exercise

	Show ``\left(\lnot 𝒬\implies \lnot 𝒫\right)\equiv\left(𝒫\implies 𝒬\right)`` using a truth table.

!!! template "proof by contraposition"

	*SET THE CONTEXT*

	*ASSERT THE HYPOTHESIS:* ``\lnot 𝒬`` is true

	*LIST IMPLICATIONS*

	*STATE THE CONCLUSION:* ``\lnot 𝒫`` is true

!!! example

	Prove by contraposition the proposition "Let ``x\in ℕ``. If ``x^2`` is even, then ``x`` is even".

	A direct proof would be problematic. We will proof the logically equivalent proposition "If ``x`` is not even, then ``x^2`` is not even".

!!! proof "by contraposition"

    Let ``x\in ℕ``. 

    Suppose ``x`` is not even. 

    Then ``x`` is odd and ``x=2k+1`` for some ``k\in ℕ``. Thus ``x^2=\left(2k+1\right)^2=2\left(2k^2+2k\right)+1``. Since ``k`` is a natural number, ``2k^2+2k`` is also a natural number. Consequently, ``x^2`` is odd. 

    Therefore, ``x^2`` is not even.

### Proof by Contradiction

A proof by *contradiction* is not limited to proving just conditional statements—it can be used to prove any kind of statement whatsoever. The basic idea is to assume that the statement we want to prove is false, and then show that this assumption leads to nonsense. We are then led to conclude that we were wrong to assume the statement was false, so the statement must be true.

!!! exercise

	Show ``𝒫\equiv \left(\lnot 𝒫\implies\left(𝒞\wedge \lnot 𝒞\right)\right)`` using a truth table.

!!! template "proof by contradiction"

	*SET THE CONTEXT*

	*ASSERT THE HYPOTHESIS:* ``𝒫`` is false.

	*LIST IMPLICATIONS*

	*STATE THE CONCLUSION:* ``𝒞\wedge \lnot 𝒞``.

A slightly unsettling feature of this method is that we may not know at the beginning of the proof what the statement ``𝒞`` is going to be. 

!!! example

	Prove by contradiction the proposition "If ``a,b\in ℕ``, then ``a^2 -4b\not= 2``".

!!! proof "by contradiction"

    Let ``a,b\in ℕ``.

    Suppose there exist ``a`` and ``b`` for which ``a^2 -4b=2``. From this equation we get ``a^2 =4b+2=2\left(2b+1\right)\,,`` so ``a^2`` is even.

    Because ``a^2`` is even, it follows that ``a`` is even, so ``a=2c`` for some natural number ``c``. Now plug ``a=2c`` back into the boxed equation to get ``\left(2c\right)^2 -4b=2``, so ``4c^2 -4b=2``. Dividing by ``2``, we get ``2c^2 -2b=1``.

    Therefore, ``1=2\left(c^2 -b\right)``, and because ``c^2 -b\in ℕ``, it follows that ``1`` is even.

    We know ``1`` is  **not** even, so something went wrong. But all the logic after the first line of the proof is correct, so it must be that the first line was incorrect. In other words, we were wrong to assume the proposition was false. Thus the proposition is true.

The previous two proof methods dealt exclusively with proving conditional statements, we now formalize the procedure in which contradiction is used to prove a conditional statement. Thus we need to prove that ``𝒫\implies𝒬`` is true. Proof by contradiction begins with the assumption that ``\lnot \left(𝒫\implies Q\right)`` is true, that is, that ``𝒫\implies 𝒬`` is false. But we know that ``𝒫\implies 𝒬`` being false means that it is possible that ``𝒫`` can be true while ``𝒬`` is false. Thus the first step in the proof is to assume ``𝒫`` and ``\lnot 𝒬``. 

!!! template "proof by contradiction of a conditional proposition"

	*SET THE CONTEXT*

	*ASSERT THE HYPOTHESIS:* ``𝒫`` and ``\lnot 𝒬`` are true.

	*LIST IMPLICATIONS*

	*STATE THE CONCLUSION:* ``𝒞\wedge \lnot 𝒞``.

!!! example

	Prove by contradiction the proposition "Let ``a\in ℕ``. If ``a^2`` is even, then ``a`` is even".

!!! proof "by contradiction"

    Let ``a\in ℕ``.

    Suppose ``a^2`` is even and ``a`` is not even.

    Since ``a`` is odd, there exists a natural number ``c`` for which ``a=2c+1``. Then ``a^2 =\left(2c+1\right)^2 =4c^2+4c+1=2\left(2c^2 +2c\right)+1``, so ``a^2`` is odd. 

    Thus ``a^2`` is even and ``a^2`` is not even, a contradiction.

### If-and-only-if Proof

Some propositions have the form ``𝒫\iff 𝒬``. We know that this is logically equivalent to ``\left(𝒫\implies 𝒬\right)\wedge \left(𝒬\implies 𝒫\right)``. So to prove "``𝒫`` if and only if ``𝒬``" we must prove  **two** conditional statements. Recall that ``𝒬\implies 𝒫`` is called the  *converse* of ``𝒫\implies 𝒬``. Thus we need to prove both ``𝒫\implies 𝒬`` and its converse. These are both conditional statements, so we may prove them with either direct, contrapositive or contradiction proof.

!!! example

	Prove the proposition "The natural number ``n`` is odd if and only if ``n^2`` is odd".

!!! proof

    Let ``n\in ℕ``.

    First we show that ``n`` being odd implies that ``n^2`` is odd. 

    Suppose ``n`` is odd. 

    Then, by definition of an odd number, ``n=2a+1`` for some natural number. Thus ``n^2 =\left(2a+1\right)^2 =4a^2 +4a+1=2\left(2a^2 +2a\right)+1``. This expresses ``n^2`` as twice a natural number, plus 1.

    Therefore, ``n^2`` is odd. 

    Conversely, we need to prove that ``n^2`` being odd implies that ``n`` is odd. We use contraposition and proof the proposition "``n`` not odd implies that ``n^2`` is not odd". 

    Suppose ``n`` is not odd. 

    Then ``n`` is even, so ``n=2a`` for some natural number ``a`` by definition of an even number. Thus ``n^2 =\left(2a\right)^2 =2\left(2a^2 \right)``, so ``n^2`` is even because it’s twice a natural number.

    Therefore, ``n^2`` is not odd.

### Existence Proof

Up until this point, we have dealt with proving conditional statements or with statements that can be expressed with two or more conditional statements. Generally, these conditional statements have form ``𝒫\left(x\right)\implies 𝒬\left(x\right)``(Possibly with more than one variable). We saw that this can be interpreted as a universally quantified statement ``\forall x:𝒫\left(x\right)\implies 𝒬\left(x\right)``. 

But how would we prove an  *existentially* quantified statement? What technique would we employ to prove a theorem of the form ``\exists x:𝒫\left(x\right)``. This statement asserts that there exists some specific object ``x`` for which ``𝒫\left(x\right)`` is true. To prove ``\exists x:𝒫\left(x\right)`` is true, all we would have to do is find and display an  *example* of a specific ``x`` that makes ``𝒫\left(x\right)`` true. 

!!! example

	There exists a natural number that can be expressed as the sum of two perfect cubes in two different ways.

!!! proof

    Consider the number ``1729``. 

    Note that ``1^3 +12^3 =1729`` and ``9^3 +10^3 =1729``. 

    Therefore, the number ``1729`` can be expressed as the sum of two perfect cubes in two different ways.

### Counterexamples

How to disprove a universally quantified statement such as ``\forall x:𝒫\left(x\right)``? To disprove this statement, we must prove its negation. Its negation is ``\lnot\left(\forall x:𝒫\left(x\right)\implies 𝒬\left(x\right)\right)\equiv \exists x:\lnot\left(𝒫\left(x\right)\implies 𝒬\left(x\right)\right)``. The negation is an existence statement. To prove the negation is true, we just need to produce an example of an ``x`` that makes ``𝒫\left(x\right)`` false.

!!! example

	Disprove the proposition "For every ``n\in ℕ``, the natural number ``f\left(n\right)=n^2 -n+11`` is prime".

!!! proof

    The statement "For every ``n\in ℕ``, the natural number ``f\left(n\right)=n^2 -n+11`` is prime," is false. For a counterexample, note that for ``n=11``, the natural number ``f\left(11\right)=121=11\cdot 11`` is not prime.

### Proof by Induction

Suppose the variable ``n`` represents any natural number, and there is a propositional function ``𝒫\left(n\right)`` that includes this variable as an argument. *Mathematical induction* is a proof technique that uses the axiom of induction to show that ``𝒫\left(n\right)`` is true for all ``n`` greater than or equal to some base value ``b\in ℕ``.

!!! template "proof by induction"

	*SET THE CONTEXT:* The statement will be proved by mathematical induction on ``n`` for all ``n\ge b``.

	*PROVE* ``𝒫\left(b\right)`` *:* Prove that the statement is true when the variable ``n`` is equal to the base value, ``b``.

	*STATE THE INDUCTION HYPOTHESIS:* Assume that ``𝒫\left(n\right)`` is true for some natural number ``n=k\ge b``.

	*PERFORM THE INDUCTION STEP:* Using the fact that ``𝒫\left(k\right)`` is true, prove that ``𝒫\left(k+1\right)`` is true.

	*STATE THE CONCLUSION:* Therefore, by mathematical induction, ``𝒫\left(n\right)`` is true for all natural numbers ``n\ge b``.

!!! example

	Prove by induction the proposition "If ``n\in ℕ\setminus \lbrace 0\rbrace``, then ``1^2+2^2+3^2+\cdots+n^2=\frac{1}{6}n\left(n+1\right)\left(2n+1\right)\,``". 

!!! proof "by induction"
    
    Let ``n\in ℕ_0``.
    
    Observe that if ``n=1``, this statement is ``1=\frac{1}{6}\left(1\right)\left(2\right)\left(3\right)``, which is obviously true.
    
    Suppose that ``1^2+2^2+3^2+\cdots+k^2=\frac{1}{6}k\left(k+1\right)\left(2k+1\right)`` for some natural number ``k\ge 1``.
    
    Then,

	```math
	\begin{aligned}
	1^2+2^2+3^2+\cdots+k^2+\left(k+1\right)^2&=\frac{1}{6}k\left(k+1\right)\left(2k+1\right)+\left(k+1\right)^2\\
	&=\frac{1}{6}\left(2k^3+\left(3+6\right)k^2+\left(1+12\right)k+6\right)\\
	&=\frac{1}{6}\left(2k^3+9k^2+13k+6\right)\\
	&=\frac{1}{6}\left(k+1\right)\left(k+2\right)\left(2k+3\right)\\
	&=\frac{1}{6}\left(k+1\right)\left(\left(k+1\right)+1\right)\left(2\left(k+1\right)+1\right)
	\end{aligned}
	```


    Therefore, by mathematical induction, ``1^2+2^2+3^2+\cdots+n^2=\frac{1}{6}n\left(n+1\right)\left(2n+1\right)`` for all natural numbers ``n\ge 1``.