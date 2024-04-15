# https://docs.julialang.org/en/v1/manual/functions/

function g(X, a)
  a * X
end

g(X, a, w) = w * a * X

g(X, a::Int64) = 2 * a * X

g(X::Matrix) = -X

g(X::Vector) = -10 * X

methods(g)

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

g1(x, y, a, b) = a * x + b * y

g2 = function(x, y, args...)
  g1(x, y, args...)
end

x = [1.0 ; 2.0 ; 3.0]
y = [4.0 ; 5.0 ; 6.0]
g2(x, y, -2, -3)

## kwargs...

f1(x, y; a, b) = a * x + b * y

f2 = function(x, y; kwargs...)
  f1(x, y; kwargs...)
end

x = [1.0 ; 2.0 ; 3.0]
y = [4.0 ; 5.0 ; 6.0]
f2(x, y; a = 2, b = 3)

##################### INPLACE 

function g1(X, a = 2)
  X = a * X
  X
end

function g1!(X, a = 2)
  X .= a * X
  X
end

X = round.(10 * rand(5, 3))
g1(X)
X
g1!(X)
X

##################### STRUCTURE 

struct Foo     # Not modifiable!
  a
  b::Int
end
typeof(Foo)

function foo(x)
  a = sum(x)
  b = Int64(round(a))
  Foo(a, b)
end

function predict(fm::Foo, x)
    fm.a .+ fm.b * x
end

x = rand(5)
res = foo(x)
res.a 
res.b 

xnew = rand(3)
predict(res, xnew)

##################### VECTORIZATION 

g(x, y) = 3 * x + 4 * y 

A = [1.0 ; 2.0 ; 3.0]
B = [4.0 ; 5.0 ; 6.0]
g.(A, B)
g.(pi, A)


