
using JLD2, CairoMakie, StatsBase
using Jchemo, JchemoData
using FreqTables


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/challenge2018.jld2") 
@load db dat
pnames(dat)


X = dat.X 
Y = dat.Y
ntot, p = size(X)


@head X
@head Y


summ(Y)


y = Y.conc
typ = Y.typ
label = Y.label 
test = Y.test
tab(test)


wl = names(X)
wl_num = parse.(Float64, wl)


freqtable(string.(typ, "-", Y.label))


freqtable(typ, test)


plotsp(X, wl_num; nsamp = 30).f


f = 21 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) ;


s = Bool.(test)
Xtrain = rmrow(Xp, s)
ytrain = rmrow(y, s)
Xtest = Xp[s, :]
ytest = y[s]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)


nval = 300 
ncal = ntrain - nval 
s = sample(1:ntrain, nval; replace = false)
Xcal = rmrow(Xtrain, s) 
ycal = rmrow(ytrain, s) 
Xval = Xtrain[s, :] 
yval = ytrain[s] 
(ntot = ntot, ntrain, ntest, ncal, nval)


nlvdis = [15; 25] ; metric = ["mahal"] 
h = [1; 2; 4; 6; Inf]
k = [150; 200; 350; 500; 1000]  
nlv = 1:20 
pars = mpar(nlvdis = nlvdis, metric = metric, 
    h = h, k = k)


length(pars[1])


res = gridscorelv(Xcal, ycal, Xval, yval;
    score = rmsep, fun = lwplsr, nlv = nlv, pars = pars, 
    verbose = false)


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


group = string.("nlvdis=", res.nlvdis, ",h=", res.h, ",k=", res.k) 
plotgrid(res.nlv, res.y1, group; step = 2,
    xlabel ="Nb. LVs", ylabel = "RMSEP").f


fm = lwplsr(Xtrain, ytrain; nlvdis = res.nlvdis[u],
    metric = res.metric[u], h = res.h[u], k = res.k[u], 
    nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
rmsep(pred, ytest)


plotxy(pred, ytest; resolution = (500, 400),
    color = (:red, .5), bisect = true, 
    xlabel = "Prediction", ylabel = "Observed (Test)").f
