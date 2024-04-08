
using Jchemo, JchemoData
using JLD2, CairoMakie, FreqTables


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/forages2.jld2") 
@load db dat
pnames(dat)


X = dat.X 
Y = dat.Y
ntot = nro(X)


@head X
@head Y


y = Y.typ
tab(y)


freqtable(y, Y.test)


wlst = names(X)
wl = parse.(Float64, wlst)


plotsp(X, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


s = Bool.(Y.test)
Xtrain = rmrow(X, s)
ytrain = rmrow(y, s)
Xtest = X[s, :]
ytest = y[s]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)


pct = .30
nval = Int64.(round(pct * ntrain))
s = samprand(ntrain, nval)
Xcal = Xtrain[s.train, :]
ycal = ytrain[s.train]
Xval = Xtrain[s.test, :]
yval = ytrain[s.test]
ncal = ntrain - nval 
(ntot = ntot, ntrain, ntest, ncal, nval)


nlvdis = [15; 25] ; metric = [:mah]
h = [1; 2; 5] ; k = [100; 200; 300]
nlv = 0:15
pars = mpar(nlvdis = nlvdis, metric = metric, h = h, k = k)


length(pars[1])


mod = lwplsrda()
res = gridscore(mod, Xcal, ycal, Xval, yval; score = errp, nlv, 
    pars, verbose = false)


group = string.("metric=", res.metric, res.nlvdis, " h=", res.h, " k=", res.k)
plotgrid(res.nlv, res.y1, group; step = 2, xlabel = "Nb. LVs", 
    ylabel = "ERR").f


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


mod = lwplsrda(nlvdis = res.nlvdis[u], metric = res.metric[u], 
    h = res.h[u], k = res.k[u], nlv = res.nlv[u], verbose = false) ;
fit!(mod, Xtrain, ytrain)
pred = predict(mod, Xtest).pred


errp(pred, ytest)


cf = conf(pred, ytest) ;
pnames(cf)


cf.cnt


cf.pct


cf.accuracy


plotconf(cf).f

