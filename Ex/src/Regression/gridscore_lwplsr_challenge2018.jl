
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
s = samprand(ntrain, nval)
Xcal = Xtrain[s.train, :]
ycal = ytrain[s.train]
Xval = Xtrain[s.test, :]
yval = ytrain[s.test]
ncal = ntrain - nval 
(ntot = ntot, ntrain, ntest, ncal, nval)


nlvdis = [15; 25] ; metric = [:mah] 
h = [1; 2; 4; 6; Inf]
k = [150; 200; 350; 500; 1000]  
nlv = 0:20 
pars = mpar(nlvdis = nlvdis, metric = metric, h = h, k = k)


length(pars[1])


mod = model(lwplsr)
res = gridscore(mod, Xcal, ycal, Xval, yval; score = rmsep, 
    pars, nlv, verbose = false)


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


group = string.("nlvdis=", res.nlvdis, ",h=", res.h, ",k=", res.k) 
plotgrid(res.nlv, res.y1, group; step = 2, xlabel ="Nb. LVs", ylabel = "RMSEP").f


mod = model(lwplsr(nlvdis = res.nlvdis[u], metric = res.metric[u], 
    h = res.h[u], k = res.k[u], nlv = res.nlv[u])
fit!(mod, Xtrain, ytrain)
pred = predict(mod, Xtest).pred 
rmsep(pred, ytest)


plotxy(pred, ytest; color = (:red, .5), bisect = true, xlabel = "Prediction", 
    ylabel = "Observed (Test)").f

