using JLD2, CairoMakie, FreqTables 
using Jchemo, JchemoData

path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/forages2.jld2") 
@load db dat
pnames(dat)
  
X = dat.X 
Y = dat.Y
y = Y.typ
test = Y.test
wl = names(X)
wl_num = parse.(Float64, wl)
ntot = nro(X)

tab(y)
freqtable(y, test)

plotsp(X, wl_num).f

s = Bool.(test)
Xtrain = rmrow(X, s)
ytrain = rmrow(y, s)
Xtest = X[s, :]
ytest = y[s]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)

## X contains high multicolinearities
## ==> a regularization is required for the FDA, 
## for instance:
## 1) by preliminary dimension reduction 
## 2) or using a ridge regularization

## 1) FDA on PCA scores
zfm = pcasvd(Xtrain; nlv = 10) ;
Ttrain = zfm.T 
fm = fda(Ttrain, ytrain; nlv = 2) ;
#fm = fdasvd(Ttrain, ytrain; nlv = 2) ;
pnames(fm)
lev = fm.lev
nlev = length(lev)
plotxy(fm.T[:, 1:2], ytrain;
    resolution = (800, 400), ellipse = true, 
    title = "FDA").f

## 2) FDA using ridge regularization
## If lb is too small (e.g. 1e-10) 
## the model overfits the discrimination of new observations
lb = 1e-5
fm = fda(Xtrain, ytrain; nlv = 2, lb = lb) ;
#fm = fdasvd(Xtrain, ytrain; nlv = 2, lb = lb) ;
pnames(fm)
lev = fm.lev
nlev = length(lev)
ct = fm.Tcenters
Ttrain = fm.T
f, ax = plotxy(Ttrain[:, 1:2], ytrain;
    title = "FDA", ellipse = true)
scatter!(ax, ct[:, 1], ct[:, 2],
    markersize = 10, color = :red)
f
Ttest = Jchemo.transform(fm, Xtest)
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

