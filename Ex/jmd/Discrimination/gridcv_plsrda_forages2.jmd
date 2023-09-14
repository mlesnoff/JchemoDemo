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
K = 3 ; segm = segmkf(ntrain, K; rep = 10)         # K-fold CV   
#m = 100 ; segm = segmts(ntrain, m; rep = 30)      # Test-set CV

```julia
nlv = 0:50
res = gridcvlv(Xtrain, ytrain; segm = segm, 
    score = err, fun = plsrda, nlv = nlv, verbose = false).res

```julia
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]

```julia
plotgrid(res.nlv, res.y1; step = 5,
    xlabel = "Nb. LVs", ylabel = "ERR").f

```julia
fm = plsrda(Xtrain, ytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
err(pred, ytest)

```julia
cf = confusion(pred, ytest) ;
cf.cnt

```julia
cf.pct

```julia
plotconf(cf).f

```julia
## PLSLDA
nlv = 1:50  ## !!: Does not start from nlv=0 (since LDA on scores)
res = gridcvlv(Xtrain, ytrain; segm = segm, 
    score = err, fun = plslda, nlv = nlv, verbose = false).res

```julia
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]

```julia
plotgrid(res.nlv, res.y1; step = 5,
    xlabel = "Nb. LVs", ylabel = "ERR").f

```julia
fm = plslda(Xtrain, ytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
err(pred, ytest)

