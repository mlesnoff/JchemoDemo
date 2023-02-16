using JLD2, CairoMakie
using Jchemo, JchemoData
using Loess

mypath = dirname(dirname(pathof(JchemoData)))
db = joinpath(mypath, "data", "tecator.jld2") 
@load db dat
pnames(dat)

X = dat.X
Y = dat.Y 
wl = names(X)
wl_num = parse.(Float64, wl) 
namy = names(Y)[1:3]
ntot, p = size(X)
y = Y.fat
typ = Y.typ

plotsp(X, wl_num,
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 
plotsp(Xp, wl_num,
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

## Train vs. Test sets
j = 2
nam = namy[j]
s = Y.typ .== "train"
Xtrain = Xp[s, :]
ytrain = Y[s, nam]
Xtest = rmrow(Xp, s)
ytest = rmrow(Y[:, nam], s)
ntrain = nro(Xtrain)
ntest = nro(Xtest)
ntot = ntrain + ntest
(ntot = ntot, ntrain, ntest)

######################### END

## Test-set validation
m = round(.30 * ntrain)
segm = segmts(ntrain, m; rep = 30)
# K-fold CV
#K = 3 ; segm = segmkf(ntrain, K; rep = 10)

segm[1]

nlv = 0:20
rescv = gridcvlv(Xtrain, ytrain; segm = segm, 
    score = rmsep, fun = plskern, nlv = nlv, 
    verbose = true) ;
pnames(rescv)
res = rescv.res
res_rep = rescv.res_rep

u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
plotgrid(res.nlv, res.y1; step = 2,
    xlabel = "Nb. LVs", ylabel = "RMSEP").f

fm = plskern(Xtrain, ytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
rmsep(pred, ytest)
plotxy(vec(pred), ytest; color = (:red, .5),
    bisect = true, xlabel = "Prediction", ylabel = "Observed").f

## Variability
plotgrid(res_rep.nlv, res_rep.y1, res_rep.repl; step = 2,
    xlabel = "Nb. LVs", ylabel = "RMSEP", leg = false).f

## Parcimony
res_sel = selwold(res.nlv, res.y1; smooth = false, 
    alpha = .05, graph = true) ;
pnames(res)
res_sel.f       # Plots
res_sel.opt     # Nb. LVs correponding to the minimal error rate
res_sel.sel     # Nb LVs selected with the Wold's criterion
fm = plskern(Xtrain, ytrain; nlv = res_sel.sel) ;
pred = Jchemo.predict(fm, Xtest).pred
rmsep(pred, ytest)

## gridcv can also be used
## but this is not time-efficient
## for LV_based methods
nlv = 0:20
pars = mpar(nlv = nlv)
rescv = gridcv(Xtrain, ytrain; segm = segm, 
    score = rmsep, fun = plskern, pars = pars, 
    verbose = true) ;
pnames(rescv)

