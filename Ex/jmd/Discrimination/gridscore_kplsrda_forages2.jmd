using JLD2, CairoMakie
using StatsBase, FreqTables 
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
## Train ==> Cal + Val
pct = .30
nval = Int64.(round(pct * ntrain))
ncal = ntrain - nval 
s = sample(1:ntrain, nval; replace = false)
Xcal = rmrow(Xtrain, s) 
ycal = rmrow(ytrain, s) 
Xval = Xtrain[s, :] 
yval = ytrain[s] 
(ntot = ntot, ntrain, ncal, nval, ntest)

```julia
nlv = 0:50
gamma = 10.0.^(-5:3)
pars = mpar(gamma = gamma)

```julia
length(pars[1])

```julia
res = gridscorelv(Xcal, ycal, Xval, yval; 
    score = err, fun = kplsrda, pars = pars, nlv = nlv)

```julia
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]

```julia
plotgrid(res.nlv, res.y1, res.gamma; step = 5,
    xlabel = "Nb. LVs", ylabel = "ERR").f

```julia
fm = kplsrda(Xtrain, ytrain; nlv = res.nlv[u],
    gamma = res.gamma[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
err(pred, ytest)

```julia
cf = confusion(pred, ytest) ;
cf.cnt

```julia
cf.pct

```julia
plotconf(cf).f
