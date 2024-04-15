
using Jchemo, JchemoData
using JLD2, CairoMakie
using Loess


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/tecator.jld2") 
@load db dat
pnames(dat)


X = dat.X
Y = dat.Y 
ntot = nro(X)


@head X 
@head Y


summ(Y)


namy = names(Y)[1:3]


typ = Y.typ
tab(typ)


wlst = names(X)
wl = parse.(Float64, wlst)


plotsp(X, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


mod1 = model(snv; centr = true, scal = true)
mod2 = model(savgol; npoint = 15, deriv = 2, degree = 3)
mod = pip(mod1, mod2)
fit!(mod, X)
Xp = transf(mod, X)


plotsp(Xp, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


s = typ .== "train"
Xtrain = Xp[s, :]
Ytrain = Y[s, namy]
Xtest = rmrow(Xp, s)
Ytest = rmrow(Y[:, namy], s)
ntrain = nro(Xtrain)
ntest = nro(Xtest)
ntot = ntrain + ntest
(ntot = ntot, ntrain, ntest)


j = 2  
nam = namy[j]    # y-variable
ytrain = Ytrain[:, nam]
ytest = Ytest[:, nam]


nlvdis = 10 ; metric = :mah
h = 3 ; k = 30 
nlv = 4
mod = model(lwplsr; nlvdis, metric, h, k, nlv) 
fit!(mod, Xtrain, ytrain)
pnames(mod)
pnames(mod.fm)


pred = Jchemo.predict(mod, Xtest).pred


rmsep(pred, ytest)


bias(pred, ytest)


mse(pred, ytest)


r = residreg(pred, ytest) # residuals


plotxy(pred, ytest; size = (500, 400), color = (:red, .5), bisect = true, 
    xlabel = "Prediction", ylabel = "Observed (Test)").f


plotxy(ytest, r; size = (500, 400), color = (:red, .5), zeros = true, 
    xlabel = "Observed (Test)", ylabel = "Residuals").f


f, ax = plotxy(pred, ytest; size = (500, 400), xlabel = "Predicted", ylabel = "Observed")
zpred = vec(pred)
zfm = loess(zpred, ytest; span = 2/3) ;
pred_loess = Loess.predict(zfm, sort(zpred))
lines!(ax, sort(zpred), pred_loess; color = :red)
ablines!(ax, 0, 1; color = :grey)
f


f, ax = plotxy(ytest, r; size = (500, 400), color = (:blue, .5), 
    xlabel = "Observed (Test)", ylabel = "Residuals") 
zfm = loess(ytest, vec(r); span = 2/3) ;
pred_loess = Loess.predict(zfm, sort(ytest))
lines!(ax, sort(ytest), pred_loess; color = :red)
hlines!(ax, 0; color = :grey, linestyle = :dashdot)
f

