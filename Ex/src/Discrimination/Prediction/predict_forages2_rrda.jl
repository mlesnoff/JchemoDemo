
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


model = rrda(; lb = 1e-5)
fit!(model, Xtrain, ytrain)
@names model


fitm = model.fitm
@names fitm


typeof(fitm.fitm)


@names fitm.fitm


res = predict(model, Xtest)
@names res
@head pred = res.pred
@head res.posterior   # predicted posterior probabilities


@head predict(model, Xtest).pred


predict(model, Xtest; lb = [.1, .01]).pred


errp(pred, ytest)


merrp(pred, ytest)


cf = conf(pred, ytest)
@names cf


cf.cnt


cf.pct


plotconf(cf).f

