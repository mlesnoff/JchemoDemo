
using Jchemo, JchemoData
using JLD2, CairoMakie
using FreqTables


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/forages2.jld2") 
@load db dat
@names dat


X = dat.X 
Y = dat.Y
ntot = nro(X)
y = Y.typ ;
test = Y.test ;
tab(y)


freqtable(y, test)


wlst = names(X)
wl = parse.(Int, wlst) ;
#plotsp(X, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


s = Bool.(test) ;
Xtrain = rmrow(X, s) ;
ytrain = rmrow(y, s) ;
Xtest = X[s, :] ;
ytest = y[s] ;
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)


model0 = pcasvd(nlv = 10)
fit!(model0, Xtrain)
@names model0
@names model0.fitm


@head Ttrain_pca = model0.fitm.T


model = fda(nlv = 2)
#model = fdasvd(nlv = 2)     # alternative algorithm (same result)
fit!(model, Ttrain_pca, ytrain) 
fitm = model.fitm ;
@names fitm


@head Ttrain = model.fitm.T


lev = fitm.lev
nlev = length(lev)


ct = fitm.Tcenters


f, ax = plotxy(Ttrain[:, 1], Ttrain[:, 2], ytrain; title = "Fda", ellipse = true) ;
scatter!(ax, ct[:, 1], ct[:, 2], markersize = 10, color = :red) ;
f


color = cgrad(:lightrainbow, nlev; categorical = true, alpha = .5) ;
f, ax = plotxy(Ttrain[:, 1], Ttrain[:, 2], ytrain; color, title = "Fda", ellipse = true) ;
scatter!(ax, ct[:, 1], ct[:, 2]; markersize = 10, color = :red) ;
f


@head Ttest_pca = transf(model0, Xtest)


@head Ttest = transf(model, Ttest_pca)


i = 1  # class "i" in test
color = cgrad(:lightrainbow, nlev; categorical = true, alpha = .5) ;
f, ax = plotxy(Ttrain[:, 1], Ttrain[:, 2], ytrain; color, title = "Fda", ellipse = true) ;
scatter!(ax, ct[:, 1], ct[:, 2]; markersize = 10, color = :red) ;
s = ytest .== lev[i] ;
zT = Ttest[s, :] ;
scatter!(ax, zT[:, 1], zT[:, 2]; markersize = 10, color = :blue)
f


lb = 1e-5
model = fda(; nlv = 2, lb)
#model = fdasvd(; nlv = 2, lb)
fit!(model, Xtrain, ytrain)
fitm = model.fitm ;


lev = fitm.lev
nlev = length(lev)


ct = fitm.Tcenters


@head Ttrain = fitm.T


f, ax = plotxy(Ttrain[:, 1], Ttrain[:, 2], ytrain; title = "Fda", ellipse = true) ;
scatter!(ax, ct[:, 1], ct[:, 2]; markersize = 10, color = :red) ;
f


color = cgrad(:lightrainbow, nlev; categorical = true, alpha = .7) ;
f, ax = plotxy(Ttrain[:, 1], Ttrain[:, 2], ytrain; color, title = "Fda", ellipse = true) ;
scatter!(ax, ct[:, 1], ct[:, 2]; markersize = 10, color = :red) ;
f


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

