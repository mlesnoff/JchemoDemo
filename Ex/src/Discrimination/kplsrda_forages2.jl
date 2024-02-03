
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


nlv = 15
gamma = .001
mod = kplsrda(; nlv, gamma, scal = true) 
fit!(mod, Xtrain, ytrain)
pnames(mod) 
pnames(mod.fm)


typeof(mod.fm.fm)


res = predict(mod, Xtest)
pnames(res)


@head pred = res.pred


@head res.posterior


errp(pred, ytest)


cf = confusion(pred, ytest) ;
cf.cnt


cf.pct


plotconf(cf).f

