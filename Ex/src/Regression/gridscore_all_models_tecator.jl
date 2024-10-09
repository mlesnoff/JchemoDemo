
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


model1 = snv)
model2 = savgol; npoint = 15, deriv = 2, degree = 3)
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
Xcal = Xtrain[s.train, :]
ycal = ytrain[s.train]
Xval = Xtrain[s.test, :]
yval = ytrain[s.test]
ncal = ntrain - nval 
(ntot = ntot, ntrain, ntest, ncal, nval)


nlv = 0:20
pars = mpar(scal = [false; true])
length(pars[1])
model = plskern)  
res = gridscore(model, Xcal, ycal, Xval, yval; score = rmsep, pars, nlv) 
group = string.(res.scal) 
plotgrid(res.nlv, res.y1, group; step = 2, xlabel ="Nb. LVs", ylabel = "RMSEP").f
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :] 
model = plskern; nlv = res.nlv[u], scal = res.scal[u])
fit!(model, Xtrain, ytrain) 
pred = predict(model, Xtest).pred 
@show rmsep(pred, ytest)
plotxy(pred, ytest; color = (:red, .5), bisect = true, xlabel = "Prediction", 
    ylabel = "Observed (Test)").f


nlv = [0:10, 0:20]
pars = mpar(nlv = nlv)
length(pars[1])
model = plsravg)
res = gridscore(model, Xcal, ycal, Xval, yval; score = rmsep, pars) 
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :] 
model = plsravg; nlv = res.nlv[u])
fit!(model, Xtrain, ytrain) 
pred = predict(model, Xtest).pred 
@show rmsep(pred, ytest)


lb = 10.0.^(-15:.1:3)
model = rr)
res = gridscore(model, Xcal, ycal, Xval, yval; score = rmsep, lb) 
zlb = round.(log.(10, res.lb), digits = 3)
plotgrid(zlb, res.y1; step = 2, xlabel ="Lambda", ylabel = "RMSEP").f
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
model = rr; lb = res.lb[u]) ;
fit!(model, Xtrain, ytrain) 
pred = predict(model, Xtest).pred 
@show rmsep(pred, ytest)


nlv = 0:20
pars = mpar(msparse = [:hard], nvar = [1])
model = splskern)
res = gridscore(model, Xcal, ycal, Xval, yval; score = rmsep, pars, nlv, verbose = false)
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
model = splskern; msparse = res.msparse[u], nvar = res.nvar[u], nlv = res.nlv[u])
fit!(model, Xtrain, ytrain) 
pred = predict(model, Xtest).pred 
@show rmsep(pred, ytest)


lb = 10.0.^(-15:5) 
gamma = 10.0.^(-3:5) 
pars = mpar(gamma = gamma) 
length(pars[1])
model = krr)
res = gridscore(model, Xcal, ycal, Xval, yval; score = rmsep, pars, lb, verbose = false)
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
model = krr; lb = res.lb[u], gamma = res.gamma[u]) 
fit!(model, Xtrain, ytrain) 
pred = predict(model, Xtest).pred 
@show rmsep(pred, ytest)
plotxy(pred, ytest; color = (:red, .5), bisect = true, xlabel = "Prediction", 
    ylabel = "Observed (Test)").f


nlv = 0:30 
gamma = 10.0.^(-3:5)
pars = mpar(gamma = gamma)
length(pars[1])
model = kplsr)
res = gridscore(model, Xcal, ycal, Xval, yval; score = rmsep, pars, nlv, verbose = false)
u = findall(res.y1 .== minimum(res.y1))[1] ;
res[u, :]
model = kplsr; nlv = res.nlv[u], gamma = res.gamma[u])
fit!(model, Xtrain, ytrain) 
pred = predict(model, Xtest).pred 
rmsep(pred, ytest)


nlv = 0:30 
gamma = 10.0.^(-3:5)
pars = mpar(gamma = gamma)
length(pars[1])
model = dkplsr)
res = gridscore(model, Xcal, ycal, Xval, yval; score = rmsep, pars, nlv, verbose = false)
u = findall(res.y1 .== minimum(res.y1))[1] ;
res[u, :]
model = dkplsr; nlv = res.nlv[u], gamma = res.gamma[u])
fit!(model, Xtrain, ytrain) 
pred = predict(model, Xtest).pred 
rmsep(pred, ytest)


nlvdis = [10; 15] ; metric = [:mah] 
h = [1; 2; 4; 6; Inf]
k = [30; 50; 100]  
nlv = 0:15 
pars = mpar(nlvdis = nlvdis, metric = metric, h = h, k = k)
length(pars[1])
model = lwplsr)
res = gridscore(model, Xcal, ycal, Xval, yval; score = rmsep, pars, nlv, verbose = true) 
group = string.(res.nlvdis, "-", res.h, "-", res.k) 
plotgrid(res.nlv, res.y1, group; xlabel ="Nb. LVs", ylabel = "RMSEP").f
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
model = lwplsr; nlvdis = res.nlvdis[u], metric = res.metric[u], 
    h = res.h[u], k = res.k[u], nlv = res.nlv[u])
fit!(model, Xtrain, ytrain)
pred = predict(model, Xtest).pred 
rmsep(pred, ytest)


nlvdis = [10; 15] ; metric = [:mah] 
h = [1; 2; 5; Inf] ; k = [30; 50; 100]  
nlv = [0:5, 0:10, 1:5, 1:10]
pars = mpar(nlv = nlv, nlvdis = nlvdis, metric = metric, h = h, k = k) 
length(pars[1])
model = lwplsravg) 
res = gridscore(model, Xcal, ycal, Xval, yval; score = rmsep, pars, verbose = true)
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
model = lwplsravg; nlvdis = res.nlvdis[u], metric = res.metric[u], h = res.h[u], 
    k = res.k[u], nlv = res.nlv[u]) ;
fit!(model, Xtrain, ytrain)
pred = predict(model, Xtest).pred ;
rmsep(pred, ytest)


nlvdis = [15; 20]  ; metric = [:eucl, :mah] 
h = [1; 2; 4; 6; Inf] 
k = [1; collect(5:10:50)] 
pars = mpar(nlvdis = nlvdis, metric = metric, h = h, k = k) 
length(pars[1])
model = knnr)
res = gridscore(model, Xcal, ycal, Xval, yval; score = rmsep, pars)
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]
model = knnr; nlvdis = res.nlvdis[u], metric = res.metric[u], h = res.h[u], 
    k = res.k[u])
fit!(model, Xtrain, ytrain) 
pred = predict(model, Xtest).pred 
rmsep(pred, ytest)


n_trees = [200]
n_subfeatures = LinRange(10, p, 10)
max_depth = [6; 10; 20; 50; 2000]
pars = mpar(n_trees = n_trees, n_subfeatures = n_subfeatures, max_depth = max_depth)
length(pars[1])
res = gridscore(model, Xcal, ycal, Xval, yval; score = rmsep, pars) 
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]
model = rfr; n_trees = res.n_trees[u], n_subfeatures = res.n_subfeatures[u], 
    max_depth = res.max_depth[u])
fit!(model, Xtrain, ytrain) 
pred = predict(model, Xtest).pred 
@show rmsep(pred, ytest)
plotxy(pred, ytest; color = (:red, .5), bisect = true, xlabel = "Prediction", 
    ylabel = "Observed (Test)").f

