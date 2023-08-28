using JLD2, CairoMakie
using StatsBase, FreqTables 
using Jchemo, JchemoData

#-
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/forages2.jld2") 
@load db dat
pnames(dat)
  
#-
X = dat.X 
Y = dat.Y
ntot = nro(X)

#-
@head X 

#-
@head Y

#-
y = Y.typ
tab(y)

#-
freqtable(y, Y.test)

#-
wl = names(X)
wl_num = parse.(Float64, wl)

#-
## X is already preprocessed
plotsp(X, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

#-
s = Bool.(Y.test)
Xtrain = rmrow(X, s)
ytrain = rmrow(y, s)
Xtest = X[s, :]
ytest = y[s]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)

#-
## Train ==> Cal + Val
pct = .30
nval = Int64.(round(pct * ntrain))
ncal = ntrain - nval 
s = sample(1:ntrain, nval; replace = false)
Xcal = rmrow(Xtrain, s) 
ycal = rmrow(ytrain, s) 
Xval = Xtrain[s, :] 
yval = ytrain[s] 
(ntot = ntot, ntrain, ncal, nval, ntest)

#-
nlvdis = [15; 25] ; metric = ["mahal"]
h = [1; 2; 5] ; k = [100; 200; 300]
nlv = 0:15
pars = mpar(nlvdis = nlvdis, metric = metric, 
    h = h, k = k)

#-
length(pars[1])

#-
res = gridscorelv(Xcal, ycal, Xval, yval;
    score = err, fun = lwplsrda, nlv = nlv, pars = pars, 
    verbose = false)

#-
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]

#-
group = string.("metric=", res.metric, res.nlvdis, " h=", res.h, 
    " k=", res.k)

#-
plotgrid(res.nlv, res.y1, group; step = 2,
    xlabel = "Nb. LVs", ylabel = "ERR").f

#-
fm = lwplsrda(Xtrain, ytrain; nlvdis = res.nlvdis[u], 
    metric = res.metric[u], h = res.h[u], k = res.k[u], 
    nlv = res.nlv[u], verbose = false) ;
pred = Jchemo.predict(fm, Xtest).pred
err(pred, ytest)

#-
cf = confusion(pred, ytest) ;
cf.cnt

#-
cf.pct

#-
plotconf(cf).f
