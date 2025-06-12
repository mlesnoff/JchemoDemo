
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
rep = 10  # nb. replications
segm = segmkf(ntrain, K; rep = rep)


lb = 10.0.^(-15:.1:3)
model = rr()
rescv = gridcv(model, Xtrain, ytrain; segm, score = rmsep, lb)
@names rescv 
res = rescv.res
res_rep = rescv.res_rep


loglb = round.(log.(10, res.lb), digits = 3)
plotgrid(loglb, res.y1; step = 2, xlabel ="lambda (log scale)", ylabel = "RMSEP-Val").f


f, ax = plotgrid(loglb, res.y1; step = 2, xlabel = "Nb. LVs", ylabel = "RMSEP-CV")
for i = 1:rep, j = 1:K
    zres = res_rep[res_rep.rep .== i .&& res_rep.segm .== j, :]
    lines!(ax, loglb, zres.y1; color = (:grey, .2))
end
lines!(ax, loglb, res.y1; color = :red, linewidth = 1)
f


pars = mpar(scal = [false; true])
lb = 10.0.^(-15:.1:3)
model = rr()
res = gridcv(model, Xtrain, ytrain; segm, score = rmsep, pars, lb).res


loglb = round.(log.(10, res.lb), digits = 3)
plotgrid(loglb, res.y1, res.scal; step = 2, xlabel ="lambda (log scale)", ylabel = "RMSEP-Val").f


u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]


model = rr(nlv = res.lb[u], scal = res.scal[u])
fit!(model, Xtrain, ytrain)
pred = predict(model, Xtest).pred


rmsep(pred, ytest)


plotxy(pred, ytest; size = (500, 400), color = (:red, .5), bisect = true, title = string("Test set - variable ", nam), 
    xlabel = "Prediction", ylabel = "Observed").f


pars = mpar(lb = 10.0.^(-15:.1:3))
model = rr()
gridcv(model, Xtrain, ytrain; segm, score = rmsep, pars).res


pars = mpar(lb = 10.0.^(-15:.1:3), scal = [false; true])
model = rr()
gridcv(model, Xtrain, ytrain; segm, score = rmsep, pars).res

