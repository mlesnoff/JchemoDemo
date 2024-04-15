
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


K = 3
segm = segmkf(ntrain, K; rep = 10)


pars = mpar(a_kde = [.5, 1, 1.5])


nlv = 1:40
mod = model(plskdeda)
rescv = gridcv(mod, Xtrain, ytrain; segm, score = errp, pars, nlv) ; 
res = rescv.res


group = string.("a_kde = ", res.a_kde)
plotgrid(res.nlv, res.y1, group; step = 2, xlabel = "Nb. LVs", ylabel = "Err-CV").f


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


mod = model(plskdeda(nlv = res.nlv[u], a_kde = res.a_kde[u])
fit!(mod, Xtrain, ytrain)
pred = predict(mod, Xtest).pred
errp(pred, ytest)


cf = conf(pred, ytest) ;
pnames(cf)


cf.cnt


cf.pct


cf.diagpct


cf.accpct


plotconf(cf).f

