
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


mo1 = snv(centr = true, scal = true)
mo2 = savgol(npoint = 11, deriv = 2, degree = 3)
mo = pip(mo1, mo2)
fit!(mo, X)
Xp = transf(mo, X)


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


mo = plskern()
nlv = 0:40
res = gridscore(mo, Xcal, ycal, Xval, yval; 
    score = rmsep, nlv)


plotgrid(res.nlv, res.y1; step = 5, xlabel = "Nb. LVs", 
    ylabel = "RMSEP").f


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


mo = plskern(nlv = res.nlv[u]) 
fit!(mo, Xtrain, ytrain)
pred = predict(mo, Xtest).pred 
rmsep(pred, ytest)
mse(pred, ytest)


plotxy(pred, ytest; color = (:red, .5), bisect = true, 
    xlabel = "Prediction", ylabel = "Observed (Test)").f


nlv = 15
metric = [:eucl, :mah]
h = [1; 2; 3.5; 6] ; k = [50; 100; 150; 200]  
pars = mpar(metric = metric, h = h, k = k) 
length(pars[1])


mo1 = pcasvd()
mo2 = lwmlr()
mo = pip(mo1, mo2)
res = gridscore(mo, Xcal, ycal, Xval, yval; score = rmsep, 
    pars, verbose = false)


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


mo1 = pcasvd(; nlv)
mo2 = lwmlr(metric = res.metric[u], h = res.h[u], k = res.k[u])
mo = pip(mo1, mo2)
fit!(mo, Xtrain, ytrain)
pred = predict(mo, Xtest).pred
@show rmsep(pred, ytest)
mse(pred, ytest)


plotxy(pred, ytest; color = (:red, .5), bisect = true, 
    xlabel = "Prediction", ylabel = "Observed (Test)").f


nlv = 15
metric = [:eucl, :mah]
h = [1; 2; 3.5; 6] ; k = [50; 100; 150; 200]  
pars = mpar(metric = metric, h = h, k = k) 
length(pars[1])


mo1 = plskern()
mo2 = lwmlr()
mo = pip(mo1, mo2)
res = gridscore(mo, Xcal, ycal, Xval, yval; score = rmsep, 
    pars, verbose = false)


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


mo1 = plskern(; nlv)
mo2 = lwmlr(metric = res.metric[u], h = res.h[u], k = res.k[u])
mo = pip(mo1, mo2)
fit!(mo, Xtrain, ytrain)
pred = predict(mo, Xtest).pred
@show rmsep(pred, ytest)
mse(pred, ytest)


plotxy(pred, ytest; color = (:red, .5), bisect = true, 
    xlabel = "Prediction", ylabel = "Observed (Test)").f


nlv = 15 ; gamma = .01
metric = [:eucl, :mah]
h = [1; 2; 3.5; 6] ; k = [50; 100; 150; 200]  
pars = mpar(metric = metric, h = h, k = k) 
length(pars[1])


mo1 = dkplsr()
mo2 = lwmlr()
mo = pip(mo1, mo2)
res = gridscore(mo, Xcal, ycal, Xval, yval; score = rmsep, 
    pars, verbose = false)


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


mo1 = dkplsr(; nlv, gamma)
mo2 = lwmlr(metric = res.metric[u], h = res.h[u], k = res.k[u])
mo = pip(mo1, mo2)
fit!(mo, Xtrain, ytrain)
pred = predict(mo, Xtest).pred
@show rmsep(pred, ytest)
mse(pred, ytest)


plotxy(pred, ytest; color = (:red, .5), bisect = true, 
    xlabel = "Prediction", ylabel = "Observed (Test)").f

