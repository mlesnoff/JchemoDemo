using JLD2, CairoMakie, StatsBase
using Jchemo, JchemoData

path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/iris.jld2")
@load db dat
pnames(dat)
summ(dat.X)

X = dat.X[:, 1:4]
y = dat.X[:, 5]
n = nro(X)

ntrain = 120
s = sample(1:n, ntrain; replace = false)
Xtrain = X[s, :]
ytrain = y[s]
Xtest = rmrow(X, s)
ytest = rmrow(y, s)

tab(ytrain)
tab(ytest)

######## End Data

fm = fda(Xtrain, ytrain; nlv = 2) ;
#fm = fdasvd(Xtrain, ytrain; nlv = 2) ;
pnames(fm)
lev = fm.lev
nlev = length(lev)

fm.T
# Class centers projected on the score space
ct = fm.Tcenters

f, ax = plotxy(fm.T[:, 1], fm.T[:, 2], ytrain;
    ellipse = true, title = "FDA", zeros = true)
scatter!(ax, ct[:, 1], ct[:, 2],
    markersize = 10, color = :red)
f

# Projection of Xtest to the score space
Ttest = Jchemo.transform(fm, Xtest)

# X-loadings matrix
# = coefficients of the linear discriminant function
# = "LD" of function lda of package MASS
fm.P
fm.P' * fm.P    # not orthogonal

fm.eig
fm.sstot
# Explained variance by PCA of the class centers
# in transformed scale
summary(fm)

