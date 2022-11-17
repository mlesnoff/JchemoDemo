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

######## End Data

m = 100 ; segm = segmts(ntrain, m; rep = 6)     # Test-set CV
#K = 3 ; segm = segmkf(ntrain, K; rep = 2)      # K-fold CV  

nlvdis = [25] ; metric = ["mahal"]
h = [1; 2; 5] ; k = [100; 250; 500]
pars = mpar(nlvdis = nlvdis, metric = metric, h = h, k = k)
length(pars[1])
nlv = 0:15
res = gridcvlv(Xtrain, ytrain; segm = segm, score = err, 
    fun = lwplsrda, nlv = nlv, pars = pars, 
    verbose = true).res
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]

group = string.(res.metric, res.nlvdis, " h=", res.h, " k=", res.k)
plotgrid(res.nlv, res.y1, group; step = 2,
    xlabel = "Nb. LVs", ylabel = "ERR").f

fm = lwplsrda(Xtrain, ytrain; nlvdis = res.nlvdis[u], 
    metric = res.metric[u], h = res.h[u], k = res.k[u], 
    nlv = res.nlv[u], verbose = true) ;
pred = Jchemo.predict(fm, Xtest).pred
err(pred, ytest)
freqtable(vec(pred), ytest)

## Averaging
nlv = "0:20"
fm = lwplsrda_avg(Xtrain, ytrain; nlvdis = 25, 
    metric = "mahal", h = 1, k = 1000, 
    nlv = nlv, verbose = true) ;
pred = Jchemo.predict(fm, Xtest).pred
err(pred, ytest)

