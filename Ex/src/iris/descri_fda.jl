
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


lev = mlev(y)


nlev = length(lev)


ntest = 30
s = samprand(n, ntest)
Xtrain = X[s.train, :]
ytrain = y[s.train]
Xtest = X[s.test, :]
ytest = y[s.test]


tab(ytrain)


tab(ytest)


model = fda(nlv = 2)
#model = fdasvd(nlv = 2)     # alternative algorithm (same result)
fit!(model, Xtrain, ytrain) 
fitm = model.fitm 
pnames(fitm)


lev = fitm.lev


nlev = length(lev)


@head Ttrain = model.fitm.T


ct = model.fitm.Tcenters


f, ax = plotxy(Ttrain[:, 1], Ttrain[:, 2], ytrain; ellipse = true, title = "Fda", zeros = true)
scatter!(ax, ct[:, 1], ct[:, 2], markersize = 10, color = :red)
f


@head Ttest = transf(model, Xtest)


V = model.fitm.V


V' * V    # not orthogonal


model.fitm.eig


model.fitm.sstot


summary(model)

