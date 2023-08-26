using StatsBase 

## & = Bitwise (elementwise) "and"
1 & 1
1 & 2
1 & missing 

## && = Boolean "and": left and right parts must be boolean
x = 3
x > 2 && x <= 5
x > 2 && x < 3

x = collect(1:10)
(x .> 3) .& (x .<= 5)
(x .> 3) .* (x .<= 5)

## | = Bitwise 
## || = Boolean: left and right parts must be boolean

x = collect(1:10)
s = (x .< 3) .| (x .> 9)
x[s]
filter(u -> (u < 3) .| (u > 9), x)
filter(u -> (u < 3) || (u > 9), x)

############### IFELSE 

z = rand(5)
ifelse.(z .< .5, 1, 2)

############### SELECTION, FILTER

x = collect(1:10)
s = x .> 3
x[x .> 3]
x[s]
filter(u -> u > 3, x)

x = rand(10)
x[x .> .5] .= 10000
x

x = collect(1:10)
s = (x .> 3) .& (x .<= 5)
x[s]
filter(u -> (u > 3) .& (u <= 5), x)
filter(u -> (u > 3) && (u <= 5), x)
filter(u -> (u > 3) .&& (u <= 5), x)

############### FIND

## findall, findmax, findmin, indexin

x = rand(10)
x .> .5
s = findall(x .> .5)

findmax(x)
argmax(x)
s = isapprox.(x, maximum(x))
findall(s) 

findmin([1 ,.5, .5, 2]) # The first is returned

X = rand(3, 2)
findmax(X)
s = findmax(X)[2]
X[s]

findmax(X; dims = 1)

s = findall(X .> .5)
X[s] .= 0
X

X = rand(3, 2)
s = X .< .5
X[s] .= 0
X

################ REPLACE 

x = [rand(3) ; 0 ; 1]
replace(x, 0 => missing)
replace(x, 0 => missing, 1 => 200)

X = rand(5, 3)
replace(X, minimum(X) => -200)

x = collect(1:4)
replace(v -> isodd(v) ? 1e3 * v : v, x)

x = rand(10) 
replace(v -> v < 0.5 ? -10 : v, x)
u = copy(x)
u[u .< .5] .= -10
u

############### WITHIN

nam = string.(350:2500) 
z = ["1000" ; "1800"] ;
f = in(nam)    # function
f.(z)          # is z[i] in nam?
# same as:
in(nam).(z)    # is z[i] in nam?

in(z[1], nam)  # is z[1] in nam?

nam = string.(350:2500) 
z = ["1000" ; "1800"] ;
s = in(z).(nam)     # is nam[i] in z?
findall(s)

x = collect(1:5)
u = sample(x, 3, replace = false)
s = in(u).(x)
findall(s)
findall(s .== 0)

x = ["a" ; "b" ; "c" ; "d" ; "e"]
y = ["b" ; "a" ; "a" ; "c"]
indexin(y, x)  # returns where is y[i] in x

x = rand(Int64(1e6))
@time indexin(x[500], x)
@time findall(x .== x[500]) # for 1 search: faster 


