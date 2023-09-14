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
ntot = nro(X)

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
## Preprocessing
f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 

plotsp(Xp, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

```julia
## Split Tot = Train + Test
## The model is tuned on Train, and
## the generalization error is estimated on Test.
## Here the split of Tot is provided by the dataset
## (= variable 'typ'), but Tot could be split 
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

```julia
## Work on the second y-variable 
j = 2  
nam = namy[j]    # y-variable
ytrain = Ytrain[:, nam]
ytest = Ytest[:, nam]

```julia
## Model fitting
nlv = 15
fm = plskern(Xtrain, ytrain; nlv = nlv) ;
pnames(fm)

```julia
## Predictions
pred = Jchemo.predict(fm, Xtest).pred

```julia
Jchemo.predict(fm, Xtest; nlv = 2).pred

```julia
Jchemo.predict(fm, Xtest; nlv = 0:2).pred

```julia
rmsep(pred, ytest)

```julia
bias(pred, ytest)

```julia
mse(pred, ytest)

```julia
r = residreg(pred, ytest) # residuals

```julia 
## Plotting predictions vs. observed data zr = vec(r)
zpred = vec(pred)
plotxy(zpred, ytest; resolution = (500, 400),
    color = (:red, .5), bisect = true, 
    xlabel = "Prediction", ylabel = "Observed (Test)").f   

```julia
zr = vec(r)
plotxy(ytest, zr; resolution = (500, 400),
    color = (:red, .5), zeros = true, 
    xlabel = "Observed (Test)", ylabel = "Residual").f   

```julia
## Adding a smoothing
f, ax = plotxy(zpred, ytest;
    xlabel = "Predicted", ylabel = "Observed",
    resolution = (500, 400))
zfm = loess(zpred, ytest; span = 2/3) ;
pred_loess = Loess.predict(zfm, sort(zpred))
lines!(ax, sort(zpred), pred_loess; color = :red)
ablines!(ax, 0, 1; color = :grey)
f    

```julia
f, ax = plotxy(ytest, zr; color = (:blue, .5), 
    resolution = (500, 400), 
    xlabel = "Observed (Test)", ylabel = "Residual") 
zfm = loess(ytest, zr; span = 2/3) ;
pred_loess = Loess.predict(zfm, sort(ytest))
lines!(ax, sort(ytest), pred_loess; color = :red)
hlines!(ax, 0; color = :grey, linestyle = :dashdot)
f   

