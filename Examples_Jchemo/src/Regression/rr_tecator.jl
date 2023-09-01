using JLD2, CairoMakie
using Jchemo, JchemoData
using Loess

#-
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/tecator.jld2") 
@load db dat
pnames(dat)

#-
X = dat.X
Y = dat.Y 
ntot = nro(X)

#-
@head X 

#-
@head Y

#-
summ(Y)

#-
namy = names(Y)[1:3]

#-
typ = Y.typ
tab(typ)

#-
wl = names(X)
wl_num = parse.(Float64, wl) 

#-
plotsp(X, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

#-
f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 

plotsp(Xp, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

#-
s = typ .== "train"
Xtrain = Xp[s, :]
Ytrain = Y[s, namy]
Xtest = rmrow(Xp, s)
Ytest = rmrow(Y[:, namy], s)
ntrain = nro(Xtrain)
ntest = nro(Xtest)
ntot = ntrain + ntest
(ntot = ntot, ntrain, ntest)

#-
j = 2  
nam = namy[j]    # y-variable
ytrain = Ytrain[:, nam]
ytest = Ytest[:, nam]

#-
lb = 1e-3
fm = rr(Xtrain, ytrain; lb = lb) ;
## Alternative RR algorithm 
## (same results, but slower to tune):
#fm = rrchol(Xtrain, ytrain; lb = lb) ;

#-
pred = Jchemo.predict(fm, Xtest).pred

#-
Jchemo.predict(fm, Xtest; lb = 1e-2).pred

#-
## Predictions for multiple values of 'lb'
## are only possible with 'rr' (not with 'rrchol')
zlb = 10.0.^(-6:-1)
Jchemo.predict(fm, Xtest; lb = zlb).pred

#-
rmsep(pred, ytest)

#-
bias(pred, ytest)

#-
mse(pred, ytest)

#-
r = residreg(pred, ytest) # residuals

#- 
zpred = vec(pred)
f, ax = plotxy(zpred, ytest;
    xlabel = "Predicted", ylabel = "Observed",
    resolution = (500, 400))
zfm = loess(zpred, ytest; span = 2/3) ;
pred_loess = Loess.predict(zfm, sort(zpred))
lines!(ax, sort(zpred), pred_loess; color = :red)
ablines!(ax, 0, 1; color = :grey)
f    

#-
zr = vec(r)
f, ax = plotxy(ytest, zr; color = (:blue, .5), 
    resolution = (500, 400), 
    xlabel = "Observed (Test)", ylabel = "Residual") 
zfm = loess(ytest, zr; span = 2/3) ;
pred_loess = Loess.predict(zfm, sort(ytest))
lines!(ax, sort(ytest), pred_loess; color = :red)
hlines!(ax, 0; color = :grey, linestyle = :dashdot)
f    
