using JLD2, CairoMakie, StatsBase
using Jchemo, JchemoData
using Loess

using JchemoData, JLD2, CairoMakie
mypath = dirname(dirname(pathof(JchemoData)))
db = joinpath(mypath, "data", "cassav.jld2")
@load db dat
pnames(dat)

X = dat.X
y = dat.Y.tbc
year = dat.Y.year
wl = names(X)
wl_num = parse.(Float64, wl) 
tab(year)
s = year .<= 2012
Xtrain = X[s, :]
ytrain = y[s]
Xtest = rmrow(X, s)
ytest = rmrow(y, s)
ntrain = nro(Xtrain)
ntest = nro(Xtest)
ntot = ntrain + ntest
(ntot = ntot, ntrain, ntest)

plotsp(X, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 
plotsp(Xp, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

nval = Int64(round(.30 * ntrain))
s = sampsys(ytrain; k = nval).train
ytrain[s]
Xcal = rmrow(Xtrain, s)
ycal = rmrow(ytrain, s)
Xval = Xtrain[s, :]
yval = ytrain[s, :]

## PLSR
nlv = 0:40
res = gridscorelv(Xcal, ycal, Xval, yval; 
    score = rmsep, fun = plskern, nlv = nlv) 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
plotgrid(res.nlv, res.y1; step = 2,
    xlabel = "Nb. LVs", ylabel = "RMSEP").f
fm = plskern(Xtrain, ytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred ;
mse(pred, ytest)
f, ax = plotxy(vec(pred), ytest; color = (:red, .5),
    xlabel = "Predicted", ylabel = "Observed (Test)",
    resolution = (450, 350))
ablines!(ax, 0, 1)
f 

## LWMLR-S(PCA) = LWR(Naes et al.1990)
metric = ["eucl", "mahal"]
h = [1; 2; 6] ; k = [50; 100; 150]  
nlv = Int64.(LinRange(5, 20, 4))
typ = ["pca"] 
pars = mpar(metric = metric, h = h, k = k, 
    nlv = nlv, typ = typ) 
length(pars[1])
res = gridscore(Xcal, ycal, Xval, yval; 
    score = rmsep, fun = lwmlr_s, pars = pars,
    verbose = true) 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
fm = lwmlr_s(Xtrain, ytrain; metric = res.metric[u], 
    h = res.h[u], k = res.k[u], nlv = res.nlv[u], 
    typ = res.typ[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
mse(pred, ytest)
plotxy(vec(pred), ytest; color = (:red, .5),
    bisect = true, xlabel = "Prediction",
    ylabel = "Observed (Test)").f

## LWMLR-S(PLS)
metric = ["eucl", "mahal"]
h = [1; 2; 6] ; k = [50; 100; 150]  
nlv = Int64.(LinRange(5, 20, 4))
typ = ["pls"] 
pars = mpar(metric = metric, h = h, k = k, 
    nlv = nlv, typ = typ) 
length(pars[1])
res = gridscore(Xcal, ycal, Xval, yval; 
    score = rmsep, fun = lwmlr_s, pars = pars,
    verbose = true) 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
fm = lwmlr_s(Xtrain, ytrain; metric = res.metric[u], 
    h = res.h[u], k = res.k[u], nlv = res.nlv[u], 
    typ = res.typ[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
mse(pred, ytest)
plotxy(vec(pred), ytest; color = (:red, .5),
    bisect = true, xlabel = "Prediction",
    ylabel = "Observed (Test)").f

## LWMLR-S(DKPLS)
metric = ["eucl", "mahal"]
h = [1; 2; 6] ; k = [50; 100; 150]  
nlv = Int64.(LinRange(5, 20, 4))
gamma = 10.0.^(-2:3)
typ = ["dkpls"] 
pars = mpar(metric = metric, h = h, k = k, 
    nlv = nlv, gamma = gamma, typ = typ) 
length(pars[1])
res = gridscore(Xcal, ycal, Xval, yval; 
    score = rmsep, fun = lwmlr_s, pars = pars,
    verbose = true) 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
fm = lwmlr_s(Xtrain, ytrain; metric = res.metric[u], 
    h = res.h[u], k = res.k[u], nlv = res.nlv[u], 
    gamma = res.gamma[u], typ = res.typ[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
mse(pred, ytest)
plotxy(vec(pred), ytest; color = (:red, .5),
    bisect = true, xlabel = "Prediction",
    ylabel = "Observed (Test)").f
