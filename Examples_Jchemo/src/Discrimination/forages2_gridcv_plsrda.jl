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

plotsp(X, wl_num).f

summ(Y)
freqtable(y, Y.test)

s = Bool.(Y.test)
Xtrain = rmrow(X, s)
ytrain = rmrow(y, s)
Xtest = X[s, :]
ytest = y[s]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)

K = 3 ; segm = segmkf(ntrain, K; rep = 10)         # K-fold CV   
#m = 100 ; segm = segmts(ntrain, m; rep = 30)      # Test-set CV

nlv = 0:50
res = gridcvlv(Xtrain, ytrain; segm = segm, 
    score = err, fun = plsrda, nlv = nlv, verbose = false).res
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
plotgrid(res.nlv, res.y1; step = 5,
    xlabel = "Nb. LVs", ylabel = "ERR").f

fm = plsrda(Xtrain, ytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
err(pred, ytest)

cf = confusion(pred, ytest) ;
cf.cnt
cf.pct
plotconf(cf).f

## PLSLDA
nlv = 1:50  ## !!: Does not start from nlv=0 (since LDA on scores)
res = gridcvlv(Xtrain, ytrain; segm = segm, 
    score = err, fun = plslda, nlv = nlv, verbose = false).res
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
plotgrid(res.nlv, res.y1; step = 5,
    xlabel = "Nb. LVs", ylabel = "ERR").f
fm = plslda(Xtrain, ytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
err(pred, ytest)

