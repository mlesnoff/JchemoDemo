
using Jchemo, JchemoData
using JLD2, CairoMakie


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/tecator.jld2") 
@load db dat
@names dat


X = dat.X
@head X


Y = dat.Y 
@head Y


typ = Y.typ
tab(typ)


wlst = names(X)
wl = parse.(Float64, wlst) 
#plotsp(X, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


model1 = snv()
model2 = savgol(npoint = 15, deriv = 2, degree = 3)
model = pip(model1, model2)
fit!(model, X)
@head Xp = transf(model, X) 
#plotsp(Xp, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


s = typ .== "train"
Xtrain = Xp[s, :] 
Ytrain = Y[s, :]
Xtest = rmrow(Xp, s)
Ytest = rmrow(Y, s)
ntrain = nro(Xtrain)
ntest = nro(Xtest)
ntot = ntrain + ntest
(ntot = ntot, ntrain, ntest)


namy = names(Y)[1:3]
j = 2  
nam = namy[j]    # work on the j-th y-variable
ytrain = Ytrain[:, nam]
ytest = Ytest[:, nam]


K = 3     # nb. folds (segments)
rep = 25  # nb. replications
segm = segmkf(ntrain, K; rep = rep)


#pct = .30
#m = Int(round(pct * ntrain))
#segm = segmts(ntrain, m; rep = 30)


i = 1  
segm[i]      # the K segments of replication 'i'


k = 1
segm[i][k]   # segment 'k' of replication 'i'


nlv = 0:20
model = plskern()
rescv = gridcv(model, Xtrain, ytrain; segm, score = rmsep, nlv)
@names rescv 
res = rescv.res
res_rep = rescv.res_rep


plotgrid(res.nlv, res.y1; step = 2, xlabel = "Nb. LVs", ylabel = "RMSEP-CV").f


f, ax = plotgrid(res.nlv, res.y1; step = 2, xlabel = "Nb. LVs", ylabel = "RMSEP-CV")
for i = 1:rep, j = 1:K
    zres = res_rep[res_rep.rep .== i .&& res_rep.segm .== j, :]
    lines!(ax, zres.nlv, zres.y1; color = (:grey, .2))
end
lines!(ax, res.nlv, res.y1; color = :red, linewidth = 1)
f


pars = mpar(scal = [false; true])
nlv = 0:20
model = plskern()
res = gridcv(model, Xtrain, ytrain; segm, score = rmsep, pars, nlv).res


plotgrid(res.nlv, res.y1, res.scal; step = 2, xlabel = "Nb. LVs", ylabel = "RMSEP-Val").f


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


model = plskern(nlv = res.nlv[u], scal = res.scal[u])
fit!(model, Xtrain, ytrain)
pred = predict(model, Xtest).pred


rmsep(pred, ytest)


plotxy(pred, ytest; size = (500, 400), color = (:red, .5), bisect = true, title = string("Test set - variable ", nam), 
    xlabel = "Prediction", ylabel = "Observed").f


pars = mpar(nlv = 0:20)
model = plskern()
gridcv(model, Xtrain, ytrain; segm, score = rmsep, pars).res


pars = mpar(nlv = 0:20, scal = [false; true])
model = plskern()
gridcv(model, Xtrain, ytrain; segm, score = rmsep, pars).res

