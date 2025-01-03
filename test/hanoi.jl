const towers = [[9, 8, 7, 6, 5, 4, 3, 2, 1], Int64[], Int64[]]
const count = Ref{Int64}(0)

function move(n::Int64, from::Int64, to::Int64)
    if n === 1
        push!(towers[to], pop!(towers[from]))
        count[] += 1
    else
        aux = 6 - from - to
        move(n-1, from, aux)
        move(1, from, to)
        move(n-1, aux, to)
    end
end

move(9, 1, 3)

@show towers
@show count[]