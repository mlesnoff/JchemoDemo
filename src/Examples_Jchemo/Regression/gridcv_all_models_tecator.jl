using JLD2, CairoMakie
using Jchemo, JchemoData
using Loess

mypath = dirname(dirname(pathof(JchemoData)))
db = joinpath(mypath, "data", "tecator.jld2") 
@load db dat
pnames(dat)

X = dat.X
Y = dat.Y 
wl = names(X)
wl_num = parse.(Float64, wl) 
ntot, p = size(X)
typ = Y.typ
namy = names(Y)[1:3]

plotsp(X, wl_num,
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 
plotsp(Xp, wl_num,
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

## Splitting Tot = Train + Test
## The model is tuned on Train, and
## the generalization error is estimated on Test.
## Here the splitting is provided by the dataset
## (variable "typ"), but the data could be splitted 
## a posteriori (e.g. random sampling with function 
## "mtest", systematic sampling, etc.) 
s = Y.typ .== "train"
Xtrain = Xp[s, :]
Ytrain = Y[s, namy]
Xtest = rmrow(Xp, s)
Ytest = rmrow(Y[:, namy], s)
ntrain = nro(Xtrain)
ntest = nro(Xtest)
ntot = ntrain + ntest
(ntot = ntot, ntrain, ntest)

## Work on the second y-variable  
j = 2
nam = namy[j]
ytrain = Ytrain[:, nam]
ytest = Ytest[:, nam]

######################### END

segm = segmkf(ntrain, 4; rep = 20)
nlv = 0:60 
res = gridcvlv(Xtrain, ytrain; segm = segm, 
    score = rmsep, fun = plskern, nlv = nlv).res ;
plotgrid(res.nlv, res.y1,
    xlabel ="Nb. LVs", ylabel = "RMSEP").f
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]
fm = plskern(Xtrain, ytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred ;
println(rmsep(pred, ytest))
zpred = vec(pred)
zfm = loess(zpred, ytest, span = 2 / 3) ;
z = Loess.predict(zfm, sort(zpred))
f, ax = plotxy(zpred, ytest;
    xlabel = "Predicted", ylabel = "Observed",
    resolution = (500, 400))
lines!(ax, sort(zpred), z; color = :red)
ablines!(ax, 0, 1)
f    

nlv = 50
res = aicplsr(Xtrain, ytrain; nlv = nlv)
pnames(res)
plotxy(res.delta.nlv, res.delta.aic).f

#### PLSR-AVG
segm = segmkf(ntrain, 4; rep = 20)
nlv = ["0:10"; "0:20"; "0:30"; "0:50"]
typf = ["unif"]
#typf = ["unif"; "aic"]
pars = mpar(nlv = nlv, typf = typf)
res = gridcv(Xtrain, ytrain; segm = segm,
    score = rmsep, fun = plsravg, pars = pars).res ;
u = findall(res.y1 .== minimum(res.y1))[1] ;
res[u, :]
fm = plsravg(Xtrain, ytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)

#### RR 
segm = segmkf(ntrain, 4; rep = 20)
lb = 10.0.^(-15:3) 
res = gridcvlb(Xtrain, ytrain; segm = segm,
    score = rmsep, fun = rr, lb = lb, verbose = true).res 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
fm = rr(Xtrain, ytrain; lb = res.lb[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
rmsep(pred, ytest)

#### RRR 
segm = segmkf(ntrain, 4; rep = 10)
nlv = 0:15
tau = [1e-5; collect(0.1:.1:1)]
pars = mpar(nlv = nlv, tau = tau)
res = gridcv(Xtrain, ytrain; segm = segm,
    score = rmsep, fun = rrr, pars = pars,
    verbose = true).res 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
group = string.("tau=", res.tau)
plotgrid(res.nlv, res.y1, group;
    xlabel ="Nb. LVs", ylabel = "RMSEP").f
fm = rrr(Xtrain, ytrain; nlv = res.nlv[u], 
    tau = res.tau[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
println(rmsep(pred, ytest))
zpred = vec(pred)
zfm = loess(zpred, ytest, span = 2 / 3) ;
z = Loess.predict(zfm, sort(zpred))
f, ax = plotxy(zpred, ytest;
    xlabel = "Predicted", ylabel = "Observed",
    resolution = (500, 400))
lines!(ax, sort(zpred), z; color = :red)
ablines!(ax, 0, 1)
f  
#plotsp(fm.P').f

#### COVSEL
nlv = 10
fm = Jchemo.covselr(Xtrain, ytrain; nlv = nlv,
    typ = "corr") ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)

rowsamp = .7 ; colsamp = 1 
fm = baggr(Xtrain, ytrain; rep = 100, 
    rowsamp = rowsamp, colsamp = colsamp, 
    fun = covselr, nlv = 10, typ = "corr") ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)

#### BAGMLR
rowsamp = .7 ; colsamp = .3 
@time fm = baggr(Xtrain, ytrain; rep = 100, 
    rowsamp = rowsamp, colsamp = colsamp, 
    fun = mlr) ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)

typw = "unif"
#typw = "imp"
rowsamp = .7 ; colsamp = .3 
sourcedir(path)
@time fm = Jchemo.baggmlr(Xtrain, ytrain; rep = 100, 
    rowsamp = rowsamp, colsamp = colsamp, typw = typw) ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)

rowsamp = .7 ; colsamp = 1
fm = baggr(Xtrain, ytrain; rep = 100, 
    fun = plskern, rowsamp = rowsamp, 
    colsamp = colsamp, nlv = 9) ;
pred = Jchemo.predict(fm, Xtest).pred ;
rmsep(pred, ytest)

#### KRR 
segm = segmkf(ntrain, 4; rep = 20)
lb = 10.0.^(-15:5) 
gamma = 10.0.^(-5:5) 
pars = mpar(gamma = gamma) 
length(pars[1])
res = gridcvlb(Xtrain, ytrain; segm = segm,
    score = rmsep, fun = krr, lb = lb, pars = pars,
    verbose = true).res
u = findall(res.y1 .== minimum(res.y1))[1] ;
res[u, :]
fm = krr(Xtrain, ytrain; lb = res.lb[u], gamma = res.gamma[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
println(rmsep(pred, ytest))
zpred = vec(pred)
zfm = loess(zpred, ytest, span = 2 / 3) ;
z = Loess.predict(zfm, sort(zpred))
f, ax = plotxy(zpred, ytest;
    xlabel = "Predicted", ylabel = "Observed",
    resolution = (500, 400))
lines!(ax, sort(zpred), z; color = :red)
ablines!(ax, 0, 1)
f  

#### KPLSR
segm = segmkf(ntrain, 4; rep = 20)
nlv = 0:50
gamma = 10.0.^(-5:5) 
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
fm = kplsr(Xtrain, ytrain; nlv = res.nlv[u], gamma = res.gamma[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)

#### DKPLSR
segm = segmkf(ntrain, 4; rep = 20)
nlv = 0:50
gamma = 10.0.^(-5:5) 
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
segm = segmkf(ntrain, 4; rep = 10)
nlvdis = [10 ; 15 ; 25] ; metric = ["mahal";] 
h = [1 ; 2 ; 6 ; Inf] ; k = [50 ; 100; 150]  
nlv = 0:20
pars = mpar(nlvdis = nlvdis, metric = metric, h = h, k = k) 
length(pars[1])
res = gridcvlv(Xtrain, ytrain; segm = segm,
    score = rmsep, fun = lwplsr, nlv = nlv, pars = pars, 
    verbose = true).res 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
group = string.("nvldis=", res.nlvdis, " h=", res.h, " k=", res.k)
plotgrid(res.nlv, res.y1, group;
    xlabel ="Nb. LVs", ylabel = "RMSEP").f
fm = lwplsr(Xtrain, ytrain; nlvdis = res.nlvdis[u],
    metric = res.metric[u], h = res.h[u], k = res.k[u], nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
println(rmsep(pred, ytest))
zpred = vec(pred)
zfm = loess(zpred, ytest, span = 2 / 3) ;
z = Loess.predict(zfm, sort(zpred))
f, ax = plotxy(zpred, ytest;
    xlabel = "Predicted", ylabel = "Observed",
    resolution = (500, 400))
lines!(ax, sort(zpred), z; color = :red)
ablines!(ax, 0, 1)
f    

#### LWPLSR-S
segm = segmkf(ntrain, 4; rep = 10)
nlv0 = [15; 20; 30; 40]
nlvdis = [5; 10; 15] ; metric = ["mahal";] 
h = [1; 2; 6] ; k = [50; 100; 150]  
nlv = 0:15
pars = mpar(nlv0 = nlv0, nlvdis = nlvdis, metric = metric, h = h, k = k) 
length(pars[1])
res = gridcvlv(Xtrain, ytrain; segm = segm,
    score = rmsep, fun = lwplsr_s, nlv = nlv, pars = pars, 
    verbose = true).res 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
group = string.("nvl0=", res.nlv0, "nvldis=", res.nlvdis, " h=", res.h, " k=", res.k)
plotgrid(res.nlv, res.y1, group;
    xlabel ="Nb. LVs", ylabel = "RMSEP").f
fm = lwplsr_s(Xtrain, ytrain; nlv0 = res.nlv0[u], nlvdis = res.nlvdis[u],
    metric = res.metric[u], h = res.h[u], k = res.k[u], nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
println(rmsep(pred, ytest))
zpred = vec(pred)
zfm = loess(zpred, ytest, span = 2 / 3) ;
z = Loess.predict(zfm, sort(zpred))
f, ax = plotxy(zpred, ytest;
    xlabel = "Predicted", ylabel = "Observed",
    resolution = (500, 400))
lines!(ax, sort(zpred), z; color = :red)
ablines!(ax, 0, 1)
f    

#### LWPLSR-DK
segm = segmkf(ntrain, 4; rep = 3)
gamma = 10.0.^(-5:5)
nlvdis = [10 ; 15 ; 25] ; metric = ["mahal";] 
h = [1 ; 2 ; 6 ; Inf] ; k = [150]  
nlv = 1:20 
pars = mpar(nlvdis = nlvdis, metric = metric, h = h, k = k,
    gamma = gamma) 
length(pars[1])
sourcedir(path)
res = gridcvlv(Xtrain, ytrain; segm = segm,
    score = rmsep, fun = Jchemo.lwplsr_dk, nlv = nlv, pars = pars, 
    verbose = true).res 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
fm = Jchemo.lwplsr_dk(Xtrain, ytrain; nlvdis = res.nlvdis[u],
    metric = res.metric[u], h = res.h[u], k = res.k[u], nlv = res.nlv[u],
    gamma = res.gamma[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
println(rmsep(pred, ytest))
zpred = vec(pred)
zfm = loess(zpred, ytest, span = 2 / 3) ;
z = Loess.predict(zfm, sort(zpred))
f, ax = plotxy(zpred, ytest;
    xlabel = "Predicted", ylabel = "Observed",
    resolution = (500, 400))
lines!(ax, sort(zpred), z; color = :red)
ablines!(ax, 0, 1)
f  

#### LWPLSR-SDK
segm = segmkf(ntrain, 4; rep = 1)
nlv0 = [20; 30; 50]
gamma0 = 10.0.^(-5:5)
nlvdis = [0; 10; 15] ; metric = ["mahal";] 
h = [1; 2; 6] ; k = [50; 100; 150]  
nlv = 0:20
pars = mpar(nlv0 = nlv0, gamma0 = gamma0, nlvdis = nlvdis, 
    metric = metric, h = h, k = k) 
length(pars[1])
sourcedir(path)
res = gridcvlv(Xtrain, ytrain; segm = segm,
    score = rmsep, fun = Jchemo.lwplsr_sdk, nlv = nlv, pars = pars, 
    verbose = true).res 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
group = string.("nvl0=", res.nlv0, "gamma0=", res.gamma0, 
    "nvldis=", res.nlvdis, " h=", res.h, " k=", res.k)
plotgrid(res.nlv, res.y1, group;
    xlabel ="Nb. LVs", ylabel = "RMSEP").f
fm = Jchemo.lwplsr_sdk(Xtrain, ytrain; nlv0 = res.nlv0[u], gamma0 = res.gamma0[u],
    nlvdis = res.nlvdis[u], metric = res.metric[u], h = res.h[u], 
    k = res.k[u], nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
println(rmsep(pred, ytest))
zpred = vec(pred)
zfm = loess(zpred, ytest, span = 2 / 3) ;
z = Loess.predict(zfm, sort(zpred))
f, ax = plotxy(zpred, ytest;
    xlabel = "Predicted", ylabel = "Observed",
    resolution = (500, 400))
lines!(ax, sort(zpred), z; color = :red)
ablines!(ax, 0, 1)
f    

#### LWPLSR-AVG
segm = segmkf(ntrain, 4; rep = 3)
nlvdis = [10 ; 15 ; 25] ; metric = ["mahal";] 
h = [1 ; 2 ; 6 ; Inf] ; k = [50 ; 100; 150]  
nlv = ["0:10"; "0:20"; "0:30"]
pars = mpar(nlvdis = nlvdis, metric = metric, h = h, 
    k = k, nlv = nlv) 
length(pars[1])
res = gridcv(Xtrain, ytrain; segm = segm,
    score = rmsep, fun = lwplsravg, pars = pars, 
    verbose = true).res 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
fm = lwplsravg(Xtrain, ytrain; nlvdis = res.nlvdis[u],
    metric = res.metric[u], h = res.h[u], k = res.k[u], nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
println(rmsep(pred, ytest))

#### LWBAGGMLR
rep = 100
nlvdis = 15 ; metric = "mahal"  
h = 2 ; k = 50 
rowsamp = .9 ; colsamp = .1 
sourcedir(path)
fm = Jchemo.lwbaggmlr(Xtrain, ytrain; nlvdis = nlvdis, metric = metric,
    h = h, k = k, rep = rep, rowsamp = rowsamp,
    colsamp = colsamp, verbose = false) ;
pred = Jchemo.predict_lwbaggmlr(fm, Xtest).pred
rmsep(pred, ytest)

#### CPLSR-AVG
ncla = 2 ; nlv_da = 3 ; nlv = "5:15"
fm = cplsravg(Xtrain, ytrain; 
    ncla = ncla, nlv_da = nlv_da, nlv = nlv) ;
@time res = Jchemo.predict(fm, Xtest) ;
rmsep(res.pred, ytest)

#### KNNR
segm = segmkf(ntrain, 4; rep = 10)
nlvdis = [15; 20]  ; metric = ["mahal"] 
h = [1; 2; 4; Inf] ;
k = [1; collect(5:10:100)] 
pars = mpar(nlvdis = nlvdis, metric = metric, h = h, k = k) 
length(pars[1])
res = gridcv(Xtrain, ytrain; segm = segm,
    score = rmsep, fun = knnr, pars = pars, 
    verbose = true).res ;
u = findall(res.y1 .== minimum(res.y1))[1] ;
res[u, :]
fm = knnr(Xtrain, ytrain; nlvdis = res.nlvdis[u], 
    metric = res.metric[u], h = res.h[u], k = res.k[u]) ;
pred = Jchemo.predict(fm, Xtest).pred ;
rmsep(pred, ytest)

#### SVMR
segm = segmkf(ntrain, 4; rep = 10)
cost = 10.0.^(-4:4)
epsilon = (.1, .25)
gamma = 10.0.^(-3:3)
pars = mpar(cost = cost, epsilon = epsilon, gamma = gamma)
length(pars[1])
res = gridcv(Xtrain, ytrain; segm = segm,
    score = rmsep, fun = svmr, pars = pars, 
    verbose = true).res ;
u = findall(res.y1 .== minimum(res.y1))[1] ;
res[u, :]
fm = svmr(Xtrain, ytrain; cost = res.cost[u], 
    epsilon = res.epsilon[u], gamma = res.gamma[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
rmsep(pred, ytest)

cost = 1000 ; epsilon = .25 ; gamma = 100 ;
fm = svmr(Xtrain, ytrain; cost = cost, epsilon = epsilon, 
    gamma = gamma) ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)

#### RFR 
@time fm = rfr_xgb(Xtrain, ytrain; rep = 100,
    subsample = .7, colsample_bynode = 1 / 3,
    max_depth = 2000, min_child_weight = 5) ;
pred = Jchemo.predict(fm, Xtest).pred ;
rmsep(pred, ytest)

fm = xgboostr(Xtrain, ytrain; rep = 150,
    eta = .1, subsample = .7,
    colsample_bytree = 1/3, colsample_bynode = 1/3,
    max_depth = 6, min_child_weight = 5,
    lambda = .3) ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)

fm = treer_xgb(Xtrain, ytrain;
    max_depth = 4,
    min_child_weight = 5) ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)

rowsamp = .7 ; colsamp = 1 
@time fm = baggr(Xtrain, ytrain; rep = 100, 
    rowsamp = rowsamp, colsamp = colsamp, 
    fun = treer_xgb,
    colsample_bynode = 1 / 3, 
    max_depth = 2000,
    min_child_weight = 5) ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)

res = baggr_oob(fm, Xtrain, ytrain; score = rmsep)
pnames(res)
res.scor
tab(res.k)

res = baggr_vi(fm, Xtrain, ytrain; score = rmsep)
res.imp
lines(vec(res.imp),
    axis = (xlabel = "Variable", ylabel = "Importance"))

fm = plskern(Xtrain, ytrain; nlv = 9) ;
lines(vip(fm),
    axis = (xlabel = "Variable", ylabel = "Importance"))

#### GBOOSTR
fm = Jchemo.gboostr(Xtrain, ytrain; rep = 500, 
    rowsamp = .7, colsamp = .5, nu = .95, 
    fun = "plskern", nlv = 1) ;
pred = Jchemo.predict_gboostr(fm, Xtest).pred ;
rmsep(pred, ytest)




























rowsamp = .7 ; colsamp = 1 
@time fm = Jchemo.baggr2(Xtrain, ytrain; rep = 100, 
    fun = treer_xgb,
    rowsamp = rowsamp, colsamp = colsamp, 
    colsample_bynode = 1 / 3, 
    max_depth = 2000,
    min_child_weight = 5) ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)

# 26 sec
n = 10^4 ; p = 700  
X = rand(n, p) 
y = rand(n) 
m = Int64(round(p * .33))
nrep = 100 ; rowsamp = .7 ; depth = 20
@time fm = build_forest(y, X, m, nrep, rowsamp, depth)

zn = 10^4 ; zp = 700  
zX = rand(zn, zp) 
zy = rand(zn) 
@time fm = rfr_xgb(zX, zy; rep = 100,
    subsample = .7, colsample_bynode = 1 / 3,
    max_depth = 20, min_child_weight = 5) ;

@time fm = xgboostr(zX, zy; rep = 100,
    subsample = .7, colsample_bynode = 1 / 3,
    max_depth = 20, min_child_weight = 5) ;

rowsamp = .7 ; colsamp = 1 
@time fm = baggr(zX, zy; rep = 100, 
    rowsamp = rowsamp, colsamp = colsamp, 
    fun = treer_xgb,
    colsample_bynode = 1 / 3, 
    max_depth = 20,
    min_child_weight = 5) ;






















sourcedir(path)
nlv_umap = 3 ; k_umap = 40 ; min_dist = .4 ;
metric = "eucl"
h = 2 ; k = 200 ;
nlv = "5:20"
@time fm = Jchemo.lwplsravg_umap(Xtrain, ytrain; nlv_umap, 
    k_umap = k_umap, min_dist = min_dist,
    metric = metric, h = h, k = k, nlv = nlv, verbose = true) ;
sourcedir(path)
@time pred = Jchemo.predict_lwplsravg_umap(fm, Xtest).pred ;
rmsep(pred, ytest)

# long
nlvdis = 15 ; h = 2 ; k = 200 ;
nlv = "0:30"
fm = lwplsravg(Xtrain, ytrain; nlvdis = nlvdis, metric = "mahal",
    h = h, k = k, nlv = nlv, wagg = "aic", verbose = false) ;
@time pred = Jchemo.predict(fm, Xtest).pred ;
rmsep(pred, ytest)

# long
nlvdis = 15 ; h = 2 ; k = 200 ;
nlv = "0:30"
fm = lwplsravg(Xtrain, ytrain; nlvdis = nlvdis, metric = "mahal",
    h = h, k = k, nlv = nlv, wagg = "fair", verbose = false) ;
@time pred = Jchemo.predict(fm, Xtest).pred ;
rmsep(pred, ytest)

sourcedir(path)
h = 2 ; k = 200 ;
nlv = "5:20"
fm = Jchemo.lwplsravg_weucl(Xtrain, ytrain;
    h = h, k = k, nlv = nlv, verbose = false) ;
pred = Jchemo.predict_lwplsravg_weucl(fm, Xtest).pred ;
rmsep(pred, ytest)

nlvdis = 0 ; h = 2 ; k = 200 ;
nlv = "5:20" 
fm = lwplsravg(Xtrain, ytrain; nlvdis = nlvdis, metric = "eucl",
    h = h, k = k, nlv = nlv, verbose = false) ;
pred = Jchemo.predict(fm, Xtest).pred ;
rmsep(pred, ytest)

nlvdis = 2:20
rep = length(nlvdis)
zpred = similar(Xtest, ntest, B)
@time for i = 1:B
    print("-", i)
    h = 2 ; k = 200 ;
    nlv = "5:20"
    fm = lwplsravg(Xtrain, ytrain; nlvdis = nlvdis[i], metric = "mahal",
        h = h, k = k, nlv = nlv, verbose = false) ;
    zpred[:, i] .= vec(Jchemo.predict(fm, Xtest).pred) ;
end
pred = mean(zpred, dims = 2)
rmsep(pred, ytest)

sourcedir(path)
nlvdis = 15 ; h = 2 ; k = 200 ;
nlv = "5:20"
fm = Jchemo.lwplsravg_dy(Xtrain, ytrain; nlvdis = nlvdis, metric = "mahal",
    h = h, k = k, nlv = nlv, theta = .5, verbose = false) ;
pred = Jchemo.predict_lwplsravg_dy(fm, Xtest).pred ;
rmsep(pred, ytest)

sourcedir(path)
nlvdis = [10 ; 15; 25] ; metric = ["mahal";] ; 
h = [1 ; 2; 5] ; k = [100; 200; 300] ;
nlv = ["0:10"; "5:10"; "0:20"; "5:20"] ;
fm = Jchemo.lwplsravg_auto(Xtrain, ytrain;
    nlvdis = nlvdis, metric = metric, h = h, k = k, nlv = nlv, verbose = true) ;
res = Jchemo.predict_lwplsravg_auto(fm, Xtest) ;
pred = res.pred ;
rmsep(pred, ytest)
res.sel
res.pred

sourcedir(path)
nlvdis = [10 ; 15; 25] ; metric = ["mahal";] ; 
h = [1; 2; 5] ; k = [100; 200; 300] ;
nlv = 25 ;
fm = Jchemo.lwplsr_auto(Xtrain, ytrain;
    nlvdis = nlvdis, metric = metric, h = h, k = k, nlv = nlv, verbose = true) ;
res = Jchemo.predict_lwplsr_auto(fm, Xtest) ;
pred = res.pred ;
rmsep(pred, ytest)
res.sel
res.pred

sourcedir(path)
nlvdis = 15 ; h = 2 ; k = 200 ;
rowsamp = .7 ; colsamp = .1 ;
fm = Jchemo.lwbaggmlr(Xtrain, ytrain; rep = 50, nlvdis = nlvdis, metric = "mahal",
    h = h, k = k, rowsamp = rowsamp, colsamp = colsamp, verbose = false) ;
@time res = Jchemo.predict_lwbaggmlr(fm, Xtest) ;
rmsep(res.pred, ytest)

sourcedir(path)
nlv0 = 50 ;
nlvdis = 15 ; metric = "mahal" ; h = 2 ; k = 200 ;
nlv = "5:20"
fm = Jchemo.lwplsravg_fast(Xtrain, ytrain; nlv0 = nlv0,
    nlvdis = nlvdis, metric = metric, h = h, k = k, nlv = nlv, verbose = false) ;
@time  res = Jchemo.predict_lwplsravg_fast(fm, Xtest) ;
rmsep(res.pred, ytest)

sourcedir(path)
nlvdis = 15 ; h = 2 ; k = 200 ;
nlv = "5:20"
fm = Jchemo.lwplsravg_fda(Xtrain, ytrain;
    nlvdis = nlvdis, metric = "mahal", h = h, k = k, nlv = nlv, verbose = false) ;
@time  res = Jchemo.predict_lwplsravg_fda(fm, Xtest) ;
rmsep(res.pred, ytest)

@time res = imp_chisq_r(Xtrain, ytrain) ;
#@time res = imp_chisq_r(Xtrain, ytrain; probs = [.20 ; .40 ; .60 ; .80]) ;
#@time res = imp_aov_r(Xtrain, ytrain) ;
#@time res = imp_aov_r(Xtrain, ytrain; probs = [.20 ; .40 ; .60 ; .80]) ;
#@time res = Jchemo.imp_aov_r2(Xtrain, ytrain) ;
imp = vec(res.imp) ;
lines(imp)

@time res = imp_perm_r(Xcal, ycal, Xval, yval; 
    rep = 5, fun = treer_xgb, max_depth = 20, min_child_weight = 5) ;
imp = vec(res.imp) ;
lines(imp)

@time res = imp_perm_r(Xcal, ycal, Xval, yval; 
    rep = 50, fun = plskern, nlv = 25) ;
imp = vec(res.imp) ;
lines(imp)
    
