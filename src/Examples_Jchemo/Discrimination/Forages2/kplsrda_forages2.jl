using JLD2, CairoMakie, FreqTables 
using Jchemo, JchemoData

path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/forages2.jld2") 
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

gamma = .001
fm = kplsrda(Xtrain, ytrain; nlv = 15, 
    gamma = gamma, scal = true) ;
pnames(fm)
pnames(fm.fm)
typeof(fm.fm)

res = Jchemo.predict(fm, Xtest)
pnames(res)
pred = res.pred
res.posterior

err(pred, ytest)
res = confusion(pred, ytest) ;
res.cnt
res.pct
plotconf(res).f

