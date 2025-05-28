
using Jchemo, JchemoData
using JLD2, CairoMakie
using FreqTables


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/forages2.jld2") 
@load db dat
@names dat


X = dat.X 
Y = dat.Y
ntot = nro(X)
y = Y.typ ;
test = Y.test ;
tab(y)


freqtable(y, test)


wlst = names(X)
wl = parse.(Int, wlst) ;
#plotsp(X, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


s = Bool.(test) ;
Xtrain = rmrow(X, s) ;
ytrain = rmrow(y, s) ;
Xtest = X[s, :] ;
ytest = y[s] ;
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)


tab(ytrain)
tab(ytest)


pct = .3  # proportion of Train for Val
nval = round(Int, pct * ntrain)    
s = samprand(ntrain, nval)


Xcal = Xtrain[s.train, :] ;
ycal = ytrain[s.train] ;
Xval = Xtrain[s.test, :] ;
yval = ytrain[s.test] ;
ncal = ntrain - nval 
(ntot = ntot, ntrain, ncal, nval, ntest)


nlvdis = [15; 25] ; metric = [:mah]
h = [1; 2; 4; 6; Inf] ; k = [30; 50; 100]  
nlv = 0:15
pars = mpar(nlvdis = nlvdis, metric = metric, h = h, k = k) 
length(pars[1])


model = lwplsrda()
res = gridscore(model, Xcal, ycal, Xval, yval; score = errp, pars, nlv)    # could also use 'merrp' if classes in Val are highly unbalanced


group = string.("nvldis=", res.nlvdis, " h=", res.h, " k=", res.k)
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

