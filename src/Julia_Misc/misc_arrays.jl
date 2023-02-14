using LinearAlgebra, SparseArrays, StatsBase

# https://docs.julialang.org/en/v1/base/arrays/

Array{Float64, 2}
Array{Float64, 2}(undef, 2, 3)
Array{Float64}(undef, 2, 3)
Array{Float64}(undef, 2, 3, 2)
Array{Float64, 1}(undef, 5)
Array{Float64}(undef, 5)

# Vector{T} <: AbstractVector{T}
# Alias for Array{T, 1}.
Vector{Float64}(undef, 3)
Vector{Union{Missing, String}}(missing, 3)
Vector{Matrix}(undef, 3)
Vector{Matrix{Float64}}(undef, 3)

# Matrix{T} <: AbstractMatrix{T}
# Alias for Array{T, 2}.
Matrix{Float64}
Matrix{Float64}(undef, 2, 3)
Matrix{Int64}(undef, 2, 3)

X = Matrix{Float64}(undef, 2, 3)
X .= rand(2, 3)
X

X'

X = rand(5, 3)
X[1:2, :]
X[1:1, :]
X[1, :]

v = vec(X)
reshape(v, 5, 3)

X = rand(5, 5)
reshape(X, length(X), 1)
reshape(X, :, 1) 
vec(X)

view(X, 1:2, :)
@view(X[1:2, :])

X1 = rand(3, 2) 
X2 = rand(2, 4) 
[X1, X2]
(X1, X2)
(a = X1, b = X2)
(a = X1, X2)

x = vec(rand(50, 1))
describe(x)

#################### CONCATENATION

## Use push! to add individual items to collection which are not already themselves in another collection. 
## The result of the preceding example is equivalent to push!([1, 2, 3], 4, 5, 6).

append!([1 ; 2 ; 3], [4 ; 5 ; 6])
push!([1 ; 2 ; 3], 4, 5, 6)

x = [1 ; 2 ; 3]
push!(x, 4, 5, 6) ;
x

## hcat, vcat
# https://discourse.julialang.org/t/vcat-vs-push-which-one-is-more-efficient/48353

X1 = rand(3, 2) 
X2 = -rand(5, 2) 
vcat(X1, X2)
cat(X1, X2; dims = 1)
reduce(vcat, [X1, X2])
reduce(vcat, (X1, X2, X1))

z = Vector{Matrix}(undef, 3)
z[1] = X1 ; z[2] = X2 ; z[3] = X1  
reduce(vcat, z)

z = ((1, 2, 3), (5, 6, 7), (10, 11, 12))
[z...]
v = collect.(z)
reduce(hcat, v)
f_comp(a) = [collect(i) for i in a]
v = f_comp(z)
reduce(hcat, v)

z = (a = (1, 2, 3), b = (5, 6, 7))
[z...]
v = collect(z)
u = f_comp(v)
reduce(hcat, u)

#################### DIAGONAL
# https://web.eecs.umich.edu/~fessler/course/551/julia/tutor/03-diag.html

diagm(1:5)      # LinearAlgebra
Diagonal(1:5)   # LinearAlgebra
spdiagm(1:5)    # SparseArrays

X = diagm(1:5)
isdiag(X)

n = 2000 # medium-size problem to illustrate the differences
M = diagm(0 => 1:n) 
D = Diagonal(1:n) 
S = spdiagm(0 => 1:n) 
x = rand(n) ; # random test vector
@time y = M * x ; # >100× slower!
@time y = D * x ; # fastest
@time y = S * x ; # 3× slower
# Here is a faster version that overwrites y each time:
@time mul!(y, M, x) ; 
@time mul!(y, D, x) ; 
@time mul!(y, S, x) ; 

X = rand(5, 4)
diag(X)

n = 3
X = rand(n, n)
d = rand(n)
Diagonal(d) * X
d .* X
(*).(d, X)
X * Diagonal(d)
X .* d'

n = 5000
X = rand(n, n)
d = rand(n)
D = Diagonal(d)
@time D * X ;
@time d .* X ;
@time (*).(d, X) ; # slow

#################### MAPSLICES

X = rand(5, 3)
mapslices(mean, X, dims = 1)
StatsBase.mean(X, dims = 1) # much faster

#################### PRODUCTS

A = rand(2, 3)
B = rand(3, 2)
A * B

C = zeros(2, 2) 
mul!(C, A, B)

n, p = size(A)
C = similar(A, n, n) 
mul!(C, A, B)
# Same as:
C .= A * B

X = [1. 2 ; 3  4]
ldiv!(2., X) ;
X

X = [1. 2 ; 3  4]
rdiv!(X, 2.0) ;
X

#### Dot products

n = 10
w = randn(n) 
w' * w
dot(w, w)
sum(w .* w)

n = Int64(1e7)
w = rand(n) 
@time w' * w ;      ## Same as dot
@time dot(w, w) ;
@time sum(w .* w) ; ## Much slower

############### TUPLE

## https://discourse.julialang.org/t/create-empty-tuple/1032/5

z = ntuple(i -> 0.0, 5)
[i for i in z]
collect(z)

