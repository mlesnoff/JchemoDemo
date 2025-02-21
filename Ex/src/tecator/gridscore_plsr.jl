
using Jchemo, JchemoData
using JLD2, CairoMakie


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/tecator.jld2") 
@load db dat
@names dat


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


model1 = snv()
model2 = savgol(npoint = 15, deriv = 2, degree = 3)
model = pip(model1, model2)
fit!(model, X)
Xp = transf(model, X)


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


nlv = 0:20
model = plskern()
res = gridscore(model, Xcal, ycal, Xval, yval; score = rmsep, nlv, verbose = false)


plotgrid(res.nlv, res.y1; step = 2, xlabel = "Nb. LVs", ylabel = "RMSEP").f


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


model = plskern(nlv = res.nlv[u])
fit!(model, Xtrain, ytrain)
pred = predict(model, Xtest).pred


rmsep(pred, ytest)


f, ax = plotxy(pred, ytest; size = (500, 400), xlabel = "Predicted", ylabel = "Observed")
zpred = vec(pred)
zmod = loessr(span = 2/3) 
fit!(zmod, zpred, ytest)
pred_loess = predict(zmod, sort(zpred)).pred
lines!(ax, sort(zpred), vec(pred_loess); color = :red)
ablines!(ax, 0, 1; color = :grey)
f

