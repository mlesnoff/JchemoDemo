using JLD2, CairoMakie, StatsBase
using Jchemo, JchemoData

#-
using JchemoData, JLD2, CairoMakie
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/cassav.jld2")
@load db dat
pnames(dat)

#-
X = dat.X
y = dat.Y.tbc
year = dat.Y.year

#-
wl = names(X)
wl_num = parse.(Float64, wl) 

#-
tab(year)

#-
s = year .<= 2012
Xtrain = X[s, :]
ytrain = y[s]
Xtest = rmrow(X, s)
ytest = rmrow(y, s)
ntrain = nro(Xtrain)
ntest = nro(Xtest)
ntot = ntrain + ntest
(ntot = ntot, ntrain, ntest)

#-
plotsp(X, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

#-
f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 

plotsp(Xp, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

#-
nval = Int64(round(.30 * ntrain))
s = sampsys(ytrain; k = nval).train
ytrain[s]
Xcal = rmrow(Xtrain, s)
ycal = rmrow(ytrain, s)
Xval = Xtrain[s, :]
yval = ytrain[s, :]
ncal = ntrain - nval
(ntot = ntot, ntrain, ntest, ncal, nval)

#-
## PLSR
nlv = 0:40
res = gridscorelv(Xcal, ycal, Xval, yval; 
    score = rmsep, fun = plskern, nlv = nlv) 

#-
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]

#-
plotgrid(res.nlv, res.y1; step = 2,
    xlabel = "Nb. LVs", ylabel = "RMSEP").f

#-
fm = plskern(Xtrain, ytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred ;
@show rmsep(pred, ytest)
mse(pred, ytest)

#-
f, ax = plotxy(vec(pred), ytest; color = (:red, .5),
    xlabel = "Predicted", ylabel = "Observed (Test)",
    resolution = (450, 350))
ablines!(ax, 0, 1)
f 

#-
## LWMLR-S with a PCA-score space = "LWR" (Naes et al.1990)
metric = ["eucl", "mahal"]
h = [1; 2; 6] ; k = [50; 100; 150]  
nlv = Int64.(LinRange(5, 20, 4))
reduc = ["pca"] 
pars = mpar(metric = metric, h = h, k = k, 
    nlv = nlv, reduc = reduc) 
length(pars[1])

#-
res = gridscore(Xcal, ycal, Xval, yval; 
    score = rmsep, fun = lwmlr_s, pars = pars,
    verbose = true) 

#-
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]

#-
fm = lwmlr_s(Xtrain, ytrain; metric = res.metric[u], 
    h = res.h[u], k = res.k[u], nlv = res.nlv[u], 
    reduc = res.reduc[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
@show rmsep(pred, ytest)
mse(pred, ytest)

#-
plotxy(vec(pred), ytest; color = (:red, .5),
    bisect = true, xlabel = "Prediction",
    ylabel = "Observed (Test)").f

#-
## LWMLR-S with a PLS-score space
metric = ["eucl", "mahal"]
h = [1; 2; 6] ; k = [50; 100; 150]  
nlv = Int64.(LinRange(5, 20, 4))
reduc = ["pls"] 
pars = mpar(metric = metric, h = h, k = k, 
    nlv = nlv, reduc = reduc) 
length(pars[1])

#-
res = gridscore(Xcal, ycal, Xval, yval; 
    score = rmsep, fun = lwmlr_s, pars = pars,
    verbose = true) 

#-
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]

#-
fm = lwmlr_s(Xtrain, ytrain; metric = res.metric[u], 
    h = res.h[u], k = res.k[u], nlv = res.nlv[u], 
    reduc = res.reduc[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
@show rmsep(pred, ytest)
mse(pred, ytest)

#-
plotxy(vec(pred), ytest; color = (:red, .5),
    bisect = true, xlabel = "Prediction",
    ylabel = "Observed (Test)").f

#-
## LWMLR-S with a DKPLS-score space
metric = ["eucl", "mahal"]
h = [1; 2; 6] ; k = [50; 100; 150]  
nlv = Int64.(LinRange(5, 20, 4))
gamma = 10.0.^(-2:3)
reduc = ["dkpls"] 
pars = mpar(metric = metric, h = h, k = k, 
    nlv = nlv, gamma = gamma, reduc = reduc) 
length(pars[1])

#-
res = gridscore(Xcal, ycal, Xval, yval; 
    score = rmsep, fun = lwmlr_s, pars = pars,
    verbose = true) 

#-
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]

#-
fm = lwmlr_s(Xtrain, ytrain; metric = res.metric[u], 
    h = res.h[u], k = res.k[u], nlv = res.nlv[u], 
    gamma = res.gamma[u], reduc = res.reduc[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
@show rmsep(pred, ytest)
mse(pred, ytest)

#-
plotxy(vec(pred), ytest; color = (:red, .5),
    bisect = true, xlabel = "Prediction",
    ylabel = "Observed (Test)").f


