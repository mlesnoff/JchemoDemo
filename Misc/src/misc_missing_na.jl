using DataFrames

x = [rand(5) ; missing]
maximum(x)
maximum(skipmissing(x))
sum(skipmissing(x))

x = [rand(5) ; missing]
y = copy(x)
s = ismissing.(y)
y[s] .= -100
y 

y = copy(x)
replace(y, missing => -100)
replace!(y, missing => -100)
y

x1 = [missing ; rand(5) ; missing]
x2 = rand(7)
X = hcat(x1, x2)
maximum(X)
maximum(skipmissing(X))
sum(skipmissing(X))

Y = copy(X)
s = ismissing.(Y)
#s = findall(ismissing.(Y))
Y[s] .= -100
Y 

Y = copy(X)
replace(Y, missing => -100)
replace!(Y, missing => -100)
Y

Y = copy(X)
for col in eachcol(Y)
    replace!(col, missing => -100)
end
Y

Y = copy(X)
for row in eachrow(Y)
    replace!(row, missing => -100)
end
Y

#### Add missing values in a matrix
X = rand(5, 2)
X = convert(Matrix{Union{Missing, eltype(X)}}, X)
X[1, 1] = missing
X[2:3, 2] .= missing
X
## This can be done also with function
## 'allowmissing' exported by DataFrame.jl 
## from Missings.jl   
## Rq: 'allowmissing!' does not work on matrices
## (only on dataframes)
X = rand(5, 2)
X = allowmissing(X)
X[1, 1] = missing
X[2:3, 2] .= missing
X

x = allowmissing(rand(10))
x[1:2] .= missing
x 
a = x .> .5
a[ismissing.(a)] .= false
b = .!ismissing.(x)
u = findall(a .&& b)
x[u]

#### Dataframes

## completecases, dropmissing

df = DataFrame(i = 1:5, x = [missing, 4, missing, 2, 1], y = [missing, missing, "c", "d", "e"])
completecases(df)
dropmissing(df)    
dropmissing!(df)
df    

## https://www.roelpeters.be/replacing-nan-missing-in-julia-dataframes/  
using BenchmarkTools
df = DataFrame(
    a = [0, 1, 2, missing, 4, 5, NaN, 7, missing, 9], 
    b = ["a", "b", "c", "d", missing, "f", NaN, "g", "h", "i"])
zdf = copy(df)
@time zdf[ismissing.(zdf.a), :a] .= 0           # Median time: 38.7 µs
zdf = copy(df)
@time collect(Missings.replace(zdf[!, :a], 0)) # 32.6 µs
zdf = copy(df)
@time zdf.a = coalesce.(zdf.a, 0)               # Median time: 5.4 µs
zdf = copy(df)
@time zdf.a = replace(zdf.a, missing => 0)      # Median time: 0.2 µs
zdf = copy(df)
@time replace!(zdf.a, missing => 0)            # Median time: 0.08 µs (!)

## REPLACE MISSING VALUES IN ALL COLUMS
## The following example uses the fastest solution (see above) in a for loop. 
## I wish there was some more elegant solution that can do it in one line of code, 
## but I haven’t been able to find one. Unsurprisingly, list comprehension 
## and map() return two vectors, instead of a DataFrame.

x1 = [missing ; rand(5) ; missing]
x2 = rand(7)
df = DataFrame(hcat(x1, x2), :auto)
for col in eachcol(df)
    replace!(col, missing => 0)
end
df

## Replace NaN in a DataFrame
## Using the R-ish solution and the isnan function, we can easily do it as follows:

df = DataFrame(a = [0, 1, 2, missing, 4, 5, NaN, 7, missing, 9], 
    b = ["a", "b", "c", "d", missing, "f", NaN, "g", "h", "i"])
zdf = copy(df)
replace!(zdf.a, missing => 0)
zdf[isnan.(zdf.a), :a] .= -1000
zdf

## However, there is a drawback. The isnan function only accepts a Float-type column, 
## and not a String column, nor missing. If you pass it a string column, it will generate an error:
## MethodError: no method matching isnan(::String)
## That’s why I prefer the following solution. In the next chunk of code I give the 
## solution for both a specific column and for all columns.

zdf = copy(df)
replace!(zdf.a, NaN => -1000)
#replace!(zdf.a, NaN => -1000)
zdf

df = DataFrame(:A => [5, 10, NaN, NaN, 25], :B => ["A", "B", "A", missing, missing])
dropmissing(df)
df
dropmissing!(df)
df

df = DataFrame(:A => [5, missing, NaN, NaN, 25], :B => ["A", "B", "A", missing, missing])
filter(:A => x -> !(ismissing(x) || isnothing(x) || isnan(x)), df)
filter(:A => x -> !any(f -> f(x), (ismissing, isnothing, isnan)), df)

df = DataFrame(y1 = [5.; 10; NaN; NaN; 25], y2 = [0; 12; .7; 0; 2])
for col in eachcol(df)
    replace!(col, NaN => 0)
end
df
allowmissing!(df)
for col in eachcol(df)
    replace!(col, 0 => missing)
end
df 

################# NaN 

x = [rand(5) ; NaN]
replace(x, NaN => -100)
y = replace(x, NaN => missing)  # The inplace version does not accept to create missing 
                                # in a Float64 object



