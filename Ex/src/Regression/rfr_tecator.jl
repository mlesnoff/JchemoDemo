using JLD2, CairoMakie
using Jchemo, JchemoData
using Loess

```julia
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/tecator.jld2") 
@load db dat
pnames(dat)

```julia
X = dat.X
Y = dat.Y 
ntot, p = size(X)

```julia term = true
@head X
@head Y

```julia
summ(Y)

```julia
namy = names(Y)[1:3]

```julia
typ = Y.typ
tab(typ)

```julia
wl = names(X)
wl_num = parse.(Float64, wl) 

```julia
plotsp(X, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

```julia
f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 

plotsp(Xp, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

```julia
s = typ .== "train"
Xtrain = Xp[s, :]
Ytrain = Y[s, namy]
Xtest = rmrow(Xp, s)
Ytest = rmrow(Y[:, namy], s)
ntrain = nro(Xtrain)
ntest = nro(Xtest)
ntot = ntrain + ntest
(ntot = ntot, ntrain, ntest)

```julia
j = 2  
nam = namy[j]    # y-variable
ytrain = Ytrain[:, nam]
ytest = Ytest[:, nam]

```julia 
n_trees = 100
partial_sampling = .7
n_subfeatures = p / 3
max_depth = 20
fm = rfr_dt(Xtrain, ytrain; 
    n_trees = n_trees,
    partial_sampling = partial_sampling,
    n_subfeatures = n_subfeatures,
    max_depth = max_depth) ;
pnames(fm)

```julia 
pred = Jchemo.predict(fm, Xtest).pred

```julia
rmsep(pred, ytest)

```julia
bias(pred, ytest)

```julia
mse(pred, ytest)

```julia
r = residreg(pred, ytest) # residuals

```julia 
zpred = vec(pred)
f, ax = plotxy(zpred, ytest;
    xlabel = "Predicted", ylabel = "Observed",
    resolution = (500, 400))
zfm = loess(zpred, ytest; span = 2/3) ;
pred_loess = Loess.predict(zfm, sort(zpred))
lines!(ax, sort(zpred), pred_loess; color = :red)
ablines!(ax, 0, 1; color = :grey)
f    

```julia
zr = vec(r)
f, ax = plotxy(ytest, zr; color = (:blue, .5), 
    resolution = (500, 400), 
    xlabel = "Observed (Test)", ylabel = "Residual") 
zfm = loess(ytest, zr; span = 2/3) ;
pred_loess = Loess.predict(zfm, sort(ytest))
lines!(ax, sort(ytest), pred_loess; color = :red)
hlines!(ax, 0; color = :grey, linestyle = :dashdot)
f    

```julia 
## RFR With function baggr
rep = 100
rowsamp = .7
n_subfeatures = p / 3
max_depth = 20
fm = baggr(Xtrain, ytrain; rep = 100,
    rowsamp = rowsamp, colsamp = 1,
    fun = treer_dt,
    n_subfeatures = n_subfeatures,
    max_depth = max_depth) ;
pnames(fm)

```julia 
pred = Jchemo.predict(fm, Xtest).pred

```julia 
rmsep(pred, ytest)

```julia 
plotxy(pred, ytest; resolution = (500, 400),
    color = (:red, .5), bisect = true, 
    xlabel = "Prediction", ylabel = "Observed (Test)").f   
