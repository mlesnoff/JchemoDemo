
using Jchemo, JchemoData
using JLD2, CairoMakie


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data", "iris.jld2") 
@load db dat
pnames(dat)


summ(dat.X)


X = dat.X[:, 1:4] 
y = dat.X[:, 5]
n = nro(X)


@head X


tab(y)


lev = unique(y)


nlev = length(lev)


ntest = 30
s = samprand(n, ntest)
Xtrain = X[s.train, :]
ytrain = y[s.train]
Xtest = X[s.test, :]
ytest = y[s.test]


tab(ytrain)


tab(ytest)


mo = fda(nlv = 2)
#mo = fdasvd(nlv = 2)     # alternative algorithm (same result)
fit!(mo, Xtrain, ytrain) 
fm = mo.fm 
pnames(fm)


lev = fm.lev


nlev = length(lev)


@head Ttrain = mo.fm.T


ct = mo.fm.Tcenters


f, ax = plotxy(Ttrain[:, 1], Ttrain[:, 2], ytrain;
    ellipse = true, title = "FDA", zeros = true)
scatter!(ax, ct[:, 1], ct[:, 2],
    markersize = 10, color = :red)
f


@head Ttest = transf(mo, Xtest)


P = mo.fm.P


P' * P    # not orthogonal


mo.fm.eig


mo.fm.sstot


summary(mo)

