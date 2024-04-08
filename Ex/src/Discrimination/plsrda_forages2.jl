
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
mod = plsrda(; nlv) 
#mod = plslda(; nlv) 
#mod = plsqda(; nlv) 
#mod = plsqda(; nlv, prior = :prop)


#mod = rrda(lb = 1e-5)


fit!(mod, Xtrain, ytrain)
pnames(mod) 
pnames(mod.fm)


res = predict(mod, Xtest) ;
pnames(res)


@head pred = res.pred


@head res.posterior   # prediction of the dummy table


errp(pred, ytest)


freqtable(ytest, vec(pred))


cf = conf(pred, ytest) ;
pnames(cf)


cf.cnt


cf.pct


cf.diagpct


cf.accpct


plotconf(cf).f

