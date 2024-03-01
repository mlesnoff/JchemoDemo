
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


mod = fda(nlv = 2)
#mod = fdasvd(nlv = 2)     # alternative algorithm (same result)
fit!(mod, Xtrain, ytrain) 
fm = mod.fm 
pnames(fm)


lev = fm.lev


nlev = length(lev)


@head Ttrain = mod.fm.T


ct = mod.fm.Tcenters


f, ax = plotxy(Ttrain[:, 1], Ttrain[:, 2], ytrain; ellipse = true, 
    title = "FDA", zeros = true)
scatter!(ax, ct[:, 1], ct[:, 2], markersize = 10, color = :red)
f


@head Ttest = transf(mod, Xtest)


P = mod.fm.P


P' * P    # not orthogonal


mod.fm.eig


mod.fm.sstot


summary(mod)

