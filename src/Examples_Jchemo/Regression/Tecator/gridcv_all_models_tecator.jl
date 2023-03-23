using JLD2, CairoMakie
using Jchemo, JchemoData

mypath = dirname(dirname(pathof(JchemoData)))
db = joinpath(mypath, "data", "tecator.jld2") 
@load db dat
pnames(dat)

X = dat.X
Y = dat.Y 
wl = names(X)
wl_num = parse.(Float64, wl) 
ntot = nro(X)
typ = Y.typ
namy = names(Y)[1:3]

plotsp(X, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 
plotsp(Xp, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

s = typ .== "train"
Xtrain = Xp[s, :]
Ytrain = Y[s, namy]
Xtest = rmrow(Xp, s)
Ytest = rmrow(Y[:, namy], s)
ntrain = nro(Xtrain)
ntest = nro(Xtest)
ntot = ntrain + ntest
(ntot = ntot, ntrain, ntest)

j = 2  # y-variable
nam = namy[j]
ytrain = Ytrain[:, nam]
ytest = Ytest[:, nam]

segm = segmkf(ntrain, 4; rep = 20)
zsegm = segm[1:3] # Only 3 reps for slow models

#### PLSR
nlv = 0:40
res = gridcvlv(Xtrain, ytrain; segm = segm, 
    score = rmsep, fun = plskern, nlv = nlv).res ;
plotgrid(res.nlv, res.y1;
    xlabel ="Nb. LVs", ylabel = "RMSEP").f
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]
fm = plskern(Xtrain, ytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred ;
println(rmsep(pred, ytest))
plotxy(vec(pred), ytest; resolution = (500, 400),
    color = (:red, .5), bisect = true, 
    xlabel = "Prediction", ylabel = "Observed (Test)").f  

#### PLSR-AVG
nlv = ["0:10"; "0:20"; "0:30"; "0:50"]
typf = ["unif"]
#typf = ["unif"; "aic"; "stack"]
pars = mpar(nlv = nlv, typf = typf)
res = gridcv(Xtrain, ytrain; segm = segm,
    score = rmsep, fun = plsravg, pars = pars).res ;
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
fm = plsravg(Xtrain, ytrain; nlv = res.nlv[u],
    typf = res.typf[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)

#### RR 
lb = 10.0.^(-15:.1:3) 
res = gridcvlb(Xtrain, ytrain; segm = segm,
    score = rmsep, fun = rr, lb = lb, verbose = true).res 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
zres = res[res.y1 .< 3, :]
zlb = round.(log.(10, zres.lb), digits = 3)
plotgrid(zlb, zres.y1; step = .5,
    xlabel ="Lambda", ylabel = "RMSEP").f
fm = rr(Xtrain, ytrain; lb = res.lb[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
rmsep(pred, ytest)

#### COVSELR
nlv = [5; 10; 15; 20; 30]
pars = mpar(nlv = nlv)
res = gridcv(Xtrain, ytrain; segm = segm,
    score = rmsep, fun = covselr, pars = pars, 
    verbose = true).res ;
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
fm = covselr(Xtrain, ytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)

#### KRR 
lb = 10.0.^(-15:5) 
gamma = 10.0.^(-3:5) 
pars = mpar(gamma = gamma) 
length(pars[1])
res = gridcvlb(Xtrain, ytrain; segm = segm,
    score = rmsep, fun = krr, lb = lb, pars = pars,
    verbose = true).res
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]
fm = krr(Xtrain, ytrain; lb = res.lb[u], 
    gamma = res.gamma[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
println(rmsep(pred, ytest))
plotxy(vec(pred), ytest; resolution = (500, 400),
    color = (:red, .5), bisect = true, 
    xlabel = "Prediction", ylabel = "Observed (Test)").f  

#### KPLSR
nlv = 0:50
gamma = 10.0.^(-3:5) 
pars = mpar(gamma = gamma) 
length(pars[1])
res = gridcvlv(Xtrain, ytrain; segm = segm,
    score = rmsep, fun = kplsr, nlv = nlv, pars = pars,
    verbose = true).res
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
zres = res[res.y1 .< 20, :]
group = string.("gamma=", round.(log.(10, zres.gamma)))
plotgrid(zres.nlv, zres.y1, group;
    xlabel ="Nb. LVs", ylabel = "RMSEP").f
fm = kplsr(Xtrain, ytrain; nlv = res.nlv[u], 
    gamma = res.gamma[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)

#### DKPLSR
nlv = 0:50
gamma = 10.0.^(-3:5) 
pars = mpar(gamma = gamma) 
length(pars[1])
res = gridcvlv(Xtrain, ytrain; segm = segm,
    score = rmsep, fun = dkplsr, nlv = nlv, pars = pars,
    verbose = true).res
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
zres = res[res.y1 .< 20, :]
group = string.("gamma=", round.(log.(10, zres.gamma)))
plotgrid(zres.nlv, zres.y1, group;
    xlabel ="Nb. LVs", ylabel = "RMSEP").f
fm = dkplsr(Xtrain, ytrain; nlv = res.nlv[u], 
    gamma = res.gamma[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)

#### LWPLSR 
nlvdis = [10; 15; 25] ; metric = ["mahal"] 
h = [1; 2; 6; Inf] ; k = [50; 100; 150]  
nlv = 0:20
pars = mpar(nlvdis = nlvdis, metric = metric, 
    h = h, k = k) 
length(pars[1])
res = gridcvlv(Xtrain, ytrain; segm = segm,
    score = rmsep, fun = lwplsr, nlv = nlv, 
    pars = pars, verbose = true).res 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
group = string.("nvldis=", res.nlvdis, " h=", res.h, 
    " k=", res.k)
plotgrid(res.nlv, res.y1, group;
    xlabel ="Nb. LVs", ylabel = "RMSEP").f
fm = lwplsr(Xtrain, ytrain; nlvdis = res.nlvdis[u],
    metric = res.metric[u], h = res.h[u], k = res.k[u], 
    nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
println(rmsep(pred, ytest))
plotxy(vec(pred), ytest; resolution = (500, 400),
    color = (:red, .5), bisect = true, 
    xlabel = "Prediction", ylabel = "Observed (Test)").f  

#### LWPLSR-S
nlv0 = [15; 20; 30; 40]
nlvdis = [5; 10; 15] ; metric = ["mahal"] 
h = [1; 2; 6] ; k = [50; 100; 150]  
nlv = 0:15
pars = mpar(nlv0 = nlv0, nlvdis = nlvdis, 
    metric = metric, h = h, k = k) 
length(pars[1])
res = gridcvlv(Xtrain, ytrain; segm = segm,
    score = rmsep, fun = lwplsr_s, nlv = nlv, 
    pars = pars, verbose = true).res 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
group = string.("nvl0=", res.nlv0, "nvldis=", res.nlvdis, 
    " h=", res.h, " k=", res.k)
plotgrid(res.nlv, res.y1, group;
    xlabel ="Nb. LVs", ylabel = "RMSEP").f
fm = lwplsr_s(Xtrain, ytrain; nlv0 = res.nlv0[u], 
    nlvdis = res.nlvdis[u], metric = res.metric[u], h = res.h[u], 
    k = res.k[u], nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
println(rmsep(pred, ytest))
plotxy(vec(pred), ytest; resolution = (500, 400),
    color = (:red, .5), bisect = true, 
    xlabel = "Prediction", ylabel = "Observed (Test)").f  

#### LWPLSR-AVG
nlvdis = [10; 15; 25] ; metric = ["mahal"] 
h = [1; 2; 6; Inf] ; k = [50; 100; 150]  
nlv = ["0:10"; "0:20"; "0:30"]
pars = mpar(nlvdis = nlvdis, metric = metric, h = h, 
    k = k, nlv = nlv) 
length(pars[1])
res = gridcv(Xtrain, ytrain; segm = zsegm,
    score = rmsep, fun = lwplsravg, pars = pars, 
    verbose = true).res 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
fm = lwplsravg(Xtrain, ytrain; nlvdis = res.nlvdis[u],
    metric = res.metric[u], h = res.h[u], k = res.k[u], 
    nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)

#### CPLSR-AVG
ncla = 2:5 ; nlv_da = 1:5
nlv = ["0:10"; "0:15"; "0:20"; 
    "5:15"; "5:20"]
pars = mpar(ncla = ncla, nlv_da = nlv_da, 
    nlv = nlv) 
length(pars[1])
res = gridcv(Xtrain, ytrain; segm = segm,
    score = rmsep, fun = cplsravg, pars = pars, 
    verbose = true).res 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
fm = cplsravg(Xtrain, ytrain; ncla = res.ncla[u],
    nlv_da = res.nlv_da[u], nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)

#### KNNR
nlvdis = [15; 20]  ; metric = ["eucl"; "mahal"] 
h = [1; 2; 4; Inf] ;
k = [1; collect(5:10:100)] 
pars = mpar(nlvdis = nlvdis, metric = metric, 
    h = h, k = k) 
length(pars[1])
res = gridcv(Xtrain, ytrain; segm = segm,
    score = rmsep, fun = knnr, pars = pars, 
    verbose = true).res ;
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]
fm = knnr(Xtrain, ytrain; nlvdis = res.nlvdis[u], 
    metric = res.metric[u], h = res.h[u], k = res.k[u]) ;
pred = Jchemo.predict(fm, Xtest).pred ;
rmsep(pred, ytest)

#### SVMR
cost = 10.0.^(-4:4)
epsilon = (.1, .25)
gamma = 10.0.^(-3:3)
pars = mpar(cost = cost, epsilon = epsilon, gamma = gamma)
length(pars[1])
res = gridcv(Xtrain, ytrain; segm = zsegm,
    score = rmsep, fun = svmr, pars = pars, 
    verbose = true).res ;
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]
fm = svmr(Xtrain, ytrain; cost = res.cost[u], 
    epsilon = res.epsilon[u], gamma = res.gamma[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
rmsep(pred, ytest)

#### RFR 
colsample_bynode = LinRange(.10, .50, 5)
max_depth = [6; 10; 20; 2000]
pars = mpar(colsample_bynode = colsample_bynode, 
    max_depth = max_depth)
length(pars[1])
res = gridcv(Xtrain, ytrain; segm = zsegm,
    score = rmsep, fun = rfr_xgb, pars = pars, 
    verbose = true).res ;
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]
fm = rfr_xgb(Xtrain, ytrain; rep = 50, 
    colsample_bynode = res.colsample_bynode[u], 
    max_depth = res.max_depth[u],
    min_child_weight = 5) ;
pred = Jchemo.predict(fm, Xtest).pred
rmsep(pred, ytest)

#### XGBOOSTR 
eta = [.1; .3]
colsample_bynode = LinRange(.10, .50, 5)
max_depth = [6; 10; 50; 2000]
lambda = [0; .1; .3; .5; 1]
pars = mpar(eta = eta, colsample_bynode = colsample_bynode, 
    max_depth = max_depth, lambda = lambda)
length(pars[1])
res = gridcv(Xtrain, ytrain; segm = zsegm,
    score = rmsep, fun = xgboostr, pars = pars, 
    verbose = true).res ;
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]
fm = xgboostr(Xtrain, ytrain; rep = 150,
    eta = res.eta[u], 
    colsample_bynode = res.colsample_bynode[u], 
    max_depth = res.max_depth[u],
    min_child_weight = 5, lambda = res.lambda[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
rmsep(pred, ytest)
