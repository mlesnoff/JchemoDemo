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

K = 3
segm = segmkf(ntrain, K; rep = 10)

```julia
## PLS-LDA
nlv = 1:50
rescv = gridcvlv(Xtrain, ytrain; segm = segm,
    score = err, fun = plslda, nlv = nlv) ; 
res = rescv.res

```julia
plotgrid(res.nlv, res.y1; step = 5,
    xlabel = "Nb. LVs", ylabel = "Err-CV").f

```julia
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]

```julia
fm = plslda(Xtrain, ytrain; nlv = res.nlv[u]) ;
res = Jchemo.predict(fm, Xtest) ;
pred = res.pred
err(pred, ytest)

```julia
confusion(pred, ytest).pct

```julia
## PLS-KDE-DA
pars = mpar(a = [.5, 1, 1.5])

```julia
nlv = 1:50
rescv = gridcvlv(Xtrain, ytrain; segm = segm,
    score = err, fun = plskdeda, pars = pars, nlv = nlv) ; 
res = rescv.res

```julia
group = string.("a = ", res.a)
plotgrid(res.nlv, res.y1, group; step = 2,
    xlabel = "Nb. LVs", ylabel = "Err-CV").f

```julia
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]

```julia
fm = plskdeda(Xtrain, ytrain; nlv = res.nlv[u],
    a = res.a[u]) ;
res = Jchemo.predict(fm, Xtest) ;
pred = res.pred
err(pred, ytest)

```julia
confusion(pred, ytest).pct
