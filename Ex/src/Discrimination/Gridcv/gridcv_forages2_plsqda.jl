
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


K = 3     # nb. folds (segments)
rep = 25  # nb. replications
segm = segmkf(ntrain, K; rep = rep)


prior = [:unif]
alpha = [0, .25, .5, .75, 1]  # continuum parameter: from alpha = 0 (PLS-QDA) to alpha = 1 (PLS-LDA)
nlv = 1:20    # here must be > 0
pars = mpar(prior = prior, alpha = alpha)
model = plsqda()
res = gridcv(model, Xtrain, ytrain; segm, score = merrp, pars, nlv).res


plotgrid(res.nlv, res.y1, res.alpha; step = 2, xlabel = "Nb. LVs", ylabel = "ERRP-CV", leg_title = "Continuum").f


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


model = plsqda(prior = res.prior[u], alpha = res.alpha[u], nlv = res.nlv[u])
fit!(model, Xtrain, ytrain)
pred = predict(model, Xtest).pred


errp(pred, ytest)
merrp(pred, ytest)


cf = conf(pred, ytest) ;
@names cf
cf.cnt
cf.pct

