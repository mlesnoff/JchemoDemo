using JLD2, CairoMakie, FreqTables 
using Jchemo, JchemoData

```julia
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/forages2.jld2") 
@load db dat
pnames(dat)
  
```julia
X = dat.X 
Y = dat.Y
ntot = nro(X)

```julia term = true
@head X
@head Y

```julia
y = Y.typ
tab(y)

```julia
freqtable(y, Y.test)

```julia
wl = names(X)
wl_num = parse.(Float64, wl)

```julia
## X is already preprocessed
plotsp(X, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

```julia
s = Bool.(Y.test)
Xtrain = rmrow(X, s)
ytrain = rmrow(y, s)
Xtest = X[s, :]
ytest = y[s]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)

```julia
## "PLSDA" gathers different methods 
nlv = 15
fm = plsrda(Xtrain, ytrain; nlv = nlv) ;
#fm = plslda(Xtrain, ytrain; nlv = nlv) ;
#fm = plsqda(Xtrain, ytrain; nlv = nlv) ;
#fm = plsqda(Xtrain, ytrain; nlv = nlv, prior = "prop") ;

## Ridge (RR-DA) 
#fm = rrda(Xtrain, ytrain; lb = 1e-5) ;

```julia
pnames(fm)

```julia
pnames(fm.fm)

```julia
res = Jchemo.predict(fm, Xtest) ;
pnames(res)

```julia
pred = res.pred

```julia
res.posterior   # prediction of the dummy table

```julia
err(pred, ytest)

```julia
freqtable(ytest, vec(pred))

```julia
cf = confusion(pred, ytest) ;
pnames(cf)

```julia
cf.cnt

```julia
cf.pct

```julia
cf.accuracy 

```julia
plotconf(cf).f

```julia
## PLSDA with averaging
nlv = "0:20"
fm = plsrdaavg(Xtrain, ytrain; nlv = nlv) ;
pred = Jchemo.predict(fm, Xtest).pred
err(pred, ytest)
