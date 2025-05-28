
using Jchemo, JchemoData
using JLD2, CairoMakie


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/tecator.jld2") 
@load db dat
@names dat


X = dat.X
Y = dat.Y 
typ = Y.typ ;
tab(typ)


wlst = names(X) ;
wl = parse.(Float64, wlst) 
#plotsp(X, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


model1 = snv()
model2 = savgol(npoint = 15, deriv = 2, degree = 3)
model = pip(model1, model2)
fit!(model, X)
@head Xp = transf(model, X) 
#plotsp(Xp, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


s = typ .== "train" ;
Xtrain = Xp[s, :] ; 
Ytrain = Y[s, :] ;
Xtest = rmrow(Xp, s) ;
Ytest = rmrow(Y, s) ;
ntrain = nro(Xtrain)
ntest = nro(Xtest)
ntot = ntrain + ntest
(ntot = ntot, ntrain, ntest)


namy = names(Y)[1:3]
j = 2  
nam = namy[j]    # work on the j-th y-variable
ytrain = Ytrain[:, nam] ;
ytest = Ytest[:, nam] ;


pct = .3  # proportion of Train for Val
nval = round(Int, pct * ntrain)    
s = samprand(ntrain, nval)


Xcal = Xtrain[s.train, :] ;
ycal = ytrain[s.train] ;
Xval = Xtrain[s.test, :] ;
yval = ytrain[s.test] ;
ncal = ntrain - nval 
(ntot = ntot, ntrain, ncal, nval, ntest)


nlvdis = [5; 10; 15] ; metric = [:mah]   # here only Mahalanobis distance is considered
h = [1; 2; 4; 6; Inf] ; k = [30; 50; 100]  
nlv = 0:15
pars = mpar(nlvdis = nlvdis, metric = metric, h = h, k = k) 
length(pars[1])


model = lwplsr()
res = gridscore(model, Xcal, ycal, Xval, yval; score = rmsep, pars, nlv)


group = string.("nvldis=", res.nlvdis, " h=", res.h, " k=", res.k)
plotgrid(res.nlv, res.y1, group; step = 2, xlabel ="Nb. LVs", ylabel = "RMSEP-Val").f


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


model = lwplsr(nlvdis = res.nlvdis[u], metric = res.metric[u], h = res.h[u], 
    k = res.k[u], nlv = res.nlv[u])
fit!(model, Xtrain, ytrain)
pred = predict(model, Xtest).pred


rmsep(pred, ytest)


plotxy(pred, ytest; size = (500, 400), color = (:red, .5), bisect = true, title = string("Test set - variable ", nam), 
    xlabel = "Prediction", ylabel = "Observed").f

