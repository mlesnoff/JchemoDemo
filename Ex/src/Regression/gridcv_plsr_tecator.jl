using JLD2, CairoMakie
using Jchemo, JchemoData
using Loess

path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/tecator.jld2") 
@load db dat
pnames(dat)

X = dat.X
Y = dat.Y 
ntot = nro(X)


@head X
@head Y

summ(Y)

namy = names(Y)[1:3]

typ = Y.typ
tab(typ)

wl = names(X)
wl_num = parse.(Float64, wl) 

plotsp(X, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

## Preprocessing
f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 

plotsp(Xp, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

## Split Tot = Train + Test
## The model is tuned on Train, and
## the generalization error is estimated on Test.
## Here the split of Tot is provided by the dataset
## (= variable `typ`), but Tot could be split 
## a posteriori (e.g. random sampling, systematic 
## sampling, etc.) 
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
nam = namy[j]    # y-variable
ytrain = Ytrain[:, nam]
ytest = Ytest[:, nam]

## The cross-validation (CV) is done within Train, 
## and the generalization error is estimated on Test.
## Two methods can be used to build the 
## segments within Train:
## (1) Replicated K-fold CV
## ==> Train is splitted in a number of K folds (segments)
## ==> and the process can be replicated
K = 3     # nb. folds (segments)
rep = 10  # nb. replications
segm = segmkf(ntrain, K; rep = rep)
## (2) Or replicated "Test-set" CV 
## ==> splitting Train = Cal + Val
## ==> and the process can be replicated
## e.g. Cal = 70% of Train, Val = 30% of Train
#pct = .30
#m = round(pct * ntrain)
#segm = segmts(ntrain, m; rep = 30)

i = 1  
k = 1
segm[i]      # the K segments of replication 'i'

segm[i][k]   # segment 'k' of replication 'i'

## Model tuning
nlv = 0:20
rescv = gridcvlv(Xtrain, ytrain; segm = segm, 
    score = rmsep, fun = plskern, nlv = nlv, 
    verbose = false) ;
pnames(rescv)

## Variability of the performance 
## between segments (folds) and replications
res_rep = rescv.res_rep

group = string.(res_rep.segm, "-", res_rep.repl)
plotgrid(res_rep.nlv, res_rep.y1, group; step = 2,
    xlabel = "Nb. LVs", ylabel = "RMSEP", leg = false).f

## Average results over the segments (folds) 
## and the replications
res = rescv.res

plotgrid(res.nlv, res.y1; step = 2,
    xlabel = "Nb. LVs", ylabel = "RMSEP").f

# Find the minimal prediction error
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]

## Final prediction (Test) using the optimal model
fm = plskern(Xtrain, ytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred

## Generalization error
rmsep(pred, ytest)

```julia 
## Plotting predictions vs. observed data 
zpred = vec(pred)
f, ax = plotxy(zpred, ytest;
    xlabel = "Predicted", ylabel = "Observed",
    resolution = (500, 400))
zfm = loess(zpred, ytest; span = 2/3) ;
pred_loess = Loess.predict(zfm, sort(zpred))
lines!(ax, sort(zpred), pred_loess; color = :red)
ablines!(ax, 0, 1; color = :grey)
f 

## A parcimony approach
## Wold's criterion
res_sel = selwold(res.nlv, res.y1; smooth = false, 
    alpha = .05, graph = true) ;
pnames(res)

res_sel.f       # plots

res_sel.opt     # nb. LVs correponding to the minimal error rate

res_sel.sel     # nb. LVs selected with the Wold's criterion

## Final prediction with the parcimonious model
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
    verbose = false).res
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]

