
using JLD2, CairoMakie, StatsBase
using Jchemo, JchemoData


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


wl = names(X)
wl_num = parse.(Float64, wl)


plotsp(X, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d)


plotsp(Xp, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


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


nval = Int64(round(.30 * ntrain))
s = sampsys(ytrain; k = nval).train
ytrain[s]
Xcal = rmrow(Xtrain, s)
ycal = rmrow(ytrain, s)
Xval = Xtrain[s, :]
yval = ytrain[s, :]
ncal = ntrain - nval
(ntot = ntot, ntrain, ntest, ncal, nval)


nlv = 0:40
res = gridscorelv(Xcal, ycal, Xval, yval; 
    score = rmsep, fun = plskern, nlv = nlv)


plotgrid(res.nlv, res.y1; step = 5,
    xlabel = "Nb. LVs", ylabel = "RMSEP").f


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


fm = plskern(Xtrain, ytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred ;
rmsep(pred, ytest)
mse(pred, ytest)


f, ax = plotxy(pred, ytest; color = (:red, .5),
    xlabel = "Predicted", ylabel = "Observed (Test)",
    resolution = (450, 350))
ablines!(ax, 0, 1)
f


reduc = ["pca"] 
nlv = Int64.(LinRange(5, 20, 4))
metric = ["eucl", "mahal"]
h = [1; 2; 6] ; k = [50; 100; 150]  
pars = mpar(reduc = reduc, nlv = nlv, 
    metric = metric, h = h, k = k) 
length(pars[1])


res = gridscore(Xcal, ycal, Xval, yval; 
    score = rmsep, fun = lwmlr_s, pars = pars,
    verbose = false)


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


fm = lwmlr_s(Xtrain, ytrain; reduc = res.reduc[u], 
    nlv = res.nlv[u], metric = res.metric[u], 
    h = res.h[u], k = res.k[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
@show rmsep(pred, ytest)
mse(pred, ytest)


plotxy(pred, ytest; color = (:red, .5),
    bisect = true, xlabel = "Prediction",
    ylabel = "Observed (Test)").f


reduc = ["pls"] 
nlv = Int64.(LinRange(5, 20, 4))
metric = ["eucl", "mahal"]
h = [1; 2; 6] ; k = [50; 100; 150]  
pars = mpar(reduc = reduc, nlv = nlv, 
    metric = metric, h = h, k = k) 
length(pars[1])


res = gridscore(Xcal, ycal, Xval, yval; 
    score = rmsep, fun = lwmlr_s, pars = pars,
    verbose = false)


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


fm = lwmlr_s(Xtrain, ytrain; reduc = res.reduc[u], 
    nlv = res.nlv[u], metric = res.metric[u], 
    h = res.h[u], k = res.k[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
@show rmsep(pred, ytest)
mse(pred, ytest)


plotxy(pred, ytest; color = (:red, .5),
    bisect = true, xlabel = "Prediction",
    ylabel = "Observed (Test)").f


reduc = ["dkpls"] 
nlv = Int64.(LinRange(5, 20, 4))
metric = ["eucl", "mahal"]
h = [1; 2; 6] ; k = [50; 100; 150]  
gamma = 10.0.^(-2:3)
pars = mpar(reduc = reduc, nlv = nlv, metric = metric, 
    h = h, k = k, gamma = gamma, ) 
length(pars[1])


res = gridscore(Xcal, ycal, Xval, yval; 
    score = rmsep, fun = lwmlr_s, pars = pars,
    verbose = false)


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


fm = lwmlr_s(Xtrain, ytrain; reduc = res.reduc[u],
    metric = res.metric[u], nlv = res.nlv[u], 
    h = res.h[u], k = res.k[u], gamma = res.gamma[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
@show rmsep(pred, ytest)
mse(pred, ytest)


plotxy(pred, ytest; color = (:red, .5),
    bisect = true, xlabel = "Prediction",
    ylabel = "Observed (Test)").f
