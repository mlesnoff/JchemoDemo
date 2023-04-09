using JLD2, CairoMakie, StatsBase
using Jchemo, JchemoData

path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data", "tecator.jld2") 
@load db dat
pnames(dat)

X = dat.X
Y = dat.Y 
wl = names(X)
wl_num = parse.(Float64, wl) 
ntot, p = size(X)
typ = Y.typ
namy = names(Y)[1:3]

## Assume that the objective is to build 
## a splitting Tot = Train + Test, by random sampling.
## If there are missing data in Y,
## the sampling must be done taking care of each y-variable
## (y-column), to avoid situations where Train and Test 
## will contain missing values.

## This script presents 
## 1) and approach "by-hand" for a given y-variable,
## 2) a more performant approach with function 'mtest'
## that build splitting for all the y-variables 
## and that can be re-used in other workin sesssions.  
## Note that the size of {Train, Test} can differ 
## between y-variables if Y contains missing data.

## NB.: Data tecator do not contain missing data.

## 1) Approach "by-hand" 
j = 2    # y-variable
y = Y[:, j]
## Select observations without missing data for y
## ==> zX, zy
s = findall(ismissing.(y) .== 0)
zX = X[s, :]
zy = y[s]
## Build a test set representing 
## a proportion pct of data zX, zy
n = nro(zX)  # different from ntot if there are missing data
pct = 1 / 3
ntest = Int64(round(pct * n)) # or: ntest = 80
s = sample(1:n, ntest; replace = false)
Xtrain = rmrow(zX, s)
ytrain = rmrow(zy, s)
Xtest = zX[s, :]
ytest = zy[s, :]
## ==> This gives Xtrain, ytrain, 
## Xtest, ytest for variable y

## 2) Function 'mtest' 
## This is a more efficient alternative.
## Function 'mtest' does automatically for each 
## y-variable what is described in point 1),
## and allows replications.
pct = 1 / 3
ids = mtest(Y[:, namy]; 
    test = pct, # proportion of Test
    rep = 10    # nb. replications of the spliiting for each y-variable
    ) ;
pnames(ids)
## IDs of the observations
ids.test
ids.train
ids.nam 
## Example
j = 1 # y-variable
k = 2 # replication
ids.train[j]
ids.test[j]
ids.train[j][k]
ids.test[j][k]

## If the objective is to get a consistent 
## value ntest = 80
ntest = 60  # Must be Int64
ids = mtest(Y[:, 1:3]; 
    test = ntest, rep = 10) ;
ids.test[j][k]

## The output of 'mtest' can be saved and 
## re-used in next sessions
root_out = "D:/Mes Donnees/Tmp/"
db = string(root, "ids_tecator.jld2") 
#@save db ids   
## Re-use 
#@load db ids
