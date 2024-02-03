
using Jchemo, JchemoData
using JLD2, CairoMakie, FreqTables


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/forages2.jld2") 
@load db dat
pnames(dat)


X = dat.X 
Y = dat.Y
ntot = nro(X)


@head X
@head Y


y = Y.typ
tab(y)


freqtable(y, Y.test)


wlst = names(X)
wl = parse.(Float64, wlst)


plotsp(X, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


s = Bool.(Y.test)
Xtrain = rmrow(X, s)
ytrain = rmrow(y, s)
Xtest = X[s, :]
ytest = y[s]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)


mod0 = pcasvd(nlv = 10)
fit!(mod0, Xtrain)
pnames(mod0)
pnames(mod0.fm)


Ttrain_pca = mod0.fm.T


mod = fda(nlv = 2)
#mod = fdasvd(nlv = 2)     # alternative algorithm (same result)
fit!(mod, Ttrain_pca, ytrain) 
fm = mod.fm 
pnames(fm)


Ttrain = mod.fm.T


lev = fm.lev
nlev = length(lev)


ct = fm.Tcenters


f, ax = plotxy(Ttrain[:, 1], Ttrain[:, 2], ytrain; 
    title = "FDA", ellipse = true)
scatter!(ax, ct[:, 1], ct[:, 2], markersize = 10, 
    color = :red)
f


Ttest_pca = transf(mod0, Xtest)


Ttest = transf(mod, Ttest_pca)


i = 1  # class 
f, ax = plotxy(Ttrain[:, 1], Ttrain[:, 2], ytrain; 
    title = "FDA")
scatter!(ax, ct[:, 1], ct[:, 2], markersize = 10, color = :red)
s = ytest .== lev[i]
zT = Ttest[s, :]
scatter!(ax, zT[:, 1], zT[:, 2], markersize = 10, 
    color = (:purple, .8))
f


lb = 1e-5
mod = fda(; nlv = 2, lb)
#mod = fdasvd(; nlv = 2, lb)
fit!(mod,Xtrain, ytrain)


lev = fm.lev
nlev = length(lev)


ct = fm.Tcenters


Ttrain = fm.T


f, ax = plotxy(Ttrain[:, 1], Ttrain[:, 2], ytrain;
    title = "FDA", ellipse = true)
scatter!(ax, ct[:, 1], ct[:, 2]; markersize = 10, 
    color = :red)
f


Ttest = transf(mod, Xtest)


i = 1  # class 
f, ax = plotxy(Ttrain[:, 1], Ttrain[:, 2], ytrain;
    title = "FDA")
scatter!(ax, ct[:, 1], ct[:, 2],
    markersize = 10, color = :red)
s = ytest .== lev[i]
zT = Ttest[s, :]
scatter!(ax, zT[:, 1], zT[:, 2],
    markersize = 10, color = (:purple, .8))
f

