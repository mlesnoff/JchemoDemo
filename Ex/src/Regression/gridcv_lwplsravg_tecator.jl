
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


mod1 = model(snv(centr = true, scal = true)
mod2 = model(savgol(npoint = 15, deriv = 2, degree = 3)
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


segm = segmkf(ntrain, 4; rep = 5)


nlvdis = [10; 15] ; metric = [:mah] 
h = [1; 2; 5; Inf] ; k = [30; 50; 100]  
nlv = [0:5, 0:10, 1:5, 1:10]
pars = mpar(nlvdis = nlvdis, metric = metric, h = h, k = k, nlv = nlv)


length(pars[1])


mod = model(lwplsravg)
res = gridcv(mod, Xtrain, ytrain; segm, score = rmsep, 
    pars, verbose = false).res


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


mod = model(lwplsravg(nlvdis = res.nlvdis[u], metric = res.metric[u], 
    h = res.h[u], k = res.k[u], nlv = res.nlv[u])
fit!(mod, Xtrain, ytrain)
pred = predict(mod, Xtest).pred
rmsep(pred, ytest)


plotxy(pred, ytest; color = (:red, .5), bisect = true, xlabel = "Prediction", 
    ylabel = "Observed (Test)").f

