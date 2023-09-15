
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
## Or:
#pct = .20
#nval = Int64(round(pct * ntrain))


s = sample(1:ntrain, nval; replace = false)


#res = sampks(Xtrain; k = nval)
#s = res.train


#res = sampdp(Xtrain; k = nval)
#s = res.train


#res = sampsys(ytrain; k = nval)
#s = res.train


Xcal = rmrow(Xtrain, s)
ycal = rmrow(ytrain, s)
Xval = Xtrain[s, :]
yval = ytrain[s, :]
ncal = ntrain - nval 
(ntot = ntot, ntrain, ntest, ncal, nval)


nlv = 0:50
res = gridscorelv(Xcal, ycal, Xval, yval; 
    score = rmsep, fun = plskern, nlv = nlv)


plotgrid(res.nlv, res.y1; step = 5,
    xlabel = "Nb. LVs", ylabel = "RMSEP").f


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


fm = plskern(Xtrain, ytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred


rmsep(pred, ytest)


plotxy(pred, ytest; color = (:red, .5),
    bisect = true, xlabel = "Prediction", 
    ylabel = "Observed (Test)").f


res_sel = selwold(res.nlv, res.y1; smooth = false, 
    alpha = .05, graph = true) ;
pnames(res)


res_sel.f       # plots


res_sel.opt     # nb. LVs correponding to the minimal error rate


res_sel.sel     # nb. LVs selected with the Wold's criterion


fm = plskern(Xtrain, ytrain; nlv = res_sel.sel) ;
pred = Jchemo.predict(fm, Xtest).pred
rmsep(pred, ytest)


nlv = 0:50
pars = mpar(nlv = nlv)
res = gridscore(Xcal, ycal, Xval, yval;  
    score = rmsep, fun = plskern, pars = pars) 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]

