
using Jchemo, JchemoData
using JLD2, CairoMakie
using FreqTables


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/mnist20pct.jld2") 
@load db dat
@names dat


Xtrain = dat.Xtrain ;
ytrain = dat.ytrain ;
Xtest = dat.Xtest ;
ytest = dat.ytest ;
@head Xtrain
@head Xtest
tab(ytrain)
tab(ytest)
ntrain, p = size(Xtrain)
ntest = nro(Xtest)
ntot = ntrain + ntest ;
(ntot = ntot, ntrain, ntest)


Xtrain = Matrix(Xtrain) / 255 ;
Xtest = Matrix(Xtest) / 255 ;


plotsp(Xtrain, 1:p; nsamp = 1, xlabel = "Pixel", ylabel = "Grey level").f


nval = 1000
nval / ntrain # sampling proportion 
s = samprand(ntrain, nval)


Xcal = Xtrain[s.train, :] ;
ycal = ytrain[s.train] ;
Xval = Xtrain[s.test, :] ;
yval = ytrain[s.test] ;
ncal = ntrain - nval 
(ntot = ntot, ntrain, ncal, nval, ntest)


nlvdis = [10; 20] ; metric = [:mah]
h = [1; 2; 5; Inf] ; k = [200; 300; 500; 1000]  
nlv = 0:15
pars = mpar(nlvdis = nlvdis, metric = metric, h = h, k = k) 
length(pars[1])


model = lwplsrda()
res = gridscore(model, Xcal, ycal, Xval, yval; score = errp, pars, nlv)


group = string.("nvldis=", res.nlvdis, " h=", res.h, " k=", res.k) ;
plotgrid(res.nlv, res.y1, group; step = 2, xlabel = "Nb. LVs", ylabel = "ERRP-Val").f


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


model = lwplsrda(nlvdis = res.nlvdis[u], metric = res.metric[u], h = res.h[u], 
    k = res.k[u], nlv = res.nlv[u])
fit!(model, Xtrain, ytrain)
@head pred = predict(model, Xtest).pred


errp(pred, ytest)
merrp(pred, ytest)


cf = conf(pred, ytest) ;
@names cf
cf.cnt
cf.pct


plotconf(cf).f


plotconf(cf; cnt = false).f

