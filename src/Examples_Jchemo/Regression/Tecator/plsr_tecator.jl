using JLD2, CairoMakie
using Jchemo, JchemoData
using Loess

path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/tecator.jld2") 
@load db dat
pnames(dat)

X = dat.X
Y = dat.Y 
typ = Y.typ
wl = names(X)
wl_num = parse.(Float64, wl) 
ntot = nro(X)
namy = names(Y)[1:3]

plotsp(X, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 
plotsp(Xp, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

## Splitting Tot = Train + Test
## The model is fitted on Train, and
## the generalization error will be estimated on Test.
## Here the splitting of Tot is provided by the dataset
## (= variable "typ"), but data Tot could be splitted 
## a posteriori (e.g. random sampling, systematic 
## sampling, etc.) 
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
nlv = 15
fm = plskern(Xtrain, ytrain; nlv = nlv) ;
pnames(fm)

## Predictions
pred = Jchemo.predict(fm, Xtest).pred

Jchemo.predict(fm, Xtest; nlv = 2).pred
Jchemo.predict(fm, Xtest; nlv = 0:2).pred

rmsep(pred, ytest)
bias(pred, ytest)
mse(pred, ytest)

r = residreg(pred, ytest) # residuals

zpred = vec(pred)
plotxy(zpred, ytest; resolution = (500, 400),
    color = (:red, .5), bisect = true, 
    xlabel = "Prediction", ylabel = "Observed (Test)").f   

zr = vec(r)
plotxy(ytest, zr; resolution = (500, 400),
    color = (:red, .5), zeros = true, 
    xlabel = "Observed (Test)", ylabel = "Residual").f   

## Using Loess
zfm = loess(zpred, ytest; span = 2/3) ;
pred_loess = Loess.predict(zfm, sort(zpred))
f, ax = plotxy(zpred, ytest;
    xlabel = "Predicted", ylabel = "Observed",
    resolution = (500, 400))
lines!(ax, sort(zpred), pred_loess; color = :red)
ablines!(ax, 0, 1; color = :grey)
f    

zfm = loess(ytest, zr; span = 2/3) ;
pred_loess = Loess.predict(zfm, sort(ytest))
f, ax = plotxy(ytest, zr; color = (:blue, .5), 
    resolution = (500, 400), 
    xlabel = "Observed (Test)", ylabel = "Residual") 
lines!(ax, sort(ytest), pred_loess; color = :red)
hlines!(ax, 0; color = :grey, linestyle = :dashdot)
f   


