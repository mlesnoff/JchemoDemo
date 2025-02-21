
using Jchemo, JchemoData
using JLD2, CairoMakie


using JchemoData, JLD2, CairoMakie
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/cassav.jld2")
@load db dat
@names dat


X = dat.X
Y = dat.Y
ntot = nro(X)


@head X
@head Y


y = dat.Y.tbc
year = dat.Y.year


tab(year)


wlst = names(X)
wl = parse.(Float64, wlst)


plotsp(X, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


model1 = snv()
model2 = savgol(npoint = 11, deriv = 2, degree = 3)
model = pip(model1, model2)
fit!(model, X)
Xp = transf(model, X)


plotsp(Xp, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


s = year .<= 2012
Xtrain = X[s, :]
ytrain = y[s]
Xtest = rmrow(X, s)
ytest = rmrow(y, s)
ntrain = nro(Xtrain)
ntest = nro(Xtest)
ntot = ntrain + ntest
(ntot = ntot, ntrain, ntest)


plotsp(X, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


nval = Int(round(.30 * ntrain))
s = sampsys(ytrain, nval)
Xcal = Xtrain[s.train, :]
ycal = ytrain[s.train]
Xval = Xtrain[s.test, :]
yval = ytrain[s.test, :]
ncal = ntrain - nval
(ntot = ntot, ntrain, ntest, ncal, nval)


model = plskern()
nlv = 0:40
res = gridscore(model, Xcal, ycal, Xval, yval; score = rmsep, nlv)


plotgrid(res.nlv, res.y1; step = 5, xlabel = "Nb. LVs", ylabel = "RMSEP").f


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


model = plskern(nlv = res.nlv[u]) 
fit!(model, Xtrain, ytrain)
pred = predict(model, Xtest).pred 
rmsep(pred, ytest)
mse(pred, ytest)


plotxy(pred, ytest; color = (:red, .5), bisect = true, xlabel = "Prediction", 
  ylabel = "Observed (Test)").f


nlv = 15
metric = [:eucl, :mah]
h = [1; 2; 3.5; 6] ; k = [50; 100; 150; 200]  
pars = mpar(metric = metric, h = h, k = k) 
length(pars[1])


model1 = pcasvd()
model2 = lwmlr()
model = pip(model1, model2)
res = gridscore(model, Xcal, ycal, Xval, yval; score = rmsep, pars, verbose = false)


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


model1 = pcasvd(; nlv)
model2 = lwmlr(metric = res.metric[u], h = res.h[u], k = res.k[u])
model = pip(model1, model2)
fit!(model, Xtrain, ytrain)
pred = predict(model, Xtest).pred
@show rmsep(pred, ytest)
mse(pred, ytest)


plotxy(pred, ytest; color = (:red, .5), bisect = true, xlabel = "Prediction", 
    ylabel = "Observed (Test)").f


nlv = 15
metric = [:eucl, :mah]
h = [1; 2; 3.5; 6] ; k = [50; 100; 150; 200]  
pars = mpar(metric = metric, h = h, k = k) 
length(pars[1])


model1 = plskern()
model2 = lwmlr()
model = pip(model1, model2)
## Pipeline ==> only the last model is tuned
res = gridscore(model, Xcal, ycal, Xval, yval; score = rmsep, pars, verbose = false)


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


model1 = plskern(; nlv)
model2 = lwmlr(metric = res.metric[u], h = res.h[u], k = res.k[u])
model = pip(model1, model2)
fit!(model, Xtrain, ytrain)
pred = predict(model, Xtest).pred
@show rmsep(pred, ytest)
mse(pred, ytest)


plotxy(pred, ytest; color = (:red, .5), bisect = true, xlabel = "Prediction", 
    ylabel = "Observed (Test)").f


nlv = 15 ; gamma = .01
metric = [:eucl, :mah]
h = [1; 2; 3.5; 6] ; k = [50; 100; 150; 200]  
pars = mpar(metric = metric, h = h, k = k) 
length(pars[1])


model1 = dkplsr()
model2 = lwmlr()
model = pip(model1, model2)
res = gridscore(model, Xcal, ycal, Xval, yval; score = rmsep, pars, verbose = false)


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


model1 = dkplsr(; nlv, gamma)
model2 = lwmlr(metric = res.metric[u], h = res.h[u], k = res.k[u])
model = pip(model1, model2)
fit!(model, Xtrain, ytrain)
pred = predict(model, Xtest).pred
@show rmsep(pred, ytest)
mse(pred, ytest)


plotxy(pred, ytest; color = (:red, .5), bisect = true, xlabel = "Prediction", 
    ylabel = "Observed (Test)").f

