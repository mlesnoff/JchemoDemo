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
namy = names(Y)[1:3]
ntot, p = size(X)
y = Y.fat
typ = Y.typ

plotsp(X, wl_num,
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 
plotsp(Xp, wl_num,
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

#### Train vs. Test sets
#### by sampling
#### Column j of Y:
j = 2
## If there are missing data in Y 
## (not the case of tecator dataset)
s = findall(ismissing.(Y[:, j]) .== 0)
zX = X[s, :]
zy = Y[s, j]
## End 
n = nro(zX)
## Example of test = 30% of the data
ntest = Int64(round(.30 * n))
## Or: ntest = 80
s = sample(1:n, ntest; replace = false)
Xtrain = rmrow(zX, s)
ytrain = rmrow(zy, s)
Xtest = zX[s, :]
ytest = zy[s, :]
## End

#### The process above can be done automatically 
#### with function "mtest" 
#### (accounts for missing data in Y)
res = mtest(Y[:, 1:3]; test = .30, 
    rep = 10) ;
pnames(res)
res.idtest
res.idtrain
res.nam 
## The size of the train and the test can differ between
## variables if Y contains missing data.
## i : variable in Y
## j : replication
i = 1 ; j = 1
res.idtrain[i][j]
res.idtest[i][j]

## If the objective is to get ntest = 80
res = mtest(Y[:, 1:3]; test = 80, 
    rep = 10) ;

#### Then the output of mtest can be saved and 
#### re-used
root = "D:/Mes Donnees/Tmp/"
db = string(root, "idtest_tecator.jld2") 
#@save db res   

#### Re-use 
## @load db res
## See script "gridcv_plsr_tecator_double.jl"



