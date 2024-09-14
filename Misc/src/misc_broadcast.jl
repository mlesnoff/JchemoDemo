using StatsBase

# https://docs.julialang.org/en/v1/manual/arrays/#Broadcasting-1

z = rand(5)
foreach(println, z)

## map, reduce, mapreduce, zip
## map(f, c...) -> collection
## Transform collection c by applying f to each element. 
## For multiple collection arguments, apply f elementwise.

map(+, [1, 2, 3], [10, 20, 30])

q = 3 
map(string, repeat(["y"], q), 1:q)

z = [4 2.5 3.7; 9 20 30] 
map(sqrt, z)
## sqrt(z) is not correct (makes square root of a matrix)

## With vectorization
## In general, not needed in Julia
## See https://docs.julialang.org/en/v1/manual/functions/
## Last Section
sqrt.(z)

##  See also: mapslices
mapslices(mean, z, dims = 1)

A = rand(5, 3)
mapslices(function g(x) ; x / sum(x) ; end, A, dims = 2)

A = rand(10, 3)
mapslices(argmax, A; dims = 2) 
# same as (but faster)
map(i -> argmax(A[i, :]), 1:size(A, 1))

n = 10000 
X = rand(n, n) 
@time map(sqrt, X) ;
@time sqrt.(X) ; ## Not faster

X = rand(5, 3)
mapslices(mean, X, dims = 1)
StatsBase.mean(X, dims = 1) # much faster

#### mapreduce

# zp = Jchemo.predict(object.fm_da, X).posterior
# zp .= (mapreduce(i -> Float64.(zp[i, :] .== maximum(zp[i, :])), hcat, 1:m)')

#### reduce

n = 1000 ; p = 1000 ; m = 100
X = Vector{Matrix{Float64}}(undef, m)
for i = 1:m
    X[i] = rand(n, p)
end
@time let
    zX = X[1]
    for i = 2:m
        zX = hcat(zX, X[i])
    end
end
# Much faster:
@time zX = reduce(hcat, X) ;  

n = 1000 ; m = 100
x = Vector{Vector{Float64}}(undef, m)
for i = 1:m
    x[i] = rand(n)
end
@time let
    zx = x[1]
    for i = 2:m
        zx = vcat(zx, x[i])
    end
end
@time let
    zx = [0.]
    for i = 2:m
        append!(zx, x[i])
    end
end
# Much faster
@time zx = reduce(vcat, x) ;


