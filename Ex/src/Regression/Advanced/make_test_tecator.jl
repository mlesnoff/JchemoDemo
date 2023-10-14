using JLD2, CairoMakie, StatsBase
using Jchemo, JchemoData

path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/tecator.jld2") 
@load db dat
pnames(dat)

X = dat.X
Y = dat.Y 
typ = Y.typ
wl = names(X)
wl_num = parse.(Float64, wl) 
ntot, p = size(X)
namy = names(Y)[1:3]

## Assume a dataset {X (n x p), Y (n x q)}, possibly with missing 
## data in Y, and that the objective is to build 
## a splitting Tot = Train + Test, by random sampling.
## Due to the possible missing data in Y,
## the sampling has to be done independently for each 
## variable y (= Y-column) to removing, for each given variable,
## the missing values.

## This script presents 
## 1) and approach "by-hand" for a given variable y,
## 2) a more performant approach with function 'mtest'
## that build splitting for all the y-variables 
## and that can be re-used in other working sesssions.  
## Note that the size of {Train, Test} can differ 
## between variables y if Y contains missing data.

## NB.: Data tecator do not contain missing data.

## 1) Approach "by-hand" 
j = 2    # variable y
y = Y[:, j]
## Select observations without missing data for y
## ==> zX, zy
s = findall(ismissing.(y) .== 0)
zX = X[s, :]
zy = y[s]
## Build a test set representing 
## a proportion pct of data zX, zy
## ==> This gives {Xtrain, ytrain, Xtest, ytest} 
## for variable y
ntot = nro(zX)  # different from ntot if there are missing data
pct = 1 / 3
ntest = round(pct * ntot) # or: ntest = 80
ntrain = n - ntest
res = samprand(n, ntrain)
strain = res.train
stest = res.test
Xtrain = zX[strain, :]
ytrain = zy[strain]
Xtest = zX[stest, :]
ytest = zy[stest]
(ntot = ntot, ntrain, ntest)

## 2) Function 'mtest' 
## This is a more efficient alternative.
## Function 'mtest' does the split automatically 
## for each variable y
ntest = 60
ids = mtest(Y[:, namy]; ntest = ntest)
pnames(ids)
ids.test
ids.train
ids.nam 
## Example
j = 2 # variable y
ids.train[j]
ids.test[j]
ids.nam[j]

## The output of 'mtest' can be saved and 
## re-used in next sessions
path_out = "D:/Mes Donnees/Tmp/"
db = joinpath(path_out, "ids_tecator.jld2") 
#jldsave(db; ids) 
  
## Re-use the ids: 
#@load db ids
