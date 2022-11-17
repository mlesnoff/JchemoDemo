using StatsBase, DataFrames, FreqTables

parentmodule(mean)
typeof(mean)

Base.loaded_modules

############### CONVERT

x = 1.
convert(Int64, x)

x = collect(1:10)
typeof(x)
convert(Vector{Float64}, x)
convert.(Float64, x)
Float64.(x)

X = DataFrame(rand(5, 3), :auto)
convert(Array, X)

############### DICTIONNARY, NAMES  

## https://docs.julialang.org/en/v1/base/collections/#Dictionaries
## https://en.wikibooks.org/wiki/Introducing_Julia/Dictionaries_and_sets

x = (nlv = 5, alpha = 12)
nam = keys(x)
collect(nam)
propertynames(x)

x.nlv
getproperty(x, :nlv)
getindex(x, 1)

d = Dict("a" => 1, "b" => 2)
keys(d)
get(d, "a", nothing)
get(d, "K", nothing)
get(d, "K", -20)
d["a"]

d = Dict(:x => 1, :y => 3, :z => 6)
d[:x]
get(d, :x, nothing)

x = rand([3, 4, 10], 100) 
#x = rand(("c", "10", "a"), 50)
d = countmap(x)
keys(d)
values(d)
get(d, 4, nothing)

function ftab(x)     # not efficient function
    d = Dict()
    for i in x
        d[i] = get!(d, i, 0) + 1
    end
    sort(d)
end
n = 100
x = rand([3, 4, 10, 20, 30, 2], n)
ftab(x)

############### EACHCOL, EACHROW 

X = rand(5, 3)
eachcol(X)
collect(eachcol(X))

for col in eachcol(X)
    println(sum(col))
end

map(sum, collect(eachcol(X)))
sum(X, dims = 1)

############### IF 

x = .3
x < .5 ? y = -1. : y = 1. ;
y

############### IS

if isdefined(fm, :C) == true
end
@isdefined

z = rand(1:9, 3)
typeof(z)
isa(x, Array)
isa(x, Vector)

summary(z)

################ FILL, REPEAT

fill(1.0, (2, 3))
ones(2, 3)
zeros(2, 3)

fill(zeros(2), 2)

v = collect(1:3)
x = fill(v, 5)
reduce(hcat, x)

x = fill(v, (5, 3))
reduce(hcat, x)

## repeat

repeat([.9], 5)
repeat([], 5)
repeat(["y"], 3)
repeat("y", 3)
"y"^3

v = collect(1:3)
x = repeat(v, 5)
repeat(v; outer = 5)
sort(x)
repeat(v; inner = 5)

repeat(1:2; outer = 2, inner = 3)

repeat([1 2 ; 3 4], inner = (2, 1), outer = (1, 3))

################ ISNAN 

X = reshape([NaN; rand(8); NaN], 5, 2)
X[isnan.(X)] .= 1
X

############### LOWERCASE, UPPERCASE 

x = ["a" ; "c"]
y = uppercase.(x) 
lowercase.(y)

############### MACRO

macro fname(arg)
    x = string(arg)
    quote
        $x
    end
end
a = @fname myvar      ## macro syntax
a = @fname(myvar)     ## called as a function

############### MAP, REDUCE 

# https://docs.julialang.org/en/v1/manual/arrays/#Broadcasting-1

# foreach(f, c...) -> Nothing
# Call function f on each element of iterable c. 
# foreach should be used instead of map when the results of f are not needed, 
# for example in foreach(println, array).

x = rand(5) 
foreach(println, x)

# map(f, c...) -> collection
# Transform collection c by applying f to each element. 
# For multiple collection arguments, apply f elementwise.

X = rand(5, 3)
map(sqrt, X)
sqrt.(X)

n = Int64(1e4)
X = rand(n, n) 
@time map(sqrt, X) ;
@time sqrt.(X) ; # Not faster

x = [1, 2, 3]
y = [10, 20, 30]
map(+, x, y)

fun = function(k)
    res = k + 1000
end
fun(5)
res = map(fun, collect(1:5))

q = 3 ;
map(string, repeat(["y"], q), 1:q)

X = rand(5, 3)
mapslices(mean, X; dims = 1)
mapslices(function g(x) ; sum(x) / length(x) ; end, X; dims = 1)

mapslices(argmax, X; dims = 2) 
# same as (but faster)
map(i -> argmax(X[i, :]), 1:size(X, 1))

## reduce(op, itr; [init])
## Reduce the given collection itr with the given binary operator op. 
## reduce(f, A; dims=:, [init])
## Reduce 2-argument function f along dimensions of A. 

reduce(-, [1 ; 2 ; 5])
map(-, [1 ; 2 ; 5])

X = rand(5, 3)
reduce(max, X; dims = 1)
mapslices(maximum, X; dims = 1) 

n = 1000 ; p = 100 ; m = 100
zX = Vector{Matrix}(undef, m)  
for i = 1:m ; zX[i] = rand(n, p) ; end
@time let
    X = zX[1]
    for i = 2:m
        X = hcat(X, zX[i])
    end
end
@time reduce(vcat, zX) ;  # Much faster

## mapreduce(f, op, itrs...; [init])
## Apply function f to each element(s) in itrs, and then reduce the result 
## using the binary function op.
## mapreduce is functionally equivalent to calling reduce(op, map(f, itr); init=init), 
## but will in general execute faster since no intermediate collection needs to be created.
## mapreduce(f, op, A::AbstractArray...; dims=:, [init])
## Evaluates to the same as reduce(op, map(f, A...); dims=dims, init=init), 
## but is generally faster because the intermediate array is avoided.

x = [1:3;]
reduce(+, map(v -> v^2, x))
mapreduce(v -> v^2, +, x)

n = 5
X = rand(n, 3)
reduce(hcat, map(i -> X[i, :] .== maximum(X[i, :]), 1:n))'
mapreduce(i -> X[i, :] .== maximum(X[i, :]), hcat, 1:n)'

## Ifelse
v = rand(1:2, 20)
map(x -> x == 1 ? :lightgrey : :red3, v)

############### PARSE, EVAL, ASSIGN 

## https://discourse.julialang.org/t/string-as-a-variable-name/2195

parse(Float64, "23")
parse(Int, "1234")
parse(Int, "1234", base = 5)
parse(Int, "afc", base = 16)
parse(Float64, "1.2e-3")

wl = string.(1:10)
parse.(Int64, wl) 
Meta.parse.(wl)
parse.(Float64, wl) 

eval(Meta.parse("1:5"))

id = ["hh123" ; "gg27"]
z = SubString.(id, 3)
parse.(Int64, z) 
Meta.parse.(z)   

fun = "sum"
flearn = eval(Meta.parse(fun))
x = rand(5)
flearn(x)

############### PASTE 

n = 3
x = repeat(["y"], n)
z = map(string, x, 1:n)
Symbol.(z)

############### PERFORMANCES 

## https://docs.julialang.org/en/v1/manual/performance-tips/

X = rand(1000, 100)
@time mean(X) ;
@time let 
    mean(X)
    var(X)
end 

## See BenchmarkTools.jl

################ RANGE, SEQ

u = range(0, 1, length = 10)
collect(u)

collect(1:5)

range(1, step = 5, length = 20)
collect(range(1, step = 5, length = 20))

range(1, step = 5, stop = 17)

################ REPLACE 

dict = Dict(
    "plsr" => 1,
    "plsr-p" => 2,
    "avg" => 3,
    "avg-cv" => 4,
    "avg-aic" => 5,
    "avg-bic" => 6,
    "stack" => 7)
z = ["stack"; "plsr-p"]
replace(z, dict...)

################ REMOVE 

## https://stackoverflow.com/questions/58033504/julia-delete-rows-and-columns-from-an-array-or-matix

X = rand(5, 2)
# remove rows 2 & 3
X[1:end .∉ [2:3], :]
X[setdiff(1:end, 2:3), :]

## setdiff(s, itrs...)
## Construct the set of elements in s but not in any of the iterables in itrs.
setdiff(1:10, 2:3)
setdiff([3 ; 7 ; 1], [3 ; 7 ; 1 ; 18])
setdiff([3 ; 7 ; 1], [1 ; 18])

############### SORT 

x = [5 ; 4 ; 200]
sort(x)
sort(x, rev = true)

## sortperm(v; alg::Algorithm=DEFAULT_UNSTABLE, lt=isless, by=identity, rev::Bool=false, order::Ordering=Forward)
## Return a permutation vector I that puts v[I] in sorted order. 
## The order is specified using the same keywords as sort!. 
x = [5 ; 4 ; 200]
id = sortperm(x)
x[id]
# "sortperm(x) = 3 7 etc." means
# - the 1st lower value of x is component 3 of x,
# - the 2nd lower value of x is component 7 of x,
# etc.

v = zeros(Int, 3)   ## Pre-allocated vector
sortperm!(v, x)     ## This recalculates p by the same output-value of sortperm
v

## See StatsBase.ordinalrank

############### STRING

X = rand(5, 2) 
string.(X)
repr.(X)

nam = ["fgvvh" ; "nngfjkjjk"]
SubString.(nam, 2, 4)
SubString.(nam, 2)






