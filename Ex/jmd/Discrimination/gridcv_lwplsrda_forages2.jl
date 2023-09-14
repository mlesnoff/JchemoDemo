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
K = 3 ; segm = segmkf(ntrain, K; rep = 1)       # K-fold CV  
#m = 100 ; segm = segmts(ntrain, m; rep = 3)    # Test-set CV

```julia
nlvdis = [25] ; metric = ["mahal"]
h = [1; 2; 5] ; k = [100; 250; 500]
nlv = 0:15
pars = mpar(nlvdis = nlvdis, metric = metric, h = h, 
    k = k)

```julia
length(pars[1])

```julia
res = gridcvlv(Xtrain, ytrain; segm = segm, 
    score = err, fun = lwplsrda, nlv = nlv, pars = pars, 
    verbose = false).res

```julia
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]

```julia
group = string.("metric=", res.metric, res.nlvdis, " h=", res.h, " k=", res.k)
plotgrid(res.nlv, res.y1, group; step = 2,
    xlabel = "Nb. LVs", ylabel = "ERR").f

```julia
fm = lwplsrda(Xtrain, ytrain; nlvdis = res.nlvdis[u], 
    metric = res.metric[u], h = res.h[u], k = res.k[u], 
    nlv = res.nlv[u], verbose = false) ;
pred = Jchemo.predict(fm, Xtest).pred
err(pred, ytest)

```julia
cf = confusion(pred, ytest) ;
cf.cnt

```julia
cf.pct

```julia
plotconf(cf).f

