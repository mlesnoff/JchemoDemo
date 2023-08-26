using JLD2, CairoMakie, StatsBase
using Jchemo, JchemoData
using FreqTables

#-
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/challenge2018.jld2") 
@load db dat
pnames(dat)

#-
X = dat.X 
Y = dat.Y
ntot, p = size(X)

#-
@head X

#-
@head Y

#-
summ(Y)

#-
y = Y.conc
typ = Y.typ
label = Y.label 
test = Y.test
tab(test)

#-
wl = names(X)
wl_num = parse.(Float64, wl)

#-
freqtable(string.(typ, "-", Y.label))

#-
freqtable(typ, test)

#-
plotsp(X, wl_num; nsamp = 30).f

#-
f = 21 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) ;

plotsp(Xp, wl_num; nsamp = 30).f

#-
## Split Tot = Train + Test
## The model is tuned on Train, and
## the generalization error is estimated on Test.
## Here the split of Tot is provided by the dataset
## (= variable 'test'), but Tot could be split 
## a posteriori (e.g. random sampling, systematic 
## sampling, etc.) 
s = Bool.(test)
Xtrain = rmrow(Xp, s)
ytrain = rmrow(y, s)
Xtest = Xp[s, :]
ytest = y[s]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)

#-
## Train = Cal + Val
nval = 300 
ncal = ntrain - nval 
s = sample(1:ntrain, nval; replace = false)
Xcal = rmrow(Xtrain, s) 
ycal = rmrow(ytrain, s) 
Xval = Xtrain[s, :] 
yval = ytrain[s] 
(ntot = ntot, ntrain, ntest, ncal, nval)

#-
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
plotxy(vec(pred), ytest; resolution = (500, 400),
    color = (:red, .5), bisect = true, 
    xlabel = "Prediction", ylabel = "Observed (Test)").f  

#-
#### PLSRAVG 
nlv = ["0:30"; "0:50"; "0:70"; "0:100"]
typf = ["unif"]
#typf = ["unif"; "aic"; "cv"; "stack"]
pars = mpar(nlv = nlv, typf = typf)
length(pars[1])
res = gridscore(Xcal, ycal, Xval, yval;
    score = rmsep, fun = plsravg, pars = pars,
    verbose = true) 
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :] 
fm = plsravg(Xtrain, ytrain; nlv = res.nlv[u], 
    typf = res.typf[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
println(rmsep(pred, ytest))

#-
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

#-
#### COVSELR
nlv = [10; 20; 30; 40]
pars = mpar(nlv = nlv)
res = gridscore(Xcal, ycal, Xval, yval;
    score = rmsep, fun = covselr, pars = pars, 
    verbose = true)
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
fm = covselr(Xtrain, ytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)

#-
#### KRR
lb = 10.0.^(-15:3) 
gamma = 10.0.^(-3:5) 
pars = mpar(gamma = gamma) 
length(pars[1])
## To decrease the computation time, 
## sampling in Cal
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
println(rmsep(pred, ytest))
plotxy(vec(pred), ytest; resolution = (500, 400),
    color = (:red, .5), bisect = true, 
    xlabel = "Prediction", ylabel = "Observed (Test)").f  

#-
#### KPLSR
nlv = 0:100 
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
res = gridscorelv(zXcal, zycal, Xval, yval;
    score = rmsep, fun = kplsr, nlv = nlv, pars = pars, 
    verbose = true) 
u = findall(res.y1 .== minimum(res.y1))[1] ;
res[u, :]
fm = kplsr(Xtrain, ytrain; nlv = res.nlv[u], 
    gamma = res.gamma[u]) ;
pred = Jchemo.predict(fm, Xtest).pred ;
rmsep(pred, ytest)

#-
#### DKPLSR
nlv = 0:100 
gamma = 10.0.^(-3:5)
pars = mpar(gamma = gamma)
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

#-
#### LWPLSR 
nlvdis = [15; 25] ; metric = ["mahal"] 
h = [1; 2; 4; 6; Inf]
k = [150; 200; 350; 500; 1000]  
nlv = 1:20 
pars = mpar(nlvdis = nlvdis, metric = metric, 
    h = h, k = k)
length(pars[1])
res = gridscorelv(Xcal, ycal, Xval, yval;
    score = rmsep, fun = lwplsr, nlv = nlv, pars = pars, 
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
plotxy(vec(pred), ytest; resolution = (500, 400),
    color = (:red, .5), bisect = true, 
    xlabel = "Prediction", ylabel = "Observed (Test)").f  

#-
## A performant model 
fm = lwplsr(Xtrain, ytrain; nlvdis = 15,
    metric = "mahal", h = 2, k = 200, nlv = 15) ;
@time pred = Jchemo.predict(fm, Xtest).pred ;
rmsep(pred, ytest)

#-
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

#-
## A performant model
nlvdis = 15 ; metric = "mahal"  
h = 2 ; k = 200 
nlv = "5:20" ; typf = "unif"
#nlv = "0:20" ; typf = "aic"   # ==> Best
fm = lwplsravg(Xtrain, ytrain; nlvdis = nlvdis, 
    metric = metric, h = h, k = k, nlv = nlv, 
    typf = typf) ;
@time pred = Jchemo.predict(fm, Xtest).pred ;
rmsep(pred, ytest)

#-
#### LWPLSR-S
nlv0 = [20 ; 30 ; 50]
metric = ["eucl"; "mahal"] 
h = [1; 2; 4; 5] ; k = [150; 200; 350; 500]  
nlv = 1:20 
pars = mpar(nlv0 = nlv0, metric = metric, h = h, 
    k = k)
length(pars[1])
res = gridscorelv(Xcal, ycal, Xval, yval;
    score = msep, fun = lwplsr_s, nlv = nlv, pars = pars, 
    verbose = true) 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
group = string.(res.nlv0, "-", res.metric, "-", res.h, "-", res.k) 
plotgrid(res.nlv, res.y1, group;
    xlabel ="Nb. LVs", ylabel = "RMSEP").f
fm = lwplsr_s(Xtrain, ytrain; nlv0 = res.nlv0[u], 
    metric = res.metric[u], h = res.h[u], 
    k = res.k[u], nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)

#-
## Working in a KPLS score space
nlv0 = [20 ; 30 ; 50]
metric = ["eucl"; "mahal"] 
reduc = ["dkpls"] ; gamma = 10.0.^(-3:3) 
h = [1; 2] ; k = [150; 200; 350]  
nlv = 1:20 
psamp = [.30]
pars = mpar(nlv0 = nlv0, metric = metric, 
    reduc = reduc, gamma = gamma, h = h, k = k,
    psamp = psamp)
length(pars[1])
res = gridscorelv(Xcal, ycal, Xval, yval;
    score = msep, fun = lwplsr_s, nlv = nlv, pars = pars, 
    verbose = true) 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
fm = lwplsr_s(Xtrain, ytrain; nlv0 = res.nlv0[u],
    reduc = res.reduc[u], gamma = res.gamma[u], 
    metric = res.metric[u], h = res.h[u], 
    k = res.k[u], nlv = res.nlv[u],
    psamp = res.psamp[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)

#-
#### CPLSR-AVG 
ncla = 5:10 ; nlv_da = 1:20
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

#-
fm = cplsravg(Xtrain, ytrain; ncla = 10,
    nlv_da = 14, nlv = "5:20") ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)


#-
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

#-
#### RFR
n_trees = [50]
n_subfeatures = LinRange(5, p / 2, 5)
max_depth = [6; 10; 20; 2000]
pars = mpar(n_trees = n_trees, n_subfeatures = n_subfeatures, 
    max_depth = max_depth)
length(pars[1])
res = gridscore(Xcal, ycal, Xval, yval;
    score = rmsep, fun = rfr_dt, pars = pars, 
    verbose = true) ;
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]
fm = rfr_dt(Xtrain, ytrain; n_trees = res.n_trees[u], 
    n_subfeatures = res.n_subfeatures[u], 
    max_depth = res.max_depth[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
rmsep(pred, ytest)

