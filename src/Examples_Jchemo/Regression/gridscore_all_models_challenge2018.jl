using JLD2, CairoMakie, StatsBase
using Jchemo, JchemoData
using FreqTables, Loess

mypath = dirname(dirname(pathof(JchemoData)))
db = joinpath(mypath, "data", "challenge2018.jld2") 
@load db dat
pnames(dat)

X = dat.X 
Y = dat.Y
y = Y.conc
wl = names(X)
wl_num = parse.(Float64, wl)
ntot = nro(X)

summ(Y)
typ = Y.typ
label = Y.label 
test = Y.test

freqtable(string.(typ, "-", Y.label))
freqtable(typ, test)

f = 21 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) ;
plotsp(Xp, wl_num; nsamp = 20).f

## Splitting Tot = Train + Test
## The model is tuned on Train, and
## the generalization error is estimated on Test.
## Here the splitting is provided by the dataset
## (variable "typ"), but the data could be splitted 
## a posteriori (e.g. random sampling with function 
## "mtest", systematic sampling, etc.) 
s = Bool.(test)
Xtrain = rmrow(Xp, s)
ytrain = rmrow(y, s)
Xtest = Xp[s, :]
ytest = y[s]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)

## Splitting Train = Cal + Val
#pct = .20
#nval = Int64.(round(pct * ntrain))
nval = 300 
ncal = ntrain - nval 
s = sample(1:ntrain, nval; replace = false)
Xcal = rmrow(Xtrain, s) 
ycal = rmrow(ytrain, s) 
Xval = Xtrain[s, :] 
yval = ytrain[s] 
(ntot = ntot, ntrain, ntest, ncal, nval)

#### PLSR
nlv = 0:50
pars = mpar(scal = [false; true])
res = gridscorelv(Xcal, ycal, Xval, yval;
    score = rmsep, fun = plskern, nlv = nlv, 
    pars = pars) 
group = string.(res.scal) 
plotgrid(res.nlv, res.y1, group;
    xlabel ="Nb. LVs", ylabel = "RMSEP").f
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :] 
fm = plskern(Xtrain, ytrain; nlv = res.nlv[u],
    scal = res.scal[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
println(rmsep(pred, ytest))
zpred = vec(pred)
zfm = loess(zpred, ytest, span = 2 / 3) ;
z = Loess.predict(zfm, sort(zpred))
f, ax = plotxy(zpred, ytest; color = (:grey, .5),
    xlabel = "Predicted", ylabel = "Observed (Test)",
    resolution = (500, 400))
lines!(ax, sort(zpred), z; color = :red)
ablines!(ax, 0, 1)
f    

#### PLSRAVG 
nlv = ["0:30"; "0:50"; "0:70"; "0:100"]
typf = ["unif"; "aic"; "cv"; "stack"]
pars = mpar(nlv = nlv, typf = typf)
res = gridscore(Xcal, ycal, Xval, yval;
    score = rmsep, fun = plsravg, pars = pars,
    verbose = true) 
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :] 
fm = plsravg(Xtrain, ytrain; nlv = res.nlv[u], 
    typf = res.typf[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
println(rmsep(pred, ytest))

#### RR 
lb = 10.0.^(-15:.1:3) 
res = gridscorelb(Xcal, ycal, Xval, yval;
    score = rmsep, fun = rr, lb = lb) 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
zres = res[res.y1 .< 2, :]
zlb = round.(log.(10, zres.lb), digits = 3)
plotgrid(zlb, zres.y1; step = 2,
    xlabel ="Lambda", ylabel = "RMSEP").f
fm = rr(Xtrain, ytrain; lb = res.lb[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
rmsep(pred, ytest)

#### COVSELR
nlv = [10; 20; 30; 40]
typ = ["cov"; "cor"]
pars = mpar(nlv = nlv, typ = typ)
res = gridscore(Xcal, ycal, Xval, yval;
    score = rmsep, fun = covselr, pars = pars, 
    verbose = true)
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
fm = covselr(Xtrain, ytrain; nlv = res.nlv[u],
    typ = res.typ[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)

#### KRR
lb = 10.0.^(-15:3) 
gamma = 10.0.^(-3:5) 
pars = mpar(gamma = gamma) 
length(pars[1])
## To decrease the computation time 
## Sampling in Cal
m = 1000
s = sample(1:ncal, m; replace = false)
zXcal = Xcal[s, :]
zycal = ycal[s]
## End
res = gridscorelb(zXcal, zycal, Xval, yval;
    score = rmsep, fun = krr, lb = lb, pars = pars, 
    verbose = true)
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
fm = krr(Xtrain, ytrain; lb = res.lb[u], 
    gamma = res.gamma[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)

#### KPLSR
nlv = 0:100 
pars = mpar(gamma = 10.0.^(-3:5))
## To decrease the computation time 
## Sampling in Cal
m = 1000
s = sample(1:ncal, m; replace = false)
zXcal = Xcal[s, :]
zycal = ycal[s]
## End
res = gridscorelv(zXcal, zycal, Xval, yval;
    score = rmsep, fun = kplsr, nlv = nlv, pars = pars, 
    verbose = true) 
u = findall(res.y1 .== minimum(res.y1))[1] ;
res[u, :]
fm = kplsr(Xtrain, ytrain; nlv = res.nlv[u], 
    gamma = res.gamma[u]) ;
pred = Jchemo.predict(fm, Xtest).pred ;
println(rmsep(pred, ytest))
# End

#### DKPLSR
nlv = 0:100 
pars = mpar(gamma = 10.0.^(-3:5)) 
length(pars[1])
res = gridscorelv(Xcal, ycal, Xval, yval;
    score = rmsep, fun = dkplsr, nlv = nlv, pars = pars, 
    verbose = true) ;
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
fm = dkplsr(Xtrain, ytrain; nlv = res.nlv[u], 
    gamma = res.gamma[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)

#### LWPLSR 
nlvdis = [15; 25] ; metric = ["mahal"] 
h = [1; 2; 4; 6; Inf]
k = [150; 200; 350; 500; 1000]  
nlv = 1:20 
pars = mpar(nlvdis = nlvdis, metric = metric, 
    h = h, k = k)
length(pars[1])
res = gridscorelv(Xcal, ycal, Xval, yval;
    score = msep, fun = lwplsr, nlv = nlv, pars = pars, 
    verbose = true) 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
group = string.(res.nlvdis, "-", res.h, "-", res.k) 
plotgrid(res.nlv, res.y1, group;
    xlabel ="Nb. LVs", ylabel = "RMSEP").f
fm = lwplsr(Xtrain, ytrain; nlvdis = res.nlvdis[u],
    metric = res.metric[u], h = res.h[u], k = res.k[u], 
    nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
println(rmsep(pred, ytest))
plotxy(vec(pred), ytest; color = (:red, .5),
    bisect = true, 
    xlabel = "Prediction", ylabel = "Observed (Test)").f  

fm = lwplsr(Xtrain, ytrain; nlvdis = 15,
    metric = "mahal", h = 2, k = 200, nlv = 15) ;
@time pred = Jchemo.predict(fm, Xtest).pred ;
rmsep(pred, ytest)

#### LWPLSR-AVG 
nlv = ["0:20"; "5:20"; "0:30"; "5:30"] 
nlvdis = [15; 25] ; metric = ["mahal"] 
h = [1; 2.5; 5] ; k = [150; 200; 350; 500]  
pars = mpar(nlv = nlv, nlvdis = nlvdis, 
    metric = metric, h = h, k = k) 
length(pars[1])
res = gridscore(Xcal, ycal, Xval, yval;
    score = rmsep, fun = lwplsravg, pars = pars, 
    verbose = true) 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
fm = lwplsravg(Xtrain, ytrain; nlvdis = res.nlvdis[u],
    metric = res.metric[u], h = res.h[u], k = res.k[u], 
    nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)

nlvdis = 15 ; metric = "mahal"  
h = 2 ; k = 200 
nlv = "5:20" ; typf = "unif"
#nlv = "0:20" ; typf = "aic"   # ==> Best
fm = lwplsravg(Xtrain, ytrain; nlvdis = nlvdis, 
    metric = metric, h = h, k = k, nlv = nlv, 
    typf = typf) ;
@time pred = Jchemo.predict(fm, Xtest).pred ;
rmsep(pred, ytest)

#### LWPLSR-S
nlv0 = [20 ; 30 ; 50]
nlvdis = [15; 20] ; metric = ["eucl"; "mahal"] 
h = [1; 2; 4; 5] ; k = [150; 200; 350; 500]  
nlv = 1:20 
pars = mpar(nlv0 = nlv0, nlvdis = nlvdis, metric = metric, 
    h = h, k = k)
length(pars[1])
res = gridscorelv(Xcal, ycal, Xval, yval;
    score = msep, fun = lwplsr_s, nlv = nlv, pars = pars, 
    verbose = true) 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
group = string.(res.nlv0, "-", res.nlvdis, "-", res.h, "-", res.k) 
plotgrid(res.nlv, res.y1, group;
    xlabel ="Nb. LVs", ylabel = "RMSEP").f
fm = lwplsr_s(Xtrain, ytrain; nlv0 = res.nlv0[u], 
    nlvdis = res.nlvdis[u], metric = res.metric[u], h = res.h[u], 
    k = res.k[u], nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
println(rmsep(pred, ytest))

fm = lwplsr_s(Xtrain, ytrain; nlv0 = 30, nlvdis = 0,
           metric = "eucl", h = 2, k = 250, nlv = 15,
           scal = false) ;
@time pred = Jchemo.predict(fm, Xtest).pred ;
println(rmsep(pred, ytest))

#### CPLSR-AVG 
ncla = 2:5 ; nlv_da = 1:5
nlv = ["0:10"; "0:15"; "0:20"; 
    "5:15"; "5:20"]
pars = mpar(ncla = ncla, nlv_da = nlv_da, 
    nlv = nlv) 
length(pars[1])
res = gridscore(Xcal, ycal, Xval, yval;
    score = rmsep, fun = cplsravg, pars = pars, 
    verbose = true)
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
fm = cplsravg(Xtrain, ytrain; ncla = res.ncla[u],
    nlv_da = res.nlv_da[u], nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)

ncla = 20 ; nlv_da = 25 ; nlv = "5:20"
fm = cplsravg(Xtrain, ytrain; 
    ncla = ncla, nlv_da = nlv_da, 
    nlv = nlv) ;
@time res = Jchemo.predict(fm, Xtest) ;
rmsep(res.pred, ytest)

#### KNNR
nlvdis = [15; 20]  ; metric = ["mahal"] 
h = [1; 2; 4; 6; Inf] ;
k = [1; collect(5:10:100)] 
pars = mpar(nlvdis = nlvdis, metric = metric, 
    h = h, k = k) 
length(pars[1])
res = gridscore(Xcal, ycal, Xval, yval;
    score = rmsep, fun = knnr, pars = pars, 
    verbose = true) 
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]
fm = knnr(Xtrain, ytrain; nlvdis = res.nlvdis[u], 
    metric = res.metric[u], h = res.h[u], k = res.k[u]) ;
@time pred = Jchemo.predict(fm, Xtest).pred ;
rmsep(pred, ytest)

#### RFR
colsample_bynode = LinRange(.10, .50, 5)
max_depth = [10; 20; 2000]
pars = mpar(colsample_bynode = colsample_bynode, max_depth = max_depth)
length(pars[1])
res = gridscore(Xcal, ycal, Xval, yval;
    score = rmsep, fun = rfr_xgb, pars = pars, 
    verbose = true) ;
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]
fm = rfr_xgb(Xtrain, ytrain; rep = 100, 
    colsample_bynode = res.colsample_bynode[u], 
    max_depth = res.max_depth[u],
    min_child_weight = 5) ;
@time pred = Jchemo.predict(fm, Xtest).pred
rmsep(pred, ytest)

#### XGBOOSTR 
eta = [.1; .3]
colsample_bynode = LinRange(.10, .50, 3)
max_depth = [10; 50 ; 2000]
lambda = [0; .1; .3; .5; 1]
pars = mpar(eta = eta, colsample_bynode = colsample_bynode, 
    max_depth = max_depth, lambda = lambda)
length(pars[1])
res = gridscore(Xcal, ycal, Xval, yval;
    score = rmsep, fun = xgboostr, pars = pars, 
    verbose = true) 
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]
@time fm = xgboostr(Xtrain, ytrain; rep = 150, 
    eta = res.eta[u],
    colsample_bynode = res.colsample_bynode[u], 
    max_depth = res.max_depth[u],
    min_child_weight = 5, lambda = res.lambda[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
rmsep(pred, ytest)
