using JLD2, CairoMakie, StatsBase
using Jchemo, JchemoData
using FreqTables

#-
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/challenge2018.jld2") 
@load db dat
pnames(dat)

#-
X = dat.X 
Y = dat.Y
ntot = nro(X)

#-
@head X

#-
@head Y

#-
summ(Y)

#-
y = Y.conc
typ = Y.typ
label = Y.label 
test = Y.test
tab(test)

#-
wl = names(X)
wl_num = parse.(Float64, wl)

#-
freqtable(string.(typ, "-", Y.label))

#-
freqtable(typ, test)

#-
plotsp(X, wl_num; nsamp = 30).f

#-
f = 21 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) ;

plotsp(Xp, wl_num; nsamp = 30).f

#-
## Split Tot = Train + Test
## The model is tuned on Train, and
## the generalization error is estimated on Test.
## Here the split of Tot is provided by the dataset
## (= variable 'test'), but Tot could be split 
## a posteriori (e.g. random sampling, systematic 
## sampling, etc.) 
s = Bool.(test)
Xtrain = rmrow(Xp, s)
ytrain = rmrow(y, s)
Xtest = Xp[s, :]
ytest = y[s]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)

#-
## Build the split Train = Cal + Val
## The model will be fitted on cal and 
## optimized on Val
nval = 300
## Or:
#pct = .20
#nval = Int64(round(pct * ntrain))    

#-
## Different methods can be used to select Val
## (1) Random sampling
s = sample(1:ntrain, nval; replace = false)

## (2) Or Kennard-Stone sampling
## Output 'train' contains higher variability
## than output 'test'
#res = sampks(Xtrain; k = nval)
#s = res.train

## (3) Or duplex sampling
#res = sampdp(Xtrain; k = nval)
#s = res.train

## (4) Or systematic sampling over y
#res = sampsys(ytrain; k = nval)
#s = res.train

#-
Xcal = rmrow(Xtrain, s)
ycal = rmrow(ytrain, s)
Xval = Xtrain[s, :]
yval = ytrain[s, :]
ncal = ntrain - nval 
(ntot = ntot, ntrain, ntest, ncal, nval)

#-
## Model tuning
nlv = 0:50
res = gridscorelv(Xcal, ycal, Xval, yval; 
    score = rmsep, fun = plskern, nlv = nlv) 

#-
plotgrid(res.nlv, res.y1; step = 5,
    xlabel = "Nb. LVs", ylabel = "RMSEP").f

#-
## Find the minimal prediction error
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]

#-
## Final prediction (Test) using the optimal model
fm = plskern(Xtrain, ytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred

#-
## Generalization error
rmsep(pred, ytest)

#- 
## Plotting predictions vs. observed data 
plotxy(vec(pred), ytest; color = (:red, .5),
    bisect = true, xlabel = "Prediction", 
    ylabel = "Observed (Test)").f

#-
## A parcimony approach
## Wold's criterion
res_sel = selwold(res.nlv, res.y1; smooth = true, 
    alpha = .025, f = 10, step = 5, graph = true) ;
pnames(res)

#-
res_sel.f       # plots

#-
res_sel.opt     # nb. LVs correponding to the minimal error rate

#-
res_sel.sel     # nb. LVs selected with the Wold's criterion

#-
## Final prediction with the parcimonious model
fm = plskern(Xtrain, ytrain; nlv = res_sel.sel) ;
pred = Jchemo.predict(fm, Xtest).pred
@show rmsep(pred, ytest)

#-
## !!! Remark
## Function "gridscore" is generic for all the functions.
## Here, it could be used instead of "gridscorelv" 
## but this is not time-efficient for LV-based methods.
## Commands below return the same results as 
## with 'gridscorelv', but in a slower way
nlv = 0:50
pars = mpar(nlv = nlv)
res = gridscore(Xcal, ycal, Xval, yval;  
    score = rmsep, fun = plskern, pars = pars) 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
