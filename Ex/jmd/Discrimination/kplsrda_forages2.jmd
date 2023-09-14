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
gamma = .001
fm = kplsrda(Xtrain, ytrain; nlv = 15, 
    gamma = gamma, scal = true) ;
pnames(fm)

```julia
pnames(fm.fm)

```julia
typeof(fm.fm)

```julia
res = Jchemo.predict(fm, Xtest)
pnames(res)

```julia
pred = res.pred

```julia
res.posterior

```julia
err(pred, ytest)

```julia
cf = confusion(pred, ytest) ;
cf.cnt

```julia
cf.pct

```julia
plotconf(cf).f

