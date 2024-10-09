
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
nval = Int.(round(pct * ntrain))
s = samprand(ntrain, nval)
Xcal = Xtrain[s.train, :]
ycal = ytrain[s.train]
Xval = Xtrain[s.test, :]
yval = ytrain[s.test]
ncal = ntrain - nval 
(ntot = ntot, ntrain, ntest, ncal, nval)


nlv = 0:50
gamma = 10.0.^(-5:3)
pars = mpar(gamma = gamma)


length(pars[1])


model = kplsrda()
res = gridscore(model, Xcal, ycal, Xval, yval; score = errp, pars, nlv)


plotgrid(res.nlv, res.y1, res.gamma; step = 5, xlabel = "Nb. LVs", ylabel = "ERR").f


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


model = kplsrda(nlv = res.nlv[u], gamma = res.gamma[u])
fit!(model, Xtrain, ytrain)
pred = predict(model, Xtest).pred


errp(pred, ytest)


cf = conf(pred, ytest) ;
pnames(cf)


cf.cnt


cf.pct


cf.diagpct


cf.accpct


plotconf(cf).f

