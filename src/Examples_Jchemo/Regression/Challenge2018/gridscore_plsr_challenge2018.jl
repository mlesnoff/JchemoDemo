using JLD2, CairoMakie, StatsBase
using Jchemo, JchemoData
using FreqTables

path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/challenge2018.jld2") 
@load db dat
pnames(dat)

X = dat.X 
Y = dat.Y
y = Y.conc
typ = Y.typ
label = Y.label 
test = Y.test
wl = names(X)
wl_num = parse.(Float64, wl)
ntot = nro(X)

summ(Y)

freqtable(string.(typ, "-", Y.label))
freqtable(typ, test)

f = 21 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) ;
plotsp(Xp, wl_num; nsamp = 20).f

## Splitting Tot = Train + Test
## The model is tuned on Train, and
## the generalization error is estimated on Test.
## Here the splitting of Tot is provided by the dataset
## (= variable "test"), but data Tot could be splitted 
## a posteriori (e.g. random sampling, systematic sampling, etc.) 
s = Bool.(test)
Xtrain = rmrow(Xp, s)
ytrain = rmrow(y, s)
Xtest = Xp[s, :]
ytest = y[s]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)

## Build the splitting Train = Cal + Val
## The model will be fitted on cal and 
## optimized on Val
nval = 300
## Or:
#pct = .20
#nval = Int64(round(pct * ntrain))    

## Different choices to select Val
## (1) Random sampling
s = sample(1:ntrain, nval; replace = false)
ytrain[s]

## (2) Kennard-Stone sampling
## Output 'train' contains higher variability
## than output 'test'
res = sampks(Xtrain; k = nval)
s = res.train
ytrain[s]

## (3) Duplex sampling
res = sampdp(Xtrain; k = nval)
s = res.train
ytrain[s]

## (4) Systematic sampling over y
res = sampsys(ytrain; k = nval)
s = res.train
ytrain[s]

## Selection
Xcal = rmrow(Xtrain, s)
ycal = rmrow(ytrain, s)
Xval = Xtrain[s, :]
yval = ytrain[s, :]
ncal = ntrain - nval 
(ntot = ntot, ntrain, ntest, ncal, nval)

## Tuning
nlv = 0:50
res = gridscorelv(Xcal, ycal, Xval, yval; 
    score = rmsep, fun = plskern, nlv = nlv) 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
plotgrid(res.nlv, res.y1; step = 5,
    xlabel = "Nb. LVs", ylabel = "RMSEP").f

## Prediction of Test using the optimal model
fm = plskern(Xtrain, ytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
rmsep(pred, ytest)
plotxy(vec(pred), ytest; resolution = (500, 400),
    color = (:red, .5), bisect = true, 
    xlabel = "Prediction", ylabel = "Observed (Test)").f  

## Parcimony approach
res_sel = selwold(res.nlv, res.y1; smooth = true, 
    f = 20, alpha = .05, graph = true) ;
pnames(res)
res_sel.f       # Plots
res_sel.opt     # Nb. LVs correponding to the minimal error rate
res_sel.sel     # Nb LVs selected with the Wold's criterion
fm = plskern(Xtrain, ytrain; nlv = res_sel.sel) ;
pred = Jchemo.predict(fm, Xtest).pred
rmsep(pred, ytest)

## !!! Remark
## Function 'gridscore' is generic for all the functions.
## Here, 'gridscore' could be used instead of 'gridscorelv' 
## but this is not time-efficient for LV-based methods.
## Commands below return the same results as 
## with 'gridscorelv', but in a slower way
nlv = 0:50
pars = mpar(nlv = nlv)
res = gridscore(Xcal, ycal, Xval, yval;  
    score = rmsep, fun = plskern, pars = pars) 
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
fm = plskern(Xtrain, ytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
rmsep(pred, ytest)
