
using Jchemo, JchemoData
using JLD2, CairoMakie


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/tecator.jld2") 
@load db dat
pnames(dat)


X = dat.X
Y = dat.Y 
ntot, p = size(X)


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


segm = segmkf(ntrain, 4; rep = 20)


segm_slow = segm[1:3]


nlv = 0:50
pars = mpar(scal = [false; true])
length(pars[1])
mod = model(plskern)  
res = gridcv(mod, Xtrain, ytrain; segm, score = rmsep, 
    pars, nlv).res 
group = string.(res.scal) 
plotgrid(res.nlv, res.y1, group; step = 2, xlabel ="Nb. LVs", ylabel = "RMSEP").f
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :] 
mod = model(plskern(nlv = res.nlv[u], scal = res.scal[u])
fit!(mod, Xtrain, ytrain) 
pred = predict(mod, Xtest).pred 
@show rmsep(pred, ytest)
plotxy(pred, ytest; color = (:red, .5), bisect = true, xlabel = "Prediction", 
    ylabel = "Observed (Test)").f


nlv = [0:10, 0:20, 0:50]
pars = mpar(nlv = nlv)
length(pars[1])
mod = model(plsravg)
res = gridcv(mod, Xtrain, ytrain; segm, score = rmsep, pars).res 
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :] 
mod = model(plsravg(nlv = res.nlv[u])
fit!(mod, Xtrain, ytrain) 
pred = predict(mod, Xtest).pred 
@show rmsep(pred, ytest)


lb = 10.0.^(-15:.1:3)
mod = model(rr)
res = gridcv(mod, Xtrain, ytrain; segm, score = rmsep, lb).res 
zlb = round.(log.(10, res.lb), digits = 3)
plotgrid(zlb, res.y1; step = 2, xlabel ="Lambda", ylabel = "RMSEP").f
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
mod = model(rr(lb = res.lb[u]) ;
fit!(mod, Xtrain, ytrain) 
pred = predict(mod, Xtest).pred 
@show rmsep(pred, ytest)


nlv = 0:20
pars = mpar(msparse = [:hard], nvar = [1])
mod = model(splskern)
res = gridcv(mod, Xtrain, ytrain; segm, score = rmsep, 
    pars, nlv, verbose = false).res
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
mod = model(splskern(msparse = res.msparse[u], nvar = res.nvar[u], 
    nlv = res.nlv[u])
fit!(mod, Xtrain, ytrain) 
pred = predict(mod, Xtest).pred 
@show rmsep(pred, ytest)


lb = 10.0.^(-15:5) 
gamma = 10.0.^(-3:5) 
pars = mpar(gamma = gamma) 
length(pars[1])
mod = model(krr)
res = gridcv(mod, Xtrain, ytrain; segm, score = rmsep, 
    pars, lb, verbose = false).res
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
mod = model(krr(lb = res.lb[u], gamma = res.gamma[u]) 
fit!(mod, Xtrain, ytrain) 
pred = predict(mod, Xtest).pred 
@show rmsep(pred, ytest)
plotxy(pred, ytest; color = (:red, .5), bisect = true, xlabel = "Prediction", 
    ylabel = "Observed (Test)").f


nlv = 0:30 
gamma = 10.0.^(-3:5)
pars = mpar(gamma = gamma)
length(pars[1])
mod = model(kplsr)
res = gridcv(mod, Xtrain, ytrain; segm, score = rmsep, 
    pars, nlv, verbose = false).res
u = findall(res.y1 .== minimum(res.y1))[1] ;
res[u, :]
mod = model(kplsr(nlv = res.nlv[u], gamma = res.gamma[u])
fit!(mod, Xtrain, ytrain) 
pred = predict(mod, Xtest).pred 
rmsep(pred, ytest)


nlv = 0:30 
gamma = 10.0.^(-3:5)
pars = mpar(gamma = gamma)
length(pars[1])
mod = model(dkplsr)
res = gridcv(mod, Xtrain, ytrain; segm, score = rmsep, 
    pars, nlv, verbose = false).res
u = findall(res.y1 .== minimum(res.y1))[1] ;
res[u, :]
mod = model(dkplsr(nlv = res.nlv[u], gamma = res.gamma[u])
fit!(mod, Xtrain, ytrain) 
pred = predict(mod, Xtest).pred 
rmsep(pred, ytest)


nlvdis = [10; 15] ; metric = [:mah] 
h = [1; 2; 4; 6; Inf]
k = [30; 50; 100]  
nlv = 0:15 
pars = mpar(nlvdis = nlvdis, metric = metric, h = h, k = k)
length(pars[1])
mod = model(lwplsr)
res = gridcv(mod, Xtrain, ytrain; segm, score = rmsep, 
    pars, nlv, verbose = true).res 
group = string.(res.nlvdis, "-", res.h, "-", res.k) 
plotgrid(res.nlv, res.y1, group; xlabel ="Nb. LVs", ylabel = "RMSEP").f
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
mod = model(lwplsr(nlvdis = res.nlvdis[u], metric = res.metric[u], 
    h = res.h[u], k = res.k[u], nlv = res.nlv[u])
fit!(mod, Xtrain, ytrain)
pred = Jchemo.predict(mod, Xtest).pred 
rmsep(pred, ytest)


nlvdis = [10; 15] ; metric = [:mah] 
h = [1; 2; 5; Inf] ; k = [30; 50; 100]  
nlv = [0:5, 0:10, 1:5, 1:10]
pars = mpar(nlv = nlv, nlvdis = nlvdis, metric = metric, h = h, k = k) 
length(pars[1])
mod = model(lwplsravg) 
res = gridcv(mod, Xtrain, ytrain; segm, score = rmsep, 
    pars, verbose = true).res
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
mod = model(lwplsravg(nlvdis = res.nlvdis[u], metric = res.metric[u], 
    h = res.h[u], k = res.k[u], nlv = res.nlv[u]) ;
fit!(mod, Xtrain, ytrain)
pred = Jchemo.predict(mod, Xtest).pred ;
rmsep(pred, ytest)


nlvdis = [15; 20]  ; metric = [:eucl, :mah] 
h = [1; 2; 4; 6; Inf] 
k = [1; collect(5:10:50)] 
pars = mpar(nlvdis = nlvdis, metric = metric, h = h, k = k) 
length(pars[1])
mod = model(knnr)
res = gridcv(mod, Xtrain, ytrain; segm, score = rmsep, pars).res
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]
mod = model(knnr(nlvdis = res.nlvdis[u], metric = res.metric[u], 
    h = res.h[u], k = res.k[u])
fit!(mod, Xtrain, ytrain) 
pred = predict(mod, Xtest).pred 
rmsep(pred, ytest)


n_trees = [200]
n_subfeatures = LinRange(10, p, 10)
max_depth = [6; 10; 20; 50; 2000]
pars = mpar(n_trees = n_trees, n_subfeatures = n_subfeatures, max_depth = max_depth)
length(pars[1])
res = gridcv(mod, Xtrain, ytrain; segm, score = rmsep, pars).res 
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]
mod = model(rfr_dt(n_trees = res.n_trees[u], n_subfeatures = res.n_subfeatures[u], 
    max_depth = res.max_depth[u])
fit!(mod, Xtrain, ytrain) 
pred = predict(mod, Xtest).pred 
@show rmsep(pred, ytest)
plotxy(pred, ytest; color = (:red, .5), bisect = true, xlabel = "Prediction", 
    ylabel = "Observed (Test)").f

