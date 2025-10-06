
using Jchemo, JchemoData
using JLD2, CairoMakie
using FreqTables


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/forages2.jld2") 
@load db dat
@names dat


X = dat.X 
@head X


Y = dat.Y
@head Y


y = Y.typ   # response variable (class membership)
test = Y.test
tab(y)


freqtable(y, test)


wlst = names(X)
wl = parse.(Int, wlst)
#plotsp(X, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


s = Bool.(test)
Xtrain = rmrow(X, s)
ytrain = rmrow(y, s)
Xtest = X[s, :]
ytest = y[s]
ntot = nro(X)
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)


tab(ytrain)


tab(ytest)


K = 3     # nb. folds (segments)
rep = 1   # nb. replications
segm = segmkf(ntrain, K; rep = rep)


nlvdis = [15; 25]; metric = [:mah]
h = [1; 2; 4; 6; Inf]; k = [30; 50; 100]  
nlv = 0:15
pars = mpar(nlvdis = nlvdis, metric = metric, h = h, k = k) 
length(pars[1])


model = lwplsrda()
res = gridcv(model, Xtrain, ytrain; segm, score = merrp, pars, nlv).res


group = string.("nvldis=", res.nlvdis, " h=", res.h, " k=", res.k)
plotgrid(res.nlv, res.y1, group; step = 2, xlabel = "Nb. LVs", ylabel = "ERRP-CV", leg_title = "Continuum").f


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


model = lwplsrda(nlvdis = res.nlvdis[u], metric = res.metric[u], h = res.h[u], k = res.k[u], nlv = res.nlv[u])
fit!(model, Xtrain, ytrain)
pred = predict(model, Xtest).pred


errp(pred, ytest)


merrp(pred, ytest)


cf = conf(pred, ytest)
@names cf


cf.cnt


cf.pct

