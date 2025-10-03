
using Jchemo, JchemoData
using JLD2, CairoMakie
using FreqTables


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/forages2.jld2") 
@load db dat
@names dat


X = dat.X 
@head X


Y = dat.Y
@head Y


y = Y.typ   # response variable (class membership)
test = Y.test
tab(y)


freqtable(y, test)


wlst = names(X)
wl = parse.(Int, wlst)
#plotsp(X, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


s = Bool.(test)
Xtrain = rmrow(X, s)
ytrain = rmrow(y, s)
Xtest = X[s, :]
ytest = y[s]
ntot = nro(X)
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)


tab(ytrain)


tab(ytest)


K = 3     # nb. folds (segments)
rep = 25  # nb. replications
segm = segmkf(ntrain, K; rep = rep)


nlv = 0:30
model = plsrda()
rescv = gridcv(model, Xtrain, ytrain; segm, score = errp, nlv)
@names rescv 
res = rescv.res
res_rep = rescv.res_rep


plotgrid(res.nlv, res.y1; step = 2, xlabel = "Nb. LVs", ylabel = "ERRP-CV").f


f, ax = plotgrid(res.nlv, res.y1; step = 2, xlabel = "Nb. LVs", ylabel = "ERRP-CV")
for i = 1:rep, j = 1:K
    zres = res_rep[res_rep.rep .== i .&& res_rep.segm .== j, :]
    lines!(ax, zres.nlv, zres.y1; color = (:grey, .2))
end
lines!(ax, res.nlv, res.y1; color = :red, linewidth = 1)
f


prior = [:unif]  
pars = mpar(prior = prior)
nlv = 0:30
model = plsrda()
res = gridcv(model, Xtrain, ytrain; segm, score = merrp, pars, nlv).res


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


model = plsrda(nlv = res.nlv[u], prior = res.prior[u])
fit!(model, Xtrain, ytrain)
pred = predict(model, Xtest).pred


errp(pred, ytest)


merrp(pred, ytest)


cf = conf(pred, ytest)
@names cf


cf.cnt


cf.pct

