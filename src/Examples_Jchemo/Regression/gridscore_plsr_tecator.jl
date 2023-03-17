using JLD2, CairoMakie, StatsBase
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
ntot = nro(X)
typ = Y.typ
namy = names(Y)[1:3]

plotsp(X, wl_num,
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 
plotsp(Xp, wl_num,
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

## Work on the second y-variable 
j = 2
nam = namy[j]
ytrain = Ytrain[:, nam]
ytest = Ytest[:, nam]

## Build the splitting Train = Cal + Val
pct = .30
nval = Int64(round(pct * ntrain))    # or: nval = 40
## Different choices:
## (1) Random sampling
s = sample(1:ntrain, nval; replace = false)
## (2) Systematic sampling over y
res = sampsys(ytrain; k = nval)
s = res.train
ytrain[s]
## (3) Kennard-Stone sampling
## Output 'train' contains higher variability
## than output 'test'
res = sampks(Xtrain; k = nval)
s = res.train
## (4) Duplex sampling
res = sampdp(Xtrain; k = nval)
s = res.train
## Selection
Xcal = rmrow(Xtrain, s)
ycal = rmrow(ytrain, s)
Xval = Xtrain[s, :]
yval = ytrain[s, :]

## Tuning
nlv = 0:20
res = gridscorelv(Xcal, ycal, Xval, yval; 
    score = rmsep, fun = plskern, nlv = nlv) 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
plotgrid(res.nlv, res.y1; step = 2,
    xlabel = "Nb. LVs", ylabel = "RMSEP").f

## Prediction for the optimal model
fm = plskern(Xtrain, ytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
rmsep(pred, ytest)
plotxy(vec(pred), ytest; color = (:red, .5), step = 2,
    bisect = true, xlabel = "Prediction", 
    ylabel = "Observed (Test)").f

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

## Remark!!!
## Function 'gridscore' is generic for all the functions.
## Here, 'gridscore' could be used instead of 'gridscorelv' 
## but this is not time-efficient for LV-based methods.
## Commands below return the same results as 
## with 'gridscorelv'
nlv = 0:20
pars = mpar(nlv = nlv)
res = gridscore(Xcal, ycal, Xval, yval;  
    score = rmsep, fun = plskern, pars = pars) 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]

