
using Jchemo, JchemoData
using JLD2, CairoMakie, FreqTables


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/forages2.jld2") 
@load db dat
@names dat


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


K = 3 ; segm = segmkf(ntrain, K; rep = 10)         # K-fold CV   
#m = 100 ; segm = segmts(ntrain, m; rep = 30)      # Test-set CV


nlv = 0:40
model = plsrda()
res = gridcv(model, Xtrain, ytrain; segm, score = errp, nlv, verbose = false).res


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


plotgrid(res.nlv, res.y1; step = 5, xlabel = "Nb. LVs", ylabel = "ERR").f


model = plsrda(nlv = res.nlv[u])
fit!(model, Xtrain, ytrain)
pred = predict(model, Xtest).pred


errp(pred, ytest)


cf = conf(pred, ytest) ;
cf.cnt


cf.pct


plotconf(cf).f


nlv = 1:40  ## !!: Does not start from nlv = 0 (since the method runs an Lda on Pls scores)
model = plslda()
res = gridcv(model, Xtrain, ytrain; segm, score = errp, nlv, verbose = false).res


plotgrid(res.nlv, res.y1; step = 5, xlabel = "Nb. LVs", ylabel = "Err-CV").f


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


model = plslda(nlv = res.nlv[u])
fit!(model, Xtrain, ytrain)
pred = predict(model, Xtest).pred
errp(pred, ytest)

