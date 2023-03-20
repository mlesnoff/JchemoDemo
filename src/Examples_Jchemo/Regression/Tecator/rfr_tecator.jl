using JLD2, CairoMakie
using Jchemo, JchemoData
using Loess

mypath = dirname(dirname(pathof(JchemoData)))
db = joinpath(mypath, "data", "tecator.jld2") 
@load db dat
pnames(dat)

X = dat.X
Y = dat.Y 
wl = names(X)
wl_num = parse.(Float64, wl) 
ntot = nro(X)
typ = Y.typ
namy = names(Y)[1:3]

plotsp(X, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 
plotsp(Xp, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

s = typ .== "train"
Xtrain = Xp[s, :]
Ytrain = Y[s, namy]
Xtest = rmrow(Xp, s)
Ytest = rmrow(Y[:, namy], s)
ntrain = nro(Xtrain)
ntest = nro(Xtest)
ntot = ntrain + ntest
(ntot = ntot, ntrain, ntest)

j = 2  # y-variable
nam = namy[j]
ytrain = Ytrain[:, nam]
ytest = Ytest[:, nam]

max_depth = 20 ; min_child_weight = 5
fm = rfr_xgb(Xtrain, ytrain; rep = 100,
      subsample = .7, colsample_bynode = 1/5,
      max_depth = max_depth, 
      min_child_weight = min_child_weight)
pnames(fm)

pred = Jchemo.predict(fm, Xtest).pred

rmsep(pred, ytest)
bias(pred, ytest)
mse(pred, ytest)

zpred = vec(pred)
plotxy(zpred, ytest; resolution = (500, 400),
    color = (:red, .5), bisect = true, 
    xlabel = "Prediction", ylabel = "Observed (Test)").f   

zfm = loess(zpred, ytest; span = 2/3) ;
pred_loess = Loess.predict(zfm, sort(zpred))
f, ax = plotxy(zpred, ytest;
    xlabel = "Predicted", ylabel = "Observed",
    resolution = (500, 400))
lines!(ax, sort(zpred), pred_loess; color = :red)
ablines!(ax, 0, 1; color = :grey)
f    

## With function baggr
max_depth = 20 ; min_child_weight = 5
fm = baggr(Xtrain, ytrain; rep = 100,
    rowsamp = .7, colsamp = 1,
    fun = treer_xgb,
    subsample = 1, colsample_bynode = 1/5,
    max_depth = max_depth, 
    min_child_weight = min_child_weight) ;
pnames(fm)
pred = Jchemo.predict(fm, Xtest).pred
println(rmsep(pred, ytest))
zpred = vec(pred)
f, ax = plotxy(zpred, ytest; color = (:red, .5),
    xlabel = "Predicted (Test)", ylabel = "Observed",
    resolution = (500, 400))
ablines!(ax, 0, 1)
f  

