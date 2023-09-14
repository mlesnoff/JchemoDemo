using JLD2, CairoMakie, StatsBase
using Jchemo, JchemoData

```julia
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data", "iris.jld2") 
@load db dat

```julia
pnames(dat)

```julia
summ(dat.X)

```julia
X = dat.X[:, 1:4] 
y = dat.X[:, 5]
n = nro(X)
  
```julia term = true
@head X

```julia
tab(y)

```julia
ntrain = 120
s = sample(1:n, ntrain; replace = false)
Xtrain = X[s, :]
ytrain = y[s]
Xtest = rmrow(X, s)
ytest = rmrow(y, s)

```julia
tab(ytrain)

```julia
tab(ytest)

```julia
fm = fda(Xtrain, ytrain; nlv = 2) ;
#fm = fdasvd(Xtrain, ytrain; nlv = 2) ;
pnames(fm)

```julia
lev = fm.lev

```julia
nlev = length(lev)

```julia term = true
@head fm.T

```julia
## Class centers projected on the score space
ct = fm.Tcenters

```julia
f, ax = plotxy(fm.T[:, 1:2], ytrain;
    ellipse = true, title = "FDA", zeros = true)
scatter!(ax, ct[:, 1], ct[:, 2],
    markersize = 10, color = :red)
f

```julia
## Projection of Xtest to the score space
Ttest = Jchemo.transform(fm, Xtest)

```julia
## X-loadings matrix
## Columns of P = coefficients of the linear discriminant function
## = "LD" of function lda of package MASS
fm.P

```julia
fm.P' * fm.P    # not orthogonal

```julia
fm.eig

```julia
fm.sstot

```julia
## Explained variance by PCA of the class centers
## in transformed scale
summary(fm)

