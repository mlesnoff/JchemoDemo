using DataFrames, Statistics, Jchemo

## https://dataframes.juliadata.org/stable/man/getting_started/
## https://towardsdatascience.com/how-to-manipulate-data-with-dataframes-jl-179d236f8601
## https://www.juliabloggers.com/how-is-used-in-dataframes-jl/

x = [2.6 ; 1.3 ; 3] 
y = [1 ; 5 ; 0]
z = ["blue" ; "yellow" ; "orange"]
df = DataFrame(height = x, age = y, col = z)
describe(df)
df[:, :age]
df[:, "age"]
nam = [:age, :height] 
#nam = ["age" ; "height"] 
df[:, nam]
df[1:2, :]
Matrix(df)

df = hcat(x, y, z)
df = DataFrame(df, :auto)
rename!(df, :x1 => :age)
nam = [:age ; :height ; :col] 
rename!(df, nam)

df = hcat(x, y, z)
#df = rand(5, 3)
nam = [:age ; :height ; :col] 
df = DataFrame(df, nam)

df = DataFrame(a = 1:3)
insertcols!(df, 1, :b => 'a':'c')
insertcols!(df, 2, :c => 2:4, :d => 3:5)
insertcols!(df, 4, :e => 2:4, :e => 3:5, makeunique = true)

df = DataFrame(a = 1:3)
df.b = 'a':'c'
df

X = rand(10, 5)
df = DataFrame(X, :auto)
describe(df)

##################### AGGREGATE

# https://stackoverflow.com/questions/64226866/groupby-with-sum-on-julia-dataframe
df = DataFrame(:A => ["x1", "x2", "x1", "x2", "x1"], 
               :B => ["a", "a", "b", "a", "b"],
               :C => [12, 7, 5, 4, 9],
               :D => ["green", "blue", "red", "blue", "yellow"])
gdf = groupby(df, [:A ; :B])
combine(gdf, :C => sum)

aggstat(df; group_nam = [:A ; :B], var_nam = :C, fun = sum)

# https://discourse.julialang.org/t/aggregate-deprecated-use-combine/42809/4
zdf = DataFrame(group = rand(["A", "B", "C"], 15), var1 = randn(15), var2 = rand(15))
combine(groupby(zdf, :group), [:var1 ; :var2] .=> [mean, std])
combine(groupby(zdf, :group), ([:var1 ; :var2] .=> f for f in (mean, std))...)
# which is kind of shorthand for:
combine(groupby(zdf, :group), [:var1 ; :var2] .=> mean, [:var1 ; :var2] .=> std)

## Tabulation

df
gdf = groupby(df, [:A ; :B])
combine(gdf, nrow)
# Or: using FreqTables

#################### CONCATENATION

df1 = DataFrame(:B => ["x1", "x2", "x1", "x2", "x1"], 
               :A => ["a", "a", "b", "a", "b"],
               :D => [12, 7, 5, 4, 9],
               :C => ["green", "blue", "red", "blue", "yellow"])
df2 = DataFrame(C = ["xxx" ; "yy"], A = 'u':'v')

https://dataframes.juliadata.org/stable/lib/functions/#Base.vcat
# `cols` keyword argument must be :orderequal, :setequal, :intersect, :union, 
# or a vector of column names
vcat(df1, df2; cols = :union)
vcat(df1, df2; cols = :intersect)
vcat(df1, df2; cols = [:C ; :A])
vcat(df1, df2; cols = ["C" ; "A"])

vcat(df1, df2; cols = :intersect)
vcat(df2, df1; cols = :intersect)

z = copy(df1) 
append!(z, df2; cols = :union)

df = DataFrame(A = 1:3, B = 1:3)
push!(df, (true, false))
push!(df, df[1, :])
push!(df, (C = "something", A = true, B = false), cols = :intersect)
push!(df, Dict(:A => 1.0, :C => 1.0), cols = :union)
push!(df, NamedTuple(), cols = :subset)

#################### MISSING DATA

https://stackoverflow.com/questions/34611109/julia-dataframe-replacing-missing-values

df = DataFrame(x = [1. ; missing ; 3]) 
df.x[ismissing.(df.x)] .= 0.
df

df = DataFrame(x = [1. ; missing ; 3]) 
replace!(df.x, missing => 0.) 
df

df = DataFrame(x = [1. ; missing ; 3]) 
df.x = replace(df.x, missing => 0.) ;
df 

df = DataFrame(x = [1. ; missing ; 3]) 
df.x = coalesce.(df.x, 0.) ;
df

X = hcat([1. ; missing ; 3], [missing ; missing ; 2.1])
replace!(X, missing => 0.)
df = DataFrame(Float64.(X), :auto) ;
df

df = DataFrame(x = [1. ; 0 ; 3]) 
allowmissing!(df)
replace!(df.x, 0. => missing)
df

df = DataFrame(x = [1. ; 0 ; 3], y = [0 ; 0 ; 2.1])
allowmissing!(df)
[for col in eachcol(df) ; replace!(col, 0. => missing) ; end]
df

#################### ORDERING

# https://dataframes.juliadata.org/stable/man/sorting/

x = [2.6 ; 1.3 ; 2.6 ; 3] 
y = [1 ; 5 ; 0 ; .5]
z = ["blue" ; "green" ; "yellow" ; "orange"]
df = DataFrame(height = x, age = y, col = z)

zdf = copy(df)
sort!(zdf)
sort!(zdf; rev = true)

sort!(zdf, [:age ; :height])

########### ALTERNATIVES

# https://github.com/davidavdav/NamedArrays.jl
# https://github.com/JuliaData/Tables.jl
# https://github.com/JuliaData

