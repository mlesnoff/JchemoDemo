using JLD2, CairoMakie, FreqTables 
using Jchemo, JchemoData

mypath = dirname(dirname(pathof(JchemoData)))
db = joinpath(mypath, "data", "forages2.jld2") 
@load db dat
pnames(dat)
  
X = dat.X 
Y = dat.Y
y = Y.typ
wl = names(X)
wl_num = parse.(Float64, wl)
ntot = nro(X)

tab(y)
freqtable(y, Y.test)

plotsp(X, wl_num).f

s = Bool.(Y.test)
Xtrain = rmrow(X, s)
ytrain = rmrow(y, s)
Xtest = X[s, :]
ytest = y[s]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)

######## End Data

fm = plsrda(Xtrain, ytrain; nlv = 15) ;
#fm = plslda(Xtrain, ytrain; nlv = 15) ;
#fm = plsqda(Xtrain, ytrain; nlv = 15) ;
#fm = plsqda(Xtrain, ytrain; nlv = 15, prior = "prop") ;
#fm = rrda(Xtrain, ytrain; lb = 1e-5) ;
pnames(fm)
pnames(fm.fm)

res = Jchemo.predict(fm, Xtest)
pnames(res)
pred = res.pred
res.posterior

err(pred, ytest)
freqtable(vec(pred), ytest)

## Averaging
nlv = "0:20"
fm = plsrdaavg(Xtrain, ytrain; nlv = nlv) ;
pred = Jchemo.predict(fm, Xtest).pred
err(pred, ytest)


