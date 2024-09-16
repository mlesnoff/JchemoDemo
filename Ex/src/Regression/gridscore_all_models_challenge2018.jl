
using Jchemo, JchemoData
using JLD2, CairoMakie
using FreqTables


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/challenge2018.jld2") 
@load db dat
pnames(dat)


X = dat.X 
Y = dat.Y
ntot, p = size(X)


@head X
@head Y


summ(Y)


y = Y.conc
typ = Y.typ
label = Y.label 
test = Y.test
tab(test)


wlst = names(X)
wl = parse.(Float64, wlst)


freqtable(string.(typ, "-", Y.label))


freqtable(typ, test)


plotsp(X, wl; nsamp = 30).f


mod1 = model(snv)
mod2 = model(savgol; npoint = 21, deriv = 2, degree = 3)
mod = pip(mod1, mod2)
fit!(mod, X)
Xp = transf(mod, X)


plotsp(Xp, wl; nsamp = 30).f


s = Bool.(test)
Xtrain = rmrow(Xp, s)
Ytrain = rmrow(Y, s)
ytrain = rmrow(y, s)
typtrain = rmrow(typ, s)
Xtest = Xp[s, :]
Ytest = Y[s, :]
ytest = y[s]
typtest = typ[s]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)


nval = 300
s = samprand(ntrain, nval)
Xcal = Xtrain[s.train, :]
ycal = ytrain[s.train]
Xval = Xtrain[s.test, :]
yval = ytrain[s.test]
ncal = ntrain - nval 
(ntot = ntot, ntrain, ntest, ncal, nval)


nlv = 0:50
pars = mpar(scal = [false; true])
length(pars[1])
mod = model(plskern)  
res = gridscore(mod, Xcal, ycal, Xval, yval; score = rmsep, pars, nlv) 
group = string.(res.scal) 
plotgrid(res.nlv, res.y1, group; step = 2, xlabel ="Nb. LVs", ylabel = "RMSEP").f
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :] 
mod = model(plskern; nlv = res.nlv[u], scal = res.scal[u])
fit!(mod, Xtrain, ytrain) 
pred = predict(mod, Xtest).pred 
@show rmsep(pred, ytest)
plotxy(pred, ytest; color = (:red, .5), bisect = true, xlabel = "Prediction", 
    ylabel = "Observed (Test)").f


nlv = [0:30, 0:50, 0:70, 0:100]
pars = mpar(nlv = nlv)
length(pars[1])
mod = model(plsravg)
res = gridscore(mod, Xcal, ycal, Xval, yval; score = rmsep, pars, verbose = false) 
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :] 
mod = model(plsravg; nlv = res.nlv[u])
fit!(mod, Xtrain, ytrain) 
pred = predict(mod, Xtest).pred 
@show rmsep(pred, ytest)


lb = 10.0.^(-15:.1:3)
mod = model(rr)
res = gridscore(mod, Xcal, ycal, Xval, yval; score = rmsep, lb) 
zres = res[res.y1 .< 2, :]
zlb = round.(log.(10, zres.lb), digits = 3)
plotgrid(zlb, zres.y1; step = 2,xlabel ="Lambda", ylabel = "RMSEP").f
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
mod = model(rr; lb = res.lb[u]) ;
fit!(mod, Xtrain, ytrain) 
pred = predict(mod, Xtest).pred 
@show rmsep(pred, ytest)


nlv = 0:40
pars = mpar(msparse = [:hard], nvar = [1])
mod = model(splskern)
res = gridscore(mod, Xcal, ycal, Xval, yval; score = rmsep, pars, nlv, verbose = false)
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
mod = model(splskern; msparse = res.msparse[u], nvar = res.nvar[u], nlv = res.nlv[u])
fit!(mod, Xtrain, ytrain) 
pred = predict(mod, Xtest).pred 
@show rmsep(pred, ytest)


lb = 10.0.^(-15:3) 
gamma = 10.0.^(-3:5) 
pars = mpar(gamma = gamma) 
length(pars[1])
## To decrease the computation time, 
## sampling in Cal
m = 1000
s = samprand(ncal, m)
zXcal = Xcal[s.test, :]
zycal = ycal[s.test]
## End
mod = model(krr)
res = gridscore(mod, zXcal, zycal, Xval, yval; score = rmsep, pars, lb, verbose = false)
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
mod = model(krr; lb = res.lb[u], gamma = res.gamma[u]) 
fit!(mod, Xtrain, ytrain) 
pred = predict(mod, Xtest).pred 
@show rmsep(pred, ytest)
plotxy(pred, ytest; color = (:red, .5), bisect = true, xlabel = "Prediction", 
    ylabel = "Observed (Test)").f


nlv = 0:100 
gamma = 10.0.^(-3:5)
pars = mpar(gamma = gamma)
length(pars[1])
## To decrease the computation time 
## Sampling in Cal
m = 1000
s = samprand(ncal, m)
zXcal = Xcal[s.test, :]
zycal = ycal[s.test]
## End
mod = model(kplsr)
res = gridscore(mod, zXcal, zycal, Xval, yval; score = rmsep, pars, nlv, verbose = false) 
u = findall(res.y1 .== minimum(res.y1))[1] ;
res[u, :]
mod = model(kplsr; nlv = res.nlv[u], gamma = res.gamma[u])
fit!(mod, Xtrain, ytrain) 
pred = predict(mod, Xtest).pred 
@show rmsep(pred, ytest)


nlv = 0:100 
gamma = 10.0.^(-3:5)
pars = mpar(gamma = gamma)
length(pars[1])
mod = model(dkplsr)
res = gridscore(mod, Xcal, ycal, Xval, yval; score = rmsep, pars, nlv, verbose = false) 
u = findall(res.y1 .== minimum(res.y1))[1] ;
res[u, :]
mod = model(dkplsr; nlv = res.nlv[u], gamma = res.gamma[u])
fit!(mod, Xtrain, ytrain) 
pred = predict(mod, Xtest).pred 
@show rmsep(pred, ytest)


nlvdis = [15; 25] ; metric = [:mah] 
h = [1; 2; 4; 6; Inf]
k = [150; 200; 350; 500; 1000]  
nlv = 0:20 
pars = mpar(nlvdis = nlvdis, metric = metric, h = h, k = k)
length(pars[1])
mod = model(lwplsr)
res = gridscore(mod, Xcal, ycal, Xval, yval; score = rmsep, pars, nlv, verbose = true) 
group = string.(res.nlvdis, "-", res.h, "-", res.k) 
plotgrid(res.nlv, res.y1, group; xlabel ="Nb. LVs", ylabel = "RMSEP").f
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
mod = model(lwplsr; nlvdis = res.nlvdis[u], metric = res.metric[u], 
    h = res.h[u], k = res.k[u], nlv = res.nlv[u]) 
fit!(mod, Xtrain, ytrain)
pred = predict(mod, Xtest).pred 
rmsep(pred, ytest)


## A performant model 
mod = model(lwplsr; nlvdis = 15, metric = :mah, h = 2, k = 200, nlv = 15) ;
fit!(mod, Xtrain, ytrain) 
pred = predict(mod, Xtest).pred 
rmsep(pred, ytest)


nlv = [0:20, 5:20, 10:20]
nlvdis = [15; 25] ; metric = [:mah] 
h = [1; 2; 4] ; k = [150; 200; 350; 500; 1000]  
pars = mpar(nlv = nlv, nlvdis = nlvdis, 
    metric = metric, h = h, k = k) 
length(pars[1])
mod = model(lwplsravg) 
res = gridscore(mod, Xcal, ycal, Xval, yval; score = rmsep, pars, verbose = false) 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
mod = model(lwplsravg; nlvdis = res.nlvdis[u], metric = res.metric[u], h = res.h[u], 
    k = res.k[u], nlv = res.nlv[u]) ;
fit!(mod, Xtrain, ytrain)
pred = predict(mod, Xtest).pred ;
rmsep(pred, ytest)


## A performant model
nlvdis = 15 ; metric = :mah  
h = 2 ; k = 200 
nlv = 5:20
mod = model(lwplsravg; nlvdis, metric, h, k, nlv)
fit!(mod, Xtrain, ytrain) 
pred = predict(mod, Xtest).pred 
rmsep(pred, ytest)


mod1 = model(plskern; nlv = 30)
nlvdis = [0; 15; 25] ; metric = [:eucl, :mah] 
h = [1; 2; 4; 6; Inf]
k = [150; 200; 350; 500; 1000]  
nlv = 0:20 
pars = mpar(nlvdis = nlvdis, metric = metric, h = h, k = k)
length(pars[1])
mod2 = model(lwplsr)
mod = pip(mod1, mod2)
## Pipeline ==> only the last model is tuned
res = gridscore(mod, Xcal, ycal, Xval, yval; score = rmsep, pars, nlv, verbose = true) 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
mod2 = model(lwplsr; nlvdis = res.nlvdis[u], metric = res.metric[u], 
    h = res.h[u], k = res.k[u], nlv = res.nlv[u])
mod = pip(mod1, mod2)
fit!(mod, Xtrain, ytrain) 
pred = predict(mod, Xtest).pred 
rmsep(pred, ytest)


nlvdis = 0  ; metric = [:eucl] 
h = [1; 2; 4; 6; Inf] 
k = [1; collect(5:10:100)] 
pars = mpar(nlvdis = nlvdis, metric = metric, h = h, k = k) 
length(pars[1])
mod = model(knnr)
res = gridscore(mod, Xcal, ycal, Xval, yval; score = rmsep, pars, verbose = false) 
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]
mod = model(knnr; nlvdis = res.nlvdis[u], metric = res.metric[u], h = res.h[u], 
    k = res.k[u])
fit!(mod, Xtrain, ytrain) 
pred = predict(mod, Xtest).pred 
rmsep(pred, ytest)


n_trees = [100]
n_subfeatures = LinRange(5, p / 2, 5)
max_depth = [6; 10; 20; 2000]
pars = mpar(n_trees = n_trees, n_subfeatures = n_subfeatures, max_depth = max_depth)
length(pars[1])
res = gridscore(mod, Xcal, ycal, Xval, yval; score = rmsep, pars, verbose = false) 
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]
mod = model(rfr; n_trees = res.n_trees[u], n_subfeatures = res.n_subfeatures[u], 
    max_depth = res.max_depth[u])
fit!(mod, Xtrain, ytrain) 
pred = predict(mod, Xtest).pred 
@show rmsep(pred, ytest)
plotxy(pred, ytest; color = (:red, .5), bisect = true, xlabel = "Prediction", 
    ylabel = "Observed (Test)").f

