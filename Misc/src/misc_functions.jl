using Chairmarks

# https://docs.julialang.org/en/v1/manual/functions/

function g(X, a)
  a * X
end

g(X, a, w) = w * a * X

g(X, a::Int) = 2 * a * X

g(X::Matrix) = -X

g(X::Vector) = -10 * X

methods(g)
first(methods(g), 1)
first(methods(g), 10)
collect(methods(g))
res = Base.method_argnames.(methods(g))
res[3]

X = rand(2, 2)
g(X, 2.)
g(X, 2)
g(X)
g(X[:, 1])

function h(X, a, b = -10)
  a * b * X
end

X = rand(5, 3)
h(X, 10)
h(X, 10, 100)

## Keywords arguments 

function h(X; a, b = -1)
  a * b * X
end

X = rand(5, 3)
h(X; a = .1)
h(X; a = .1, b = 100)

## Does not create two methods
# function h(X; a)
# function h(X; a, b)

## args...

h1(x, y, a, b) = a * x + b * y

h2 = function(x, y, args...)
  h1(x, y, args...)
end

x = [1.0; 2.0; 3.0]
y = [4.0; 5.0; 6.0]
h2(x, y, -2, -3)

## kwargs...

f1(x, y; a, b) = a * x + b * y

f2 = function(x, y; kwargs...)
  f1(x, y; kwargs...)
end

x = [1.0; 2.0; 3.0]
y = [4.0; 5.0; 6.0]
f2(x, y; a = 2, b = 3)

##################### Inplace 

function h1(X, a = 2)
  X = a * X
  X
end

function h1!(X, a = 2)
  X .= a * X
  X
end

X = round.(10 * rand(5, 3))
h1(X)
X
h1!(X)
X

##################### Structure 

struct Foo     # Not modifiable!
  a
  b::Int
end
typeof(Foo)

function foo(x)
  a = sum(x)
  b = Int(round(a))
  Foo(a, b)
end

function predict(fitm::Foo, x)
    fitm.a .+ fitm.b * x
end

x = rand(5)
res = foo(x)
res.a 
res.b 

xnew = rand(3)
predict(res, xnew)

##################### Vectorization 

g(x, y) = 3 * x + 4 * y 

A = [1.0; 2.0; 3.0]
B = [4.0; 5.0; 6.0]
g.(A, B)
g.(pi, A)

##################### Coding

## https://discourse.julialang.org/t/julian-way-to-write-this-code/119348/18

function g1(x, y, w)
  sum(i -> x[i] * y[i] * w[i], 1:length(x))
end

function g2(x, y, w)
    sum(x .* y .* w)
end

function g3(x::AbstractArray{T}, y::AbstractArray{T}, w::AbstractArray{T}) where T
    l = length(x)
    r = T(0)
    @inbounds for i in 1:l
        r += x[i] * y[i] * w[i]
    end
    return r
end

function g4!(x, y, w)
    x .*= y
    x .*= w
    sum(x)
end

## Generally using eachindex signals the compiler that the index access are in fact inbounds.
function g5(x, y, w)
  T = promote_type(eltype(x), eltype(y), eltype(w))
  r = zero(T)
  for i in eachindex(x, y, w)
      r += x[i] * y[i] * w[i]
  end
  return r
end

g7(x, y, z) = sum(splat(*), zip(x, y, z))

g9(x, y, z) = sum(x[i] * y[i] * z[i] for i in eachindex(x, y, z))

## Results highly depend on n
n = 10^5
#n = 10^6
#n = 3
x = rand(n); y = rand(n); z = rand(n)
vx = copy(x); vy = copy(y); vz = copy(z) 
@b g1($x, $y, $z)  # ** for large n
@b g2($x, $y, $z)
@b g3($x, $y, $z)
@b g4!($vx, $vy, $vz)
@b g5($x, $y, $z)
@b g7($x, $y, $z)
@b g9($x, $y, $z)

@b g1(x, y, z)  # ** for large n
@b g2(x, y, z)
@b g3(x, y, z)
@b g4!(vx, vy, vz)
@b g5(x, y, z)
@b g7(x, y, z)
@b g9(x, y, z)

