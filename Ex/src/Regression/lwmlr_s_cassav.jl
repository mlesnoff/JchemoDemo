
using Jchemo, JchemoData
using JLD2, CairoMakie


using JchemoData, JLD2, CairoMakie
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/cassav.jld2")
@load db dat
pnames(dat)


X = dat.X
Y = dat.Y
ntot = nro(X)


@head X
@head Y


y = dat.Y.tbc
year = dat.Y.year


tab(year)


wlst = names(X)
wl = parse.(Float64, wlst)


plotsp(X, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


mod1 = model(snv; centr = true, scal = true)
mod2 = model(savgol; npoint = 11, deriv = 2, degree = 3)
mod = pip(mod1, mod2)
fit!(mod, X)
Xp = transf(mod, X)


plotsp(Xp, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


s = year .<= 2012
Xtrain = X[s, :]
ytrain = y[s]
Xtest = rmrow(X, s)
ytest = rmrow(y, s)
ntrain = nro(Xtrain)
ntest = nro(Xtest)
ntot = ntrain + ntest
(ntot = ntot, ntrain, ntest)


plotsp(X, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


nval = Int64(round(.30 * ntrain))
s = sampsys(ytrain, nval)
Xcal = Xtrain[s.train, :]
ycal = ytrain[s.train]
Xval = Xtrain[s.test, :]
yval = ytrain[s.test, :]
ncal = ntrain - nval
(ntot = ntot, ntrain, ntest, ncal, nval)


mod = model(plskern)
nlv = 0:40
res = gridscore(mod, Xcal, ycal, Xval, yval; score = rmsep, nlv)


plotgrid(res.nlv, res.y1; step = 5, xlabel = "Nb. LVs", ylabel = "RMSEP").f


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


mod = model(plskern; nlv = res.nlv[u]) 
fit!(mod, Xtrain, ytrain)
pred = predict(mod, Xtest).pred 
rmsep(pred, ytest)
mse(pred, ytest)


plotxy(pred, ytest; color = (:red, .5), bisect = true, xlabel = "Prediction", 
  ylabel = "Observed (Test)").f


nlv = 15
metric = [:eucl, :mah]
h = [1; 2; 3.5; 6] ; k = [50; 100; 150; 200]  
pars = mpar(metric = metric, h = h, k = k) 
length(pars[1])


mod1 = model(pcasvd)
mod2 = model(lwmlr)
mod = pip(mod1, mod2)
res = gridscore(mod, Xcal, ycal, Xval, yval; score = rmsep, pars, verbose = false)


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


mod1 = model(pcasvd; nlv)
mod2 = model(lwmlr; metric = res.metric[u], h = res.h[u], k = res.k[u])
mod = pip(mod1, mod2)
fit!(mod, Xtrain, ytrain)
pred = predict(mod, Xtest).pred
@show rmsep(pred, ytest)
mse(pred, ytest)


plotxy(pred, ytest; color = (:red, .5), bisect = true, xlabel = "Prediction", 
    ylabel = "Observed (Test)").f


nlv = 15
metric = [:eucl, :mah]
h = [1; 2; 3.5; 6] ; k = [50; 100; 150; 200]  
pars = mpar(metric = metric, h = h, k = k) 
length(pars[1])


mod1 = model(plskern)
mod2 = model(lwmlr)
mod = pip(mod1, mod2)
res = gridscore(mod, Xcal, ycal, Xval, yval; score = rmsep, pars, verbose = false)


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


mod1 = model(plskern; nlv)
mod2 = model(lwmlr; metric = res.metric[u], h = res.h[u], k = res.k[u])
mod = pip(mod1, mod2)
fit!(mod, Xtrain, ytrain)
pred = predict(mod, Xtest).pred
@show rmsep(pred, ytest)
mse(pred, ytest)


plotxy(pred, ytest; color = (:red, .5), bisect = true, xlabel = "Prediction", 
    ylabel = "Observed (Test)").f


nlv = 15 ; gamma = .01
metric = [:eucl, :mah]
h = [1; 2; 3.5; 6] ; k = [50; 100; 150; 200]  
pars = mpar(metric = metric, h = h, k = k) 
length(pars[1])


mod1 = model(dkplsr)
mod2 = model(lwmlr)
mod = pip(mod1, mod2)
res = gridscore(mod, Xcal, ycal, Xval, yval; score = rmsep, pars, verbose = false)


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


mod1 = model(dkplsr; nlv, gamma)
mod2 = model(lwmlr; metric = res.metric[u], h = res.h[u], k = res.k[u])
mod = pip(mod1, mod2)
fit!(mod, Xtrain, ytrain)
pred = predict(mod, Xtest).pred
@show rmsep(pred, ytest)
mse(pred, ytest)


plotxy(pred, ytest; color = (:red, .5), bisect = true, xlabel = "Prediction", 
    ylabel = "Observed (Test)").f

