
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


pct = .3
nval = Int(round(pct * ntrain))


s = samprand(ntrain, nval)


#s = sampks(Xtrain, nval; metric = :eucl)


#s = sampdp(Xtrain, nval)


#s = sampsys(ytrain, nval)


Xcal = Xtrain[s.train, :]
ycal = ytrain[s.train]
Xval = Xtrain[s.test, :]
yval = ytrain[s.test]
ncal = ntrain - nval 
(ntot = ntot, ntrain, ntest, ncal, nval)


mod = model(plskern)
nlv = 0:20
res = gridscore(mod, Xcal, ycal, Xval, yval; score = rmsep, nlv, verbose = false)


plotgrid(res.nlv, res.y1; step = 2, xlabel = "Nb. LVs", ylabel = "RMSEP").f


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


mod = model(plskern; nlv = res.nlv[u])
fit!(mod, Xtrain, ytrain)
pred = Jchemo.predict(mod, Xtest).pred


rmsep(pred, ytest)


f, ax = plotxy(pred, ytest; xlabel = "Predicted", ylabel = "Observed")
zpred = vec(pred)
zfm = loess(zpred, ytest; span = 2/3) ;
pred_loess = Loess.predict(zfm, sort(zpred))
lines!(ax, sort(zpred), pred_loess; color = :red)
ablines!(ax, 0, 1; color = :grey)
f

