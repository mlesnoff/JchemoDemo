
using Jchemo, JchemoData
using JLD2, CairoMakie


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data", "iris.jld2") 
@load db dat
@names dat


summ(dat.X)


@head X = dat.X[:, 1:4] 
@head y = dat.X[:, 5]    # the classes (species)
ntot = nro(X)


tab(y)


lev = mlev(y)
nlev = length(lev)


ntest = 30
s = samprand(ntot, ntest)
Xtrain = X[s.train, :] ;
ytrain = y[s.train] ;
Xtest = X[s.test, :] ;
ytest = y[s.test] ;
ntrain = ntot - ntest
(ntot = ntot, ntrain, ntest)
tab(ytrain)
tab(ytest)


model = fda(nlv = 2)
#model = fdasvd(nlv = 2)     # alternative algorithm (same result)
fit!(model, Xtrain, ytrain) 
fitm = model.fitm ;
@names fitm


lev = fitm.lev
nlev = length(lev)


@head Ttrain = fitm.T


ct = fitm.Tcenters


f, ax = plotxy(Ttrain[:, 1], Ttrain[:, 2], ytrain; title = "Fda", ellipse = true)
scatter!(ax, ct[:, 1], ct[:, 2]; markersize = 10, color = :red)
f


color = cgrad(:lightrainbow, nlev; categorical = true, alpha = .7) ;
f, ax = plotxy(Ttrain[:, 1], Ttrain[:, 2], ytrain; color, title = "Fda", ellipse = true)
scatter!(ax, ct[:, 1], ct[:, 2]; markersize = 10, color = :red)
f


V = fitm.V


V' * V    # not orthogonal


fitm.eig


fitm.sstot


summary(model)


@head Ttest = transf(model, Xtest)


i = 1  # class "i" in test
color = cgrad(:lightrainbow, nlev; categorical = true, alpha = .7) ;
f, ax = plotxy(Ttrain[:, 1], Ttrain[:, 2], ytrain; color, 
    title = string("Projection test-class ", lev[i], " (blue points)"), ellipse = true) ;
scatter!(ax, ct[:, 1], ct[:, 2]; markersize = 10, color = :red) ;
s = ytest .== lev[i] ;
zT = Ttest[s, :] ;
scatter!(ax, zT[:, 1], zT[:, 2]; markersize = 10, color = :blue) ;
f

