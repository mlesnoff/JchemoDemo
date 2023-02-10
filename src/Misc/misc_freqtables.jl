using StatsBase, DataFrames, FreqTables

x = rand(1:5, 100)
res = countmap(x)
propertynames(res)
keys(res)
res.keys
res.vals
values(res)
sort(res)

counts(x)
lev = sort(unique(x))
hcat(lev, counts(x))
counts(x, x)
proportions(x)
proportions(x, x)

## freqtable

n = 100
x = rand(1:5, n)
y = rand(1:3, n)
freqtable(x)
freqtable(x, y)

res = freqtable(x, y)
prop(res, margins = 2)

