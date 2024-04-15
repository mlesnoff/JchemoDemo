
using Jchemo, JchemoData
using JLD2, CairoMakie
using FreqTables


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/challenge2018.jld2") 
@load db dat
pnames(dat)


X = dat.X 
Y = dat.Y
ntot, p = size(X)


@head X
@head Y


summ(Y)


y = Y.conc
typ = Y.typ
label = Y.label 
test = Y.test
tab(test)


wlst = names(X)
wl = parse.(Float64, wlst)


freqtable(string.(typ, "-", Y.label))


freqtable(typ, test)


plotsp(X, wl; nsamp = 30).f


mod1 = model(snv(centr = true, scal = true)
mod2 = model(savgol(npoint = 21, deriv = 2, degree = 3)
mod = pip(mod1, mod2)
fit!(mod, X)
Xp = transf(mod, X)


s = Bool.(test)
Xtrain = rmrow(Xp, s)
ytrain = rmrow(y, s)
Xtest = Xp[s, :]
ytest = y[s]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)


nval = 300
## Or:
#pct = .20
#nval = Int64(round(pct * ntrain))


s = samprand(ntrain, nval)


#s = sampks(Xtrain, nval; metric = :eucl)


#s = sampdp(Xtrain, nval)


#s = sampsys(ytrain, nval)


Xcal = Xtrain[s.train, :]
ycal = ytrain[s.train]
Xval = Xtrain[s.test, :]
yval = ytrain[s.test]
ncal = ntrain - nval 
(ntot = ntot, ntrain, ntest, ncal, nval)


mod = model(plskern)
nlv = 0:50
res = gridscore(mod, Xcal, ycal, Xval, yval; score = rmsep, 
    nlv)


plotgrid(res.nlv, res.y1; step = 5, xlabel = "Nb. LVs", ylabel = "RMSEP").f


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


mod = model(plskern(nlv = res.nlv[u])
fit!(mod, Xtrain, ytrain) 
pred = predict(mod, Xtest).pred


rmsep(pred, ytest)


plotxy(pred, ytest; color = (:red, .5), bisect = true, xlabel = "Prediction", 
    ylabel = "Observed (Test)").f


res_sel = selwold(res.nlv, res.y1; smooth = true, alpha = .05, graph = true) ;
pnames(res)


res_sel.f       # plots


res_sel.opt     # nb. LVs correponding to the minimal error rate


res_sel.sel     # nb. LVs selected with the Wold's criterion


mod = model(plskern(nlv = res_sel.sel)
fit!(mod, Xtrain, ytrain) 
pred = predict(mod, Xtest).pred
rmsep(pred, ytest)

