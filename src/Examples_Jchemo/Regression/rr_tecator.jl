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
ntot, p = size(X)
y = Y.fat
typ = Y.typ
namy = names(Y)[1:3]

plotsp(X, wl_num,
    xlabel = "Wavelength (nm)", 
    ylabel = "Absorbance").f

f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 
plotsp(Xp, wl_num,
    xlabel = "Wavelength (nm)", 
    ylabel = "Absorbance").f

s = typ .== "train"
Xtrain = Xp[s, :]
Ytrain = Y[s, namy]
Xtest = rmrow(Xp, s)
Ytest = rmrow(Y[:, namy], s)
ntrain = nro(Xtrain)
ntest = nro(Xtest)
ntot = ntrain + ntest
(ntot = ntot, ntrain, ntest)

## Work on the second y-variable 
j = 2
nam = namy[j]
ytrain = Ytrain[:, nam]
ytest = Ytest[:, nam]

## Model fitting
lb = 1e-3
fm = rr(Xtrain, ytrain; lb = lb) ;
#fm = rrchol(Xtrain, ytrain; lb = lb) ;

## Predictions
pred = Jchemo.predict(fm, Xtest).pred

## Commands below are only possible with "rr" 
## (not with "rrchol")
Jchemo.predict(fm, Xtest; lb = 1e-2).pred
zlb = 10.0.^(-6:-1)
Jchemo.predict(fm, Xtest; lb = zlb).pred

rmsep(pred, ytest)
bias(pred, ytest)
mse(pred, ytest)

zpred = vec(pred)
f, ax = plotxy(zpred, ytest;
    xlabel = "Predicted", ylabel = "Observed",
    resolution = (500, 400))
ablines!(ax, 0, 1)
f   

## Using Loess
zfm = loess(zpred, ytest, span = 2 / 3) ;
pred_loess = Loess.predict(zfm, sort(zpred))
f, ax = plotxy(zpred, ytest;
    xlabel = "Predicted (Test)", ylabel = "Observed",
    resolution = (500, 400))
lines!(ax, sort(zpred), pred_loess; color = :red)
ablines!(ax, 0, 1)
f    

