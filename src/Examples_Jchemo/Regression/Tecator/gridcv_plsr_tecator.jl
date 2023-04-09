using JLD2, CairoMakie
using Jchemo, JchemoData
using Loess

path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data", "tecator.jld2") 
@load db dat
pnames(dat)

X = dat.X
Y = dat.Y 
wl = names(X)
wl_num = parse.(Float64, wl) 
ntot = nro(X)
typ = Y.typ
namy = names(Y)[1:3]

plotsp(X, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 
plotsp(Xp, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

s = typ .== "train"
Xtrain = Xp[s, :]
Ytrain = Y[s, namy]
Xtest = rmrow(Xp, s)
Ytest = rmrow(Y[:, namy], s)
ntrain = nro(Xtrain)
ntest = nro(Xtest)
ntot = ntrain + ntest
(ntot = ntot, ntrain, ntest)

j = 2  # y-variable
nam = namy[j]
ytrain = Ytrain[:, nam]
ytest = Ytest[:, nam]

## The CV is done within Train, and
## the generalization error is estimated on Test
## Different choices of building the segments 
## within Train
## (1) Replicated K-fold CV
K = 3
segm = segmkf(ntrain, K; rep = 10)
## (2) Replicated "Test-set" CV 
## ==> splitting Train = Cal + Val
## e.g. Val = 30% of traing (Cal = 70%)
pct = .30
m = round(pct * ntrain)
segm = segmts(ntrain, m; rep = 30)
i = 1  # segment within a replication
k = 1  # replication
segm[i]
segm[i][k]

## Tuning
nlv = 0:20
rescv = gridcvlv(Xtrain, ytrain; segm = segm, 
    score = rmsep, fun = plskern, nlv = nlv, 
    verbose = true) ;
pnames(rescv)
## Results for each replication
res_rep = rescv.res_rep
## Average results over the replications
res = rescv.res

u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
plotgrid(res.nlv, res.y1; step = 2,
    xlabel = "Nb. LVs", ylabel = "RMSEP").f

## Variability of the performance 
## between folds and replications
group = string.(res_rep.segm, "-", res_rep.repl)
plotgrid(res_rep.nlv, res_rep.y1, group; step = 2,
    xlabel = "Nb. LVs", ylabel = "RMSEP", leg = false).f

## Prediction of Test using the optimal model
fm = plskern(Xtrain, ytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
rmsep(pred, ytest)
plotxy(vec(pred), ytest; color = (:red, .5), step = 2,
    bisect = true, xlabel = "Prediction", 
    ylabel = "Observed (Test)").f

## Parcimony approach
res_sel = selwold(res.nlv, res.y1; smooth = false, 
    alpha = .05, graph = true) ;
pnames(res)
res_sel.f       # Plots
res_sel.opt     # Nb. LVs correponding to the minimal error rate
res_sel.sel     # Nb LVs selected with the Wold's criterion
fm = plskern(Xtrain, ytrain; nlv = res_sel.sel) ;
pred = Jchemo.predict(fm, Xtest).pred
rmsep(pred, ytest)

## !!! Remark
## Function "gridcv" is generic for all the functions.
## Here, it could be used instead of "gridcvlv" 
## but this is not time-efficient for LV-based methods.
## Commands below return the same results as 
## with 'gridcvlv', but in a slower way
nlv = 0:20
pars = mpar(nlv = nlv)
res = gridcv(Xtrain, ytrain; segm = segm, 
    score = rmsep, fun = plskern, pars = pars, 
    verbose = true).res
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]

