
using Jchemo, JchemoData
using JLD2, CairoMakie 
using DataFrames, Dates, FreqTables


## Importation
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/multifruit.jld2") 
@load db dat
@names dat


## Training and test sets
Xtrain = dat.Xtrain
Ytrain = dat.Ytrain
ytrain = Ytrain.dm   # dry matter (DM)
yclatrain = Ytrain.fruit
Xtest = dat.Xtest
Ytest = dat.Ytest
ytest = Ytest.dm     # dry matter (DM)
yclatest = Ytest.fruit ;


ntrain = nro(Xtrain)
ntest = nro(Xtest)
ntot = ntrain + ntest
(ntot = ntot, ntrain, ntest)


tab(yclatrain)


tab(yclatest)


## Wavelengths
wlst = names(Xtrain)
@head wl = parse.(Float64, wlst)
extrema(wl)


## Plotting some spectra
zX = copy(Xtrain)
#zX = copy(Xtest)
plotsp(zX, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance", nsamp = 100).f


## Training set ==> Cal/Val
nval = 500
s = sampsys(ytrain, nval)
Xcal = Xtrain[s.train, :]
ycal = ytrain[s.train]
Xval = Xtrain[s.test, :]
yval = ytrain[s.test]
ncal = ntrain - nval
(ntot = ntot, ntrain, ncal, nval, ntest)


## Importation
db = joinpath(path_jdat, "data/mango_anderson.jld2") 
@load db dat
@names dat


X = dat.X
Y = dat.Y 
y = Y.dm
set = Y.set
wlst_a = names(X)
wl_a = parse.(Float64, wlst_a)
year = Dates.year.(Date.(Y.date, dateformat"d/m/y")) ;


freqtable(set, year)


## Preprocessing
npoint = 9 ; degree = 2 ; deriv = 2
model = savgol(; npoint, degree, deriv)
fit!(model, X)
zXp = transf(model, X) / 2 ;


## Wavelength selection
s = wl_a .>= 735 .&& wl_a .<= 1047
wlp = wl_a[s]
Xp = DataFrame(zXp[:, s], string.(wlp)) ;


## Final data
Xtrain_ext = vcat(Xtrain, Xtest)
ytrain_ext = vcat(ytrain, ytest)
s = set .== "Val Ext" .&& year .>= 2018
Xtest_ext = Xp[s, :] 
ytest_ext = y[s] ;


## Plotting some spectra
zX = copy(Xtrain_ext)
#zX = copy(Xtest_ext)
plotsp(zX, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance", nsamp = 100).f


## Grid
nlv = 0:50
scal = true  # Passos & Mishra scaled the X-columns
pars = mpar(scal = scal)  # grid (except nlv)


## Grid-search
model = plskern()
res = gridscore(model, Xcal, ycal, Xval, yval; score = rmsep, pars = pars, nlv)
@head res  # first rows of the grid evaluation


plotgrid(res.nlv, res.y1; xlabel = "Nb. LVs", ylabel = "RMSEP_val").f


## Best model
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]


## Refitting the best model and predictions
model = plskern(nlv = res.nlv[u], scal = res.scal[u])
fit!(model, Xtrain, ytrain)
pred = predict(model, Xtest).pred
@head pred


## Generalization error
rmsep(pred, ytest)


plotxy(ytest, vec(pred); bisect = true, color = (:blue, .3), xlabel = "Observed DM", ylabel = "Predictions").f


## Refitting the best model and predictions
model = plskern(nlv = res.nlv[u], scal = res.scal[u])
fit!(model, Xtrain_ext, ytrain_ext)
pred = predict(model, Xtest_ext).pred
@head pred


## Generalization error
rmsep(pred, ytest_ext)


plotxy(ytest_ext, vec(pred); bisect = true, color = (:blue, .3), xlabel = "Observed DM", ylabel = "Predictions").f


## Grid
gamma = 10. .^(-1:-.1:-6)
nlv = 0:50
pars = mpar(gamma = gamma, scal = true)   # grid (except nlv)
length(pars[1])  # nb. parameter combinations (except nlv)


## Grid-search
model = dkplsr()
res = gridscore(model, Xcal, ycal, Xval, yval; score = rmsep, pars, nlv)
@head res  # first rows of the grid evaluation


group = round.(log.(10, res.gamma); digits = 1)
plotgrid(res.nlv, res.y1, group; xlabel = "Nb. LVs", ylabel = "RMSEP_val", title_leg = "log(gamma)").f


## Best model
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]


## Refitting the best model and predictions
model = dkplsr(gamma = res.gamma[u], nlv = res.nlv[u], scal = res.scal[u])
fit!(model, Xtrain, ytrain)
pred = predict(model, Xtest).pred
@head pred


## Generalization error
rmsep(pred, ytest)


plotxy(ytest, vec(pred); bisect = true, color = (:blue, .3), xlabel = "Observed DM", ylabel = "Predictions").f


## Refitting the best model and predictions
model = dkplsr(gamma = res.gamma[u], nlv = res.nlv[u], scal = res.scal[u])
fit!(model, Xtrain_ext, ytrain_ext)
pred = predict(model, Xtest_ext).pred
@head pred


## Generalization error
rmsep(pred, ytest_ext)


plotxy(ytest_ext, vec(pred); bisect = true, color = (:blue, .3), xlabel = "Observed DM", ylabel = "Predictions").f


## Grid
nlvdis = [5; 10; 15 ; 25] ; metric = [:mah]   
h = [1; 1.8; 2.5; 3.5; 5] ; k = [150; 300; 500; 600; 750; 1000] 
nlv = 0:20
scal = true
pars = mpar(nlvdis = nlvdis, metric = metric, h = h, k = k, scal = scal)  # grid (except nlv)
length(pars[1])  # nb. parameter combinations (except nlv)


## Grid-search
model = lwplsr()
res = gridscore(model, Xcal, ycal, Xval, yval; score = rmsep, pars, nlv)
@head res  # first rows of the grid evaluation


group = string.("nlvdis=", res.nlvdis, "metric=", res.metric, " h=", res.h, " k=", res.k)
plotgrid(res.nlv, res.y1, group; xlabel = "Nb. LVs", ylabel = "RMSEP_val").f


## Best model
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]


## Refitting the best model and predictions
model = lwplsr(nlvdis = res.nlvdis[u], metric = res.metric[u], h = res.h[u], k = res.k[u], 
    nlv = res.nlv[u], scal = res.scal[u])
fit!(model, Xtrain, ytrain)
pred = predict(model, Xtest).pred
@head pred


## Generalization error
rmsep(pred, ytest)


plotxy(ytest, vec(pred); bisect = true, color = (:blue, .3), xlabel = "Observed DM", ylabel = "Predictions").f


## Refitting the best model and predictions
model = lwplsr(nlvdis = res.nlvdis[u], metric = res.metric[u], h = res.h[u], k = res.k[u], 
    nlv = res.nlv[u], scal = res.scal[u])
fit!(model, Xtrain_ext, ytrain_ext)
pred = predict(model, Xtest_ext).pred
@head pred


## Generalization error
rmsep(pred, ytest_ext)


plotxy(ytest_ext, vec(pred); bisect = true, color = (:blue, .3), xlabel = "Observed DM", ylabel = "Predictions").f


## Grid
## In the actual version of Jchemo, for a pipeline, function gridscore 
## only optimizes the last model of the pipeline
nlv0 = 50
gamma = 1e5
##
nlvdis = [5; 10; 15; 25] ; metric = [:mah]
h = [1; 1.8; 2.5; 3.5; 5] ; k = [150; 300; 500; 600; 750; 1000] 
nlv = 0:min(nlv0, 20)
scal = true
pars = mpar(nlvdis = nlvdis, metric = metric, h = h, k = k, scal = scal)  # grid (except nlv)
length(pars[1])  # nb. parameter combinations (except nlv)


## Grid-search
model1 = dkplsr(; gamma, nlv = nlv0)
model2 = lwplsr()
model = pip(model1, model2)
res = gridscore(model, Xcal, ycal, Xval, yval; score = rmsep, pars, nlv)
@head res  # first rows of the grid evaluation


group = string.("nlvdis=", res.nlvdis, "metric=", res.metric, " h=", res.h, " k=", res.k)
plotgrid(res.nlv, res.y1, group; xlabel = "Nb. LVs", ylabel = "RMSEP_val").f


## Best model
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]


## Refitting the best model and predictions
model2 = lwplsr(nlvdis = res.nlvdis[u], metric = res.metric[u], h = res.h[u], 
    k = res.k[u], nlv = res.nlv[u], scal = res.scal[u], verbose = false)
model = pip(model1, model2) 
fit!(model, Xtrain, ytrain)
pred = predict(model, Xtest).pred
@head pred


## Generalization error
rmsep(pred, ytest)


plotxy(ytest, vec(pred); bisect = true, color = (:blue, .3), xlabel = "Observed DM", ylabel = "Predictions").f


## Refitting the best model and predictions
model1 = dkplsr(; gamma, nlv = nlv0)
model2 = lwplsr(nlvdis = res.nlvdis[u], metric = res.metric[u], h = res.h[u], 
    k = res.k[u], nlv = res.nlv[u], scal = res.scal[u], verbose = false)
model = pip(model1, model2) 
fit!(model, Xtrain_ext, ytrain_ext)
pred = predict(model, Xtest_ext).pred
@head pred


## Generalization error
rmsep(pred, ytest_ext)


plotxy(ytest_ext, vec(pred); bisect = true, color = (:blue, .3), xlabel = "Observed DM", ylabel = "Predictions").f

