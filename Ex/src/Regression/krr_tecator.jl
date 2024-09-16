
using Jchemo, JchemoData
using JLD2, CairoMakie


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


mod1 = model(snv)
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


gamma = 100
lb = 1e-3
mod = model(krr; gamma, lb)
fit!(mod, Xtrain, ytrain)
pnames(mod)
pnames(mod.fm)


pred = predict(mod, Xtest).pred


rmsep(pred, ytest)


bias(pred, ytest)


mse(pred, ytest)


r = residreg(pred, ytest) # residuals


f, ax = plotxy(pred, ytest; size = (500, 400), xlabel = "Predicted", ylabel = "Observed")
zpred = vec(pred)
zmod = model(loessr; span = 2/3) 
fit!(zmod, zpred, ytest)
pred_loess = predict(zmod, sort(zpred)).pred
lines!(ax, sort(zpred), vec(pred_loess); color = :red)
ablines!(ax, 0, 1; color = :grey)
f


f, ax = plotxy(ytest, r; size = (500, 400), color = (:blue, .5), xlabel = "Observed (Test)", 
    ylabel = "Residuals") 
zpred = vec(pred)
zr = vec(r)
zmod = model(loessr; span = 2/3) 
fit!(zmod, zpred, zr)
r_loess = predict(zmod, sort(zpred)).pred
lines!(ax, sort(zpred), vec(r_loess); color = :red)
hlines!(ax, 0; color = :grey)
f

