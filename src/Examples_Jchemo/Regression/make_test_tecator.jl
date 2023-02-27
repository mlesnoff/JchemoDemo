using JLD2, CairoMakie
using Jchemo, JchemoData
using Loess, StatsBase

mypath = dirname(dirname(pathof(JchemoData)))
db = joinpath(mypath, "data", "tecator.jld2") 
@load db dat
pnames(dat)

X = dat.X
Y = dat.Y 
wl = names(X)
wl_num = parse.(Float64, wl) 
ntot, p = size(X)
typ = Y.typ
namy = names(Y)[1:3]

plotsp(X, wl_num,
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 
plotsp(Xp, wl_num,
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

## How to make a plitting: Tot = Train + Test
## Here this is done by random sampling.
## If there are missing data in Y,
## (this is not the case of the specific example "tecator")
## the sampling must be done for each y-variable
## (i.e. a different splitting has to be done 
## between the variables).
## Example of the second y-variable 
j = 2
y = Y[:, j]
## Select observation without missing data for y
## ==> zX, zy
s = findall(ismissing.(y) .== 0)
zX = X[s, :]
zy = y[s]
## Build a test set representing 30% of 
## the data zX, zy
n = nro(zX)
ntest = Int64(round(.30 * n)) # Or: ntest = 80
s = sample(1:n, ntest; replace = false)
Xtrain = rmrow(zX, s)
ytrain = rmrow(zy, s)
Xtest = zX[s, :]
ytest = zy[s, :]
## ==> This gives Xtrain, ytrain, Xtest, ytest
## for y

## !!!! More efficient alternative:
## The process above can be done automatically 
## with function "mtest" 
## (accounts for missing data in Y).
## Below the splitting is replicated "rep" times
ids = mtest(Y[:, namy]; test = .30, 
    rep = 10) ;
pnames(ids)
ids.test
ids.train
ids.nam 
## The sizes of resulting Train and Test can differ 
## between variables if Y contains missing data.
## i : variable in Y
## j : replication
i = 1
ids.train[i]
ids.test[i]

## If the objective is to get a consistent 
## value ntest = 80
ids = mtest(Y[:, 1:3]; test = 80, 
    rep = 10) ;

## Then the output of mtest can be saved and 
## re-used in next sessions
root = "D:/Mes Donnees/Tmp/"
db = string(root, "ids_tecator.jld2") 
#@save db ids   

## Re-use 
#@load db ids
