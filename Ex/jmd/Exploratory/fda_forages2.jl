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
## Tot ==> Train + Test
s = Bool.(Y.test)
Xtrain = rmrow(X, s)
ytrain = rmrow(y, s)
Xtest = X[s, :]
ytest = y[s]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)

```julia
## X contains high multicolinearities
## ==> a regularization is required for the FDA, 
## for instance:
## 1) by preliminary dimension reduction 
## 2) or using a ridge regularization

## 1) FDA on PCA scores
fm0 = pcasvd(Xtrain; nlv = 10) ;
pnames(fm0)

```julia
Ttrain_pca = fm0.T 

```julia
fm = fda(Ttrain_pca, ytrain; nlv = 2) ;
#fm = fdasvd(Ttrain_pca, ytrain; nlv = 2) ;
pnames(fm)

```julia
Ttrain = fm.T

```julia
lev = fm.lev
nlev = length(lev)

```julia
plotxy(Ttrain[:, 1:2], ytrain;
    resolution = (800, 400), ellipse = true, 
    title = "FDA").f

```julia
## 2) FDA directly on X
## ==> using ridge regularization
## Rq: If lb is too small (e.g. here 1e-10) 
## the model can overfit the discrimination of new observations
lb = 1e-5
fm = fda(Xtrain, ytrain; nlv = 2, lb = lb) ;
#fm = fdasvd(Xtrain, ytrain; nlv = 2, lb = lb) ;
pnames(fm)

```julia
lev = fm.lev
nlev = length(lev)

```julia
ct = fm.Tcenters


```julia
Ttrain = fm.T

```julia
f, ax = plotxy(Ttrain[:, 1:2], ytrain;
    title = "FDA", ellipse = true)
scatter!(ax, ct[:, 1], ct[:, 2],
    markersize = 10, color = :red)
f

```julia
## Test
Ttest = Jchemo.transform(fm, Xtest)

```julia
i = 1  # class 
f, ax = plotxy(Ttrain[:, 1:2], ytrain;
    title = "FDA")
scatter!(ax, ct[:, 1], ct[:, 2],
    markersize = 10, color = :red)
s = ytest .== lev[i]
zT = Ttest[s, :]
scatter!(ax, zT[:, 1], zT[:, 2],
    markersize = 10, color = (:purple, .8))
f

